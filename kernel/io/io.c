// io.c - I/O functions

#include "../include/io.h"

/*
* Prints a string to the screen using the VGA buffer.
* @param str The string to print.
* @param x The x coordinate of the string.
* @param y The y coordinate of the string.
* @param color The color of the string.
*/
void ps(const char *str, int x, int y, int color) {
    // VGA buffer address
    volatile unsigned short *vga_buffer = (volatile unsigned short *)0xB8000;

    // Calculate the starting position of the string
    int offset = (y * 80 + x);

    // Loop through the string and print each character
    for (int i = 0; str[i] != '\0'; i++) {
        // Each character takes up 2 bytes: 1 for the character, 1 for the color
        vga_buffer[offset + i] = ((unsigned short)str[i] | (unsigned short)(color << 8));
    }
}