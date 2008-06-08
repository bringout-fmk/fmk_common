#include "sc.ch"

// -------------------------------
// otvaranje tabele KONTO
// -------------------------------
function P_Konto(cId,dx,dy)
local nTArea
private ImeKol
private Kol

ImeKol := {}
Kol := {}

nTArea := SELECT()

O_KONTO

AADD(ImeKol, {PADC("ID",7), {|| id}, "id", {|| .t.}, {|| vpsifra(wId) }})
AADD(ImeKol, {"Naziv", {|| naz}, "naz" })

for i:=1 to LEN(ImeKol)
	AADD(Kol, i)
next

select (nTArea)

return PostojiSifra(F_KONTO,1,10,60,"Lista: Konta",@cId,dx,dy)


// Funkcija vraca vrijednost polja naziv po zadatom idkonto
function GetNameFromKonto(cIdKonto)
local nArr
nArr:=SELECT()
select konto
hseek cIdKonto
cRet:=ALLTRIM(field->naz)
select (nArr)
return cRet


