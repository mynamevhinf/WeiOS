#include <include/mem.h>
#include <include/mmu.h>
#include <include/x86.h>
#include <include/pmap.h>
#include <include/cmos.h>
#include <include/slab.h>
#include <include/proc.h>
#include <include/file.h>
#include <include/error.h>
#include <include/stdio.h>
#include <include/types.h>
#include <include/buddy.h>
#include <include/string.h>
#include <include/kernel.h>
#include <include/sysfunc.h>
#include <include/kmalloc.h>

// used during boot time.
uint32_t npages_num;
uint32_t npages_base_num;
struct page  *pages;

pde_t *kern_pgdir;              // real kernel's page directory
pde_t *uvpt, *uvpd;

static char  *boot_next_free;

static uintptr_t user_mem_check_addr;

extern struct zone   kernel_zone;
extern struct zone   normal_zone;
extern struct zone  *zones_list[];


#define read_memory(offset)   \
    ((cmos_read(offset+1)<<8) | (cmos_read(offset)))

static void memory_dect(void)
{
    // (KB)
    uint32_t base_mem, ext16_mem, ext_mem, total_mem;
    
    base_mem = read_memory(CMOS_BASE_MEM_LOW);
    ext16_mem = read_memory(CMOS_EXT16_MEM_LOW);
    ext_mem = read_memory(CMOS_EXT_MEM_LOW) * 64;

    if (ext16_mem)
        total_mem = 16 * 1024 + ext16_mem;
    else if (ext_mem)
        total_mem = 1024 + ext_mem;
    else
        total_mem = base_mem;

    npages_num = total_mem / 4;          // 1 page's size = 4KB = 4096B
    npages_base_num = base_mem / 4;

    //prink("Physical memory: %uKB, Base = %uKB, Extended = %uKB\n",
    			//total_mem, base_mem, total_mem - base_mem);
}

static char *boot_alloc(uint32_t n)
{
	if (!boot_next_free) {
		extern char end[];
		boot_next_free = (char *)ROUNDUP((char *)end, PGSIZE);	
	}

	if (n == 0)
		return boot_next_free;

	char *tmp_addr;
	if (n > 0) {
		n = ROUNDUP(n, PGSIZE);
		tmp_addr = boot_next_free;
		boot_next_free += n;
		// Because of the limit of memory we mapped during boot
        // we have only 4MB memory available.
		//if (PADDR(result_addr) > (uintptr_t)page2pa(&pages[npages_num-1]))
		//	panic("there is not enough room size!\n");
		return tmp_addr;
	}
	return 0;
}

// Used to initialize struct zone.
static void buddy_init(void)
{
	// 4 MB for reserved area 
	// PTSIZE = 4MB
	zones_list[KERN_ZONE] = &kernel_zone;
	zones_list[NORMAL_ZONE] = &normal_zone;


	physaddr_t  reserved_start = (PTSIZE<<2);	// 16 MB
	size_t  reserved_size = PDENTRIES/2;		// 512 page frames

	physaddr_t  kernel_start = (physaddr_t)PADDR(boot_next_free);
	size_t	kernel_size = (reserved_start - kernel_start) >> PGSHIFT;

	physaddr_t  normal_start = reserved_start + (reserved_size>>PGSHIFT);// 18 MB
	size_t  normal_size = npages_num - (normal_start >> PGSHIFT);	// 

	// Firstly is kernel_zone.
	boot_zone_init(zones_list[KERN_ZONE], reserved_start, reserved_size, 
												kernel_start, kernel_size);

	// Next is normal_zone.
	boot_zone_init(zones_list[NORMAL_ZONE], 0, 0, normal_start, normal_size);	

}

void mem_init(void)
{
	uint32_t cr0;
	uint32_t need_bytes;

    memory_dect();

	kern_pgdir = (pde_t *)boot_alloc(PGSIZE);
	memset(kern_pgdir, 0, PGSIZE);

	kern_pgdir[PDINDEX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;

    // Alloc enough room for Pages'sturctures.
	need_bytes = sizeof(struct page)*npages_num;
	pages = (Page)boot_alloc(need_bytes);
	memset(pages, 0, need_bytes);

	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U | PTE_P);

	extern char  kernstack[];
	boot_map_region(kern_pgdir, KSTACKTOP - KSTACKSIZE, KSTACKSIZE, 
                                        PADDR(kernstack), PTE_P|PTE_W);

	need_bytes = ROUNDUP(0xffffffff - KERNBASE, PGSIZE);
	boot_map_region(kern_pgdir, KERNBASE, need_bytes, 0, PTE_P | PTE_W);

	buddy_init();
	slab_init();

	uvpt = (pde_t *)UVPT;
	uvpd = (pde_t *)(UVPT + (UVPT >> 12) * 4);

	lcr3(PADDR(kern_pgdir));

	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);
}

