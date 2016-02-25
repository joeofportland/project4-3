#include "types.h"
#include "user.h"
#include "date.h"

#define MAX_ARGS 20
#define NULL_PTR ((char*)0)


int
main(int argc, char *argv[])
{
struct rtcdate r1;
struct rtcdate r2;

char *p[MAX_ARGS];

static int status = 1;

//start time
date(&r1);

// check for args
if (argc < 2)
{
	printf(2, "minimum one command after 'timem'");
}
else if (argc > MAX_ARGS+1)
{
	printf(2, "Hit maximum commands.\n");
}
else
{
	int i;

	int pid = fork();
    
	// negative (fork failed)
	if (pid < 0)                       
		printf(2, "'%s' has failed.\n", argv[0]);
	else if (pid > 0)                           
	{
		//parent
      		pid = wait();

	//end time
	date(&r2);
	}
	else             
	{
		for (i = 0; i < argc-1; i++)
		p[i] = argv[i+1];
		p[i] = NULL_PTR;

		//execute command
		status = exec(p[0], p);
		if (status)
			printf(2, "exec '%s' failed", p[0]);

		exit();
	}

	int s1 = r1.hour * 3600 + r1.minute * 60 + r1.second;
	int s2 = r2.hour * 3600 + r2.minute * 60 + r2.second;
	printf(2, "\nTime: %d seconds\n", s2-s1);
}
exit();
}