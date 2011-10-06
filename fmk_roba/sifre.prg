/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "fmk.ch"

 
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

AADD(opc,"9. strings - karakteristike ")  
if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","STROPEN"))
	AADD(opcexe, {|| p_strings()} )
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif


CLOSE ALL
OFmkRoba()

private Izbor:=1
gMeniSif:=.t.
Menu_SC("srob")
gMeniSif:=.f.

CLOSERET
return
*}
