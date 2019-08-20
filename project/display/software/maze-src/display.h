#ifndef __DISPLAY_H
#define __DISPLAY_H

#include <stdint.h>

void display_clear(uint16_t color);
void display_fill_rect(uint16_t x1, uint16_t x2, uint16_t y1, uint16_t y2, uint16_t color);
void display_vline(uint16_t x, uint16_t y1, uint16_t y2, uint16_t color);
void display_hline(uint16_t x1, uint16_t x2, uint16_t y, uint16_t color);

#endif