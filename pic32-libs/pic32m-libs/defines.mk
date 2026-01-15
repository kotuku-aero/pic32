PREFIX=mips-elf
TARGET=mips-elf
AS	=$(PREFIX)-as
AR	=$(PREFIX)-ar
CC	=$(PREFIX)-gcc
STRIP   =$(PREFIX)-strip

SKIPARCHS=none

#EXCEPT	=-fexceptions

GPOPT	= -mno-gpopt -mexplicit-relocs

# Minimal backtrace debug info, no assertion checking
DEBUG	= -g -fvar-tracking
ASSERT	= -DNDEBUG=1
ARCH_FLAGS = -march=m14k -msoft-float
PLATFORM = -ffreestanding -ffunction-sections $(ARCH_FLAGS)  -D_GNU_SOURCE -v
CFLAGS	= $(VAR) $(OPTIM) $(GPOPT) $(DEBUG) $(ASSERT) $(EXCEPT) $(PLATFORM)
ASFLAGS	= $(VAR) $(ASSERT) $(EXCEPT) $(PLATFORM)
STRIPFLAGS =-X
ARCH	=mips

DESTROOT        =$(HOME)/xc32/build/install-image
TGTDESTDIR	=$(DESTROOT)/$(TARGET)
TGTLIBSRC	=$(DESTROOT)/pic32-libs
LIBDESTDIR	=$(TGTDESTDIR)/lib
INCDESTDIR	=$(TGTDESTDIR)/include

# To enable multi-byte character support, uncomment the next line
#CFLAGS += -DMB_SUPPORT

# flags to pass to recursive makes
F		=ROOT=$(ROOT)

# Useful debugging targets.  (Recommended for any Makefile you write!)
print-%:
	@printf '%s = %s\n' "$*" "$($*)"

printvars:
	@$(foreach V,$(sort $(.VARIABLES)),\
	   $(if \
	     $(filter-out environ% default automatic,$(origin $V)),\
	       $(info $V=$($V) ($(value $V)))))
	@true
