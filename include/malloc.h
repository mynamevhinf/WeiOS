#ifndef _MALLOC_H_
#define _MALLOC_H_

#include <include/types.h>
#include <include/kernel.h>
#include <include/krbtree.h>

// Real Malloc functions
struct mm_node {
    int busy;
    struct rbnode rb;
    struct list_head list_node;
};

#define MMSIZE  (sizeof(struct mm_node))
#define IS_LEFT_SIBLING(N, LN)  \
   (((char *)((LN)+1) + LN->rb.key) == (char *)N)
#define IS_RIGHT_SIBLING(N, RN) \
   (((char *)((RN)-1) - N->rb.key) == (char *)N) 
void *malloc(uint32_t size);
void free(void *ptr);

#endif