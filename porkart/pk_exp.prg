#include "ld.ch"



// --------------------------------------------------
// funkcija exporta podataka poreskih kartica
// --------------------------------------------------
function pk_export()
local nCnt := 0
local cFExp := ""
local aErrors := {}
local cSep := "#"

O_RADN
o_pk_tbl()

if _g_params( @cFExp ) == 0
	return
endif

// otvori fajl za export...
o_file( cFExp )

select radn
go top

do while !EOF()
	
	cIdR := field->id
	
	select pk_radn
	seek cIdR
	
	if FOUND() .and. field->idradn == cIdR
		
		// podaci su tu !!!

		cPom := field->r_prez + cSep + ;
			field->r_imeoca + cSep + ;
			field->r_ime + cSep + ;
			field->r_jmb + cSep + ;
			field->r_adr

		if nCnt = 0
			?? cPom
		else
			? cPom
		endif

		++ nCnt 
	else

		
		// nema podataka...
		AADD( aErrors, { radn->id, ;
			ALLTRIM(radn->naz) + " ( " + ;
			ALLTRIM(radn->imerod) + " ) " + ;
			ALLTRIM(radn->ime) } )

	endif

	select radn
	skip

enddo

// zatvori fajl
c_file()

msgbeep("Exportovani podaci za " + ALLTRIM(STR(nCnt)) + " radnika !")

if LEN(aErrors) > 0
	_s_errors( aErrors )
	msgbeep("Ispravite sve greske i ponovo pokrenite export !")
endif

return


// ----------------------------------------
// prikazi errore
// ----------------------------------------
static function _s_errors( aErr )
local i
local nCnt := 0

START PRINT CRET

? "Lista radnika koji nemaju popunjenu poresku karticu"
? "---------------------------------------------------"
?
? " rbr  sifra  ime i prezime"
? "----- ------ ---------------------------------"
for i := 1 to LEN( aErr )

	? PADL(ALLTRIM(STR(++nCnt)),4) + ")"
	@ prow(), pcol() + 1 SAY aErr[i, 1]
	@ prow(), pcol() + 1 SAY aErr[i, 2]

next

FF
END PRINT

return


// ----------------------------------------
// parametri exporta
// ----------------------------------------
static function _g_params( cFile )
local GetList := {}
local nX := 1

cFile := PADR("c:\test\EXP.TXT", 200)

Box(,5,65)

	@ m_x + nX, m_y + 2 SAY "Lokacija:" GET cFile ;
		VALID !EMPTY(cFile) ;
		PICT "@S40"

	read
BoxC()

if LastKey() == K_ESC
	return 0
endif

return 1


// -------------------------------------------
// otvara fajl za pisanje...
// -------------------------------------------
static function o_file( cFile )

set printer to (cFile)
set printer on
set console off

return


// -------------------------------------------
// zatvara fajl za pisanje
// -------------------------------------------
static function c_file()
set printer to
set printer on
set console off
return



