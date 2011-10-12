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

 

// Omogucava izradu naljepnica u dvije varijante:
// 1 - prikaz naljepnica sa tekucom cijenom
// 2 - prikaz naljepnica sa novom cijenom, kao i prekrizenom starom cijenom


function RLabele()
local cVarijanta
local cKolicina

cVarijanta := "1"
cKolicina := "N"

// kreiraj tabelu rLabele
CreTblRLabele()

if GetVars( @cVarijanta, @cKolicina ) == 0 
	close all
	return
endif

// izvrsi funkciju koja filuje tabelu rLabele 
// podacima a vraca varijantu ( 1-5 )
if (gModul == "KALK")
	KaFillRLabele( cKolicina )
else
	FaFillRLabele()
endif

CLOSE ALL

if (cVarijanta>"0" .and. cVarijanta<"3")
	PrintRLabele( cVarijanta )
endif

return


// --------------------------------------------------
// uslovi generisanja labela
// --------------------------------------------------
static function GetVars( cVarijanta, cKolicina )
local lOpened
local cIdVd

cIdVd := "XX"
cVarijanta := "1"
cKolicina := "N"
lOpened := .t.

if (gModul=="KALK")

	SELECT(F_PRIPR)
	if !USED()
		O_PRIPR
		lOpened:=.f.
	endif

	PushWa()
	SELECT pripr
	GO TOP
	cIdVd:=pripr->idVd
	
	PopWa()
	
	if (cIdVd=="19")
		cVarijanta:="2"
	endif
endif

Box(, 6, 65)
	
	@ m_x+1, m_y+2 SAY "Broj labela zavisi od kolicine artikla (D/N):" ;
		GET cKolicina VALID cKolicina $ "DN" PICT "@!"

	@ m_x+3, m_y+2 SAY "1 - standardna naljepnica"
	@ m_x+4, m_y+2 SAY "2 - sa prikazom stare cijene (prekrizeno)"
	
	@ m_x+6, m_y+3 SAY "Odaberi zeljenu varijantu " ;
		GET cVarijanta VALID cVarijanta $ "12"
	
	read

BoxC()

if (gModul=="KALK")
	if (!lOpened)
		USE
	endif
endif

if (LASTKEY()==K_ESC)
	return 0
endif

return 1




// -------------------------------------------------------------
// Kreira tabelu rLabele u privatnom direktoriju
// -------------------------------------------------------------
static function CreTblRLabele()
local cPom, aDbf

SELECT(F_RLABELE)
cPom:=PRIVPATH+"rLabele"
if (FILE(cPom+".dbf") .and. FERASE(cPom+".dbf")==-1)
	MsgBeep("Ne mogu izbrisati"+cPom+".dbf !")
	ShowFError()
endif
if (FILE(cPom+".cdx") .and. FERASE(cPom+".cdx")==-1)
	MsgBeep("Ne mogu izbrisati"+cPom+".cdx !")
	ShowFError()
endif

aDBf:={}
AADD(aDBf,{ 'idRoba'		, 'C', 10, 0 })
AADD(aDBf,{ 'naz'		, 'C', 40, 0 })
AADD(aDBf,{ 'idTarifa'		, 'C',  6, 0 })
AADD(aDBf,{ 'barkod'		, 'C', 20, 0 })
AADD(aDBf,{ 'evBr'		, 'C', 10, 0 })
AADD(aDBf,{ 'cijena'		, 'N', 10, 2 })
AADD(aDBf,{ 'sCijena'		, 'N', 10, 2 })
AADD(aDBf,{ 'skrNaziv'		, 'C', 20, 0 })
AADD(aDBf,{ 'brojLabela'	, 'N',  6, 0 })
AADD(aDBf,{ 'jmj'		, 'C',  3, 0 })
AADD(aDBf,{ 'katBr'		, 'C', 20, 0 })
AADD(aDBf,{ 'cAtribut'		, 'C', 30, 0 })
AADD(aDBf,{ 'cAtribut2'		, 'C', 30, 0 })
AADD(aDBf,{ 'nAtribut'		, 'N', 10, 2 })
AADD(aDBf,{ 'nAtribut2'		, 'N', 10, 2 })
AADD(aDBf,{ 'vpc'		, 'N',  8, 2 })
AADD(aDBf,{ 'mpc'		, 'N',  8, 2 })
AADD(aDBf,{ 'porez'		, 'N',  8, 2 })
AADD(aDBf,{ 'porez2'		, 'N',  8, 2 })
AADD(aDBf,{ 'porez3'		, 'N',  8, 2 })

DbCreate2(cPom+'.dbf',aDbf)
usex (cPom)
index on idRoba tag "1"
set order to tag "1"
return nil




// -------------------------------------------------------------------------
// Puni tabelu rLabele podacima na osnovu dokumenta iz pripreme modula KALK
// 
// cKolicina - D ili N, broj labela zavisi od kolicine robe
// -------------------------------------------------------------------------
static function KaFillRLabele( cKolicina )
local cDok
local nBr_labela := 0

O_PRIPR
O_ROBA

select pripr
go top

cDok := ( field->idFirma + field->idVd + field->brDok )

do while ( !eof() .and. cDok == ( field->idFirma + field->idVd + ;
	field->brDok ) )
	
	nBr_labela := field->kolicina

	// ako ne zavisi od kolicine artikla 
	// uvijek je jedna labela

	if cKolicina == "N"
		nBr_labela := 1
	endif

	// pronadji ovu robu
	select roba
	seek pripr->idRoba
	
	// pregledaj postoji li vec u rlabele.dbf !
	select rLabele
	seek pripr->idroba
	
	if ( cKolicina == "D" .or. ( cKolicina == "N" .and. !found() ) )
		
	  for i := 1 to nBr_labela
		
		select rLabele
		append blank
		
		Scatter()
		
		_idRoba := pripr->idRoba
		_naz := LEFT(roba->naz, 40)
		_idTarifa := pripr->idTarifa
		_evBr := pripr->brDok

		if roba->(FIELDPOS("barkod")) <> 0
			if !EMPTY( roba->barkod )
				_barkod := roba->barkod
			endif
		endif
		
		if (pripr->idVd=="19")
			_cijena:=pripr->mpcSaPP+pripr->fCj
			_sCijena:=pripr->fCj
		else
			_cijena:=pripr->mpcSaPP
			_sCijena:=_cijena
		endif
		
		Gather()
	   
	   next
	
	endif
	
	select pripr
	skip 1
enddo

return nil


// ---------------------------------------------------------------
// Prodji kroz pripremu FAKT-a i napuni tabelu rLabele
// ---------------------------------------------------------------
static function FaFillRLabele()
return nil



// -------------------------------------------------------------------
// Stampaj RLabele (delphirb)
//   cVarijanta - varijanta izgleda labele robe: 
//       "1" - standardna; 
//       "2" - za dokument nivelacije - prikazuju snizenje, 
//             gdje se vidi i precrtana stara cijena
// -------------------------------------------------------------------
static function PrintRLabele( cVarijanta )
// pozovi delphi rb i odgovarajuci rtm-fajl 
// (rlab1 / rlab2) za kreiranje labela
private cKomLin

cKomLin:="DelphiRB "+"rlab"+cVarijanta+" "+PRIVPATH+"  rlabele 1"

run &cKomLin

return nil

