#include <include/types.h>
#include <include/mem.h>
#include <include/mmu.h>
#include <include/time.h>
#include <include/file.h>
#include <include/proc.h>
#include <include/error.h>
#include <include/stdio.h>
#include <include/sched.h>
#include <include/stdarg.h>
#include <include/syscall.h>
#include <include/sysfile.h>
#include <include/sysfunc.h>


static int sys_puts(const char *s)
{
	return prink("%s", s);
}

static int sys_printf(const char *str, va_list ap)
{
	int cnt = 0;

	vprintfmt(str, &cnt, ap);
	return cnt;
}

static int sys_exit(void)
{
	exit();
	return 0; // nerver reache here if no bugs.
}

static int sys_wait(void)
{
	return wait();
}

static int sys_kill(pid_t pid)
{
	return kill(pid);
}

static int sys_exec(char *pathname, char **uargv)
{
	char *argv[MAXARG];

	if (!pathname || !uargv)
		return -1;
	for (int argc = 0; ; argc++) {
		if (argc >= MAXARG)
			return -1;
		if (uargv[argc] == 0) {
			if (!argc)
				return -1;
			argv[argc] = 0;
			break;
		}
		argv[argc] = uargv[argc];
	}

	return exec(pathname, argv);
}

static pid_t sys_getpid(void)
{
	return myproc()->pid;
}

static pid_t sys_getppid(void)
{
	return myproc()->ppid;
}

static int sys_alarm(uint32_t alarmticks, void (*handler)())
{
	myproc()->alarmticks = alarmticks;
    myproc()->alarmticks_left = alarmticks;
    myproc()->alarmhandler = handler;
    return 0;
}

static int sys_cancel_alarm(void)
{
	myproc()->alarmhandler = 0;
	return 0;
}

static int sys_yield(void)
{
	yield();
	return 0;
}

static int sys_exofork(void)
{
	return dup_proc_struct(0);
}

static int sys_set_proc_trapframe(pid_t pid, struct trapframe *tf)
{
	struct proc *p;

	if (pid2proc(pid, &p, 1) < 0)
		return -E_BAD_PROC;

	tf->eflags &= EFLAGS_IOPL_0;
	*(p->tf) = *tf;

	return 0;

}
// useless
static int sys_set_proc_pgfault_handler(pid_t pid, void *func)
{
	struct proc *p;

	if (pid2proc(pid, &p, 1) < 0)
		return -E_BAD_PROC;
	//p->pgfault_handler = func;
	return 0;
}

static int sys_page_alloc(pid_t pid, void *va, int perm)
{
	return user_page_alloc(pid, va, perm); 
}

static int sys_page_map(pid_t srcpid, void *srcva,
	     				pid_t dstpid, void *dstva, int perm)
{
	return user_page_map(srcpid, srcva, dstpid, dstva, perm);
}

static int sys_page_unmap(pid_t pid, void *va)
{
	return user_page_upmap(pid, va);
}

static int sys_fork(void)
{
	return clone(CLONE_FORK);
}

static int sys_ipc_try_send(pid_t pid, uint32_t value, 
							void *srcva, int32_t perm)
{
	return ipc_try_send(pid, value, srcva, perm);
}

static int ipc_send(pid_t to_proc, uint32_t val, void *pg, int32_t perm)
{
	int r;
	if (!pg)
		pg = (void *)(UTOP+1);
	while ((r = ipc_try_send(to_proc, val, pg, perm)) < 0) {
		if (r == -E_IPC_NOT_RECV)
			return r;
		else 
			return sys_exit();
	}
	return 0;
}

static int sys_ipc_recv(void *pg)
{
	return ipc_recv(pg);
}

static int sys_sbrk(int n)
{
	return (int)sbrk(n);
}

static int sys_brk(uint32_t heap_break)
{
	return brk(heap_break);
}

static int sys_pipe(int fd[2])
{
	return pipe(fd);
}

static int sys_dup(int fd)
{
	return dup(fd);
}

static int sys_dup2(int oldfd, int newfd)
{
	return dup2(oldfd, newfd);
}

