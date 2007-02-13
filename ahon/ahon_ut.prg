#include "\dev\fmk\ld\ld.ch"


// -------------------------------------------------------
// vrijednosti koje su neophodne za obracun
// -------------------------------------------------------
function ahon_param( cIdRadn, nPrStopa, nPrOdbit, nPorez )
local nTArea := SELECT()
local cRnOpc := ""

nPrStopa := 0
nPrOdbit := 0
nPorez := 0

if EMPTY(cIdRadn)
	return .f.
endif

select radn
seek cIdRadn

cRnOpc := radn->idopsst

select ops
go top
seek cRnOpc

if FOUND() .and. ops->id == cRnOpc
	nPrStopa := field->ah_prst
	nPrOdbit := field->ah_prtr
	nPorez := field->ah_por
endif

select (nTArea)
return .t.


// ------------------------------------------------
// da li je podeseno sve za autorske honorare
// ------------------------------------------------
function ahon_ready()
local nTArea := SELECT()
local cMsg := ""

if (gAHonorar == nil .or. gAHonorar == "N")
	return .t.
endif

O_LD

if ld->(FIELDPOS("IZDANJE")) == 0
	cMsg += "Odraditi modifikaciju struktura AHON.CHS !!!"
endif

if !FILE(SIFPATH + "IZDANJA.DBF")
	if !EMPTY( cMsg )
		cMsg += "##"
	endif
	cMsg += "Odraditi instalaciju fajlova i reindex."
endif

if !EMPTY(cMsg)
	msgbeep(cMsg)
endif

select (nTArea)
return .t.



// -------------------------------------
// vraca informacije o casopisu
// -------------------------------------
function get_izd_info( cId, cIzName, cIzNo, dIzDate )
local nTArea := SELECT()

O_IZDANJA
select izdanja
set order to tag "1"
go top
seek cId

if FOUND()
	cIzName := field->iz_naz
	cIzNo := field->iz_broj
	dIzDate := field->iz_datum
endif

select (nTArea)

return 


// -----------------------------------------------
// izracunavanje honorara za autora
// -----------------------------------------------
function izr_honorar()
local nPrStopa := 0
local nPorez := 0
local nPrTrosk := 0
local nTArea := SELECT()

// uzmi parametre za radnika i opcinu
ahon_param(_idradn, @nPrStopa, @nPrTrosk, @nPorez)

_ubruto := ( _uneto / nPrStopa ) * 100
_uprtrosk := _ubruto * ( nPrTrosk / 100 )
_uporez := (_ubruto - _uprtrosk) * (nPorez / 100)

select (nTArea)
return


