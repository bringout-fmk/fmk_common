#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/specif/vindija/1g/distrib.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.4 $
 * $Log: distrib.prg,v $
 * Revision 1.4  2002/09/13 09:11:53  mirsad
 * dokumentovanje INI parametara
 *
 * Revision 1.3  2002/07/04 08:34:19  mirsad
 * dokumentovanje ini parametara
 *
 * Revision 1.2  2002/06/19 09:12:07  sasa
 * no message
 *
 * Revision 1.1.1.1  2002/06/17 18:30:18  ernad
 * no message
 *
 *
 */
 

/*! \file fmk/fakt/specif/vindija/1g/distrib.prg
 *  \brief Izvjestaji vezani za vindiju
 */


/*! \ingroup ini
  * \var *string FmkIni_ExePath_Fakt_Ugovori_UNapomenuSamoBrUgovora
  * \brief Da li ce se pri generisanju faktura na osnovu ugovora u napomenu dodati iza teksta "VEZA:" samo broj ugovora 
  * \param D - da, default vrijednost
  * \param N - ne, ispisace se i tekst "UGOVOR:", te datum ugovora
  */
*string FmkIni_ExePath_Fakt_Ugovori_UNapomenuSamoBrUgovora;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_DodatniTXTZaSlucajObracunatogPoreza
  * \brief Tekst koji se dodaje u napomenu ukoliko kupac nije oslobodjen placanja poreza na promet proizvoda
  * \param Porez na promet proizvoda je obracunat na osnovu izjave kupca. - default vrijednost
  * \param
  */
*string FmkIni_KumPath_FAKT_DodatniTXTZaSlucajObracunatogPoreza;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_DodatniTXTZaSlucajOslobadjanjaOdPoreza
  * \brief Tekst koji se dodaje u napomenu ukoliko je kupac oslobodjen placanja poreza na promet proizvoda
  * \param Na osnovu izjave kupca porez na promet proizvoda nije obracunat. - default vrijednost
  */
*string FmkIni_KumPath_FAKT_DodatniTXTZaSlucajOslobadjanjaOdPoreza;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_Doks2
  * \brief Da li se koristi baza DOKS2 za dodatne podatke o dokumentu?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_KumPath_FAKT_Doks2;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_KupacDesno
  * \brief Da li se kupac na dokumentima ispisuje uz desnu marginu?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_KumPath_FAKT_KupacDesno;



/*! \fn Gen10iz26()
 *  \brief Generisanje faktura vp na osnovu ugovora i auriranih narudzbenica
 */
 
function Gen10iz26()
*{
PRIVATE lOpor:=.f.

O_PRIPR
IF RECCOUNT2()<>0
  MsgBeep("Priprema mora biti prazna!")
  CLOSERET
ENDIF

dDatOd:=dDatDo:=DATE()

O_PARAMS
private cSection:="D",cHistory:=" "; aHistory:={}
Params1()
RPar("d1",@dDatOd) ; RPar("d2",@dDatDo)

Box("#GENERISANJE FAKTURA VP NA OSNOVU UGOVORA I NARUDZBI",3,70)
  @ m_x+2, m_y+2 SAY "Obuhvatiti narudzbenice za period od" GET dDatOd
  @ m_x+2, col()+2 SAY "do" GET dDatDo VALID dDatOd<=dDatDo
  READ; ESC_BCR
BoxC()

select params
WPar("d1",dDatOd); WPar("d2",dDatDo)
use

O_TARIFA
O_UGOV
SET ORDER TO TAG "PARTNER"
O_RUGOV
SET ORDER TO TAG "ID"
O_ROBA
O_FTXT

O_FAKT
SEEK gFirma+"10"+"È"
SKIP -1
IF idfirma+idtipdok<>gFirma+"10"
  cNext:=UBrojDok(1,gNumDio,"")
ELSE
  cNext:=UBrojDok( val(left(brdok,gNumDio))+1, ;
                   gNumDio, ;
                   right(brdok,len(brdok)-gNumDio) ;
                 )
ENDIF

IF UPPER(RIGHT(TRIM(cNext),1))=="S"
  cNext:=padr(left(cNext,gNumDio),8)
ELSE
  cNext:=padr(cNext,8)
ENDIF

SET ORDER TO TAG "4"
// idfirma+idtipdok+dtos(datdok)+idrelac+marsruta+brdok+rbr
SEEK gFirma+"26"+dtos(dDatOd)

DO WHILE !EOF() .and. idfirma+idtipdok==gFirma+"26" .and. datdok <= dDatDo
  cBrDok := brdok
  SELECT UGOV; HSEEK FAKT->idpartner
  SELECT FAKT
  lOpor := (k2=="OPOR")
  DO WHILE !EOF() .and. idfirma+idtipdok==gFirma+"26" .and. datdok <= dDatDo;
           .and. brdok==cBrDok
    Scatter()
     SELECT RUGOV; SEEK UGOV->id
     DO WHILE !EOF() .and. id==UGOV->id
       IF _idroba==idroba
         _rabat := rabat
         EXIT
       ENDIF
       cPom:=TRIM(idroba)
       IF RIGHT(cPom,1)==";" .and. _idroba=LEFT(cPom,LEN(cPom)-1)
         _rabat := rabat
       ENDIF
       SKIP 1
     ENDDO
     SELECT ROBA; HSEEK _idroba
     IF lOpor
       SELECT TARIFA; HSEEK ROBA->idtarifa
       _porez := TARIFA->opp
     ENDIF
     SELECT PRIPR
      APPEND BLANK
       _idtipdok := "10"
       _brdok    := cNext
       if cTipVPC=="1"
          _Cijena := ROBA->vpc
       elseif ROBA->(fieldpos("vpc2"))<>0
        if gVarC=="1"
          _Cijena := ROBA->vpc2
        elseif gVarc=="2"
          _Cijena := ROBA->vpc
        elseif gVarc=="3"
          _Cijena := ROBA->nc
        endif
       else
         _Cijena:=0
       endif
       IsprUzorTxt(.t.,{|| Setuj_Txt()})
       SELECT PRIPR
       Gather()
    SELECT FAKT
    SKIP 1
  ENDDO
  cNext:=UBrojDok( val(left(cNext,gNumDio))+1, ;
                    gNumDio, ;
                    right(cNext,len(cNext)-gNumDio) ;
                 )
ENDDO

CLOSERET
return
*}


