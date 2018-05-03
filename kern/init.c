#include <include/types.h>
#include <include/mem.h>
#include <include/mmu.h>
#include <include/x86.h>
#include <include/fs.h>
#include <include/ide.h>
#include <include/kbd.h>
#include <include/time.h>
#include <include/trap.h>
#include <include/pmap.h>
#include <include/slab.h>
#include <include/proc.h>
#include <include/file.h>
#include <include/buddy.h>
#include <include/stdio.h>
#include <include/sched.h>
#include <include/picirq.h>
#include <include/string.h>
#include <include/buffer.h>
#include <include/monitor.h>
#include <include/console.h>

int main(void)
{
    extern char edata[], end[];
    memset(edata, 0, end - edata);

    console_init();
    gdt_init();
    trap_init();
    irq_init();
    kbd_init();
    time_init();
    mem_init();
    proc_init();

    ide_init();
    buffer_init();
    ftable_init();

    // Jobs above are all successfully done.
    WeiOS_first_process();
    scheduler();
}

__attribute__((__aligned__(PGSIZE)))
pde_t temppgdir[PDENTRIES] = {
    [0] = 0 | PTE_P | PTE_W | PTE_PS,
    [1] = (0x400000) | PTE_P | PTE_W | PTE_PS,
    [2] = (0x800000) | PTE_P | PTE_W | PTE_PS,
    [PDINDEX(KERNBASE)] = 0 | PTE_P | PTE_W | PTE_PS,
    [PDINDEX(KERNBASE+0x400000)] = (0x400000) | PTE_P | PTE_W | PTE_PS,
    [PDINDEX(KERNBASE+0X800000)] = (0X800000) | PTE_P | PTE_W | PTE_PS
};

