#include "\cl\sigma\fmk\virm\virm.ch"

function MnuParams()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. opsti parametri                  ")
AADD(opcexe, {|| Pars1()})
AADD(opc, "2. parametri za virmane            ")
AADD(opcexe, {|| Pars2()})
AADD(opc, "3. parametri za uplatnice")
AADD(opcexe, {|| Pars3()})

Menu_SC("par")

return
*}

