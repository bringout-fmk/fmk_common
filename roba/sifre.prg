#include "sc.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/roba/sifre.prg,v $
 * $Author: ernadhusremovic $ 
 * $Revision: 1.6 $
 * $Log: sifre.prg,v $
 * Revision 1.6  2003/11/04 02:13:30  ernadhusremovic
 * Planika Kranj - Robno poslovanje
 *
 * Revision 1.5  2003/10/04 12:34:51  sasavranic
 * uveden security sistem
 *
 * Revision 1.4  2002/07/04 19:04:08  ernad
 *
 *
 * ciscenje sifrarnik fakt
 *
 * Revision 1.3  2002/07/04 08:15:08  sasa
 * dodat sifrarnik fakt->txt
 *
 * Revision 1.2  2002/06/16 14:16:54  ernad
 * no message
 *
 *
 */
 
function SifFmkRoba()
*{
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

AADD(opc,"7. sifk - karakteristike")  
if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","SIFKOPEN"))
	AADD(opcexe, {|| P_SifK()} )
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
