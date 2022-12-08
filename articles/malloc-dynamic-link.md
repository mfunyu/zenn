---
title: "【malloc自作のために】共有ライブラリ差し替えとmain()の前処理を理解する"
emoji: "💨"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["malloc", "c", "dyld", "linker"]
published: false
---

この記事は、**42tokyo Advent Calendar 2022**の9日目となります🎄

https://qiita.com/advent-calendar/2022/42tokyo

こんにちは。42Tokyo在校生のU (ユウ)です。
私事ですが、今年10月に42Tokyoのファーストサークルと呼ばれる基礎課程を終了し、晴れて”卒業”いたしました！

https://note.com/u_yuu/n/n67b7bfca642b

とはいっても、42での学びを完遂したわけでは全くありません。
現在は応用課程の位置付けである、セカンドサークルの課題に取り組んでいます。

さて、前置きはここまでとして、今日はその42セカンドサークルの **"malloc"** という課題について、
> 自作mallocを実装しようと思ったけど、その前に動的リンクやらmainの前処理やらを理解する必要があった！

ということで、その道中を書き認めていこうと思います

# 動的リンクと静的リンク（リンカのはなし）

これまでに、**mallocを差し替えて、mallocが失敗した場合の挙動を確認したい！**
と思ったことがある方、多いのではないでしょうか。(特に42生)

標準ライブラリなどのほとんどのライブラリは共有ライブラリであり、実行時に動的にリンクされています。
というのは、実行ファイルの中に含まれておらず、実行時にローダが走って、必要な関数を動的ライブラリ（共有ライブラリ）から参照します。
つまり、`printf`などの標準ライブラリの関数を呼び出すとき、`./a.out`の実行ファイルの中には、`printf`の関数は含まれていません。

この動的リンクの仕組みを使えば、コンパイル済みの実行ファイルを用いて、ソースコードを変更したり、再コンパイルしたりする必要一切なしに、簡単にmalloc（だけでなくどの関数も）を差し替えることができます。

ですので、読み込む共有ライブラリを指定することで、すでにコンパイルされた実行ファイルに対して、なんの変更も加えることなく、`malloc`や`printf`を差し替えることができるのです。

# 共有ライブラリの差し替え方法

Q. では、指定した共有ライブラリ（動的ライブラリと同義）を、実行時にロードしてもらうにはどうすればいいのでしょうか。

A. 環境変数を設定します！
はい。ただ、macOSとLinuxでは変数名が違うので注意が必要です。

## macOS

```shell
export DYLD_INSERT_LIBRARIES=./libft_malloc.so
export DYLD_FORCE_FLAT_NAMESPACE=1
```
`DYLD_LIBRARY_PATH`を`DYLD_LIBRARY_PATH=.`などと設定して、`DYLD_INSERT_LIBRARIES`の変数はライブラリ名のみの指定にすることもできます。

:::message
`DYLD_FORCE_FLAT_NAMESPACE`も同時に設定する必要があります。
:::

ちなみに、各環境変数の詳細などは`man dyld`で確認することができます。

## Linux

```shell
export LD_PRELOAD=./libft_malloc.so
```

こちらも同様に`LD_LIBRARY_PATH`を使ってパスを指定することもできます。


# 実際に共有ライブラリを差し替えて関数をフックする

実際にmallocを差し替えるためには以下のような手順が必要です。
まず、動的ライブラリを何らかの方法で用意します。

```shell
$> gcc -shared -o libft_malloc.so malloc.c free.c realloc.c
```
コンパイルするならこんな感じです。

あとは環境変数を設定します。
ただし、今回は`export`してしまうと全コマンドのmallocが自作中のmallocを呼び出すようになってめちゃくちゃ不便なので、プログラムの実行時に毎回環境変数を宣言します。

```shell
$> DYLD_INSERT_LIBRARIES=./libft_malloc.so DYLD_FORCE_FLAT_NAMESPACE=1 ./a.out 
```

こうすると、そのプログラムの実行時だけに環境変数を適用できます。
今回のように`export`したくない時に非常に便利です。（全く知らなかったです。）


これで差し替えが完了です。
```c:main.c
int main() { printf("42\n"); }
```
差し替えによって、例えばこのようにmallocが呼ばれたときにそのサイズをログ出力させることができます

```shell:ubuntu
$> LD_PRELOAD=./libft_malloc.so ./a.out
malloc called: 1024
42 
```
printfがmallocを呼び出して、バッファ分の1024byteを確保していることがわかりました。

# 空のプログラムでもmallocが呼ばれる！？

