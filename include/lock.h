#ifndef _LOCK_H_
#define _LOCK_H_

#include <include/types.h>
#include <include/kernel.h>

struct spinlock {
    uint32_t locked;
    char *name;
    void *cpu;    //Multiprocessor
};

struct sleeplock {
	uint32_t locked;      
	struct spinlock lk; // spinlock protecting the sleep lock
	struct list_head sleep_procs;// what's the processes holding the lock?
};

void special_cli(void);
void special_sli(void);

void spinlock_init(struct spinlock *lk, char *name);
int holding_spinlock(struct spinlock *lk);
void spin_lock_irqsave(struct spinlock *lk);
void spin_unlock_irqrestore(struct spinlock *lk);

void sleeplock_init(struct sleeplock *slk, char *name);
int holding_sleeplock(struct sleeplock *slk);
void sleep_lock(struct sleeplock *slk);
void sleep_unlock(struct sleeplock *slk);

#endif
