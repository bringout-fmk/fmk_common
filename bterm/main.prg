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


// -------------------------------------------------------
// import barcode terminal data
// -------------------------------------------------------
function iBTerm_data( cI_File )
local cPath := ""
local aError := {}
local cFilter := "p*.txt"

cI_File := ""

// pronadji fajl za import u export direktoriju
_gExpPath( @cPath )

if _gFList( cFilter, cPath, @cI_File ) = 0
	return 0
endif

// prebaci iz TXT fajla u pomocnu tabelu
Txt2TTerm( cI_File )

// podaci su sada importovani u TEMP.DBF

// provjeri nepostojece artikle
aError := _cBarkod()

if LEN( aError ) > 0
	// ima spornih artikala...
	return 0
endif


return 1


// -----------------------------------------------------
// Vraca podesenje putanje do exportovanih fajlova
// -----------------------------------------------------
static function _gExpPath( cPath )
cPath:=IzFmkIni("FMK", "ImportPath", "c:\import\", PRIVPATH)
if Empty(cPath) .or. cPath == nil
	cPath := "c:\import\"
endif
return


// ---------------------------------------
// provjeri barkod
// ---------------------------------------
static function _cBarkod()
local aErr := {}
local nScan 
local i
local nCnt

select temp
// STR(status)
set order to tag "3"
go top

// stavke sa statusom 0 - nemaju svog para u ROBI
do while !EOF() .and. field->status = 0
	
	cTmp := field->barkod
	
	nScan := ASCAN( aErr, {| xVal | xVal[1] == cTmp } )
	
	if nScan = 0
		AADD( aErr, { field->barkod, field->kolicina } )
	endif
	
	skip
enddo

if LEN(aErr) = 0
	return aErr
endif

START PRINT CRET
?
? "Lista nepostojecih artikala:"
? "--------------------------------------------------------------"
nCnt := 0
for i:=1 to LEN( aErr )
	? PADL( ALLTRIM(STR(++nCnt)), 3) + "."
	@ prow(), pcol()+1 SAY "barkod: " + aErr[i,1]
	@ prow(), pcol()+1 SAY "_________________________________"
next

FF
END PRINT

return aErr



// ------------------------------------------------
// generise txt fajl sa artiklima za terminal...
// ------------------------------------------------
function eBTerm_data()
local aStruct := _gAStruct()
local nTArea := SELECT()
local cSeparator := ";"
local aData := {}
// trim podataka unutar niza
local lTrimData := .t.
// zadnji slog sa separatorom
local lLastSeparator := .f.
local cFileName := ""
local cFilePath := ""
local nScan 
local cBK
local nCnt := 0

// aData
// [1] barkod
// [2] naziv
// [3] kolicina
// [4] cijena

// kreiraj pomocnu tabelu
cre_tmp()

select (249)
use (PRIVPATH + "R_EXPORT") alias "exp"
index on barkod TAG "ID" 

O_ROBA
set order to tag "BARKOD"
go top

do while !EOF()
	
	cBK := PADR( field->barkod, 20 )

	if EMPTY( cBK )
		skip
		loop
	endif
	
	select exp
	go top
	seek cBK
	
	if !FOUND()
		
		append blank
		replace field->barkod with roba->barkod
		replace field->naz with roba->naz
		replace field->tk with 0
		replace field->tc with roba->vpc
	
		++ nCnt
	endif

	select roba
	skip
enddo

_gExpPath( @cFilePath )
cFileName := "ARTIKLI.TXT"

// dodaj u fajl
_dbf_to_file( cFilePath, cFileName, aStruct, "R_EXPORT", ;
	cSeparator, lTrimData, lLastSeparator )

msgbeep("Exportovao " + ALLTRIM(STR(nCnt)) + " zapisa robe !")

select (249)
use

select (nTArea)
return 1



// ----------------------------------------
// artikli.txt struktura txt fajla
// ----------------------------------------
static function _gAStruct()
local aRet := {}

// BARKOD
AADD( aRet, { "C", 20, 0 } )
// NAZIV
AADD( aRet, { "C", 40, 0 } )
// TRENUTNA KOLICINA
AADD( aRet, { "N", 8, 2 } )
// TRENUTNA CIJENA
AADD( aRet, { "N", 8, 2 } )

return


// -------------------------------------------
// kreiraj pomocnu tabelu
// -------------------------------------------
static function cre_tmp()
local aFields := {}

AADD( aFields, {"barkod", "C", 20, 0} )
AADD( aFields, {"naz", "C", 40, 0} )
AADD( aFields, {"tk", "N", 8, 2} )
AADD( aFields, {"tc", "N", 8, 2} )

t_exp_create( aFields )

return

