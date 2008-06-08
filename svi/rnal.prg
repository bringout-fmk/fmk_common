#include "sc.ch"


// otvaranje tabele RNAL
function P_RNal(cId,dx,dy)
local nTArea
private ImeKol
private Kol

ImeKol := {}
Kol := {}

nTArea := SELECT()
O_RNAL

AADD(ImeKol, { PADC("Id",10), {|| id}, "id", {|| .t.}, {|| vpsifra(wId)} })
AADD(ImeKol, { PADC("Naziv",60), {|| naz}, "naz" })

for i:=1 to LEN(ImeKol)
	AADD(Kol, i)
next

select (nTArea)

return PostojiSifra(F_RNAL,1,10,65,"Lista radnih naloga",@cId,dx,dy)



// Vraca naziv radnog naloga za trazeni cIdRnal
function GetNameRNal(cIdRnal)
local nArr
nArr:=SELECT()
O_RNAL
select rnal
set order to tag "ID"
seek cIdRnal
cRet:=ALLTRIM(field->naz)
select (nArr)
return cRet


