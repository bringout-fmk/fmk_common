#include "sc.ch"

/*! \fn GenPartnSt(lGenPartnSt, nSldMinIzn, cPosId)
 *  \brief Postavljanje upita za generisanje stanja partnera te setovanje varijabli
 *  \param lGenPartnSt - da li se koristi ovaj feature
 *  \param nMinIznos - minimalan iznos 
 *  \param cPosId
 */
function GenPartnSt(lGenPartnSt, nSldMinIzn, cPosId)
*{
local GetList:={}
local cModName:=""
local cDN:="D"

if cPosId == nil
	cPosId := ""
endif

lGenPartnSt:=.f.
nSldMinIzn:=5
cModName:=goModul:oDataBase:cName

Box(, 5, 60)
	@ 1+m_x, 2+m_y SAY "Prenos stanja partnera: " + cModName + SPACE(10)
	@ 2+m_x, 2+m_y SAY "--------------------------------"
	@ 3+m_x, 2+m_y SAY "Ne prenosi partnere sa saldom < od:" GET nSldMinIzn PICT "999.99"
	// ako je proslijedjen i ovaj parametar onda se radi o topsu
	if cPosId <> nil
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



function AzurTopsOstav(nId, cIdFmk, cNaziv, nIznosG, nSldMinIzn)
*{
if nIznosG < nSldMinIzn
	return
endif
O_PrenHH()
AddToOstav(nId, cIdFmk, cNaziv, nIznosG)
return
*}

function AzurTopsParams(cId, cNaziv, cOpis)
*{
O_PrenHH()
AddToParams(cId, cNaziv, cOpis)
return
*}


function AzurFinOstav(cPosId, cIdFmk, nIznos1, nIznos2, nIznos3, nIznos4, nSldMinIzn)
*{
if nIznos1+nIznos2+nIznos3+nIznos4 < nSldMinIzn
	return
endif
O_PrenHH(cPosId)
AddFinIntervalsToOstav(cIdFmk, nIznos1, nIznos2, nIznos3, nIznos4)
return
*}


function AddPAzToParams(dDate)
*{
AzurTopsParams("PAZ", "Posljednje azuriranje", DToS(dDate))
return
*}

function AddSCnToParams(nPartners, lSilent)
*{
if lSilent == nil
	lSilent := .t.
endif
AzurTopsParams("SCN", "Broj prenesenih partnera", STR(nPartners))
if !lSilent
	MsgBeep("Preneseno " + ALLTRIM(STR(nPartners)) + " partnera!")
endif
return
*}


