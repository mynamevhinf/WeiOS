#ifndef _FS_H_
#define _FS_H_

#include <include/types.h>

struct superblock {
	uint32_t size; //size of file system (in blocks)
	uint32_t data_blks;	// number of data blocks
	uint32_t inode_blks; // number of inode blocks
	uint32_t log_blks;	// number of log blocks;
	uint32_t log_start;	// block number where log block starts.
	uint32_t inode_start;	// block number where inode block starts.
	uint32_t bitmap_start;	// block number where bitmap block starts.
};

void read_superblock(uint32_t dev, struct superblock *sb);

#define NDIRECT 11
#define NINDIRECT (BLKSIZE/sizeof(uint32_t))
#define NDINDIRECT (NINDIRECT * NINDIRECT)
#define MAXFILE (NDIRECT + NINDIRECT + NDINDIRECT)
#define MAXFILESIZ	(MAXFILE*BLKSIZE)

struct d_inode {
	ushort type;
	ushort major;	// major device number
	ushort minor;	// minor device number
	ushort nlink;	// numbers of links to inode in file system
	uint32_t file_siz;	// size of file (in bytes)
	uint32_t blk_addrs[NDIRECT+2];
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

#endif
