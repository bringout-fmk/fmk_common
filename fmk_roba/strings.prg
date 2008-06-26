#include "fmk.ch"


// otvaranje sifrarnika strings
function p_strings(cId, dx, dy)
local nTArea := SELECT()
private ImeKol
private Kol

if !SigmaSIF("STRING")
	MsgBeep("Opcija nedostupna !!!")
	return
endif

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


// *******************************************
// CHK funkcije ....
// *******************************************

// da li je definisana opcija strings
function is_strings()
local nTArea := SELECT()
local lRet := .f.
O_ROBA
if roba->(fieldpos("STRINGS")) <> 0
	lRet := .t.
endif
select (nTArea)
return lRet


// provjerava da li roba ima definisan string
function is_roba_strings(cIDRoba)
local lRet := .f.
local nTArea := SELECT()
O_ROBA
set order to tag "ID"
go top
seek cIdRoba
if FOUND() .and. field->strings <> 0
	lRet := .t.
endif
select (nTArea)
return lRet


// uporedi nizove...
static function arr_integ_ok(aModArr, aDefArr)
local lRet := .f.
return lRet

// *******************************************
// GET funkcije.....
// *******************************************


// vraca naziv odabrane grupe...
function g_roba_grupe(cGrupa)
local nSelection := 0
local aGrupe := {}

aGrupe := get_strings("R_GRUPE", .t.)

// otvori meni i vrati odabir
nSelection := arr_menu(aGrupe, "R_GRUPE")
		
cGrupa := g_naz_byid(nSelection)

return .t.


// vraca polje strings->naz po id pretrazi
static function g_naz_byid(nId)
local cNaz := ""
select strings
set order to tag "1"
hseek STR(nId,10,0)

if FOUND()
	cNaz := TRIM(field->naz)
endif

return cNaz


// vraca strings->id za grupu iz stringa...
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


// vraca oznaku atributa iz id-a
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


// vraca oznaku atributa-veze iz id-a
static function g_attv_byid(nId)
local nAtribut := 0

select strings
set order to tag "1"
hseek STR(nId,10,0)

if FOUND()
	nAtribut := field->veza_1
endif

return nAtribut




// vraca matricu sa nazivima po uslovu "cOznaka"
function get_strings(cOznaka, lAktivni)
local nTRec := RecNo()
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
seek PADR(cOznaka, 10)

do while !EOF() .and. field->oznaka == PADR(cOznaka, 10)
	
	if lAktivni
		// dodaj samo aktivne
		if field->aktivan <> "D"
			skip
			loop
		endif
	endif
	
	AADD(aRet, {field->id, TRIM(field->naz) })
	
	skip
enddo

select (nTArea)
go (nTRec)

return aRet



// vraca matricu sa stringovima po uslovu "nIdString"
function get_str_val(nIdString)
local nTRec := RecNo()
local nTArea := SELECT()
local aRet := {}
local aTemp := {}
local cStrings := ""
local aStrings := {}
local i
local nIdStr
local nIdAttr

O_STRINGS
select strings
// id
set order to tag "1"
go top
seek STR(nIdString, 10, 0)

if FOUND()
	if field->aktivan == "D" .and. field->veza_1 == -1
		cStrings := TRIM(field->naz)
	endif
else
	fill_strings(@aRet)
	return aRet
endif

if !EMPTY(ALLTRIM(cStrings))

	// sada kada sam dobio strings napuni matricu aRet
	aStrings := TokToNiz(cStrings, "#")
	// 15#16
	
	if LEN(aStrings) > 0
		
		nIdStr := VAL( aStrings[1] )
		
		// prvo dodaj grupu ....
		nIdAttr := g_gr_byid( nIdStr )
		
		// naziv grupe
		cPom := g_naz_byid(nIdAttr)
		
		// filuj grupu i dostupne atribute....
		fill_str_atr(@aRet, nIdAttr, cPom)
		
		// sada napuni atribute ...
		
		// 15#16...
		for i:=1 to LEN(aStrings)
		
			nIdStr := VAL(aStrings[i])
			nIdAttr := g_attr_byid(nIdStr)
			nIdAttV := g_attv_byid(nIdStr)
			
			nScan := ASCAN(aRet, {|xVal| xVal[2] == nIdAttV })

			if nScan == 0
				AADD(aRet, { nIdStr, nIdAttV, "R_G_ATTRIB", g_naz_byid(nIdAttr) + ":" , g_naz_byid(nIdStr) })		
			else
				aRet[nScan, 1] := nIdStr
				aRet[nScan, 2] := nIdAttV
				aRet[nScan, 3] := "R_G_ATTRIB"

				cPom := g_naz_byid(nIdAttr) + ":"

				aRet[nScan, 4] := cPom

				cPom := g_naz_byid(nIdStr)

				aRet[nScan, 5] := cPom
			endif
		next
	endif
