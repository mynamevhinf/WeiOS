#ifndef _PICIRQ_H_
#define _PICIRQ_H_

#include <include/types.h>

#define MAX_IRQS     16

#define PIC_MASTER_CMD   	0x20
#define PIC_MASTER_DATA		0x21
#define PIC_SLAVE_CMD		0xA0
#define PIC_SLAVE_DATA		0xA1

#define PIC_EOI				0x20

// OCW3 command word
#define PIC_READ_IRR		0x0A
#define PIC_READ_ISR		0x0B

#define IRQ_SLAVE 			2
#define PIC_SLAVE_OFF		8

#ifndef __ASSEMBLER__

void irq_set_mask(uchar irq_line);
void irq_clear_mask(uchar irq_line);
uint16_t pic_get_irr(void);
uint16_t pic_get_isr(void);
void irq_init(void);
void irq_eoi(void);

#endif



#endif