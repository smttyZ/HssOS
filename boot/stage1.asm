[bits 16]
[org 0x7c00]

jmp main

; Data
msg_16 db 'HssOS Bootloader Starting...', 0
leaving_16 db 'Leaving Real Mode...', 0

; GDT
align 8
gdt_start:
    dq 0x0                 ; Null descriptor

    ; Code segment (0x08)
    dw 0xffff             ; Limit (0-15)
    dw 0x0000             ; Base (0-15)
    db 0x00               ; Base (16-23)
    db 10011010b          ; Access byte
    db 11001111b          ; Flags + Limit (16-19)
    db 0x00               ; Base (24-31)

    ; Data segment (0x10)
    dw 0xffff             ; Limit (0-15)
    dw 0x0000             ; Base (0-15)
    db 0x00               ; Base (16-23)
    db 10010010b          ; Access byte
    db 11001111b          ; Flags + Limit (16-19)
    db 0x00               ; Base (24-31)
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ 0x08
DATA_SEG equ 0x10

main:
    cli
    ; Set up real-mode stack
    mov ax, 0x0000
    mov ss, ax
    mov sp, 0x7C00        ; Stack grows downwards from 0x7C00

    mov si, msg_16
    call ps_16

    call enable_a20
    call real_to_prot

    ; This code is unreachable
    jmp $
    hlt

ps_16:
    pusha
    mov ah, 0x0E
.loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    popa
    ret

enable_a20:
    in al, 0x92
    or al, 2
    out 0x92, al
    ret

real_to_prot:
    mov si, leaving_16    ; Print message before switching
    call ps_16

    cli
    lgdt [gdt_descriptor]

    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp CODE_SEG:protected_mode  ; Far jump to 32-bit code

[bits 32]
protected_mode:
    ; Initialize data segments
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Set up protected mode stack
    mov esp, 0x8000       ; Stack top at 0x8000

    ; Add 32-bit code here (e.g., kernel load)
    jmp $                 ; Halt

times 510-($-$$) db 0
dw 0xAA55