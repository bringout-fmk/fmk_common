#include "\cl\sigma\fmk\kalk\kalk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/specif/planika/1g/rpt_all.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.1 $
 * $Log: rpt_all.prg,v $
 * Revision 1.1  2002/06/25 15:08:47  ernad
 *
 *
 * prikaz parovno - Planika
 *
 *
 */
 
function PrintParovno(nKolUlaz, nKolIzlaz)
*{
?
?
? REPLICATE("=",80)
? "PAROVNO:"
@ prow(),pcol()+1  SAY  "Ulaz:"
@ prow(),pcol()+1  SAY  nKolUlaz  PICT "9,999,999"
@ prow(),pcol()+1  SAY  "Izlaz:"
@ prow(),pcol()+1  SAY  nKolIzlaz PICT "9,999,999"
@ prow(),pcol()+1  SAY  "Stanje:"
@ prow(),pcol()+1  SAY  nKolUlaz-nKolIzlaz PICT "9,999,999"
? REPLICATE("=",80)

return
*}
