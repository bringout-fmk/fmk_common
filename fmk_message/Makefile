ROOT = ../../harbour/harbour/

HB_INC_COMPILE += -I$(TOP)../../fmk_lib/include

PRG_SOURCES= \
   db.prg main.prg app_msg.prg mnu_msg.prg rpt_msg.prg

LIBNAME=fmk_message

include $(TOP)$(ROOT)config/lib.cf

HB_FLAGS = -n -b -ufmk_std.ch -kM -gc0 -I$(TOP) -I$(HB_INC_COMPILE)
