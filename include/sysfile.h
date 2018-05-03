#ifndef _SYSFILE_H_
#define _SYSFILE_H_

#ifndef __ASSEMBLER__

#include <include/types.h>
#include <include/fs.h>
#include <include/file.h>

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
int ls_test(const char *str);

#endif

#endif