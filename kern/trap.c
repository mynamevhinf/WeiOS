#include <include/types.h>
#include <include/mem.h>
#include <include/mmu.h>
#include <include/x86.h>
#include <include/kbd.h>
#include <include/ide.h>
#include <include/lock.h>
#include <include/proc.h>
#include <include/trap.h>
#include <include/pmap.h>
#include <include/sched.h>
#include <include/stdio.h>
#include <include/picirq.h>
#include <include/string.h>
#include <include/sysfunc.h>
#include <include/syscall.h>
#include <include/monitor.h>

struct cpu  single_cpu;
extern pde_t *uvpt, *uvpd;
extern volatile uint32_t jiffs;
extern struct spinlock  jiffs_lock;
extern void gdt_flush(uint32_t addr);

struct pseudo_desc gdt_desc = {sizeof(single_cpu.gdt)-1, (uint32_t)(single_cpu.gdt)};
struct gatedesc idt[256];
struct pseudo_desc idt_desc = {sizeof(idt)-1, (uint32_t)idt};

static const char *trapname(int trap_no)
{
    // The strings follow are copied from pdos.csail.mit.edu/**/s09_01.html
	static const char * const excnames[] = {
		"Divide error",
		"Debug exceptions",
		"Non-Maskable Interrupt",
		"Breakpoint(one-byte INT 3 instruction)",
		"Overflowi(INT0 instruction)",
		"Bounds check(BOUND instruction)",
		"Invalid Opcode",
		"Coprocessor not available",
		"Double Fault",
		"Coprocessor Segment Overrun(Reserved)",
		"Invalid TSS",
		"Segment Not Present",
		"Stack exception",
		"General Protection",
		"Page Fault",
		"trap 15(Reserved)",
		"x87 FPU Floating-Point Error",
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trap_no >= 0 && trap_no < ARRAY_SIZE(excnames))
		return excnames[trap_no];
	if (trap_no == T_SYSCALL)
		return "System call";
	if (trap_no >= IRQ_STARTED && trap_no < (IRQ_STARTED + IRQ_MAX))
		return "Hardware Interrupt";
	return "(unknown trap)";
}

static void prink_regs(struct pushregs *regs)
{
    if (regs) {
        prink("    edi:    %p\n", regs->edi);
        prink("    esi:    %p\n", regs->esi);
        prink("    ebp:    %p\n", regs->ebp);
        prink("    ebx:    %p\n", regs->ebx);
        prink("    edx:    %p\n", regs->edx);
        prink("    ecx:    %p\n", regs->ecx);
        prink("    eax:    %p\n", regs->eax);
    }
}

void prink_trapframe(Trapf tf)
{
    if (tf) {
        if (curproc)
            prink("WOW pid = %u is bad guy!!!\n", curproc->pid);
        prink("TrapFrame Imformation:\n");
        prink("Trap function's name: %s\n", trapname(tf->trap_no));
        if ((tf->cs & 0x3))
            prink("    ss:     %p\n", tf->ss);
        prink("    es:     %p\n", tf->es);
        prink("    ds:     %p\n", tf->ds);
        prink("    gs:     %p\n", tf->gs);
        prink("    fs:     %p\n", tf->fs);
        prink("    cs:     %p\n", tf->cs);
        prink("    efl:    %p\n", tf->eflags);
        prink("    tno:    %p\n", tf->trap_no);
        if (tf->trap_no == T_PGFAULT)
            prink("    cr2:    %p\n", rcr2());
        prink("    terr:   %p\n", tf->trap_err);
        prink("    eip:    %p\n", tf->eip);
        prink_regs(&tf->normal_regs);
    }
    
}

void gdt_init(void)
{
    //GD_KT
    single_cpu.gdt[SEG_KCODE] = SEG_CONSTRUCT((STA_X|STA_R), 0, 0xFFFFFFFF, 0);
    //GD_KD
    single_cpu.gdt[SEG_KDATA] = SEG_CONSTRUCT(STA_W, 0, 0xFFFFFFFF, 0);
    //GD_UT
    single_cpu.gdt[SEG_UCODE] = SEG_CONSTRUCT((STA_X|STA_R), 0, 0xFFFFFFFF, USER_DPL);
    //GD_UD
    single_cpu.gdt[SEG_UDATA] = SEG_CONSTRUCT(STA_W, 0, 0xFFFFFFFF, USER_DPL);
    //GD_TSS

    gdt_flush((uint32_t)&gdt_desc);
}

