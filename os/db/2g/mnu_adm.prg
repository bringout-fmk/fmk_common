#include "\cl\sigma\fmk\os\os.ch"

function MnuAdminDB()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. install db-a                         ")
AADD(opcexe, {|| goModul:oDatabase:install()})

Menu_SC("adm")

return
*}

