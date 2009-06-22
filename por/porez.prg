#include "ld.ch"


// -----------------------------------------------
// vraca tip algoritma iz sifrarnika poreza
// -----------------------------------------------
function get_algoritam()
local xRet := ""
local nTArea := SELECT()

select por

if por->(FIELDPOS("ALGORITAM")) <> 0
	xRet := field->algoritam
endif

select (nTArea)
return xRet


// -----------------------------------------------
// vraca prirodu obracuna poreza
// -----------------------------------------------
function get_pr_obracuna()
local xRet := " "
local nTArea := SELECT()

select por

if por->(FIELDPOS("POR_TIP")) <> 0
	xRet := field->por_tip
endif

select (nTArea)
return xRet


// -------------------------------------------
// obracun poreza
// cId - porez id
// nOsnNeto - osnovica neto
// nOsnOstalo - osnovica ostala primanja
// -------------------------------------------
function obr_por( cId, nOsnNeto, nOsnOstalo )
local aPor := {}
local aPorTek := {}
local cAlg := ""
local cPrObr := ""
local nPorTot := 0
local nIznos := 0
local i

// uzmi koji je algoritam
cAlg := get_algoritam()
cPrObr := get_pr_obracuna()

if cPrObr == "N" .or. cPrObr == " " .or. cPrObr == "B" 

	// osnovica je neto
	nIznos := nOsnNeto

elseif cPrObr == "2"
	
	// osnovica je ostala primanja
	nIznos := nOsnOstalo 
	
elseif cPrObr == "P"
	
	// osnovica je neto + ostala primanja
	nIznos := nOsnNeto + nOsnOstalo
	
endif

select por
 
if cAlg == "S"

	// stepenasti obracun
	aPortek := _get_portek( 2 )
	aPor := obr_por_st( aPorTek, nIznos )	
	
else
	// standardni obracun
	aPorTek := _get_portek( 1 )
	aPor := obr_por_os( aPorTek, nIznos )
	
endif

return aPor

// ---------------------------------------------
// ispis poreza
// lWOpis - bez opisa id, naz
// ---------------------------------------------
function isp_por( aPor, cPorType, cMargina, lIspis, lWOpis )
local nRet := 0

if lIspis == nil
	lIspis := .t.
endif

if lWOpis == nil
	lWOpis := .f.
endif

if cPorType == "S"
	nRet := isp_por_st( aPor, cMargina, lIspis )
else
	nRet := isp_por_os( aPor, cMargina, lIspis, lWOpis )
endif

return nRet

// -----------------------------------------
// ispis poreza, osnovni obracun
// -----------------------------------------
static function isp_por_os( aPor, cMargina, lIspis, lWOpis )
local nTotal := 0
local i := 1

if lIspis == .t.
	
	? cMargina

	if lWOpis == .f.
		?? aPor[i, 1], "-", aPor[i, 2]
		@ prow(),pcol()+1 SAY aPor[i, 3] pict "99.99%"
		nC1 := pcol() + 1
		@ prow(),pcol()+1 SAY aPor[i, 5] pict gPici
		@ prow(),pcol()+1 SAY aPor[i, 4] pict gPici
	else
		cTmp := aPor[i, 2] + " " + ;
			ALLTRIM(STR(aPor[i, 5])) + ;
			" * " + ALLTRIM(STR(aPor[i, 3], 2)) + "%"
 		@ prow(),pcol()+1 SAY SPACE(10) + cTmp
	endif
endif

nTotal += aPor[i, 4]

if nTotal < 0
	nTotal := 0
endif

return nTotal


// ------------------------------------
// ispis poreza, stepenasti obracun
// ------------------------------------
static function isp_por_st( aPor, cMargina, lIspis )
local i
local nTotal := 0
local cPom := ""

if LEN(aPor) == 0
	return 0
endif

if lIspis == .t.
	
	? cMargina + aPor[1, 1] + " - " + aPor[1, 2]
	?? "( Obracun stepen.poreza )"
	? cMargina + REPLICATE("-", 60)

endif

