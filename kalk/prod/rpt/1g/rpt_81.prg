#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/prod/rpt/1g/rpt_81.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.8 $
 * $Log: rpt_81.prg,v $
 * Revision 1.8  2003/11/22 09:05:05  sasavranic
 * ispravljen bug pri stampi 81-ce varijanta prenos za TOPS
 *
 * Revision 1.7  2003/11/20 09:24:06  sasavranic
 * no message
 *
 * Revision 1.6  2003/09/29 13:26:56  mirsadsubasic
 * sredjivanje koda za poreze u ugostiteljstvu
 *
 * Revision 1.5  2003/09/20 07:37:07  mirsad
 * sredj.koda za poreze u MP
 *
 * Revision 1.4  2003/09/08 08:41:43  ernad
 * porezi u ugostiteljstvu
 *
 * Revision 1.3  2002/07/19 13:59:27  mirsad
 * lPrikPRUC ubacio kao globalnu varijablu
 *
 * Revision 1.2  2002/06/21 12:12:43  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/prod/rpt/1g/rpt_81.prg
 *  \brief Stampa kalkulacije 81 - direktno zaduzenje prodavnice
 */


/*! \fn StKalk81(fzatops)
 *  \brief Stampa kalkulacije 81 - direktno zaduzenje prodavnice
 *  \param fzatops -
 */

