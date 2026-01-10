/**
 * @file syscalls.c
 * @brief Newlib system call stubs for Atom library integration
 *
 * This file implements the system call interface that newlib requires.
 * These stubs bridge newlib's libc functions (printf, malloc, etc.) to
 * the Atom library's stream and memory management interfaces.
 *
 * The functions here are weak symbols - you can override individual
 * functions in your application if needed.
 *
 * Required Atom headers:
 *   - atom.h (or neutron.h)
 *   - stream.h
 *
 * Usage:
 *   1. Include this file in your build
 *   2. Call syscalls_init() early in main() with your console stream
 *   3. printf(), malloc(), etc. will now work
 *
 * @note File descriptor mapping:
 *   - fd 0: stdin  (console_stream->read)
 *   - fd 1: stdout (console_stream->write)
 *   - fd 2: stderr (console_stream->write)
 *   - fd 3+: available for file streams if atom_open is implemented
 */

#include <sys/stat.h>
#include <sys/types.h>
#include <sys/times.h>
#include <errno.h>
#include <stdint.h>
#include <string.h>

/* Include Atom library headers */
#include "atom.h"
#include "stream.h"

/*============================================================================
 * Configuration
 *============================================================================*/

/**
 * Maximum number of open file descriptors.
 * fd 0-2 are reserved for stdin/stdout/stderr
 */
#ifndef SYSCALLS_MAX_FDS
#define SYSCALLS_MAX_FDS 16
#endif

/**
 * Heap configuration - define these in your linker script or board config
 */
extern uint8_t _heap_start[];   /* Start of heap (from linker script) */
extern uint8_t _heap_end[];     /* End of heap (from linker script) */

/*============================================================================
 * Internal State
 *============================================================================*/

/* Console stream for stdin/stdout/stderr */
static stream_t* console_stream = NULL;

/* File descriptor table */
static stream_t* fd_table[SYSCALLS_MAX_FDS] = {NULL};

/* Current heap pointer */
static uint8_t* heap_ptr = NULL;

/* Initialization flag */
static int syscalls_initialized = 0;

/*============================================================================
 * Initialization
 *============================================================================*/

/**
 * Initialize the syscalls layer with a console stream
 *
 * @param console  Stream to use for stdin/stdout/stderr
 * @return s_ok on success
 *
 * Call this early in main() before using printf() or other libc I/O functions.
 *
 * Example:
 *   stream_t* console;
 *   uart_create_stream(UART1, 115200, &console);
 *   syscalls_init(console);
 */
result_t syscalls_init(stream_t* console)
{
    if (console == NULL)
        return e_bad_parameter;

    console_stream = console;
    
    /* Map fd 0-2 to console */
    fd_table[0] = console;  /* stdin */
    fd_table[1] = console;  /* stdout */
    fd_table[2] = console;  /* stderr */
    
    /* Initialize heap pointer */
    heap_ptr = _heap_start;
    
    syscalls_initialized = 1;
    
    return s_ok;
}

/**
 * Set a specific file descriptor to a stream
 *
 * @param fd      File descriptor (0-SYSCALLS_MAX_FDS-1)
 * @param stream  Stream to associate with fd
 * @return s_ok on success
 */
result_t syscalls_set_fd(int fd, stream_t* stream)
{
    if (fd < 0 || fd >= SYSCALLS_MAX_FDS)
        return e_bad_parameter;
    
    fd_table[fd] = stream;
    return s_ok;
}

/**
 * Allocate a new file descriptor for a stream
 *
 * @param stream  Stream to associate
 * @return File descriptor (>= 3) or -1 on error
 */
int syscalls_alloc_fd(stream_t* stream)
{
    for (int i = 3; i < SYSCALLS_MAX_FDS; i++) {
        if (fd_table[i] == NULL) {
            fd_table[i] = stream;
            return i;
        }
    }
    return -1;  /* No free descriptors */
}

/*============================================================================
 * Newlib System Call Stubs
 *
 * These are the functions that newlib calls for OS services.
 * They are declared weak so applications can override them if needed.
 *============================================================================*/

/**
 * Write to a file descriptor
 *
 * This is the core output function - printf() ultimately calls this.
 */
__attribute__((weak))
int _write(int fd, const char* buf, int count)
{
    if (fd < 0 || fd >= SYSCALLS_MAX_FDS) {
        errno = EBADF;
        return -1;
    }
    
    stream_t* stream = fd_table[fd];
    if (stream == NULL) {
        errno = EBADF;
        return -1;
    }
    
    /* Use Atom stream write */
    result_t result = stream->write((handle_t)stream, buf, (uint32_t)count);
    
    if (failed(result)) {
        errno = EIO;
        return -1;
    }
    
    return count;
}

/**
 * Read from a file descriptor
 *
 * This is the core input function - scanf() and getchar() use this.
 */
