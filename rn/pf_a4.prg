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

static LEN_RBR := 6
// naziv dobra
static LEN_NAZIV := 0

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

static LEN_STRANICA := 58
static LEN_REKAP_PDV := 7

static RAZMAK := ""

static nStr := 0
static lPrintedTotal := .f.

// ako se koristi PTXT onda se ova korekcija primjenjuje
// za prikaz vecih fontova
static nDuzStrKorekcija := 0

static lShowPopust := .t.
static lKomision := .f.

// linije sa "=" prva i zadnja
static nSw1
// linija sa "-" prva
static nSw2
// local sa "-" druga
static nSw3
// linija ispod kupac
static nSw4
// header broj redova - slika
static nPicHRow
// footer broj redova - slika
static nPicFRow

// ------------------------------------------------------
// glavna funkcija za poziv stampe fakture a4
// lStartPrint - pozovi funkcije stampe START PRINT
// -----------------------------------------------------
function pf_a4_print(lStartPrint, cDocumentName)

// ako je nil onda je uvijek .t.
if lStartPrint == nil
	lStartPrint := .t.
endif

PIC_KOLICINA :=  PADL(ALLTRIM(RIGHT(PicKol, LEN_KOLICINA)), LEN_KOLICINA, "9")
PIC_VRIJEDNOST := PADL(ALLTRIM(RIGHT(PicDem, LEN_VRIJEDNOST)), LEN_VRIJEDNOST, "9")
PIC_CIJENA := PADL(ALLTRIM(RIGHT(PicCDem, LEN_CIJENA)), LEN_CIJENA, "9")

drn_open()

select drn
go top

LEN_NAZIV(53)
LEN_UKUPNO(99)
if Round(drn->ukpopust, 2) <> 0
	lShowPopust :=.t.
else
	lShowPopust:=.f.
	LEN_NAZIV += LEN_PROC2 + LEN_CIJENA + 2
endif

if (gPdvDokVar == "1")
 // stampaj racun
 st_pf_a4(lStartPrint, cDocumentName)
else
 st_pf_a4_2(lStartPrint, cDocumentName)
endif

return


// stampa fakture a4
function st_pf_a4(lStartPrint, cDocumentName)
local cBrDok
local dDatDok
local aRNaz
local cArtikal
local cSlovima
local cLine

// lijeva margina
private nLMargina
// broj dodatnih redova
private nDodRedova
// broj redova slobodnog text-a
private nSlTxtRow
// prikaz samo kolicina
private lSamoKol
// zaglavlje na svakoj stranici
private lZaglStr
// prikaz datuma otpremnice i narudzbenice
private lDatOtp
// prikaz valute KM ili ???
private cValuta
// automatski formirati zaglavlje
private lStZagl
// gornja margina
private nGMargina 

nDuzStrKorekcija := 0

lPrintedTotal := .f.

if lStartPrint

	if !StartPrint(nil, nil, cDocumentName)
		close all
		return
	endif

endif

nSw1 := VAL(get_dtxt_opis("X04"))
nSw2 := VAL(get_dtxt_opis("X05"))
nSw3 := VAL(get_dtxt_opis("X06"))
nSw4 := VAL(get_dtxt_opis("X07"))

nPicHRow := VAL(get_dtxt_opis("X11"))
nPicFRow := VAL(get_dtxt_opis("X12"))

// uzmi glavne varijable za stampu fakture
// razmak, broj redova sl.teksta, 
get_pfa4_vars(@nLMargina, @nGMargina, @nDodRedova, @nSlTxtRow, @lSamoKol, @lZaglStr, @lStZagl, @lDatOtp, @cValuta)

// razmak ce biti
RAZMAK:= SPACE(nLMargina)

// dodaj sliku headera
if nPicHRow > 1
	// put picture code
	?
	gpPicH( nPicHRow )
endif

if lStZagl == .t.
	// zaglavlje por.fakt
	a4_header()
else
	if gPDFPrint <> "D"
	// ostavi prostor umjesto automatskog zaglavlja
		for i:=1 to nGMargina
			?
		next
	else
		?
	endif
