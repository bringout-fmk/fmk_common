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

static LEN_TRAKA  := 40

static LEN_RAZMAK :=  0
static LEN_RBR    :=  3
static LEN_NAZIV  := 25
static LEN_UKUPNO := 10

static PIC_UKUPNO := "9999999.99"

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



// ----------------------------------------------
// varijable za stampu racuna
// ----------------------------------------------
function get_rb_vars(nFeedLines, cOLadSkv, cSTrakSkv, nPdvCijene, lStampId, nVrRedukcije, lPrKupac )
local cTmp

// broj linija za odcjepanje trake
nFeedLines := VAL(get_dtxt_opis("P12"))
cOLadSkv := get_dtxt_opis("P13") // sekv.za otv.ladice
cSTrakSkv := get_dtxt_opis("P14") // sekv.za sjec.trake
nPdvCijene := VAL(get_dtxt_opis("P20")) // cijene sa pdv, bez pdv
cTmp := get_dtxt_opis("P21") // prikaz id artikal na racunu
lStampId := .f.
lPrKupac := .f.

if ( cTmp == "D" )
	lStampId := .t.
endif

nVrRedukcije := VAL(get_dtxt_opis("P22")) // redukcija trake

// ispis kupca na racunu
cTmp := get_dtxt_opis("P23")
if cTmp == "D"
	lPrKupac := .t.
endif

return


function isAzurDok(lRet)
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


// ---------------------------------------
// vraca ukupan iznos racuna
// ---------------------------------------
function get_rb_ukupno()
local nUkupno:=0
local nTArea := SELECT()

select drn
go top
do while !EOF()
	nUkupno += field->ukupno
	skip
enddo

select (nTArea)
return nUkupno


function get_rn_mjesto()
*{
local cMjesto := get_dtxt_opis("R01")
return cMjesto
*}


