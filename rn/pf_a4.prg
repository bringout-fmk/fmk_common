#include "sc.ch"

static LEN_RBR := 6
static LEN_NAZIV := 53
static LEN_UKUPNO := 99
static LEN_KUPAC := 35
static LEN_DATUM := 34

static LEN_KOLICINA := 8
// 9999999.99
static LEN_CIJENA := 10
static LEN_VRIJEDNOST := 12

// 999.99 - popust
static LEN_PROC2 := 6
static DEC_PROC2 := 2

static DEC_KOLICINA := 2
static DEC_CIJENA := 2 
static DEC_VRIJEDNOST := 2

static PIC_PROC2 := "999.99"
static PIC_KOLICINA := ""
static PIC_VRIJEDNOST := ""
static PIC_CIJENA := ""

static LEN_STRANICA := 60
static LEN_REKAP_PDV := 9

static RAZMAK := ""



// glavna funkcija za poziv stampe fakture a4
// lStartPrint - pozovi funkcije stampe START PRINT
function pf_a4_print(lStartPrint)
*{
// ako je nil onda je uvijek .t.
if lStartPrint == nil
	lStartPrint := .t.
endif

PIC_KOLICINA :=  PADL(ALLTRIM(RIGHT(PicKol, LEN_KOLICINA)), LEN_KOLICINA, "9")
PIC_VRIJEDNOST := PADL(ALLTRIM(RIGHT(PicDem, LEN_VRIJEDNOST)), LEN_VRIJEDNOST, "9")
PIC_CIJENA := PADL(ALLTRIM(RIGHT(PicDem, LEN_CIJENA)), LEN_CIJENA, "9")


drn_open()

if (gPdvDokVar == "1")
 // stampaj racun
 st_pf_a4(lStartPrint)
else
 st_pf_a4_2(lStartPrint)
endif

return
*}


