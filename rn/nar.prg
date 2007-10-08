#include "sc.ch"

static LEN_COLONA :=  42
static LEN_FOOTER := 14

static lShowPopust

static cLine
static lPrintedTotal := .f.
static nStr := 0

// ako se koristi PTXT onda se ova korekcija primjenjuje
// za prikaz vecih fontova
static nDuzStrKorekcija := 0

// prikaz samo kolicine 0, cijena 1
static nSw6


// glavna funkcija za poziv stampe fakture a4
// lStartPrint - pozovi funkcije stampe START PRINT
function nar_print(lStartPrint)
*{
// ako je nil onda je uvijek .t.
if lStartPrint == nil
	lStartPrint := .t.
endif

PIC_KOLICINA(PADL(ALLTRIM(RIGHT(PicKol, LEN_KOLICINA())), LEN_KOLICINA(), "9"))
PIC_VRIJEDNOST(PADL(ALLTRIM(RIGHT(PicDem, LEN_VRIJEDNOST())), LEN_VRIJEDNOST(), "9"))
PIC_CIJENA(PADL(ALLTRIM(RIGHT(PicCDem, LEN_CIJENA())), LEN_CIJENA(), "9"))


drn_open()

select drn
go top

LEN_NAZIV(53)
LEN_UKUPNO(99)
if Round(drn->ukpopust, 2) <> 0
	lShowPopust :=.t.
else
	lShowPopust:=.f.
	LEN_NAZIV( LEN_NAZIV() + LEN_PROC2() + LEN_CIJENA() + 2 )
endif

narudzba(lStartPrint)
return
*}


// stampa narudzbenice
function narudzba(lStartPrint)
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

nSw6 := VAL(get_dtxt_opis("X09"))

lPrintedTotal := .f.

// uzmi glavne varijable za stampu fakture
// razmak, broj redova sl.teksta, 
get_nar_vars(@nLMargina, @nGMargina, @nDodRedova, @nSlTxtRow, @lSamoKol, @lZaglStr, @lStZagl, @lDatOtp, @cValuta)

// razmak ce biti
RAZMAK(SPACE(nLMargina))

cLine := nar_line()

// zaglavlje por.fakt
nar_header()

if nSw6 == 0
	P_12CPI
endif

select rn
set order to tag "1"
go top

if nSw6 > 0
	P_COND
endif

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
	
	if nSw6 > 0
	
		// cijena bez pdv
		?? show_number(rn->cjenbpdv, PIC_CIJENA()) 
		?? " "


		if lShowPopust
			// procenat popusta
			?? show_popust(rn->popust)
			?? " "

			// cijena bez pd - popust
			?? show_number(rn->cjen2bpdv, PIC_CIJENA()) 
			?? " "
		endif


		// ukupno bez pdv
		?? show_number( rn->cjenbpdv * rn->kolicina,  PIC_VRIJEDNOST())
		?? " "
	endif

	if LEN(aNazivDobra) > 1
	    // DRUGI RED
	    ? RAZMAK()
	    ?? " "
	    ?? SPACE(LEN_RBR())
	    ?? PADR(aNazivDobra[2], LEN_NAZIV())
	endif
	
	// provjeri za novu stranicu
	if prow() > (nDodRedova + LEN_STRANICA() - DSTR_KOREKCIJA()) 
		++nStr
		Nstr_a4(nStr, .t.)
    	endif	

	SELECT rn
	skip
enddo

// provjeri za novu stranicu
if prow() > nDodRedova + (LEN_STRANICA() - LEN_FOOTER)
	++nStr
	Nstr_a4(nStr, .t.)
endif	

if nSw6 > 0
	print_total()
	lPrintedTotal:=.t.

	if prow() > nDodRedova + (LEN_STRANICA() - LEN_FOOTER)
		++nStr
		Nstr_a4(nStr, .t.)
	endif	
endif

// dodaj text na kraju fakture
nar_footer()


