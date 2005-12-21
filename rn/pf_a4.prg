#include "sc.ch"

function pf_a4_print()
*{
drn_open()

// stampaj racun
st_pf_a4()

return
*}

function st_pf_a4()
*{
local cBrDok
local dDatDok
local aRNaz
local cArtikal
local cRazmak := SPACE(1)
local cLine
local lViseRacuna := .f.

START PRINT2 CRET gLocPort,SPACE(5)

rb_traka_line(@cLine)

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
?

END PRN2 13

return
*}