/****************************************************************
 *	 Follows are functions of memory management during boot time.
 ****************************************************************/
static Page boot_page_alloc(int alloc_zero)
{
	//static char *boot_alloc(uint32_t n)
	void  *va = (void *)boot_alloc(PGSIZE);
	struct page  *PageInfo = va2page((uintptr_t)va);

	if (alloc_zero)
		memset(va, 0, PGSIZE);
	PageInfo->flag = 0; 
	PageInfo->p_ref = 1;
	PageInfo->p_private = OUT_OF_BUDDY;
	return PageInfo;
}

static pte_t *boot_pgdir_walk(pde_t *pgdir, const void *va, int create)
{
	Page        Tp;
    uint32_t    paddr;
	uint32_t    entry_addr = (uintptr_t)pgdir + (PDINDEX(va)<<2);

    paddr = *((uint32_t *)entry_addr);

	if (!(paddr & PTE_P)) {
		if (!create)
			return 0;
		if (!(Tp = boot_page_alloc(ALLOC_ZERO)))
			return 0;
		*((uint32_t *)entry_addr) = (page2pa(Tp) | PTE_P);
	}
	// Now calculate the index of page table.
	paddr = (*((physaddr_t *)entry_addr)) & 0xfffff000;
	entry_addr = KADDR(paddr) + (PTINDEX(va)<<2);
	return (pte_t *)entry_addr;
}

static void boot_map_region(pde_t *pgdir, uintptr_t va, 
                            size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	pte_t 		*tmp_pt_entry;
	physaddr_t 	 pa_end = pa + size;
	physaddr_t 	 tmp_entry_value;

	if (!(perm & PTE_PS)) {
		while (pa < pa_end) {
			if (!(tmp_pt_entry = boot_pgdir_walk(pgdir, (void *)va, ALLOC_ZERO)))
				panic("Fuck Yeah!!!\n");
			//prink("tmp_pt_entry = %p\n", tmp_pt_entry);
			*tmp_pt_entry = pa | perm | PTE_P;
			pgdir[PDINDEX(va)] |=  (perm | PTE_P);
			va += PGSIZE;
			pa += PGSIZE;
		}
	} else 
		pgdir[PDINDEX(va)] |= ((pa & 0xffc00000)| PTE_P | PTE_PS | perm);
}


/****************************************************************
 *	 Follows are functions of conventional memory management.
 ****************************************************************/
Page page_alloc(int alloc_zero)
{
	uintptr_t     p_va;
	struct page  *PageInfo;
	
	gfp_t  gfp_flags = 0;
	if (alloc_zero) 
		gfp_flags |= __GFP_ZERO;
	
	p_va = (uintptr_t)kmalloc(PGSIZE, gfp_flags);
	if (!(PageInfo = va2page(p_va)))
		return 0;
	PageInfo->p_ref = 0;
	return PageInfo;
}

void page_free(Page pp)
{
	kfree(page2va(pp));
}

void page_decrease_ref(struct page *page)
{
	if ((page->p_ref -= 1) == 0)
		page_free(page);
}

pte_t *pgdir_walk(pde_t *pgdir, const void *va, int create)
{
	Page        Tp;
    uint32_t    paddr;
	uint32_t    entry_addr = (uintptr_t)pgdir + (PDINDEX(va)<<2);

    paddr = *((uint32_t *)entry_addr);
	if (!(paddr & PTE_P)) {
		if (!create)
			return 0;
		if (!(Tp = page_alloc(ALLOC_ZERO)))
			return 0;
		Tp->p_ref++;
		*((uint32_t *)entry_addr) = (page2pa(Tp) | PTE_P);
	}
	// Now calculate the index of page table.
	paddr = (*((physaddr_t *)entry_addr)) & 0xfffff000;
	entry_addr = KADDR(paddr) + (PTINDEX(va)<<2);
	return (pte_t *)entry_addr;
}

int page_insert(pde_t *pgdir, struct page *pp, void *va, int perm)
{
	// Fill this function in
	pde_t      *tmp_pd_entry;
	pte_t      *tmp_pt_entry;
	physaddr_t	tpa;
	physaddr_t  pa = (physaddr_t)page2pa(pp);
	if (!(tmp_pt_entry = pgdir_walk(pgdir, va, 1)))
		return -E_NO_MEM;

	// We have to update pd_entry too.
	tpa = *((physaddr_t *)tmp_pt_entry);
	if ((tpa & PTE_P)) {
		if ((tpa & 0xfffff000) == pa) {
			*((physaddr_t *)tmp_pt_entry) = (pa | perm | PTE_P);
			pgdir[PDINDEX(va)] |= perm;
			tlb_invalidate(pgdir, va);
			return 0;
		} else 
			page_remove(pgdir, va);
	}
	// i don't add p_ref, what if i am wrong?
	*((physaddr_t *)tmp_pt_entry) = (pa | perm | PTE_P);
	pgdir[PDINDEX(va)] |= perm;
	pp->p_ref++;

	tlb_invalidate(pgdir, va);
	return 0;
}

