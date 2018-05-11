#include <include/types.h>
#include <include/param.h>
#include <include/mmu.h>
#include <include/mem.h>
#include <include/x86.h>
#include <include/log.h>
#include <include/lock.h>
#include <include/proc.h>
#include <include/pmap.h>
#include <include/file.h>
#include <include/sched.h>
#include <include/stdio.h>

extern pde_t  *kern_pgdir;
extern struct proc_manager  proc_manager;
extern void swtch(struct context **context_a, struct context *context_b);

void add_proc_to_queue(struct proc_queue *proc_queue, struct proc *p)
{
    uint32_t *tbitmap;

    if (p->priority >= 32) 
        tbitmap = (uint32_t *)(&proc_queue->priority_bitmap) + 1;
    else
        tbitmap = (uint32_t *)(&proc_queue->priority_bitmap);
    *tbitmap |= (1 << p->priority);
	list_add_tail(&p->kinds_list, &proc_queue->procs_in_queue[p->priority]);
    proc_queue->n_procs++;
    p->proc_queue = proc_queue;
    prink("");
}

void del_proc_fron_queue(struct proc *p)
{
    uint32_t *tbitmap;
    struct proc_queue *proc_queue;

    proc_queue = p->proc_queue;
    //prink("p->kinds_list = %p\n", p->kinds_list);
    list_del(&p->kinds_list);
    if (list_empty(&(proc_queue->procs_in_queue[p->priority]))) {
        if (p->priority >= 32) 
            tbitmap = (uint32_t *)(&proc_queue->priority_bitmap) + 1;
        else
            tbitmap = (uint32_t *)(&proc_queue->priority_bitmap);
        //proc_queue->priority_bitmap &= ~(1 << p->priority);
        *tbitmap &= ~(1 << p->priority);
    }
    proc_queue->n_procs--;
    p->proc_queue = 0;
}

static ushort find_first_set(struct proc_queue *proc_queue)
{
    ushort idx;
    uint64_t prior;

    idx = 0;
    prior = 1;
    while (idx < N_PRIORITY) {
        if (prior & proc_queue->priority_bitmap) //prink("idx = %u\n", idx);
            return idx;
        prior <<= 1;
        idx++;
    }

    return idx;
}

void switch_kvm(void)
{
	lcr3(PADDR(kern_pgdir));
}

// swtich TSS and Page table to process p
void switch_uvm(struct proc *p)
{
    if (!p)
        panic("bad process: null process!!!\n");
    if (p->proc_pgdir == 0)
        panic("bad process: null pgdir!!!\n");
    
    special_cli();
    mycpu()->gdt[SEG_TSS] = SEG16_CONSTRUCT(STS_T32A, (uint32_t)(&mycpu()->ts),
                                     sizeof(struct tss_struct)-1, 0); 
    // Tss is system segment
    mycpu()->gdt[SEG_TSS].s = 0;
    mycpu()->ts.ss0 = GD_KD; 
    mycpu()->ts.esp0 = KSTACKTOP;
    // Forbids I/O instructions from user space.
    mycpu()->ts.iomb = (ushort)0xFFFF;  
    ltr(GD_TSS);
    lcr3(PADDR(p->proc_pgdir));
    special_sli();
}

// calculate process's timeslice 
ushort recalculate_priority(struct proc *p)
{
    int  bonus, priority;

    bonus = CURRENT_BONUS(p) - MAX_BONUS / 2;
    priority = p->priority - bonus;
    if (priority < MIN_USER_PRIO)
        priority = MIN_USER_PRIO;
    if (priority > MAX_USER_PRIO - 1)
        priority = MAX_USER_PRIO - 1;
    return priority;
}

uint32_t task_timeslice(struct proc *p)
{
    if (p->priority < NICE_TO_PRIO(0))
        return SCALE_PRIO(DEFAULT_TIMESLICE*4, p->priority);
    else
        return SCALE_PRIO(DEFAULT_TIMESLICE, p->priority);
}

void scheduler(void)
{
    uint32_t timeslice_left;
    ushort prior;
	struct cpu  *c;
	struct proc *p;
    struct proc_queue *t_queue;

    // First time come to scheduler
    p = 0;
    c = mycpu();
    c->proc = 0;
	for (;;) {
		// Acquire profit process, cli() at the same time
        spin_lock_irqsave(&proc_manager.proc_table_lock);
        if (p && (p->status == RUNNABLE)) {//) && (p->status != SLEEPING)) {

            if (p->proc_queue)
                del_proc_fron_queue(p);
            //del_proc_fron_queue(p);
            timeslice_left = p->timeslice_left;
            p->priority = recalculate_priority(p);
            p->timeslice = task_timeslice(p) / 2;
            p->sleep_avg = 0;
            // waken up.
            if (timeslice_left == 0) { 
                p->timeslice_left = p->timeslice;
                add_proc_to_queue(c->exhausted_queue, p);
            } else //if (p->preempted)// includes preemptive scheduler
                add_proc_to_queue(c->run_queue, p);
        }

        if (!(c->run_queue->n_procs)) {
            t_queue = c->run_queue;
            c->run_queue = c->exhausted_queue;
            c->exhausted_queue = t_queue;
        }

        prior = find_first_set(c->run_queue);
        // must idle.
        if (prior < N_PRIORITY) {       
            p = list_entry(c->run_queue->procs_in_queue[prior].next,  \
                                          struct proc, kinds_list);
            // delete selected process from run_queue.
            // prevent other cpus from selecting the process
            // who is running in a cpu.
            del_proc_fron_queue(p);
    		c->proc = p;
       		switch_uvm(p);
       		p->status = RUNNING;
            // It's a important point.
            // schduler -> process
       		swtch(&c->scheduler, p->context);
       		// process -> scheduler 
            switch_kvm();
            p = myproc();
            c = mycpu();
    		c->proc = 0;
            // may be call sti().
            spin_unlock_irqrestore(&proc_manager.proc_table_lock);
        } else {
            // Enable interrupts on this processor.
            // If interrupts are unable, but current cpu is idle,
            // all other cpus in the mechine can not handle the process table.
            // It is said, no processes can be RUNNING any more.
            switch_kvm();
            p = 0;
            c->proc = 0;
            spin_unlock_irqrestore(&proc_manager.proc_table_lock);
            asm volatile ("sti; hlt":::"memory");
        }
    }
}

void sched(void)
{
	struct proc  *p = myproc();

	if (p->status == RUNNING)
		panic("sched while current process running!\n");
	if (reflags() & EFLAGS_IF)
		panic("sched while interrup enabled!\n");
    // We cannot do task switch if the process is in running.
	swtch(&p->context, mycpu()->scheduler);
}

void yield(void)
{
    spin_lock_irqsave(&proc_manager.proc_table_lock);
    myproc()->status = RUNNABLE;
    sched();
    spin_unlock_irqrestore(&proc_manager.proc_table_lock);
}

void forkret(void)
{
    static int first_proc = 1;

    spin_unlock_irqrestore(&proc_manager.proc_table_lock);
    if (first_proc) {
        inode_init();
        log_init(ROOTDEV);
        if (!(curproc->pwd = namei("/")))
            panic("holy shit, file system is bulshit!!!\n");
        first_proc = 0;
    }
}

