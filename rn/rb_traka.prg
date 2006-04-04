#include "sc.ch"


// glavna funkcija za stampu PDV blag.racuna na traci
// lStartPrint - .t. - pozivaju se funkcije za stampu START PRINT itd...
function rb_print(lStartPrint)
*{
local nIznUkupno
local lPrintPfTraka := .f.
local lGetKupData := .f.
local lAzurDok := .f.
local lJedanRacun

if lStartPrint == nil
	lStartPrint := .t.
endif

lJedanRacun := lStartPrint

drn_open()

if !drn_csum()
	MsgBeep("Stampanje onemoguceno! checksum error!!!")
	return .f.
endif

nIznUkupno := get_rb_ukupno()
// da li uopste stampati fakture - parametri
isPfTraka(@lPrintPfTraka)
// da li je ovo prepis dokumenta
isAzurDok(@lAzurDok)

// podaci o kupcu
if (lJedanRacun .and. nIznUkupno <= 100)
	if lPrintPfTraka
		if Pitanje(,"Stampati poresku fakturu (D/N)?", "N") == "D"
			lGetKupData := .t.
		endif
	endif
endif

// ako je racun veci od 100 - nudi po defaultu poresku fakturu
if (lJedanRacun .and. nIznUkupno > 100)
	if lPrintPfTraka
		lGetKupData := .t.
	endif
endif

if lJedanRacun .and. (lGetKupData .and. !lAzurDok)
	// daj nam podatke o kupcu
	get_kup_data()
endif

if lJedanRacun
	// Ispisi iznos racuna velikim slovima
	ShowIznRac(nIznUkupno)
endif

// vidjeti sta sa ovim
if gDisplay=="D"
	Send2ComPort(CHR(10)+CHR(13))
	Send2ComPort(CHR(10)+CHR(13))
	Send2ComPort(CHR(30) + "UKUPAN IZNOS RN:")
	Send2ComPort(CHR(22))
	Send2ComPort(CHR(13))
	Send2ComPort(ALLTRIM(STR(nIznUkupno, 10, 2)))
endif

// stampaj racun
st_rb_traka(lStartPrint, lAzurDok)

if lJedanRacun .and. lGetKupData
	st_pf_traka()
endif

if lJedanRacun
	// skloni iznos racuna
	BoxC()
endif

return
*}


function get_rb_vars(nFeedLines, cOLadSkv, cSTrakSkv)
*{
// broj linija za odcjepanje trake
nFeedLines := VAL(get_dtxt_opis("P12"))
cOLadSkv := get_dtxt_opis("P13") // sekv.za otv.ladice
cSTrakSkv := get_dtxt_opis("P14") // sekv.za sjec.trake
return
*}

function isAzurDok(lRet)
*{
local cTemp 
cTemp := get_dtxt_opis("D01")
if cTemp == "A"
	lRet := .t.
elseif cTemp == "S"
	lRet := .t.
else
	lRet := .f.
endif
return
*}


function isPfTraka(lRet)
*{
// inace iscitati parametar
if gPorFakt == "D"
	lRet := .t.
else
	lRet := .f.
endif
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
cLine := " " + REPLICATE("-",3) + " " + REPLICATE("-",22) + " " + REPLICATE("-",11)
return
*}


