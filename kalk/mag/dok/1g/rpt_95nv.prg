#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/mag/dok/1g/rpt_95nv.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.2 $
 * $Log: rpt_95nv.prg,v $
 * Revision 1.2  2002/06/20 13:13:03  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/mag/dok/1g/rpt_95nv.prg
 *  \brief Stampa kalkulacije tipa 95, varijanta samo po nabavnim cijenama
 */


/*! \fn StKalk95_1()
 *  \brief Stampa kalkulacije tipa 95, varijanta samo po nabavnim cijenama
 */

function StKalk95_1()
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
m:="--- ----------- --------------------------- ---------- ----------- -----------"
? m
? "*R * Konto     * ARTIKAL                   * Kolicina *  NABAV.  *    NV     *"
? "*BR*           *                           *          *  CJENA   *           *"
? m
nTot4:=nTot5:=nTot6:=nTot7:=nTot8:=nTot9:=nTota:=ntotb:=ntotc:=nTotd:=0

private cIdd:=idpartner+brfaktp+idkonto+idkonto2
do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD


  nT4:=nT5:=nT8:=0
  cBrFaktP:=brfaktp; dDatFaktP:=datfaktp; cIdpartner:=idpartner
  do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD .and. idpartner+brfaktp+dtos(datfaktp)== cidpartner+cbrfaktp+dtos(ddatfaktp)

    if cIdVd $ "97" .and. tbanktr=="X"
      skip 1; loop
    endif

    select ROBA; HSEEK PRIPR->IdRoba
    select TARIFA; HSEEK PRIPR->IdTarifa
    select PRIPR
    KTroskovi()

    if prow()>62+gPStranica; FF; @ prow(),125 SAY "Str:"+str(++nStr,3); endif



    SKol:=Kolicina

    nT4+=  (nU4:=NC*Kolicina     )  // nv

    @ prow()+1,0 SAY  Rbr PICTURE "999"
    if idvd=="16"
     cNKonto:=idkonto
    else
     cNKonto:=idkonto2
    endif
    @ prow(),4 SAY  ""; ?? padr(cnkonto,11), idroba, trim(ROBA->naz)+"("+ROBA->jmj+")"
    if gRokTr=="D"; ?? space(4),"Rok Tr.:",RokTr; endif
    @ prow()+1,46 SAY Kolicina  PICTURE PicKol
    nC1:=pcol()+1
    @ prow(),pcol()+1   SAY NC                          PICTURE PicCDEM
    @ prow(),pcol()+1 SAY nU4  pict picdem

    skip
  enddo

  nTot4+=nT4; nTot5+=nT5; nTot8+=nT8
  ? m
  @ prow()+1,0        SAY "Ukupno za "; ?? cidpartner
  ? cBrFaktP,"/",dDatFaktp
  @ prow(),nc1      SAY 0  pict "@Z "+picdem
  @ prow(),pcol()+1 SAY nT4  pict picdem
  ? m

enddo

if prow()>61+gPStranica; FF; @ prow(),125 SAY "Str:"+str(++nStr,3); endif
? m
@ prow()+1,0        SAY "Ukupno:"
@ prow(),nc1      SAY 0  pict "@Z "+picdem
@ prow(),pcol()+1 SAY nTot4  pict picdem

? m
return
*}

