#include "sc.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/svi/rpt_all.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.6 $
 * $Log: rpt_all.prg,v $
 * Revision 1.6  2003/11/11 14:06:46  sasavranic
 * Uvodjenje f-je IspisNaDan()
 *
 * Revision 1.5  2003/01/19 23:44:18  ernad
 * test network speed (sa), korekcija bl.lnk
 *
 * Revision 1.4  2002/07/01 12:25:23  sasa
 * ispravka parametra u f-ji DokNovaStrana:
 * stari:  nSlijediRedova
 * novi: nSlijediRedovaZajedno
 *
 * Revision 1.3  2002/06/29 16:53:01  ernad
 *
 *
 * uvodjenje parametra -1, DokNovaStrana
 *
 * Revision 1.2  2002/06/28 08:40:10  ernad
 *
 *
 * Dokument inventure - primjer implementacije cl-sc build sistema
 *
 * Revision 1.1  2002/06/28 07:04:15  ernad
 *
 *
 * uveden rpt_all.prg : dijeljene report funkcije za izvjestaje
 *
 *
 */
 

/*! \fn DokNovaStrana(nColumn, nStr, nSlijediRedovaZajedno)
 *  \brief Prelazak na novu stranicu
 *  \param nColumn - kolona na kojoj se stampa "Str: XXX"
 *  \param nStr  - stranica
 *  \param nSlijediRedovaZajedno - koliko nakon ove funkcije redova zelimo odstampati, nakon preloma se treba zajedno odstmpati "nSlijediRedova"; za vrijednost -1 stampa bez obzira na trenutnu poziciju (koristiti za stampu na prvoj strani) 
 */
 
function DokNovaStrana(nColumn, nStr, nSlijediRedovaZajedno)
*{

if (nSlijediRedovaZajedno==nil)
	nSlijediRedovaZajedno:=1
endif

if (nSlijediRedovaZajedno==-1) .or. (PROW()>(62+gPStranica-nSlijediRedovaZajedno))
	
	if (nSlijediRedovaZajedno<>-1)
		FF
	endif
	
	@ prow(), nColumn SAY "Str:"+str(++nStr,3)
endif

return
*}


function NovaStrana(bZagl, nOdstampatiStrana)
*{

if (nOdstampatiStrana==nil)
	nOdstampatiStrana:=1
endif

if PROW()>(62+gPStranica-nOdstampatiStrana)
	FF
	if (bZagl<>nil)
		EVAL(bZagl)
	endif
endif
return

*}

function PrnClanoviKomisije()
*{

?
P_10CPI
? PADL("Clanovi komisije: 1. ___________________",75)
? PADL("2. ___________________",75)
? PADL("3. ___________________",75)
?

return
*}



/*! \fn FSvaki2()
 *  \brief
 */
 
function FSvaki2()
*{
RETURN
*}

 
/*! \fn IspisFirme(cIdRj)
 *  \brief Ispisuje naziv fime
 *  \param cIdRj  - Oznaka radne jedinice
 */
 
function IspisFirme(cIdRj)
*{
local nOArr:=select()

?? "Firma: "
B_ON
	?? gNFirma
B_OFF
if !empty(cidrj)
	select rj
	hseek cidrj
	select(nOArr)
	?? "  RJ",rj->naz
endif

return
*}

function IspisNaDan(nEmptySpace)
*{
?? REPLICATE(" ",nEmptySpace) + " Na dan: " + DToC(DATE())
return
*}

