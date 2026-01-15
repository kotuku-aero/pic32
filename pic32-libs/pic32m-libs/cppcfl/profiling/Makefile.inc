_VPATH	+=:$(ROOT)/profiling

SUPOBJ  += cp_flp_dc.o cp_dcword_common.o

cp_flp_dc.o: OPTIM += -Os