関数フックの手法を理解したところで、実際にmacOSで`malloc`を置き換えてみました。
上記の通り、ubuntuではうまくいったのですが、なぜかmacOSでは期待通りの挙動になりません。

ですので、まず空のプログラムで挙動を確認しました。

## 空のmain

```c
int main() {}
```

このプログラムをmacOSで`gcc main.c`と普通にコンパイルし、
```shell:macOS
$> DYLD_INSERT_LIBRARIES=./libft_malloc.so DYLD_FORCE_FLAT_NAMESPACE=1 ./a.out
```
このようにmalloc/realloc/freeを自作のログを出力する関数と差し替えて実行すると、

```shell:macOS
$> DYLD_INSERT_LIBRARIES=./libft_malloc.so DYLD_FORCE_FLAT_NAMESPACE=1 ./a.out
malloc: size = 1536
realloc: ptr = 0x0, size = 64
malloc: size = 32
free: ptr = 0x7fae36404110
free: ptr = 0x7fae36404100
free: ptr = 0x7fae36404130
malloc: size = 32
malloc: size = 11
malloc: size = 45
malloc: size = 406
malloc: size = 45
malloc: size = 50
 (省略)
```

え？？？？

めちゃくちゃmallocが呼ばれています。なんならreallocも呼ばれています。

え？？？？？？？？？？？？？？？？

main空なのに？

## 呼び出しタイミングを探る
malloc等はどのタイミングで呼び出されたのか？を確かめるために以下の出力を追加します。
```c:main.c
__attribute__((constructor))
void init() {
	write(1, "---\n", 4);
}

int main() {}
```

このようにmain呼び出しの直前で`---`を出力するようにして再度実行すると、

```shell:macOS
$> DYLD_INSERT_LIBRARIES=./libft_malloc.so DYLD_FORCE_FLAT_NAMESPACE=1 ./a.out
malloc: size = 1536
realloc: ptr = 0x0, size = 64
malloc: size = 32
free: ptr = 0x7f99dd404110
free: ptr = 0x7f99dd404100
free: ptr = 0x7f99dd404130
malloc: size = 32
malloc: size = 11
malloc: size = 45
malloc: size = 406
malloc: size = 45
malloc: size = 50
malloc: size = 47
malloc: size = 14
malloc: size = 64
malloc: size = 52
malloc: size = 54
malloc: size = 12
malloc: size = 45
malloc: size = 119
free: ptr = 0x0
malloc: size = 16
malloc: size = 64
malloc: size = 14
---
$>
```
`---`は一番最後に出力されました。

これらのmalloc/realloc/freeの呼び出しは、全てmainの実行前だということがわかりました。
では、これらのmalloc等の呼び出しはどこから来たのでしょうか。

## mallocをトレースする

どこでmallocが呼ばれたのかを探るために、`malloc_history`を使ってみます

:::message
詳細は`man malloc_history`で！
:::

まず、ループするプログラムをコンパイルします。
```c:main.c
int main() { while(1); }
```

そして、`MallocStackLogging`という環境変数を（ライブラリの指定に加えて）設定して実行します。
```shell:macOS
$> DYLD_INSERT_LIBRARIES=./libft_malloc.so DYLD_FORCE_FLAT_NAMESPACE=1 MallocStackLogging=1 ./a.out
```

このプログラムを動かしながら、同時に

```shell:macOS
$> malloc_history -callTree -showConten a.out
```

と実行します。これで、（長いので出力の前後省略しますが）以下のような出力を得ることができました。

