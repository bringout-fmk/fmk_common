#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/mag/konsig/1g/fak_kal.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.2 $
 * $Log: fak_kal.prg,v $
 * Revision 1.2  2002/06/20 13:13:03  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/mag/konsig/1g/fak_kal.prg
 *  \brief Prenos dokumenata FAKT->KALK za konsignaciju
 */


/*! \fn FaktKonsig()
 *  \brief Meni opcija prenosa FAKT->KALK za konsignaciju
 */

function FaktKonsig()
*{
private Opc:={}
private opcexe:={}

AADD(Opc,"1. fakt->kalk (16->10) ulaz od dobavljaca  ")
AADD(opcexe,{|| Prenos16() })
private Izbor:=1
Menu_SC("fkon")
CLOSERET
return
*}


/*! \fn Prenos16()
 *  \brief Racun konsignacije (FAKT 16) -> ulaz od dobavljaca (KALK 10)
 */
 
function Prenos16()
*{
local cIdFirma:=gFirma, cIdTipDok:="16", cBrDok:=cBrKalk:=space(8)
local cTipKalk:="10"

O_KONCIJ
O_PRIPR
O_KALK
O_ROBA
O_KONTO
O_PARTN
O_TARIFA

XO_FAKT

dDatKalk:=date()

cIdKonto:=padr("1310",7)
cIdKonto2:=padr("",7)

cIdZaduz2:=space(6)

cBrkalk:=space(8)
if gBrojac=="D"
 select kalk
 select kalk; set order to 1
 seek cidfirma+cTipkalk+"X"
 skip -1
 if cTipkalk<>IdVD
   cbrkalk:=space(8)
 else
   cbrkalk:=brdok
 endif
endif
Box(,15,60)

if gBrojac=="D"
 cbrkalk:=UBrojDok(val(left(cbrkalk,5))+1,5,right(cBrKalk,3))
endif

do while .t.

  nRBr:=0
  @ m_x+1,m_y+2   SAY "Broj kalkulacije "+cTipKalk+" -" GET cBrKalk pict "@!"
  @ m_x+1,col()+2 SAY "Datum:" GET dDatKalk
  @ m_x+3,m_y+2   SAY "Konto zaduzuje :" GET cIdKonto  pict "@!" valid P_Konto(@cIdKonto)
  if gNW<>"X"
    @ m_x+4,col()+2 SAY "Razduzuje:" GET cIdZaduz2  pict "@!"      valid empty(cidzaduz2) .or. P_Firma(@cIdZaduz2)
  endif

  cFaktFirma:="20"  // pretpostavljam da se odvaja RJ u FAKT za konsignaciju

  @ m_x+6,m_y+2 SAY "Broj "+IF(LEFT(cIdTipDok,1)!="0","otpremnice","dokumenta u FAKT")+": " GET  cFaktFirma
  @ m_x+6,col()+1 SAY "- "+cidtipdok
  @ m_x+6,col()+1 SAY "-" GET cBrDok
  read
  if lastkey()==K_ESC; exit; endif


  select xfakt
  seek cFaktFirma+cIdTipDok+cBrDok
  if !found()
     Beep(4)
     @ m_x+14,m_y+2 SAY "Ne postoji ovaj dokument !!"
     inkey(4)
     @ m_x+14,m_y+2 SAY space(30)
     loop
  else
     aMemo:=parsmemo(txt)
     if len(aMemo)>=5
       @ m_x+10,m_y+2 SAY padr(trim(amemo[3]),30)
       @ m_x+11,m_y+2 SAY padr(trim(amemo[4]),30)
       @ m_x+12,m_y+2 SAY padr(trim(amemo[5]),30)
     else
	cTxt:=""
     endif
     cIdPartner:=IDPARTNER
     private cBeze:=" "

     if cTipKalk $ "10"
       @ m_x+14,m_y+2 SAY "Sifra partnera:"  GET cIdpartner pict "@!" valid P_Firma(@cIdPartner)
       @ m_x+15,m_y+2 SAY "<ENTER> - prenos" GET cBeze
       read
     endif

     select PRIPR
     locate for BrFaktP=cBrDok // faktura je vec prenesena
     if found()
      Beep(4)
      @ m_x+8,m_y+2 SAY "Dokument je vec prenesen !!"
      inkey(4)
      @ m_x+8,m_y+2 SAY space(30)
      loop
     endif
     go bottom
     if brdok==cBrKalk; nRbr:=val(Rbr); endif

     SELECT KONCIJ; SEEK TRIM(cIdKonto)

     select xfakt
     IF !ProvjeriSif("!eof() .and. '"+cFaktFirma+cIdTipDok+cBrDok+"'==IdFirma+IdTipDok+BrDok","IDROBA",F_ROBA)
       MsgBeep("U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!")
       LOOP
     ENDIF
     do while !eof() .and. cFaktFirma+cIdTipDok+cBrDok==IdFirma+IdTipDok+BrDok
       select ROBA; hseek xfakt->idroba

       select tarifa; hseek roba->idtarifa

       select xfakt
       if alltrim(podbr)=="."  .or. idroba="U"
          skip
          loop
       endif

       select PRIPR
       APPEND BLANK

       REPLACE idfirma   WITH cIdFirma        ,;
               rbr       WITH str(++nRbr,3)   ,;
               idvd      WITH cTipKalk        ,;
               brdok     WITH cBrKalk         ,;
               datdok    WITH dDatKalk        ,;
               idpartner WITH cIdPartner      ,;
               idtarifa  WITH ROBA->idtarifa  ,;
               brfaktp   WITH xfakt->brdok    ,;
               datfaktp  WITH xfakt->datdok   ,;
               idkonto   WITH cidkonto        ,;
               idkonto2  WITH cidkonto2       ,;
               idzaduz2  WITH cidzaduz2       ,;
               datkurs   WITH xfakt->datdok   ,;
               kolicina  WITH xfakt->kolicina ,;
               idroba    WITH xfakt->idroba   ,;
               fcj       WITH xfakt->cijena   ,;
               nc        WITH xfakt->cijena   ,;
               rabatv    WITH xfakt->rabat

       REPLACE vpc       WITH KoncijVPC()

       PrenPoNar()

       select xfakt
       skip 1
     enddo
     @ m_x+8,m_y+2 SAY "Dokument je prenesen !!"
     if gBrojac=="D"
      cbrkalk:=UBrojDok(val(left(cbrkalk,5))+1,5,right(cBrKalk,3))
     endif
     inkey(4)
     @ m_x+8,m_y+2 SAY space(30)
  endif

enddo
BoxC()
CLOSERET
return
*}

