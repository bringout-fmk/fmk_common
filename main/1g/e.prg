#include "\dev\fmk\ld\ld.ch"

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
 * $Source: c:/cvsroot/cl/sigma/fmk/ld/main/1g/e.prg,v $
 * $Author: sasa $ 
 * $Revision: 1.1 $
 * $Log: e.prg,v $
 * Revision 1.1  2002/11/05 13:23:31  sasa
 * ubacivanje LD-a u cvs, novi kod
 *
 * Revision 1.5  2002/06/25 08:44:24  ernad
 *
 */
 

/*! \file fmk/ld/main/1g/e.prg
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
	MainLD(cKorisn,cSifra,p3,p4,p5,p6,p7)
return
*}

#endif



/*! \fn MainLD(cKorisn,cSifra,p3,p4,p5,p6,p7)
 *  \brief
 */

function MainLD(cKorisn,cSifra,p3,p4,p5,p6,p7)
*{
local oLD

oLD:=TLDModNew()
cModul:="LD"

PUBLIC goModul

goModul:=oLD
oLD:init(NIL, cModul, D_LD_VERZIJA, D_LD_PERIOD , cKorisn, cSifra, p3,p4,p5,p6,p7)

oLD:run()

return 
*}

