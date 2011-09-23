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

