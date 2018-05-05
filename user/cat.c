#include <include/types.h>
#include <include/user.h>

int wmain(int argc, char *argv[])
{
	int fd;
	int nbytes;
	char buf[512];
	
	if (argc < 2) {
		printf(1, "Usage: cat target\n");
		return -1;
	}

	if ((fd = open(argv[1], O_RDONLY)) < 0) {
		printf(1, "no such file or directory: %s!\n", argv[1]);
		return 0;
	}
	while ((nbytes = read(fd, buf, 512)) >= 0)
		if (write(stdin, buf, nbytes) < 0)
			break;
	printf(1, "\n");
	return 0;
}