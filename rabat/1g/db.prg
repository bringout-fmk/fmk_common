#include "sc.ch"
#include "rabat.ch"

/*! \fn CreRabDB()
 *  \brief Kreira tabelu rabat u SIFPATH
 */
 
function CreRabDB()
*{
// RABAT.DBF
aDbf:={}
AADD(aDbf,{"IDRABAT"      , "C", 10, 0})
AADD(aDbf,{"TIPRABAT"     , "C", 10, 0})
AADD(aDbf,{"DATUM"        , "D",  8, 0})
AADD(aDbf,{"DANA"         , "N",  5, 2})
AADD(aDbf,{"IDROBA"       , "C", 10, 0})
AADD(aDbf,{"IZNOS1"       , "N",  5, 5})
AADD(aDbf,{"IZNOS2"       , "N",  5, 5})
AADD(aDbf,{"IZNOS3"       , "N",  5, 5})
AADD(aDbf,{"IZNOS4"       , "N",  5, 5})
AADD(aDbf,{"IZNOS5"       , "N",  5, 5})
AADD(aDbf,{"SKONTO"       , "N",  5, 5})

if !File((SIFPATH + "rabat.dbf"))
	DbCreate2(SIFPATH + "rabat.dbf", aDbf)
endif

CREATE_INDEX("1", "IDRABAT+TIPRABAT+IDROBA", SIFPATH + "rabat.dbf", .t.)
CREATE_INDEX("2", "IDRABAT+TIPRABAT+DTOS(DATUM)", SIFPATH + "rabat.dbf", .t.)

return
*}


/*! \fn GetRabForArticle(cIdRab, cTipRab, cIdRoba, nTekIznos)
 *  \brief Vraca iznos rabata za dati artikal
 *  \param cIdRab - id rabat
 *  \param nTekIznos - tekuce polje iznosa
 *  \param cTipRab - tip rabata
 *  \param cIdRoba - id roba
 *  \return nRet - vrijednost rabata
 */
function GetRabForArticle(cIdRab, cTipRab, cIdRoba, nTekIznos)
*{
local nArr
nArr:=SELECT()

cIdRab := PADR(cIdRab, 10)
cTipRab := PADR(cTipRab, 10)

O_RABAT
select rabat
set order to tag "1"
go top
seek cIdRab + cTipRab + cIdRoba

// vrati iznos rabata za tekucu vriijednost polja IZNOSn
nRet:=GetRabIznos(nTekIznos)

select (nArr)

return nRet
*}


/*! \fn GetDaysForRabat(cIdRab, cTipRab)
 *  \brief Vraca broj dana (rok placanja) za odredjeni tip rabata
 *  \param cIdRab - id rabat
 *  \param cTipRab - tip rabata
 *  \return nRet - vrijednost dana
 */
function GetDaysForRabat(cIdRab, cTipRab)
*{
local nArr
nArr:=SELECT()

cIdRab := PADR(cIdRab, 10)
cTipRab := PADR(cTipRab, 10)

O_RABAT
select rabat
set order to tag "1"
go top
seek cIdRab + cTipRab
nRet:=field->dana
select (nArr)

return nRet
*}


/*! \fn GetRabIznos(cTekIzn)
 *  \brief Vraca iznos rabata za zadati cTekIznos (vrijednost polja)
 *  \param cTekIzn - tekuce polje koje se uzima
 */
function GetRabIznos(cTekIzn)
*{
if (cTekIzn == nil)
	cTekIzn := "1"
endif

// primjer: "iznos" + cTekIzn
//           iznos1 ili iznos3
cField := "iznos" + ALLTRIM(cTekIzn)
// izvrsi macro evaluaciju
nRet := field->&cField
return nRet
*}


/*! \fn GetSkontoArticle(cIdRab, cTipRab, cIdRoba)
 *  \brief Vraca iznos skonto za dati artikal
 *  \param cIdRab - id rabat
 *  \param cTipRab - tip rabata
 *  \param cIdRoba - id roba
 *  \return nRet - vrijednost skonto
 */
function GetSkontoArticle(cIdRab, cTipRab, cIdRoba)
*{
local nArr
nArr:=SELECT()

cIdRab := PADR(cIdRab, 10)
cTipRab := PADR(cTipRab, 10)
O_RABAT
select rabat
set order to tag "1"
go top
seek cIdRab + cTipRab + cIdRoba
nRet:=field->skonto
select (nArr)

return nRet
*}





