#include "sc.ch"

// glavna funkcija za poziv stampe fakture a4
function pf_a4_print()
*{
drn_open()

// stampaj racun
st_pf_a4()

return
*}


// stampa fakture a4
function st_pf_a4()
*{
local cBrDok
local dDatDok
local aRNaz
local cArtikal
local cRazmak
local cLine
local cSlovima

private nLMargina // lijeva margina
private nDodRedova // broj dodatnih redova
private nSlTxtRow // broj redova slobodnog text-a
private lSamoKol // prikaz samo kolicina
private lZaglStr // zaglavlje na svakoj stranici
private lDatOtp // prikaz datuma otpremnice i narudzbenice
private cValuta // prikaz valute KM ili ???

if !StartPrint()
	close all
	return
endif

// uzmi glavne varijable za stampu fakture
// razmak, broj redova sl.teksta, 
get_pfa4_vars(@nLMargina, @nDodRedova, @nSlTxtRow, @lSamoKol, @lZaglStr, @lDatOtp, @cValuta)

// razmak ce biti
cRazmak := SPACE(nLMargina)

// zaglavlje por.fakt
pf_a4_header()

// podaci kupac i broj dokumenta itd....
pf_a4_kupac(cRazmak)

// definisi liniju 
pf_a4_line(@cLine, cRazmak)

select rn
set order to tag "1"
go top

P_COND

st_zagl_data(cLine, cRazmak)

select rn

nStr:=1

// data
do while !EOF()
	// provjeri za novu stranicu
	if prow() > nDodRedova + 48 - nSlTxtRow
		++nStr
		NStr(cLine, nStr, cRazmak, .t.)
    	endif	
	
	// PRVI RED
	? cRazmak + PADL(rn->rbr + ")", 6) + SPACE(1)
	?? padr(rn->idroba, 10) + SPACE(1)
	?? padr(rn->robanaz, 40) + SPACE(1)
	?? STR(rn->kolicina, 11, 2) + SPACE(1)
	?? rn->jmj + SPACE(1)
	if !lSamoKol
		?? STR(rn->cjenbpdv,11,2) + SPACE(1)
		?? STR(rn->cjen2bpdv,11,2) + SPACE(1)
		?? STR(rn->vpdv,11,2) + SPACE(1)
		?? STR(ukupno, 11,2)
	endif
	
	// DRUGI RED
	if !lSamoKol
		? cRazmak + SPACE(80) + TRANSFORM(rn->popust,"99.99%") + SPACE(1)
		?? STR(rn->cjen2pdv,11,2) + SPACE(1)
		?? PADL(TRANSFORM(rn->ppdv, "999.99%"),11)
	endif
	
	skip
enddo

? cLine

if !lSamoKol
	? cRazmak + PADL("Ukupno bez PDV ("+cValuta+") :", 95), PADL(STR(drn->ukbezpdv, 12, 2),26)
	// provjeri i dodaj stavke vezane za popust
	if Round(drn->ukpopust, 2) <> 0
		? cRazmak + PADL("Popust ("+cValuta+") :", 95), PADL(STR(drn->ukpopust, 12, 2),26)
		? cRazmak + PADL("Uk.bez.PDV-popust ("+cValuta+") :", 95), PADL(STR(drn->ukbpdvpop, 12, 2), 26)
	endif
	? cRazmak + PADL("PDV 17% :", 95), PADL(STR(drn->ukpdv, 12, 2),26)
	? cLine
	? cRazmak + PADL("S V E U K U P N O   S A   P D V ("+cValuta+") :", 95), PADL(STR(drn->ukupno,12,2), 26)
	cSlovima := get_dtxt_opis("D04")
	? cRazmak + "slovima: " + cSlovima
	? cLine
endif

?
// dodaj text na kraju fakture
pf_a4_footer(cRazmak, cLine)

?

FF

EndPrint()

return
*}

