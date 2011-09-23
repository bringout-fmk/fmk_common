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


#include "sc.ch"

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


