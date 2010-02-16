#include "sc.ch"


// ------------------------------------
// xml node
// ------------------------------------
function xml_node( cName, cData, lWrite )
local cTmp

if lWrite == nil
	lWrite := .t.
endif

// eg. 
// cName = "position"
// cData = "x26"
// => <position>x26</position>

cTmp := _bracket( cName, .f. )
cTmp += ALLTRIM(cData)
cTmp += _bracket( cName, .t. )

if lWrite == .t.
	?? cTmp
	?
endif

return cTmp



// ----------------------------------------------
// xml subnode
// ----------------------------------------------
function xml_subnode( cName, lEscape, lWrite )
local cTmp

if lWrite == nil
	lWrite := .t.
endif

// eg.
// cName = "position"
// => <position> (lEscape = .f.)
// => </position> (lEscape = .t.)

cTmp := _bracket( cName, lEscape ) 

if lWrite == .t.
	?? cTmp
	?
endif

return cTmp



// ----------------------------------------------------
// xml header
// ----------------------------------------------------
function xml_head( lWrite, cTxt )
local cTmp := '<?xml version="1.0" encoding="UTF-8"?>'

if cTxt == nil
	cTxt := cTmp
endif

if lWrite == nil
	lWrite := .t.
endif

if lWrite == .t.
	?? cTxt
	?
endif

return cTxt


// --------------------------------------------
// stavi string u zagrade
// --------------------------------------------
static function _bracket( cStr, lEsc )
local cRet

cRet := "<"
if lEsc == .t.
	cRet += "/"
endif
cRet += cStr
cRet += ">"

return cRet


// --------------------------------
// otvori xml fajl za upis
// --------------------------------
function open_xml( cFile )

if cFile == nil
	cFile := PRIVPATH + "data.xml"
endif

set printer to (cFile)
set printer on
set console off
return


// --------------------------------
// zatvori fajl za upis
// --------------------------------
function close_xml()
set printer to
set printer off
set console on
return


// ----------------------------------------------
// datum za xml dokument
// ----------------------------------------------
function xml_date( dDate )
local cRet := ""

cRet := ALLTRIM( STR( YEAR(dDate )) )
cRet += "-"
cRet += PADL( ALLTRIM( STR( MONTH(dDate)) ), 2, "0" )
cRet += "-"
cRet += PADL( ALLTRIM( STR( DAY(dDate)) ), 2, "0" )

return cRet

