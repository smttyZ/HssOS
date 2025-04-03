; boot/stage1.asm
; !THIS FILE WILL BE COMPILED INTO A FLAT BINARY!

[bits 16]
[org 0x7c00]

; Jump to code
jmp main

; === Data ===
stage1_msg db 'Now In: 16 bit Real Mode', 0x0d, 0x0a, 0

; === Main ===
main:
; Disable interrupts for sanity
cli

xor ax, ax                      ; Clear ax register, though it should be empty
mov ds, ax                      ; Set ds to 0
mov es, ax                      ; Set es to 0
mov ss, ax                      ; Set ss to 0
mov sp, 0x9000                  ; Set stack pointer just below bootloader

; Print msg to confirm we made it this far
mov si, stage1_msg
call ps_16                      ; Call print string 16bit

; Enable A20 line
call enable_a20

jmp $

; === 16-bit Functions ===
ps_16:
    ; Input: SI points to null-terminated string
    ; Preserves: AX, SI
    pusha             ; Save all registers
    
.loop:
    lodsb             ; Load byte at SI into AL and increment SI
    or al, al         ; Test if character is 0 (end of string)
    jz .done          ; If zero, we're done
    
    mov ah, 0x0E      ; BIOS teletype function
    int 0x10          ; Call BIOS
    jmp .loop         ; Repeat for next character
    
.done:
    popa              ; Restore all registers
    ret               ; Return to caller

enable_a20:
    in al, 0x92
    or al, 2
    out 0x92, al
    ret

times 510 - ($ - $$) db 0
dw 0xaa55