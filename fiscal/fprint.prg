#include "sc.ch"


// pos komande
static F_POS_RN := "POS_RN"

// ocekivana matrica
// aData
//
// 1 - broj racuna
// 2 - redni broj
// 3 - id roba
// 4 - roba naziv
// 5 - cijena
// 6 - kolicina
// 7 - tarifa
// 8 - broj racuna za storniranje
// 9 - roba plu
// 10 - plu cijena
// 11 - popust
// 12 - barkod
// 13 - vrsta placanja
// 14 - total racuna


// --------------------------------------------------------
// fiskalni racun pos (FPRINT)
// cFPath - putanja do fajla
// cFName - naziv fajla
// aData - podaci racuna
// lStorno - da li se stampa storno ili ne (.T. ili .F. )
// --------------------------------------------------------
function fp_pos_rn( cFPath, cFName, aData, aKupac, lStorno, cError )
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
cFName := fp_filename( aData[ 1, 1] )

// uzmi strukturu tabele za pos racun
aStruct := _g_f_struct( F_POS_RN )

// iscitaj pos matricu
aPosData := _fp_pos_rn( aData, aKupac, lStorno )

_a_to_file( cFPath, cFName, aStruct, aPosData )

return nErr

// ----------------------------------------------------
// fprint: unos pologa u printer
// ----------------------------------------------------
function fp_polog( cFPath, cFName )
local cSep := ";"
local aPolog := {}
local aStruct := {}
local nPolog := 0

Box(,1,60)
	@ m_x + 1, m_y + 2 SAY "Zaduzujem kasu za:" GET nPolog ;
		PICT "999999.99"
	read
BoxC()

if nPolog = 0
	msgbeep("Polog mora biti <> 0 !")
	return
endif

if LastKey() == K_ESC
	return
endif

// naziv fajla
cFName := fp_filename( "0" )

// uzmi strukturu tabele za pos racun
aStruct := _g_f_struct( F_POS_RN )

// iscitaj pos matricu
aPolog := _fp_polog( nPolog )

_a_to_file( cFPath, cFName, aStruct, aPolog )

return



// ----------------------------------------------------
// fprint: dupliciranje racuna
// ----------------------------------------------------
function fp_double( cFPath, cFName )
local cSep := ";"
local aDouble := {}
local aStruct := {}
local dD_from := DATE()
local dD_to := dD_from
local cT_from := TIME()
local cT_to := cT_from
local cType := "F"

cT_from := STRTRAN( cT_from, ":", "" )
cT_to := STRTRAN( cT_to, ":", "" )

Box(,10,60)
	
	@ m_x + 1, m_y + 2 SAY "Za datum od:" GET dD_from 
	@ m_x + 1, col() + 1 SAY "vrijeme od (hhmmss):" GET cT_from
	
	@ m_x + 2, m_y + 2 SAY "         do:" GET dD_to
	@ m_x + 2, col() + 1 SAY "vrijeme do (hhmmss):" GET cT_to

	@ m_x + 3, m_y + 2 SAY "--------------------------------------"

	@ m_x + 4, m_y + 2 SAY "A - duplikat svih dokumenata"
	@ m_x + 5, m_y + 2 SAY "F - duplikat fiskalnog racuna"
	@ m_x + 6, m_y + 2 SAY "R - duplikat reklamnog racuna"
	@ m_x + 7, m_y + 2 SAY "Z - duplikat Z izvjestaja"
	@ m_x + 8, m_y + 2 SAY "X - duplikat X izvjestaja"
	@ m_x + 9, m_y + 2 SAY "P - duplikat periodicnog izvjestaja" ;
		GET cType ;
		VALID cType $ "AFRZXP" PICT "@!"

	read
BoxC()

if LastKey() == K_ESC
	return
endif

// naziv fajla
cFName := fp_filename( "0" )

// uzmi strukturu tabele za pos racun
aStruct := _g_f_struct( F_POS_RN )

// iscitaj pos matricu
aDouble := _fp_double( cType, dD_from, dD_to, cT_from, cT_to )

_a_to_file( cFPath, cFName, aStruct, aDouble )

return