else
	fill_strings(@aRet)
endif

select (nTArea)
go (nTRec)

return aRet



// **********************************************
// FILL funkcije 
// **********************************************


// filuj prazan aStrings
static function fill_strings(aStrings)
AADD(aStrings, { 0, 0, "R_GRUPE", "Grupa:", "-" })
return

// filuj prazan aArr
static function fill_arr(aArr)
AADD(aArr, { 0, "-" } )
return


// napuni matricu sa atributima...
static function fill_str_attr(aStrings, nIdGrupa, cNazGrupa)
local cGrOzn := PADR("R_GRUPE", 10)
local cAtOzn := PADR("R_G_ATTRIB", 10)
local i
local nTArea := SELECT()

// ponovo napravi aStrings
aStrings := {}
AADD(aStrings, { nIdGrupa, nIdGrupa, cGrOzn, "Grupa:", cNazGrupa })

O_STRINGS
select strings
// oznaka + veza_1
set order to tag "3"
seek cAtOzn + STR(nIdGrupa, 10, 0)

if FOUND()
	do while !EOF() .and. field->oznaka == cAtOzn;
			.and. field->veza_1 == nIdGrupa
			
		if field->aktivan <> "D"
			skip
			loop
		endif
			
		AADD(aStrings, { 0, field->id, cAtOzn, TRIM(field->naz) + ":", "-"})
		
		skip
	enddo
endif

select (nTArea)

return



// **********************************************
// MENI funkcije
// **********************************************

// glavni meni strings
function m_strings(nIdString, cRoba)
local aStrings := {}
local aMStrings := {}
local nRet := -99

// aStrings { idstr, idatr, oznaka, naz_atributa, vrijednost }
//              9  ,  6   , "R_G_ATTRIB", "proizvodjac", "proizvodjac 1"

if ( nIdString == 0 )
	// ako je strings == 0 napravi praznu matricu...
	fill_strings(@aStrings)
else
	// generisi matricu na osnovu podataka...
	aStrings := get_str_val(nIdString) 
endif

// uzmi za usporedbu matricu strings
aMStrings := aStrings

// non stop do izlaska regenerisi meni
do while .t.
	if gen_m_str(@aStrings) == 0
		
		if !arr_integ_ok(aStrings, aMStrings) .and. Pitanje(,"Snimiti promjene?","D") == "D"
			// snimi promjene napravljene na nizu
			save_str_state(aStrings, cRoba)
		endif
		
		exit
	endif
enddo

return


// generisi menij sa aStrings
function gen_m_str(aStrings)
local cPom
private izbor := 1
private opc := {}
private opcexe := {}

for i:=1 to LEN(aStrings)
	
	cPom := PADL(aStrings[i, 4], 20)
	cPom += " "
	if aStrings[i, 5] == "-"
		cPom += PADR("nije setovano", 30)
	else
		cPom += PADR(aStrings[i, 5], 30)
	endif
	
	AADD(opc, cPom )
	AADD(opcexe, {|| key_strings(@aStrings, izbor), izbor := 0 })
	
next

Menu_SC("str")

ESC_RETURN 0

// test - debug / print matrice
//pr_strings(aStrings)

return 1


// obrada dogadjaja menija strings na ENTER
static function key_strings(aStrings, nIzbor)
local cOznaka
local nTIzbor
local cAkcija

// 10001
nTIzbor := nIzbor

// "" - enter
// "K_CTRL_N" - novi
// "K_CTRL_T" - brisi ...
cAkcija := what_action(nTIzbor)

// 1
nIzbor := retitem(nIzbor)

cOznaka := aStrings[nIzbor, 3]

