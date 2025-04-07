// main.c - Kernel entry point

// Include main kernel header
#include "../include/kernel.h"

void start() {
    // Clear screen
    vga_clear(0x00); // Clear the screen with color 0x00 (black)

    // Initialize serial port
    serial_init();

    // Print "Hello, HssOS Kernel!" at position (0,0) with color 0x0F (white on black)
    kprintf(0, 0, 0x0F, "Hello, HssOS Kernel!");
    
    // Print version info with variables
    int major = 0;
    int minor = 1;
    kprintf(0, 1, 0x07, "Version: %d.%d", major, minor);
    
    // Print various data types using kprintf
    kprintf(0, 3, 0x0F, "String: %s", "This is a string");
    kprintf(0, 4, 0x0A, "Decimal: %d", 12345);
    kprintf(0, 5, 0x0B, "Hexadecimal: 0x%x", 0xABCD);
    kprintf(0, 6, 0x0C, "Character: %c", 'A');
    kprintf(0, 7, 0x0D, "Negative: %d", -9876);
    
    // Multiple format specifiers in one line
    kprintf(0, 9, 0x0F, "Multiple values: %s %d 0x%x %c", "Test", 42, 0xFF, '!');
    
    // Serial output
    serial_printf("HssOS Kernel started!\r\n");
    serial_printf("Version: %d.%d\r\n", major, minor);
    serial_printf("--------------------------------\r\n");
    serial_printf("Serial Port Diagnostics:\r\n");
    serial_printf("  String test: %s\r\n", "This is a serial string");
    serial_printf("  Decimal test: %d\r\n", 12345);
    serial_printf("  Hex test: 0x%x\r\n", 0xABCD);
    serial_printf("  Character test: %c\r\n", 'A');
    serial_printf("  Negative test: %d\r\n", -9876);
    serial_printf("--------------------------------\r\n");
    
    // VGA status message
    kprintf(0, 11, 0x0E, "Serial output initialized on COM1 (0x%x)", COM1);
    
    // Halt the CPU - we don't have anything else to do yet
    while(1) {
        // Infinite loop to prevent the CPU from executing random memory
        __asm__("hlt");
    }
}