// ----------------------------------------------------
// zatvori nasilno racun sa 0.0 KM iznosom
// ----------------------------------------------------
function fp_void( cFPath, cFName )
local cSep := ";"
local aVoid := {}
local aStruct := {}

// naziv fajla
cFName := fp_filename( "0" )

// uzmi strukturu tabele za pos racun
aStruct := _g_f_struct( F_POS_RN )

// iscitaj pos matricu
aVoid := _fp_void_rn()

_a_to_file( cFPath, cFName, aStruct, aVoid )

return


// ----------------------------------------------------
// zatvori racun
// ----------------------------------------------------
function fp_close( cFPath, cFName )
local cSep := ";"
local aClose := {}
local aStruct := {}

// naziv fajla
cFName := fp_filename( "0" )

// uzmi strukturu tabele za pos racun
aStruct := _g_f_struct( F_POS_RN )

// iscitaj pos matricu
aClose := _fp_close_rn()

_a_to_file( cFPath, cFName, aStruct, aClose )

return


// ----------------------------------------------------
// manualno zadavanje komandi
// ----------------------------------------------------
function fp_man_cmd( cFPath, cFName )
local cSep := ";"
local aManCmd := {}
local aStruct := {}
local nCmd := 0
local cCond := SPACE(150)
local cErr := "N"
local nErr := 0
private GetList:={}

Box(,4, 65)
	
	@ m_x+1, m_y+2 SAY "**** manuelno zadavanje komandi ****" 
	
	@ m_x+2, m_y+2 SAY "   broj komande:" GET nCmd PICT "999" ;
		VALID nCmd > 0
	@ m_x+3, m_y+2 SAY "        komanda:" GET cCond PICT "@S40"
	
	@ m_x+4, m_y+2 SAY "provjera greske:" GET cErr PICT "@!" ;
		VALID cErr $ "DN"
	read
BoxC()

if LastKey() == K_ESC
	return
endif

// naziv fajla
cFName := fp_filename( "0" )

// uzmi strukturu tabele za pos racun
aStruct := _g_f_struct( F_POS_RN )

// iscitaj pos matricu
aManCmd := _fp_man_cmd( nCmd, cCond )

_a_to_file( cFPath, cFName, aStruct, aManCmd )

if cErr == "D"
	
	// provjeri gresku
	nErr := fp_r_error( cFPath, gFC_tout, 0 )

	if nErr <> 0
		msgbeep("Postoji greska !!!")
	endif

endif

return



// ----------------------------------------------------
// dnevni fiskalni izvjestaj
// ----------------------------------------------------
function fp_daily_rpt( cFPath, cFName )
local cSep := ";"
local aDaily := {}
local aStruct := {}
local nErr := 0

// naziv fajla
cFName := fp_filename( "0" )

// uzmi strukturu tabele za pos racun
aStruct := _g_f_struct( F_POS_RN )

// iscitaj pos matricu
aDaily := _fp_daily_rpt()

_a_to_file( cFPath, cFName, aStruct, aDaily )

// procitaj error
nErr := fp_r_error( cFPath, gFC_tout, 0 )

if nErr <> 0
	msgbeep("Postoji greska !!!")
endif

return


// ----------------------------------------------------
// fiskalni izvjestaj za period
// ----------------------------------------------------
function fp_per_rpt( cFPath, cFName  )
local cSep := ";"
local aPer := {}
local aStruct := {}
local nErr := 0
local dD_from := DATE() - 30
local dD_to := DATE()
private GetList:={}

Box(,1,50)
	@ m_x + 1, m_y + 2 SAY "Za period od" GET dD_from 
	@ m_x + 1, col() + 1 SAY "do" GET dD_to
	read
BoxC()

if LastKey() == K_ESC
	return
endif

// naziv fajla
cFName := fp_filename( "0" )

// uzmi strukturu tabele za pos racun
aStruct := _g_f_struct( F_POS_RN )

// iscitaj pos matricu
aPer := _fp_per_rpt( dD_from, dD_to )

_a_to_file( cFPath, cFName, aStruct, aPer )

// procitaj error
nErr := fp_r_error( cFPath, gFC_tout, 0 )