/*! \fn Setuj_Txt()
 *  \brief
 */
 
function Setuj_Txt()
*{
LOCAL cPor:=""
  select ftxt; hseek ugov->iddodtxt; cDodTxt:=TRIM(naz)
  hseek ugov->idtxt
  IF IzFMKINI("Fakt_Ugovori","UNapomenuSamoBrUgovora","D")=="D"
    cVezaUgovor := "Veza: "+trim(ugov->id)
  ELSE
    cVezaUgovor := "Veza: UGOVOR: "+trim(ugov->id)+" od "+dtoc(ugov->datod)
  ENDIF
  IF lOpor
    cPor:=IzFmkIni("FAKT","DodatniTXTZaSlucajObracunatogPoreza","Porez na promet proizvoda je obracunat na osnovu izjave kupca.",KUMPATH)
  ELSE
    cPor:=IzFmkIni("FAKT","DodatniTXTZaSlucajOslobadjanjaOdPoreza","Na osnovu izjave kupca porez na promet proizvoda nije obracunat.",KUMPATH)
  ENDIF
  _txt2 := trim(cPor) + chr(13)+chr(10) + ;
           trim(ftxt->naz) + chr(13)+chr(10) + ;
           IF(gNovine=="D","",cVezaUgovor+chr(13)+chr(10)) + cDodTxt
  _datpl := _datdok + UGOV->rokpl
RETURN
*}


/*! \fn TeretniList(lGen)
 *  \brief Teretni list
 *  \param lGen
 */
 
function TeretniList(lGen)
*{
IF lGen=NIL; lGen:=.f.; ENDIF

 IF lGen
   lDoks2 := ( IzFMKINI("FAKT","Doks2","N",KUMPATH)=="D" )
   O_PRIPR
   IF RECCOUNT2()<>0
     MsgBeep("Priprema mora biti prazna!")
     CLOSERET
   ENDIF
 ENDIF

 dDatOd:=dDatDo:=DATE(); cIdRelac:=SPACE(4); cIdDist:=SPACE(6); cTipDok:="10"
 cVarI:="S"; cIdVozila:=SPACE(4)

 O_SIFV
 O_SIFK
 O_RJ
 O_VOZILA
 O_RELAC
 O_PARTN

 O_PARAMS
 private cSection:="E",cHistory:=" "; aHistory:={}
 Params1()
 RPar("d1",@dDatOd)   ; RPar("d2",@dDatDo)
 RPar("c1",@cIdRelac) ; RPar("c2",@cIdDist)
 RPar("c3",@cTipDok)  ; RPar("c4",@cVarI)
 RPar("c5",@cIdVozila)

 Box("#USLOVI ZA "+IF(lGen,"GENERACIJU DOKUMENTA","IZVJESTAJ")+" 'TERETNI LIST'",8,75)
   @ m_x+2, m_y+2 SAY "Obuhvatiti dokumente za period od" GET dDatOd
   @ m_x+2, col()+2 SAY "do" GET dDatDo VALID dDatOd<=dDatDo
   @ m_x+3, m_y+2 SAY "Relacija (prazno-sve)   " GET cIdRelac VALID EMPTY(cIdRelac).or.P_Relac(@cIdRelac)
   @ m_x+4, m_y+2 SAY "Distributer (prazno-svi)" GET cIdDist VALID EMPTY(cIdDist).or.P_Firma(@cIdDist)
   @ m_x+5, m_y+2 SAY "Vozilo (prazno-sva)     " GET cIdVozila VALID EMPTY(cIdVozila).or.P_Vozila(@cIdVozila)
   IF lGen
     cTipDok := "26"
     cVarI   := "S"
   ELSE
     cTipDok := "10"
     @ m_x+6, m_y+2 SAY "Tip dokumenta (10/26)   " GET cTipDok VALID cTipDok$"26#10" PICT "99"
     @ m_x+7, m_y+2 SAY "Z-zaduzenja/P-povrati/S-sve" GET cVarI VALID cVarI$"ZPS" PICT "@!"
   ENDIF
   READ; ESC_BCR
 BoxC()

 select params
 WPar("d1",dDatOd)   ; WPar("d2",dDatDo)
 WPar("c1",cIdRelac) ; WPar("c2",cIdDist)
 WPar("c3",cTipDok)  ; WPar("c4",cVarI)
 WPar("c5",cIdVozila)
 use

 O_ROBA
 O_VOZILA
 O_FAKT

 SEEK gFirma+"21"+"È"
 SKIP -1
 IF idfirma+idtipdok<>gFirma+"21"
   cNext:=UBrojDok(1,gNumDio,"")
 ELSE
   cNext:=UBrojDok( val(left(brdok,gNumDio))+1, ;
                    gNumDio, ;
                    right(brdok,len(brdok)-gNumDio) ;
                  )
 ENDIF

 // SET ORDER TO TAG "3"
 SET ORDER TO TAG "5"
 // idfirma+idtipdok+dtos(datdok)+idrelac+iddist+idvozila+idroba

 SEEK gFirma+cTipDok+dtos(dDatOd)
 IF gFirma<>idfirma .or. cTipDok<>idtipdok .or. datdok>dDatDo
   MsgBeep("Ne postoje dokumenti koji zadovoljavaju postavljene uslove!")
   CLOSERET
 ENDIF

   START PRINT CRET

   gnLMarg:=0; gOstr:="N"; gTabela:=1
   aKol:={}; nKol:=0
   nRbr:=0; cIdRoba:=""; cNazRoba:=""; cJMJ:=""; nUkupno:=0; cAmbalaza:=""
   AADD(aKol, { "R.br."   , {|| STR(nRBr,4)+"."  }, .f., "C",  5, 0, 1, ++nKol } )
   AADD(aKol, { "Sifra"   , {|| cIdRoba          }, .f., "C", 10, 0, 1, ++nKol } )
   AADD(aKol, { "Naziv"   , {|| cNazRoba         }, .f., "C", 50, 0, 1, ++nKol } )
   AADD(aKol, { "JMJ"     , {|| cJMJ             }, .f., "C",  3, 0, 1, ++nKol } )
   AADD(aKol, { "Kolicina", {|| nUkupno          }, .f., "N", 12, 3, 1, ++nKol } )
   AADD(aKol, { "Ambalaza", {|| cAmbalaza        }, .f., "C",  8, 0, 1, ++nKol } )

   SELECT FAKT
   DO WHILE !EOF() .and. idfirma==gFirma .and. idtipdok==cTipDok .and. datdok<=dDatDo

     IF !EMPTY(cIdRelac) .and. idrelac<>cIdRelac .or.;
        !EMPTY(cIdDist) .and. iddist<>cIdDist .or.;
        !EMPTY(cIdVozila) .and. idvozila<>cIdVozila
       SKIP 1; LOOP
     ENDIF

     qIdRelac  := idrelac
     qiddist   := iddist
     qidvozila := idvozila
     qdatdok   := datdok

     P_10CPI
     ? "FAKT,",date(),", TERETNI LIST ROBE"
     ? ; IspisFirme(gFirma)
     ?
     ? "Za dan", qdatdok
     IF cVarI<>"S"
       ? "Obuhvaceni su samo dokumenti "+IF(cVarI=="P","povrata","zaduzenja")+"!"
     ENDIF

     P_12CPI
     ?  "Relacija:", TRIM(qIdRelac)
     ?? "   Distributer:", TRIM(qIdDist)+" "+TRIM(Ocitaj(F_PARTN,qiddist,"naz"))
     ?? "   Vozilo:", TRIM(qIdVozila)+" "+Ocitaj(F_VOZILA,qidvozila,"TRIM(naz)+' '+TRIM(tablice)")
     ?
     bWhile := {|| idfirma==gFirma .and. idtipdok==cTipDok .and.;
                   datdok   == qdatdok   .and.;
                   IdRelac  == qidrelac  .and.;
                   iddist   == qiddist   .and.;
                   idvozila == qidvozila ;
                }
     nRBr := nUkupno := 0
     StampaTabele(aKol,,,gTabela,bWhile,;
                  ,,;
                  {|| FTerList(lGen)},IF(gOstr=="D",,-1),,,,,,.f.)
     ?
     ? "           ODOBRIO                         IZDAO                            PRIMIO"
     FF

     cNext:=UBrojDok( val(left(cNext,gNumDio))+1, ;
                       gNumDio, ;
                       right(cNext,len(cNext)-gNumDio) ;
                    )

   ENDDO
   END PRINT

CLOSERET
return
*}


