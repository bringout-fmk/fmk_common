#include "\cl\sigma\fmk\virm\virm.ch"

function MnuRazDB()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. ld   ->   virman             ")
AADD(opcexe, {|| PrenosLD()})
AADD(opc, "2. fin  ->   virman   ")
AADD(opcexe, {|| PrenosFin()})
AADD(opc, "3. kalk ->   virman   ")
AADD(opcexe, {|| PrenosKalk()})

Menu_SC("mraz")

return
*}


