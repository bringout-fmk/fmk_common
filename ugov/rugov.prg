#include "sc.ch"


static __partn


// --------------------------------------
// otvara stavke ugovora - robu iz RUGOV
// --------------------------------------
function V_Rugov( cId )
local nLenTbl := 10
local nWidthTbl := 65
private cIdUgov
private GetList:={}
private ImeKol
private Kol

cIdUgov := cId

Box(, nLenTbl, nWidthTbl)

select rugov

set_a_kol(@ImeKol, @Kol)

set cursor on

@ m_x+1,m_y+1 SAY ""

?? "Ugovor:", ugov->id, ugov->naz, ugov->DatOd

__partn := ugov->idpartner

BrowseKey(m_x+3, m_y+1, m_x+ nLenTbl - 1, m_y+ nWidthTbl, ;
    ImeKol, {|Ch| key_handler(Ch, cIdUgov)}, ;
    "id+brisano==cIdUgov + ' '", ;
    cIdUgov, 2,,,{|| .f.})

select ugov
BoxC()

return .t.


// -------------------------------------
// setovanje kolona pregleda
// -------------------------------------
static function set_a_kol(aImeKol, aKol)
aImeKol := {}
aKol := {}

AADD(aImeKol, { "ID roba",   {|| IdRoba} })
AADD(aImeKol, { PADC("Kol.", LEN(pickol)), {|| transform(Kolicina, pickol)} })

if rugov->(fieldpos("cijena"))<>0
  	AADD(aImeKol, { "Cijena", {|| transform(cijena, picdem) },  "cijena"    } )
endif

AADD(aImeKol, { "Rabat",   {|| Rabat}  })
AADD(aImeKol, { "Porez",   {|| Porez}  })

if rugov->(fieldpos("K1"))<>0
	AADD(aImeKol, { "K1", {|| K1},    "K1"    } )
  	AADD(aImeKol, { "K2", {|| K2},    "K2"    } )
endif

if rugov->(fieldpos("dest")) <> 0
	AADD(aImeKol, { "Dest.", {|| get_dest_info( __partn, dest )}, "dest"  } )
endif

for i:=1 to len(aImeKol)
	AADD(aKol, i)
next

return


//------------------------------------------------
// key handler
//------------------------------------------------
static function key_handler(Ch, cIdUgov)
local nRet:=DE_CONT

do case
	case Ch == K_CTRL_N
		nRet := edit_rugov(.t.)
	
	case Ch == K_F2
		nRet := edit_rugov(.f.)

	case Ch==K_CTRL_T
     		if Pitanje(,"Izbrisati stavku ?","N")=="D"
        		delete
     		endif
     		nRet:=DE_DEL
endcase
return nRet



// ---------------------------------
// edit rugov
// ---------------------------------
function edit_rugov(lNovi)
local cIdRoba
local nKolicina
local cDestinacija
local nRabat
local nPorez
local nCijena
local lCijena := .f.
local lK1 := .f.
local lDest := .f.
local cK1
local cK2
local nX := 1
local nBoxLen := 20

cIdRoba:=IdRoba
nKolicina:=kolicina
nRabat:=rabat
nPorez:=porez

if is_dest()
	lDest := .t.
endif

if rugov->(fieldpos("K1")) <> 0
	cK1 := k1
       	cK2 := k2
       	lK1 := .t.
endif

if rugov->(fieldpos("cijena")) <> 0
	nCijena := cijena
	lCijena := .t.
endif

if lDest
	cDestinacija := dest
endif

Box(, 8, 75, .f.)

@ m_x + nX, m_y + 2 SAY PADL("Roba", nBoxLen) GET cIdRoba pict "@!" valid P_Roba(@cIDRoba)

if lDest
	
	++ nX
	@ m_x + nX, m_y + 2 SAY PADL("Destinacija:", nBoxLen) GET cDestinacija pict "@!" valid {|| EMPTY(cDestinacija) .or. p_dest_2( @cDestinacija, __partn )}
	
endif

++ nX

@ m_x + nX, m_y + 2 SAY PADL("Kolicina", nBoxLen) GET nKolicina pict "99999999.999" VALID _val_num( nKolicina )

if lCijena
	++ nX
	@ m_x + nX, m_y + 2 SAY PADL("Cijena", nBoxLen) GET nCijena pict gPICCDEM VALID _val_num( nCijena )
endif

++ nX
@ m_x + nX, m_y + 2 SAY PADL("Rabat", nBoxLen) GET nRabat pict "99.999"
    
++ nX
@ m_x + nX, m_y + 2 SAY PADL("Porez", nBoxLen) GET nPorez pict "99.99"

if lK1
	++ nX
	@ m_x + nX, m_y + 2 SAY PADL("K1", nBoxLen) GET cK1 PICT "@!"
	++ nX
	@ m_x + nX, m_y + 2 SAY PADL("K2", nBoxLen) GET cK2 PICT "@!"
endif

read

BoxC()

if LastKey() == K_ESC
	return DE_CONT
endif

if lNovi
	append blank
       	replace id with cIdUgov
endif

replace idroba with cIdRoba
replace kolicina with nKolicina
replace rabat with nRabat
replace porez with nPorez

if lDest
	replace dest with cDestinacija
endif

if lCijena
	replace cijena with nCijena
endif
      
if lK1
	replace k1 with cK1
	replace k2 with cK2
endif
    
return DE_REFRESH


// ----------------------------------------
// validacija numerika
// ----------------------------------------
static function _val_num( nNum )
local lRet := .t.

if nNum <= 0
	lRet := .f.
endif

if lRet == .f.
	MsgBeep("Vrijednost mora biti > 0 !!!")
endif

return lRet

// ----------------------------------------
// vecina ugovora ima samo jednu stavku
// koja najcesce govi sta ugovor sadrzi
// -----------------------------------------
function g_rugov_opis(cIdUgov)
local cOpis:=""
local nTArea := SELECT()
PushWa()
SELECT RUGOV
seek cIdUgov
cOpis += trim(idroba)+ " " + alltrim(transform(kolicina, pickol)) + " x " + alltrim(transform(cijena, picdem))

PopWa()
select (nTArea)
return cOpis