/*! \fn FTerList(lGen)
 *  \brief
 */
 
function FTerList(lGen)
*{
LOCAL nArr:=SELECT(), nPak:=0, nKom:=0
  ++nRBr; cIdRoba:=IDROBA
  SELECT ROBA; HSEEK cIdRoba
  cNazRoba := naz
  cJMJ     := jmj
  SELECT (nArr)
  nUkupno:=0
  DO WHILE !EOF() .and. EVAL(bWhile) .and. IDROBA == cIdRoba
    nUkupno += kolicina
    nPak += ambp
    nKom += ambk
    SKIP 1
  ENDDO
  SKIP -1
  // Prepak(cIdRoba,cjmj,@nPak,@nKom,nUkupno)
  cAmbalaza := STR(nPak,2)+"P+"+STR(nKom,2)+"K"
  IF lGen
    Scatter()
    SELECT PRIPR
     APPEND BLANK
      _IdTipDok  := "21"
      _BrDok     := cNext
      _rbr       := STR(nRBr,3)
      _kolicina  := nUkupno
      _idpartner := qIdDist
      _idpm      := ""
      _IDDIST    := qIdDist
      _IDRELAC   := qIdRelac
      _IDVOZILA  := qIdVozila
      _MARSRUTA  := ""
      _ambp      := nPak
      _ambk      := nKom

      IF nRBr==1
        _txt3a   := qIdDist+"."
        _txt3b   := ""
        _txt3c   := ""
        IzSifre(.T.)  // da nafiluje _txt3a, _txt3b i _txt3c - NAZIV KUPCA
        _txt := FormirajTxt(cNazRoba,,_txt3a,_txt3b,_txt3c)
      ELSE
        _txt := ""
      ENDIF
      Gather()
    SELECT (nArr)
  ENDIF
RETURN .t.
*}


/*! \fn FormirajTxt(_txt1,_txt2,_txt3a,_txt3b,_txt3c,_BrOtp,_DatOtp,_BrNar,_DatPl,_VezOtpr,d2k1,d2k2,d2k3,d2k4,d2k5,d2n1,d2n2)
 *  \brief Formira tekstualni fajl
 *  \param _txt1
 *  \param _txt2
 *  \param _txt3a
 *  \param _txt3b
 *  \param _txt3c
 *  \param _BrOtp
 *  \param _DatOtp
 *  \param _BrNar
 *  \param _DatPl
 *  \param _VezOtpr
 *  \param d2k1
 *  \param d2k2
 *  \param d2k3
 *  \param d2k4
 *  \param d2k5
 *  \param d2n1
 *  \param d2n2
 */
 
