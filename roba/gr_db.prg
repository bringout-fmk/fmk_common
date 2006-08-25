#include "sc.ch"


// kreiranje tabela grupa i karakteristika
function cre_group()

// GRUPE.DBF
// lista grupa
if !FILE( SIFPATH + "GRUPE.DBF" )
   aDBf:={}
   AADD(aDBf,{ "ID"       , "C",  5, 0 })
   AADD(aDBf,{ "NAZ"      , "C", 20, 0 })
   AADD(aDBf,{ "GR_AKTIV" , "C",  1, 0 })
   dbcreate2( SIFPATH + "GRUPE.DBF", aDbf)
endif
CREATE_INDEX("ID", "ID", SIFPATH + "GRUPE" )


// GR_DINFO.DBF
// grupe dodatne informacije
if !FILE( SIFPATH + "GR_DINFO.DBF" )
   aDBf:={}
   AADD(aDBf,{ "ID"    , "C",  5, 0 })
   AADD(aDBf,{ "NAZ"   , "C", 30, 0 })
   dbcreate2( SIFPATH + "GR_DINFO.DBF", aDbf)
endif
CREATE_INDEX("ID", "ID", SIFPATH + "GR_DINFO" )

// GR_PAR.DBF
// grupe parovi
if !FILE( SIFPATH + "GR_PAR.DBF" )
   aDBf:={}
   AADD(aDBf,{ "ID"          , "N", 10, 0 })
   AADD(aDBf,{ "ID_GR"       , "C",  5, 0 })
   AADD(aDBf,{ "ID_GR_DINFO" , "C",  5, 0 })
   AADD(aDBf,{ "K1"          , "C", 10, 0 })
   dbcreate2( SIFPATH + "GR_PAR.DBF", aDbf)
endif
CREATE_INDEX("1", "STR(ID, 10, 0)", SIFPATH + "GR_PAR" )
CREATE_INDEX("2", "ID_GR", SIFPATH + "GR_PAR" )


// GR_D_VR.DBF
// grupe dozvoljene vrijednosti
if !FILE( SIFPATH + "GR_D_VR.DBF" )
   aDBf:={}
   AADD(aDBf,{ "ID"          , "N",  10, 0 })
   AADD(aDBf,{ "ID_GR_PAR"   , "N",  10, 0 })
   AADD(aDBf,{ "NAZ"         , "C", 100, 0 })
   dbcreate2( SIFPATH + "GR_D_VR.DBF", aDbf)
endif
CREATE_INDEX("1", "STR(ID, 10, 0)", SIFPATH + "GR_D_VR" )
CREATE_INDEX("2", "STR(ID_GR_PAR, 10, 0)", SIFPATH + "GR_D_VR" )


// GR_D_VAL.DBF
// grupe vrijednosti
if !FILE( SIFPATH + "GR_D_VAL.DBF" )
   aDBf:={}
   AADD(aDBf,{ "IDROBA"      , "C", 10, 0 })
   AADD(aDBf,{ "GR_D_VR"     , "N", 10, 0 })
   dbcreate2( SIFPATH + "GR_D_VAL.DBF", aDbf)
endif
CREATE_INDEX("1", "IDROBA", SIFPATH + "GR_D_VAL" )

return


function gr_get_area(cTable)
local nArea := 0
do case
	case cTable == "GRUPE"
		nArea := F_GRUPE
	case cTable == "GR_PAR"
		nArea := F_GR_PAR
	case cTable == "GR_D_INFO"
		nArea := F_GR_DINFO
	case cTable == "GR_D_VR"
		nArea := F_GR_D_VR
	case cTable == "GR_D_VAL"
		nArea := F_GR_D_VAL
endcase
return nArea


// novi id za tabele gdje je ID = (C) polje
function gr_new_cid(cId, cTable)
local nTArea := SELECT()
local nArea
local cTempId := ""
local nNewId := 0

nArea := gr_get_area(cTable)

select (nArea)
set order to tag "ID"
go bottom

cTempId := field->id
nNewId := VAL(cTempId) + 1

select (nTArea)

cId := STR(nNewId, 5, 0)

return .t.


// novi id za tabele gdje je ID = (N) polje
function gr_new_nid(nId, cTable)
local nTArea := SELECT()
local nArea
local nTempId := 0
local nNewId := 0

nArea := gr_get_area(cTable)

select (nArea)
set order to tag "1"
go bottom

nTempId := field->id
nNewId := nTempId + 1

select (nTArea)

nId := nNewId

return .t.



