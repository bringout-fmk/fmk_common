#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/mag/dok/1g/rpt_82.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.2 $
 * $Log: rpt_82.prg,v $
 * Revision 1.2  2002/06/20 13:13:03  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/mag/dok/1g/rpt_82.prg
 *  \brief Stampa kalkulacije 82 - izlaz iz magacina diskont
 */


/*! \fn StKalk82()
 *  \brief Stampa kalkulacije 82 - izlaz iz magacina diskont
 */

function StKalk82()
*{
local nCol0:=nCol1:=nCol2:=0,npom:=0

Private nMarza,nMarza2

nStr:=0
cIdPartner:=IdPartner; cBrFaktP:=BrFaktP; dDatFaktP:=DatFaktP
dDatKurs:=DatKurs; cIdKonto:=IdKonto; cIdKonto2:=IdKonto2

P_COND
?? "KALK BR:",  cIdFirma+"-"+cIdVD+"-"+cBrDok,SPACE(2),P_TipDok(cIdVD,-2), SPACE(2),"Datum:",DatDok
@ prow(),125 SAY "Str:"+str(++nStr,3)
select PARTN; HSEEK cIdPartner

select KONTO; HSEEK cIdKonto
?  "Magacin razduzuje:",cIdKonto,"-",naz

select PRIPR

m:="--- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------"
? m
? "*R * ROBA     * Kolicina *   NC     *  VPC    *    MPC   *   PPP %  *   PPP    *  MPC     *"
? "*BR*          *          *          *         *          *   PPU %  *   PPU    *  SA Por  *"
? "*  *          *          *    ä     *         *     ä    *     ä    *    ä     *    ä     *"
? m
nTot1:=nTot1b:=nTot2:=nTot3:=nTot4:=nTot5:=nTot6:=nTot7:=0

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
    Marza2R()   // izracunaj nMarza2
    KTroskovi()

    select ROBA; HSEEK PRIPR->IdRoba
    select TARIFA; HSEEK PRIPR->IdTarifa
    select PRIPR
    VtPorezi()

    if prow()>62+gPStranica; FF; @ prow(),125 SAY "Str:"+str(++nStr,3); endif


    nTot3+=  (nU3:= NC*kolicina )
    nTot4+=  (nU4:= vpc*(1-rabatv/100)*Kolicina )
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
    @ prow(),pcol()+1 SAY NC                   PICTURE PicCDEM
    @ prow(),pcol()+1 SAY vpc*(1-rabatv/100)   PICTURE PicCDEM
    @ prow(),pcol()+1 SAY MPC                  PICTURE PicCDEM
    nCol1:=pcol()+1
    @ prow(),pcol()+1 SAY TARIFA->OPP          PICTURE PicProc
    @ prow(),pcol()+1 SAY nPor1                PICTURE PiccDEM
    @ prow(),pcol()+1 SAY MPCSAPP              PICTURE PicCDEM

    @ prow()+1, nCol0     SAY  nc*kolicina      picture picdem
    @ prow(),   pcol()+1  SAY  vpc*(1-rabatv/100)*kolicina  picture picdem
    @ prow(),   pcol()+1  SAY  mpc*kolicina      picture picdem

    @ prow(),nCol1    SAY    _PPP       picture picproc
    @ prow(),  pcol()+1 SAY  nPor2             picture piccdem

    skip

enddo

if prow()>61+gPStranica; FF; @ prow(),125 SAY "Str:"+str(++nStr,3); endif
? m
@ prow()+1,0        SAY "Ukupno:"
@ prow(),nCol0      SAY  nTot3        picture       PicDEM
@ prow(),pcol()+1   SAY  nTot4        picture       PicDEM
@ prow(),pcol()+1   SAY  nTot5        picture       PicDEM
@ prow(),pcol()+1   SAY  space(len(picproc))
@ prow(),pcol()+1   SAY  nTot6        picture        PicDEM
@ prow(),pcol()+1   SAY  nTot7        picture        PicDEM
? m

IF prow()>55+gPStranica; FF; @ prow(),125 SAY "Str:"+str(++nStr,3);  endif
nRec:=recno()
select pripr
set order to 2
seek cidfirma+cidvd+cbrdok
m:="------ ---------- ---------- ---------- ---------- ---------- ----------"
? m
? "* Tar *  PPP%    *   PPU%   *    MPV   *    PPP   *   PPU    * MPVSAPP *"
? m
nTot1:=nTot2:=nTot3:=nTot4:=0
nTot5:=nTot6:=nTot7:=0
do while !eof() .and. cidfirma+cidvd+cbrdok==idfirma+idvd+brdok
  cidtarifa:=idtarifa
  nU1:=nU2:=nU3:=nU4:=0
  select tarifa; hseek cidtarifa
  select pripr
  do while !eof() .and. cidfirma+cidvd+cbrdok==idfirma+idvd+brdok .and. idtarifa==cidtarifa
    select roba; hseek pripr->idroba; select pripr
    VtPorezi()
    nU1+=mpc*kolicina
    nU2+=mpc*_OPP*kolicina
    nU3+=mpc*(1+_OPP)*_PPP*kolicina
    nU4+=mpcsapp*kolicina
    nTot5+=(mpc-nc)*kolicina
    skip
  enddo
  nTot1+=nu1; nTot2+=nU2; nTot3+=nU3
  nTot4+=nU4
  ? cidtarifa
  @ prow(),pcol()+1   SAY _OPP*100 pict picproc
  @ prow(),pcol()+1   SAY _PPP*100 pict picproc
  nCol1:=pcol()+1
  @ prow(),pcol()+1   SAY nu1 pict picdem
  @ prow(),pcol()+1   SAY nu2 pict picdem
  @ prow(),pcol()+1   SAY nu3 pict picdem
  @ prow(),pcol()+1   SAY nu4 pict picdem
enddo
IF prow()>56+gPStranica; FF; @ prow(),125 SAY "Str:"+str(++nStr,3);  endif
? m
? "UKUPNO"
@ prow(),nCol1      SAY nTot1 pict picdem
@ prow(),pcol()+1   SAY nTot2 pict picdem
@ prow(),pcol()+1   SAY nTot3 pict picdem
@ prow(),pcol()+1   SAY nTot4 pict picdem
? m
? "RUC:";  @ prow(),pcol()+1 SAY nTot5 pict picdem
? m

set order to 1
go nRec
return
*}
