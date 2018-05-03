#ifndef _PMAP_H_
#define _PMAP_H_

#include <include/types.h>
#include <include/mem.h>
#include <include/mmu.h>
#include <include/proc.h>

extern Page pages;
extern size_t npages_num;

extern pde_t *kern_pgdir;

#define ALLOC_ZERO      1

#define PADDR(X)        (((uint32_t)X)-KERNBASE)

#define KADDR(X)        (((uint32_t)X)+KERNBASE)

static inline physaddr_t page2pa(Page target_page)
{
    if (!target_page)
        return 0;
    return (target_page - pages) << PGSHIFT;
}

static inline void *page2va(struct page *target_page)
{
    return (void *)KADDR(page2pa(target_page));
}

static inline struct page *pa2page(physaddr_t pa)
{
    if (PGNUM(pa) >= npages_num)
        return 0;
    return &pages[PGNUM(pa)];
}

static struct page *va2page(uintptr_t va)
{
    if (va < KERNBASE)
        return 0;
    return pa2page(PADDR(va));
}

static void memory_dect(void);
static char *boot_alloc(uint32_t n);
void mem_init(void);
static void buddy_init(void);
Page page_alloc(int alloc_zero);
void page_free(Page pp);
void page_decrease_ref(struct page *page);
pte_t *pgdir_walk(pde_t *pgdir, const void *va, int create);
static Page boot_page_alloc(int alloc_zero);
static pte_t *boot_pgdir_walk(pde_t *pgdir, const void *va, int create);
static void boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm);
int page_insert(pde_t *pgdir, Page pp, void *va, int perm);
Page page_lookup(pde_t *pgdir, void *va, pte_t **pte_store);
void page_remove(pde_t *pgdir, void *va);
void tlb_invalidate(pde_t *pgdir, void *va);
int user_mem_check(struct proc *p, const void *va, size_t len, int perm);
void user_mem_assert(struct proc *p, const void *va, size_t len, int perm);
int grow_vm(pde_t *pgdir, uint32_t oldsz, uint32_t newsz);
int load_program(pde_t *pgdir, char *des, struct inode *i, uint32_t off, uint32_t size);

#endif
