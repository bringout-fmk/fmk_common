VERZIJA=CDX
MODUL=ld_1rpt

include /sclib/Makefile_clipper

SRCDOSROOT=c:\\dev\\fmk\\ld\\rpt\\1g\\

PRGS=mnu_izvj.prg rpt_rek.prg izvj.prg izvj2.prg rpt_spec.prg rpt_kart.prg rpt_plsp.prg rpt_ppl.prg rpt_prim.prg rpt_rek.prg rpt_rnet.prg rpt_pprn.prg rpt_ahon.prg rpt_ut.prg

CS=
ASMS=

OBJS=$(OBJPRGS) $(OBJCS) $(OBJASMS)

all: $(OBJS)
	rm -f $(MODUL).lib 
	$(LIBEXE) $(MODUL) $(LIBCMD) ,,
	cp $(MODUL).lib $(LIB_DEST)

	
clean:
	rm -f *~
	rm -f *.xref
	rm -f *.xrefs
	rm -f *.html
	rm -f *.OBJ *.obj
	rm -f xref_files
	rm -f $(OBJS) *.bak *.BAK


