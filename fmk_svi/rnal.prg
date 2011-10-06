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


// otvaranje tabele RNAL
function P_RNal(cId,dx,dy)
local nTArea
private ImeKol
private Kol

ImeKol := {}
Kol := {}

nTArea := SELECT()
O_RNAL

AADD(ImeKol, { PADC("Id",10), {|| id}, "id", {|| .t.}, {|| vpsifra(wId)} })
AADD(ImeKol, { PADC("Naziv",60), {|| naz}, "naz" })

for i:=1 to LEN(ImeKol)
	AADD(Kol, i)
next

select (nTArea)

return PostojiSifra(F_RNAL,1,10,65,"Lista radnih naloga",@cId,dx,dy)



// Vraca naziv radnog naloga za trazeni cIdRnal
function GetNameRNal(cIdRnal)
local nArr
nArr:=SELECT()
O_RNAL
select rnal
set order to tag "ID"
seek cIdRnal
cRet:=ALLTRIM(field->naz)
select (nArr)
return cRet


