include	$(ROOT)/../defines.mk

include $(ROOT)/arch/mips/Makefile.inc
include $(ROOT)/stubs/Makefile.inc
include $(ROOT)/startup/Makefile.inc
include $(ROOT)/default_vector_dispatch/Makefile.inc

vpath	%.c		$(_VPATH)
vpath	%.cc		$(_VPATH)
vpath	%.s		$(_VPATH)
vpath	%.sx		$(_VPATH)
vpath	%.S		$(_VPATH)
vpath	%.h		$(_VPATH)
vpath	Makefile	$(_VPATH)

# Force optimisation, but no inlining/unrolling
OPTIM	=-O2 -fno-inline-functions -fno-unroll-loops \
	 -foptimize-sibling-calls -ffunction-sections \
	 -fno-common -fno-builtin-exit -fno-builtin-abort -minterlink-mips16 \
	 -fno-jump-tables
PLATFORM += -fframe-base-loclist -mno-smart-io -Wcast-align -Wall

CPPFLAGS = -DNDEBUG=1 -D__LIBBUILD__ -I$(ROOT)/include -I$(ROOT)/../include

all: libpic32.a startup_modules

libpic32.a: Makefile $(LIBOBJ)
	$(STRIP) $(STRIPFLAGS) $(LIBOBJ)
	$(AR) rcs $@ $(LIBOBJ)

startup_modules:  Makefile $(SUPOBJ)
	$(STRIP) $(STRIPFLAGS) $(SUPOBJ)

install: libpic32.a startup_modules
	mkdir -p $(LIBDESTDIR)/$(SUBDIR)
	rm -f $(LIBDESTDIR)/$(SUBDIR)/libpic32.a
	cp -p libpic32.a $(LIBDESTDIR)/$(SUBDIR)/libpic32.a
	@rm -f $(addprefix $(LIBDESTDIR)/$(SUBDIR)/,$(SUPOBJ))
	cp -p $(SUPOBJ) $(LIBDESTDIR)/$(SUBDIR)

clean:
	rm -f libpic32.a *.o core* *~

