#ifndef __GPIO_H
#define __GPIO_H

#include <stdint.h>

void initialize_map();
void finalize_map();
void lcd_init(uint16_t scan, uint16_t xs, uint16_t xe, uint16_t ys, uint16_t ye);
void lcd_write(uint16_t *data, uint32_t n);
void lcd_fill(uint16_t color, uint32_t n);

extern volatile uint32_t *btn_key;
extern volatile uint32_t *lcd_ctrl;
extern volatile uint32_t *touch_sda;
extern volatile uint32_t *touch_scl;

#define lcd_inst(inst) (*lcd_ctrl = (1 << 31) | (1 << 16) | (inst))
#define lcd_data(data) (*lcd_ctrl = (1 << 31) | (2 << 16) | (data))

#endif
