#include <include/types.h>
#include <include/user.h>

int wmain(int argc, char *argv[])
{
	if (argc < 2) {
		printf(1, "Usage: rm target\n");
		return -1;
	}

	return unlink(argv[1]);
}