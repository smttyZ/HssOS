#ifndef IO_H
#define IO_H

/*
* Prints a string to the screen using the VGA buffer.
* @param str The string to print.
* @param x The x coordinate of the string.
* @param y The y coordinate of the string.
* @param color The color of the string.
*/
void ps(const char *str, int x, int y, int color);

#endif /* IO_H */