// stampa fakture a4
function st_pf_a4(lStartPrint)
*{
local cBrDok
local dDatDok
local aRNaz
local cArtikal
local cSlovima
local cLine

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
get_pfa4_vars(@nLMargina, @nGMargina, @nDodRedova, @nSlTxtRow, @lSamoKol, @lZaglStr, @lStZagl, @lDatOtp, @cValuta)

// razmak ce biti
RAZMAK:= SPACE(nLMargina)

if lStZagl
	// zaglavlje por.fakt
	pf_a4_header()
else
	// ostavi prostor umjesto automatskog zaglavlja
	for i:=1 to nGMargina
		?
	next
endif

// podaci kupac i broj dokumenta itd....
pf_a4_kupac()

cLine := pf_a4_line()

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
	aNazivDobra := SjeciStr(cNazivDobra, LEN_NAZIV)
	
	// PRVI RED
	// redni broj ili podbroj
	? RAZMAK
	
	if EMPTY(rn->podbr)
		?? PADL(rn->rbr + ")", LEN_RBR)
	else
		?? PADL(rn->rbr + "." + ALLTRIM(rn->podbr), LEN_RBR)
	endif
	?? " "
	
	// idroba, naziv robe, kolicina, jmj
	?? PADR( aNazivDobra[1], LEN_NAZIV) 
	?? " "
	?? TRANSFORM(rn->kolicina, PIC_KOLICINA) 
	?? " "
	
	// cijene
	if !lSamoKol
		
		// cijena bez pdv
		?? TRANSFORM(rn->cjenbpdv, PIC_CIJENA) 
		?? " "
		
		// procenat popusta
		?? show_popust(rn->popust)
		?? " "

		// cijena bez pd - popust
		?? TRANSFORM(rn->cjen2bpdv, PIC_CIJENA) 
		?? " "
		
		// ukupno bez pdv
		?? TRANSFORM( rn->cjenbpdv * rn->kolicina,  PIC_VRIJEDNOST)
	endif
	
	
	if LEN(aNazivDobra) > 1
	    // DRUGI RED
	    ? RAZMAK
	    ?? " "
	    ?? SPACE(LEN_RBR)
	    ?? PADR(aNazivDobra[2], LEN_NAZIV)
	endif
	
	// provjeri za novu stranicu
	if prow() > nDodRedova + LEN_STRANICA 
		++nStr
		Nstr_pf_a4(nStr, .t.)
    	endif	

	skip
enddo

// provjeri za novu stranicu
if prow() > nDodRedova + (LEN_STRANICA - LEN_REKAP_PDV)
	++nStr
	Nstr_pf_a4(nStr, .t.)
endif	


? cLine

if !lSamoKol
   ? RAZMAK
   ?? PADL("Ukupno bez PDV ("+cValuta+") :", LEN_UKUPNO)
   ?? TRANSFORM(drn->ukbezpdv, PIC_VRIJEDNOST)
   ++nStr
   
   // provjeri i dodaj stavke vezane za popust
   if Round(drn->ukpopust, 2) <> 0
		? RAZMAK 
		?? PADL("Popust ("+cValuta+") :", LEN_UKUPNO)
		?? TRANSFORM(drn->ukpopust, PIC_VRIJEDNOST)
		
		? RAZMAK 
		?? PADL("Uk.bez.PDV-popust ("+cValuta+") :", LEN_UKUPNO)
		?? TRANSFORM(drn->ukbpdvpop, PIC_VRIJEDNOST)
    endif
	
    
    ? RAZMAK 
    ?? PADL("PDV 17% :", LEN_UKUPNO)
    ?? TRANSFORM(drn->ukpdv, PIC_VRIJEDNOST)
    
    // zaokruzenje
    if ROUND(drn->zaokr,4) <> 0
		? RAZMAK 
		?? PADL("Zaokruzenje :", LEN_UKUPNO)
		?? TRANSFORM(drn->zaokr, PIC_VRIJEDNOST)
    endif
	
    ? cLine
    ? RAZMAK 
    ?? PADL("S V E U K U P N O   S A   P D V ("+cValuta+") :", LEN_UKUPNO)
    ?? TRANSFORM(drn->ukupno, PIC_VRIJEDNOST)

    // popust na teret prodavca 
    if drn->(fieldpos("ukpoptp")) <> 0
             if Round(drn->ukpoptp, 2) <> 0
		? RAZMAK
		?? PADL("Popust na teret prodavca ("+cValuta+") :", LEN_UKUPNO)
		?? TRANSFORM(drn->ukpoptp, PIC_VRIJEDNOST)
		
	        ? RAZMAK 
		? PADL("S V E U K U P N O   S A   P D V -  P O P U S T  N A   T. P. ("+cValuta+") : ZA PLATITI :", LEN_UKUPNO)
		?? TRANSFORM(drn->ukupno - drn->ukpoptp, PIC_VRIJEDNOST)
	     endif
    endif
	
    cSlovima := get_dtxt_opis("D04")
    ? RAZMAK + "slovima: " + cSlovima
    ? cLine
endif

if prow() > nDodRedova + (LEN_STRANICA - LEN_REKAP_PDV)
	++nStr
	Nstr_pf_a4(nStr, .t.)
endif	

?
// dodaj text na kraju fakture
pf_a4_footer()

?

if lStartPrint
	FF
	EndPrint()
endif

return
*}

// uzmi osnovne parametre za stampu dokumenta
function get_pfa4_vars(nLMargina, nGMargina, nDodRedova, nSlTxtRow, lSamoKol, lZaglStr, lStZagl, lDatOtp, cValuta, cPDVStavka)
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
local cLine

local cRed1:=""
local cRed2:=""
local cRed3:=""

cLine := pf_a4_line()

? cLine

cRed1 := RAZMAK 
cRed1 += PADC("R.br", LEN_RBR) 
cRed1 += " " + PADR("Trgovacki naziv dobra (sifra, naziv, jmj)", LEN_NAZIV)
cRed1 += " " + PADC("kolicina", LEN_KOLICINA)
cRed1 += " " + PADC("C.b.PDV", LEN_CIJENA)
cRed1 += " " + PADC("Pop.%", LEN_PROC2)
cRed1 += " " + PADC("C.2.b.PDV", LEN_CIJENA)
cRed1 += " " + PADC("Uk.bez.PDV", LEN_VRIJEDNOST)

