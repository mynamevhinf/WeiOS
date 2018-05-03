#ifndef _CMOS_H_
#define _CMOS_H_

#define CMOS_DATA_PORT      0x71
#define CMOS_INDEX_PORT     0x70

#define CMOS_BASE_MEM_LOW   0x15
#define CMOS_BASE_MEM_HIGH  0x16

#define CMOS_EXT_MEM_LOW    0x34        // extend mem > 16M
#define CMOS_EXT_MEM_HIGH   0x35

#define CMOS_EXT16_MEM_LOW  0x17        // extend mem < 16M
#define CMOS_EXT16_MEM_HIGH 0x18

#define CMOS_SEC			0x00
#define CMOS_MIN			0x02
#define CMOS_HOUR			0x04
#define CMOS_DAY_OF_WEEK	0x06
#define CMOS_DATE_OF_MONTH	0x07
#define CMOS_MONTH  		0x08
#define CMOS_YEAR			0x09

#define CMOS_NMI_DISABLED	0x80

#define CMOS_REGA			0x0A
#define CMOS_REGB			0x0B
#define CMOS_REGC			0x0C
#define CMOS_REGD			0x0D

// Default: Ms146818B
unsigned cmos_read(unsigned reg);
void cmos_write(unsigned reg, unsigned data);

#endif
