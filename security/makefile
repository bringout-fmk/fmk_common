VERZIJA=CDX
MODUL=fmk_sec

include /sclib/Makefile_clipper

SRCDOSROOT=c:\\dev\\fmk\\AF\\cl-AF\\security\\

PRGS=db.prg main.prg mnu_sec.prg

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


