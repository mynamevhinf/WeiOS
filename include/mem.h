#ifndef _MEM_H_
#define _MEM_H_

#ifndef __ASSEMBLER__

#include <include/mmu.h>
#include <include/kernel.h>

#endif

/* Physical memory: 512M                              Permissions
 * Virtual memory map:                                kernel/user 

 *    4 Gig -------->  +------------------------------+                 --+
 *                     |                              | RW/--             |
 *                     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~                   |
 *                     :              .               :                   |
 *                     :              .               :                   |
 *                     :              .               :          RAM: 512MB
 *                     |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~| RW/--             |
 *                     |                              | RW/--             |
 *                     |   Remapped Physical Memory   | RW/--             |
 *                     |                              | RW/--             |
 *    KERNBASE, ---->  +------------------------------+ 0xf0000000      --+
 *    KSTACKTOP        |        Kernel Stack          | RW/--  KSTACKSIZE  
 *                     | - - - - - - - - - - - - - - -|                 
 *                     |      Invalid Memory (*)      | --/--  KSTACKSIZE
                       | - - - - - - - - - - - - - - -|
                       :              .               :
                       :              .               :  
 *    MMIOLIM ------>  +------------------------------+ 0xefc00000      
 *                     |       Memory-mapped I/O      | RW/--  PTSIZE
 *    MMIOBASE ----->  +------------------------------+ 0xef800000
 *                     |      Invalid Memory (*)      | --/--  PTSIZE  
 *    ULIM     ----->  +------------------------------+ 0xef400000      
 *                     |  Cur. Page Table (User R-)   | R-/R-  PTSIZE
 *    UVPT      ---->  +------------------------------+ 0xef000000
 *                     |          RO PAGES            | R-/R-  PTSIZE
 *    UPAGES    ---->  +------------------------------+ 0xeec00000
 *                     |          RO PROCS            | R-/R-  PTSIZE
 * UTOP,UPROCS  ---->  +------------------------------+ 0xee800000
 *                     |                              |
 *                     |                              |
 *                     |          .........           |
                       |	                            |
                       |                              |
 *    USTACKTOP  --->  +------------------------------+ 0xd0000000
 *                     |      Normal User Stack       | RW/RW  PGSIZE
      USTACKBOTTOM ->  +------------------------------+ 0xcffff000
                       |      Emptry memory space     |
 *    UXSTACKTOP --->  +------------------------------+ 0xcfffe000
 *                     |      User Exception Stack    | RW/RW  PGSIZE
      UXSTACKBOTTOM -> +------------------------------+ 0xcfffd000
 *                     |      Empty memory space      |	
 *    MMAPTOP   --->   +------------------------------+ 0xcfffc000
                       |                              |
                       |    MMAP and thread stack     |
                       |                              |
      HEAPTOP   --->   |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~| 0xc0000000
 *                     .                              .
 *                     .                              .
 *                     .                              .
 *                     .                              .
 *                     |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|
 *                     |     Program Data & Heap      |
 *    UTEXT -------->  +------------------------------+ 0x08048000
 *                     |                              |  
 *    PFTEMP ------->  +------------------------------+ 0x08047000
                       |                              |
 *                     |                              |
 *    UTEMP -------->  +------------------------------+ 0x07c00000      --+
 *                     |       Empty Memory (*)       |                   |
 *                     | - - - - - - - - - - - - - - -|                   |
 *                     |  User STAB Data (optional)   |              PTSIZE
 *    USTABDATA ---->  +------------------------------+ 0x00200000        |
 *                     |       Empty Memory (*)       |                   |
 *    0 ------------>  +------------------------------+                 --+
 *
 */

#define IOPHYSMEM   0x000A0000
#define MMAPTOP     0xCFFFC000
#define HEAPTOP     0xC0000000

// the kernel stack's size of per process
#define USTACKSIZE  PGSIZE
#define KSTACKSIZE  PGSIZE
#define UXSTACKSIZE PGSIZE

#define KERNBASE    0xF0000000
#define KSTACKTOP   KERNBASE

#define MMIOLIM     0xEFC00000
#define MMIOBASE    (MMIOLIM - PTSIZE)

#define ULIM        (MMIOBASE - PTSIZE)
#define UVPT        (ULIM - PTSIZE)
#define UPAGES      (UVPT - PTSIZE)
#define UPROCS      (UPAGES - PTSIZE)

#define UTOP        UPROCS

#define USTACKTOP   0xD0000000
#define UXSTACKTOP  0xCFFFE000
#define UTEXT       0x08048000
#define USTABDATA   0x00200000

#define PFTEMP      (UTEXT - PGSIZE)
#define UTEMP       (UTEXT - PTSIZE)

#define USTACKBOTTOM  (USTACKTOP - PGSIZE)
#define UXSTACKBOTTOM (UXSTACKTOP - PGSIZE)

#define PG_RESERVED 0x0002

/* Global descriptor numbers */
#define GD_KT   0x08
#define GD_KD   0x10
#define GD_UT   0x18
#define GD_UD   0x20
#define GD_TSS  0x28


#ifndef __ASSEMBLER__

//#define is_page_dynamic(page)  (page && !(page->flag & PG_RESERVED))

#define RESERVED_PAGE   0x0002
#define PAGE_IN_SLAB    0x0004
// Used for every physical pages
typedef struct page *Page;
struct page {
    // 0th bit means which zone the page comes from
    // 0 -- kernel_zone
    // 1 -- normal_zone

    // 1st bit means wether the page is reserved
    // 0 - not reserved
    // 1 - reserved
    
    // 2nd bit means wether the page is in slab system
    // 0 - not  1 - in 
    ushort          flag;
    // When a page frame is free, we set p_private = order in buddy system.
    // otherwise, we set p_private = IN_BUDDY or OUT_OF_BUDDY;
    uint32_t          p_private;
    uintptr_t         p_ref;
    // If a page is assigned to a slan
    // i set lru.next = cache descriptor's virtual address
    // and lru.prev = slab descriptor's virtual address.
    struct list_head  lru;
};

#endif

#endif
