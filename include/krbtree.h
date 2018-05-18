#ifndef _KRBTREE_H_
#define _KRBTREE_H_

#include <include/types.h>

#define RED     0
#define BLACK   1

typedef struct rbnode *RBNode;
struct rbnode {
    int32_t   color;
    uint32_t  key;       // Also key
    RBNode    left;
    RBNode    right;
    RBNode    parent;
};

typedef struct rbtree *RBTree;
struct rbtree {
    RBNode root;
    struct rbnode nil;
};

// Functions about red-black tree.
void rbtree_init(RBTree T);
void rbnode_init(RBTree T,  RBNode N,  uint32_t key, int32_t color);
RBNode RBTreeMinimum(RBTree T, RBNode N);
RBNode RBNodeSucceeder(RBTree T, RBNode N);
RBNode RBTreeSearch(RBTree T, uint32_t key);
int RBTreeInsert(RBTree T, RBNode N);
void RBTreeDeleteNode(RBTree T, RBNode N);

#endif