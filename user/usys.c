#include <include/types.h>
#include <include/user.h>

int fork(void)
{
	return usyscall(SYS_fork, 0, 0, 0, 0, 0);
}

int exit(void)
{
	return usyscall(SYS_exit, 0, 0, 0, 0, 0);
}

void *sbrk(int n)
{
	return (void *)usyscall(SYS_sbrk, (uint32_t)n, 0, 0, 0, 0);
}

int brk(void *heap_brk)
{
	return usyscall(SYS_brk, (uint32_t)heap_brk, 0, 0, 0, 0);
}

ushort wait(void)
{
	return usyscall(SYS_wait, 0, 0, 0, 0, 0);
}

int kill(pid_t pid)
{
	return usyscall(SYS_kill, pid, 0, 0, 0, 0);
}

int exec(char *pathname, char **argv)
{
	return usyscall(SYS_exec, (uint32_t)pathname, (uint32_t)argv, 0, 0, 0);
}

int pipe(int fd[2])
{
	return usyscall(SYS_pipe, (uint32_t)fd, 0, 0, 0, 0);
}

int dup(int fd)
{
	return usyscall(SYS_dup, (uint32_t)fd, 0, 0, 0, 0);
}

int dup2(int oldfd, int newfd)
{
	return usyscall(SYS_dup2, (uint32_t)oldfd, (uint32_t)newfd, 0, 0, 0);
}

int read(int fd, char *des, uint32_t nbytes)
{
	return usyscall(SYS_read, (uint32_t)fd, (uint32_t)des, (uint32_t)nbytes, 0, 0);
}

int write(int fd, char *src, uint32_t nbytes)
{
	return usyscall(SYS_write, (uint32_t)fd, (uint32_t)src, (uint32_t)nbytes, 0, 0);	
}

int close(int fd)
{
	return usyscall(SYS_close, (uint32_t)fd, 0, 0, 0, 0);
}

int fstat(int fd, struct stat *sbuf)
{
	return usyscall(SYS_fstat, (uint32_t)sbuf, 0, 0, 0, 0);
}

int link(char *oldpname, char *newpname)
{
	return usyscall(SYS_link, (uint32_t)oldpname, (uint32_t)newpname, 0, 0, 0);
}
int unlink(char *pathname)
{
	return usyscall(SYS_unlink, (uint32_t)pathname, 0, 0, 0, 0);
}
int open(char *pathname, int flag)
{
	return usyscall(SYS_open, (uint32_t)pathname, (uint32_t)flag, 0, 0, 0);
}

int mknod(char *pathname, ushort major, ushort minor)
{
	return usyscall(SYS_mknod, (uint32_t)pathname, 
					(uint32_t)major, (uint32_t)minor, 0, 0);
}

int mkdir(char *pathname)
{
	return usyscall(SYS_mkdir, (uint32_t)pathname, 0, 0, 0, 0);
}

int chdir(char *pathname)
{
	return usyscall(SYS_chdir, (uint32_t)pathname, 0, 0, 0, 0);
}

int ipc_try_send(pid_t pid, uint32_t value, void *srcva, int32_t perm)
{
	return usyscall(SYS_ipc_try_send, pid, value, 
					(uint32_t)srcva, (uint32_t)perm, 0);
}

int ipc_send(pid_t to_proc, uint32_t val, void *pg, int32_t perm)
{
	return usyscall(SYS_ipc_send, to_proc, val, 
					(uint32_t)pg, (uint32_t)perm, 0);
}

int ipc_recv(void *pg)
{
	return usyscall(SYS_ipc_recv, (uint32_t)pg, 0, 0, 0, 0);
}

int getpid(void)
{
	return usyscall(SYS_getpid, 0, 0, 0, 0, 0);
}

int WeiOS_welcome(void)
{
	return usyscall(SYS_welcome, 0, 0, 0, 0, 0);
}

int ls(const char *path)
{
	return usyscall(SYS_lsdir, (uint32_t)path, 0, 0, 0, 0);
}

int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5)
{
	int32_t ret;
	asm volatile("int %1\n"
		     : "=a" (ret)
		     : "i" (T_SYSCALL),
		       "a" (syscallno),
		       "d" (a1),
		       "c" (a2),
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	return ret;
}