#include <include/types.h>
#include <include/user.h>

int wmain(int argc, char *argv[])
{
	int nbytes;
	int fd1, fd2;
	char buf[512];

	if (argc < 3) {
		printf(1, "Usage: cp source target\n");
		return -1;
	}

	if ((fd1 = open(argv[1], O_RDONLY)) < 0) {
		printf(1, "cannot open %s\n", argv[1]);
		return -1;
	}
	if ((fd2 = open(argv[2], O_CREAT|O_RDWR)) < 0) {
		printf(1, "cannot open %s\n", argv[2]);
		return -1;
	}
	while ((nbytes = read(fd1, buf, 512)) > 0)
		if (write(fd2, buf, nbytes) < 0)
			break;
	close(fd1);
	close(fd2);
	return 0;
}