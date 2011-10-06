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

// ---------------------------------
// otvaranje tabele OPS
// ---------------------------------
function P_Ops(cId,dx,dy)
local nArr
private ImeKol
private Kol

nArr:=SELECT()
O_OPS

ImeKol:={}
Kol:={}

AADD(ImeKol, { PADR("Id", 2), {|| id}, "id", {|| .t.}, {|| vpsifra(wid)} })
if ops->(FieldPOS("IDJ")<>0) 
	AADD(ImeKol, {PADR("IDJ", 3), {|| idj}, "idj"})
	AADD(ImeKol, {PADR("Kan", 3), {|| idkan}, "idkan"})
	AADD(ImeKol, {PADR("N0", 3), {|| idN0}, "idN0"})
endif
AADD(ImeKol, {PADR("Naziv", 20), {|| naz}, "naz"})
if ops->(FieldPOS("REG"))<>0
	AADD(ImeKol, {PADR("Region", 20), {|| reg}, "reg"})
endif
for i:=1 to LEN(ImeKol)
	AADD(Kol, i)
next

select (nArr)
return PostojiSifra(F_OPS,1,10,65,"Lista opcina",@cId,dx,dy)


// ---------------------------------
// otvaranje tabele BANKE
// ---------------------------------
function P_Banke(cId,dx,dy)
local nArr
private ImeKol
private Kol

nArr := SELECT()
O_BANKE

ImeKol := {}
AADD(ImeKol, { PADR("Id",2), {|| id}, "id", {|| .t.}, {|| vpsifra(wId)} })
AADD(ImeKol, { "Naziv", {|| naz}, "naz" })
AADD(ImeKol, { "Mjesto", {|| mjesto}, "mjesto" })
AADD(ImeKol, { "Adresa", {|| adresa}, "adresa" })

Kol := {}
for i:=1 to LEN(ImeKol)
	AADD(Kol, i)
next

select (nArr)
return PostojiSifra(F_BANKE, 1, 10, 55, "Lista banaka", @cId, dx, dy)



