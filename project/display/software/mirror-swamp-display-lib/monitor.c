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

    printf("[info] monitor started\n");
    print_big_string("MONITOR", BLACK, 20, 20);
    print_string("GPIO monitor is running", BLACK, 20, 60);

    print_string("GPIO1", BLACK, 20, 100);
    print_string("GPIO2", BLACK, 20, 120);
    print_string("GPIO3", BLACK, 20, 140);
    print_string("GPIO4", BLACK, 20, 160);
    print_string("GPIO5", BLACK, 20, 180);

    while (1) {
        uint32_t addr, data, num;
        for(num=0; num<5; num++)
        {
            addr = 0xbfd0f040 + (num << 2);
            uint32_t ret = syscall(__NR_Linux + __NR_gpio_control, addr, 0x0, 1);
            // printf("GET 0x%x form 0x%x\n", ret, addr);
            char buf[64];
            sprintf(buf, "0x%x", ret);
            print_string(buf, BLACK, 120, 100+20*num);
        }
    }
    return 0;
}
