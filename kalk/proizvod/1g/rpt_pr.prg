#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/proizvod/1g/rpt_pr.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.2 $
 * $Log: rpt_pr.prg,v $
 * Revision 1.2  2002/06/21 13:07:28  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/proizvod/1g/rpt_pr.prg
 *  \brief Stampa kalkulacije PR
 */


/*! \fn StKalkPR()
 *  \brief Stampa kalkulacije PR
 */

function StKalkPR()
*{
local nCol1:=nCol2:=0,npom:=0

Private nPrevoz,nCarDaz,nZavTr,nBankTr,nSpedTr,nMarza,nMarza2
// iznosi troskova i marzi koji se izracunavaju u KTroskovi()

nStr:=0
cIdPartner:=IdPartner; cBrFaktP:=BrFaktP; dDatFaktP:=DatFaktP
dDatKurs:=DatKurs; cIdKonto:=IdKonto; cIdKonto2:=IdKonto2

P_COND
?? "KALK BR:",  cIdFirma+"-"+cIdVD+"-"+cBrDok,SPACE(2),P_TipDok(cIdVD,-2), SPACE(2),"Datum:",DatDok
@ prow(),125 SAY "Str:"+str(++nStr,3)
select PARTN; HSEEK cIdPartner

 m:="--- ------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------"
 ? m
 ? "*R *Konto  * ROBA     *          *  NCJ     * "+cRNT1+" * "+cRNT2+" * "+cRNT3+" * "+cRNT4+" * "+cRNT5+" * Cij.Kost *  Marza   * Prod.Cj * "
 ? "*BR*       * TARIFA   * KOLICINA *          *          *          *          *          *          *          *          *         *"
 ? "*  *       *          *          *    ä     *    ä     *    ä     *     ä    *    ä     *    ä     *    ä     *    ä     *   ä     *"
 ? m
 nTot:=nTot1:=nTot2:=nTot3:=nTot4:=nTot5:=nTot6:=nTot7:=nTot8:=nTot9:=nTotA:=0

select pripr

private cIdd:=idpartner+brfaktp+idkonto+idkonto2
do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD

  nT:=nT1:=nT2:=nT3:=nT4:=nT5:=nT6:=nT7:=nT8:=nT9:=nTA:=0
  cBrFaktP:=brfaktp; dDatFaktP:=datfaktp; cIdpartner:=idpartner
  do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD .and. idpartner+brfaktp+dtos(datfaktp)== cidpartner+cbrfaktp+dtos(ddatfaktp)
    // !!!!!!!!!!!!!!!
   if gmagacin<>"1"
    if idpartner+brfaktp+idkonto+idkonto2<>cidd
     set device to screen
     Beep(2)
     Msg("Unutar kalkulacije se pojavilo vise dokumenata !",6)
     set device to printer
    endif
   endif

    KTroskovi()

    select ROBA; HSEEK PRIPR->IdRoba
    select TARIFA; HSEEK PRIPR->IdTarifa
    select PRIPR

    if prow()>62+gPStranica; FF; @ prow(),125 SAY "Str:"+str(++nStr,3); endif


    if gKalo=="1"
        SKol:=Kolicina-GKolicina-GKolicin2
    else
        SKol:=Kolicina
    endif

    nU:=FCj*Kolicina
    if val(rbr)>900
      nU:=NC*Kolicina
    endif

    if gKalo=="1"
        nU1:=FCj2*(GKolicina+GKolicin2)
    else
        nU1:=NC*(GKolicina+GKolicin2)
    endif

    nU3:=nPrevoz*SKol
    nU4:=nBankTr*SKol
    nU5:=nSpedTr*SKol
    nU6:=nCarDaz*SKol
    nU7:=nZavTr* SKol
    nU8:=NC *    (Kolicina-Gkolicina-GKolicin2)
    nU9:=nMarza* (Kolicina-Gkolicina-GKolicin2)
    nUA:=VPC   * (Kolicina-Gkolicina-GKolicin2)

    if val(Rbr)>900
     nT+=nU; nT1+=nU1
     nT3+=nU3; nT4+=nU4; nT5+=nU5; nT6+=nU6
     nT7+=nU7; nT8+=nU8; nT9+=nU9; nTA+=nUA
    endif

    if rbr=="901"
     ?
     ? m
     ? "Rekapitulacija troskova - razduzenje konta:", idkonto2
     ? m

    endif
    @ prow()+1,0 SAY  Rbr PICTURE "999"
    if val(rbr)<900
      @  prow(),pcol()+1 SAY  idkonto
    else
      @  prow(),pcol()+1 SAY  space(7)
    endif
    @ prow(),11 SAY  "";?? trim(ROBA->naz),"(",ROBA->jmj,")"
    if gRokTr=="D"; ?? space(4),"Rok Tr.:",RokTr; endif
    @ prow()+1,11 SAY IdRoba
    @ prow(),pcol()+1 SAY Kolicina             PICTURE PicKol
    nCol1:=pcol()+1
    if val(rbr)>900
      @ prow(),pcol()+1 SAY nc                   PICTURE PicCDEM
    endif
    if val(rbr)<900
     @ prow(),pcol()+1 SAY fcj                   PICTURE PicCDEM
     @ prow(),pcol()+1 SAY nPrevoz/FCJ2*100      PICTURE PicProc
     @ prow(),pcol()+1 SAY nBankTr/FCJ2*100      PICTURE PicProc
     @ prow(),pcol()+1 SAY nSpedTr/FCJ2*100      PICTURE PicProc
     @ prow(),pcol()+1 SAY nCarDaz/FCJ2*100      PICTURE PicProc
     @ prow(),pcol()+1 SAY nZavTr/FCJ2*100       PICTURE PicProc
     @ prow(),pcol()+1 SAY NC                    PICTURE PicCDEM
     @ prow(),pcol()+1 SAY nMarza/NC*100         PICTURE PicProc
     @ prow(),pcol()+1 SAY VPC                   PICTURE PicCDEM
    endif

    if val(rbr)<900
     @ prow()+1,11 SAY IdTarifa
     @ prow(),nCol1    SAY space(len(PicCDEM))
     @ prow(),pcol()+1 SAY nPrevoz              PICTURE PicCDEM
     @ prow(),pcol()+1 SAY nBankTr              PICTURE PicCDEM
     @ prow(),pcol()+1 SAY nSpedTr              PICTURE PicCDEM
     @ prow(),pcol()+1 SAY nCarDaz              PICTURE PicCDEM
     @ prow(),pcol()+1 SAY nZavTr               PICTURE PicCDEM
     @ prow(),pcol()+1 SAY 0                    PICTURE PicDEM
     @ prow(),pcol()+1 SAY nMarza               PICTURE PicDEM
    endif

    @ prow()+1,nCol1   SAY nU          picture         PICDEM
    if val(rbr)<900
     @ prow(),pcol()+1  SAY nU3         picture         PICDEM
     @ prow(),pcol()+1  SAY nU4         picture         PICDEM
     @ prow(),pcol()+1  SAY nU5         picture         PICDEM
     @ prow(),pcol()+1  SAY nU6         picture         PICDEM
     @ prow(),pcol()+1  SAY nU7         picture         PICDEM
     @ prow(),pcol()+1  SAY nU8         picture         PICDEM
     @ prow(),pcol()+1  SAY nU9         picture         PICDEM
     @ prow(),pcol()+1  SAY nUA         picture         PICDEM
    endif
    skip
enddo

nTot+=nT; nTot1+=nT1; nTot2+=nT2; nTot3+=nT3; nTot4+=nT4
nTot5+=nT5; nTot6+=nT6; nTot7+=nT7; nTot8+=nT8; nTot9+=nT9; nTotA+=nTA

enddo

if prow()>61+gPStranica; FF; @ prow(),125 SAY "Str:"+str(++nStr,3); endif
? m
@ prow()+1,0        SAY "Ukupno:"
@ prow(),nCol1     SAY nTot          picture         PICDEM

? m
return
*}


