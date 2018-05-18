#include <include/types.h>
#include <include/krbtree.h>

void rbnode_init(RBTree T,  RBNode N,  uint32_t key, int32_t color)
{
    N->key = key;
    N->left = &T->nil;
    N->right = &T->nil;
    N->parent = &T->nil;
    N->color = color;
}

void rbtree_init(RBTree T)
{
    T->root = &T->nil;
    rbnode_init(T, T->root, 0, BLACK);
}

// nil is a struct
// root is a pointer.
RBNode RBTreeMinimum(RBTree T, RBNode N)
{
    while (N->left != &T->nil)
        N = N->left;
    return N;
}

RBNode RBTreeSearch(RBTree T, uint32_t key)
{
    RBNode TN = T->root;

    while (TN != &T->nil) {
        if (TN->key > key)
            TN = TN->left;
        else if (TN->key < key)
            TN = TN->right;
        else
            return TN;
    }

    return &T->nil;
}

RBNode RBNodeSucceeder(RBTree T, RBNode N)
{
    if ((N != &T->nil) && (N->right != &T->nil))
        return N->right; 
    
    RBNode Tx = N;
    while ((Tx->parent != &T->nil) && (Tx == Tx->parent->right))
        Tx = Tx->parent;
    return Tx->parent;
}

static void LeftRotate(RBTree T, RBNode N)
{
    RBNode M = N->right;
    N->right = M->left;
    if (M->left != &T->nil)
        M->left->parent = N;
    M->parent = N->parent;
    if (N->parent == &T->nil)
        T->root = M;
    else if (N == N->parent->left)
        N->parent->left = M;
    else
        N->parent->right = M;
    M->left = N;
    N->parent = M;
}

static void RightRotate(RBTree T, RBNode N)
{
    RBNode M = N->left;
    N->left = M->right;
    if (M->right != &T->nil)
        M->right->parent = N;
    M->parent = N->parent;
    if (N->parent == &T->nil)
        T->root = M;
    else if (N == N->parent->left)
        N->parent->left = M;
    else
        N->parent->right = M;
    M->right = N;
    N->parent = M;
}

static void RBTreeTransplant(RBTree T, RBNode src, RBNode dst)
{
    if (src->parent == &T->nil)
        T->root = dst;
    else if (src == src->parent->left)
        src->parent->left = dst;
    else
        src->parent->right = dst;
    dst->parent = src->parent;
}

static void RBTreeInsertFixup(RBTree T, RBNode N)
{
    RBNode Ny;
    while (N->parent->color == RED) {
        if (N->parent == N->parent->parent->left) {
            Ny = N->parent->parent->right;
            if (Ny->color == RED) {
                N->parent->color = BLACK;
                Ny->color = BLACK;
                N->parent->parent->color = RED;
                N = N->parent->parent;
                continue;
            } else if (N == N->parent->right) {
                N = N->parent;
                LeftRotate(T, N);
            }
            N->parent->color = BLACK;
            N->parent->parent->color = RED;
            RightRotate(T, N->parent->parent);
        } else {
            Ny = N->parent->parent->left;
            if (Ny->color == RED) {
                N->parent->color = BLACK;
                Ny->color = BLACK;
                N->parent->parent->color = RED;
                N = N->parent->parent;
                continue;
            } else if (N == N->parent->left) {
                N = N->parent;
                RightRotate(T, N);
            }
            N->parent->color = BLACK;
            N->parent->parent->color = RED;
            LeftRotate(T, N->parent->parent);
        }
    }
    T->root->color = BLACK;
}

int RBTreeInsert(RBTree T, RBNode N)
{
    uint32_t key; 
    RBNode Tp = &T->nil;
    RBNode Tc = T->root;

    key = N->key;
    while (Tc != &T->nil) {
        Tp = Tc;
        if (key < Tc->key)
            Tc = Tc->left;
        else
            Tc = Tc->right;
    }
    N->parent = Tp;
    if (Tp == &T->nil)
        T->root = N;
    else if (key < Tp->key)
        Tp->left = N;
    else
        Tp->right = N;
    RBTreeInsertFixup(T, N);
    return 0;
}

static void RBTreeDeleteFixup(RBTree T, RBNode N)
{
    RBNode Tw;

    while (N != T->root && N->color == BLACK) {
        if (N == N->parent->left) {
            Tw = N->parent->right;
            if (Tw->color == RED) {
                Tw->color = BLACK;
                Tw->parent->color = RED;
                LeftRotate(T, N->parent);
                Tw = N->parent->right;
            }
            if (Tw->left->color == BLACK && Tw->right->color == BLACK) {
                Tw->color = RED;
                N = N->parent;
                continue;
            } else if (Tw->right->color == BLACK) {
                Tw->left->color = BLACK;
                Tw->color = RED;
                RightRotate(T, Tw);
                Tw = N->parent->right;
            }
            Tw->color = RED;
            N->parent->color = BLACK;
            Tw->right->color = BLACK;
            LeftRotate(T, N->parent);
            N = T->root;
        } else {
            Tw = N->parent->left;
            if (Tw->color == RED) {
                Tw->color = BLACK;
                Tw->parent->color = RED;
                RightRotate(T, N->parent);
                Tw = N->parent->left;
            }
            if (Tw->left->color == BLACK && Tw->right->color == BLACK) {
                Tw->color = RED;
                N = N->parent;
                continue;
            } else if (Tw->left->color == BLACK) {
                Tw->right->color = BLACK;
                Tw->color = RED;
                LeftRotate(T, Tw);
                Tw = N->parent->left;
            }
            Tw->color = N->parent->color;
            N->parent->color = BLACK;
            Tw->left->color = BLACK;
            RightRotate(T, N->parent);
            N = T->root;
        }
    }
    N->color = BLACK;
}

void RBTreeDeleteNode(RBTree T, RBNode N)
{
    RBNode Tx;
    RBNode Ty = N;
    int TyOriginalColor = Ty->color;

    if (N->left == &T->nil) {
        Tx = N->right;
        RBTreeTransplant(T, N, Tx); 
    } else if (N->right == &T->nil) {
        Tx = N->left;
        RBTreeTransplant(T, N, Tx);
    } else {
        Ty = RBTreeMinimum(T, N->right);
        TyOriginalColor = Ty->color;
        Tx = Ty->right;
        if (Ty->parent == N) {
            Tx->parent = Ty;        // what will happen if Tx is T->nil?
        } else {
            RBTreeTransplant(T, Ty, Ty->right);
            Ty->right = N->right;
            Ty->right->parent = Ty;
        }
        RBTreeTransplant(T, N, Ty);
        Ty->left = N->left;
        Ty->left->parent = Ty;
        Ty->color = N->color;
    }
    // must be set to null.
    N->left = &T->nil;
    N->right = &T->nil;
    if (TyOriginalColor == BLACK)
        RBTreeDeleteFixup(T, Tx);
}