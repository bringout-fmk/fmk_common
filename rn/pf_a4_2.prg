#include "sc.ch"

// stampa fakture a4
function st_pf_a4_2(lStartPrint)
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
private lStZagl // automatski formirati zaglavlje
private nGMargina // gornja margina
private cPDVSvStavka // varijanta fakture 

if lStartPrint

	if !StartPrint()
		close all
		return
	endif

endif

// uzmi glavne varijable za stampu fakture
// razmak, broj redova sl.teksta, 
get_pfa4_vars(@nLMargina, @nGMargina, @nDodRedova, @nSlTxtRow, @lSamoKol, @lZaglStr, @lStZagl, @lDatOtp, @cValuta, @cPDVSvStavka)

// razmak ce biti
cRazmak := SPACE(nLMargina)

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
pf_a4_kupac(cRazmak)

// definisi liniju 
pf_a4_line(@cLine, cRazmak)

select rn
set order to tag "1"
go top

P_COND

//if cPDVSvStavka == "D"
//	st_zagl_data(cLine, cRazmak, "1" )
//else
st_zagl_data(cLine, cRazmak, "2" )
//endif

select rn

nStr:=1
aArtNaz := {}

// data
do while !EOF()
	
	// provjeri za novu stranicu
	if prow() > nDodRedova + 48 - nSlTxtRow
		++nStr
		NStr(cLine, nStr, cRazmak, .t.)
    	endif	
	
	// uzmi naziv u matricu
	aArtNaz := SjeciStr(rn->robanaz, 40)
	
	// PRVI RED
	
	// redni broj ili podbroj
	if EMPTY(rn->podbr)
		? cRazmak + PADL(rn->rbr + ")", 6) + SPACE(1)
	else
		? cRazmak + PADL(rn->rbr + "." + ALLTRIM(rn->podbr), 6) + SPACE(1)
	endif
	
	// idroba, naziv robe, kolicina, jmj
	?? padr(rn->idroba, 10) + SPACE(1)
	?? padr(aArtNaz[1], 40) + SPACE(1)
	?? TRANSFORM(rn->kolicina, PicKol) + SPACE(1)
	?? rn->jmj + SPACE(1)
	
	// cijene
	if !lSamoKol
		?? TRANSFORM(rn->cjenbpdv, PicCDem) + SPACE(1)
		?? TRANSFORM(rn->cjen2bpdv, PicCDem) + SPACE(1)
		
		// ako je pdv na svaku stavku ispisi PDV
		if cPDVSvStavka == "D"
			?? TRANSFORM(rn->vpdv, PicCDem) + SPACE(1)
		else
			?? TRANSFORM(rn->cjen2pdv, PicCDem) + SPACE(1)
		endif

		// ukupno bez pdv
		?? TRANSFORM( rn->cjen2bpdv * rn->kolicina,  PicDem)
	endif
	
	cArtNaz2Red := SPACE(40)
	
	if LEN(aArtNaz) > 1
		cArtNaz2Red := aArtNaz[2]
	endif
	
	// DRUGI RED
	? cRazmak + SPACE(18) + PADR(cArtNaz2Red, 40)
	
	// ako nisu samo kolicine dodaj i ostale podatke
	if !lSamoKol
		nPopust := rn->popust 
		if rn->(fieldpos("poptp")) <> 0 
			if rn->poptp <> 0
				nPopust := rn->poptp
			endif
		endif
					
		?? SPACE(22) + TRANSFORM(nPopust, "99.99%") + SPACE(1)
		
		if cPDVSvStavka == "D" 
			?? TRANSFORM(rn->cjen2pdv, PicCDem) + SPACE(1)
		endif
		
		?? PADL(TRANSFORM(rn->ppdv, "999.99%"), 11)

		?? SPACE(LEN(PicDem) + 2)
		
		// ukupno sa pdv
		?? TRANSFORM(rn->ukupno , PicDem)

	endif
	
	skip
enddo

? cLine

if !lSamoKol
	? cRazmak + PADL("Ukupno bez PDV ("+cValuta+") :", 95), PADL(TRANSFORM(drn->ukbezpdv, PicDem),26)
	// provjeri i dodaj stavke vezane za popust
	if Round(drn->ukpopust, 2) <> 0
		? cRazmak + PADL("Popust ("+cValuta+") :", 95), PADL(TRANSFORM(drn->ukpopust, PicDem),26)
		? cRazmak + PADL("Uk.bez.PDV-popust ("+cValuta+") :", 95), PADL(TRANSFORM(drn->ukbpdvpop, PicDem), 26)
	endif
	? cRazmak + PADL("PDV 17% :", 95), PADL(TRANSFORM(drn->ukpdv, PicDem),26)
	// zaokruzenje
	if ROUND(drn->zaokr,4) <> 0
			? cRazmak + PADL("Zaokruzenje :", 95), PADL(TRANSFORM(drn->zaokr, PicDem),26)
	endif
	
	? cLine
	? cRazmak + PADL("S V E U K U P N O   S A   P D V ("+cValuta+") :", 95), PADL(TRANSFORM(drn->ukupno, PicDem), 26)

	if drn->(fieldpos("ukpoptp")) <> 0
             if Round(drn->ukpoptp, 2) <> 0
	        // popust na teret prodavca
		? cRazmak + PADL("Popust na teret prodavca ("+cValuta+") :", 95), PADL(TRANSFORM(drn->ukpoptp, PicDem), 26)
	        ? cRazmak + PADL("S V E U K U P N O   S A   P D V -  P O P U S T  N A   T. P. ("+cValuta+") : ZA PLATITI :", 95), PADL(TRANSFORM(drn->ukupno - drn->ukpoptp, PicDem), 26)
	     endif
	endif
	
	cSlovima := get_dtxt_opis("D04")
	? cRazmak + "slovima: " + cSlovima
	? cLine