function rb_traka_line(cLine)
*{
cLine := REPLICATE("-", LEN_RBR) + " " + REPLICATE("-", LEN_NAZIV) + " " + REPLICATE("-", LEN_UKUPNO)
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
local cLine
local lViseRacuna := .f.
local nPFeed

// sekv.otvaranja ladice
local cOtvLadSkv
// prikaz kupca na racunu
local lKupac

// sekv.sjecenja trake
local cSjeTraSkv 

local cZakBr:=""
local nSetCijene
local lStRobaId
local nRedukcija
local cRb_row
local aRb_row
local aRb_row_1
local aRb_row_2
local nRedova1
local nRedova2
local cPop_row
local cPom
local nLen
local cNum

if lStartPrint
	START PRINT2 CRET gLocPort, SPACE(5)
endif

rb_traka_line(@cLine)

// uzmi glavne varijable
get_rb_vars(@nPFeed, @cOtvLadSkv, @cSjeTraSkv, @nSetCijene, @lStRobaId, @nRedukcija, @lKupac)

hd_rb_traka(nRedukcija)

if lKupac == .t.
	// ispis kupca ako je potreban
	kup_rb_traka()
endif

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
? SPACE(LEN_RAZMAK) + " " + drn->vrijeme + PADL(get_rn_mjesto() + ", " + DToC(drn->datdok), 32)

? cLine

// broj racuna
cPom:=  "BLAGAJNA RACUN br. " + ALLTRIM(drn->brdok)

if lAzurDok
	if lStartPrint
		cPom += SPACE(8) + "PREPIS"
	endif
endif

? PADC(cPom, LEN_TRAKA)


? cLine

// opis kolona
// setcijene = 1 (sa pdv)
// setcijene = 2 (bez pdv)

cPom := "" 
cPom += PADC("Rbr", LEN_RBR)
cPom += " "
cPom += PADC("Artikal (jmj), kol x cij", LEN_NAZIV)
cPom += " "
if nSetCijene == 2
	cPom += PADC("Uk.sa.PDV", LEN_UKUPNO)
else
	cPom += PADC("Uk.sa.PDV", LEN_UKUPNO)
endif

? cPom

? cLine

select rn

// stampa stavki racuna
do while !EOF()

	// odredi tip cijene za prikaz
	if nSetCijene == 2 // cijena sa pdv
		nPdvCijena := rn->cjenpdv
		nRnUkupno := rn->ukupno
	else
		nPdvCijena := rn->cjenbpdv
		nRnUkupno := rn->ukupno
	endif

	// R.br
	cStr1 := PADR(rn->rbr, LEN_RBR) +  " "            
	
	// id.roba
	if lStRobaId // prikaz id robe .t. 
		cStr1 += ALLTRIM(rn->idroba) + " - " 
	endif

	// naziv
	cStr1 += ALLTRIM(rn->robanaz) 
	
	// jmj
	cStr1 += " (" + ALLTRIM(rn->jmj) + ")" 
	
	// prvi dio do kolicine
	cStr2 := ""
	
	// kolicina
	cStr2 += " " + ALLTRIM(show_number(rn->kolicina, nil, -10))
	
	// puta
	cStr2 += " x " 
	
	// cijena
	cStr2 += ALLTRIM(show_number(nPdvCijena, nil, -10))


	// da li postoji popust
	if Round(rn->cjen2pdv, 4) <> 0
		
		// cijena sa pdv
		if nSetCijene == 2 
			nPopcjen := rn->cjen2pdv
		else
			nPopcjen := rn->cjen2bpdv
		endif
	
		cStr2 += " , cij-pop " + ALLTRIM( show_number(rn->popust, nil, -5)) + "% = "
		cStr2 += ALLTRIM(show_number(nPopcjen, nil, -10))
		
	endif


	cNum := ALLTRIM(show_number(nRnUkupno, PIC_UKUPNO))
	
	// sve spoji pa presjeci
	aRb_row_1 := SjeciStr(cStr1 + cStr2, LEN_TRAKA - LEN_RAZMAK - LEN_RBR - 1)
	// trebam redova u varijanti 1
	nRedova1 := LEN(aRb_row_1)
	if  LEN_RAZMAK + LEN_RBR + 1 + LEN(TRIM(aRb_row_1[nRedova1])) + 1 + LEN(cNum) > LEN_TRAKA
		++nRedova1
	endif
	
	// varijanta 2 prvo presjeci string 1
	aRb_row_2 := SjeciStr(cStr1, LEN_TRAKA - LEN_RAZMAK - LEN_RBR - 1)
	
	// nastiklaj matricu
	SjeciStr(cStr2, LEN_TRAKA - LEN_RAZMAK - LEN_RBR - 1, @aRb_row_2)
	
	nRedova2 := LEN(aRb_row_2)
	if  LEN_RAZMAK + LEN_RBR + 1 + LEN(TRIM(aRb_row_2[nRedova2])) + 1 + LEN(cNum) > LEN_TRAKA
		++nRedova2
	endif
	
	if nRedova2 > nRedova1
		aRb_row := aRb_row_1
	else
		// ljepsa varijanta
		aRb_row := aRb_row_2
	endif
		
	// prikazi sve do predzanjeg reda
	for i:=1 to (LEN(aRb_row)-1)
		? SPACE(LEN_RAZMAK)
		if i > 1
			?? space(LEN_RBR + 1)
		endif
		?? aRb_row[i]
		
		nLenRow := LEN(TRIM(aRb_row[i]))
	next
	
	// ostaje prikaz zadnjeg reda
	cPom := TRIM( aRb_row[LEN(aRb_row)] )
	nLen := LEN(cPom)
	

	// ako se ne moze nastiklati iznos ukupno na zadnji red
	// onda ga i neces dodavati sad
	if LEN_RAZMAK + LEN_RBR + 1 + nLen + 1 + LEN(cNum)  > LEN_TRAKA 
		? SPACE(LEN_RAZMAK)
		?? SPACE(LEN_RBR + 1)
		?? cPom
		cPom := ""
		nLen := 0
	endif

	
	// ispis zadnjeg reda
	? SPACE(LEN_RAZMAK)
	
	
	// nije prvi red napravi indent za redni broj
	if LEN(aRb_row) > 1
		?? SPACE(LEN_RBR + 1) 
		cPom += PADL( cNum , LEN_TRAKA - nLen - LEN_RBR - LEN_RAZMAK - 1)
	else
		// prvi red
		cPom += PADL( cNum , LEN_TRAKA - nLen - LEN_RAZMAK)
	endif
	?? cPom
	
	skip
enddo

? cLine

? SPACE(LEN_RAZMAK) + PADL("Ukupno bez PDV (KM):", LEN_TRAKA - LEN_UKUPNO - 1), show_number(drn->ukbezpdv, PIC_UKUPNO)
// dodaj i popust
if Round(drn->ukpopust, 2) <> 0
	? SPACE(LEN_RAZMAK) + PADL("Popust (KM):", LEN_TRAKA - LEN_UKUPNO - 1), show_number(drn->ukpopust, PIC_UKUPNO)
	? SPACE(LEN_RAZMAK) + PADL("Uk.bez.PDV-popust (KM):", LEN_TRAKA - LEN_UKUPNO - 1), show_number(drn->ukbpdvpop, PIC_UKUPNO)
endif
? SPACE(LEN_RAZMAK) + PADL("PDV 17% :", LEN_TRAKA - LEN_UKUPNO - 1), show_number(drn->ukpdv, PIC_UKUPNO)

if ROUND(drn->zaokr, 2) <> 0
	? SPACE(LEN_RAZMAK) + PADL("zaokruzenje (+/-):", LEN_TRAKA - LEN_UKUPNO - 1), show_number(ABS(drn->zaokr), PIC_UKUPNO)
endif

? cLine
? SPACE(LEN_RAZMAK) + PADL("UKUPNO ZA NAPLATU (KM):", LEN_TRAKA - LEN_UKUPNO - 1), PADL(show_number(drn->ukupno,"******9.99"), LEN_UKUPNO)
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

// -----------------------------------
// -----------------------------------
function hd_rb_traka(nRedukcija)
*{
local cDuplaLin
local cINaziv
local cIAdresa
local cIIdBroj
local cIPM
local cITelef
local cRaz2 := SPACE(LEN_RAZMAK + 1)

cDuplaLin := REPLICATE("=", LEN_TRAKA - LEN_RAZMAK - 1)
cINaziv := get_dtxt_opis("I01")
cIAdresa := get_dtxt_opis("I02")
cIIdBroj := get_dtxt_opis("I03")
cIPM := ALLTRIM( get_dtxt_opis("I04") )
cITelef := ALLTRIM( get_dtxt_opis("I05") )

// stampaj header

if ( nRedukcija < 1 )
	? SPACE(LEN_RAZMAK) + " " + cDuplaLin
endif

? cRaz2 + " " + cINaziv

if (nRedukcija < 1)
	? cRaz2 + " " + REPLICATE("-", LEN(cINaziv))
endif

? cRaz2 + " Adresa : " + cIAdresa
? cRaz2 + " ID broj: " + cIIdBroj

if ( nRedukcija < 1 )
	? cRaz2 + " " + REPLICATE("-", LEN_TRAKA - 11)
endif

if !EMPTY( cIPM ) .and. cIPM <> "-"
  if ( nRedukcija > 0 )
	? cRaz2 + "  PM:", cIPM
  else
	? cRaz2 + " Prodajno mjesto:"
	? cRaz2 + " " + cIPM
  endif
endif

if !EMPTY(cITelef) .and. cITelef <> "-"
	? cRaz2 + " Telefon: " + cITelef
endif

if ( nRedukcija < 1 )
	? SPACE(LEN_RAZMAK) + " " + cDuplaLin
endif

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


function g_vez_racuni(aRacuni)
*{
local cRead
cRead := get_dtxt_opis("R12")
if cRead == "-"
	aRacuni := {}
	return
endif
aRacuni:=SjeciStr(cRead, 20)
return
*}


function ft_rb_traka(cIdRadnik)
*{
local cRadnik
local cSmjena
local cVrstaP
local cPomTxt1
local cPomTxt2
local cPomTxt3
local cBrStola
local cVezRacuni:=""
local aVezRacuni:={}

cRadnik := get_dtxt_opis("R02")
cSmjena := get_dtxt_opis("R03")
cVrstaP := get_dtxt_opis("R05")
cPomTxt1 := get_dtxt_opis("R06")
cPomTxt2 := get_dtxt_opis("R07")
cPomTxt3 := get_dtxt_opis("R08")

g_br_stola(@cBrStola)
g_vez_racuni(@aVezRacuni)

? SPACE(LEN_RAZMAK) + " " + PADR(cRadnik,27), PADL("Smjena: " + cSmjena, 10)
if !EMPTY(cBrStola)
	? SPACE(LEN_RAZMAK) + " Sto.br:" + SPACE(1) + cBrStola
	if LEN(aVezRacuni) > 0
		?? " RN: "
		for i:=1 to LEN(aVezRacuni)
			if i == 1
				?? aVezRacuni[i]
			else
				? SPACE(LEN_RAZMAK) + " " + aVezRacuni[i]
			endif
		next
	endif
else
	?
endif
? SPACE(LEN_RAZMAK) + " Placanje izvrseno: " + cVrstaP 

// pomocni text na racunu
if !EMPTY(cPomTXT1)
	?
	? SPACE(LEN_RAZMAK) + " " + cPomTxt1
endif
if !EMPTY(cPomTxt2)
	? SPACE(LEN_RAZMAK) + " " + cPomTxt2
endif
if !EMPTY(cPomTxt3)
	? SPACE(LEN_RAZMAK) + " " + cPomTxt3
endif

return
*}


