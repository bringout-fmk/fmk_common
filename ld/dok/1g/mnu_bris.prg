#include "\cl\sigma\fmk\ld\ld.ch"

function MnuBrisanje()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. brisanje obracuna za jednog radnika       ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"DOK","BRISIRADNIKA"))
	AADD(opcexe, {|| BrisiRadnika()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "2. brisanje obracuna za jedan mjesec   ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"DOK","BRISIMJESEC"))
	AADD(opcexe, {|| BrisiMjesec()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "3. brisanje nepotrebnih sezona         ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"DOK","PRENOSLD"))
	AADD(opcexe, {|| PrenosLD()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "4. totalno brisanje radnika iz evidencije")
if (ImaPravoPristupa(goModul:oDatabase:cName,"DOK","TOTBRISRADN"))
	AADD(opcexe, {|| TotBrisRadn()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

Menu_SC("bris")

return
*}


