VERZIJA=CDX
MODUL=FAKT

PRGS=/cl/sigma/fmk/fakt/main/1g/e.prg
CS=
ASMS=

include /cl/sigma/Makefile_clipper

FMK_LIBS=fmk_roba.lib fmk_svi.lib fmk_pi.lib fmk_evn.lib fmk_sec.lib fmk_mes.lib

SCLIB_LIBS=sc1g_arh.lib sc1g_ba.lib sc1g_cui.lib sc1g_db.lib sc1g_os.lib sc1g_ost.lib sc1g_par.lib sc1g_pr.lib sc1g_sif.lib sc1g_sql.lib sc1g_ut.lib sc2g_app.lib sc2g_db.lib sc1g_rpt.lib sc2g_cui.lib sc1g_key.lib ka_s1pf.lib

MODUL_LIBS=fa_1ma.lib fa_2ma.lib fa_2db.lib fa_1db.lib fa_1upl.lib fa_1ugo.lib fa_1dok.lib fa_1sif.lib fa_1rof.lib fa_1rdb.lib fa_1sql.lib fa_1ost.lib fa_1svi.lib fa_1rpt.lib fa_1smk.lib fa_1par.lib fa_1stv.lib fa_1sta.lib fa_1kon.lib fa_2dok.lib fa_1gdo.lib fa_1rud.lib

PREF2=lib $(LIB_DOS_DEST)
FMKLIBCMD=$(addprefix $(PREF2), $(SCLIB_LIBS) $(FMK_LIBS) $(MODUL_LIBS) )


OBJS=$(OBJPRGS) $(OBJCS) $(OBJASMS)

all:    cleaneobj mod 

cleaneobj:
	rm -f /cl/sigma/fmk/fakt/main/1g/e.obj
	
mod: $(OBJS)
	echo Prilikom kompilacije obj se napravi u tekucem direktoriju
	echo a blinker opet trazi obj fajl u orig direktoriju
	cp e.obj /cl/sigma/fmk/fakt/main/1g/
	/cl/sigma/form_blinker_lnk.sh $(LINKCMD)
	/cl/sigma/form_blinker_lnk_2.sh $(FMKLIBCMD)
	$(LINKEREXE) @_bl_.lnk BEGINAREA  @_bl_2_.lnk ENDAREA $(DEBUGLINK) @H:\\CLIPPER\\$(VERZIJA)\\BL.LNK output e.exe
	cp e.exe $(EXEDEST)/$(MODUL).EXE

zip:
	rm -f /z/fmk/$(MODUL).zip
	/cl/sigma/zip.sh z:\\fmk\\$(MODUL).zip ..\\chs\\\*.chs \\cl\\sigma\\fmk\\roba\\\*.chs \\cl\\sigma\\fmk\\fakt\\template\\\*.txt $(EXEDOSDEST)\\$(MODUL).EXE 


clean:
	rm -f *.obj *.OBJ
	rm -f $(OBJS) I$(MODULH).OBJ *.bak *.BAK



sfx:
	/cygdrive/p/bat/SFXMA.BAT fakt
