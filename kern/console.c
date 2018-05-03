#include <include/x86.h>
#include <include/mem.h>
#include <include/cga.h>
#include <include/kbd.h>
#include <include/file.h>
#include <include/lock.h>
#include <include/proc.h>
#include <include/param.h>
#include <include/kernel.h>
#include <include/sysfunc.h>
#include <include/console.h>

// I'll only deal with the contrl_tty
// which print data in just screen, do not transmit.
// yeah, you are right,What i mean is that i ignore serial.
struct tty_struct console_tty; 
static ushort  lattr = (0x07<<8);
extern struct dev_struct dev_structs[NDEV];

static void delay(void)
{
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}

static short is_color_controller(char c)
{
    if (c >= '0' && c <= '9')
        return c-0x30;
    else if (c >= 'a' && c <= 'f')
        return c-0x61+0x0A;
    else if (c >= 'A' && c <= 'F')
        return c-0x41+0x0A;
    else
        return -1;
}

// A simple parser for text color.
// status = 6. Acceptence
// status = 7, Error
const char *set_local_attr(const char *str)
{
    int     cancel;
    int     status;
    short   t1, t2;
    char    c;
    const char   *s = str;
    
    cancel = 0;
    status = 1;
    spin_lock_irqsave(&console_tty.console_lock);
    while (status < 6) { 
        c = *s++;
        switch (status) {
            case 1:
                if (c == '[')
                    status = 2;
                else 
                    status = 7;
                break;
            case 2:
                if ((t1 = is_color_controller(c)) == 0) 
                    status = 3;
                else if (t1 > 0)
                    status = 4;
                else 
                    status = 7;
                break;
            case 3:
                if (c == 'm') {
                    cancel = 1;
                    status = 6;
                } else if ((t2 = is_color_controller(c)) > 0)
                    status = 5;
                else 
                    status = 7;
                break;
            case 4:
                if ((t2 = is_color_controller(c)) >= 0)
                    status = 5;
                else 
                    status = 7;
                break;
            case 5:
                if (c == 'm')
                    status = 6;
                else 
                    status = 7;
                break;
        }
    }
    if (status == 7) {
        spin_unlock_irqrestore(&console_tty.console_lock);
        return s+1; 
    }
    if (!cancel) {
        lattr = ((t1<<4)|t2)<<8;
    } else
        lattr = (0x07<<8);
    spin_unlock_irqrestore(&console_tty.console_lock);
    return s;
}

void console_putc(int c)
{
    spin_lock_irqsave(&console_tty.console_lock);
    cga_putc((char)c, lattr);
    spin_unlock_irqrestore(&console_tty.console_lock);   
}

int console_puts(const char *s)
{
    int cnt;
    spin_lock_irqsave(&console_tty.console_lock);
    cnt = cga_puts(s, lattr);
    spin_unlock_irqrestore(&console_tty.console_lock); 
    return cnt;
}

int console_getc(void)
{
    char  c;
    struct  tty_queue *tyqueue;

    kbd_intr();

    // We have to choose which buf to use, 
    // depends on struct termios in console_tty.
    tyqueue = &console_tty.write_buf;
    if (tyqueue->rpos != tyqueue->wpos) {
        c = tyqueue->buf[(tyqueue->rpos++ % TTY_BUF)];
        return c;
    }
    return 0;
}

int is_echo(void)
{
    return console_tty.echo; 
}

void close_echo(void)
{
    console_tty.echo = 0;
}

int getchar(void)
{
    int  c;
    spin_lock_irqsave(&console_tty.console_lock);
    while (!(c = console_getc()))
        continue;
    spin_unlock_irqrestore(&console_tty.console_lock);
    
    return c;
}

int compatible_console_read(struct inode *i, char *dst, int nbytes)
{
    char c;
    int cnt = 0;
    struct  tty_queue *tyqueue;

    iunlock(i);
    spin_lock_irqsave(&console_tty.console_lock);
    tyqueue = &console_tty.write_buf;
    while (cnt < nbytes) {
        while (tyqueue->rpos == tyqueue->wpos) {
            sleep(&tyqueue->procs_list, &console_tty.console_lock);
            if (curproc->killed) {
                spin_unlock_irqrestore(&console_tty.console_lock);
                ilock(i);
                return -1;
            }
        }
        c = console_getc();
        if (c == ('D' - '@')) {
            if (cnt > 0)
                tyqueue->rpos--;
            break;
        }
        *dst++ = c;
        cnt++;
        if (c == '\n')
            break;
    }
    spin_unlock_irqrestore(&console_tty.console_lock);
    ilock(i);

    return cnt;
}

int compatible_console_write(struct inode *i, const char *src, int nbytes)
{
    iunlock(i);
    spin_lock_irqsave(&console_tty.console_lock);
    for (int i = 0; i < nbytes; i++)
        cga_putc(src[i], lattr);
    spin_unlock_irqrestore(&console_tty.console_lock); 
    ilock(i);

    return nbytes;
}

void console_init(void)
{
    console_tty.echo = 1; 
    LIST_HEAD_INIT(console_tty.read_buf.procs_list);
    LIST_HEAD_INIT(console_tty.write_buf.procs_list);
    spinlock_init(&console_tty.console_lock, "console_lock");
    dev_structs[CONSOLE].write = compatible_console_write;
    dev_structs[CONSOLE].read = compatible_console_read;
    cga_init();
}

