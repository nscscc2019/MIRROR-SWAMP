#!/bin/bash

mipsel-linux-gcc main.c gpio.c display.c maze.c mazegen.c -o maze -static
