# Variables
ASM := nasm
CC := x86_64-elf-gcc
CFLAGS := -ffreestanding -O0 -g -Wall -Wextra -std=c99 -m32 -fno-pie
QEMU := qemu-system-x86_64
STAGE1_SRC := boot/stage1.asm
STAGE1_OUT := out/stage1.bin
KERNEL_SRC := kernel/main.c
KERNEL_OBJ := out/kernel.o
KERNEL_BIN := out/kernel.bin
DISK_IMG := out/disk.img
BOOTLOADER_SIZE := 512
DISK_SIZE := 1440K  # Standard floppy size

# Main target
all: $(DISK_IMG) run

# Assemble bootloader
$(STAGE1_OUT): $(STAGE1_SRC)
	@mkdir -p out
	$(ASM) -f bin $(STAGE1_SRC) -o $(STAGE1_OUT)

# Compile the kernel C code
$(KERNEL_OBJ): $(KERNEL_SRC)
	$(CC) $(CFLAGS) -c $(KERNEL_SRC) -o $(KERNEL_OBJ)

# Link the kernel
$(KERNEL_BIN): $(KERNEL_OBJ)
	$(CC) -T linker.ld $(CFLAGS) -nostdlib $(KERNEL_OBJ) -o $(KERNEL_BIN)
	objdump -d $(KERNEL_BIN) > out/kernel.dump
	objdump -h $(KERNEL_BIN) > out/kernel_headers.dump

# Create disk image with bootloader and kernel
$(DISK_IMG): $(STAGE1_OUT) $(KERNEL_BIN)
	@echo "Creating disk image..."
	@dd if=/dev/zero of=$(DISK_IMG) bs=512 count=2880
	@dd if=$(STAGE1_OUT) of=$(DISK_IMG) conv=notrunc
	@dd if=$(KERNEL_BIN) of=$(DISK_IMG) bs=512 seek=1 conv=notrunc

# Run in QEMU (as floppy)
run: $(DISK_IMG)
	@echo "Running HssOS. Press ESC to exit the OS."
	@echo "If ESC doesn't work, press Ctrl+C or Ctrl+Alt+G to kill QEMU."
	$(QEMU) -fda $(DISK_IMG) -boot a -device isa-debug-exit,iobase=0xf4,iosize=0x04

# Run with debug options (no auto-reset)
debug: $(DISK_IMG)
	@echo "Running HssOS in debug mode. Press ESC to exit the OS."
	@echo "If ESC doesn't work, type 'quit' in the monitor window."
	$(QEMU) -fda $(DISK_IMG) -boot a -d int,cpu_reset -no-reboot -no-shutdown -monitor stdio -device isa-debug-exit,iobase=0xf4,iosize=0x04

# Run with full debug options and GDB server
gdb-debug: $(DISK_IMG)
	@echo "Running HssOS with GDB server. Connect with:"
	@echo "gdb -ex \"target remote localhost:1234\" out/kernel.bin"
	$(QEMU) -fda $(DISK_IMG) -boot a -d int,cpu_reset -no-reboot -no-shutdown -s -S -monitor stdio -device isa-debug-exit,iobase=0xf4,iosize=0x04

# Clean build artifacts
clean:
	rm -rf out $(DISK_IMG)

.PHONY: all run debug gdb-debug clean