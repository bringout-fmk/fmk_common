#include "\cl\sigma\fmk\fin\fin.ch"
/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fin/razoff/1g/mnu_off.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.2 $
 * $Log: mnu_off.prg,v $
 * Revision 1.2  2004/01/13 19:07:56  sasavranic
 * appsrv konverzija
 *
 *
 */


/*! \file fmk/fin/razoff/1g/mnu_off.prg
 *  \brief Menij prenosa podataka
 */
 

/*! \fn MnuUdaljeneLokacije()
 *  \brief Menij prenosa udaljenih lokacija
 */

function MnuUdaljeneLokacije()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. fin <-> fin (diskete,modem)        ")
AADD(opcexe, {|| FinDisk()})

Menu_SC("rof")

return
*}

