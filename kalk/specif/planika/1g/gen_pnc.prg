
#include "\cl\sigma\fmk\kalk\kalk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/specif/planika/1g/gen_pnc.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.3 $
 * $Log: gen_pnc.prg,v $
 * Revision 1.3  2003/11/22 15:26:45  sasavranic
 * planika robno poslovanje, prodnc
 *
 * Revision 1.2  2003/11/20 16:17:52  ernadhusremovic
 * Planika Kranje Robno poslovanje / 2
 *
 * Revision 1.1  2003/11/10 07:00:30  ernadhusremovic
 * Planika kranj - Robno poslovanje
 *
 *
 *
 */

function GenProdNc()
local cPKonto
local cIdRoba

local nNc
local cBrDok
local cIdVd
local dDatDok


O_PRODNC
O_ROBA
O_KALK

// mora biti otvorena radi KalknabP funkcije
O_PRIPR

O_KONCIJ
go top

Box(,3,60)

// prodji kroz sve prodavnice
do while !eof()

	SELECT koncij
	if !EMPTY(koncij->IdProdMjes)
		cPKonto = koncij->Id
	else
		skip
		loop
	endif
	
	// prodji kroz sve artikle
	@ m_x+1, m_y+2 SAY "Prodavnica: " + cPKonto
	SELECT roba
	GO TOP
	do while !eof()
	
		cIdRoba := roba->id
		if IsRobaInProdavnica(cPKonto, cIdRoba)
			@ m_x+2, m_y+2 SAY "Roba " + cIdRoba
			nNc:=GetNcForProdavnica(cPKonto, cIdRoba)
			cBrDok:="00000000"
			cIdVd := "00"
			dDatDok := DATE()
			SetProdNc(cPKonto, cIdRoba, cIdVd, cBrDok, dDatDok, nNc )
		else
			@ m_x+2, m_y+2 SAY "!Roba " + cIdRoba
		endif
		
		select roba
		skip
	enddo
			
	select koncij
	skip
enddo

BoxC()
return

/*
 * *******************************
 */
function IsRobaInProdavnica(cPKonto, cIdRoba)
*{

//  "4","idFirma+Pkonto+idroba+dtos(datdok)+podbr+PU_I+IdVD",KUMPATH+"KALK")
SELECT kalk
SET ORDER TO TAG "4"
SEEK gFirma + cPKonto + cIdRoba

if found()
	return .t.
else
	return .f.
endif

*}


/*
 * *******************************
 */
function GetNcForProdavnica(cPKonto, cIdRoba)
*{
local nKolS
local nKolZn
local nNc1
local nSredNc
local dDatNab
local dRokTr

private _DatDok 

SELECT (F_PRIPR)
if !used()
	O_PRIPR
endif

_DatDok = DATE()
KalkNabP( gFirma, cIdRoba, cPKonto, @nKolS, @nKolZN, @nNc1, @nSredNc, @dDatNab, @dRokTr)

return nSredNc
*}


/*
 * *******************************
 */
 
function SetProdNc(cPKonto, cIdRoba, cIdVd, cBrDok, dDatDok, nNc )
*{
local nArr
nArr:=SELECT()

SELECT (F_PRODNC)
if !used()
	O_PRODNC
endif

seek cPKonto + cIdRoba

if !found()
	APPEND BLANK
	replace PKonto with cPKonto
	replace IdRoba with cIdRoba
endif

replace IdVd with cIdVd
replace BrDok with cBrDok
replace DatDok with dDatDok
replace Nc with nNc

select (nArr)
return
*}



function SetIdPartnerRoba()
*{
local cPKonto
local cIdRoba

local nNc
local cBrDok
local cIdVd
local dDatDok


O_ROBA
O_PARTN
go top

Box(,3,60)


for i = 1 to 7

	if (i==1)
		cGodina = ""
	elseif (i==2)
		cGodina = "2002"
	elseif (i==3)
		cGodina = "2001"
	elseif (i==4)
		cGodina = "2000"
	elseif (i==5)
		cGodina = "1999"
	elseif (i==6)
		cGodina = "1998"
	elseif (i==7)
		cGodina = "1997"
	endif


	SELECT (F_KALK)
	use  (KUMPATH+cGodina+"\kalk") 
	set order to tag "1"

	
	@ m_x+1, m_y+2 SAY iif(cGodina=="", "2003", cGodina)
	
	SEEK gFirma + "10"
	do while !eof() .and. (IdVd == "10")

		@ m_x+2, m_y+2 SAY kalk->IdRoba
		
		SELECT ROBA
		cIdPartner = kalk->IdPartner
		SEEK kalk->IdRoba
		if found()
			if Empty(IdPartner)
				replace IdPartner with cIdPartner
			endif
		endif

		SELECT KALK
		skip
	enddo

	select kalk
	USE

next

BoxC()
return

