VERZIJA=CDX
MODUL=ka_p1dok
#include "\cl\sigma\fmk\kalk\kalk.ch"

include /cl/sigma/Makefile_clipper

SRCDOSROOT=h:\\cl\\sigma\\fmk\\kalk\\prod\\dok\\1g\\

PRGS=frm_11.prg frm_12.prg frm_41.prg frm_80.prg frm_19.prg frm_81.prg frm_all.prg frm_ip.prg rpt_11.prg rpt_11_3.prg rpt_11nc.prg rpt_19.prg rpt_41.prg rpt_80.prg

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


