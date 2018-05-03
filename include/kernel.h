#ifndef _KERNEL_H_
#define _KERNEL_H_

#ifndef __ASSEMBLER__

#include <include/types.h>

struct list_head {
    struct list_head  *next;
    struct list_head  *prev;
};

#define LIST_HEAD_INIT(name)    \
    name.next = &(name);        \
    name.prev = &(name)         

#define LIST_HEAD(name) \
    struct list_head name;  \
    LIST_HEAD_INIT(name)

static int list_empty(struct list_head *head)
{
    return (head->next == head);
}

static void list_add(struct list_head *new_node, struct list_head *head)
{
    new_node->next = head->next;
    head->next->prev = new_node;    
    head->next = new_node;
    new_node->prev = head; 
}

static void list_add_tail(struct list_head *new_node, struct list_head *head)
{
    new_node->next = head;
    new_node->prev = head->prev;
    new_node->prev->next = new_node;
    head->prev = new_node;
}

static void list_del(struct list_head *entry)
{
    entry->prev->next = entry->next;
    entry->next->prev = entry->prev;
    entry->next = entry->prev = 0;
}

#define offsetof(type, member)  ((size_t)&((type *)0)->member)
#define container_of(ptr, type, member) ({\
    const typeof(((type *)0)->member) *mptr = (ptr);  \
    (type *)((char *)mptr - offsetof(type, member));})


#define list_entry(ptr, type, member) container_of(ptr, type, member)

#define bcd_to_dec(x) ((x >> 4) * 10 + (x & 0x0F))

#endif

#endif
