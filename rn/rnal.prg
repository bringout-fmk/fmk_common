#include "sc.ch"

static LEN_COLONA :=  42
static LEN_FOOTER := 14
static cLine
static lPrintedTotal := .f.
static nStr := 0

// ako se koristi PTXT onda se ova korekcija primjenjuje
// za prikaz vecih fontova
static nDuzStrKorekcija := 0

// glavna funkcija za poziv stampe fakture a4
// lStartPrint - pozovi funkcije stampe START PRINT
function rnal_print(lStartPrint)
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

LEN_NAZIV(71)
LEN_UKUPNO(99)

radni_nalog(lStartPrint)

return
*}


// stampa radnog naloga
function radni_nalog(lStartPrint)
*{
local cBrDok
local dDatDok
local aRNaz
local cArtikal

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

lPrintedTotal := .f.

// uzmi glavne varijable za stampu radnog naloga
// razmak, broj redova sl.teksta, 
get_rnal_vars(@nLMargina, @nGMargina, @nDodRedova, @nSlTxtRow, @lSamoKol, @lZaglStr, @lStZagl, @lDatOtp, @cValuta)

// razmak ce biti
RAZMAK(SPACE(nLMargina))

cLine := rnal_line()

// zaglavlje por.fakt
rnal_header()

P_12CPI

select rn
set order to tag "1"
go top

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

// dodaj text na kraju fakture
rnal_footer()


if lStartPrint
	FF
	EndPrint()
endif

return
*}

// uzmi osnovne parametre za stampu dokumenta
function get_rnal_vars(nLMargina, nGMargina, nDodRedova, nSlTxtRow, lSamoKol, lZaglStr, lStZagl, lDatOtp, cValuta, cPDVStavka)
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
cRed1 += " " + PADR("Trgovacki naziv dobra/usluge (sifra, naziv, jmj)", LEN_NAZIV())

cRed1 += " " + PADC("kolicina", LEN_KOLICINA())

? cRed1

? cLine

return
*}

// definicija linije za glavnu tabelu sa stavkama
function rnal_line()
local cLine

cLine:= RAZMAK()
cLine += REPLICATE("-", LEN_RBR())
cLine += " " + REPLICATE("-", LEN_NAZIV())
// kolicina
cLine += " " + REPLICATE("-", LEN_KOLICINA())

return cLine


// ----------------------------------------
// funkcija za ispis podataka o kupcu
// ----------------------------------------
static function rnal_header()
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
cPom := PADR("Narucioc:", LEN_COLONA) + " " + PADR("Dobavljac:", LEN_COLONA)

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
cPom := PADR("ID: " + cPom, LEN_COLONA)
cPom += " " + PADR("ID: " + cPom2, LEN_COLONA)
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

?
?
P_10CPI
// broj dokumenta
cPom := SPACE(15)
cPom += "RADNI NALOG br. ___________ od ___________"
p_line( cPom, 10, .t.)
?
cPom := SPACE(15)
cPom += "Veza (narudzba,ugovor,zahtjev) __________________________ od __________________________"
p_line( cPom, 17, .t.)

B_OFF
?
nPRowsDelta:= prow() - nPRowsDelta 
if IsPtxtOutput()
	nDuzStrKorekcija += nPRowsDelta * 7/100 
endif

return

//-----------------------------------
function rnal_footer()
local cPom
local cLinPodv

cLinPodv:=REPLICATE("-", 80)

?
cPom:= "A. Komentari i napomene (popunjava izvrsioc):"
p_line( cPom, 12, .t.)
?
p_line( cLinPodv, 12, .t.)
?
p_line( cLinPodv, 12, .t.)
?
p_line( cLinPodv, 12, .t.)
?
cPom:= "B. Komentari, primjedbe, napomene (popunjava korisnik):"
p_line( cPom, 12, .t.)
?
p_line( cLinPodv, 12, .t.)
?
p_line( cLinPodv, 12, .t.)
?
p_line( cLinPodv, 12, .t.)
?

?
?
cPom := SPACE(10) + "Odobrio"
cPom += SPACE(30)
cPom += "Potvrda realizacije"
p_line(cPom, 12, .f.)

cPom := SPACE(5) + "(od strane izvrsioca)"
cPom += SPACE(20)
cPom += "(od strane korisnika)"
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
p_line( "Prenos na sljedecu stranicu", 17, .f. )
? cLine

FF

P_COND
? cLine
if nStr <> nil
	p_line( "       Strana:" + str(nStr, 3), 17, .f.)
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
