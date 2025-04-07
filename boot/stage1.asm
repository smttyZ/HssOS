[org 0x7c00]
[bits 16]

%define ENDL 0x0d, 0x0a  ; Define newline characters (CRLF)

; Jump to code
jmp start

;
; Loads the second sector of the disk into memory at 0x8000
; Params:
;  - es:bx - pointer to the buffer where the sector will be loaded
;   - This gets overriden with hardcoded value, MAY BE UNSAFE!

ls2_16:
    ; set es:bx to the buffer address, 0x0000:0x8000
    mov ax, 0x0000    ; segment 0
    mov es, ax        ; set ES to 0x0000
    mov bx, 0x8000    ; offset 0x8000 (buffer start)

    ; bios disk read
    mov ah, 0x02      ; BIOS read sectors function
    mov al, 1         ; number of sectors to read (1 sector)
    mov ch, 0         ; cylinder 0
    mov cl, 2         ; sector 2 (1-based index, so 2 means second sector)
    mov dh, 0         ; head 0


    int 0x13          ; call BIOS interrupt to read the sector
    jc .disk_error    ; if carry flag is set, there was an error

    ; jump to the loaded code at 0x8000
    jmp 0x0000:0x8000 ; jump to the loaded code in the buffer

.not_floppy:
    mov si, _nflop
    call ps_16        ; call the print string function to display error
    hlt
    jmp $             ; infinite loop to halt execution

.disk_error:
    mov si, _err16    ; load the address of the error message into SI
    call ps_16        ; call the print string function to display error
    jmp $


;
; Prints a string to the screen in real mode
; Params:
;  - ds:si - pointer to the string
ps_16:
    ; save registers to be modified
    push si
    push ax

.loop:
    lodsb           ; load byte at DS:SI into AL and increment SI
    or al, al       ; check if AL is zero (end of string)
    jz .done        ; if zero, we reached the end of the string

    mov ah, 0x0e    ; call BIOS teletype function
    mov bh, 0       ; page number (0 for default)
    int 0x10        ; call BIOS interrupt to print character in AL
    jmp .loop       ; continue loop

.done:
    pop ax          ; restore AX
    pop si          ; restore SI
    ret             ; return from ps_16

start:
    cli             ; disable interrupts (sanity check)
    
    ; set up data segments
    xor ax, ax      ; clear AX
    mov ds, ax      ; set DS to 0
    mov es, ax      ; set ES to 0

    ; Set up stack
    mov ss, ax      ; set SS to 0
    mov sp, 0x7A00  ; grow stack down from 0x7A00 (below bootloader)

    ; print message
    mov si, _msg16  ; load the address of the message into SI
    call ps_16      ; call the print string function

    ; Load the second sector of the disk
    call ls2_16      ; load sector 2 into memory at 0x8000
    ; If loading was successful, we should have jumped to 0x8000
    ; If we reach here, it means the jump failed or we are still in stage1
    

    ; Infinite loop to prevent execution from falling through
    hlt             ; halt CPU
    jmp $           ; infinite loop

; === DATA ===
_msg16 db 'Real mode is too easy!', ENDL, 0
_err16 db 'Error reading sector 2!', ENDL, 0
_nflop db 'Not a floppy disk!', ENDL, 0

times 510-($-$$) db 0
dw 0xAA55