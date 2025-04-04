// kernel/main.c

void main() {
    // This is the entry point of the os kernel
    // Essentially, this will start the lifecycle of the OS
    // and pass off jobs to other smaller kernels they all
    // return to this main function when they are done.

    // Initialize the kernel environment
    // This could include setting up memory management,
    // initializing hardware components, and more.
    // For now, we will just print a message to indicate
    // that the kernel has started successfully using the 
    // VGA buffer.

    char *vga_buffer = (char *)0xB8000; // VGA text mode buffer address

    const char *message = "Kernel started successfully!\n";

    for (int i = 0; message[i] != '\0'; i++) {
        // Each character takes 2 bytes in VGA buffer: char + attribute
        vga_buffer[i * 2] = message[i];       // Character
        vga_buffer[i * 2 + 1] = 0x07;          // Attribute (light gray on black background)
    }

    while (1) {
        // Keep the kernel running indefinitely
        // In a real kernel, this would be replaced with
        // a scheduler or an idle loop to manage tasks.
        // For now, we just loop forever to prevent exit.
        // This is a placeholder for the kernel's main loop.
    }

}