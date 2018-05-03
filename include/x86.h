#ifndef _X86_H_
#define _X86_H_

// asm code in C 
#include <include/types.h>

#define LBA 0x40

static inline uchar inb(ushort port)
{
    uchar data;
    asm volatile ("inb %1, %0":"=a" (data):"d" (port));
    return data; 
}

static inline ushort inw(ushort port)
{
    ushort data;
    asm volatile ("inw %1, %0":"=a" (data):"d" (port));
    return data;
}

static inline void insl(int port, void *addr, int count)
{
    asm volatile ("cld\n\trepne\n\tinsl"
                  :"=D" (addr), "=c" (count)
                  :"d" (port), "0" (addr), "1" (count)
                  :"memory", "cc");
}


static inline void outb(ushort port, uchar data)
{
    asm volatile ("outb %1, %w0"::"d" (port), "a" (data));
}

static inline void outw(ushort port, ushort data)
{
    asm volatile ("outw %1, %w0"::"d" (port), "a" (data));
}

static inline void outsl(ushort port, const void *addr, uint32_t cnt)
{
    asm volatile ("cld; rep outsl"
                  :"=S" (addr), "=c" (cnt)
                  :"d" (port), "0" (addr), "1" (cnt)
                  :"cc");
}

static inline void stosb(void *desc, int value, int bytes)
{
    asm volatile ("cld; rep stosb"
                  :"=D"(desc), "=c" (value)
                  :"0" (desc), "1" (value), "a" (bytes)
                  :"memory", "cc");
}

static inline void invlpg(void *addr)
{
  asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
}

static inline uint32_t rcr0(void)
{
    uint32_t cr0;
    asm volatile ("movl %%cr0, %0":"=r" (cr0)::);
    return cr0;
}

static inline uint32_t rcr2(void)
{
    uint32_t cr2;
    asm volatile ("movl %%cr2, %0":"=r" (cr2)::);
    return cr2;
}

static inline void lcr0(uint32_t cr0)
{
    asm volatile ("movl %0, %%cr0"::"r" (cr0));
}

static inline void lcr3(uint32_t cr3)
{
    asm volatile ("movl %0, %%cr3"::"r" (cr3));
}

static inline void lgdt(void *addr) 
{
    asm volatile ("lgdt %0"::"m" (addr):"memory");
}

static inline void lidt(uint32_t addr) 
{
    asm volatile ("lidt (%0)"::"r" (addr));
}

static inline void ltr(ushort seg) 
{
    asm volatile ("ltr %0"::"r" (seg));
}

static inline void lldt(uint16_t sel)
{
    asm volatile ("lldt %0" : : "r" (sel));
}

static inline uint32_t reflags(void)
{
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" :"=r" (eflags));
    return eflags;
}

static inline void sti(void)
{
    asm volatile ("sti");
}

static inline void cli(void)
{
    asm volatile ("cli");
}

static inline uint32_t xchg(volatile uint *addr, uint newval)
{
    uint32_t result;

    // The + in "+m" denotes a read-modify-write operand.
    asm volatile("lock; xchgl %0, %1" :
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
    /* No matter there is a lock or not, xchg is always atomic
     * it means i can writes following codes instead:
    asm volatile("xchgl %0, %1" :
           "+m" (*addr), "=a" (result) :
           "1" (newval) :
           "cc");
    */
    return result;
}

#endif
