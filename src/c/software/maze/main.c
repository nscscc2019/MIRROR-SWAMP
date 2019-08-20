#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <time.h>

#include "maze.h"

int main() {
  initialize_map();
  srand(time(NULL));
  maze_main();
  finalize_map();
}