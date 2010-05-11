#include "sc.ch"


// -------------------------------------------------------
// import barcode terminal data
// -------------------------------------------------------
function iBTerm_data()
local cPath := ""
local cI_File := ""
local cFilter := "*.txt"

// pronadji fajl za import u export direktoriju
_gExpPath( @cPath )
_gFList( cFilter, cPath, @cI_File )

// prebaci iz TXT fajla u pomocnu tabelu
Txt2TTerm( cI_File )

// podaci su sada importovani u TEMP.DBF


// pobrisi txt fajl
TxtErase( cI_file, .t. )

return


// -----------------------------------------------------
// Vraca podesenje putanje do exportovanih fajlova
// -----------------------------------------------------
static function _gExpPath( cPath )
cPath:=IzFmkIni("FMK", "ImportPath", "c:\import\", PRIVPATH)
if Empty(cPath) .or. cPath == nil
	cPath := "c:\import\"
endif
return


