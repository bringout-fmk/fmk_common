#include "ld.ch"

// identifikatori za tabelu clanova
static I_BR_DR := "1"
static I_IZ_DJ := "2"
static I_CL_P := "3"
static I_CL_PI := "4"


// ---------------------------------------
// forma za unos poreske kartice
// ---------------------------------------
function p_kartica( cIdRadn )
local nZ_id := 0
local lNew := .t.

o_pk_tbl()

select pk_radn
set order to tag "1"
seek cIdRadn

if FOUND() .and. field->idradn == cIdRadn
	lNew := .f.
else
	lNew := .t.
endif

// pronadji novi zahtjev za radnika...
if lNew == .t.
	nZ_id := n_zahtjev()
endif

// unos osnovnih podataka
unos_osn( lNew, cIdRadn, nZ_id )

return

// ----------------------------------------------
// unos osnovnih podataka
// ----------------------------------------------
static function unos_osn( lNew, cIdRadn, nZ_id )
local nX := 1
local cClan := "N"
local cLoPict := "9.999"
local cPkColor := "W+/G+"

select pk_radn

scatter()

if lNew == .t.
	
	cClan := "D"
	_idradn := cIdRadn
	_zahtjev := nZ_id
	_datum := DATE()
	_r_ime := PADR( radn->ime, LEN(_r_ime) )
	_r_prez := PADR( radn->naz, LEN(_r_prez) )
	_r_imeoca := PADR( radn->imerod, LEN(_r_imeoca) )
	_r_jmb := PADR( radn->matbr, LEN(_r_jmb) ) 
	_r_adr := PADR( ALLTRIM(radn->streetname) + ;
		" " + ALLTRIM(radn->streetnum), LEN(_r_adr))
	_r_opc := PADR( _g_r_opc( radn->idopsst ), LEN(_r_opc) )
	_r_opckod := PADR( _g_r_kopc( radn->idopsst ), LEN(_r_opckod) )
	_p_zap := "D"
	_p_naziv := PADR( _g_firma(), LEN(_p_naziv) )
	_p_jib := PADR( _g_f_jib(), LEN(_p_jib)) 
	_lo_osn := 1

endif

Box(, 22, 77)

	@ m_x + nX, m_y + 2 SAY PADR("*** unos osnovnih podataka", 76) ;
		COLOR cPkColor

	++ nX

	@ m_x + nX, m_y + 2 SAY "zahtjev broj:" GET _zahtjev
	@ m_x + nX, col() + 2 SAY "datum:" GET _datum

	++ nX

	@ m_x + nX, m_y + 2 SAY "ime" GET _r_ime PICT "@S15"
	@ m_x + nX, col() + 1 SAY "ime oca" GET _r_imeoca PICT "@S15"
	@ m_x + nX, col() + 1 SAY "prezime" GET _r_prez PICT "@S20"
	
	++ nX

	@ m_x + nX, m_y + 2 SAY "jmb" GET _r_jmb
	@ m_x + nX, col() + 1 SAY "adresa" GET _r_adr PICT "@S30"
	
	++ nX
	
	@ m_x + nX, m_y + 2 SAY "opcina prebivalista" GET _r_opc PICT "@S15"
	@ m_x + nX, col() + 1 SAY "'kod':" GET _r_opckod PICT "@S10"

	++ nX

	@ m_x + nX, m_y + 2 SAY "datum rodjenja" GET _r_drodj
	@ m_x + nX, col() + 1 SAY "telefon" GET _r_tel
	
	++ nX
	++ nX 

	@ m_x + nX, m_y + 2 SAY PADR("*** podaci o poslodavcu",76) ;
		COLOR cPkColor
	
	++ nX 

	@ m_x + nX, m_y + 2 SAY "poslodavac" GET _p_naziv PICT "@S30"
	@ m_x + nX, col() + 1 SAY "JIB" GET _p_jib
	
	++ nX

	@ m_x + nX, m_y + 2 SAY "zaposlen (D/N)" GET _p_zap ;
		VALID _p_zap $ "DNX" PICT "@!"

	++ nX
	++ nX
	
	@ m_x + nX, m_y + 2 SAY PADR("*** podaci o clanovima porodice", 76) ;
		COLOR cPkColor

	++ nX
	
	@ m_x + nX, m_y + 2 SAY "unos podataka o uzdrzavanim clanovima" ;
		GET cClan ;
		VALID cClan $ "DN" PICT "@!"
	read

	// izadji ako je kraj...
	if LastKey() == K_ESC
		BoxC()
		return
	endif

	if cClan == "D"
		
		// unos izdrzavanih clanova
		pk_data( cIdRadn )

		select pk_radn
	
		// kalkulisi parametre licnih odbitaka
		_lo_brdr := lo_clan( I_BR_DR,  cIdRadn )
		_lo_izdj := lo_clan( I_IZ_DJ,  cIdRadn )
		_lo_clp := lo_clan( I_CL_P, cIdRadn )
		_lo_clpi := lo_clan( I_CL_PI, cIdRadn )
		// total
		_lo_ufakt := _lo_osn + _lo_brdr + ;
				_lo_izdj + _lo_clp + _lo_clpi
	
	endif

	++ nX
	++ nX

	@ m_x + nX, m_y + 2 SAY PADR("*** podaci o licnim odbicima", 76) ;
		COLOR cPkColor

	++ nX
	@ m_x + nX, m_y + 2 SAY PADL("osnovni odbitak:",30) GET _lo_osn PICT cLoPict
	++ nX 
	@ m_x + nX, m_y + 2 SAY PADL("bracni drug:",30) GET _lo_brdr PICT cLoPict
	++ nX
	@ m_x + nX, m_y + 2 SAY PADL("izdr.djeca:",30) GET _lo_izdj PICT cLoPict
	++ nX
	@ m_x + nX, m_y + 2 SAY PADL("clan.porodice:",30) GET _lo_clp PICT cLoPict
	++ nX
	@ m_x + nX, m_y + 2 SAY PADL("clan.porodice inv.:",30) GET _lo_clpi PICT cLoPict
	++ nX
	@ m_x + nX, m_y + 2 SAY "----------------------------------------" 
	++ nX
	@ m_x + nX, m_y + 2 SAY PADL("Ukupni faktor:",30) GET _lo_ufakt PICT cLoPict

	read

BoxC()

if LastKey() == K_ESC
	return
endif

if lNew == .t.
	append blank
endif

gather()

return





// ---------------------------------------
// vraca naziv firme
// ---------------------------------------
static function _g_firma()
return ""


// ---------------------------------------
// vraca naziv firme
// ---------------------------------------
static function _g_f_jib()
return ""


// ---------------------------------------
// vraca opcinu stanovanja radnika
// ---------------------------------------
static function _g_r_opc( cOpc )
local nTArea := SELECT()
local cRet := ""

O_OPS
seek cOpc

cRet := field->naz

select (nTArea)
return cRet


// ---------------------------------------
// vraca kod opcine stanovanja radnika
// ---------------------------------------
static function _g_r_kopc( cOpc )
local nTArea := SELECT()
local cRet := ""

O_OPS
seek cOpc

cRet := field->puccity

select (nTArea)

return cRet
















