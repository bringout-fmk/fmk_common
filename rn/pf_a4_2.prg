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

st_zagl_data(cLine, cRazmak, "2" )

select rn

nStr:=1
aArtNaz := {}

// data
do while !EOF()
	
	// provjeri za novu stranicu
	if prow() > nDodRedova + 48 - nSlTxtRow
		++nStr
		Nstr_pf_a4(cLine, nStr, cRazmak, .t.)
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
		
		?? TRANSFORM(rn->cjen2pdv, PicCDem) + SPACE(1)

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


? cLine

cRed1 := " R.br  Sifra      Naziv                                      Kolicina  jmj  C.bez PDV   C.bez PDV    C.sa PDV   Uk.bez PDV"
cRed2 := SPACE(75) + " Popust(%)     PDV(%)                Uk.sa PDV"

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



