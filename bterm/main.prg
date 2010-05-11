#include "sc.ch"


// -------------------------------------------------------
// import barcode terminal data
// -------------------------------------------------------
function iBTerm_data( cI_File )
local cPath := ""
local aError := {}
local cFilter := "*.txt"

cI_File := ""

// pronadji fajl za import u export direktoriju
_gExpPath( @cPath )
_gFList( cFilter, cPath, @cI_File )

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
? "----------------------------------"
nCnt := 0
for i:=1 to LEN( aErr )
	? PADL( ALLTRIM(STR(++nCnt)), 3) + "."
	@ prow(), pcol()+1 SAY "barkod: " + aErr[i,1]
next

FF
END PRINT

return aErr



