ASM ?= nasm
QEMU ?= qemu-system-i386
MCOPY ?= mcopy
NEWFS ?= newfs_msdos
DD ?= dd

BOOT_DIR=boot
OUT_DIR=out

# Ensure output directory exists
always:
	@mkdir -p $(OUT_DIR)

# Build floppy
floppy: $(OUT_DIR)/floppy.img
$(OUT_DIR)/floppy.img: asm always
	@echo "Building floppy image..."
	$(DD) if=/dev/zero of=$(OUT_DIR)/floppy.img bs=512 count=2880 status=none
	$(NEWFS) -F 12 -f 2880 $(OUT_DIR)/floppy.img
	@echo "Copying boot binary to floppy image..."
	$(DD) if=$(OUT_DIR)/boot.bin of=$(OUT_DIR)/floppy.img conv=notrunc
	$(MCOPY) -i $(OUT_DIR)/floppy.img $(OUT_DIR)/stage1.bin ::/boot.bin
	$(MCOPY) -i $(OUT_DIR)/floppy.img $(OUT_DIR)/stage2.bin ::/stage2.bin
	@echo "Floppy image created: $(OUT_DIR)/floppy.img"

# build asm
asm: $(BOOT_DIR)/stage1.asm $(BOOT_DIR)/stage2.asm always
	@mkdir -p $(OUT_DIR)
	$(ASM) -f bin $(BOOT_DIR)/stage1.asm -o $(OUT_DIR)/stage1.bin
	$(ASM) -f bin $(BOOT_DIR)/stage2.asm -o $(OUT_DIR)/stage2.bin
	@echo "Assembly complete: stage1.bin and stage2.bin"

# Run in QEMU
run: $(OUT_DIR)/floppy.img
	@echo "Running QEMU with the floppy image..."
	$(QEMU) -fda $(OUT_DIR)/floppy.img -boot a -m 16M
	@echo "QEMU session ended."

# Run in QEMU with logging
run-log: $(OUT_DIR)/floppy.img
	@echo "Running QEMU with logging enabled..."
	$(QEMU) -fda $(OUT_DIR)/floppy.img -boot a -m 16M -d int,mmu,cpu -D $(OUT_DIR)/qemu.log
	@echo "QEMU session ended. Logs saved to $(OUT_DIR)/qemu.log"
	@echo "To view logs, use: cat $(OUT_DIR)/qemu.log"

# Run in QEMU with debugging
run-debug: $(OUT_DIR)/floppy.img
	@echo "Running QEMU with debugging enabled..."
	$(QEMU) -fda $(OUT_DIR)/floppy.img -boot a -m 16M -s -S
	@echo "QEMU session started in debug mode. Connect with gdb using:"
	@echo "  gdb -ex 'target remote localhost:1234' $(OUT_DIR)/boot.bin"
	@echo "To continue debugging, use 'c' in gdb."

# Clean up generated files
clean:
	@echo "Cleaning up generated files..."
	rm -rf $(OUT_DIR)/*.img $(OUT_DIR)/*.bin
	@echo "Clean up complete."

# Help message
help:
	@echo "Usage:"
	@echo "  make floppy  - Build the floppy image."
	@echo "  make asm     - Assemble the boot code to binary."
	@echo "  make clean   - Remove generated files."
	@echo "  make help    - Show this help message."
	@echo ""
	@echo "Note: Ensure you have nasm installed to build the assembly code."
	@echo "Make sure 'nasm', 'qemu', 'mtools', and 'newfs_msdos' are installed on your system."
	@echo "On macOS, use Homebrew: brew install nasm qemu mtools"
	@echo "On Ubuntu, use APT: sudo apt install nasm qemu-system-x86 mtools dosfstools"

.PHONY: all floppy asm run run-log run-debug clean help always
.DEFAULT_GOAL := help
