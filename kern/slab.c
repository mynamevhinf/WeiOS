#include <include/types.h>
#include <include/kernel.h>
#include <include/mem.h>
#include <include/slab.h>
#include <include/pmap.h>
#include <include/buddy.h>
#include <include/kmalloc.h>

#include <include/stdio.h>

kmem_cache_t  meta_cache;
kmem_cache_t  normal_caches[NKMEMCACHE];

static void kmem_cache_init(kmem_cache_t *cache, uint32_t obj_size, gfp_t gfp_flags)
{
	cache->obj_size = obj_size;
	if (obj_size < 512)
		cache->n_objs_per_slab = SLAB_SIZE / (obj_size + sizeof(ushort));
	else
		cache->n_objs_per_slab = SLAB_SIZE / obj_size;
	cache->n_pages_per_slab = 1;
	cache->gfp_flags = gfp_flags;
	cache->m_cache_ptr = &meta_cache;
	cache->lists.free_objects = 0;
	spinlock_init(&cache->kmem_cache_lock, "slab_locks");

	LIST_HEAD_INIT(cache->lists.slabs_full);
	LIST_HEAD_INIT(cache->lists.slabs_empty);
	LIST_HEAD_INIT(cache->lists.slabs_partitial);
}

static inline void set_page_slab(struct page *page)
{
	page->flag |= PAGE_IN_SLAB;
}

static inline void clear_page_slab(struct page *page)
{
	page->flag &= (~PAGE_IN_SLAB);
}

// I return the descriptor of the specified page
static struct page *kmem_get_page(kmem_cache_t *cachep, gfp_t gfp_flags)
{
	struct page  *page;
	gfp_flags |= cachep->gfp_flags;

	if (!(page = alloc_page(gfp_flags)))
		return 0;
	set_page_slab(page);

	return page;
}

// I receive virtual address.
static void kmem_free_page(void *vaddr)
{
	struct page  *page = va2page((uintptr_t)vaddr);

	if (page) {
		clear_page_slab(page);
		__free_page(page);
	}
}

// alloc a new slab descriptor in the meta_cache.
static struct slab *alloc_slab_desc(kmem_cache_t *m_cache_ptr)
{
	return (struct slab *)kmem_cache_alloc(m_cache_ptr, __GFP_ZERO);
}

// Delete a slab descriptor as a object in the meta_cache
static void destroy_slab_desc(kmem_cache_t *m_cache_ptr, struct slab *slabp)
{
	kfree(slabp);
}

// alloc a new slab.
static struct slab *cache_grow(kmem_cache_t *cachep, gfp_t gfp_flags)
{
	int 		   i;
	size_t		   objs_size;
	void          *p_va;
	char          *first_obj_addr;
	struct  page  *page;
	struct slab   *slab;

	if (!(page = kmem_get_page(cachep, gfp_flags)))
		return 0;
	p_va = page2va(page);
	first_obj_addr = ((char *)p_va + cachep->n_objs_per_slab * sizeof(ushort));
	if (cachep == &meta_cache) {
		slab = (struct slab *)first_obj_addr;
		slab->n_inuse = 1;
		slab->free = 1;
	} else {
		if (!(slab = alloc_slab_desc(cachep->m_cache_ptr))) {
			kmem_free_page(p_va);
			return 0;
		}	
		slab->n_inuse = 0;
		slab->free = 0;
	}
	page->lru.next = (struct list_head *)cachep;
	page->lru.prev = (struct list_head *)slab;

	if (cachep->obj_size < 512) {
		slab->first_obj_mem = (void *)first_obj_addr;
		slab->objs_desc_array = (ushort *)p_va;
	} else {
		slab->first_obj_mem = (void *)p_va;
		slab->objs_desc_array = slab->objs_desc;
	}

	for (i = 0; i < cachep->n_objs_per_slab - 1; i++)
		slab->objs_desc_array[i] = i+1;
	slab->objs_desc_array[i] = BUFCTL_END;

	spin_lock_irqsave(&cachep->kmem_cache_lock);
	cachep->lists.free_objects += cachep->n_objs_per_slab;
	if (cachep == &meta_cache) {
		list_add_tail(&slab->list, &cachep->lists.slabs_partitial);
		cachep->lists.free_objects -= 1;
	} else
		list_add_tail(&slab->list, &cachep->lists.slabs_empty);
	
	return slab;
}

