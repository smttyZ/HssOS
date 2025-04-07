[org 0x8000] ; where we loaded in stage1
[bits 16]

jmp s2_start

; === Data ===
s2_msg db "Stage 2 loaded successfully!", 0x0D, 0x0A, 0
kernel_load_msg db "Loading kernel...", 0x0D, 0x0A, 0
protected_mode_msg db "Switching to protected mode...", 0x0D, 0x0A, 0
disk_error_msg db "Disk read error!", 0x0D, 0x0A, 0

; === GDT (Global Descriptor Table) ===
gdt_start:
    ; Null descriptor (required)
    dq 0x0

    ; Code segment descriptor
    gdt_code:
        dw 0xFFFF       ; Limit (bits 0-15)
        dw 0x0000       ; Base (bits 0-15)
        db 0x00         ; Base (bits 16-23)
        db 10011010b    ; Access byte: Present=1, DPL=00, S=1, Type=1010 (code, execute/read)
        db 11001111b    ; Flags/Limit: G=1, D/B=1, L=0, AVL=0, Limit(16-19)=1111
        db 0x00         ; Base (bits 24-31)

    ; Data segment descriptor
    gdt_data:
        dw 0xFFFF       ; Limit (bits 0-15)
        dw 0x0000       ; Base (bits 0-15)
        db 0x00         ; Base (bits 16-23)
        db 10010010b    ; Access byte: Present=1, DPL=00, S=1, Type=0010 (data, read/write)
        db 11001111b    ; Flags/Limit: G=1, D/B=1, L=0, AVL=0, Limit(16-19)=1111
        db 0x00         ; Base (bits 24-31)
gdt_end:

; GDT descriptor
gdt_descriptor:
    dw gdt_end - gdt_start - 1  ; Size of GDT (minus 1)
    dd gdt_start                ; Address of GDT

; Define constants for GDT segment selectors
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

; Kernel load parameters
KERNEL_LOAD_SEGMENT equ 0x1000  ; Will load kernel at 0x10000 (segment * 16)
KERNEL_LOAD_OFFSET equ 0x0000   ; Initially load to 0x10000
KERNEL_SECTORS equ 64           ; Adjust based on your kernel size (32KB)
KERNEL_PMODE_ADDR equ 0x100000  ; Final kernel address in protected mode (1MB)

s2_start:
    ; Set up segments and stack
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00          ; Set stack below stage2

    ; Print initial message
    mov si, s2_msg
    call ps_16
    
    ; Load kernel from disk
    mov si, kernel_load_msg
    call ps_16
    call load_kernel
    
    ; Enable A20 line
    call enable_a20
    
    ; Switch to protected mode
    mov si, protected_mode_msg
    call ps_16
    call switch_to_protected_mode
    
    ; We never return from switch_to_protected_mode

; === Print String in Real Mode ===
[bits 16]
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

; === A20 Line Enable ===
enable_a20:
    in al, 0x92        ; Read from the keyboard controller port
    or al, 0x02        ; Set bit 1 (A20 enable)
    out 0x92, al       ; Write back to the keyboard controller port
    ret

; === Load kernel from disk ===
load_kernel:
    ; Set up registers for BIOS disk read
    mov ax, KERNEL_LOAD_SEGMENT
    mov es, ax
    mov bx, KERNEL_LOAD_OFFSET

    ; BIOS disk parameters
    mov ah, 0x02               ; BIOS read function
    mov al, KERNEL_SECTORS     ; Number of sectors to read
    mov ch, 0                  ; Cylinder 0
    mov cl, 3                  ; Start from sector 3 (1-based, so sector 3 is the third sector)
    mov dh, 0                  ; Head 0
    mov dl, 0                  ; Drive 0 (floppy A:)
    
    int 0x13                   ; Call BIOS disk read
    jc disk_error              ; If carry flag set, read failed
    
    ; Check if we read all requested sectors
    cmp al, KERNEL_SECTORS
    jne disk_error
    ret

disk_error:
    mov si, disk_error_msg
    call ps_16
    cli
    hlt
    jmp $                      ; Infinite loop

; === Switch to protected mode ===
switch_to_protected_mode:
    cli                        ; Disable interrupts
    
    ; Load GDT
    lgdt [gdt_descriptor]
    
    ; Set protection enable bit in CR0
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    
    ; Far jump to flush CPU pipeline and enter 32-bit code
    jmp CODE_SEG:protected_mode_entry

[bits 32]
protected_mode_entry:
    ; Set up segment registers for protected mode
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    
    ; Set up stack
    mov esp, 0x90000         ; Set stack pointer to a safe location
    
    ; Copy kernel from 0x10000 (where we loaded it) to 0x100000 (where it will run)
    mov esi, 0x10000         ; Source: initial load address
    mov edi, KERNEL_PMODE_ADDR ; Destination: final kernel address
    mov ecx, KERNEL_SECTORS * 512 / 4 ; Size in dwords (sectors * 512 bytes per sector / 4 bytes per dword)
    
    ; Copy the kernel
    rep movsd
    
    ; Jump to kernel entry point (0x100000 as specified in linker.ld)
    ; Our start function is now at exactly this address due to linker script changes
    jmp KERNEL_PMODE_ADDR