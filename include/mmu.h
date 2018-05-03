#ifndef _MMU_H_
#define _MMU_H_

#include <include/types.h>

// Eflags register
#define EFLAGS_CF           0x00000001      // Carry Flag
#define EFLAGS_PF           0x00000004      // Parity Flag
#define EFLAGS_AF           0x00000010      // Auxiliary carry Flag
#define EFLAGS_ZF           0x00000040      // Zero Flag
#define EFLAGS_SF           0x00000080      // Sign Flag
#define EFLAGS_TF           0x00000100      // Trap Flag
#define EFLAGS_IF           0x00000200      // Interrupt Enable
#define EFLAGS_DF           0x00000400      // Direction Flag
#define EFLAGS_OF           0x00000800      // Overflow Flag
#define EFLAGS_IOPL_MASK    0x00003000      // I/O Privilege Level bitmask
#define EFLAGS_IOPL_0       0x00000000      //   IOPL == 0
#define EFLAGS_IOPL_1       0x00001000      //   IOPL == 1
#define EFLAGS_IOPL_2       0x00002000      //   IOPL == 2
#define EFLAGS_IOPL_3       0x00003000      //   IOPL == 3
#define EFLAGS_NT           0x00004000      // Nested Task
#define EFLAGS_RF           0x00010000      // Resume Flag
#define EFLAGS_VM           0x00020000      // Virtual 8086 mode
#define EFLAGS_AC           0x00040000      // Alignment Check
#define EFLAGS_VIF          0x00080000      // Virtual Interrupt Flag
#define EFLAGS_VIP          0x00100000      // Virtual Interrupt Pending
#define EFLAGS_ID           0x00200000      // ID flag

// Cr3
#define CR0_PG  0x80000000
#define CR0_CD  0x40000000
#define CR0_NW  0x20000000
#define CR0_AM  0x00040000
#define CR0_WP  0x00010000
#define CR0_NE  0x00000020
#define CR0_ET  0x00000010
#define CR0_TS  0x00000008
#define CR0_EM  0x00000004
#define CR0_MP  0x00000002
#define CR0_PE  0x00000001

// Cr4
#define CR4_PSE 0x00000010 

// Page fault error codes
#define FEC_PR      0x1 // Page fault caused by protection violation
#define FEC_WR      0x2 // Page fault caused by a write
#define FEC_U       0x4 // Page fault occured while in user mode

// Page management
#define PTE_P           0x001   // Present
#define PTE_W           0x002   // Writeable
#define PTE_U           0x004   // User
#define PTE_PWT         0x008   // Write-Through
#define PTE_PCD         0x010   // Cache-Disable
#define PTE_A           0x020   // Accessed
#define PTE_D           0x040   // Dirty
#define PTE_PS          0x080   // Page Size
#define PTE_MBZ         0x180   // Bits must be zero

// CPU will not depends on AVL field in page entry. so i can use it.
// it is the reason why i can set PTE_AVAIL, PTE_SHARE and PTE_COW. 

// The PTE_AVAIL bits aren't used by the kernel or interpreted by the
// hardware, so user processes are allowed to set them arbitrarily.
#define PTE_AVAIL       0xE00 
// PTE_COW marks copy-on-write page table entries.
// It is one of the bits explicitly allocated to user processes (PTE_AVAIL).
#define PTE_COW     0x800
#define PTE_SHARE   0x400
#define PTE_LAZY    0x200

#define PTE_USTK        (PTE_P | PTE_W | PTE_U)
#define PTE_SYSCALL     (PTE_AVAIL | PTE_USTK)

#define PDENTRIES   1024
#define PGSIZE      4096
#define PTSIZE      (PGSIZE*PDENTRIES)

#define PDXSHIFT    22
#define PTXSHIFT    12

#define PGSHIFT     12

#define PDINDEX(x)  ((((uint32_t)x)>>PDXSHIFT)&0x3ff) 
#define PTINDEX(x)  ((((uint32_t)x)>>PTXSHIFT)&0x3ff)

// We can construct a virtual address
// by using pgdir's index, pgtable's index and offset.
#define PGADDR(PGIDX, PTIDX, OFFSET)  \
        ((void*) ((PGIDX) << PDXSHIFT | (PTIDX) << PTXSHIFT | (OFFSET)))

#define PGNUM(X)    (((uint32_t)(X)) >> PTXSHIFT)

#define PTE_ADDR(PTE)   ((uint32_t)PTE & ~0xFFF)
#define PTE_ATTR(PTE)   ((uint32_t)PTE & 0xFFF)

// Some macro functions
#define Va2Pa(X)    ((X)-KERNBASE)


/**************************************
 *          Macros about GDT
 **************************************/
// Varias segment selectors, the index of segdesc's array
#define SEG_KCODE 1
#define SEG_KDATA 2
#define SEG_UCODE 3
#define SEG_UDATA 4
#define SEG_TSS   5

// Total segments in my kernel.
#define NSEGS       6

// Total processes in my kernel.
#define NPROC       1024

#define USER_DPL    0x3

// Application segment type bits
#define STA_X       0x8     // Executable segment
#define STA_E       0x4     // Expand down (non-executable segments)
#define STA_C       0x4     // Conforming code segment (executable only)
#define STA_W       0x2     // Writeable (non-executable segments)
#define STA_R       0x2     // Readable (executable segments)
#define STA_A       0x1     // Accessed