function FormirajTxt(_txt1,_txt2,_txt3a,_txt3b,_txt3c,_BrOtp,_DatOtp,_BrNar,_DatPl,_VezOtpr,d2k1,d2k2,d2k3,d2k4,d2k5,d2n1,d2n2)
*{
  IF _txt1    == NIL; _txt1    :=""; ENDIF       // naziv robe
  IF _txt2    == NIL; _txt2    :=""; ENDIF       // tekst napomene
  IF _txt3a   == NIL; _txt3a   :=""; ENDIF       // kupac 1.red
  IF _txt3b   == NIL; _txt3b   :=""; ENDIF       // kupac 2.red
  IF _txt3c   == NIL; _txt3c   :=""; ENDIF       // kupac 3.red
  IF _BrOtp   == NIL; _BrOtp   :=""; ENDIF       //
  IF _DatOtp  == NIL; _DatOtp  :=CTOD(""); ENDIF //
  IF _BrNar   == NIL; _BrNar   :=""; ENDIF       //
  IF _DatPl   == NIL; _DatPl   :=CTOD(""); ENDIF //
  IF _VezOtpr == NIL; _VezOtpr :=""; ENDIF       //
  IF d2k1     == NIL; d2k1     :=""; ENDIF       //
  IF d2k2     == NIL; d2k2     :=""; ENDIF       //
  IF d2k3     == NIL; d2k3     :=""; ENDIF       //
  IF d2k4     == NIL; d2k4     :=""; ENDIF       //
  IF d2k5     == NIL; d2k5     :=""; ENDIF       //
  IF d2n1     == NIL; d2n1     :=""; ENDIF       //
  IF d2n2     == NIL; d2n2     :=""; ENDIF       //
RETURN ( Chr(16)+trim(_txt1)  +Chr(17) + Chr(16)+_txt2 +Chr(17)+;
         Chr(16)+trim(_txt3a) +Chr(17) + Chr(16)+_txt3b+Chr(17)+;
         Chr(16)+trim(_txt3c) +Chr(17) + Chr(16)+_BrOtp+Chr(17)+;
         Chr(16)+dtoc(_DatOtp)+Chr(17) + Chr(16)+_BrNar+Chr(17)+;
         Chr(16)+dtoc(_DatPl) +Chr(17) +;
         IF(Empty(_VezOtpr), Chr(16)+""+Chr(17), Chr(16)+_VezOtpr+Chr(17))+;
  IF(lDoks2, Chr(16)+d2k1+Chr(17) ,"")+IF(lDoks2, Chr(16)+d2k2+Chr(17) ,"")+;
  IF(lDoks2, Chr(16)+d2k3+Chr(17) ,"")+IF(lDoks2, Chr(16)+d2k4+Chr(17) ,"")+;
  IF(lDoks2, Chr(16)+d2k5+Chr(17) ,"")+IF(lDoks2, Chr(16)+d2n1+Chr(17) ,"")+;
  IF(lDoks2, Chr(16)+d2n2+Chr(17) ,"") )

*}



/*! \fn MenuSistOtp()
 *  \brief Sistemske otpremnice -> konacne otpremnice
 */
 
function MenuSistOtp()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. priprema sistemskih otpremnica         ")
AADD(opcexe,{|| PriprSO()})
AADD(opc,"2. stampanje sistemskih otpremnica")
AADD(opcexe,{|| StampaSO()})
AADD(opc,"3. generacija konacnih otpremnica (12-ki)")
AADD(opcexe,{|| GenKonOtp()})

Menu_SC("sotp")
return .f.
*}



/*! \fn PriprSO()
 *  \brief Priprema sistemskih otpremnica
 */
 
