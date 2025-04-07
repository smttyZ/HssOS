#ifndef IO_H
#define IO_H

// Define COM port addresses
#define COM1 0x3F8
#define COM2 0x2F8
#define COM3 0x3E8
#define COM4 0x2E8

// Port I/O functions
static inline unsigned char inb(unsigned short port) {
    unsigned char value;
    __asm__ volatile("inb %1, %0" : "=a"(value) : "Nd"(port));
    return value;
}

static inline void outb(unsigned short port, unsigned char value) {
    __asm__ volatile("outb %0, %1" : : "a"(value), "Nd"(port));
}

/*
* Prints a string to the screen using the VGA buffer.
* @param str The string to print.
* @param x The x coordinate of the string.
* @param y The y coordinate of the string.
* @param color The color of the string.
*/
void kps(const char *str, int x, int y, int color);

/*
* Prints an integer to the screen using the VGA buffer.
* @param num The integer to print.
* @param base The base to use (10 for decimal, 16 for hexadecimal).
* @param x The x coordinate of the number.
* @param y The y coordinate of the number.
* @param color The color of the number.
*/
void kps_int(int num, int base, int x, int y, int color);

/*
* Printf-like function for the kernel that supports formatting.
* Supports %s (string), %d (decimal), %x (hexadecimal), %c (character)
* @param x The x coordinate to start printing at
* @param y The y coordinate to start printing at
* @param color The color of the text
* @param format The format string
* @param ... Variable arguments corresponding to format specifiers
* @return The number of characters printed
*/
int kprintf(int x, int y, int color, const char *format, ...);

/*
* Clears the screen via the VGA buffer.
* @param color The color to fill the screen with.
* @return None
* @note This function uses the VGA buffer to clear the screen.
*/
void vga_clear(unsigned char color);

/*
* Converts an integer to a string.
* @param num The integer to convert.
* @param str The string to store the result.
* @param base The base to use for conversion (e.g., 10 for decimal, 16 for hexadecimal).
* @return None
*/
void itoa(int num, char *str, int base);

/*
* Checks if the serial port is ready to send data.
* @return 1 if ready, 0 otherwise.
*/
int serial_is_ready();

/*
* Sends a character to the serial port.
* @param c The character to send.
* @return None
*/
void serial_send_char(char c);

/*
* Sends a string to the serial port.
* @param str The string to send.
* @return None
*/
void serial_send_string(const char *str);

/*
* Printf-like function for the serial port.
* Supports %s (string), %d (decimal), %x (hexadecimal), %c (character)
* @param format The format string
* @param ... Variable arguments corresponding to format specifiers
* @return The number of characters printed
*/
int serial_printf(const char *format, ...);

/*
* Serial port initialization.
* @return None
*/
void serial_init();


#endif /* IO_H */