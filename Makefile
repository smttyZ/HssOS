# Variables
ASM = nasm
QEMU = qemu-system-x86_64
BOOTLOADER_SRC = boot/stage1.asm
BOOTLOADER_BIN = out/stage1.bin

# Main target
all: $(BOOTLOADER_BIN) run

# Assemble bootloader
$(BOOTLOADER_BIN): $(BOOTLOADER_SRC)
	mkdir -p out
	$(ASM) -f bin $(BOOTLOADER_SRC) -o $(BOOTLOADER_BIN)

# Run in QEMU
run: $(BOOTLOADER_BIN)
	$(QEMU) -drive format=raw,file=$(BOOTLOADER_BIN)

# Clean build artifacts
clean:
	rm -rf out