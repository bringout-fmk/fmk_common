#include "ld.ch"

static __IDRADN := ""


// -------------------------------------------
// prikaz podataka o clanovima
// -------------------------------------------
function pk_data( cId, dx, dy )
local i
local cHeader := ""
private ImeKol
private Kol

__IDRADN := cID

cHeader += "Podaci o izdrzavanim clanovima " 

select pk_data
set filter to

// setuj filter
set_filt( cId )

// setuj kolone tabele
set_a_kol(@ImeKol, @Kol)

PostojiSifra(F_PK_DATA, 1, 10, 77, cHeader, ;
	nil, dx, dy, {|Ch| key_handler(Ch)})

return

// ------------------------------------------
// setuje filter na bazi
// ------------------------------------------
static function set_filt( cId )
local cFilt := ""

cFilt := "idradn == " + cm2str(cId)
set filter to &cFilt
go top

return


// -----------------------------------------
// setovanje kolona prikaza
// -----------------------------------------
static function set_a_kol(aImeKol, aKol)
local i

aImeKol := {}
aKol := {}

AADD(aImeKol, { "ident.", {|| PADR(s_ident( ident ),15) }, "ident"  })
AADD(aImeKol, { "rbr.", {|| PADR(STR(rbr),3) }, "rbr"  })
AADD(aImeKol, { "prezime i ime", {|| PADR(ime_pr,15)+"..." }, "ime_pr"  })
AADD(aImeKol, { "JMB", {|| jmb }, "jmb"  })
AADD(aImeKol, { "k.srod", {|| sr_kod }, "sr_kod"  })
AADD(aImeKol, { "naz.srodstva", {|| sr_naz }, "sr_naz"  })
AADD(aImeKol, { "vl.prihod", {|| prihod }, "prihod"  })
AADD(aImeKol, { "udio", {|| udio }, "udio"  })
AADD(aImeKol, { "koef.", {|| koef }, "koef"  })

for i:=1 TO LEN(aImeKol)
	AADD(aKol, i)
next

return


// --------------------------------
// key handler
// --------------------------------
static function key_handler(Ch)
local GetList:={}
local nRec:=0

do case
		
	case (Ch == K_F2)
		// ispravka stavke
		unos_clan( .f. )
		return 7
	
	case (Ch == K_CTRL_N)
		
		// nova stavka
	   	unos_clan( .t. )
	  	return 7
	
endcase

return DE_CONT



// -----------------------------------
// unos clanova
// -----------------------------------
function unos_clan( lNew )
local nBoxLen:=10
local nX

Box(, 12,70,.f.)

   do while .t.
	
	altd()

	nX := 1

   	scatter()

	if lNew == .t.
		_idradn := __IDRADN
		_ident := " "
		_rbr := 0
		_ime_pr := PADR("", LEN(_ime_pr))
		_jmb := PADR("", LEN(_jmb))
		_sr_naz := PADR("", LEN(_sr_naz))
		_sr_kod := 0
		_prihod := 0
		_udio := 0
		_koef := 0
	endif

	@ nXX:=m_x + nX, nYY:=m_y + 2 SAY PADL("ident.", nBoxLen) ;
		GET _ident ;
      		WHEN lNew ;
		VALID {|| g_ident( @_ident ), ;
			_n_rbr(@_rbr, __IDRADN, _ident), ;
			p_ident( _ident, nXX, nYY ) }
      		
	++ nX

	@ m_x + nX, m_y + 2 SAY PADL("rbr", nBoxLen) ;
		GET _rbr ;
		WHEN lNew ;
		VALID _g_koef( @_koef, _ident, _rbr ) ;
		PICT "999"

	++ nX
	
	@ m_x + nX, m_y + 2 SAY PADL("prez.i ime", nBoxLen) ;
		GET _ime_pr ;
		VALID !EMPTY( _ime_pr ) 

	++ nX
	
	@ m_x + nX, m_y + 2 SAY PADL("jmb", nBoxLen) ;
		GET _jmb ;
		VALID !EMPTY( _jmb ) 

	++ nX
	
	@ m_x + nX, m_y + 2 SAY PADL("'kod' sr.", nBoxLen) ;
		GET _sr_kod ;
		VALID {|| _sr_naz := PADR( g_srodstvo( _sr_kod ), ;
		LEN(_sr_naz)), .t. } ;
		PICT "99"

	++ nX
	
	@ m_x + nX, m_y + 2 SAY PADL("srodstvo", nBoxLen) ;
		GET _sr_naz
	
	++ nX
	
	@ m_x + nX, m_y + 2 SAY PADL("vl.prihod", nBoxLen) ;
		GET _prihod PICT "9999999.99"

	++ nX
	
	@ m_x + nX, m_y + 2 SAY PADL("udio", nBoxLen) ;
		GET _udio PICT "999"

	++ nX
	
	@ m_x + nX, m_y + 2 SAY PADL("koef.", nBoxLen) ;
		GET _koef PICT "9.999"

	read
	
	if lNew == .t. .and. LastKey() <> K_ESC
		append blank
		gather()
	endif

	if lNew == .f.
		gather()
		exit
	endif

	if LastKey() == K_ESC
		exit
	endif
	
    enddo

BoxC()

return 7


// ----------------------------------------------
// novi broj
// ----------------------------------------------
static function _n_rbr( nRbr, cIdRadn, cIdent )
local nTArea := SELECT()
local nTRec := RECNO()

select pk_data
set order to tag "1"

seek cIdRadn + cIdent

nRbr := 0

do while !EOF() .and. field->idradn == cIdRadn ;
	.and. field->ident == cIdent
	
	nRbr := field->rbr + 1
	
	skip
enddo

if nRbr = 0
	nRbr := 1
endif

go (nTRec)
select (nTArea)
return .t.




// -------------------------------------------------
// funkcija vraca listu identifikatora
// -------------------------------------------------
static function g_ident( cIdent )
local lRet := .f.

if cIdent $ "1234"
	lRet := .t.
endif

return lRet


// ----------------------------------------
// prikazi identifikator
// ----------------------------------------
static function p_ident( cIdent, nX, nY )
local cVal := s_ident( cIdent )

@ nX, nY + 20 SAY PADR( cVal, 20 )

return .t.


// ------------------------------------------
// daj vrijednost polja
// ------------------------------------------
static function s_ident( cIdent )
local cVal := "?????"

do case
	case cIdent == "1"
		cVal := "bracni drug"
	case cIdent == "2"
		cVal := "izdr.djeca"
	case cIdent == "3"
		cVal := "clan porodice"
	case cIdent == "4"
		cVal := "clan por.inv."
endcase

return cVal



// ----------------------------------------------
// vraca koeficijent za clanove porodice
// ----------------------------------------------
static function _g_koef( nKoef, cIdent, nRbr )

do case
	case cIdent == "1"
		// bracni drug
		nKoef := 0.5	
	case cIdent == "2"
		// djeca
		nKoef := _g_k_dj( nRbr )
	case cIdent == "3"
		// uzi clanovi porodice
		nKoef := 0.3
	case cIdent == "4"
		// uzi clanovi porodice - invalidi
		nKoef := 0.3
endcase

return .t.


// -----------------------------------------
// vraca koeficijent za djecu
// -----------------------------------------
static function _g_k_dj( nRbr )
local nKoef := 0.5

do case
	case nRbr = 1
		nKoef := 0.5
	case nRbr = 2
		nKoef := 0.7
	case nRbr >= 3
		nKoef := 0.9
endcase

return nKoef


