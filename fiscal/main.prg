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

cPom := f_filename( _F_VRN_TXT, nInvoice )

// upisi aItems prema aVRnTxt u PRIVPATH + "F_V_RACUN.TXT"
_a_to_file( cFPath, cPom, aS_rn_txt, aItems )

if LEN(aTxt) <> 0
	
	cPom := f_filename( _F_VRN_MEM, nInvoice )
	// upisi zatim stavke u fajl "F_V_RACUN.MEM"
	_a_to_file( cFPath, cPom, aS_rn_mem, aTxt )
endif
	
cPom := f_filename( _F_VRN_PLA, nInvoice )
// upisi zatim stavke u fajl "F_V_RACUN.PLA"
_a_to_file( cFPath, cPom, aS_rn_pla, aPla_Data )

cPom := f_filename( _F_SEMAFOR, nInvoice )
// upisi i semafor "F_SEMAFOR.TXT"
_a_to_file( cFPath, cPom, aS_semafor, aSem_Data ) 


return


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


cPom := f_filename( _F_MRN_TXT, nInvoice )
// upisi aItems prema aVRnTxt u PRIVPATH + "F_V_RACUN.TXT"
_a_to_file( cFPath, cPom, aS_rn_txt, aItems )

if LEN(aTxt) <> 0

	cPom := f_filename( _F_MRN_MEM, nInvoice )
	// upisi zatim stavke u fajl "F_V_RACUN.MEM"
	_a_to_file( cFPath, cPom, aS_rn_mem, aTxt )
endif

cPom := f_filename( _F_MRN_PLA, nInvoice )
// upisi zatim stavke u fajl "F_V_RACUN.PLA"
_a_to_file( cFPath, cPom, aS_rn_pla, aPla_Data )

cPom := f_filename( _F_SEMAFOR, nInvoice )
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

cPom := f_filename( _F_NIV, nInvoice )
// upisi aItems prema aVRnTxt u PRIVPATH + "F_V_RACUN.TXT"
_a_to_file( cFPath, cPom, aS_nivel, aItems )

cPom := f_filename( _F_SEMAFOR, nInvoice )
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




