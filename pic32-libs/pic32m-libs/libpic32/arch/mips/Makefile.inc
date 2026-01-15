_VPATH	+=:$(ROOT)/arch/mips

LIBOBJ	+= setjmp.o _sync.o _xchsrspss.o
# _xxc0.o removed - incompatible with GNU assembler macros
#LIBOBJ += gmon.o


LIBOBJ	+= mulsi.o mulsidi.o multab.o divsi.o
