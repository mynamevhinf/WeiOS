#include <include/types.h>
#include <include/param.h>
#include <include/fs.h>
#include <include/file.h>
#include <include/string.h>
#include <include/buffer.h>

//#include <include/stdio.h>

struct superblock sb;
struct dev_struct dev_structs[NDEV];

void read_superblock(uint32_t dev, struct superblock *sb)
{
	struct buf *b;

	b = bread(dev, 1);
	memmove(sb, b->data, sizeof(struct superblock));
	brelse(b);
}