if .f.
cRed2 := PADC(" ", 5) 
cRed2 += " " + PADC("(1)", LEN_NAZIV)
cRed2 += " " + PADC("(2)", LEN_KOLICINA)
cRed2 += " " + PADC("(3)", LEN_CIJENA)
cRed2 += " " + PADC("(4)", LEN_PROC2)
cRed2 += " " + PADC("(5)=(3-4)", LEN_CIJENA)
cRed2 += " " + PADC("(7)=(2*6)", LEN_VRIJEDNOST)
endif

? cRed1

? cLine

return
*}


// funkcija za ispis slobodnog teksta na kraju fakture
function pf_a4_sltxt()
*{
local cLine
local cTxt
local nFTip

cLine := pf_a4_line()

if prow() > nDodRedova + LEN_STRANICA
         Nstr_pf_a4(nil, .f.)
endif


select drntext
set order to tag "1"
hseek "F20"

do while !EOF() .and. field->tip = "F"
	nFTip := VAL(RIGHT(field->tip, 2))
	if nFTip < 51
		cTxt := ALLTRIM(field->opis)
		// cTxt, 17cpi, bold = off, if empty() new line
		p_line(cTxt, 17, .f., .t.)
	endif

	if prow() > nDodRedova + LEN_STRANICA
        	 Nstr_pf_a4(nil, .f.)
	endif

	skip
enddo

return
*}


// generalna funkcija footer
function pf_a4_footer()
*{
local cLine 

cLine := pf_a4_line()

// ispisi slobodni text
pf_a4_sltxt(cLine)
?
P_12CPI
?
// ispisi potpis na kraju dokumenta
? RAZMAK + SPACE(10) + get_dtxt_opis("F10")

return
*}


// funkcija za ispis headera
function pf_a4_header()
*{

local cDLHead := REPLICATE("=", 72) // double line header
local cSLHead := REPLICATE("-", 72) // single line header
local cINaziv
local cIAdresa
local cIIdBroj
local cIBanke
local aBanke
local cITelef
local cIWeb
local cIText1
local cIText2
local cIText3

cINaziv  := get_dtxt_opis("I01") // naziv
cIAdresa := get_dtxt_opis("I02") // adresa
cIIdBroj := get_dtxt_opis("I03") // idbroj
cIBanke  := get_dtxt_opis("I09")
aIBanke  := SjeciStr(cIBanke, 68)
cITelef  := get_dtxt_opis("I10") // telefoni
cIWeb    := get_dtxt_opis("I11") // email-web
cIText1  := get_dtxt_opis("I12") // sl.text 1
cIText2  := get_dtxt_opis("I13") // sl.text 2
cIText3  := get_dtxt_opis("I14") // sl.text 3


p_line(cDLHead, 10, .t.)
p_line(cINaziv, 10, .t.)
p_line(REPLICATE("-", LEN(cINaziv)), 10, .t.)
p_line("Adresa: " + cIAdresa + ", ID broj: " + cIIdBroj, 12, .f.)
p_line(cITelef, 12, .f.)
p_line(cIWeb, 12, .f.)
p_line(cSLHead, 10, .f.)

p_line("Banke:", 12, .f.)
for i:=1 to LEN(aIBanke)
	if i == 1
		?? aIBanke[i]
	else
		? " " + RAZMAK + aIBanke[i] + " "
	endif
next


if !EMPTY(cIText1 + cIText2 + cIText3)
  p_line(cSLHead, 10, .t.)
  p_line(cIText1, 12, .f.)
  p_line(cIText2, 12, .f.)
  p_line(cIText3, 12, .f.)
endif
p_line(cDLHead, 10, .f.)
?

return
*}


// definicija linije za glavnu tabelu sa stavkama
static function pf_a4_line()
local cLine


cLine:= RAZMAK
cLine += REPLICATE("-", LEN_RBR)
cLine += " " + REPLICATE("-", LEN_NAZIV)
// kolicina
cLine += " " + REPLICATE("-", LEN_KOLICINA)
// cijena b. pdv
cLine += " " + REPLICATE("-", LEN_CIJENA)
// popust
cLine += " " + REPLICATE("-", LEN_PROC2)
// cijen b. pdv - popust
cLine += " " + REPLICATE("-", LEN_CIJENA)
// vrijednost b. pdv
cLine += " " + REPLICATE("-", LEN_VRIJEDNOST)

return cLine


