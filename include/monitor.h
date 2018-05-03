#ifndef _MONITOR_H_
#define _MONITOR_H_

#include <include/trap.h>

static int mon_help(struct trapframe *tf);
static int mon_kerninfo(struct trapframe *tf);
static int mon_lookregs(struct trapframe *tf);
static int mon_continue(struct trapframe *tf);
void monitor(struct trapframe *tf);

#endif 