if nErr <> 0
	msgbeep("Postoji greska !!!")
endif

return




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
local cOption := "2"

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
static function _fp_pos_rn( aData, aKupac, lStorno )
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
local nTotal := 0
local cVr_placanja := "0"

cVr_placanja := ALLTRIM( aData[1, 13] )
nTotal := aData[1, 14]

// ocekuje se matrica formata
// aData { brrn, rbr, idroba, nazroba, cijena, kolicina, porstopa, 
//         rek_rn, plu, plu_cijena, popust, barkod, vrsta plac, total racuna }

// prvo dodaj artikle za prodaju...
_a_fp_articles( @aArr, aData, lStorno )

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
	cTmp += cSep
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
		cTmp += "-" + ALLTRIM(STR( aData[i, 11], 10, 2 ))
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

// 0 - cash
// 1 - card
// 2 - chek
// 3 - virman

if cVr_placanja <> "0"
 	
	// imamo drugu vrstu placanja...
	cTmp += cVr_placanja
	cTmp += cSep
	cTmp += ALLTRIM( STR( nTotal, 12, 2 ) )
	cTmp += cSep

else

	cTmp += cSep
	cTmp += cSep

endif

AADD( aArr, { cTmp } )

// 5. kupac - podaci
if LEN( aKupac ) > 0

	// aKupac = { idbroj, naziv, adresa, ptt, mjesto }

	// postoje podaci...
	cTmp := "55"
	cTmp += cLogSep
	cTmp += cLogic
	cTmp += cLogSep
	cTmp += REPLICATE("_", 6) 
	cTmp += cLogSep
	cTmp += REPLICATE("_", 1) 
	cTmp += cLogSep
	cTmp += REPLICATE("_", 2)
	cTmp += cSep
	
	// id broj
	cTmp += ALLTRIM( aKupac[ 1, 1 ] )
	cTmp += cSep

	// naziv
	cTmp += ALLTRIM( aKupac[ 1, 2 ] )
	cTmp += cSep

	// adresa, ptt, mjesto
	cTmp += ALLTRIM( aKupac[ 1, 3 ] ) + ", " + ;
		ALLTRIM( aKupac[ 1, 4 ] ) + " " + ;
		ALLTRIM( aKupac[ 1, 5 ] )

	cTmp += cSep

	AADD( aArr, { cTmp } )

endif

// 6. otvaranje ladice
cTmp := "106"
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



// 7. zatvaranje racuna
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



// ---------------------------------------------------
// manualno zadavanje komandi
// ---------------------------------------------------
static function _fp_man_cmd( nCmd, cCond )
local cTmp := ""
local cLogic
local cLogSep := ","
local cSep := ";"
local aArr := {}

cLogic := "1"

// broj komande
cTmp := ALLTRIM(STR(nCmd))

// ostali regularni dio
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep

if !EMPTY( cCond )
	// ostatak komande
	cTmp += ALLTRIM(cCond)
endif

AADD( aArr, { cTmp } )

return aArr


// ---------------------------------------------------
// zatvori racun
// ---------------------------------------------------
static function _fp_close_rn()
local cTmp := ""
local cLogic
local cLogSep := ","
local cSep := ";"
local aArr := {}

cLogic := "1"

// 7. zatvaranje racuna
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

// --------------------------------------------------------
// vraca formatiran datum za opcije izvjestaja
// --------------------------------------------------------
static function _fix_date( dDate )
local cRet := ""
local nM := MONTH( dDate )
local nD := DAY( dDate )
local nY := YEAR( dDate )

// format datuma treba da bude DDMMYY
cRet := PADL( ALLTRIM(STR(nD)), 2, "0" )
cRet += PADL( ALLTRIM(STR(nM)), 2, "0" )
cRet += RIGHT( ALLTRIM(STR(nY)), 2 )

return cRet


// ---------------------------------------------------
// dnevni fiskalni izvjestaj
// ---------------------------------------------------
static function _fp_per_rpt( dD_from, dD_to )
local cTmp := ""
local cLogic
local cLogSep := ","
local cSep := ";"
local cD_from
local cD_to
local aArr := {}