function StKalk81(fzatops)
*{
local nCol1:=nCol2:=0,npom:=0

Private nPrevoz,nCarDaz,nZavTr,nBankTr,nSpedTr,nMarza,nMarza2,nPRUC,aPorezi
nMarza:=nMarza2:=nPRUC:=0
aPorezi:={}
// iznosi troskova i marzi koji se izracunavaju u KTroskovi()

nStr:=0
cIdPartner:=IdPartner; cBrFaktP:=BrFaktP; dDatFaktP:=DatFaktP
dDatKurs:=DatKurs; cIdKonto:=IdKonto; cIdKonto2:=IdKonto2

if fzaTops==NIL
 fzaTops:=.f.
endif

P_COND2
?? "KALK: KALKULACIJA BR:",  cIdFirma+"-"+cIdVD+"-"+cBrDok,SPACE(2),P_TipDok(cIdVD,-2), SPACE(2),"Datum:",DatDok
@ prow(),125 SAY "Str:"+str(++nStr,3)
select PARTN; HSEEK cIdPartner

?  "DOBAVLJAC:",cIdPartner,"-",naz,SPACE(5),"DOKUMENT Broj:",cBrFaktP,"Datum:",dDatFaktP

select KONTO; HSEEK cIdKonto
?  "KONTO zaduzuje :",cIdKonto,"-",naz

if !fZaTops

 m:="--- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------"

 IF lPrikPRUC
   m += " ----------"
   ? m
   ? "*R * ROBA     *  FCJ     * TRKALO   * KASA-    * "+c10T1+" * "+c10T2+" * "+c10T3+" * "+c10T4+" * "+c10T5+" *   NC     * MARZA.   * POREZ NA *   MPC    * MPCSaPP *"
   ? "*BR* TARIFA   *  KOLICINA* OST.KALO * SKONTO   *          *          *          *          *          *          *          *   MARZU  *          *         *"
   ? "*  *          *          *          *          *          *          *          *          *          *          *          *          *          *         *"
 ELSE
   ? m
   ? "*R * ROBA     *  FCJ     * TRKALO   * KASA-    * "+c10T1+" * "+c10T2+" * "+c10T3+" * "+c10T4+" * "+c10T5+" *   NC     * MARZA.   *   MPC    * MPCSaPP *"
   ? "*BR* TARIFA   *  KOLICINA* OST.KALO * SKONTO   *          *          *          *          *          *          *          *          *         *"
   ? "*  *          *          *          *          *          *          *          *          *          *          *          *          *         *"
 ENDIF
 ? m

else

 m:="--- ---------- ---------- ---------- ----------"

 ? m
 ? "*R * ROBA     * Kolicina *   MPC    * MPCSaPP *"
 ? "*BR* TARIFA   *          *          *         *"
 ? "*  *          *          *          *         *"
 ? m

endif

nTot:=nTot1:=nTot2:=nTot3:=nTot4:=nTot5:=nTot6:=nTot7:=nTot8:=nTot9:=nTotA:=nTotb:=0
nTot9a:=0

select pripr

private cIdd:=idpartner+brfaktp+idkonto+idkonto2
do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD

    if idpartner+brfaktp+idkonto+idkonto2<>cidd
     set device to screen
     Beep(2)
     Msg("Unutar kalkulacije se pojavilo vise dokumenata !",6)
     set device to printer
    endif

    KTroskovi()

    select ROBA; HSEEK PRIPR->IdRoba
    select TARIFA; HSEEK PRIPR->IdTarifa

    select PRIPR
    
    altd()	
    
    Tarifa(field->pkonto,field->idRoba,@aPorezi)
    aIPor:=RacPorezeMP(aPorezi,field->mpc,field->mpcSaPP,field->nc)

    IF lPrikPRUC
      nPRUC:=aIPor[2]
      nMarza2:=nMarza2-nPRUC
    ENDIF

    if prow()>62+gPStranica; FF; @ prow(),125 SAY "Str:"+str(++nStr,3); endif

    if gKalo=="1"
        SKol:=Kolicina-GKolicina-GKolicin2
    else
        SKol:=Kolicina
    endif

    nTot+=  (nU:=FCj*Kolicina)
    if gKalo=="1"
        nTot1+= (nU1:=FCj2*(GKolicina+GKolicin2))
    else
        nTot1+= (nU1:=NC*(GKolicina+GKolicin2))
    endif
    nTot2+= (nU2:=-Rabat/100*FCJ*Kolicina)
    nTot3+= (nU3:=nPrevoz*SKol)
    nTot4+= (nU4:=nBankTr*SKol)
    nTot5+= (nU5:=nSpedTr*SKol)
    nTot6+= (nU6:=nCarDaz*SKol)
    nTot7+= (nU7:=nZavTr* SKol)
    nTot8+= (nU8:=NC *    (Kolicina-Gkolicina-GKolicin2) )
    nTot9+= (nU9:=nMarza2* (Kolicina-Gkolicina-GKolicin2) )
    IF lPrikPRUC
      nTot9a+= (nU9a:=nPRUC* (Kolicina-Gkolicina-GKolicin2) )
    ENDIF
    nTotA+= (nUA:=MPC   * (Kolicina-Gkolicina-GKolicin2) )
    nTotB+= (nUB:=MPCSAPP* (Kolicina-Gkolicina-GKolicin2) )

    @ prow()+1,0 SAY  Rbr PICTURE "999"
    @ prow(),4 SAY  ""; ?? trim(ROBA->naz),"(",ROBA->jmj,")"
    if gRokTr=="D"; ?? space(4),"Rok Tr.:",RokTr; endif
    IF lPoNarudzbi
      IspisPoNar()
    ENDIF
    @ prow()+1,4 SAY IdRoba
    nCol1:=pcol()+1
    if !fZaTops
     @ prow(),pcol()+1 SAY FCJ                   PICTURE PicCDEM
     @ prow(),pcol()+1 SAY GKolicina             PICTURE PicKol
     @ prow(),pcol()+1 SAY -Rabat                PICTURE PicProc
     @ prow(),pcol()+1 SAY nPrevoz/FCJ2*100      PICTURE PicProc
     @ prow(),pcol()+1 SAY nBankTr/FCJ2*100      PICTURE PicProc
     @ prow(),pcol()+1 SAY nSpedTr/FCJ2*100      PICTURE PicProc
     @ prow(),pcol()+1 SAY nCarDaz/FCJ2*100      PICTURE PicProc
     @ prow(),pcol()+1 SAY nZavTr/FCJ2*100       PICTURE PicProc
     @ prow(),pcol()+1 SAY NC                    PICTURE PicCDEM
     @ prow(),pcol()+1 SAY nMarza2/NC*100        PICTURE PicProc
     IF lPrikPRUC
       @ prow(),pcol()+1 SAY aPorezi[POR_PRUCMP] PICTURE PicProc
     ENDIF
    else
     @ prow(),pcol()+1 SAY Kolicina             PICTURE PicCDEM
    endif
    @ prow(),pcol()+1 SAY MPC                   PICTURE PicCDEM
    @ prow(),pcol()+1 SAY MPCSaPP               PICTURE PicCDEM

    @ prow()+1,4 SAY IdTarifa
    if !fzatops
     @ prow(),nCol1    SAY Kolicina             PICTURE PicCDEM
     @ prow(),pcol()+1 SAY GKolicin2            PICTURE PicKol
     @ prow(),pcol()+1 SAY -Rabat/100*FCJ       PICTURE PicCDEM
     @ prow(),pcol()+1 SAY nPrevoz              PICTURE PicCDEM
     @ prow(),pcol()+1 SAY nBankTr              PICTURE PicCDEM
     @ prow(),pcol()+1 SAY nSpedTr              PICTURE PicCDEM
     @ prow(),pcol()+1 SAY nCarDaz              PICTURE PicCDEM
     @ prow(),pcol()+1 SAY nZavTr               PICTURE PicCDEM
     @ prow(),pcol()+1 SAY space(len(picdem))
     @ prow(),pcol()+1 SAY nMarza2              PICTURE PicCDEM
     IF lPrikPRUC
       @ prow(),pcol()+1 SAY nPRUC                PICTURE PicCDEM
     ENDIF
    endif

    if !fzatops
     @ prow()+1,nCol1   SAY nU          picture         PICDEM
     @ prow(),pcol()+1  SAY nU1         picture         PICDEM
     @ prow(),pcol()+1  SAY nU2         picture         PICDEM
     @ prow(),pcol()+1  SAY nU3         picture         PICDEM
     @ prow(),pcol()+1  SAY nU4         picture         PICDEM
     @ prow(),pcol()+1  SAY nU5         picture         PICDEM
     @ prow(),pcol()+1  SAY nU6         picture         PICDEM
     @ prow(),pcol()+1  SAY nU7         picture         PICDEM
     @ prow(),pcol()+1  SAY nU8         picture         PICDEM
     @ prow(),pcol()+1  SAY nU9         picture         PICDEM
     IF lPrikPRUC
       @ prow(),pcol()+1  SAY nU9a        picture         PICDEM
     ENDIF
    else
     @ prow()+1,nCol1-1   SAY space(len(picdem))
    endif
    @ prow(),pcol()+1  SAY nUA         picture         PICDEM
    @ prow(),pcol()+1  SAY nUB         picture         PICDEM
  skip
enddo

if prow()>61+gPStranica; FF; @ prow(),125 SAY "Str:"+str(++nStr,3); endif
? m
@ prow()+1,0        SAY "Ukupno:"
*************************** magacin *****************************
if !fzatops
  @ prow(),nCol1     SAY nTot          picture         PICDEM
  @ prow(),pcol()+1  SAY nTot1         picture         PICDEM
  @ prow(),pcol()+1  SAY nTot2         picture         PICDEM
  @ prow(),pcol()+1  SAY nTot3         picture         PICDEM
  @ prow(),pcol()+1  SAY nTot4         picture         PICDEM
  @ prow(),pcol()+1  SAY nTot5         picture         PICDEM
  @ prow(),pcol()+1  SAY nTot6         picture         PICDEM
  @ prow(),pcol()+1  SAY nTot7         picture         PICDEM
  @ prow(),pcol()+1  SAY nTot8         picture         PICDEM
  @ prow(),pcol()+1  SAY nTot9         picture         PICDEM
  IF lPrikPRUC
    @ prow(),pcol()+1  SAY nTot9a        picture         PICDEM
  ENDIF
else
  @ prow()+1,nCol1-1   SAY space(len(picdem))
endif
  @ prow(),pcol()+1  SAY nTotA         picture         PICDEM
  @ prow(),pcol()+1  SAY nTotB         picture         PICDEM

? m

nTot1:=nTot2:=nTot2b:=nTot3:=nTot4:=0
nTot5:=nTot6:=nTot7:=0
RekTarife()

if !fZaTops
	? "RUC:";  @ prow(),pcol()+1 SAY nTot6 pict picdem
endif

? m
return
*}




