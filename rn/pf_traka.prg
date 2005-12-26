#include "sc.ch"


function pf_traka_print()
*{
drn_open()

// stampaj racun
st_pf_traka()

return
*}


function f7_pf_traka()
*{
local lPfTraka
local lPartNemaPodataka:=.f.

isPfTraka(@lPfTraka)

if Pitanje(,"Stampati poresku fakturu za zadnji racun (D/N)?", "D") == "N"
	return
endif

drn_open()

if !lPfTraka
	if !read_kup_data()
		lPartNemaPodataka := .t.
		get_kup_data()
	endif
endif

st_pf_traka()

if !lPfTraka .and. lPartNemaPodataka
	AzurKupData(gIdPos)
endif

return
*}


function read_kup_data()
*{
local cKNaziv
cKNaziv := get_dtxt_opis("K01")
if cKNaziv == "???"
	return .f.
endif
return .t.
*}

function get_kup_data()
*{
local cKNaziv := SPACE(35)
local cKAdres := SPACE(35)
local cKIdBroj := SPACE(13)
local cUnosOk := "N"
local GetList:={}

Box(,6, 65)
	do while .t.
		 @ 1+m_x, 2+m_y SAY "Podaci o kupcu:" COLOR "I"
		 @ 2+m_x, 2+m_y SAY "Naziv (pravnog ili fizickog lica):" GET cKNaziv VALID !Empty(cKNaziv) PICT "@S20"
		 @ 3+m_x, 2+m_y SAY "Adresa:" GET cKAdres VALID !Empty(cKAdres)
		 @ 4+m_x, 2+m_y SAY "Identifikacijski broj:" GET cKIdBroj VALID !Empty(cKIdBroj)
		 @ 6+m_x, 2+m_y SAY "Unos podataka ispravan (D/N)?" GET cUnosOk VALID cUnosOk $ "DN" PICT "@!"
		
		read
		// potvrdi unos
		if cUnosOk == "D"
			exit
		endif
		
	enddo
BoxC()

//dodaj parmetre u drntext
add_drntext("K01", cKNaziv)
add_drntext("K02", cKAdres)
add_drntext("K03", cKIdBroj)

return
*}



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

START PRINT2 CRET gLocPort,SPACE(5)

rb_traka_line(@cLine)

get_rb_vars(@nPFeed)

hd_rb_traka()

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
? cRazmak + drn->vrijeme + PADL(get_rn_mjesto() + ", " + DToC(drn->datdok), 32)

? cLine

// broj racuna
? SPACE(12) + "FAKTURA br." + ALLTRIM(drn->brdok) 

? cLine

// opis kolona
? " R.br  Sifra, Naziv"
? cLine
? " kolicina/jmj            Cij.bez PDV"
? "  Cij.sa PDV   Cij*kolicina sa PDV (KM)"

? cLine

select rn

// data
do while !EOF()

	// rbr
	? cRazmak + rn->rbr

	// artikal
	cArtikal := ALLTRIM(field->idroba) + " - " + ALLTRIM(field->robanaz)
	aRNaz := SjeciStr(cArtikal, 34)
	for i:=1 to LEN(aRNaz)
		if i == 1
			?? cRazmak + aRNaz[i]
		else
			? SPACE(5) + aRNaz[i]
		endif
	next

	// kolicina, jmj, cjena sa pdv
	? cRazmak + STR(rn->kolicina, 9, 2), rn->jmj + PADL(STR(rn->cjenbpdv, 12, 2), 25)
	// da li postoji popust
	if Round(rn->cjen2pdv, 4) <> 0
		? cRazmak + "popust:" + STR(rn->popust, 3) + "%"
		?? cRazmak + "  cij.2.b.PDV", STR(rn->cjen2bpdv, 12, 2)
	endif
	// pdv
	? cRazmak + "  PDV:", STR(rn->ppdv, 3) + "%"
	?? cRazmak + "  poj.izn.PDV", STR(rn->vpdv, 12, 2)
	
	? cRazmak + STR( if(Round(rn->cjen2pdv,4)<>0, rn->cjen2pdv, rn->cjenpdv), 12,2), PADL(STR(rn->ukupno, 12, 2), 25)	
	?
	
	skip
enddo

? cLine
?
? cRazmak + PADL("Ukupno bez PDV (KM):", 25), STR(drn->ukbezpdv, 12, 2)
// dodaj i popust
if Round(drn->ukpopust, 2) <> 0
	? cRazmak + PADL("Popust (KM):", 25), STR(drn->ukpopust, 12, 2)
	? cRazmak + PADL("Uk.bez.PDV-popust (KM):", 25), STR(drn->ukbpdvpop, 12, 2)
endif
? cRazmak + PADL("PDV 17% :", 25), STR(drn->ukpdv, 12, 2)
? cLine
? cRazmak + PADL("UKUPNO ZA NAPLATU (KM):", 25), PADL(TRANSFORM(drn->ukupno,"******9.99"), 12)
? cLine

ft_rb_traka()

?
? SPACE(3) + "Fakturisao: ______________________"
?

for i:=1 to nPFeed
	?
next

END PRN2 13

return
*}



function kup_rb_traka()
*{
local cKNaziv
local cKAdres
local cKIdBroj
local cRazmak := SPACE(2)

cKNaziv := get_dtxt_opis("K01")
cKAdres := get_dtxt_opis("K02")
cKIdBroj := get_dtxt_opis("K03")

? cRazmak + "Kupac:"
? cRazmak + cKNaziv
? cRazmak + cKAdres 
? cRazmak + "Ident.br:" + cRazmak + cKIdBroj
?

return
*}

