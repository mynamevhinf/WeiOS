#include <include/types.h>
#include <include/stdio.h>
#include <include/error.h>
#include <include/stdarg.h>
#include <include/console.h>


static const char * const err_string[MAXERROR] = {
    [E_UNSPECIFIED] = "unspecific error", 
    [E_BAD_PROC] = "bad proceess", 
    [E_INVAL] = "invalid parameter",
    [E_NO_MEM] = "out of memory", 
    [E_NO_FREE_PROC] = "out of procs", 
    [E_FAULT] = "segment fault",
    [E_IPC_NOT_RECV] = "process is not recving", 
    [E_EOF] = "unexpected end of file", 
    [E_NO_DISK] = "no free space on disk",
    [E_MAX_OPEN] = "too many files are open", 
    [E_NOT_FOUND] = "file or block not found", 
    [E_BAD_PATH] = "invalid path",
    [E_FILE_EXISTS] = "file already exists", 
    [E_NOT_FOUND] = "file is not a valid executable", 
    [E_NOT_SUPP] = "operation not supported"
};

static int screen_write_hex(uint32_t n)
{
    int count = 0;
    int num_stack[8];
    static char hex_map[16] = {'0', '1', '2', '3', '4', '5', '6',
                                '7', '8', '9', 'A', 'B', 'C', 'D',
                                'E', 'F'};
    if (!n) {
        console_putc('0');
        return 1;
    }

    while (n) {
        num_stack[count++] = n % 16;
        n /= 16;
    }
    for (int i = count-1; i >= 0; i--)
        console_putc(hex_map[num_stack[i]]);
    return count;
}

// combine screen_write_dec and screen_write_oct
static int screen_write_radix(uint32_t n, uint32_t radix)
{
    int count = 0;
    int num_stack[12];

    if (!n) {
        console_putc(0x30 & 0xff);
        return 1; 
    }

    while (n) {
        num_stack[count++] = n % radix;
        n /= radix;
    }
    for (int i = count-1; i >= 0; i--)
        console_putc((num_stack[i] | 0x30) & 0xff);
    return count;
}

static int print_error(int errno)
{
    errno *= -1;
    if (errno > MAXERROR || errno < 1)
        return 0;
    return console_puts(err_string[errno]); 
}

void vprintfmt(const char *str, int *cnt, va_list ap)
{
    char        c;
    const char *s = str;
    int         count;  
    int32_t     d_num;
    uint32_t    u_num;

    if (!s) 
        return ;

    count = 0;
    // default attribute
    while ((c = *s++) != '\0') {
        if (c != '%' && c != '\033') {
            count++;
            console_putc(c);
            continue;
        }
        if (c == '\033') {
            s = set_local_attr(s);
            continue;
        }
        // deal with '%'
        c = *s++;
        switch (c) {
            case 'o':
                console_putc('0');
                count++;
                count += screen_write_radix(va_arg(ap, uint32_t),8);
                break;
            case 'd':
                d_num = va_arg(ap, int32_t);
                if (d_num < 0) {
                    console_putc('-');
                    d_num *= -1;
                }
                count += screen_write_radix(d_num,10);
                break;
            case 'u':
                u_num = va_arg(ap, uint32_t);
                count += screen_write_radix(u_num, 10);
                break;
            case 'x':
                count += screen_write_hex(va_arg(ap, uint32_t));
                break;
            case 'p':
                console_putc('0');
                console_putc('x');
                count += (screen_write_hex(va_arg(ap, uint32_t))+2);
                break;
            case 's':
                count += console_puts(va_arg(ap, const char *));
                break;
            case 'e':
                count += print_error(va_arg(ap, int32_t));             
                break;
            default:        // deal with %c and %%
                console_putc(c);
                count++;
                break;
        }
    }

    *cnt += count;
}
