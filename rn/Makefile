VERZIJA=CDX
MODUL=fmk_rn

include /sclib/Makefile_clipper

SRCDOSROOT=c:\\dev\\fmk\\\AF\\cl-AF\\rn\\


PRGS=rb_traka.prg pf_a4.prg pf_a4_2.prg pf_traka.prg pf_db.prg rn_ut.prg otpr_mp.prg nar.prg
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


