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


#include "fmk.ch"

static nStr := 0
static lPrintedTotal := .f.
static cLine
// ako se koristi PTXT onda se ova korekcija primjenjuje
// za prikaz vecih fontova
static nDuzStrKorekcija := 0

// glavna funkcija za poziv stampe fakture a4
// lStartPrint - pozovi funkcije stampe START PRINT
function omp_print(lStartPrint)
*{
// ako je nil onda je uvijek .t.
if lStartPrint == nil
	lStartPrint := .t.
endif

PIC_KOLICINA(PADL(ALLTRIM(RIGHT(PicKol, LEN_KOLICINA())), LEN_KOLICINA(), "9"))
PIC_VRIJEDNOST(PADL(ALLTRIM(RIGHT(PicDem, LEN_VRIJEDNOST())), LEN_VRIJEDNOST(), "9"))
PIC_CIJENA(PADL(ALLTRIM(RIGHT(PicCDem, LEN_CIJENA())), LEN_CIJENA(), "9"))


nDuzStrKorekcija := 0

drn_open()

select drn
go top

LEN_NAZIV(52)
LEN_UKUPNO(80)

otpr_mp(lStartPrint)

return
*}


// stampa otpremnica maloprodaja
function otpr_mp(lStartPrint)
*{
local cBrDok
local dDatDok
local aRNaz
local cArtikal
local cSlovima

private nLMargina // lijeva margina
private nDodRedova // broj dodatnih redova
private nSlTxtRow // broj redova slobodnog text-a
private lSamoKol // prikaz samo kolicina
private lZaglStr // zaglavlje na svakoj stranici
private lDatOtp // prikaz datuma otpremnice i narudzbenice
private cValuta // prikaz valute KM ili ???
private lStZagl // automatski formirati zaglavlje
private nGMargina // gornja margina


if lStartPrint

	if !StartPrint()
		close all
		return
	endif

endif

// uzmi glavne varijable za stampu fakture
// razmak, broj redova sl.teksta, 
get_omp_vars(@nLMargina, @nGMargina, @nDodRedova, @nSlTxtRow, @lSamoKol, @lZaglStr, @lStZagl, @lDatOtp, @cValuta)

// razmak ce biti
RAZMAK(SPACE(nLMargina))

if lStZagl
	// zaglavlje por.fakt
	a4_header()
else
	// ostavi prostor umjesto automatskog zaglavlja
	for i:=1 to nGMargina
		?
	next
endif

// podaci kupac i broj dokumenta itd....
omp_kupac()

cLine := a4_line("otpr_mp")

select rn
set order to tag "1"
go top

P_COND

st_zagl_data()

select rn

nStr:=1
aArtNaz := {}

// data
do while !EOF()
	
	
	// uzmi naziv u matricu
	cNazivDobra := NazivDobra(rn->idroba, rn->robanaz, rn->jmj)
	aNazivDobra := SjeciStr(cNazivDobra, LEN_NAZIV())
	
	// PRVI RED
	// redni broj ili podbroj
	? RAZMAK()
	
	if EMPTY(rn->podbr)
		?? PADL(rn->rbr + ")", LEN_RBR())
	else
		?? PADL(rn->rbr + "." + ALLTRIM(rn->podbr), LEN_RBR())
	endif
	?? " "
	
	// idroba, naziv robe, kolicina, jmj
	?? PADR( aNazivDobra[1], LEN_NAZIV()) 
	?? " "
	?? show_number(rn->kolicina, PIC_KOLICINA()) 
	?? " "
	
	// cijena bez pdv
	?? show_number(rn->cjenbpdv, PIC_CIJENA()) 
	?? " "
		
	// ukupno bez pdv
	?? show_number( rn->cjenbpdv * rn->kolicina,  PIC_VRIJEDNOST())
	?? " "

	// cijena sa PDV
	?? show_number(rn->cjenpdv, PIC_CIJENA()) 
	?? " "
	
	// uk sa PDV
	?? show_number(rn->ukupno, PIC_VRIJEDNOST()) 
	?? " "

	
	
	if LEN(aNazivDobra) > 1
	    // DRUGI RED
	    ? RAZMAK()
	    ?? " "
	    ?? SPACE(LEN_RBR())
	    ?? PADR(aNazivDobra[2], LEN_NAZIV())
	endif
	
	// provjeri za novu stranicu
	if prow() > nDodRedova + LEN_STRANICA() - DSTR_KOREKCIJA() 
		++nStr
		Nstr_a4(nStr, .t.)
    	endif	

	SELECT rn
	skip
enddo

// provjeri za novu stranicu
if prow() > nDodRedova + (LEN_STRANICA() - LEN_REKAP_PDV())
	++nStr
	Nstr_a4(nStr, .t.)
endif	




print_total()
lPrintedTotal:=.t.


if prow() > nDodRedova + (LEN_STRANICA() - LEN_REKAP_PDV())
	++nStr
	Nstr_a4(nStr, .t.)
endif	

?
// dodaj text na kraju fakture
a4_footer()

?

if lStartPrint
	FF
	EndPrint()
endif

return
*}

