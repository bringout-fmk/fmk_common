#include "\cl\sigma\fmk\kalk\kalk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/rpt/1g/mnu_rpt.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.5 $
 * $Log: mnu_rpt.prg,v $
 * Revision 1.5  2003/02/03 00:28:48  mirsad
 * Vindija - propust
 *
 * Revision 1.4  2002/07/06 17:28:58  ernad
 *
 *
 * izvjestaj Trgomarket: pregled stanja po objektima
 *
 * Revision 1.3  2002/06/24 08:42:34  sasa
 * no message
 *
 *
 */


/*! \file fmk/kalk/rpt/1g/mnu_rpt.prg
 *  \brief Izvjestaji
 */

/*! \fn MIzvjestaji()
 *  \brief Glavni menij izvjestaja
 */
 
function MIzvjestaji()
*{

private Opc:={}
private opcexe:={}

AADD(opc,"1. izvjestaji magacin             ")
AADD(opcexe, {|| IzvjM()})
AADD(opc,"2. izvjestaji prodavnica")
AADD(opcexe, {|| IzvjP()})
AADD(opc,"3. izvjestaji magacin+prodavnica")
AADD(opcexe, {|| IzvjMaPr() } )
AADD(opc,"4. proizvoljni izvjestaji")
AADD(opcexe, {|| Proizv()})
private Izbor:=1
Menu_SC("izvj")
CLOSERET
return
*}


/*! \fn IzvjMaPr()
 *  \brief Izvjestaji magacin / prodavnica
 */
 
function IzvjMaPr()
*{
private opc:={}
private opcexe:={}

AADD(opc, "F. finansijski obrt za period mag+prod")
AADD(opcexe, {|| ObrtPoMjF()})
AADD(opc, "N. najprometniji artikli")
AADD(opcexe, {|| NPArtikli()})
AADD(opc, "O. stanje artikala po objektima ")
AADD(opcexe, {|| StanjePoObjektima()})

if IsPlanika()
	AADD(opc, "Z. pregled kretanja zaliha mag/prod     ")
	AADD(opcexe, {|| PreglKret()})
	AADD(opc, "M. mjesecni iskazi prodavnice/magacin")
	AADD(opcexe, {|| ObrazInv()})
endif

if IsVindija()
	AADD(opc, "V. pregled prodaje")
	AADD(opcexe, {|| PregProdaje()})
endif

close all
private Izbor:=1
Menu_SC("izmp")
return
*}

