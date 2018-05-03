#ifndef _SCHED_H_
#define _SCHED_H_

// prio belongs to [0, 39]
#define MAX_USER_PRIO			40	
#define MIN_USER_PRIO			0
#define DEFAULT_USER_PRIO		19
#define LINUX_PRIO(x)  			(x+100)

// nice belongs to [-20, 19]
#define NICE_TO_PRIO(nice)	((nice) + 20)

#define MIN_TIMESLICE		5	// ms
#define DEFAULT_TIMESLICE   100 // ms
#define MAX_TIMESLICE		800 // ms

#define SCALE_PRIO(x, priority)	\
	MAX(x * (MAX_USER_PRIO - priority) \
		/ (MAX_USER_PRIO / 2), MIN_TIMESLICE)

#define PRIO_BONUS_RATIO	25
#define MAX_BONUS			(MAX_USER_PRIO*PRIO_BONUS_RATIO/100)
#define MAX_SLEEP_AVG		(DEFAULT_TIMESLICE*MAX_BONUS)
#define CURRENT_BONUS(p)	\
    ((p)->sleep_avg * MAX_BONUS / MAX_SLEEP_AVG)  

#ifndef __ASSEMBLER__

#include <include/time.h>
#include <include/proc.h>

void add_proc_to_queue(struct proc_queue *proc_queue, struct proc *p);
void del_proc_fron_queue(struct proc *p);
ushort recalculate_priority(struct proc *p);
uint32_t task_timeslice(struct proc *p);
void switch_kvm(void);
void switch_uvm(struct proc *p);
void scheduler(void);
void sched(void);
void yield(void);
void forkret(void);

#endif

#endif