// st_rb_traka() - funkcija za stampu stavki trake
// lStartPrint - ako je .t. pozivaju se funkcije stampe
function st_rb_traka(lStartPrint, lAzurDok)
*{
local cBrDok
local dDatDok
local aRNaz
local cArtikal
local cRazmak := SPACE(1)
local cLine
local lViseRacuna := .f.
local nPFeed
local cOtvLadSkv // sekv.otvaranja ladice
local cSjeTraSkv // sekv.sjecenja trake
local cZakBr:=""

if lStartPrint
	START PRINT2 CRET gLocPort, SPACE(5)
endif

rb_traka_line(@cLine)

// uzmi glavne varijable
get_rb_vars(@nPFeed, @cOtvLadSkv, @cSjeTraSkv)

hd_rb_traka()


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
? SPACE(10) + "BLAGAJNA RACUN br." + ALLTRIM(drn->brdok) 

if lAzurDok
	if lStartPrint
		? SPACE(15) + "PREPIS"
	endif
endif

? cLine

// opis kolona
? " R.br  Sifra, Naziv"
? cLine
? "     kol/jmj  Cijena sa PDV     Ukupno"

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
	? cRazmak + STR(rn->kolicina, 9, 2), rn->jmj + cRazmak + STR(rn->cjenpdv, 12, 2)
	// da li postoji popust
	if Round(rn->cjen2pdv, 4) <> 0
		?? " popust:" + STR(rn->popust, 3) + "%"
		? cRazmak + "  Cij-popust:", STR(rn->cjen2pdv, 12, 2)
	endif

	?? STR(rn->ukupno, 12, 2)	

	skip
enddo

? cLine

? cRazmak + PADL("Ukupno bez PDV (KM):", 25), STR(drn->ukbezpdv, 12, 2)
// dodaj i popust
if Round(drn->ukpopust, 2) <> 0
	? cRazmak + PADL("Popust (KM):", 25), STR(drn->ukpopust, 12, 2)
	? cRazmak + PADL("Uk.bez.PDV-popust (KM):", 25), STR(drn->ukbpdvpop, 12, 2)
endif
? cRazmak + PADL("PDV 17% :", 25), STR(drn->ukpdv, 12, 2)

if glUgost
     // porez na potrosnju
     if ROUND( drn->ukpp1, 3) <> 0
        ? cRazmak + PADL("P.P" +  STR(drn->stpp1) +"% :", 25), STR(drn->ukpp1, 12, 2)
     endif
     if ROUND(drn->ukpp2, 3) <> 0
        ? cRazmak + PADL("P.P" +  STR(drn->stpp2) +"% :", 25), STR(drn->ukpp2, 12, 2)
     endif
     if ROUND(drn->ukpp3, 3) <> 0
        ? cRazmak + PADL("P.P" +  STR(drn->stpp3) +"% :", 25), STR(drn->ukpp3, 12, 2)
     endif
     if ROUND(drn->ukpp4, 3) <> 0
        ? cRazmak + PADL("P.P" +  STR(drn->stpp4) +"% :", 25), STR(drn->ukpp4, 12, 2)
     endif
   
endif

? cLine
? cRazmak + PADL("UKUPNO ZA NAPLATU (KM):", 25), PADL(TRANSFORM(drn->ukupno,"******9.99"), 12)
? cLine

ft_rb_traka()

for i:=1 to nPFeed
	?
next

if lStartPrint 
	// odsjeci traku
	sjeci_traku(cSjeTraSkv)
	// otvori ladicu
	otvori_ladicu(cOtvLadSkv)
endif

if lStartPrint
	END PRN2 13
endif

return
*}


function hd_rb_traka()
*{
local cDuplaLin
local cINaziv
local cIAdresa
local cIIdBroj
local cIPM
local cITelef
local cRazmak := SPACE(1)
local cRaz2 := SPACE(2)

cDuplaLin := REPLICATE("=", 38)
cINaziv := get_dtxt_opis("I01")
cIAdresa := get_dtxt_opis("I02")
cIIdBroj := get_dtxt_opis("I03")
cIPM := get_dtxt_opis("I04")
cITelef := get_dtxt_opis("I05")

// stampaj header

? cRazmak + cDuplaLin

? cRaz2 + cINaziv
? cRaz2 + REPLICATE("-", LEN(cINaziv))

? cRaz2 + "Adresa : " + cIAdresa
? cRaz2 + "ID broj: " + cIIdBroj

? cRaz2 + REPLICATE("-", 30)

? cRaz2 + "Prodajno mjesto:"
? cRaz2 + cIPM

if !EMPTY(cITelef)
	? cRaz2 + "Telefon: " + cITelef
endif

? cRazmak + cDuplaLin

?

return
*}


function g_br_stola(cBrStola)
*{
cBrStola := get_dtxt_opis("R11")
if cBrStola == "-"
	cBrStola := ""
endif
return
*}


function ft_rb_traka(cIdRadnik)
*{
local cRazmak := SPACE(1)
local cRadnik
local cSmjena
local cVrstaP
local cPomTxt1
local cPomTxt2
local cPomTxt3
local cBrStola

cRadnik := get_dtxt_opis("R02")
cSmjena := get_dtxt_opis("R03")
cVrstaP := get_dtxt_opis("R05")
cPomTxt1 := get_dtxt_opis("R06")
cPomTxt2 := get_dtxt_opis("R07")
cPomTxt3 := get_dtxt_opis("R08")

g_br_stola(@cBrStola)

? cRazmak + PADR(cRadnik,27), PADL("Smjena: " + cSmjena, 10)
?
? cRazmak + "Placanje izvrseno: " + cVrstaP 

if !EMPTY(cBrStola)
	? cRazmak + "Sto.br:" + SPACE(1) + cBrStola
endif

// pomocni text na racunu
if !EMPTY(cPomTXT1)
	?
	? cRazmak + cPomTxt1
endif
if !EMPTY(cPomTxt2)
	? cRazmak + cPomTxt2
endif
if !EMPTY(cPomTxt3)
	? cRazmak + cPomTxt3
endif

return
*}


