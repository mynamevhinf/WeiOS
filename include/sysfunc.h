#ifndef _SYSFUNC_H_
#define _SYSFUNC_H_

#ifndef __ASSEMBLER__

#include <include/types.h>
#include <include/kernel.h>
#include <include/proc.h>
#include <include/lock.h>

void lastest_eip(void);
void sleep(struct list_head *sleep_list, struct spinlock *lk);
void wakeup(struct list_head *sleep_list, struct spinlock *lk);
int murder(pid_t pid);
int kill(pid_t pid);
ushort wait(void);
void exit(void);
void *sbrk(int n);
int exec(char *pathname, char **argv);
int user_page_alloc(pid_t pid, void *va, int perm);
int user_page_map(pid_t srcpid, void *srcva,
	     		  pid_t dstpid, void *dstva, int perm);
int user_page_upmap(pid_t pid, void *va);

int dup_proc_struct(struct proc **proc_store);
int cow_fork(struct proc *son_p);
int clone(uint32_t cflg);

int ipc_try_send(pid_t pid, uint32_t value, void *srcva, uint32_t perm);
int ipc_recv(void *dstva);

#endif

#endif
