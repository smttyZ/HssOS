# Henry's Secure Server OS Memory Map Cheat Sheet (x86, BIOS Boot)

_A clear overview of memory layout, boot process, and kernel placement._

---

## Real Mode Memory (First 1MB)

| Memory Range             | Size (Hex) | Size (KB) | Description                                      |
|--------------------------|------------|-----------|--------------------------------------------------|
| 0x00000000 - 0x000003FF  | 0x400      | 1 KB      | **Interrupt Vector Table (IVT)**                 |
| 0x00000400 - 0x000004FF  | 0x100      | 256 B     | **BIOS Data Area (BDA)**                         |
| 0x00000500 - 0x000079FF  | ~0x74FF    | ~29 KB    | Free memory (usable)                             |
| 0x00007A00 - 0x00007BFF  | 0x200      | 512 B     | **Stage 1 Bootloader Stack** (grows downward)    |
| 0x00007C00 - 0x00007DFF  | 0x200      | 512 B     | **Stage 1 Bootloader** (loaded by BIOS)          |
| 0x00007E00 - 0x00007FFF  | 0x200      | 512 B     | Free/overflow buffer space                       |
| 0x00008000 - 0x0000FFFF  | 0x8000     | 32 KB     | **Stage 2 Bootloader**                           |
| 0x00010000 - 0x0008FFFF  | 0x80000    | 512 KB    | Free space / **Temp kernel load** (0x10000)      |
| 0x00090000 - 0x0009FFFF  | 0x10000    | 64 KB     | **Protected Mode Stack** (grows downward)        |
| 0x000A0000 - 0x000BFFFF  | 0x20000    | 128 KB    | **Video Memory** (VGA at 0xB8000, graphics at 0xA0000) |
| 0x000C0000 - 0x000FFFFF  | 0x40000    | 256 KB    | **BIOS ROM, EBDA, hardware-reserved**            |

---

## Protected Mode Memory (1MB+)

| Memory Range             | Size       | Description                                      |
|--------------------------|------------|--------------------------------------------------|
| 0x00100000+ (1MB)        | Variable   | **Kernel Code (final location)**                 |
| - .text                  | Variable   | Executable code (entry point here)               |
| - .data                  | Variable   | Initialized global/static variables              |
| - .bss                   | Variable   | Uninitialized variables                          |
| - .rodata                | Variable   | Constant/read-only data                          |
| - .stack                 | 0x1000     | Kernel runtime stack                             |
| Heap & Pages             | Grows up   | Dynamic memory (allocations, page tables, etc.)  |

---

## Memory-Mapped I/O (MMIO)

| Memory Range             | Description                                      |
|--------------------------|--------------------------------------------------|
| 0x000B8000 - 0x000BFFFF  | **VGA Text Buffer**                              |
| 0x000A0000 - 0x000AFFFF  | **Graphics Video Memory (Mode 13h, etc.)**      |
| 0x000B0000 - 0x000B7FFF  | Monochrome display text buffer                   |
| I/O Ports (in/out)       |                                                  |
| - 0x3F8                  | **COM1 Serial Port** (useful for debug output)   |

---

## Memory Management Structures

| Structure                | Description                                      |
|--------------------------|--------------------------------------------------|
| **GDT**                  | Global Descriptor Table (used for segmentation) |
| **IDT**                  | Interrupt Descriptor Table (up to 256 entries)  |
| **Page Directory/Table** | (To be implemented for paging)                  |

---

## Boot Process Flow

1. **BIOS** loads Stage 1 bootloader at `0x7C00`
2. **Stage 1**:
   - Sets up a stack at `0x7BFF`
   - Loads Stage 2 into `0x8000`
3. **Stage 2**:
   - Sets up Protected Mode GDT
   - Loads kernel to temp `0x10000`
   - Enters Protected Mode
   - Relocates kernel to `0x100000`
   - Jumps to kernel entry point

---

## Virtual Memory (Future Plan)

_Not yet implemented, but planned structure:_

| Address Range            | Description                                      |
|--------------------------|--------------------------------------------------|
| 0x00000000 - 0xBFFFFFFF  | **User Space**                                   |
| 0xC0000000 - 0xFFFFFFFF  | **Kernel Space** (higher-half kernel mapping)    |
| Page Size                | 4 KB (aligned)                                   |
| Paging Mode              | x86 32-bit (non-PAE to start)                    |

---

✅ This cheat sheet assumes:
- Real hardware boot using BIOS (not UEFI)
- 32-bit protected mode target (no long mode yet)
- Direct physical addressing (no paging yet)

---

📝 Last updated: April 8 2025  
🛠 Author: Henry  
