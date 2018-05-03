#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <assert.h>

#define stat WeiOS_stat  // avoid clash with host struct stat
#include "mkfs.h"

#ifndef static_assert
#define static_assert(a, b) do { switch (0) case 0: case (a): ; } while (0)
#endif

#define NINODES 200

// Disk layout:
// [ boot block | sb block | log | inode blocks | free bit map | data blocks ]

int nbitmap = FSSIZE/(BLKSIZE*8) + 1;
int ninodeblocks = NINODES / IPB + 1;
int nlog = LOGSIZE;
int nmeta;    // Number of meta blocks (boot, sb, nlog, inode, bitmap)
int nblocks;  // Number of data blocks

int fsfd;
struct superblock sb;
char zeroes[BLKSIZE];
uint freeinode = 1;
uint freeblock;


void balloc(int);
void wsect(uint sec, void *buf);
void winode(uint inum, struct d_inode *ip);
void rinode(uint inum, struct d_inode *ip);
void rsect(uint sec, void *buf);
uint ialloc(ushort type);
void iappend(uint inum, void *p, int n);

// convert to intel byte order
ushort xshort(ushort x)
{
    ushort y;
    uchar *a = (uchar*)&y;
    a[0] = x;
    a[1] = x >> 8;
    return y;
}

uint xint(uint x)
{
    uint y;
    uchar *a = (uchar *)&y;
    a[0] = x;
    a[1] = x >> 8;
    a[2] = x >> 16;
    a[3] = x >> 24;
    return y;
}

int main(int argc, char *argv[])
{
    int i, cc, fd;
    uint rootino, inum, off;
    struct dirent de;
    char buf[BLKSIZE];
    struct d_inode din;

    fsfd = open(argv[1], O_RDWR|O_CREAT|O_TRUNC, 0666);
    if(fsfd < 0){
        perror(argv[1]);
        exit(1);
    }

    // 1 fs block = 1 disk sector
    nmeta = 2 + nlog + ninodeblocks + nbitmap;
    nblocks = FSSIZE - nmeta;

    sb.size = xint(FSSIZE);
    sb.data_blks = xint(nblocks);
    sb.inode_blks = xint(NINODES);
    sb.log_blks = xint(nlog);
    sb.log_start = xint(2);
    sb.inode_start = xint(2+nlog);
    sb.bitmap_start = xint(2+nlog+ninodeblocks);

    printf("size = %u, data_blks = %u, inode_blks = %u, log_blks = %u\n" 
            "log_start = %u, inode_start = %u, bitmap_start = %u\n", 
            sb.size, sb.data_blks, sb.inode_blks, sb.log_blks, sb.log_start,
            sb.inode_start, sb.bitmap_start);

    printf("nmeta %d (boot, super, log blocks %u inode blocks %u, bitmap blocks %u) blocks %d total %d\n",
           nmeta, nlog, ninodeblocks, nbitmap, nblocks, FSSIZE);

    freeblock = nmeta;     // the first free block that we can allocate

    for(i = 0; i < FSSIZE; i++)
        wsect(i, zeroes);

    memset(buf, 0, sizeof(buf));
    memmove(buf, &sb, sizeof(sb));
    wsect(1, buf);

    rootino = ialloc(T_DIR);
    assert(rootino == ROOTINO);

    bzero(&de, sizeof(de));
    de.ino = xshort(rootino);
    strcpy(de.name, ".");
    iappend(rootino, &de, sizeof(de));

    bzero(&de, sizeof(de));
    de.ino = xshort(rootino);
    strcpy(de.name, "..");
    iappend(rootino, &de, sizeof(de));

    for(i = 2; i < argc; i++){
        assert(index(argv[i], '/') == 0);

        if ((fd = open(argv[i], 0)) < 0) {
            perror(argv[i]);
            exit(1);
        }

        // Skip leading _ in name when writing to file system.
        // The binaries are named _rm, _cat, etc. to keep the
        // build operating system from trying to execute them
        // in place of system binaries like rm and cat.
        if(argv[i][0] == '_')
            ++argv[i];

        inum = ialloc(T_FILE);

        bzero(&de, sizeof(de));
        de.ino = xshort(inum);
        strncpy(de.name, argv[i], DIRSIZ);
        iappend(rootino, &de, sizeof(de));

        while((cc = read(fd, buf, sizeof(buf))) > 0)
            iappend(inum, buf, cc);

        close(fd);
    }

    // fix size of root inode dir
    rinode(rootino, &din);
    off = xint(din.file_siz);
    off = ((off/BLKSIZE) + 1) * BLKSIZE;
    din.file_siz = xint(off);
    printf("\nrootino = %d, din.file_siz = %d\n\n", rootino, din.file_siz);
    winode(rootino, &din);

    balloc(freeblock);
    printf("Oh yeah! file system is OK!!!\n");
    exit(0);
}

