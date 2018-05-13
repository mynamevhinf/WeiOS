#include <include/types.h>
#include <include/param.h>
#include <include/picirq.h>
#include <include/buffer.h>
#include <include/kernel.h>
#include <include/sysfunc.h>
#include <include/trap.h>
#include <include/lock.h>
#include <include/x86.h>
#include <include/ide.h>

static int slave_disk_existed;

struct ide_manager {
    uint32_t n_requests;
    struct spinlock ide_lock;
    struct list_head ide_queue;
} ide_manager;

static int ide_wait(int check)
{
	  int out;

  	while (((out = inb(IDE_STATUS_PORT)) & (IDE_BUSY | IDE_READY)) != IDE_READY)
  		  ;
  	if (check && (out & (IDE_WRFLT | IDE_ERROR)) != 0)
  		  return -1;
  	return 0;
}

static void update_idequeue(struct buf *b)
{
    struct buf *tb, *fb;
    struct list_head *list_node;

    ide_manager.n_requests++;
    if (!list_empty(&ide_manager.ide_queue)) {
        // I don't care about consistency of device.
        // whatever, follow the sequence.if two same block was in the queue
        // they follow FIFO.
        tb = list_entry(ide_manager.ide_queue.next, struct buf, ide_queue_node);
        if (b->blockno > tb->blockno) {
            //list_node = ide_manager.ide_queue.next->next;
            list_node = tb->ide_queue_node.next;
            while (list_node != &ide_manager.ide_queue) {
                fb = list_entry(list_node, struct buf, ide_queue_node);
                if (b->blockno < fb->blockno)
                    break; 
                list_node = list_node->next;
                tb = fb;
            }
        } else if (b->blockno < tb->blockno) { 
            list_node = ide_manager.ide_queue.prev;
            while (list_node != &ide_manager.ide_queue) {
                fb = list_entry(list_node, struct buf, ide_queue_node);
                if (b->blockno <= fb->blockno) {
                    list_add_tail(&b->ide_queue_node, &fb->ide_queue_node);
                    return;
                }
                list_node = list_node->prev;
                tb = fb;
            }
        }
        list_add(&b->ide_queue_node, &tb->ide_queue_node);
    } else
        list_add(&b->ide_queue_node, &ide_manager.ide_queue);
}

void ide_init(void)
{
    ide_wait(0);

    // Test if disk master disk exists or not.
    outb(IDE_DRIVE_PORT, 0xE0 | IDE_SLAVE);
  	for(int i = 0; i < 1000; i++){
        if(inb(IDE_STATUS_PORT) != 0) {
	      	  slave_disk_existed = 1;
	      	  break;
	      }
	  }
  	// Switch back to disk 0.
  	outb(IDE_DRIVE_PORT, 0xE0 | IDE_MASTER);

    ide_manager.n_requests = 0;
    LIST_HEAD_INIT(ide_manager.ide_queue);
    spinlock_init(&ide_manager.ide_lock, "ide_lock");
	  // Enable IRQ 14
    irq_clear_mask(IRQ_IDE);
}

static void ide_start(struct buf *b)
{
  	if (!b || b->blockno >= FSSIZE)
  		  return ;

  	ide_wait(0);
  	outb(0x3F6, 0);	// enable interrupt
  	outb(0x1F2, 1);
    outb(0x1F3, b->blockno & 0xff);
    outb(0x1F4, (b->blockno >> 8) & 0xff);
    outb(0x1F5, (b->blockno >> 16) & 0xff);
    outb(IDE_DRIVE_PORT, LBA|0xA0|((b->dev & 1) << 4)|((b->blockno>>24)&0x0f));
    if (b->flag & B_DIRTY) {
      	outb(IDE_CMD_PORT, IDE_WRITE);
      	outsl(IDE_DATA_PORT, b->data, BLKSIZE / 4); // BLKSIZE / 4 double word
    } else     
      	outb(IDE_CMD_PORT, IDE_READ);
}

void ide_intr(void)
{
  	struct buf *b;
    struct dozenbufs *dozens;
    struct list_head *list_node;

  	// First queued buffer is the active request.
  	spin_lock_irqsave(&ide_manager.ide_lock);  	
  	if (ide_manager.n_requests == 0){
    	  spin_unlock_irqrestore(&ide_manager.ide_lock);
    	  return;
  	}

    // delete completed block from queue.
    list_node = ide_manager.ide_queue.next;
    b = list_entry(list_node, struct buf, ide_queue_node);
    list_del(list_node);
    ide_manager.n_requests--;
  	// Read data if needed.
  	if(!(b->flag & B_DIRTY) && !ide_wait(1))
    	  insl(IDE_DATA_PORT, b->data, BLKSIZE / 4);

  	// whatever the last requist is read or write
  	// we have to set B_VALID because it is just Fresh,
  	// and clear the B_DIRTY, if it was a read requist,
  	// it cannot be DIRTY, if it was a write requist, now
  	// it becomes valid!!!!
  	b->flag |= B_VALID;
  	b->flag &= (~B_DIRTY);
    if (b->dozen_ptr) {
        dozens = b->dozen_ptr;
        b->dozen_ptr = 0;
        dozens->n_request--;
        if (dozens->n_request == 0)
            wakeup(&dozens->waiting_for_io, &ide_manager.ide_lock);
    } else 
	      wakeup(&b->waiting_for_io, &ide_manager.ide_lock);

  	// Start disk on next buf in queue.
   	if(ide_manager.n_requests != 0) {
        list_node = ide_manager.ide_queue.next;
        b = list_entry(list_node, struct buf, ide_queue_node);
       	ide_start(b);
    }  	
  	spin_unlock_irqrestore(&ide_manager.ide_lock);
}

// What i do just throw the requist into a array
// which contains blocks waiting to be handled.
int ide_read_write(struct buf *b)
{
  	if ((b->flag & (B_VALID|B_DIRTY)) == B_VALID)
  		  return 0;
  	if (b->dev && !slave_disk_existed)
    	  return -1;

  	spin_lock_irqsave(&ide_manager.ide_lock); 
    update_idequeue(b);
  	// Start disk if necessary.
  	if(ide_manager.n_requests == 1)
    	ide_start(b);

  	// Wait for request to finish.
    while((b->flag & (B_VALID | B_DIRTY)) != B_VALID) 
        sleep(&b->waiting_for_io, &ide_manager.ide_lock);
  	spin_unlock_irqrestore(&ide_manager.ide_lock);
    return 0;
}

int ide_write_dozens(struct dozenbufs *dozens)
{
    struct buf *tb;

    if (dozens->n_bufs == 0)
        return -1;
    if (dozens->buf_array == 0 || dozens->buf_array[0] == 0)
        return -1;
    if (dozens->buf_array[0]->dev && !slave_disk_existed)
        return -1;

    spin_lock_irqsave(&ide_manager.ide_lock);
    // put all blocks into the idequeue.
    for (int j = 0; j < dozens->n_bufs; j++)
        update_idequeue(dozens->buf_array[j]);

    if (ide_manager.n_requests == dozens->n_bufs) {
        tb = list_entry(ide_manager.ide_queue.next, struct buf, ide_queue_node);
        ide_start(tb);
    }

    while (dozens->n_request > 0) 
        sleep(&dozens->waiting_for_io, &ide_manager.ide_lock);

    spin_unlock_irqrestore(&ide_manager.ide_lock);
    return 0;
}