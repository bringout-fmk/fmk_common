#include "sc.ch"

/*! \fn drn_create()
 *  \brief kreiranje tabela RN i DRN
 */
function drn_create()
*{
local cDRnName := "DRN.DBF"
local cRnName := "RN.DBF"
local cDRTxtName := "DRNTEXT.DBF"
local aDRnField:={}
local aRnField:={}
local aDRTxtField:={}

// provjeri da li postoji fajl DRN.DBF
if !FILE(PRIVPATH + cDRnName)
	// drn specifikacija polja
	get_drn_fields(@aDRnField)
        // kreiraj tabelu
	dbcreate2(PRIVPATH + cDRnName, aDRnField)
endif

// provjeri da li postoji fajl RN.DBF
if !FILE(PRIVPATH + cRnName)
	// rn specifikacija polja
	get_rn_fields(@aRnField)
        // kreiraj tabelu
	dbcreate2(PRIVPATH + cRnName, aRnField)
endif

// provjeri da li postoji fajl DRNTEXT.DBF
if !FILE(PRIVPATH + cDRTxtName)
	// rn specifikacija polja
	get_dtxt_fields(@aDRTxtField)
        // kreiraj tabelu
	dbcreate2(PRIVPATH + cDRTxtName, aDRTxtField)
endif

// kreiraj indexe
CREATE_INDEX("1", "brdok+DToS(datdok)", PRIVPATH + "DRN")
CREATE_INDEX("1", "brdok+rbr+podbr", PRIVPATH + "RN")
CREATE_INDEX("1", "tip", PRIVPATH + "DRNTEXT")

return
*}


function dokspf_create()
*{
local aDbf:={}

if !FILE(KUMPATH + "\DOKSPF.DBF")
	AADD(aDbf, {"IDPOS", "C", 2, 0})
	AADD(aDbf, {"IDVD",  "C", 2, 0})
	AADD(aDbf, {"DATUM", "D", 8, 0})
	AADD(aDbf, {"BRDOK", "C", 6, 0})
	AADD(aDbf, {"KNAZ",  "C", 35, 0})
	AADD(aDbf, {"KADR",  "C", 35, 0})
	AADD(aDbf, {"KIDBR", "C", 13, 0})
	if gSql == "D"
		AddOidFields(@aDbf)
	endif
	DbCreate2(KUMPATH + "\DOKSPF.DBF", aDbf)
endif

CREATE_INDEX("1", "idpos+idvd+DToS(datum)+brdok", KUMPATH + "DOKSPF")

return
*}

/*! \fn get_drn_fields(aArr)
 *  \brief napuni matricu aArr sa specifikacijom polja tabele
 *  \param aArr - matrica
 */
function get_drn_fields(aArr)
*{
AADD(aArr, {"BRDOK",   "C",  6, 0})
AADD(aArr, {"DATDOK",  "D",  8, 0})
AADD(aArr, {"DATVAL",  "D",  8, 0})
AADD(aArr, {"DATISP",  "D",  8, 0})
AADD(aArr, {"VRIJEME", "C",  5, 0})
AADD(aArr, {"UKBEZPDV","N", 15, 5})
AADD(aArr, {"UKPOPUST","N", 15, 5})
AADD(aArr, {"UKBPDVPOP","N", 15, 5})
AADD(aArr, {"UKPDV",   "N", 15, 5})
AADD(aArr, {"UKUPNO",  "N", 15, 5})
AADD(aArr, {"CSUMRN",  "N",  6, 0})
return
*}


/*! \fn get_rn_fields(aArr)
 *  \brief napuni matricu aArr sa specifikacijom polja tabele
 *  \param aArr - matrica
 */
function get_rn_fields(aArr)
*{
AADD(aArr, {"BRDOK",   "C",  6, 0})
AADD(aArr, {"RBR",     "C",  3, 0})
AADD(aArr, {"PODBR",   "C",  2, 0})
AADD(aArr, {"IDROBA",  "C", 10, 0})
AADD(aArr, {"ROBANAZ", "C", 40, 0})
AADD(aArr, {"JMJ",     "C",  3, 0})
AADD(aArr, {"KOLICINA","N", 15, 5})
AADD(aArr, {"CJENPDV", "N", 15, 5})
AADD(aArr, {"CJENBPDV", "N", 15, 5})
AADD(aArr, {"CJEN2PDV", "N", 15, 5})
AADD(aArr, {"CJEN2BPDV", "N", 15, 5})
AADD(aArr, {"POPUST",   "N", 8, 3})
AADD(aArr, {"PPDV",     "N", 8, 3})
AADD(aArr, {"VPDV",     "N", 15, 5})
AADD(aArr, {"UKUPNO",    "N", 15, 5})
return
*}

