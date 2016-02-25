#include "types.h"
#include "user.h"
#include "date.h"

int
main(int argc, char *argv[])
{
    struct rtcdate r;

int pid = getpid();
int gid = getgid();
int uid = getuid();
int ppid = getppid();

	printf(2, "PID:%d  GID:%d  UID:%d PPID:%d ", pid,gid,uid,ppid);


    if (date(&r)) {
	printf(2, "date failed\n");
	exit ();
    }


    // your code to print the time in any format your like
   date(&r);
    printf(1,"UTC Time (h:m:s): %d:%d:%d : UTC Date (m/d/y): %d/%d/%d",r.hour, r.minute, r.second,r.month, r.day, r.year);





    exit();

}