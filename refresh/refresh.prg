#include "sc.ch"

// REFRESH MODUL


// glavna funkcija programa
function Main()
local cLocal 
local cServer 
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
if _get_params( @cLocal, @cServer, @cFileList, @cIni ) == 0
	quit
endif

// napravi matricu liste fajlova
aFileList := a_fileList( cFileList )

// provjeri za update
if _chk_update( cLocal, cServer, aFileList, @aUpdate ) == 0
	? "izlazim :: chk update "
	quit
endif

// glavni prozor
if main_window( cLocal, cServer, aUpdate ) == 1
	
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
static function _get_params( cLocal, cServer, cFileList, cIni )

cIni := "c:\sigma\refresh.ini"

cLocal := nil
cServer := nil
cFileList := nil

// local path
cLocal := UzmiIzIni( cIni, "Path", "Client", "c:\sigma", "READ" )
// server path
cServer := UzmiIzIni( cIni, "Path", "Server", "i:\fmk\update", "READ" )

// lista fajlova za osvjezenje
cFileList := UzmiIzIni( cIni, "Files", "List", "FIN;KALK;FAKT;", "READ" )


return 1



// ---------------------------------------
// glavni prozor aplikacije
// ---------------------------------------
static function main_window( cLocal, cServer, aUpdate )
local i
local cUpdate

if LEN( aUpdate ) == 0
	? "Nema update-a.... "
	quit
endif
@ 1, 2 SAY "----------------------"
@ 2, 2 SAY "fmk.REFRESH ver. 01.20"
@ 3, 2 SAY "----------------------"

@ 4, 2 SAY "Klijent putanja:" + cLocal + ", Server putanja: " + cServer 

@ 6, 2 SAY "Lista fajlova za osvjezenje"
@ 7, 2 SAY "------------------------------------------"

for i := 1 to LEN( aUpdate )
	@ 7 + i, 2 SAY aUpdate[ i, 1 ]
next

cUpdate := "D"

@ row() + 2, 5 SAY "Postoje software-ske nadogradnje, odraditi update ?" GET cUpdate VALID cUpdate $ "DN" PICT "@!"
	
read

if cUpdate == "N"
	return 0
endif

return 1


static function _chk_update( cLocal, cServer, aFList, aUpdate )
local i

aUpdate := {}

if aFList == nil .or. LEN(aFList) == 0
	msgbeep("params :: error")
	return 0
endif

// aFList := { "FIN", "KALK", "FAKT" .... }

for i := 1 to LEN( aFList )
	
	// "FIN"
	cTmpFName := ALLTRIM( aFList[i] ) + ".EXE"
	
	// "c:\sigma\fin.zip"
	cTmpLocal := cLocal + SLASH + cTmpFName
	
	// "i:\fmk\update\fin.zip"
	cTmpServer := cServer + SLASH + cTmpFName

	// filuj podatke o fajlovima
	aLocal := DIRECTORY( cTmpLocal )
	aServer := DIRECTORY( cTmpServer )

	// naziv FIN.exe (C)
	// velicina - 694656 (N)
	// datum "11/29/07" (D)
	// vrijeme "01:04:42" (C)
	// tip "A" (C)

	if LEN( aLocal ) == 0 .or. LEN( aServer ) == 0
		loop
	endif
	
	cServDate := DTOS(aServer[ 1, 3 ])  
	cServTime := aServer[ 1, 4 ]
	
	cLocDate :=  DTOS(aLocal[ 1, 3 ])
	cLocTime := aLocal[ 1, 4]
	
	if cServDate + cServTime > cLocDate + cLocTime
		// odradi update
		AADD( aUpdate, { cTmpServer, cLocal } )
	endif
	
next

return 1



static function _get_update( cIni, aUpdate )
local i
local cFSys := UzmiIzIni( cIni, "OS", "Version", "XP", "READ" )
private cTmp := ""

for i:=1 to LEN( aUpdate )

	cTmp := "copy"
	cTmp += " "
	
	cTmp += aUpdate[i, 1] 
	cTmp += " " 
	cTmp += aUpdate[i, 2]
	
	@ 18, 2 SAY PADR( cTmp, 70 )
	
	// kopiraj fajl
	run &cTmp

	// kopiraj i chs
	cTmp := STRTRAN( UPPER(cTmp), ".EXE", ".CHS" )
	run &cTmp

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
