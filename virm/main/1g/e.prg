#include "\cl\sigma\fmk\virm\virm.ch"

/*! \defgroup ini Parametri rada programa - fmk.ini
 *  @{
 *  @}
 */
 
/*! \defgroup params Parametri rada programa - *param.dbf
 *  @{
 *  @}
 */

/*! \defgroup TblZnacenjePolja Tabele - znacenje pojedinih polja
 *  @{
 *  @}
 */

/*! \file fmk/virm/main/1g/e.prg
 *  \brief
 */


#ifndef CPP
EXTERNAL RIGHT,LEFT,FIELDPOS
#endif

#ifdef LIB

/*! \fn Main(cKorisn,cSifra,p3,p4,p5,p6,p7)
 *  \brief
 */

function Main(cKorisn,cSifra,p3,p4,p5,p6,p7)
*{
	MainVirm(cKorisn,cSifra,p3,p4,p5,p6,p7)
return
*}

#endif



/*! \fn MainVirm(cKorisn,cSifra,p3,p4,p5,p6,p7)
 *  \brief
 */

function MainVirm(cKorisn,cSifra,p3,p4,p5,p6,p7)
*{
local oVirm

oVirm:=TVirmModNew()
cModul:="VIRM"

PUBLIC goModul

goModul:=oVirm
oVirm:init(NIL, cModul, D_VIRM_VERZIJA, D_VIRM_PERIOD , cKorisn, cSifra, p3,p4,p5,p6,p7)

oVirm:run()

return 
*}

