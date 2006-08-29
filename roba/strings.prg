#include "sc.ch"


// kreiranje tabele strings
function cre_strings()
local aDbf

// STRINGS.DBF
if !File( SIFPATH + "STRINGS.DBF" )
	aDBf := g_str_fields()
   	DbCreate2( SIFPATH + "STRINGS.DBF", aDbf)
endif

CREATE_INDEX("1", "STR(ID,10,0)", SIFPATH + "STRINGS" )
CREATE_INDEX("2", "OZNAKA+STR(ID,10,0)", SIFPATH + "STRINGS" )

return


// vraca matricu sa definicijom polja
static function g_str_fields()
// aDbf => 
//    id   veza_1   veza_2   oznaka   aktivan   naz
// -------------------------------------------------------------
//  (grupe)
//     1                     R_GRUPE     D      obuca
//     2                     R_GRUPE     D      kreme
//  (atributi)
//     3                     R_D_ATRIB   D      proizvodjac
//     4                     R_D_ATRIB   D      lice
//     5                     R_D_ATRIB   D      sastav
//  (grupe - atributi)
//     6       1         3   R_G_ATRIB   D      obuca / proizvodjac
//     7       1         4   R_G_ATRIB   D      obuca / lice
//     8       2         5   R_G_ATRIB   D      kreme / sastav
//  (dodatni atributi - dozvoljene vrijednosti)
//     9       6             ATRIB_DOZ   D      proizvodjac 1
//    10       6             ATRIB_DOZ   D      proizvodjac 2
//    11       6             ATRIB_DOZ   D      proizvodjac 3
//    12       6             ATRIB_DOZ   D      proizvodjac n...
//    13       7             ATRIB_DOZ   D      lice 1
//    14       7             ATRIB_DOZ   D      lice 2 ...
//  (vrijednosti za artikle)
//    15      -1             01MCJ12002  D      9#13 
//    16      -1             01MCJ13221  D      10#14
// itd....

aDbf := {}
AADD(aDBf,{ "ID"       , "N", 10, 0 })
AADD(aDBf,{ "VEZA_1"   , "N", 10, 0 })
AADD(aDBf,{ "VEZA_2"   , "N", 10, 0 })
AADD(aDBf,{ "OZNAKA"   , "C", 10, 0 })
AADD(aDBf,{ "AKTIVAN"  , "C",  1, 0 })
AADD(aDBf,{ "NAZ"      , "C",200, 0 })
return aDbf



// novi id za tabelu strings
function str_new_id( nId )
local nTArea := SELECT()
local nTRec := RecNo()
local cDbFilter := DBFilter()
local nNewId := 0

select strings
set filter to
set order to tag "1"
go bottom

nNewId := field->id + 1

select (nTArea)
set filter to &cDbFilter
go (nTRec)

nId := nNewId

return .t.


// vraca matricu sa nazivima po uslovu "cOznaka"
function get_strings(cOznaka, lAktivni)
local cDbFilter := DBFilter()
local nRecNo := RecNo()
local nTArea := SELECT()
local aRet := {}

if lAktivni == nil
	lAktivni := .t.
endif

O_STRINGS
select strings
// oznaka + id
set order to tag "2"
go top
seek cOznaka

do while !EOF() .and. field->oznaka == cOznaka
	
	if lAktivni
		// dodaj samo aktivne
		if field->aktivan <> "D"
			skip
			loop
		endif
	endif
	
	AADD(aRet, {field->id, field->naz})
	
	skip
enddo

select (nTArea)
set filter to &cDBFilter
go (nTRec)

return aRet



// vraca matricu sa stringovima po uslovu "cOznaka"
function get_str_val(cOznaka)
local cDbFilter := DBFilter()
local nRecNo := RecNo()
local nTArea := SELECT()
local aRet := {}
local cStrings := ""
local aStrings := {}
local nGrupa
local nAttr
local nTmpId
local i

O_STRINGS
select strings
// oznaka + id
set order to tag "2"
seek cOznaka

if FOUND()
	// dakle, interesuje nas samo aktivni
	if field->aktivan == "D" .and. field->veza_1 == -1
		cStrings := TRIM(field->naz)
	endif
