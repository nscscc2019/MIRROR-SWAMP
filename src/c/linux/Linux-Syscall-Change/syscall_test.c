#include <stdio.h>
#include <linux/unistd.h>
#include <sys/syscall.h>
#include <errno.h>

#define __NR_num_regwrite 337

int main(void)
{
    syscall(__NR_Linux + __NR_num_regwrite, 0x12345678);
    return 0;
}