static int sys_read(int fd, char *des, uint32_t nbytes)
{
	return read(fd, des, nbytes);
}

static int sys_write(int fd, char *src, uint32_t nbytes)
{
	return write(fd, src, nbytes);
}

static int sys_close(int fd)
{
	return close(fd);
}

static int sys_fstat(int fd, struct stat *sbuf)
{
	return fstat(fd, sbuf);
}

static int sys_link(char *oldpname, char *newpname)
{
	return link(oldpname, newpname);
}

static int sys_unlink(char *pathname)
{
	return unlink(pathname);
}

static int sys_open(char *pathname, int flag)
{
	return open(pathname, flag);
}

static int sys_mknod(char *pathname, ushort major, ushort minor)
{
	return mknod(pathname, major, minor);
}

static int sys_mkdir(char *pathname)
{
	return mkdir(pathname);
}

static int sys_chdir(char *pathname)
{
	return chdir(pathname);
}

static int sys_ls(const char *str)
{
	return ls_test(str);
}

int32_t syscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	switch (syscallno) {
		case SYS_puts:
			return sys_puts((const char *)a1);
		case SYS_exit:
			return sys_exit();
		case SYS_wait:
			return sys_wait();
		case SYS_kill:
			return sys_kill((pid_t)a1);
		case SYS_getpid:
			return (int32_t)sys_getpid();
		case SYS_getppid:
			return (int32_t)sys_getppid();
		case SYS_alarm:
			return sys_alarm(a1, (void (*)())a2);
		case SYS_cancel_alarm:
			return sys_cancel_alarm();
		case SYS_yield:
			return sys_yield();
		case SYS_exofork:
			return sys_exofork();
		case SYS_set_proc_trapframe:
			return sys_set_proc_trapframe((pid_t)a1, (struct trapframe *)a2);
		case SYS_set_proc_pgfault_handler:
			return sys_set_proc_pgfault_handler((pid_t)a1, (void *)a2);
		case SYS_page_alloc:
			return sys_page_alloc((pid_t)a1, (void *)a2, (int)a3);
		case SYS_page_map:
			return sys_page_map((pid_t)a1, (void *)a2, (pid_t)a3, 
								(void *)a4, (int)a5);
		case SYS_page_unmap:
			return sys_page_unmap((pid_t)a1, (void *)a2);
		case SYS_fork:
			return sys_fork();
		case SYS_ipc_try_send:
			return sys_ipc_try_send((pid_t)a1, a2, (void *)a3, a4);
		case SYS_ipc_send:
			return ipc_send((pid_t)a1, a2, (void *)a3, a4);
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
		case SYS_sbrk:
			return sys_sbrk((int)a1);
		case SYS_pipe:
			return sys_pipe((int *)a1);
		case SYS_dup:
			return sys_dup((int)a1);
		case SYS_dup2:
			return sys_dup2((int)a1, (int)a2);
		case SYS_read:
			return sys_read((int)a1, (char *)a2, a3);
		case SYS_write:
			return sys_write((int)a1, (char *)a2, a3);
		case SYS_close:
			return sys_close((int)a1);
		case SYS_fstat:
			return sys_fstat((int)a1, (struct stat *)a2);
		case SYS_link:
			return sys_link((char *)a1, (char *)a2);
		case SYS_unlink:
			return sys_unlink((char *)a1);
		case SYS_open:
			return sys_open((char *)a1, (int)a2);
		case SYS_mkdir:
			return sys_mkdir((char *)a1);
		case SYS_chdir:
			return sys_chdir((char *)a1);
		case SYS_printf:
			return sys_printf((const char *)a1, (va_list)a2);
		case SYS_exec:
			return sys_exec((char *)a1, (char **)a2);
		case SYS_mknod:
			return sys_mknod((char *)a1, (ushort)a2, (ushort)a2);
		case SYS_welcome:
			welcome_to_WeiOS();
			return 0;
		case SYS_lsdir:
			return sys_ls((const char *)a1);
		case SYS_brk:
			return sys_brk(a1);
		default:
			prink("Bad syscall number!\n");
			return -1;
	}
}