#include "\dev\fmk\ld\ld.ch"


//#define  RADNIK  radn->(padr(  trim(naz)+" ("+trim(imerod)+") "+ime,35))
function MnuKred()
*{
private izbor:=1
private opc:={}
private opcexe:={}

AADD(opc, "1. novi kredit                        ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"KREDIT","NOVIKREDIT"))
	AADD(opcexe, {|| NoviKredit()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "2. pregled/ispravka kredita")
if (ImaPravoPristupa(goModul:oDatabase:cName,"KREDIT","EDITKREDIT"))
	AADD(opcexe, {|| EditKredit()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "3. lista kredita za jednog kreditora")
AADD(opcexe, {|| ListaKredita()})

AADD(opc, "4. brisanje kredita")
if (ImaPravoPristupa(goModul:oDatabase:cName,"KREDIT","BRISIKREDIT"))
	AADD(opcexe, {|| BrisiKredit()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

Menu_SC("kred")
return

*}




