#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/razdb/1g/mnu_raz.prg,v $
 * $Author: sasa $ 
 * $Revision: 1.4 $
 * $Log: mnu_raz.prg,v $
 * Revision 1.4  2003/06/09 14:51:45  sasa
 * uvedena nova opcija generacije tops dokumenta na osnovu azuriranih kalk dokumenata
 *
 * Revision 1.3  2002/10/17 14:37:31  mirsad
 * nova opcija prenosa dokumenata: FAKT11->KALK42
 * dorada za Vindiju (sa rabatom u MP)
 *
 * Revision 1.2  2002/06/24 09:19:02  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/razdb/1g/mnu_raz.prg
 *  \brief Centralni meni opcija za prenos podataka KALK<->ostali moduli
 */


/*! \fn ModRazmjena()
 *  \brief Centralni meni opcija za prenos podataka KALK<->ostali moduli
 */

function ModRazmjena()
*{
private Opc:={}
private opcexe:={}
AADD(opc,"1. generisi FIN,FAKT dokumente (kontiraj) ")
AADD(opcexe,{|| Rekapk(.t.)})
AADD(opc,"2. iz FAKT generisi KALK dokumente")
AADD(opcexe, {|| Faktkalk()})
AADD(opc,"3. iz TOPS generisi KALK dokumente")
AADD(opcexe, {|| UzmiIzTOPSa()})
AADD(opc,"4. sifrarnik KALK prebaci u TOPS")
AADD(opcexe, {|| SifKalkTOPS()} )
AADD(opc,"5. iz KALK generisi TOPS dokumente")
AADD(opcexe, {|| Mnu_GenKaTOPS()} )
private Izbor:=1
Menu_SC("rmod")

CLOSERET

return
*}
