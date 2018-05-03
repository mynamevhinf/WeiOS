#include <include/types.h>
#include <include/param.h>
#include <include/fs.h>
#include <include/log.h>
#include <include/proc.h>
#include <include/lock.h>
#include <include/file.h>
#include <include/error.h>
#include <include/stdio.h>
#include <include/buddy.h>
#include <include/buffer.h>
#include <include/string.h>
#include <include/kmalloc.h>
#include <include/sysfunc.h>

extern struct superblock sb;
extern struct dev_struct dev_structs[];

#define min(a, b) (((a)<(b))?(a):(b))

struct {
	struct spinlock  icache_lock;
	struct list_head free_list_head;
	struct list_head hash_table[HASHSLOT];
} icache;

/**********************************************
 *
 *  i use icache.icache_lock to protect i->ref
 *  inode->inode_slk to protect single inode.  
 *
 *********************************************/
void inode_init(void)
{
	struct inode *i;

	spinlock_init(&icache.icache_lock, "icache_lock");
	LIST_HEAD_INIT(icache.free_list_head);
	for (int i = 0; i < HASHSLOT; i++) {
		icache.hash_table[i].next = &(icache.hash_table[i]);
		icache.hash_table[i].prev = &(icache.hash_table[i]);
	}

	for (int j = 0; j < NINODE; j++) {
		if (!(i = (struct inode *)kmalloc(sizeof(struct inode), __GFP_ZERO)))
			panic("inode_init() failed!!!\n");
        sleeplock_init(&i->inode_slk, "inode_slk");
		list_add(&i->free_list_node, &icache.free_list_head);
	}
    read_superblock(ROOTDEV, &sb);
    //prink("data_blks = %u, inode_blks = %u, log_blks = %u\n", 
    //                    sb.data_blks, sb.inode_blks, sb.log_blks);
    //prink("log_start = %u, inode_start = %u, Bitmap_start = %u\n", 
    //                    sb.log_start, sb.inode_start, sb.bitmap_start);
}

static inline int icache_hash_func(uint32_t dev, uint32_t ino)
{
	return (dev*5+ino) % HASHSLOT;
}

static struct inode *find_inode_in_hash(uint32_t dev, uint32_t ino)
{
	int slot;
	struct inode *i;
	struct list_head *list_head;
	struct list_head *list_node;

	slot = icache_hash_func(dev, ino);
	list_head = &(icache.hash_table[slot]);
	list_node = list_head->next;
	while (list_node != list_head) {
		i = list_entry(list_node, struct inode, hash_node);
		if ((i->dev == dev) && (i->ino == ino))
			return i;
		list_node = list_node->next;
	}
	
    return 0;
}

static void put_inode_in_hash(struct inode *i)
{
	int slot;

	slot = icache_hash_func(i->dev, i->ino);
	list_add_tail(&i->hash_node, &(icache.hash_table[slot]));
}

// I divide traditional iget() into two functions iget() and ilock().
static struct inode *iget(uint32_t dev, uint32_t ino)
{
    struct inode *i;
    struct d_inode *di;

    while (1) {
        spin_lock_irqsave(&icache.icache_lock);
        i = find_inode_in_hash(dev, ino);
        if (i && (i->ref > 0)) {
            // check if the inode is in free list or not.
            if (i->free_list_node.next)
                list_del(&i->free_list_node);
            i->ref++;
            spin_unlock_irqrestore(&icache.icache_lock);
            return i;
        }

        if (list_empty(&icache.free_list_head)) 
            return 0;
        // remove a new inode from free list.
        i = list_entry(icache.free_list_head.next, struct inode, free_list_node);
        list_del(&i->free_list_node);
        // reset inode number and file system
        i->ref = 1;
        i->dev = dev;
        i->ino = ino;
        i->valid = 0;
        if (i->hash_node.next)
            list_del(&i->hash_node);
        put_inode_in_hash(i);
        // We must to free the lock to make system more efficiently.
        spin_unlock_irqrestore(&icache.icache_lock);
        return i;
    }
}

struct inode* ialloc(uint32_t dev, ushort type)
{
    struct buf *b;
    struct d_inode *di;

