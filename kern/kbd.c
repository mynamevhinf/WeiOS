#include <include/x86.h>
#include <include/mem.h>
#include <include/kbd.h>
#include <include/trap.h>
#include <include/lock.h>
#include <include/picirq.h>
#include <include/console.h>
#include <include/sysfunc.h>

//#define BACKSPACE  0x0100
#define CONTROL(X) ((X)-'@')
extern struct tty_struct console_tty; 
static struct spinlock kbd_lock;

/*****************************************
              Keyboard driver 
 ****************************************/
uint kbd_get_data(char *rdata)
{
    static uint shift;
    static uchar *charcode[4] = {
        normalmap, shiftmap, ctlmap, ctlmap
    };
    uint st, data, c;

    st = inb(KBSTATP);
    if((st & KBS_DIB) == 0)
        return -1;
    data = inb(KBDATAP);
    *rdata = data;

    if(data == 0xE0){
        shift |= E0ESC;
        return 0;
    } else if(data & 0x80){
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
        shift &= ~(shiftcode[data] | E0ESC);
        return 0;
    } else if(shift & E0ESC){
    // Last character was an E0 escape; or with 0x80
        data |= 0x80;
        shift &= ~E0ESC;
    }

    shift |= shiftcode[data];
    shift ^= togglecode[data];
    c = charcode[shift & (CTL | SHIFT)][data];
    if(shift & CAPSLOCK){
        if('a' <= c && c <= 'z')
            c += 'A' - 'a';
        else if('A' <= c && c <= 'Z')
            c += 'a' - 'A';
    }
    return c;
}

//#include <include/stdio.h>
void kbd_intr(void)
{
    char c, rc;
    struct tty_queue  *rbuf, *wbuf;

    rbuf = &console_tty.read_buf;
    wbuf = &console_tty.write_buf;
    spin_lock_irqsave(&kbd_lock);
    while ((c = (char)kbd_get_data(&rc)) >= 0) {
        if (rbuf->wpos - rbuf->rpos < TTY_BUF)
            rbuf->buf[(rbuf->wpos++ % TTY_BUF)] = rc;
        switch (c) {
            case CONTROL('P'):      // process listing.
                break;
            case CONTROL('U'):// kill line
                while (wbuf->wpos != wbuf->rpos 
                        && wbuf->buf[(wbuf->wpos-1) % TTY_BUF] != '\n')
                {
                    wbuf->wpos--;
                    console_putc('\b');
                }
                break;
            case '\x7f':
            case CONTROL('H'):  // Backspace
                if (wbuf->wpos != wbuf->rpos) {
                    wbuf->wpos--;
                    console_putc('\b');
                }
                break;
            default:
                if (c != 0 && (wbuf->wpos - wbuf->rpos < TTY_BUF)) {
                    c = (c=='\r')?'\n':c;
                    console_putc(c);
                    wbuf->buf[(wbuf->wpos++ % TTY_BUF)] = c;
                    if (c == '\n' || wbuf->wpos == wbuf->rpos + TTY_BUF) 
                        wakeup(&console_tty.write_buf.procs_list, &kbd_lock);
                }
        }
    }
    spin_unlock_irqrestore(&kbd_lock);
}

void kbd_init(void)
{
    kbd_intr();
    spinlock_init(&kbd_lock, "kbd_lock");
    // enable keyboard irq, unfinished
    irq_clear_mask(IRQ_KBD);
}

