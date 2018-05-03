#ifndef _LOG_H_
#define _LOG_H_

#ifndef __ASSEMBLER__

#include <include/types.h>
#include <include/param.h>
#include <include/lock.h>
#include <include/buffer.h>
#include <include/kernel.h>

struct log_header {
	  int32_t nblks;
    int32_t blks_no[LOGSIZE];		// the array of block number.
};

struct log_manager {
	int32_t dev;
  	int32_t size;
  	int32_t start;       // the blkno log starts.
  	int32_t committing;  // in commit(), please wait.
  	int32_t n_occupiers; // how many FS sys calls are executing.
  	struct spinlock log_lock;
  	struct log_header lheader;  // real on-disk imformation.
  	struct list_head procs_waitting;
};

static void commit(void);
static void recover_from_log(void);
void log_init(int32_t dev);
void begin_transaction(void);
void end_transaction(void);
int log_write(struct buf *b);

#endif

#endif