    for(int ino = 1; ino < sb.inode_blks; ino++){
        b = bread(dev, IBLOCK(ino, sb));
        di = (struct d_inode*)b->data + (ino % IPB);
        if(di->type == 0){  // free
            memset(di, 0, sizeof(struct d_inode));
            di->type = type;
            log_write(b);
            brelse(b);
            return iget(dev, ino);
        }
        brelse(b);
    }
    return 0;
}

int ilock(struct inode *i)
{
    int off;
    int blkno;
    struct buf *b;    
    struct d_inode *di;

    if (!i || i->ref < 1)
        return -1;

    sleep_lock(&i->inode_slk);
    if (i->ref < 1) {
    	sleep_unlock(&i->inode_slk);
    	panic("ilock die1!!!\n");
    }

    if (i->valid == 0) {
        b = bread(i->dev, IBLOCK(i->ino, sb));
        di = (struct d_inode *)b->data + (i->ino % IPB);
        i->type = di->type;
        i->major = di->major;
        i->minor = di->minor;
        i->nlink = di->nlink;
        i->file_siz = di->file_siz;
        memmove(i->blk_addrs, di->blk_addrs, sizeof(i->blk_addrs));
        brelse(b);
        if (i->type == 0) {
        	spin_lock_irqsave(&icache.icache_lock);
        	i->ref = 0;
        	list_del(&i->hash_node);
        	//list_add_tail(&i->free_list_node, &icache.free_list_head);
        	spin_unlock_irqrestore(&icache.icache_lock);
        	sleep_unlock(&i->inode_slk);
        	panic("ilock die2!!!\n");
        }
        i->valid = 1;
    }
    return 0;
}

// improves performence
int iunlock(struct inode *i)
{
    if (!i || !holding_sleeplock(&i->inode_slk) || (i->ref < 1))
        return -1;
    sleep_unlock(&i->inode_slk);
    return 0;
}

void iupdate(struct inode *i)
{
    struct buf *b;
    struct d_inode *di;

    b = bread(i->dev, IBLOCK(i->ino, sb));       
    di = (struct d_inode *)b->data + (i->ino % IPB);
    di->type = i->type;
    di->major = i->major;
    di->minor = i->minor;
    di->nlink = i->nlink;
    di->file_siz = i->file_siz;
    memmove(di->blk_addrs, i->blk_addrs, sizeof(i->blk_addrs));
    log_write(b);
    brelse(b);
}

// Truncate inode -- delete all contents the inode points.
// set i->file_siz = 0;
static void ifree(struct inode *i)
{
    struct buf *b;
    struct buf *b2;
    uint32_t *entry, *entry2;

    // bfree may block.
    for (int j = 0; j < NDIRECT; j++) {
        if (i->blk_addrs[j]) {
            bfree(i->dev, i->blk_addrs[j]);
            i->blk_addrs[j] = 0;
        }
    }

    if (i->blk_addrs[NDIRECT]) {
        b = bread(i->dev, i->blk_addrs[NDIRECT]);
        entry = (uint32_t *)(b->data);
        for(int j = 0; j < NINDIRECT; j++) {
            if (entry[j])
                bfree(i->dev, entry[j]);
        }
        brelse(b);
        bfree(i->dev, i->blk_addrs[NDIRECT]);
        i->blk_addrs[NDIRECT] = 0;
    }

    if (i->blk_addrs[NDIRECT+1]) {
        b2 = bread(i->dev, i->blk_addrs[NDIRECT+1]);
        entry2 = (uint32_t *)(b2->data);
        for (int j = 0; j < NINDIRECT; j++) {
            if (entry2[j] == 0)
                continue;
            b = bread(i->dev, entry2[j]);
            entry = (uint32_t *)(b->data);
            for (int z = 0; z < NINDIRECT; z++) {
                if (entry[z])
                    bfree(i->dev, entry[z]);
            }
            brelse(b);
            bfree(i->dev, entry2[j]);
            entry2[j] = 0;   
        }
        brelse(b2);
        bfree(i->dev, i->blk_addrs[NDIRECT+1]);
        i->blk_addrs[NDIRECT+1] = 0;
    }
    i->file_siz = 0;
    iupdate(i);
}