// uzmi osnovne parametre za stampu dokumenta
function get_omp_vars(nLMargina, nGMargina, nDodRedova, nSlTxtRow, lSamoKol, lZaglStr, lStZagl, lDatOtp, cValuta, cPDVStavka)
*{

// uzmi podatak za lijevu marginu
nLMargina := VAL(get_dtxt_opis("P01"))

// uzmi podatak za gornju marginu
nGMargina := VAL(get_dtxt_opis("P07"))

// broj dodatnih redova po listu
nDodRedova := VAL(get_dtxt_opis("P06"))

// uzmi podatak za duzinu slobodnog teksta
nSlTxtRow := VAL(get_dtxt_opis("P02"))

// varijanta fakture (porez na svaku stavku D/N)
cPDVStavka := get_dtxt_opis("P11")

// da li se prikazuju samo kolicine
lSamoKol := .f.
if get_dtxt_opis("P03") == "D"
	lSamoKol := .t.
endif

// da li se kreira zaglavlje na svakoj stranici
lZaglStr := .f.
if get_dtxt_opis("P04") == "D"
	lZaglStr := .t.
endif

// da li se kreira zaglavlje na svakoj stranici
lStZagl := .f.
if get_dtxt_opis("P10") == "D"
	lStZagl := .t.
endif

// da li se ispisuji podaci otpremnica itd....
lDatOtp := .t.
if get_dtxt_opis("P05") == "N"
	lZaglStr := .f.
endif

// valuta dokuemnta
cValuta := get_dtxt_opis("D07")

nSw1(VAL(get_dtxt_opis("X04")))
nSw2(VAL(get_dtxt_opis("X05")))
nSw3(VAL(get_dtxt_opis("X06")))
nSw4(VAL(get_dtxt_opis("X07")))

return
*}


// zaglavlje glavne tabele sa stavkama
static function st_zagl_data()
*{

local cRed1:=""
local cRed2:=""
local cRed3:=""

cLine := a4_line("otpr_mp")

? cLine

cRed1 := RAZMAK() 
cRed1 += PADC("R.br", LEN_RBR()) 
cRed1 += " " + PADR("Trgovacki naziv dobra (sifra, naziv, jmj)", LEN_NAZIV())

cRed1 += " " + PADC("kolicina", LEN_KOLICINA())
cRed1 += " " + PADC("C.b.PDV", LEN_CIJENA())
cRed1 += " " + PADC("Uk.bez.PDV", LEN_VRIJEDNOST())

cRed1 += " " + PADC("C.sa.PDV", LEN_CIJENA())
cRed1 += " " + PADC("Uk.sa.PDV", LEN_VRIJEDNOST())

? cRed1

? cLine

return
*}



// definicija linije za glavnu tabelu sa stavkama
function otpr_mp_line()
local cLine


cLine:= RAZMAK()
cLine += REPLICATE("-", LEN_RBR())
cLine += " " + REPLICATE("-", LEN_NAZIV())
// kolicina
cLine += " " + REPLICATE("-", LEN_KOLICINA())

// cijena b. pdv
cLine += " " + REPLICATE("-", LEN_CIJENA())
// vrijednost b. pdv
cLine += " " + REPLICATE("-", LEN_VRIJEDNOST())

// cijena s. pdv
cLine += " " + REPLICATE("-", LEN_CIJENA())
// vrijednost s. pdv
cLine += " " + REPLICATE("-", LEN_VRIJEDNOST())

return cLine

// --------------------------------------------
// --------------------------------------------
static function print_total()
? cLine

// kolona bez PDV
   
? RAZMAK()
?? SPACE(LEN_UKUPNO() - (LEN_KOLICINA() + LEN_CIJENA() + 2))

if ROUND(drn->ukkol,2)<>0
	?? show_number(drn->ukkol, PIC_KOLICINA())
else
 	?? SPACE(LEN_KOLICINA())
endif
?? " "

?? SPACE( LEN_CIJENA() )
?? " "

?? show_number(drn->ukbezpdv, PIC_VRIJEDNOST())
   
// cijene se ne rekapituliraju
?? " "
?? SPACE(LEN(PIC_CIJENA()))

// ukupno sa PDV
?? " "
?? show_number(drn->ukupno, PIC_VRIJEDNOST())
   
// obracun PDV-a
? RAZMAK() 
?? PADL("PDV 17% :", LEN_UKUPNO())
?? show_number(drn->ukpdv, PIC_VRIJEDNOST())
    
// zaokruzenje
if ROUND(drn->zaokr,4) <> 0
	? RAZMAK() 
	?? PADL("Zaokruzenje :", LEN_UKUPNO())
	?? show_number(drn->zaokr, PIC_VRIJEDNOST())
endif
	
? cLine
? RAZMAK()
// ipak izleti za dva karaktera rekapitulacija u bold rezimu
?? SPACE(50 - 2)
B_ON
?? PADL("** SVEUKUPNO SA PDV  ("+cValuta+") :", LEN_UKUPNO() - 50)
?? show_number(drn->ukupno, PIC_VRIJEDNOST())
B_OFF

	
cSlovima := get_dtxt_opis("D04")
? RAZMAK() 
B_ON
?? "slovima: " + cSlovima
B_OFF
? cLine
return