function PriprSO()
*{
LOCAL i:=0
 PRIVATE ddatdok:=DATE(), cIdPartner:=SPACE(6), cIdPM:=SPACE(15)

 O_KALPOS
 O_RELAC
 O_PARTN
 O_PRIPR
 O_FAKT
 O_TARIFA
 O_SIFK; O_SIFV
 O_ROBA

 IF !FILE(PRIVPATH+"POMGS.DBF")
   // napravimo pomocnu bazu
   aDbf := {}
   AADD (aDbf, {"IDROBA"    , "C", 10, 0})
   AADD (aDbf, {"DATDOK"    , "D",  8, 0})
   AADD (aDbf, {"IDPARTNER" , "C",  6, 0})
   AADD (aDbf, {"NAZIV"     , "C", 30, 0})
   AADD (aDbf, {"KOLICINA"  , "N", 12, 3})
   AADD (aDbf, {"IDPM"      , "C", 15, 0})
   AADD (aDbf, {"IDDIST"    , "C",  6, 0})
   AADD (aDbf, {"IDRELAC"   , "C",  4, 0})
   AADD (aDbf, {"IDVOZILA"  , "C",  4, 0})
   AADD (aDbf, {"MARSRUTA"  , "C", 10, 0})

   DBCREATE2 (PRIVPATH+"POMGS", aDbf)
   USEX (PRIVPATH+"POMGS") NEW
   INDEX ON BRISANO TAG "BRISAN"
   INDEX ON DTOS(DATDOK)+IDRELAC+MARSRUTA        TAG "1"
   INDEX ON DTOS(DATDOK)+IDPARTNER+IDPM          TAG "2"
   INDEX ON DTOS(DATDOK)+IDRELAC+MARSRUTA+IDROBA TAG "3"
   USE
 ENDIF
 IF !FILE(PRIVPATH+"POMGS.CDX")
   USEX (PRIVPATH+"POMGS") NEW
   INDEX ON BRISANO TAG "BRISAN"
   INDEX ON DTOS(DATDOK)+IDRELAC+MARSRUTA        TAG "1"
   INDEX ON DTOS(DATDOK)+IDPARTNER+IDPM          TAG "2"
   INDEX ON DTOS(DATDOK)+IDRELAC+MARSRUTA+IDROBA TAG "3"
   USE
 ENDIF
 USEX (PRIVPATH+"POMGS") NEW

 // getuj datum optreme i partnera
 // ------------------------------
 cIdPartner := SPACE(6)
 cIdPM      := SPACE(15)

 _idpartner := cIdPartner
 _datdok    := dDatDok
 _idpm      := cIdPM

 Box("#PRIPREMA SISTEMSKIH OTPREMNICA",6,70)
  @ m_x+2, m_y+2 SAY "Datum otpreme     :" GET _DatDok
  @ m_x+3, m_y+2 SAY "Partner           :" GET _IdPartner VALID {|| P_Firma(@_idpartner)} PICT "@!"
  @ m_x+4, m_y+2 SAY "Prod.mjesto       :" GET _IdPM VALID {|| P_IDPM(@_idpm,_idpartner)}
  READ; ESC_BCR

  dDatDok    := _datdok
  cIdPartner := _idpartner
  cIdPM      := _idpm

  SELECT POMGS

  SET ORDER TO TAG "2"

  SEEK DTOS(dDatDok)
  // ako nema nista, ponudi automatsku generaciju
  IF EOF() .or. DTOS(DATDOK)<>DTOS(dDatDok)

    IF Pitanje(,"Zelite li da se sistemske otpremnice izgenerisu? (D/N)","D")=="D"
      SELECT FAKT
      SET ORDER TO TAG "4"
      SEEK gFirma+"26"+DTOS(dDatDok)
      DO WHILE !EOF() .and.;
	       idfirma+idtipdok+DTOS(datdok)==gFirma+"26"+DTOS(dDatDok)
	Scatter()
	SELECT POMGS
	APPEND BLANK
	 _naziv     := Ocitaj(F_ROBA,_idroba,"naz")
	Gather()
	SELECT FAKT; SKIP 1
      ENDDO
    ENDIF
  ENDIF

  SEEK DTOS(dDatDok)+cIdPartner+cIdPM
  IF EOF() .or. DTOS(DATDOK)+idpartner+idpm <> DTOS(dDatDok)+cIdPartner+cIdPM
    MsgBeep("Ne postoji pripremljena sistemska otpremnica za navedenog kupca i datum!")
    // ? idvozila,idrelac,iddist,marsruta ?
    // konsultovati kalendar posjeta?
    cIdDist   := SPACE(LEN(IDDIST))
    cIdRelac  := SPACE(LEN(IDRELAC))
    cIdVozila := SPACE(LEN(IDVOZILA))
    cMarsruta := SPACE(LEN(MARSRUTA))
    Box("#NEOPHODNO JE DA IZABERETE RELACIJU",3,75)
     @  m_x+2,m_y+2  SAY "Relacija   :" get cidrelac  picture "@!" valid {|| IzborRelacije(@cIdRelac,@cIdDist,@cIdVozila,ddatdok,@cmarsruta)}
     READ
    BoxC()
    ESC_BCR
  ELSE
    cIdDist   := IDDIST
    cIdRelac  := IDRELAC
    cIdVozila := IDVOZILA
    cMarsruta := MARSRUTA
  ENDIF

 BoxC()

 // browse - priprema otpremnice za izabrani dan i partnera
 // -------------------------------------------------------

   ImeKol:={ { "SIF.ROBE" ,      {|| idroba     }  } ,;
	     { "NAZIV ROBE" ,    {|| NAZIV      }  } ,;
	     { "Kol.za otpremu", {|| KOLICINA   }, "KOLICINA", {|| .t.}, {|| wkolicina>=0}, "V"  } }

   Kol:={}; for i:=1 to LEN(ImeKol); AADD(Kol,i); next

   Box(,20,77)
    SELECT PARTN; HSEEK cIdPartner
    DO WHILE .t.
      // GO TOP
      SELECT POMGS
      HSEEK DTOS(dDatDok)+cIdPartner+cIdPM
      @ m_x+18,m_y+2 SAY "Datum: "+DTOC(ddatdok)
      @ m_x+18,m_y+18 SAY " Partner: "+cIDPartner+"-"+PADR(PARTN->naz,22)+", Pr.mj."+cIdPM COLOR INVERT
      @ m_x+19,m_y+2 SAY "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
      @ m_x+20,m_y+2 SAY " <c-N>  Nove Stavke      ³ <ENT> Ispravi stavku   ³ <c-T> Brisi Stavku      "

      adImeKol:={}
      private  gTBDir:="D"
      private  bGoreRed:=NIL
      private  bDoleRed:=NIL
      private  bDodajRed:=NIL
      private  fTBNoviRed:=.f. // trenutno smo u novom redu ?
      private  TBCanClose:=.t. // da li se moze zavrsiti unos podataka ?
      private  TBAppend:="N"  // mogu dodavati slogove
      private  bZaglavlje:=NIL
      private  TBSkipBlock:={|nSkip| SkipDB(nSkip, @nTBLine)}
      private  nTBLine:=1      // tekuca linija-kod viselinijskog browsa
      private  nTBLastLine:=1  // broj linija kod viselinijskog browsa
      private  TBPomjerise:="" // ako je ">2" pomjeri se lijevo dva
                              // ovo se mo§e setovati u when/valid fjama
      private  TBScatter:="N"  // uzmi samo teku†e polje
      for i:=1 TO LEN(ImeKol); AADD(adImeKol,ImeKol[i]); next
      adKol:={}; for i:=1 to len(adImeKol); AADD(adKol,i); next

      // napraviti pomocnu bazu: PPOMGS
      // ------------------------------
      SELECT POMGS

      // ExportBaze(PRIVPATH+"PPOMGS")
      cBaza:=PRIVPATH+"PPOMGS"
      FERASE(cBaza+".DBF")
      FERASE(cBaza+".CDX")
      cBaza+=".DBF"
      COPY STRUCTURE EXTENDED TO (PRIVPATH+"struct")
      CREATE (cBaza) FROM (PRIVPATH+"struct") NEW
      MsgO("Ubacujem slogove u pripremu...")
      // APPEND FROM (ALIAS(nArr))
      SELECT POMGS
      DO WHILE !EOF() .and.;
	       DTOS(DATDOK)+idpartner+idpm==DTOS(dDatDok)+cIdPartner+cIdPM
        Scatter()
        SELECT PPOMGS
        APPEND BLANK
        Gather()
        SELECT POMGS; SKIP 1
      ENDDO
      MsgC()
      SELECT PPOMGS
      USE
      SELECT POMGS

      USEX (PRIVPATH+"PPOMGS") NEW
       INDEX ON BRISANO TAG "BRISAN"
        USE
      USEX (PRIVPATH+"PPOMGS") NEW
       SET ORDER TO TAG "BRISAN"
        GO TOP

      KEYBOARD CHR(K_ALT_E)

      ObjDbedit("PSiO",20,77,{|| EdSiO()},"","Priprema sistemske otpremnice:", , , , ,3)

      // azurirati POMGS iz pomocne baze PPOMGS
      // --------------------------------------
      SELECT POMGS
      MsgO("Brisem stare slogove...")

      HSEEK DTOS(dDatDok)+cIdPartner+cIdPM
      DO WHILE !EOF() .and.;
	       DTOS(DATDOK)+idpartner+idpm==DTOS(dDatDok)+cIdPartner+cIdPM
        SKIP 1; nRec:=RECNO(); SKIP -1
        DELETE
        GO (nRec)
      ENDDO

      MsgC()

      APPEND FROM PPOMGS

      SELECT POMGS
      EXIT
    ENDDO
   BoxC()
CLOSERET
return
*}


