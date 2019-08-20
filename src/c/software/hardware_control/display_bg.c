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
    char *filename = "1.bin";
    lcd_show_img(filename, 0, 0, 480, 800);
    printf("image shown\n");
}