for i:=1 to LEN( aPor )
	
	if lIspis == .t.
		
		nRazlika := aPor[i, 3] - aPor[i, 4]
	
		? cMargina + "("
	
		@ prow(), pcol()+1 SAY aPor[i, 3] pict "9999.99"
		@ prow(), pcol()+1 SAY " - "
		@ prow(), pcol()+1 SAY aPor[i, 4] pict "9999.99"
		@ prow(), pcol()+1 SAY ") = "
		@ prow(), pcol()+1 SAY nRazlika pict "9999.99"
		@ prow(), pcol()+1 SAY " * "
		@ prow(), pcol()+1 SAY aPor[i, 5] pict "99.99%"
		@ prow(), pcol()+1 SAY " ="
		@ prow(), pcol()+1 SAY aPor[i, 6] pict gPici
	endif
	
	nTotal += aPor[i, 6]

next


if lIspis == .t. .and. ROUND(nTotal, 2) <> 0

	? cMargina + REPLICATE("-", 60)
	cPom := "Ukupno poreske obaveze:"
	? cMargina + cPom
	
	@ prow(), pcol() + (60 - LEN(cPom) - LEN(gPici)) SAY nTotal PICT gPici
	? cMargina + REPLICATE("-", 60)
	
endif

return nTotal



// ---------------------------------------------------
// obracun standardni poreza
// ---------------------------------------------------
static function obr_por_os( aPorTek, nIznos )
local aPor := {}
local nPorIznos := 0
local nDLimit := 0
local nPor := 0
local i:=1

nDLimit := aPorTek[i, 4]
nPor := aPorTek[i, 3]
nOsnovica := MAX( nIznos, PAROBR->prosld * gPDLimit/100 ) 
nPorIznos := MAX( nDLimit, ROUND( nPor/100 * MAX( nIznos, PAROBR->PROSLD * gPDLIMIT / 100), gZaok2))

AADD(aPor, { aPorTek[i, 1], aPorTek[i, 2], ;
	nPor, nPorIznos, nOsnovica })		

return aPor



// ------------------------------------------------
// obracunaj porez stepenasti
// aPorTek - matrica sa poreznim stopama i limitima
// nIznos - obracunska osnovica
// ------------------------------------------------
static function obr_por_st( aPorTek, nIznos )
local aPor := {}
local i
local nDLimit := 0
local nGLimit := 0
local nStopa := 0
local nPom

for i := 1 to LEN(aPorTek)

	nDLimit := aPorTek[i, 4]
	nGLimit := aPorTek[i, 5]
	
	nStopa := aPorTek[i, 3]

	cPorSifra := aPorTek[i, 1]
	cPorNaz := aPorTek[i, 2]

	if i == 1
		if nIznos < nDLimit
			EXIT
		endif
	endif

	if ( nIznos > nDLimit .and. nIznos < nGLimit )
		
		nPom := nIznos - nDLimit
		nPorIznos := nPom * ( nStopa / 100 )
		
		AADD(aPor, { cPorSifra, cPorNaz, ;
			nIznos, nDLimit, nStopa, nPorIznos })
		
		EXIT
		
	else
		nPom := nGLimit - nDLimit
		nPorIznos := nPom * ( nStopa / 100 )

		AADD(aPor, { cPorSifra, cPorNaz, ;
			nGLimit, nDLimit, nStopa, nPorIznos })
		
	endif
	
next

return aPor



// -------------------------------------------
// vraca matricu sa porezima i stopama
//
// aPor := { nStopa, nLimitMin, nLimitMax }
// nvar - varijanta 1 - standardna 
//        varijanta 2 - stepenasti
// -------------------------------------------
static function _get_portek( nVar )
local aPor := {}
local i
local nStopa
local nLimit
local nLimitPr
local cPom

if nVar == 2
    for i:=1 to 5
	
	cPom := "S_STO_" + ALLTRIM(STR(i))
	nStopa := &cPom

	cPom := "S_IZN_" + ALLTRIM(STR(i))
	nLimit := &cPom
	
	if nStopa <> 0
		
		// prethodna stopa
		cPom := "S_IZN_" + ALLTRIM(STR(i-1))
		nLimitPr := &cPom
		
		AADD(aPor, { por->id, por->naz, nStopa, nLimitPr, nLimit })
	endif
	
    next

else
	
	nStopa := field->iznos 
	AADD(aPor, { por->id, por->naz, nStopa, por->dlimit })
	
endif

return aPor


