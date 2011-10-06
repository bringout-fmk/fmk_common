/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "fmk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/roba/adm_db.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.3 $
 * $Log: adm_db.prg,v $
 * Revision 1.3  2003/01/19 23:44:18  ernad
 * test network speed (sa), korekcija bl.lnk
 *
 * Revision 1.2  2002/06/16 14:16:54  ernad
 * no message
 *
 *
 */
 
function PP_Sast()
*{
  PRIVATE cAkoNema:="N"
  // cDirSif - putanja (direktorij) sifrarnika aktivne firme
  cK2KS:=PADR(TRIM(cDirSif)+"\",40)

  O_PARAMS
  private cSection:="6",cHistory:=" "; aHistory:={}
  Params1()
  RPar("ks",@cK2KS)

  Box(,4,77)
   @ m_x+2, m_y+2 SAY "Direktorij sifrarnika druge firme:" GET cK2KS PICT "@!"
   @ m_x+3, m_y+2 SAY 'Prikazivati rezultat "NEMA TOG ARTIKLA" ? (D/N):' GET cAkoNema VALID cAkoNema$"DN" PICT "@!"
   READ
  BoxC()
  IF LASTKEY()==K_ESC
    SELECT PARAMS; USE
    RETURN
  ENDIF

  Params2()
  WPar("ks",@cK2KS)
  SELECT PARAMS; USE

  IF TRIM(cK2KS)!=TRIM(cDirSif)
    cPom:=SezRad(TRIM(cK2KS))+"SAST.DBF"
    cPom2:=SezRad(TRIM(cK2KS))+"ROBA.DBF"
    IF SELECT("SAST2")!=0
      SELECT SAST2; USE
    ENDIF
    IF SELECT("ROBA2")!=0
      SELECT ROBA2; USE
    ENDIF
    IF ! ( FILE(cPom) ) .OR. ! ( FILE(cPom2) )
      Msg("Na zadanom direktoriju druge firme ne postoji baza za poredjenje !",6)
      RETURN
    ENDIF
    USE (cPom) ALIAS SAST2 NEW;    SET ORDER TO TAG "ID"
    GO TOP
    USE (cPom2) ALIAS ROBA2 NEW;    SET ORDER TO TAG "ID"
    GO TOP
  ELSE
    Msg("Zadani direktorij je isti kao i direktorij sifrarnika ove firme !",6)
    RETURN
  ENDIF

  gnLMarg:=0
  gTabela:=1
  gOstr:="D"

  SELECT SAST
  SET ORDER TO TAG "ID"
  GO TOP
  SELECT ROBA; SET ORDER TO TAG "ID"; SET FILTER TO TIP="P"
  GO TOP
  if eof(); Msg("Ne postoje trazeni podaci...",6); return; endif

  START PRINT CRET

  PRIVATE cIdSif:="", cRezultat:=""

  aKol:={ { "SIFRA(ID)"           , {|| cIdSif       }, .f., "C", 10, 0, 1, 1},;
          { "REZULTAT POREDJENJA" , {|| cRezultat    }, .f., "C", 40, 0, 1, 2},;
          { "(DRUGA FIRMA U ODNOSU NA OVU)", {|| "#" }, .f., "C", 40, 0, 2, 2} }

  ?? space(gnLMarg); ?? "KALK: Izvjestaj na dan",date()
  ? space(gnLMarg); IspisFirme("")
  ? space(gnLMarg); ?? "DIREKTORIJ SIFRARNIKA OVE FIRME  :",TRIM(cDirSif)+"\"
  ? space(gnLMarg); ?? "DIREKTORIJ SIFRARNIKA DRUGE FIRME:",TRIM(cK2KS)

  StampaTabele(aKol,{|| FSvaki2()},,gTabela,,;
       ,"UPOREDJIVANJE SASTAVNICA PROIZVODA",;
                               {|| FFor2()},IF(gOstr=="D",,-1),,,,,)

  FF
  END PRINT

RETURN
*}

function FFor2()
*{  
  
* NA ROBA.DBF SMO
cIdSif:=ROBA->id                   
cRezultat:=""

SELECT ROBA2
SEEK cIdSif
SELECT SAST
SEEK cIdSif
SELECT SAST2
SEEK cIdSif
SELECT ROBA

do case

	case  ! ( cIdSif == ROBA2->id )

		IF cAkoNema=="D"
			cRezultat := "NEMA TOG ARTIKLA"
		ENDIF

	case ROBA2->tip!="P"

		cRezultat := "ARTIKAL NIJE DEFINIRAN KAO PROIZVOD"

	case SAST->id == cIdSif .and. SAST2->id != cIdSif

		cRezultat := "NEMA SASTAVNICE"

	case SAST->id != cIdSif

		IF SAST2->id == cIdSif
			cRezultat := "RAZLIKUJE SE"
		ENDIF

	otherwise

		SELECT SAST

		DO WHILE !EOF() .and. cIdSif==id
			IF SAST->id2 != SAST2->id2 .or. SAST->kolicina != SAST2->kolicina
				cRezultat:="RAZLIKUJE SE"
				EXIT
			ENDIF
			SELECT SAST2
			SKIP 1
			SELECT SAST
			SKIP 1
		ENDDO

		* sast 2 je "duza" od sast 1
		IF EMPTY(cRezultat) .and. SAST2->id == cIdSif  
			cRezultat:="RAZLIKUJE SE"                   
		ENDIF


endcase

SELECT ROBA

RETURN !EMPTY(cRezultat)
*}


function FmkRobaVer()
*{
return DBUILD
*}

