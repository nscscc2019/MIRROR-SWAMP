#ifndef __MAZE_H
#define __MAZE_H

#define WIDTH     20
#define HEIGHT    20
#define MAX_MOVE  (WIDTH * HEIGHT)

char cell[HEIGHT][WIDTH];
char wall_v[HEIGHT][WIDTH - 1];
char wall_h[HEIGHT - 1][WIDTH];

void maze_gen();
void maze_main();

#endif