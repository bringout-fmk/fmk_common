VERZIJA=CDX
MODUL=ka_s1pf

include /cl/sigma/Makefile_clipper

SRCDOSROOT=h:\\cl\\sigma\\fmk\\kalk\\specif\\planika\\1g\\

PRGS=planika.prg rpt_fobm.prg db.prg db_gen1.prg db_gen2.prg db_cre.prg rpt_all.prg rpt_oinv.prg rpt_pkz.prg rpt_ppp.prg rpt_dnpr.prg rpt_rekp.prg mnu_sif.prg gen_pnc.prg pl_sif.prg

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


