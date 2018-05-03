#include <include/x86.h>
#include <include/cmos.h>

unsigned cmos_read(unsigned offset)
{
    outb(CMOS_INDEX_PORT, offset);
    return inb(CMOS_DATA_PORT);
}

void cmos_write(unsigned offset, unsigned data)
{
    outb(CMOS_INDEX_PORT, offset);
    outb(CMOS_DATA_PORT, data);
}
