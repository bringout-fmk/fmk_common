#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/prod/dok/1g/rpt_11_3.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.4 $
 * $Log: rpt_11_3.prg,v $
 * Revision 1.4  2003/09/20 07:37:07  mirsad
 * sredj.koda za poreze u MP
 *
 * Revision 1.3  2003/08/01 16:18:43  mirsad
 * no message
 *
 * Revision 1.2  2002/06/21 07:49:36  mirsad
 * no message
 *
 *
 */
 

/*! \file fmk/kalk/prod/dok/1g/rpt_11_3.prg
 *  \brief Stampa kalkulacije 11, varijanta "3" - papir formata A3
 */


/*! \fn StKalk11_3()
 *  \brief Stampa kalkulacije 11, varijanta "3" - papir formata A3
 */

function StKalk11_3()
*{
local nCol0:=nCol1:=nCol2:=0,npom:=0

Private nMarza,nMarza2

nStr:=0
cIdPartner:=IdPartner; cBrFaktP:=BrFaktP; dDatFaktP:=DatFaktP
dDatKurs:=DatKurs; cIdKonto:=IdKonto; cIdKonto2:=IdKonto2

P_COND
?? SPACE(155)+"Str."+str(++nStr,3)     // 220-40
? PADC("MALOPRODAJNA KALKULACIJA BR."+cIdFirma+"-"+cIdVD+"-"+cBrDok+"     Datum:"+DTOC(DatDok),180)
? PADC(REPLICATE("-",64),180)

?
B_ON
? PADC(IF( cidvd=="11", "ZADUZENJE PRODAVNICE IZ MAGACINA",;
       IF( cidvd=="12", "POVRAT IZ PRODAVNICE U MAGACIN",;
       IF( cidvd=="13", "POVRAT IZ PRODAVNICE U MAGACIN RADI ZADUZENJA DRUGE PRODAVNICE", "") ) ),180)
B_OFF

select PARTN; HSEEK cIdPartner

? "OTPREMNICA Broj:",cBrFaktP,"Datum:",dDatFaktP

select KONTO; HSEEK cIdKonto
?  "KONTO zaduzuje :",cIdKonto,"-",naz
HSEEK cIdKonto2
?  "KONTO razduzuje:",cIdKonto2,"-",naz

select PRIPR

m:="--- ---------- ---------------------------------------- ---"+IF(gRokTr=="D"," --------","")+" ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- -----------"
? m
? "*R.* Sifra    *                                        *Jed*"+IF(gRokTr=="D","  Rok   *","")+" Kolicina * VELEPROD.*  IZNOS   *  RAZLIKA U CIJENI   *POREZ NA PROM.PROIZV.*POREZ NA PROM.USLUGA *   IZNOS  * MALOPROD.*"
? "*br* artikla  *       N A Z I V    A R T I K L A       *mj.*"+IF(gRokTr=="D","trajanja*","")+"          *  CIJENA  *  VELE-   *---------------------*---------------------*---------------------*  MALO-   *  CIJENA  *"
? "*  *          *                                        *   *"+IF(gRokTr=="D","        *","")+"          *          * PRODAJE  *    %     *   Iznos  *    %     *   Iznos  *    %     *   Iznos  *  PRODAJE *          *"
? m

nTot1:=nTot1b:=nTot2:=nTot3:=nTot4:=nTot4b:=nTot5:=nTot6:=nTot7:=nTot8:=nTot8b:=0

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

    select ROBA; HSEEK PRIPR->IdRoba
    select TARIFA; HSEEK PRIPR->IdTarifa
    select PRIPR

    Tarifa(field->pkonto,field->idroba,@aPorezi)

    Marza2(); nMarza:=_marza   // izracunaj nMarza,nMarza2
    VTPorezi()

    if prow()>62+gPStranica; FF; @ prow(),180 SAY "Str:"+str(++nStr,3); endif

    aIPor:=RacPorezeMP(aPorezi,field->mpc,field->mpcSaPP,field->nc)
    nPor1:=aIPor[1]
    nPor2:=aIPor[2]

    nTot1+=  (nU1:= FCJ*Kolicina   )
    nTot1b+= (nU1b:= VPC*Kolicina  )
    nTot2+=  (nU2:= Prevoz*Kolicina   )
    nTot3+=  (nU3:= NC*kolicina )
    nTot4+=  (nU4:= nmarza*Kolicina )
    nTot4b+=  (nU4b:= nmarza2*Kolicina )
    nTot5+=  (nU5:= MPC*Kolicina )
    nTot6+=  (nU6:=(nPor1+nPor2)*Kolicina)
    nTot8+=  (nPor1*Kolicina)
    nTot8b+=  (nPor2*Kolicina)
    nTot7+=  (nU7:= MPcSaPP*Kolicina )

    @ prow()+1,0 SAY  Rbr PICTURE "999"
    ?? " "+IdRoba+" "+ROBA->naz+" "+ROBA->jmj
    if gRokTr=="D"; ?? " "+DTOC(RokTr); endif
    ?? " "+TRANSFORM(Kolicina,pickol)+" "+TRANSFORM(VPC,PicCDEM)
    ?? " "+TRANSFORM(vpc*kolicina,picdem)
    ?? " "+TRANSFORM(nmarza2*100/iif(vpc=0,999999999,vpc),picproc)+" "+TRANSFORM(nmarza2*kolicina,picdem)
    ?? " "+TRANSFORM(aPorezi[POR_PPP],picproc)+" "+TRANSFORM(npor1*kolicina,picdem)
    ?? " "+TRANSFORM(PrPPUMP(),picproc)+" "+TRANSFORM(npor2*kolicina,picdem)
    ?? " "+TRANSFORM(mpcsapp*kolicina,picdem)
    ?? " "+TRANSFORM(mpcsapp,piccdem)

    skip
enddo

if prow()>61+gPStranica; FF; @ prow(),180 SAY "Str:"+str(++nStr,3); endif

? m
? "UKUPNO:"+SPACE(75+if(gRokTr=="D",9,0))+TRANSFORM(nTot1b,PICDEM)
?? SPACE(12)+TRANSFORM(nTot4b,PICDEM)+SPACE(12)+TRANSFORM(nTot8,PICDEM)
?? SPACE(12)+TRANSFORM(nTot8b,PICDEM)+SPACE(1)+TRANSFORM(nTot7,PICDEM)
? m

gPStranica:=gPStranica+6
RekTarife()
gPStranica:=gPStranica-6

return
*}
