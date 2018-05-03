#include <include/syscall.h>
#include <include/trap.h>

.text
.globl _ustart
_ustart:
	call wmain
	addl $8, %esp

  	movl $SYS_exit, %eax
  	int $T_SYSCALL