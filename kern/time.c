#include <include/types.h>
#include <include/time.h>
#include <include/trap.h>
#include <include/cmos.h>
#include <include/lock.h>
#include <include/stdio.h>
#include <include/kernel.h>
#include <include/picirq.h>

volatile uint32_t  jiffs;
struct spinlock jiffs_lock;

static struct time_struct  sys_time;
static char *days_of_week[7] = {
	"Sunday", "Monday", "Tuseday",
	"Wednesday", "Thursday", "Friday", "Saturday", 
};

static char *months[12] = {
	"jan", "Feb", "Mar", "Apr",
	"May", "June", "July", "Aug",
	"Sept", "Oct", "Now", "Dec"
};

void time_init(void)
{
	unsigned  t_reg;

	// We first read from CMOS
	// Getting current time
	sys_time.sec = bcd_to_dec(cmos_read(CMOS_SEC));
	sys_time.min = bcd_to_dec(cmos_read(CMOS_MIN));
	sys_time.hour = bcd_to_dec(cmos_read(CMOS_HOUR));
	sys_time.day_of_week = bcd_to_dec(cmos_read(CMOS_DAY_OF_WEEK));
	sys_time.date_of_month = bcd_to_dec(cmos_read(CMOS_DATE_OF_MONTH));
	sys_time.month = bcd_to_dec(cmos_read(CMOS_MONTH));
	sys_time.year = bcd_to_dec(cmos_read(CMOS_YEAR));

	jiffs = 0;

	t_reg = cmos_read(CMOS_REGA | CMOS_NMI_DISABLED);
	t_reg |= 0x0B;	// intervel = 1.25(ms)
	cmos_write(CMOS_REGA, t_reg);

	t_reg = cmos_read(CMOS_REGB);
	t_reg |= 0x40;	// Set PIE in regB
	cmos_write(CMOS_REGB, t_reg);

	cmos_read(CMOS_REGC);

	spinlock_init(&jiffs_lock, "time_lock");

	irq_clear_mask(IRQ_TIMER);
}

uint32_t time_msec(void)
{
	return jiffs;
}

void welcome_to_WeiOS(void)
{
	prink("\nWelcome to WeiOS, current time is: ");
	prink("%d:%d:%d %s %d%s %s 20%d\n", sys_time.hour, sys_time.min, sys_time.sec,
								  days_of_week[sys_time.day_of_week-1], 
								  sys_time.date_of_month,
								  (sys_time.date_of_month == 1)? "st":
								  (sys_time.date_of_month == 2)? "nd":
								  (sys_time.date_of_month == 3)? "rd":"th",
								  months[sys_time.month-1],
								  sys_time.year);
}