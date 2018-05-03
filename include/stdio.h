#ifndef _STDOUT_H_
#define _STDOUT_H_

#include <include/stdarg.h>

#ifndef NULL
#define NUMM ((void *)0)
#endif

// lib/printfmt.c
void vprintfmt(const char *str, int *c, va_list ap);

// kern/prink.c
int vcprintk(const char *str, va_list ap);
int prink(const char *str, ...);
void panic(const char *str, ...);
char *readline(const char *s);

#endif