// uzmi osnovne parametre za stampu dokumenta
function get_pfa4_vars(nLMargina, nDodRedova, nSlTxtRow, lSamoKol, lZaglStr, lDatOtp, cValuta)
*{

// uzmi podatak za lijevu marginu
nLMargina := VAL(get_dtxt_opis("P01"))

// broj dodatnih redova po listu
nDodRedova := VAL(get_dtxt_opis("P06"))

// uzmi podatak za duzinu slobodnog teksta
nSlTxtRow := VAL(get_dtxt_opis("P02"))

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
function st_zagl_data(cLine, cRazmak)
*{
? cLine

// opis kolona
? cRazmak + " R.br  Sifra      Naziv                                      Kolicina  jmj  C.bez PDV   C.bez PDV   Pojed.PDV   Sveukupno"
? cRazmak + SPACE(75) + " Popust(%)   C.sa PDV    PDV(%)       sa PDV"

? cLine
return
*}


// funkcija za ispis slobodnog teksta na kraju fakture
function pf_a4_sltxt(cRazmak, cLine)
*{
local cTxt
local nFTip

if prow() > nDodRedova + 48 - nSlTxtRow
         NStr(cLine, nil, cRazmak, .f.)
endif


select drntext
set order to tag "1"
hseek "F20"

do while !EOF() .and. field->tip = "F"
	nFTip := VAL(RIGHT(field->tip, 2))
	if nFTip < 51
		cTxt := ALLTRIM(field->opis)
			if !Empty(cTxt)
				? cRazmak + cTxt
			endif
	endif
	skip
enddo

return
*}


// generalna funkcija footer
function pf_a4_footer(cRazmak, cLine)
*{
// ispisi slobodni text
pf_a4_sltxt(cRazmak, cLine)
?
P_12CPI
?
// ispisi potpis na kraju dokumenta
? cRazmak + SPACE(20) + get_dtxt_opis("F10")

return
*}


// funkcija za ispis headera
function pf_a4_header()
*{
local cRazmak := SPACE(1)
local cDLHead := REPLICATE("=", 80) // double line header
local cSLHead := REPLICATE("-", 80) // single line header
local cINaziv
local cIAdresa
local cIIdBroj
local cIBrRjes
local cIPorBr
local cIBrUpis
local cIUstanova
local cIBanke
local aBanke

cINaziv  := get_dtxt_opis("I01") // naziv
cIAdresa := get_dtxt_opis("I02") // adresa
cIIdBroj := get_dtxt_opis("I03") // idbroj
cIPorBr  := get_dtxt_opis("I05") // por.broj
cIBrRjes := get_dtxt_opis("I06") // broj rjesenja
cIBrUpis := get_dtxt_opis("I07") // broj upisa
cIUstanova:= get_dtxt_opis("I08") // ustanova
cIBanke := get_dtxt_opis("I09")
aIBanke := SjeciStr(cIBanke, 73)

P_10CPI
gPB_ON()

? cRazmak + cDLHead
? cRazmak + cINaziv
? cRazmak + REPLICATE("-", LEN(cINaziv))
? cRazmak + "Adresa: " + cIAdresa
? cRazmak + PADR("ID broj: " + cIIdBroj, 30) + PADR("Poreski broj: " + cIPorBr, 50)
? cRazmak + PADR("Broj sudskog rjesenja: " + cIBrRjes, 40) + PADR("Broj upisa: " + cIBrUpis, 30)
? cRazmak + "Ustanova: " + cIUstanova

? cRazmak + cSLHead

? cRazmak + "Banke: "

P_12CPI
// ispisi banke
for i:=1 to LEN(aIBanke)
	if i == 1
		?? aIBanke[i]
	else
		? cRazmak + aIBanke[i] + " "
	endif
next

P_10CPI

? cRazmak + cDLHead

gPB_OFF()

?
?

return
*}


// definicija linije za glavnu tabelu sa stavkama
function pf_a4_line(cLine, cRazmak)
*{
          
cLine := cRazmak
// RBR
cLine += REPLICATE("-", 6) + SPACE(1)
// SIFRA
cLine += REPLICATE("-",10) + SPACE(1)
// NAZIV
cLine += REPLICATE("-",40) + SPACE(1)
// KOLICINA
cLine += REPLICATE("-",11) + SPACE(1)
// JMJ
cLine += REPLICATE("-", 3) + SPACE(1)
// C.BEZ PDV
cLine += REPLICATE("-",11) + SPACE(1)
// C.BEZ PDV
cLine += REPLICATE("-",11) + SPACE(1)
// POJED.PDV
cLine += REPLICATE("-",11) + SPACE(1)
// SVEUKUPNO
cLine += REPLICATE("-",11) + SPACE(1)

return
*}


// funkcija za ispis podataka o kupcu, dokument, datum fakture, otpremnica itd..
function pf_a4_kupac(cRazmak)
*{
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
local cTipDok := "FAKTURA/OTPREMNICA br. "
local cBrDok
local cBrNar
local cBrOtp

drn_open()
select drn
go top

cDatDok := DToC(field->datdok)
cDatIsp := DToC(field->datisp)
cDatVal := DToC(field->datval)
cBrDok := field->brdok

cBrNar :=get_dtxt_opis("D06") 
cBrOtp :=get_dtxt_opis("D05") 
cMjesto:=get_dtxt_opis("D01")
cTipDok:=get_dtxt_opis("D02")
cKNaziv:=get_dtxt_opis("K01")
cKAdresa:=get_dtxt_opis("K02")
cKIdBroj:=get_dtxt_opis("K03")
cKPorBroj:=get_dtxt_opis("K05")
cKBrRjes:=get_dtxt_opis("K06")
cKBrUpisa:=get_dtxt_opis("K07")
cKMjesto:=get_dtxt_opis("K10")+", " + get_dtxt_opis("K11")

aKupac:=Sjecistr(cKNaziv,30)

// naziv, mjesto i datdok
? cRazmak
gPB_ON()
?? padc(alltrim(aKupac[1]),30)
gPB_OFF()
?? padl(cMjesto + ", " + cDatDok, 45)

// adresa
? cRazmak
gPB_ON()
?? padc(cKAdresa,30)
gPB_OFF()
?? padl("Datum isporuke: " + cDatIsp, 45)

// mjesto
? cRazmak
gPB_ON()
?? padc(cKMjesto,30)
gPB_OFF()
?? padl("Datum valute: " + cDatVal, 45)

P_COND
? cRazmak
?? padc("Ident.broj: " + cKIdBroj, 30)
?? padc("Por.broj: " + cKPorBroj, 30)
? cRazmak
?? padc("Br.sud.Rj: " + cKBrRjes, 30)
?? padc("Br.upisa: " + cKBrUpisa, 30)
P_10CPI

gPB_ON()
// broj dokumenta
? padl("#%FS012#" + cTipDok + cBrDok, 83)
gPB_OFF()

// ako je prikaz broja otpremnice itd...
if lDatOtp
	P_10CPI
	P_COND
	? cRazmak + "Broj otpremnice: " + cBrOtp + " , Broj narudzbenice: " + cBrNar
	P_10CPI
else
	?
endif

return
*}



// funkcija za novu stranu
static function NStr(cLine, nStr, cRazmak, lShZagl)
*{

? cLine
? cRazmak + "Prenos na sljedecu stranicu"
? cLine

FF

? cLine
if nStr <> nil
	? cRazmak, "       Strana:", str(nStr, 3)
endif
if lShZagl
	st_zagl_data(cLine, cRazmak)
else
	? cLine
endif

return
*}

