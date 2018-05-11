#include <include/types.h>
#include <include/param.h>
#include <include/log.h>
#include <include/lock.h>
#include <include/file.h>
#include <include/buddy.h>
#include <include/stdio.h>
#include <include/string.h>
#include <include/kernel.h>
#include <include/kmalloc.h>

struct ftable {
	int n_openfiles;
	struct spinlock flk;
	struct list_head flist_head;
} ftable;

void ftable_init(void)
{
	struct file *f;

	ftable.n_openfiles = 0;
	spinlock_init(&ftable.flk, "ftable_lock");
	LIST_HEAD_INIT(ftable.flist_head);

	for (int i = 0; i < NFILE; i++) {
		f = (struct file *)kmalloc(sizeof(struct file), __GFP_ZERO);
		list_add(&f->flist_node, &ftable.flist_head);
	}
}

struct file *file_alloc(void)
{
	struct file *f;

	spin_lock_irqsave(&ftable.flk);
	if (ftable.n_openfiles == NFILE) {
		spin_unlock_irqrestore(&ftable.flk);		
		return 0;
	}

	f = list_entry(ftable.flist_head.next, struct file, flist_node);
	list_del(&f->flist_node);
	memset(f, 0, sizeof(struct file));
	f->ref = 1;
	ftable.n_openfiles++;
	spin_unlock_irqrestore(&ftable.flk);
	return f;
}

struct file *file_dup(struct file *f)
{
	spin_lock_irqsave(&ftable.flk);
	if (!f || (f->ref == 0))
		panic("file_dup(): system corruption!!!\n");
	f->ref++;
	spin_unlock_irqrestore(&ftable.flk);	
	return f;
}

void file_close(struct file *f)
{
	struct file ftmp;

	spin_lock_irqsave(&ftable.flk);
	if (f->ref == 0)
		panic("file_close(): system corruption!!!\n");
	if ((f->ref -= 1) > 0) {
		spin_unlock_irqrestore(&ftable.flk);		
		return;
	}

	ftmp = *f;
	f->type = FS_NONE;
	ftable.n_openfiles--;
	list_add(&f->flist_node, &ftable.flist_head);
	spin_unlock_irqrestore(&ftable.flk);

	if (f->type == FS_NONE)
		return ;

	if (ftmp.type != FS_PIPE) {
		begin_transaction();
		iput(ftmp.inode);
		end_transaction();
	} else 
		pipe_close(ftmp.pipe, ftmp.flag & O_WRONLY);
}

int file_stat(struct file *f, struct stat *st)
{
	if (!f || !(f->inode) || (f->type == FS_PIPE) || !st)
		return -1;
	ilock(f->inode);
	stati(f->inode, st);
	iunlock(f->inode);
	return 0;
}

int file_read(struct file *f, char *dst, int nbytes)
{
	int rdbytes;

	if (!f || (f->type == FS_NONE) || !(f->flag & (O_RDONLY|O_RDWR)))
		return -1;
	if (f->type != FS_PIPE) {
		ilock(f->inode);
		if ((rdbytes = readi(f->inode, dst, f->offset, nbytes)) >= 0)
			f->offset += rdbytes;
		iunlock(f->inode);
		return rdbytes;
	} else
		return pipe_read(f->pipe, dst, nbytes);
	return -1;
}

int file_write(struct file *f, char *src, int nbytes)
{
	int perop;
	int total;
	int wrbytes;
	int maxbytes;
	
	if (!f || (f->type == FS_NONE) || !(f->flag & (O_WRONLY|O_RDWR)))
		return -1;
	if (f->type == FS_PIPE)
		return pipe_write(f->pipe, src, nbytes);

	// i use only two types.
	total = 0;
	maxbytes = ((MAXOPBLOCKS - 4) / 2) * BLKSIZE;
	while (total < nbytes) {
		perop = ((nbytes-total)>maxbytes)?(maxbytes):(nbytes-total);
		begin_transaction();
		ilock(f->inode);
		if ((wrbytes = writei(f->inode, src+total, f->offset, perop)) > 0)
			f->offset += wrbytes;
		iunlock(f->inode);
		end_transaction();
		if ((wrbytes < 0) || (wrbytes != perop))
			return -1;
		total += wrbytes;
	}
	return total;
}