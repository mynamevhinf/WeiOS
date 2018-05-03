#include "../include/mem.h"

.text
.globl gdt_flush
gdt_flush:
    movl 4(%esp), %eax
    lgdt (%eax)

    movw $(GD_KD), %ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %fs
    movw %ax, %gs
    movw %ax, %ss

    ljmp $(GD_KT), $flush2
flush2:
    ret
    
