[bits 16]
[org 0x7c00]

jmp main

kernel_bin db 0x00, 0x00, ...   ; The binary content of kernel.bin (insert in the hex format)
kernel_bin_size equ <size_in_bytes>


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

    ; Load kernel at 0x1000
    mov si, kernel_bin
    mov di, 0x1000   ; Destination address in memory
    mov cx, kernel_bin_size / 512   ; Total sectors to read
    call load_kernel

    ; Jump to the kernel entry point (0x1000)
    jmp 0x1000

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

lba_to_chs:
    ; Inputs:
    ;   AX = LBA
    ; Outputs:
    ;   CH = Cylinder
    ;   DH = Head
    ;   CL = Sector
    ; Clobbers: AX, BX, CX, DX

    xor dx, dx          
    mov bx, 36           ; heads * sectors = 2 * 18
    div bx               ; AX / 36 → AX = cylinder, DX = remainder
    mov ch, al           ; CH = cylinder

    mov ax, dx           ; remainder → AX (we divide it again)
    xor dx, dx
    mov bx, 18           ; sectors per track
    div bx               ; AX / 18 → AX = head, DX = sector (0-based)
    mov dh, al           ; DH = head
    inc dl               ; sector = remainder + 1
    mov cl, dl           ; CL = sector

    ret

load_kernel:
    pusha
    ; Read kernel from disk into memory
    mov ah, 0x02    ; INT 0x13 read sector function
    mov al, 1       ; Number of sectors
    mov bx, di      ; Destination address
    mov dl, 0x80    ; Drive number (floppy or hard disk)
    int 0x13
    popa
    ret

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

kernel_bin_size equ <insert_size_of_kernel_here>

times 510-($-$$) db 0
dw 0xAA55