void trap_init(void)
{
    int i;
    extern uint trap_funcs[];
    extern uint irq_funcs[];

    for (i = 0; i < 20; i++)
        GATE_CONSTRUCT(idt[i], INTGATE, GD_KT, trap_funcs[i], 0);

    GATE_CONSTRUCT(idt[T_BRKPOINT], INTGATE, GD_KT, trap_funcs[T_BRKPOINT], 0);
    
    // two 8259a have 16 irqs in total.
    for (i = 0; i < IRQ_MAX; i++)
        GATE_CONSTRUCT(idt[i+IRQ_STARTED], INTGATE, GD_KT, irq_funcs[i], 0); 
    
    // Construct a entry in idt[] for irq_err.
    // After loop, i = 16 here. 
    extern void irq_err();
    GATE_CONSTRUCT(idt[IRQ_STARTED+IRQ_ERR], INTGATE, GD_KT, 
                                        irq_funcs[IRQ_MAX], 0);

    // Construct a entry in idt[] for syscall.
    extern void t_syscall();
    GATE_CONSTRUCT(idt[T_SYSCALL], TRAPGATE, GD_KT, t_syscall, USER_DPL);

    // Construct a entry in idt[] for default.
    extern void t_default();
    GATE_CONSTRUCT(idt[T_DEFAULT], INTGATE, GD_KT, t_default, 0);

    lidt((uint32_t)&idt_desc);
}

static void cow_pgfault(uint32_t falt_va)
{
    pid_t  cid = curproc->pid;
    void *addr = (void *)falt_va;
    void *raddr = (void *)ROUNDDOWN(falt_va, PGSIZE);

    // i do all about it in kernel stack
    // so if it was wrong, i kill the process.
    //if (!((utf->utrap_err & FEC_WR) && (uvpt[PGNUM(addr)] & PTE_COW)))
    //    exit();
    if (user_page_alloc(cid, (void *)PFTEMP, PTE_USTK) < 0) 
        exit();
    memmove((void *)PFTEMP, raddr, PGSIZE);
    if (user_page_upmap(cid, raddr) < 0)
        exit();
    if (user_page_map(cid, (void *)PFTEMP, cid, raddr, PTE_USTK) < 0)
        exit();
    if (user_page_upmap(cid, (void *)PFTEMP) < 0)
        exit();
}

void page_fault_handler(struct trapframe *tf)
{
    uint32_t falt_va = rcr2(); 

    if (((tf->trap_err & FEC_WR) && (uvpt[PGNUM(falt_va)] & PTE_COW))) {
        cow_pgfault(falt_va);
        return ;
    }
    if ((falt_va < curproc->heap_ptr) && (falt_va >= curproc->base_mem_sz)) {
        if (proc_region_alloc(curproc, (void *)falt_va, PGSIZE, PTE_SYSCALL) < 0)
            exit();
    }
}

void trap(struct trapframe *tf)
{
    struct proc *p = myproc();

    //It's not the time to uncomment it.
    if (!(tf->cs & USER_DPL) && tf->trap_no <= T_SIMDERR) {
        monitor(tf);
        panic("Int occurs in kernel mode!!!\n");
    }
    if (tf && tf->trap_no != (IRQ_STARTED+IRQ_TIMER))
    switch (tf->trap_no) {
        case (IRQ_STARTED + IRQ_TIMER):
            spin_lock_irqsave(&jiffs_lock);
            jiffs++;
            spin_unlock_irqrestore(&jiffs_lock);
            if (p && (p->tf->cs & 0x3)) {
                p->sleep_avg -= ((p->sleep_avg)?1:0);
                if (!(p->timeslice_left -= 1)) 
                    yield();
                if (p->alarmhandler && !(p->alarmticks_left -= 1)) {
                    p->alarmticks_left = p->alarmticks;
                    tf->esp -= 4;
                    *((uint32_t *)(tf->esp)) = tf->eip;
                    tf->eip = (uint32_t)(p->alarmhandler);
                }
            }
            irq_eoi();
            break;
        case (IRQ_STARTED + IRQ_SPURIOUS):
            prink("spurious interrupt on irq 7, unknow type?\n");
            prink_trapframe(tf);
            break;
        case (IRQ_STARTED + IRQ_KBD):
            kbd_intr();
            irq_eoi();
            break;
        case (IRQ_STARTED + IRQ_IDE):
            ide_intr();
            irq_eoi();
            break;
        case T_SYSCALL:
            tf->normal_regs.eax = syscall(tf->normal_regs.eax, tf->normal_regs.edx, 
                                        tf->normal_regs.ecx, tf->normal_regs.ebx, 
                                        tf->normal_regs.edi, tf->normal_regs.esi);
            break;
        case T_BRKPOINT:
            monitor(tf);
            break;
        case T_PGFAULT:
            //prink_trapframe(tf);
            page_fault_handler(tf);
            break;
        default:
            prink_trapframe(tf);
            monitor(tf);
            break;
    }

    // kill the process if it was killed.
    if (myproc() && myproc()->killed && (tf->cs & USER_DPL)) 
        exit();

    // current process was preempted. 
    if (myproc() && myproc()->preempted && (tf->cs & USER_DPL))
        yield();

    // What if the process was killed during sleeping?
    // So we have to check it again.
    if (myproc() && myproc()->killed && (tf->cs & USER_DPL))
        exit();
}