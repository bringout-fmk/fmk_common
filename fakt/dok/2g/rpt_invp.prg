#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/dok/2g/rpt_invp.prg,v $
 * $Author: sasa $ 
 * $Revision: 1.10 $
 * $Log: rpt_invp.prg,v $
 * Revision 1.10  2002/07/01 12:50:22  sasa
 * Zavrsena ispravka stampe inventure i popisne liste
 *
 * Revision 1.9  2002/07/01 09:19:50  sasa
 * korekcije u stilu pisanja koda i ispravka gresaka
 *
 * Revision 1.8  2002/07/01 08:52:04  sasa
 * korekcije u stilu pisanja koda i ispravka gresaka
 *
 * Revision 1.7  2002/07/01 08:28:06  sasa
 * korekcije u stilu pisanja koda i ispravka gresaka
 *
 * Revision 1.6  2002/06/29 09:32:19  sasa
 * no message
 *
 * Revision 1.5  2002/06/28 14:05:43  sasa
 * implementacija stampe obrasca
 *
 * Revision 1.4  2002/06/28 13:50:56  sasa
 * implementacija stampe obrasca
 *
 * Revision 1.3  2002/06/28 13:16:45  sasa
 * implementacija stampe obrasca
 *
 * Revision 1.2  2002/06/28 12:58:30  sasa
 * implementacija stampe obrasca
 *
 * Revision 1.1  2002/06/28 07:16:44  ernad
 *
 *
 * skeleton funkcija RptInv, RptObrPopisa
 *
 *
 */


/*! \fn RptInvObrPopisa()
 *  \brief Stampa inventurnog obrasca popisa
 */
 
function RptInvObrPopisa()
*{
local nRecNo
private nStr:=0

cLin:="--- --------------------------------------------- ------------ ------------"

cIdFirma:=idFirma
cIdTipDok:=idTipDok
cBrDok:=brDok

nRecNo:=RecNo()

START PRINT CRET

ZInvp(cLin)

GO TOP
do while !eof() 
	SELECT roba
	HSEEK pripr->idRoba
    	SELECT pripr

	DokNovaStrana(125,@nStr,1)
	
	@ PROW()+1,0 SAY field->rbr PICTURE "XXX"
	@ PROW(),4 SAY ""
	
	?? PADR(field->idRoba+""+TRIM(roba->naz)+" ("+roba->jmj+")", 37)
	
	// popisana kolicina    	
	?? SPACE(10)+REPLICATE("_", LEN(PicKol)-1)+SPACE(2)
	
	// VP cijena
	?? TRANSFORM(field->cijena, PicCDem)
    	skip
enddo

DokNovaStrana(125,@nStr,4)

? cLin

PrnClanoviKomisije()

END PRINT

SELECT pripr
GO nRecNo

return
*}

/*! \fn ZInvp(cLinija)
 *  \brief Zaglavlje izvjestaja inventura
 *  \param cUlaz - Proslijedjuje se linija koja se ispise iznad i ispod zaglavlja 
 */
 
function ZInvp(cLinija)
*{
P_10CPI
?? "OBRAZAC POPISA INVENTURE :"
P_COND2
?
? "DOKUMENT BR. :", cIdFirma+"-"+cIdTipDok+"-"+cBrDok, SPACE(2), "Datum:", DatDok
?
DokNovaStrana(125,@nStr,-1)

? cLinija
? "*R * ROBA                                        *  Popisana  *   Cijena   *"
? "*BR*                                             *  Kolicina  *     VP     *"
? cLinija

return
*}

