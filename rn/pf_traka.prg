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


#include "sc.ch"

static LEN_KOLICINA := 9
static LEN_CIJENA := 12
static LEN_VRIJEDNOST := 14

static DEC_KOLICINA := 2
static DEC_CIJENA := 2 
static DEC_VRIJEDNOST := 2


function pf_traka_print()
*{
drn_open()

// stampaj racun
st_pf_traka()

return
*}


function f7_pf_traka(lSilent)
*{
local lPfTraka

if lSilent == nil
	lSilent := .f.
endif

isPfTraka(@lPfTraka)

if !lSilent .and. Pitanje(,"Stampati poresku fakturu za zadnji racun (D/N)?", "D") == "N"
	return
endif

drn_open()

if !lPfTraka
	if !get_kup_data()
		return
	endif
endif

st_pf_traka()

if !lPfTraka 
	AzurKupData(gIdPos)
endif

return
*}


function read_kup_data()
*{
local cKNaziv
cKNaziv := get_dtxt_opis("K01")
if cKNaziv == "-"
	return .f.
endif
return .t.
*}


function get_kup_data()
*{

local cKNaziv := SPACE(35)
local cKAdres := SPACE(35)
local cKIdBroj := SPACE(13)
local cUnosOk := "D"
local dDatIsp := DATE()
local GetList:={}
local nMX
local nMY

SET CURSOR ON
if read_kup_data()
	cKNaziv:=PADR(get_dtxt_opis("K01"), 35)
	cKAdres:=PADR(get_dtxt_opis("K02"), 35)
	cKIdBroj:=PADR(get_dtxt_opis("K03"), 13)
	dDatIsp:= get_drn_di()
	if dDatIsp == nil
		dDatIsp := CTOD("")
	endif
endif

Box(,7, 65)
	
	nMX := m_x
	nMY := m_y
	
	@ 1+m_x, 2+m_y SAY "Podaci o kupcu:" COLOR "I"
	@ 2+m_x, 2+m_y SAY "Naziv (pravnog ili fizickog lica):" GET cKNaziv VALID !Empty(cKNaziv) .and. get_arr_kup_data(@cKNaziv, @cKAdres, @cKIdBroj) PICT "@S20"
	read
	
	m_x := nMX
	m_y := nMY
	
	@ 3+m_x, 2+m_y SAY "Adresa:" GET cKAdres VALID !Empty(cKAdres)
	@ 4+m_x, 2+m_y SAY "Identifikacijski broj:" GET cKIdBroj VALID !Empty(cKIdBroj)
	@ 5+m_x, 2+m_y SAY "Datum isporuke " GET dDatIsp

	 @ 7+m_x, 2+m_y SAY "Unos podataka ispravan (D/N)?" GET cUnosOk VALID cUnosOk $ "DN" PICT "@!"
	read
	
BoxC()

if (cUnosOk <> "D") .or. (LASTKEY()==K_ESC)
	return .f.
endif
	
//dodaj parametre u drntext
add_drntext("K01", cKNaziv)
add_drntext("K02", cKAdres)
add_drntext("K03", cKIdBroj)
add_drn_di(dDatIsp)

return .t.
*}

function pf_traka_line(nRazmak)
local cPom
cPom := SPACE(nRazmak)
cPom += REPLICATE("-", LEN_KOLICINA) + " " 
cPom += REPLICATE("-", LEN_CIJENA) + " " 
cPom += REPLICATE("-", LEN_VRIJEDNOST)
return cPom

