#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/mag/dok/1g/rpt_10sk.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.2 $
 * $Log: rpt_10sk.prg,v $
 * Revision 1.2  2002/06/20 13:13:03  mirsad
 * dokumentovanje
 *
 *
 */
 


/*! \file fmk/kalk/mag/dok/1g/rpt_10sk.prg
 *  \brief Stampa kalkulacije 10 - samo kolicine
 */


/*! \fn StKalk10_sk()
 *  \brief Stampa kalkulacije 10 - samo kolicine
 */

function StKalk10_sk()
*{
local nCol1:=nCol2:=0,npom:=0

nStr:=0
cIdPartner:=IdPartner; cBrFaktP:=BrFaktP; dDatFaktP:=DatFaktP
dDatKurs:=DatKurs; cIdKonto:=IdKonto; cIdKonto2:=IdKonto2

P_12CPI
?? "KALK: KALKULACIJA BR:",  cIdFirma+"-"+cIdVD+"-"+cBrDok,SPACE(2),P_TipDok(cIdVD,-2), SPACE(2),"Datum:",DatDok
@ prow(),125 SAY "Str:"+str(++nStr,3)
select PARTN; HSEEK cIdPartner

m:="--- ----------- ---------- ---------------------------------------- ---- -----------"
 ? m
 ? "*R.*           * SIFRA    *                                        * J. *"
 ? "*BR*   KONTO   * ARTIKLA  *             NAZIV ARTIKLA              * MJ.*  KOLICINA"
 ? m

select pripr

private cIdd:=idpartner+brfaktp+idkonto+idkonto2
do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD

  cBrFaktP:=brfaktp; dDatFaktP:=datfaktp; cIdpartner:=idpartner
  do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD .and. idpartner+brfaktp+dtos(datfaktp)== cidpartner+cbrfaktp+dtos(ddatfaktp)

    select ROBA; HSEEK PRIPR->IdRoba
    select TARIFA; HSEEK PRIPR->IdTarifa
    select PRIPR

    if prow()>62+gPStranica; FF; @ prow(),125 SAY "Str:"+str(++nStr,3); endif

    @ prow()+1,0 SAY  Rbr PICTURE "999"
    @ prow(),pcol()+1 SAY  padr(idkonto,11)
    @ prow(),pcol()+1 SAY  IdRoba
    @ prow(),pcol()+1 SAY  ROBA->naz
    @ prow(),pcol()+1 SAY  ROBA->jmj
    @ prow(),pcol()+2 SAY  Kolicina         PICTURE PicKol

    skip
enddo

? m

enddo

? m

return (nil)
*}


