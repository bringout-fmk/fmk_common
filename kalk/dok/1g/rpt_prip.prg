#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/dok/1g/rpt_prip.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.3 $
 * $Log: rpt_prip.prg,v $
 * Revision 1.3  2002/06/26 17:53:45  ernad
 *
 *
 * ciscenje, inventura magacina
 *
 * Revision 1.2  2002/06/19 13:57:53  mirsad
 * no message
 *
 *
 */
 

/*! \file fmk/kalk/dok/1g/rpt_prip.prg
 *  \brief Stampa liste dokumenata koji se nalaze u pripremi
 */


/*! \fn StPripr()
 *  \brief Stampa liste dokumenata koji se nalaze u pripremi
 */

function StPripr()
*{
m:="-------------- -------- ----------"
O_PRIPR

START PRINT CRET

?? m
? "   Dokument     Datum  Broj stavki"
? m
do while !eof()
  cIdFirma:=IdFirma; cIdVd:=idvd; cBrDok:=BrDok
  dDatDok:=datdok
  nStavki:=0
  do while !eof() .and. cIdFirma==idfirma .and. cIdVd==idvd .and. cbrdok==brdok
    ++nStavki
    skip
  enddo
  ? cIdFirma+"-"+cIdVd+"-"+cBrDok, dDatDok, STR(nStavki,4), space(2), "__"
enddo
? m
END PRINT
closeret
return
*}

