#include "sc.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/svi/sifre.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.11 $
 * $Log: sifre.prg,v $
 * Revision 1.11  2004/03/11 16:44:38  sasavranic
 * no message
 *
 * Revision 1.10  2004/03/02 18:37:28  sasavranic
 * no message
 *
 * Revision 1.9  2003/10/13 12:36:59  sasavranic
 * no message
 *
 * Revision 1.8  2003/10/04 12:35:02  sasavranic
 * uveden security sistem
 *
 * Revision 1.7  2003/09/08 11:32:59  mirsad
 * omogucen sifrarnik rad.naloga i za FAKT po radnim nalozima
 *
 * Revision 1.6  2003/07/24 16:00:30  sasa
 * stampa podataka o bankama na narudzbenici
 *
 * Revision 1.5  2003/01/08 03:16:54  mirsad
 * ubacen RNAL.DBF za rama glas i varijanta rama glas
 *
 * Revision 1.4  2002/07/04 19:04:08  ernad
 *
 *
 * ciscenje sifrarnik fakt
 *
 * Revision 1.3  2002/07/04 08:14:38  sasa
 * dodat sifrarnik opcina
 *
 * Revision 1.2  2002/06/16 11:44:53  ernad
 * unos header-a
 *
 *
 */
 
function SifFmkSvi()
*{
private Opc:={}
private opcexe:={}

AADD(opc,"1. partneri                          ")
if (ImaPravoPristupa("FMK","SIF","PARTNOPEN"))
	AADD(opcexe, {|| P_Firma()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

if (goModul:oDataBase:cName <> "FIN")
	AADD(opc,"2. konta")
	if (ImaPravoPristupa("FMK","SIF","KONTOOPEN"))
		AADD(opcexe, {|| P_Konto() } )
	else
		AADD(opcexe, {|| MsgBeep(cZabrana)})
	endif
else
	AADD(opc, "2. ----------------- ")
	AADD(opcexe, {|| NotImp()})
endif

AADD(opc,"3. tipovi naloga")
if (ImaPravoPristupa("FMK","SIF","TIPNALOPEN"))
	AADD(opcexe, {|| P_VN() } )
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc,"4. tipovi dokumenata")
if (ImaPravoPristupa("FMK","SIF","TIPDOKOPEN"))
	AADD(opcexe, {|| P_TipDok() } )
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc,"5. valute")
if (ImaPravoPristupa("FMK","SIF","VALUTEOPEN"))
	AADD(opcexe, {|| P_Valuta() } )
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc,"6. radne jedinice")
if (ImaPravoPristupa("FMK","SIF","RJOPEN"))
	AADD(opcexe, {|| P_RJ() } )
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc,"7. opcine")
if (ImaPravoPristupa("FMK","SIF","OPCINEOPEN"))
	AADD(opcexe, {|| P_Ops() } )
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc,"8. banke")
if (ImaPravoPristupa("FMK","SIF","BANKEOPEN"))
	AADD(opcexe, {|| P_Banke() } )
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc,"9. sifk - karakteristike")  
if (ImaPravoPristupa("FMK","SIF","SIFKOPEN"))
	AADD(opcexe, {|| P_SifK() } )
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

if (IsRamaGlas().or.gModul=="FAKT".and.glRadNal)
	AADD(opc,"10. radni nalozi")  
	AADD(opcexe, {|| P_RNal() } )
endif

CLOSE ALL
OFmkSvi()

private Izbor:=1
gMeniSif:=.t.
Menu_SC("ssvi")
gMeniSif:=.f.

CLOSERET
return
*}
