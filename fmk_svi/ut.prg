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


#include "fmk.ch"

 
function OtkljucajBug()
if SigmaSif("BUG     ")
	lPodBugom:=.f.
    	gaKeys:={}
endif
return


// ------------------------------------
// dodaj match_code u browse
// ------------------------------------
function add_mcode(aKolona)
if fieldpos("MATCH_CODE") <> 0
	AADD(aKolona, { PADC("MATCH CODE",10), {|| match_code}, "match_code" })
endif
return

