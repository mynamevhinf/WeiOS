#ifndef _FILE_H_
#define _FILE_H_

#ifndef __ASSEMBLER__

#include <include/fs.h>
#include <include/lock.h>
#include <include/types.h>
#include <include/kernel.h>

#define PIPESIZE 512

struct file;

// nread and nwrite increments until the limit -- 0x7FFFFFFF, it is enough
struct pipe {
  char 	   *data;
  uint32_t 	nread;     // number of bytes read
  uint32_t  nwrite;    // number of bytes written
  int32_t   readopen;   // read fd is still open
  int32_t   writeopen;  // write fd is still open
  struct spinlock pipe_lock;
  struct list_head wait_to_read;	// waitting for to read
  struct list_head wait_to_write;	// waitting for to write.
};

int pipe_alloc(struct file **f1, struct file **f2);
void pipe_close(struct pipe *p, int writend);
int pipe_read(struct pipe *p, char *dst, int nbytes);
int pipe_write(struct pipe *p, char *src, int nbytes);

// in-memory copy of an disk struct dinode
struct inode {
	uint32_t  dev;
	uint32_t  ino;
	uint32_t  ref;
	uint32_t  valid;	// inode has been read from disk?
	struct sleeplock inode_slk;

	ushort type;
	ushort major;	// major device number
	ushort minor;	// minor device number
	ushort nlink;	// numbers of links to inode in file system
	uint32_t file_siz;	// size of file (in bytes)
	uint32_t blk_addrs[NDIRECT+2];
	struct list_head hash_node;
	struct list_head free_list_node;
};
// functions about inode.
void inode_init(void);
struct inode* ialloc(uint32_t dev, ushort type);
int ilock(struct inode *i);
int iunlock(struct inode *i);
void iupdate(struct inode *i);
void iput(struct inode *i);
void iunlockput(struct inode *i);
struct inode *iref(struct inode *i);
int readi(struct inode *i, char *dst, uint32_t offset, uint32_t nbytes);
int writei(struct inode *i, char *src, uint32_t offset, uint32_t nbytes);
int dirlookup(struct inode *diri, char *name, struct inode **istore, int *offset);
int dirlink(struct inode *di, char *name, uint32_t ino);
struct inode *namei(char *path);
struct inode *namep(char *path, char *name);

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
// functions
void stati(struct inode *i, struct stat *st);


// for flag field
#define O_RDONLY 0x1
#define O_WRONLY 0x2
#define O_RDWR	 0x4
#define O_CREAT	 0x8

#define FS_NONE			0x0
#define FS_DIRECTORY	0x1
#define FS_FILE			0x2
#define FS_CHARDEV		0x3
#define FS_BLOCKDEV		0x4
#define FS_PIPE			0x5
#define FS_SYMLINK		0x6
#define FS_MOUNTPOINT	0x7

struct file {
	int32_t type;
	int32_t ref;
	uint32_t offset;
	ushort flag;
	struct pipe *pipe;
	struct inode *inode;
	struct list_head flist_node;
};

void ftable_init(void);
struct file *file_alloc(void);
struct file *file_dup(struct file *f);
void file_close(struct file *f);
int file_stat(struct file *f, struct stat *st);
int file_read(struct file *f, char *dst, int nbytes);
int file_write(struct file *f, char *src, int nbytes);


// dev_struct -- an abstract struture for dev operations.
struct dev_struct {
  int (*read)(struct inode *, char *, int);
  int (*write)(struct inode *, const char *, int);
};

#define CONSOLE 1

#endif

#endif
