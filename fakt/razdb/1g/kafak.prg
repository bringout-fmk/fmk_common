#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/razdb/1g/kafak.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.6 $
 * $Log: kafak.prg,v $
 * Revision 1.6  2003/01/21 13:28:23  ernad
 * korekcije direktorij
 *
 * Revision 1.5  2002/09/12 07:45:16  mirsad
 * dokumentovanje INI parametara
 *
 * Revision 1.4  2002/07/04 08:34:19  mirsad
 * dokumentovanje ini parametara
 *
 * Revision 1.3  2002/07/04 08:16:44  sasa
 * to do: izvrsiti korekciju nad ovim fajlom
 *
 * Revision 1.2  2002/06/18 13:39:48  sasa
 * no message
 *
 * Revision 1.1.1.1  2002/06/17 18:30:18  ernad
 * no message
 *
 *
 */

/*! \file fmk/fakt/razdb/1g/kafak.prg
 *  \brief Kalk 2 Fakt
 */

/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_KalFakBezRbr901
  * \brief Da li se ne prenose stavke KALK dokumenta sa rednim brojem >900 (u proizvodnji to su stavke utrosenih sirovina)
  * \param D - da, ne prenose se, default vrijednost
  * \param N - ne, tj. prenose se
  */
*string FmkIni_KumPath_FAKT_KalFakBezRbr901;


 
/*! \fn KaFak()
 *  \brief Prenos dokumenata KALK<->FAKT
 */
 
