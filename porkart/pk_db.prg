#include "ld.ch"


// ---------------------------------------
// forma za unos poreske kartice
// ---------------------------------------
function pk_dbcre()
local aDbf := {}

AADD(aDBf,{ 'idradn'              , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'zahtjev'             , 'N' ,   4 ,  0 })
AADD(aDBf,{ 'datum'               , 'D' ,   8 ,  0 })

// 1. podaci o radniku
// -----------------------------------------------------
// prezime
AADD(aDBf,{ 'r_prez'              , 'C' ,   20 ,  0 })
// ime
AADD(aDBf,{ 'r_ime'               , 'C' ,   20 ,  0 })
// ime oca
AADD(aDBf,{ 'r_imeoca'            , 'C' ,   20 ,  0 })
// jmb
AADD(aDBf,{ 'r_jmb'               , 'C' ,   13 ,  0 })
// adresa prebivalista
AADD(aDBf,{ 'r_adr'               , 'C' ,   30 ,  0 })
// opcina prebivalista
AADD(aDBf,{ 'r_opc'               , 'C' ,   30 ,  0 })
// opcina prebivalista "kod"
AADD(aDBf,{ 'r_opckod'            , 'C' ,   10 ,  0 })
// datum rodjenja
AADD(aDBf,{ 'r_drodj'             , 'D' ,    8 ,  0 })
// telefon
AADD(aDBf,{ 'r_tel'               , 'N' ,   12 ,  0 })

// 2. podaci o poslodavcu
// -----------------------------------------------------
// naziv poslodavca
AADD(aDBf,{ 'p_naziv'             , 'C' ,  100 ,  0 })
// jib poslodavca
AADD(aDBf,{ 'p_jib'               , 'C' ,   13 ,  0 })
// zaposlen TRUE/FALSE
AADD(aDBf,{ 'p_zap'               , 'C' ,    1 ,  0 })

// 3. podaci o licnim odbicima
// -----------------------------------------------------
// osnovni licni odbitak
AADD(aDBf,{ 'lo_osn'            , 'N' ,  10 ,  3 })
// licni odbitak za bracnog druga
AADD(aDBf,{ 'lo_brdr'           , 'N' ,  10 ,  3 })
// licni odbitak za izdrzavanu djecu
AADD(aDBf,{ 'lo_izdj'           , 'N' ,  10 ,  3 })
// licni odbitak za clanove porodice
AADD(aDBf,{ 'lo_clp'            , 'N' ,  10 ,  3 })
// licni odbitak za clanove porodice sa invaliditeom
AADD(aDBf,{ 'lo_clpi'           , 'N' ,  10 ,  3 })
// ukupni faktor licnog odbitka
AADD(aDBf,{ 'lo_ufakt'          , 'N' ,  10 ,  3 })

if !FILE( KUMPATH + "PK_RADN.DBF" )
	DBCreate2( KUMPATH + "PK_RADN.DBF", aDbf)
endif

CREATE_INDEX( "1", "idradn", KUMPATH + "PK_RADN" )
CREATE_INDEX( "2", "STR(zahtjev)", KUMPATH + "PK_RADN" )

aDbf := {}

// id radnik
AADD(aDBf,{ 'idradn'              , 'C' ,   6 ,  0 })
// identifikator podatka (1) bracni drug
//                       (2) djeca
//                       (3) clanovi porodice ....
AADD(aDBf,{ 'ident'               , 'C' ,   1 ,  0 })
// redni broj
AADD(aDBf,{ 'rbr'                 , 'N' ,   2 ,  0 })
// ime i prezime
AADD(aDBf,{ 'ime_pr'              , 'C' ,   50 ,  0 })
// jmb
AADD(aDBf,{ 'jmb'                 , 'C' ,   13 ,  0 })
// srodstvo naziv
AADD(aDBf,{ 'sr_naz'              , 'C' ,   30 ,  0 })
// kod srodstva
AADD(aDBf,{ 'sr_kod'              , 'N' ,   2 ,  0 })
// prihod vlastiti
AADD(aDBf,{ 'prihod'              , 'N' ,    10 ,  2 })
// udio u izdrzavanju
AADD(aDBf,{ 'udio'                , 'N' ,    3 ,  0 })
// koeficijent odbitka
AADD(aDBf,{ 'koef'                , 'N' ,    10 ,  3 })

if !FILE( KUMPATH + "PK_DATA.DBF" )
	DBCreate2( KUMPATH + "PK_DATA.DBF", aDbf)
endif

CREATE_INDEX( "1", "idradn+ident+STR(rbr)", KUMPATH + "PK_DATA" )

return


