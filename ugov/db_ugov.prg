#include "sc.ch"


// -------------------------------
// kreiranje tabela ugovora
// -------------------------------
function db_cre_ugov()

cre_tbl("UGOV")
cre_tbl("RUGOV")

return

// ------------------------------------------
// interna funkcija za kreiranje tabela
// ------------------------------------------
static function cre_tbl(cTbl)
local aDbf

// struktura
do case
	case cTbl == "UGOV"
		aDbf := a_ugov()		
	case cTbl == "RUGOV"
		aDbf := a_rugov()
		
endcase

// kreiraj dbf
if !File( KUMPATH + cTbl + "." + DBFEXT )
	DBcreate2(KUMPATH + cTbl, aDBF)
endif

// indexi
do case
	case cTbl == "UGOV"
		CREATE_INDEX("ID"      ,"Id+idpartner" ,KUMPATH+"UGOV")
		CREATE_INDEX("NAZ"     ,"idpartner+Id" ,KUMPATH+"UGOV")
		CREATE_INDEX("NAZ2"    ,"naz"          ,KUMPATH+"UGOV")
		CREATE_INDEX("PARTNER" ,"IDPARTNER"    ,KUMPATH+"UGOV")
		CREATE_INDEX("AKTIVAN" ,"AKTIVAN"      ,KUMPATH+"UGOV")
	case cTbl == "RUGOV"
		CREATE_INDEX("ID","id+IdRoba",KUMPATH+"RUGOV")
		CREATE_INDEX("IDROBA","IdRoba",KUMPATH+"RUGOV")
	
endcase 

return


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
AADD(aDBf, { 'IdTXT'     , 'C' ,  2,  0 })
AADD(aDBf, { 'zaokr'     , 'N' ,  1,  0 })
AADD(aDBf, { 'IdDodTXT'  , 'C' ,  2,  0 })
AADD(aDBf, { 'A1'        , 'N' , 12,  2 })
AADD(aDBf, { 'A2'        , 'N' , 12,  2 })
AADD(aDBf, { 'B1'        , 'N' , 12,  2 })
AADD(aDBf, { 'B2'        , 'N' , 12,  2 })

return aDbf


// ----------------------------------------
// vraca strukturu polja tabele RUGOV
// ----------------------------------------
static function a_rugov()
aDbf:={}

AADD(aDBF, { "ID"       , "C" ,  10,  0 })
AADD(aDBF, { "IDROBA"   , "C" ,  10,  0 })
AADD(aDBF, { "Kolicina" , "N" ,  15,  4 })
AADD(aDBf, { 'Rabat'    , 'N' ,   6,  3 })
AADD(aDBf, { 'Porez'    , 'N' ,   5,  2 })
AADD(aDBf, { 'K1'       , 'C' ,   1,  0 })
AADD(aDBf, { 'K2'    , 'C' ,   2,  0 })

//AADD(aDBf, { 'DESTIN'   , 'C' ,   1,  0 })

return aDbf



