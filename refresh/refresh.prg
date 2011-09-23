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

// REFRESH MODUL


// glavna funkcija programa
function Main()
local cLocal 
local cServer 
local cTops
local cFileList
local aFileList
local aUpdate
local cIni

public gAppSrv := .f.
public gSql := .f.
public gReadOnly := .f.

// setuj glavne varijable
SetSCGVars()

cls

// uzmi prvo parametre
if _get_params( @cLocal, @cTops, @cServer, @cFileList, @cIni ) == 0
	quit
endif

// napravi matricu liste fajlova
aFileList := a_fileList( cFileList )

// provjeri za update
if _chk_update( cLocal, cTops, cServer, aFileList, @aUpdate ) == 0
	? "izlazim :: chk update "
	quit
endif

// glavni prozor
if main_window( cLocal, cTops, cServer, aUpdate ) == 1
	
	// odradi update
	_get_update( cIni, aUpdate )

endif

quit
return


// ------------------------------------------
// napravi matricu liste fajlova
// ------------------------------------------
static function a_filelist( cList )
local aList := {}

aList := TokToNiz( cList, ";" )

return aList

// ---------------------------------------
// get parametri
// ---------------------------------------
static function _get_params( cLocal, cTops, cServer, cFileList, cIni )

cIni := "c:\sigma\refresh.ini"

cLocal := nil
cServer := nil
cTops := nil
cFileList := nil

// local path
cLocal := UzmiIzIni( cIni, "Path", "Client", "c:\sigma", "READ" )
// server path
cServer := UzmiIzIni( cIni, "Path", "Server", "i:\fmk\update", "READ" )
// tops path
cTops := UzmiIzIni( cIni, "Path", "Pos", "c:\tops", "READ" )
// lista fajlova za osvjezenje
cFileList := UzmiIzIni( cIni, "Files", "List", "FIN;KALK;FAKT;", "READ" )


return 1



// ---------------------------------------
// glavni prozor aplikacije
// ---------------------------------------
static function main_window( cLocal, cTops, cServer, aUpdate )
local i
local cUpdate

if LEN( aUpdate ) == 0
	? "Nema update-a.... "
	quit
endif

@ 1, 2 SAY "------------------------------------------"
@ 2, 2 SAY "fmk.REFRESH ver. 02.21  :  29.10.2009"
@ 3, 2 SAY "------------------------------------------"

@ 4, 2 SAY "- Klijent putanja: " + cLocal
@ 5, 2 SAY "-     POS putanja: " + cTops
@ 6, 2 SAY "-  Server putanja: " + cServer 

@ 8, 2 SAY "Lista fajlova za osvjezenje"
@ 9, 2 SAY "------------------------------------------"

for i := 1 to LEN( aUpdate )
	@ 9 + i, 2 SAY aUpdate[ i, 1 ]
next

cUpdate := "D"

@ row() + 2, 5 SAY "Postoje software-ske nadogradnje, odraditi update ?" GET cUpdate VALID cUpdate $ "DN" PICT "@!"
	
read

if cUpdate == "N"
	return 0
endif

return 1


static function _chk_update( cLocal, cTops, cServer, aFList, aUpdate )
local i
local cFExt := ".ZIP"

aUpdate := {}

if aFList == nil .or. LEN(aFList) == 0
	msgbeep("params :: error")
	return 0
endif

// aFList := { "FIN", "KALK", "FAKT" .... }

for i := 1 to LEN( aFList )
	
	// "FIN.ZIP"
	cTmpFName := ALLTRIM( aFList[i] ) + cFExt
	
	// "c:\sigma\fin.zip"
	cTmpLocal := cLocal + SLASH + cTmpFName
	
	// ako je u pitanju tops
	if cTmpFName == "TOPS.ZIP"
		cTmpLocal := cTops + SLASH + cTmpFName
	endif

	// "i:\fmk\update\fin.zip"
	cTmpServer := cServer + SLASH + cTmpFName

	// filuj podatke o fajlovima
	if FILE( cTmpLocal )
		aLocal := DIRECTORY( cTmpLocal )
	else
		aLocal := {}
		AADD(aLocal, {"-99"})
	endif

	if FILE( cTmpServer )
		aServer := DIRECTORY( cTmpServer )
	else
		aServer := {}
		AADD(aServer, {"-99"})
	endif

	// naziv FIN.zip (C)
	// velicina - 694656 (N)
	// datum "11/29/07" (D)
	// vrijeme "01:04:42" (C)
	// tip "A" (C)

	if aServer[1,1] == "-99"
		loop
	endif
	
	cServDate := DTOS(aServer[ 1, 3 ])  
	cServTime := aServer[ 1, 4 ]
	
	// ako nema lokalno zip fajla
	if aLocal[1,1] == "-99"
		// inicijalne vrijednosti
		cLocDate := "01/01/00"
		cLocTime := "01:01:01"
	else
		cLocDate :=  DTOS(aLocal[ 1, 3 ])
		cLocTime := aLocal[ 1, 4]
	endif

	if cServDate + cServTime > cLocDate + cLocTime
		// odradi update
		if cTmpFName == "TOPS.ZIP"
			AADD( aUpdate, { cTmpServer, cTops, cTmpFName } )
		else
			AADD( aUpdate, { cTmpServer, cLocal, cTmpFName } )
		endif
	endif
	
