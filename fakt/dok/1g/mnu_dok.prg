#include "\cl\sigma\fmk\fakt\fakt.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/dok/1g/mnu_dok.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.3 $
 * $Log: mnu_dok.prg,v $
 * Revision 1.3  2004/05/11 09:00:31  sasavranic
 * Dodao stampu narudzbenice kroz Fmk.NET
 *
 * Revision 1.2  2002/09/26 12:47:05  mirsad
 * no message
 *
 * Revision 1.1  2002/07/03 12:21:12  sasa
 * uvodjenje novog prg fajla
 *
 * Revision 
 * no message
 *
 *
 */

/*! \file fmk/fakt/dok/1g/mnu_dok.prg
 *  \brief Meni opcija za stampu i pregled dokumenata
 */

/*! \fn MBrDoks()
 *  \brief Meni opcija za stampu i pregled dokumenata
 */

function MBrDoks()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. stampa azuriranog dokumenta              ")
AADD(opcexe, {|| StAzFakt()})
AADD(opc,"2. stampa liste dokumenata")
AADD(opcexe, {|| StDatn()})

Menu_SC("stfak")
CLOSERET
return .f.
*}

/*! \fn MAzurDoks()
 *  \brief Ostale operacije nad podacima
 */
 
function MAzurDoks()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. povrat dokumenta u pripremu       ")
AADD(opcexe,{|| Povrat()})
AADD(opc,"2. povrat dokumenata prema kriteriju ")
AADD(opcexe,{|| if(SigmaSif(),PovSvi(),nil)})
AADD(opc,"3. prekid rezervacije")
AADD(opcexe,{|| Povrat(.t.)})
AADD(opc,"4. evidentiranje uplata")
AADD(opcexe,{|| Uplate()})
AADD(opc,"5. lista salda kupaca")
AADD(opcexe,{|| SaldaKupaca()})
AADD(opc,"6. pocetno stanje za evidenciju uplata")
AADD(opcexe,{|| GPSUplata()})
AADD(opc,"7. stampa narudzbenice")
AADD(opcexe,{|| Mnu_Narudzbenica()})

Menu_SC("ostop")
return .f.
*}
