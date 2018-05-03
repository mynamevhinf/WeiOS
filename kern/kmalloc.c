#include <include/slab.h>
#include <include/buddy.h>
#include <include/types.h>
#include <include/kmalloc.h>

extern kmem_cache_t  normal_caches[];

void *kmalloc(size_t size, gfp_t gfp_flags)
{
	int  dma;
	int  cache_idx;
	size_t  tmp_size;

	if (size > SLAB_SIZE || size == 0)
		return 0;
	
	cache_idx = 0;
	tmp_size = 32;
	dma = (gfp_flags & __GFP_DMA)?1:0;
	while (tmp_size < size) {
		cache_idx++;
		tmp_size *= 2;
	}

	cache_idx += ((NKMEMCACHE / 2) * dma);
	return kmem_cache_alloc(&normal_caches[cache_idx], gfp_flags);
}

void kfree(void *objp)
{
	struct page  *page;
	struct slab  *slabp;
	kmem_cache_t *cachep;

	if (!(page = va2page((uintptr_t)objp)))
		return;
	if ((page->flag & RESERVED_PAGE))
		return;
	if (!(page->flag & PAGE_IN_SLAB))
		return;

	slabp = (struct slab *)(page->lru.prev);
	cachep = (kmem_cache_t *)(page->lru.next);
	kmem_cache_free(cachep, slabp, objp);
}