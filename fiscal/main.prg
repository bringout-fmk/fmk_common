#include "sc.ch"

static F_RN_TXT := "RACUN_TXT"
static _F_VRN_TXT := "FV*.TXT"
static _F_MRN_TXT := "FM*.TXT"
static F_RN_PLA := "RACUN_PLA"
static _F_VRN_PLA := "FV*.PLA"
static _F_MRN_PLA := "FM*.PLA"
static F_RN_MEM := "RACUN_MEM"
static _F_VRN_MEM := "FV*.MEM"
static _F_MRN_MEM := "FM*.MEM"
static F_SEMAFOR := "SEMAFOR"
static _F_SEMAFOR := "FS*.TXT"
static F_NIV := "NIVELACIJA"
static _F_NIV := "FN*.TXT"

static F_FPOR := "POREZI"
static _F_FPOR := "F_POR.TXT"

static F_FPART := "PARTNERI"
static _F_FPART := "F_KUPCI.TXT"

static F_FROBA := "ROBA"
static _F_FROBA := "F_ROBA.TXT"

static F_FROBGR := "ROBAGRUPE"
static _F_FROBGR := "F_GRUPE.TXT"

static F_FOBJ := "OBJEKTI"
static _F_FOBJ := "F_OBJ.TXT"

static F_FOPER := "OPERATERI"
static _F_FOPER := "F_OPER.TXT"

// pos komande
static F_POS_RN := "POS_RN"

// komande semafora 
// -------------------------------------------
// 0 - stampanje racuna maloprodaje
// 1 - stampanje storno racuna maloprodaje
// 2 - unos nove sifre u fiskalni uredjaj
// 3 - nivelacija robe
// 4 - stampanje dnevnog izvjestaja
// 13 - upis sifara robe u fisk.uredjaj
// 14 - upis grupe sifara robe u fisk.uredjaj
// 20 - stampanje racuna veleprodaje 
// 21 - stampanje storno racuna veleprodaje
// 50 - uplata u kasu
// 51 - isplata iz kase


// (F_V_RACUN.TXT) aItems: treba da sadrzi
// [1] - broj racuna
// [2] - tip racuna
// [3] - identifikator storno stavke
// [4] - fiskalna sifra robe
// [5] - naziv roba
// [6] - barkod
// [7] - grupa robe
// [8] - poreska stopa identifikator
// [9] - cijena robe
// [10] - kolicina robe

// (F_V_RACUN.MEM) aTxt: treba da sadrzi
// [1] - red 1
// [2] - red 2
// [3] - red 3
// [4] - red 4

// (F_V_RACUN.PLA) : aPla_data
// [1] - broj racuna
// [2] - tip racuna
// [3] - nacin placanja
// [4] - uplaceno novca
// [5] - total racuna
// [6] - povrat novca

// (SEMAFOR.TXT) : aSem_data
// [1] - broj racuna / nivelacije / operacije
// [2] - tip knjizenja - komanda operacije
// [3] - print memo identifikator - od broja
// [4] - print memo identifikator - do broja
// [5] - fiskalna sifra kupca za veleprodaju ili 0
// [6] - broj reklamnog racuna

// (NIVELACIJA.TXT) : aNiv_data 
// [1] - broj nivelacije 
// [2] - sifra robe
// [3] - naziv robe
// [4] - bar kod
// [5] - sifra grupe robe
// [6] - sifra poreske stope
// [7] - cijena robe



// -------------------------------------------------------
// racun veleprodaje
// cFPath - destination path
// aItems - matrica sa stavkama racuna
// aTxt - dodatni tekst racuna
// cRnNum - broj racuna
// nTotal - total racuna
// -------------------------------------------------------
function fisc_v_rn( cFPath, aItems, aTxt, aPla_data, aSem_data )

// cFPath := PRIVPATH

// uzmi strukturu tabele za f_v_racun.txt
aS_rn_txt := _g_f_struct( F_RN_TXT )
// uzmi strukturu tabele za f_v_racun.mem
aS_rn_mem := _g_f_struct( F_RN_MEM )
// uzmi strukturu tabele za f_v_racun.pla
aS_rn_pla := _g_f_struct( F_RN_PLA )
// uzmi strukturu tabele za semafor
aS_semafor := _g_f_struct( F_SEMAFOR )


// broj racuna
nInvoice := aItems[1, 1]

cPom := _filename( _F_VRN_TXT, nInvoice )

// upisi aItems prema aVRnTxt u PRIVPATH + "F_V_RACUN.TXT"
_a_to_file( cFPath, cPom, aS_rn_txt, aItems )

if LEN(aTxt) <> 0
	
	cPom := _filename( _F_VRN_MEM, nInvoice )
	// upisi zatim stavke u fajl "F_V_RACUN.MEM"
	_a_to_file( cFPath, cPom, aS_rn_mem, aTxt )
endif
	
cPom := _filename( _F_VRN_PLA, nInvoice )
// upisi zatim stavke u fajl "F_V_RACUN.PLA"
_a_to_file( cFPath, cPom, aS_rn_pla, aPla_Data )

