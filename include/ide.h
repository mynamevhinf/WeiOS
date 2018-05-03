#ifndef _IDE_H_
#define _IDE_H_

// Status
#define SECTSIZE	512
#define IDE_BUSY	0x80
#define IDE_READY 	0x40
#define IDE_WRFLT	0x20
#define IDE_ERROR	0x01

// Commands
#define IDE_READ 	0x20
#define IDE_WRITE 	0x30
#define IDE_RDMUL 	0xC4
#define IDE_WRMUL   0xC5

#define IDE_MASTER	(0 << 4)
#define IDE_SLAVE   (1 << 4)

// i don't know why the port 0x1F6 has such an equivocal name.
// Bochs text tell me so, http://bochs.sourceforge.net/techspec/PORTS.LST
#define IDE_DATA_PORT	0x1F0
#define IDE_DRIVE_PORT  0x1F6
#define IDE_CMD_PORT	0x1F7
#define IDE_STATUS_PORT	0x1F7

#ifndef __ASSEMBLER__

#include <include/buffer.h>

void ide_init(void);
// An interrupt handler.
void ide_intr(void);
// Start the request for block b, caller must hold the lock.
int ide_read_write(struct buf *b);

#endif

#endif