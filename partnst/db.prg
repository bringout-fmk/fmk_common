#include "sc.ch"
#include "partnst.ch"



/*! \fn CrePStDB()
 *  \brief Kreiranje tabela za prenos (OSTAV, PARAMS)
 */
function CrePStDB(cModulName)
*{

if cModulName<>"POS"
	return
endif

// Izbrisi tabelu OSTAV
ferase(KUMPATH+"ostav.dbf")
ferase(KUMPATH+"ostav.cdx")
// Izbrisi tabelu PARAMS
ferase(KUMPATH+"params.dbf")
ferase(KUMPATH+"params.cdx")

aDbf:={} 
AADD(aDbf, { "ID",       "N",  6, 0})
AADD(aDbf, { "OZNAKA",   "C",  8, 0})
AADD(aDbf, { "NAZIV",    "C", 30, 0})
AADD(aDbf, { "IZNOSG",   "N", 15, 2})
AADD(aDbf, { "IZNOSZ1",  "N", 15, 2})
AADD(aDbf, { "IZNOSZ2",  "N", 15, 2})
AADD(aDbf, { "IZNOSZ3",  "N", 15, 2})
AADD(aDbf, { "IZNOSZ4",  "N", 15, 2})
DBcreate2(KUMPATH+"OSTAV.DBF",aDbf)
CREATE_INDEX("ID", "id", KUMPATH+"OSTAV")
CREATE_INDEX("OZNAKA", "oznaka", KUMPATH+"OSTAV")

aDbf:={}
AADD(aDbf, { "ID",   "C",  3, 0} )
AADD(aDbf, { "NAZ",  "C", 20, 0} )
AADD(aDbf, { "OPIS", "C", 40, 0} )
DBcreate2(KUMPATH+"PARAMS.DBF",aDbf)
CREATE_INDEX("ID", "ID", KUMPATH+"PARAMS")

return
*}


/*! \fn O_PrenHH()
 *  \brief Otvaranje tabele za prenos na HH
 */
function O_PrenHH(cPosID)
*{
local nArr
nArr:=SELECT()
altd()

if cPosID <> nil
	O_KONCIJ
	cTKPath:=GetTopsKumPath(cPosId)
	// OSTAV
	SELECT (F_F_OSTAV)
	USE (cTKPath+"OSTAV")
	set order to tag "ID"
	// PARAMS
	SELECT (F_F_PARAMS)
	USE (cTKPath+"PARAMS")
	set order to tag "ID"
else
	O_OSTAV
	O_PARAMS
endif

select (nArr)
return
*}


function GetTopsKumPath(cTId)
*{
cTKPath:=""
O_KONCIJ
select koncij
// setuj filter po cProdId
set filter to idprodmjes=cTId
go top
if (field->idprodmjes == cTId)
	cTKPath:=ALLTRIM(koncij->kumtops)
endif
set filter to

return cTKPath
*}


/*! \fn AddToOstav(nIdN,dDatum,cBrojDok,cStatus,nIznos)
 *  \brief Dodaje gotovinski zapis u tabelu ostav - iz TOPS-a
 *  \param nId - polje IDN iz rngost (veza sa partn->id)
 *  \param cOznaka - oznaka idfmk iz RNGOST
 *  \param nIznosG - saldo partnera iz TOPS-a
 */
function AddToOstav(nId, cOznaka, cNaziv, nIznosG)
*{
local nArr
nArr:=SELECT()

select ostav
append blank
replace id with nId
replace oznaka with cOznaka
replace naziv with cNaziv
replace iznosg with nIznosG
// ostala polja setuj na 0
replace iznosz1 with 0
replace iznosz2 with 0
replace iznosz3 with 0
replace iznosz4 with 0

select (nArr)

return
*}


/*! \fn AddToParams(cID, cNaziv, cOpis)
 *  \brief Dodaje zapis u tabelu params - ovo je kontrolna tabela iz koje mozemo vidjeti koliko je preneseno partnera a koliko otvorenih stavki te kada je zadnji put prenos radjen.
 *  \param cID - 1. PAZ - Posljednje azuriranje 2. PCN - Broj prenesenih partnera 3. SCN - Broj prenesenih otvorenih stavki.
 *  \param cNaziv - Naziv promjene
 *  \param cOpis - Opis promjene
 */
function AddToParams(cID, cNaziv, cOpis)
*{
local nArr
nArr:=SELECT()

select params
append blank
replace id with cId
replace naz with cNaziv
replace opis with cOpis

select (nArr)

return
*}


/*! \fn AddFinIntervalsToOstav(cIdPartn, nIznos1, nIznos2, nIznos3, nIznos4)
 *  \brief Dodaje rocne intervale u OSTAV iz modula FIN 
 *  \param cIdPartn - id partnera
 *  \param nIznos1 - saldo do 4 dana
 *  \param nIznos2 - saldo do 8 dana
 *  \param nIznos3 - saldo do 16 dana
 *  \param nIznos4 - saldo do 20 dana
 */
function AddFinIntervalsToOstav(cIdPartn, nIznos1, nIznos2, nIznos3, nIznos4)
*{
local nArr
nArr:=SELECT()

select (F_F_OSTAV)
set order to tag "oznaka"
go top

hseek cIdPartn

if ostav->oznaka == cIdPartn
	replace iznosz1 with nIznos1
	replace iznosz2 with nIznos2
	replace iznosz3 with nIznos3
	replace iznosz4 with nIznos4
endif

select (nArr)

return
*}


