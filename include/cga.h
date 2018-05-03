#ifndef _CGA_H_
#define _CGA_H_

#include "types.h"

#define CGA_BASE    0xB8000

#define TWINKLE     0x80
#define HIGHLIGHT   0x08

#define B_RED       0x40
#define B_GREEN     0x20
#define B_BLUE      0x10

#define F_RED       0x04
#define F_GREEN     0x02
#define F_BLUE      0x01

void cga_init(void);
void cga_clear(void);
void cga_putc(char, ushort);
int cga_puts(const char *, ushort);

#endif