// -----------------------------------------------
// funkcija za ispis podataka o kupcu, dokument, 
// datum fakture, otpremnica itd..
// -----------------------------------------------
static function omp_kupac()
*{
local cPartMjesto
local cPartPTT

local cKNaziv
local cKAdresa
local cKIdBroj
local cKPorBroj
local cKBrRjes
local cKBrUpisa
local cKMjesto
local aKupac
local cMjesto
local cDatDok
local cDatIsp
local cDatVal
local cTipDok := "OTPREMNICA MP br. "
local cBrDok
local cBrNar
local cBrOtp
local nPRowsDelta

nPRowsDelta := prow()

drn_open()
select drn
go top

cDatDok := DToC(datdok)

if EMPTY(datIsp)
	// posto je ovo obavezno polje na racunu
	// stavicemo ako nije uneseno da je datum isporuke
	// jednak datumu dokumenta
	cDatIsp := DTOC(datDok)
else
        cDatIsp := DToC(datisp)
endif

cDatVal := DToC(field->datval)
cBrDok := field->brdok

cBrNar :=get_dtxt_opis("D06") 
cBrOtp :=get_dtxt_opis("D05") 
cMjesto:=get_dtxt_opis("D01")
cTipDok:=get_dtxt_opis("D02")
cKNaziv:=get_dtxt_opis("K01")
cKAdresa:=get_dtxt_opis("K02")
cKIdBroj:=get_dtxt_opis("K03")
cDestinacija:=get_dtxt_opis("D08")

//K10 - partner mjesto
cPartMjesto := get_dtxt_opis("K10") 
//K11 - partner PTT
cPartPTT := get_dtxt_opis("K11")


cKMjesto:= ALLTRIM(cPartMjesto)
if !EMPTY(cPartPTT)
 cKMjesto := ALLTRIM(cPartPTT) + " " + cKMjesto
endif

aKupac:=Sjecistr(cKNaziv, 30)

I_ON
p_line( "Zaduzuje:" , 10, .t.)
p_line( REPLICATE("-", LEN_KUPAC() - 10) , 10, .f.)
I_OFF

// prvi red kupca, 10cpi, bold
cPom := ALLTRIM(aKupac[1])
if EMPTY(cPom)
  cPom := "-"
endif
p_line( SPACE(2) + PADR(cPom, LEN_KUPAC()) , 10, .t.)
B_OFF
//  u istom redu mjesto
?? padl(cMjesto + ", " + cDatDok, LEN_DATUM())


// adresa, 10cpi, bold
cPom := ALLTRIM(cKAdresa)
if EMPTY(cPom)
  cPom := "-"
endif
p_line( SPACE(2) + PADR(cPom, LEN_KUPAC()), 10, .t.)
B_OFF
// u istom redu datum isporuke
if cDatIsp <> DToC(CToD(""))
	?? padl("Datum isporuke: " + cDatIsp, LEN_DATUM())
endif

// mjesto
cPom := ALLTRIM(cKMjesto)
if EMPTY(cPom)
  cPom := "-"
endif
p_line(SPACE(2) + PADR(cKMjesto, LEN_KUPAC()), 10, .t.)
B_OFF
// u istom redu datum valute
if cDatVal <> DToC(CTOD(""))
	?? padl("Datum valute: " + cDatVal, LEN_DATUM())
endif


if !EMPTY(cDestinacija)
 p_line( REPLICATE("-", LEN_KUPAC() - 10) , 10, .f.)
 cPom := "Za: "  + ALLTRIM( cDestinacija )
 p_line(cPom, 12 , .f.)
 ?
endif

?
P_10CPI
// broj dokumenta
p_line( PADL(cTipDok + cBrDok, LEN_KUPAC() + LEN_DATUM()), 10, .t.)
B_OFF
?

nPRowsDelta:= prow() - nPRowsDelta 
if IsPtxtOutput()
	nDuzStrKorekcija += nPRowsDelta * 7/100 
endif


return

// ------------------------------------
// funkcija za novu stranu
// ------------------------------------
static function NStr_a4(nStr, lShZagl)
*{

// korekcija duzine je na svako strani razlicita
nDuzStrKorekcija := 0 

P_COND
? cLine
p_line( "Prenos na sljedecu stranicu", 17, .f. )
? cLine

FF

P_COND
? cLine
if nStr <> nil
	p_line( "       Strana:" + str(nStr, 3), 17, .f.)
endif

// total nije odstampan znaci ima jos podataka
if lShZagl 
	if !lPrintedTotal
		st_zagl_data()
	else
		// vec je odstampan, znaci nema vise stavki
		// najbolje ga prenesi na ovu stranu koja je posljednja
		print_total(cValuta, cLine)
	endif
else
	? cLine
endif

return

// --------------------------------
// korekcija za duzinu strane
// --------------------------------
static function	DSTR_KOREKCIJA()
local nPom

nPom := ROUND(nDuzStrKorekcija, 0)
if ROUND(nDuzStrKorekcija - nPom, 1) > 0.2
	nPom ++
endif

return nPom

return
