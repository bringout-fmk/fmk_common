#include "fmk.ch"


// otvaranje tabele RJ
function P_RJ(cId,dx,dy)
local nTArea
private ImeKol
private Kol

ImeKol := {}
Kol := {}

nTArea := SELECT()

O_RJ

AADD(ImeKol, { PADR("Id",2), {|| id}, "id", {|| .t.}, {|| vpsifra(wId)} })
AADD(ImeKol, { PADR("Naziv",35), {|| naz}, "naz" })

if gModul == "FAKT"
	AADD(ImeKol, { PADR("Tip cij.",10), {|| tip}, "tip" })
	AADD(ImeKol, { PADR("Konto",10), {|| konto}, "konto" })
	if gMjRJ=="D"
	  	AADD(ImeKol, { padr("Grad",20), {||  grad}, "grad" } )
	endif
endif

for i:=1 to LEN(ImeKol)
	AADD(Kol, i)
next

select (nTArea)
private gTBDir:="N"
return PostojiSifra(F_RJ,1,10,65,"Lista radnih jedinica",@cId,dx,dy)