endif

// podaci kupac i broj dokumenta itd....
pf_a4_kupac()

cLine := a4_line( "pf" )

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

	nQty := pcol()
	
	?? show_number(rn->kolicina, PIC_KOLICINA) 
	?? " "
	
	// cijene
	if !lSamoKol
		
		// cijena bez pdv
		?? show_number(rn->cjenbpdv, PIC_CIJENA) 
		?? " "
		
		if lShowPopust
			// procenat popusta
			?? show_popust(rn->popust)
			?? " "

			// cijena bez pd - popust
			?? show_number(rn->cjen2bpdv, PIC_CIJENA) 
			?? " "
		endif
		
		// ukupno bez pdv
		?? show_number( rn->cjenbpdv * rn->kolicina,  PIC_VRIJEDNOST)
	endif
	
	
	if LEN(aNazivDobra) > 1
	    // DRUGI RED
	    ? RAZMAK
	    ?? " "
	    ?? SPACE(LEN_RBR)
	    ?? PADR(aNazivDobra[2], LEN_NAZIV)
	endif
	
	// opis
	if !EMPTY( rn->opis )
		? RAZMAK
		?? " "
		?? SPACE(LEN_RBR)
		?? ALLTRIM(rn->opis)
	endif
	// c1, c2, c3
	if !EMPTY( rn->c1 ) .or. !EMPTY( rn->c2 ) .or. !EMPTY( rn->c3 )
		? RAZMAK
		?? " "
		?? SPACE(LEN_RBR)
		?? ALLTRIM(rn->c1) + ", " + ALLTRIM(rn->c2) + ", " + ALLTRIM(rn->c3)
	endif
	
	// provjeri za novu stranicu
	if prow() > nDodRedova + LEN_STRANICA - DSTR_KOREKCIJA() - PICT_KOREKCIJA(nStr)
		++nStr
		Nstr_a4(nStr, .t.)
    	endif	

	SELECT rn
	skip
enddo

// provjeri za novu stranicu
if prow() > nDodRedova + (LEN_STRANICA - LEN_REKAP_PDV) - DSTR_KOREKCIJA() - PICT_KOREKCIJA(nStr)
	
	++nStr
	Nstr_a4(nStr, .t.)

endif	

? cLine

if lSamoKol
	// prikazi ukupno kolicinu
	?
	@ prow(), nQty SAY show_number(drn->ukkol, PIC_KOLICINA)
endif

if !lSamoKol
	print_total(cValuta, cLine)
endif

lPrintedTotal := .t.

if prow() > nDodRedova + (LEN_STRANICA - LEN_REKAP_PDV) - DSTR_KOREKCIJA() - PICT_KOREKCIJA(nStr)
	++nStr
	Nstr_a4(nStr, .t.)
	
endif	

?

// dodaj text na kraju fakture
a4_footer()

// dodaj sliku footera
//if nPicFRow > 0
	
	// daj slobodne redove do kraja...... stranice
	//nPom := nDodRedova + (LEN_STRANICA - LEN_REKAP_PDV) - DSTR_KOREKCIJA() - PICT_KOREKCIJA(nStr) - prow()
	
	//for nI := 0 to nPom
	//	?
	//next	
	
	// put pic footer code
	//gpPicF()
	
//endif

if lStartPrint
	FF
	EndPrint()
endif

return



// uzmi osnovne parametre za stampu dokumenta
function get_pfa4_vars(nLMargina, nGMargina, nDodRedova, nSlTxtRow, lSamoKol, lZaglStr, lStZagl, lDatOtp, cValuta, cPDVStavka)


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



// zaglavlje glavne tabele sa stavkama
static function st_zagl_data()
local cLine
local cRed1:=""
local cRed2:=""
local cRed3:=""

cLine := a4_line("pf")

? cLine

