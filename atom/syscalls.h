/**
 * @file syscalls.h
 * @brief Newlib system call stubs for Atom library integration
 *
 * Include this header and call syscalls_init() to enable printf() and
 * other libc functions with your Atom streams.
 */

#ifndef _SYSCALLS_H_
#define _SYSCALLS_H_

#include "atom.h"
#include "stream.h"

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Initialize the syscalls layer with a console stream
 *
 * @param console  Stream to use for stdin/stdout/stderr
 * @return s_ok on success
 *
 * Call this early in main() before using printf() or other libc I/O functions.
 *
 * Example:
 * @code
 *   stream_t* console;
 *   uart_create_stream(UART1, 115200, &console);
 *   syscalls_init(console);
 *   
 *   printf("Hello from Atom!\n");  // Now works!
 * @endcode
 */
result_t syscalls_init(stream_t* console);

/**
 * Set a specific file descriptor to a stream
 *
 * Use this to redirect stdin/stdout/stderr or add additional file descriptors.
 *
 * @param fd      File descriptor (0 = stdin, 1 = stdout, 2 = stderr, 3+ = files)
 * @param stream  Stream to associate with fd
 * @return s_ok on success
 *
 * Example - redirect stderr to a different UART:
 * @code
 *   stream_t* error_uart;
 *   uart_create_stream(UART2, 115200, &error_uart);
 *   syscalls_set_fd(2, error_uart);  // stderr now goes to UART2
 * @endcode
 */
result_t syscalls_set_fd(int fd, stream_t* stream);

/**
 * Allocate a new file descriptor for a stream
 *
 * @param stream  Stream to associate
 * @return File descriptor (>= 3) or -1 if no descriptors available
 *
 * Example:
 * @code
 *   handle_t file;
 *   fs_open(filesystem, "data.txt", STREAM_O_RDONLY, &file);
 *   int fd = syscalls_alloc_fd((stream_t*)file);
 *   
 *   // Now you can use fd with read(), write(), etc.
 *   char buf[100];
 *   read(fd, buf, sizeof(buf));
 * @endcode
 */
int syscalls_alloc_fd(stream_t* stream);

#ifdef __cplusplus
}
#endif

#endif /* _SYSCALLS_H_ */
