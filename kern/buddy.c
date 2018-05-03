#include <include/mmu.h>
#include <include/mem.h>
#include <include/pmap.h>
#include <include/lock.h>
//#include <include/proc.h>
#include <include/buddy.h>
#include <include/types.h>
#include <include/kernel.h>
#include <include/sysfunc.h>

extern struct page *pages;
extern struct proc_manager  proc_manager;

struct zone kernel_zone;
struct zone normal_zone;

struct zone *zones_list[NZONES];


static int page_is_buddy(Page page, Page buddy, int order)
{
    if ((buddy->p_private == order) && (buddy->p_ref == 0))
        return 1;
    return 0;
}

Page __rmqueue(struct zone *z, int order)
{
    Page              page;
    Page              tpage;
    Page              buddy;
    size_t            size;
    uint32_t          curr_order;
    struct free_area *area;

    if (order < 0)
        return 0;

    page = 0;
    size = (1 << order);
    for (curr_order = order; curr_order < MEMLEVEL; curr_order++) {
        area = z->free_area + curr_order;
        if (list_empty((&area->free_list)))
            continue;
        page = list_entry(area->free_list.next, struct page, lru);
        list_del(&page->lru);
        page->p_private = OUT_OF_BUDDY; 
        area->nr_free--;
        z->free_pages -= size;
        break;
    }

    if (page) {
        // Now we have to repair something
        // if the block found comes from a list of size curr_order grea-
        // -ter than the requested order.
        size = (1 << curr_order);
        while (curr_order > order) {
            area--;
            curr_order--;
            size >>= 1;
            buddy = page + size;
            //list_del(&buddy->lru);
            list_add(&buddy->lru, &area->free_list);
            area->nr_free++;
            buddy->p_private = curr_order;
        }
    }
    return page;
}

void __free_pages_bulk(Page page, struct zone *z, int order)
{
    Page                zone_base = z->zone_first_page;
    uint32_t            order_size = (1<<order);
    uint32_t            buddy_idx, page_idx = page - zone_base;
    Page                buddy, coalesced;   

    while (order < MEMLEVEL) {
        buddy_idx = page_idx ^ (1<<order);
        buddy = zone_base + buddy_idx;
        if (!page_is_buddy(page, buddy, order))
            break;
        list_del(&buddy->lru);
        z->free_area[order].nr_free--;
        buddy->p_private = IN_BUDDY;
        page_idx &= buddy_idx;
        order++;
    }
    coalesced = zone_base + page_idx;
    coalesced->p_private = order;
    list_add(&coalesced->lru, &z->free_area[order].free_list);
    z->free_area[order].nr_free++;
    z->free_pages += order_size;
}

// free pages in a per_cpu_pageset back to relative zone of buddy system
void free_pages_bulk(struct zone *z, struct list_head *page_list, int order)
{
    Page     page;
    uint32_t page_size = (1<<order);
     
    for (int i = 0; i < page_size; i++) {
        page = list_entry(page_list->prev, struct page, lru);
        list_del(&page->lru);
        page->p_ref = 0;
        __free_pages_bulk(page, z, 0);
    }
}

// per_cpu_cache alloc & free
// gfp_flags's bit 0 = __GFP_COLD
Page buffered_rmqueue(struct zone *z, int order, gfp_t gfp_flags)
{
    int                      irq;
    int                      cold;
    int                      order_size;
    Page                     page;
    struct per_cpu_pageset  *pageset;

    irq = (gfp_flags && __GFP_IRQ);
    order_size = (1<<order);
firststep:
    if (order)
        goto forthstep;

    cold = (gfp_flags & __GFP_COLD);
    pageset = &z->pageset[cold];

    // We have to alloc enough pages above low watermark.
    if (pageset->count <= pageset->low) {
        pageset->batch = (pageset->high - pageset->low) / 2 + 1; 
        if (z->free_pages - pageset->batch <= z->pages_low)
            return 0;
        for (int i = 0; i < pageset->batch; i++) {
            if (!(page = __rmqueue(z, 0))) 
                return 0;
            pageset->count++;
            list_add(&page->lru, &pageset->free_list);
        }
        pageset->batch = 0;
    }

    //if (pageset->count > pageset->low) {
    if (!(page = list_entry(pageset->free_list.next, struct page, lru)))
        return 0;
    //if (!page)
    pageset->count--; 
    list_del(&page->lru);
    goto fifthstep;
    //}
        
forthstep:
    // If order > 0, which means that we have to 
    // alloc free pages directly from buddy system.
    if (z->free_pages - order_size <= z->pages_low)
        return 0;
    if (!(page = __rmqueue(z, order)))
        return 0;

fifthstep:
    page->p_private = OUT_OF_BUDDY;
    if ((gfp_flags & __GFP_ZERO)) {
        for (int i = 0; i < order_size; i++) 
            memset(page2va(page+i), 0, PGSIZE);      
    }
    return page;
}

