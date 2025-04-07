#!/bin/bash

# Install required packages for macOS
echo "Installing dependencies for HssOS development on macOS..."

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Please install Homebrew first:"
    echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    exit 1
fi

# Install dependencies
brew install nasm
brew install qemu
brew install x86_64-elf-gcc
brew install x86_64-elf-binutils

# Check installation
echo "Checking installations:"
echo -n "NASM: "
nasm --version | head -n 1
echo -n "x86_64-elf-gcc: "
x86_64-elf-gcc --version | head -n 1
echo -n "QEMU: "
qemu-system-x86_64 --version | head -n 1

echo "Setup complete! You can now build HssOS with 'make all'"