#include "sc.ch"

/*! \fn GenPartnSt(lGenPartnSt, nSldMinIzn, cPosId)
 *  \brief Postavljanje upita za generisanje stanja partnera te setovanje varijabli
 *  \param lGenPartnSt - da li se koristi ovaj feature
 *  \param nMinIznos - minimalan iznos 
 *  \param cPosId - id oznaka pos-a
 */
function GenPartnSt(lGenPartnSt, nSldMinIzn, cPosId)
*{
local GetList:={}
local cModName:=""
local cDN:="D"

altd()
if cPosId == nil
	cPosId := ""
endif

lGenPartnSt:=.f.
nSldMinIzn:=5
cModName:=goModul:oDataBase:cName

if Pitanje(,"Generisati stanje partnera za HH", "N")=="N"
	return
endif

Box(, 6, 60)
	@ 1+m_x, 2+m_y SAY "Prenos stanja partnera: " + cModName + SPACE(10)
	@ 2+m_x, 2+m_y SAY "--------------------------------"
	@ 3+m_x, 2+m_y SAY "Ne prenosi partnere sa saldom < od:" GET nSldMinIzn PICT "999.99"
	// ako je proslijedjen i ovaj parametar onda se radi o topsu
	if cModName <> "POS"
		@ 4+m_x, 2+m_y SAY "Prodajno mjesto TOPS: " GET cPosId
	endif
	
	@ 6+m_x, 2+m_y SAY "Prenjeti stanje partnera (D/N)?" GET cDN PICT "@!" VALID cDN$"DN"
	read
BoxC()
if cDN=="D"
	lGenPartnSt:=.t.
	CrePstDB(cModName)
endif

return
*}


/*! \fn AzurTopsOstav(nId, cIdFmk, cNaziv, nIznosG, nSldMinIzn)
 *  \brief Poziva funkciju AddToOstav() i odredjuje da li je nIznosG manji od nSldMinIzn 
 */
function AzurTopsOstav(nId, cIdFmk, cNaziv, nIznosG, nSldMinIzn)
*{
if nIznosG < nSldMinIzn
	return
endif
O_PrenHH()
AddToPartn(nId, cIdFmk, cNaziv)
AddToOstav(nId, nIznosG)
return
*}


/*! \fn AzurTopsParams(cId, cNaziv, cOpis)
 *  \brief Poziva f-ju AddToParams()
 */
function AzurTopsParams(cId, cNaziv, cOpis)
*{
O_PrenHH()
AddToParams(cId, cNaziv, cOpis)
return
*}


/*! \fn AzurFinOstav(cPosId, cIdFmk, nIznos1, nIznos2, nIznos3, nIznos4, nSldMinIzn)
 *  \brief Poziva f-ju AddFinIntervalsToOstav() 
 */
function AzurFinOstav(cPosId, cIdFmk, nIznos1, nIznos2, nIznos3, nIznos4, nSldMinIzn)
*{
if nIznos1+nIznos2+nIznos3+nIznos4 < nSldMinIzn
	return
endif
O_PrenHH(cPosId)
AddFinIntervalsToOstav(cIdFmk, nIznos1, nIznos2, nIznos3, nIznos4)
return
*}


/*! \fn AddPAzToParams(dDate)
 *  \brief Poziva f-ju AddToParams() i dodjeljuje joj parametre PAZ
 *  \param dDate - datum azuriranja
 */
function AddPAzToParams(dDate)
*{
AzurTopsParams("PAZ", "Posljednje azuriranje", DToS(dDate))
return
*}


/*! \fn AddSCnToParams(lSilent)
 *  \brief Poziva f-ju AddToParams() i dodjeljuje joj parametre SCN
 *  \param lSilent - .t. - tihi mod, .f. - prijavi MSG o prenesenim parametrima
 */
function AddSCnToParams(lSilent)
*{
if lSilent == nil
	lSilent := .t.
endif
nPartners:=GetOstavCnt()
AzurTopsParams("SCN", "Broj prenesenih partnera", ALLTRIM(STR(nPartners)))
if !lSilent
	MsgBeep("Preneseno " + ALLTRIM(STR(nPartners)) + " partnera!")
endif
return
*}


