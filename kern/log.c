#include <include/types.h>
#include <include/param.h>
#include <include/fs.h>
#include <include/log.h>
#include <include/lock.h>
#include <include/stdio.h>
#include <include/buddy.h>
#include <include/string.h>
#include <include/kernel.h>
#include <include/buffer.h>
#include <include/sysfunc.h>
#include <include/kmalloc.h>

struct log_manager log_manager;
extern struct superblock sb;
static struct buf buf_ptrs[LOGSIZE];

void log_init(int dev)
{
    spinlock_init(&log_manager.log_lock, "log_lock");
    //readsb(dev, &sb);
    log_manager.start = sb.log_start;
    log_manager.size = sb.log_blks;
    log_manager.dev = dev;
    LIST_HEAD_INIT(log_manager.procs_waitting);
    for (int i = 0; i < LOGSIZE; i++)
    	if (!(buf_ptrs[i].data = (char *)kmalloc(BLKSIZE, __GFP_ZERO|__GFP_DMA)))
    		panic("log_init(): failed!!!\n");
    recover_from_log();
}

// Copy committed blocks from log to their home location
static void keep_consistent_on_disk(int boot)
{
    struct buf *disk_buf;

    if (boot) {
        struct buf *log_buf;
        for (int i = 0; i < log_manager.lheader.nblks; i++) {
            // read log block
            log_buf = bread(log_manager.dev, log_manager.start + i + 1); 
            // read dst
            disk_buf = bread(log_manager.dev, log_manager.lheader.blks_no[i]);
            memmove(disk_buf->data, log_buf->data, BLKSIZE);
            bwrite(disk_buf);
            brelse(log_buf);
            brelse(disk_buf);
        }
    } else {
        for (int i = 0; i < log_manager.lheader.nblks; i++) {
            disk_buf = bread(log_manager.dev, log_manager.lheader.blks_no[i]); // read dst
            memmove(disk_buf->data, buf_ptrs[i].data, BLKSIZE);
            bwrite(disk_buf);  // write dst to disk
            brelse(disk_buf);
        }
    }
}

// Read the log header into memory from disk. 
// then call brelse to release the block was occupied.
static void read_log_header(void)
{
    struct buf *buf = bread(log_manager.dev, log_manager.start);
    struct log_header *lh_blk = (struct log_header *)(buf->data);

    log_manager.lheader.nblks = lh_blk->nblks;
    for (int i = 0; i < log_manager.lheader.nblks; i++)
        log_manager.lheader.blks_no[i] = lh_blk->blks_no[i];
    
    brelse(buf);
}

// Write in-memory log header to log header in disk.
// At the point that the current transaction was really commited
// But not actually write back to where it must to be -- right position in disk
static void write_log_header(void)
{
  struct buf *buf = bread(log_manager.dev, log_manager.start);
  struct log_header *lh_blk = (struct log_header *)(buf->data);
  
  lh_blk->nblks = log_manager.lheader.nblks;
  for (int i = 0; i < log_manager.lheader.nblks; i++)
      lh_blk->blks_no[i] = log_manager.lheader.blks_no[i];

  bwrite(buf);
  brelse(buf);
}


static void recover_from_log(void)
{
    read_log_header();
    keep_consistent_on_disk(1); // if committed, copy from log to disk
    log_manager.lheader.nblks = 0;
    write_log_header(); // clear the log
}

// called at the start of each FS system call.
void begin_transaction(void)
{
    spin_lock_irqsave(&log_manager.log_lock);
    while(1){
        if(log_manager.committing)
            sleep(&log_manager.procs_waitting, &log_manager.log_lock);
        // i assume that every operation want to transmit max blocks.
        else if(log_manager.lheader.nblks + (log_manager.n_occupiers+1)*MAXOPBLOCKS > LOGSIZE)
            // this op might exhaust log space; wait for commit.
            sleep(&log_manager.procs_waitting, &log_manager.log_lock);
        else {
            log_manager.n_occupiers++;
            spin_unlock_irqrestore(&log_manager.log_lock);
            break;
        }
    }
}

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void end_transaction(void)
{
    int do_commit = 0;

    spin_lock_irqsave(&log_manager.log_lock);
    
    log_manager.n_occupiers--;
    if(log_manager.committing)
        panic("end_transaction: system broken down!!!");

    if(log_manager.n_occupiers == 0){
        do_commit = 1;
        log_manager.committing = 1;
    } else 
        wakeup(&log_manager.procs_waitting, &log_manager.log_lock);
    spin_unlock_irqrestore(&log_manager.log_lock);

    if(do_commit) {
        // call commit w/o holding locks, since not allowed
        // to sleep with locks.
        commit();
        spin_lock_irqsave(&log_manager.log_lock);
        log_manager.committing = 0;
        wakeup(&log_manager.procs_waitting, &log_manager.log_lock);
        spin_unlock_irqrestore(&log_manager.log_lock);
    }
}

// Copy modified block in memory to log space on disk.
// We must keep consistency between log header on disk and in memory. 
static void write_log_blk(void)
{
    struct buf  *to;
    struct buf  *from;

    // Write each modified transaction from 
    // buffer cache in-memory to the log space on-disk.
    for (int i = 0; i < log_manager.lheader.nblks; i++) {
        // the log blocks
        to = bread(log_manager.dev, log_manager.start + i + 1);
        // cache block, There is a great possibility that blk we need in cache.
        // We have only one device in WeiOS.
        from = bread(log_manager.dev, log_manager.lheader.blks_no[i]);
        memmove(to->data, from->data, BLKSIZE);
        from->flag &= (~B_DIRTY);
        from->flag |= B_VALID;
        bwrite(to);  // write the log
        brelse(from);
        brelse(to);
        // We only copy data from cache to log area on disk.
        // Not in the right position it should be.
        // We do this job in function keep_consistent_on_disk()
    	buf_ptrs[i].flag = to->flag;
    	buf_ptrs[i].refcnt = to->refcnt;
    	buf_ptrs[i].dev = to->dev;
    	buf_ptrs[i].blockno = to->blockno;
    	memmove(buf_ptrs[i].data, to->data, BLKSIZE);
    }
}

static void commit()
{
    if (log_manager.lheader.nblks > 0) {
        write_log_blk();       // Write modified blocks from cache to log
        write_log_header();    // Write header to disk -- the real commit
        keep_consistent_on_disk(0);      // Now install writes to home locations
        log_manager.lheader.nblks = 0;
        write_log_header();    // Erase the transaction from the log
    }
}

int log_write(struct buf *b)
{
    int i;

    if (log_manager.lheader.nblks >= LOGSIZE || 
              log_manager.lheader.nblks >= log_manager.size - 1)
        return -1;
    if (log_manager.n_occupiers < 1)
        return -1;

    spin_lock_irqsave(&log_manager.log_lock);
    // log merge, avoiding duplication of labor
    for (i = 0; i < log_manager.lheader.nblks; i++) {
        if (log_manager.lheader.blks_no[i] == b->blockno)
            break;
    }
    log_manager.lheader.blks_no[i] = b->blockno;
    log_manager.lheader.nblks += (i == log_manager.lheader.nblks)?1:0;
    b->flag &= (~B_VALID);
    b->flag |= B_DIRTY; // prevent eviction
    spin_unlock_irqrestore(&log_manager.log_lock);
    return 0;
}