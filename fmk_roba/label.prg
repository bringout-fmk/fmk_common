#include "fmk.ch"




// -----------------------------------------
// funkcija za labeliranje barkodova...
// -----------------------------------------
function label_bkod()
local cIBK
local cPrefix
local cSPrefix
local cBoxHead
local cBoxFoot
local lStrings := .f.
local lDelphi := .t.
private cKomLin
private Kol
private ImeKol

O_SIFK
O_SIFV
O_PARTN
O_ROBA
set order to tag "ID"
O_BARKOD
O_PRIPR

lStrings := is_strings()

SELECT PRIPR
private aStampati:=ARRAY(RECCOUNT())

GO TOP

for i:=1 to LEN(aStampati)
	aStampati[i]:="D"
next

// setuj kolone za pripremu...
set_a_kol(@ImeKol, @Kol)

cBoxHead := "<SPACE> markiranje Í <ESC> kraj"
cBoxFoot := "Priprema za labeliranje bar-kodova..."

Box(,20,50)
ObjDbedit("PLBK", 20, 50, {|| key_handler()}, cBoxHead, cBoxFoot, .t. , , , ,0)
BoxC()

if lStrings
	if Pitanje(,"Stampa deklaracije (D/N)?", "D") == "D"
		lDelphi := .f.
	endif
endif

if lDelphi
	label_1_delphi(aStampati)
else
	// stampanje deklaracija...
	label_2_deklar(aStampati)
endif

closeret
return


// ---------------------------------
// dodavanje barkoda...
// ---------------------------------
function dodajBK(cBK)
if EMPTY(cBK) .and. IzFmkIni("BARKOD", "Auto", "N", SIFPATH)=="D" .and. IzFmkIni("BARKOD","Svi","N",SIFPATH)=="D" .and. (Pitanje(,"Formirati Barkod ?","N")=="D")
	cBK:=NoviBK_A()
endif
return .t.


// --------------------------------
// nastimaj pointer na partnera...
// --------------------------------
function seek_partner(cPartner)
select partn
set order to tag "ID"
hseek cPartner
return


// -----------------------------------------------------
// setovanje kolone opcije pregleda labela....
// -----------------------------------------------------
static function set_a_kol(aImeKol, aKol)
aImeKol := {}
aKol := {}

AADD(aImeKol, {"IdRoba"    ,{|| IdRoba }} )
AADD(aImeKol, {"Kolicina"  ,{|| transform( Kolicina, "99999999.9" ) }} )
AADD(aImeKol, {"Stampati?" ,{|| bk_stamp_dn( aStampati[RECNO()] ) }} )

aKol:={}
for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return


// --------------------------------
// prikaz stampati ili ne stampati
// --------------------------------
static function bk_stamp_dn(cDN)
local cRet := ""
if cDN == "D"
	cRet := "-> DA <-"
else
	cRet := "      NE"
endif

return cRet



// --------------------------------
// Obrada dogadjaja u browse-u 
// tabele "Priprema za labeliranje 
// bar-kodova"
// --------------------------------
static function key_handler()
if Ch==ASC(' ')
	if aStampati[recno()]=="N"
		aStampati[recno()] := "D"
	else
		aStampati[recno()] := "N"
	endif
	return DE_REFRESH
endif
return DE_CONT



