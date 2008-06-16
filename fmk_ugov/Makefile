ROOT = ../../harbour/harbour/

HB_INC_COMPILE += -I$(TOP)../../fmk_lib/include

PRG_SOURCES= \
	     ugov.prg genug.prg genug2.prg dest.prg m_ugov.prg \
	     rugov.prg db_ugov.prg param.prg ut.prg g_fin.prg dest_2.prg

LIBNAME=fmk_ugov

include $(TOP)$(ROOT)config/lib.cf

HB_FLAGS = -n -b -ufmk_std.ch -kM -gc0 -I$(TOP) -I$(HB_INC_COMPILE)