cRed1 := RAZMAK 
cRed1 += PADC("R.br", LEN_RBR) 
cRed1 += " " + PADR(lokal("Trgovacki naziv dobra/usluge (sifra, naziv, jmj)"), LEN_NAZIV)
cRed1 += " " + PADC(lokal("kolicina"), LEN_KOLICINA)
cRed1 += " " + PADC(lokal("C.b.PDV"), LEN_CIJENA)
if lShowPopust
 cRed1 += " " + PADC(lokal("Pop.%"), LEN_PROC2)
 cRed1 += " " + PADC(lokal("C.2.b.PDV"), LEN_CIJENA)
endif
cRed1 += " " + PADC(lokal("Uk.bez.PDV"), LEN_VRIJEDNOST)

? cRed1

? cLine

return



// funkcija za ispis slobodnog teksta na kraju fakture
static function pf_a4_sltxt()
local cLine
local cTxt
local nFTip

cLine := a4_line("pf")

if prow() > nDodRedova + LEN_STRANICA - DSTR_KOREKCIJA() - PICT_KOREKCIJA(nStr)
         ++nStr
	 Nstr_a4(nil, .f.)
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

	if prow() > nDodRedova + LEN_STRANICA - DSTR_KOREKCIJA() - PICT_KOREKCIJA(nStr)
		 ++nStr
        	 Nstr_a4(nil, .f.)
	endif

	skip
enddo

return


// generalna funkcija footer
function a4_footer()
local cLine 

cLine := a4_line("pf")

// ispisi slobodni text
pf_a4_sltxt(cLine)
?
P_12CPI
?

cPotpis:= get_dtxt_opis("F10")

cPotpis:=STRTRAN(cPotpis, "?S_5?", SPACE(5) )
cPotpis:=STRTRAN(cPotpis, "?S_10?", SPACE(10) )

aPotpis:= lomi_tarabe(cPotpis)

for i :=1 to LEN(aPotpis)
   p_line( aPotpis[i], 10, .f.)
next

return



// --------------------------
// funkcija za ispis headera
// ----------------------------
function a4_header()
local cPom
local nPom

local nPos1

local cDLHead 
local cSLHead 
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
local nPRowsDelta

// double line header
cDLHead := REPLICATE("=", nSw1())
// single line header
cSLHead := REPLICATE("-", nSw3())
nPRowsDelta := prow()
// naziv
cINaziv  := get_dtxt_opis("I01")
// pomocni opis
cIPNaziv  := get_dtxt_opis("I20")
// adresa
cIAdresa := get_dtxt_opis("I02")
// idbroj
cIIdBroj := get_dtxt_opis("I03") 
cIBanke  := get_dtxt_opis("I09")

if "##" $ cIBanke
	// rucno lomi
	aIBanke:={}

	do while .t.
	  nPos1 := AT("##", cIBanke)
	  if nPos1 == 0
	  	// nema vise sta lomiti
	  	AADD(aIBanke, cIBanke)
		exit
	  endif
 	  AADD(aIBanke, LEFT( cIBanke, nPos1 - 1))
          // ostatak	
	  cIBanke:=SUBSTR( cIBanke, nPos1 + 2)
	enddo
	
else
        aIBanke  := SjeciStr(cIBanke, 68)
endif

cITelef  := get_dtxt_opis("I10") // telefoni
cIWeb    := get_dtxt_opis("I11") // email-web
cIText1  := get_dtxt_opis("I12") // sl.text 1
cIText2  := get_dtxt_opis("I13") // sl.text 2
cIText3  := get_dtxt_opis("I14") // sl.text 3

p_line(cDLHead, 10, .t.)

cTmp := ALLTRIM( cINaziv )
aTmp := SjeciStr( cTmp, 74 )
// ispisi naziv firme u gornjem dijelu zaglavlja
for i:=1 to LEN(aTmp)
	p_line( aTmp[i], 10, .t.)
next

// ispisi dodatni tekst ispod naziva firme
if !EMPTY( cIPNaziv )
	cTmp := ALLTRIM( cIPNaziv )
	aTmp := SjeciStr( cTmp, 74 )
	i := 1
	for i:=1 to LEN( aTmp )
		p_line( aTmp[i], 10, .t. )
	next
endif

