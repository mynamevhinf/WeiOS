#ifndef _BUDDY_H_
#define _BUDDY_H_

#ifndef __ASSEMBER__

#include <include/types.h>
#include <include/mem.h>
#include <include/pmap.h>
#include <include/lock.h>
#include <include/string.h>

#define NZONES     2

#define __GFP_COLD 0x0001
#define __GFP_ZERO 0x0002
#define __GFP_WAIT 0x0004
// __GFP_DMA equals to __GFP_DMA in Linux
#define __GFP_DMA  0x0008
#define __GFP_IRQ  0x0010

// kernel_zone's address is below to 16MB(physical addr)
#define KERN_ZONE       0x0
#define NORMAL_ZONE     0x1

#define COLD_ZONE_PAGESET   1
#define HOT_ZONE_PAGESET    0

// The levels contain 1, 2, 4, 8, 16, 32, 
// 64, 128, 256, 512 and 1024 contiguous page frams.
#define MEMLEVEL        11
#define IN_BUDDY        12
#define OUT_OF_BUDDY    13

/*
 * Two blocks are considered buddies of:
 *     1. Both blocks have the same size, say b.
 *     2. They are located in contiguous physical addresses.
 *     3. The physical addresses of the FIRST page frame of the first 
 *        block is a multiple of 2*b*(2^12)
 */
struct free_area {
    uint32_t          nr_free;  // the number of free blocks(in size 2^k)
    struct list_head  free_list;
};

/*
 * The structure of per-cpu cache
 */
struct per_cpu_pageset {
    uint32_t  count;
    uint32_t  low;
    uint32_t  high;
    uint32_t  batch;
    // A doubly-link list of pages
    struct list_head free_list;
};

#define page_zone_idx(page) (page->flag & 0x1)

/*
 * I divide usable memory to two region.
 * each region represented by a single struct zone.
 * one for Kernel & DMA, named struct zone zone_normal;
 * the other shared with all processes, without specific prior,
 * named struct zone zone_high;
 */
/*
 * In fact, the structure is used for 'buddy system'
 */

struct zone {
    // The number of free pages in the zone.
    int   free_pages;
    int   pages_low;

    int   pages_reserved;
    struct list_head  reserved_pages_list;
    // Unimplemented
    //spinlock_t  zone_lock;
    struct free_area  free_area[MEMLEVEL];
    // The Array's size depended on cpus
    // We figure it out during boot time.
    // Or hard code, just only 1.
    //
    // cold cache = pageset[1]
    // hot cache = pageset[0]
    struct per_cpu_pageset   pageset[2];
    struct list_head  zone_wait_queue;
    struct spinlock   zone_lock;
    struct page *zone_first_page;      // A subset of pages(global).
};

static int page_is_buddy(Page page, Page buddy, int order);

Page __rmqueue(struct zone *z, int order);
void __free_pages_bulk(Page page, struct zone *z, int order);
void free_pages_bulk(struct zone *z, struct list_head *page_list, 
                     int order);
Page buffered_rmqueue(struct zone *z, int order, gfp_t gfp_flags);
void free_hot_cold_page(Page page, int cold);
void free_hot_page(Page page);
void free_cold_page(Page page);
Page __alloc_pages(int order, gfp_t gfp_flags);
void __free_pages(Page page, int order);


//  API
Page alloc_page(gfp_t gfp_flags);
uintptr_t __get_free_pages(int order, gfp_t gfp_flags);
uintptr_t __get_free_page(gfp_t gfp_flags);
uintptr_t get_zeroed_page(gfp_t gfp_flags);
uintptr_t __get_dma_pages(int order, gfp_t gfp_flags);
uintptr_t __get_reserved_page(gfp_t gfp_flags);

void __free_page(Page page);
void free_page(uintptr_t addr);
void free_pages(uintptr_t addr, int order);
void __free_rerserved_page(Page page);

void boot_zone_init(struct zone *z, physaddr_t reserved_start, size_t reserved_size, 
                        physaddr_t zone_first_page, size_t zone_size);

#endif

#endif
