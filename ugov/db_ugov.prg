#include "sc.ch"


// -------------------------------
// kreiranje tabela ugovora
// -------------------------------
function db_cre_ugov()

cre_tbl("UGOV")
cre_tbl("RUGOV")
cre_tbl("GEN_UG")
cre_tbl("GEN_UG_P")
cre_tbl("DEST")

return

// ------------------------------------------
// interna funkcija za kreiranje tabela
// ------------------------------------------
static function cre_tbl(cTbl)
local aDbf
local cPath := KUMPATH

// struktura
do case
	case cTbl == "UGOV"
		aDbf := a_ugov()		
	case cTbl == "RUGOV"
		aDbf := a_rugov()
	case cTbl == "GEN_UG"
		aDbf := a_genug()
	case cTbl == "GEN_UG_P"
		aDbf := a_gug_p()
	case cTbl == "DEST"
		cPath := SIFPATH
		aDbf := a_dest()
endcase

// kreiraj dbf
if !File( cPath + cTbl + "." + DBFEXT )
	DBcreate2(cPath + cTbl, aDBF)
endif

// indexi
do case
	case cTbl == "UGOV"
		CREATE_INDEX("ID"      ,"Id+idpartner" ,cPath+"UGOV")
		CREATE_INDEX("NAZ"     ,"idpartner+Id" ,cPath+"UGOV")
		CREATE_INDEX("NAZ2"    ,"naz"          ,cPath+"UGOV")
		CREATE_INDEX("PARTNER" ,"IDPARTNER"    ,cPath+"UGOV")
		CREATE_INDEX("AKTIVAN" ,"AKTIVAN"      ,cPath+"UGOV")

	case cTbl == "RUGOV"
		CREATE_INDEX("ID","id+IdRoba",cPath+"RUGOV")
		CREATE_INDEX("IDROBA","IdRoba",cPath+"RUGOV")

	case cTbl == "GEN_UG"
		CREATE_INDEX("DAT_OBR","DTOS(DAT_OBR)", cPath+"GEN_UG")
		CREATE_INDEX("DAT_GEN","DTOS(DAT_GEN)", cPath+"GEN_UG")

	case cTbl == "GEN_UG_P"
		CREATE_INDEX("DAT_OBR","DTOS(DAT_OBR)+ID_UGOV+IDPARTNER", cPath+"GEN_UG_P")
	case cTbl == "DEST"
		CREATE_INDEX("ID","IDPARTNER+ID", cPath+"DEST")
		CREATE_INDEX("IDDEST","ID", cPath+"DEST")
endcase 

return


// ---------------------------------------------
// vraca matricu sa tabelom DEST
// ---------------------------------------------
static function a_dest()
local aDbf:={}

AADD(aDBF, { "ID"        , "C" ,  6,  0 })
AADD(aDBF, { "IDPartner" , "C" ,  6,  0 })
AADD(aDBF, { "Naziv"     , "C" , 40,  0 })
AADD(aDBF, { "Naziv2"    , "C" , 40,  0 })
AADD(aDBF, { "Mjesto"    , "C" , 20,  0 })
AADD(aDBF, { "Adresa"    , "C" , 30,  0 })
AADD(aDBF, { "Ptt"       , "C" , 10,  0 })
AADD(aDBF, { "Telefon"   , "C" , 20,  0 })
AADD(aDBf, { "Mobitel"   , "C" , 20,  0 })
AADD(aDBf, { "Fax"       , "C" , 20,  0 })

return aDbf


// -----------------------------------------
// vraca matricu sa strukturom tabele UGOV
// -----------------------------------------
static function a_ugov()
local aDbf:={}

AADD(aDBF, { "ID"        , "C" , 10,  0 })
AADD(aDBF, { "DatOd"     , "D" ,  8,  0 })
AADD(aDBF, { "IDPartner" , "C" ,  6,  0 })
AADD(aDBF, { "DatDo"     , "D" ,  8,  0 })
AADD(aDBF, { "Naz"       , "C" , 20,  0 })
AADD(aDBF, { "Vrsta"     , "C" ,  1,  0 })
AADD(aDBF, { "IdTipdok"  , "C" ,  2,  0 })
AADD(aDBF, { "Aktivan"   , "C" ,  1,  0 })
AADD(aDBf, { 'DINDEM'    , 'C' ,  3,  0 })
AADD(aDBf, { 'IDTXT'     , 'C' ,  2,  0 })
AADD(aDBf, { 'ZAOKR'     , 'N' ,  1,  0 })
AADD(aDBf, { 'IDDODTXT'  , 'C' ,  2,  0 })

AADD(aDBf, { 'A1'        , 'N' , 12,  2 })
AADD(aDBf, { 'A2'        , 'N' , 12,  2 })

AADD(aDBf, { 'B1'        , 'N' , 12,  2 })
AADD(aDBf, { 'B2'        , 'N' , 12,  2 })

AADD(aDBf, { 'TXT2'      , 'C' ,  2,  0 })
AADD(aDBf, { 'TXT3'      , 'C' ,  2,  0 })
AADD(aDBf, { 'TXT4'      , 'C' ,  2,  0 })

// nivo fakturisanja
AADD(aDBf, { 'F_NIVO'    , 'C' ,  1,  0 })
// proizvoljni nivo
AADD(aDBf, { 'F_P_D_NIVO', 'N' ,  5,  0 })
// datum zadnjeg obracuna    
AADD(aDBf, { 'DAT_L_FAKT', 'D' ,  8,  0 })
// destinacija    
AADD(aDBf, { 'DEF_DEST',   'C' ,  6,  0 })

