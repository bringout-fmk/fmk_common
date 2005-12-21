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
local cRazmak := SPACE(1)
local cLine
local cSlovima

if !lSSIP99 .and. !StartPrint()
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

? cLine

// opis kolona
? " R.br  Sifra     Naziv                        Kolicina  jmj   C.bez PDV  C.bez PDV  Pojed.PDV   Sveukupno"
? "                                                              Popust(%)  C.sa PDV      PDV(%)     sa PDV"

? cLine

select rn

// data
do while !EOF()
	// rbr
	? cRazmak + PADL(rn->rbr + ")", 6), padr(rn->idroba, 10), padr(rn->robanaz, 40), STR(rn->kolicina, 10, 2), rn->jmj, STR(rn->cjenbpdv,12,2), STR(rn->cjen2bpdv,12,2), STR(rn->vpdv,12,2), STR(ukupno, 12,2)
	
	? SPACE(70) + TRANSFORM(rn->popust,"99.9%"), STR(rn->cjen2pdv), TRANSFORM(rn->ppdv, "999.9%")
	
	skip
enddo

? cLine
?
? cRazmak + PADL("Ukupno bez PDV (KM):", 70), STR(drn->ukbezpdv, 12, 2)
// dodaj i popust
if Round(drn->ukpopust, 2) <> 0
	? cRazmak + PADL("Popust (KM):", 70), STR(drn->ukpopust, 12, 2)
	? cRazmak + PADL("Uk.bez.PDV-popust (KM):", 70), STR(drn->ukbpdvpop, 12, 2)
endif
? cRazmak + PADL("PDV 17% :", 70), STR(drn->ukpdv, 12, 2)
? cLine
? cRazmak + PADL("UKUPNO ZA NAPLATU (KM):", 70), STR(drn->ukupno,12,2)

cSlovima := get_dtxt_opis("D04")

? cRazmak + "slovima: " + cSlovima

? cLine
?
// dodaj text na kraju fakture
pf_a4_footer()

?
?
?

FF

if !lSSIP99
	EndPrint()
endif

return
*}


function pf_a4_footer()
*{

? get_dtxt_opis("F04")
?
? get_dtxt_opis("F05")

return
*}

function pf_a4_header()
*{
local cRazmak := SPACE(1)
local cDLHead := REPLICATE("=", 60) // double line header
local cSLHead := REPLICATE("-", 60) // single line header
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
aIBanke := SjeciStr(cIBanke, 60)

P_10CPI

? cRazmak + cDLHead
? cRazmak + cINaziv
? cRazmak + REPLICATE("-", LEN(cINaziv))
? cRazmak + "Adresa: " + cIAdresa
? cRazmak + PADR("ID broj: " + cIIdBroj, 30) + PADR("Poreski broj: " + cIPorBr, 30)
? cRazmak + PADR("Broj sudskog rjesenja: " + cIBrRjes, 30) + PADR("Broj upisa: " + cIBrUpis, 30)
? cRazmak + "Ustanova: " + cIUstanova

? cRazmak + cSLHead

? cRazmak + "Banke: "

// ispisi banke
for i:=1 to LEN(aBanke)
	if i == 1
		?? aBanke[i]
	else
		? cRazmak + aBanke[i]
	endif
next

? cRazmak + cDLHead

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
cKMjesto:=get_dtxt_opis("K08")+", " + get_dtxt_opis("K09")

aKupac:=Sjecistr(cKNaziv,30)

// naziv, mjesto i datdok
? space(5)
gPB_ON()
?? padc(alltrim(aKupac[1]),30)
gPB_OFF()
?? padl(cMjesto + ", " + cDatDok, 39)

// adresa
? space(5)
gPB_ON()
?? padc(cKAdresa,30)
gPB_OFF()
?? padl("Datum isporuke: " + cDatIsp, 39)

// mjesto
? space(5)
gPB_ON()
?? padc(cKMjesto,30)
gPB_OFF()
?? padl("Datum valute: " + cDatVal, 39)

? space(5)
?? padc("Ident.broj: " + cIIdBroj)
? space(5)
?? padc("Por.broj: " + cIPorBroj)
? space(5)
?? padc("Br.sud.Rj: " + cIBrRjes)
? space(5)
?? padc("Br.upisa: " + cIBrUpis)

gPB_ON()
// broj dokumenta
?? padl("#%FS012#" + cTipDok + cBrDok, 39)
gPB_OFF()

?
?

return
*}


