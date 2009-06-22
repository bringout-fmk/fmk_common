#include "ld.ch"


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
go top
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

if nPrStopa == 0 .or. nPrOdbit == 0 .or. nPorez == 0
	MsgBeep( "Iznosi poreza, pr.troska i pr.stope za " + cRnOpc + "#moraju biti popunjeni u sifraniku opcina !!!" )	
	return .f.
endif

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
set order to tag "ID"
go top
seek cId

if FOUND()
	cIzName := field->iz_naz
	cIzNo := field->iz_broj
	dIzDate := field->iz_datum
endif

select (nTArea)

return 


// -------------------------------------
// vraca opis izdanja
// -------------------------------------
function _get_izd( cIzdanje )
local cIzName
local cIzNo
local dIzDate
local cRet := ""

get_izd_info(cIzdanje, @cIzName, @cIzNo, @dIzDate)

cRet := ALLTRIM(cIzName) + "," + ALLTRIM(cIzNo)

return cRet



// -----------------------------------------------
// izracunavanje honorara za autora
// -----------------------------------------------
function izr_honorar( cIdRadn, lShowInfo )
local nPrStopa := 0
local nPorez := 0
local nPrTrosk := 0
local nTArea := SELECT()

if lShowInfo == nil
	lShowInfo := .t.
endif

altd()

// uzmi parametre za radnika i opcinu
if ahon_param( cIdRadn, @nPrStopa, @nPrTrosk, @nPorez ) == .f.
	select (nTAreA)
	return .f.
endif

_ubruto := ( _uneto / nPrStopa ) * 100
_uprtrosk := _ubruto * ( nPrTrosk / 100 )
_uporez := (_ubruto - _uprtrosk) * (nPorez / 100)

if lShowInfo == .t.
	prik_ah_total()
endif

select (nTArea)
return .t.


// --------------------------------------------
// prikazuje na formi za unos izr.vrijednosti
// --------------------------------------------
static function prik_ah_total()

@ m_x+14,m_y+2 SAY "NETO:"
@ row(),col()+1 SAY _UNeto PICT gPics
@ m_x+15,m_y+2 SAY "BRUTO:"
@ row(),col()+1 SAY _UBruto PICT gPici
@ m_x+16,m_y+2 SAY "Priznati troskovi:"
@ row(),col()+1 SAY _UPrTrosk PICT gPici
@ m_x+17,m_y+2 SAY "Porez:"
@ row(),col()+1 SAY _UPorez PICT gPici

return