return aDbf


// ----------------------------------------
// vraca strukturu polja tabele RUGOV
// ----------------------------------------
static function a_rugov()
aDbf:={}

AADD(aDBF, { "ID"       , "C" ,  10,  0 })
AADD(aDBF, { "IDROBA"   , "C" ,  10,  0 })
AADD(aDBF, { "Kolicina" , "N" ,  15,  4 })
AADD(aDBF, { "Cijena"   , "N" ,  15,  3 })
AADD(aDBf, { 'Rabat'    , 'N' ,   6,  3 })
AADD(aDBf, { 'Porez'    , 'N' ,   5,  2 })
AADD(aDBf, { 'K1'       , 'C' ,   1,  0 })
AADD(aDBf, { 'K2'       , 'C' ,   2,  0 })
AADD(aDBf, { 'DEST'     , 'C' ,   6,  0 })

return aDbf


// ----------------------------------------
// vraca strukturu polja tabele GEN_UG
// ----------------------------------------
static function a_genug()
aDbf:={}

/// datum obracuna je kljucni datum - 
// on nam govori na koji se mjesec generacija 
// odnosi
AADD(aDBF, { "DAT_OBR"  , "D" ,   8,  0 })

// datum generacije govori kada je 
// obracun napravljen
AADD(aDBF, { "DAT_GEN"  , "D" ,   8,  0 })

// datum valute za izgenerisane dokumente
AADD(aDBF, { "DAT_VAL"  , "D" ,   8,  0 })

// datum posljednje uplate
AADD(aDBF, { "DAT_U_FIN", "D" ,   8,  0 })
// konto kupac
AADD(aDBF, { "KTO_KUP"  , "C" ,   7,  0 })
// konto dobavljac
AADD(aDBF, { "KTO_DOB"  , "C" ,   7,  0 })
// opis
AADD(aDBF, { "OPIS"     , "C" , 100,  0 })
// broj fakture od
AADD(aDBf, { 'BRDOK_OD' , 'C' ,   8,  0 })
// broj fakture do
AADD(aDBf, { 'BRDOK_DO' , 'C' ,   8,  0 })
// broj faktura
AADD(aDBf, { 'FAKT_BR'  , 'N' ,   5,  0 })
// saldo fakturisanja
AADD(aDBf, { 'SALDO'    , 'N' ,  15,  5 })
// saldo pdv-a
AADD(aDBf, { 'SALDO_PDV', 'N' ,  15,  5 })

return aDbf


// ----------------------------------------
// vraca strukturu polja tabele GEN_UG_P
// ----------------------------------------
static function a_gug_p()
aDbf:={}

// datum obracuna
AADD(aDBF, { "DAT_OBR"  , "D" ,   8,  0 })

// partner
AADD(aDBF, { "IDPARTNER", "C" ,   6,  0 })
// id ugovora
AADD(aDBF, { "ID_UGOV"    , "C" ,  10,  0 })
// saldo kupca
AADD(aDBF, { "SALDO_KUP", "N" ,  15,  5 })
// saldo dobavljaci
AADD(aDBF, { "SALDO_DOB", "N" ,  15,  5 })
// datum posljednje uplate kupca
AADD(aDBf, { 'D_P_UPL_KUP', 'D' ,   8,  0 })
// datum posljednje promjene kupca
AADD(aDBf, { 'D_P_PROM_KUP', 'D' ,   8,  0 })
// datum posljednje promjene dobavljac
AADD(aDBf, { 'D_P_PROM_DOB', 'D' ,   8,  0 })
// fakturisanje iznos
AADD(aDBF, { "F_IZNOS"     , "N" ,  15,  5 })
// fakturisanje iznos pdv-a
AADD(aDBF, { "F_IZNOS_PDV" , "N" ,  15,  5 })

return aDbf


// --------------------------------
// otvori tabele neophodne za UGOV
// --------------------------------
function o_ugov()

O_FTXT
O_SIFK
O_SIFV
O_FAKT
O_DOKS
O_ROBA
O_PARTN
O_DEST
O_UGOV
O_RUGOV
O_GEN_UG
O_G_UG_P
O_KONTO

return


// --------------------------------------
// dodaj stavku u gen_ug_p
// --------------------------------------
function a_to_gen_p(dDatObr, cIdUgov, cUPartner,  ;
                    nSaldoKup, nSaldoDob, dPUplKup,;
		    dPPromKup, dPPromDob, nFaktIzn, nFaktPdv)

select gen_ug_p
set order to tag "dat_obr"
seek DTOS(dDatObr) + cIdUgov + cUPartner
if !FOUND()
	append blank
endif
replace dat_obr with dDatObr
replace id_ugov with cIdUgov
replace idpartner with cUPartner
replace saldo_kup with nSaldoKup
replace saldo_dob with nSaldoDob
replace d_p_upl_kup with dPUplKup
replace d_p_prom_kup with dPPromKup
replace d_p_prom_dob with dPPromDob
replace f_iznos with nFaktIzn
replace f_iznos_pdv with nFaktPDV

return 


// -------------------------------------
// da li se koristi destinacija
// -------------------------------------
function is_dest()
local lRet := .f.
local nTArea := SELECT()

if rugov->(fieldpos("dest")) <> 0 .and. ;
	FILE( SIFPATH + "DEST.DBF" )
	
	lRet := .t.
	
endif

select (nTArea)
return lRet



