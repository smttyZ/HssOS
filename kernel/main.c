// kernel/main.c - Minimal kernel for HssOS

// This is a bare-bones kernel that simply displays "KERNEL" 
// on the screen and allows safe exit via ESC key

// Structure for IDT gate descriptor
typedef struct {
    unsigned short offset_low;
    unsigned short selector;
    unsigned char zero;
    unsigned char type_attr;
    unsigned short offset_high;
} __attribute__((packed)) idt_gate_t;

// Structure for IDT pointer
typedef struct {
    unsigned short limit;
    unsigned int base;
} __attribute__((packed)) idt_ptr_t;

// Declare IDT
#define IDT_ENTRIES 256
idt_gate_t idt[IDT_ENTRIES];
idt_ptr_t idt_ptr;

// Function to set an IDT gate
static inline void set_idt_gate(int n, unsigned int handler) {
    idt[n].offset_low = (handler & 0xFFFF);
    idt[n].selector = 0x08; // Code segment
    idt[n].zero = 0;
    idt[n].type_attr = 0x8E; // Present, Ring 0, 32-bit Interrupt Gate
    idt[n].offset_high = ((handler >> 16) & 0xFFFF);
}

// Function to load the IDT
static inline void load_idt() {
    idt_ptr.limit = sizeof(idt_gate_t) * IDT_ENTRIES - 1;
    idt_ptr.base = (unsigned int)&idt;
    __asm__ volatile ("lidt %0" : : "m"(idt_ptr));
}

// Default exception handler - no interrupt attribute
void default_handler() {
    // Just display 'E' for error at top-right to indicate an exception
    volatile char *video = (volatile char*)0xB8000;
    video[158] = 'E'; // Position (79, 0)
    video[159] = 0x4F; // White on red background
    
    // Halt the CPU
    __asm__ volatile("cli; hlt");
}

// Function to output a character to screen
static inline void putchar(int x, int y, char c, char attr) {
    // VGA memory starts at 0xB8000
    volatile char *video = (volatile char*)0xB8000;
    
    // Each character takes two bytes (char and attribute)
    int offset = (y * 80 + x) * 2;
    
    // Write character and attribute
    video[offset] = c;
    video[offset + 1] = attr;
}

// Clear the screen (fill with spaces)
static inline void clear_screen() {
    for (int y = 0; y < 25; y++) {
        for (int x = 0; x < 80; x++) {
            putchar(x, y, ' ', 0x07);  // Light gray on black
        }
    }
}

// Main kernel function - this is where execution starts
void kernel_main() {
    // Minimal approach - just clear screen and display text
    
    // Clear screen by directly writing to video memory
    volatile unsigned short *video = (volatile unsigned short*)0xB8000;
    for (int i = 0; i < 80 * 25; i++) {
        video[i] = 0x0720; // Attribute 0x07 (light gray on black), character 0x20 (space)
    }
    
    // Display "KERNEL" in green - directly to video memory
    volatile unsigned short *display = (volatile unsigned short*)0xB8000;
    char *text = "KERNEL LOADED";
    unsigned char attr = 0x0A;  // Green on black
    
    for (int i = 0; text[i] != '\0'; i++) {
        display[i] = (attr << 8) | text[i];
    }
    
    // Display simple exit message
    volatile unsigned short *exitMsg = (volatile unsigned short*)0xB8000 + (24 * 80);
    char *exit_text = "Press ESC to exit";
    unsigned char exit_attr = 0x07;  // Light gray on black
    
    for (int i = 0; exit_text[i] != '\0'; i++) {
        exitMsg[i] = (exit_attr << 8) | exit_text[i];
    }
    
    // Wait for ESC key
    while (1) {
        // Check if there's keyboard data available
        unsigned char status = 0;
        __asm__ volatile("inb $0x64, %0" : "=a"(status));
        
        if (status & 1) {  // Is there data available?
            unsigned char keycode = 0;
            __asm__ volatile("inb $0x60, %0" : "=a"(keycode));
            
            // Simple debug output - show keystroke at position (0,5)
            char key_debug[3] = "00";
            unsigned char hi = (keycode >> 4) & 0xF;
            unsigned char lo = keycode & 0xF;
            key_debug[0] = hi < 10 ? '0' + hi : 'A' + (hi - 10);
            key_debug[1] = lo < 10 ? '0' + lo : 'A' + (lo - 10);
            
            volatile unsigned short *keypos = (volatile unsigned short*)0xB8000 + (5 * 80);
            keypos[0] = (0x0E << 8) | 'K';  // Yellow K
            keypos[1] = (0x0E << 8) | 'e';  // Yellow e
            keypos[2] = (0x0E << 8) | 'y';  // Yellow y
            keypos[3] = (0x0E << 8) | ':';  // Yellow :
            keypos[4] = (0x0E << 8) | ' ';  // Yellow space
            keypos[5] = (0x0E << 8) | key_debug[0];  // Yellow first hex digit
            keypos[6] = (0x0E << 8) | key_debug[1];  // Yellow second hex digit
            
            if (keycode == 0x01) {  // ESC key scancode = 0x01
                // Display "Exiting..." message in red
                volatile unsigned short *video = (volatile unsigned short*)0xB8000;
                for (int i = 0; i < 80 * 25; i++) {
                    video[i] = 0x0720; // Clear screen
                }
                
                char *exit_msg = "Exiting...";
                unsigned char exit_attr = 0x0C;  // Red on black
                
                for (int i = 0; exit_msg[i] != '\0'; i++) {
                    video[i] = (exit_attr << 8) | exit_msg[i];
                }
                
                // Try all methods to exit QEMU
                // Method 1: QEMU isa-debug-exit device (if available)
                __asm__ volatile("outb %%al, %%dx" : : "a"(0x31), "d"(0xf4));
                
                // Method 2: QEMU shutdown device
                __asm__ volatile("outw %%ax, %%dx" : : "a"(0x2000), "d"(0x604));
                
                // Method 3: ACPI poweroff (may not work in all QEMU configs)
                __asm__ volatile(
                    "movw $0x2000, %%ax\n"
                    "movw $0x604, %%dx\n"
                    "outw %%ax, %%dx"
                    : : : "ax", "dx"
                );
                
                // Method 4: If all else fails, just halt
                __asm__ volatile("cli; hlt");
                
                // This will never be reached, but just in case
                while(1) {}
            }
        }
        
        // Smaller delay, will poll keyboard more frequently
        for (volatile unsigned int i = 0; i < 100000; i++) { }
    }
}

// Entry point - this sets up the environment and calls kernel_main
void _start() {
        // No BSS initialization for now as it might be causing issues
    
    // Set up proper stack
    __asm__ volatile(
        // Ensure we have a proper stack pointer
        "movl $0x90000, %esp\n"
        "movl $0x90000, %ebp\n"
        
        // Clear general purpose registers
        "xorl %eax, %eax\n"
        "xorl %ebx, %ebx\n"
        "xorl %ecx, %ecx\n"
        "xorl %edx, %edx\n"
        "xorl %esi, %esi\n"
        "xorl %edi, %edi\n"
    );
    
    // Call the main kernel function
    kernel_main();
    
    // If we ever return, halt the CPU
    __asm__ volatile(
        "cli\n"
        "hlt"
    );
    
    // This should never be reached
    while (1) {}
}