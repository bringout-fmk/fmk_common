#include "sc.ch"

// ----------------------------------
// ----------------------------------
function P_Lokal()

SELECT (nArea)

if !used()
	O_LOKAL
endif


set_a_kol( @Kol, @ImeKol)

return PostojiSifra( nArea, 1, 10, 75, cHeader, ;
	       @cId, dx, dy, ;
               {|Ch| k_handler(Ch)} )
								       

// --------------------------------------
// --------------------------------------
static function set_a_kol(aKol, ImeKol)
local i

aImeKol := {}

AADD(aImeKol, {"ID", {|| id}, "id", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"ID#STR", {|| id_str}, "id_str", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Naziv", {|| id}, "naziv", {|| .t.}, {|| .t.} })

aKol:={}
FOR i:=1 TO LEN(aImeKol)
	AADD(aKol, i)
NEXT
return
	


// ------------------------------------
// gen shema kif keyboard handler
// ------------------------------------
static function k_handler(Ch)

return DE_CONT