void free_hot_cold_page(Page page, int cold)
{
    int  zone_idx = page->flag & 0x1;
    struct zone  *z = zones_list[zone_idx];
    struct per_cpu_pageset *pageset = &z->pageset[cold];

    spin_lock_irqsave(&z->zone_lock);
    if (pageset->count > pageset->high) {
        pageset->batch = (pageset->high - pageset->low) / 2;
        pageset->batch += pageset->low;
        for (int i = 0; i < pageset->batch; i++)
            free_pages_bulk(z, &pageset->free_list, 0);
        pageset->count -= pageset->batch;
        pageset->batch = 0;
    }

    // I don't clears the p_ref of the page
    // because i assume that page->p_ref = 0
    // only pages who in buddy system have p_ref = 0
    list_add(&page->lru, &pageset->free_list);
    pageset->count++;
    wakeup(&z->zone_wait_queue, &proc_manager.proc_table_lock);
    spin_unlock_irqrestore(&z->zone_lock);
}

void free_hot_page(Page page)
{
    if (page)
        free_hot_cold_page(page, HOT_ZONE_PAGESET);
}

void free_cold_page(Page page)
{
    if (page)
        free_hot_cold_page(page, COLD_ZONE_PAGESET);
}

/*********************************
 *          BUDDY'S API
 ********************************/

// High level functions.
Page __alloc_pages(int order, gfp_t gfp_flags)
{
    Page    page;
    struct zone  *z;
    int     order_size = (1<<order);
    int     irq = gfp_flags & __GFP_IRQ;
    int     dma = gfp_flags & __GFP_DMA;
    int     wait = gfp_flags & __GFP_WAIT;

    if (order < 0 || order >= MEMLEVEL)
        return 0;

    gfp_flags &= (~__GFP_COLD);

    z = zones_list[KERN_ZONE];
    if (dma) {  
        // the number of page > 1
        spin_lock_irqsave(&z->zone_lock);
        if ((z->free_pages - order_size <= z->pages_low) && order) {
            spin_unlock_irqrestore(&z->zone_lock);
            return 0;
        }
        // reaching here means order = 0.So we have to check cache only.
        //if (z->pageset[HOT_ZONE_PAGESET].count == 0) {
        //    spin_unlock_irqrestore(&z->zone_lock);
        //    return 0;
        //}
        page = buffered_rmqueue(z, order, gfp_flags); 
        spin_unlock_irqrestore(&z->zone_lock);
        return page;
    } 

    // I assume that each irq requist only one page 
    // if it will be a change in the future,
    // Add a new zone to manage reserved area.
    if (irq) {
        spin_lock_irqsave(&z->zone_lock);
        if (z->pages_reserved > 0) {
            page = list_entry(z->reserved_pages_list.next, struct page, lru);
            list_del(&page->lru);
            z->free_pages--;
            z->pages_reserved--;
            if ((gfp_flags & __GFP_ZERO))
                memset(page2va(page), 0, PGSIZE); 
            spin_unlock_irqrestore(&z->zone_lock);
            return page;
        } else {
            spin_unlock_irqrestore(&z->zone_lock);
            return 0;
        }
    }

Loop: 
    for (int i = NZONES-1; i >= 0; i--) {
        z = zones_list[i];
        spin_lock_irqsave(&z->zone_lock);
        if (z->free_pages - order_size <= z->pages_low) {
            spin_unlock_irqrestore(&z->zone_lock);            
            continue;
        }
        if ((page = buffered_rmqueue(z, order, gfp_flags))) {
            spin_unlock_irqrestore(&z->zone_lock);
            return page; 
        }
    }

    if (wait) {
        spin_lock_irqsave(&zones_list[NORMAL_ZONE]->zone_lock);
        sleep(&zones_list[NORMAL_ZONE]->zone_wait_queue, 
                &zones_list[NORMAL_ZONE]->zone_lock);
        spin_unlock_irqrestore(&zones_list[NORMAL_ZONE]->zone_lock);
        goto Loop;
    }

    return 0;
}

void __free_pages(Page page, int order)
{
    int  order_size = (1<<order);
    struct per_cpu_pageset *pageset;
    struct zone *z;

    if (!page)
        return;

    if (!order)
        free_hot_page(page);

    z = zones_list[page_zone_idx(page)];
    pageset = &z->pageset[HOT_ZONE_PAGESET];
    spin_lock_irqsave(&z->zone_lock);
    for (int i = 0; i < order_size; i++)
        list_add(&((page+i)->lru), &pageset->free_list);
    free_pages_bulk(z, &pageset->free_list, order);
    wakeup(&z->zone_wait_queue, &proc_manager.proc_table_lock);
    spin_unlock_irqrestore(&z->zone_lock);
}


