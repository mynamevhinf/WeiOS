#include <include/types.h>
#include <include/user.h>
#include <include/kernel.h>
#include <include/malloc.h>
#include <include/krbtree.h>

struct rbtree mm_rbtree;
struct list_head list_head;

// Unfinished
static RBNode MallocSearch(RBTree T, uint32_t key)
{
    int left;       // 1 - left son, 0 - right son
    RBNode Ty;
    RBNode Tx = T->root;
    
    if (T->root == &T->nil)
        return &T->nil;
    while (Tx != &T->nil) {
        Ty = Tx;
        if (key > Tx->key) {
            left = 0;
            Tx = Tx->right;
        } else if (key < Tx->key) {
            left = 1;
            Tx = Tx->left;
        } else
            return Tx; 
    }

    if (left)
        return Ty;
    // left == 0
    return RBNodeSucceeder(T, Ty);
}

void *malloc(uint32_t size)
{
    RBNode trb;
    uint32_t tsize;
    struct mm_node *MN, *SMN;

    static int firsttime = 1;
    if (firsttime) {
        rbtree_init(&mm_rbtree);
        LIST_HEAD_INIT(list_head);
        firsttime = 0;
    }

Search:
    if ((trb = MallocSearch(&mm_rbtree, size)) != &mm_rbtree.nil) {
        RBTreeDeleteNode(&mm_rbtree, trb);  // Delete the node from tree.
        MN = container_of(trb, struct mm_node, rb);
        if ((size+MMSIZE) < trb->key) {
            SMN = (struct mm_node *)((char *)(MN + 1) + size); 
            SMN->busy = 0;
            rbnode_init(&mm_rbtree, &SMN->rb, trb->key-size-MMSIZE, RED);
            list_add(&SMN->list_node, &MN->list_node);
            RBTreeInsert(&mm_rbtree, &SMN->rb);
            trb->key -= (SMN->rb.key + MMSIZE);
        }
        MN->busy = 1;
        return (void *)(MN + 1);
    }

    tsize = ROUNDUP(size+MMSIZE, PGSIZE);
    if (!(MN = (struct mm_node *)sbrk(tsize))) 
        return NULL;
    MN->busy = 0;
    rbnode_init(&mm_rbtree, &MN->rb, tsize-MMSIZE, RED);
    list_add_tail(&MN->list_node, &list_head);
    RBTreeInsert(&mm_rbtree, &MN->rb);
    goto Search;
}

struct mm_node *find_siblings(struct mm_node *MN)
{
    struct mm_node *SMN;
    struct list_head *LN;

    // left first
    LN = MN->list_node.prev;
    if (LN != &list_head) {
        SMN = container_of(LN, struct mm_node, list_node); 
        if (IS_LEFT_SIBLING(MN, SMN) && (SMN->busy == 0))
            return SMN;
    }

    // right next
    LN = MN->list_node.next;
    if (LN != &list_head) {
        SMN = container_of(LN, struct mm_node, list_node); 
        if (IS_RIGHT_SIBLING(MN, SMN) && (SMN->busy == 0))
            return SMN;
    }

    return NULL;
}

void free(void *ptr)
{
    struct mm_node *MN, *SMN;

    // MN->rb is not in the red-black tree now.
    MN = (struct mm_node *)ptr - 1;
    while ((SMN = find_siblings(MN))) {
        // Delete SMN->rb_node from tree.
        RBTreeDeleteNode(&mm_rbtree, &SMN->rb);
        if (MN < SMN) {
            // Delete it from double link list.
            list_del(&SMN->list_node); 
            MN->busy = 0;
            MN->rb.color = RED;
            MN->rb.key += (MMSIZE + SMN->rb.key);
            RBTreeInsert(&mm_rbtree, &MN->rb); 
        } else {
            list_del(&MN->list_node); 
            SMN->rb.color = RED; 
            SMN->rb.key += (MMSIZE + MN->rb.key);
            RBTreeInsert(&mm_rbtree, &SMN->rb); 
            MN = SMN;
        }
    }

    if (MN->busy) {
        MN->busy = 0;
        RBTreeInsert(&mm_rbtree, &MN->rb); 
    }
}
