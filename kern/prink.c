#include <include/types.h>
#include <include/stdio.h>
#include <include/stdarg.h>
#include <include/console.h>

#define BUFSIZE 1024
static char readline_buf[BUFSIZE];

int vcprintk(const char *str, va_list ap)
{
    int count = 0;

    vprintfmt(str, &count, ap);
    return count;
}

int prink(const char *str, ...)
{
    va_list ap;
    int count;

    va_start(ap, str);
    count = vcprintk(str, ap);
    va_end(ap);

    return count;
}

void panic(const char *str, ...)
{

    va_list ap;

    asm volatile ("cli; cld");

    prink("panic: ");

    va_start(ap, str);
    vcprintk(str, ap);
    va_end(ap);

    while (1)
        ;
}

char *readline(const char *s)
{
    int  i, c;
    int  echo = is_echo();

    if (s)
        prink("%s", s);

    i = 0;
    while (1) {
        c = getchar();
        if (!c || c == '\n' || c == '\r') {
            readline_buf[i++] = '\0';
            if (echo)
                console_putc('\n');
            return readline_buf;
        } else if (c == '\b') {
            if (i) {
                i--;
                if (echo)
                    console_putc(c);
            }
        } else {
            readline_buf[i++] = (char)c;
            if (echo)
                console_putc(c);
            if (i == BUFSIZE -1)
                return readline_buf;
        }
    }
}
