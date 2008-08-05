ROOT = ../../harbour/harbour/

HB_INC_COMPILE += -I$(TOP)../../fmk_lib/include

PRG_SOURCES= \
          adm_db.prg \
          dok_src.prg \
          gvars.prg konto.prg \
          ops.prg   partn.prg \
          relation.prg \
          rj.prg \
          rnal.prg \
          rpt_all.prg \
          sifre.prg \
          ut.prg \
          valute.prg \
          vn_vd.prg


LIBNAME=fmk_svi

include $(TOP)$(ROOT)config/lib.cf

HB_FLAGS = -n -b -ufmk_std.ch -kM -gc0 -I$(TOP) -I$(HB_INC_COMPILE)