endif

?
// dodaj text na kraju fakture
pf_a4_footer(cRazmak, cLine)

?

if lStartPrint
	FF
	EndPrint()
endif

return
*}

// zaglavlje glavne tabele sa stavkama
static function st_zagl_data(cLine, cRazmak, cVarijanta)
*{
local cRed1:=""
local cRed2:=""
local cRed3:=""

if cVarijanta == nil
	cVarijanta := "2"
endif

? cLine

do case
	// varijanta 1
	case cVarijanta == "1"
		cRed1 := " R.br  Sifra      Naziv                                      Kolicina  jmj  C.bez PDV   C.bez PDV   Pojed.PDV   Sveukupno"
		cRed2 := SPACE(75) + " Popust(%)   C.sa PDV    PDV(%)       sa PDV"
	case cVarijanta == "2"
		cRed1 := " R.br  Sifra      Naziv                                      Kolicina  jmj  C.bez PDV   C.bez PDV    C.sa PDV   Uk.bez PDV"
		cRed2 := SPACE(75) + " Popust(%)     PDV(%)                Uk.sa PDV"
endcase

if !EMPTY(cRed1)
	? cRazmak + cRed1
endif
if !EMPTY(cRed2)
	? cRazmak + cRed2
endif
if !EMPTY(cRed3)
	? cRazmak + cRed3
endif

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
static function pf_a4_footer(cRazmak, cLine)
*{
// ispisi slobodni text
pf_a4_sltxt(cRazmak, cLine)
?
P_12CPI
?
// ispisi potpis na kraju dokumenta
? cRazmak + SPACE(10) + get_dtxt_opis("F10")

return
*}


// funkcija za ispis headera
static function pf_a4_header()
*{
local cRazmak := SPACE(3)
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

P_10CPI
? cRazmak + cDLHead
B_ON
? cRazmak + cINaziv
? cRazmak + REPLICATE("-", LEN(cINaziv))
B_OFF

P_12CPI
? cRazmak + " Adresa: " + cIAdresa + ",     ID broj: " + cIIdBroj
// ako nije prazno telefon ispisi
if !EMPTY(cITelef)
	? " " + cRazmak + cITelef
endif
// ako nije prazno web ispisi
if !EMPTY(cIWeb)
	? " " + cRazmak + cIWeb
endif

P_10CPI
? cRazmak + cSLHead

P_12CPI
//B_ON
? cRazmak + " Banke: "
// ispisi banke
for i:=1 to LEN(aIBanke)
	if i == 1
		?? aIBanke[i]
	else
		? " " + cRazmak + aIBanke[i] + " "
	endif
next
//B_OFF

P_10CPI
// ako nije prazan slobodni tekst ispisi ga liniju po liniju
if !EMPTY(cIText1 + cIText2 + cIText3)
	? cRazmak + cSLHead
	if !EMPTY(cIText1)
		? cRazmak + cIText1
	endif
	if !EMPTY(cIText2)
		? cRazmak + cIText2
	endif
	if !EMPTY(cIText3)
		? cRazmak + cIText3
	endif
endif

? cRazmak + cDLHead

?
?

return
*}


// definicija linije za glavnu tabelu sa stavkama
static function pf_a4_line(cLine, cRazmak)
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
static function pf_a4_kupac(cRazmak)
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
local cTipDok := "FAKTURA br. "
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
//cKPorBroj:=get_dtxt_opis("K05")
//cKBrRjes:=get_dtxt_opis("K06")
//cKBrUpisa:=get_dtxt_opis("K07")
cKMjesto:=get_dtxt_opis("K10")+", " + get_dtxt_opis("K11")

aKupac:=Sjecistr(cKNaziv,30)

// naziv, mjesto i datdok
? cRazmak
B_ON
?? padc(alltrim(aKupac[1]),30)
B_OFF
?? padl(cMjesto + ", " + cDatDok, 37)

// adresa
? cRazmak
B_ON
?? padc(cKAdresa,30)
B_OFF
if cDatIsp <> DToC(CToD(""))
	?? padl("Datum isporuke: " + cDatIsp, 37)
endif

// mjesto
? cRazmak
B_ON
?? padc(cKMjesto,30)
B_OFF
if cDatVal <> DToC(CTOD(""))
	?? padl("Datum valute: " + cDatVal, 37)
endif

P_COND
? cRazmak
?? SPACE(12) + padc("Ident.broj: " + cKIdBroj, 30)

//?? padc("Por.broj: " + cKPorBroj, 30)
//? cRazmak
//?? padc("Br.sud.Rj: " + cKBrRjes, 30)
//?? padc("Br.upisa: " + cKBrUpisa, 30)

P_10CPI

// broj dokumenta
? space(30)
B_ON
?? padl(cTipDok + cBrDok, 39)
?
B_OFF

// ako je prikaz broja otpremnice itd...
if lDatOtp
	P_10CPI
	P_COND
	if !EMPTY(cBrOtp)
		? cRazmak + "Broj otpremnice: " + cBrOtp 
	endif
	if !EMPTY(cBrNar)
		?? " ,  Broj narudzbenice: " + cBrNar
	endif
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
	if cPDVSvStavka == "D"
		st_zagl_data(cLine, cRazmak, "1" )
	else
		st_zagl_data(cLine, cRazmak, "2" )
	endif
else
	? cLine
endif

return
*}

