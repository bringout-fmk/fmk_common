#include "\cl\sigma\fmk\fin\fin.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fin/specif/jerry/1g/rpt_bil.prg,v $
 * $Author: sasa $ 
 * $Revision: 1.2 $
 * $Log: rpt_bil.prg,v $
 * Revision 1.2  2002/06/21 08:48:36  sasa
 * no message
 *
 *
 */


/*! \file fmk/fin/specif/jerry/1g/rpt_bil.prg
 *  \brief Bilans stanja, bilans uspjeha
 */

/*! \fn BilansS()
 *  \brief Bilans stanja 
 */
 
function BilansS()
*{
dDo:=DATE()
  O_KONTO
  O_SINT
  SET ORDER TO TAG "1"  // IdFirma+IdKonto+dtos(DatNal)
  cTip:=ValDomaca(); cBBV:=cTip; nBBK:=1

  Box("#BILANS STANJA",3,75)
    @ m_x+2, m_y+2 SAY "Do datuma:" GET dDo
    READ; ESC_BCR
  BoxC()

  SELECT KONTO
  cSort := "POZBILS+ID"

  cFilt := "LEN(TRIM(ID))==3 .and. !EMPTY(POZBILS)"
  // NAP:mo§da ne treba uslovljavati bilansnu poziciju 3-cifrenom sintetikom?

  INDEX ON &cSort TO "TMPSINT" FOR &cFilt
  GO TOP
  if eof(); Msg("Ne postoje trazeni podaci...",6); closeret; endif

  BBMnoziSaK()

  nDKol:=77
  aAktiva:={}
  aPasiva:={}
  nUkPoz:=nUkSve:=nUkSveD:=nUkSveP:=0
  DO WHILE !EOF()
    cPozBilS:=pozbils
    nSaldo:=0
    cIdKonto := TRIM(ID)
    cNKonto  := NAZ
    SELECT SINT
     SEEK gFirma+cIdKonto
      DO WHILE !EOF() .and. idkonto==cIdKonto .and. idfirma==gFirma .and. datnal<=dDo
        nSaldo += (dugbhd-potbhd)*nBBK
        SKIP 1
      ENDDO
    SELECT KONTO
    nUkPoz += nSaldo
    nUkSve += nSaldo
    IF LEFT(POZBILS,1)=="1"
      AADD( aAktiva , cIdKonto+" "+cNKonto+" "+TRANS(nSaldo,gpicbhd) )
      nUkSveD += nSaldo
    ELSE
      nSaldo := - nSaldo
      AADD( aPasiva , cIdKonto+" "+cNKonto+" "+TRANS(nSaldo,gpicbhd) )
      nUkSveP += nSaldo
    ENDIF
    SKIP 1
    IF EOF() .or. cPozBilS<>pozbils
      IF LEFT(cPozBilS,1)=="1"
        AADD( aAktiva , REPL("-",nDKol) )
        AADD( aAktiva , PADR("UKUPNO POZICIJA "+SUBSTR(cPozBilS,2,1),62)+;
                        TRANS(nUkPoz,gpicbhd) )
        AADD( aAktiva , REPL("-",nDKol) )
      ELSE
        AADD( aPasiva , REPL("-",nDKol) )
        nUkPoz := -nUkPoz
        AADD( aPasiva , PADR("UKUPNO POZICIJA "+SUBSTR(cPozBilS,2,1),62)+;
                        TRANS(nUkPoz,gpicbhd) )
        AADD( aPasiva , REPL("-",nDKol) )
      ENDIF
      nUkPoz:=0
    ENDIF
  ENDDO

  START PRINT CRET
   P_10CPI
   ?? gnFirma+PADL("Iznosi prikazani u valuti: "+cBBV,60)
   IF cTip<>cBBV
     ? PADL("Omjer valuta: 1 "+cTip+"= "+ALLTRIM(STR(nBBK))+" "+cBBV,80)
   ELSE
     ?
   ENDIF
   ?
   ?
   ? PADC("BILANS STANJA NA DAN "+DTOC(dDo),80)
   ?
   ?

   P_COND2

   cPom  := REPL("-",nDKol)
   cPom1 := PADC("A K T I V A",nDKol)
   cPom2 := PADC("P A S I V A",nDKol)
   ? cPom , "³", cPom
   ? cPom1, "³", cPom2
   ? cPom , "³", cPom
   FOR i:=1 TO MAX( LEN(aAktiva) , LEN(aPasiva) )
     cPom1 := IF( i>LEN(aAktiva) , SPACE(nDKol) , aAktiva[i] )
     cPom2 := IF( i>LEN(aPasiva) , SPACE(nDKol) , aPasiva[i] )
     ? cPom1, "³", cPom2
   NEXT

   cPom  := REPL("-",nDKol)
   cPom1 := PADR("UKUPNO AKTIVA",62)+TRANS(nUkSveD,gPicBHD)
   cPom2 := PADR("UKUPNO PASIVA",62)+TRANS(nUkSveP,gPicBHD)
   ? cPom , "³", cPom
   ? cPom1, "³", cPom2
   ? cPom , "³", cPom

   cPom  := REPL("=",nDKol)
   IF nUkSveD>nUkSveP
     cTxt  := IzFMKIni("BILANSI_JERRY_SALDA_OPISI","BilansStanjaDuguje","=",KUMPATH)
     cPom1 := SPACE(nDKol)
     cPom2 := PADL(cTxt,62)+TRANS(nUkSveD-nUkSveP,gPicBHD)
     cPom3 := SPACE(62)+TRANS(nUkSveD,gPicBHD)
   ELSEIF nUkSveP>nUkSveD
     cTxt  := IzFMKIni("BILANSI_JERRY_SALDA_OPISI","BilansStanjaPotrazuje","=",KUMPATH)
     cPom2 := SPACE(nDKol)
     cPom1 := PADL(cTxt,62)+TRANS(nUkSveP-nUkSveD,gPicBHD)
     cPom3 := SPACE(62)+TRANS(nUkSveP,gPicBHD)
   ELSE
     cPom1 := cPom2 := SPACE(nDKol)
     cPom3 := SPACE(62)+TRANS(nUkSveD,gPicBHD)
   ENDIF
   ? cPom , "³", cPom
   ? cPom1, "³", cPom2
   ? cPom3, "³", cPom3
   ? cPom , "³", cPom

   FF
  END PRINT
CLOSERET
return
*}



