#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#include "gpio.h"

#define IO_MAP_BASE     0x1fd00000
#define IO_MAP_SIZE     0x10000
#define BTN_KEY_ADDR    0xf024
#define LCD_CTRL_ADDR   0xd000
#define TOUCH_SDA_ADDR  0xd004
#define TOUCH_SCL_ADDR  0xd008

int devmemfd;
void *map_base;
volatile uint32_t *btn_key;
volatile uint32_t *lcd_ctrl;
volatile uint32_t *touch_sda;
volatile uint32_t *touch_scl;

void initialize_map() {
  devmemfd = open("/dev/mem", O_RDWR|O_SYNC);
  if (devmemfd == -1) {  
    perror("init_map open failed");
    exit(1);
  }
  
  map_base = mmap(NULL, IO_MAP_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, devmemfd, IO_MAP_BASE);
  
  if (map_base == MAP_FAILED) {
    perror("init_map mmap failed");
    close(devmemfd);
    exit(1);
  }
  
  btn_key   = (void *)((uint8_t *)map_base + BTN_KEY_ADDR);
  lcd_ctrl  = (void *)((uint8_t *)map_base + LCD_CTRL_ADDR);
  touch_sda = (void *)((uint8_t *)map_base + TOUCH_SDA_ADDR);
  touch_scl = (void *)((uint8_t *)map_base + TOUCH_SCL_ADDR);
  printf("map_base:   %p\n", map_base);
  printf("btn_key:    %p\n", btn_key);
  printf("lcd_ctrl:   %p\n", lcd_ctrl);
  printf("touch_sda:  %p\n", lcd_ctrl);
  printf("touch_scl:  %p\n", lcd_ctrl);
}

void finalize_map() {
  munmap(map_base, IO_MAP_SIZE);
	close(devmemfd);
}

void lcd_init(uint16_t scan, uint16_t xs, uint16_t xe, uint16_t ys, uint16_t ye) {
  lcd_inst(0x3600);
  lcd_data(scan);
  lcd_inst(0x2a00);
  lcd_data(xs>>8);
  lcd_inst(0x2a01);
  lcd_data(xs&0xff);
  lcd_inst(0x2a02);
  lcd_data(xe>>8);
  lcd_inst(0x2a03);
  lcd_data(xe&0xff);
  lcd_inst(0x2b00);
  lcd_data(ys>>8);
  lcd_inst(0x2b01);
  lcd_data(ys&0xff);
  lcd_inst(0x2b02);
  lcd_data(ye>>8);
  lcd_inst(0x2b03);
  lcd_data(ye&0xff);
}

void lcd_write(uint16_t *data, uint32_t n) {
  uint32_t i;
  lcd_inst(0x2c00);
  for (i=0; i<n; i++)
    lcd_data(data[i]);
}

void lcd_fill(uint16_t color, uint32_t n) {
  uint32_t i;
  lcd_inst(0x2c00);
  for (i=0; i<n; i++)
    lcd_data(color);
}