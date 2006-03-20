#include "sc.ch"

// ---------------------------------------
// lokalizira string u skladu sa
// trenutnom postavkom lokalizacije
// ---------------------------------------
function lokal(cString, cLokal )

if (cLokal == nil)
	cLokal := gLokal
endif
	
if ALLTRIM(cLokal) == "0"
	return cString
endif

return

