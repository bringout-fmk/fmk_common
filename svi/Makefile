VERZIJA=CDX
MODUL=fmk_svi

include /sclib/Makefile_clipper

SRCDOSROOT=h:\\dev\\fmk\\AF\\cl-AF\\svi\\

PRGS=adm_db.prg db.prg fmk_ut.prg gvars.prg konto.prg ops.prg partn.prg rj.prg sifre.prg ut.prg valute.prg vn_vd.prg specif.prg rpt_all.prg dokstxt.prg rnal.prg

CS=
ASMS=

OBJS=$(OBJPRGS) $(OBJCS) $(OBJASMS)

ifdef CLIP

all: $(OBJS)
	clip_makeslib $(MODUL)$(LIBEXT) $(LIBCMD)
	cp $(MODUL).dll* $(LIB_DEST)

else
all: $(OBJS)
	rm -f $(MODUL)$(LIBEXT) 
	$(LIBEXE) $(MODUL)$(LIBEXT) $(LIBCMD) $(LIBSUFFIX)
	cp $(MODUL)$(LIBEXT) $(LIB_DEST)
endif

	
clean:
	rm -f *~
	rm -f *.xref
	rm -f *.xrefs
	rm -f *.html
	rm -f *.OBJ *.obj
	rm -f xref_files
	rm -f $(OBJS) *.bak *.BAK

