#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/razdb/1g/fak_kal.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.2 $
 * $Log: fak_kal.prg,v $
 * Revision 1.2  2002/06/21 14:08:29  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/razdb/1g/fak_kal.prg
 *  \brief Prenos dokumenata iz modula FAKT u KALK
 */


/*! \fn FaktKalk()
 *  \brief Meni opcija za prenos dokumenata iz modula FAKT u KALK
 */

function FaktKalk()
*{
private Opc:={}
private opcexe:={}

AADD(Opc,"1. magacin fakt->kalk         ")
AADD(opcexe,{|| FaKaMag() })
AADD(Opc,"2. prodavnica fakt->kalk")
AADD(opcexe,{||  FaKaProd()  })
AADD(Opc,"3. proizvodnja fakt->kalk")
AADD(opcexe,{||  FaKaProizvodnja() })        
AADD(Opc,"4. konsignacija fakt->kalk")
AADD(opcexe, {|| FaktKonsig() }) 
private Izbor:=1
Menu_SC("faka")
CLOSERET
return
*}




/*! \fn ParsMemo(cTxt)
 *  \brief Pretvaranje formatiranog memo polja u niz
 */

// Struktura cTxt-a je: Chr(16) txt1 Chr(17)  Chr(16) txt2 Chr(17) ...
function ParsMemo(cTxt)
*{
local aMemo:={}
local i,cPom,fPoc

 fPoc:=.f.
 cPom:=""
 for i:=1 to len(cTxt)
   if  substr(cTxt,i,1)==Chr(16)
     fPoc:=.t.
   elseif  substr(cTxt,i,1)==Chr(17)
     fPoc:=.f.
     AADD(aMemo,cPom)
     cPom:=""
   elseif fPoc
      cPom:=cPom+substr(cTxt,i,1)
   endif
 next
return aMemo
*}




/*! \fn ProvjeriSif(clDok,cImePoljaID,nOblSif,clFor)
 *  \brief Provjera postojanja sifara
 *  \param clDok - "while" uslov za obuhvatanje slogova tekuce baze
 *  \param cImePoljaID - ime polja tekuce baze u kojem su sifre za ispitivanje
 *  \param nOblSif - oblast baze sifrarnika
 *  \param clFor - "for" uslov za obuhvatanje slogova tekuce baze
 */

function ProvjeriSif(clDok,cImePoljaID,nOblSif,clFor)
*{
LOCAL lVrati:=.t., nArr:=SELECT(), nRec:=RECNO(), lStartPrint:=.f., cPom3:=""
LOCAL nR:=0
IF clFor==NIL; clFor:=".t."; ENDIF
PRIVATE cPom := clDok, cPom2 := cImePoljaID, cPom4:=clFor
DO WHILE &cPom
  IF &cPom4
    SELECT (nOblSif)
    cPom3 := (nArr)->(&cPom2)
    SEEK cPom3
    IF !FOUND()  .and.  !(  xFakt->(alltrim(podbr)==".")  .and. empty(xfakt->idroba))
                        // ovo je kada se ide 1.  1.1 1.2
      ++nR
      lVrati:=.f.
      IF !lStartPrint
        lStartPrint:=.t.
        StartPrint()
        ? "NEPOSTOJECE SIFRE:"
        ? "------------------"
      ENDIF
      ? STR(nR)+") SIFRA '"+cPom3+"'"
    ENDIF
  ENDIF
  SELECT (nArr)
  SKIP 1
ENDDO
GO (nRec)
IF lStartPrint
  ?
  EndPrint()
ENDIF
return lVrati
*}




/*! \fn PrenPoNar()
 *  \brief Za evidenciju po narudzbama, ovdje prenosimo i te podatke
 */

function PrenPoNar()
*{
  IF lPoNarudzbi .and. FIELDPOS("IDNAR")<>0
    REPLACE idnar WITH XFAKT->idnar, brojnar WITH XFAKT->brojnar
  ENDIF
return
*}

