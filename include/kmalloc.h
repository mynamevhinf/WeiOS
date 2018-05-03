#ifndef _KMALLOC_H_
#define _KMALLOC_H_

#ifndef __ASSEMBLER__

#include <include/types.h>

void *kmalloc(size_t size, gfp_t gfp_flags);
void kfree(void *objp);

#endif

#endif