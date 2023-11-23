---
title: "【malloc自作のために2】謎のfree呼び出しと隠されたアロケーター関数を探る"
emoji: "📝"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["malloc", "c", "dyld", "macOS"]
published: true
---

自作mallocを作る道のりの記事、第2弾です。

前回の記事で、mallocを自作関数で置き換えることで、macOSでは`main()`の前処理でも`malloc`が呼び出されているということがわかりました。

https://zenn.dev/mfunyu/articles/malloc-dynamic-link

今回は、その前処理の中で、`malloc`していないはずのアドレスにおいて`free`が呼び出されていたので、一体何が起きているのか検証しました。


# 謎のfreeを確認する

まずは、`malloc`, `realloc`, `free`を自作の関数に差し替えて、空のmain関数を実行しました。
※差し替えの方法などについては[前回の記事](https://zenn.dev/mfunyu/articles/malloc-dynamic-link)で詳細説明しています。

```c: main.c
int main() {}
```

```bash
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
```

これで、main呼び出し前処理で、`malloc`, `realloc`, `free`の関数がどれも呼び出されていることがわかりました。

各関数の呼び出し時引数を、自作printf（malloc不使用）で表示しましたが、これだけでは分かりづらいので、`malloc`と`realloc`の戻り値（アロケートされたアドレス）も、`ret`として表示させます。

```bash
$> DYLD_INSERT_LIBRARIES=./libft_malloc.so DYLD_FORCE_FLAT_NAMESPACE=1 ./a.out
[malloc] size = 1536, ret = 0x105626004
[realloc] ptr = 0x0, size = 64, ret = 0x1052cc004
[malloc] size = 32, ret = 0x1052cc04c
[free] ptr = 0x7fd1e0404110
[free] ptr = 0x7fd1e0404100
[free] ptr = 0x7fd1e0404130
[malloc] size = 32, ret = 0x1052cc074
[malloc] size = 11, ret = 0x1052cc09c
[malloc] size = 45, ret = 0x1052cc0b4
[malloc] size = 406, ret = 0x10562660c
[malloc] size = 45, ret = 0x1052cc0ec
[malloc] size = 50, ret = 0x1052cc124
[malloc] size = 47, ret = 0x1052cc164
[malloc] size = 14, ret = 0x1052cc19c
[malloc] size = 64, ret = 0x1052cc1b4
[malloc] size = 52, ret = 0x1052cc1fc
[malloc] size = 54, ret = 0x1052cc23c
[malloc] size = 12, ret = 0x1052cc27c
[malloc] size = 45, ret = 0x1052cc294
[malloc] size = 119, ret = 0x1052cc2cc
[free] ptr = 0x0
[malloc] size = 16, ret = 0x1052cc34c
[malloc] size = 64, ret = 0x1052cc364
[malloc] size = 14, ret = 0x1052cc3ac
```

これを見ると、自作`malloc`, `realloc`が返すアドレスは全て`0x105000000`番台なのに、mallocしていないはずの`0x7fd1e0000000`という大きなアドレスが`free`の引数に渡されていることがわかります。

このせいで、自作`malloc`に対応するように`free`を実装したところ、アロケートしていないはずのアドレスを`free`しようとしたことになりエラー、または運が悪いときにはセグメンテーションフォルトになってしまいました。

:::message
何者かが`malloc`してないはずのアドレスで`free`呼び出してくる。
一体何を`free`しようとしているんだsegfaultしちゃうよ🥺
:::

# freeの呼び出し元を探る

自作関数で置き換えたのは`malloc`と`realloc`だけということで、残された`calloc`や`valloc`が呼び出されているのかも！
と`_malloc.h`から着想を得て、`calloc`や`valloc`も置き換えてみましたが、呼び出されていませんでした。
残念。

:::details ご参考までに、_malloc.h
```c:_malloc.h
/*
 * Copyright (c) 2018 Apple Computer, Inc. All rights reserved.
 *
 * @APPLE_LICENSE_HEADER_START@
 *
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this
 * file.
 *
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 *
 * @APPLE_LICENSE_HEADER_END@
 */

#ifndef _MALLOC_UNDERSCORE_MALLOC_H_
#define _MALLOC_UNDERSCORE_MALLOC_H_

/*
 * This header is included from <stdlib.h>, so the contents of this file have
 * broad source compatibility and POSIX conformance implications.
 * Be cautious about what is included and declared here.
 */

#include <Availability.h>
#include <sys/cdefs.h>
#include <_types.h>
#include <sys/_types/_size_t.h>

__BEGIN_DECLS

void	*malloc(size_t __size) __result_use_check __alloc_size(1);
void	*calloc(size_t __count, size_t __size) __result_use_check __alloc_size(1,2);
void	 free(void *);
void	*realloc(void *__ptr, size_t __size) __result_use_check __alloc_size(2);
#if !defined(_ANSI_SOURCE) && (!defined(_POSIX_C_SOURCE) || defined(_DARWIN_C_SOURCE))
void	*valloc(size_t) __alloc_size(1);
#endif // !defined(_ANSI_SOURCE) && (!defined(_POSIX_C_SOURCE) || defined(_DARWIN_C_SOURCE))
#if (__DARWIN_C_LEVEL >= __DARWIN_C_FULL) || \
    (defined(__STDC_VERSION__) && __STDC_VERSION__ >= 201112L) || \
    (defined(__cplusplus) && __cplusplus >= 201703L)
void    *aligned_alloc(size_t __alignment, size_t __size) __result_use_check __alloc_size(2) __OSX_AVAILABLE(10.15) __IOS_AVAILABLE(13.0) __TVOS_AVAILABLE(13.0) __WATCHOS_AVAILABLE(6.0);
#endif
int 	 posix_memalign(void **__memptr, size_t __alignment, size_t __size) __OSX_AVAILABLE_STARTING(__MAC_10_6, __IPHONE_3_0);

__END_DECLS

#endif /* _MALLOC_UNDERSCORE_MALLOC_H_ */
```
:::

では、一体どんな関数がなんの目的で、アロケートしていないはずのアドレスでfreeを呼び出しているのか。

ソースコードを見ないことには理解できない！

ということで、とにかく関数名を表示してみます。

## 呼び出し元の関数名を表示する

呼び出し元の関数名を直接取得することはできないので、その代わりに
1. リターンアドレスを取得
2. アドレスからシンボル名を解決（関数名と同じ場合が多い）

という手順で、関数名を取得→表示します。


まず、[`__builtin_return_address`](https://man.netbsd.org/NetBSD-6.1/__builtin_return_address.3
)という、リターンアドレス（呼び出した関数のアドレス：現在の関数が終わったらそこに戻る）を取得する関数を使い、呼び出し元関数に含まれるアドレスを取得します。

それを用いて、指定したアドレスを含む共有オブジェクトに関する情報を返す関数、[`dladdr`](https://nxmnpg.lemoda.net/ja/3/dladdr)を使って、関数の情報を取得し、名前を表示します。

【大参考】
https://qiita.com/koara-local/items/07a4f76b2d44ac719b65

---
以下のような`alloc_debug`という関数を作成しました。

- 汎用性のある関数にしたい
- 復帰アドレスは`alloc_debug`内で取得すると、`alloc_debug`の復帰アドレス（呼び出した`malloc`とか）になってしまう（当たり前だけど）なので、引数で渡す
- 該当関数名も表示したいので、使いまわせるように`__func__`で引数に渡す

【呼び出し方】
```c
alloc_debug(__func__, __builtin_return_address(0));
```

【呼び出し例】
```c:malloc.c
void	*malloc(size_t size)
{
	...
	alloc_debug(__func__, __builtin_return_address(0));
	ft_printf("size = %d, ret = %p\n", (int)size, ret);
	...
}
```

【実装】
```c:alloc_debug.c
# define __USE_GNU
#include <dlfcn.h>
#include "ft_printf.h"

void	alloc_debug(const char *func_name, void *ret_addr)
{
	Dl_info	info;

	dladdr(ret_addr, &info);
	ft_printf("[%s] by %s	: ", func_name, info.dli_sname);
}
```

【結果】
```bash
$> DYLD_INSERT_LIBRARIES=./libft_malloc.so DYLD_FORCE_FLAT_NAMESPACE=1 ./a.out
[malloc] by _objc_init                  : size = 1536, ret = 0x10b5bd004
[realloc] by _ZN4objc10SafeRanges3addEmm: ptr = 0x0, size = 64, ret = 0x10b263004
[malloc] by NXCreateHashTableFromZone   : size = 32, ret = 0x10b26304c
[free] by _NXHashRehashToCapacity       : ptr = 0x7ff535404110
[free] by _NXHashRehashToCapacity       : ptr = 0x7ff535404100
[free] by NXHashInsert                  : ptr = 0x7ff535404130
[malloc] by NXCreateMapTableFromZone    : size = 32, ret = 0x10b263074
[malloc] by strdup      : size = 11, ret = 0x10b26309c
[malloc] by _xpc_malloc : size = 45, ret = 0x10b2630b4
[malloc] by strdup      : size = 406, ret = 0x10b5bd60c
[malloc] by _xpc_malloc : size = 45, ret = 0x10b2630ec
[malloc] by strdup      : size = 50, ret = 0x10b263124
[malloc] by _xpc_malloc : size = 47, ret = 0x10b263164
[malloc] by strdup      : size = 14, ret = 0x10b26319c
[malloc] by _xpc_malloc : size = 64, ret = 0x10b2631b4
[malloc] by strdup      : size = 52, ret = 0x10b2631fc
[malloc] by _xpc_malloc : size = 54, ret = 0x10b26323c
[malloc] by strdup      : size = 12, ret = 0x10b26327c
[malloc] by _xpc_malloc : size = 45, ret = 0x10b263294
[malloc] by _xpc_malloc : size = 119, ret = 0x10b2632cc
[free] by __vfprintf    : ptr = 0x0
[malloc] by _owned_ptr_alloc    : size = 16, ret = 0x10b26334c
[malloc] by _owned_ptr_alloc    : size = 64, ret = 0x10b263364
[malloc] by __setenv_locked     : size = 14, ret = 0x10b2633ac
```
各呼び出しで、呼び出し元の関数名を表示させることができました🎉


## 各関数のソースを読む

これで、`free`を呼び出している関数が、`_NXHashRehashToCapacity`と`NXHashInsert`であるということがわかりました。

いや、聞いたこともないよ！😅

### `_NXHashRehashToCapacity`を読み解く

`_NXHashRehashToCapacity`関数、ググったら見つかりました。
どうやら[Objective-C runtime](https://developer.apple.com/documentation/objectivec/objective-c_runtime)の中で使われている関数っぽい。

https://github.com/RetVal/objc-runtime/blob/master/runtime/hashtable2.mm#L291-L312

そして、どうやら、
```shell
[free] by _NXHashRehashToCapacity       : ptr = 0x7ff535404110
[free] by _NXHashRehashToCapacity       : ptr = 0x7ff535404100
```
この2行のfreeは、上記のファイルの310, 311行目
```c
    free (old->buckets);
    free (old);
```
ここで呼び出されていると考えてほぼ間違いなさそうです。

ここでfreeの引数に渡されている2つの変数、

- `old->buckets`は、303行目`ALLOCBUCKETS(z, table->nbBuckets)`で、
- `old`は、299行目`ALLOCTABLE(z)`で、

どうやらどちらもアロケートされているようです。

どちらもマクロなので、次にこれらの定義を見ていきます。

https://github.com/RetVal/objc-runtime/blob/master/runtime/hashtable2.mm#L53-L69

`ALLOCTABLE`は`!SUPPORT_ZONES`の場合には`malloc`と定義されていますが、それ以外の場合、つまり`SUPPORT_ZONES`が0でない場合には、`malloc_zone_malloc`という関数で定義されていることがわかりました。

つまり、`malloc`の代わりに、`malloc_zone_malloc`という関数が呼び出されていたのではと推測できました！

`SUPPORT_ZONES`の定義も見つかりました。

https://github.com/RetVal/objc-runtime/blob/master/runtime/objc-config.h#L53-L58

これを見ると、macOSの環境ではどうやら`SUPPORT_ZONES`は1、つまり、

- `ALLOCTABLE`は`malloc_zone_malloc`
- `ALLOCBUCKETS`は`malloc_zone_calloc`

で定義されているようです。

# `malloc_zone_malloc`を調査する

これで、謎の`free`呼び出しの原因がわかりました。

:::message
`malloc`ではなく、`malloc_zone_malloc`という別の関数を呼び出してアロケートしているので、自作関数は呼び出されておらず、アロケートしていないものと思い込んでいた💡
:::

が、なぜ`free`が直接呼び出されているのか？

## `free`の実装

`malloc_zone_malloc`を使うなら、`malloc_zone_free`という対応する関数を呼ぶ必要があるのでは？

と思ったので、まず[`free`の実装](https://opensource.apple.com/source/libmalloc/libmalloc-53.1.1/src/malloc.c.auto.html#:~:text=return%20retval%3B%0A%7D%0A%0Avoid-,free(void%20*ptr)%20%7B,-malloc_zone_t%09*zone%3B%0A%09size_t)を確認しました。

```c:libmalloc/src/malloc.c
void	free(void *ptr) {
    malloc_zone_t	*zone;
    size_t		size;
    if (!ptr)
    	return;
    zone = find_registered_zone(ptr, &size);
    if (!zone) {
        malloc_printf("*** error for object %p: pointer being freed was not allocated\n"
                      "*** set a breakpoint in malloc_error_break to debug\n", ptr);
        malloc_error_break();
        if ((malloc_debug_flags & (SCALABLE_MALLOC_ABORT_ON_CORRUPTION|SCALABLE_MALLOC_ABORT_ON_ERROR))) {
            _SIMPLE_STRING b = _simple_salloc();
            if (b) {
            	_simple_sprintf(b, "*** error for object %p: pointer being freed was not allocated\n", ptr);
            	CRSetCrashLogMessage(_simple_string(b));
            } else {
            	CRSetCrashLogMessage("*** error: pointer being freed was not allocated\n");
            }
            abort();
    	}
    } else if (zone->version >= 6 && zone->free_definite_size)
    	malloc_zone_free_definite_size(zone, ptr, size);
    else
    	malloc_zone_free(zone, ptr);
}
```

`malloc_zone_free`呼び出してました。



## `malloc_zone_malloc`って何者？

`malloc_zone_malloc`ってなんだよ、と思ったのですが、

```c:libmalloc/src/malloc.c
void	*malloc(size_t size) {
    void	*retval;
    retval = malloc_zone_malloc(inline_malloc_default_zone(), size);
    if (retval == NULL) {
    	errno = ENOMEM;
    }
    return retval;
}
```

めちゃくちゃそのまま上記の[本家の`malloc`の実装](https://opensource.apple.com/source/Libc/Libc-594.1.4/gen/malloc.c.auto.html#:~:text=callouts%09************/%0A%0Avoid%20*-,malloc(size_t%20size),-%7B%0A%20%20%20%20void%09*retval)で呼び出されてました。

エラー時に`errno`設定してるだけじゃん、、、

`malloc`は`malloc_zone_malloc`のラッパー関数であると考えられそうですね。

<!---
### zoneの概念

https://developer.apple.com/library/archive/documentation/Performance/Conceptual/ManagingMemory/Articles/MemoryAlloc.html

`malloc_zone_malloc`の、`zone`ってなんだ？と思ったのですが、`zone`はヒープと同義のようです。

> The term zone is **synonymous** with the terms **heap**, pool, and arena in terms of memory allocation using the malloc routines.

--->

# アロケート外領域のfree対策には

エラーを回避するためには、
1. `malloc_zone_malloc`も自作する
2. 自作`free`でも本家と同じように場合によって`malloc_zone_free`を呼び出す

の手段がありそうです。

圧倒的に自作`free`において`malloc_zone_free`を呼び出すほうが簡単そうなので、呼び出しの追加を採用します。
macOSの場合にのみ以下のようにzoneのチェック、もし該当すれば`malloc_zone_free`を呼び出す処理を追記しました。

```c:free.c
void	free(void *ptr)
{
    ...
#ifdef __APPLE__
	malloc_zone_t	*zone;

	zone = malloc_zone_from_ptr(ptr);
	if (zone) {
		malloc_zone_free(zone, ptr);
		return ;
	}
#endif
    ...
}
```
これで、`malloc_zone_malloc`によって確保された領域は、`malloc_zone_free`を呼び出して開放できるようになりました。

---

今回は、malloc自作において、直面した謎のfree、mallocを置き換えたときにアロケートしていないはずのアドレスでfreeが呼ばれている問題についてまとめました。

malloc関数を自作関数で置き換えても、macOSの`main()`の前処理において`malloc_zone_malloc`が呼び出されます。
その時、`malloc_zone_malloc`関数を自作で実装していない場合は本家のzone式mallocが呼び出されます。

`malloc_zone_malloc`によってアロケートされたアドレスも、本家では同じく`free`によって開放できるので、開放時にはそのまま自作の`free`関数がよびだされてしまいます。
もちろん、自作の`malloc`のアロケート範囲ではありませんので自作の`free`ではエラーになり、「アロケートしていないはずのアドレスにおいて、何故か`free`が呼ばれている！」という状況が生み出されるというわけです。

以上、malloc自作のために、第2弾でした。

ここまで読んでいただき、ありがとうございました！

👋