endif

if !EMPTY(cStrings)

	// sada kada sam dobio strings napuni matricu aRet
	aStrings := TokToNiz(cStrings, "#")
	// 15#16

	if LEN(aStrings) > 0
		
		nTmpId := VAL( aStrings[1, 1] )
		
		// prvo dodaj grupu ....
		nGrupa := g_gr_byid( nTmpId )
		// npr: { 1, "R_GRUPE", "obuæa"}
		
		AADD(aRet, { nGrupa, "R_GRUPE", g_naz_byid(nGrupa) })
	
		// sada atributi....
		// 15#16
		for i:=1 to LEN(aStrings)
		
			// { 15, "Proizvodjac", "proizvodjac 1 xxxxx"}
			
			nTmpId := VAL(aStrings[i, 1])
			nAttr := g_attr_byid(nTmpId)
			
			AADD(aRet, { nTmpId, g_naz_byid(nAttr), g_naz_byid(nTmpId) })		
		next
	endif
endif

select (nTArea)
set filter to &cDBFilter
go (nTRec)

return aRet



// vraca string po id pretrazi
static function g_naz_byid(nId)
local cNaz := ""
select strings
set order to tag "1"
hseek STR(nId,10,0)

if FOUND()
	cNaz := TRIM(field->naz)
endif

return cNaz


// vrati grupu iz stringa...
static function g_gr_byid(nId)
local nVeza_1
local nGrupa := 0

select strings
set order to tag "1"
hseek STR(nId,10,0)

if FOUND()
	nVeza_1 := field->veza_1
	
	// sada trazi grupe - atribute
	hseek STR(nVeza_1, 10, 0)
	
	if FOUND()
		// dobio sam grupu
		nGrupa := field->veza_1
	endif
endif

return nGrupa



// vrati atribut iz stringa...
static function g_attr_byid(nId)
local nVeza_1
local nVeza_2
local nAtribut := 0

select strings
set order to tag "1"
hseek STR(nId,10,0)

if FOUND()
	nVeza_1 := field->veza_1
	
	// sada trazi grupe - atribute
	hseek STR(nVeza_1, 10, 0)
	
	if FOUND()
		// dobio sam atribut
		nAtribut := field->veza_2
	endif
endif

return nAtribut



// otvaranje sifrarnika strings
function p_strings(cId, dx, dy)
local nTArea := SELECT()
private ImeKol
private Kol

O_STRINGS
set_a_kol(@ImeKol, @Kol)

select (nTArea)

return PostojiSifra(F_STRINGS, "1", 10, 65, "Strings", @cId, dx, dy, {|Ch| key_handler(Ch)})


// setovanje kolona tabele
static function set_a_kol(aImeKol, aKol)
aImeKol := {}
aKol := {}

AADD(aImeKol, {padc("ID", 10), {|| id }, "id", {|| inc_id(@wId), .f.}, {|| .t.} })
AADD(aImeKol, {padc("Veza 1", 10), {|| veza_1}, "veza_1", {|| .t.}, {|| .t.}})
AADD(aImeKol, {padc("Veza 2", 10), {|| veza_2}, "veza_2", {|| .t.}, {|| .t.}})
AADD(aImeKol, {padc("Oznaka", 10), {|| oznaka}, "oznaka", {|| .t.}, {|| .t.}})
AADD(aImeKol, {padc("Aktivan", 7), {|| aktivan}, "aktivan", {|| .t.}, {|| .t.}})
AADD(aImeKol, {padc("Naziv", 20), {|| PADR(naz, 20)}, "naz", {|| .t.}, {|| .t.}})

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return


// key handler
static function key_handler()
return DE_CONT


// uvecaj ID
static function inc_id(wId)
local lRet:=.t.

if ((Ch==K_CTRL_N) .or. (Ch==K_F4))
	if (LastKey()==K_ESC)
		return lRet:=.f.
	endif
	
	nRecNo:=RecNo()
	
	str_new_id(@wId)
	
	AEVAL(GetList,{|o| o:display()})
endif
return lRet


