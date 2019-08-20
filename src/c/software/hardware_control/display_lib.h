// display_lib.h
// string display lib for mirror_swamp CPU
// by H.Q. Wang & F.Z. Li on 2019.8.16
// usage: mipsel-linux-gcc test.c -o test -static

#ifndef DISPLAY_LIB_H_
#define DISPLAY_LIB_H_

#include "char_map.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <errno.h>
#include <sys/syscall.h>
#include <linux/unistd.h>

// #ifndef __NR_num_lcdwrite
#define __NR_num_lcdwrite 335
// #endif

// #ifndef __NR_gpio_control
#define __NR_gpio_control 338
// #endif

// #define LCD_CTRL_REG            (*((volatile uint32_t *)(0xbfd0d000)))
// #define LCD_PUT_INST(inst) { (0x80010000 | (uint16_t)inst); }
// #define LCD_PUT_DATA(data) { (0x80020000 | (uint16_t)data); }
// #define LCD_WRITE_REG(reg, data) \
//     LCD_PUT_INST(reg)            \
//     LCD_PUT_DATA(data)


#define WHITE         	 0xFFFF
#define BLACK         	 0x0000
#define BLUE         	 0x001F
#define BRED             0XF81F
#define GRED 			 0XFFE0
#define GBLUE			 0X07FF
#define RED           	 0xF800
#define MAGENTA       	 0xF81F
#define GREEN         	 0x07E0
#define CYAN          	 0x7FFF
#define YELLOW        	 0xFFE0
#define BROWN 			 0XBC40
#define BRRED 			 0XFC07
#define GRAY  			 0X8430
#define DARKBLUE      	 0X01CF
#define LIGHTBLUE      	 0X7D7C
#define GRAYBLUE       	 0X5458
#define LIGHTGREEN     	 0X841F
#define LGRAY 			 0XC618
#define LGRAYBLUE        0XA651
#define LBBLUE           0X2B12

int select_bit(char* src, int num)
{
    return src[num >> 3] & (1 << (7 - num % 8));
}

inline void lcd_show_buf(uint32_t *buf, int cnt) {
    syscall(__NR_Linux + __NR_num_lcdwrite, (buf), (cnt));
}

inline void lcd_set_cursor(int xmin, int ymin, int xmax, int ymax) {
    uint32_t *ctrl = (uint32_t *)calloc(19, sizeof(uint32_t));
    int xminh = (xmin & 0xff00) >> 8, xminl = xmin & 0xff;
    int yminh = (ymin & 0xff00) >> 8, yminl = ymin & 0xff;
    int xmaxh = (xmax & 0xff00) >> 8, xmaxl = xmax & 0xff;
    int ymaxh = (ymax & 0xff00) >> 8, ymaxl = ymax & 0xff;
    ctrl[ 0] = 0x80013600; ctrl[ 1] = 0x80020000;
    ctrl[ 2] = 0x80012a00; ctrl[ 3] = 0x80020000 | xminh;
    ctrl[ 4] = 0x80012a01; ctrl[ 5] = 0x80020000 | xminl;
    ctrl[ 6] = 0x80012a02; ctrl[ 7] = 0x80020000 | xmaxh;
    ctrl[ 8] = 0x80012a03; ctrl[ 9] = 0x80020000 | xmaxl;
    ctrl[10] = 0x80012b00; ctrl[11] = 0x80020000 | yminh;
    ctrl[12] = 0x80012b01; ctrl[13] = 0x80020000 | yminl;
    ctrl[14] = 0x80012b02; ctrl[15] = 0x80020000 | ymaxh;
    ctrl[16] = 0x80012b03; ctrl[17] = 0x80020000 | ymaxl;
    ctrl[18] = 0x80012c00;
    syscall(__NR_Linux + __NR_num_lcdwrite, ctrl, 19);
}

#define LCD_SHOW(ptr, cnt) {syscall(__NR_Linux + __NR_num_lcdwrite, (ptr), (cnt));}

void lcd_show_img(char *filename, int x, int y, int width, int height) {
    uint16_t *buf = (uint16_t *)calloc(4096, sizeof(uint16_t));
    uint32_t *dat = (uint32_t *)calloc(4096, sizeof(uint32_t));
    lcd_set_cursor(x, y, x + width - 1, y + height - 1);
    FILE *ptr = fopen(filename, "rb");
    if (!ptr)
        printf("Error occurred while opening %s\n", filename);
    int i, num;
    while ((num = fread(buf, sizeof(uint16_t), 4096, ptr)) != 0) {
        for (i = 0; i < num; i++)
            dat[i] = 0x80020000 | buf[i];
        syscall(__NR_Linux + __NR_num_lcdwrite, dat, num);
    }
    free(buf);
    free(dat);
    fclose(ptr);
    return;
}

void lcd_clear() {
    uint32_t *dat = (uint32_t *)calloc(4800, sizeof(uint32_t));
    int i;
    for (i = 0; i < 4800; i++)
        dat[i] = 0x8002ffff;
    for (i = 0; i < 80; i++) {
        lcd_set_cursor(0, i*10, 799, i*10+9);
        syscall(__NR_Linux + __NR_num_lcdwrite, dat, 4800);
    }
    free(dat);
}