next

return 1



static function _get_update( cIni, aUpdate )
local i
local cFSys := UzmiIzIni( cIni, "OS", "Version", "XP", "READ" )
private cTmp := ""
private cTmpU := ""

for i:=1 to LEN( aUpdate )

	cTmp := "copy"
	cTmp += " "
	
	cTmp += aUpdate[i, 1] 
	cTmp += " " 
	cTmp += aUpdate[i, 2]

	@ 18, 2 SAY PADR( cTmp, 70 )

	// kopiraj fajl
	run &cTmp

	// sada ga raspakuj lokalno !

	cTmpU := "c:\progra~1\7-zip\7z"
	cTmpU += " "
	cTmpU += "e"
	cTmpU += " "
	cTmpU += "-y"
	cTmpU += "o"
	cTmpU += aUpdate[i, 2]
	cTmpU += " "
	cTmpU += aUpdate[i, 3]

	@ 18, 2 SAY PADR( cTmpU, 70 )

	run &cTmpU

next

return


#ifdef C52
#include "h:\clipper\include\RDDINIT.CH"
#endif


function SkloniSezonu()


function SetScGVars()
*{

public ZGwPoruka:=""
public GW_STATUS:="-"

public GW_HANDLE:=0

public gModul:=""
public gVerzija:=""
public gAppSrv:=.f.
public gSQL:="N"
public ZGwPoruka:=""
public GW_STATUS:="-"
public GW_HANDLE:=0
public gReadOnly:=.f.
public gProcPrenos:="N"
public gInstall:=.f.
public gfKolor:="D"
public gPrinter:="1"
public gMeniSif:=.f.
public gValIz:="280 "
public gValU:="000 "
public gKurs:="1"
public gPTKONV:="0 "
public gPicSif:="V"
public gcDirekt:="V"
public gSKSif:="D"
public gSezona:="    "

public gShemaVF:="B5"

//counter - za testiranje
public gCnt1:=0


PUBLIC m_x
PUBLIC m_y
PUBLIC h[20]
PUBLIC lInstal:=.t.

//  .t. - korisnik je SYSTEM
PUBLIC System   
PUBLIC aRel:={}

PUBLIC cDirRad
PUBLIC cDirSif
PUBLIC cDirPriv
PUBLIC gNaslov

public gSezonDir:=""
public gRadnoPodr:="RADP"

public ImeKorisn:="" 
public SifraKorisn:=""
public KLevel:="9"

public gArhDir

public gPFont
gPFont:="Arial"

public gKodnaS:="8"
public gWord97:="N"
public g50f:=" "

//if !goModul:lStarted 
	public cDirPriv:=""
	public cDirRad:=""
	public cDirSif:=""
//endif

PUBLIC StaraBoja
StaraBoja:=SETCOLOR()

public System:=.f.
public gGlBaza:=""
public gSQL
public gSqlLogBase

PUBLIC  Invert:="N/W,R/N+,,,R/B+"
PUBLIC  Normal:="GR+/N,R/N+,,,N/W"
PUBLIC  Blink:="R****/W,W/B,,,W/RB"
PUBLIC  Nevid:="W/W,N/N"

PUBLIC gHostOS
gHostOS:="Win9X"

public cBteksta
public cBokvira
public cBnaslova
public cBshema:="B1"


#ifdef CLIP
	? "end SetScGVars"
#endif

return
*}

function PreUseEvent(cImeDbf,fShared)
*{
return cImeDbf
*}

