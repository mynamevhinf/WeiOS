#ifndef _TYPE_H_
#define _TYPE_H_

#include <include/param.h>

typedef unsigned int    uint;
typedef unsigned int    size_t;
typedef unsigned char   uchar;
typedef unsigned short  ushort;

typedef __signed char int8_t;
typedef unsigned char uint8_t;
typedef short int16_t;
typedef unsigned short uint16_t;
typedef int int32_t;
typedef unsigned int uint32_t;
typedef long long int64_t;
typedef unsigned long long uint64_t;


// Used for struct Elf
typedef uint        Elf32_Addr;
typedef uint        Elf32_Off;

// Used for page protection
typedef uint32_t        pde_t;
typedef uint32_t        pte_t;

typedef uint32_t        physaddr_t;
typedef uint32_t        uintptr_t;

typedef uint32_t 		pid_t;
typedef uint32_t 		ppid_t;

#define NULL            0

// Used for buddy and slab
typedef ushort gfp_t;

#define MIN(a, b)       \
({                      \
    typeof(a) ta = (a); \
    typeof(b) tb = (b); \
    ta <= tb ? ta : tb; \
})

#define MAX(a, b)       \
({                      \
    typeof(a) ta = (a); \
    typeof(b) tb = (b); \
    ta >= tb ? ta : tb; \
})

// Rounding operations (efficient when n is a power of 2)
// Round down to the nearest multiple of n
#define ROUNDDOWN(a, n)						\
({								\
	uint32_t __a = (uint32_t) (a);				\
	(typeof(a)) (__a - __a % (n));				\
})
// Round up to the nearest multiple of n
#define ROUNDUP(a, n)						\
({								\
	uint32_t __n = (uint32_t) (n);				\
	(typeof(a)) (ROUNDDOWN((uint32_t) (a) + __n - 1, __n));	\
})

#define ARRAY_SIZE(array)   \
    (sizeof(array)/sizeof(array[0]))

#endif
