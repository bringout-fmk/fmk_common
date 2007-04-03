#include "sc.ch"


// -----------------------------------------
// kreiranje tabele relacija
// -----------------------------------------
function cre_relation()
local aDbf

aDbf := g_rel_tbl()

if !FILE( SIFPATH + "RELATION.DBF" )
	DBCREATE2( SIFPATH + "RELATION.DBF", aDbf)
endif

CREATE_INDEX( "1", "TFROM+TTO+TFROMID", SIFPATH + "RELATION" )
CREATE_INDEX( "2", "TTO+TFROM+TTOID", SIFPATH + "RELATION" )

return


// ------------------------------------------
// struktura tabele relations
// ------------------------------------------
static function g_rel_tbl()
local aDbf := {}

// TABLE FROM
AADD( aDbf, { "TFROM"   , "C", 10, 0 } )
// TABLE TO
AADD( aDbf, { "TTO"   , "C", 10, 0 } )
// TABLE FROM ID
AADD( aDbf, { "TFROMID" , "C", 10, 0 } )
// TABLE TO ID
AADD( aDbf, { "TTOID" , "C", 10, 0 } )

// structure example:
// -------------------------------------------
// TFROM    | TTO     | TFROMID  | TTOID
// ------------------- -----------------------
// ARTICLES | ROBA    |    123   |  22TX22
// CUSTOMS  | PARTN   |     22   |  1CT02
// .....

return aDbf


// ---------------------------------------------
// vraca vrijednost za zamjenu
// cType - '1' = TBL1->TBL2, '2' = TBL2->TBL1 
// cFrom - iz tabele
// cTo - u tabelu
// cId - id za pretragu
// ---------------------------------------------
function g_rel_val( cType, cFrom, cTo, cId )
local xVal := ""
local nTArea := SELECT()

if cType == nil
	cType := "1"
endif

O_RELATION
set order to tag &cType
go top

seek PADR(cFrom,10) + PADR(cTo,10) + PADR(cId,10) 

if FOUND()

	if cType == "1"
		xVal := field->ttoid
	else
		xVal := field->tfromid
	endif

endif

select ( nTArea )
return xVal


// ---------------------------------------------
// otvara tabelu relacija
// ---------------------------------------------
function p_relation( cId , dx, dy )
local nTArea := SELECT()
local i
local bFrom
local bTo
private ImeKol
private Kol

O_RELATION

ImeKol:={}
Kol:={}

AADD(ImeKol, { "Tab.1" , {|| tfrom }, "tfrom", {|| .t. }, {|| !EMPTY(wtfrom)} })
AADD(ImeKol, { "Tab.2" , {|| tto   }, "tto", {|| .t.}, {|| !EMPTY(wtto)} })
AADD(ImeKol, { "Tab.1 ID" , {|| tfromid }, "tfromid" })
AADD(ImeKol, { "Tab.2 ID" , {|| ttoid }, "ttoid" })

for i:=1 to LEN(ImeKol)
	AADD(Kol, i)
next

select (nTArea)
return PostojiSifra(F_RELATION, 1, 10, 65, "Lista relacija konverzije", @cId, dx, dy)





