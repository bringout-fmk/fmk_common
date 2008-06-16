#include "fmk.ch"

// ---------------------------------------
// lokalizira string u skladu sa
// trenutnom postavkom lokalizacije
// ---------------------------------------
function lokal(cString, cLokal )
local cPrevod
local nIdStr

if (cLokal == nil)
	cLokal := gLokal
endif
	
if ALLTRIM(cLokal) == "0"
	return cString
endif

PushWa()
SELECT F_LOKAL
if !used()
	O_LOKAL
endif

SET ORDER TO TAG "IDNAZ"
// nadji izvorni string
SEEK "0 " + cString + "##"

if !found()
	APPEND BLANK
	replace id with "0 ",;
		naz with cString+"##",;
		id_str with next_id_str()
else
	nIdStr := id_str
	// nadji prevod - za tekucu lokalizaciju
	SET ORDER TO TAG "ID"
	SEEK PADR(cLokal, 2) + STR(nIdStr, 6, 0)
	if found()
		// postoji prevod
		
		// "neki tekst##            "
		cString := RTRIM(naz)
		// "neki tekst##"
		cString := LEFT(cString, LEN(cString) - 2)
		// "neki tekst"
	endif
	
endif
PopWa()
return cString

// ----------------------
// sljedeci id na redu
// ----------------------
function next_id_str()
local nNext

PushWa()
SET ORDER TO TAG "ID_STR"
GO BOTTOM
nNext := id_str + 1
PopWa()

return nNext
