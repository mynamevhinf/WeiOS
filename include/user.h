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
/*
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
*/
#endif