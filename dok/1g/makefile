VERZIJA=CDX
MODUL=ld_1dok

include /sclib/Makefile_clipper

SRCDOSROOT=h:\\dev\\fmk\\ld\\dok\\1g\\

PRGS=mnu_obr.prg mnu_bris.prg mnu_rek.prg unos.prg brisi.prg rekalk.prg zak_obr.prg

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


