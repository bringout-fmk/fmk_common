#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/mag/dok/1g/rpt_95sk.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.2 $
 * $Log: rpt_95sk.prg,v $
 * Revision 1.2  2002/06/20 13:13:03  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/mag/dok/1g/rpt_95sk.prg
 *  \brief Stampa kalkulacije tipa 95, varijanta samo kolicine (bez cijena)
 */


/*! \fn StKalk95_sk()
 *  \brief Stampa kalkulacije tipa 95, varijanta samo kolicine (bez cijena)
 */

function StKalk95_sk()
*{
local nCol1:=nCol2:=0,npom:=0

Private nPrevoz,nCarDaz,nZavTr,nBankTr,nSpedTr,nMarza,nMarza2

nStr:=0
cIdPartner:=IdPartner; cBrFaktP:=BrFaktP; dDatFaktP:=DatFaktP
dDatKurs:=DatKurs; cIdKonto:=IdKonto; cIdKonto2:=IdKonto2

P_12CPI
?? "KALK BR:",  cIdFirma+"-"+cIdVD+"-"+cBrDok,"  Datum:",DatDok
@ prow(),76 SAY "Str:"+str(++nStr,3)

if cidvd=="16"  // doprema robe
 select konto; hseek cidkonto
 ?
 ? "PRIJEM U MAGACIN (INTERNI DOKUMENT)"
 ?
elseif cidvd=="96"
 ?
 ? "OTPREMA IZ MAGACINA (INTERNI DOKUMENT):"
 ?
elseif cidvd=="97"
 ?
 ? "PREBACIVANJE IZ MAGACINA U MAGACIN (INTERNI DOKUMENT):"
 ?
elseif cidvd=="95"
 ?
 ? "OTPIS MAGACIN"
 ?
endif

select PRIPR
m:="--- ----------- ---------- ---------------------------------------- ---- -----------"
? m
? "*R.*           * SIFRA    *                                        * J. *"
? "*BR*   KONTO   * ARTIKLA  *             NAZIV ARTIKLA              * MJ.*  KOLICINA"
? m

private cIdd:=idpartner+brfaktp+idkonto+idkonto2
do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD

  cBrFaktP:=brfaktp; dDatFaktP:=datfaktp; cIdpartner:=idpartner
  do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD .and. idpartner+brfaktp+dtos(datfaktp)== cidpartner+cbrfaktp+dtos(ddatfaktp)

    if cIdVd $ "97" .and. tbanktr=="X"
      skip 1; loop
    endif

    select ROBA; HSEEK PRIPR->IdRoba
    select TARIFA; HSEEK PRIPR->IdTarifa
    select PRIPR

    if prow()>62+gPStranica; FF; @ prow(),125 SAY "Str:"+str(++nStr,3); endif

    SKol:=Kolicina

    if idvd=="16"
     cNKonto:=idkonto
    else
     cNKonto:=idkonto2
    endif

    @ prow()+1,0 SAY  Rbr PICTURE "999"
    @ prow(),pcol()+1 SAY  padr(cNKonto,11)
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
