VERZIJA=CDX
MODUL=LD

PRGS=/cl/sigma/fmk/ld/main/1g/e.prg
CS=
ASMS=

include /cl/sigma/Makefile_clipper

FMK_LIBS=fmk_roba.lib fmk_svi.lib fmk_pi.lib fmk_evn.lib fmk_sec.lib fmk_mes.lib

SCLIB_LIBS=sc1g_arh.lib sc1g_ba.lib sc1g_cui.lib sc1g_db.lib sc1g_os.lib sc1g_ost.lib sc1g_par.lib sc1g_pr.lib sc1g_sif.lib sc1g_sql.lib sc1g_ut.lib sc2g_app.lib sc2g_db.lib sc1g_rpt.lib sc2g_cui.lib sc1g_key.lib 

MODUL_LIBS=ld_1db.lib ld_2db.lib ld_1dok.lib ld_1kre.lib ld_1ma.lib ld_2ma.lib ld_1par.lib ld_1rpt.lib ld_1sif.lib ld_1ut.lib 

PREF2=lib $(LIB_DOS_DEST)
FMKLIBCMD=$(addprefix $(PREF2), $(SCLIB_LIBS) $(FMK_LIBS) $(MODUL_LIBS) )


OBJS=$(OBJPRGS) $(OBJCS) $(OBJASMS)

all:    cleaneobj mod 

cleaneobj:
	rm -f /cl/sigma/fmk/ld/main/1g/e.obj
	
mod: $(OBJS)
	echo Prilikom kompilacije obj se napravi u tekucem direktoriju
	echo a blinker opet trazi obj fajl u orig direktoriju
	cp e.obj /cl/sigma/fmk/ld/main/1g/
	/cl/sigma/form_blinker_lnk.sh $(LINKCMD)
	/cl/sigma/form_blinker_lnk_2.sh $(FMKLIBCMD)
	$(LINKEREXE) @_bl_.lnk   @_bl_2_.lnk $(DEBUGLINK) @H:\\CLIPPER\\$(VERZIJA)\\BL.LNK output e.exe
	cp e.exe $(EXEDEST)/$(MODUL).EXE

zip:
	rm -f /z/fmk/$(MODUL).zip
	/cl/sigma/zip.sh z:\\fmk\\$(MODUL).zip ..\\chs\\1g\\\*.chs \\cl\\sigma\\fmk\\ld\\rpt\\rtm\\\*.rtm \\cl\\sigma\\fmk\\svi\\\*.chs  $(EXEDOSDEST)\\$(MODUL).EXE 



clean:
	rm -f *.obj *.OBJ
	rm -f $(OBJS) I$(MODULH).OBJ *.bak *.BAK




sfx:
	/cygdrive/p/bat/SFXMA.BAT ld
