#ifndef _USER_H_
#define _USER_H_

#include <include/types.h>
#include <include/syscall.h>
#include <include/stdarg.h>

#define PGSIZE 4096

// string.h
int strlen(char *s);
int strcmp(const char *str1, const char *str2);
int strncmp(const char *str1, const char *str2, int n);
char *strcpy(char *des, const char *src);
char *strncpy(char *des, const char *src, int n);
char *strcat(char *des, char *src);
char *strchr(char *s, char c);
void *memset(void *s, char ch, size_t n);
void *memmove(void *dst, const void *src, size_t n);
int atoi(const char *s);


//printf.h
char getc(void);
char *gets(char *buf, int max);
char *shell_gets(char *buf, int max);
int printf(int fd, const char *str, ...);

// file.h.
// for flag field
#define O_RDONLY 0x1
#define O_WRONLY 0x2
#define O_RDWR	 0x4
#define O_CREAT	 0x8

#define stdin     0
#define stdout    1
#define stderr    2

#define T_DIR  1   // Directory
#define T_FILE 2   // File
#define T_DEV  3   // Device

struct stat {
  ushort type;  // Type of file
  uint32_t dev;     // File system's disk device
  uint32_t ino;    // Inode number
  ushort nlink; // Number of links to file
  uint32_t size;   // Size of file in bytes
};

/* syscall.h
#define SYS_exit 			1
#define SYS_wait 			2
#define SYS_kill 			3
#define SYS_getpid 			4
#define SYS_getppid 		5
#define SYS_alarm 			6
#define SYS_cancel_alarm 	7
#define SYS_yield			8
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
#define SYS_exec			33
#define SYS_mknod			34
#define SYS_welcome			35
#define SYS_lsdir 			36
*/
#define T_SYSCALL       128

int fork(void);
int exit(void);
void *sbrk(int n);
ushort wait(void);
int kill(pid_t pid);
int exec(char *pathname, char **argv);
int pipe(int fd[2]);
int dup(int fd);
int dup2(int oldfd, int newfd);
int read(int fd, char *des, uint32_t nbytes);
int write(int fd, char *src, uint32_t nbytes);
int close(int fd);
int fstat(int fd, struct stat *sbuf);
int link(char *oldpname, char *newpname);
int unlink(char *pathname);
int open(char *pathname, int flag);
int mknod(char *pathname, ushort major, ushort minor);
int mkdir(char *pathname);
int chdir(char *pathname);
int ipc_try_send(pid_t pid, uint32_t value, void *srcva, int32_t perm);
int ipc_send(pid_t to_proc, uint32_t val, void *pg, int32_t perm);
int ipc_recv(void *pg);
int getpid(void);
int WeiOS_welcome(void);
int ls(const char *path);

int usyscall(uint32_t syscallno, uint32_t a1, 
				uint32_t a2, uint32_t a3, 
				uint32_t a4, uint32_t a5);

// malloc.h
union malloc_header {
	struct {
		union malloc_header *ptr;
		uint32_t size;
	} exist;
	long padding;
};
typedef union malloc_header Header;

void *malloc(size_t nbytes);
void free(void *ptr);

#endif