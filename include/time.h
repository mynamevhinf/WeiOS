
#ifndef _TIME_H_
#define _TIME_H_

#ifndef __ASSEMBLER__

#include <include/types.h>
#include <include/cmos.h>

// 1 jiffs = 1 ms
#define HZ	1000
#define NS_TO_JIFFIES(x) ((x) / (1000000000 / HZ))	// x(ns)

struct time_struct {
	uchar  sec;
	uchar  min;
	uchar  hour;
	uchar  day_of_week;
	uchar  date_of_month;
	uchar  month;
	uchar  year;
};

void time_init(void);
uint32_t time_msec(void);
void welcome_to_WeiOS(void);

#endif

#endif