VERZIJA=CDX
MODUL=fmk_roba

include /sclib/Makefile_clipper

SRCDOSROOT=c:\\dev\\fmk\\\AF\\cl-AF\\roba\\


PRGS=adm_db.prg db.prg gvars.prg id_j.prg koncij.prg roba.prg rpt_cjen.prg rpt_sast.prg sast.prg sifk.prg sifre.prg tarifa.prg trfp.prg barkod.prg rlabele.prg ut.prg
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