do case 
	// ako su grupe....
	case ALLTRIM(cOznaka) == "R_GRUPE"
		
		// enter
		if cAkcija == ""
			// definisi grupu
			def_group(@aStrings, nIzbor)
		else
			// ostale tipke....
			// definisi attribute - veze
			def_attveze(@aStrings, nIzbor, cAkcija)
		endif

	// ako su atributi veze
	case ALLTRIM(cOznaka) == "R_G_ATTRIB"
		
		if cAkcija == ""
			// odabir atributa....
			def_attrib(@aStrings, nIzbor)
		else
			// ostale tipke....
			// definisi attribute - veze
			def_attveze(@aStrings, nIzbor, cAkcija)
		endif

endcase

return


// funkcij za iscrtavanje menija sa nizom aArr te citanjem odabira
static function arr_menu(aArr, cGrupa, nGrId)
local i
local cPom
local nArrRet := 0
local nReturn := -99
private izbor := 1
private opc := {}
private opcexe := {}

if LEN(aArr) == 0
	fill_arr(@aArr)
endif

for i:=1 to len(aArr)
	if (aArr[i, 2] == "-")
		cPom := PADR("nema setovanih stavki",30)
	else
		cPom := PADR(aArr[i, 2], 30)
	endif
	AADD(opc, cPom)
	AADD(opcexe, {|| key_array(@nArrRet, aArr, izbor, cGrupa, nGrId), izbor := 0 })
next

Menu_SC("arr")

if nArrRet > 0
	nReturn := aArr[nArrRet, 1]
endif

if nArrRet == 0
	nReturn := 0
endif

return nReturn


// obrada dogadjaja tipke na array menu
static function key_array(nArrRet, aArr, nIzbor, cGrupa, nGrId)
local nTIzbor := nIzbor
local cAction

nIzbor := retitem(nTIzbor)
cAction := what_action(nTIzbor)

if nGrId == nil
	nGrId := aArr[nIzbor, 1]
endif

do case
	case cAction == "K_CTRL_N"
		add_s_item(aArr, cGrupa, nGrId, nIzbor)
		nArrRet := -99
		
	case cAction == "K_F2"
		edit_s_item(aArr, cGrupa, nGrId, nIzbor)
		nArrRet := -99
	case cAction == "K_CTRL_T"
		del_s_item(aArr, cGrupa, nGrId, nIzbor)
		nArrRet := -99
	otherwise
		nArrRet := nIzbor		
endcase

return


// dodaje novi zapis u strings
static function add_s_item(aArr, cGrupa, nGrId, nIzbor, nVeza_1)
local cItNaz := SPACE(200)
local nNStr1 := 0
local nNStr2 := 0
local nTArea := SELECT()
private getlist:={}

Box(,1,60)
	@ m_x+1, m_y+2 SAY "Naziv:" GET cItNaz PICT "@S40"
	read
BoxC()

if Pitanje(,"Dodati novu stavku (D/N)?", "D") == "N"
	return
endif

O_STRINGS

// daj novi id
str_new_id(@nNStr1)

select strings
append blank
replace id with nNStr1
replace oznaka with cGrupa
replace aktivan with "D"
replace naz with cItNaz

// ako nisu grupe.... dodaj odmah veze atributa
if cGrupa <> "R_GRUPE"
	add_att_veza(nGrId, nNStr1, cItNaz)
endif

select (nTArea)

return


// dodaje attribute - veze...
static function add_att_veza(nVeza_1, nVeza_2, cNaz)
local nNewId
local nTArea := SELECT()
local nRet := 0

O_STRINGS
select strings 
set order to tag "5"
go top
seek PADR("R_G_ATTRIB", 10) + STR(nVeza_1, 10, 0) + STR(nVeza_2, 10, 0)

if FOUND() .and. field->aktivan == "D"
	
	// vec postoji ova veza...
	nRet := field->id
	
	return nRet
endif

// daj novi id
str_new_id(@nNewId)

select strings	
append blank
replace id with nNewId
replace veza_1 with nVeza_1
replace veza_2 with nVeza_2
replace oznaka with "R_G_ATTRIB"
replace aktivan with "D"
replace naz with cNaz

select (nTArea)

nRet := nNewId