// destroy a fully empty slab.
static void slab_destroy(struct slab *slabp)
{
	struct page  *page = va2page((uintptr_t)(slabp->first_obj_mem));
	char  *page_va = page2va(page);
	kmem_cache_t *cachep = (kmem_cache_t *)(page->lru.next);

	// Firstly i delete externel objects's descriptors if exsited.
	//if (cachep->obj_size < 512)
	//	destroy_externel_objdesc(slabp);
	// We clears all data in this slab.
	list_del(&slabp->list);
	cachep->lists.free_objects -= (cachep->n_objs_per_slab - slabp->n_inuse);
	memset(page_va, 0, SLAB_SIZE);
	if (cachep != &meta_cache) 
		destroy_slab_desc(cachep->m_cache_ptr, slabp);

	page->lru.next = 0;
	page->lru.prev = 0;
	kmem_free_page(page_va);
}


/*
 * API for external world.
 */
// allocate a sn object in the slab system.
void *kmem_cache_alloc(kmem_cache_t *cachep, gfp_t gfp_flags)
{
	char              *obj_addr;
	ushort             obj_index;
	struct slab       *slabp = 0;
	struct list_head  *list_node;
	struct list_head  *list_head_node;  

	spin_lock_irqsave(&cachep->kmem_cache_lock);
	if (cachep->lists.free_objects > 0) {
		// We start at partial slabs.
		list_head_node = &(cachep->lists.slabs_partitial);
		list_node = list_head_node->prev;
		while (list_node != list_head_node) {
			slabp = list_entry(list_node, struct slab, list);
			if (slabp->free != BUFCTL_END)
				goto find_slab;
			list_node = list_node->prev;
		}

		list_head_node = &(cachep->lists.slabs_empty);
		list_node = list_head_node->prev;
		slabp = list_entry(list_node, struct slab, list);
		/*
		while (list_node != list_head_node) {
			slabp = list_entry(list_node, struct slab, list);
			if (slabp->free != BUFCTL_END)
				break;
			list_node = list_node->prev;
		}
		*/
	} else {
		spin_unlock_irqrestore(&cachep->kmem_cache_lock);
		if (!(slabp = cache_grow(cachep, gfp_flags))) {
		    //spin_unlock_irqrestore(&cachep->kmem_cache_lock);
			return 0;
		}
	}
    /*
	if (!slabp) {
		spin_unlock_irqrestore(&cachep->kmem_cache_lock);		
		return 0;
	}
    */
find_slab:
	obj_index = slabp->free;
	slabp->free = slabp->objs_desc_array[obj_index];
	slabp->n_inuse++;
	cachep->lists.free_objects--;
	spin_unlock_irqrestore(&cachep->kmem_cache_lock);
	obj_addr = (char *)slabp->first_obj_mem + obj_index * cachep->obj_size;
	/*
	if (cachep->obj_size == PGSIZE) {
		prink("obj_index = %u\n", obj_index);
		prink("slabp->first_obj_mem = %p\n", slabp->first_obj_mem);
		prink("jjbb, obj_addr = %p\n\n", obj_addr);
	}
	*/
	memset(obj_addr, 0, cachep->obj_size);

	return (void *)obj_addr;
}

// Free a objects
void kmem_cache_free(kmem_cache_t *cachep, struct slab *slabp, void *objp)
{
	ushort        obj_index;

	obj_index = (char *)objp - (char *)(slabp->first_obj_mem);
	obj_index /= cachep->obj_size;
	spin_lock_irqsave(&cachep->kmem_cache_lock);
	slabp->objs_desc_array[obj_index] = slabp->free;
	slabp->free = obj_index;

	cachep->lists.free_objects++;

	if ((slabp->n_inuse -= 1) == 0) //{
		slab_destroy(slabp);
		//cachep->lists.free_objects -= cachep->n_objs_per_slab;
	//}
	spin_unlock_irqrestore(&cachep->kmem_cache_lock);
}

void slab_init(void)
{
	uint32_t  obj_size; 
	gfp_t  gfp_flags = __GFP_ZERO;
	
	// initialize meta_cache
	kmem_cache_init(&meta_cache, sizeof(struct slab), gfp_flags|__GFP_WAIT);

	// Now is normal_caches.
	for (int i = 0, obj_size = 32; i < NKMEMCACHE / 2; i++, obj_size *= 2) {
		kmem_cache_init(&normal_caches[i], obj_size, gfp_flags|__GFP_WAIT);
		kmem_cache_init(&normal_caches[i+NKMEMCACHE/2], obj_size, gfp_flags|__GFP_DMA);
	}
}
