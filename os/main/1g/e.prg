#include "\cl\sigma\fmk\os\os.ch"

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

/*! \file fmk/os/main/1g/e.prg
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
	MainOs(cKorisn,cSifra,p3,p4,p5,p6,p7)
return
*}

#endif



/*! \fn MainOs(cKorisn,cSifra,p3,p4,p5,p6,p7)
 *  \brief
 */

function MainOs(cKorisn,cSifra,p3,p4,p5,p6,p7)
*{
local oOs

oOs:=TOsModNew()
cModul:="OS"

PUBLIC goModul

goModul:=oOs
oOs:init(NIL, cModul, D_OS_VERZIJA, D_OS_PERIOD , cKorisn, cSifra, p3,p4,p5,p6,p7)

oOs:run()

return 
*}

