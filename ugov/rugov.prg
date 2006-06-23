#include "sc.ch"


// --------------------------------------
// otvara stavke ugovora - robu iz RUGOV
// --------------------------------------
function V_Rugov( cId )
private cIdUgov
private GetList:={}
private ImeKol
private Kol

cIdUgov := cId

Box(,15,50)

select rugov

set_a_kol(@ImeKol, @Kol)

set cursor on

@ m_x+1,m_y+1 SAY ""

?? "Ugovor:", ugov->id, ugov->naz, ugov->DatOd

BrowseKey(m_x+3, m_y+1, m_x+14, m_y+50, ImeKol, {|Ch| key_handler(Ch, cIdUgov)}, ;
          "id+brisano==cIdUgov+' '", cIdUgov, 2,,,{|| .f.})

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
AADD(aImeKol, { "Kolicina", {|| Kolicina} })
AADD(aImeKol, { "Rabat",   {|| Rabat}  })
AADD(aImeKol, { "Porez",   {|| Porez}  })

if rugov->(fieldpos("cijena"))<>0
  	AADD(aImeKol, { "Cijena", {|| cijena},  "cijena"    } )
endif

if rugov->(fieldpos("K1"))<>0
	AADD(aImeKol, { "K1", {|| K1},    "K1"    } )
  	AADD(aImeKol, { "K2", {|| K2},    "K2"    } )
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
local nRabat
local nPorez
local nCijena
local lCijena := .f.
local lK1 := .f.
local cK1
local cK2
local nX := 1
local nBoxLen := 20

cIdRoba:=IdRoba
nKolicina:=kolicina
nRabat:=rabat
nPorez:=porez

if rugov->(fieldpos("K1")) <> 0
	cK1 := k1
       	cK2 := k2
       	lK1 := .t.
endif

if rugov->(fieldpos("cijena")) <> 0
	nCijena := cijena
	lCijena := .t.
endif

Box(,7,75,.f.)

@ m_x + nX, m_y + 2 SAY PADL("Roba", nBoxLen) GET cIdRoba pict "@!" valid P_Roba(@cIDRoba)

++ nX
@ m_x + nX, m_y + 2 SAY PADL("Kolicina", nBoxLen) GET nKolicina pict "99999999.999"

if lCijena
	++ nX
	@ m_x + nX, m_y + 2 SAY PADL("Cijena", nBoxLen) GET nCijena pict gPICCDEM
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

if lCijena
	replace cijena with nCijena
endif
      
if lK1
	replace k1 with cK1
	replace k2 with cK2
endif
    
return DE_REFRESH



