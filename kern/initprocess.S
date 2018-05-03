#include <include/syscall.h>
#include <include/trap.h>

.globl start
start:
  movl $init_statement_1, %edx
  movl $SYS_puts, %eax
  int $T_SYSCALL
  
  movl $init_statement_2, %edx
  movl $SYS_puts, %eax
  int $T_SYSCALL

  movl $init_statement_8, %edx
  movl $SYS_puts, %eax
  int $T_SYSCALL
  
  movl $init_statement_3, %edx
  movl $SYS_puts, %eax
  int $T_SYSCALL
  
  movl $init_statement_4, %edx
  movl $SYS_puts, %eax
  int $T_SYSCALL
  
  movl $init_statement_5, %edx
  movl $SYS_puts, %eax
  int $T_SYSCALL
  
  movl $init_statement_6, %edx
  movl $SYS_puts, %eax
  int $T_SYSCALL

  movl $init_statement_9, %edx
  movl $SYS_puts, %eax
  int $T_SYSCALL
  
  movl $init_statement_7, %edx
  movl $SYS_puts, %eax
  int $T_SYSCALL

  movl $argv, %ecx 
  movl $init, %edx
  movl $SYS_exec, %eax
  int $T_SYSCALL

  movl $SYS_exit, %eax
  int $T_SYSCALL

init:
  .string "/init\0"

.p2align 2
argv:
  .long init 
  .long 0

# char init[] = "/init\0";
init_statement_1:
	.asciz "   /******************************************************************\n"
init_statement_2:
    .asciz "		Hello, strangers!\n"
init_statement_8:
    .asciz "        My name is WeiQingFu, From UESTC. Reaching here means that \n"
init_statement_3:
    .asciz "        WeiOS run perfectly so far. If you have found any bugs in \n"
init_statement_4:
    .asciz "        the kernel, please send an email to vhinf2047@gmail.com.\n"
init_statement_5:
    .asciz "		otherwise, contact to me with my wechat number: aoewqf1997. \n"
init_statement_6:
    .asciz "        I'll appreciate it very much!!!\n"
init_statement_9:
	.asciz "        Friday, 20 April 2018.\n"
init_statement_7:
    .asciz "   ******************************************************************/\n"


