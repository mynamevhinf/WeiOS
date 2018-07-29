#ifndef _PARAM_H_
#define _PARAM_H_

#define NPROCS       1024  // maximum number of processes
#define N_PRIORITY   40  // maximum priority
#define NCPU         1   // maximum number of CPUs
#define NOFILE       16  // open files per process
#define NFILE        200  // open files per system
#define NINODE       60  // maximum number of active i-nodes
#define NDEV         10  // maximum major device number
#define ROOTDEV       1  // device number of file system root disk
#define ROOTINO		  1	 // inode number of the root directory '/'
#define MAXARG       32  // max exec arguments
#define MAXOPBLOCKS  40  // max # of blocks any FS op writes
#define LOGSIZE      (MAXOPBLOCKS*3)  // max data blocks in on-disk log
#define NBUF         (MAXOPBLOCKS*3)  // size of disk block cache
#define FSSIZE		 5000 // size of file system in blocks
#define SMALLSECTOR  0

#if (SMALLSECTOR == 1)
#define BLKSIZE 512 
#else
#define BLKSIZE 4096
#endif

#endif
