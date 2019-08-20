//mipsel-linux-gcc test.c -o test -static
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <errno.h>
#include <sys/syscall.h>
#include <linux/unistd.h>
#include "display_lib.h"

// #define __NR_num_lcdwrite 335
// #define __NR_gpio_control 338

// // #define LCD_CTRL_REG            (*((volatile uint32_t *)(0xbfd0d000)))
// // #define LCD_PUT_INST(inst) { (0x80010000 | (uint16_t)inst); }
// // #define LCD_PUT_DATA(data) { (0x80020000 | (uint16_t)data); }
// // #define LCD_WRITE_REG(reg, data) \
// //     LCD_PUT_INST(reg)            \
// //     LCD_PUT_DATA(data)

// inline void lcd_show_buf(uint32_t *buf, int cnt) {
//     syscall(__NR_Linux + __NR_num_lcdwrite, (buf), (cnt));
// }

// inline void lcd_set_cursor(int xmin, int ymin, int xmax, int ymax) {
//     uint32_t *ctrl = (uint32_t *)calloc(19, sizeof(uint32_t));
//     int xminh = (xmin & 0xff00) >> 8, xminl = xmin & 0xff;
//     int yminh = (ymin & 0xff00) >> 8, yminl = ymin & 0xff;
//     int xmaxh = (xmax & 0xff00) >> 8, xmaxl = xmax & 0xff;
//     int ymaxh = (ymax & 0xff00) >> 8, ymaxl = ymax & 0xff;
//     ctrl[ 0] = 0x80013600; ctrl[ 1] = 0x80020000;
//     ctrl[ 2] = 0x80012a00; ctrl[ 3] = 0x80020000 | xminh;
//     ctrl[ 4] = 0x80012a01; ctrl[ 5] = 0x80020000 | xminl;
//     ctrl[ 6] = 0x80012a02; ctrl[ 7] = 0x80020000 | xmaxh;
//     ctrl[ 8] = 0x80012a03; ctrl[ 9] = 0x80020000 | xmaxl;
//     ctrl[10] = 0x80012b00; ctrl[11] = 0x80020000 | yminh;
//     ctrl[12] = 0x80012b01; ctrl[13] = 0x80020000 | yminl;
//     ctrl[14] = 0x80012b02; ctrl[15] = 0x80020000 | ymaxh;
//     ctrl[16] = 0x80012b03; ctrl[17] = 0x80020000 | ymaxl;
//     ctrl[18] = 0x80012c00;
//     syscall(__NR_Linux + __NR_num_lcdwrite, ctrl, 19);
// }

// #define LCD_SHOW(ptr, cnt) {syscall(__NR_Linux + __NR_num_lcdwrite, (ptr), (cnt));}

// void lcd_show_img(char *filename, int x, int y, int width, int height) {
//     uint16_t *buf = (uint16_t *)calloc(4096, sizeof(uint16_t));
//     uint32_t *dat = (uint32_t *)calloc(4096, sizeof(uint32_t));
//     lcd_set_cursor(x, y, x + width - 1, y + height - 1);
//     FILE *ptr = fopen(filename, "rb");
//     if (!ptr)
//         printf("Error occurred while opening %s\n", filename);
//     int i, num;
//     while ((num = fread(buf, sizeof(uint16_t), 4096, ptr)) != 0) {
//         for (i = 0; i < num; i++)
//             dat[i] = 0x80020000 | buf[i];
//         syscall(__NR_Linux + __NR_num_lcdwrite, dat, num);
//     }
//     free(buf);
//     free(dat);
//     fclose(ptr);
//     return;
// }

// void lcd_clear() {
//     uint32_t *dat = (uint32_t *)calloc(4800, sizeof(uint32_t));
//     int i;
//     for (i = 0; i < 4800; i++)
//         dat[i] = 0x80028430;
//     for (i = 0; i < 80; i++) {
//         lcd_set_cursor(0, i*10, 799, i*10+9);
//         syscall(__NR_Linux + __NR_num_lcdwrite, dat, 4800);
//     }
//     free(dat);
// }

int main() {
    char *filename = "1.bin";
    lcd_show_img(filename, 0, 0, 480, 800);
    printf("image shown\n");
    lcd_set_cursor(20, 20, 39, 39);
    uint32_t *buf = (uint32_t *)calloc(1600, sizeof(uint32_t));
    int i;
    for (i = 0; i < 1600; i++)
        buf[i] = 0x800207e0;
    lcd_show_buf(buf, 1600);
    lcd_set_cursor(200, 200, 219, 219);
    lcd_show_buf(buf, 1600);

    print_string("POWER OVERWHELMING", BLACK, 20, 20);
    print_big_string("POWER!!!", BLACK, 80, 80);

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
