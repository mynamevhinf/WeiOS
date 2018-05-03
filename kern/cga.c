#include <include/x86.h>
#include <include/mem.h>
#include <include/cga.h>

/*****************************************
 * The following functions are used for
 * Printing to screen
 ****************************************/
ushort cursor_x = 0;
ushort cursor_y = 0;
// mapped at physical address 0xB8000
ushort *cga_mem;

/*
static void get_cursor()
{
    uchar   low, high;
    ushort  location;

    // Get high byte 
    outb(0x3d4, 0x0e);
    high = inb(0x3d5);
    // Get low byte
    outb(0x3d4, 0x0f);
    low = inb(0x3d5);

    location = ((ushort)high<<8) | (ushort)low;

    cursor_x = location % 80;
    cursor_y = location / 80;
}
*/

static void move_cursor()
{

    ushort cur_pos = cursor_y * 80 + cursor_x;

    // Get high byte 
    outb(0x3d4, 0x0e);
    outb(0x3d5, cur_pos>>8);
    // Get low byte
    outb(0x3d4, 0x0f);
    outb(0x3d5, cur_pos & 0xff);
}

static void scroll_screen()
{
    uchar attr = 0x07;   // black background, white chars 
    ushort blank = (attr<<8)|0x20; // means ' ' --- blank 

    for (int i = 0; i < 80 * 24; i++)
        cga_mem[i] = cga_mem[i+80]; 
    for (int i = 80 * 24; i < 80 * 25; i++)
        cga_mem[i] = blank;
    cursor_y = 24;
}

void cga_clear(void)
{
    uchar  addr = (0<<4) | (15 & 0x0f);
    ushort blank = 0x20 | (addr << 8);

    for (int i = 0; i < 80 * 25; i++)
        cga_mem[i] = blank;
    cursor_x = 0;
    cursor_y = 0;
    move_cursor();
}

void cga_putc(char c, ushort attr) 
{
    ushort  cursor_pos;

    cursor_pos = cursor_y * 80 + cursor_x;
    switch (c) {
        case '\b':
            if (cursor_x > 0) {
                cursor_x--;    
                cga_mem[cursor_pos-1] = ' ' | attr;
            }
            break;
        case '\n':
            cursor_y++;
            cursor_x = 0;
            break;
        case '\r':
            cursor_x = 0;
            break;
        case '\t':
            cga_putc(' ', attr);
            cga_putc(' ', attr);
            cga_putc(' ', attr);
            cga_putc(' ', attr);
            break;
        default:
            cga_mem[cursor_pos] = (c & 0xff) | attr; 
            if (++cursor_x > 80) {
                cursor_x = 0;
                cga_putc('\n', attr);
            }
    }
    if (cursor_y >= 25)
        scroll_screen();
    move_cursor();
}

int cga_puts(const char *str, ushort attr) 
{
    int     i = 0;
    while (str[i] != '\0') {
        cga_putc(str[i], attr);
        i++;
    }
    return i;
}

// initialize cga
void cga_init(void)
{
    cga_mem = (ushort *)(KERNBASE + CGA_BASE);
    cga_clear();
}
