#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/main/1g/e.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.5 $
 * $Log: e.prg,v $
 * Revision 1.5  2003/01/14 03:23:33  ernad
 * exclusiv ... probelm mreza W2K ...
 *
 * Revision 1.4  2002/12/30 16:33:37  mirsad
 * no message
 *
 * Revision 1.3  2002/10/15 13:24:57  sasa
 * ciscenje koda
 *
 * Revision 1.2  2002/06/18 13:07:22  sasa
 * no message
 *
 *
 */

/*! \file fmk/fakt/main/1g/e.prg
 *  \brief
 */


#ifndef CPP
EXTERNAL RIGHT,LEFT,FIELDPOS
#endif

#ifdef LIB
function Main(cKorisn, cSifra, p3,p4,p5,p6,p7)
*{
	MainFakt(cKorisn, cSifra, p3,p4,p5,p6,p7)
return
*}
#endif



/*! \fn MainFAKT(cKorisn,cSifra,p3,p4,p5,p6,p7)
 *  \brief
 *  \param cKorisn
 *  \param cSifra
 *  \param p3
 *  \param p4
 *  \param p5
 *  \param p6
 *  \param p7
 */
 
function MainFAKT(cKorisn,cSifra,p3,p4,p5,p6,p7)
*{
local oFakt

oFakt:=TFaktModNew()
cModul:="FAKT"

PUBLIC goModul

goModul:=oFakt
oFakt:init(NIL, cModul, D_FA_VERZIJA, D_FA_PERIOD , cKorisn, cSifra, p3,p4,p5,p6,p7)

oFakt:run()

return 
*}


