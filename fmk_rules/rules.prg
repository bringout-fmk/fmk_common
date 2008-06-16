#include "fmk.ch"

static __LEV_MIN
static __LEV_MAX

// ------------------------------------------------
// vraca vrijednost za seek polja rule_obj
// ------------------------------------------------
function g_ruleobj( cSeek )
return PADR(cSeek, 30)


// ------------------------------------------------
// vraca vrijednost za seek polja modul_name
// ------------------------------------------------
function g_rulemod( cSeek )
return PADR(cSeek, 10)

// ------------------------------------------------
// vraca vrijednost za seek polja rule_c1
// ------------------------------------------------
function g_rule_c1( cSeek )
return PADR(cSeek, 1)

// ------------------------------------------------
// vraca vrijednost za seek polja rule_c2
// ------------------------------------------------
function g_rule_c2( cSeek )
return PADR(cSeek, 5)

// ------------------------------------------------
// vraca vrijednost za seek polja rule_c3
// ------------------------------------------------
function g_rule_c3( cSeek )
return PADR(cSeek, 10)

// ------------------------------------------------
// vraca vrijednost za seek polja rule_c4
// ------------------------------------------------
function g_rule_c4( cSeek )
return PADR(cSeek, 10)

// ------------------------------------------------
// vraca vrijednost za seek polja rule_c5
// ------------------------------------------------
function g_rule_c5( cSeek )
return PADR(cSeek, 50)


// ------------------------------------------------
// vraca vrijednost za seek polja rule_c6
// ------------------------------------------------
function g_rule_c6( cSeek )
return PADR(cSeek, 50)


// ------------------------------------------------
// vraca vrijednost za seek polja rule_c7
// ------------------------------------------------
function g_rule_c7( cSeek )
return PADR(cSeek, 100)


// -----------------------------------------------
// da li se koriste pravila
// -----------------------------------------------
function is_fmkrules()
if !FILE(SIFPATH + "FMKRULES.DBF")
	return .f.
endif
return .t.


// -----------------------------------------------
// otvaranje sifrarnika pravila "RULES"
// cID - id
// dx - koordinata x
// dy - koordinata y
// aSpecKol - specificne kolone // modul defined
// bRules - rules block for object browse
// -----------------------------------------------
function p_fmkrules( cId, dx, dy, aSpecKol, bRBlock )
local cModName
local nSelect := SELECT()
local nRet
local cHeader := ""
private Kol
private ImeKol

__LEV_MIN := 0
__LEV_MAX := 5

O_FMKRULES
set order to tag "2"

if aSpecKol == nil
	aSpecKol := {}
endif

cHeader += " " 
cHeader += ALLTRIM( goModul:oDataBase:cName )
cHeader += " "
cHeader += "pravila : RULES "

cModName := goModul:oDataBase:cName
cModName := PADR( cModName, 10 )

// sredi kolone
set_a_kol( @ImeKol, @Kol, aSpecKol )
// postavi filter za modul
set_mod_filt()

go top

nRet := PostojiSifra( F_FMKRULES, 1, 16, 70, cHeader, @cId, dx, dy , bRBlock )

select (nSelect)

return nRet


// ---------------------------------------
// postavlja filter za modul
// ---------------------------------------
static function set_mod_filt()
local cFilt := ""

cFilt := "modul_name = " + cm2str( PADR(goModul:oDataBase:cName , 10) )

set filter to &cFilt

return

// --------------------------------------------------------
// setovanje kolona tabele "FMKRULES"
// --------------------------------------------------------
static function set_a_kol( aImeKol , aKol, aSpecKol )
local i
local nSpec

aImeKol := {}
aKol := {}

// standardne kolone tabele

AADD(aImeKol, { "ID", {|| rule_id}, "rule_id", ;
	{|| i_rule_id(@wrule_id ) , .f.}, {|| .t.} })
AADD(aImeKol, { "Modul", {|| modul_name }, "modul_name", {|| _w_mod_name(@wmodul_name), .f. }  })
AADD(aImeKol, { "Objekat", {|| rule_obj }, "rule_obj"  })
AADD(aImeKol, { "Podbr.", {|| rule_no}, "rule_no", ;
	{|| i_rule_no(@wrule_no, wrule_obj ) , .f.}, {|| .t.}, , "99999" })
AADD(aImeKol, { "Naziv", {|| PADR(rule_name, 20) + ".." }, ;
	"rule_name" })
AADD(aImeKol, { "Err.msg", {|| PADR(rule_ermsg, 30) + ".." }, ;
	"rule_ermsg" })
AADD(aImeKol, { "Nivo", {|| rule_level }, ;
	"rule_level", {|| .t.}, {|| _w_level(wrule_level) } })

