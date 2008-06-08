#include "sc.ch"


// vrste naloga
function P_VN(CId,dx,dy)
local nTArea
private ImeKol
private Kol

ImeKol := {}
Kol := {}

nTArea := SELECT()

O_TNAL

AADD(ImeKol, { "ID", {|| id}, "id", {|| .t.}, {|| vpsifra(wId)} })
AADD(ImeKol, { "Naziv", {|| naz}, "naz" })

for i:=1 to LEN(ImeKol)
	AADD(Kol, i)
next

select (nTArea)
return PostojiSifra(F_TNAL,1,10,60,"Lista: Vrste naloga",@cId,dx,dy)


// vrsta dokumenta
function P_TipDok(cId,dx,dy)
local nTArea
private ImeKol
private Kol

ImeKol := {}
Kol := {}

nTArea := SELECT()
O_TDOK

AADD(ImeKol, { "ID", {|| id}, "id", {|| .t.}, {|| vpsifra(wId)} })
AADD(ImeKol, { "Naziv", {|| naz}, "naz" })

for i:=1 to LEN(ImeKol)
	AADD(Kol, i)
next

select (nTArea)
return PostojiSifra(F_TDOK,1,10,32,"Lista: Tipovi dokumenata",@cId,dx,dy)