/*! \fn GenKonOtp()
 *  \brief Generisanje konacnih otpremnica
 */
 
function GenKonOtp()
*{
 dDatDok := DATE()
 qqPartn := ""
 qqRelac := ""

 O_PARAMS
 private cSection:="F",cHistory:=" "; aHistory:={}
 Params1()
 RPar("c1",@qqRelac)
 RPar("c2",@qqPartn)
 RPar("c3",@dDatDok)
 qqPartn := PADR(qqPartn,180)
 qqRelac := PADR(qqRelac,30)

 Box("#USLOVI ZA GENERISANJE KONACNIH OTPREMNICA",6,70)
  DO WHILE .t.
   @ m_x+2, m_y+2 SAY "Datum otpreme        :" GET dDatDok
   @ m_x+3, m_y+2 SAY "Partner (prazno-svi) :" GET qqPartn PICT "@S30"
   @ m_x+4, m_y+2 SAY "Relacija (prazno-sve):" GET qqRelac
   READ; ESC_BCR
   aUsl1 := Parsiraj( qqPartn , "IDPARTNER" )
   aUsl2 := Parsiraj( qqRelac , "IDRELAC" )
   IF aUsl1<>NIL .and. aUsl2<>NIL; EXIT; ENDIF
  ENDDO
 BoxC()

 select params
 qqPartn := TRIM(qqPartn)
 qqRelac := TRIM(qqRelac)
 WPar("c1",qqRelac)
 WPar("c2",qqPartn)
 WPar("c3",dDatDok)
 use

 O_ROBA
 O_TARIFA
 O_PARTN
 O_PRIPR
 IF RECCOUNT2()<>0
   MsgBeep("Priprema mora biti prazna!")
   CLOSERET
 ENDIF
 O_FAKT
 USEX (PRIVPATH+"POMGS") NEW
 SET ORDER TO TAG "3"
 // DTOS(DATDOK)+IDRELAC+MARSRUTA+IDROBA

 cFilter := "kolicina>0 .and. DATDOK==dDatDok .and. " + aUsl1
 IF !EMPTY(qqRelac)
   cFilter += ( " .and. " + aUsl2 )
 ENDIF

 SET FILTER TO &cFilter
 GO TOP

 // napravimo otpremnice (10-12-XXXXX)
 lPrviPut:=.t.
 DO WHILE !EOF()
   if lPrviPut
     lPrviPut:=.f.
     SELECT FAKT
     SEEK gFirma+"12"+"È"
     SKIP -1
     IF idfirma+idtipdok<>gFirma+"12"
        SEEK gFirma+"22"+"È"
        SKIP -1
        IF idfirma+idtipdok<>gFirma+"22"
          cBrDok:=UBrojDok(1,gNumDio,"")
        ELSE
          cBrDok:=UBrojDok( val(left(brdok,gNumDio))+1, ;
                            gNumDio, ;
                            right(brdok,len(brdok)-gNumDio) ;
                          )
        ENDIF
     ELSE
        cBrDok:=UBrojDok( val(left(brdok,gNumDio))+1, ;
                          gNumDio, ;
                          right(brdok,len(brdok)-gNumDio) ;
                        )
     ENDIF
     SELECT POMGS
   else
     cBrDok:=UBrojDok( val(left(cbrdok,gNumDio))+1, ;
                       gNumDio, ;
                       right(cbrdok,len(cbrdok)-gNumDio) ;
                     )
   endif

   cIdPartner:=IDPARTNER
   cIdRelac:=IDRELAC
   cMarsruta:=MARSRUTA
   nRbr:=0
   SELECT POMGS

   DO WHILE !EOF() .and. IDRELAC+MARSRUTA==cIdRelac+cMarsruta

     SELECT PRIPR; APPEND BLANK; Scatter()
     POMGS->(Scatter())

     IF nRbr==0
       select PARTN; hseek cIdPartner
       _txt3b:=_txt3c:=""
       _txt3a:=cIdPartner+"."
       IzSifre()
       private _Txt1:=" "
       _txt:=Chr(16)+_txt1 +Chr(17)+;
            Chr(16)+""+chr(13)+chr(10)+;
            ""+;
            ""+Chr(17)+Chr(16)+_Txt3a+ Chr(17)+ Chr(16)+_Txt3b+Chr(17)+;
            Chr(16)+_Txt3c+Chr(17)
     ENDIF

     private _Txt1:=""
     NSRNPIdRoba(POMGS->idroba)

     if nRbr<>0 .and. roba->tip=="U"
        _txt1:=roba->naz
        _txt:=Chr(16)+_txt1 +Chr(17)
     endif

     _idfirma   := gFirma
     _zaokr     := 2
     _rbr       := str(++nRbr,3)
     _idtipdok  := "12"
     _brdok     := cBrDok

     nCijena:=0
     setujcijenu()
     if ncijena<>0
       _cijena:=nCijena
     endif
     _rabat:=0
     _porez:=0
     _dindem:="KM"
     select pripr
     Gather()

     SELECT POMGS
     SKIP 1

   ENDDO

 ENDDO

CLOSERET
return
*}


