#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/mag/dok/1g/rpt_15.prg,v $
 *
 *
 */
 

/*! \file fmk/kalk/mag/dok/1g/rpt_15.prg
 *  \brief Stampa dokumenta tipa 15
 */


/*! \fn StKalk15()
 *  \brief Stampa kalkulacije 15
 */



***********************************************************************************
* stampa kalkulacije 15 / magacin po vpc
***********************************************************************************
function StKalk15(fZaTops)
local nCol0:=nCol1:=nCol2:=0,npom:=0, n11BezNC, nRecPrva:=0

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
if cidvd=="15"
 ?? "IZLAZ IZ MP PUTEM VP , UZ NARUDZBENICU KUPCA"
endif
B_OFF
? "KALK: KALKULACIJA BR:",  cIdFirma+"-"+cIdVD+"-"+cBrDok,SPACE(2),", Datum:",DatDok
@ prow(),123 SAY "Str:"+str(++nStr,3)
select PARTN; HSEEK cIdPartner

? "OTPREMNICA Broj:",cBrFaktP,"Datum:",dDatFaktP

select KONTO; HSEEK cIdKonto
?  "Prodavnica zaduzuje :",cIdKonto,"-",naz
HSEEK cIdKonto2
?  "Magacin razduzuje   :",cIdKonto2,"-",naz

select PRIPR

m:="--- ---------- ---------- "+IF(g11bezNC=="D","","---------- ")+"---------- ---------- "+IF(g11bezNC=="D","","---------- ---------- ")+"---------- ---------- ---------- --------- -----------"

? m
select koncij; seek trim(pripr->mkonto); select pripr

if koncij->naz=="P2"
  ? "*R * ROBA     * Kolicina "+IF(g11bezNC=="D","","*  NAB.CJ  ")+"* Plan.Cj. *  TROSAK  *"+IF(g11bezNC=="D","","  NAB.CJ  *  MARZA   *")+"  MARZA  *    MPC   *   PPP %  *   PPP    *  MPC     *"
else
  ? "*R * ROBA     * Kolicina "+IF(g11bezNC=="D","","*  NAB.CJ  ")+"*   VPC    *  TROSAK  *"+IF(g11bezNC=="D","","  NAB.CJ  *  MARZA   *")+"  MARZA  *    MPC   *   PPP %  *   PPP    *  MPC     *"
endif
? "*BR*          *          "+IF(g11bezNC=="D","","*   U VP   ")+"*          *   U MP   *"+IF(g11bezNC=="D","","   U MP   *   VP     *")+"   MP    *          *   PPU %  *   PPU    *  SA Por  *"
? "*  *          *          "+IF(g11bezNC=="D","","*          ")+"*          *          *"+IF(g11bezNC=="D","","          *          *")+"         *          *          *          *          *"
? m

select koncij; seek trim(pripr->pkonto); select pripr
nTot1:=nTot1b:=nTot2:=nTot3:=nTot4:=nTot4b:=nTot5:=nTot6:=nTot7:=0

private cIdd:=idpartner+brfaktp+idkonto+idkonto2

nRecPrva:=RECNO()

