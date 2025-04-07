// main.c - Kernel entry point

// Include main kernel header
#include "../include/kernel.h"

void start() {
    // Print "Hello, HssOS Kernel!" at position (0,0) with color 0x0F (white on black)
    ps("Hello, HssOS Kernel!", 0, 0, 0x0F);
    
    // Halt the CPU - we don't have anything else to do yet
    while(1) {
        // Infinite loop to prevent the CPU from executing random memory
        __asm__("hlt");
    }
}
