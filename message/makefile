VERZIJA=CDX
MODUL=fmk_mes

include /sclib/Makefile_clipper

SRCDOSROOT=h:\\dev\\fmk\\AF\\cl-AF\\message\\

PRGS=db.prg main.prg app_msg.prg mnu_msg.prg rpt_msg.prg

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


