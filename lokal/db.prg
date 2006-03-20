#include "sc.ch"


// -------------------------------------------
// -------------------------------------------
function get_lokal_fields()
local aDbf:={}

AADD(aDBf,{ "id"    , "C" ,   2 ,  0 })
// id stringa
AADD(aDBf,{ "id_str"  , "N" ,   6 ,  0 })
// string
AADD(aDBf,{ "naz"    , "C" ,   200 ,  0 })

return aDbf

