---
title: "【malloc自作のために3】本家との実装の違いの工夫"
emoji: "💭"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["malloc", "c"]
published: false
---

# tiny領域とsmall領域の区別

本家では、アロケートする際には、サイズによって判断している。
64bit環境では、tinyの範囲は`(NUM_TINY_SLOTS - 1) * TINY_QUANTUM = (64 - 1) * (1 << 4) = 63 * 16 = 1008`以下となる。

```c:magazine_malloc.c
static NOINLINE void *
szone_malloc_should_clear(szone_t *szone, size_t size, boolean_t cleared_requested)
{
    void	*ptr;
    msize_t	msize;

    if (size <= (NUM_TINY_SLOTS - 1)*TINY_QUANTUM) {
    // think tiny
    } else if (!((szone->debug_flags & SCALABLE_MALLOC_ADD_GUARD_PAGES) && PROTECT_SMALL) &&
        (size <= szone->large_threshold)) {
    // think small
    } else {
    // large
    }
    return ptr;
}
```
しかし、freeするときは、判断にsizeは用いられていない。

```c:magazine_malloc.c
static NOINLINE void
szone_free(szone_t *szone, void *ptr)
{
    region_t	tiny_region;
    region_t	small_region;

    /*
     * Try to free to a tiny region.
     */
    if ((tiny_region = tiny_region_for_ptr_no_lock(szone, ptr)) != NULL) {
        ...
        free_tiny(szone, ptr, tiny_region, 0);
        return;
    }

    /*
     * Try to free to a small region.
     */
    if ((small_region = small_region_for_ptr_no_lock(szone, ptr)) != NULL) {
        ...
        free_small(szone, ptr, small_region, 0);
        return;
    }

    /* check that it's a legal large allocation */
    ...
    free_large(szone, ptr);
}
```

`tiny_region_for_ptr_no_lock`という関数が判定に呼ばれているが、この関数は内部で`hash_lookup_region_no_lock`を呼び出し該当するアドレスを含んだregionの有無を判定している。

```c:magazine_malloc.c
/*
 * tiny_region_for_ptr_no_lock - Returns the tiny region containing the pointer,
 * or NULL if not found.
 */
static INLINE region_t
tiny_region_for_ptr_no_lock(szone_t *szone, const void *ptr)
{
    rgnhdl_t r = hash_lookup_region_no_lock(szone->tiny_region_generation->hashed_regions,
	szone->tiny_region_generation->num_regions_allocated,
	szone->tiny_region_generation->num_regions_allocated_shift,
	TINY_REGION_FOR_PTR(ptr));
    return r ? *r : r;
}
```

tinyのregionと、smallのregionは異なり、別の場所にアロケートされるので、free時にどちらの領域にアロケートされているか判別できる必要がある。
本家と同様にハッシュ検索を実装するほどではないので、ここでは単純にtinyのサイズ上限を変化させて判別するように実装する。

smallのアラインメントを512,tinyのアラインメントを16にする。
これによって、アラインメントを確認すれば、どちらのregionに属するか判別できる。

ただし、tinyの上限を本家と同じく1008にすると、1024のサイズのブロックのときにtinyに属するのかsmallに属するのかわからない。

理由として、サイズ1024のブロックに1008のtinyのアロケーション要求があったとき、`1024 > 1008 + 32`より、ブロックは分割されずそのままアロケートされる。

この場合、もともとサイズ1016のsmallの要求にヘッダが追加されアラインされて、1024が確保されたのか、1008の要求でtinyのregionに確保されたのか判断がつかない。

よって1024をサイズ境界として、サイズ1025以上のアロケーションがsmallに分類されるようにすることで、単純にアドレスのアラインメントが512であればsmall、16であればtinyと判断することができるようになる。
