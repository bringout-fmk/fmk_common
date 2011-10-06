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

// ----------------------------------
// ----------------------------------
function P_Lokal(cId, dx, dy)
local cHeader := lokal("Lista: Lokalizacija")
local nArea := F_LOKAL
	

SELECT (nArea)

if !used()
	O_LOKAL
endif

private Kol
private ImeKol

set_a_kol( @Kol, @ImeKol)

return PostojiSifra( nArea, 1, 10, 75, cHeader, ;
	       @cId, dx, dy, ;
               {|Ch| k_handler(Ch)} )
								       

// --------------------------------------
// --------------------------------------
static function set_a_kol(aKol, aImeKol)
local i

aImeKol := {}

AADD(aImeKol, {"ID", {|| id}, "id", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"ID#STR", {|| id_str}, "id_str", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Naziv", {|| LEFT(naz, 55)+".."}, "naz", {|| .t.}, {|| .t.} })

aKol:={}
FOR i:=1 TO LEN(aImeKol)
	AADD(aKol, i)
NEXT
return
	



// ------------------------------------
// gen shema kif keyboard handler
// ------------------------------------
static function k_handler(Ch)
local nOrder
local nTekRec
local nRet
do case 
case Chr(Ch) $ "tT"
	do while .t.
		nTekRec := RECNO()
		add_prevod()
		aZabIsp:={}
		nOrder:=indexord()	
		nRet := EditSifItem(Ch, nOrder, aZabIsp) 
		if nRet <> 1
			exit
		endif
		go (nTekRec)
	
		SKIP
		
	enddo
	
	return DE_REFRESH
otherwise
	return DE_CONT
endcase

// --------------------------
// --------------------------
static function add_prevod()
Scatter()
_id := gLokal
SELECT lokal

// idlokala=hr + id_str=100
SEEK PADR(gLokal, 2) + STR(_id_str, 6, 0)
if !found()
	append blank
	// id lokala je tekuci globalni id
	_id := PADR(gLokal, 2)
	Gather()
endif

return


