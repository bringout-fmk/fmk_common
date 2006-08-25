#include "sc.ch"

 
function SifFmkRoba()
private Opc:={}
private opcexe:={}

AADD(opc,"1. roba                               ")
if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","ROBAOPEN"))
	AADD(opcexe, {|| P_Roba()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc,"2. tarife")
if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","TARIFAOPEN"))
	AADD(opcexe, {|| P_Tarifa()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc,"3. konta - tipovi cijena")
if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","KONC1OPEN"))
	AADD(opcexe, {|| P_Koncij()} )
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc,"4. konta - atributi / 2 ")
if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","KONC2OPEN"))
	AADD(opcexe, {|| P_Koncij2()} )
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc,"5. trfp - sheme kontiranja u fin")
if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","TRFPOPEN"))
	AADD(opcexe, {|| P_TrFP()} )
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc,"6. sastavnice")
if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","SASTOPEN"))
	AADD(opcexe, {|| P_Sast()} )
else
endif

AADD(opc,"7. Rabatne skale")
if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","RABSOPEN"))
	AADD(opcexe, {|| P_Rabat()} )
else
endif

AADD(opc,"8. sifk - karakteristike")  
if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","SIFKOPEN"))
	AADD(opcexe, {|| P_SifK()} )
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc,"9. roba - grupe i karakteristike")  
if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","RGRUPOPEN"))
	AADD(opcexe, {|| roba_grupe()} )
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif


CLOSE ALL
OFmkRoba()

if IsPlanika()
	// Planika vrste robe
	O_RVRSTA
endif

private Izbor:=1
gMeniSif:=.t.
Menu_SC("srob")
gMeniSif:=.f.

CLOSERET
return
*}