if LEN(aSpecKol) == 0

	// dodajem po defaultu specificne kolone
	
	// karakterne
	AADD(aImeKol, { "pr.k1", {|| rule_c1 }, "rule_c1" })
	AADD(aImeKol, { "pr.k2", {|| rule_c2 }, "rule_c2" })
	AADD(aImeKol, { "pr.k3", {|| rule_c3 }, "rule_c3" })
	AADD(aImeKol, { "pr.k4", {|| rule_c4 }, "rule_c4" })
	AADD(aImeKol, { "pr.k5", {|| rule_c5 }, "rule_c5" })
	AADD(aImeKol, { "pr.k6", {|| rule_c6 }, "rule_c6" })
	AADD(aImeKol, { "pr.k7", {|| rule_c7 }, "rule_c7" })
	
	// numericke
	AADD(aImeKol, { "pr.n1", {|| rule_n1 }, "rule_n1" })
	AADD(aImeKol, { "pr.n2", {|| rule_n2 }, "rule_n2" })
	
	// date
	AADD(aImeKol, { "pr.d1", {|| rule_d1 }, "rule_d1" })
	AADD(aImeKol, { "pr.d2", {|| rule_d2 }, "rule_d2" })


else
	
	// dodajem na osnovu matrice aSpecKol
	for nSpec := 1 to LEN( aSpecKol )
		
		AADD( aImeKol, { aSpecKol[nSpec, 1] , aSpecKol[nSpec, 2], ;
			aSpecKol[nSpec, 3], aSpecKol[nSpec, 4], ;
			aSpecKol[nSpec, 5] } )

	next
	
endif

for i:=1 to LEN( aImeKol )
	AADD( aKol, i )
next

return


// ----------------------------------------------
// when naziv
// ----------------------------------------------
static function _w_mod_name( cName )
cName := PADR( goModul:oDataBase:cName, 10 )
return .t.


// ----------------------------------------
// when levela
// ----------------------------------------
static function _w_level( nLev )
local lRet := .f.

if nLev >= __LEV_MIN .and. nLev <= __LEV_MAX
	lRet := .t.
endif

if lRet == .f.
	msgbeep("Nivo greske mora biti u rangu od " + ;
		ALLTRIM(STR(__LEV_MIN)) + " do " + ;
		ALLTRIM(STR(__LEV_MAX)))
endif

return lRet


// -----------------------------------------------
// uvecaj automatski broj pravila
// -----------------------------------------------
function i_rule_no( nNo, cRuleObj )
local lRet := .t.

if ( (Ch==K_CTRL_N) .or. (Ch==K_F4) )
	
	if ( LastKey()==K_ESC )
		return lRet := .f.
	endif
	
	nNo := _last_no( cRuleObj )
	
	AEVAL(GetList,{|o| o:display()})
	
endif

return lRet



// -----------------------------------------------
// uvecaj automatski id broj pravila
// -----------------------------------------------
function i_rule_id( nID )
local lRet := .t.

if ( (Ch==K_CTRL_N) .or. (Ch==K_F4) )
	
	if ( LastKey()==K_ESC )
		return lRet := .f.
	endif
	
	nID := _last_id()
	
	AEVAL(GetList,{|o| o:display()})
	
endif

return lRet




// --------------------------------------------
// vraca posljednji zapis iz tabele
// --------------------------------------------
function _last_no( cRuleObj )
local nNo := 0
local nSelect := SELECT()
local nRec := RECNO()
local cModul := PADR( goModul:oDataBase:cName, 10 )

cRuleObj := PADR( cRuleObj, 30 )

select fmkrules
set order to tag "2"
go top
seek cModul + cRuleObj 

do while !EOF() .and. field->modul_name == cModul ;
	.and. field->rule_obj == cRuleObj

	nNo := field->rule_no
	
	skip
enddo

nNo += 1

select (nSelect)
go (nRec)

return nNo



// --------------------------------------------
// vraca posljednji id iz tabele
// --------------------------------------------
function _last_id()
local nNo := 0
local nSelect := SELECT()
local nRec := RECNO()
local cTbFilter

select fmkrules
cTbFilter := DBFilter()
set filter to

set order to tag "1"
go bottom

nNo := field->rule_id + 1

set order to tag "2"
set filter to &cTbFilter

select (nSelect)
go (nRec)

return nNo



// -----------------------------------------------------
// prikazuje poruku o gresci
// -----------------------------------------------------
function sh_rule_err( cMsg, nLevel )
local aMsg
local cTxt := ""
local i

if nLevel == nil
	nLevel := 0
endif

aMsg := SjeciStr( ALLTRIM( cMsg ), 70 )

cTxt := ""

for i:=1 to LEN(aMsg)

	cTxt += aMsg[i] + "#"
	
next

cTxt := _info_level( nLevel ) + cTxt

msgbeep( cTxt )

return


// -----------------------------------------
// informacija o nivou 
// -----------------------------------------
static function _info_level( nLev )
cRet := ""

do case
	case nLev == 1 .or. nLev == 2 .or. nLev == 3
		cRet := "! OBAVJESTENJE !##"
	case nLev == 4
		cRet := "! UPOZORENJE !##"
	case nLev == 5
		cRet := "!!! VAZNO UPOZORENJE !!!##"
		
endcase

return cRet


