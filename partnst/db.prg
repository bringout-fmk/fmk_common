#include "sc.ch"
#include "partnst.ch"



/*! \fn CrePStDB(cModulName)
 *  \brief Kreiranje tabela za prenos (OSTAV, PARAMS)
 *  \param cModulName - ime modula - generisi tabele samo dok si u modulu POS
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
// Izbrisi tabelu PARTN
ferase(KUMPATH+"partn.dbf")
ferase(KUMPATH+"partn.cdx")

aDbf:={} 
AADD(aDbf, { "ID",       "N",  6, 0})
AADD(aDbf, { "IZNOSG",   "N", 15, 2})
AADD(aDbf, { "IZNOSZ1",  "N", 15, 2})
AADD(aDbf, { "IZNOSZ2",  "N", 15, 2})
AADD(aDbf, { "IZNOSZ3",  "N", 15, 2})
AADD(aDbf, { "IZNOSZ4",  "N", 15, 2})
DBcreate2(KUMPATH+"OSTAV.DBF",aDbf)
CREATE_INDEX("ID", "id", KUMPATH+"OSTAV")

aDbf:={} 
AADD(aDbf, { "ID",       "N",  6, 0})
AADD(aDbf, { "OZNAKA",   "C",  8, 0})
AADD(aDbf, { "NAZIV",    "C", 30, 0})
DBcreate2(KUMPATH+"PARTN.DBF",aDbf)
CREATE_INDEX("ID", "id", KUMPATH+"PARTN")
CREATE_INDEX("OZNAKA", "oznaka", KUMPATH+"PARTN")


aDbf:={}
AADD(aDbf, { "ID",   "C",  3, 0} )
AADD(aDbf, { "NAZ",  "C", 20, 0} )
AADD(aDbf, { "OPIS", "C", 40, 0} )
DBcreate2(KUMPATH+"PARAMS.DBF",aDbf)
CREATE_INDEX("ID", "ID", KUMPATH+"PARAMS")

return
*}


/*! \fn O_PrenHH(cPosID)
 *  \brief Otvaranje tabele za prenos na HH
 *  \param cPosID - id oznaka POS-a - bitan za modul FIN
 */
function O_PrenHH(cPosID)
*{
local nArr
nArr:=SELECT()
altd()

if cPosID <> nil
	O_KONCIJ
	altd()

	cTKPath:=addbs(GetTopsKumPathFromKoncij())

	// OSTAV
	SELECT (F_F_OSTAV)
	USE (cTKPath+"OSTAV")
	set order to tag "ID"

	// PARTN
	SELECT (F_F_PARTN)
	if !used()
		USE (cTKPath+"PARTN") ALIAS "T_PARTN"
	endif
	set order to tag "ID" 
else
	O_OSTAV
	O_PARAMS
	O_PARTN
endif

select (nArr)
return
*}


/*! \fn GetTopsKumPathFromKoncij(cTId)
 *  \brief Vraca KUMPATH TOPS-a iz tabele koncij
 *  \param cTId - idpm TOPS
 *  \todo razraditi procedure ako nema podesenog PATH-a
 */
function GetTopsKumPathFromKoncij()
*{
altd()
cTKPath:=""
O_KONCIJ
select koncij
// setuj filter po cProdId
set filter to idprodmjes = cPosId
go top
if (field->idprodmjes == cPosId)
	cTKPath:=ALLTRIM(koncij->kumtops)
endif
set filter to

return cTKPath
*}


/*! \fn AddToOstav(nId, nIznosG)
 *  \brief Dodaje gotovinski zapis u tabelu ostav - iz TOPS-a
 *  \param nId - polje IDN iz rngost (veza sa partn->id)
 *  \param nIznosG - saldo partnera iz TOPS-a
 */
function AddToOstav(nId, nIznosG)
*{
local nArr
nArr:=SELECT()

select ostav
append blank
replace id with nId
replace iznosg with nIznosG
// ostala polja setuj na 0
replace iznosz1 with 0
replace iznosz2 with 0
replace iznosz3 with 0
replace iznosz4 with 0

select (nArr)

return
*}

/*! \fn AddToPartn(nId, cIdFmk, cNaziv)
 *  \brief Dodaje zapis u tabelu partn - iz TOPS-a
 *  \param nId - polje IDN iz rngost (veza sa partn->id)
 *  \param cIdFmk - polje IDFMK iz tabele RNGOST
 *  \param cNaziv - naziv partnera
 */
function AddToPartn(nId, cIdFmk, cNaziv)
*{
local nArr
nArr:=SELECT()

select partn
append blank
replace id with nId
replace oznaka with cIdFmk
replace naziv with cNaziv

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

select (F_F_PARTN)
set order to tag "OZNAKA"
go top
hseek cIdPartn

if field->oznaka == cIdPartn
	nId := field->id
else
	return
endif

select (F_F_OSTAV)
set order to tag "id"
go top
hseek nId

if field->id == nId
	replace iznosz1 with nIznos1
	replace iznosz2 with nIznos2
	replace iznosz3 with nIznos3
	replace iznosz4 with nIznos4
endif
select (nArr)

return
*}


/*! \fn GetOstavCnt()
 *  \brief Vraca broj prenesenih partnera u OSTAV
 */
function GetOstavCnt()
*{
local nArr
nArr:=SELECT()
O_OSTAV
nCnt:=RecCount()
select (nArr)
return nCnt
*}