/*************************************
 *         Packaged functions
 ************************************/
/*
 *  Alloc API
 */
Page alloc_page(gfp_t gfp_flags)
{
    return __alloc_pages(0, gfp_flags);
}

uintptr_t __get_free_pages(int order, gfp_t gfp_flags)
{
    Page page = __alloc_pages(order, gfp_flags);
    if (!page)
        return 0;
    return (uintptr_t)page2va(page);
}

uintptr_t __get_free_page(gfp_t gfp_flags)
{
    return __get_free_pages(0, gfp_flags);
}

uintptr_t get_zeroed_page(gfp_t gfp_flags)
{
    return __get_free_pages(0, gfp_flags|__GFP_ZERO);
}

uintptr_t __get_dma_pages(int order, gfp_t gfp_flags)
{
    return __get_free_pages(order, gfp_flags|__GFP_DMA);
}

uintptr_t __get_reserved_page(gfp_t gfp_flags)
{
    gfp_flags &= __GFP_ZERO;
    gfp_flags |= __GFP_IRQ;
    return __get_free_page(gfp_flags);
}


/*
 * Free API
 */
void __free_page(Page page)
{
    if ((page->flag & RESERVED_PAGE))
        __free_rerserved_page(page);
    else 
        __free_pages(page, 0);
}

void free_page(uintptr_t addr)
{
    free_pages(addr, 0);
}

void free_pages(uintptr_t addr, int order)
{
    Page page = va2page(addr);
    for (int i = 0; i < (1<<order); i++) {
        __free_page(page);
        page++;
    }
}

void __free_rerserved_page(Page page)
{
    zones_list[KERN_ZONE]->free_pages++;
    list_add(&page->lru, &zones_list[KERN_ZONE]->reserved_pages_list);
}


// reserved_size & zone_size means the number of pages.
void boot_zone_init(struct zone *z, physaddr_t reserved_start, size_t reserved_size, 
                        physaddr_t zone_start, size_t zone_size)
{
    ushort        zone_flag = 0;
    size_t        n_contiguous_pages;
    struct page  *page_ptr;
    struct free_area  *free_area_p;
    struct per_cpu_pageset  *cache_p;
    physaddr_t  reserved_phy = reserved_start;
    physaddr_t  zone_page_phy = zone_start;

    z->pages_reserved = reserved_size;
    z->pages_low = reserved_size;
    z->zone_first_page = &pages[PGNUM(zone_page_phy)];
    z->free_pages = reserved_size + zone_size;
    spinlock_init(&z->zone_lock, "zone_locks");
    LIST_HEAD_INIT(z->reserved_pages_list);
    LIST_HEAD_INIT(z->zone_wait_queue);

    for (int i = 0; i < 2; i++) {
        cache_p = &z->pageset[i];
        cache_p->low = 0;
        cache_p->count = 0;
        cache_p->batch = 0;
        cache_p->high = (PTSIZE >> PGSHIFT); // 4 MB
        LIST_HEAD_INIT(cache_p->free_list);
    }

    zone_flag = (zones_list[KERN_ZONE] == z)?KERN_ZONE:NORMAL_ZONE;

    if (reserved_size) {
        zone_flag |= RESERVED_PAGE;
        while (reserved_phy < (reserved_start + reserved_size * PGSIZE)) {
            if (!(page_ptr = pa2page(reserved_phy)))
                break;
            page_ptr->flag = zone_flag;
            page_ptr->p_ref = 0;
            page_ptr->p_private = OUT_OF_BUDDY;
            list_add(&page_ptr->lru, &z->reserved_pages_list);
            reserved_phy += PGSIZE;
        }
        zone_flag &= (~RESERVED_PAGE);
    }

    // The levels contain 1, 2, 4, 8, 16, 32, 
    // 64, 128, 256, 512 and 1024 contiguous page frams.
    n_contiguous_pages = 1024;
    for (int i = MEMLEVEL-1; i >= 0; i--) {
        z->free_area[i].nr_free = 0;
        LIST_HEAD_INIT(z->free_area[i].free_list);
        while (zone_size >= n_contiguous_pages) {
            if (!(page_ptr = pa2page(zone_page_phy)))
                break;
            page_ptr->flag = zone_flag;
            page_ptr->p_ref = 0;
            page_ptr->p_private = i;
            list_add(&page_ptr->lru, &z->free_area[i].free_list);

            z->free_area[i].nr_free++;
            zone_size -= n_contiguous_pages;
            zone_page_phy += (PGSIZE * n_contiguous_pages);
        }
        n_contiguous_pages /= 2;
    }
}
