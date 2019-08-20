//mipsel-linux-gcc test.c -o test -static
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <errno.h>
#include <sys/syscall.h>
#include <linux/unistd.h>
#include "display_lib.h"

int main() {
    while (1) {
        uint32_t addr, data, num;
        int op;
        printf("input GPIO num:\n");
        scanf("%u", &num);
        addr = 0xbfd0f000 + (num << 2);
        printf("input operation: 1=read 0=write\n");
        scanf("%d", &op);
        if (op) {
            uint32_t ret = syscall(__NR_Linux + __NR_gpio_control, addr, 0x0, 1);
            printf("GET 0x%x form 0x%x\n", ret, addr);
        }
        else
        {        
            printf("input data:\n");
            scanf("%x", &data);
            syscall(__NR_Linux + __NR_gpio_control, addr, data, 0);
            printf("SENT\n");
        }
    }
    return 0;
}
