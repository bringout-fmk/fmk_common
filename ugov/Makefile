VERZIJA=CDX
MODUL=fmk_ugov

include /sclib/Makefile_clipper

SRCDOSROOT=h:\\dev\\fmk\\AF\\cl-AF\\ugov\\


PRGS=ugov.prg genug.prg

CS=
ASMS=

OBJS=$(OBJPRGS) $(OBJCS) $(OBJASMS)



all: $(OBJS)
	rm -f $(MODUL)$(LIBEXT) 
	$(LIBEXE) $(MODUL)$(LIBEXT) $(LIBCMD) $(LIBSUFFIX)
	cp $(MODUL)$(LIBEXT) $(LIB_DEST)

clean:
	rm -f *~
	rm -f *.xref
	rm -f *.xrefs
	rm -f *.html

