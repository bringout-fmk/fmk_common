#include "sc.ch"


// delete rn dbf's
function del_rndbf()
*{
close all
// drn.dbf
FErase(PRIVPATH + "DRN.DBF")
FErase(PRIVPATH + "DRN.CDX")

// rn.dbf
FErase(PRIVPATH + "RN.DBF")
FErase(PRIVPATH + "RN.CDX")

// drntext.dbf
FErase(PRIVPATH + "DRNTEXT.DBF")
FErase(PRIVPATH + "DRNTEXT.CDX")

return 1
*}


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

if del_rndbf() == 0
	MsgBeep("Greska: brisanje pomocnih tabela !!!")
	return
endif

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


// kreiranje tabele DOKSPF (POS tabela za podatke o kupcu)
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
	AADD(aDbf, {"DATISP", "D", 8, 0})
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
if gModul == "TOPS"
	AADD(aArr, {"BRDOK",   "C",  6, 0})
else
	AADD(aArr, {"BRDOK",   "C",  8, 0})
endif
AADD(aArr, {"DATDOK",  "D",  8, 0})
AADD(aArr, {"DATVAL",  "D",  8, 0})
AADD(aArr, {"DATISP",  "D",  8, 0})
AADD(aArr, {"VRIJEME", "C",  5, 0})
AADD(aArr, {"ZAOKR",   "N", 10, 5})
AADD(aArr, {"UKBEZPDV","N", 15, 5})
AADD(aArr, {"UKPOPUST","N", 15, 5})
AADD(aArr, {"UKPOPTP", "N", 15, 5})
AADD(aArr, {"UKBPDVPOP","N",15, 5})
AADD(aArr, {"UKPDV",   "N", 15, 5})
AADD(aArr, {"UKUPNO",  "N", 15, 5})
AADD(aArr, {"UKKOL",   "N", 14, 2})
AADD(aArr, {"CSUMRN",  "N",  6, 0})
if glUgost
  // stopa poreza na potrosnju 1
  AADD(aArr, {"STPP1",  "N",  6, 1})
  // ukupno porez na potrosnju 1
  AADD(aArr, {"UKPP1",  "N", 14, 2})
  // moguce 4 stope poreza na potrosnju
  AADD(aArr, {"STPP2",  "N",  6, 1})
  AADD(aArr, {"UKPP2",  "N", 14, 2})
  AADD(aArr, {"STPP3",  "N",  6, 1})
  AADD(aArr, {"UKPP3",  "N", 14, 2})
  AADD(aArr, {"STPP4",  "N",  6, 1})
  AADD(aArr, {"UKPP4",  "N", 14, 2})
  AADD(aArr, {"STPP5",  "N",  6, 1})
  AADD(aArr, {"UKPP5",  "N", 14, 2})
endif

return
*}


/*! \fn get_rn_fields(aArr)
 *  \brief napuni matricu aArr sa specifikacijom polja tabele
 *  \param aArr - matrica
 */
function get_rn_fields(aArr)
*{
if gModul == "TOPS"
	AADD(aArr, {"BRDOK",   "C",  6, 0})
else
	AADD(aArr, {"BRDOK",   "C",  8, 0})
endif
AADD(aArr, {"RBR",     "C",  3, 0})
AADD(aArr, {"PODBR",   "C",  2, 0})
AADD(aArr, {"IDROBA",  "C", 10, 0})
AADD(aArr, {"ROBANAZ", "C", 160, 0})
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
AADD(aArr, {"POPTP",   "N", 8, 3})
AADD(aArr, {"VPOPTP",   "N", 15, 5})
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
local lFound
if !USED(F_DRNTEXT)
	O_DRNTEXT
	SET ORDER TO TAG "ID"
endif

select drntext
GO TOP


SEEK cTip

if !FOUND()
  append blank
endif

replace tip with cTip
replace opis with cOpis

return
*}