void iput(struct inode *i)
{
	int ref;

    sleep_lock(&i->inode_slk);
    if (i->valid && (i->nlink == 0)) {
    	spin_lock_irqsave(&icache.icache_lock);
    	ref = i->ref;
    	spin_unlock_irqrestore(&icache.icache_lock);
    	if (ref == 1) {
    		ifree(i);
	        i->type = 0;
	        iupdate(i);
	        i->valid = 0;
    	}
    }  
    spin_lock_irqsave(&icache.icache_lock);
    if ((i->ref -= 1) == 0)
    	list_add_tail(&i->free_list_node, &icache.free_list_head); 
    spin_unlock_irqrestore(&icache.icache_lock);

    sleep_unlock(&i->inode_slk);
}

void iunlockput(struct inode *i)
{
    if (iunlock(i) == 0)
        iput(i);
}

struct inode *iref(struct inode *i)
{
    spin_lock_irqsave(&icache.icache_lock);
    i->ref++;
    spin_unlock_irqrestore(&icache.icache_lock);
    return i;
}

// Tanslate logical block number to Actual block number in disk
static uint32_t bmap(struct inode *i, uint32_t lblkno)
{
    uint32_t    n, r;
    uint32_t    addr;
    uint32_t   *entries;
    struct buf *b;

    if (lblkno < NDIRECT) {
        if ((addr = i->blk_addrs[lblkno]) == 0) {
            if (!(addr = balloc(i->dev)))
                return 0;
            i->blk_addrs[lblkno] = addr;
        }
        return addr;
    } 

    lblkno -= NDIRECT;
    if (lblkno < NINDIRECT) {
        if (!(addr = i->blk_addrs[NDIRECT])) {
            if (!(addr = balloc(i->dev)))
                return 0;
            i->blk_addrs[NDIRECT] = addr;
        }
        b = bread(i->dev, i->blk_addrs[NDIRECT]);
        entries = (uint32_t *)(b->data);
        if (!(addr = entries[lblkno])) {
            if (!(addr = balloc(i->dev)))
                return 0;
            entries[lblkno] = addr;
            log_write(b);
        }
        brelse(b);
        return addr;
    }

    lblkno -= NINDIRECT;
    if (lblkno < NDINDIRECT) {
        n = lblkno / NINDIRECT;
        r = lblkno % NINDIRECT;
        if (!(addr = i->blk_addrs[NDIRECT+1])) {
            if (!(addr = balloc(i->dev)))
                return 0;
            i->blk_addrs[NDIRECT+1] = addr;
        }
        b = bread(i->dev, i->blk_addrs[NDIRECT+1]);
        entries = (uint32_t *)(b->data);
        if (!(entries[n])) {
            if (!(entries[n] = balloc(i->dev)))
                return 0;
            log_write(b);
        }
        addr = entries[n];
        brelse(b);

        b = bread(i->dev, addr);
        entries = (uint32_t *)(b->data);
        if (!(addr = entries[r-1])) {
            if (!(addr = balloc(i->dev)))
                return 0;
            entries[r-1] = addr;
            log_write(b);
        }
        brelse(b);
        return addr;
    }

    prink("Bitmap: file'size is out of limit\n");
    return 0;
}

int readi(struct inode *i, char *dst, uint32_t offset, uint32_t nbytes)
{
    int total;
    struct buf *b;
    uint32_t rdbytes;

    if (i->type == T_DEV) {
        if (i->major < 0 || i->major >= NDEV || !(dev_structs[i->major].read))
            return -E_BAD_DEV;
        return dev_structs[i->major].read(i, dst, nbytes);
    }

    if ((offset > i->file_siz) || (offset + nbytes < offset))
        return -E_BAD_OFFSET;
    if (offset + nbytes > i->file_siz)
        nbytes = i->file_siz - offset;

    for (total=0; total<nbytes; total+=rdbytes, offset+=rdbytes, dst+=rdbytes){
        b = bread(i->dev, bmap(i, offset / BLKSIZE));
        // yeah, we have to decide how bytes we have to read.
        rdbytes = min(nbytes-total, BLKSIZE - offset%BLKSIZE);
        memmove(dst, b->data + offset % BLKSIZE, rdbytes);
        brelse(b);
    }
    return nbytes;
}

