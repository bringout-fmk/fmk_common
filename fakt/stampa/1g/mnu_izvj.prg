#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/stampa/1g/mnu_izvj.prg,v $
 * $Author: sasa $ 
 * $Revision: 1.1 $
 * $Log: mnu_izvj.prg,v $
 * Revision 1.1  2002/07/05 14:38:22  sasa
 * uveden novi prg
 *
 *
 */


/*! \file fmk/fakt/stampa/1g/mnu_izvj.prg
 *  \brief Izvjestaji vezani za opresu stampa
 */

/*! \fn MnuStampa()
 *  \brief Menij izvjestaja za opresu stampa
 */
 
function MnuStampa()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. vrijednost robe po partnerima i opstinama")
AADD(opcexe,{|| VRobPoPar()})
AADD(opc,"2. vrijednost robe po izdanjima i izdavacima")
AADD(opcexe,{|| VRobPoIzd()})
AADD(opc,"3. porezi po tarifama i opstinama")
AADD(opcexe,{|| PorPoOps()})

Menu_SC("stizv")
return
*}

