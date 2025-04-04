[bits 16]
[org 0x7c00]  ; BIOS loads bootloader at 0x7C00

; Jump over BPB area (important for some BIOSes)
jmp start
nop
times 33 db 0    ; BPB (BIOS Parameter Block) area

start:
    ; Clear interrupts during setup
    cli 

    ; Set up segment registers
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov sp, 0x7C00  ; Set up stack

    ; Reenable interrupts
    sti

    ; Print a message
    mov si, msg_boot
    call print_msg

    ; Load kernel
    mov si, msg_load
    call print_msg
    call load_kernel

    ; Switch to protected mode
    mov si, msg_prot
    call print_msg
    call switch_to_pm

; -------------------------------------------------
; Helper functions
; -------------------------------------------------

; Print message
; SI = null-terminated string
print_msg:
    pusha
    mov ah, 0x0E  ; BIOS teletype function
.loop:
    lodsb          ; Load byte at SI into AL
    test al, al    ; Check if AL is 0 (end of string)
    jz .done
    int 0x10       ; Print character in AL
    jmp .loop
.done:
    popa
    ret

; Load kernel from disk sectors
load_kernel:
    pusha
    
    ; Reset the disk system
    xor ah, ah
    int 0x13
    
    ; Read kernel into memory
    mov ax, 0x0000     ; ES:BX = 0x0000:0x1000 = physical 0x1000
    mov es, ax
    mov bx, 0x1000     ; Load kernel at 0x1000
    
    mov ah, 0x02       ; BIOS read sectors function
    mov al, 8          ; Number of sectors to read (4KB)
    mov ch, 0          ; Cylinder 0
    mov cl, 2          ; Start from sector 2 (bootloader = sector 1)
    mov dh, 0          ; Head 0
    mov dl, 0          ; Drive 0 (floppy)
    
    int 0x13           ; Call BIOS
    jc disk_error      ; Check for error (carry flag)
    
    cmp al, 8          ; Make sure we read all sectors
    jne disk_error
    
    ; Reset ES to 0
    xor ax, ax
    mov es, ax
    
    popa
    ret

disk_error:
    mov si, msg_disk_error
    call print_msg
    jmp $  ; Infinite loop

; -------------------------------------------------
; GDT (Global Descriptor Table)
; -------------------------------------------------
gdt_start:
    ; Null descriptor (required)
    dd 0x0, 0x0

    ; Code segment descriptor
    dw 0xFFFF    ; Limit (bits 0-15)
    dw 0x0000    ; Base (bits 0-15)
    db 0x00      ; Base (bits 16-23)
    db 10011010b ; Access byte
    db 11001111b ; Flags + Limit (bits 16-19)
    db 0x00      ; Base (bits 24-31)

    ; Data segment descriptor
    dw 0xFFFF    ; Limit (bits 0-15) 
    dw 0x0000    ; Base (bits 0-15)
    db 0x00      ; Base (bits 16-23)
    db 10010010b ; Access byte
    db 11001111b ; Flags + Limit (bits 16-19)
    db 0x00      ; Base (bits 24-31)
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1  ; GDT size (one less than true size)
    dd gdt_start                ; GDT address

; Define segment selectors
CODE_SEG equ 8     ; Offset of code segment in GDT
DATA_SEG equ 16    ; Offset of data segment in GDT

; -------------------------------------------------
; Switch to protected mode
; -------------------------------------------------
switch_to_pm:
    cli                     ; Disable interrupts
    lgdt [gdt_descriptor]   ; Load GDT
    
    ; Set the Protected Mode bit in CR0
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    
    ; Far jump to 32-bit code segment to flush pipeline
    jmp CODE_SEG:init_pm

; -------------------------------------------------
; 32-bit code
; -------------------------------------------------
[bits 32]
init_pm:
    ; Update segment registers
    mov ax, DATA_SEG    ; Data segment selector
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    
    ; Set up stack
    mov ebp, 0x90000    ; Base pointer at top of free memory
    mov esp, 0x90000    ; Stack pointer at top of free memory
    
    ; Clear screen
    mov ecx, 80 * 25    ; Screen has 80x25 characters  
    mov edi, 0xB8000    ; Start of video memory
    mov ax, 0x0720      ; Normal attribute (0x07), space character (0x20)
    rep stosw           ; Repeat Store Word - fills screen with spaces
    
    ; Print 'PM' at top left to show we're in protected mode
    mov edi, 0xB8000
    mov byte [edi], 'P'
    mov byte [edi+1], 0x0F    ; White on black
    mov byte [edi+2], 'M'
    mov byte [edi+3], 0x0F    ; White on black
    
    ; Zero all general purpose registers to ensure clean state
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx
    xor esi, esi
    xor edi, edi
    
    ; Jump to kernel at 0x1000
    jmp CODE_SEG:0x1000

; -------------------------------------------------
; Data
; -------------------------------------------------
msg_boot:      db 'Booting HssOS...', 13, 10, 0
msg_load:      db 'Loading kernel...', 13, 10, 0
msg_prot:      db 'Switching to protected mode...', 13, 10, 0
msg_disk_error:db 'Error loading kernel from disk!', 13, 10, 0

; -------------------------------------------------
; Boot signature
; -------------------------------------------------
times 510-($-$$) db 0   ; Pad to 510 bytes
dw 0xAA55               ; Boot signature