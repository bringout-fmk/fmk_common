#include "sc.ch"

// ---------------------------------
// otvaranje tabele REFER
// ---------------------------------
function p_refer(cId,dx,dy)
local nArr
private ImeKol
private Kol

nArr:=SELECT()
O_REFER

ImeKol:={}
Kol:={}

AADD(ImeKol, { PADR("Id", 2), {|| id}, "id", {|| .t.}, {|| vpsifra(wid)} })
AADD(ImeKol, {PADR("idops", 5), {|| idops}, "idops", {|| .t.}, {|| p_ops(widops)} })
AADD(ImeKol, {PADR("Naziv", 40), {|| naz}, "naz"})

for i:=1 to LEN(ImeKol)
	AADD(Kol, i)
next

select (nArr)
return PostojiSifra(F_REFER,1,10,65,"Lista referenata",@cId,dx,dy)


// ------------------------------------------------
// vraca naziv referenta iz tabele REFER
// ------------------------------------------------
function g_refer( cReferId )
local cNaz := ""
local nTarea := SELECT()
O_REFER
seek cReferId
if FOUND() .and. refer->id == cReferId
	cNaz := ALLTRIM( refer->naz )
endif
select (nTarea)
return cNaz



