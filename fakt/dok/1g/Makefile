VERZIJA=CDX
MODUL=fa_1dok
MMODUL=fakt

include /cl/sigma/Makefile_clipper

SRCDOSROOT=h:\\cl\\sigma\\fmk\\$(MMODUL)\\dok\\1g\\

PRGS=knjiz.prg stdatn.prg stdok.prg stdok13.prg stdok2.prg stdok23.prg stdok29.prg stdok295.prg stdok2a.prg stdok3.prg stdok30.prg stdokm.prg stdrtf1.prg stdrtf2.prg stdrtf21.prg stdrtf3.prg vknjiz.prg vknjiz2.prg rpt_nar.prg rpt_olpp.prg mnu_dok.prg

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


