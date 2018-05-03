#include <include/types.h>
#include <include/file.h>
#include <include/lock.h>
#include <include/buddy.h>
#include <include/kernel.h>
#include <include/kmalloc.h>
#include <include/sysfunc.h>

// this function is called in sys_pipe()
int pipe_alloc(struct file **f1, struct file **f2)
{
	struct pipe *p = 0;

	if (!(*f1 = file_alloc()))
		goto pipe_alloc_failure;
	if (!(*f2 = file_alloc()))
		goto pipe_alloc_failure;
	if (!(p = (struct pipe *)kmalloc(sizeof(struct pipe), __GFP_ZERO)))
		goto pipe_alloc_failure;
	if (!(p->data = (char *)kmalloc(PIPESIZE, __GFP_ZERO)))
		goto pipe_alloc_failure;

	p->nread = 0;
	p->nwrite = 0;
	p->readopen = 1;
	p->writeopen = 1;
	spinlock_init(&p->pipe_lock, "pipe_lock");
	LIST_HEAD_INIT(p->wait_to_read);
	LIST_HEAD_INIT(p->wait_to_write);

	(*f1)->type = FS_PIPE;
	(*f1)->flag |= O_RDONLY;
	(*f1)->pipe = p;
	(*f2)->type = FS_PIPE;
	(*f2)->flag |= O_WRONLY;
	(*f2)->pipe = p;

	return 0;

pipe_alloc_failure:
	if (*f1)
		file_close(*f1);
	if (*f2)
		file_close(*f2);
	if (p)
		kfree(p);
	return -1;
}

// called in file_close(). reaching here means that the file's referencee is 0.
void pipe_close(struct pipe *p, int writend)
{
	spin_lock_irqsave(&p->pipe_lock);
	if (writend) {
		p->writeopen = 0;
		wakeup(&p->wait_to_read, &p->pipe_lock);
	} else {
		p->readopen = 0;
		wakeup(&p->wait_to_write, &p->pipe_lock);
	}

	spin_unlock_irqrestore(&p->pipe_lock);
	if (!(p->readopen) && !(p->writeopen))		
		kfree(p);
}

// if pipe is empty, we have to sleep, waitting for other process
// write something, or close the pipe. if process was killed when it is
// sleeping in this position, it must quit the function right away!
int pipe_read(struct pipe *p, char *dst, int nbytes)
{
	int total;

	spin_lock_irqsave(&p->pipe_lock);
	while ((p->nwrite == p->nread)) {
		sleep(&p->wait_to_read, &p->pipe_lock);
		if (!(p->writeopen) || curproc->killed) {
			spin_unlock_irqrestore(&p->pipe_lock);
			return -1;
		}
	}

	for (total = 0; total < nbytes; total++) {
		if (p->nwrite == p->nread)
			break;
		dst[total] = p->data[(p->nread++ % PIPESIZE)];
	}

	wakeup(&p->wait_to_write, &p->pipe_lock);
	spin_unlock_irqrestore(&p->pipe_lock);
	return total;
}


int pipe_write(struct pipe *p, char *src, int nbytes)
{
	int total;

	spin_lock_irqsave(&p->pipe_lock);
	while ((p->nwrite - p->nread) == PIPESIZE) {
		sleep(&p->wait_to_write, &p->pipe_lock);
		if (!(p->readopen) || curproc->killed) {
			spin_unlock_irqrestore(&p->pipe_lock);
			return -1;
		}
	}

	for (total = 0; total < nbytes; total++) {
		if ((p->nwrite - p->nread) == PIPESIZE)
			break;
		src[total] = p->data[(p->nread++ % PIPESIZE)];
	}

	wakeup(&p->wait_to_read, &p->pipe_lock);
	spin_unlock_irqrestore(&p->pipe_lock);
	return total;	
}