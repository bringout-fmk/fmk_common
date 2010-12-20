#include "sc.ch"


// pos komande
static F_POS_RN := "POS_RN"

// --------------------------------------------------------
// fiskalni racun pos (FPRINT)
// cFPath - putanja do fajla
// cFName - naziv fajla
// aData - podaci racuna
// lStorno - da li se stampa storno ili ne (.T. ili .F. )
// --------------------------------------------------------
function fp_pos_rn( cFPath, cFName, aData, lStorno, cError )
local cSep := ";"
local aPosData := {}
local aStruct := {}
local nErr := 0

if lStorno == nil
	lStorno := .f.
endif

if cError == nil
	cError := "N"
endif

// naziv fajla
cFName := f_filepos( aData[ 1, 1] )

// uzmi strukturu tabele za pos racun
aStruct := _g_f_struct( F_POS_RN )

// iscitaj pos matricu
aPosData := _fp_pos_rn( aData, lStorno )

_a_to_file( cFPath, cFName, aStruct, aPosData )

return nErr



// -----------------------------------------------------
// fiskalno upisivanje robe (FPRINT)
// cFPath - putanja do fajla
// aData - podaci racuna
// -----------------------------------------------------
function fp_pos_art( cFPath, cFName, aData )
local cSep := ";"
local aPosData := {}
local aStruct := {}

// uzmi strukturu tabele za pos racun
aStruct := _g_f_struct( F_POS_RN )

// iscitaj pos matricu
aPosData := _fp_p_art( aData )

_a_to_file( cFPath, cFName, aStruct, aPosData )

return


// ------------------------------------------------------
// vraca popunjenu matricu za upis artikla u memoriju
// (FPRINT)
// ------------------------------------------------------
static function _fp_p_art( aData )
local aArr := {}
local cTmp := ""
local cLogic
local cLogSep := ","
local cSep := ";"
local i
local cOption := "<2>"

// ocekivana struktura
// aData = { idroba, nazroba, cijena, kolicina, porstopa, plu }

cLogic := "1"

for i := 1 to LEN( aData )
	
	cTmp := "107"
	cTmp += cLogSep
	cTmp += cLogic
	cTmp += cLogSep
	cTmp += REPLICATE("_", 6) 
	cTmp += cLogSep
	cTmp += REPLICATE("_", 1) 
	cTmp += cLogSep
	cTmp += REPLICATE("_", 2)
	cTmp += cSep
	
	cTmp += cOption
	cTmp += cSep

	// poreska grupa artikala 1 - 5
	cTmp += _g_tar( aData[i, 5] )
	cTmp += cSep
	
	// kod PLU
	cTmp += ALLTRIM( aData[i, 1] )
	cTmp += cSep
	
	// cjena 0-99999.99
	cTmp += ALLTRIM(STR( aData[i, 3], 12, 2 ))
	cTmp += cSep

	// naziv artikla
	cTmp += PADR( ALLTRIM(aData[i, 2]), 32 )
	cTmp += cSep

	AADD( aArr, { cTmp } )

next

return aArr



// ------------------------------------------
// vraca tarifu
// ------------------------------------------
static function _g_tar( cStopa )
local xRet := ""

do case
	case ALLTRIM( cStopa ) == "PDV17"
		xRet := "2"
endcase

return xRet


// ----------------------------------------
// vraca popunjenu matricu za ispis raèuna
// FPRINT driver
// ----------------------------------------
static function _fp_pos_rn( aData, lStorno )
local aArr := {}
local cTmp := ""
local cLogic
local cLogSep := ","
local cSep := ";"
local i
local cRek_rn := ""
local cRnBroj
local cOperator := "1"
local cOp_pwd := "000000"

// ocekuje se matrica formata
// aData { brrn, rbr, idroba, nazroba, cijena, kolicina, porstopa, 
//         rek_rn, plu, popust }

// broj racuna
cRnBroj := ALLTRIM( aData[1,1] )

// logic je uvijek "1"
cLogic := "1"

// 1) otvaranje fiskalnog racuna

cTmp := "48"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep
cTmp += ALLTRIM( gIOSA )
cTmp += cSep
cTmp += cOperator
cTmp += cSep
cTmp += cOp_pwd
cTmp += cSep

if lStorno == .t.
	cRek_rn := ALLTRIM( aData[ 1, 8 ] )
	cTmp += cRek_rn
	cTmp += cSep
else
	cTmp += cSep
endif

// dodaj ovu stavku u matricu...
AADD( aArr, { cTmp } )

// 2. prodaja stavki

for i := 1 to LEN( aData )

	cTmp := "52"
	cTmp += cLogSep
	cTmp += cLogic
	cTmp += cLogSep
	cTmp += REPLICATE("_", 6) 
	cTmp += cLogSep
	cTmp += REPLICATE("_", 1) 
	cTmp += cLogSep
	cTmp += REPLICATE("_", 2)
	cTmp += cSep
	
	// kod PLU
	cTmp += ALLTRIM( STR( aData[i, 9] ) )
	cTmp += cSep
	
	// kolicina 0-99999.99
	cTmp += ALLTRIM(STR( aData[i, 6], 12, 2 ))
	cTmp += cSep

	// popust 0-99.99%
	if aData[i, 10] > 0
		cTmp += ALLTRIM(STR( aData[i, 10], 10, 2 ))
	endif
	cTmp += cSep

	// dodaj u matricu prodaju...
	AADD( aArr, { cTmp } )

next

// 3. subtotal

cTmp := "51"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep

AADD( aArr, { cTmp } )


// 4. nacin placanja
cTmp := "53"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep
cTmp += cSep
cTmp += cSep

AADD( aArr, { cTmp } )


// 5. zatvaranje racuna
cTmp := "56"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep

AADD( aArr, { cTmp } )


return aArr

