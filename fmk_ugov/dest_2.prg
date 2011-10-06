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


#include "fmk.ch"


// id partner
static __partn
static __ugov
static __dest_len

// ----------------------------------
// pregled destinacije 
// ----------------------------------
function p_dest_2( cId, cPartId, dx, dy )
local nArr := SELECT()
local cHeader := ""
local cFooter := ""
local xRet
private ImeKol
private Kol

cHeader += "Destinacije za: " 
cHeader += cPartId 
cHeader += "-" 
cHeader += PADR( Ocitaj(F_PARTN, cPartId, "naz"), 20 ) + ".."

select dest
set order to tag "IDDEST"

if !EMPTY(cPartId)
	__partn := cPartId
else
	__partn := SPACE(6)
endif

__ugov := ugov->id
__dest_len := 6

// postavi filter
set_f_tbl( cPartId )

// setuj kolone
set_a_kol( @ImeKol, @Kol )

xRet := PostojiSifra(F_DEST, "IDDEST", 16, 70, cHeader, @cId, dx, dy,{|Ch| key_handler(Ch)} )

set filter to

select (nArr)

return xRet


// setovanje filtera na tabeli destinacija
static function set_f_tbl( cPart )
local cFilt := ".t."

if cPart <> nil .and. !EMPTY(cPart)
	cFilt += ".and. idpartner == " + Cm2Str( cPart )
endif

if cFilt == ".t."
	cFilt := ""
endif

if !EMPTY( cFilt )
	set filter to &cFilt
else
	set filter to
endif

go top

return


// ----------------------------------------------------
// setovanje kolona tabele
// ----------------------------------------------------
static function set_a_kol( aImeKol, aKol )
local i

aImeKol := {}
aKol := {}

AADD(aImeKol, { "Naziv" , {|| PADR(ALLTRIM(naziv) + "/" + ALLTRIM(naziv2), 50) }, "naziv" } )
AADD(aImeKol, { "Mjesto" , {|| PADR( ALLTRIM(mjesto) + "/" + ALLTRIM(adresa), 20) }, "mjesto" })
AADD(aImeKol, { "Telefon", {|| PADR(telefon, 10) }, "telefon" })
AADD(aImeKol, { "Fax", {|| PADR(fax, 10) }, "fax" } )
AADD(aImeKol, { "Mobitel", {|| PADR(mobitel, 10) }, "mobitel" } )

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return



// --------------------------------
// key handler
// --------------------------------
static function key_handler( Ch )

@ m_x + 17, 6 SAY "<S> setuj kao def.destin.za fakturisanje"

do case
	case Ch == K_CTRL_N
	
		edit_dest( .t. )
		return 7
		
	case Ch == K_F2
		
		edit_dest( .f. )
		return 7

	case UPPER(CHR(Ch)) == "S"
		
		// set as default...
		set_as_default( __ugov, id )
		
endcase

return DE_CONT


// ----------------------------------------------------
// vraca novi broj destinacije
// ----------------------------------------------------
static function n_dest_id()
local xRet := "  1"
local nTArea := SELECT()
local nTRec := RECNO()
local cTBFilter := DBFilter()

select dest
set filter to
set order to tag "IDDEST"
go bottom

xRet := PADL( ALLTRIM( STR( VAL(field->id) + 1 ) ), __dest_len, "0" )

set order to tag "ID"

select (nTArea)
set filter to &cTbFilter
go (nTRec)

return xRet



// -----------------------------------
// edit destinacije
// -----------------------------------
static function edit_dest( lNova )
local nRec
local nBoxLen := 20
local nX := 1
private GetList:={}

if lNova
	nRec := RECNO()
	GO BOTTOM
	SKIP 1
endif
 	    
Scatter()
	   
if lNova

	_idpartner := __partn
	// uvecaj id automatski
	_id := n_dest_id()
	_mjesto := SPACE(LEN(_mjesto))
	_adresa := SPACE(LEN(_adresa))
	_naziv := SPACE(LEN(_naziv))
	_naziv2 := SPACE(LEN(_naziv2))
	_telefon := SPACE(LEN(_telefon))
	_fax := SPACE(LEN(_fax))
	_mobitel := SPACE(LEN(_mobitel))
	_ptt := SPACE(LEN(_mobitel))
	