if nSw2 == 1
	// ako je 1 neka ima duzinu kao naziv firme
	nPom := LEN(cINaziv) 
elseif nSw2 == 0
	// ne prikazuj
	nPom := 0
else
	// duzina zadata
	nPom := nSw2
endif
cPom := REPLICATE("-", nPom)
p_line( cPom , 10, .t.)


p_line(lokal("Adresa: ") + cIAdresa + lokal(", ID broj: ") + cIIdBroj, 12, .f.)
p_line(cITelef, 12, .f.)
p_line(cIWeb, 12, .f.)
p_line(cSLHead, 10, .f.)

p_line(lokal("Banke: "), 12, .f.)
for i:=1 to LEN(aIBanke)
	if i == 1
		?? aIBanke[i]
	else
		p_line(SPACE(7) + aIBanke[i], 12, .f.)
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

nPRowsDelta:= prow() - nPRowsDelta 
if IsPtxtOutput()
	nDuzStrKorekcija += nPRowsDelta * 7/100 
endif

return



// definicija linije za glavnu tabelu sa stavkama
function a4_line(cTip)
local cLine

if cTip == "otpr_mp"
	otpr_mp_line()
	return
endif

// standardna porezna faktura

cLine:= RAZMAK
cLine += REPLICATE("-", LEN_RBR)
cLine += " " + REPLICATE("-", LEN_NAZIV)
// kolicina
cLine += " " + REPLICATE("-", LEN_KOLICINA)
// cijena b. pdv
cLine += " " + REPLICATE("-", LEN_CIJENA)

if lShowPopust
 // popust
 cLine += " " + REPLICATE("-", LEN_PROC2)
 // cijen b. pdv - popust
 cLine += " " + REPLICATE("-", LEN_CIJENA)
endif
// vrijednost b. pdv
cLine += " " + REPLICATE("-", LEN_VRIJEDNOST)

return cLine


// ---------------------------------------------------------------------------
// funkcija za ispis podataka o kupcu, dokument, datum fakture, otpremnica itd..
static function pf_a4_kupac()
local cPartMjesto
local cPartPTT
local cKNaziv
local cKAdresa
local cKIdBroj
local cKPorBroj
local cKBrRjes
local cKBrUpisa
local cKMjesto
local cKTelFax
local aKupac
local cMjesto
local cDatDok
local cFiscal
local cDatIsp
local cDatVal
local cTipDok := lokal("FAKTURA br. ")
local cBrDok
local cBrNar
local cBrOtp
local cIdVd
local cDokVeza
local n
local nLines
local i
local cLinijaNarOtp 

// nRowsIznad - Redova iznad kupca
// nRowsIspod - Redova ispod kupca - izmedju dna kupac - tabela
// nRowsOdTabele - Redova izmedju broja ugovora i tabele
// ---------------------------------------------------------------------------
local nRowsIznad
local nRowsIspod
local nRowsOdTabele

// koliko je redova odstampano u zaglavlju
local nPRowsDelta


nPRowsDelta := prow()

nRowsIznad := VAL(get_dtxt_opis("X01"))
nRowsIspod := VAL(get_dtxt_opis("X02"))
nRowsOdTabele := VAL(get_dtxt_opis("X03"))

nShowRj := VAL(get_dtxt_opis("X10"))

// redova iznad
if nRowsIznad == nil
	nRowsIznad := 0
endif

// redova ispod
if nRowsIspod == nil
	nRowsIspod := 0
endif

// redova ispod linije broj narudzbe/otpremnice i tabele
if nRowsOdTabele == nil
	nRowsOdTabele := 0
endif

// prije broja dokumenta prikazi i idfirma (radna jedinica)
if nShowRj == nil
	nShowRj := 0
endif

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
cRNalID := get_dtxt_opis("O01")
cRnalDesc := get_dtxt_opis("O02")
cIdVd:=get_dtxt_opis("D09")
cFiscal:=ALLTRIM( get_dtxt_opis("O10") )
 
