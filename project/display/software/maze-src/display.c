#include <stdint.h>

#include "gpio.h"

void display_clear(uint16_t color) {
  lcd_init(0, 0, 479, 0, 799);
  lcd_fill(color, 480*800);
}

void display_fill_rect(uint16_t x1, uint16_t x2, uint16_t y1, uint16_t y2, uint16_t color) {
  lcd_init(0, x1, x2-1, y1, y2-1);
  lcd_fill(color, (x2-x1)*(y2-y1));
}

void display_vline(uint16_t x, uint16_t y1, uint16_t y2, uint16_t color) {
  display_fill_rect(x, x+1, y1, y2, color);
}

void display_hline(uint16_t x1, uint16_t x2, uint16_t y, uint16_t color) {
  display_fill_rect(x1, x2, y, y+1, color);
}