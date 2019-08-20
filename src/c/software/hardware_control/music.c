//mipsel-linux-gcc test.c -o test -static
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <errno.h>
#include <sys/syscall.h>
#include <linux/unistd.h>
#include "display_lib.h"

uint32_t key_map[10] =
    {
        0x00000000,
        0x8000f601,
        0x8000db3a,
        0x8000c350,
        0x8000b8ad,
        0x8000a46b,
        0x8000927c,
        0x80008278};

//NOTE:
//we define note map as:
//0 低音 1234567
//1 中音 1234567
//2 高音 1234567
//3 #低音 12456
//4 #中音 12456
//5 #高音 12456
uint32_t full_map[61] =
    {
        0x0,
        0x8000F6F2,
        0x8000DBF9,
        0x8000C3E7,
        0x8000B8AD,
        0x8000A46B,
        0x8000927C,
        0x800082BC,
        0x0,
        0x0,
        0x0,
        0x80007B3C,
        0x80006DCD,
        0x800061CD,
        0x80005C56,
        0x80005250,
        0x8000493E,
        0x8000414D,
        0x0,
        0x0,
        0x0,
        0x80003D9E,
        0x800036E6,
        0x800030E6,
        0x80002E2B,
        0x8000291A,
        0x8000249F,
        0x800020A2,
        0x0,
        0x0,
        0x0,
        0x8000E8AE,
        0x8000CF3E,
        0x0,
        0x8000AEAB,
        0x80009B4F,
        0x80008A4F,
        0x0,
        0x0,
        0x0,
        0x0,
        0x80007457,
        0x8000679F,
        0x0,
        0x80005737,
        0x80004DA7,
        0x80004527,
        0x0,
        0x0,
        0x0,
        0x0,
        0x80003A2B,
        0x800033CF,
        0x0,
        0x80002B94,
        0x800026CD,
        0x80002293,
        0x0,
        0x0,
        0x0};

int xon[300] = {
    //prelude: lover....
    6, 11, 0, 6, 11, 0, 6, 5, 0, 0, 6, 11, 0, 7, 11, 0, 0,
    //prelude: pure music
    7, 11, 36, 36, 7, 11, 36, 0, 6, 0, 6, 6, 5, 7, 11, 36, 36, 7, 11, 36, 0, 6, 0, 6, 0, 6, 6, 5, 7, 11, 36, 36, 7, 11, 36, 0, 6, 0, 6, 6, 5, 0,
    44, 15, 16, 46, 16, 15, 16, 15, 14, 42, 14, 13, 12, 11, 36, 0, 6, 6, 0, 5, 0, 0,
    //main:
    16, 16, 16, 12, 12, 11, 12, 14, 13, 13, 0, 16, 13, 13, 12, 12, 11, 12, 13, 16, 13, 0,
    4, 4, 4, 4, 5, 4, 4, 5, 4, 0, 4, 4, 4, 4, 4, 7, 7, 1, 1, 7, 0,
    //!!!!
    6, 0, 12, 11, 11, 7, 7, 7, 11, 7, 6, 6, 0, 12, 11, 7, 7, 7, 11, 7, 6,
    6, 0, 12, 11, 11, 7, 7, 11, 11, 7, 6, 0, 13, 12, 12, 11, 7, 11, 7, 6, 7, 6,
    //!!!! again
    6, 0, 12, 11, 11, 7, 7, 7, 11, 7, 6, 6, 0, 12, 11, 7, 7, 7, 11, 7, 6,
    6, 0, 12, 11, 11, 7, 7, 11, 11, 7, 6, 0, 13, 12, 12, 11, 7, 11, 7, 6, 7, 6,

    6, 11, 0, 6, 11, 0, 6, 5, 0, 0, 6, 11, 0, 7, 11, 0, 0};

inline void wait(int t)
{
    volatile int i = 0;
    while (i < t)
        i++;
}

void play_note(int note, int length, int interval)
{
    static int servo = 0;
    if (!note)
    {
        if (servo)
        {
            syscall(__NR_Linux + __NR_gpio_control, 0xbfd0f050, 0x80006000, 0);
            servo = 0;
        }
        else
        {
            syscall(__NR_Linux + __NR_gpio_control, 0xbfd0f050, 0x80010000, 0);
            servo = 1;
        }
    }
    syscall(__NR_Linux + __NR_gpio_control, 0xbfd0f04c, 0xc0000000, 0);    //light LED
    syscall(__NR_Linux + __NR_gpio_control, 0xbfd0f048, key_map[note], 0); //play note
    wait(length);
    syscall(__NR_Linux + __NR_gpio_control, 0xbfd0f04c, 0x00000000, 0); //close LED
    syscall(__NR_Linux + __NR_gpio_control, 0xbfd0f048, 0x00000000, 0); //stop playing note
    wait(interval);
    return;
}

