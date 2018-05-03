#ifndef _PROC_H_
#define _PROC_H_

#include <include/types.h>
#include <include/param.h>
#include <include/mmu.h>
#include <include/file.h>
#include <include/lock.h>
#include <include/trap.h>

// clone parameters
#define CLONE_FORK    0x19960912
#define CLONE_VFORK   0x19970717
#define CLONE_THREAD  0x3

// In WeiOS, I don't need hardware's task translation.
struct context {
    uint32_t    edi;    
    uint32_t    esi;
    uint32_t    ebx;
    uint32_t    ebp;
    uint32_t    eip;
};

struct proc_queue {
    size_t  n_procs;
    uint32_t  padding;
    uint64_t  priority_bitmap; // 1 means process(es) exist(s), 0 means empty
    struct list_head  procs_in_queue[N_PRIORITY];
};

struct cpu {
    uchar  apcid;    // The cpuid in mp system.
    int  n_clis;
    int  int_enabled;
    volatile unsigned int  started;  // Has cpu started?
    struct spinlock  per_cpu_lock;
    struct context *scheduler;       // swtch() here to come back to user mode.
    struct tss_struct  ts;
    struct segdesc  gdt[NSEGS];
    struct proc  *proc;          // The current proc in this cpu.
    // used for Tasks switch.
    struct proc_queue *run_queue;
    struct proc_queue *exhausted_queue;
};

// Unfinished.
enum proc_status {
    RUNNABLE,
    RUNNING,
    READY,
    SLEEPING,
    ZOMBLE, 	
    FREE
};

#define curproc  (myproc())
// I define that the default timeslice is 100 jiffs
// default priority is 10. Hint: priority is 
typedef struct proc *Proc;
struct proc {
    pid_t  pid;
    pid_t  ppid;
    uint32_t  base_mem_sz;
    uint32_t  heap_ptr;
    pte_t  *proc_pgdir;         /* physical address of Process pgdir, 
                                   loaded in cr3 during running. */
    enum proc_status  status;     // Process state
    struct trapframe  *tf;
    struct context *context;    // switch() here to enter scheduler.
    struct inode *pwd;

    uint32_t  timeslice;
    uint32_t  timeslice_left;         

    uint32_t  sleep_avg;        // used for task switch.
    uint32_t  sleep_start_jiffs;

    int killed;                     // Is it killed?
    int preempted;
    int wait_for_child;

    // alarm &  timer referenced
    uint32_t  alarmticks_left;
    uint32_t alarmticks;
    void (*alarmhandler)();
        
    // ipc
    int  ipc_recving;       // Proc is blocked receiving?
    void *ipc_dstva;        // VA at which to map received page
    uint32_t ipc_value;     // Data value sent to me
    uint32_t ipc_perm;       // Perm of page mapping received
    pid_t ipc_from;       // pid of the sender

    // run_queue or exhausted_queue?
    struct proc_queue *proc_queue;

    int n_opfiles;
    struct file  *open_file_table[NOFILE];
    
    ushort  priority;                  // priority level
    // Process name (for debug)
    char  name[16];

    struct list_head  sleep_alone;  // The element must be itself or none.
    struct list_head  children;     // Header of children list.
    struct list_head  siblings;     // iy is a node, not a header
                                    // We all are kids of a process.
    // In run_queue, exhausted_queue or wait_queue(waiting event to happen).
    struct list_head  kinds_list;
};

struct proc_manager {
    struct spinlock proc_table_lock;
    uint32_t  n_procs_alive;
    uint32_t  id_bitmap[32];    // if bits in id_bitmap is 0, it is occupied.
    struct proc  *proc_table[NPROCS];
    struct list_head  procs_desc_cache;
};

struct cpu *mycpu(void);
struct proc *myproc(void);

void proc_init(void);
static uint32_t get_pid(void);
static void clear_pid(pid_t pid);
struct proc *get_proc_desc(void);
void proc_desc_destroy(struct proc *p);
int pid2proc(pid_t pid, struct proc **proc_store, int check);
pde_t *setup_vm(void);
int proc_setup_vm(struct proc *p);
int proc_region_alloc(struct proc *p, void *va, size_t len, int perm);
void pgdir_free(pde_t *pgdir);
void proc_free(struct proc *p);
int proc_alloc(struct proc **new_proc_store);
static void load_binary(struct proc *p, uint8_t *binary);
int proc_create(struct proc **p_store, uint8_t *binary);
void WeiOS_first_process(void);
void rectify_tf_context(struct proc *p);

#endif
