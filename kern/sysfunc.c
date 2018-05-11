#include <include/types.h>
#include <include/param.h>
#include <include/fs.h>
#include <include/elf.h>
#include <include/log.h>
#include <include/mmu.h>
#include <include/mem.h>
#include <include/file.h>
#include <include/trap.h>
#include <include/pmap.h>
#include <include/proc.h>
#include <include/lock.h>
#include <include/sched.h>
#include <include/error.h>
#include <include/stdio.h>
#include <include/kernel.h>
#include <include/string.h>
#include <include/sysfunc.h>

extern pde_t *uvpt, *uvpd;
extern volatile uint32_t jiffs;
extern struct proc *rootproc;
extern struct proc_manager  proc_manager;

void lastest_eip(void)
{
    uint32_t ebp, eip;

    asm volatile ("movl %%ebp, %0":"=r"(ebp));
    while (ebp != 0) {
        eip = *((uint32_t *)ebp +1);
        prink("ebp  %p  eip  %p\n", ebp, eip); 
        ebp = *((int *)ebp);
    }
}

void sleep(struct list_head *sleep_list, struct spinlock *lk)
{
	struct proc *p = curproc;
	//prink("flag sleep\n");
	if (!p)
		panic("A process who is null want to sleep?\n");
	if (!lk)
		panic("WeiOS must sleep with a spinlock\n");

	if (lk != &proc_manager.proc_table_lock) {
		spin_lock_irqsave(&proc_manager.proc_table_lock);
		spin_unlock_irqrestore(lk);
	}
	p->status = SLEEPING;
	p->sleep_start_jiffs = jiffs;
	//del_proc_fron_queue(p);
	//prink("lk->name = %s\n", lk->name);
	list_add_tail(&p->kinds_list, sleep_list);
	
	sched();
	// After waken up
	spin_unlock_irqrestore(&proc_manager.proc_table_lock);
	if (lk != &proc_manager.proc_table_lock)
		spin_lock_irqsave(lk);
}

static void wakeup1(struct list_head *sleep_list)
{
	ushort priority;
	struct cpu   *c;
	struct proc  *p;
	struct list_head  *t_node;

	c = mycpu();
	priority = N_PRIORITY;
	t_node = sleep_list->next;
	while (t_node != sleep_list) {
		p = list_entry(t_node, struct proc, kinds_list);
		t_node = t_node->next;
		list_del(&p->kinds_list);
		p->sleep_avg += (jiffs - p->sleep_start_jiffs);
		p->sleep_start_jiffs = 0;
		p->status = RUNNABLE;
		p->priority = recalculate_priority(p);
		p->timeslice = task_timeslice(p) / 2;
		p->sleep_avg = 0;
		//prink("p desc addr = %p, p->priority = %p\n", p, p->priority);
		if (p->priority < priority)
			priority = p->priority;
		add_proc_to_queue(c->run_queue, p);
	}

	p = myproc();
	if (p && (priority < p->priority))
		p->preempted = 1;
}

void wakeup(struct list_head *sleep_list, struct spinlock *lk)
{	
	if (lk != &proc_manager.proc_table_lock)
		spin_lock_irqsave(&proc_manager.proc_table_lock);
	wakeup1(sleep_list);
	if (lk != &proc_manager.proc_table_lock)
		spin_unlock_irqrestore(&proc_manager.proc_table_lock);
}

ushort wait(void)
{
	ushort pid;
	struct proc *p;
	struct list_head *single_child;

	while (1) {
		spin_lock_irqsave(&proc_manager.proc_table_lock);
		single_child = curproc->children.next;
		while (single_child != &curproc->children) {
			p = list_entry(single_child, struct proc, siblings);
			single_child = single_child->next;
			if (p->status == ZOMBLE) {
				pid = p->pid;
				list_del(&p->siblings);
				// free its kernel stack.
				page_remove(p->proc_pgdir, (void *)(KSTACKTOP - KSTACKSIZE));
				// free proc_pgdir itself.
				page_decrease_ref(va2page((uintptr_t)p->proc_pgdir));
				// free process descriptor.
				proc_desc_destroy(p);
				spin_unlock_irqrestore(&proc_manager.proc_table_lock);
				return pid;
			}
		}
		curproc->wait_for_child = 1;
		// No need to call spin_unlock_irqrestore()
		// because of it was called in sleep() when
		// we going to return.
		sleep(&curproc->sleep_alone, &proc_manager.proc_table_lock);
	}
}

