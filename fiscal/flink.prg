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


// pos komande
static F_POS_RN := "POS_RN"

// --------------------------------------------------------
// fiskalni racun pos (FLINK)
// cFPath - putanja do fajla
// cFName - naziv fajla
// aData - podaci racuna
// lStorno - da li se stampa storno ili ne (.T. ili .F. )
// --------------------------------------------------------
function fc_pos_rn( cFPath, cFName, aData, lStorno, cError )
local cSep := ";"
local aPosData := {}
local aStruct := {}
local nErr := 0

if lStorno == nil
	lStorno := .f.
endif

if cError == nil
	cError := "N"
endif

// naziv fajla
cFName := f_filepos( aData[ 1, 1] )

// izbrisi fajl greske odmah na pocetku ako postoji
_f_err_delete( cFPath, cFName )

// uzmi strukturu tabele za pos racun
aStruct := _g_f_struct( F_POS_RN )

// iscitaj pos matricu
aPosData := __pos_rn( aData, lStorno )

cTmp_date := DTOC( DATE() )
cTmp_time := TIME()

_a_to_file( cFPath, cFName, aStruct, aPosData )

if cError == "D"
	msgo("...provjeravam greske...")
	sleep(3)
	msgc()
	// provjeri da li je racun odstampan
	nErr := fc_pos_err( cFPath, cFName, cTmp_date, cTmp_time )
endif

return nErr

// ---------------------------------------------------
// citanje log fajla
// ---------------------------------------------------
function fc_pos_err( cFPath, cFName, cDate, cTime )
local nErr := 0
local aDir := {}
local cTmp
local cE_date
// error file time-hour, min, sec.
local cE_th
local cE_tm
local cE_ts
// origin file time-hour, min, sec.
local cF_th := SUBSTR( cTime, 1, 2 )
local cF_tm := SUBSTR( cTime, 4, 2 )
local cF_ts := SUBSTR( cTime, 7, 2 )
local i

cTmp := cFPath + "printe~1\" + cFName 

aDir := DIRECTORY( cTmp )

// nema fajla...
if LEN( aDir ) = 0
	return nErr
endif

// napravi pattern za pretragu unutar matrice
// <filename> + <date> + <file hour> + <file minute>
// primjer:
//
// 21100000.inp + 10.10.10 + 12 + 15 = "21100000.inp10.10.101215"

cF_patt := ALLTRIM( UPPER(cFName) ) + cDate + cF_th + cF_tm

// ima fajla...
// provjeri jos samo datum i vrijeme

for i := 1 to LEN( aDir )

	cE_name := UPPER( ALLTRIM( aDir[ i, 1 ] ) )
	// datum fajla
	cE_date := DTOC( aDir[ i, 3 ] )
	// vrijeme fajla
	cE_th := SUBSTR( ALLTRIM( aDir[ i, 4 ] ), 1, 2 )
	cE_tm := SUBSTR( ALLTRIM( aDir[ i, 4 ] ), 4, 2 )
	cE_ts := SUBSTR( ALLTRIM( aDir[ i, 4 ] ), 7, 2 )
	
	// patern pretrage
	cE_patt := ALLTRIM( cE_name ) + cE_date + cE_th + cE_tm

	if cE_patt == cF_patt
		// imamo error fajl !!!
		nErr := 1
		exit
	endif
next

return nErr

// --------------------------------------------------------
// brisi fajl greske ako postoji prije kucanja racuna
// --------------------------------------------------------
static function _f_err_delete( cFPath, cFName )
local cTmp
cTmp := cFPath + "printe~1\" + cFName 

FERASE(cTmp)

return


// -----------------------------------------------------
// fiskalno upisivanje robe
// cFPath - putanja do fajla
// aData - podaci racuna
// -----------------------------------------------------
function fc_pos_art( cFPath, cFName, aData )
local cSep := ";"
local aPosData := {}
local aStruct := {}

// uzmi strukturu tabele za pos racun
aStruct := _g_f_struct( F_POS_RN )

// iscitaj pos matricu
aPosData := __pos_art( aData )

_a_to_file( cFPath, cFName, aStruct, aPosData )

return


// ------------------------------------------------------
// vraca popunjenu matricu za upis artikla u memoriju
// ------------------------------------------------------
static function __pos_art( aData )
local aArr := {}
local cTmp := ""
local cLogic
local cLogSep := ","
local cSep := ";"
local i

