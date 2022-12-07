---
title: "malloc自作しようと思ったけど、その前にmain()の呼び出しの前の処理を理解する必要があった"
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
> 自作mallocを実装しようと思ったけど、その前に動的リンクを理解する必要があった！

ということで、道中を書き認めていこうと思います

# 動的リンクと静的リンク（リンカのはなし）

42生は、特になのですが、これまでにmallocを差し替えて、mallocが失敗した場合の挙動を確認したい！
と思ったことがある方、多いのではないでしょうか。

動的リンクを使えば、コンパイル済みの実行ファイルを用いて、ソースコードを変更したり、再コンパイルしたりする必要一切なしに、簡単にmalloc（だけでなくどの関数も）を差し替えることができます。

これを

# 

関数フックのやり方
## macOS

```shell
export DYLD_INSERT_LIBRARIES=./libft_malloc.so
export DYLD_FORCE_FLAT_NAMESPACE=1
```
`DYLD_LIBRARY_PATH`を`DYLD_LIBRARY_PATH=.`などと設定すれば、`DYLD_INSERT_LIBRARIES`の変数はライブラリ名のみの指定で問題ありません。

:::message
Linuxとは少し違い、`DYLD_FORCE_FLAT_NAMESPACE`も同時に設定する必要があります。
:::

ちなみに、各環境変数の詳細などは`man dyld`で確認することができます。

## Linux

```shell
export LD_PRELOAD=./libft_malloc.so
```

# 空のプログラムなのにmallocが呼ばれている！？

```c
int main() {}
```

このプログラムをmacOSで`gcc main.c`と普通にコンパイルし、
```shell
$> DYLD_INSERT_LIBRARIES=./libft_malloc.so DYLD_FORCE_FLAT_NAMESPACE=1 ./a.out
```
このようにmalloc/realloc/freeを自作のログを出力する関数と差し替えて実行すると、

```shell
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

## 呼び出しタイミングを探る
これを
```c
__attribute__((constructor))
void init() {
	write(1, "---\n", 4);
}

int main() {}
```

このようにmain呼び出しの直前で`---`を出力するようにして再度実行すると、

```shell
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
つまり、これらのmalloc/realloc/freeの呼び出しは、全てmainの実行前だということがわかりました。

では、これらのmalloc等の呼び出しはどこから来たのでしょうか。

## mallocをトレースする



MacOS
-static

環境変数の有効範囲の指定
AMD64
-fPIC

mallocがmainの前に呼ばれている？


# めんどくさい/注意すべきポイント

### 1. printfが使えない
自作mallocの挙動をデバッグするときには、printfが使用できません。（できないこともないが望む結果とならない場合があるだろう）
printfもmallocの呼び出しを行っているからです。

ここで活躍するのが [ft_printf](https://github.com/mfunyu/ft_printf/)（42Tokyoのlevel2の課題：printfの再実装！）です。

数字を出力してデバッグしたいケースや、アドレスを出力したいケースなどを考えたときに、mallocを使わない(バッファリングをしない)自作printfがあると非常に便利です。
自分のft_printfは昔はmallocを使用していたので、今回、mallocのために書き換えました...

### 2. `-static`が使えない (macOS)

mallocの謎の呼び出しに出くわした時に、ロード時に動的リンクされているライブラリの中で呼び出されているならば、`-static`をつけて静的リンクさせてコンパイルすればいいじゃないか！
と思ったのですが、
macOSでは


### 3. 静的ライブラリとリンクできない: `-fPIC`を使う (amd64)

libft_mallocをコンパイルするときに、上記の通り、printfの代わりに使うためのft_printfなどの**静的ライブラリをリンクしたい**、と考えました。
これはmacOSでは問題ないのですが、ubuntu(amd64)環境で実行すると、以下のようなエラーが出てしまいます。

```shell
gcc -Wall -Wextra -Werror -shared -o libft_malloc.so malloc.o free.o realloc.o -Llibft -lft -Lft_printf -lftprintf
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
```shell
--(amd64)--
$> dpkg-architecture -qDEB_HOST_ARCH
amd64
```

https://stackoverflow.com/questions/17809403/makefile-determine-build-if-build-target-is-amd64-so-that-i-can-adapt-cflags

