#include <stdlib.h>

#include "maze.h"

static int count = 0;

static void removewall(int x1, int y1, int x2, int y2) {
  int dx = x2 - x1;
  int dy = y2 - y1;
  if (dx == 1) wall_v[y1][x1] = 0;
  if (dx == -1) wall_v[y1][x1 - 1] = 0;
  if (dy == 1) wall_h[y1][x1] = 0;
  if (dy == -1) wall_h[y1 - 1][x1] = 0;
}

static void genmaze(int x, int y) {
  count++;
  cell[y][x] = 1;
  int neighbor[4][2];
  neighbor[0][0] = x - 1;
  neighbor[0][1] = y;
  neighbor[1][0] = x + 1;
  neighbor[1][1] = y;
  neighbor[2][0] = x;
  neighbor[2][1] = y - 1;
  neighbor[3][0] = x;
  neighbor[3][1] = y + 1;
  int table[4];
  int i, j, k, x2, y2;
  for (i = 0; i < 4; i++) table[i] = i;
  for (i = 4; i > 0; i--) {
    j = rand() % i;
    k = table[j];
    table[j] = table[i - 1];
    x2 = neighbor[k][0];
    y2 = neighbor[k][1];
    if (x2 >= 0 && x2 < WIDTH && y2 >= 0 && y2 < HEIGHT) {
      if (!cell[y2][x2]) {
        removewall(x, y, x2, y2);
        genmaze(x2, y2);
      }
    }
  }
}

void maze_gen() {
  int i, j;
  for (i = 0; i < WIDTH; i++)
    for (j = 0; j < HEIGHT; j++)
      cell[j][i] = 0;
  for (i = 0; i < WIDTH - 1; i++)
    for (j = 0; j < HEIGHT; j++)
      wall_v[j][i] = 1;
  for (i = 0; i < WIDTH; i++)
    for (j = 0; j < HEIGHT - 1; j++)
      wall_h[j][i] = 1;
  genmaze(rand() % WIDTH, rand() % HEIGHT);
}