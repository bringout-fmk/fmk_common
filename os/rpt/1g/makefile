VERZIJA=CDX
MODUL=os_1rpt

include /cl/sigma/Makefile_clipper

SRCDOSROOT=h:\\cl\\sigma\\fmk\\os\\rpt\\1g\\

PRGS=rpt_kart.prg rpt_rk1.prg rpt_rjre.prg rpt_rjk.prg rpt_rjam.prg rpt_prj.prg rpt_mnu.prg rpt_kias.prg rpt_amst.prg

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


