#include "\cl\sigma\fmk\kalk\kalk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/specif/planika/1g/mnu_sif.prg,v $
 * $Author: ernadhusremovic $ 
 * $Revision: 1.2 $
 * $Log: mnu_sif.prg,v $
 * Revision 1.2  2003/11/04 02:13:29  ernadhusremovic
 * Planika Kranj - Robno poslovanje
 *
 * Revision 1.1  2002/07/12 12:13:21  ernad
 *
 *
 * sifrarnici - planika
 *
 *
 */
 
function KaSifPlanika()
*{
private opc:={}
private opcexe:={}
private Izbor

O_K1
O_OBJEKTI
O_RVRSTA

AADD(opc,"1. k1 - grupe dobavljaca            ")
AADD(opcexe, {|| P_K1()})
AADD(opc,"2. objekti (prodavnice i magacini")
AADD(opcexe, {|| P_Objekti()})
AADD(opc,"3. planika vrste artikala")
AADD(opcexe, {|| P_RVrsta()})
AADD(opc,"4. popuni planika - polje vrsta")
AADD(opcexe, {|| PlFill_Vrsta()})
AADD(opc,"5. popuni planika - polje sezona")
AADD(opcexe, {|| PlFill_Sezona()})

Izbor:=1
Menu_SC("spla")

return
*}
