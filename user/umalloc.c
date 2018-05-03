#include <include/types.h>
#include <include/user.h>

static Header  base;
static Header *free_list;

static Header *more_core(uint32_t n_units)
{
	char *p;
	Header *hp;

	if (n_units < PGSIZE)
		n_units = PGSIZE;
	if ((p = sbrk(n_units * sizeof(Header))) == (char *)-1)
		return 0;
	hp = (Header *)p;
	hp->exist.size = n_units;
	free((void *)(hp + 1));
	return free_list;
}

void *malloc(size_t nbytes)
{
	uint32_t  n_units;
	Header *ptr, *prev_ptr;

	// How many Header objects? -- n_units
	n_units = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
	if ((prev_ptr = free_list) == 0) {
		prev_ptr = &base;
		free_list = prev_ptr;
		base.exist.ptr = free_list;
		base.exist.size = 0;
	}
	for (ptr = prev_ptr->exist.ptr; ; prev_ptr = ptr, ptr = ptr->exist.ptr) {
		if (ptr->exist.size >= n_units) {
			if (ptr->exist.size == n_units)
				prev_ptr->exist.ptr = ptr->exist.ptr;
			else {
				ptr->exist.size -= n_units;
				ptr += ptr->exist.size;
				ptr->exist.size = n_units;
			}
			free_list = prev_ptr;
			return (void *)(ptr + 1);
		}
		if (ptr == free_list)
			if (!(ptr = more_core(n_units)))
				return 0;
	}
}

void free(void *fptr)
{
	Header *bptr, *ptr;

	bptr = (Header *)fptr - 1;
	for (ptr = free_list; !(bptr > ptr && bptr < ptr->exist.ptr); ptr = ptr->exist.ptr)
		if (ptr >= ptr->exist.ptr && (bptr > ptr || bptr < ptr->exist.ptr))
			break;
	if (bptr + bptr->exist.size == ptr->exist.ptr) {
		bptr->exist.size += ptr->exist.size;
		bptr->exist.ptr = ptr->exist.ptr->exist.ptr;
	} else
		bptr->exist.ptr = ptr->exist.ptr;
	
	if (ptr + ptr->exist.size == bptr) {
		ptr->exist.size += bptr->exist.size;
		ptr->exist.ptr = bptr->exist.ptr;
	} else
		ptr->exist.ptr = bptr;

	free_list = ptr;
}