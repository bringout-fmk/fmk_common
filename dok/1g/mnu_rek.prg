#include "\cl\sigma\fmk\ld\ld.ch"

function MnuRekalk()
*{
private opc:={}
private opcexe:={}
private izbor:=1

if GetObrStatus(gRj,gGodina,gMjesec)$"ZX"
	MsgBeep("Obracun zakljucen! Ne mozete vrsiti ispravku podataka!!!")
	return
elseif GetObrStatus(gRj,gGodina,gMjesec)=="N"
	MsgBeep("Nema otvorenog obracuna za "+ALLTRIM(STR(gMjesec))+"."+ALLTRIM(STR(gGodina)))
	return
endif

AADD(opc, "1. rekalkulacija satnica i primanja               ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"DOK","REKALKPRIMANJA"))
	AADD(opcexe, {|| RekalkPrimanja()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "2. ponovo izracunaj neto sati/neto iznos/odbici")
if (ImaPravoPristupa(goModul:oDatabase:cName,"DOK","REKALKSVE"))
	AADD(opcexe, {|| RekalkSve()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "3. rekalkulacija odredjenog primanja za procenat")
if (ImaPravoPristupa(goModul:oDatabase:cName,"DOK","REKALKPROCENAT"))
	AADD(opcexe, {|| RekalkProcenat()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "4. rekalkulacija odredjenog primanja po formuli")
if (ImaPravoPristupa(goModul:oDatabase:cName,"DOK","REKALKFORMULA"))
	AADD(opcexe, {|| RekalkFormula()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

Menu_SC("rklk")

return
*}