do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD

    // !!!!!!!!!!!!!!!
    if idpartner+brfaktp+idkonto+idkonto2<>cidd
     set device to screen
     Beep(2)
     Msg("Unutar kalkulacije se pojavilo vise dokumenata !",6)
     set device to printer
    endif

    scatter()  // formiraj varijable _....

    select ROBA; HSEEK PRIPR->IdRoba
    select TARIFA; HSEEK PRIPR->IdTarifa
    select PRIPR

    Marza2(); nMarza:=_marza   // izracunaj nMarza,nMarza2
    VTPorezi()

    if prow()>62+gPStranica; FF; @ prow(),123 SAY "Str:"+str(++nStr,3); endif


    nTot1+=  (nU1:= FCJ*Kolicina   )
    nTot1b+= (nU1b:= VPC*Kolicina  )
    nTot2+=  (nU2:= Prevoz*Kolicina   )
    nTot3+=  (nU3:= NC*kolicina )
    nTot4+=  (nU4:= nmarza*Kolicina )
    nTot4b+=  (nU4b:= nmarza2*Kolicina )
    nTot5+=  (nU5:= MPC*Kolicina )
    nPor1:=  MPC*_OPP
    nPor2:=  MPC*(1+_OPP)*_PPP
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
    IF g11bezNC != "D"
      @ prow(),pcol()+1 SAY FCJ                  PICTURE PicCDEM
    ENDIF
    @ prow(),pcol()+1 SAY VPC                  PICTURE PicCDEM
    @ prow(),pcol()+1 SAY Prevoz               PICTURE PicCDEM
    IF g11bezNC != "D"
      @ prow(),pcol()+1 SAY NC                   PICTURE PicCDEM
      @ prow(),pcol()+1 SAY nMarza               PICTURE PicCDEM
    ENDIF
    @ prow(),pcol()+1 SAY nMarza2              PICTURE PicCDEM
    @ prow(),pcol()+1 SAY MPC                  PICTURE PicCDEM
    nCol1:=pcol()+1
    @ prow(),pcol()+1 SAY _OPP*100             PICTURE PicProc
    @ prow(),pcol()+1 SAY nPor1                PICTURE PiccDEM
    @ prow(),pcol()+1 SAY MPCSAPP              PICTURE PicCDEM

    @ prow()+1,4 SAY IdTarifa+roba->tip
    IF g11bezNC == "D"
      @ prow(),nCol0-1    SAY  ""
    ELSE
      @ prow(),nCol0    SAY  fcj*kolicina      picture picdem
    ENDIF
    @ prow(),  pcol()+1 SAY  vpc*kolicina      picture picdem
    @ prow(),  pcol()+1 SAY  prevoz*kolicina      picture picdem
    IF g11bezNC != "D"
      @ prow(),  pcol()+1 SAY  nc*kolicina      picture picdem
      @ prow(),  pcol()+1 SAY  nMarza*kolicina      picture picdem
    ENDIF
    @ prow(),  pcol()+1 SAY  nMarza2*kolicina      picture picdem
    @ prow(),  pcol()+1 SAY  mpc*kolicina      picture picdem
    @ prow(),nCol1    SAY    _PPP*100          picture picproc
    @ prow(),  pcol()+1 SAY  nPor2             picture piccdem
    @ prow(),  pcol()+1 SAY  nU7               picture picdem

    skip

enddo

if prow()>61+gPStranica; FF; @ prow(),123 SAY "Str:"+str(++nStr,3); endif

? m
@ prow()+1,0        SAY "Ukupno:"

IF g11bezNC == "D"
  @ prow(),nCol0-1      SAY  ""
ELSE
  @ prow(),nCol0      SAY  nTot1        picture       PicDEM
ENDIF

@ prow(),pcol()+1   SAY  nTot1b       picture       PicDEM
@ prow(),pcol()+1   SAY  nTot2        picture       PicDEM

IF g11bezNC != "D"
  @ prow(),pcol()+1   SAY  nTot3        picture       PicDEM
  @ prow(),pcol()+1   SAY  nTot4        picture       PicDEM
ENDIF

@ prow(),pcol()+1   SAY  nTot4b        picture       PicDEM
@ prow(),pcol()+1   SAY  nTot5        picture       PicDEM
@ prow(),pcol()+1   SAY  space(len(picproc))
@ prow(),pcol()+1   SAY  nTot6        picture        PicDEM
@ prow(),pcol()+1   SAY  nTot7        picture        PicDEM
? m

nTot5:=nTot6:=nTot7:=0
RekTarife()

IF g11bezNC=="D"
  ? "RUC MP:";  @ prow(),pcol()+1 SAY nTot5-nTot6 pict picdem
ELSE
  ? "RUC:";  @ prow(),pcol()+1 SAY nTot5 pict picdem
ENDIF

if cidvd=="15" .and. g11bezNC != "D"
  @ prow(),pcol()+2 SAY "Od toga storno RUC u VP:"; @ prow(),pcol()+1 SAY nTot6 pict picdem
elseif cidvd $ "12#13" .and. g11bezNC != "D"
  @ prow(),pcol()+2 SAY "Od toga prenijeti RUC u VP:"; @ prow(),pcol()+1 SAY nTot6 pict picdem
endif
? m

if fzatops
  g11BezNC:=n11BezNC
endif


select pripr
go (nRecPrva)
?
?
StKalk14()

RETURN



