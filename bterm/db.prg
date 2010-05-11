#include "sc.ch"



// -------------------------------------------------------
// Setuj matricu sa poljima tabele dokumenata TERM
// -------------------------------------------------------
static function _sTblTerm(aDbf)

AADD(aDbf,{"barkod",  "C", 13, 0})
AADD(aDbf,{"idroba",  "C", 10, 0})
AADD(aDbf,{"kolicina", "N", 15, 5})
AADD(aDbf,{"status", "N", 2, 0})

// status
// 0 - nema robe u sifrarniku
// 1 - roba je tu

return


// --------------------------------------------------------
// Kreiranje temp tabele, te prenos zapisa iz text fajla 
// "cTextFile" u tabelu 
//  - param cTxtFile - txt fajl za import
// --------------------------------------------------------
function Txt2TTerm( cTxtFile )
local cDelimiter := ";"
local aDbf := {}

// prvo kreiraj tabelu temp
close all

// polja tabele TEMP.DBF
_sTblTerm( @aDbf )

// kreiraj tabelu
_creTemp( aDbf, .t. )

O_ROBA
O_TEMP

if !File(PRIVPATH + SLASH + "TEMP.DBF")
	MsgBeep("Ne mogu kreirati fajl TEMP.DBF!")
	return
endif

// zatim iscitaj fajl i ubaci podatke u tabelu

// broj linija fajla
nBrLin := BrLinFajla(cTxtFile)
nStart := 0

// prodji kroz svaku liniju i insertuj zapise u temp.dbf
for i := 1 to nBrLin
	
	aBTerm := SljedLin( cTxtFile, nStart )
	nStart := aBTerm[2]
	// uzmi u cText liniju fajla
	cVar := aBTerm[1]

	if EMPTY(cVar)
		loop
	endif

	aRow := csvrow2arr( cVar, cDelimiter ) 
	
	// struktura podataka u txt-u je
	// [1] - barkod
	// [2] - kolicina
	
	// pa uzimamo samo sta nam treba
	cTmp := PADR( ALLTRIM( aRow[1] ), 13 )
	nTmp := VAL ( ALLTRIM( aRow[2] ) )
	
	select roba
	set order to tag "BARKOD"
	go top
	seek cTmp

	if FOUND()
		cRoba_id := field->id
		nStatus := 1
	else
		cRoba_id := ""
		nStatus := 0
	endif

	// selektuj temp tabelu
	select temp
	// dodaj novi zapis
	append blank

	replace barkod with cTmp
	replace idroba with cRoba_id
	replace kolicina with nTmp
	replace status with nStatus

next

select temp

MsgBeep("Import txt => temp - OK")

return


// ----------------------------------------------------------------
// Kreira tabelu PRIVPATH\TEMP.DBF prema definiciji polja iz aDbf
// ----------------------------------------------------------------
static function _creTemp( aDbf, lIndex )
cTmpTbl := PRIVPATH + "TEMP"

if lIndex == nil
	lIndex := .t.
endif

if File(cTmpTbl + ".DBF") .and. FErase(cTmpTbl + ".DBF") == -1
	MsgBeep("Ne mogu izbrisati TEMP.DBF!")
    	ShowFError()
endif
if File(cTmpTbl + ".CDX") .and. FErase(cTmpTbl + ".CDX") == -1
	MsgBeep("Ne mogu izbrisati TEMP.CDX!")
    	ShowFError()
endif

DbCreate2(cTmpTbl, aDbf)

if lIndex 
	create_index("1","barkod", cTmpTbl )
	create_index("2","idroba", cTmpTbl )
	create_index("3","STR(status)", cTmpTbl )
endif

return



