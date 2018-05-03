#include <include/types.h>
#include <include/mem.h>
#include <include/x86.h>
#include <include/trap.h>
#include <include/proc.h>
#include <include/stdio.h>
#include <include/string.h>
#include <include/console.h>
#include <include/monitor.h>

#define WHITESPACE  "\n\r\t "
#define CMD_NUM     4

struct monitor_command {
	const char  *name;
	const char  *description;
	int (*func) (struct trapframe *tf);
} monitor_commands[CMD_NUM] = {
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "lookregs", "Display imformation about all registers", mon_lookregs }, 
	{ "continue", "Continue executing", mon_continue }
};

static int mon_help(struct trapframe *tf)
{
	for (int i = 0; i < CMD_NUM; i++) 
		prink("%s -- %s\n", monitor_commands[i].name, monitor_commands[i].description);

	return 0;
}

static int mon_kerninfo(struct trapframe *tf)
{
	extern char _entry[], etext[], edata[], end[]; 

	prink("Kernel imformation as follows.\n");
	prink("Entry Point:	  %p(virtual address)	%p(physical address)\n", _entry, Va2Pa(_entry));
	prink("End of Text:	  %p(virtual address)	%p(physical address)\n", etext, Va2Pa(etext)); 
	prink("End of Data:	  %p(virtual address)	%p(physical address)\n", edata, Va2Pa(edata));
	prink("End of Kernel:    %p(virtual address)	%p(physical address)\n", end, Va2Pa(end));
	prink("Therefore Kernel' size is %pBytes\n", end-_entry);
	return 0;
}

static int mon_lookregs(struct trapframe *tf)
{
	if (tf) {
		if (curproc)
			prink("pid:		%p\n", curproc->pid);
		if ((tf->cs & 0x3))
			prink("ss:     %p\n", tf->ss);
	    prink("es:     %p\n", tf->es);
	    prink("ds:     %p\n", tf->ds);
	    prink("gs:     %p\n", tf->gs);
	    prink("fs:     %p\n", tf->fs);
	    prink("cs:     %p\n", tf->cs);
	    prink("eip:     %p\n", tf->eip);
	    prink("esp:     %p\n", tf->esp);
	    prink("edi:     %p\n", tf->normal_regs.edi);
	    prink("esi:     %p\n", tf->normal_regs.esi);
	    prink("ebp:     %p\n", tf->normal_regs.ebp);
	    prink("ebx:     %p\n", tf->normal_regs.ebx);
	    prink("edx:     %p\n", tf->normal_regs.edx);
	    prink("ecx:     %p\n", tf->normal_regs.ecx);
	    prink("eax:     %p\n", tf->normal_regs.eax);
	    prink("err:		%p\n", tf->trap_err);
	    if (tf->trap_no == T_PGFAULT)
            prink("cr2:     %p\n", rcr2());
	} else 
		prink("mon_lookregs: emptry trapframe.\n");
	return 0;
}

static int mon_continue(struct trapframe *tf)
{
	if (tf) 
		return 1;

	prink("mon_continue: emptry trapframe.\n");
	return 0;
}

static int runcmd(char *s, struct trapframe *tf)
{
	while (strchr(WHITESPACE, *s))
		s++;

	if (*s) {
		lowercase(s);
		for (int i = 0; i < CMD_NUM; i++) {
			if (strcmp(s, monitor_commands[i].name) == 0)
				return monitor_commands[i].func(tf);
		}
		prink("unknown command\n");
	}
	return 0;
}


void monitor(struct trapframe *tf)
{
	char  *cmd;

	prink("Welcome to WeiOS, it is a primordial monitor.\n");
	prink("You could type 'help' to get a list of commands.\n");

	while (1) {
		if ((cmd = readline("W> ")))
			if (runcmd(cmd, tf))
				return;
	}
}
