#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/prod/dok/1g/rpt_11nc.prg,v $
 * $Author: mirsadsubasic $ 
 * $Revision: 1.5 $
 * $Log: rpt_11nc.prg,v $
 * Revision 1.5  2003/09/29 13:26:56  mirsadsubasic
 * sredjivanje koda za poreze u ugostiteljstvu
 *
 * Revision 1.4  2003/09/20 07:37:07  mirsad
 * sredj.koda za poreze u MP
 *
 * Revision 1.3  2002/07/19 13:57:23  mirsad
 * lPrikPRUC ubacio kao globalnu varijablu
 *
 * Revision 1.2  2002/06/21 07:49:36  mirsad
 * no message
 *
 *
 */
 

/*! \file fmk/kalk/prod/dok/1g/rpt_11nc.prg
 *  \brief Stampa kalkulacije 11 / magacin po nabavnim cjenama
 */


/*! \fn StKalk11_1()
 *  \brief Stampa kalkulacije 11 / magacin po nabavnim cjenama
 */

function StKalk11_1()
*{
local nCol0:=nCol1:=nCol2:=0,npom:=0

Private nMarza,nMarza2

nStr:=0
cIdPartner:=IdPartner; cBrFaktP:=BrFaktP; dDatFaktP:=DatFaktP
dDatKurs:=DatKurs; cIdKonto:=IdKonto; cIdKonto2:=IdKonto2

P_COND
?? "KALK BR:",  cIdFirma+"-"+cIdVD+"-"+cBrDok,SPACE(2),P_TipDok(cIdVD,-2), SPACE(2),"Datum:",DatDok
@ prow(),123 SAY "Str:"+str(++nStr,3)
select PARTN; HSEEK cIdPartner

?  "OTPREMNICA Broj:",cBrFaktP,"Datum:",dDatFaktP

select KONTO; HSEEK cIdKonto
?  "KONTO zaduzuje :",cIdKonto,"-",naz
HSEEK cIdKonto2
?  "KONTO razduzuje:",cIdKonto2,"-",naz

select PRIPR

m:="--- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------"
IF lPrikPRUC
  //m += " ----------"
  ? m
  ? "*R * ROBA     * Kolicina *  NAB.CJ  *  NAB.CJ  *  MARZA   *  MARZA   * POREZ NA *    MPC   *   PPP %  *   PPP    * MPC     *"
  ? "*BR*          *          *   U VP   *   U MP   *   VP     *    MP    *  MARZU   *          *   PPU %  *   PPU    * SA Por  *"
  ? "*  *          *          *          *          *          *          *    MP    *          *          *          *         *"
ELSE
  ? m
  ? "*R * ROBA     * Kolicina *  NAB.CJ  *  TROSAK  *  NAB.CJ  *  MARZA   *  MARZA   *    MPC   *   PPP %  *   PPP    * MPC     *"
  ? "*BR*          *          *   U VP   *   U MP   *   U MP   *   VP     *    MP    *          *   PPU %  *   PPU    * SA Por  *"
  ? "*  *          *          *          *          *          *          *          *          *          *          *         *"
ENDIF
? m
nTot1:=nTot1b:=nTot2:=nTot3:=nTot4:=nTot4B:=nTot5:=nTot6:=nTot7:=0
nTot4c:=0

private aPorezi
aPorezi:={}

private cIdd:=idpartner+brfaktp+idkonto+idkonto2
do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD

    // !!!!!!!!!!!!!!!
    if idpartner+brfaktp+idkonto+idkonto2<>cidd
     set device to screen
     Beep(2)
     Msg("Unutar kalkulacije se pojavilo vise dokumenata !",6)
     set device to printer
    endif

    scatter()  // formiraj varijable _....
    Marza2(); nMarza:=_marza   // izracunaj nMarza,nMarza2

    select ROBA; HSEEK PRIPR->IdRoba
    select TARIFA; HSEEK PRIPR->IdTarifa

    select PRIPR
    Tarifa(field->pkonto,field->idroba,@aPorezi)
    aIPor:=RacPorezeMP(aPorezi,field->mpc,field->mpcSaPP,field->nc)

    nPor1:=aIPor[1]
    if lPrikPRUC
      nPRUC:=aIPor[2]
      nPor2:=0
      nMarza2:=nMarza2-nPRUC
    else
      nPor2:=aIPor[2]
    endif

    if prow()>62+gPStranica; FF; @ prow(),123 SAY "Str:"+str(++nStr,3); endif

    nTot1+=  (nU1:= FCJ*Kolicina   )
    nTot2+=  (nU2:= Prevoz*Kolicina   )
    nTot3+=  (nU3:= NC*kolicina )
    nTot4+=  (nU4:= nmarza*Kolicina )
    nTot4b+=  (nU4b:= nmarza2*Kolicina )
    IF lPrikPRUC
      nTot4c+= (nU4c:=nPRUC*Kolicina)
    ENDIF
    nTot5+=  (nU5:= MPC*Kolicina )
    nTot6+=  (nU6:=(nPor1+nPor2)*Kolicina)
    nTot7+=  (nU7:= MPcSaPP*Kolicina )

    @ prow()+1,0 SAY  Rbr PICTURE "999"
    @ prow(),4 SAY  ""; ?? trim(ROBA->naz),"(",ROBA->jmj,")"
    if gRokTr=="D"; ?? space(4),"Rok Tr.:",RokTr; endif
    IF lPoNarudzbi
      IspisPoNar()
    ENDIF
    @ prow()+1,4 SAY IdRoba
    @ prow(),pcol()+1 SAY Kolicina             PICTURE PicKol

    nCol0:=pcol()+1
    @ prow(),pcol()+1 SAY FCJ                  PICTURE PicCDEM
    IF !lPrikPRUC
      @ prow(),pcol()+1 SAY Prevoz               PICTURE PicCDEM
    ENDIF
    @ prow(),pcol()+1 SAY NC                   PICTURE PicCDEM
    @ prow(),pcol()+1 SAY nMarza              PICTURE PicCDEM
    @ prow(),pcol()+1 SAY nMarza2              PICTURE PicCDEM
    IF lPrikPRUC
      @ prow(),pcol()+1 SAY aPorezi[POR_PRUCMP] PICTURE PicProc
    ENDIF
    @ prow(),pcol()+1 SAY MPC                  PICTURE PicCDEM
    nCol1:=pcol()+1
    @ prow(),pcol()+1 SAY aPorezi[POR_PPP]     PICTURE PicProc
    @ prow(),pcol()+1 SAY nPor1                PICTURE PiccDEM
    @ prow(),pcol()+1 SAY MPCSAPP              PICTURE PicCDEM

    @ prow()+1,nCol0    SAY  fcj*kolicina      picture picdem
    IF !lPrikPRUC
      @ prow(),  pcol()+1 SAY  prevoz*kolicina      picture picdem
    ENDIF
    @ prow(),  pcol()+1 SAY  nc*kolicina      picture picdem
    @ prow(),  pcol()+1 SAY  nmarza*kolicina      picture picdem
    @ prow(),  pcol()+1 SAY  nmarza2*kolicina      picture picdem
    IF lPrikPRUC
      @ prow(),pcol()+1 SAY nU4c                PICTURE PicCDEM
    ENDIF
    @ prow(),  pcol()+1 SAY  mpc*kolicina      picture picdem
    if lPrikPRUC
    	@ prow(),nCol1 SAY aPorezi[POR_PPU]  picture picproc
    else
    	@ prow(),nCol1 SAY PrPPUMP()  picture picproc
    endif
    @ prow(),  pcol()+1 SAY  nPor2             picture piccdem

    skip 1

enddo

if prow()>61+gPStranica; FF; @ prow(),123 SAY "Str:"+str(++nStr,3); endif
? m
@ prow()+1,0        SAY "Ukupno:"
@ prow(),nCol0      SAY  nTot1        picture       PicDEM
IF !lPrikPRUC
  @ prow(),pcol()+1   SAY  nTot2        picture       PicDEM
ENDIF
@ prow(),pcol()+1   SAY  nTot3        picture       PicDEM
@ prow(),pcol()+1   SAY  nTot4        picture       PicDEM
@ prow(),pcol()+1   SAY  nTot4b        picture       PicDEM
IF lPrikPRUC
  @ prow(),pcol()+1  SAY nTot4c        picture         PICDEM
ENDIF
@ prow(),pcol()+1   SAY  nTot5        picture       PicDEM
@ prow(),pcol()+1   SAY  space(len(picproc))
@ prow(),pcol()+1   SAY  nTot6        picture        PicDEM
@ prow(),pcol()+1   SAY  nTot7        picture        PicDEM
? m

Rektarife()

? "RUC:";  @ prow(),pcol()+1 SAY nTot6 pict picdem
? m

return
*}