int c2bigfont(char c)
{
    static int warning = 0;
    switch (c)
    {
        case ' ': return 0 * 256;
        case '!': return 1 * 256;
        case '"': return 2 * 256;
        case '#': return 3 * 256;
        case '$': return 4 * 256;
        case '%': return 5 * 256;
        case '&': return 6 * 256;
        case '\'': return 7 * 256;
        case '(': return 8 * 256;
        case ')': return 9 * 256;
        case '*': return 10 * 256;
        case '+': return 11 * 256;
        case ',': return 12 * 256;
        case '-': return 13 * 256;
        case '.': return 14 * 256;
        case '/': return 15 * 256;
        case '0': return 16 * 256;
        case '1': return 17 * 256;
        case '2': return 18 * 256;
        case '3': return 19 * 256;
        case '4': return 20 * 256;
        case '5': return 21 * 256;
        case '6': return 22 * 256;
        case '7': return 23 * 256;
        case '8': return 24 * 256;
        case '9': return 25 * 256;
        case ':': return 26 * 256;
        case ';': return 27 * 256;
        case '<': return 28 * 256;
        case '=': return 29 * 256;
        case '>': return 30 * 256;
        case '?': return 31 * 256;
        case '@': return 32 * 256;
        case 'A': return 33 * 256;
        case 'B': return 34 * 256;
        case 'C': return 35 * 256;
        case 'D': return 36 * 256;
        case 'E': return 37 * 256;
        case 'F': return 38 * 256;
        case 'G': return 39 * 256;
        case 'H': return 40 * 256;
        case 'I': return 41 * 256;
        case 'J': return 42 * 256;
        case 'K': return 43 * 256;
        case 'L': return 44 * 256;
        case 'M': return 45 * 256;
        case 'N': return 46 * 256;
        case 'O': return 47 * 256;
        case 'P': return 48 * 256;
        case 'Q': return 49 * 256;
        case 'R': return 50 * 256;
        case 'S': return 51 * 256;
        case 'T': return 52 * 256;
        case 'U': return 53 * 256;
        case 'V': return 54 * 256;
        case 'W': return 55 * 256;
        case 'X': return 56 * 256;
        case 'Y': return 57 * 256;
        case 'Z': return 58 * 256;
        case '[': return 59 * 256;
        case '\b': return 60 * 256;
        case ']': return 61 * 256;
        case '^': return 62 * 256;
        case '_': return 63 * 256;
        case '`': return 64 * 256;
        case 'a': return 65 * 256;
        case 'b': return 66 * 256;
        case 'c': return 67 * 256;
        case 'd': return 68 * 256;
        case 'e': return 69 * 256;
        case 'f': return 70 * 256;
        case 'g': return 71 * 256;
        case 'h': return 72 * 256;
        case 'i': return 73 * 256;
        case 'j': return 74 * 256;
        case 'k': return 75 * 256;
        case 'l': return 76 * 256;
        case 'm': return 77 * 256;
        case 'n': return 78 * 256;
        case 'o': return 79 * 256;
        case 'p': return 80 * 256;
        case 'q': return 81 * 256;
        case 'r': return 82 * 256;
        case 's': return 83 * 256;
        case 't': return 84 * 256;
        case 'u': return 85 * 256;
        case 'v': return 86 * 256;
        case 'w': return 87 * 256;
        case 'x': return 88 * 256;
        case 'y': return 89 * 256;
        case 'z': return 90 * 256;
        case '{': return 91 * 256;
        case '|': return 92 * 256;
        case '}': return 93 * 256;
        case '~': return 94 * 256;
        default:
            if(!warning)
                printf("[warning] char %c does not exist in BigFont char lib.\n", c);
            warning = 1;
            return 0;//return space
    }
}

int print_char(char c, int xmin, int ymin, int color)
// print a 16x16 ascii char at (xmin, ymin)
{
    lcd_set_cursor(xmin, ymin, xmin+16-1, ymin+16-1);
    uint32_t *buf = (uint32_t *)calloc(16*16, sizeof(uint32_t));
    int i;
    for (i = 0; i < 16*16; i++)
        buf[i] = 0x80020000 | ( select_bit(BigFont, c2bigfont(c) + i) ? color : 0xFFFF);
    lcd_show_buf(buf, 16*16);
    free(buf);
}

int print_big_char(char c, int xmin, int ymin, int color)
// print a 32x32 ascii char at (xmin, ymin)
{
    lcd_set_cursor(xmin, ymin, xmin+32-1, ymin+32-1);
    uint32_t *buf = (uint32_t *)calloc(32*32, sizeof(uint32_t));
    int a, b;
    for (a = 0; a<16 ; a++)
        for (b = 0; b<16 ; b++)
        {
            {
                uint32_t res = 0x80020000 | ( select_bit(BigFont, c2bigfont(c) + a*16+b) ? color : 0xFFFF);
                buf[a*2*32+b*2] = res;
                buf[a*2*32+b*2+1] = res;
                buf[(a*2+1)*32+b*2] = res;
                buf[(a*2+1)*32+b*2+1] = res;
            }
        }
    lcd_show_buf(buf, 32*32);
    free(buf);
}

int print_string(char* string, int color, int xmin, int ymin)
{
    int i;
    for(i=0; string[i]!='\0'; i++)
    {
        print_char(string[i], xmin+i*16, ymin, color);
    }
    // printf("printed string %s to LCD.", string);
    return 0;
}

int print_big_string(char* string, int color, int xmin, int ymin)
{
    int i;
    for(i=0; string[i]!='\0'; i++)
    {
        print_big_char(string[i], xmin+i*32, ymin, color);
    }
    // printf("printed string %s to LCD.", string);
    return 0;
}

#endif