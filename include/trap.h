#ifndef _TRAP_H_
#define _TRAP_H_


#define T_DIVIDE        0
#define T_DEBUG         1
#define T_NMI           2
#define T_BRKPOINT      3
#define T_OVERFLOW      4
#define T_BOUND         5
#define T_INVALIDOP     6
#define T_COPRONA       7
#define T_DOUBLEFAULT   8
#define T_COPROC        9
#define T_TSS           10
#define T_SEGNOTP       11
#define T_STK           12
#define T_GERNERAL      13
#define T_PGFAULT       14
// Reserved #define T_RESERVED 15 
#define T_RES           15

#define T_FLPERR        16
#define T_ALIGN         17
#define T_MACHINE       18
#define T_SIMDERR       19

#define T_SYSCALL       128 
#define T_DEFAULT       255 

// IRQ_MAX is not a valid irq number.
// it means how many irqs we have.
#define IRQ_MAX         16
// The same as in JOS
#define IRQ_STARTED     32
#define IRQ_TIMER       0
#define IRQ_KBD         1
#define IRQ_SERIAL      4 
#define IRQ_SPURIOUS    7
#define IRQ_IDE         14

#define IRQ_ERR         19 

#ifndef __ASSEMBLER__

#include <include/types.h>

struct pushregs {
    uint32_t edi;
    uint32_t esi;
    uint32_t ebp;
    uint32_t oesp;
    uint32_t ebx;
    uint32_t edx;
    uint32_t ecx;
    uint32_t eax;
} __attribute__((packed));

typedef struct trapframe *Trapf;
struct trapframe {
    struct pushregs normal_regs;     
    uint16_t        gs;
    uint16_t        padding5; 
    uint16_t        fs;
    uint16_t        padding6;
    uint16_t        es;
    uint16_t        padding1; 
    uint16_t        ds;
    uint16_t        padding2;
    uint32_t        trap_no;

    // below here hadled by x86 architecture
    uint32_t        trap_err;
    uint32_t        eip;
    uint16_t        cs;
    uint16_t        padding3;
    uint32_t        eflags;
    // If we have to change stack
    // i means switch from user mode to kernel mode
    uint32_t        esp;
    uint16_t        ss;
    uint16_t        padding4;
} __attribute__((packed));

void prink_trapframe(struct trapframe *tf);
void trap_init(void);
void gdt_init(void);
void trap(Trapf tf);

#endif

#endif