endif

Box(, 16, 75 )

if lNova
	@ m_x + nX, m_y + 2 SAY PADL("*** Unos nove destinacije", 65)
else

	@ m_x + nX, m_y + 2 SAY PADL("*** Ispravka destinacije", 65)
endif

++nX

@ m_x + nX, m_y + 2 SAY PADR("Partner: " + ALLTRIM(_idpartner) + " , dest.rbr: " + ALLTRIM(_id), 70)

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("Naziv:", nBoxLen) GET _naziv

++ nX

@ m_x + nX, m_y + 2 SAY PADL("Naziv 2:", nBoxLen) GET _naziv2 

++ nX

@ m_x + nX, m_y + 2 SAY PADL("Mjesto:", nBoxLen) GET _mjesto 

++ nX

@ m_x + nX, m_y + 2 SAY PADL("Adresa:", nBoxLen) GET _adresa

++ nX

@ m_x + nX, m_y + 2 SAY PADL("PTT:", nBoxLen) GET _ptt 

++ nX

@ m_x + nX, m_y + 2 SAY PADL("Telefon:", nBoxLen) GET _telefon

++ nX

@ m_x + nX, m_y + 2 SAY PADL("Fax:", nBoxLen) GET _fax

++ nX

@ m_x + nX, m_y + 2 SAY PADL("Mobitel:", nBoxLen) GET _mobitel

read

BoxC()

if LastKey() == K_ESC
	return DE_CONT
endif

if lNova
	append blank
endif

Gather()

if lNova
	GO (nRec)
endif

return 7


// --------------------------------------------
// vraca info o destinaciji
// --------------------------------------------
function get_dest_info( cPartn, cDest, nLen )
local xRet := "---"
local nTArea := SELECT()

if nLen == nil
	nLen := 15
endif

select dest
set order to tag "ID"
hseek cPartn + cDest

if FOUND() 
	if cPartn == field->idpartner .and. cDest == field->id
		xRet := ALLTRIM(field->naziv) + ":" + ALLTRIM(field->naziv2) + ":" + ALLTRIM(field->adresa)
	endif
endif

xRet := PADR( xRet, nLen )

select (nTArea)
return xRet


// --------------------------------------------
// vraca box info o destinaciji
// --------------------------------------------
function get_dest_binfo( nX, nY, cPartn, cDest )
local xRet := "---"
local nTArea := SELECT()

select dest
set order to tag "ID"
go top
hseek cPartn + cDest

if FOUND() 
	if cPartn == field->idpartner .and. cDest == field->id
		
		cPom := ALLTRIM( field->naziv) + ", " + ALLTRIM(field->naziv2)
		
		@ nX, nY SAY SPACE( 65 ) COLOR "I"
		@ nX, nY SAY PADR( cPom, 65 ) COLOR "I"

		cPom := ALLTRIM(field->adresa) + ", " + ALLTRIM(field->telefon)
		
		@ nX + 1, nY SAY SPACE( 65 ) COLOR "I"
		@ nX + 1, nY SAY PADR( cPom, 65 ) COLOR "I"
		
	endif
endif

select (nTArea)
return


// ----------------------------------------
// set default destinacija
// ----------------------------------------
function set_as_default( cUgovId, cDest )
local nTArea := SELECT()
local nRec

if Pitanje(,"Setovati kao glavnu destinaciju fakturisanja (D/N)?", "D") == "N"
	return
endif

select ugov
set order to tag "ID"
nRec := RECNO()
seek cUgovId

if FOUND()
	replace def_dest with cDest
	MsgBeep("Destinacija '" + ALLTRIM(cDest) + "' setovana#za ugovor " + cUgovId + " !!!")
endif

select ugov
go (nRec)

select (nTArea)
return


