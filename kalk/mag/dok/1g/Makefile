VERZIJA=CDX
MODUL=ka_m1dok

include /cl/sigma/Makefile_clipper

SRCDOSROOT=h:\\cl\\sigma\\fmk\\kalk\\mag\\dok\\1g\\

PRGS=frm_10.prg frm_14.prg frm_16.prg frm_18.prg frm_82.prg frm_94.prg frm_95.prg frm_im.prg frm_15.prg rpt_10.prg rpt_10nc.prg rpt_10sk.prg rpt_14.prg rpt_18.prg rpt_82.prg rpt_95nv.prg rpt_95sk.prg rpt_im.prg rpt_15.prg

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

