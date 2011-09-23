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


// otvaranje tabele RJ
function P_RJ(cId,dx,dy)
local nTArea
private ImeKol
private Kol

ImeKol := {}
Kol := {}

nTArea := SELECT()

O_RJ

AADD(ImeKol, { PADR("Id",2), {|| id}, "id", {|| .t.}, {|| vpsifra(wId)} })
AADD(ImeKol, { PADR("Naziv",35), {|| naz}, "naz" })

if gModul $ "FAKT#FIN"
	AADD(ImeKol, { PADR("Tip cij.",10), {|| tip}, "tip" })
	AADD(ImeKol, { PADR("Konto",10), {|| konto}, "konto" })
	if gMjRJ=="D"
	  	AADD(ImeKol, { padr("Grad",20), {||  grad}, "grad" } )
	endif
endif

for i:=1 to LEN(ImeKol)
	AADD(Kol, i)
next

select (nTArea)
private gTBDir:="N"
return PostojiSifra(F_RJ,1,10,65,"Lista radnih jedinica",@cId,dx,dy)

