#include "\cl\sigma\fmk\kalk\kalk.ch"

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


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/main/1g/e.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.5 $
 * $Log: e.prg,v $
 * Revision 1.5  2002/06/25 08:44:24  ernad
 *
 *
 * ostranicavanje planika, doxy - grupa: Planika
 *
 * Revision 1.4  2002/06/24 07:33:48  mirsad
 * no message
 *
 *
 */
 

/*! \file fmk/kalk/main/1g/e.prg
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
	MainKalk(cKorisn,cSifra,p3,p4,p5,p6,p7)
return
*}

#endif



/*! \fn MainKALK(cKorisn,cSifra,p3,p4,p5,p6,p7)
 *  \brief
 */

function MainKALK(cKorisn,cSifra,p3,p4,p5,p6,p7)
*{
local oKalk

oKalk:=TKalkModNew()
cModul:="KALK"

PUBLIC goModul

goModul:=oKalk
oKalk:init(NIL, cModul, D_KA_VERZIJA, D_KA_PERIOD , cKorisn, cSifra, p3,p4,p5,p6,p7)

oKalk:run()

return 
*}

