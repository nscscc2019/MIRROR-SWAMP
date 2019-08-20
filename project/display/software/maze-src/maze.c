#include <unistd.h>

#include "maze.h"
#include "gpio.h"
#include "display.h"

int x = 0, y = 0;

#define getwallv(x, y)  (wall_v[y][x])
#define getwallh(x, y)  (wall_h[y][x])

static void drawwall(int x, int y, char vertical) {
  int real_x, real_y;
  real_x = 20 + 22 * (x + 1);
  real_y = 20 + 22 * (y + 1);
  if (vertical)
    display_vline(real_x, real_y - 20, real_y + 1, 0);
  else
    display_hline(real_x - 20, real_x + 1, real_y, 0);
}

static void draw_player(uint16_t color) {
  display_fill_rect(20+22*x+4, 20+22*x+18, 20+22*y+4, 20+22*y+18, color);
}

static void OnPaint() {
  int i, j;
  display_vline(20, 20, 461, 0);
  display_vline(461, 20, 461, 0);
  display_hline(20, 461, 20, 0);
  display_hline(20, 461, 461, 0);
  for (i = 0; i < WIDTH; i++) {
    for (j = 0; j < HEIGHT; j++) {
      if (getwallv(i, j)) drawwall(i, j, 1);
      if (getwallh(i, j)) drawwall(i, j, 0);
    }
  }
  display_fill_rect(20+22*19+4, 20+22*19+18, 20+22*19+4, 20+22*19+18, 0x001f);
  draw_player(0xf800);
}

static void OnMove(int dir) {
  // passable?
  if (dir == 0 && (x <= 0 || getwallv(x - 1, y))) return;
  if (dir == 1 && (y <= 0 || getwallh(x, y - 1))) return;
  if (dir == 2 && (x >= WIDTH - 1 || getwallv(x, y))) return;
  if (dir == 3 && (y >= HEIGHT - 1 || getwallh(x, y))) return;
  draw_player(0xffff);
  // perform move
  switch (dir) {
  case 0:
    x--;
    break;
  case 1:
    y--;
    break;
  case 2:
    x++;
    break;
  case 3:
    y++;
    break;
  }
  OnPaint();
}

void maze_main() {
  for (;;) {
    x = 0; y = 0;
    maze_gen();
    display_clear(0xffff);
    OnPaint();
    for (;;) {
      uint32_t btn = *btn_key;
      if (btn & 0x10)
        OnMove(0); // left
      else if (btn & 0x2)
        OnMove(1); // up
      else if (btn & 0x40)
        OnMove(2); // right
      else if (btn & 0x200)
        OnMove(3); // down
      if (x == WIDTH-1 && y == HEIGHT - 1)
        break;
      usleep(200000);
    }
  }
}
