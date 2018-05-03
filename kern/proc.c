#include <include/types.h>
#include <include/mmu.h>
#include <include/x86.h>
#include <include/elf.h>
#include <include/proc.h>
#include <include/pmap.h>
#include <include/trap.h>
#include <include/lock.h>
//#include <include/file.h>
#include <include/buddy.h>
#include <include/error.h>
#include <include/sched.h>
#include <include/stdio.h>
#include <include/string.h>
#include <include/kernel.h>
#include <include/kmalloc.h>

extern struct cpu  single_cpu;
extern pde_t *kern_pgdir;

extern void forkret(void);
extern void trapsret(void);
extern char _binary_initprocess_start[];

struct proc *rootproc;
struct proc_manager  proc_manager;

struct cpu *mycpu(void)
{
	if ((reflags() & EFLAGS_IF)) 
		panic("mycpu called with interruptible.");
	return &single_cpu;
}

struct proc *myproc(void)
{
	struct cpu *c;
	struct proc *p;
	special_cli();
	c = mycpu();
	p = c->proc;
	special_sli();
	return p;
}

// I think i have no need to initialize.
void proc_init(void)
{
	// Initialize proc_manager.
	/*
	for (int i = 0; i < 32; i++)
		proc_manager.id_bitmap[i] = 0;
	for (int i = 0; i < NPROC; i++)
		proc_manager.proc_table[i] = 0;
	proc_manager.n_procs_alive = 0;
	*/
	LIST_HEAD_INIT(proc_manager.procs_desc_cache);
	spinlock_init(&proc_manager.proc_table_lock, "proctabe_lock");
	for (int i = 0; i < 32; i++)
		proc_manager.id_bitmap[i] = 0xFFFFFFFF;

	mycpu()->proc = 0;
	spinlock_init(&mycpu()->per_cpu_lock, "cpu_locks");
    mycpu()->run_queue =    \
     (struct proc_queue *)kmalloc(sizeof(struct proc_queue), __GFP_ZERO);
    mycpu()->exhausted_queue =    \
     (struct proc_queue *)kmalloc(sizeof(struct proc_queue), __GFP_ZERO);
	if (!(mycpu()->run_queue) || !(mycpu()->exhausted_queue))
		panic("proc_init() Failed!!!\n");
	mycpu()->run_queue->priority_bitmap = 0;
	mycpu()->exhausted_queue->priority_bitmap = 0;
	
	for (int i = 0; i < N_PRIORITY; i++) {
		LIST_HEAD_INIT(mycpu()->run_queue->procs_in_queue[i]);
		LIST_HEAD_INIT(mycpu()->exhausted_queue->procs_in_queue[i]);
	}

    lldt(0);
}

static uint32_t get_pid(void)
{
	int       t_size;
	uint32_t  id_mask;
	uint32_t  idx = 0;

	t_size = sizeof(uint32_t) * 8;
	for (int i = 0; i < 32; i++) {
		while (idx < t_size) {
			id_mask = 1<<idx; 
			if ((id_mask & proc_manager.id_bitmap[i])) {
				proc_manager.id_bitmap[i] &= ~id_mask;
				return idx + i*32;
			}
			idx++;
		}
		idx = 0;
	}
	return 0;
}

static void clear_pid(pid_t pid)
{
	ushort	t_no = pid / sizeof(uint32_t);
	ushort  idx = pid % sizeof(uint32_t);

	proc_manager.id_bitmap[t_no] |= (1<<idx);
}

struct proc *get_proc_desc(void)
{
	struct proc *p;

	if (!(list_empty(&proc_manager.procs_desc_cache))) {
		p = list_entry(proc_manager.procs_desc_cache.next,	\
										struct proc, kinds_list);
		list_del(&p->kinds_list);
		memset(p, 0, sizeof(struct proc));
	} else
		p = (struct proc *)kmalloc(sizeof(struct proc), __GFP_ZERO);

	return p;
}

// We have to call it when before wait() returns
void proc_desc_destroy(struct proc *p)
{
	clear_pid(p->pid);
	proc_manager.proc_table[p->pid] = 0;
	p->status = FREE;
	proc_manager.n_procs_alive--;
	list_add(&p->kinds_list, &proc_manager.procs_desc_cache);
}

