//include/type.h
typedef unsigned int   uint;
typedef unsigned short ushort;
typedef unsigned char  uchar;
typedef uint pde_t;

#include "../include/param.h"
/*
#define NPROCS       1024  // maximum number of processes
#define N_PRIORITY   40  // maximum priority
#define NCPU         1   // maximum number of CPUs
#define NOFILE       16  // open files per process
#define NFILE       200  // open files per system
#define NINODE       60  // maximum number of active i-nodes
#define NDEV         10  // maximum major device number
#define ROOTDEV       1  // device number of file system root disk
#define ROOTINO		  1	 // inode number of the root directory '/'
#define MAXARG       32  // max exec arguments
#define MAXOPBLOCKS  40  // max # of blocks any FS op writes
#define LOGSIZE      (MAXOPBLOCKS*3)  // max data blocks in on-disk log
#define NBUF         (MAXOPBLOCKS*3)  // size of disk block cache
#define FSSIZE		 40000 // size of file system in blocks
*/

//include/fs.h
#if (SMALLSECTOR == 1)
#define BLKSIZE 512 
#else
#define BLKSIZE 4096
#endif

struct superblock {
	uint size; //size of file system (in blocks)
	uint data_blks;	// number of data blocks
	uint inode_blks; // number of inode blocks
	uint log_blks;	// number of log blocks;
	uint log_start;	// block number where log block starts.
	uint inode_start;	// block number where inode block starts.
	uint bitmap_start;	// block number where bitmap block starts.
};

#define NDIRECT 11
#define NINDIRECT (BLKSIZE/sizeof(uint))
#define NDINDIRECT (NINDIRECT * NINDIRECT)
#define MAXFILE (NDIRECT + NINDIRECT + NDINDIRECT)
#define MAXFILESIZ	(MAXFILE*BLKSIZE)

struct d_inode {
	ushort type;
	ushort major;	// major device number
	ushort minor;	// minor device number
	ushort nlink;	// numbers of links to inode in file system
	uint file_siz;	// size of file (in bytes)
	uint blk_addrs[NDIRECT+2];
};

// Inodes per block
#define IPB					(BLKSIZE / sizeof(struct d_inode))
#define IBLOCK(ino, sb)  	((ino) / IPB + sb.inode_start)

// Bitmap bits per block
#define BITPB				(BLKSIZE * 8)		
#define BITBLOCK(b, sb)		(b/BITPB + sb.bitmap_start)

// The same as unix.
#define DIRSIZ 14

struct dirent {
	ushort ino;
	char name[DIRSIZ];
};

// include/file.h
#define T_DIR  1   // Directory
#define T_FILE 2   // File
#define T_DEV  3   // Device

struct stat {
  ushort type;  // Type of file
  uint dev;     // File system's disk device
  uint ino;    // Inode number
  ushort nlink; // Number of links to file
  uint size;   // Size of file in bytes
};
