#ifndef _SYSCALL_H_
#define _SYSCALL_H_

#define SYS_puts 			0
#define SYS_exit 			1
#define SYS_wait 			2
#define SYS_kill 			3
#define SYS_getpid 			4
#define SYS_getppid 		5
#define SYS_alarm 			6
#define SYS_cancel_alarm 	7
#define SYS_yield			8
#define SYS_exofork 		9 
#define SYS_set_proc_trapframe		10
#define SYS_set_proc_pgfault_handler	11
#define SYS_page_alloc		12
#define SYS_page_map		13
#define SYS_page_unmap		14
#define SYS_fork            15
#define SYS_ipc_try_send    16
#define SYS_ipc_send 		17
#define SYS_ipc_recv		18
#define SYS_sbrk			19
#define SYS_pipe			20
#define SYS_dup 			21
#define SYS_dup2 			22
#define SYS_read 			23
#define SYS_write			24
#define SYS_close			25
#define SYS_fstat			26
#define SYS_link 			27
#define SYS_unlink 			28
#define SYS_open 			29
#define SYS_mkdir 			30
#define SYS_chdir			31
#define SYS_printf			32
#define SYS_exec			33
#define SYS_mknod			34
#define SYS_welcome			35
#define SYS_lsdir 			36
#define SYS_brk 			37


#ifndef __ASSEMBLER__

#include <include/types.h>

int32_t syscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5);

#endif

#endif