; This code doesn't have to be bootable, therefor more room to work

[org 0x8000] ; where we loaded in stage1
[bits 16]

jmp s2_start

; === Data ===
s2_msg db "Stage 2 loaded successfully!", 0x0A, 0x00, 0

s2_start:
    xor ax, ax
    mov ds, ax
    mov si, s2_msg
    call ps_16

    cli
    hlt
    jmp $

ps_16:
    push si
    push ax
.loop:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0e
    mov bh, 0
    int 0x10
    jmp .loop
.done:
    pop ax
    pop si
    ret