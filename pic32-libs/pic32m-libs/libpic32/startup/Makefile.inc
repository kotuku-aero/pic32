_VPATH	+=:$(ROOT)/startup

LIBOBJ  += general-exception.o
LIBOBJ  += cache-err-exception.o
LIBOBJ  += simple-tlb-refill-exception.o

# The startup code is built as needed in XC32 builds.
# SUPOBJ	+= crt0.o mcrt0.o crti.o crtn.o cpprt0.o crt0_pic.o
SUPOBJ  += software-debug-break.o
SUPOBJ  += debug-exception-return.o

# Starting in MPLAB XC32 v1.30, we now build device-specific startup modules.
# See the device-specific Makefile (proc/<device>/Makefile)

# PIC32MX

mcrt0.o: CPPFLAGS += -DMCRT0
mcrt0.o: crt0.S
	$(CC) $(ASFLAGS) $(CPPFLAGS) -c -o $@ $<

cpprt0.o: CPPFLAGS += -DCPP_INIT
cpprt0.o: crt0.S
	$(CC) $(ASFLAGS) $(CPPFLAGS) -c -o $@ $<

crt0_pic.o: PLATFORM += -fPIC

# PIC32 all

software-debug-break.o: OPTIM += -Os