function st_pf_traka()
*{
local cBrDok
local dDatDok
local aRNaz
local cArtikal
local cRazmak := SPACE(1)
local cLine
local lViseRacuna := .f.
local nPFeed
local cSjeTraSkv
local cOtvLadSkv
local nLeft1 := 22
local nRedukcija
local nSetCijene
local lStRobaId

START PRINT2 CRET gLocPort, SPACE(5)

cLine := pf_traka_line(1)

get_rb_vars(@nPFeed, @cOtvLadSkv, @cSjeTraSkv, @nSetCijene, @lStRobaId, @nRedukcija)

hd_rb_traka(nRedukcija)

kup_rb_traka()

select drn
go top
// ako postoji vise zapisa onda ima vise racuna
if RecCount2() > 1
	lViseRacuna := .t.
endif

select rn
set order to tag "1"
go top

// mjesto i datum racuna
? cRazmak + drn->vrijeme + PADL(get_rn_mjesto() + "," + DToC(drn->datdok), 32)
? cRazmak + "Datum isporuke: " + DTOC(drn->datisp)

? cLine

// broj racuna
? SPACE(12) + "FAKTURA br." + ALLTRIM(drn->brdok) 

? cLine

// opis kolona
? " R.br   Roba (sif - naziv, jmj)"
? cLine
? cRazmak + PADC("kolicina", LEN_KOLICINA)  + " " + PADC("C.bez PDV", LEN_CIJENA) + PADC(" Uk b.PDV  ", LEN_VRIJEDNOST)
if ROUND(drn->ukpopust,3) <> 0
? cRazmak + PADC("-popust", LEN_KOLICINA) + PADC("C.2.bez PDV", LEN_CIJENA)
endif
? cLine

select rn

// data
do while !EOF()

	// rbr
	? cRazmak + rn->rbr

	// artikal
	cArtikal := ALLTRIM(field->idroba) + " - " + ALLTRIM(field->robanaz) +  " (" + ALLTRIM(rn->jmj) + ")"
	aRNaz := SjeciStr(cArtikal, 34)
	for i:=1 to LEN(aRNaz)
		if i == 1
			?? cRazmak + aRNaz[i]
		else
			? SPACE(5) + aRNaz[i]
		endif
	next

	// kolicina, jmj, cjena sa pdv
	? cRazmak + STR(rn->kolicina, LEN_KOLICINA, DEC_KOLICINA), STR(rn->cjenbpdv, LEN_CIJENA, DEC_CIJENA)
	
	
	// ukupna vrijednost bez pdv-a je uvijek bez popusta iskazana
	// jer se popust na dnu iskazuje
	?? " "
	nPom:= rn->cjenbpdv * rn->kolicina
	?? STR( nPom,  LEN_VRIJEDNOST, DEC_VRIJEDNOST)

	// da li postoji popust
	if Round(rn->cjen2pdv, 3) <> 0
		? cRazmak 
		?? PADL("-" + STR(rn->popust, 3) + "%", LEN_KOLICINA)
		?? " "
		?? STR(rn->cjen2bpdv, LEN_CIJENA, DEC_CIJENA)

	endif
	
	
	skip
enddo

? cLine

? cRazmak + PADL("Ukupno bez PDV (KM):", nLeft1), STR(drn->ukbezpdv, LEN_VRIJEDNOST, DEC_VRIJEDNOST)
// dodaj i popust
if Round(drn->ukpopust, 2) <> 0
	? cRazmak + PADL("Popust (KM):", nLeft1), STR(drn->ukpopust, LEN_VRIJEDNOST, DEC_VRIJEDNOST)
	? cRazmak + PADL("Uk.bez.PDV-popust (KM):", nLeft1), STR(drn->ukbpdvpop, LEN_VRIJEDNOST, DEC_VRIJEDNOST)
endif
? cRazmak + PADL("PDV 17% :", nLeft1), STR(drn->ukpdv, LEN_VRIJEDNOST, DEC_VRIJEDNOST)

if ROUND(drn->zaokr, 2) <> 0
	? cRazmak + PADL("zaokruzenje (+/-):", nLeft1), str(ABS(drn->zaokr), LEN_VRIJEDNOST, DEC_VRIJEDNOST )
endif

? cLine
? cRazmak + PADL("UKUPNO ZA NAPLATU (KM):", nLeft1), PADL(TRANSFORM(drn->ukupno,"******9."+REPLICATE("9", DEC_VRIJEDNOST)), LEN_VRIJEDNOST)
? cLine

ft_rb_traka()

?
? SPACE(3) + "Fakturisao: ______________________"
?

for i:=1 to nPFeed
	?
next

sjeci_traku(cSjeTraSkv)

END PRN2 13

return
*}



function kup_rb_traka()
local cKNaziv
local cKAdres
local cKIdBroj
local cRazmak := SPACE(2)
local cDokVeza := ""
local i

cKNaziv := get_dtxt_opis("K01")
cKAdres := get_dtxt_opis("K02")
cKIdBroj := get_dtxt_opis("K03")
cDokVeza := get_dtxt_opis("D11")

? cRazmak + "Kupac:"
? cRazmak + cKNaziv
? cRazmak + cKAdres 
? cRazmak + "Ident.br:" + cRazmak + cKIdBroj

if !EMPTY(cDokVeza) .and. ALLTRIM(cDokVeza) <> "-"

	cDokVeza := "veza: " + ALLTRIM( cDokVeza )

	aTmp := SjeciStr( cDokVeza, 34 )

	for i:=1 to LEN( aTmp )
		? cRazmak + aTmp[ i ]
	next

endif

?

return


// vraca matricu sa dostupnim kupcima koji pocinju sa cKupac
function get_arr_kup_data(cKupac, cKAdr, cKIdBroj)
local aKupci:={}
local nKupIzbor

if RIGHT(ALLTRIM(cKupac), 2) <> ".."
	return .t.
endif

aKupci := fnd_kup_data(cKupac)

if LEN(aKupci) > 0
	
	nKupIzbor := list_kup_data(aKupci)
	
	// odabrano je ESC
	if nKupIzbor == nil
		return .f.
	endif

	cKupac := aKupci[nKupIzbor, 1]
	cKAdr := aKupci[nKupIzbor, 2]
	cKIdBroj := aKupci[nKupIzbor, 3]
	
	return .t.
else
	MsgBeep("Trazeni pojam ne postoji u tabeli kupaca !")
endif

return .f.


function list_kup_data(aKupci)
local nIzbor
local cPom
private GetList:={}
private Izbor := 1
private opc:={}
private opcexe:={}

for i:=1 to LEN(aKupci)
	cPom := STR(i, 2) + ". " + TRIM(aKupci[i, 1]) + " - " + TRIM(aKupci[i, 2]) 
	cPom := PADR(cPom, 50)
	AADD( opc, cPom )
	AADD( opcexe, {|| nIzbor := Izbor, Izbor:=0} )
next

Izbor:=1
Menu_SC("kup")

return nIzbor

