VERZIJA=CDX
MODUL=fmk_evn

include /sclib/Makefile_clipper

SRCDOSROOT=h:\\dev\\fmk\\AF\\cl-AF\\event\\

PRGS=db.prg main.prg mnu_evn.prg rpt_evn.prg

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


