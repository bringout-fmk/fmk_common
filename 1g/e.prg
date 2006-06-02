#include "\dev\fmk\ld\ld.ch"

/*
 * ----------------------------------------------------------------
 *                         Copyright Sigma-com software 1996-2006 
 * ----------------------------------------------------------------
 *
 */
 

/*! \file fmk/ld/main/1g/e.prg
 *  \brief
 */


EXTERNAL RIGHT,LEFT,FIELDPOS

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

