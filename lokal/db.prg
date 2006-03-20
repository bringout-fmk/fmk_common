#include "sc.ch"


// -------------------------------------------
// -------------------------------------------
function g_lokal_fields()
local aDbf:={}

AADD(aDBf,{ "id"    , "C" ,   2 ,  0 })
// id stringa
AADD(aDBf,{ "id_str"  , "N" ,   6 ,  0 })
// string
AADD(aDBf,{ "naz"    , "C" ,   200 ,  0 })

return aDbf


// --------------------------------
// --------------------------------
function cre_lokal(nArea)
local cTbl

if (nArea==-1 .or. nArea == F_LOKAL)

	aDbf := g_lokal_fields()
	cTbl := "LOKAL"

	if !FILE( SIFPATH+ cTbl + '.DBF' )
		dbcreate2(SIFPATH+ cTbl + '.DBF', aDbf)
	endif
	
	CREATE_INDEX("ID","id+STR(id_str,6,0)+naz",  SIFPATH+cTbl)
	CREATE_INDEX("IDNAZ","id+naz",  SIFPATH+cTbl)
	CREATE_INDEX("ID_STR","STR(id_str,6,0)+naz+id", SIFPATH+cTbl)
	CREATE_INDEX("NAZ","naz+str(id_str,6,0)", SIFPATH+cTbl)
endif

return