// ocekivana struktura
// aData = { idroba, nazroba, cijena, kolicina, porstopa, plu }

// nemam pojma sta ce ovdje biti logic ?
cLogic := "1"

for i := 1 to LEN( aData )
	
	cTmp := "U"
	cTmp += cLogSep
	cTmp += cLogic
	cTmp += cLogSep
	cTmp += REPLICATE("_", 6) 
	cTmp += cLogSep
	cTmp += REPLICATE("_", 1) 
	cTmp += cLogSep
	cTmp += REPLICATE("_", 2)
	cTmp += cSep
	// naziv artikla
	cTmp += ALLTRIM(aData[i, 2])
	cTmp += cSep
	// cjena 0-99999.99
	cTmp += ALLTRIM(STR( aData[i, 3], 12, 2 ))
	cTmp += cSep
	// kolicina 0-99999.99
	cTmp += ALLTRIM(STR( aData[i, 4], 12, 2 ))
	cTmp += cSep
	// stand od 1-9
	cTmp += "1"
	cTmp += cSep
	// grupa artikla 1-99
	cTmp += "1"
	cTmp += cSep
	// poreska grupa artikala 1 - 4
	cTmp += "1"
	cTmp += cSep
	// 0 ???
	cTmp += "0"
	cTmp += cSep
	// kod PLU
	cTmp += ALLTRIM( aData[i, 1] )
	cTmp += cSep

	AADD( aArr, { cTmp } )

next

return aArr


// ----------------------------------------
// vraca popunjenu matricu za ispis raèuna
// ----------------------------------------
static function __pos_rn( aData, lStorno )
local aArr := {}
local cTmp := ""
local cLogic
local cLogSep := ","
local cSep := ";"
local i
local cRek_rn := ""
local cRnBroj

// ocekuje se matrica formata
// aData { brrn, rbr, idroba, nazroba, cijena, kolicina, porstopa, rek_rn, plu }

// !!! nije broj racuna !!!!
// prakticno broj racuna
// cLogic := ALLTRIM( aData[1, 1] )

// broj racuna
cRnBroj := ALLTRIM( aData[1,1] )

// logic je uvijek "1"
cLogic := "1"

if lStorno == .t.
	
	cRek_rn := ALLTRIM( aData[ 1, 8 ] )
	
	cTmp := "K"
	cTmp += cLogSep
	cTmp += cLogic
	cTmp += cLogSep
	cTmp += REPLICATE("_", 6) 
	cTmp += cLogSep
	cTmp += REPLICATE("_", 1) 
	cTmp += cLogSep
	cTmp += REPLICATE("_", 2)
	cTmp += cSep
	cTmp += cRek_rn

	AADD( aArr, { cTmp } )

endif

for i := 1 to LEN( aData )

	cT_porst := aData[ i, 7 ]

	cTmp := "S"
	cTmp += cLogSep
	cTmp += cLogic
	cTmp += cLogSep
	cTmp += REPLICATE("_", 6) 
	cTmp += cLogSep
	cTmp += REPLICATE("_", 1) 
	cTmp += cLogSep
	cTmp += REPLICATE("_", 2)
	cTmp += cSep
	// naziv artikla
	cTmp += ALLTRIM(aData[i, 4])
	cTmp += cSep
	// cjena 0-99999.99
	cTmp += ALLTRIM(STR( aData[i, 5], 12, 2 ))
	cTmp += cSep
	// kolicina 0-99999.99
	cTmp += ALLTRIM(STR( aData[i, 6], 12, 2 ))
	cTmp += cSep
	// stand od 1-9
	cTmp += PADR("1", 1)
	cTmp += cSep
	// grupa artikla 1-99
	cTmp += "1"
	cTmp += cSep
	// poreska grupa artikala 1 - 4
	if cT_porst == "E"
		cTmp += "2"
	else
		cTmp += "1"
	endif
	cTmp += cSep
	// -0 ???
	cTmp += "-0"
	cTmp += cSep
	// kod PLU
	cTmp += ALLTRIM( aData[i, 3] )
	cTmp += cSep

	AADD( aArr, { cTmp } )

next

// podnozje
cTmp := "Q"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep
cTmp += "1"
cTmp += cSep
cTmp += "pos rn: " + cRnBroj

AADD( aArr, { cTmp } )


// zatvaranje racuna
cTmp := "T"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep

AADD( aArr, { cTmp } )

return aArr



