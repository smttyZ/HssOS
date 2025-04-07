#ifndef IDT_H
#define IDT_H

#include "kernel.h"

// IDT entry structure (gate descriptor)
struct idt_entry {
    uint16_t offset_low;    // Lower 16 bits of handler function address
    uint16_t selector;      // Kernel segment selector
    uint8_t  zero;          // Reserved
    uint8_t  type_attr;     // Type and attributes
    uint16_t offset_high;   // Upper 16 bits of handler function address
} __attribute__((packed));

// IDT pointer structure
struct idt_ptr {
    uint16_t limit;         // Size of IDT - 1
    uint32_t base;          // Base address of IDT
} __attribute__((packed));

// Declare IDT handling functions
void idt_init();
void idt_set_gate(int num, uint32_t base, uint16_t sel, uint8_t flags);
extern void load_idt_asm(struct idt_ptr* idt_ptr);

// Define the registers structure for ISR handler
struct registers {
    uint32_t ds;                  // Data segment pushed by our ASM stub
    uint32_t edi, esi, ebp, esp, ebx, edx, ecx, eax; // Pushed by pusha
    uint32_t int_no, err_code;    // Interrupt number and error code
    uint32_t eip, cs, eflags, useresp, ss; // Pushed by the processor automatically
};

// Declare interrupt handlers
void isr_handler(struct registers *regs);

// Declare ISR stubs for exceptions (0-31)
extern void isr0();   // Division by Zero
extern void isr1();   // Debug Exception
extern void isr2();   // Non-Maskable Interrupt
extern void isr3();   // Breakpoint
extern void isr4();   // Overflow
extern void isr5();   // Bound Range Exceeded
extern void isr6();   // Invalid Opcode
extern void isr7();   // Device Not Available
extern void isr8();   // Double Fault
extern void isr9();   // Coprocessor Segment Overrun (reserved)
extern void isr10();  // Invalid TSS
extern void isr11();  // Segment Not Present
extern void isr12();  // Stack-Segment Fault
extern void isr13();  // General Protection Fault
extern void isr14();  // Page Fault
extern void isr15();  // Reserved
extern void isr16();  // x87 Floating-Point Exception
extern void isr17();  // Alignment Check
extern void isr18();  // Machine Check
extern void isr19();  // SIMD Floating-Point Exception
extern void isr20();  // Virtualization Exception
extern void isr21();  // Control Protection Exception
extern void isr22();  // Reserved
extern void isr23();  // Reserved
extern void isr24();  // Reserved
extern void isr25();  // Reserved
extern void isr26();  // Reserved
extern void isr27();  // Reserved
extern void isr28();  // Reserved
extern void isr29();  // Reserved
extern void isr30();  // Reserved
extern void isr31();  // Reserved

#endif /* IDT_H */