/*! \fn get_dtxt_fields(aArr)
 *  \brief napuni matricu aArr sa specifikacijom polja tabele
 *  \param aArr - matrica
 */
function get_dtxt_fields(aArr)
*{
AADD(aArr, {"TIP",   "C",   3, 0})
AADD(aArr, {"OPIS",  "C", 200, 0})
return
*}


function add_drntext(cTip, cOpis)
*{
if !USED(F_DRNTEXT)
	O_DRNTEXT
endif

select drntext
append blank
replace tip with cTip
replace opis with cOpis

return
*}


function add_drn(cBrDok, dDatDok, dDatVal, dDatIsp, cTime, nUBPDV, nUPopust, nUBPDVPopust, nUPDV, nUkupno, nCSum)
*{
if !USED(F_DRN)
	O_DRN
endif
select drn
append blank
replace brdok with cBrDok
replace datdok with dDatDok
if (dDatVal <> nil)
	replace datval with dDatVal
endif
if (dDatIsp <> nil)
	replace datisp with dDatIsp
endif
replace vrijeme with cTime
replace ukbezpdv with nUBPDV
replace ukpopust with nUPopust
replace ukbpdvpop with nUBPDVPopust
replace ukpdv with nUPDV
replace ukupno with nUkupno
replace csumrn with nCSum

return
*}

function add_rn(cBrDok, cRbr, cPodBr, cIdRoba, cRobaNaz, cJmj, nKol, nCjenPdv, nCjenBPdv, nCjen2Pdv, nCjen2BPdv, nPopust, nPPdv, nVPdv, nUkupno)
*{
if !USED(F_RN)
	O_RN
endif

select rn
append blank
replace brdok with cBrDok
replace rbr with cRbr
replace podbr with cPodBr
replace idroba with cIdRoba
replace robanaz with cRobaNaz
replace jmj with cJmj
replace kolicina with nKol
replace cjenpdv with nCjenPdv
replace cjenbpdv with nCjenBPdv
replace cjen2pdv with nCjen2Pdv
replace cjen2bpdv with nCjen2BPdv
replace popust with nPopust
replace ppdv with nPPdv
replace vpdv with nVPdv
replace ukupno with nUkupno 

return
*}



function drn_empty()
*{
O_DRN
select drn
zap

O_RN
select rn
zap

O_DRNTEXT
select drntext
zap

return
*}


function drn_open()
*{
O_DRN
O_DRNTEXT
O_RN
return
*}


function drn_csum()
*{
local nCSum
local nRNSum

// uzmi csumrn iz DRN
select drn
go top
nCSum := field->csumrn

// uzmi broj zapisa iz RN
select rn
nRNSum := RecCount2()

if nRNSum == nCSum
	return .t.
endif

return .f.
*}


function get_dtxt_opis(cTip)
*{
local cRet

if !USED(F_DRNTEXT)
	O_DRNTEXT
endif
select drntext
set order to tag "1"
hseek cTip

if !Found()
	MsgBeep("Ne mogu procitati opis za tip " + cTip + " !")
	return "XXX"
endif
cRet := ALLTRIM(field->opis)

return cRet
*}


function AzurKupData(cIdPos)
*{
local cKNaziv
local cKAdres
local cKIdBroj

if !USED(F_DRN)
	O_DRN
endif
if !USED(F_DOKSPF)
	O_DOKSPF
endif
if !USED(F_DRNTEXT)
	O_DRNTEXT
endif

cKNaziv := get_dtxt_opis("K01")
cKAdres := get_dtxt_opis("K02")
cKIdBroj := get_dtxt_opis("K03")

select drn
go top

select dokspf
append blank
Sql_Append(.t.)

SmReplace("idpos", cIdPos)
SmReplace("idvd", VD_RN)
SmReplace("brdok", drn->brdok)
SmReplace("datum", drn->datdok)
SmReplace("knaz", cKNaziv)
SmReplace("kadr", cKAdres)
SmReplace("kidbr", cKIdBroj)

return
*}


