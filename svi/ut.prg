#include "sc.ch"

 
function OtkljucajBug()
if SigmaSif("BUG     ")
	lPodBugom:=.f.
    	gaKeys:={}
endif
return


// ------------------------------------
// dodaj match_code u browse
// ------------------------------------
function add_mcode(aKolona)
if fieldpos("MATCH_CODE") <> 0
	AADD(aKolona, { PADC("MATCH CODE",10), {|| match_code}, "match_code" })
endif
return


// --------------------------------------------------
// sifrarnik uredjaja za fiskalizaciju
// --------------------------------------------------
function P_FDevice(cId,dx,dy)
local nTArea
private ImeKol
private Kol

if gFc_use == "N"
	return .t.
endif

ImeKol := {}
Kol := {}

nTArea := SELECT()

O_FDEVICE

AADD(ImeKol, { PADC("id",3), {|| id}, "id", {|| .t. }, {|| .t. } })
AADD(ImeKol, { PADC("tip",10), {|| tip}, "tip" })
AADD(ImeKol, { PADC("oznaka",10), {|| oznaka}, "oznaka" })
AADD(ImeKol, { PADC("iosa",16), {|| iosa}, "iosa" })
AADD(ImeKol, { PADC("pdv korisn.",16), {|| pdv}, "pdv" })
AADD(ImeKol, { PADC("vrsta",5), {|| vrsta}, "vrsta" })
AADD(ImeKol, { PADC("path",20), {|| path}, "path" })
AADD(ImeKol, { PADC("output",10), {|| output}, "output" })
AADD(ImeKol, { PADC("duz.roba",8), {|| duz_roba}, "duz_roba" })
AADD(ImeKol, { PADC("prov.greske",10), {|| error}, "error" })
AADD(ImeKol, { PADC("timeout",7), {|| timeout}, "timeout" })
AADD(ImeKol, { PADC("zbirni rn.",10), {|| zbirni}, "zbirni" })
AADD(ImeKol, { PADC("pitanje st.",10), {|| st_pitanje}, "st_pitanje" })
AADD(ImeKol, { PADC("st_brrb",10), {|| st_brrb}, "st_brrb" })
AADD(ImeKol, { PADC("stampa rac.",10), {|| st_rac}, "st_rac" })
AADD(ImeKol, { PADC("provjera",10), {|| check}, "check" })
AADD(ImeKol, { PADC("vr.sifre",11), {|| art_code}, "art_code" })
AADD(ImeKol, { PADC("init plu",10), {|| init_plu}, "init_plu" })
AADD(ImeKol, { PADC("auto polog",10), {|| auto_p}, "auto_p" })
AADD(ImeKol, { PADC("opis",30), {|| opis}, "opis" })
AADD(ImeKol, { PADC("dokument",10), {|| dokumenti}, "dokumenti" })
AADD(ImeKol, { PADC("aktivan",10), {|| aktivan}, "aktivan" })

for i:=1 to LEN(ImeKol)
	AADD(Kol, i)
next

select (nTArea)

return PostojiSifra(F_FDEVICE,1,10,65,"Lista fiskalnih uredjaja",@cId,dx,dy)





