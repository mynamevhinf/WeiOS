#ifndef _SLAB_H_
#define _SLAB_H_

#ifndef __ASSEMBLER__

#include <include/types.h>
#include <include/mem.h>
#include <include/lock.h>
#include <include/kernel.h>

#define SLAB_SIZE		4096
#define SLAB_OBJ_DESP	8
#define BUFCTL_END  	0xFFFF

struct slab {
	void     *first_obj_mem;
	ushort    n_inuse;			// number of objects in the slab that are currently used.
	ushort    free;				// Index of first free objects in slab.
	ushort   *objs_desc_array;
	ushort    objs_desc[SLAB_OBJ_DESP];

	struct list_head  list;		// Used in kmem_list to construct relative slabs list.
};

struct kmem_list {
	struct list_head  slabs_full;
	struct list_head  slabs_empty;
	struct list_head  slabs_partitial;

	uint32_t  free_objects;
};

#define NKMEMCACHE	16
// n_objs_per_slab can be selected from [32, 64, 128, 256, 512, 1024, 2048, 4096]
typedef struct kmem_cache {
	struct kmem_list  lists;
	uint32_t  obj_size;
	uint32_t  n_objs_per_slab;
	uint32_t  n_pages_per_slab;
	gfp_t	gfp_flags;		// Set of flags passed to the buddy system function when
							// allocating page frames.
	struct kmem_cache  *m_cache_ptr;	// point to the gerneral kmem_cache_t which 
										// containing slab descriptors.
	struct spinlock  kmem_cache_lock;
} kmem_cache_t;

static void kmem_cache_init(kmem_cache_t *cache, uint32_t obj_size, gfp_t gfp_flags);
static inline void set_page_slab(struct page *page);
static inline void clear_page_slab(struct page *page);

// slab use functions follow to conmunicate with buddy.
// alloc and free page, one for each time.
static struct page *kmem_get_page(kmem_cache_t *cachep, gfp_t gfp_flags);
static void kmem_free_page(void *vaddr);

static struct slab *alloc_slab_desc(kmem_cache_t *m_cache_ptr);
static void destroy_slab_desc(kmem_cache_t *m_cache_ptr, struct slab *slabp);
static void destroy_externel_objdesc(struct slab *slabp);

static struct slab *cache_grow(kmem_cache_t *cachep, gfp_t gfp_flags);
static void slab_destroy(struct slab *slabp);

// objs to/from slab
void *kmem_cache_alloc(kmem_cache_t *cachep, gfp_t gfp_flags);
void kmem_cache_free(kmem_cache_t *cachep, struct slab *slabp, void *objp);
void slab_init(void);

#endif

#endif
