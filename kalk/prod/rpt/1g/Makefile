VERZIJA=CDX
MODUL=ka_p1rpt

include /cl/sigma/Makefile_clipper

SRCDOSROOT=h:\\cl\\sigma\\fmk\\kalk\\prod\\rpt\\1g\\

PRGS=frm_kpro.prg mnu_izvj.prg rpt_81.prg rpt_all.prg rpt_fllp.prg rpt_ip.prg rpt_kpro.prg rpt_llp.prg rpt_llps.prg rpt_olpp.prg rpt_rflp.prg rpt_rrp.prg rpt_rup.prg

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