// kill without check.
int murder(pid_t pid)
{
	int r;
	struct proc *p;

	if (pid > NPROC)
		return -E_BAD_PROC;

	spin_lock_irqsave(&proc_manager.proc_table_lock);
	if (!(r = pid2proc(pid, &p, 0))) {
		p->killed = 1;
		if (p->status == SLEEPING) {
			p->status = RUNNABLE;
			list_del(&p->kinds_list);
			add_proc_to_queue(mycpu()->run_queue, p);
		}
	}
	spin_unlock_irqrestore(&proc_manager.proc_table_lock);		
	return r;	
}

int kill(pid_t pid)
{
	int r;
	struct proc *p;

	if (pid > NPROC)
		return -E_BAD_PROC;

	spin_lock_irqsave(&proc_manager.proc_table_lock);
	if (!(r = pid2proc(pid, &p, 1))) {
		p->killed = 1;
		if (p->status == SLEEPING) {
			p->status = RUNNABLE;
			list_del(&p->kinds_list);
			add_proc_to_queue(mycpu()->run_queue, p);
		}
	}
	spin_unlock_irqrestore(&proc_manager.proc_table_lock);		
	return r;
}

void exit(void)
{
	struct proc *p;
	struct list_head *children_list_head;
	struct list_head *single_child;

	if (curproc == rootproc)
		panic("root process exit!!!\n");

	// We have deal with many things.
	spin_lock_irqsave(&proc_manager.proc_table_lock);
	// i don't care about kernel threads and filesystem right now.
	children_list_head = &curproc->children;
	single_child = children_list_head->next;
	while (single_child != children_list_head) {
		p = list_entry(single_child, struct proc, siblings);
		single_child = single_child->next;
		list_del(&p->siblings);
		p->ppid = rootproc->pid;
		list_add(&p->siblings, &rootproc->children);
	}
	// Never switch to the process.
	curproc->proc_queue = 0;
	curproc->status = ZOMBLE;
	// free all space it occupied.
	// only user space. dont care about kernel stack.
	proc_free(curproc);
	if (curproc->ppid)
		pid2proc(curproc->ppid, &p, 0);
	else 
		p = rootproc;
	if (p->wait_for_child) 
		wakeup(&p->sleep_alone, &proc_manager.proc_table_lock);
		// implicitly wake up.
		//list_del(&p->kinds_list);
		//p->sleep_avg += (jiffs - p->sleep_start_jiffs);
		//p->sleep_start_jiffs = 0;
		//p->status = RUNNABLE;
		//p->wait_for_child = 0;
		//add_proc_to_queue(mycpu()->run_queue, p);
	spin_unlock_irqrestore(&proc_manager.proc_table_lock);
	
	// free all file struct it used
	for (int i = 0; i < NOFILE; i++) {
		if (curproc->open_file_table[i])
			file_close(curproc->open_file_table[i]);
	}
	iput(curproc->pwd);
	curproc->n_opfiles = 0;
	
	spin_lock_irqsave(&proc_manager.proc_table_lock);
	sched();
    spin_unlock_irqrestore(&proc_manager.proc_table_lock);
}

