/*
 * PRIVIDE(KEYWORD): KEYWORD was used in object file but never 
 *                   declared, Yeah! We delare it right here.
 */

OUTPUT_FORMAT("elf32-i386", "elf32-i386", "elf32-i386")
OUTPUT_ARCH(i386)
ENTRY(_start)

SECTIONS
{
    . = 0xF0100000;

    .text : AT(0x100000) {
        *(.text .stub .text.* .gnu_linkonce.t.*)
    }

    PROVIDE(etext = .);

    .rodata : {
        *(.rodata .rodata.* .gnu.linkonce.r.*)
    }

    .stab : {
        PROVIDE(__STAB_BEGIN__ = .);
        *(.stab);
        PROVIDE(__STAB_END__ = .);
        BYTE(0) /* Force the linker to allocate space
                   for this section, the same as .stabstr */
    }

    .stabstr : {
        PROVIDE(__STABSTR_BEGIN__ = .);
        *(.stabstr);
        PROVIDE(__STABSTR_END__ = .);
        BYTE(0)
    }

    . = ALIGN(0x1000);  /* align 4096 */
    
    .data : {
        *(.data)
    }

    PROVIDE(edata = .);

    .bss : {
        *(.bss)
    }

    PROVIDE(end = .);

    /DISCARD/ : {
        *(.eh_frame .note.GNU-stack)
    }
}