return nRet


// ispravka zapisa u strings
static function edit_s_item(aArr, cGrupa, nGrId, nIzbor, nVeza_1)
local cItNaz := SPACE(200)
local nTArea := SELECT()
local nStrId := aArr[nIzbor, 1]
local cVal
private getlist:={}

if Pitanje(,"Ispraviti stavku (D/N)?", "D") == "N"
	return
endif

O_STRINGS
select strings
set order to tag "1"
go top
seek STR(nStrId, 10, 0)

if FOUND()
	Scatter()
	Box(,1,60)
		@ m_x+1, m_y+2 SAY "Naziv:" GET _naz PICT "@S40"
		read
	BoxC()
	Gather()
endif

select (nTArea)
return


// brisanje zapisa u strings
static function del_s_item(aArr, cGrupa, nGrId, nIzbor, nVeza_1)
local nNStrId := 0
local nTArea := SELECT()
local nStrId := aArr[nIzbor, 1]

if Pitanje(,"Izbrisati stavku (D/N)?", "D") == "N"
	return
endif

O_STRINGS
select strings
set order to tag "1"
go top
seek STR(nStrId, 10, 0)

if FOUND()
	Scatter()
	_aktivan := "N"
	Gather()
endif

select (nTArea)

return


// ********************************************
// DEF funkcije....
// ********************************************


// definisanje grupe
static function def_group(aStrings, nIzbor)
local aGrupe := {}
local nSelection
local cPom := ""

nSelection := aStrings[nIzbor, 2]

// otvori meni sa dostupnim grupama...
if (nSelection == 0) .or. (nSelection <> 0 .and. Pitanje(,"Promjeniti grupu artikla ?", "D") == "D")

	nSelection := -99

	do while nSelection == -99
		// generisi matricu sa grupama... (aktivnim)
		aGrupe := get_strings("R_GRUPE", .t.)

		// otvori meni i vrati odabir
		nSelection := arr_menu(aGrupe, "R_GRUPE")
		
		if nSelection == 0
			return
		endif
		
	enddo
	
	// uzmi naziv grupe
	cPom := g_naz_byid(nSelection)

	// regenerisi niz aStrings sa pripadajucim atributima
	// grupa + atributi
	fill_str_attr(@aStrings, nSelection, cPom)
	
endif

return


// definisanje grupe
static function def_attveze(aStrings, nIzbor, cAkcija)
local nAttrib := {}
local nSelection := -99
// id grupe
local nIdGrupa := aStrings[1, 2]
local cAttNaz := ""
local nScan

do while nSelection == -99
	
	// izvuci u matricu sve atribute...
	nAttrib := get_strings("R_D_ATTRIB", .t.)

	nSelection := arr_menu(@nAttrib, "R_D_ATTRIB", nIdGrupa)

	if nSelection == 0
		return
	endif

	if nSelection > 1
		// ako je nesto odabrano onda dodaj vezu sa grupom
		cAttNaz := g_naz_byid(nSelection)
		nAttVeza := add_att_veza(nIdGrupa, nSelection, cAttNaz)

		nScan := ASCAN(aStrings, {|xVal| xVal[2] == nAttVeza })
		
		// napuni matricu sa atributima... ako ne postoji...
		if nScan == 0
			AADD(aStrings, { 0, nAttVeza, PADR("R_G_ATTRIB", 10), ALLTRIM(cAttNaz) + ":", "-" })
		endif
	endif
enddo

return



// definisanje atributa...
static function def_attrib(aStrings, nIzbor)
local cAttrVal
local nDozId := aStrings[nIzbor, 2]
local nAttrId

cAttrVal := SPACE(200)

Box(,1,60)
	@ m_x+1, m_y+2 SAY "Unesi/trazi vrijednost:" GET cAttrVal PICT "@S30" VALID find_attr(@cAttrVal, nDozId, @nAttrId)
	read
BoxC()

if LastKey() == K_ESC
	cAttrVal := ""
	return
endif

// napuni matricu sa trazenim pojmom

aStrings[nIzbor, 1] := nAttrId
aStrings[nIzbor, 5] := cAttrVal
	
return


// ******************************************
// DB funkcije ...
// ******************************************

