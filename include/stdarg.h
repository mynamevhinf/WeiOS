#ifndef _STDDARG_H_
#define _STDDARG_H_

/*
typedef char *va_list;

#define _UINT32SIZEOF(n)    \
    ((sizeof(n)+sizeof(uint32_t)-1) & (~(sizeof(uint32_t)-1)))

#define va_start(ap, v) \
    (ap = (va_list)&v + _UINT32SIZEOF(v))
#define va_arg(ap, t)   \
    (*(t *)((ap += _UINT32SIZEOF(t)) - _UINT32SIZEOF(t)))
#define va_end(ap)  \
    (ap = (va_list)0)
*/

typedef __builtin_va_list va_list;

#define va_start(ap, last) __builtin_va_start(ap, last)
#define va_arg(ap, type) __builtin_va_arg(ap, type)
#define va_end(ap) __builtin_va_end(ap)

#endif
