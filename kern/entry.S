
.p2align 2
.text
.globl _start
_start = ((_entry)-0xF0000000)

.globl _entry
_entry:
    movl %cr4, %eax
    orl  $(0x00000010), %eax
    movl %eax, %cr4

    movl $(temppgdir-0xF0000000), %eax
    movl %eax, %cr3

    movl %cr0, %eax
    orl $(0x80010000), %eax
    movl %eax, %cr0

    movl $(kernstacktop), %esp

    movl $main, %eax
    jmp *%eax

.data
    .p2align 12
    .globl  kernstack
kernstack:
    .space  8192
    .globl  kernstacktop
kernstacktop:
    
