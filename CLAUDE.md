# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands
- `make all`: Build the bootloader, kernel, and disk image, then run in QEMU
- `make run`: Run the OS in QEMU
- `make debug`: Run with debugging options enabled
- `make clean`: Remove build artifacts

## Code Style Guidelines
- **Assembly**: 
  - Use consistent indentation (4 spaces)
  - Document functions with clear comments explaining inputs/outputs
  - Use meaningful labels for jumps and data

- **C Code**:
  - Follow K&R style with 4-space indentation
  - Variable names: snake_case
  - Constants: UPPER_CASE
  - Include descriptive comments for non-obvious code
  - Avoid global variables where possible

## Project Organization
- `boot/`: Bootloader code
- `kernel/`: Kernel source files
- `out/`: Build artifacts and disk images
- `.asm` for assembly, `.c` for C code

## Error Handling
- Check function returns for error conditions
- Document error handling approaches in comments