//Just used for boot.S to establish a temporary GDT
#ifndef _BOOT_H_
#define _BOOT_H_

#define KERNEL_CODE   0x08
#define KERNEL_DATA   0x10

// LIM:     20 bits
// BASE:    32 bits
// TYPE:    TYPE bits
// CTL:     AVL(20), L(21), D/B(22), G(23) bits
// ATR:     S(12), DPL(13-14), P(15) bits
#define SEG_DES(LIM, BASE, TYPE, CTL)    \
    .word (((LIM) >> 12) & 0xffff), ((BASE) & 0xffff);   \
    .byte (((BASE) >> 16) & 0xff), ((TYPE) | GDT_P | GDT_S),  \
            ((((LIM) >> 28) & 0xf) | (CTL)), (((BASE) >> 24) & 0xff)

//segment descriptors' Attr bits of GDT
// CTL:
#define GDT_G   0x80
#define GDT_DB  0x40
#define GDT_L   0x20
#define GDT_AVL 0x10
//ATR:
#define GDT_P   0x80
#define GDT_S   0x10
//TYPE:
#define GDT_X   0x8
#define GDT_E   0x4
#define GDT_W   0x2
#define GDT_R   0x2
#define GDT_A   0x1

#define SEG_DES_NULL    \
    .word 0, 0;         \
    .byte 0, 0, 0, 0

/*
#define SEG_DES_CODE    \
    SEG_DES(0xfffff, 0x0, GDT_X|GDT_R, GDT_G|GDT_DB)
#define SEG_DES_DATA    \
    SEG_DES(0xfffff, 0x0, GDT_W, GDT_G|GDT_DB)
*/

#endif