nLines := VAL( get_dtxt_opis("D30") )
cDokVeza := ""
nTmp := 30
for n := 1 to nLines
	cDokVeza += get_dtxt_opis("D" + ALLTRIM(STR( nTmp + n )))
next

if nShowRj == 1
	cIdRj:=get_dtxt_opis("D10")
endif

//K10 - partner mjesto
cPartMjesto := get_dtxt_opis("K10") 
//K11 - partner PTT
cPartPTT := get_dtxt_opis("K11")
cInoDomaci:=ALLTRIM(get_dtxt_opis("P11"))


cKMjesto:= ALLTRIM(cPartMjesto)
if !EMPTY(cPartPTT)
 cKMjesto := ALLTRIM(cPartPTT) + " " + cKMjesto
endif

aKupac:=Sjecistr(cKNaziv, 30)

cPom:=""

// redova iznad
for i:=1 to nRowsIznad
	?
next

lKomision := .f.

do case
  case cIdVd == "12" .and. cInoDomaci == "KOMISION"
  	// komisiona otpremnica
	cPom := lokal("Komisionar:")
	lKomision:=.t.
	
  case ALLTRIM(cInoDomaci) == "INO"
  
	do case
	  case cIdVd $ "10#11#20#22#29"
		// ino partner
		cPom:= lokal("Ino-Kupac:")
	  otherwise
	  	cPom:= lokal("Partner")
	endcase
		
   case ALLTRIM(cInoDomaci) == "DOMACA"

	do case
	  case cIdVd == "12"
		// otpremnica - subjekat koji zaduzuje
		cPom:= lokal("Prima:")
		
	  case cIdVd $ "10#11#20#29"
		cPom:= lokal("Kupac:")
	  otherwise
	  	cPom := lokal("Partner:")
	endcase
		
   otherwise
	// obracun PDV-a po nekom osnovu = 0
	do case
	  case cIdVd == "12"
		cPom := lokal("Zaduzuje:")
	  case cIdVd $ "10#11#20#29"
		// kupac oslobodjen PDV-a po nekom clanu ZPDV
		cPom:= lokal("Kupac, oslobodjen PDV, cl. ") + ALLTRIM(cInoDomaci)
	  otherwise
	  	cPom:=lokal("Partner")
	endcase
	
endcase	

I_ON
p_line( cPom , 10, .t.)
p_line( REPLICATE("-", nSw4) , 10, .f.)
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
	if !(cIdVd $ "12#00#01")
		?? padl(lokal("Datum isporuke: ") + cDatIsp, LEN_DATUM)
	endif
endif

// mjesto
cPom := ALLTRIM(cKMjesto)
if EMPTY(cPom)
  cPom := "-"
endif
p_line(SPACE(2) + PADR(cPom, LEN_KUPAC), 10, .t.)
B_OFF
// u istom redu datum valute
if cDatVal <> DToC(CTOD(""))
	if !(cIdVd $ "12#00#01#20")
		?? padl(lokal("Datum valute: ") + cDatVal, LEN_DATUM)
	endif
endif

// identifikacijski broj
cPom := ALLTRIM(cKIdBroj)
if EMPTY(cPom)
  cPom := "-"
endif
cPom := lokal("ID broj: ") + cPom
p_line(SPACE(2) + PADR(cPom, LEN_KUPAC), 10, .f.)

cKTelFax:=""
cPom:=ALLTRIM(get_dtxt_opis("K13"))
if !empty(cPom)
	cKTelFax:=lokal("tel: ")+ cPom
endif
cPom:=ALLTRIM(get_dtxt_opis("K14"))
if !empty(cPom)
	if !empty(cKTelFax)
		cKTelFax += ", "
	endif
	cKTelFax += lokal("fax: ") + cPom
endif

if !EMPTY(cKTelFax)
	p_line(SPACE(2), 10, .f., .t.)
	P_12CPI
	?? PADR(cKTelFax, LEN_KUPAC)
endif

if !EMPTY( cDokVeza ) .and. cDokVeza <> "-"
	
	// specificno za radni nalog
	cDokVeza := "Veza: " + ALLTRIM(cDokVeza)	
	
	aDokVeza := SjeciStr( cDokVeza, 70 )
	
	for i := 1 to LEN( aDokVeza )
		p_line(SPACE(2), 10, .f., .t.)
		?? aDokVeza[ i ]
	next
