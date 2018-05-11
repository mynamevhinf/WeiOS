#include <include/types.h>
#include <include/mem.h>
#include <include/mmu.h>
#include <include/x86.h>
#include <include/lock.h>
#include <include/proc.h>
#include <include/stdio.h>
#include <include/kernel.h>
#include <include/sysfunc.h>

// Because i set syscall(in trap.c) be a trap gate
// when i call system call, it is interruptible
// so i have to do it myself if neccesary.
void special_cli(void)
{
	uint32_t eflags;

	eflags = reflags();
	cli();
	if (!(mycpu()->n_clis))
		mycpu()->int_enabled = eflags & EFLAGS_IF;
	mycpu()->n_clis += 1;
}

// enable interrupts
void special_sli(void)
{
	if (reflags() & EFLAGS_IF)
    	panic("special_sli(): interruptible\n");
  	if (--mycpu()->n_clis < 0)
    	panic("special_sli()\n");
  	if (mycpu()->n_clis == 0 && mycpu()->int_enabled)
    	sti();
}

void spinlock_init(struct spinlock *lk, char *name)
{
	lk->name = name;
    lk->locked = 0;
    lk->cpu = 0;
}

int holding_spinlock(struct spinlock *lk)
{
    return ((lk->locked) && ((struct cpu *)(lk->cpu) == mycpu()));
}

void spin_lock_irqsave(struct spinlock *lk)
{
	special_cli();
	if (holding_spinlock(lk)) {
		if (curproc) {
			prink("pid = %d, lock = %s\n", curproc->pid, lk->name);
			lastest_eip();
		}
		panic("spin_lock_irqsave(): Deadlock!!!\n");
	}
	
	while (xchg(&lk->locked, 1) != 0)
		;

	__sync_synchronize();
	lk->cpu = mycpu();
}

void spin_unlock_irqrestore(struct spinlock *lk)
{
	if (!holding_spinlock(lk)) 
		panic("Lock belongs to other!\n");

	lk->cpu = 0;
	__sync_synchronize();
	asm volatile("movl $0, %0" : "+m" (lk->locked) : );

	special_sli();
}

void sleeplock_init(struct sleeplock *slk, char *name)
{
	spinlock_init(&slk->lk, name);
	// process whose pid equals 0 will never sleep
	// so it is correctly.
	slk->locked = 0;
	LIST_HEAD_INIT(slk->sleep_procs);
}

void sleep_lock(struct sleeplock *slk)
{
	spin_lock_irqsave(&slk->lk);
	while (slk->locked)
		sleep(&slk->sleep_procs, &slk->lk);
	slk->locked = 1;
	spin_unlock_irqrestore(&slk->lk);
}

void sleep_unlock(struct sleeplock *slk)  
{
	spin_lock_irqsave(&slk->lk);
	slk->locked = 0;
	wakeup(&slk->sleep_procs, &slk->lk);
	spin_unlock_irqrestore(&slk->lk);
}

int holding_sleeplock(struct sleeplock *slk)
{
	int out;
	spin_lock_irqsave(&slk->lk);
	// It is different from spinlock
	// sleeping process has no prosibility to reach here.
	out = slk->locked;
	spin_unlock_irqrestore(&slk->lk);

	return out;
}