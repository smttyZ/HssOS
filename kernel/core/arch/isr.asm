; kernel/core/arch/isr.asm - Interrupt Service Routines
[bits 32]

; Define constants for external linkage
global load_idt_asm
global isr0
global isr1
global isr2
global isr3
global isr4
global isr5
global isr6
global isr7
global isr8
global isr9
global isr10
global isr11
global isr12
global isr13
global isr14
global isr15
global isr16
global isr17
global isr18
global isr19
global isr20
global isr21
global isr22
global isr23
global isr24
global isr25
global isr26
global isr27
global isr28
global isr29
global isr30
global isr31

; External function that will handle all interrupts
extern isr_handler

; Load the IDT
load_idt_asm:
    mov eax, [esp+4]  ; Get the pointer to the IDT
    lidt [eax]        ; Load the IDT
    ret

; Common ISR handler stub
%macro ISR_NOERRCODE 1
    global isr%1
    isr%1:
        cli           ; Disable interrupts
        push 0        ; Push dummy error code
        push %1       ; Push interrupt number
        jmp isr_common_stub
%endmacro

%macro ISR_ERRCODE 1
    global isr%1
    isr%1:
        cli           ; Disable interrupts
        ; No need to push error code, it's already pushed by the CPU
        push %1       ; Push interrupt number
        jmp isr_common_stub
%endmacro

; Define ISRs for exceptions
ISR_NOERRCODE 0  ; Division by Zero
ISR_NOERRCODE 1  ; Debug Exception
ISR_NOERRCODE 2  ; Non-Maskable Interrupt
ISR_NOERRCODE 3  ; Breakpoint
ISR_NOERRCODE 4  ; Overflow
ISR_NOERRCODE 5  ; Bound Range Exceeded
ISR_NOERRCODE 6  ; Invalid Opcode
ISR_NOERRCODE 7  ; Device Not Available

ISR_ERRCODE   8  ; Double Fault
ISR_NOERRCODE 9  ; Coprocessor Segment Overrun (reserved)
ISR_ERRCODE   10 ; Invalid TSS
ISR_ERRCODE   11 ; Segment Not Present
ISR_ERRCODE   12 ; Stack-Segment Fault
ISR_ERRCODE   13 ; General Protection Fault
ISR_ERRCODE   14 ; Page Fault
ISR_NOERRCODE 15 ; Reserved (Intel)

ISR_NOERRCODE 16 ; x87 Floating-Point Exception
ISR_ERRCODE   17 ; Alignment Check
ISR_NOERRCODE 18 ; Machine Check
ISR_NOERRCODE 19 ; SIMD Floating-Point Exception
ISR_NOERRCODE 20 ; Virtualization Exception
ISR_ERRCODE   21 ; Control Protection Exception
ISR_NOERRCODE 22 ; Reserved
ISR_NOERRCODE 23 ; Reserved

ISR_NOERRCODE 24 ; Reserved
ISR_NOERRCODE 25 ; Reserved
ISR_NOERRCODE 26 ; Reserved
ISR_NOERRCODE 27 ; Reserved
ISR_NOERRCODE 28 ; Reserved
ISR_NOERRCODE 29 ; Reserved
ISR_NOERRCODE 30 ; Reserved
ISR_NOERRCODE 31 ; Reserved

; Common ISR handler code
isr_common_stub:
    pusha           ; Push all registers (EAX, ECX, EDX, EBX, ESP, EBP, ESI, EDI)
    
    mov ax, ds      ; Save the data segment
    push eax
    
    mov ax, 0x10    ; Load kernel data segment
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    
    ; Call C handler with pointer to stack frame
    push esp        ; Push pointer to registers structure
    call isr_handler
    add esp, 4      ; Clean up pushed argument
    
    pop eax         ; Restore original data segment
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    
    popa            ; Restore registers
    add esp, 8      ; Clean up pushed error code and interrupt number
    sti             ; Re-enable interrupts
    iret            ; Return from interrupt