int user_page_alloc(pid_t pid, void *va, int perm)
{
	struct proc *p;
	struct page *Pinfo;

	if (((uint32_t)va >= UTOP) || (perm & ~PTE_SYSCALL))
		return -E_INVAL;
	if (pid2proc(pid, &p, 1) < 0)
		return -E_BAD_PROC;
	if (!(Pinfo = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
	if (page_insert(p->proc_pgdir, Pinfo, va, perm) < 0) {
		page_decrease_ref(Pinfo);
		return -E_NO_MEM;
	}

	return 0;
}

int user_page_map(pid_t srcpid, void *srcva,
	     		  pid_t dstpid, void *dstva, int perm)
{
	int r;
	pte_t  *pte_s;
	struct proc  *p_s, *p_d;
	struct page  *Pinfo;
	uint32_t  va_s = (uint32_t)srcva;
	uint32_t  va_d = (uint32_t)dstva;

	if (va_s >= UTOP || (va_s % PGSIZE))
		return -E_INVAL;
	if (va_d >= UTOP || (va_d % PGSIZE))
		return -E_INVAL;
	if (perm & ~PTE_SYSCALL)
		return -E_INVAL;
	if (pid2proc(srcpid, &p_s, 1) < 0 || pid2proc(dstpid, &p_d, 1) < 0)
		return -E_BAD_PROC;
	if (!(Pinfo = page_lookup(p_s->proc_pgdir, srcva, &pte_s)))
		return -E_INVAL;
	if (!(*pte_s & PTE_W) && (perm & PTE_W))
		return -E_INVAL;

	r = page_insert(p_d->proc_pgdir, Pinfo, dstva, perm);	
	return r;
}

int user_page_upmap(pid_t pid, void *va)
{
	struct proc *p;

	if ((uint32_t)va >= UTOP)
		return -E_INVAL;
	if (pid2proc(pid, &p, 1) < 0)
		return -E_BAD_PROC;
	page_remove(p->proc_pgdir, va);
	return 0;
}

int dup_proc_struct(struct proc **proc_store)
{
	int r;
	struct proc *curr_p;
	struct proc *son_p;

	curr_p = curproc;
	// returing 0 means proc_alloc() successfully.
	// we have allocated user exception stack and kernel stack
	if ((r = proc_alloc(&son_p)))
		return r;
	// copy context.
	son_p->base_mem_sz = curr_p->base_mem_sz;
	son_p->heap_ptr = curr_p->heap_ptr;
	son_p->ppid = curr_p->pid;
	son_p->status = RUNNABLE;
	// difference between parent and kid.
	son_p->tf->normal_regs = curr_p->tf->normal_regs;
	son_p->tf->normal_regs.eax = 0;
	son_p->tf->esp = curr_p->tf->esp;
	son_p->tf->eip = curr_p->tf->eip;
	son_p->tf->eflags = curr_p->tf->eflags;
	son_p->tf->trap_err = curr_p->tf->trap_err;
	rectify_tf_context(son_p);
	// timeslice_is different.
	// avoids stealing system time by fork over and over again.
	curr_p->timeslice_left /= 2;
	if (curr_p->timeslice_left == 0)
		curr_p->timeslice_left = 1;
	son_p->timeslice_left = curr_p->timeslice_left;
	son_p->timeslice = DEFAULT_TIMESLICE;
	son_p->sleep_avg = curr_p->sleep_avg;

	son_p->alarmticks_left = curr_p->alarmticks_left;
	son_p->alarmticks = curr_p->alarmticks;
	son_p->alarmhandler = curr_p->alarmhandler;
	son_p->priority = DEFAULT_USER_PRIO;

	// file system relatives
	for (int i = 0; i < NOFILE; i++)
		if (curr_p->open_file_table[i])
			son_p->open_file_table[i] = file_dup(curr_p->open_file_table[i]);
	son_p->n_opfiles = curr_p->n_opfiles;
	son_p->pwd = curr_p->pwd;
	iref(son_p->pwd);

	safestrcpy(son_p->name, curr_p->name, strlen(curr_p->name));
	if (proc_store)
		*proc_store = son_p;
	return son_p->pid;
}

/*****************************************
 * 			Copy-on-write fork!!!
 ****************************************/
static int duppage(pid_t pid, uint32_t p_num)
{
	int r;
	int perm = PTE_U | PTE_P;
	pte_t  pt = uvpt[p_num];
	pid_t cid = curproc->pid;
	void *va = (void *)(p_num * PGSIZE);

	if (pt & PTE_SHARE)
		return user_page_map(cid, va, pid, va, PTE_SYSCALL & uvpt[p_num]);
	if ((pt & PTE_W) || (pt & PTE_COW))
		perm |= PTE_COW;
	if ((r = user_page_map(cid, va, pid, va, perm)) < 0)
		return r;
	if (perm & PTE_COW) {
		if ((r = user_page_map(cid, va, cid, va, perm)) < 0) 
			return r; // let caller deal with it.
	}

	return 0;
}

int cow_fork(struct proc *son_p)
{
	int 	   r;
	//void 	  *va_p;
	pid_t      cur_id;
	pid_t      chld_id;   
	//uintptr_t  va = UXSTACKBOTTOM;
	// duppages
	int j, pn;
	//va_p = (void *)va;
	chld_id = son_p->pid;
	for (r = PDINDEX(UTEXT); r < PDINDEX(UTOP); r++) {
		if (uvpd[r] & PTE_P) {
			for (j = 0; j < PDENTRIES; j++) {
				pn = PGNUM(PGADDR(r, j, 0));
				if (uvpt[pn] & PTE_P) {
					if (duppage(chld_id, pn) < 0)
						goto failure;
				}
			}
		}
	}
	return chld_id;
failure:
	return -1;
}

/* 
 * i move the function to kern/trap.c
 * static void cow_pgfault(struct utrapframe *utf)
 */
int clone(uint32_t cflg)
{
	int r;
	struct proc *son_p;

	if ((r = dup_proc_struct(&son_p)) < 0)
		return r;

	if ((cflg == CLONE_FORK) || (cflg == CLONE_VFORK)) {
		if ((r = cow_fork(son_p)) < 0) 
			goto cow_fork_failed;	
	} else
		return -1;
	// finally i add the new one into run_queue.
	spin_lock_irqsave(&proc_manager.proc_table_lock);
	list_add_tail(&son_p->siblings, &curproc->children); 
	add_proc_to_queue(mycpu()->run_queue, son_p);   
    spin_unlock_irqrestore(&proc_manager.proc_table_lock);

	return son_p->pid;

cow_fork_failed:
	proc_free(son_p);
	return r;
}

void *sbrk(int n)
{
	struct proc *curr_p = curproc;
	uint32_t pn;
	uint32_t real_n, end_addr;
	uint32_t base_addr = curr_p->heap_ptr;

  	if (n < 0) {
  		real_n = (n % (~0x80000000));
  		end_addr = ROUNDDOWN(base_addr - real_n, PGSIZE);
  		if (end_addr < ROUNDUP(curr_p->base_mem_sz, PGSIZE))
  			return 0;
    	curr_p->heap_ptr = end_addr;
  		while (end_addr < base_addr) {
  			page_remove(curr_p->proc_pgdir, (void *)end_addr);
  			end_addr += PGSIZE;
  		}
  		return (void *)(curr_p->heap_ptr);
  	} else if (n > 0) {
  		real_n = ROUNDUP(n, PGSIZE);
  		end_addr = base_addr + real_n;
      	if (end_addr > HEAPTOP || end_addr < base_addr)
          	return 0;
        curr_p->heap_ptr += end_addr;
  	  	return (void *)(end_addr);
  	}
	return (void *)(base_addr);
} 

int brk(uint32_t heap_break)
{
	struct proc *curr_p = curproc;

	if (heap_break > curr_p->heap_ptr) {
		heap_break = ROUNDUP(heap_break, PGSIZE);
		if (heap_break <= HEAPTOP)
			curr_p->heap_ptr = heap_break;
		else
			return -1;
	} else if (heap_break < curr_p->heap_ptr) {
		heap_break = ROUNDDOWN(heap_break, PGSIZE);
		if (heap_break < ROUNDUP(curr_p->base_mem_sz, PGSIZE))
			return -1;
		while (curr_p->heap_ptr > heap_break) {
			curr_p->heap_ptr -=  PGSIZE;
			page_remove(curr_p->proc_pgdir, (void *)(curr_p->heap_ptr));
		}
	}
	return 0;
}

static inline uint32_t vesp_to_esp(uint32_t esp)
{
	return ((esp % PGSIZE) + USTACKBOTTOM);
}

// We havo to malloc a new pgdir and delete the old.
int exec(char *pathname, char **argv)
{ 
	char *last, *str;
	int slen, phsiz;
	int base_mem_sz, off, argc;
	uint32_t esp, uargv[MAXARG+3];
	struct page *Pinfo;
	pde_t *npgdir, *opgdir;
	struct inode *i;
	struct Elf32_Phdr ph;
	struct Elf32_Ehdr elfh;

	begin_transaction();
	if (!(i = namei(pathname))) {
		// i have already call iunlockput() in name if failed.
		// so it is no need to do it again.
		end_transaction();
		//prink("exec error: no such file -- %s\n", pathname);
		return -1;
	}
	// now check if the head is legel!!
	ilock(i);
	npgdir = 0;
	if (readi(i, (char *)&elfh, 0, sizeof(struct Elf32_Ehdr)) < 0) {
		prink("exec error: cannot load the program!\n");
		goto exec_failure;
	}
	// In real Unix-like system, print no imformation.so i follow them.
	if (elfh.e_magic != ELF_MAGIC)
		goto exec_failure;

	if (!(npgdir = setup_vm()))
		goto exec_failure;

	base_mem_sz = UTEXT;
	phsiz = sizeof(struct Elf32_Phdr);
	for (int j = 0, off = elfh.e_phoff; j < elfh.e_phnum; j++, off += phsiz) {
		if (readi(i, (char *)&ph, off, phsiz) != phsiz)
			goto exec_failure;
		if (ph.p_type != ELF_PROG_LOAD)
			continue;
		if (ph.p_vaddr > UTOP)
			goto exec_failure;
		if (ph.p_vaddr + ph.p_memsz < ph.p_vaddr)
			goto exec_failure;
		if (ph.p_memsz < ph.p_filesz)
			goto exec_failure;
		if (!(base_mem_sz = grow_vm(npgdir, base_mem_sz, ph.p_vaddr + ph.p_memsz)))
			goto exec_failure;
		if (ph.p_vaddr % PGSIZE)
			goto exec_failure;
		if (load_program(npgdir, (char *)(ph.p_vaddr), i, ph.p_offset, ph.p_filesz) < 0)
			goto exec_failure;
	}
	iunlockput(i);
	end_transaction();
	// for exec_failure
	i = 0;

	// Now we deal with the stack.in Unix-like OS, when calling exec(), system
	// alloc a new stack for process, I have to follow it.
	if (!(Pinfo = page_alloc(ALLOC_ZERO)))
		goto exec_failure;
	if (page_insert(npgdir, Pinfo, (void *)USTACKBOTTOM, PTE_USTK) < 0) {
		page_decrease_ref(Pinfo);
		goto exec_failure;
	}

	// copy parameters from its old address to the new stack.
	// i follow the traditional memory layout.
	esp = (uint32_t)page2va(Pinfo) + USTACKSIZE - 1;
	for (argc = 0; argv[argc]; argc++) {
		if (argc >= MAXARG)
			goto exec_failure;
		slen = strlen(argv[argc]);
		esp = (esp - slen - 1) & ~3;
		strncpy((void *)esp, argv[argc], slen);
		uargv[2+argc] = vesp_to_esp(esp);
	}
	uargv[2+argc] = 0;
	uargv[0] = argc;
	uargv[1] = vesp_to_esp(esp - (argc+1)*4);

	esp -= ((3+argc)*4);
	memmove((void *)esp, uargv, (3+argc)*4);

	// rename process
	for (last = str = pathname; *str; str++)
		if (*str == '/')
			last = str + 1;
	safestrcpy(curproc->name, last, str - last + 1);

	// finally, it is kernel stack. i copy it.
	opgdir = curproc->proc_pgdir;
	Pinfo = page_lookup(opgdir, (void *)(KSTACKTOP - KSTACKSIZE), 0);
	if (page_insert(npgdir, Pinfo, (void *)(KSTACKTOP - KSTACKSIZE), PTE_P|PTE_W) < 0)
		goto exec_failure;

	curproc->proc_pgdir = npgdir;
	curproc->tf->eip = elfh.e_entry;
	curproc->tf->esp = vesp_to_esp(esp);
	curproc->base_mem_sz = base_mem_sz;
	curproc->heap_ptr = ROUNDUP(base_mem_sz, PGSIZE);
	switch_uvm(curproc);
	pgdir_free(opgdir);
	page_remove(opgdir, (void *)(KSTACKTOP - KSTACKSIZE));
	page_decrease_ref(va2page((uint32_t)opgdir));
	
	return 0;

exec_failure:
	if (npgdir) {
		pgdir_free(npgdir);
		page_decrease_ref(va2page((uintptr_t)npgdir));
	}
	if (i) {
		iunlockput(i);
		end_transaction();
	}
	return -1;
}

int ipc_try_send(pid_t pid, uint32_t value, void *srcva, uint32_t perm)
{
	int 		r;
	pte_t	   *pte;
	uintptr_t   va;
	struct page *pp;
	struct proc *receiver;

	if (pid2proc(pid, &receiver, 0)) 
		return -E_BAD_PROC;

	spin_lock_irqsave(&proc_manager.proc_table_lock);
	if (!(receiver->ipc_recving)) {
		r = -E_IPC_NOT_RECV;
		goto failure;
	}
	// Deal with page transfer.
	// i stipulate that sender cannot send page above UTOP
	// so i can use UTOP to check if user is trying to send a page or not.
	// and wether receiver is waiting for a page to be send.
	if ((receiver->ipc_dstva < ((void *)UTOP)) && (srcva < (void*)UTOP)) {
		va = (uintptr_t)srcva;
		if (va % PGSIZE) {
			r = -E_INVAL;
			goto failure;
		}
		if (!(pp = page_lookup(curproc->proc_pgdir, srcva, &pte))) {
			r = -E_INVAL;
			goto failure;
		}
		// PTE_U, PTE_W, PTE_P.
		if ((perm & ~PTE_SYSCALL)) {
			r = -E_INVAL;
			goto failure;
		}
		if ((perm & PTE_W) && !(*pte & PTE_W)) {
			r = -E_INVAL;
			goto failure;
		}
		if (page_insert(receiver->proc_pgdir, pp, receiver->ipc_dstva, perm) < 0)
		{
			r = -E_NO_MEM;
			goto failure;
		}	
		receiver->ipc_perm = perm;
	} else 
		receiver->ipc_perm = 0;
	receiver->ipc_recving = 0;
	receiver->ipc_from = curproc->pid;
	receiver->ipc_value = value;

	// let it wake up.Unfinished.
	wakeup(&receiver->sleep_alone, &proc_manager.proc_table_lock);
	spin_unlock_irqrestore(&proc_manager.proc_table_lock);
	return 0;

failure:
	spin_unlock_irqrestore(&proc_manager.proc_table_lock);
	return r;
}

int ipc_recv(void *dstva)
{
	uintptr_t va = (uintptr_t)dstva;
	if ((va < UTOP) && (va % PGSIZE))
		return -E_INVAL;

	// i don't judge va <> UTOP anymore, just follow caller's heart.
	// if va >= UTOP, it doesn't want to receive a page
	// otherwise, it want to.
	spin_lock_irqsave(&proc_manager.proc_table_lock);
	curproc->ipc_dstva = dstva;
	curproc->ipc_recving = 1;

	// sleep
	sleep(&curproc->sleep_alone, &proc_manager.proc_table_lock);
	return 0;
}