#!/bin/bash

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect the OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macOS"
    if ! command_exists x86_64-elf-gcc; then
        echo "x86_64-elf-gcc not found. Running setup script..."
        chmod +x install-macos-deps.sh
        ./install-macos-deps.sh
    fi
else
    OS="Linux"
    if ! command_exists gcc; then
        echo "gcc not found. Running setup script..."
        chmod +x install-ubuntu-deps.sh
        ./install-ubuntu-deps.sh
    fi
fi

# Parse command line arguments
case "$1" in
    build)
        echo "Building HssOS on $OS..."
        make
        ;;
    run)
        echo "Running HssOS on $OS..."
        make run
        ;;
    debug)
        echo "Running HssOS in debug mode on $OS..."
        make debug
        ;;
    gdb)
        echo "Running HssOS with GDB server on $OS..."
        make gdb-debug
        ;;
    clean)
        echo "Cleaning build artifacts..."
        make clean
        ;;
    setup)
        echo "Setting up dependencies for $OS..."
        if [[ "$OS" == "macOS" ]]; then
            chmod +x install-macos-deps.sh
            ./install-macos-deps.sh
        else
            chmod +x install-ubuntu-deps.sh
            ./install-ubuntu-deps.sh
        fi
        ;;
    *)
        echo "Usage: $0 {build|run|debug|gdb|clean|setup}"
        exit 1
        ;;
esac

exit 0