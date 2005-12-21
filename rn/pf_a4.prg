#include "sc.ch"

function pf_a4_print()
*{
drn_open()

// stampaj racun
st_pf_a4()

return
*}

function st_pf_a4()
*{
local cBrDok
local dDatDok
local aRNaz
local cArtikal
local cRazmak := SPACE(5)
local cLine
local cSlovima

if !StartPrint()
	close all
	return
endif

// definisi liniju 
pf_a4_line(@cLine)

// zaglavlje por.fakt
pf_a4_header()

// podaci kupac i broj dokumenta itd....
pf_a4_kupac_()

select rn
set order to tag "1"
go top

P_COND

st_zagl_data(cLine)

select rn

nStr:=1

// data
do while !EOF()
	
	if prow() > gERedova + 43
      		if prow() > 50  
         		NStr(cLine, nStr)
			++nStr
      		endif
    	endif	
	
	? cRazmak + PADL(rn->rbr + ")", 6), padr(rn->idroba, 10), padr(rn->robanaz, 40), STR(rn->kolicina, 11, 2), rn->jmj, STR(rn->cjenbpdv,11,2), STR(rn->cjen2bpdv,11,2), STR(rn->vpdv,11,2), STR(ukupno, 11,2)
	
	? SPACE(85) + TRANSFORM(rn->popust,"99.99%"), STR(rn->cjen2pdv,11,2), PADL(TRANSFORM(rn->ppdv, "999.99%"),11)
	
	skip
enddo

? cLine

? cRazmak + PADL("Ukupno bez PDV (KM) :", 95), PADL(STR(drn->ukbezpdv, 12, 2),26)
// dodaj i popust
if Round(drn->ukpopust, 2) <> 0
	? cRazmak + PADL("Popust (KM) :", 95), PADL(STR(drn->ukpopust, 12, 2),26)
	? cRazmak + PADL("Uk.bez.PDV-popust (KM) :", 95), PADL(STR(drn->ukbpdvpop, 12, 2), 26)
endif
? cRazmak + PADL("PDV 17% :", 95), PADL(STR(drn->ukpdv, 12, 2),26)
? cLine
? cRazmak + PADL("S V E U K U P N O   S A   P D V (KM) :", 95), PADL(STR(drn->ukupno,12,2), 26)

cSlovima := get_dtxt_opis("D04")

? cRazmak + "slovima: " + cSlovima

? cLine
?
// dodaj text na kraju fakture
pf_a4_footer()

?

FF

EndPrint()

return
*}


function st_zagl_data(cLine)
*{
? cLine

// opis kolona
? SPACE(6) + "R.br  Sifra      Naziv                                      Kolicina  jmj  C.bez PDV   C.bez PDV   Pojed.PDV   Sveukupno"
? SPACE(81) + "Popust(%)   C.sa PDV    PDV(%)       sa PDV"

? cLine
return
*}


function pf_a4_footer()
*{
local cTxt1
local cTxt2
local cTxt3
local cTxt

cTxt1 := get_dtxt_opis("F04")
cTxt2 := get_dtxt_opis("F05")
cTxt3 := get_dtxt_opis("F06")

cTxt := ""
if cTxt1 <> "???"
	cTxt += cTxt1
endif
if cTxt2 <> "???"
	cTxt += cTxt2
endif
if cTxt3 <> "???"
	cTxt += cTxt3
endif

cTxt := STRTRAN(cTxt, "" + Chr(10), "")
cTxt := STRTRAN(cTxt, Chr(13) + Chr(10), Chr(13) +Chr(10) + space(5))

? space(5)
?? cTxt
?
?

P_12CPI

?
? SPACE(5) + get_dtxt_opis("F10")

return
*}


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


function pf_a4_line(cLine)
*{
          
cLine := SPACE(5)
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


function pf_a4_kupac()
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

drn_open()
select drn
go top

cDatDok := DToC(field->datdok)
cDatIsp := DToC(field->datisp)
cDatVal := DToC(field->datval)
cBrDok := field->brdok

cMjesto:=get_dtxt_opis("D01")
cKNaziv:=get_dtxt_opis("K01")
cKAdresa:=get_dtxt_opis("K02")
cKIdBroj:=get_dtxt_opis("K03")
cKPorBroj:=get_dtxt_opis("K05")
cKBrRjes:=get_dtxt_opis("K06")
cKBrUpisa:=get_dtxt_opis("K07")
cKMjesto:=get_dtxt_opis("K10")+", " + get_dtxt_opis("K11")

aKupac:=Sjecistr(cKNaziv,30)

// naziv, mjesto i datdok
? space(5)
gPB_ON()
?? padc(alltrim(aKupac[1]),30)
gPB_OFF()
?? padl(cMjesto + ", " + cDatDok, 45)

// adresa
? space(5)
gPB_ON()
?? padc(cKAdresa,30)
gPB_OFF()
?? padl("Datum isporuke: " + cDatIsp, 45)

// mjesto
? space(5)
gPB_ON()
?? padc(cKMjesto,30)
gPB_OFF()
?? padl("Datum valute: " + cDatVal, 45)

P_COND
? space(5)
?? padc("Ident.broj: " + cKIdBroj, 30)
//? space(5)
?? padc("Por.broj: " + cKPorBroj, 30)
? space(5)
?? padc("Br.sud.Rj: " + cKBrRjes, 30)
//? space(5)
?? padc("Br.upisa: " + cKBrUpisa, 30)
P_10CPI

gPB_ON()
// broj dokumenta
? padl("#%FS012#" + cTipDok + cBrDok, 83)
gPB_OFF()

?

return
*}


static function NStr(cLine, nStr)
*{

? cLine
? space(5) + "Prenos na sljedecu stranicu"
? cLine

FF

? cLine
? space(5), "       Strana:", str(nStr, 3)
st_zagl_data(cLine)

return
*}

