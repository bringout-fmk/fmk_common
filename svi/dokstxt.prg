#include "sc.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/svi/dokstxt.prg,v $
 * $Author: sasa $ 
 * $Revision: 1.2 $
 * $Log: dokstxt.prg,v $
 * Revision 1.2  2002/07/25 11:05:56  sasa
 * ispravljen komentar
 *
 * Revision 1.1  2002/07/25 11:01:08  sasa
 * uveden novi prg, sifrarnik uzoraka tekstova za dokumente
 *
 *
 */


/*! \file fmk/svi/dokstxt.prg
 *  \brief Uzorci teksta za pocetak i kraj izvjestaja
 */

/*! \fn P_DoksTxt(cId,dx,dy)
 *  \brief Otvara tabelu doks txt u sifrarniku
 *  \param
 */
 
function P_DoksTxt(cId,dx,dy)
*{
local vrati
private ImeKol
private Kol
private gTBDir:="N"

OSifDoksTxt()

SELECT (F_DOKSTXT)

if !USED()
	O_DOKSTXT
endif

ImeKol:={}
AADD(ImeKol,{PADR("ID",2)   ,{|| id}      ,"id",{|| .t.},{||VpSifra(wid)}})
AADD(ImeKol,{PADR("NAZ",3)  ,{|| naz}     ,"naz"})
AADD(ImeKol,{PADR("MODUL",5),{|| modul}   ,"modul"})
AADD(ImeKol,{PADR("POZ",3)  ,{|| pozicija},"pozicija"})

AADD(ImeKol,{"TXT",{|| txt},"txt",{|| UsTipke(),.t.},{|| wtxt:=STRTRAN(wtxt,"##",CHR(13)+CHR(10)), BosTipke(), .t.},nil, "@S50" })

AADD(ImeKol,{"TXT2",{|| txt2},"txt2",{|| UsTipke(),.t.},{|| wtxt2:=STRTRAN(wtxt2,"##",CHR(13)+CHR(10)), BosTipke(), .t.},nil, "@S50" })

Kol:={1,2,3,4,5,6}

Prozor1(3,0,11,79,"PREGLED UZORAKA TEKSTA ZA IZVJESTAJE")

@ 12,0 SAY ""

vrati:=PostojiSifra(F_DOKSTXT,1,7,77,"Uzorci teksta za izvjestaje",@cId,,,{|| PrikDoksTxt()})

Prozor0()

return vrati
*}


/*! \fn PrikDoksTxt()
 *  \brief Prikazuje tekst dokstxt->txt u odvojenom prozoru
 */
 
function PrikDoksTxt()
*{
local i:=0
local aTxt:={}

@ 3,60 SAY "Sifra:"+id

aTxt:=TxtUNiz(txt,78)

for i:=1 TO 7
	if (i>LEN(aTXT))
     		@ 3+i,1 SAY SPACE(78)
   	else
     		@ 3+i,1 SAY PADR(aTXT[i],78)
   	endif
next
return -1
*}

/*! \fn TxtUNiz(cTxt,nKol)
 *  \brief Pretvara tekst u niz
 *  \param cTxt - tekst
 *  \param nKol - kolone
 *  \return aVrati - vraca niz
 */
 
static function TxtUNiz(cTxt,nKol)
*{
local aVrati:={}
local nPoz:=0
local lNastavi:=.t.
local cPom:=""
local aPom:={}
local i:=0

cTxt:=TRIM(cTxt)

do while lNastavi
	nPoz:=AT(CHR(13)+CHR(10),cTxt)
    	if (nPoz>0)
      		cPom:=LEFT(cTxt,nPoz-1)
      		if ((nPoz-1)>nKol)
        		cPom:=TRIM(LomiGa(cPom,1,5,nKol))
        		for i:=1 to INT((LEN(cPom)-1)/nKol)+1
          			AADD(aVrati,SUBSTR(cPom,(i-1)*nKol+1,nKol))
        		next
      		else
        		AADD(aVrati,cPom)
      		endif
      		cTxt:=SUBSTR(cTxt,nPoz+2)
    	elseif !EMPTY(cTxt)
      		cPom:=TRIM(cTxt)
      		if (LEN(cPom)>nKol)
        		cPom:=TRIM(LomiGa(cPom,1,5,nKol))
        		for i:=1 to INT((LEN(cPom)-1)/nKol)+1
          			AADD(aVrati,SUBSTR(cPom,(i-1)*nKol+1,nKol))
        		next
      		else
        		AADD(aVrati,cPom)
      		endif
      		lNastavi:=.f.
    	else
      		lNastavi := .f.
    	endif
enddo

return aVrati
*}

/*! \fn GetDoksTxt(cModul,cIdDok,cPozicija)
 *  \brief Preuzima iz sif->DoksTxt vrijednost polja txt
 *  \param cModul - o kojem je modulu rijec (KA-kalk, FA-fakt, FI-fin, ...). Moguce varijante su: KA, FA, FI, LD, OS
 *  \param cIdDok - o kojoj je vrsti dokumenta rijec (10, 11, 80, ...)
 *  \param cPozicija - H-header, F-fouter, K-kraj izvjestaja itd...
                       Mozemo definisati razne varijante tekstova i pozivati ih po zelji.
 *  \return cIspisi - tekst preuzet iz FIELD->TXT
 */
 
function GetDoksTxt(cModul,cIdDok,cPozicija)
*{
cIspisi:=""

O_DOKSTXT

SELECT (F_DOKSTXT)
SET ORDER TO TAG "ID"
SEEK cModul+cIdDok+cPozicija

if FOUND()
	cIspisi:=FIELD->txt
else
	cIspisi:=""
endif

return cIspisi
*}


