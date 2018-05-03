#include <include/types.h>
#include <include/param.h>
#include <include/fs.h>
#include <include/ide.h>
#include <include/log.h>
#include <include/lock.h>
#include <include/proc.h>
#include <include/buddy.h>
#include <include/stdio.h>
#include <include/string.h>
#include <include/kernel.h>
#include <include/buffer.h>
#include <include/kmalloc.h>
#include <include/sysfunc.h>

extern struct superblock sb;
static struct blk_cache bcache;

// Some functions
static inline int hash_func(uint32_t dev, uint32_t blockno)
{
	return (dev*5+blockno) % HASHSLOT;
}

void buffer_init(void)
{
	struct buf *b;

	spinlock_init(&bcache.blk_cache_lk, "bcache_lock");
	LIST_HEAD_INIT(bcache.free_list_head);
	LIST_HEAD_INIT(bcache.waiting_proc_list);
	for (int i = 0; i < HASHSLOT; i++) {
		bcache.hash_table[i].next = &(bcache.hash_table[i]);
		bcache.hash_table[i].prev = &(bcache.hash_table[i]);
	}

	// Alloc enough space for block cache
	for (int j = 0; j < NBUF; j++) {
		if (!(b = (struct buf *)kmalloc(sizeof(struct buf), __GFP_ZERO)))
			panic("buffer_init() failed!!!\n");
		if (!(b->data = (char *)kmalloc(BLKSIZE, __GFP_ZERO | __GFP_DMA)))
			panic("buffer_init() failed!!!\n");
		LIST_HEAD_INIT(b->waiting_for_io);
		LIST_HEAD_INIT(b->waiting_proc_list);
		list_add(&b->free_list_node, &bcache.free_list_head);
	}
}

struct buf *getblk(uint32_t dev, uint32_t blockno)
{
	struct buf *b;
	struct list_head *list_node;

	while (1) {
		spin_lock_irqsave(&bcache.blk_cache_lk);
		if ((b = find_blk_in_hash(dev, blockno))) {
			if (b->flag & B_BUSY) {
				sleep(&b->waiting_proc_list, &bcache.blk_cache_lk);
				spin_unlock_irqrestore(&bcache.blk_cache_lk);
				continue;
			}
			b->flag |= B_BUSY;
			b->owner = curproc;
			// i assume that every blocks in the hash table has
			// been used by other processes, otherwise, it must
			// be in the free_list waitting around.
			if (b->free_list_node.next)
				list_del(&b->free_list_node);
			spin_unlock_irqrestore(&bcache.blk_cache_lk);
			return b;
		} else {
			if (list_empty(&bcache.free_list_head)) {
				sleep(&bcache.waiting_proc_list, &bcache.blk_cache_lk);
				spin_unlock_irqrestore(&bcache.blk_cache_lk);
				continue;				
			}
			// remove buffer from free list;
			list_node = bcache.free_list_head.next;
			b = list_entry(list_node, struct buf, free_list_node);
			// remove it from freelist, in this way, others can not
			// alloc it any more.
			list_del(&b->free_list_node);
			// remove buffer from old hash queue
			// the process who requist the same block can not accss such block.
			// yeah, it reduce the effciency. 
			if (b->hash_node.next)
				list_del(&b->hash_node);
			b->flag |= B_BUSY;
			b->owner = curproc;
			//if ((b->flag & (B_VALID | B_DIRTY)) == B_DIRTY) {
				// it may block.
			//	spin_unlock_irqrestore(&bcache.blk_cache_lk);
			//	ide_read_write(b);
			//	spin_lock_irqsave(&bcache.blk_cache_lk);
			//}
			b->dev = dev;
			b->blockno = blockno;
			b->flag &= (~B_VALID);
			put_blk_in_hash(b);
			spin_unlock_irqrestore(&bcache.blk_cache_lk);
			return b;
		}
	}
}

struct buf *bread(uint32_t dev, uint32_t blkno)
{
	struct buf *b;

	b = getblk(dev, blkno);
	if (b->flag & B_VALID) 
		return b;
	ide_read_write(b);
	return b;
}