/*! \fn EdSiO()
 *  \brief Obrada opcija
 */
 
function EdSiO()
*{
 SELECT PPOMGS

 if (Ch==K_CTRL_T .or. Ch==K_ENTER) .and. reccount2()==0
   return DE_CONT
 endif

 DO CASE

  case Ch==K_ALT_E
     IF gTBDir=="D"
       gTBDir:="N"
       NeTBDirektni()  // ELIB, vrati stari tbrowse
     ELSE
       gTBDir:="D"
       select(F_PARTN); if !used(); O_PARTN; endif
       select PPOMGS
       DaTBDirektni() // ELIB, promjeni tbrowse na edit rezim
     ENDIF

  case Ch==K_CTRL_T // .and. gTBDir=="N"
    if Pitanje(,"Zelite izbrisati tekucu stavku ?","D")=="D"
      DELETE
      return DE_REFRESH
    endif
    return DE_CONT

  case Ch==K_ENTER // .and. gTBDir=="N"
    Box("ist",6,70,.f.)
    Scatter()
    if EditSiO(.f.)==0
      BoxC()
      return DE_CONT
    else
      Gather()
      BoxC()
      return DE_REFRESH
    endif

  case Ch==K_CTRL_A // .and. gTBDir=="N"
    PushWA()
    select PPOMGS
    go top
    Box("ists",6,70,.f.,"Ispravka svih stavki redom")
    DO WHILE !EOF()
      skip; nTR2:=RECNO(); skip-1
      Scatter()
      @ m_x+1,m_y+1 CLEAR to m_x+6,m_y+70
      if EditSiO(.f.)==0
        exit
      endif
      select PPOMGS
      Gather()
      GO (nTR2)
    ENDDO
    PopWA()
    BoxC()
    return DE_REFRESH

  case Ch==K_CTRL_N // .and. gTBDir=="N"   // nove stavke
    GO BOTTOM
    Box("novs",6,70,.f.,"Unos nove stavke")
    do while .t.
      Scatter()
      @ m_x+1,m_y+1 CLEAR to m_x+6,m_y+70
      if EditSiO(.t.)==0
        exit
      endif
      select PPOMGS
      APPEND BLANK
      Gather()
    enddo

    BoxC()
    return DE_REFRESH

  case Ch=K_CTRL_F9 // .and. gTBDir=="N"
    if Pitanje(,"Zelite li izbrisati sve stavke ?!","N")=="D"
      ZapFiltSort()
    endif
    return DE_REFRESH

 ENDCASE

RETURN DE_CONT
*}


/*! \fn EditSiO()
 *  \brief
 */
 
function EditSiO()
*{
PARAMETERS fNovi
  SET CURSOR ON

  _DatDok   := dDatDok
  _IdPartn  := cIdPartner
  _idpm     := cIdPM
  _idrelac  := cIdRelac
  _iddist   := cIdDist
  _idvozila := cIdVozila
  _marsruta := cMarsruta

  @ m_x+2, m_y+2  SAY "Sifra artikla       "  GET _IdRoba    VALID P_Roba(@_IdRoba) PICT "@!"
  @ m_x+3, m_y+2  SAY "Naziv artikla       "  GET _NAZIV WHEN {|| _naziv:=ROBA->naz , .f. }
  @ m_x+4, m_y+2  SAY "Otpremljena kolicina"  GET _kolicina  PICT "99999999.999"

  READ; ESC_RETURN 0

RETURN 1
*}


/*! \fn StampaSO()
 *  \brief Stampa sistemskih otpremnica
 */
 
function StampaSO()
*{
dDatDok:=DATE()

  Box("#STAMPANJE SISTEMSKIH OTPREMNICA",3,70)
    @ m_x+2, m_y+2 SAY "Datum otpreme        :" GET dDatDok
    READ; ESC_BCR
  BoxC()

  O_SIFV
  O_SIFK
  O_RELAC
  O_VOZILA
  O_PARTN
  O_ROBA
  USEX (PRIVPATH+"POMGS") NEW
  SET ORDER TO TAG "1"
  // DTOS(DATDOK)+IDRELAC+MARSRUTA

  START PRINT CRET

  gnLMarg:=0; gOstr:="N"; gTabela:=1
  aKol:={}; nKol:=0
  nRbr:=0; cIdRoba:=""; cNazRoba:=""; cJMJ:=""; nUkupno:=0; cAmbalaza:=""
  AADD(aKol, { "R.br."   , {|| STR(nRBr,4)+"."  }, .f., "C",  5, 0, 1, ++nKol } )
  AADD(aKol, { "Sifra"   , {|| cIdRoba          }, .f., "C", 10, 0, 1, ++nKol } )
  AADD(aKol, { "Naziv"   , {|| cNazRoba         }, .f., "C", 50, 0, 1, ++nKol } )
  AADD(aKol, { "JMJ"     , {|| cJMJ             }, .f., "C",  3, 0, 1, ++nKol } )
  AADD(aKol, { "Kolicina", {|| nUkupno          }, .f., "N-", 12, 3, 1, ++nKol } )
  AADD(aKol, { "Ambalaza", {|| cAmbalaza        }, .f., "C",  8, 0, 1, ++nKol } )

  SEEK DTOS(dDatDok)
  DO WHILE !EOF() .and. datdok==dDatDok
    cIdRelac   := idrelac
    cMarsruta  := marsruta
    cIdPartner := idpartner

    lDodatno:=.f.
    nDodatno:=5

     P_10CPI
     cIdFirma:=gFirma
     StZaglav2(gVlZagl,PRIVPATH)

     StKupac()

     for i:=1 to gOdvT2; ?; next

     P_12CPI
     ?  "Relacija:", TRIM(cIdRelac)
     ?? "   Distributer:", TRIM(IdDist)+" "+TRIM(Ocitaj(F_PARTN,iddist,"naz"))
     ?? "   Vozilo:", TRIM(IdVozila)+" "+Ocitaj(F_VOZILA,idvozila,"TRIM(naz)+' '+TRIM(tablice)")
     ?
     bWhile := {|| datdok   == ddatdok   .and.;
                   IdRelac  == cidrelac  .and.;
                   marsruta == cMarsruta ;
                }
     nRBr := nUkupno := 0
     StampaTabele(aKol,,,gTabela,bWhile,;
                  ,,;
                  {|| FSistOtp()},IF(gOstr=="D",,-1),,,,,,.f.)
     ?
     ? "Isporucio:                                                        Primio:"
     FF

  ENDDO

  END PRINT

CLOSERET
*}