if lStartPrint
	FF
	EndPrint()
endif

return
*}

// uzmi osnovne parametre za stampu dokumenta
function get_nar_vars(nLMargina, nGMargina, nDodRedova, nSlTxtRow, lSamoKol, lZaglStr, lStZagl, lDatOtp, cValuta, cPDVStavka)
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

return
*}


// zaglavlje glavne tabele sa stavkama
static function st_zagl_data()
*{

local cRed1:=""
local cRed2:=""
local cRed3:=""


? cLine

cRed1 := RAZMAK() 
cRed1 += PADC("R.br", LEN_RBR()) 
cRed1 += " " + PADR(lokal("Trgovacki naziv dobra/usluge (sifra, naziv, jmj)"), LEN_NAZIV())

cRed1 += " " + PADC(lokal("kolicina"), LEN_KOLICINA())

if nSw6 > 0
	cRed1 += " " + PADC(lokal("C.b.PDV"), LEN_CIJENA())
	if lShowPopust
 		cRed1 += " " + PADC(lokal("Pop.%"), LEN_PROC2())
 		cRed1 += " " + PADC(lokal("C.2.b.PDV"), LEN_CIJENA())
	endif
	cRed1 += " " + PADC(lokal("Uk.bez.PDV"), LEN_VRIJEDNOST())
endif

? cRed1

? cLine

return
*}

// definicija linije za glavnu tabelu sa stavkama
function nar_line()
local cLine


cLine:= RAZMAK()
cLine += REPLICATE("-", LEN_RBR())
cLine += " " + REPLICATE("-", LEN_NAZIV())
// kolicina
cLine += " " + REPLICATE("-", LEN_KOLICINA())

if nSw6 > 0
	// cijena b. pdv
	cLine += " " + REPLICATE("-", LEN_CIJENA())

	if lShowPopust
 		// popust
 		cLine += " " + REPLICATE("-", LEN_PROC2())
 		// cijen b. pdv - popust
 		cLine += " " + REPLICATE("-", LEN_CIJENA())
	endif

	// vrijednost b. pdv
	cLine += " " + REPLICATE("-", LEN_VRIJEDNOST())
endif

return cLine

// --------------------------------------------------
// --------------------------------------------------
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


// provjeri i dodaj stavke vezane za popust
if Round(drn->ukpopust, 2) <> 0
		? RAZMAK()
		?? PADL(lokal("Popust (")+cValuta+") :", LEN_UKUPNO())
		?? show_number(drn->ukpopust, PIC_VRIJEDNOST())
		
		? RAZMAK()
		?? PADL(lokal("Uk.bez.PDV-popust (")+cValuta+") :", LEN_UKUPNO())
		?? show_number(drn->ukbpdvpop, PIC_VRIJEDNOST())
endif


// obracun PDV-a
? RAZMAK()
?? PADL(lokal("PDV 17% :"), LEN_UKUPNO())
?? show_number(drn->ukpdv, PIC_VRIJEDNOST())


// zaokruzenje
if ROUND(drn->zaokr,4) <> 0
	? RAZMAK() 
	?? PADL(lokal("Zaokruzenje :"), LEN_UKUPNO())
	?? show_number(drn->zaokr, PIC_VRIJEDNOST())
endif
	
? cLine
? RAZMAK()
// ipak izleti za dva karaktera rekapitulacija u bold rezimu
?? SPACE(50 - 2)
B_ON
?? PADL(lokal("** SVEUKUPNO SA PDV  (")+cValuta+") :", LEN_UKUPNO() - 50)
?? TRANSFORM(drn->ukupno, PIC_VRIJEDNOST())
B_OFF

	
cSlovima := get_dtxt_opis("D04")
? RAZMAK() 
B_ON
?? lokal("slovima: ") + cSlovima
B_OFF
? cLine
return


