PREFIX=pic32m
TARGET=pic32m
AS	=$(PREFIX)-as
AR	=$(PREFIX)-ar
CC	=$(PREFIX)-gcc
STRIP   =$(PREFIX)-strip

SKIPARCHS=none

#EXCEPT	=-fexceptions

GPOPT	= -G0

# Minimal backtrace debug info, no assertion checking
DEBUG	= -g -fvar-tracking -fframe-base-loclist
ASSERT	= -DNDEBUG=1
PLATFORM = -ffreestanding -ffunction-sections -minterlink-compressed -mchp-stack-usage
CFLAGS	= $(VAR) $(OPTIM) $(GPOPT) $(DEBUG) $(ASSERT) $(EXCEPT) $(PLATFORM)
ASFLAGS	= $(VAR) $(GPOPT) $(ASSERT) $(EXCEPT) $(PLATFORM)
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
