ASM = nasm
CC = gcc
LD = ld
OUT_DIR = out
BOOT_DIR = boot
KERNEL_DIR = kernel

# Compiler flags for a freestanding kernel
CFLAGS = -m32 -ffreestanding -fno-pie -nostdlib -nostdinc -fno-builtin \
         -fno-stack-protector -nostartfiles -nodefaultlibs -Wall -Wextra -O2

# Linker flags
LDFLAGS = -m elf_i386 -nostdlib -z max-page-size=0x1000

all: $(OUT_DIR)/floppy.img

$(OUT_DIR)/stage1.bin: $(BOOT_DIR)/stage1.asm
	@mkdir -p $(OUT_DIR)
	$(ASM) -f bin $< -o $@

$(OUT_DIR)/stage2.bin: $(BOOT_DIR)/stage2.asm
	@mkdir -p $(OUT_DIR)
	$(ASM) -f bin $< -o $@

# Find all .c files in the kernel directory and subdirectories
KERNEL_SRCS := $(wildcard $(KERNEL_DIR)/*/*.c)
# Convert .c filenames to .o filenames in the output directory
KERNEL_OBJS := $(patsubst $(KERNEL_DIR)/%.c,$(OUT_DIR)/kernel/%.o,$(KERNEL_SRCS))

# Rule to compile .c files to .o files
$(OUT_DIR)/kernel/%.o: $(KERNEL_DIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -I$(KERNEL_DIR)/include -c $< -o $@

# Create the kernel binary
$(OUT_DIR)/kernel.bin: $(KERNEL_OBJS) linker.ld
	@mkdir -p $(OUT_DIR)
	$(LD) $(LDFLAGS) -T linker.ld -o $(OUT_DIR)/kernel.elf $(KERNEL_OBJS)
	objcopy -O binary $(OUT_DIR)/kernel.elf $(OUT_DIR)/kernel.bin
	@echo "Kernel size: `ls -la $(OUT_DIR)/kernel.bin | awk '{print $$5}'` bytes"

# Create floppy disk image
$(OUT_DIR)/floppy.img: $(OUT_DIR)/stage1.bin $(OUT_DIR)/stage2.bin $(OUT_DIR)/kernel.bin
	@mkdir -p $(OUT_DIR)
	# Create empty floppy image (1.44MB)
	dd if=/dev/zero of=$@ bs=512 count=2880
	# Write bootsector (first sector)
	dd if=$(OUT_DIR)/stage1.bin of=$@ bs=512 count=1 conv=notrunc
	# Write stage2 (second sector)
	dd if=$(OUT_DIR)/stage2.bin of=$@ bs=512 seek=1 count=1 conv=notrunc
	# Write kernel (starting at third sector)
	dd if=$(OUT_DIR)/kernel.bin of=$@ bs=512 seek=2 conv=notrunc

# Run in QEMU
run: $(OUT_DIR)/floppy.img
	qemu-system-i386 -fda $(OUT_DIR)/floppy.img -boot a -serial stdio

# Run with debug info in monitor
debug: $(OUT_DIR)/floppy.img
	qemu-system-i386 -fda $(OUT_DIR)/floppy.img -boot a -monitor stdio

# Run with debug info and GDB server
debuggdb: $(OUT_DIR)/floppy.img
	qemu-system-i386 -fda $(OUT_DIR)/floppy.img -boot a -s -S

clean:
	rm -rf $(OUT_DIR)/*