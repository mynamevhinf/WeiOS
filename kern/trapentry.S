#include "../include/mem.h"
#include "../include/trap.h" 

#define TRAPHANDLER(name, num)  \
    .text;  \
    .globl name;    \
    .type name, @function;  \
    .align 2;   \
    name:   \
        pushl $(num);   \
        jmp alltraps;  \
    .data;  \
    .long name; 

#define TRAPHANDLER_NOERRNO(name, num)  \
    .text;  \
    .globl name;    \
    .type name, @function;  \
    .align 2;   \
    name:   \
        pushl $0;   \
        pushl $(num);   \
        jmp alltraps;   \
    .data;  \
    .long name;


# vector table for traps
.data
.globl trap_funcs
trap_funcs:
    TRAPHANDLER_NOERRNO(t_divide, T_DIVIDE)    
    TRAPHANDLER_NOERRNO(t_debug, T_DEBUG)
    TRAPHANDLER_NOERRNO(t_nmi, T_NMI)
    TRAPHANDLER_NOERRNO(t_brk, T_BRKPOINT)
    TRAPHANDLER_NOERRNO(t_oflow, T_OVERFLOW)
    TRAPHANDLER_NOERRNO(t_bound, T_BOUND)
    TRAPHANDLER_NOERRNO(t_illop, T_INVALIDOP)
    TRAPHANDLER_NOERRNO(t_device, T_COPRONA)

    TRAPHANDLER(t_dbflt, T_DOUBLEFAULT)
    TRAPHANDLER(t_coproc, T_COPROC) 
    TRAPHANDLER(t_tss, T_TSS)
    TRAPHANDLER(t_segnp, T_SEGNOTP)
    TRAPHANDLER(t_stack, T_STK)
    TRAPHANDLER(t_gpflt, T_GERNERAL)
    TRAPHANDLER(t_pgflt, T_PGFAULT)
    TRAPHANDLER(t_res, T_RES)
    TRAPHANDLER_NOERRNO(t_flperr, T_FLPERR)
    TRAPHANDLER(t_align, T_ALIGN)
    TRAPHANDLER_NOERRNO(t_mchk, T_MACHINE)
    TRAPHANDLER_NOERRNO(t_simd, T_SIMDERR)  //19

# vetor table for irqs
.data
.globl irq_funcs
irq_funcs:
    TRAPHANDLER_NOERRNO(irq_timer, IRQ_STARTED+IRQ_TIMER) 
    TRAPHANDLER_NOERRNO(irq_kbd, IRQ_STARTED+IRQ_KBD) 
    TRAPHANDLER_NOERRNO(irq_res2, IRQ_STARTED+2) 
    TRAPHANDLER_NOERRNO(irq_res3, IRQ_STARTED+3) 
    TRAPHANDLER_NOERRNO(irq_serial, IRQ_STARTED+IRQ_SERIAL) 
    TRAPHANDLER_NOERRNO(irq_res5, IRQ_STARTED+5) 
    TRAPHANDLER_NOERRNO(irq_res6, IRQ_STARTED+6) 
    TRAPHANDLER_NOERRNO(irq_spurious, IRQ_STARTED+IRQ_SPURIOUS) 
    TRAPHANDLER_NOERRNO(irq_res8, IRQ_STARTED+8) 
    TRAPHANDLER_NOERRNO(irq_res9, IRQ_STARTED+9) 
    TRAPHANDLER_NOERRNO(irq_res10, IRQ_STARTED+10) 
    TRAPHANDLER_NOERRNO(irq_res11, IRQ_STARTED+11) 
    TRAPHANDLER_NOERRNO(irq_res12, IRQ_STARTED+12) 
    TRAPHANDLER_NOERRNO(irq_res13, IRQ_STARTED+13) 
    TRAPHANDLER_NOERRNO(irq_ide, IRQ_STARTED+IRQ_IDE) 
    TRAPHANDLER_NOERRNO(irq_res15, IRQ_STARTED+15) 

    // irq_err
    TRAPHANDLER_NOERRNO(irq_err, IRQ_STARTED+IRQ_ERR)

    // for syscall and default
    TRAPHANDLER_NOERRNO(t_syscall, T_SYSCALL)
    TRAPHANDLER_NOERRNO(t_default, T_DEFAULT)


.text
.globl alltraps
alltraps:
    pushl %ds
    pushl %es
    pushl %fs
    pushl %gs
    pushal

    movw $(GD_KD), %ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %gs
    movw %ax, %fs

    pushl %esp
    call trap
    addl $0x4, %esp

.globl trapsret
trapsret:
    popal
    popl %gs
    popl %fs
    popl %es
    popl %ds
    addl $0x8, %esp
    iret