// --------------------------------------
// otvara tabele za unos podataka
// --------------------------------------
function o_pk_tbl()
O_PK_RADN
O_PK_DATA
return



// ------------------------------------------
// brisanje poreske kartice radnika
// ------------------------------------------
function pk_delete( cIdRadn )
local nTA

if Pitanje(,"Izbrisati podatke poreske kartice radnika ?", "N") == "N"
	return
endif

nTA := SELECT()
nCnt := 0

o_pk_tbl()

// izbrisi pk_radn
select pk_radn
go top
seek cIdRadn

do while !EOF() .and. field->idradn == cIdRadn
	delete
	++ nCnt
	skip
enddo

// izbrisi pk_data
select pk_data
go top
seek cIdRadn

do while !EOF() .and. field->idradn == cIdRadn
	delete
	++ nCnt
	skip
enddo

if nCnt > 0 
	msgbeep("Izbrisano " + ALLTRIM(STR(nCnt)) + " zapisa !")
endif

return 


// ------------------------------------
// vraca novi zahtjev 
// ------------------------------------
function n_zahtjev()
local nRet := 0
local nTArea := SELECT()
local nBroj := 9999999

select pk_radn
set order to tag "2"

seek nBroj
skip -1

if field->zahtjev = 0
	nRet := 1
else
	nRet := field->zahtjev + 1
endif

set order to tag "1"

select (nTArea)
return nRet



// --------------------------------
// vraca srodstvo za "kod"
// --------------------------------
function g_srodstvo( nId )
local cRet := "???"
local aPom
local nScan

// napuni matricu sa srodstvima
aPom := a_srodstvo()

nScan := ASCAN( aPom, {|xVal| xVal[1] = nId } )

if nScan <> 0
	cRet := aPom[ nScan, 2 ]
endif

return cRet



// ---------------------------------------------
// vraca matricu popunjenu sa srodstvima
// ---------------------------------------------
function a_srodstvo()
local aRet := {}

AADD( aRet, { 1, "Otac" } )
AADD( aRet, { 2, "Majka" } )
AADD( aRet, { 3, "Otac supruznika" } )
AADD( aRet, { 4, "Majka supruznika" } )
AADD( aRet, { 5, "Sin" } )
AADD( aRet, { 6, "Kcerka" } )
AADD( aRet, { 7, "Unuk" } )
AADD( aRet, { 8, "Unuka" } )
AADD( aRet, { 9, "Djed" } )
AADD( aRet, { 10, "Baka" } )
AADD( aRet, { 11, "Djed supruznika" } )
AADD( aRet, { 12, "Baka supruznika" } )
AADD( aRet, { 13, "Bivsi supruznik" } )
AADD( aRet, { 14, "Poocim" } )
AADD( aRet, { 15, "Pomajka" } )
AADD( aRet, { 16, "Poocim supruznika" } )
AADD( aRet, { 17, "Pomajka supruznika" } )
AADD( aRet, { 18, "Pocerka" } )
AADD( aRet, { 19, "Posinak" } )

return aRet


// -----------------------------------------
// lista srodstva u GET rezimu na unosu
// odabir srodstva
// -----------------------------------------
function sr_list( nSrodstvo )
local nXX := m_x
local nYY := m_y

if nSrodstvo > 0
	return .t.
endif

// napuni matricu sa srodstvima
aSrodstvo := a_srodstvo()

// odaberi element
nSrodstvo := _pick_srodstvo( aSrodstvo )

m_x := nXX
m_y := nYY

return .t.

// -----------------------------------------
// uzmi element...
// -----------------------------------------
static function _pick_srodstvo( aSr )
local nChoice := 1
local nRet
local i
local cPom
private GetList:={}
private izbor := 1
private opc := {}
private opcexe := {}

for i:=1 to LEN( aSr )

	cPom := PADL( ALLTRIM(STR( aSr[i, 1] )), 2 ) + ". " + PADR( aSr[i, 2] , 20 )
	
	AADD(opc, cPom)
	AADD(opcexe, {|| nChoice := izbor, izbor := 0 })
	
next

Menu_sc("izbor")

if LastKey() == K_ESC

	nChoice := 0
	nRet := 0
	
else
	nRet := aSr[ nChoice, 1 ]
endif

return nRet


// -------------------------------------------------
// vraca odbitak za clanove po identifikatoru
// -------------------------------------------------
function lo_clan( cIdent, cIdRadn )
local nOdb := 0
local nTArea := SELECT()

select pk_data
set order to tag "1"

seek cIdRadn + cIdent

do while !EOF() .and. field->idradn == cIdRadn ;
		.and. field->ident == cIdent

	nOdb += field->koef
	skip
enddo

select (nTArea)
return nOdb



