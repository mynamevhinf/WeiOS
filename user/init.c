#include <include/types.h>
#include <include/user.h>

char *argv[2] = {"sh", 0};

int wmain(void)
{
	  int d = 5;
    int pid, dpid;

  	if (open("console", O_RDWR) < 0) {
    	  mknod("console", 1, 1);
    	  open("console", O_RDWR);
  	}
  	dup(0);  // stdout
  	dup(0);  // stderr

    if ((pid = fork()) == 0) {
        exec("sh", argv);
        printf(1, "exec(): failed to setup shell!!!\n");
        exit();      
    } else if (pid == -1) {
        printf(1, "oh no!!!\n");
        return 0;
    }
  
    while (1) {
        dpid = wait();
        printf(1, "pid = %u died!!!\n\n", dpid);
    }

  	return 0;
}