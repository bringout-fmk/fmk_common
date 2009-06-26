#include "fmk.ch"

/*! \fn MnuEvents()
 *  \brief Menij events
 */
function MnuEvents()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. tabela dogadjaja za logiranje        ")
if (ImaPravoPristupa("FMK","EVENT","EDITSIFEVENTS"))
	AADD(opcexe, {|| P_Events()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "2. pregled logiranih dogadjaja  ")
if (ImaPravoPristupa("FMK","EVENT","KARTICALOG"))
	AADD(opcexe, {|| KarticaLog()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "3. brisanje logova ")
if (ImaPravoPristupa("FMK","EVENT","BRISILOGOVE"))
	AADD(opcexe, {|| BrisiLogove(.f.)})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

Menu_SC("evnt")

return
*}


