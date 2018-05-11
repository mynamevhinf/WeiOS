#include <include/x86.h>
#include <include/types.h>
#include <include/trap.h>
#include <include/picirq.h>

void irq_set_mask(uchar irq_line)
{
	uint16_t	port;
	uint8_t		value;

	if (irq_line < 8) 
		port = PIC_MASTER_DATA;
	else {
		irq_line -= 8;
		port = PIC_SLAVE_DATA;
	}

	value = inb(port) | (1 << irq_line);
	outb(port, value);
}

void irq_clear_mask(uchar irq_line)
{
	uint16_t port;
	uint8_t  value;

	if (irq_line < 8)
		port = PIC_MASTER_DATA;
	else {
		port = PIC_SLAVE_DATA;
		irq_line -= 8;
	}

	value = inb(port) & ~(1 << irq_line);
	outb(port, value);
}

static uint16_t _pic_get_irq_regs(int ocw3)
{
	outb(PIC_MASTER_CMD, ocw3);
	outb(PIC_SLAVE_CMD, ocw3);
	return (inb(PIC_SLAVE_CMD) << 8) | inb(PIC_MASTER_CMD);
}

uint16_t pic_get_irr(void)
{
	return _pic_get_irq_regs(PIC_READ_IRR);
}

uint16_t pic_get_isr(void)
{
	return _pic_get_irq_regs(PIC_READ_ISR);
}


void irq_init(void)
{
	// Disabling two
	outb(PIC_MASTER_DATA, 0xFF);
	outb(PIC_SLAVE_DATA, 0xFF);

	// Let's first initialize master
	outb(PIC_MASTER_CMD, 0x11);
	// ICW2
	outb(PIC_MASTER_DATA, IRQ_STARTED);
	// ICW3
	outb(PIC_MASTER_DATA, 1<<IRQ_SLAVE);
	// ICW4 
	// setting bit 0 means 8086/8087 system
	// setting bit 1 means automatically EOI.
	outb(PIC_MASTER_DATA, 0x3);

	// Then is Slave.
	// Whick is similiar to Master.
	outb(PIC_SLAVE_CMD, 0x11);
	outb(PIC_SLAVE_DATA, IRQ_STARTED + PIC_SLAVE_OFF);
	outb(PIC_SLAVE_DATA, IRQ_SLAVE);
	// ICW4 (Copy) Automatic EOI mode doesn't tend to work on the slave.
	outb(PIC_SLAVE_DATA, 0x01);

	// OCW3
	outb(PIC_MASTER_CMD, 0x68); 
	outb(PIC_MASTER_CMD, 0x0A);
	outb(PIC_SLAVE_CMD, 0x68);
	outb(PIC_SLAVE_CMD, 0x0A);

	pic_get_irr();

	// We only enable irq 2 in master - for slave
	for (int i = 0; i < 16; i++)
		irq_set_mask(i);
	irq_clear_mask(IRQ_SLAVE);
}

void irq_eoi(void)
{
	outb(PIC_MASTER_CMD, PIC_EOI);
	outb(PIC_SLAVE_CMD, PIC_EOI);
}