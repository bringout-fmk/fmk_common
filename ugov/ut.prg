#include "sc.ch"


// -------------------------------------------------------
// vraca naziv partnera
// -------------------------------------------------------
function NazPartn()
local cVrati
local cPom

cPom:=UPPER(ALLTRIM(mjesto))
if cPom$UPPER(naz) .or. cPom$UPPER(naz2)
	cVrati:=TRIM(naz)+" "+TRIM(naz2)
else
	cVrati:=TRIM(naz)+" "+TRIM(naz2)+" "+TRIM(mjesto)
endif

return PADR(cVrati,40)


// -----------------------------------
// ??????
// -----------------------------------
function MSAY2(x, y, c)
@ x,y SAY c
return .t.





