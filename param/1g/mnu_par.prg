#include "\dev\fmk\ld\ld.ch"


function MnuParams()
*{
private opc:={}
private opcexe:={}
private izbor:=1
O_RJ
O_PARAMS

AADD(opc, "1. naziv firme, RJ, mjesec, godina...                           ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"PARAM","SETFIRMA"))
	AADD(opcexe, {|| SetFirma()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "2. postavka zaokruzenja, valute, formata prikaza iznosa...      ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"PARAM","SETFORMA"))
	AADD(opcexe, {|| SetForma()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "3. postavka nacina obracuna ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"PARAM","SETOBRACUN"))
	AADD(opcexe, {|| SetObracun()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "4. postavka formula (uk.prim.,uk.sati,godisnji) i koeficijenata ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"PARAM","SETFORMULE"))
	AADD(opcexe, {|| SetFormule()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "5. postavka parametara izgleda dokumenata ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"PARAM","SETPRIKAZ"))
	AADD(opcexe, {|| SetPrikaz()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "6. parametri - razno ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"PARAM","SETRAZNO"))
	AADD(opcexe, {|| SetRazno()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif


Menu_SC("par")

return
*}