```shell:macOS
 (省略)
Call graph:
    1 (4.00K) _dyld_start  (in dyld) + 37  [0x10e264025]
      1 (4.00K) dyldbootstrap::start(dyld3::MachOLoaded const*, int, char const**, dyld3::MachOLoaded const*, unsigned long*)  (in dyld) + 450  [0x10e264224]
        1 (4.00K) dyld::_main(macho_header const*, unsigned long, int, char const**, char const**, char const**, unsigned long*)  (in dyld) + 9098  [0x10e26c041]
          1 (4.00K) dyld::initializeMainExecutable()  (in dyld) + 129  [0x10e26586b]
            1 (4.00K) ImageLoader::runInitializers(ImageLoader::LinkContext const&, ImageLoader::InitializerTimingList&)  (in dyld) + 82  [0x10e279940]
              1 (4.00K) ImageLoader::processInitializers(ImageLoader::LinkContext const&, unsigned int, ImageLoader::InitializerTimingList&, ImageLoader::UninitedUpwards&)  (in dyld) + 233  [0x10e2798c9]
                1 (4.00K) ImageLoader::processInitializers(ImageLoader::LinkContext const&, unsigned int, ImageLoader::InitializerTimingList&, ImageLoader::UninitedUpwards&)  (in dyld) + 191  [0x10e27989f]
                  1 (4.00K) ImageLoader::recursiveInitialization(ImageLoader::LinkContext const&, unsigned int, char const*, ImageLoader::InitializerTimingList&, ImageLoader::UninitedUpwards&)  (in dyld) + 474  [0x10e27bad4]
                    1 (4.00K) dyld::notifySingle(dyld_image_states, ImageLoader const*, ImageLoader::InitializerTimingList*)  (in dyld) + 425  [0x10e265527]
                      1 (4.00K) load_images  (in libobjc.A.dylib) + 847  [0x7fff202e6211]
                        1 (4.00K) AutoreleasePoolPage::autoreleaseNoPage(objc_object*)  (in libobjc.A.dylib) + 119  [0x7fff203055d9]
                          1 (4.00K) _malloc_zone_memalign  (in libsystem_malloc.dylib) + 460  [0x7fff2028a348]
                            1 (4.00K) CONTENT:  malloc<4096>

 (省略)
```

> Stack logging was dynamically enabled in target process, after it was launched,
so no backtraces are available for earlier allocations.

このような出力もあり、`malloc_history`によって全てのmalloc呼び出しを追跡できたわけではないですが、一部のmallocの呼び出しがどこで行われたのかをみることができました。

どうやら、
`_dyld_start`（`dyld`ライブラリ内）の関数中の関数で、結果的に`_malloc_zone_memalign`（`libsystem_malloc.dylib`ライブラリ内）が呼び出されており、そこでmallocが呼び出された、
ということのようです。

# main()より前にたくさんの処理が行われている
https://embeddedartistry.com/blog/2019/05/20/exploring-startup-implementations-os-x/

プログラムを実行してからmainの呼び出し前までに、動的ライブラリのリンクを含めるさまざまな処理が行われています。
macOSの場合はここで[mallocの呼び出しを含むような処理](https://opensource.apple.com/source/dyld/dyld-635.2/src/dyld.cpp.auto.html#:~:text=MappedRanges*%20newRanges%20%3D%20(MappedRanges*)malloc(allocationSize)%3B
)があり、よって、プログラムの実装に関係なく常に実行時にmallocが呼び出されていました。


macOSでの一連の処理の流れに関して、この図があまりにもわかりやすかったので上記のサイトからお借りしました。先程のトレースに含まれていた`_dyld_start`関数は左下のdyldに表記されています。

![](/images/malloc-dynamic-link/2022-12-08-18-38-32.png)



# 注意すべき（めんどくさい）ポイント

以上で共有ライブラリの差し替え方、macOSにおけるmain()の前に行われる処理について説明しました。
mallocの自作を始めるというこれまでの手順で、既にエラーが出てつまずくポイントがいくつもありましたので、これらもついでにまとめておきます。


### 1. printfが使えない
自作mallocの挙動をデバッグするときには、printfが使用できません。（できないこともないが望む結果とならない場合があるだろう）
printfもmallocの呼び出しを行っているからです。