// konvertuj datum
cD_from := _fix_date( dD_from )
cD_to := _fix_date( dD_to )

cLogic := "1"

cTmp := "79"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep
cTmp += cD_from
cTmp += cSep
cTmp += cD_to
cTmp += cSep
cTmp += cSep
cTmp += cSep
	
AADD( aArr, { cTmp } )

return aArr


// ---------------------------------------------------
// dnevni fiskalni izvjestaj
// ---------------------------------------------------
static function _fp_daily_rpt()
local cTmp := ""
local cLogic
local cLogSep := ","
local cSep := ";"
local aArr := {}

// 0 - "Z"
// 2 - "X"

local cType := "0"

// "N" - 
// "A" - 
local cOper := "N"

cLogic := "1"

cTmp := "69"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep
cTmp += cType
cTmp += cSep
cTmp += cOper
cTmp += cSep
	
AADD( aArr, { cTmp } )

return aArr




// ------------------------------------------------------------------
// dupliciranje dokumenta
// ------------------------------------------------------------------
static function _fp_double( cType, dD_from, dD_to, cT_from, cT_to )
local cTmp := ""
local cLogic
local cLogSep := ","
local cSep := ";"
local aArr := {}
local cStart := ""
local cEnd := ""

// sredi start i end linije
cStart := _fix_date(dD_from) + cT_from
cEnd := _fix_date(dD_to) + cT_to

cLogic := "1"

cTmp := "109"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep
cTmp += cType
cTmp += cSep
cTmp += cStart
cTmp += cSep
cTmp += cEnd
cTmp += cSep
	
AADD( aArr, { cTmp } )

return aArr

// ---------------------------------------------------
// unos pologa u printer
// ---------------------------------------------------
static function _fp_polog( nIznos )
local cTmp := ""
local cLogic
local cLogSep := ","
local cSep := ";"
local aArr := {}
local cZnak := "+"

if nIznos < 0
	cZnak := ""
endif

cLogic := "1"

cTmp := "70"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep
cTmp += cZnak + ALLTRIM(STR( nIznos ))
cTmp += cSep
	
AADD( aArr, { cTmp } )

return aArr


// ---------------------------------------------------
// zatvori nasilno racun sa 0.0 iznosom
// ---------------------------------------------------
static function _fp_void_rn()
local cTmp := ""
local cLogic
local cLogSep := ","
local cSep := ";"
local aArr := {}

cLogic := "1"

cTmp := "301"
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


// ----------------------------------------------------
// dodaj artikle za racun
// ----------------------------------------------------
static function _a_fp_articles( aArr, aData, lStorno )
local i
local cTmp := ""
// opcija dodavanja artikla u printer <1|2> 
// 1 - dodaj samo jednom
// 2 - mozemo dodavati vise puta
local cOp_add := "2"
// opcija promjene cijene u printeru
local cOp_ch := "4"
local cLogic
local cLogSep := ","
local cSep := ";"

// ocekuje se matrica formata
// aData { brrn, rbr, idroba, nazroba, cijena, kolicina, porstopa, 
//         rek_rn, plu, plu_cijena, popust }

cLogic := "1"

if lStorno == .t.
	return
endif

for i:=1 to LEN( aData )
	
	// 1. dodavanje artikla u printer
	
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
	
	// opcija dodavanja "2"
	cTmp += cOp_add
	cTmp += cSep
	
	// poreska stopa
	cTmp += _g_tar( aData[ i, 7 ] )
	cTmp += cSep
	
	// plu kod 
	cTmp += ALLTRIM( STR( aData[ i, 9 ]) )
	cTmp += cSep

	// plu cijena
	cTmp += ALLTRIM(STR( aData[ i, 10 ], 12, 2 ))
	cTmp += cSep
	
	// plu naziv
	cTmp += ALLTRIM( aData[ i, 4 ] ) 
	cTmp += cSep

	AADD( aArr, { cTmp } )
	
	// 2. dodavanje stavke promjena cijene - ako postoji
	
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
	
	// opcija dodavanja "4"
	cTmp += cOp_ch
	cTmp += cSep
	
	// plu kod 
	cTmp += ALLTRIM( STR( aData[ i, 9 ]) )
	cTmp += cSep
	
	// plu cijena
	cTmp += ALLTRIM(STR( aData[ i, 10 ], 12, 2 ))
	cTmp += cSep

	AADD( aArr, { cTmp } )

