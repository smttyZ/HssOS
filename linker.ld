/* Simple linker script for HssOS */
OUTPUT_FORMAT("elf32-i386")
OUTPUT_ARCH(i386)
ENTRY(_start)

SECTIONS {
  /* Kernel starts at 0x1000 (physical address) */
  . = 0x1000;
  
  /* Text section (code) */
  .text : {
    *(.text)
  }
  
  /* Read-only data */
  .rodata : {
    *(.rodata)
    *(.rodata.*)
  }
  
  /* Read-write data (initialized) */
  .data : {
    *(.data)
  }
  
  /* Read-write data (uninitialized) and stack */
  .bss : {
    bss_start = .;
    *(.bss)
    *(COMMON)
    bss_end = .;
  }
  
  /* End of kernel marker */
  end = .;
}