endif

if !EMPTY( cRNalId ) .and. cRNalId <> "-"
	
	cPom := " R.nal.: "
	cPom += "(" + cRNalId + ") " + cRNalDesc
	
	if EMPTY( cDokVeza )
		p_line(SPACE(2), 10, .f., .t.)
	endif

	?? ALLTRIM( cPom )
endif

if !EMPTY(cDestinacija)
	
	p_line( REPLICATE("-", LEN_KUPAC - 10) , 10, .f.)
 	
	cPom := lokal("Za: ")  + ALLTRIM( cDestinacija )
 	aPom := SjeciStr( cPom, 75 )
	
	B_ON
	
	for i := 1 to LEN( aPom )
		p_line( aPom[i] , 12 , .f.)
 	next
	
	B_OFF
	
	?
endif

if !EMPTY( cFiscal ) .and. cFiscal <> "0"
	p_line( "   Broj fiskalnog racuna: " + ALLTRIM(cFiscal), 10, .f., .t.)
endif

P_10CPI
// broj dokumenta

cPom := ALLTRIM(cTipDok)
if lKomision
	cPom := lokal("KOMISIONA DOSTAVNICA br. ")
endif

if nShowRj == 1
	cPom += cIdRj + "-" + cBrDok
else
	cPom += " " + cBrDok
endif

cPom := ALLTRIM(cPom)
p_line( PADL( cPom, LEN_KUPAC + LEN_DATUM), 10, .t.)
B_OFF

// redova ispod
for i:=1 to nRowsIspod
	? 
next

// ako je prikaz broja otpremnice itd...

cLinijaNarOtp := ""
cPom := cBrOtp
lBrOtpr := .f.
if !empty(cPom)
	cLinijaNarOtp := lokal("Broj otpremnice: ") + cPom
	lBrOtpr := .t.
endif

cPom := cBrNar
if !empty(cPom)
	if lBrOtpr
		cLinijaNarOtp += " , "
	endif
	cLinijaNarOtp += lokal("Broj ugov./narudzb: ") + cPom
endif

if !EMPTY(cLinijaNarOtp)
    p_line(cLinijaNarOtp, 12, .f.)

    for i:=1 to nRowsOdTabele
		?
    next

else

    // samo ako maloprije nije bilo odvajanja
    // da ne pravimo nepotrebni prazan prostor
    if nRowsIspod == 0
	    for i:=1 to nRowsOdTabele
		?
	    next
    endif
    
endif

// koliko je redova odstampano u zaglavlju
nPRowsDelta :=  prow() - nPRowsDelta

if IsPtxtOutput()
	nDuzStrKorekcija += nPRowsDelta * 7/100 
endif


return
*}


// funkcija za novu stranu
static function NStr_a4(nStr, lShZagl)
*{
local cLine

cLine := a4_line("pf")

// korekcija duzine je na svako strani razlicita
nDuzStrKorekcija := 0 

P_COND
? cLine
p_line( lokal("Prenos na sljedecu stranicu"), 17, .f. )
? cLine

if nPicFRow > 0
	// za sada nam ne treba....
	//?
	//gpPicF()
endif

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
		print_total(cValuta, cLine)
	endif
else
	? cLine
endif

return
*}


// ---------------------------------------
// printaj rekapitulaciju PDV-a
// ---------------------------------------
static function print_total(cValuta, cLine)

? RAZMAK
?? PADL(lokal("Ukupno bez PDV (")+cValuta+") :", LEN_UKUPNO)
?? show_number(drn->ukbezpdv, PIC_VRIJEDNOST)
   
// provjeri i dodaj stavke vezane za popust
if Round(drn->ukpopust, 2) <> 0
		? RAZMAK 
		?? PADL(lokal("Popust (")+cValuta+") :", LEN_UKUPNO)
		?? show_number(drn->ukpopust, PIC_VRIJEDNOST)
		
		? RAZMAK 
		?? PADL(lokal("Uk.bez.PDV-popust (")+cValuta+") :", LEN_UKUPNO)
		?? show_number(drn->ukbpdvpop, PIC_VRIJEDNOST)