int pid2proc(pid_t pid, struct proc **proc_store, int check)
{
	struct proc  *p;

	if (!pid) {
		*proc_store = curproc;
		return 0;
	}

	if (pid > NPROC) {
		*proc_store = 0;
		return -E_BAD_PROC;
	}

	p = proc_manager.proc_table[pid];
	if (p->status == FREE || p->pid != pid) {
		*proc_store = 0;
		return -E_BAD_PROC;
	}

	if (check && p != curproc && p->ppid != curproc->pid) {
		*proc_store = 0;
		return -E_BAD_PROC;
	}

	*proc_store = p;
	return 0;
}

// in fact, i can rewrite the proc_setup_vm() to keep a simple style.
pde_t *setup_vm(void)
{
	pde_t *pgdir;
	struct page *Pinfo;

	if (!(Pinfo = page_alloc(ALLOC_ZERO)))
		return 0;
	pgdir = (pde_t *)page2va(Pinfo);
	for (int i = PDINDEX(UTOP); i < PDENTRIES; i++)
		pgdir[i] = kern_pgdir[i];
	pgdir[PDINDEX(KSTACKTOP - KSTACKSIZE)] = 0;
	pgdir[PDINDEX(UVPT)] = PADDR(pgdir) | PTE_P | PTE_U;

	return pgdir;
}

// Doesn't care about user stack, kernel stack.
int proc_setup_vm(struct proc *p)
{
	pde_t *pgdir;

	if (!(pgdir = setup_vm()))
		return -E_NO_MEM;
	p->proc_pgdir = pgdir;

    return 0;
}

int proc_region_alloc(struct proc *p, void *va, size_t len, int perm)
{	
	struct page 		*Tp;
	uint32_t	 		 va_t;
	uint32_t     		 va_start = ROUNDDOWN((uint32_t)va, PGSIZE);
	uint32_t	 		 va_end = ROUNDUP((uint32_t)va + len, PGSIZE);
	pte_t 				*tmp_pt_entry;

	va_t = va_start;
	while (va_t < va_end) {
		if (!(Tp = page_alloc(ALLOC_ZERO)))
			return -E_NO_MEM;
		if (page_insert(p->proc_pgdir, Tp, (void *)va_t, perm|PTE_P))
			return -E_NO_MEM; 	
		va_t += PGSIZE;
	}
	return 0;
}

void pgdir_free(pde_t *pgdir)
{
	pte_t *ptable;
	physaddr_t paddr;
	struct page *Pinfo;
	int pde_number, pte_number;

	for (pde_number = 0; pde_number < PDINDEX(UTOP); pde_number++) {
		if (!(pgdir[pde_number] & PTE_P))
			continue;
		paddr = PTE_ADDR(pgdir[pde_number]);
		ptable = (pte_t *)KADDR(paddr);
		for (pte_number = 0; pte_number < PDENTRIES; pte_number++) {
			if (ptable[pte_number] & PTE_P) {
				Pinfo = pa2page(PTE_ADDR(ptable[pte_number]));
				page_decrease_ref(Pinfo);
			}
		}
		page_decrease_ref(pa2page(paddr));
		pgdir[pde_number] = 0;
	}
}

// Free all memory process owns including kernel stack.
void proc_free(struct proc *p)
{
	pgdir_free(p->proc_pgdir);
}

//int proc_alloc(struct proc **new_proc_store, struct proc *parent)
int proc_alloc(struct proc **new_proc_store)
{
	int       	 r;
	void	    *va;
	char 	    *k_esp;
	struct page *Pinfo;
	struct proc *p;

	spin_lock_irqsave(&proc_manager.proc_table_lock);

	if (proc_manager.n_procs_alive == NPROC) {
		r = -E_NO_FREE_PROC;
		goto proc_allc_failed;
	}

    if (!(p = get_proc_desc())) {
    	r = -E_NO_MEM;
    	goto proc_allc_failed;
    }
	if ((r = proc_setup_vm(p)) < 0) {
		proc_desc_destroy(p);
		goto proc_allc_failed;
	}
	
	proc_manager.n_procs_alive++;

	p->pid = get_pid();
	// write the ptr to slot.
    proc_manager.proc_table[p->pid] = p;

    p->status = READY;
    LIST_HEAD_INIT(p->children);
    LIST_HEAD_INIT(p->sleep_alone);

    //p->wait_for_child = 0;

    // Kernel stacks of two different processes are different
    // even if one is another's child, and it was created by fork() 
    va = (void *)(KSTACKTOP - KSTACKSIZE);
    if (proc_region_alloc(p, va, KSTACKSIZE, PTE_P | PTE_W)) {
    	proc_free(p);
    	proc_desc_destroy(p);
    	goto proc_allc_failed;
    }

 	Pinfo = page_lookup(p->proc_pgdir, va, 0);
    spin_unlock_irqrestore(&proc_manager.proc_table_lock);
        //prink("jsjs\n");
	k_esp = (char *)(page2va(Pinfo) + KSTACKSIZE);
	k_esp -= sizeof(struct trapframe);
	p->tf = (struct trapframe *)k_esp;

    p->tf->cs = GD_UT | USER_DPL;
    p->tf->ds = GD_UD | USER_DPL;
    p->tf->es = p->tf->ds;
    p->tf->fs = p->tf->ds;
    p->tf->gs = p->tf->ds;
    p->tf->ss = p->tf->ds;

	// A bound
	k_esp -= 4;
	*(uintptr_t *)k_esp = (uintptr_t)trapsret;

	k_esp -= sizeof(struct context);
	p->context = (struct context *)k_esp;
	p->context->eip = (uintptr_t)forkret;

    *new_proc_store = p;
    return 0;

proc_allc_failed:
    spin_unlock_irqrestore(&proc_manager.proc_table_lock);
    return r;	
}

