#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/razdb/1g/mnu_raz.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.3 $
 * $Log: mnu_raz.prg,v $
 * Revision 1.3  2003/04/24 06:59:15  mirsad
 * preuzimanje TOPS->FAKT
 *
 * Revision 1.2  2003/04/12 07:01:13  mirsad
 * omogucen prenos KALK10,11,81->FAKT poput KALK->TOPS za udaljene lokacije
 *
 * Revision 1.1  2002/07/03 12:24:37  sasa
 * uvodjenje novog prg fajla
 *
 * Revision 
 * 
 *
 *
 */
 

/*! \file fmk/fakt/razdb/1g/mnu_raz.prg
 *  \brief Centralni meni opcija za prenos podataka FAKT<->ostali moduli
 */


/*! \fn ModRazmjena()
 *  \brief Centralni meni opcija za prenos podataka FAKT<->ostali moduli
 */

function ModRazmjena()
*{
private Opc:={}
private opcexe:={}

AADD(opc,"1. kalk <-> fakt      ")
AADD(opcexe,{|| KaFak()})
AADD(opc,"2. kalk->fakt (modem)")
AADD(opcexe,{|| PovModem()})

if IsTigra()
	AADD(opc,"3. preuzmi tops->fakt ")
	AADD(opcexe,{|| TopsFakt()})
endif

private Izbor:=1
Menu_SC("rpod")

CLOSERET

return
*}