// System segment type bits
#define STS_T16A    0x1     // Available 16-bit TSS
#define STS_LDT     0x2     // Local Descriptor Table
#define STS_T16B    0x3     // Busy 16-bit TSS
#define STS_CG16    0x4     // 16-bit Call Gate
#define STS_TG      0x5     // Task Gate / Coum Transmitions
#define STS_IG16    0x6     // 16-bit Interrupt Gate
#define STS_TG16    0x7     // 16-bit Trap Gate
#define STS_T32A    0x9     // Available 32-bit TSS
#define STS_T32B    0xB     // Busy 32-bit TSS
#define STS_CG32    0xC     // 32-bit Call Gate
#define STS_IG32    0xE     // 32-bit Interrupt Gate
#define STS_TG32    0xF     // 32-bit Trap Gate

#ifndef __ASSEMBLER__

struct segdesc {
    unsigned int    lim_0_15:16;
    unsigned int    base_0_15:16; 
    unsigned int    base_16_23:8;
    unsigned int    type:4;
    unsigned int    s:1;
    unsigned int    dpl:2;
    unsigned int    p:1;
    unsigned int    lim_16_19:4;
    unsigned int    avl:1;
    unsigned int    reserved:1;
    unsigned int    d_or_b:1;
    unsigned int    granularity:1;
    unsigned int    base_24_31:8;
} __attribute__((packed));

// I assume that LIM is 20 bits.
// So i use only low 20 bits in LIM.
#define SEG_CONSTRUCT(TYPE, BASE, LIM, DPL) \
    (struct segdesc) {  \
        (LIM>>12) & 0xFFFF, BASE & 0xFFFF, (BASE>>16) & 0xFFFF,   \
        TYPE & 0xF, 1, DPL, 1, LIM>>28, 0, 0, 1, 1, BASE>>24}
// In 16-bit mode, Address space <= 0xFFFFF
#define SEG16_CONSTRUCT(TYPE, BASE, LIM, DPL) \
    (struct segdesc) {  \
        (LIM) & 0xFFFF, (BASE) & 0xFFFF, (BASE>>16) & 0xFFFF,   \
        (TYPE) & 0xF, 1, DPL, 1, (LIM)>>16, 0, 0, 1, 0, (BASE)>>24}


/********************************************
 *          Macros about TSS & GATE 
 ********************************************/
// Tss segment
struct tss_struct {
    uint32_t  link;
    uint32_t  esp0;
    unsigned short  ss0;
    unsigned short  padding0;
    uint32_t  esp1;
    unsigned short  ss1;
    unsigned short  padding1;
    uint32_t  esp2;
    unsigned short  ss2;
    unsigned short  padding2;
    void  *cr3;
    uint32_t  eip;
    uint32_t  eflags;
    uint32_t  eax;
    uint32_t  ecx;
    uint32_t  edx;
    uint32_t  ebx;
    uint32_t  esp;
    uint32_t  ebp;
    uint32_t  esi;
    uint32_t  edi;
    unsigned short  es;
    unsigned short  padding3;
    unsigned short  cs;
    unsigned short  padding4;
    unsigned short  ss;
    unsigned short  padding5;
    unsigned short  ds;
    unsigned short  padding6;
    unsigned short  fs;
    unsigned short  padding7;
    unsigned short  gs;
    unsigned short  padding8;
    unsigned short  ldt;
    unsigned short  padding9;
    unsigned short  t;      /* if 0 bit in the field is set
                            cpu will raise a trap when switching task. */
    unsigned short  iomb;
} __attribute__((packed));


// Gate descriptors for interrupts and traps.
struct gatedesc {
    unsigned int  off_0_15:16;
    unsigned int  cs:16;    // Code segment selector
    unsigned int  args:5;   // how many args?
    unsigned int  reserved:3;
    unsigned int  type:4;   // interrupt or trap gate? 
    unsigned int  s:1;      // must be 0, means system.
    unsigned int  dpl:2;    
    unsigned int  p:1;      // Present?
    unsigned int  off_16_31:16;
} __attribute__((packed));

// The difference between trap gate and interrupt gate 
// is that trap gate leave EFLAGS_IF alone, interrupt gate
// does not. which means that when executing in the code segment
// specified by trap gate, interrupt is still enabled.
#define TRAPGATE    1
#define INTGATE     0

#define GATE_CONSTRUCT(GATE, ISTRAP, SELECTOR, OFF, DPL)    \
{\
    (GATE).off_0_15 = (uint32_t)(OFF) & 0xFFFF;   \
    (GATE).cs = SELECTOR;    \
    (GATE).args = 0;        \
    (GATE).reserved = 0;    \
    (GATE).type = ((ISTRAP)?(STS_TG32):(STS_IG32)); \
    (GATE).s = 0;   \
    (GATE).dpl = DPL;   \
    (GATE).p = 1;   \
    (GATE).off_16_31 = (uint32_t)(OFF)>>16; \
}

// Used for loading idt, gdt, tss and ldt.
// The structure must be packed because directives demand it.
struct pseudo_desc {
    uint16_t    lim;
    uint32_t    base_addr;
} __attribute__((packed));

#endif

#endif