// funkcija za ispis podataka o kupcu, dokument, datum fakture, otpremnica itd..
function pf_a4_kupac()
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
local cTipDok := "FAKTURA br. "
local cBrDok
local cBrNar
local cBrOtp

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
p_line( "Kupac:" , 10, .t.)
p_line( REPLICATE("-", LEN_KUPAC - 10) , 10, .f.)
I_OFF

// prvi red kupca, 10cpi, bold
cPom := ALLTRIM(aKupac[1])
if EMPTY(cPom)
  cPom := "-"
endif
p_line( SPACE(2) + PADR(cPom, LEN_KUPAC) , 10, .t.)
B_OFF
//  u istom redu mjesto
?? padl(cMjesto + ", " + cDatDok, LEN_DATUM)


// adresa, 10cpi, bold
cPom := ALLTRIM(cKAdresa)
if EMPTY(cPom)
  cPom := "-"
endif
p_line( SPACE(2) + PADR(cPom, LEN_KUPAC), 10, .t.)
B_OFF
// u istom redu datum isporuke
if cDatIsp <> DToC(CToD(""))
	?? padl("Datum isporuke: " + cDatIsp, LEN_DATUM)
endif

// mjesto
cPom := ALLTRIM(cKMjesto)
if EMPTY(cPom)
  cPom := "-"
endif
p_line(SPACE(2) + PADR(cKMjesto, LEN_KUPAC), 10, .t.)
B_OFF
// u istom redu datum valute
if cDatVal <> DToC(CTOD(""))
	?? padl("Datum valute: " + cDatVal, LEN_DATUM)
endif

// identifikacijski broj
cPom := ALLTRIM(cKIdBroj)
if EMPTY(cPom)
  cPom := "-"
endif
cPom := "ID broj: " + cPom
p_line(SPACE(2) + PADR(cPom, LEN_KUPAC), 10, .f.)

P_10CPI
// broj dokumenta
p_line( PADL(cTipDok + cBrDok, LEN_KUPAC + LEN_DATUM), 10, .t.)
B_OFF

// ako je prikaz broja otpremnice itd...

cPom := cBrOtp
lBrOtpr := .f.
if !empty(cPom)
	cPom := "Broj otpremnice: " + cPom
	lBrOtpr := .t.
endif
p_line(cPom, 12, .f.)

cPom := cBrNar
if !empty(cPom)
	cPom := "Broj narudzbenice: " + cPom
endif
if lBrOtpr
	// odstampaj u istom redu br.nar sa br.otp
	?? " , " + cPom
else
    p_line(cPom, 12, .f.)
endif
return
*}


// funkcija za novu stranu
function NStr_pf_a4(nStr, lShZagl)
*{
local cLine

cLine := pf_a4_line()

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
if lShZagl
	st_zagl_data()
else
	? cLine
endif

return
*}


static function NazivDobra(cIdRoba, cRobaNaz, cJmj)
local cPom

cPom := ALLTRIM(cIdRoba)
cPom += " - " + ALLTRIM(cRobaNaz)
if !EMPTY(cJmj)
	cPom += " (" + ALLTRIM (cJmj) + ")"
endif

return cPom


static function show_popust(nPopust)
local cPom
local i
for i:=0 to 2
 if ROUND(nPopust, i) == ROUND(nPopust,2)
	cPom := STR(nPopust, LEN_PROC2, i)
	exit
 endif
next

cPom:=ALLTRIM(cPom)

if LEN(cPom)< LEN_PROC2
	// ima prostora za dodati znak %
	cPom += "%"
endif

return PADL(cPom, LEN_PROC2)


static function p_line(cPLine, nCpi, lBold, lNewLine)
// ako nije prazno telefon ispisi

if lNewLine == nil
	lNewline := .f.
endif

if EMPTY(cPLine) 
 if lNewLine
  // odstampaj i praznu liniju
  cPLine := " "
 else
  return
 endif
endif


// odstapaj razmak u COND rezimu
P_COND
? RAZMAK
// nakon toga idi na rezim ispisa linije
do case
 case (nCpi == 12)
	P_12CPI
 case (nCpi == 10)
	P_10CPI
 case (nCpi == 17)
	P_COND
 case (nCpi == 20)
	P_COND2
endcase

if lBold
  B_ON
endif
??  cPLine
return

