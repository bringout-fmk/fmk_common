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

/*! \fn GenPartnSt(lGenPartnSt, nSldMinIzn, cPosId)
 *  \brief Postavljanje upita za generisanje stanja partnera te setovanje varijabli
 *  \param lGenPartnSt - da li se koristi ovaj feature
 *  \param nMinIznos - minimalan iznos 
 *  \param cPosId - id oznaka pos-a
 */
function GenPartnSt(lGenPartnSt, nSldMinIzn, cPosId)
*{
local GetList:={}
local cModName:=""
local cDN:="D"

if cPosId == nil
	cPosId := ""
else
	cPosId := "1 "
endif

lGenPartnSt:=.f.
nSldMinIzn:=5
cModName:=goModul:oDataBase:cName

if Pitanje(,"Generisati stanje partnera za HH", "N")=="N"
	return
endif

Box(, 6, 60)
	@ 1+m_x, 2+m_y SAY "Prenos stanja partnera: " + cModName + SPACE(10)
	@ 2+m_x, 2+m_y SAY "--------------------------------"
	@ 3+m_x, 2+m_y SAY "Ne prenosi partnere sa saldom < od:" GET nSldMinIzn PICT "999.99"
	// ako je proslijedjen i ovaj parametar onda se radi o topsu
	if cModName <> "POS"
		@ 4+m_x, 2+m_y SAY "Prodajno mjesto TOPS: " GET cPosId
	endif
	
	@ 6+m_x, 2+m_y SAY "Prenjeti stanje partnera (D/N)?" GET cDN PICT "@!" VALID cDN$"DN"
	read
BoxC()
if cDN=="D"
	lGenPartnSt:=.t.
	CrePstDB(cModName)
endif

return
*}


/*! \fn AzurTopsOstav(nId, cIdFmk, cNaziv, nIznosG, nSldMinIzn)
 *  \brief Poziva funkciju AddToOstav() i odredjuje da li je nIznosG manji od nSldMinIzn 
 */
function AzurTopsOstav(nId, cIdFmk, cNaziv, nIznosG, nSldMinIzn)
*{
if nIznosG < nSldMinIzn
	return
endif
O_PrenHH()
AddToPartn(nId, cIdFmk, cNaziv)
AddToOstav(nId, nIznosG)
return
*}


/*! \fn AzurTopsParams(cId, cNaziv, cOpis)
 *  \brief Poziva f-ju AddToParams()
 */
function AzurTopsParams(cId, cNaziv, cOpis)
*{
O_PrenHH()
AddToParams(cId, cNaziv, cOpis)
return
*}


/*! \fn AzurFinOstav(cPosId, cIdFmk, nIznos1, nIznos2, nIznos3, nIznos4, nSldMinIzn)
 *  \brief Poziva f-ju AddFinIntervalsToOstav() 
 */
function AzurFinOstav(cPosId, cIdFmk, cParNaz, nIznos1, nIznos2, nIznos3, nIznos4, nIznos5, nSldMinIzn)
*{
local nArr
nArr:=SELECT()
if nIznos1+nIznos2+nIznos3+nIznos4+nIznos5 < nSldMinIzn
	return
endif
O_PrenHH(cPosId)
AddFinIntervalsToOstav(cIdFmk, cParNaz, nIznos1, nIznos2, nIznos3, nIznos4, nIznos5)
select (nArr)
return
*}


/*! \fn AddPAzToParams(dDate)
 *  \brief Poziva f-ju AddToParams() i dodjeljuje joj parametre PAZ
 *  \param dDate - datum azuriranja
 */
function AddPAzToParams(dDate)
*{
AzurTopsParams("PAZ", "Posljednje azuriranje", DToS(dDate))
return
*}


/*! \fn AddSCnToParams(lSilent)
 *  \brief Poziva f-ju AddToParams() i dodjeljuje joj parametre SCN
 *  \param lSilent - .t. - tihi mod, .f. - prijavi MSG o prenesenim parametrima
 */
function AddSCnToParams(lSilent)
*{
if lSilent == nil
	lSilent := .t.
endif
nOstav:=GetOstavCnt()
AzurTopsParams("SCN", "Broj prenesenih otv.stavki", ALLTRIM(STR(nOstav)))
if !lSilent
	MsgBeep("Preneseno " + ALLTRIM(STR(nOstav)) + " otvorenih stavki!")
endif
return
*}


/*! \fn AddPCnToParams(lSilent)
 *  \brief Poziva f-ju AddToParams() i dodjeljuje joj parametre PCN
 *  \param lSilent - .t. - tihi mod, .f. - prijavi MSG o prenesenim parametrima
 */
function AddPCnToParams(lSilent)
*{
if lSilent == nil
	lSilent := .t.
endif
nPartners:=GetPartnCnt()
AzurTopsParams("PCN", "Broj prenesenih partnera", ALLTRIM(STR(nPartners)))
if !lSilent
	MsgBeep("Preneseno " + ALLTRIM(STR(nPartners)) + " partnera!")
endif
return
*}



/*! \fn Rpt_Ostav()
 *  \brief Stampa kontrolnog izvjestaja
 */
function Rpt_Ostav()
*{
O_PrenHH()
START PRINT CRET

select params
go top
cLastAzur := DToC(SToD(params->opis))
skip
cPartnCnt := ALLTRIM(params->opis)

? "Pregled generisanih podataka za HH"
?
? "Broj prenesenih partnera: " + cPartnCnt
? "Datum zadnjeg azuriranja: " + cLastAzur
?
? REPLICATE("-", 100)
? "Rbr. Partner                       Stanje      Stanje      Stanje      Stanje      Stanje      Stanje"
? "                                   POS        do 4 d.     do 8 d.     do 16 d.    do 20 d.     pr.20 d."
? REPLICATE("-", 100)

select ostav
set order to tag "ID"
go top

i:=0
nUkPos:=0
nUkFin4:=0
nUkFin8:=0
nUkFin16:=0
nUkFin20:=0
nUkFin21:=0

do while !EOF()
	select partn
	set order to tag "ID"
	hseek ostav->id
	select ostav
	? STR(++i, 3) + ". "
	?? PADR(partn->oznaka, 6) + "(" + PADR(partn->id, 3) + ")" +  PADR(ALLTRIM(partn->naziv), 10) + "..."
	?? STR(ostav->iznosg, 12, 2)
	?? STR(ostav->iznosz1, 12, 2)
	?? STR(ostav->iznosz2, 12, 2)
	?? STR(ostav->iznosz3, 12, 2)
	?? STR(ostav->iznosz4, 12, 2)
	?? STR(ostav->iznosz5, 12, 2)
	// calculate total
	nUkPos += ostav->iznosg
	nUkFin4 += ostav->iznosz1
	nUkFin8 += ostav->iznosz2
	nUkFin16 += ostav->iznosz3
	nUkFin20 += ostav->iznosz4
	nUkFin21 += ostav->iznosz5
	skip
enddo
// write total
? Replicate("-", 100)
? PADR("UKUPNO", 29)
?? STR(nUkPos, 12, 2)
?? STR(nUkFin4, 12, 2)
?? STR(nUkFin8, 12, 2)
?? STR(nUkFin16, 12, 2)
?? STR(nUkFin20, 12, 2)
?? STR(nUkFin21, 12, 2)
? Replicate("-", 100)

FF
END PRINT

return
*}