// write the block with buf[BLKSIZE]
void wsect(uint sec, void *buf)
{
    if(lseek(fsfd, sec * BLKSIZE, 0) != sec * BLKSIZE) {
        perror("lseek");
        exit(1);
    }
    if(write(fsfd, buf, BLKSIZE) != BLKSIZE){
        perror("write");
        exit(1);
    }
}

void winode(uint inum, struct d_inode *ip)
{
    char buf[BLKSIZE];
    uint bn;
    struct d_inode *dip;

    bn = IBLOCK(inum, sb);
    rsect(bn, buf);
    dip = ((struct d_inode*)buf) + (inum % IPB);
    *dip = *ip;
    wsect(bn, buf);
}

void
rinode(uint inum, struct d_inode *ip)
{
    char buf[BLKSIZE];
    uint bn;
    struct d_inode *dip;

    bn = IBLOCK(inum, sb);
    rsect(bn, buf);
    dip = ((struct d_inode*)buf) + (inum % IPB);
    *ip = *dip;
}

void rsect(uint sec, void *buf)
{
    if(lseek(fsfd, sec * BLKSIZE, 0) != sec * BLKSIZE){
        perror("lseek");
        exit(1);
    }
    if(read(fsfd, buf, BLKSIZE) != BLKSIZE){
        perror("read");
        exit(1);
    }
}

uint ialloc(ushort type)
{
    uint inum = freeinode++;
    struct d_inode din;

    bzero(&din, sizeof(din));
    din.type = xshort(type);
    din.nlink = xshort(1);
    din.file_siz = xint(0);
    winode(inum, &din);
    return inum;
}

void balloc(int used)
{
    uchar buf[BLKSIZE];
    int i;

    printf("balloc: first %d blocks have been allocated\n", used);
    assert(used < BLKSIZE*8);
    bzero(buf, BLKSIZE);
    for(i = 0; i < used; i++){
        buf[i/8] = buf[i/8] | (0x1 << (i%8));
    }
    printf("balloc: write bitmap block at sector %d\n", sb.bitmap_start);
    wsect(sb.bitmap_start, buf);
}

#define min(a, b) ((a) < (b) ? (a) : (b))

void iappend(uint inum, void *xp, int n)
{
    char *p = (char*)xp;
    uint fbn, off, n1;
    struct d_inode din;
    char buf[BLKSIZE];
    uint indirect[NINDIRECT];
    uint x;

    rinode(inum, &din);
    off = xint(din.file_siz);

    while(n > 0){
        fbn = off / BLKSIZE;
        assert(fbn < MAXFILE);
        if(fbn < NDIRECT){
            if(xint(din.blk_addrs[fbn]) == 0)
                din.blk_addrs[fbn] = xint(freeblock++);
            x = xint(din.blk_addrs[fbn]);
        } else {
            if(xint(din.blk_addrs[NDIRECT]) == 0)
                din.blk_addrs[NDIRECT] = xint(freeblock++);
            rsect(xint(din.blk_addrs[NDIRECT]), (char*)indirect);
            if(indirect[fbn - NDIRECT] == 0){
                indirect[fbn - NDIRECT] = xint(freeblock++);
                wsect(xint(din.blk_addrs[NDIRECT]), (char*)indirect);
            }
            x = xint(indirect[fbn-NDIRECT]);
        }
        n1 = min(n, (fbn + 1) * BLKSIZE - off);
        rsect(x, buf);
        bcopy(p, buf + off - (fbn * BLKSIZE), n1);
        wsect(x, buf);
        n -= n1;
        off += n1;
        p += n1;
    }
    din.file_siz = xint(off);
    winode(inum, &din);
}