function KaFak()
*{
local izb:=1
PUBLIC gDirKalk:=""

O_PARAMS


cOdradjeno:="D"
altd()
if file(EXEPATH+'scshell.ini')
        //cBrojLok:=R_IniRead ( 'TekucaLokacija','Broj',  "",EXEPATH+'scshell.INI' )
        cOdradjeno:=R_IniRead ( 'ShemePromjena',alltrim(strtran(strtran(goModul:oDataBase:cDirPriv,"\","_"),":","_")),  "N" ,EXEPATH+'scshell.INI' )
        R_IniWrite ( 'ShemePromjena',alltrim(strtran(strtran(goModul:oDataBase:cDirPriv,"\","_"),":","_")),  "D" ,EXEPATH+'scshell.INI' )
endif

private cSection:="T",cHistory:=" "; aHistory:={}
RPar("dk",@gDirKalk)
if empty(gDirKalk) .or. cOdradjeno="N"
  gDirKalk:=trim(strtran(goModul:oDataBase:cDirKum,"FAKT","KALK"))+"\"
  WPar("dk",gDirKalk)
endif

if cOdradjeno="N"
 private cSection:="1",cHistory:=" "; aHistory:={}
 gKomlin:=strtran(Upper(gKomlin),"1\FAKT.RTF",Right(trim(ImeKorisn))+"\FAKT.RTF" )
 WPar("95",gKomLin)       // prvenstveno za win 95
endif

select 99; use



private opc[3]
Opc[1]:="1. prenos kalk -> fakt    "
Opc[2]:="2. kalk->fakt za partnera "
Opc[3]:="3. parametri              "

h[1]:=h[2]:=h[3]:=""


do while .t.

   Izb:=menu("tkalk",opc,Izb,.f.)

   do case
     case izb == 0
         exit
     case izb == 1
         Prenos()
     case izb == 2
         Prenos2()
     case izb == 3
         Params()
   endcase

enddo

return
*}



/*! \fn Params() 
 *  \brief Parametri prenosa KALK<->FAKT
 */
 
function Params()
*{
gDirKalk:=padr(gDirKalk,80)

O_PARAMS
private cSection:="T",cHistory:=" "; aHistory:={}

Box(,3,70)
  @ m_x+1,m_y+2 SAY "Radni direktorij KALK (KALK.DBF):" GET gDirKalk PICT "@S30"
  READ
BoxC()

gDirKalk:=trim(gDirKalk)
IF LASTKEY()<>K_ESC
 WPar("dk",gDirKalk)
ENDIF
select params; use

return
*}



/*! \fn Prenos()
 *  \brief Prenos dokumenata
 */
 
function Prenos()
*{
local cIdFirma:=gFirma,cIdTipDok:="10",cBrDok:=space(8),cBrFakt
local cDir:=space(25)
O_PARAMS
private cSection:="K"; cHistory:=" "; aHistory:={}

RPar("c1",@cDir)
select params; use

cDir:=trim(cDir)  // direktorij u kome je kalk.dbf

O_FAKT
O_PRIPR
O_PARTN

#ifdef C52
 use  (gDirKalk+"KALK")    new
 set order to tag "1"
#else
 use  (gDirKalk+"KALK")   index (gDirKalk+"KALKi1") new
#endif

Box(,15,60)

do while .t.
  cIdTipDok:="10"
  cBrDok:=space(8)
  @ m_x+2,m_y+2 SAY "Broj KALK dokumenta:"
  if gNW=="N"
   @ m_x+2,col()+1 GET cIdFirma pict "@!"
  else
   @ m_x+2,col()+1 SAY cIdFirma pict "@!"
  endif
  @ m_x+2,col()+1 SAY "- " GET cIdTipDok
  @ m_x+2,col()+1 SAY "-" GET cBrDok
  read
  cTipFakt:="01"
  cBrFakt:=cBrDok
  cIdRj:=cIdFirma
  @ m_x+3,m_y+2 SAY "Broj dokumenta u modulu FAKT: "
  @ m_x+3,col()+1 GET cIdRJ pict "@!"
  @ m_x+3,col()+2 SAY "-" GET cTipFakt
  @ m_x+3,col()+2 SAY "-" GET cBrFakt
  read
  if lastkey()==K_ESC; exit; endif

  select FAKT
  seek cIdRj+cTipFakt+cBrFakt
  if found()
     Beep(4)
     @ m_x+14,m_y+2 SAY "U FAKT vec postoji ovaj dokument !!"
     inkey(4)
     @ m_x+14,m_y+2 SAY space(37)
     loop
  endif


  select KALK
  seek cIdFirma+cIdTipDok+cBrDok
  if !found()
     Beep(4)
     @ m_x+14,m_y+2 SAY "Ne postoji ovaj dokument !!"
     inkey(4)
     @ m_x+14,m_y+2 SAY space(30)
  else


     lBezSirovina := ( IzFMKINI("FAKT","KalFakBezRbr901","D",KUMPATH)=="D" )

     select KALK
     fFirst:=.t.
     do while !eof() .and. cIdFirma+cIdTipDok+cBrDok==IdFirma+IdVD+BrDok

       if lBezSirovina
         if val(rbr)>900; skip; loop; endif  //!! ne uzimaj sirovine
       endif

       if ffirst
           select PARTN; hseek KALK->idpartner
           cTxta:=padr(naz,30)
           cTxtb:=padr(naz2,30)
           cTxtc:=padr(mjesto,30)
           @ m_x+10,m_Y+2 SAY "Partner " GET cTxta
           @ m_x+11,m_Y+2 SAY "        " GET cTxtb
           @ m_x+12,m_Y+2 SAY "Mjesto  " GET cTxtc
           read
           ctxt:=Chr(16)+" " +Chr(17)+;
                 Chr(16)+" "+Chr(17)+;
                 Chr(16)+cTxta+ Chr(17)+ Chr(16)+cTxtb+Chr(17)+;
                 Chr(16)+cTxtc+Chr(17)
           fFirst:=.f.

          select PRIPR
          append blank
          replace txt with ctxt
       else

        select PRIPR
        APPEND BLANK
       endif

       private nKolicina:=kalk->kolicina
       if kalk->idvd=="11" .and. cTipFakt="0"
          nKolicina:=-nKolicina
       endif
       replace idfirma  with cIdRj,;
               rbr      with KALK->Rbr,;
               idtipdok with cTipFakt,;   // izlazna faktura
               brdok    with cBrFakt,;
               datdok   with KALK->datdok,;
               kolicina with nKolicina,;
               idroba   with KALK->idroba,;
               cijena   with KALK->fcj,;
               rabat    with KALK->rabat,;
               dindem   with "DEM"
       IF lPoNarudzbi .and. FIELDPOS("IDNAR")<>0
         replace idnar with KALK->idnar, brojnar with KALK->brojnar
       ENDIF
       select KALK
       skip
     enddo
     @ m_x+8,m_y+2 SAY "Dokument je prenesen !!"
     inkey(4)
     @ m_x+8,m_y+2 SAY space(30)
  endif

enddo
Boxc()
closeret
*}



/*! \fn Prenos2()
 *  \brief Prenos po uslovu za period, vrstu dokumenta, partnera
 *  \brief Moze i vise Kalk dokumenata u jedan Fakt dokument
 */
 
function Prenos2()
*{
local cDir:=space(25)

  O_DOKS
  O_FAKT
  O_PRIPR
  SET ORDER TO TAG "3"     // idfirma+idroba+rbr

  O_PARTN

  cIdFirma   := gFirma
  dOd := dDo := DATE()
  cIdPartner := SPACE(LEN(PARTN->id))
  qqIdVd     := PADR("41;",40)
  cIdTipDok  := "11"

  O_PARAMS
  private cSection:="K"; cHistory:=" "; aHistory:={}
  RPar("c1",@cDir)
  RPar("p1",@dOd)
  RPar("p2",@dDo)
  RPar("p3",@cIdPartner)
  RPar("p4",@qqIdVd)
  RPar("p5",@cIdTipDok)
  select params; use

  cDir:=trim(cDir)  // direktorij u kome je kalk.dbf

  USE (gDirKalk+"KALK") NEW
  SET ORDER TO TAG "7"  // idroba

  Box("#KALK->FAKT za partnera",15,75)

  DO WHILE .T.
    @ m_x+1,m_y+2 SAY "Firma/RJ:"
    if gNW=="N"
      @ m_x+1,col()+1 GET cIdFirma pict "@!"
    else
      @ m_x+1,col()+1 SAY cIdFirma pict "@!"
    endif
    @ m_x+2,m_y+2 SAY "Partner" GET cIdPartner VALID P_Firma(@cIdPartner)
    @ m_x+3,m_y+2 SAY "Vrste KALK dokumenata" GET qqIdVd PICT "@!S30"
    @ m_x+4,m_y+2 SAY "Za period od" GET dOd
    @ m_x+4,col()+1 SAY "do" GET dDo

    cTipFakt := cIdTipDok
    cBrFakt  := SPACE(8)
    cIdRj    := cIdFirma
    @ m_x+6,m_y+2 SAY "Broj dokumenta u modulu FAKT: "
    @ m_x+6,col()+1 GET cIdRJ pict "@!"
    @ m_x+6,col()+2 SAY "-" GET cTipFakt
    @ m_x+6,col()+2 SAY "-" GET cBrFakt WHEN SljedBrFakt()
    read
    if lastkey()==K_ESC; exit; endif
    IF (aUsl1 := Parsiraj(qqIdVd,"IDVD")) == NIL; LOOP; ENDIF

    select FAKT
    seek cIdRj+cTipFakt+cBrFakt
    if found()
       Beep(4)
       @ m_x+14,m_y+2 SAY "U FAKT vec postoji ovaj dokument !!"
       inkey(4)
       @ m_x+14,m_y+2 SAY space(37)
       loop
    endif

    select KALK
    cFilter := "IDFIRMA==cIdFirma.and.DATDOK>=dOd.and.DATDOK<=dDo.and.IDPARTNER==cIdPartner"
    IF !EMPTY(qqIdVd); cFilter+=".and."+aUsl1; ENDIF
    SET FILTER TO &cFilter
    GO TOP

    altd()

    IF EOF()
      Beep(4)
      @ m_x+14,m_y+2 SAY "Trazeno ne postoji u KALK-u !"
      INKEY(4)
      @ m_x+14,m_y+2 SAY space(30)
      LOOP
    ELSE
      // imamo filterisan KALK, slijedi generacija FAKT iz KALK
      lBezSirovina := ( IzFMKINI("FAKT","KalFakBezRbr901","D",KUMPATH)=="D" )
      select KALK
      fFirst:=.t.

      DO WHILE !EOF()
        if lBezSirovina
          if val(rbr)>900; skip; loop; endif  //!! ne uzimaj sirovine
        endif
        nKalkCijena := IF(cTipFakt$"00#01",KALK->nc,;
                       IF(cTipFakt$"11#27",KALK->mpcsapp,KALK->vpc))
        nKalkRabat := IF(cTipFakt$"00#01",0,KALK->rabatv)
        IF lPoNarudzbi
          cidnar := KALK->idnar; cbrojnar := KALK->brojnar
        ENDIF
        private nKolicina:=kalk->kolicina
        if kalk->idvd=="11" .and. cTipFakt="0"
          nKolicina := -nKolicina
        endif

        cArtikal:=idroba
        SKIP 1
        DO WHILE !EOF() .and. cArtikal==idroba
          n2KalkCijena := IF(cTipFakt$"00#01",KALK->nc,;
                         IF(cTipFakt$"11#27",KALK->mpcsapp,KALK->vpc))
          n2KalkRabat := IF(cTipFakt$"00#01",0,KALK->rabatv)
          n2Kolicina:=kalk->kolicina
          if kalk->idvd=="11" .and. cTipFakt="0"
            n2Kolicina := -n2Kolicina
          endif
          IF nKalkCijena<>n2KalkCijena .or. nKalkRabat<>n2KalkRabat
            EXIT
          ENDIF
          nKolicina += (n2Kolicina)
          SKIP 1
        ENDDO
        SKIP -1

        if ffirst
          nRBr:=1
          select PARTN; hseek KALK->idpartner
          _Txt3a:=padr(KALK->idpartner+".",30); _txt3b:=_txt3c:=""; IzSifre(.t.)
          cTxta:=_txt3a
          cTxtb:=_txt3b
          cTxtc:=_txt3c
          @ m_x+10,m_Y+2 SAY "Partner " GET cTxta
          @ m_x+11,m_Y+2 SAY "        " GET cTxtb
          @ m_x+12,m_Y+2 SAY "Mjesto  " GET cTxtc
          read
          ctxt:=Chr(16)+" " +Chr(17)+;
                Chr(16)+" "+Chr(17)+;
                Chr(16)+cTxta+ Chr(17)+ Chr(16)+cTxtb+Chr(17)+;
                Chr(16)+cTxtc+Chr(17)
          fFirst:=.f.
          select PRIPR
          append blank
          replace txt with ctxt
        else
          select PRIPR
          HSEEK cIdFirma+KALK->idroba
          IF FOUND() .and. ROUND(nKalkCijena-cijena,5)==0 .and.;
             ( cTipFakt="0" .or. ROUND(nKalkRabat-rabat,5)==0 ) .and.;
             ( !lPoNarudzbi .or. idnar==cIdNar.and.brojnar==cBrojNar )
            Scatter()
            _kolicina += nKolicina
            Gather()
            SELECT KALK; SKIP 1; LOOP
          ELSE
            ++nRBr
            APPEND BLANK
          ENDIF
        endif
        replace idfirma   with cIdRj        ,;
                rbr       with STR(nRBr,3)  ,;
                idtipdok  with cTipFakt     ,;   // izlazna faktura
                brdok     with cBrFakt      ,;
                datdok    with dDo          ,;
                idpartner with cIdPartner   ,;
                kolicina  with nKolicina    ,;
                idroba    with KALK->idroba ,;
                cijena    with nKalkCijena  ,;
                rabat     with nKalkRabat   ,;
                dindem    with "KM"
        IF lPoNarudzbi
          REPLACE idnar WITH cidnar, brojnar WITH cbrojnar
        ENDIF
        select KALK
        SKIP 1
      ENDDO

      @ m_x+8,m_y+2 SAY "Dokument je prenesen !"
      INKEY(4)
      @ m_x+8,m_y+2 SAY space(30)
      // snimi parametre !!!
      O_PARAMS
      private cSection:="K"; cHistory:=" "; aHistory:={}
      WPar("c1",cDir)
      WPar("p1",dOd)
      WPar("p2",dDo)
      WPar("p3",cIdPartner)
      WPar("p4",qqIdVd)
      WPar("p5",cIdTipDok)
      select params; use
      SELECT KALK
    ENDIF
  ENDDO
  Boxc()
CLOSERET
*}



/*! \fn SljedBrFakt()
 *  \brief Sljedeci broj fakture
 */
 
static function SljedBrFakt()
*{
LOCAL nArr:=SELECT()
  IF EMPTY(cBrFakt)
    _datdok    := dDo
    _idpartner := cIdPartner
    cBrFakt := OdrediNBroj(cIdRJ,cTipFakt)
    SELECT (nArr)
  ENDIF
return .t.
*}


