#!/bin/bash

# Install required packages for Ubuntu/WSL2
echo "Installing dependencies for HssOS development on Ubuntu/WSL2..."

# Update package lists
sudo apt-get update

# Install basic tools
sudo apt-get install -y build-essential
sudo apt-get install -y nasm
sudo apt-get install -y qemu-system-x86
sudo apt-get install -y gcc-multilib
sudo apt-get install -y gdb

# Check installation
echo "Checking installations:"
echo -n "NASM: "
nasm --version | head -n 1
echo -n "GCC: "
gcc --version | head -n 1
echo -n "QEMU: "
qemu-system-x86_64 --version | head -n 1

echo "Setup complete! You can now build HssOS with 'make all'"