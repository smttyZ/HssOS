// io.c - I/O functions

#include "../include/io.h"

// Define a simple implementation for variable arguments
typedef __builtin_va_list va_list;
#define va_start(ap, param) __builtin_va_start(ap, param)
#define va_arg(ap, type) __builtin_va_arg(ap, type)
#define va_end(ap) __builtin_va_end(ap)

// Serial port functions are using COM1 defined in the header

void kps(const char *str, int x, int y, int color) {
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

void vga_clear(unsigned char color) {
    // VGA buffer address
    volatile unsigned short *vga_buffer = (volatile unsigned short *)0xB8000;

    // Fill the VGA buffer with the specified color
    for (int i = 0; i < 80 * 25; i++) {
        vga_buffer[i] = (unsigned short)(color << 8);
    }
}

void itoa(int num, char *str, int base) {
    int i = 0;
    int isNegative = 0;

    // Handle 0 explicitly
    if (num == 0) {
        str[i++] = '0';
        str[i] = '\0';
        return;
    }

    // Handle negative numbers for base 10
    if (num < 0 && base == 10) {
        isNegative = 1;
        num = -num;
    }

    // Process individual digits
    while (num != 0) {
        int remainder = num % base;
        str[i++] = (remainder > 9) ? (remainder - 10) + 'A' : remainder + '0';
        num /= base;
    }

    // If the number is negative, append '-'
    if (isNegative) {
        str[i++] = '-';
    }

    // Null-terminate the string
    str[i] = '\0';

    // Reverse the string
    for (int j = 0; j < i / 2; j++) {
        char temp = str[j];
        str[j] = str[i - j - 1];
        str[i - j - 1] = temp;
    }
}

void kps_int(int num, int base, int x, int y, int color) {
    // Buffer to hold the string representation
    char buffer[33]; // 32 bits plus null terminator
    
    // Convert the number to a string
    itoa(num, buffer, base);
    
    // Print the string
    kps(buffer, x, y, color);
}

int kprintf(int x, int y, int color, const char *format, ...) {
    char buffer[1024]; // Buffer to hold the formatted string
    char num_buffer[33]; // Buffer to hold converted numbers
    int buffer_pos = 0; // Current position in the buffer
    int chars_printed = 0; // Number of characters printed
    
    va_list args;
    va_start(args, format);
    
    // Process the format string
    for (int i = 0; format[i] != '\0'; i++) {
        if (format[i] != '%') {
            // Regular character, just add it to the buffer
            buffer[buffer_pos++] = format[i];
            chars_printed++;
        } else {
            // Format specifier, handle it based on the next character
            i++; // Move to the character after '%'
            
            switch (format[i]) {
                case 's': {
                    // String
                    const char *str = va_arg(args, const char *);
                    for (int j = 0; str[j] != '\0'; j++) {
                        buffer[buffer_pos++] = str[j];
                        chars_printed++;
                    }
                    break;
                }
                
                case 'd': {
                    // Decimal (base 10)
                    int num = va_arg(args, int);
                    itoa(num, num_buffer, 10);
                    for (int j = 0; num_buffer[j] != '\0'; j++) {
                        buffer[buffer_pos++] = num_buffer[j];
                        chars_printed++;
                    }
                    break;
                }
                
                case 'x': {
                    // Hexadecimal (base 16)
                    int num = va_arg(args, int);
                    itoa(num, num_buffer, 16);
                    for (int j = 0; num_buffer[j] != '\0'; j++) {
                        buffer[buffer_pos++] = num_buffer[j];
                        chars_printed++;
                    }
                    break;
                }
                
                case 'c': {
                    // Character
                    char c = (char)va_arg(args, int); // char is promoted to int in var args
                    buffer[buffer_pos++] = c;
                    chars_printed++;
                    break;
                }
                
                case '%': {
                    // Literal '%'
                    buffer[buffer_pos++] = '%';
                    chars_printed++;
                    break;
                }
                
                default: {
                    // Unknown format specifier, just print it as is
                    buffer[buffer_pos++] = '%';
                    buffer[buffer_pos++] = format[i];
                    chars_printed += 2;
                    break;
                }
            }
        }
    }
    
    // Null-terminate the buffer
    buffer[buffer_pos] = '\0';
    
    // Print the buffer
    kps(buffer, x, y, color);
    
    va_end(args);
    return chars_printed;
}

int serial_is_ready() {
    return inb(COM1 + 5) & 0x20; // Check if the transmitter holding register is empty
}

void serial_send_char(char c) {
    while (!serial_is_ready()); // Wait until the serial port is ready
    outb(COM1, c); // Send the character to the serial port
}

void serial_send_string(const char *str) {
    while (*str) {
        serial_send_char(*str++);
    }
}

int serial_printf(const char *format, ...) {
    char buffer[1024]; // Buffer to hold the formatted string
    char num_buffer[33]; // Buffer to hold converted numbers
    int buffer_pos = 0; // Current position in the buffer
    int chars_printed = 0; // Number of characters printed
    
    va_list args;
    va_start(args, format);
    
    // Process the format string
    for (int i = 0; format[i] != '\0'; i++) {
        if (format[i] != '%') {
            // Regular character, just add it to the buffer
            buffer[buffer_pos++] = format[i];
            chars_printed++;
        } else {
            // Format specifier, handle it based on the next character
            i++; // Move to the character after '%'
            
            switch (format[i]) {
                case 's': {
                    // String
                    const char *str = va_arg(args, const char *);
                    for (int j = 0; str[j] != '\0'; j++) {
                        buffer[buffer_pos++] = str[j];
                        chars_printed++;
                    }
                    break;
                }
                
                case 'd': {
                    // Decimal (base 10)
                    int num = va_arg(args, int);
                    itoa(num, num_buffer, 10);
                    for (int j = 0; num_buffer[j] != '\0'; j++) {
                        buffer[buffer_pos++] = num_buffer[j];
                        chars_printed++;
                    }
                    break;
                }
                
                case 'x': {
                    // Hexadecimal (base 16)
                    int num = va_arg(args, int);
                    itoa(num, num_buffer, 16);
                    for (int j = 0; num_buffer[j] != '\0'; j++) {
                        buffer[buffer_pos++] = num_buffer[j];
                        chars_printed++;
                    }
                    break;
                }
                
                case 'c': {
                    // Character
                    char c = (char)va_arg(args, int); // char is promoted to int in var args
                    buffer[buffer_pos++] = c;
                    chars_printed++;
                    break;
                }
                
                case '%': {
                    // Literal '%'
                    buffer[buffer_pos++] = '%';
                    chars_printed++;
                    break;
                }
                
                default: {
                    // Unknown format specifier, just print it as is
                    buffer[buffer_pos++] = '%';
                    buffer[buffer_pos++] = format[i];
                    chars_printed += 2;
                    break;
                }
            }
        }
    }
    
    // Null-terminate the buffer
    buffer[buffer_pos] = '\0';
    
    // Send the buffer to serial port
    serial_send_string(buffer);
    
    va_end(args);
    return chars_printed;
}

void serial_init() {
    outb(COM1 + 1, 0x00); // Disable all interrupts
    outb(COM1 + 3, 0x80); // Enable DLAB (set baud rate divisor)
    outb(COM1 + 0, 0x03); // Set divisor to 3 (38400 baud rate)
    outb(COM1 + 1, 0x00); // High byte of divisor (0)
    outb(COM1 + 3, 0x03); // 8 data bits, no parity, 1 stop bit
    outb(COM1 + 2, 0xC7); // Enable FIFO, clear them, with 14-byte threshold
    outb(COM1 + 4, 0x0B); // IRQs enabled, RTS/DSR set
    
    // Test serial port
    outb(COM1 + 4, 0x1E); // Set in loopback mode to test
    outb(COM1, 0xAE);     // Send test byte
    
    // Check if serial port is working properly
    if (inb(COM1) != 0xAE) {
        // Serial port is not working, handle error (maybe print to VGA)
        kps("Serial port COM1 initialization failed!", 0, 24, 0x04);
        return;
    }
    
    // If we get here, serial port is working
    outb(COM1 + 4, 0x0F); // Set to normal operation mode (not loopback)
    
    // Send initialization message to serial console
    serial_printf("HssOS Serial Console Initialized - COM1 at %x\r\n", COM1);
}