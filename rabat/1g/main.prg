#include "sc.ch"


/*! \fn RabVrijednost(cIdRab, cTipRab, cIdRoba, nTekIzn)
 *  \brief Vrati vrijednost rabata - pozovi func. GetRabatForArticle()
 */
function RabVrijednost(cIdRab, cTipRab, cIdRoba, nTekIzn)
*{

if Empty(cIdRoba)
	return
endif

nRet := GetRabForArticle(cIdRab, cTipRab, cIdRoba, nTekIzn)

return nRet
*}


/*! \fn GetDays(cIdRab, cTipRab)
 *  \brief Vrati vrijednost broja dana za rabat - poziva GetDaysForRabat() 
 */
function GetDays(cIdRab, cTipRab)
*{

nRet := GetDaysForRabat(cIdRab, cTipRab)

return nRet
*}

/*! \fn GetSKntForArticle()
 *  \brief Vrati vrijdnost SKONTO za artikal - poziva GetSkontoArtcile()
 */
function GetSKntForArticle(cIdRab, cTipRab, cIdRoba)
*{

nRet := GetSkontoArticle(cIdRab, cTipRab, cIdRoba)

return nRet
*}




