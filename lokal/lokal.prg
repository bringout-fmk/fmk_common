/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "sc.ch"

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