// ----------------------------------------
// funkcija za ispis podataka o kupcu
// ----------------------------------------
static function nar_header()
*{
local cPom, cPom2

local cLin
local cPartMjesto
local cPartPTT

local cNaziv, cNaziv2
local cAdresa, cAdresa2
local cIdBroj, cIdBroj2
local cMjesto, cMjesto2
local cTelFax, cTelFax2
local aKupac, aDobavljac

local cDatDok
local cDatIsp
local cDatVal
local cBrDok
local cBrNar
local cBrOtp
local nPRowsDelta

nPRowsDelta:= prow()

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


cNaziv:=get_dtxt_opis("K01")
cAdresa:=get_dtxt_opis("K02")
cIdBroj:=get_dtxt_opis("K03")
cDestinacija:=get_dtxt_opis("D08")

cTelFax:="tel: "
cPom:=ALLTRIM(get_dtxt_opis("K13"))
if empty(cPom)
	cPom:="-"
endif
cTelFax += cPom
cPom:=ALLTRIM(get_dtxt_opis("K14"))
if empty(cPom)
	cPom:="-"
endif
cTelFax += ", fax: " + cPom

//K10 - partner mjesto
cMjesto := get_dtxt_opis("K10") 
//K11 - partner PTT
cPTT := get_dtxt_opis("K11")


PushWa()
SELECT F_PARTN
if !used()
	O_PARTN
endif

// gFirma sadrzi podatke o maticnoj firmi
seek gFirma
cNaziv2  := ALLTRIM(partn->naz)
cMjesto2 := ALLTRIM(partn->ptt) + " " + ALLTRIM(partn->mjesto)
cAdresa2 := ALLTRIM(partn->adresa)
cAdresa2 := get_dtxt_opis("I02")
// idbroj
cIdBroj2 := get_dtxt_opis("I03") 
cTelFax2 := "tel: " + ALLTRIM(partn->telefon)  + ", fax: " + ALLTRIM(partn->fax)

PopWa()


cMjesto:= ALLTRIM(cMjesto)
if !EMPTY(cPTT)
 cMjesto := ALLTRIM(cPTT) + " " + cMjesto
endif

aKupac:=Sjecistr(cNaziv, LEN_COLONA)
aDobavljac:=SjeciStr(cNaziv2, LEN_COLONA)

B_ON
cPom := PADR(lokal("Narucioc:"), LEN_COLONA) + " " + PADR(lokal("Dobavljac:"), LEN_COLONA)

p_line( cPom, 12, .t.)

cPom := PADR(REPLICATE("-",LEN_COLONA-2), LEN_COLONA)
cLin := cPom + " " + cPom
p_line( cLin  , 12, .f.)

// prvi red kupca, 10cpi, bold
cPom := ALLTRIM(aKupac[1])
if EMPTY(cPom)
  cPom := "-"
endif
cPom := PADR(cPom, LEN_COLONA)

// prvi red dobavljaca, 10cpi, bold
cPom2 := ALLTRIM(aDobavljac[1])
if EMPTY(cPom2)
  cPom2 := "-"
endif
cPom := cPom +  " " + PADR(cPom2, LEN_COLONA)
p_line( cPom , 12, .f.)


cPom := ALLTRIM(cAdresa)
if EMPTY(cPom)
  cPom := "-"
endif
cPom2 := ALLTRIM(cAdresa2)
if EMPTY(cPom2)
  cPom2 := "-"
endif

cPom := PADR(cPom, LEN_COLONA)
cPom += " " + PADR(cPom2, LEN_COLONA)
p_line( cPom, 12, .t.)

// mjesto
cPom := ALLTRIM(cMjesto)
if EMPTY(cPom)
  cPom := "-"
endif
cPom2 := ALLTRIM(cMjesto2)
if EMPTY(cPom2)
  cPom2 := "-"
endif
cPom := PADR(cPom, LEN_COLONA)
cPom += " " + PADR(cPom2, LEN_COLONA)
p_line( cPom, 12, .t.)

// idbroj
cPom := ALLTRIM(cIdBroj)
if EMPTY(cPom)
  cPom := "-"
endif
cPom2 := ALLTRIM(cIdBroj2)
if EMPTY(cPom2)
  cPom2 := "-"
endif
cPom := PADR(lokal("ID: ") + cPom, LEN_COLONA)
cPom += " " + PADR(lokal("ID: ") + cPom2, LEN_COLONA)
p_line( cPom, 12, .t.)


// telfax
cPom := ALLTRIM(cTelFax)
if EMPTY(cTelFax)
  cPom := "-"
endif
cPom2 := ALLTRIM(cTelFax2)
if EMPTY(cPom2)
  cPom2 := "-"
endif


cPom := PADR(cPom, LEN_COLONA)
cPom += " " + PADR(cPom2, LEN_COLONA)
p_line( cPom, 12, .t.)


p_line( cLin  , 12, .t.)

B_OFF

if !EMPTY(cDestinacija)
 ?
 p_line( REPLICATE("-", LEN_KUPAC() - 10) , 12, .f.)
 cPom := lokal("Destinacija: ")  + ALLTRIM( cDestinacija )
 p_line(cPom, 12 , .f.)
 ?
endif


?
?
P_10CPI
// broj dokumenta
cPom := lokal("NARUDZBENICA br. ___________ od ") + cDatDok
cPom := PADC(cPom, LEN_COLONA * 2)
p_line( cPom, 10, .t.)
B_OFF
?
cPom:=lokal("Molimo da nam na osnovu ponude/dogovora/ugovora _________________ ")
p_line(cPom, 12 , .f.)
cPom:=lokal("isporucite sljedeca dobra/usluge:" )
p_line(cPom, 12 , .f.)

nPRowsDelta:= prow() - nPRowsDelta 
if IsPtxtOutput()
	nDuzStrKorekcija += nPRowsDelta * 7/100 
endif

return

//-----------------------------------
//-----------------------------------
function nar_footer()
local cPom

?
cPom:=lokal("USLOVI NABAVKE:")
p_line( cPom, 12, .t.)
cPom:="----------------"
p_line( cPom, 12, .t.)
?
cPom:= lokal("Mjesto isporuke _______________________  Nacin placanja: gotovina/banka/kompenzacija")
p_line( cPom, 12, .t.)
?
cPom := lokal("Vrijeme isporuke _____________________________________________________________")
?
p_line( cPom, 12, .t.)
?
cPom:=lokal("Napomena: Molimo popuniti prazna polja, te zaokruziti zeljene opcije")
p_line(cPom, 20, .f.)

?
cPom := PADL(lokal(" M.P.          "), LEN_COLONA) + " "
cPom += PADC(lokal("Za narucioca:"), LEN_COLONA)
p_line(cPom, 12, .f.)
?
cPom := PADC(" ", LEN_COLONA) + " "
cPom += PADC(REPLICATE("-", LEN_COLONA - 4), LEN_COLONA)
p_line(cPom, 12, .f.)

?
return

// -----------------------------------------
// funkcija za novu stranu
// -----------------------------------------
static function NStr_a4(nStr, lShZagl)
*{

// korekcija duzine je na svako strani razlicita
nDuzStrKorekcija := 0 

P_COND
? cLine
p_line( lokal("Prenos na sljedecu stranicu"), 17, .f. )
? cLine

FF

P_COND
? cLine
if nStr <> nil
	p_line( lokal("       Strana:") + str(nStr, 3), 17, .f.)
endif

// total nije odstampan znaci ima jos podataka
if lShZagl 
	if !lPrintedTotal
		st_zagl_data()
	else
		// vec je odstampan, znaci nema vise stavki
		// najbolje ga prenesi na ovu stranu koja je posljednja
		print_total()
	endif
else
	? cLine
endif

return
*}


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