// dodaj u drn.dbf
function add_drn(cBrDok, dDatDok, dDatVal, dDatIsp, cTime, nUBPDV, nUPopust, nUBPDVPopust, nUPDV, nUkupno, nCSum, nUPopTp, nZaokr, aPP)
*{
local cnt1

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
replace zaokr with nZaokr

if fieldpos("UKPOPTP") <> 0
	// popust na teret prodavca
	replace ukpoptp with nUPopTp
endif

if glUgost

 // poseban porez na potrosnju
 if (aPP <> nil) 
     // primjer matrice za 3 stope poreza 5%, 7%, 10%
     //
     // aPP := { { 5, 7, 10}  , { 333.22, 15.19, 200.3 } }
    for cnt1 := 1 to LEN(aPP[1])
        
        if cnt1 == 1 
           replace stpp1 with aPP[1,1] ,;
               ukpp1 with aPP[2,1]
	endif
	if cnt1 == 2
           replace stpp2 with aPP[1,2] ,;
               ukpp2 with aPP[2,2]
	endif
        if cnt1 == 3 
            replace stpp3 with aPP[1,3] ,;
               ukpp3 with aPP[2,3]
	endif
        if cnt1 == 4
           replace stpp4 with aPP[1,4] ,;
               ukpp4 with aPP[2,4]
	endif
	if cnt1 == 5
           replace stpp5 with aPP[1,5] ,;
               ukpp5 with aPP[2,5]
	endif

    next

 endif

endif

return
*}

function add_drn_di(dDatIsp)

if !USED(F_DRN)
	O_DRN
endif


SELECT DRN
if EMPTY(brdok)
	APPEND BLANK
endif

if FIELDPOS("datisp")<>0
	replace datisp with dDatIsp
else
	MsgBeep("DATISP ne postoji u drn.dbf (add_drn_di) #Izvrsiti modstru "+gModul+".CHS !")
endif

return


// get datum isporuka
function get_drn_di()
local xRet

PushWa()

if !USED(F_DRN)
	O_DRN
endif

SELECT drn
if EMPTY(drn->BrDok)
	xRet:=nil
else

	if FIELDPOS("datisp")<>0
		xRet := datisp
	else
		MsgBeep("DATISP ne postoji u drn.dbf (get_drn_di)#Izvrsiti modstru "+gModul+".CHS !")
		xRet := nil
	endif
endif

PopWa()
return xRet




// dodaj u rn.dbf
function add_rn(cBrDok, cRbr, cPodBr, cIdRoba, cRobaNaz, cJmj, nKol, nCjenPdv, nCjenBPdv, nCjen2Pdv, nCjen2BPdv, nPopust, nPPdv, nVPdv, nUkupno, nPopNaTeretProdavca, nVPopNaTeretProdavca)
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

if ( ROUND(nPopNaTeretProdavca, 4) <> 0 )
	// popust na teret prodavca
	if FIELDPOS("poptp") <> 0
		replace poptp with nPopNaTeretProdavca
  		replace vpoptp with nVPopNaTeretProdavca
	else
  		MsgBeep("Tabela RN ne sadrzi POPTP - popust na teret prodavca")
	endif
endif

return
*}


// isprazni drn tabele
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


// otvori rn tabele
function drn_open()
*{
O_DRN
O_DRNTEXT
O_RN
return
*}


// provjera checksum-a
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


// vrati vrijednost polja opis iz tabele drntext.dbf po id kljucu
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
	return "???"
endif
cRet := ALLTRIM(field->opis)

return cRet
*}


// azuriranje podataka o kupcu
function AzurKupData(cIdPos)
*{
local cKNaziv
local cKAdres
local cKIdBroj

O_DOKSPF
// idpos+idvd+DToS(datum)+brdok
SET ORDER TO TAG "1"

if !USED(F_DRN)
	O_DRN
endif
if !USED(F_DRNTEXT)
	O_DRNTEXT
endif


cKNaziv := get_dtxt_opis("K01")
cKAdres := get_dtxt_opis("K02")
cKIdBroj := get_dtxt_opis("K03")
dDatIsp := get_drn_di()


// nema poreske fakture
if cKNaziv == "???"
	return
endif

select drn
go top

select dokspf

SEEK cIdPos + "42" + DTOS(drn->datdok) + drn->brdok
if !FOUND()
 append blank
 Sql_Append(.t.)
endif

SmReplace("idpos", cIdPos)
SmReplace("idvd", "42")
SmReplace("brdok", drn->brdok)
SmReplace("datum", drn->datdok)
if FIELDPOS("datisp")<>0
	if dDatIsp <> nil
		SmReplace("datisp", dDatIsp)
	endif
endif
SmReplace("knaz", cKNaziv)
SmReplace("kadr", cKAdres)
SmReplace("kidbr", cKIdBroj)

return
*}