static void load_binary(struct proc *p, uint8_t *binary)
{
	char				*va_t;
	struct page 	    *Pinfo;
	struct Elf32_Ehdr   *elf_ptr;
	struct Elf32_Phdr	*ph;

	lcr3(PADDR(p->proc_pgdir));
	elf_ptr = (struct Elf32_Ehdr *)binary;
	if (elf_ptr->e_magic != ELF_MAGIC) 
		goto error;

	ph = (struct Elf32_Phdr *)((uint8_t *)elf_ptr + elf_ptr->e_phoff);
	for(int i=0; i< elf_ptr->e_phnum; i++, ph++){
		if (ph->p_type != ELF_PROG_LOAD) 
			continue;
		if (ph->p_memsz < ph->p_filesz)
			goto error;
		if (ph->p_vaddr > UTOP)
			goto error;
		if ((ph->p_vaddr + ph->p_memsz) < ph->p_vaddr)
			goto error;
		proc_region_alloc(p, (void *)ph->p_vaddr, ph->p_memsz, PTE_USTK);
		memmove((void *)ph->p_vaddr, binary + ph->p_offset, ph->p_filesz);
		memset((void *)(ph->p_vaddr + ph->p_filesz), 0, ph->p_memsz - ph->p_filesz);
		p->base_mem_sz += ph->p_filesz;
	}
	p->tf->eip = elf_ptr->e_entry;
	lcr3(PADDR(kern_pgdir));

	return;

error:
    proc_free(p);
	lcr3(PADDR(kern_pgdir));
	panic("Error occurs when Initializing.\n");
	return ;
}

int proc_create(struct proc **p_store, uint8_t *binary)
{
	struct proc *p;
    
	if (proc_alloc(&p)) 
        return -E_NO_MEM;

    load_binary(p, binary);
    *p_store = p;
    return 0;
}

void rectify_tf_context(struct proc *p)
{
	char *k_esp;

	k_esp = (char *)(KSTACKTOP - sizeof(struct trapframe));
    p->tf = (struct trapframe *)k_esp;
    k_esp = k_esp - 4 - sizeof(struct context);
	p->context = (struct context *)k_esp;
}

void WeiOS_first_process(void)
{
	void *va;
	struct proc  *p;

    if (proc_create(&p, (uint8_t *)_binary_initprocess_start))
    	panic("Failed to create init process!!!\n");
    
    va = (void *)USTACKBOTTOM;
    if (proc_region_alloc(p, va, PGSIZE, PTE_USTK))
    	panic("Failed to create init process!!!\n");
    
    safestrcpy(p->name, "WeiQingFu", strlen("WeiQingFu"));
    p->tf->eflags = EFLAGS_IF;
    p->tf->esp = USTACKTOP;
    p->heap_ptr = ROUNDUP(p->base_mem_sz, PGSIZE) + UTEXT;
    p->status = RUNNABLE;
    p->priority = DEFAULT_USER_PRIO;
    p->timeslice = DEFAULT_TIMESLICE;
    p->timeslice_left = DEFAULT_TIMESLICE;
	rectify_tf_context(p);

	add_proc_to_queue(mycpu()->run_queue, p);
	rootproc = p;
}