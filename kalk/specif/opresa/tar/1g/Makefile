VERZIJA=CDX
MODUL=ka_s1opt
#include "\cl\sigma\fmk\kalk\kalk.ch"

include /cl/sigma/Makefile_clipper

SRCDOSROOT=h:\\cl\\sigma\\fmk\\kalk\\specif\\opresa\\tar\\1g\\

PRGS=mnu_tar.prg izvj.prg


CS=
ASMS=

OBJS=$(OBJPRGS) $(OBJCS) $(OBJASMS)

all: $(OBJS)
	rm -f $(MODUL).lib 
	$(LIBEXE) $(MODUL) $(LIBCMD) ,,
	cp $(MODUL).lib $(CLIPPERROOT)$(DEBUGDIR)/$(VERZIJA)/

	
clean:
	rm -f *~
	rm -f *.xref
	rm -f *.xrefs
	rm -f *.html
	rm -f *.OBJ *.obj
	rm -f xref_files
	rm -f $(OBJS) *.bak *.BAK


