#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/mag/dok/1g/rpt_10nc.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.2 $
 * $Log: rpt_10nc.prg,v $
 * Revision 1.2  2002/06/20 13:13:03  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/mag/dok/1g/rpt_10nc.prg
 *  \brief Stampa kalkulacije 10 za vodjenje magacina po nabavnim cijenama
 */


/*! \fn StKalk10_1()
 *  \brief Stampa kalkulacije 10 - nabavne cijene
 */

function StKalk10_1()
*{
local nCol1:=nCol2:=0,npom:=0


Private nPrevoz,nCarDaz,nZavTr,nBankTr,nSpedTr,nMarza,nMarza2
// iznosi troskova i marzi koji se izracunavaju u KTroskovi()


nStr:=0
cIdPartner:=IdPartner; cBrFaktP:=BrFaktP; dDatFaktP:=DatFaktP
dDatKurs:=DatKurs; cIdKonto:=IdKonto; cIdKonto2:=IdKonto2

P_COND2
?? "KALK: KALKULACIJA BR:",  cIdFirma+"-"+cIdVD+"-"+cBrDok,SPACE(2),P_TipDok(cIdVD,-2), SPACE(2),"Datum:",DatDok
@ prow(),125 SAY "Str:"+str(++nStr,3)
select PARTN; HSEEK cIdPartner


 m:="--- ----------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------"
 ? m
 ? "*R * Konto     * ROBA     *          *  FCJ     * KASA-    * "+c10T1+" * "+c10T2+" * "+c10T3+" * "+c10T4+" * "+c10T5+" *   NC     "
 ? "*BR*           * TARIFA   * KOLICINA *          * SKONTO   *          *          *          *          *          *          "
 ? "*  *           *          *          *    ä     *   ä      *    ä     *    ä     *     ä    *    ä     *    ä     *    ä     "
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


    select ROBA; HSEEK PRIPR->IdRoba
    select TARIFA; HSEEK PRIPR->IdTarifa
    select PRIPR
    KTroskovi()

    if prow()>62+gPStranica; FF; @ prow(),125 SAY "Str:"+str(++nStr,3); endif


    if gKalo=="1"
        SKol:=Kolicina-GKolicina-GKolicin2
    else
        SKol:=Kolicina
    endif

    nT+=  (nU:=round(FCj*Kolicina,gZaokr))
    if gKalo=="1"
        nT1+= (nU1:=round(FCj2*(GKolicina+GKolicin2),gZaokr))
    else
        nT1+= (nU1:=round(NC*(GKolicina+GKolicin2),gZaokr))
    endif
    nT2+= (nU2:=round(-Rabat/100*FCJ*Kolicina,gZaokr))
    nT3+= (nU3:=round(nPrevoz*SKol,gZaokr))
    nT4+= (nU4:=round(nBankTr*SKol,gZaokr))
    nT5+= (nU5:=round(nSpedTr*SKol,gZaokr))
    nT6+= (nU6:=round(nCarDaz*SKol,gZaokr))
    nT7+= (nU7:=round(nZavTr* SKol,gZaokr))
    nT8+= (nU8:=round(NC *    (Kolicina-Gkolicina-GKolicin2),gZaokr) )
    nT9+= (nU9:=round(nMarza* (Kolicina-Gkolicina-GKolicin2),gZaokr) )
    nTA+= (nUA:=round(VPC   * (Kolicina-Gkolicina-GKolicin2),gZaokr) )

    @ prow()+1,0 SAY  Rbr PICTURE "999"
    @ prow(),pcol()+1 SAY  padr(idkonto,11)
    @ prow(),16 SAY  "";?? trim(ROBA->naz),"(",ROBA->jmj,")"
    if roba->(fieldpos("KATBR"))<>0
       ?? " KATBR:", roba->katbr
    endif
    if gRokTr=="D"; ?? space(4),"Rok Tr.:",RokTr; endif
    IF lPoNarudzbi
      IspisPoNar()
    ENDIF
    @ prow()+1,16 SAY IdRoba
    @ prow(),pcol()+1 SAY Kolicina             PICTURE PicKol
    nCol1:=pcol()+1
    @ prow(),pcol()+1 SAY fcj                   PICTURE PicCDEM
    @ prow(),pcol()+1 SAY -Rabat                PICTURE PicProc
    @ prow(),pcol()+1 SAY nPrevoz/FCJ2*100      PICTURE PicProc
    @ prow(),pcol()+1 SAY nBankTr/FCJ2*100      PICTURE PicProc
    @ prow(),pcol()+1 SAY nSpedTr/FCJ2*100      PICTURE PicProc
    @ prow(),pcol()+1 SAY nCarDaz/FCJ2*100      PICTURE PicProc
    @ prow(),pcol()+1 SAY nZavTr/FCJ2*100       PICTURE PicProc
    @ prow(),pcol()+1 SAY NC                    PICTURE PicCDEM

    @ prow()+1,16 SAY IdTarifa
    @ prow(),nCol1    SAY space(len(PicCDEM))
    @ prow(),pcol()+1 SAY -Rabat/100*FCJ       PICTURE PicCDEM
    @ prow(),pcol()+1 SAY nPrevoz              PICTURE PicCDEM
    @ prow(),pcol()+1 SAY nBankTr              PICTURE PicCDEM
    @ prow(),pcol()+1 SAY nSpedTr              PICTURE PicCDEM
    @ prow(),pcol()+1 SAY nCarDaz              PICTURE PicCDEM
    @ prow(),pcol()+1 SAY nZavTr               PICTURE PicCDEM
    @ prow(),pcol()+1 SAY 0                    PICTURE PicDEM

    @ prow()+1,nCol1   SAY nU          picture         PICDEM
    //@ prow(),pcol()+1  SAY nU1         picture         PICDEM
    @ prow(),pcol()+1  SAY nU2         picture         PICDEM
    @ prow(),pcol()+1  SAY nU3         picture         PICDEM
    @ prow(),pcol()+1  SAY nU4         picture         PICDEM
    @ prow(),pcol()+1  SAY nU5         picture         PICDEM
    @ prow(),pcol()+1  SAY nU6         picture         PICDEM
    @ prow(),pcol()+1  SAY nU7         picture         PICDEM
    @ prow(),pcol()+1  SAY nU8         picture         PICDEM

    skip
enddo

? m
@ prow()+1,0        SAY "Ukupno za "; ?? cidpartner
? cBrFaktP,"/",dDatFaktp
@ prow(),nCol1     SAY nT          picture         PICDEM
//@ prow(),pcol()+1  SAY nT1         picture         PICDEM
@ prow(),pcol()+1  SAY nT2         picture         PICDEM
@ prow(),pcol()+1  SAY nT3         picture         PICDEM
@ prow(),pcol()+1  SAY nT4         picture         PICDEM
@ prow(),pcol()+1  SAY nT5         picture         PICDEM
@ prow(),pcol()+1  SAY nT6         picture         PICDEM
@ prow(),pcol()+1  SAY nT7         picture         PICDEM
@ prow(),pcol()+1  SAY nT8         picture         PICDEM

? m
nTot+=nT
nTot1+=nT1
nTot2+=nT2
nTot3+=nT3
nTot4+=nT4
nTot5+=nT5
nTot6+=nT6
nTot7+=nT7
nTot8+=nT8
nTot9+=nT9
nTotA+=nTA

enddo

if prow()>61+gPStranica; FF; @ prow(),125 SAY "Str:"+str(++nStr,3); endif
? m
@ prow()+1,0        SAY "Ukupno:"
@ prow(),nCol1     SAY nTot          picture         PICDEM
//@ prow(),pcol()+1  SAY nTot1         picture         PICDEM
@ prow(),pcol()+1  SAY nTot2         picture         PICDEM
@ prow(),pcol()+1  SAY nTot3         picture         PICDEM
@ prow(),pcol()+1  SAY nTot4         picture         PICDEM
@ prow(),pcol()+1  SAY nTot5         picture         PICDEM
@ prow(),pcol()+1  SAY nTot6         picture         PICDEM
@ prow(),pcol()+1  SAY nTot7         picture         PICDEM
@ prow(),pcol()+1  SAY nTot8         picture         PICDEM
? m
return
*}