// i think the function is useless.
// in fact, most files are  decentralized across disk.
struct buf *breada(uint32_t dev, uint32_t blkno)
{
	struct buf *b1, *b2;

	if (!(b1 = find_blk_in_hash(dev, blkno)))
		b1 = bread(dev, blkno);
	if (!(b2 = find_blk_in_hash(dev, blkno+1))) {
		b2 = getblk(dev, blkno+1);
		if (b2->flag & B_VALID)
			brelse(b2);
		else
			ide_read_write(b2);
	}
	// if first block is originally in cache.
	return b1;
}

// not delay write.
void bwrite(struct buf *b)
{
	// all write operations are delayed write
	if (b->owner != curproc)
		return;
    b->flag &= (~B_VALID);
	b->flag |= B_DIRTY;
	ide_read_write(b);
}

void bwrite_delay(struct buf *b)
{
	if (b->owner != curproc)
		return;
    b->flag &= (~B_VALID);
	b->flag |= B_DIRTY;
	brelse(b);
}

// if a buffer was marked B_DIRTY and the call brelse.
// the affect is the same as delayed write.
void brelse(struct buf *b)
{
	if (b->owner != curproc)
		return;

	spin_lock_irqsave(&bcache.blk_cache_lk);
	b->flag &= (~B_BUSY);
	if ((b->flag & (B_VALID | B_DIRTY)) == B_VALID) {
		list_add_tail(&b->free_list_node, &bcache.free_list_head);
		wakeup(&bcache.waiting_proc_list, &bcache.blk_cache_lk);
		wakeup(&b->waiting_proc_list, &bcache.blk_cache_lk);
	}
	//else
	//	list_add(&b->free_list_node, &bcache.free_list_head);
	// the block is still in hash table.
	spin_unlock_irqrestore(&bcache.blk_cache_lk);
}

// i assume that if balloc() call bzero(), the block will be used soon
// so if i leave it in the cache, it is a good for system's performence.
void bzero(uint32_t dev, uint32_t blkno)
{
	struct buf *b;

	b = bread(dev, blkno);
	memset(b->data, 0, BLKSIZE);
	log_write(b);
	brelse(b);
}

// alloc a disk block. i must set all block to be 0 for security.
uint32_t balloc(uint32_t dev)
{
	uint32_t byteidx, byter;
	struct buf *b;

	for (int i = 0; i < sb.size; i += BITPB) {
		b = bread(dev, BITBLOCK(i, sb));
		for (int j = 0; j < BITPB && (i + j < sb.size); j++) {
			byteidx = j / 8;
			byter = 1 << (j % 8);
			if ((b->data[byteidx] & byter) == 0) {
				b->data[byteidx] |= byter;
				log_write(b);
				brelse(b);
				bzero(dev, i + j);
				return i + j;
			}
		}
		brelse(b);
	}
	return 0; 
}

int bfree(uint32_t dev, uint32_t blkno)
{
	struct buf *b;
	uint32_t bitidx, byteidx, byter;;

	read_superblock(dev, &sb);
	b = bread(dev, BITBLOCK(blkno, sb));
	// we get the bit no wa want to free
	bitidx = blkno % BITPB;
	// 1 byte = 8 bits.
	byteidx = bitidx / 8;
	byter = 1 << (bitidx % 8);
	if ((b->data[byteidx] & byter) == 0)
		return -1;
	b->data[byteidx] &= (~byter);
	log_write(b);
	brelse(b);
	return 0;
}

static struct buf *find_blk_in_hash(uint32_t dev, uint32_t blockno)
{
	int slot;
	struct buf *b;
	struct list_head *list_head;
	struct list_head *list_node;

	slot = hash_func(dev, blockno);
	list_head = &(bcache.hash_table[slot]);
	list_node = list_head->next;
	while (list_node != list_head) {
		b = list_entry(list_node, struct buf, hash_node);
		if ((b->dev = dev) && (b->blockno == blockno))
			return b;
		list_node = list_node->next;
	}
	return 0;
}

static void put_blk_in_hash(struct buf *b)
{
	int slot;

	slot = hash_func(b->dev, b->blockno);
	list_add_tail(&b->hash_node, &(bcache.hash_table[slot]));
}