// dodaje u strings dozvoljenu vrijednost atributa
static function add_atr_doz(cVal, nVeza_1)
local nRet := 0
local nNewId := 0
local nTArea := SELECT()

O_STRINGS
select strings
set order to tag "1"

str_new_id(@nNewId)

append blank
replace id with nNewId
replace oznaka with PADR("ATTRIB_DOZ", 10)
replace veza_1 with nVeza_1
replace naz with cVal
replace aktivan with "D"

select (nTArea)

return nNewId


// pronadji dozvoljenu vrijednost...
static function find_attr(cAttr, nDozId, nAttrId)
local aAttrVal := {}
local nTArea := SELECT()
local cOznaka := PADR("ATTRIB_DOZ", 10)
local cSeek 

O_STRINGS
select strings
set order to tag "4"
go top

cSeek := cOznaka + STR(nDozId, 10, 0)
if !EMPTY(cAttr)
	cSeek += ALLTRIM(cAttr)
endif

seek cSeek

if FOUND()
	// nafiluj matricu dostupnih vrijednosti....
	do while !EOF() .and. field->oznaka == cOznaka ;
			.and. field->veza_1 == nDozId

		if field->aktivan <> "D"
			skip
			loop
		endif

		// pregledaj i po nazivu
		if !EMPTY(ALLTRIM(cAttr))
			if ALLTRIM(UPPER(field->naz)) = ALLTRIM(UPPER(cAttr))
				//
			else
				skip
				loop
			endif
		endif
		
		AADD(aAttrVal, {field->id, TRIM(field->naz)})
		
		skip
	enddo
	
	if LEN(aAttrVal) > 0
	
		// otvori meni sa dozvoljenim vrijednostima
		nAttrId := arr_menu(aAttrVal)
		
		// vrijednost atributa
		cAttr := g_naz_byid(nAttrId)
		
		return .t.
	endif
endif

// trazeni pojam ne postoji - dodaj ga!
MsgBeep("Trazeni pojam ne postoji!")

if Pitanje(, "Dodati novi pojam ? ", "N") == "D"
	private getlist:={}
	// dodaj novi pojam....
	Box(,4, 60)
		cAttr := SPACE(200)
		@ m_x+1, m_y+2 SAY "Unos novog pojma..." 
		@ m_x+3, m_y+2 SAY "pojam->" GET cAttr PICT "@S40"
		read
	BoxC()

	// dodaj novi pojam...
	nAttrId := add_atr_doz(cAttr, nDozId)
	cAttr := g_naz_byid(nAttrId)
endif

return .t.


// snimi promjene u polje roba->strings
static function save_str_state(aStrings, cRoba)
local cStr := ""
local nNewId := 0
local nStrNId := 0
// preskacem prvi jer je to grupa
for i:=2 to LEN(aStrings)
	if aStrings[i, 1] <> 0
		cStr += ALLTRIM(STR(aStrings[i, 1])) + "#"
	endif
next

cStr := LEFT(cStr, LEN(cStr) - 1)

str_new_id(@nNewId)

O_STRINGS
set order to tag "2"
seek cRoba

if !FOUND()
	append blank
	replace id with nNewId
	replace veza_1 with -1
	replace oznaka with cRoba
	replace aktivan with "D"
endif

replace naz with cStr
nStrNId := strings->id

select roba
Scatter()
_strings := nStrNId
Gather()

return

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
CREATE_INDEX("3", "OZNAKA+STR(VEZA_1,10,0)+STR(ID,10,0)", SIFPATH + "STRINGS" )
CREATE_INDEX("4", "OZNAKA+STR(VEZA_1,10,0)+NAZ", SIFPATH + "STRINGS" )
CREATE_INDEX("5", "OZNAKA+STR(VEZA_1,10,0)+STR(VEZA_2,10,0)", SIFPATH + "STRINGS" )

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
local nNewId := 0

select strings
set order to tag "1"
go bottom

nNewId := field->id + 1

select (nTArea)
go (nTRec)

nId := nNewId

return .t.


static function pr_strings(aStrings)
local i

START PRINT CRET

for i:=1 to LEN(aStrings)

 ? aStrings[i,1], aStrings[i,2], aStrings[i,3], aStrings[i,4], aStrings[i,5]

next

END PRINT
FF

return

