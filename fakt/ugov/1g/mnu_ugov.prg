
/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/ugov/1g/mnu_ugov.prg,v $
 * $Author: sasa $ 
 * $Revision: 1.1 $
 * $Log: mnu_ugov.prg,v $
 * Revision 1.1  2002/07/05 14:25:35  sasa
 * dodat novi prg
 *
 *
 */


/*! \file fmk/fakt/ugov/1g/mnu_ugov.prg
 *  \brief Ugovori
 */

/*! \fn MnuUgovori()
 *  \brief Menij ugovora
 */
 
function SifUgovori()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. ugovori                  ")
AADD(opcexe,{|| P_Ugov()})
AADD(opc,"2. ugovori - default podaci ")
AADD(opcexe,{|| DFTParUg()})

Menu_SC("sugov")
return
*}

