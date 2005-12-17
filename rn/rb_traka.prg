#include "sc.ch"

function rb_print()
*{
local nIznUkupno
local lPrintPfTraka := .f.

drn_open()

if !drn_csum()
	MsgBeep("Stampanje onemoguceno! checksum error!!!")
	return
endif

nIznUkupno := get_rb_ukupno()

isPfTraka(@lPrintPfTraka)

// podaci o kupcu
if nIznUkupno > 100
	if lPrintPfTraka
		//get_part_data()
	endif
endif

// Ispisi iznos racuna velikim slovima
PisiIznRac(nIznUkupno)

// vidjeti sta sa ovim
if gDisplay=="D"
	Send2ComPort(CHR(10)+CHR(13))
	Send2ComPort(CHR(10)+CHR(13))
	Send2ComPort(CHR(30) + "UKUPAN IZNOS RN:")
	Send2ComPort(CHR(22))
	Send2ComPort(CHR(13))
	Send2ComPort(ALLTRIM(STR(nIznos-nNeplaca, 10, 2)))
endif

// stampaj racun
st_rb_traka()
//PaperFeed()

if lPrintPfTraka
	st_pf_traka()
	//PaperFeed()
endif

// skloni iznos racuna
SkloniIznRac()

return
*}


function isPfTraka(lRet)
*{
// inace iscitati parametar
lRet := .f.
return
*}


function get_rb_ukupno()
*{
local nUkupno:=0

select drn
go top
do while !EOF()
	nUkupno += field->ukupno
	skip
enddo

return nUkupno
*}


function get_rn_mjesto()
*{
local cMjesto := get_dtxt_opis("R01")
return cMjesto
*}


function rb_traka_line(cLine)
*{
cLine := " " + REPLICATE("-",3) + " " + REPLICATE("-",16) + " " + REPLICATE("-",15)
return
*}


function st_rb_traka()
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

select drn
go top
// ako postoji vise zapisa onda ima vise racuna
if RecCount() > 1
	lViseRacuna := .t.
endif

select rn
set order to tag "1"
go top

// mjesto i datum racuna
? cRazmak + drn->vrijeme + PADL(get_rn_mjesto() + ", " + DToC(drn->datdok), 32)

? cLine

// broj racuna
? SPACE(10) + "BLAGAJNA RACUN br." + ALLTRIM(drn->brdok) 

? cLine

// opis kolona
? " R.br  Sifra, Naziv"
? cLine
? "     kol/jmj  Cijena sa PDV   Ukupno"

? cLine

select rn

// data
do while !EOF()

	// rbr
	? cRazmak + rn->rbr

	// artikal
	cArtikal := ALLTRIM(field->idroba) + "-" + ALLTRIM(field->robanaz)
	aRNaz := SjeciStr(cArtikal, 38)
	for i:=1 to LEN(aRNaz)
		if i == 1
			?? cRazmak + aRNaz[i]
		else
			? SPACE(5) + aRNaz[i]
		endif
	next

	// kolicina, jmj, cjena sa pdv
	? cRazmak + STR(rn->kolicina, 9, gKolDec), rn->jmj, STR(rn->cjenpdv, 12, 2)
	// da li postoji popust
	if Round(rn->cjen2pdv, 4) <> 0
		?? " popust:", STR(rn->popust, 5) + "%"
		? cRazmak + "Cij-popust:", STR(rn->cjen2pdv, 12, 2)
	endif

	?? STR(rn->ukupno, 12, 2)	
	
	skip
enddo

? cLine
?
? cRazmak + PADL("Ukupno bez PDV (KM):", 25), ROUND(drn->ukbezpdv, 2)
// dodaj i popust
if Round(drn->ukpopust, 2) <> 0
	? cRazmak + PADL("Popust (KM):", 25), ROUND(drn->ukpopust, 2)
	? cRazmak + PADL("Uk.bez.PDV-popust (KM):", 25), ROUND(drn->ukbpdvpop, 2)
endif
? cRazmak + PADL("PDV 17% :", 25), ROUND(drn->ukpdv, 2)
? cLine
? cRazmak + PADL("UKUPNO ZA NAPLATU (KM):", 25), ROUND(drn->ukupno, 2)
? cLine
?

ft_rb_traka()

END PRN2 13

return
*}


function hd_rb_traka()
*{
local cDuplaLin
local cINaziv
local cIAdresa
local cIIdBroj
local cIPM
local cRazmak := SPACE(1)
local cRazmak2 := SPACE(2)

cDuplaLin := REPLICATE("=", 38)
cINaziv := get_dtxt_opis("I01")
cIAdresa := get_dtxt_opis("I02")
cIIdBroj := get_dtxt_opis("I03")
cIPM := get_dtxt_opis("I04")

// stampaj header

? cRazmak + cDuplaLin

? cRazmak2 + cINaziv
? cRazmak2 + REPLICATE("-", LEN(cINaziv))

? cRazmak2 + "Adresa : " + cIAdresa
? cRazmak2 + "ID broj: " + cIIdBroj

? cRazmak2 + REPLICATE("-", 30)

? cRazmak2 + "Prodajno mjesto:"
? cRazmak2 + cIPM

? cRazmak + cDuplaLin
?
?

return
*}


function ft_rb_traka(cIdRadnik)
*{
local cRazmak := SPACE(1)
local cRadnik
local cSmjena

cRadnik := get_dtxt_opis("R02")
cSmjena := get_dtxt_opis("R03")

? cRazmak + cRadnik, "Smjena: " + cSmjena
?
?
? cRazmak + "Placanje izvrseno: gotovina" 

return
*}