__attribute__((weak))
int _read(int fd, char* buf, int count)
{
    if (fd < 0 || fd >= SYSCALLS_MAX_FDS) {
        errno = EBADF;
        return -1;
    }
    
    stream_t* stream = fd_table[fd];
    if (stream == NULL || stream->read == NULL) {
        errno = EBADF;
        return -1;
    }
    
    uint32_t bytes_read = 0;
    result_t result = stream->read((handle_t)stream, buf, (uint32_t)count, &bytes_read);
    
    if (failed(result)) {
        errno = EIO;
        return -1;
    }
    
    return (int)bytes_read;
}

/**
 * Open a file
 *
 * Override this if you have a filesystem in Atom.
 * Default implementation only supports the pre-opened console streams.
 */
__attribute__((weak))
int _open(const char* name, int flags, int mode)
{
    (void)name;
    (void)flags;
    (void)mode;
    
    /* 
     * TODO: Implement if you have a filesystem
     * 
     * Example with Atom filesystem:
     *   handle_t hndl;
     *   result_t result = atom_open(filesystem, name, flags, &hndl);
     *   if (succeeded(result)) {
     *       return syscalls_alloc_fd((stream_t*)hndl);
     *   }
     */
    
    errno = ENOENT;
    return -1;
}

/**
 * Close a file descriptor
 */
__attribute__((weak))
int _close(int fd)
{
    if (fd < 0 || fd >= SYSCALLS_MAX_FDS) {
        errno = EBADF;
        return -1;
    }
    
    /* Don't close stdin/stdout/stderr */
    if (fd < 3) {
        return 0;
    }
    
    stream_t* stream = fd_table[fd];
    if (stream == NULL) {
        errno = EBADF;
        return -1;
    }
    
    /* Close the stream if it has a close method (via etherealize) */
    /* neutron_free will call the type's etherealize function */
    neutron_free(stream);
    fd_table[fd] = NULL;
    
    return 0;
}

/**
 * Seek within a file
 */
__attribute__((weak))
int _lseek(int fd, int offset, int whence)
{
    if (fd < 0 || fd >= SYSCALLS_MAX_FDS) {
        errno = EBADF;
        return -1;
    }
    
    stream_t* stream = fd_table[fd];
    if (stream == NULL) {
        errno = EBADF;
        return -1;
    }
    
    /* Check if stream supports seeking */
    if (stream->setpos == NULL || stream->getpos == NULL) {
        errno = ESPIPE;  /* Illegal seek (e.g., on a pipe/console) */
        return -1;
    }
    
    /* Map POSIX whence to Atom STREAM_SEEK_* */
    uint32_t atom_whence;
    switch (whence) {
        case 0: atom_whence = STREAM_SEEK_SET; break;  /* SEEK_SET */
        case 1: atom_whence = STREAM_SEEK_CUR; break;  /* SEEK_CUR */
        case 2: atom_whence = STREAM_SEEK_END; break;  /* SEEK_END */
        default:
            errno = EINVAL;
            return -1;
    }
    
    result_t result = stream->setpos((handle_t)stream, offset, atom_whence);
    if (failed(result)) {
        errno = EIO;
        return -1;
    }
    
    /* Return new position */
    uint32_t pos;
    result = stream->getpos((handle_t)stream, &pos);
    if (failed(result)) {
        errno = EIO;
        return -1;
    }
    
    return (int)pos;
}

/**
 * Get file status
 *
 * Returns minimal information - override for real filesystem support.
 */
__attribute__((weak))
int _fstat(int fd, struct stat* st)
{
    if (fd < 0 || fd >= SYSCALLS_MAX_FDS || st == NULL) {
        errno = EBADF;
        return -1;
    }
    
    memset(st, 0, sizeof(*st));
    
    /* Console streams are character devices */
    if (fd < 3) {
        st->st_mode = S_IFCHR;
        return 0;
    }
    
    stream_t* stream = fd_table[fd];
    if (stream == NULL) {
        errno = EBADF;
        return -1;
    }
    
    /* If stream has length function, report as regular file */
    if (stream->length != NULL) {
        uint32_t len;
        if (succeeded(stream->length((handle_t)stream, &len))) {
            st->st_mode = S_IFREG;
            st->st_size = len;
            return 0;
        }
    }
    
    /* Default: character device */
    st->st_mode = S_IFCHR;
    return 0;
}

/**
 * Check if file descriptor is a terminal
 */
__attribute__((weak))
int _isatty(int fd)
{
    /* fd 0-2 are console, which is a TTY */
    if (fd >= 0 && fd <= 2) {
        return 1;
    }
    return 0;
}

/**
 * Extend the heap for malloc()
 *
 * This is the critical function for dynamic memory allocation.
 * newlib's malloc() calls this when it needs more memory.
 */
__attribute__((weak))
void* _sbrk(ptrdiff_t incr)
{
    if (heap_ptr == NULL) {
        heap_ptr = _heap_start;
    }
    
    uint8_t* prev_heap = heap_ptr;
    uint8_t* new_heap = heap_ptr + incr;
    
    /* Check for heap overflow */
    if (new_heap > _heap_end || new_heap < _heap_start) {
        errno = ENOMEM;
        return (void*)-1;
    }
    
    heap_ptr = new_heap;
    return prev_heap;
}

