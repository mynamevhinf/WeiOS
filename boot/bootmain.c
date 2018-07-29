#include <include/types.h>
#include <include/x86.h>
#include <include/elf.h>

#define SECTORSIZE 512 

void readdisk(void *dst, uint sec_num);
void readsegment(uchar *pa, uint bytes, uint offset);

void bootmain(void)
{
    struct Elf32_Ehdr      *e;
    struct Elf32_Phdr      *ph;
    void (*kernel_entry)(void);
    uchar* pa;

    e = (struct Elf32_Ehdr *)0x10000;
    readsegment((uchar *)e, 4096, 0);
    // check wether the image is a legal elf file.
    if (e->e_magic != ELF_MAGIC)
        return ;

    ph = (struct Elf32_Phdr *)((uchar *)e + e->e_phoff);
    for (int i = 0; i < e->e_phnum; i++, ph++) {
        pa = (uchar *)ph->p_paddr;
        readsegment(pa, ph->p_filesz, ph->p_offset);
        if (ph->p_memsz > ph->p_filesz)
            stosb(pa + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
    }

    kernel_entry = (void (*)(void))(e->e_entry);
    kernel_entry();
}

/************************************************
                Useful function
************************************************/
void waitfordisk(void)
{
    while ((inb(0x1f7) & 0xC0) != 0x40)
        ;
}

// read a single block into memory.
// void outb(ushort port, uchar data)
void readdisk(void *dst, uint sec_num)
{
    int rsec_num, secs_per_blk;
    secs_per_blk = SECTORSIZE / SECTORSIZE;
    rsec_num = secs_per_blk * sec_num;

    waitfordisk();    
    outb(0x1f2, secs_per_blk);
    outb(0x1f3, rsec_num & 0xff);
    outb(0x1f4, (rsec_num>>8) & 0xff);
    outb(0x1f5, (rsec_num>>16) & 0xff);
    outb(0x1f6, LBA|0xA0|((rsec_num>>24) & 0x0f));
    outb(0x1f7, 0x20);

    waitfordisk();
    insl(0x1f0, dst, SECTORSIZE/4);
}

// read a segment into memory
// offset relatives to the start of the kernel.
void readsegment(uchar *pa, uint bytes, uint offset)
{
    uint  sec_num;
    uchar *epa = pa + bytes;
    
    sec_num = offset / SECTORSIZE + 1;
    for (pa -= (offset%SECTORSIZE); pa < epa; sec_num++, pa += SECTORSIZE)  
        readdisk(pa, sec_num);
}

