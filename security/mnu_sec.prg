#include "sc.ch"

function MnuSecMain()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. events - logovi dogadjaja")
AADD(opcexe, {|| MnuEvents()})
AADD(opc, "2. security - tabele")
AADD(opcexe, {|| MnuSecurity()})

Menu_SC("secm")

return
*}



function MnuSecurity()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. tabela korisnika")
if (ImaPravoPristupa("FMK","SECURITY","EDITSIFUSERS"))
	AADD(opcexe, {|| P_Users()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "2. tabela grupa")
if (ImaPravoPristupa("FMK","SECURITY","EDITSIFGROUPS"))
	AADD(opcexe, {|| P_Groups()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "3. tabela pravila")
if (ImaPravoPristupa("FMK","SECURITY","EDITSIFRULES"))
	AADD(opcexe, {|| P_Rules()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

Menu_SC("secu")
return
*}