// write data in src to disk.
int writei(struct inode *i, char *src, uint32_t offset, uint32_t nbytes)
{ 
    int total;
    struct buf *b;
    uint32_t wrbytes;

    if (i->type == T_DEV) {
        if (i->major < 0 || i->major >= NDEV || !(dev_structs[i->major].write))
            return -E_BAD_DEV;
        return dev_structs[i->major].write(i, src, nbytes);
    }
    // too many data. i only allow to extend file starts at the end.
    if ((offset > i->file_siz) || (offset + nbytes < offset))
        return -E_BAD_OFFSET;
    if (offset + nbytes > MAXFILESIZ)
        nbytes = MAXFILESIZ - offset;

    for(total=0; total<nbytes; total+=wrbytes, offset+=wrbytes, src+=wrbytes){
        b = bread(i->dev, bmap(i, offset / BLKSIZE));
        wrbytes = min(nbytes - total, BLKSIZE - (offset % BLKSIZE));
        memmove(b->data + offset % BLKSIZE, src, wrbytes);
        // Not delayed.
        log_write(b);
        brelse(b);
    }

    if (offset > i->file_siz) {
        i->file_siz = offset;
        iupdate(i);
    }
    return nbytes;
}

// get the direntry's inode.
int dirlookup(struct inode *diri, char *name, struct inode **istore, int *offset)
{
    int r, ssize;
    struct inode *ip;
    struct dirent direntry;

    if (diri->type != T_DIR)
        return -E_BAD_PATH;

    ssize = sizeof(struct dirent);
    for (int i = 0; i < diri->file_siz; i += ssize) {
        if ((r = readi(diri, (char *)&direntry, i, ssize)) != ssize) 
            return r;

        // means this entry is free.
        if (direntry.ino == 0)
            continue;
        //prink("direntry.name = %s, off = %d\n", direntry.name, i);
        if (strncmp(direntry.name, name, DIRSIZ) == 0) {
            ip = iget(diri->dev, direntry.ino);
            *istore = ip;
            if (offset)
                *offset = i;
            return 0;
        }
    }
    return -E_FILE_EXISTS;
}

// Write a new directory entry (name, inum) into the directory dp.
int dirlink(struct inode *di, char *name, uint32_t ino)
{
    uint32_t off;
    int struct_size;
    struct inode *i;
    struct dirent direntry;

    // check if that name is already in the directory.
    //dirlookup(di, name, &i, 0);
    if (dirlookup(di, name, &i, 0) == 0) {
        iput(i);
        return -1;
    }

    struct_size = sizeof(struct dirent);
    for (off = 0; off < di->file_siz; off += struct_size) {
        if (readi(di, (char *)&direntry, off, struct_size) != struct_size)
            panic("dirlink: Failed to readi!!!\n");
        if (direntry.ino == 0)
            break;
    }
    direntry.ino = ino;
    strncpy(direntry.name, name, DIRSIZ);
    // i think it is not a vital error!!!
    if (writei(di, (char *)&direntry, off, struct_size) != struct_size)
        panic("dirlink: Failed to writei!!!");
    return 0;
}

static struct inode *namex(char *path, int nameiparent, char *name)
{
    char *start, *end;
    struct inode *curi, *next;

    if (*path == '/') {
        curi = iget(ROOTDEV, ROOTINO);
        if (strlen(path) == 1)
            return curi;
        start = path + 1;
    } else {
        curi = iref(curproc->pwd);
        start = path;
    }

    while (1) {
        ilock(curi);
        end = start;
        while (*end != '/' && *end != '\0')
            end++;
        strncpy(name, start, end - start);
        // return the last directory's inode but
        // the name of the last element. for example
        // '.../etc/profile', curi = I(etc), name = "profile"
        if (*end == '\0' && nameiparent) {
            iunlock(curi);
            return curi;            
        }
        if (dirlookup(curi, name, &next, 0) < 0) {
            iunlockput(curi);
            return 0;
        }
        iunlockput(curi);
        curi = next;
        if (*end)
            start = end + 1;
        if (*end == '\0' || *start == '\0')
            return curi;
    }
}

// translate pathname to inode pointer.
struct inode *namei(char *path)
{
    char name[DIRSIZ];
    return namex(path, 0, name);
}

struct inode *namep(char *path, char *name)
{
    return namex(path, 1, name);
}

void stati(struct inode *i, struct stat *st)
{
    if (!i)
        return;
    st->dev = i->dev;
    st->ino = i->ino;
    st->size = i->file_siz;
    st->type = i->type;
    st->nlink = i->nlink;
}