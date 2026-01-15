all: libmips-semihost.a

include		$(ROOT)/../defines.mk

_VPATH		:=.
include 	$(ROOT)/Makefile.inc

vpath	%.S	$(_VPATH)
vpath	%.c	$(_VPATH)

CPPFLAGS = -I$(ROOT)/include 

# build semihosting library
OPTIM = -O2 -fno-strict-aliasing

libmips-semihost.a: $(LIBOBJ)
	$(STRIP) $(STRIPFLAGS) $(LIBOBJ)
	$(AR) rcs $@ $?

install: libmips-semihost.a
	if [ -d $(LIBDESTDIR)/$(SUBDIR) ]; then \
		rm -f $(LIBDESTDIR)/$(SUBDIR)/libmips-semihost.a; \
	else \
		mkdir -p $(LIBDESTDIR)/$(SUBDIR); \
	fi
	cp -p libmips-semihost.a $(LIBDESTDIR)/$(SUBDIR)/libmips-semihost.a

clean:
	rm -f libmips-semihost.a *.o core*
