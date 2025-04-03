# Variables
ASM := nasm
QEMU := qemu-system-x86_64
STAGE1_SRC := boot/stage1.asm
STAGE1_OUT := out/stage1.bin
DISK_IMG := out/disk.img
BOOTLOADER_SIZE := 512
DISK_SIZE := 1440K  # Standard floppy size

# Main target
all: $(DISK_IMG) run

# Assemble bootloader
$(STAGE1_OUT): $(STAGE1_SRC)
	@mkdir -p out
	$(ASM) -f bin $(STAGE1_SRC) -o $(STAGE1_OUT)

# Create disk image with bootloader
$(DISK_IMG): $(STAGE1_OUT)
	@dd if=/dev/zero of=$(DISK_IMG) bs=$(BOOTLOADER_SIZE) count=1
	@dd if=$(STAGE1_OUT) of=$(DISK_IMG) conv=notrunc
	@truncate -s $(DISK_SIZE) $(DISK_IMG)

# Run in QEMU (as floppy)
run: $(DISK_IMG)
	$(QEMU) -fda $(DISK_IMG) -boot a

# Run with debug options
debug: $(DISK_IMG)
	$(QEMU) -fda $(DISK_IMG) -boot a -d int -no-reboot -no-shutdown

# Clean build artifacts
clean:
	rm -rf out

.PHONY: all run debug clean