endif
	
    
? RAZMAK 
?? PADL(lokal("PDV 17% :"), LEN_UKUPNO)
?? show_number(drn->ukpdv, PIC_VRIJEDNOST)
    
// zaokruzenje
if ROUND(drn->zaokr,2) <> 0
	? RAZMAK 
	?? PADL(lokal("Zaokruzenje (+/-):"), LEN_UKUPNO)
	?? show_number(ABS(drn->zaokr), PIC_VRIJEDNOST)
endif
	
? cLine
? RAZMAK
// ipak izleti za dva karaktera rekapitulacija u bold rezimu
?? SPACE(50 - 2)
B_ON
?? PADL(lokal("** SVEUKUPNO SA PDV  (")+cValuta+") :", LEN_UKUPNO - 50)
?? show_number(drn->ukupno, PIC_VRIJEDNOST)
B_OFF

// popust na teret prodavca 
if drn->(fieldpos("ukpoptp")) <> 0
             if Round(drn->ukpoptp, 2) <> 0
		? RAZMAK
		?? PADL(lokal("Popust na teret prodavca (")+cValuta+") :", LEN_UKUPNO)
		?? show_number(drn->ukpoptp, PIC_VRIJEDNOST)
		
	        ? RAZMAK 
		?? SPACE(50 - 2)
		B_ON
		? PADL(lokal("SVEUKUPNO SA PDV - POPUST NA T.P. (")+cValuta+lokal(") : ZA PLATITI :"), LEN_UKUPNO - 50)
		?? show_number(drn->ukupno - drn->ukpoptp, PIC_VRIJEDNOST)
		B_OFF
	     endif
endif
	
cSlovima := get_dtxt_opis("D04")
? RAZMAK 
B_ON
?? lokal("slovima: ") + cSlovima
B_OFF
? cLine
return


// --------------------------------------------
// --------------------------------------------
function NazivDobra(cIdRoba, cRobaNaz, cJmj)
local cPom

cPom := ALLTRIM(cIdRoba)
cPom += " - " + ALLTRIM(cRobaNaz)
if !EMPTY(cJmj)
	cPom += " (" + ALLTRIM (cJmj) + ")"
endif

return cPom


// -------------------------------------
// -------------------------------------
function show_popust(nPopust)
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


// ---------------------------------------------
// ---------------------------------------------
function p_line(cPLine, nCpi, lBold, lNewLine)
// ako nije prazno telefon ispisi

if lNewLine == nil
	lNewline := .f.
endif

if EMPTY(cPLine) 
 if lNewLine
  // odstampaj i praznu liniju
  if LEN(cPLine) == 0
  	cPLine := " "
  endif
 else
  return
 endif
endif


// odstapaj razmak u COND rezimu
?
P_COND
?? RAZMAK
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


// ---------------------------------
// ---------------------------------
function len_rbr(xPom)
if xPom <> NIL
	LEN_RBR := xPom
endif
return LEN_RBR


function len_naziv(xPom)
if xPom <> NIL
	LEN_NAZIV := xPom
endif
return LEN_NAZIV

function len_ukupno(xPom)
if xPom <> NIL
	LEN_UKUPNO:= xPom
endif
return LEN_UKUPNO

function len_kupac(xPom)
if xPom <> NIL
	LEN_KUPAC:= xPom
endif
return LEN_KUPAC

function len_datum(xPom)
if xPom <> NIL
	LEN_DATUM := xPom
endif
return LEN_DATUM

function len_kolicina(xPom)
if xPom <> NIL
	LEN_KOLICINA := xPom
endif
return LEN_KOLICINA

function len_cijena(xPom)
if xPom <> NIL
	LEN_CIJENA:= xPom
endif
return LEN_CIJENA

function len_vrijednost(xPom)
if xPom <> NIL
	LEN_VRIJEDNOST := xPom
