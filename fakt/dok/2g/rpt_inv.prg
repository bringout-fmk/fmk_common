#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/dok/2g/rpt_inv.prg,v $
 * $Author: sasa $ 
 * $Revision: 1.12 $
 * $Log: rpt_inv.prg,v $
 * Revision 1.12  2002/07/04 08:15:48  sasa
 * korekcija kolone manjak (predznak +)
 *
 * Revision 1.11  2002/07/01 12:50:22  sasa
 * Zavrsena ispravka stampe inventure i popisne liste
 *
 * Revision 1.10  2002/07/01 09:19:50  sasa
 * korekcije u stilu pisanja koda i ispravka gresaka
 *
 * Revision 1.9  2002/07/01 08:52:04  sasa
 * korekcije u stilu pisanja koda i ispravka gresaka
 *
 * Revision 1.8  2002/07/01 08:28:06  sasa
 * korekcije u stilu pisanja koda i ispravka gresaka
 *
 * Revision 1.7  2002/06/28 14:10:06  sasa
 * zavrsena stampa inventure
 *
 * Revision 1.6  2002/06/28 14:05:43  sasa
 * implementacija stampe obrasca
 *
 * Revision 1.5  2002/06/28 12:57:04  sasa
 * zavrsena stampa inventure
 *
 * Revision 1.4  2002/06/28 12:43:56  sasa
 * implementacija stampe inventure u toku
 *
 * Revision 1.3  2002/06/28 11:09:12  sasa
 * implementacija stampe inventure u toku
 *
 * Revision 1.2  2002/06/28 10:22:44  sasa
 * implementacija stampe inventure u toku
 *
 * Revision 1.1  2002/06/28 07:16:44  ernad
 *
 *
 * skeleton funkcija RptInv, RptObrPopisa
 *
 *
 */


/*! \fn RptInv()
 *  \brief Stampa dokumenta inventure IM
 */
 
function RptInv()
*{
local nTota:=0
local nTotb:=0
local nTotc:=0
local nTotd:=0
local nRecNo
local nRazlika:=0
local nVisak:=0
local nManjak:=0
local cPict
private nStr:=0

cLin:="--- --------------------------------------- ---------- ---------- ----------- ----------- ----------- ----------- ----------- -----------"

cIdFirma:=idFirma
cIdTipDok:=idTipDok
cBrDok:=brDok

nRecNo:=RecNo()

START PRINT CRET

ZaglInv(cLin)

GO TOP
do while !eof()
    	SELECT roba
	HSEEK pripr->idRoba
    	SELECT pripr

	DokNovaStrana(125,@nStr,1)
	
	@ PROW()+1,0 SAY field->rbr PICTURE "XXX"
	@ PROW(),4 SAY ""
	
	?? PADR(field->idRoba+" "+TRIM(roba->naz)+" ("+roba->jmj+")",36)
	
	// popisana kolicina    	
	@ PROW(),PCOL()+1 SAY field->kolicina PICTURE PicKol
	
	// knjizena kolicina
	@ PROW(),PCOL()+1 SAY VAL(field->serbr) PICTURE PicKol
	
	nC1:=PCOL()+1
     	
	// knjizna vrijednost
	@ PROW(),PCOL()+1 SAY (VAL(field->serbr))*(field->cijena) PICTURE PicDem

	// popisana vrijednost
	@ PROW(),PCOL()+1 SAY (field->kolicina)*(field->cijena) PICTURE PicDem
	
	// razlika
	nRazlika:=(VAL(field->serbr))-(field->kolicina)
	@ PROW(),PCOL()+1 SAY nRazlika PICTURE PicKol
	
	// VP cijena
    	@ PROW(),PCOL()+1 SAY field->cijena PICTURE PicCDem
	
    	if (nRazlika>0)
		nVisak:=nRazlika*(field->cijena)
		nManjak:=0
	elseif (nRazlika<0)
		nVisak:=0
		nManjak:=nRazlika*(field->cijena)
	else
		nVisak:=0
		nManjak:=0
	endif
	
	// VPV visak
	@ PROW(),PCOL()+1 SAY nVisak PICTURE PicDem
	nTotc+=nVisak
	
	// VPV manjak
	@ PROW(),PCOL()+1 SAY -nManjak PICTURE PicDem
	nTotd+=-nManjak
	
	// sumiraj knjizne vrijednosti
	nTota+=(VAL(field->serbr))*(field->cijena) 
	
	// sumiraj popisane vrijednosti
	nTotb+=(field->kolicina)*(field->cijena) 
	
	skip
enddo

DokNovaStrana(125,@nStr,3)

// UKUPNO:
// nTota - suma knj.vrijednosti
// nTotb - suma pop.vrijednosti
// nTotc - suma VPV visak
// nTotd - suma VPV manjak

? cLin
@ PROW()+1,0 SAY "Ukupno:"
@ PROW(),nC1 SAY nTota PICTURE PicDem
@ PROW(),PCOL()+1 SAY nTotb PICTURE PicDem
@ PROW(),PCOL()+1 SAY REPLICATE(" ",LEN(PicDem))
@ PROW(),PCOL()+1 SAY REPLICATE(" ",LEN(PicDem))
@ PROW(),PCOL()+1 SAY nTotc PICTURE PicDem
@ PROW(),PCOL()+1 SAY nTotd PICTURE PicDem
? cLin

END PRINT

SELECT pripr
GO nRecNo

return
*}


/*! \fn ZaglInv(cLinija)
 *  \brief Zaglavlje izvjestaja inventura
 *  \param cLinija - Proslijedjuje se linija koja se ispisuje iznad i ispod zaglavlja 
 */
 
function ZaglInv(cLinija)
*{
P_10CPI
?? "INVENTURA VP :"
P_COND
?
? "DOKUMENT BR. :", cIdFirma+"-"+cIdTipDok+"-"+cBrDok, SPACE(2), "Datum:", datDok
?
DokNovaStrana(125,@nStr,-1)
? cLinija
?  "*R * ROBA                                  * Popisana * Knjizna  *  Knjizna  * Popisana  *  Razlika  *  Cijena   *   Visak   *  Manjak  *"
?  "*BR*                                       * Kolicina * Kolicina *vrijednost *vrijednost *  (kol)    *    VP     *    VPV    *   VPV    *"
? cLinija

return
*}