struct page *page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	// Fill this function in
	physaddr_t   	 tmp_phy_addr;
	pte_t 			*tmp_pt_entry;

	if (!(tmp_pt_entry = pgdir_walk(pgdir, va, 0))) 
		return 0;
	
	if (pte_store)
		*pte_store = tmp_pt_entry;

	tmp_phy_addr = *((physaddr_t *)tmp_pt_entry);
	tmp_phy_addr &= 0xfffff000; 
	return pa2page(tmp_phy_addr);
}

void page_remove(pde_t *pgdir, void *va)
{
	Page              Pinfo;
	pte_t 			 *pte_store;

	Pinfo = page_lookup(pgdir, va, &pte_store);
	if (Pinfo) {
		page_decrease_ref(Pinfo);
		*((physaddr_t *)pte_store) = 0;
		tlb_invalidate(pgdir, va);
	}
}


void tlb_invalidate(pde_t *pgdir, void *va)
{
	if (!curproc || curproc->proc_pgdir == pgdir)
		invlpg(va);
}

int user_mem_check(struct proc *p, const void *va, size_t len, int perm)
{
	pde_t	   *tp;
	uintptr_t 	va_t;
	uintptr_t 	va_start = (uint32_t)va;
	uintptr_t 	va_end = va_start + len;

	if (va_start >= ULIM) {
		user_mem_check_addr = va_start;
		return -E_FAULT;
	}
	if (va_end >= ULIM) {
		user_mem_check_addr = ULIM;
		return -E_FAULT;
	}

	va_start = ROUNDDOWN(va_start, PGSIZE);
	va_end = ROUNDUP(va_end, PGSIZE);
	va_t = va_start;
	while (va_t < va_end) {
		if (!(p->proc_pgdir[PDINDEX(va_t)] & perm))
			break;
		tp = (pte_t *)KADDR(PTE_ADDR(p->proc_pgdir[PDINDEX(va_t)]));
		if (!(tp[PTINDEX(va_t)] & perm))
			break;
		va_t += PGSIZE;
	}

	if (va_t < va_end) {
		user_mem_check_addr = ((va_end - (uintptr_t)va) < PGSIZE)?
                                (uintptr_t)va:va_t;
		return -E_FAULT;
	}

	return 0;
}

void user_mem_assert(struct proc *p, const void *va, size_t len, int perm)
{
	if (user_mem_check(p, va, len, perm | PTE_U) < 0) {
		prink("user_mem_assert failed. pid = %u, addr = %p\n", 
			  p->pid, user_mem_check_addr);
		if (p == curproc)
			exit();
		else
			murder(p->pid);
	}
}

// i leave the page marked PTE_P alone.
// and alloc a new physical page if the page table entry is empty.
int grow_vm(pde_t *pgdir, uint32_t oldsz, uint32_t newsz)
{
	uint32_t va;
	pte_t *ptentry;
	struct page *Pinfo;

	if (newsz >= UTOP)
		return 0;
	if (oldsz >= newsz)
		return oldsz;

	for (va = ROUNDUP(oldsz, PGSIZE); va < newsz; va += PGSIZE) {
		if (!(ptentry = pgdir_walk(pgdir, (void *)va, 1)))
			return 0;
		if ((*ptentry) & PTE_P)
			continue;
		if (!(Pinfo = page_alloc(ALLOC_ZERO)))
			return 0;
		if (page_insert(pgdir, Pinfo, (void *)va, PTE_W|PTE_U|PTE_P) < 0)
			return 0;
	}
	return newsz;
}

// we have to call iget(i) and ilock(i) before we reach the function.
int load_program(pde_t *pgdir, char *des, struct inode *i, uint32_t off, uint32_t size)
{
	pte_t *ptentry;
	uint32_t j, pa, nbytes;

	for (j = 0; j < size; j += PGSIZE) {
		if (!(ptentry = pgdir_walk(pgdir, des + j, 0)))
			panic("load_program: address should be allocated!!!\n");
		pa = PTE_ADDR(*ptentry);
		//prink("des+j = %p, ptentry = %p\n", (uint32_t)(des+j), *ptentry);
		nbytes = (size-j < PGSIZE)?(size-j):(PGSIZE);
		if (readi(i, (char *)KADDR(pa), off+j, nbytes) != nbytes)
			return -1;
	}

	return 0;
}