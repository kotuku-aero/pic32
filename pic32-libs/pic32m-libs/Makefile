#
# Global makefile for libraries
#
include defines.mk
SHELL=/bin/bash

SUBDIRS = cppcfl semihosting debugsupport dsp dspr2 ieee libpic32 math proc sol

# We ship with source code for some libraries
SRCINSTALL_SUBDIRS = debugsupport

headers-cppcfl = 		# Not needed: compiler generates calls
headers-debugsupport = sys/appio.h
headers-dsp = dsplib_def.h dsplib_dsp.h dsplib_video.h mchp_dsp_wrapper.h mips_unaligned.h
headers-dspr2 =
headers-ieee = ieee754.h machine/endian.h
headers-libpic32 = 		# Not needed: defines some things in C stdlib
headers-math =
headers-proc = cp0defs.h p32xxxx.h machine/cdefs.h proc/
headers-proc += sys/asm.h sys/attribs.h sys/cdefs.h sys/endian.h
headers-proc += sys/l1cache.h sys/kmem.h sys/swap.h
headers-sol = InstrumentedTrace.h

headers = $(foreach d,$(SUBDIRS),$(headers-$(d)))


all: create-machine $(SUBDIRS)

install: $(SUBDIRS) install-headers

install-src: $(SUBDIRS)
	cp Makefile $(TGTLIBSRC)
	cp defines.mk $(TGTLIBSRC)
	cp HOWTO-build-libraries-from-windows.txt $(TGTLIBSRC)
	$(foreach dir,$(shell find include -type d  | grep -v .svn), \
		mkdir -p $(TGTLIBSRC)/$(dir); \
		cp $(dir)/* ${TGTLIBSRC}/$(dir) 2>>/dev/null; )
	cd $(TGTLIBSRC)/include && rm -rf machine && cp -RL mips machine && cd -

install-baseline: $(SUBDIRS) install-headers

install-proc: proc

clean: $(SUBDIRS)

create-machine:
	cd include && rm -rf machine && cp -RL mips machine && cd ..

# Each subdirectory is optional, so only build the ones that are present
$(SUBDIRS):
	@if [[ -d $@ ]] ; then $(MAKE) -C $@ $(MAKECMDGOALS) ; fi

install-headers: create-machine
	mkdir -p ${INCDESTDIR}/pic32m-libs
	for h in $(headers); do \
	  d=$(INCDESTDIR)/pic32m-libs/$$(dirname $$h); \
	  test -d $$d || mkdir -p $$d; \
	  cp -RL ./include/$$h $$d || exit 1; \
	done
	mkdir -p $(TGTDESTDIR)/xc32/32MXGENERIC && cp ./proc/32MXGENERIC/procdefs.ld $(TGTDESTDIR)/xc32/32MXGENERIC/

.PHONY: all install clean install-headers install-baseline install-proc
.PHONY: $(SUBDIRS)

