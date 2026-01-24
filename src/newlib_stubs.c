/*
 * Newlib System Call Stubs for PIC32 Bare Metal
 *
 * OVERVIEW:
 * Newlib (the C standard library) expects certain POSIX-like system calls
 * to be provided by the platform. Since PIC32 is bare-metal (no OS), we
 * provide minimal stub implementations.
 *
 * These stubs allow programs to link but may return errors for operations
 * that don't make sense in a bare-metal environment (like file I/O).
 *
 * USAGE:
 * This is a reference implementation. You can:
 *  1. Use as-is for simple applications
 *  2. Customize for your specific needs (e.g., connect write() to UART)
 *  3. Replace with your own RTOS-specific implementations
 *
 * INTEGRATION:
 * Add this file to a library that gets linked AFTER the standard libraries:
 *   target_link_libraries(your_app PRIVATE c m gcc your_stubs_lib)
 *
 * CUSTOMIZATION NOTES:
 * - sbrk(): Currently calls panic() - customize if you need malloc support
 * - write(): Silently succeeds - connect to UART for printf output
 * - read(): Returns EOF - connect to UART for scanf/getchar input
 * - _exit(): Infinite loop - could trigger watchdog or jump to bootloader
 */

#include <sys/stat.h>
#include <sys/types.h>
#include <errno.h>

/*
 * errno implementation
 * Newlib expects a per-thread errno, but in bare metal we use a simple global.
 */
static int _errno = 0;
int *__errno(void) {
    return &_errno;
}

/*
 * panic - User-provided function (optional)
 * If you don't provide panic(), remove the extern and the call in sbrk().
 */
extern void panic(void) __attribute__((weak));

/*
 * sbrk - Increase program data space
 *
 * HEAP ALLOCATION:
 * This is called by malloc() to expand the heap.
 *
 * CURRENT IMPLEMENTATION:
 * Calls panic() to catch unexpected malloc usage. This is useful when:
 *  - You have a custom allocator (e.g., thread-safe pool allocator)
 *  - You want to ensure malloc is never called
 *
 * ALTERNATIVE IMPLEMENTATION:
 * For standard malloc support, you would implement:
 *   static char *heap_end = 0;
 *   extern char _end;           // Defined by linker (end of BSS)
 *   extern char _stack;         // Defined by linker (top of stack)
 *
 *   if (heap_end == 0) heap_end = &_end;
 *   char *prev_heap_end = heap_end;
 *
 *   // Check for collision with stack
 *   if (heap_end + incr > &_stack) {
 *       errno = ENOMEM;
 *       return (void *)-1;
 *   }
 *
 *   heap_end += incr;
 *   return (void *)prev_heap_end;
 */
void *sbrk(int incr) {
    (void)incr;

    // If panic is provided, call it
    if (panic) {
        panic();
    }

    // Otherwise just fail
    errno = ENOMEM;
    return (void *)-1;
}

/*
 * _exit - Terminate program execution
 * Called when program exits or abort() is called.
 *
 * IMPLEMENTATION:
 * Disables interrupts and enters infinite low-power loop.
 * A debugger can catch this by setting a breakpoint here.
 *
 * ALTERNATIVES:
 *  - Jump to bootloader
 *  - Trigger watchdog reset
 *  - Enter low-power sleep mode
 */
void _exit(int status) {
    (void)status;  // Unused in bare metal

    // Disable interrupts
    __asm__ volatile ("di");

    // Infinite loop - debugger can catch this
    while (1) {
        __asm__ volatile ("wait");  // Low power wait
    }
}

/*
 * close - Close a file descriptor
 * Not supported in bare metal environment.
 */
int close(int file) {
    (void)file;
    errno = EBADF;  // Bad file descriptor
    return -1;
}

/*
 * fstat - Get file status
 *
 * IMPLEMENTATION:
 * Returns minimal information claiming the file is a character device.
 * This allows isatty() and similar functions to work correctly.
 */
int fstat(int file, struct stat *st) {
    (void)file;

    // Make it look like a character device (for stdout/stderr)
    st->st_mode = S_IFCHR;
    return 0;
}

/*
 * isatty - Check if file descriptor is a terminal
 * Return 1 for stdin/stdout/stderr, 0 otherwise.
 *
 * This allows printf/scanf to work correctly.
 */
int isatty(int file) {
    // Consider stdin(0), stdout(1), stderr(2) as TTY
    return (file >= 0 && file <= 2) ? 1 : 0;
}

/*
 * lseek - Reposition file offset
 * Not supported in bare metal environment.
 */
int lseek(int file, int ptr, int dir) {
    (void)file;
    (void)ptr;
    (void)dir;
    errno = ESPIPE;  // Illegal seek
    return -1;
}

/*
 * read - Read from a file descriptor
 *
 * CURRENT IMPLEMENTATION:
 * Returns 0 (EOF) - getchar/scanf will fail.
 *
 * UART INTEGRATION EXAMPLE:
 *   if (file == 0) {  // stdin
 *       for (int i = 0; i < len; i++) {
 *           ptr[i] = uart_getchar();  // Your UART function
 *       }
 *       return len;
 *   }
 *   return 0;
 */
int read(int file, char *ptr, int len) {
    (void)file;
    (void)ptr;
    (void)len;
    return 0;  // EOF
}

/*
 * write - Write to a file descriptor
 *
 * CURRENT IMPLEMENTATION:
 * Silently succeeds - printf output is discarded.
 *
 * UART INTEGRATION EXAMPLE:
 *   if (file == 1 || file == 2) {  // stdout/stderr
 *       for (int i = 0; i < len; i++) {
 *           uart_putchar(ptr[i]);  // Your UART function
 *       }
 *   }
 *   return len;
 */
int write(int file, char *ptr, int len) {
    (void)file;
    (void)ptr;

    // Could output to UART here if needed
    // For now, just pretend we wrote the data
    return len;
}

/*
 * kill - Send signal to a process
 * Not supported in bare metal (no processes).
 */
int kill(int pid, int sig) {
    (void)pid;
    (void)sig;
    errno = EINVAL;
    return -1;
}

/*
 * getpid - Get process ID
 * Not supported in bare metal (no processes).
 * Returns a dummy PID to satisfy newlib.
 */
int getpid(void) {
    return 1;  // Return a dummy PID
}
