#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/prod/dok/1g/rpt_80.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.6 $
 * $Log: rpt_80.prg,v $
 * Revision 1.6  2004/01/07 13:43:27  sasavranic
 * Korekcija algoritama za tarife, ako je bilo promjene tarifa
 *
 * Revision 1.5  2003/09/20 07:37:07  mirsad
 * sredj.koda za poreze u MP
 *
 * Revision 1.4  2002/07/19 13:57:23  mirsad
 * lPrikPRUC ubacio kao globalnu varijablu
 *
 * Revision 1.3  2002/06/25 08:44:24  ernad
 *
 *
 * ostranicavanje planika, doxy - grupa: Planika
 *
 * Revision 1.2  2002/06/21 07:49:36  mirsad
 * no message
 *
 *
 */
 

/*! \file fmk/kalk/prod/dok/1g/rpt_80.prg
 *  \brief Stampa dokumenta tipa 80 - direktno zaduzenje prodavnice
 */


/*! \fn StKalk80(fBezNc)
 *  \brief Stampa dokumenta tipa 80 - direktno zaduzenje prodavnice
 *  \param fBezNc -
 */

function StKalk80(fBezNc)
*{
local nCol1:=nCol2:=0,npom:=0

Private nPrevoz,nCarDaz,nZavTr,nBankTr,nSpedTr,nMarza,nMarza2
// iznosi troskova i marzi koji se izracunavaju u KTroskovi()

if fbeznc==NIL
 fBezNC:=.f.
endif

nStr:=0
cIdPartner:=IdPartner; cBrFaktP:=BrFaktP; dDatFaktP:=DatFaktP
dDatKurs:=DatKurs; cIdKonto:=IdKonto; cIdKonto2:=IdKonto2

P_10CPI
?
? "PRIJEM U PRODAVNICU (INTERNI DOKUMENT)"
?
P_COND
? "KALK. DOKUMENT BR:",  cIdFirma+"-"+cIdVD+"-"+cBrDok,SPACE(2),P_TipDok(cIdVD,-2), SPACE(2),"Datum:",DatDok
@ prow(),125 SAY "Str:"+str(++nStr,3)
select PARTN; HSEEK cIdPartner

?  "DOKUMENT Broj:",cBrFaktP,"Datum:",dDatFaktP

select KONTO; HSEEK cIdKonto
?  "KONTO zaduzuje :",cIdKonto,"-",naz


 m:="--- -------------------------------------------- ----------"+iif(fBezNC,""," ---------- ----------")+" ---------- ----------"

 IF lPrikPRUC
   m += " ----------"
   ? m
   ? "*R * ROBA                                       * KOLICINA *"+iif(fBezNC,"","  NAB.CJ  * MARZA.   * POREZ NA *")+"   MPC    * MPCSaPP *"
   ? "*BR* TARIFA                                     *          *"+iif(fBezNC,"","          *          *   MARZU  *")+"          *         *"
 ELSE
   ? m
   ? "*R * ROBA                                       * KOLICINA *"+iif(fBezNC,"","  NAB.CJ  * MARZA.   *")+"   MPC    * MPCSaPP *"
   ? "*BR* TARIFA                                     *          *"+iif(fBezNC,"","          *          *")+"          *         *"
 ENDIF
 ? m

select pripr
nRec:=recno()
altd()
private cIdd:=idpartner+brfaktp+idkonto+idkonto2
if !empty(idkonto2)
  cidkont:=idkonto
  cIdkont2:=idkonto2
  nProlaza:=2
else
  cidkont:=idkonto
  nProlaza:=1
endif

unTot:=unTot1:=unTot2:=unTot3:=unTot4:=unTot5:=unTot6:=unTot7:=unTot8:=unTot9:=unTotA:=unTotb:=0
unTot9a:=0

private aPorezi
aPorezi:={}

for i:=1 to nprolaza
nTot:=nTot1:=nTot2:=nTot3:=nTot4:=nTot5:=nTot6:=nTot7:=nTot8:=nTot9:=nTotA:=nTotb:=0
nTot9a:=0
go nRec
do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD

    if idkonto2="XXX"
         cIdkont2:=Idkonto
    else
         cIdkont:=Idkonto
    endif
    
    KTroskovi()

    if empty(idkonto2)
    	ViseDokUPripremi(cIdd)
    else
      if (i==1 .and. left(idkonto2,3)<>"XXX") .or. (i==2 .and. left(idkonto2,3)=="XXX")
         // nastavi
      else
         skip
         loop
      endif
    endif

    KTroskovi()

    RptSeekRT()

    Tarifa(field->pkonto,field->idroba,@aPorezi)
    aIPor:=RacPorezeMP(aPorezi,field->mpc,field->mpcSaPP,field->nc)

    IF lPrikPRUC
    	nPRUC:=aIPor[2]
    	nMarza2:=nMarza2-nPRUC
    ENDIF

    DokNovaStrana(125, @nStr, 2)

    if gKalo=="1"
        SKol:=Kolicina-GKolicina-GKolicin2
    else
        SKol:=Kolicina
    endif

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
    @ prow(),pcol()+35  SAY Kolicina             PICTURE PicCDEM
    nCol1:=pcol()+1
    if !fBezNC  // bez nc
      @ prow(),nCol1    SAY NC                    PICTURE PicCDEM
      if round(nc,5)<>0
        @ prow(),pcol()+1 SAY nMarza2/NC*100        PICTURE PicProc
      else
        @ prow(),pcol()+1 SAY 0        PICTURE PicProc
      endif
      IF lPrikPRUC
        @ prow(),pcol()+1 SAY TARIFA->mpp        PICTURE PicProc
      ENDIF
    endif
    @ prow(),pcol()+1 SAY MPC                   PICTURE PicCDEM
    @ prow(),pcol()+1 SAY MPCSaPP               PICTURE PicCDEM

    @ prow()+1,4 SAY IdTarifa
    IF !fBezNC
      @ prow(),nCol1     SAY nU8         picture         PICDEM
      @ prow(),pcol()+1  SAY nU9         picture         PICDEM
      IF lPrikPRUC
        @ prow(),pcol()+1 SAY nU9a                PICTURE PicCDEM
      ENDIF
      @ prow(),pcol()+1  SAY nUA         picture         PICDEM
      @ prow(),pcol()+1  SAY nUB         picture         PICDEM
    ELSE
      @ prow(),nCol1     SAY nUA         picture         PICDEM
      @ prow(),pcol()+1  SAY nUB         picture         PICDEM
    ENDIF

  skip
enddo

 if nprolaza==2
   ? m
   ? "Konto "
   if i==1
     ?? cidkont
   else
     ?? cidkont2
   endif
   IF !fBezNC
     @ prow(),nCol1     SAY nTot8         picture         PICDEM
     @ prow(),pcol()+1  SAY nTot9         picture         PICDEM
     IF lPrikPRUC
       @ prow(),pcol()+1  SAY nTot9a        picture         PICDEM
     ENDIF
     @ prow(),pcol()+1  SAY nTotA         picture         PICDEM
     @ prow(),pcol()+1  SAY nTotB         picture         PICDEM
   ELSE
     @ prow(),nCol1     SAY nTotA         picture         PICDEM
     @ prow(),pcol()+1  SAY nTotB         picture         PICDEM
   ENDIF
   ? m
 endif
 unTot8  += nTot8
 unTot9  += nTot9
 unTot9a += nTot9a
 unTotA  += nTotA
 unTotB  += nTotB
next

DokNovaStrana(125, @nStr, 3)
? m
@ prow()+1,0        SAY "Ukupno:"
  @ prow(),nCol1     SAY unTot8         picture         PICDEM
  @ prow(),pcol()+1  SAY unTot9         picture         PICDEM
  IF lPrikPRUC
    @ prow(),pcol()+1  SAY unTot9a        picture         PICDEM
  ENDIF
  @ prow(),pcol()+1  SAY unTotA         picture         PICDEM
  @ prow(),pcol()+1  SAY unTotB         picture         PICDEM

? m

DokNovaStrana(125, @nStr, 8)
nRec:=recno()
RekTarife()

return
*}
