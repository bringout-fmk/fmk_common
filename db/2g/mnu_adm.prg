#include "\dev\fmk\ld\ld.ch"

function MnuAdmin()
*{

private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. instalacija db-a ")
AADD(opcexe, {|| goModul:oDataBase:install()})
AADD(opc, "2. security")
AADD(opcexe, {|| MnuSecMain()})

Menu_SC("adm")

return
*}