cPom := _filename( _F_SEMAFOR, nInvoice )
// upisi i semafor "F_SEMAFOR.TXT"
_a_to_file( cFPath, cPom, aS_semafor, aSem_Data ) 


return

// ----------------------------------------------------
// sredjuje naziv fajla za fiskalni stampac
// ----------------------------------------------------
static function _filename( cPattern, nInvoice )
local cRet := ""
cRet := STRTRAN( cPattern, "*", ALLTRIM(STR(nInvoice)) )
return cRet


// ----------------------------------------
// fajl za pos fiskalni stampac
// ----------------------------------------
static function _filepos( cBrRn )
local cRet
cRet := PADL( ALLTRIM( cBrRn ), 8, "0" ) + ".inp"
return cRet


// ---------------------------------
// racun maloprodaje
// ---------------------------------
function fisc_m_rn( cFPath, aItems, aTxt, aPla_data, aSem_data )
// cFPath := PRIVPATH

// uzmi strukturu tabele za f_v_racun.txt
aS_rn_txt := _g_f_struct( F_RN_TXT )
// uzmi strukturu tabele za f_v_racun.mem
aS_rn_mem := _g_f_struct( F_RN_MEM )
// uzmi strukturu tabele za f_v_racun.pla
aS_rn_pla := _g_f_struct( F_RN_PLA )
// uzmi strukturu tabele za semafor
aS_semafor := _g_f_struct( F_SEMAFOR )

// broj racuna
nInvoice := aItems[1, 1]


cPom := _filename( _F_MRN_TXT, nInvoice )
// upisi aItems prema aVRnTxt u PRIVPATH + "F_V_RACUN.TXT"
_a_to_file( cFPath, cPom, aS_rn_txt, aItems )

if LEN(aTxt) <> 0

	cPom := _filename( _F_MRN_MEM, nInvoice )
	// upisi zatim stavke u fajl "F_V_RACUN.MEM"
	_a_to_file( cFPath, cPom, aS_rn_mem, aTxt )
endif

cPom := _filename( _F_MRN_PLA, nInvoice )
// upisi zatim stavke u fajl "F_V_RACUN.PLA"
_a_to_file( cFPath, cPom, aS_rn_pla, aPla_Data )

cPom := _filename( _F_SEMAFOR, nInvoice )
// upisi i semafor "F_SEMAFOR.TXT"
_a_to_file( cFPath, cPom, aS_semafor, aSem_Data ) 

return



// ---------------------------------
// nivelacija
// ---------------------------------
function fisc_nivel(cFPath, aItems, aSem_data )

// uzmi strukturu tabele za f_nivel.txt
aS_nivel := _g_f_struct( F_NIV )
// uzmi strukturu tabele za semafor
aS_semafor := _g_f_struct( F_SEMAFOR )

// broj nivelacije
nInvoice := aSem_data[1, 1]

cPom := _filename( _F_NIV, nInvoice )
// upisi aItems prema aVRnTxt u PRIVPATH + "F_V_RACUN.TXT"
_a_to_file( cFPath, cPom, aS_nivel, aItems )

cPom := _filename( _F_SEMAFOR, nInvoice )
// upisi i semafor "F_SEMAFOR.TXT"
_a_to_file( cFPath, cPom, aS_semafor, aSem_Data ) 

return



// ---------------------------------
// inicijalizacija tabela sifrarnika
// ---------------------------------
function fisc_init( cFPath, aPor, aRoba, aRobGr, aPartn, aObj, aOper )

aS_por := _g_f_struct( F_FPOR )
aS_roba := _g_f_struct( F_FROBA )
aS_robgr := _g_f_struct( F_FROBGR )
aS_partn := _g_f_struct( F_FPART )
aS_obj := _g_f_struct( F_FOBJ )
aS_oper := _g_f_struct( F_FOPER )

// upisi poreze
_a_to_file( cFPath, _F_FPOR, aS_por, aPor ) 

// upisi robu
_a_to_file( cFPath, _F_FROBA, aS_roba, aRoba ) 

// upisi grupe robe
_a_to_file( cFPath, _F_FROBGR, aS_robgr, aRobGr ) 

// upisi partnere
_a_to_file( cFPath, _F_FPART, aS_partn, aPartn ) 

// upisi objekte
_a_to_file( cFPath, _F_FOBJ, aS_obj, aObj ) 

// upisi operatere
_a_to_file( cFPath, _F_FOPER, aS_oper, aOper ) 

return

// --------------------------------------------------------
// brisi fajl greske ako postoji prije kucanja racuna
// --------------------------------------------------------
static function _f_err_delete( cFPath, cFName )
local cTmp
cTmp := cFPath + "printe~1\" + cFName 

FERASE(cTmp)

return


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
// fiskalni racun pos
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
cFName := _filepos( aData[ 1, 1] )

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


// -----------------------------------------------------
// fisalno upisivanje robe
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
// aData = { idroba, nazroba, cijena, kolicina, porstopa }

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
// aData { brrn, rbr, idroba, nazroba, cijena, kolicina, porstopa, rek_rn }

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


