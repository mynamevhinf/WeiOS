#include <include/types.h>
#include <include/stdarg.h>
#include <include/user.h>

char getc(void)
{
	char c;
	if (read(stdin, &c, 1) < 0)
		return 0;
	return c;
}

char *gets(char *buf, int max)
{
  	int i, cc;
  	char c;

  	for (i = 0; i+1 < max; ) {
    	cc = read(stdin, &c, 1);
	    if (cc < 1)
	      	break;
	    buf[i++] = c;
	    if(c == '\n' || c == '\r')
	      	break;
    }
	buf[i] = '\0';
	return buf;
}

char *shell_gets(char *buf, int max)
{
    int i, cc;
    char c;

    for (i = 0; i+1 < max; ) {
        cc = read(stdin, &c, 1);
        if (cc < 1)
            break;
        printf(1, "%c", c);
        buf[i++] = c;
        if(c == '\n' || c == '\r')
            break;
    }
    buf[i] = '\0';
    return buf;
}

static void putc(int fd, char c)
{
	write(fd, &c, 1);
}

static int puts(int fd, const char *str)
{
	int cnt = 0;
	while (*str++) {
		putc(fd, *str);
		cnt++;
	}

	return cnt;
}

// i copy it from WeiOS/lib/printfmt.c directly
static int printf_write_hex(int fd, uint32_t n)
{
    int count = 0;
    int num_stack[8];
    static char hex_map[16] = {'0', '1', '2', '3', '4', '5', '6',
                                '7', '8', '9', 'A', 'B', 'C', 'D',
                                'E', 'F'};
    if (!n) {
        putc(fd, '0');
        return 1;
    }

    while (n) {
        num_stack[count++] = n % 16;
        n /= 16;
    }
    for (int i = count-1; i >= 0; i--)
        putc(fd, hex_map[num_stack[i]]);
    return count;
}

// combine screen_write_dec and screen_write_oct
static int printf_write_radix(int fd, uint32_t n, uint32_t radix)
{
    int count = 0;
    int num_stack[12];

    if (!n) {
        putc(fd, 0x30 & 0xff);
        return 1; 
    }

    while (n) {
        num_stack[count++] = n % radix;
        n /= radix;
    }
    for (int i = count-1; i >= 0; i--)
        putc(fd, (num_stack[i] | 0x30) & 0xff);
    return count;
}

static void printfmt(int fd, const char *s, int *count, va_list ap)
{
	char c;
	int cnt;
    int d_num;
    uint32_t u_num;

	if (!s)
		return ;

	while ((c = *s++) != '\0') {
		if (c != '%') {
			cnt++;
			putc(fd, c);
			continue;
		}
		c = *s++;
		switch (c) {
			case 'o':
                putc(fd, '0');
                cnt++;
                cnt += printf_write_radix(fd, va_arg(ap, uint32_t), 8);
                break;
            case 'd':
                d_num = va_arg(ap, int32_t);
                if (d_num < 0) {
                    putc(fd, '-');
                    d_num &= (~0x80000000);
                }
                cnt += printf_write_radix(fd, d_num, 10);
                break;
            case 'u':
                u_num = va_arg(ap, uint32_t);
                cnt += printf_write_radix(fd, u_num, 10);
                break;
            case 'x':
                cnt += printf_write_hex(fd, va_arg(ap, uint32_t));
                break;
            case 'p':
                putc(fd, '0');
                putc(fd, 'x');
                cnt += (printf_write_hex(fd, va_arg(ap, uint32_t))+2);
                break;
            case 's':
                cnt += puts(fd, va_arg(ap, const char *));
                break;       
            case 'c':
                putc(fd, va_arg(ap, uint32_t));
                cnt++;
                break;    
            default:        // deal with %c and %%
                putc(fd, c);
                cnt++;
                break;
		}
	}
	*count = cnt;  
}

int printf(int fd, const char *str, ...)
{
	va_list ap;
    int count = -1;

    va_start(ap, str);
    printfmt(fd, str, &count, ap);
    va_end(ap);

    return count;
}