/*! \fn FSistOtp()
 *  \brief 
 */
 
function FSistOtp()
*{
LOCAL nArr:=SELECT(), nPak:=0, nKom:=0
  ++nRBr
  IF lDodatno
    --nDodatno
    cIdRoba:=""
    cJMJ:=""
    cNazRoba:=""
    IF nDodatno>0
      glNeSkipuj:=.t.
    ELSE
      glNeSkipuj:=.f.
    ENDIF
  ELSE
    cIdRoba:=IDROBA
    SELECT ROBA; HSEEK cIdRoba
    cNazRoba := naz
    cJMJ     := jmj
  ENDIF
  SELECT (nArr)

  // nUkupno:=kolicina
  nUkupno:=0

  // Prepak(cIdRoba,cjmj,@nPak,@nKom,nUkupno)
  // cAmbalaza := STR(nPak,2)+"P+"+STR(nKom,2)+"K"
  IF !lDodatno
    SKIP 1
    IF EOF() .or. !EVAL(bWhile)
      altd()
      lDodatno:=.t.
      glNeSkipuj:=.t.
    ENDIF
    SKIP -1
  ENDIF
RETURN .t.
*}


/*! \fn StKupac()
 *  \brief
 */
 
static function StKupac()
*{
local nArr:=SELECT()
local cMjesto:=padl(Mjesto(gFirma)+", "+dtoc(ddatdok)+" godine",iif(gFPZag=99,gnTMarg3,0)+39)

IF "U" $ TYPE("lPartic"); lPartic:=.f.; ENDIF

SELECT PARTN; HSEEK cIdPartner; SELECT (nArr)
_txt3a   := cIdPartner+"."
_txt3b   := ""
_txt3c   := ""
IzSifre(.T.)  // da nafiluje _txt3a, _txt3b i _txt3c - NAZIV KUPCA
cTxt3a:=_txt3a
cTxt3b:=_txt3b
cTxt3c:=_txt3c

aPom:=Sjecistr(cTxt3a,30)
 IF IzFMKINI("FAKT","KupacDesno","N",KUMPATH)=="D"
   ?? space(5); ?? PADR(ALLTRIM(iif(gFPzag<>99 .or. gnTMarg2=1,cMjesto,"")),39); gPB_ON(); ?? padc(alltrim(aPom[1]),30); gPB_OFF()
   for i:=2 to len(aPom)
     ? space(5+39);gPB_ON();?? padc(alltrim(aPom[i]),30);gPB_OFF()
   next
   ?  space(5); ?? PADR(ALLTRIM(iif(gFPzag=99 .and. gnTMarg2=2,cMjesto,"")),39) ;gPB_ON();?? padc(alltrim(cTxt3b),30);gPB_OFF()
   ?  space(5); ?? PADR(ALLTRIM(iif(gFPzag=99 .and. gnTMarg2=3,cMjesto,"")),39) ;gPB_ON();?? padc(alltrim(cTxt3c),30);gPB_OFF()
 ELSE
   ?? space(5);gPB_ON();?? padc(alltrim(aPom[1]),30);gPB_OFF(); ?? iif(gFPzag<>99 .or. gnTMarg2=1,cMjesto,"")
   for i:=2 to len(aPom)
     ? space(5);gPB_ON();?? padc(alltrim(aPom[i]),30);gPB_OFF()
   next
   ?  space(5);gPB_ON();?? padc(alltrim(cTxt3b),30);gPB_OFF(); ?? iif(gFPzag=99 .and. gnTMarg2=2,cMjesto,"")
   ?  space(5);gPB_ON();?? padc(alltrim(cTxt3c),30);gPB_OFF(); ?? iif(gFPzag=99 .and. gnTMarg2=3,cMjesto,"")
 ENDIF

if gFPZag=99 .and. gnTMarg2>3 // uzmi iz parametara poizviju za stampanjemjesta
 for i:=4 to gnTMarg2
  if  gnTMarg2 = i
     ? space(35)+cMjesto
     ?
     ? space(35)
     exit
  else
     ?
  endif
 next
endif

cStr := "SISTEMSKA OTPREMNICA br."
// cStr := cStr+" "+trim(cBrdok)

if gPrinter="R"
 B_ON
 IF IzFMKINI("FAKT","KupacDesno","N",KUMPATH)=="D"
   ?
   ShowIdPar(cIdPartner,44,.f.)
   ? SPACE(12)
   ?? padc("#%FS012#"+cStr,50)
 ELSE
   ShowIdPar(cIdPartner,5,.t.)
   ?? padl("#%FS012#"+cStr,39+4+iif(gFPZag=99,gnTMarg3,0))
 ENDIF
 B_OFF
else
 IF IzFMKINI("FAKT","KupacDesno","N",KUMPATH)=="D"
   ?
   ShowIdPar(cIdPartner,44,.f.)
   ? SPACE(12)
   B_ON; ?? padc(cStr,50); B_OFF
 ELSE
   ShowIdPar(cIdPartner,5,.t.)
   B_ON; ?? padl(cStr,39+iif(gFPZag=99,gnTMarg3,0)); B_OFF
 ENDIF
endif
RETURN
*}


