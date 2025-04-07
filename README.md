# HssOS - Henry's Secure Server Operating System

HssOS is a simple hobbyist operating system is designed to turn older hardware into modern-ish servers

## Prerequisites

The following tools are required:
- NASM (Netwide Assembler)
- GCC (with 32-bit multilib support on Linux)
- QEMU (for emulation)
- make

## Setup Instructions

### Automatic Setup

1. Clone this repository:
   ```
   git clone <repository-url>
   cd HssOS
   ```

2. Run the setup script for your platform:

   For macOS:
   ```
   chmod +x install-macos-deps.sh
   ./install-macos-deps.sh
   ```

   For Ubuntu/WSL2:
   ```
   chmod +x install-ubuntu-deps.sh
   ./install-ubuntu-deps.sh
   ```

### Manual Setup

#### macOS
```
brew install nasm qemu x86_64-elf-gcc x86_64-elf-binutils
```

#### Ubuntu/WSL2
```
sudo apt-get update
sudo apt-get install -y nasm qemu-system-x86 gcc-multilib build-essential gdb
```

## Building and Running

To build and run the OS:
```
make all
```

To clean build artifacts:
```
make clean
```

To run with debugging options:
```
make debug
```

To run with GDB server:
```
make gdb-debug
```

## Project Structure

- `boot/`: Bootloader code
- `kernel/`: Kernel source files
- `out/`: Build artifacts and disk images
- `.asm` files are assembly code
- `.c` files are C code

## How to Exit the OS

Press the ESC key while running the OS to exit cleanly.
If ESC doesn't work, you can use Ctrl+C to terminate QEMU.