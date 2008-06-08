#include "sc.ch"

 
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

