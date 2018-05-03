#include <include/types.h>
#include <include/user.h>

int wmain(int argc, char *argv[])
{
	int fd;
	int nbytes;
	char buf[512];

	if ((fd = open(argv[1], O_RDONLY)) < 0)
		return 0;
	while ((nbytes = read(fd, buf, 512)) >= 0)
		if (write(stdin, buf, nbytes) < 0)
			break;
	printf(1, "\n");
	return 0;
}