endif
return LEN_VRIJEDNOST

function len_proc2(xPom)
if xPom <> NIL
	LEN_PROC2 := xPom
endif
return LEN_PROC2

function dec_proc2(xPom)
if xPom <> NIL
	DEC_PROC2 := xPom
endif
return DEC_PROC2

function dec_kolicina(xPom)
if xPom <> NIL
	DEC_KOLICINA := xPom
endif
return DEC_KOLICINA

function dec_cijena(xPom)
if xPom <> NIL
	DEC_CIJENA := xPom
endif
return DEC_CIJENA

function dec_vrijednost(xPom)
if xPom <> NIL
	DEC_VRIJEDNOST := xPom
endif
return DEC_VRIJEDNOST

function pic_proc2(xPom)
if xPom <> NIL
	PIC_PROC2 := xPom
endif
return PIC_PROC2

function pic_kolicina(xPom)
if xPom <> NIL
	PIC_KOLICINA := xPom
endif
return PIC_KOLICINA

function pic_cijena(xPom)
if xPom <> NIL
	PIC_CIJENA := xPom
elseif EMPTY(PIC_CIJENA)
    PIC_CIJENA := PADL(ALLTRIM(RIGHT(PicCDem, LEN_CIJENA)), LEN_CIJENA, "9")
endif
return PIC_CIJENA

function pic_vrijednost(xPom)
if xPom <> NIL
	PIC_VRIJEDNOST := xPom
endif
return PIC_VRIJEDNOST

function len_stranica(xPom)
if xPom <> NIL
	LEN_STRANICA := xPom
endif
return LEN_STRANICA  

function len_rekap_pdv(xPom)
if xPom <> NIL
	LDE_REKAP_PDV := xPom
endif
return LEN_REKAP_PDV

// ------------------------------
// ------------------------------
function razmak(xPom)
if xPom <> NIL
	RAZMAK := xPom
endif
return RAZMAK

// ------------------------------
// ------------------------------
function nSw1(xPom)
if xPom <> NIL
	nSw1 := xPom
endif
return nSw1
// ------------------------------
// ------------------------------
function nSw2(xPom)
if xPom <> NIL
	nSw2 := xPom
endif
return nSw2
// ------------------------------
// ------------------------------
function nSw3(xPom)
if xPom <> NIL
	nSw3 := xPom
endif
return nSw3

// ------------------------------
// ------------------------------
function nSw4(xPom)
if xPom <> NIL
	nSw4 := xPom
endif
return nSw4

// ------------------------------
// ------------------------------
function nSw5(xPom)
if xPom <> NIL
	nSw5 := xPom
endif
return nSw5



// ------------------------------
// ------------------------------
function lomi_tarabe(cLomi)
local nPos1
local aLomi

// rucno lomi
aLomi:={}

do while .t.
	  nPos1 := AT("##", cLomi)
	  if nPos1 == 0
	  	// nema vise sta lomiti
	  	AADD(aLomi, cLomi)
		exit
	  endif
 	  AADD(aLomi, LEFT( cLomi, nPos1 - 1))
          // ostatak	
	  cLomi:=SUBSTR( cLomi, nPos1 + 2)
enddo
	

return aLomi

// --------------------------
// --------------------------
function IsPtxtOutput()
return gpIni == "#%INI__#"


// --------------------------------
// korekcija za duzinu strane
// --------------------------------
static function	DSTR_KOREKCIJA()
local nPom
altd()
nPom := ROUND(nDuzStrKorekcija, 0)
if ROUND(nDuzStrKorekcija - nPom, 1) > 0.2
	nPom ++
endif

return nPom


// --------------------------------
// PICTURE korekcija duzine
// --------------------------------
static function	PICT_KOREKCIJA( nStr )
local nPom

if nPicHRow == nil
	nPicHRow := 0
endif
if nPicFRow == nil
	nPicFRow := 0
endif

if nStr == 1
	nPom := ( nPicHRow + nPicFRow )
else
	nPom := nPicFRow
endif

return nPom


