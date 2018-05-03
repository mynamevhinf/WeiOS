#include <include/boot.h>

.code16
.globl start_16
start_16:
    cli
    xorw    %ax, %ax
    movw    %ax, %ds
    movw    %ax, %es
    movw    %ax, %ss
    movw    $start_16, %sp

setupA20_1:
    inb     $0x64, %al      # Wait for not busy
    testb   $0x2, %al
    jnz     setupA20_1
    
    movb    $0xd1, %al
    outb    %al, $0x64

setupA20_2:
    inb     $0x64, %al
    testb   $0x2, %al
    jnz     setupA20_2

    movb    $0xdf, %al
    outb    %al, $0x60

    # It time to load gdt
    lgdt    gdtdesc
    movl    %cr0, %eax
    orl     $0x1, %eax          # segment protection
    movl    %eax, %cr0
    ljmp    $(KERNEL_CODE), $start_32

.code32
start_32:
    movw    $(KERNEL_DATA), %ax 
    movw    %ax, %es
    movw    %ax, %ds
    movw    %ax, %ss
    movl    $0x7c00, %esp

    call    bootmain

deadloop:
    jmp     deadloop    

.p2align 2
gdt:
    SEG_DES_NULL
    SEG_DES(0xffffffff, 0x0, GDT_X|GDT_R, GDT_G|GDT_DB)
    SEG_DES(0xffffffff, 0x0, GDT_W, GDT_G|GDT_DB)

gdtdesc:
    .word (gdtdesc-gdt-1)
    .long gdt
