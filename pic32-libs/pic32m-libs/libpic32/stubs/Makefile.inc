_VPATH	+=:$(ROOT)/stubs

LIBOBJ	+= sbrk.o default-general-exception-handler.o \
	default-bootstrap-exception-handler.o default-on-reset.o \
	default-on-bootstrap.o default-nmi-handler.o \
	 _exit.o \
	system.o \
	default-gettimeofday.o isatty.o
LIBOBJ += _mon_getc.o _mon_putc.o _mon_puts.o _mon_write.o
LIBOBJ += read.o
LIBOBJ += write.o
LIBOBJ += lseek.o
LIBOBJ += remove.o
LIBOBJ += close.o
LIBOBJ += getenv.o
LIBOBJ += rename.o
LIBOBJ += open.o
LIBOBJ += unlink.o
LIBOBJ += kill.o
LIBOBJ += getpid.o
LIBOBJ += xc32_uart.o
LIBOBJ += errno.o
LIBOBJ += rmdir.o
LIBOBJ += isinf.o
LIBOBJ += pic32_data_init_core.o
LIBOBJ += pic32_data_init_clear.o
LIBOBJ += pic32_data_init_copy.o
LIBOBJ += pic32_data_init_copy_emb.o
LIBOBJ += pic32_data_init_copy_val.o
LIBOBJ += pic32_data_init_decompress.o
LIBOBJ += pic32_init_cache.o
LIBOBJ += pic32_init_tlb_ebi_sqi.o
LIBOBJ += default-cache-err-exception-handler.o
LIBOBJ += default-simple-tlb-refill-exception-handler.o
LIBOBJ += pic32_software_reset.o
LIBOBJ += fstat.o

# LIBOBJ += stubs.o getenv.o 
# LIBOBJ += raise.o signal.o localeconv.o setlocale.o isatty.o

SUPOBJ  += pic32_software_reset.o

sbrk.o: CPPFLAGS += -DPAGESIZE=128
sbrk.o: sbrk.c
