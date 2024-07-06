// CHANGES PRIORITY GIVEN A PROCESS ID AND NEW PRIORITY (VALID FOR SET_PRIORITY)
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
    if (argc != 3)
    {
        fprintf(2, "Usage: setpriority priority pid\n");
        exit(1);
    }
   int a =  set_priority(atoi(argv[2]), getpid());
   printf("\n%d\n", a);
    a =  set_priority(atoi(argv[2]), getpid());
        printf("\n%d\n", a);
    exit(0);
}
