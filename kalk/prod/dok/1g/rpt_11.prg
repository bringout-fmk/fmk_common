#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/prod/dok/1g/rpt_11.prg,v $
 * $Author: mirsadsubasic $ 
 * $Revision: 1.7 $
 * $Log: rpt_11.prg,v $
 * Revision 1.7  2003/09/29 13:26:56  mirsadsubasic
 * sredjivanje koda za poreze u ugostiteljstvu
 *
 * Revision 1.6  2003/09/20 07:37:07  mirsad
 * sredj.koda za poreze u MP
 *
 * Revision 1.5  2003/09/08 08:41:43  ernad
 * porezi u ugostiteljstvu
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
 

/*! \file fmk/kalk/prod/dok/1g/rpt_11.prg
 *  \brief Stampa dokumenta tipa 11
 */


/*! \fn StKalk11_2(fZaTops)
 *  \brief Stampa dokumenta tipa 11
 */

function StKalk11_2(fZaTops)
*{
local nCol0:=nCol1:=nCol2:=0,npom:=0, n11BezNC
private aPorezi

Private nMarza,nMarza2

nStr:=0
cIdPartner:=IdPartner; cBrFaktP:=BrFaktP; dDatFaktP:=DatFaktP
dDatKurs:=DatKurs; cIdKonto:=IdKonto; cIdKonto2:=IdKonto2

if fzaTops==NIL
 fzaTops:=.f.
endif

if fzatops
  n11BezNC:=g11BezNC
  g11BezNc:="D"
endif

P_COND
B_ON
if cidvd=="11"
 ?? "ZADUZENJE PRODAVNICE IZ MAGACINA"
ELSEIF CIDVD=="12"
 ?? "POVRAT IZ PRODAVNICE U MAGACIN"
ELSEIF CIDVD=="13"
 ?? "POVRAT IZ PRODAVNICE U MAGACIN RADI ZADUZENJA DRUGE PRODAVNICE"
endif
B_OFF
? "KALK: KALKULACIJA BR:",  cIdFirma+"-"+cIdVD+"-"+cBrDok,SPACE(2),", Datum:",DatDok
@ prow(),123 SAY "Str:"+str(++nStr,3)
select PARTN
HSEEK cIdPartner

? "OTPREMNICA Broj:",cBrFaktP,"Datum:",dDatFaktP

if cidvd=="11"
 select KONTO; HSEEK cIdKonto
 ?  "Prodavnica zaduzuje :",cIdKonto,"-",naz
 HSEEK cIdKonto2
 ?  "Magacin razduzuje   :",cIdKonto2,"-",naz
else
 select KONTO; HSEEK cIdKonto
 ?  "Storno Prodavnica zaduzuje :",cIdKonto,"-",naz
 HSEEK cIdKonto2
 ?  "Storno Magacin razduzuje   :",cIdKonto2,"-",naz
endif

select PRIPR

m:="--- ---------- ---------- "+IF(g11bezNC=="D","","---------- ")+"---------- ---------- "+IF(g11bezNC=="D","","---------- ---------- ")+"---------- ---------- ---------- --------- -----------"

select koncij; seek trim(pripr->mkonto); select pripr

IF lPrikPRUC
  //m += " ----------"
  ? m
  if koncij->naz=="P2"
    ? "*R * ROBA     * Kolicina "+IF(g11bezNC=="D","","*  NAB.CJ  ")+"* Plan.Cj. *"+IF(g11bezNC=="D","","  NAB.CJ  *  MARZA   *")+"  MARZA   * POREZ NA*    MPC   *   PPP %  *   PPP    *  MPC     *"
  else
    ? "*R * ROBA     * Kolicina "+IF(g11bezNC=="D","","*  NAB.CJ  ")+"*   VPC    *"+IF(g11bezNC=="D","","  NAB.CJ  *  MARZA   *")+"  MARZA   * POREZ NA*    MPC   *   PPP %  *   PPP    *  MPC     *"
  endif
  ? "*BR*          *          "+IF(g11bezNC=="D","","*   U VP   ")+"*          *"+IF(g11bezNC=="D","","   U MP   *   VP     *")+"   MP     *  MARZU  *          *   PPU %  *   PPU    *  SA Por  *"
  ? "*  *          *          "+IF(g11bezNC=="D","","*          ")+"*          *"+IF(g11bezNC=="D","","          *          *")+"          *   MP    *          *          *          *          *"
ELSE
  ? m
  if koncij->naz=="P2"
    ? "*R * ROBA     * Kolicina "+IF(g11bezNC=="D","","*  NAB.CJ  ")+"* Plan.Cj. *  TROSAK  *"+IF(g11bezNC=="D","","  NAB.CJ  *  MARZA   *")+"  MARZA  *    MPC   *   PPP %  *   PPP    *  MPC     *"
  else
    ? "*R * ROBA     * Kolicina "+IF(g11bezNC=="D","","*  NAB.CJ  ")+"*   VPC    *  TROSAK  *"+IF(g11bezNC=="D","","  NAB.CJ  *  MARZA   *")+"  MARZA  *    MPC   *   PPP %  *   PPP    *  MPC     *"
  endif
  ? "*BR*          *          "+IF(g11bezNC=="D","","*   U VP   ")+"*          *   U MP   *"+IF(g11bezNC=="D","","   U MP   *   VP     *")+"   MP    *          *   PPU %  *   PPU    *  SA Por  *"
  ? "*  *          *          "+IF(g11bezNC=="D","","*          ")+"*          *          *"+IF(g11bezNC=="D","","          *          *")+"         *          *          *          *          *"
ENDIF
? m
select koncij
seek trim(pripr->pkonto)
select pripr
nTot1:=nTot1b:=nTot2:=nTot3:=nTot4:=nTot4b:=nTot5:=nTot6:=nTot7:=0
nTot4c:=0

aPorezi:={}
private cIdd:=idpartner+brfaktp+idkonto+idkonto2
do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD

    ViseDokUPripremi(cIdd)
    RptSeekRT()
    
    Scatter()  // formiraj varijable _....
   
    Marza2()
    nMarza:=_marza   // izracunaj nMarza,nMarza2
    VTPorezi()
    
    Tarifa(field->pkonto, field->idRoba, @aPorezi)
    aIPor:=RacPorezeMP(aPorezi,field->mpc,field->mpcSaPP,field->nc)

    nPor1:=aIPor[1]
    if lPrikPRUC
      nPRUC:=aIPor[2]
      nPor2:=0
      nMarza2:=nMarza2-nPRUC
    else
      nPor2:=aIPor[2]
    endif
    
    DokNovaStrana(123, @nStr, 2)

    nTot1+=  (nU1:= FCJ*Kolicina   )
    nTot1b+= (nU1b:= VPC*Kolicina  )
    nTot2+=  (nU2:= Prevoz*Kolicina   )
    nTot3+=  (nU3:= NC*kolicina )
    nTot4+=  (nU4:= nmarza*Kolicina )
    nTot4b+=  (nU4b:= nmarza2*Kolicina )
    IF lPrikPRUC
      nTot4c+= ( nU4c := nPRUC*Kolicina )
    ENDIF
    nTot5+=  (nU5:= MPC*Kolicina )
    nTot6+=  (nU6:=(nPor1+nPor2)*Kolicina)
    nTot7+=  (nU7:= MPcSaPP*Kolicina )

    @ prow()+1,0 SAY  Rbr PICTURE "999"
    @ prow(),4 SAY  ""
    ?? trim(ROBA->naz),"(",ROBA->jmj,")"

    if gRokTr=="D"
	?? space(4),"Rok Tr.:",RokTr
    endif

    IF lPoNarudzbi
      IspisPoNar()
    ENDIF
    @ prow()+1,4 SAY IdRoba
    @ prow(),pcol()+1 SAY Kolicina             PICTURE PicKol

    nCol0:=pcol()+1
    IF g11bezNC != "D"
      @ prow(),pcol()+1 SAY FCJ                  PICTURE PicCDEM
    ENDIF
    @ prow(),pcol()+1 SAY VPC                  PICTURE PicCDEM
    IF !lPrikPRUC
      @ prow(),pcol()+1 SAY Prevoz               PICTURE PicCDEM
    ENDIF
    IF g11bezNC != "D"
      @ prow(),pcol()+1 SAY NC                   PICTURE PicCDEM
      @ prow(),pcol()+1 SAY nMarza               PICTURE PicCDEM
    ENDIF
    @ prow(),pcol()+1 SAY nMarza2              PICTURE PicCDEM
    IF lPrikPRUC
      @ prow(),pcol()+1 SAY aPorezi[POR_PRUCMP] PICTURE PicProc
    ENDIF
    @ prow(),pcol()+1 SAY MPC                  PICTURE PicCDEM
    nCol1:=pcol()+1
    @ prow(),pcol()+1 SAY aPorezi[POR_PPP]     PICTURE PicProc
    @ prow(),pcol()+1 SAY nPor1                PICTURE PiccDEM
    @ prow(),pcol()+1 SAY MPCSAPP              PICTURE PicCDEM

    @ prow()+1,4 SAY IdTarifa+roba->tip
    IF g11bezNC == "D"
      @ prow(),nCol0-1    SAY  ""
    ELSE
      @ prow(),nCol0    SAY  fcj*kolicina      picture picdem
    ENDIF
    @ prow(),  pcol()+1 SAY  vpc*kolicina      picture picdem
    IF !lPrikPRUC
      @ prow(),  pcol()+1 SAY  prevoz*kolicina      picture picdem
    ENDIF
    IF g11bezNC != "D"
      @ prow(),  pcol()+1 SAY  nc*kolicina      picture picdem
      @ prow(),  pcol()+1 SAY  nMarza*kolicina      picture picdem
    ENDIF
    @ prow(),  pcol()+1 SAY  nMarza2*kolicina      picture picdem
    IF lPrikPRUC
      @ prow(),pcol()+1 SAY nU4c                PICTURE PicCDEM
    ENDIF
    @ prow(),  pcol()+1 SAY  mpc*kolicina      picture picdem
    if lPrikPRUC
    	@ prow(),nCol1    SAY aPorezi[POR_PPU]   picture picproc
    else
    	@ prow(),nCol1    SAY PrPPUMP()   picture picproc
    endif
    @ prow(),  pcol()+1 SAY  nPor2             picture piccdem
    @ prow(),  pcol()+1 SAY  nU7               picture picdem

    skip

enddo


DokNovaStrana(123, @nStr, 3)
? m
@ prow()+1,0        SAY "Ukupno:"
IF g11bezNC == "D"
  @ prow(),nCol0-1      SAY  ""
ELSE
  @ prow(),nCol0      SAY  nTot1        picture       PicDEM
ENDIF

@ prow(),pcol()+1   SAY  nTot1b       picture       PicDEM
IF !lPrikPRUC
  @ prow(),pcol()+1   SAY  nTot2        picture       PicDEM
ENDIF

nMarzaVP:=nTot4
IF g11bezNC != "D"
  @ prow(),pcol()+1   SAY  nTot3        picture       PicDEM
  @ prow(),pcol()+1   SAY  nTot4        picture       PicDEM
ENDIF

@ prow(),pcol()+1   SAY  nTot4b        picture       PicDEM
IF lPrikPRUC
  @ prow(),pcol()+1  SAY nTot4c        picture         PICDEM
ENDIF
@ prow(),pcol()+1   SAY  nTot5        picture       PicDEM
@ prow(),pcol()+1   SAY  space(len(picproc))
@ prow(),pcol()+1   SAY  nTot6        picture        PicDEM
@ prow(),pcol()+1   SAY  nTot7        picture        PicDEM
? m

nTot5:=nTot6:=nTot7:=0
RekTarife()

? "RUC:"
@ prow(),pcol()+1 SAY nTot6 pict picdem
if cidvd=="11" .and. g11bezNC!="D"
	@ prow(),pcol()+2 SAY "Od toga storno RUC u VP:"
	@ prow(),pcol()+1 SAY nMarzaVP pict picdem
elseif cidvd$"12#13" .and. g11bezNC!="D"
	@ prow(),pcol()+2 SAY "Od toga prenijeti RUC u VP:"
	@ prow(),pcol()+1 SAY nMarzaVP pict picdem
endif


? m

if fZaTops
	g11BezNC:=n11BezNC
endif

return
*}

