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


#include "sc.ch"

 

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

function IspisNaDan(nEmptySpace)
*{
?? REPLICATE(" ",nEmptySpace) + " Na dan: " + DToC(DATE())
return
*}

