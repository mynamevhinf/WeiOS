#ifndef _ELF_H_
#define _ELF_H_

#include <include/types.h>

#define EI_NIDENT       12 
#define ELF_MAGIC       0x464c457fU

struct Elf32_Ehdr {
    uint        e_magic;
    uchar       e_ident[EI_NIDENT];
    uint16_t    e_type;
    uint16_t    e_machine;
    uint32_t    e_version;
    Elf32_Addr  e_entry;
    Elf32_Off   e_phoff;
    Elf32_Off   e_shoff;
    uint32_t    e_flags;
    uint16_t    e_ehsize;
    uint16_t    e_phentsize;
    uint16_t    e_phnum;
    uint16_t    e_shentsize;
    uint16_t    e_shnum;
    uint16_t    e_shstrndx;
};

struct Elf32_Phdr {
    uint32_t    p_type;
    Elf32_Off   p_offset;
    Elf32_Addr  p_vaddr;
    Elf32_Addr  p_paddr;
    uint32_t    p_filesz;
    uint32_t    p_memsz;
    uint32_t    p_flags;
    uint32_t    p_align;
};

#define ELF_PROG_LOAD           1

#define ELF_PROG_FLAG_EXEC      1
#define ELF_PROG_FLAG_WRITE     2
#define ELF_PROG_FLAG_READ      4

#endif
