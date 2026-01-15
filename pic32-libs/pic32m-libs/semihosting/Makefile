# 
# Makefile for libmips-semihost.a
#

ROOT		:=$(shell pwd)
include 	../defines.mk

MAKEFILE	=-f $(ROOT)/libmips-semihost.mk

all:
	@$(MAKE) doall T=all

install-baseline:
	@$(MAKE) doall T=install

install:
	@$(MAKE) doall T=install

install-proc:

install-src:

clean:
	@$(MAKE) doall T=clean
	[ ! -d OBJ ] || rm -r OBJ
	rm -f *[~#]

doall: 
	-mkdir -p OBJ
	set -e; \
	for i in `$(CC) --print-multi-lib`; do \
	  rdir=`echo $$i | sed -e 's/;.*$$//'`; dir=OBJ/$$rdir; \
	  flags=`echo $$i | sed -e 's/^[^;]*;//' -e 's/@/ -/g'`; \
	  if echo "$$flags" | egrep -v '$(SKIPARCHS)' >/dev/null; then \
	    if [ -d $$dir ]; then true; else mkdir -p $$dir; fi; \
	    $(MAKE) -C $$dir $(MAKEFILE) VAR="$$flags" SUBDIR=$$rdir $F $T; \
	  fi; \
	done

doone: 
	-mkdir -p OBJ
	rdir=`$(CC) --print-multi-dir $(VAR)`; \
	  dir=OBJ/$$rdir; \
	  if [ -d $$dir ]; then true; else mkdir -p $$dir; fi; \
	  $(MAKE) -C $$dir $(MAKEFILE) VAR="$(VAR)" SUBDIR=$$rdir $F $T

.PHONY: all install clean doall doone dodir install-baseline install-proc