ここで活躍するのが [ft_printf](https://github.com/mfunyu/ft_printf/)（42Tokyoのlevel2の課題：printfの再実装！）です。

数字を出力してデバッグしたいケースや、アドレスを出力したいケースなどを考えたときに、mallocを使わない(バッファリングをしない)自作printfがあると非常に便利です。
自分のft_printfは昔はmallocを使用していたので、今回、mallocのために書き換えました...

### 2. `-static`でコンパイルできない（ほぼ） (macOS)

mallocの謎の呼び出しに出くわした時に、ロード時に動的リンクされているライブラリの中で呼び出されているならば、`-static`をつけて静的リンクさせてコンパイルすればいいじゃないか！
と思ったのですが、
macOSではリンクされている全てのライブラリが`-static`でコンパイルされていなければならないので、エラーになりました。（ソース見つけられませんでした）

例えば、ほとんどのプログラムは実行に`libSystem`のライブラリを必要としますが、このライブラリは共有ライブラリとしてのみ（staticでなく）提供されています。
よって、macOSではプログラムを静的にビルドすることは`libSystem`等のライブラリを使用しない場合にのみ可能、つまりほぼ不可能なのです。

https://stackoverflow.com/questions/3801011/ld-library-not-found-for-lcrt0-o-on-osx-10-6-with-gcc-clang-static-flag

```shell:macOS
$> gcc -static main.c
ld: library not found for -lcrt0.o
clang: error: linker command failed with exit code 1 (use -v to see invocation)
```

### 3. 静的ライブラリとリンクできない: `-fPIC`を使う (amd64)

libft_mallocをコンパイルするときに、上記の通り、printfの代わりに使うためのft_printfなどの**静的ライブラリをリンクしたい**、と考えました。
これはmacOSでは問題ないのですが、ubuntu(amd64)環境で実行すると、以下のようなエラーが出てしまいます。

```shell:amd64
$> gcc -Wall -Wextra -Werror -shared -o libft_malloc.so malloc.o free.o realloc.o -Llibft -lft -Lft_printf -lftprintf
/usr/bin/ld: objs/malloc.o: relocation R_X86_64_PC32 against symbol `error_exit' can not be used when making a shared object; recompile with -fPIC
/usr/bin/ld: final link failed: Bad value
```

これは下記のリンク先の *"[Case 4: Linking dynamically against static archives](https://wiki.gentoo.org/wiki/Project:AMD64/Fixing_-fPIC_Errors_Guide#:~:text=will%20not%20help.-,Case%204%3A%20Linking%20dynamically%20against%20static%20archives,-Sometimes%20a%20package)"* のケースに該当するのですが、amd64では、PICが有効化されていない状態で作成された静的ライブラリを用いて共有ライブラリを作成することはできません。
ですのでamd64では、動的ライブラリとリンクするためには、静的ライブラリを全て`-fPIC`のフラグ付きで作成する必要があります。

https://wiki.gentoo.org/wiki/Project:AMD64/Fixing_-fPIC_Errors_Guide

:::message
amd64以外では`-fPIC`のフラグを使用するべきではありません。（これもめんどくさいポイント）
:::

makefileでの分岐用には`dpkg-architecture -qDEB_HOST_ARCH`が使用できます
```shell:amd64
$> dpkg-architecture -qDEB_HOST_ARCH
amd64
```

https://stackoverflow.com/questions/17809403/makefile-determine-build-if-build-target-is-amd64-so-that-i-can-adapt-cflags

### 4. `-fsanitize=address`が使えない

メモリアクセスに関するエラーをデバッグするために、コンパイル時に`-fsanitize=address`のフラグをつけることがあると思います。

このフラグは、コンパイラにAddress Sanitizerを使用するように伝えるものです。
（Address SanitizerはGoogleによって開発されたメモリアクセスにおけるエラーを検出するためのツールです。）

https://github.com/google/sanitizers/wiki/AddressSanitizer

mallocの自作でも使いたいと思う瞬間がありますが、Wikiを見てみると、

> The tool consists of a compiler instrumentation module (currently, an LLVM pass) and a run-time library which **replaces the `malloc` function**.

との記載があります。

Address Sanitizerでは、mallocが置き換えられてしまうので、自作mallocのエラーを解析することはできません。

これを知らずにsanitizerを使うと、
”自作のmalloc、テストを通すと失敗していたけど、`-fsanitize=address`をつけて原因解析しようとしたらなぜか正常に動作した！”
なんてことが起こり得ます。


---

以上、malloc自作の第一歩である、共有ライブラリの差し替え、動的リンクの処理、そしてつまずきやすいポイントについてご紹介しました。

mallocの実装に取り組むにあたって、ふわっと理解していた部分や何となく知らないままにしていたことを勉強し直す良い機会になりました。
進捗は亀の歩みではありますが、、、mallocが完成した際にはmallocの実装に焦点を当ててまとめ記事にしようと思います。


ここまで読んでいただき、ありがとうございました。

**42tokyo Advent Calendar 2022**の10日目の記事はこちらです↓


またこちらのリンクから、他の42生＆42スタッフの記事も読めますので、是非チェックしてみてください！
https://qiita.com/advent-calendar/2022/42tokyo



---

mainの前の処理に関して、記事中で紹介したサイトに加えて以下のサイトも参照しました。

https://atmarkit.itmedia.co.jp/ait/articles/1703/01/news173.html

また、この本にもmainの呼び出し前について記載がありそうなので、読んでみようと思います。
https://www.amazon.co.jp/%E3%83%8F%E3%83%AD%E3%83%BC%E2%80%9CHello-World-OS%E3%81%A8%E6%A8%99%E6%BA%96%E3%83%A9%E3%82%A4%E3%83%96%E3%83%A9%E3%83%AA%E3%81%AE%E3%82%B7%E3%82%B4%E3%83%88%E3%81%A8%E3%81%97%E3%81%8F%E3%81%BF-%E5%9D%82%E4%BA%95-%E5%BC%98%E4%BA%AE/dp/4798044784
