// kernel/core/idt/ idt.c
#include "../include/idt.h"

// Create space for our IDT entries
struct idt_entry idt_entries[256];
struct idt_ptr idtp;

// Load the IDT - implemented in assembly
extern void load_idt_asm(struct idt_ptr* idt_ptr);

// Set an IDT gate (entry)
void idt_set_gate(int num, uint32_t base, uint16_t sel, uint8_t flags) {
    idt_entries[num].offset_low = base & 0xFFFF;
    idt_entries[num].offset_high = (base >> 16) & 0xFFFF;
    idt_entries[num].selector = sel;
    idt_entries[num].zero = 0;
    idt_entries[num].type_attr = flags;
}

// Initialize the IDT
void idt_init() {
    // Set up the IDT pointer
    idtp.limit = (sizeof(struct idt_entry) * 256) - 1;
    idtp.base = (uint32_t)&idt_entries;

    // Clear out the entire IDT
    for (int i = 0; i < 256; i++) {
        idt_set_gate(i, 0, 0, 0);
    }

    // Set up exception handlers (ISRs 0-31)
    idt_set_gate(0, (uint32_t)isr0, 0x08, 0x8E);  // Division by Zero
    idt_set_gate(1, (uint32_t)isr1, 0x08, 0x8E);  // Debug Exception
    idt_set_gate(2, (uint32_t)isr2, 0x08, 0x8E);  // Non-Maskable Interrupt
    idt_set_gate(3, (uint32_t)isr3, 0x08, 0x8E);  // Breakpoint
    idt_set_gate(4, (uint32_t)isr4, 0x08, 0x8E);  // Overflow
    idt_set_gate(5, (uint32_t)isr5, 0x08, 0x8E);  // Bound Range Exceeded
    idt_set_gate(6, (uint32_t)isr6, 0x08, 0x8E);  // Invalid Opcode
    idt_set_gate(7, (uint32_t)isr7, 0x08, 0x8E);  // Device Not Available
    idt_set_gate(8, (uint32_t)isr8, 0x08, 0x8E);  // Double Fault
    idt_set_gate(9, (uint32_t)isr9, 0x08, 0x8E);  // Coprocessor Segment Overrun
    idt_set_gate(10, (uint32_t)isr10, 0x08, 0x8E); // Invalid TSS
    idt_set_gate(11, (uint32_t)isr11, 0x08, 0x8E); // Segment Not Present
    idt_set_gate(12, (uint32_t)isr12, 0x08, 0x8E); // Stack-Segment Fault
    idt_set_gate(13, (uint32_t)isr13, 0x08, 0x8E); // General Protection Fault
    idt_set_gate(14, (uint32_t)isr14, 0x08, 0x8E); // Page Fault
    idt_set_gate(15, (uint32_t)isr15, 0x08, 0x8E); // Reserved
    idt_set_gate(16, (uint32_t)isr16, 0x08, 0x8E); // x87 Floating-Point Exception
    idt_set_gate(17, (uint32_t)isr17, 0x08, 0x8E); // Alignment Check
    idt_set_gate(18, (uint32_t)isr18, 0x08, 0x8E); // Machine Check
    idt_set_gate(19, (uint32_t)isr19, 0x08, 0x8E); // SIMD Floating-Point Exception
    idt_set_gate(20, (uint32_t)isr20, 0x08, 0x8E); // Virtualization Exception
    idt_set_gate(21, (uint32_t)isr21, 0x08, 0x8E); // Control Protection Exception
    idt_set_gate(22, (uint32_t)isr22, 0x08, 0x8E); // Reserved
    idt_set_gate(23, (uint32_t)isr23, 0x08, 0x8E); // Reserved
    idt_set_gate(24, (uint32_t)isr24, 0x08, 0x8E); // Reserved
    idt_set_gate(25, (uint32_t)isr25, 0x08, 0x8E); // Reserved
    idt_set_gate(26, (uint32_t)isr26, 0x08, 0x8E); // Reserved
    idt_set_gate(27, (uint32_t)isr27, 0x08, 0x8E); // Reserved
    idt_set_gate(28, (uint32_t)isr28, 0x08, 0x8E); // Reserved
    idt_set_gate(29, (uint32_t)isr29, 0x08, 0x8E); // Reserved
    idt_set_gate(30, (uint32_t)isr30, 0x08, 0x8E); // Reserved
    idt_set_gate(31, (uint32_t)isr31, 0x08, 0x8E); // Reserved

    // Load the IDT
    load_idt_asm(&idtp);
    
    // Enable interrupts
    __asm__ volatile("sti");
    
    serial_printf("IDT initialized with %d entries\r\n", 256);
}

// Maps exception numbers to exception names for better error reporting
const char *exception_messages[] = {
    "Division By Zero",
    "Debug",
    "Non Maskable Interrupt",
    "Breakpoint",
    "Overflow",
    "Bound Range Exceeded",
    "Invalid Opcode",
    "Device Not Available",
    "Double Fault",
    "Coprocessor Segment Overrun",
    "Invalid TSS",
    "Segment Not Present",
    "Stack-Segment Fault",
    "General Protection Fault",
    "Page Fault",
    "Reserved",
    "x87 Floating-Point Exception",
    "Alignment Check",
    "Machine Check",
    "SIMD Floating-Point Exception",
    "Virtualization Exception",
    "Control Protection Exception",
    "Reserved", "Reserved", "Reserved", "Reserved",
    "Reserved", "Reserved", "Reserved", "Reserved",
    "Reserved", "Reserved"
};

// This function is called from the ASM interrupt handler
void isr_handler(struct registers *regs) {
    // Handle the interrupt
    serial_printf("Received interrupt: %d, Error code: %d\r\n", regs->int_no, regs->err_code);
    
    // For debugging, print to screen as well
    kprintf(0, 15, 0x04, "INTERRUPT: %d  ERROR: %d", regs->int_no, regs->err_code);
    
    // Halt on exception - most exceptions are fatal in a simple kernel
    if (regs->int_no < 32) {
        // Print exception name if it's a known exception
        serial_printf("FATAL: %s Exception\r\n", exception_messages[regs->int_no]);
        serial_printf("EIP: 0x%x, CS: 0x%x, EFLAGS: 0x%x\r\n", 
                     regs->eip, regs->cs, regs->eflags);
        
        // Infinite loop to stop execution
        while(1) {
            __asm__("cli"); // Clear interrupts
            __asm__("hlt"); // Halt the CPU
        }
    }
}