/*! \fn BilansU()
 *  \brief Bilans uspjeha
 */
 
function BilansU()
*{
dDo:=DATE()
  O_KONTO
  O_SINT
  SET ORDER TO TAG "1"  // IdFirma+IdKonto+dtos(DatNal)
  cTip:=ValDomaca(); cBBV:=cTip; nBBK:=1

  Box("#BILANS USPJEHA",3,75)
    @ m_x+2, m_y+2 SAY "Do datuma:" GET dDo
    READ; ESC_BCR
  BoxC()

  SELECT KONTO
  cSort := "POZBILU+ID"

  cFilt := "LEN(TRIM(ID))==3 .and. !EMPTY(POZBILU)"
  // NAP:mo§da ne treba uslovljavati bilansnu poziciju 3-cifrenom sintetikom?

  INDEX ON &cSort TO "TMPSINT" FOR &cFilt
  GO TOP
  if eof(); Msg("Ne postoje trazeni podaci...",6); closeret; endif

  BBMnoziSaK()

  nDKol:=77
  aRashod:={}
  aPrihod:={}
  nUkPoz:=nUkSve:=nUkSveD:=nUkSveP:=0
  DO WHILE !EOF()
    cPozBilU:=pozbilu
    nSaldo:=0
    cIdKonto := TRIM(ID)
    cNKonto  := NAZ
    SELECT SINT
     SEEK gFirma+cIdKonto
      DO WHILE !EOF() .and. idkonto==cIdKonto .and. idfirma==gFirma .and. datnal<=dDo
        nSaldo += (dugbhd-potbhd)*nBBK
        SKIP 1
      ENDDO
    SELECT KONTO
    nUkPoz += nSaldo
    nUkSve += nSaldo
    IF LEFT(POZBILU,1)=="1"
      AADD( aRashod , cIdKonto+" "+cNKonto+" "+TRANS(nSaldo,gpicbhd) )
      nUkSveD += nSaldo
    ELSE
      nSaldo := - nSaldo
      AADD( aPrihod , cIdKonto+" "+cNKonto+" "+TRANS(nSaldo,gpicbhd) )
      nUkSveP += nSaldo
    ENDIF
    SKIP 1
    IF EOF() .or. cPozBilU<>pozbilu
      IF LEFT(cPozBilU,1)=="1"
        AADD( aRashod , REPL("-",nDKol) )
        AADD( aRashod , PADR("UKUPNO POZICIJA "+SUBSTR(cPozBilU,2,1),62)+;
                        TRANS(nUkPoz,gpicbhd) )
        AADD( aRashod , REPL("-",nDKol) )
      ELSE
        AADD( aPrihod , REPL("-",nDKol) )
        nUkPoz := -nUkPoz
        AADD( aPrihod , PADR("UKUPNO POZICIJA "+SUBSTR(cPozBilU,2,1),62)+;
                        TRANS(nUkPoz,gpicbhd) )
        AADD( aPrihod , REPL("-",nDKol) )
      ENDIF
      nUkPoz:=0
    ENDIF
  ENDDO

  START PRINT CRET
   P_10CPI
   ?? gnFirma+PADL("Iznosi prikazani u valuti: "+cBBV,60)
   IF cTip<>cBBV
     ? PADL("Omjer valuta: 1 "+cTip+"= "+ALLTRIM(STR(nBBK))+" "+cBBV,80)
   ELSE
     ?
   ENDIF
   ?
   ?
   ? PADC("BILANS USPJEHA NA DAN "+DTOC(dDo),80)
   ?
   ?

   P_COND2

   cPom  := REPL("-",nDKol)
   cPom1 := PADC("R A S H O D",nDKol)
   cPom2 := PADC("P R I H O D",nDKol)
   ? cPom , "³", cPom
   ? cPom1, "³", cPom2
   ? cPom , "³", cPom
   FOR i:=1 TO MAX( LEN(aRashod) , LEN(aPrihod) )
     cPom1 := IF( i>LEN(aRashod) , SPACE(nDKol) , aRashod[i] )
     cPom2 := IF( i>LEN(aPrihod) , SPACE(nDKol) , aPrihod[i] )
     ? cPom1, "³", cPom2
   NEXT

   cPom  := REPL("-",nDKol)
   cPom1 := PADR("UKUPNO RASHOD",62)+TRANS(nUkSveD,gPicBHD)
   cPom2 := PADR("UKUPNO PRIHOD",62)+TRANS(nUkSveP,gPicBHD)
   ? cPom , "³", cPom
   ? cPom1, "³", cPom2
   ? cPom , "³", cPom

   cPom  := REPL("=",nDKol)
   IF nUkSveD>nUkSveP
     cTxt  := IzFMKIni("BILANSI_JERRY_SALDA_OPISI","BilansUspjehaDuguje","=",KUMPATH)
     cPom1 := SPACE(nDKol)
     cPom2 := PADL(cTxt,62)+TRANS(nUkSveD-nUkSveP,gPicBHD)
     cPom3 := SPACE(62)+TRANS(nUkSveD,gPicBHD)
   ELSEIF nUkSveP>nUkSveD
     cTxt  := IzFMKIni("BILANSI_JERRY_SALDA_OPISI","BilansUspjehaPotrazuje","=",KUMPATH)
     cPom2 := SPACE(nDKol)
     cPom1 := PADL(cTxt,62)+TRANS(nUkSveP-nUkSveD,gPicBHD)
     cPom3 := SPACE(62)+TRANS(nUkSveP,gPicBHD)
   ELSE
     cPom1 := cPom2 := SPACE(nDKol)
     cPom3 := SPACE(62)+TRANS(nUkSveD,gPicBHD)
   ENDIF
   ? cPom , "³", cPom
   ? cPom1, "³", cPom2
   ? cPom3, "³", cPom3
   ? cPom , "³", cPom

   FF
  END PRINT
CLOSERET
return
*}



