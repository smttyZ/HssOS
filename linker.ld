ENTRY(start)

SECTIONS
{
    . = 0x100000; /* The kernel is loaded at this address */
    
    .text : {
        /* Place the start function at the very beginning of the text section */
        *(.text.start)   /* Entry point goes first */
        *(.text)         /* Then the rest of the code */
    }
    
    .data : {
        *(.data)     /* Place all initialized variables here */
    }
    
    .bss : {
        *(.bss)      /* Place all uninitialized variables here */
    }
    
    .rodata : {
        *(.rodata)   /* Place read-only data here */
    }
    
    .stack : {
        . = . + 0x1000; /* Reserve 4KB for stack */
        stack_top = .;   /* Define the stack top symbol */
    }
}