void xon_note(int note, int length, int interval)
{
    syscall(__NR_Linux + __NR_gpio_control, 0xbfd0f048, full_map[note], 0);
    wait(length);
    syscall(__NR_Linux + __NR_gpio_control, 0xbfd0f048, 0x00000000, 0);
    wait(interval);
    return;
}

void mMIDI_note(int note, int length, int interval)
{
    static int servo = 0;
    if (!note)
    {
        if (servo)
        {
            syscall(__NR_Linux + __NR_gpio_control, 0xbfd0f050, 0x80006000, 0);
            servo = 0;
        }
        else
        {
            syscall(__NR_Linux + __NR_gpio_control, 0xbfd0f050, 0x80010000, 0);
            servo = 1;
        }
    }
    if (!note)
    {
        syscall(__NR_Linux + __NR_gpio_control, 0xbfd0f048, 0x0, 0);
    }
    else
    {
        syscall(__NR_Linux + __NR_gpio_control, 0xbfd0f048, note | 0x80000000, 0);
        syscall(__NR_Linux + __NR_gpio_control, 0xbfd0f04c, 0xc0000000, 0); //light LED
    }
    wait(length);
    syscall(__NR_Linux + __NR_gpio_control, 0xbfd0f048, 0x00000000, 0);
    syscall(__NR_Linux + __NR_gpio_control, 0xbfd0f04c, 0x00000000, 0); //close LED

    wait(interval);
    return;
}

int main()
{

    int mode, length = 1200000, interval = 200000;
    while (1)
    {
        printf("BGM player: input mode:\n");
        printf("0: keyboard   1: player    2: settings    5: mmidi player\n");
        scanf("%d", &mode);
        if (mode == 2)
        {
            printf("note length:\n");
            scanf("%d", &length);
            printf("note interval:\n");
            scanf("%d", &interval);
        }
        if (mode == 0)
        {
            while (1)
            {
                uint32_t addr, data, num, key;
                num = 2;
                addr = 0xbfd0f040 + (num << 2);
                printf("input key:");
                scanf("%d", &key);
                {
                    play_note(key, length, interval);
                    // syscall(__NR_Linux + __NR_gpio_control, addr, key_map[key], 0);
                    // printf("NEW KEY SENT\n");
                }
            }
        }
        if (mode == 1)
        {
            int xxx[48] = {1, 1, 5, 5, 6, 6, 5, 0, 4, 4, 3, 3, 2, 2, 1, 0, 5, 5, 4, 4, 3, 3, 2, 0, 5, 5, 4, 4, 3, 3, 2, 0, 1, 1, 5, 5, 6, 6, 5, 0, 4, 4, 3, 3, 2, 2, 1};
            int jht[70] = {3, 3, 2, 3, 0, 3, 5, 3, 2, 3, 0, 1, 1, 2, 3, 5, 3, 0, 2, 2, 1, 2, 0, 3, 5, 3, 6, 5, 0, 6, 5, 5, 3, 5, 0, 3, 2, 3, 5, 3, 2, 1, 0, 3, 5, 3, 6, 5, 0, 6, 5, 5, 3, 5, 0, 3, 2, 3, 5, 3, 2, 1, 1, 2, 1, 0};
            int i;
            for (i = 0; i < sizeof(jht) / sizeof(int); i++)
            {
                play_note(jht[i], length, interval);
            }
        }
        if (mode == 3)
        {
            int jht[70] = {3, 3, 2, 3, 0, 3, 5, 3, 2, 3, 0, 1, 1, 2, 3, 5, 3, 0, 2, 2, 1, 2, 0, 3, 5, 3, 6, 5, 0, 6, 5, 5, 3, 5, 0, 3, 2, 3, 5, 3, 2, 1, 0, 3, 5, 3, 6, 5, 0, 6, 5, 5, 3, 5, 0, 3, 2, 3, 5, 3, 2, 1, 1, 2, 1, 0};
            int i;
            while (syscall(__NR_Linux + __NR_gpio_control, 0xbfd0f040, 0x00000000, 1))
                ;
            for (i = 0; i < sizeof(jht) / sizeof(int); i++)
            {
                play_note(jht[i], length, interval);
            }
        }
        if (mode == 4)
        {
            //play xon
            int i;
            for (i = 0; i < sizeof(xon) / sizeof(int); i++)
            {
                xon_note(xon[i], length, interval);
            }
        }
        if (mode == 5)
        {
            int mMIDI[1024];
            int int_array[1024];
            char filename[20];
            printf("input mMIDI filename:");
            scanf("%s", &filename);
            FILE *fp = fopen(filename, "r");
            // FILE *fp = fopen("lemon.mmidi", "r");
            int j = 0;
            while (!feof(fp))
            {
                fscanf(fp, "%d %d", &(mMIDI[j]), &(int_array[j])); //读取一行
                j++;
            }
            fclose(fp); //关闭文件
            int i = 0;
            while (i < j)
            {
                mMIDI_note(mMIDI[i], int_array[i] * 12000, 60000);
                i++;
            }
            return 0;
        }
    }
}