/*! \fn StKalk81_2()
 *  \brief Stampa kalkulacije 81 - direktno zaduzenje prodavnice
 */

function StKalk81_2()
*{
local nCol1:=nCol2:=0,npom:=0
private aPorezi

Private nPrevoz,nCarDaz,nZavTr,nBankTr,nSpedTr,nMarza,nMarza2,nPRUC
nMarza:=nMarza2:=nPRUC:=0
// iznosi troskova i marzi koji se izracunavaju u KTroskovi()

nStr:=0
cIdPartner:=IdPartner; cBrFaktP:=BrFaktP; dDatFaktP:=DatFaktP
dDatKurs:=DatKurs; cIdKonto:=IdKonto; cIdKonto2:=IdKonto2

P_10CPI
?? "ULAZ U PRODAVNICU DIREKTNO OD DOBAVLJACA"
P_COND
?
?? "KALK: KALKULACIJA BR:",  cIdFirma+"-"+cIdVD+"-"+cBrDok,SPACE(2),P_TipDok(cIdVD,-2), SPACE(2),"Datum:",DatDok
@ prow(),125 SAY "Str:"+str(++nStr,3)
select PARTN; HSEEK cIdPartner

?  "DOBAVLJAC:",cIdPartner,"-",naz,SPACE(5),"DOKUMENT Broj:",cBrFaktP,"Datum:",dDatFaktP

select KONTO; HSEEK cIdKonto
?  "KONTO zaduzuje :",cIdKonto,"-",naz

 m:="---- ---------- ---------- ---------- ---------- ---------- ---------- ----------"+;
    IF(lPrikPRUC," ----------","")+" ---------- -----------"

 ? m
 IF lPrikPRUC
   ? "*R * ROBA     *  FCJ     * RABAT    *  FCJ-RAB  * TROSKOVI *    NC    * MARZA.   * POREZ NA *   MPC    * MPCSaPP  *"
   ? "*BR* TARIFA   *  KOLICINA* DOBAVLJ  *           *          *          *          *   MARZU  *          *          *"
   ? "*  *          *    ä     *   ä      *     ä     *          *          *    ä     *    ä     *    ä     *    ä     *"
 ELSE
   ? "*R * ROBA     *  FCJ     * RABAT    *  FCJ-RAB  * TROSKOVI *    NC    * MARZA.   *   MPC    * MPCSaPP  *"
   ? "*BR* TARIFA   *  KOLICINA* DOBAVLJ  *           *          *          *          *          *          *"
   ? "*  *          *    ä     *   ä      *     ä     *          *          *    ä     *    ä     *    ä     *"
 ENDIF
 ? m
 nTot:=nTot1:=nTot2:=nTot3:=nTot4:=nTot5:=nTot6:=nTot7:=nTot8:=nTot9:=nTotA:=nTotb:=0
 nTot9a:=0

select pripr

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

    KTroskovi()
    Tarifa(field->pkonto, field->idRoba, @aPorezi)

    select ROBA
    HSEEK PRIPR->IdRoba
    select TARIFA
    HSEEK PRIPR->IdTarifa
    select PRIPR

    aIPor:=RacPorezeMP(aPorezi,field->mpc,field->mpcSaPP,field->nc)

    IF lPrikPRUC
      	nPRUC:=aIPor[2]
      	nMarza2:=nMarza2-nPRUC
    ENDIF

    if prow()>62+gPStranica; FF; @ prow(),125 SAY "Str:"+str(++nStr,3); endif

    if gKalo=="1"
        SKol:=Kolicina-GKolicina-GKolicin2
    else
        SKol:=Kolicina
    endif

    nTot+=  (nU:=FCj*Kolicina)
    if gKalo=="1"
        nTot1+= (nU1:=FCj2*(GKolicina+GKolicin2))
    else
        nTot1+= (nU1:=NC*(GKolicina+GKolicin2))
    endif
    nTot2+= (nU2:=-Rabat/100*FCJ*Kolicina)
    nTot3+= (nU3:=nPrevoz*SKol)
    nTot4+= (nU4:=nBankTr*SKol)
    nTot5+= (nU5:=nSpedTr*SKol)
    nTot6+= (nU6:=nCarDaz*SKol)
    nTot7+= (nU7:=nZavTr* SKol)
    nTot8+= (nU8:=NC *    (Kolicina-Gkolicina-GKolicin2) )
    nTot9+= (nU9:=nMarza2* (Kolicina-Gkolicina-GKolicin2) )
    IF lPrikPRUC
      nTot9a+= (nU9a:=nPRUC* (Kolicina-Gkolicina-GKolicin2) )
    ENDIF
    nTotA+= (nUA:=MPC   * (Kolicina-Gkolicina-GKolicin2) )
    nTotB+= (nUB:=MPCSAPP* (Kolicina-Gkolicina-GKolicin2) )

    @ prow()+1,0 SAY  Rbr PICTURE "999"
    @ prow(),4 SAY  ""; ?? trim(ROBA->naz),"(",ROBA->jmj,")"
    if gRokTr=="D"; ?? space(4),"Rok Tr.:",RokTr; endif
    IF lPoNarudzbi
      IspisPoNar()
    ENDIF
    @ prow()+1,4 SAY IdRoba
    nCol1:=pcol()+1
    @ prow(),pcol()+1 SAY FCJ                   PICTURE PicCDEM
    //@ prow(),pcol()+1 SAY GKolicina             PICTURE PicKol
    @ prow(),pcol()+1 SAY -Rabat                PICTURE PicProc
    @ prow(),pcol()+1 SAY fcj*(1-Rabat/100)     picture piccdem
    @ prow(),pcol()+1 SAY (nPrevoz+nBankTr+nSpedtr+nCarDaz+nZavTr)/FCJ2*100       PICTURE PicProc
    @ prow(),pcol()+1 SAY NC                    PICTURE PicCDEM
    @ prow(),pcol()+1 SAY nMarza2/NC*100        PICTURE PicProc
    IF lPrikPRUC
      @ prow(),pcol()+1 SAY aPorezi[POR_PRUCMP] PICTURE PicProc
    ENDIF
    @ prow(),pcol()+1 SAY MPC                   PICTURE PicCDEM
    @ prow(),pcol()+1 SAY MPCSaPP               PICTURE PicCDEM

    @ prow()+1,4 SAY IdTarifa
    @ prow(),nCol1    SAY Kolicina             PICTURE PicCDEM
    @ prow(),pcol()+1 SAY -Rabat/100*FCJ       PICTURE PicCDEM
    @ prow(),pcol()+1 SAY space(len(piccdem))
    @ prow(),pcol()+1 SAY (nPrevoz+nBankTr+nSpedtr+nCarDaz+nZavTr)   PICTURE Piccdem
    @ prow(),pcol()+1 SAY space(len(picdem))
    @ prow(),pcol()+1 SAY nMarza2              PICTURE PicCDEM
    IF lPrikPRUC
      @ prow(),pcol()+1 SAY nPRUC              PICTURE PicCDEM
    ENDIF

    @ prow()+1,nCol1   SAY nU          picture         PICDEM
    @ prow(),pcol()+1  SAY nU2         picture         PICDEM
    @ prow(),pcol()+1  SAY nu+nU2         picture         PICDEM
    @ prow(),pcol()+1  SAY nu3+nu4+nu5+nu6+nU7         picture  PICDEM
    @ prow(),pcol()+1  SAY nU8         picture         PICDEM
    @ prow(),pcol()+1  SAY nU9         picture         PICDEM
    IF lPrikPRUC
      @ prow(),pcol()+1  SAY nU9a         picture         PICDEM
    ENDIF
    @ prow(),pcol()+1  SAY nUA         picture         PICDEM
    @ prow(),pcol()+1  SAY nUB         picture         PICDEM

  skip
enddo

if prow()>61+gPStranica; FF; @ prow(),125 SAY "Str:"+str(++nStr,3); endif
? m
@ prow()+1,0        SAY "Ukupno:"
*************************** magacin *****************************
  @ prow(),nCol1     SAY nTot          picture         PICDEM
  @ prow(),pcol()+1  SAY nTot2         picture         PICDEM
  @ prow(),pcol()+1  SAY nTot+nTot2         picture         PICDEM
  @ prow(),pcol()+1  SAY ntot3+ntot4+ntot5+ntot6+nTot7         picture         PICDEM
  @ prow(),pcol()+1  SAY nTot8         picture         PICDEM
  @ prow(),pcol()+1  SAY nTot9         picture         PICDEM
  IF lPrikPRUC
    @ prow(),pcol()+1  SAY nTot9a        picture         PICDEM
  ENDIF
  @ prow(),pcol()+1  SAY nTotA         picture         PICDEM
  @ prow(),pcol()+1  SAY nTotB         picture         PICDEM

? m

if prow()>55+gPStranica; FF; @ prow(),125 SAY "Str:"+str(++nStr,3); endif
?
if  round(ntot3+ntot4+ntot5+ntot6+ntot7,2) <>0
?  m
?  "Troskovi (analiticki):"
?  c10T1,":"
@ prow(),30 SAY  ntot3 pict picdem
?  c10T2,":"
@ prow(),30 SAY  ntot4 pict picdem
?  c10T3,":"
@ prow(),30 SAY  ntot5 pict picdem
?  c10T4,":"
@ prow(),30 SAY  ntot6 pict picdem
?  c10T5,":"
@ prow(),30 SAY  ntot7 pict picdem
? m
? "Ukupno troskova:"
@ prow(),30 SAY  ntot3+ntot4+ntot5+ntot6+ntot7 pict picdem
? m
endif

nTot1:=nTot2:=nTot2b:=nTot3:=nTot4:=0
nTot5:=nTot6:=nTot7:=0
RekTarife()

? "RUC:";  @ prow(),pcol()+1 SAY nTot6 pict picdem
? m
return
*}


