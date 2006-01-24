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


function f7_pf_traka()
*{
local lPfTraka

isPfTraka(@lPfTraka)

if Pitanje(,"Stampati poresku fakturu za zadnji racun (D/N)?", "D") == "N"
	return
endif

drn_open()

if !lPfTraka
	get_kup_data()
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
local cUnosOk := "D"
local dDatIsp := DATE()
local GetList:={}

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
	do while .t.
		 @ 1+m_x, 2+m_y SAY "Podaci o kupcu:" COLOR "I"
		 @ 2+m_x, 2+m_y SAY "Naziv (pravnog ili fizickog lica):" GET cKNaziv VALID !Empty(cKNaziv) PICT "@S20"
		 @ 3+m_x, 2+m_y SAY "Adresa:" GET cKAdres VALID !Empty(cKAdres)
		 @ 4+m_x, 2+m_y SAY "Identifikacijski broj:" GET cKIdBroj VALID !Empty(cKIdBroj)
		 @ 5+m_x, 2+m_y SAY "Datum isporuke " GET dDatIsp

		 @ 7+m_x, 2+m_y SAY "Unos podataka ispravan (D/N)?" GET cUnosOk VALID cUnosOk $ "DN" PICT "@!"
		read
		// potvrdi unos
		if cUnosOk == "D"
			exit
		endif
		
	enddo
BoxC()



//dodaj parametre u drntext
add_drntext("K01", cKNaziv)
add_drntext("K02", cKAdres)
add_drntext("K03", cKIdBroj)
add_drn_di(dDatIsp)

return
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

START PRINT2 CRET gLocPort, SPACE(5)

cLine := pf_traka_line(1)

get_rb_vars(@nPFeed, @cOtvLadSkv, @cSjeTraSkv)

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
? cRazmak + drn->vrijeme + PADL(get_rn_mjesto() +  "D.ispor: " + DTOC(drn->datisp)+ ", " + DToC(drn->datdok), 32)


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

