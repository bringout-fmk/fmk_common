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

// -------------------------------
// otvaranje tabele KONTO
// -------------------------------
function P_Konto(cId,dx,dy)
local nTArea
private ImeKol
private Kol

ImeKol := {}
Kol := {}

nTArea := SELECT()

O_KONTO

AADD(ImeKol, {PADC("ID",7), {|| id}, "id", {|| .t.}, {|| vpsifra(wId) }})
AADD(ImeKol, {"Naziv", {|| naz}, "naz" })

for i:=1 to LEN(ImeKol)
	AADD(Kol, i)
next

select (nTArea)

return PostojiSifra(F_KONTO,1,10,60,"Lista: Konta",@cId,dx,dy)


// Funkcija vraca vrijednost polja naziv po zadatom idkonto
function GetNameFromKonto(cIdKonto)
local nArr
nArr:=SELECT()
select konto
hseek cIdKonto
cRet:=ALLTRIM(field->naz)
select (nArr)
return cRet


