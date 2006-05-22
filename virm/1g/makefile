VERZIJA=CDX
MODUL=VIRM

PRGS=/cl/sigma/fmk/virm/main/1g/e.prg
CS=
ASMS=

FMK_LIBS=fmk_roba.lib fmk_svi.lib fmk_pi.lib fmk_evn.lib fmk_sec.lib

SCLIB_LIBS=sc1g_arh.lib sc1g_ba.lib sc1g_cui.lib sc1g_db.lib sc1g_os.lib sc1g_ost.lib sc1g_par.lib sc1g_pr.lib sc1g_sif.lib sc1g_sql.lib sc1g_ut.lib sc2g_app.lib sc2g_db.lib sc1g_rpt.lib sc2g_cui.lib sc1g_key.lib 

MODUL_LIBS=vi_1db.lib vi_2db.lib vi_1dok.lib vi_1ma.lib vi_2ma.lib vi_1par.lib vi_1rpt.lib vi_1sif.lib vi_1raz.lib 

include $(SC_BUILD_HOME_DIR)/sclib/Makefile_clipper

PREF2=lib $(LIB_DOS_DEST)
FMKLIBCMD=$(addprefix $(PREF2), $(SCLIB_LIBS) $(FMK_LIBS) $(MODUL_LIBS) )


OBJS=$(OBJPRGS) $(OBJCS) $(OBJASMS)

all:    cleaneobj mod 

cleaneobj:
	rm -f /cl/sigma/fmk/virm/main/1g/e.obj
	
mod: $(OBJS)
	echo Prilikom kompilacije obj se napravi u tekucem direktoriju
	echo a blinker opet trazi obj fajl u orig direktoriju
	cp e.obj /cl/sigma/fmk/virm/main/1g/
	/cl/sigma/form_blinker_lnk.sh $(LINKCMD)
	/cl/sigma/form_blinker_lnk_2.sh $(FMKLIBCMD)
	$(LINKEREXE) @_bl_.lnk   @_bl_2_.lnk $(DEBUGLINK) @H:\\CLIPPER\\$(VERZIJA)\\BL.LNK output e.exe
	cp e.exe $(EXEDEST)/$(MODUL).EXE

zip:
	rm -f /p/zipsig/fmk/$(MODUL).zip
	/cl/sigma/zip.sh p:\\zipsig\\fmk\\$(MODUL).zip ..\\chs\\\*.chs \\cl\\sigma\\fmk\\svi\\\*.chs  $(EXEDOSDEST)\\$(MODUL).EXE 



clean:
	rm -f *.obj *.OBJ
	rm -f $(OBJS) I$(MODULH).OBJ *.bak *.BAK




sfx:
	/cygdrive/p/bat/SFXMA.BAT virm
