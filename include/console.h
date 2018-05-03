#ifndef _CONSOLE_H_
#define _CONSOLE_H_

#include <include/lock.h>
#include <include/file.h>
#include <include/kernel.h>

#define TTY_BUF 256 

struct tty_queue {
    uint32_t  rpos;          // The same as in JOS
    uint32_t  wpos;
    struct list_head  procs_list;  /* The list of procs who 
                                      wait for this buffer */
    char      buf[TTY_BUF];
};

struct tty_struct {
    int echo;
    struct spinlock  console_lock;
    //struct termios    tty_attr;
    struct tty_queue  read_buf; 
    struct tty_queue  write_buf;
};

int is_echo(void);
void close_echo(void); 
int console_getc(void);
void console_putc(int);
int console_puts(const char *s);
int getchar(void);
void console_init(void);
int compatible_console_read(struct inode *i, char *dst, int nbytes);
int compatible_console_write(struct inode *i, const char *src, int nbytes);
const char *set_local_attr(const char *str);


#endif
