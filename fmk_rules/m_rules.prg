#include "fmk.ch"


// ---------------------------------------
// meni pravila
// ---------------------------------------
function m_fmkrules()
private opc := {}
private opcexe := {}
private izbor := 1

AADD(opc, "1. RULES (pravila)                ")
AADD(opcexe, {|| p_fmkrules() })

Menu_SC("rules")

return