next

return


// ----------------------------------------
// fajl za pos fiskalni stampac
// ----------------------------------------
static function fp_filename( cBrRn )
local cRet
local cF_name := ALLTRIM( gFC_name )

do case

	case "$rn" $ cF_name
		// broj racuna.txt
		cRN := PADL( ALLTRIM( cBrRn ), 8, "0" )
		cRet := STRTRAN( cF_name, "$rn", cRN )
		cRet := UPPER( cRet )
	otherwise 
		// ono sta je navedeno u parametrima
		cRet := cF_name

endcase

return cRet



// ----------------------------------------------
// pobrisi answer fajl
// ----------------------------------------------
function fp_d_answer( cPath )
local cF_name

cF_name := cPath + "ANSWER" + SLASH + "ANSWER.TXT"

if FERASE( cF_name ) = -1
	msgbeep("Greska sa brisanjem answer.txt !")
endif

return



// ------------------------------------------------
// citanje gresaka za FPRINT driver
// vraca broj
// 0 - sve ok
// -9 - ne postoji answer fajl
// 
// nTimeOut - time out fiskalne operacije
// nFisc_no - broj fiskalnog isjecka
// ------------------------------------------------
function fp_r_error( cPath, nTimeOut, nFisc_no )
local nErr := 0
local cF_name
local i
local nBrLin
local nStart
local cErr
local aErr_read
local aErr_data
local nTime 

nTime := nTimeOut

// sacekaj malo !
//sleep( nTimeOut )

// primjer: c:\fprint\answer\answer.txt
cF_name := cPath + "ANSWER" + SLASH + "ANSWER.TXT"

// ova opcija podrazumjeva da je ukljuèena opcija 
// prikaza greske tipa ER,OK...

Box(,1,50)

do while nTime > 0
	
	-- nTime

	if FILE( cF_name )
		// fajl se pojavio - izadji iz petlje !
		exit
	endif

	@ m_x + 1, m_y + 2 SAY PADR( "Cekam na fiskalni uredjaj: " + ;
		ALLTRIM( STR(nTime) ), 48)

	sleep(1)
enddo

BoxC()

if !FILE( cF_name )
	msgbeep("Fajl " + cF_name + " ne postoji !!!")
	nFisc_no := 0
	nErr := -9
	return nErr
endif

nFisc_no := 0
nBrLin := BrLinFajla( cF_name )
nStart := 0

cFisc_txt := ""

// prodji kroz svaku liniju i procitaj zapise
for i:=1 to nBrLin
	
	aErr_read := SljedLin( cF_name, nStart )
      	nStart := aErr_read[ 2 ]

	// uzmi u cErr liniju fajla
	cErr := aErr_read[ 1 ]

	// ovo je dodavanje artikla
	if "107,1,00" $ cErr
		// preskoci
		loop
	endif
	
	// ovu liniju zapamti, sadrzi fiskalni racun broj
	// komanda 56, zatvaranje racuna
	if "56,1,00" $ cErr
		cFisc_txt := cErr
	endif

	// ima neka greska !
	if "Er;" $ cErr
		msgbeep( ALLTRIM(cErr) )
		nRet := 1
		return nRet
	endif
	
next

// ako je sve ok, uzmi broj fiskalnog isjecka
if !EMPTY( cFisc_txt )
	nFisc_no := _g_fisc_no( cFisc_txt )
endif

return nErr



// ------------------------------------------------
// vraca broj fiskalnog isjecka
// ------------------------------------------------
static function _g_fisc_no( cTxt )
local nFiscNO := 0
local aTmp := {}
local aFisc := {}
local cFisc := ""

aTmp := toktoniz( cTxt, ";" )
cFisc := aTmp[2]
aFisc := toktoniz( cFisc, "," )
nFiscNO := VAL( aFisc[2] )

return nFiscNO


