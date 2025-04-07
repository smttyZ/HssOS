// main.c - Kernel entry point

// Include main kernel header
#include "../include/kernel.h"

// Place the start function in a special section to ensure it's at the beginning
__attribute__((section(".text.start")))
void start() {
    // Write directly to VGA memory as a first test
    volatile unsigned short *vga_buffer = (volatile unsigned short *)0xB8000;
    
    // Print "K" in white on black at the top left to indicate kernel entry
    vga_buffer[0] = 'K' | (0x0F << 8);
    
    // Small delay
    for (volatile int i = 0; i < 10000000; i++);
    
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

    kprintf(0, 2, 0x0E, "Initializing IDT...");
    idt_init(); // Initialize the IDT
    kprintf(0, 3, 0x0a, "IDT initialized with %d entries", 256);

    
    // Print various data types using kprintf
    kprintf(0, 4, 0x0F, "String: %s", "This is a string");
    kprintf(0, 5, 0x0A, "Decimal: %d", 12345);
    kprintf(0, 6, 0x0B, "Hexadecimal: 0x%x", 0xABCD);
    kprintf(0, 7, 0x0C, "Character: %c", 'A');
    kprintf(0, 8, 0x0D, "Negative: %d", -9876);
    
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
    
    // Test IDT by generating different interrupts
    kprintf(0, 13, 0x0E, "Testing IDT with direct interrupts...");
    serial_printf("Testing IDT with direct interrupt calls...\r\n");
    
    // Small delay to ensure messages are displayed
    for (volatile int i = 0; i < 10000000; i++);
    
    // Choose which interrupt to test (uncomment one):
    
    // INT 0: Divide by Zero
    serial_printf("Triggering INT 0 (divide by zero)...\r\n");
    __asm__ volatile("int $0");
    
    // INT 3: Breakpoint (normally used by debuggers)
    // serial_printf("Triggering INT 3 (breakpoint)...\r\n");
    // __asm__ volatile("int $3");
    
    // INT 13: General Protection Fault
    // serial_printf("Triggering INT 13 (general protection fault)...\r\n");
    // __asm__ volatile("int $13");
    
    // We should never reach here if IDT is working
    kprintf(0, 14, 0x04, "ERROR: IDT failed to catch interrupt!");
    
    // Halt the CPU - we don't have anything else to do yet
    while(1) {
        // Infinite loop to prevent the CPU from executing random memory
        __asm__("hlt");
    }
}