/**
 * Exit the program
 */
__attribute__((weak))
void _exit(int status)
{
    (void)status;
    
    /* On embedded systems, we typically just halt */
    while (1) {
        /* Could enter low-power mode here */
        __asm__ volatile ("wait");
    }
}

/**
 * Kill a process (not supported on bare metal)
 */
__attribute__((weak))
int _kill(int pid, int sig)
{
    (void)pid;
    (void)sig;
    errno = EINVAL;
    return -1;
}

/**
 * Get process ID
 */
__attribute__((weak))
int _getpid(void)
{
    return 1;  /* Single process system */
}

/**
 * Get process times
 *
 * Override if you have a system tick counter.
 */
__attribute__((weak))
clock_t _times(struct tms* buf)
{
    (void)buf;
    return (clock_t)-1;
}

/**
 * Create a symbolic link (not supported)
 */
__attribute__((weak))
int _link(const char* old, const char* new)
{
    (void)old;
    (void)new;
    errno = EMLINK;
    return -1;
}

/**
 * Remove a file
 */
__attribute__((weak))
int _unlink(const char* name)
{
    (void)name;
    errno = ENOENT;
    return -1;
}

/**
 * Wait for child process (not supported)
 */
__attribute__((weak))
int _wait(int* status)
{
    (void)status;
    errno = ECHILD;
    return -1;
}

/**
 * Fork process (not supported)
 */
__attribute__((weak))
int _fork(void)
{
    errno = EAGAIN;
    return -1;
}

/**
 * Execute a program (not supported)
 */
__attribute__((weak))
int _execve(const char* name, char* const* argv, char* const* env)
{
    (void)name;
    (void)argv;
    (void)env;
    errno = ENOMEM;
    return -1;
}

/**
 * File stat by name (not supported without filesystem)
 */
__attribute__((weak))
int _stat(const char* file, struct stat* st)
{
    (void)file;
    (void)st;
    errno = ENOENT;
    return -1;
}

/*============================================================================
 * Reentrant Versions (if REENTRANT_SYSCALLS_PROVIDED is defined)
 *
 * These pass a _reent structure for thread-local errno handling.
 * The implementation simply forwards to the non-reentrant versions.
 *============================================================================*/

#ifdef REENTRANT_SYSCALLS_PROVIDED

#include <reent.h>

int _write_r(struct _reent* r, int fd, const void* buf, size_t count)
{
    int ret = _write(fd, buf, count);
    if (ret < 0) r->_errno = errno;
    return ret;
}

int _read_r(struct _reent* r, int fd, void* buf, size_t count)
{
    int ret = _read(fd, buf, count);
    if (ret < 0) r->_errno = errno;
    return ret;
}

int _open_r(struct _reent* r, const char* name, int flags, int mode)
{
    int ret = _open(name, flags, mode);
    if (ret < 0) r->_errno = errno;
    return ret;
}

int _close_r(struct _reent* r, int fd)
{
    int ret = _close(fd);
    if (ret < 0) r->_errno = errno;
    return ret;
}

off_t _lseek_r(struct _reent* r, int fd, off_t offset, int whence)
{
    int ret = _lseek(fd, offset, whence);
    if (ret < 0) r->_errno = errno;
    return ret;
}

int _fstat_r(struct _reent* r, int fd, struct stat* st)
{
    int ret = _fstat(fd, st);
    if (ret < 0) r->_errno = errno;
    return ret;
}

int _isatty_r(struct _reent* r, int fd)
{
    (void)r;
    return _isatty(fd);
}

void* _sbrk_r(struct _reent* r, ptrdiff_t incr)
{
    void* ret = _sbrk(incr);
    if (ret == (void*)-1) r->_errno = errno;
    return ret;
}

int _kill_r(struct _reent* r, int pid, int sig)
{
    int ret = _kill(pid, sig);
    if (ret < 0) r->_errno = errno;
    return ret;
}

int _getpid_r(struct _reent* r)
{
    (void)r;
    return _getpid();
}

#endif /* REENTRANT_SYSCALLS_PROVIDED */

/*============================================================================
 * Optional: Time Support
 *
 * Uncomment and implement if you need time() to work.
 *============================================================================*/

#if 0
#include <time.h>

/**
 * Get current time
 *
 * Implement using your RTC or system tick.
 */
__attribute__((weak))
int _gettimeofday(struct timeval* tv, void* tz)
{
    (void)tz;
    
    if (tv == NULL) {
        errno = EINVAL;
        return -1;
    }
    
    /* 
     * TODO: Implement using Atom's now() function or RTC
     * 
     * tm_t tm;
     * now(&tm);
     * Convert tm to Unix timestamp...
     */
    
    tv->tv_sec = 0;
    tv->tv_usec = 0;
    
    return 0;
}
#endif
