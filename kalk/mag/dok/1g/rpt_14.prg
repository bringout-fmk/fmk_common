#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/mag/dok/1g/rpt_14.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.2 $
 * $Log: rpt_14.prg,v $
 * Revision 1.2  2002/06/20 13:13:03  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/mag/dok/1g/rpt_14.prg
 *  \brief Stampa dokumenta tipa 14
 */


/*! \fn StKalk14()
 *  \brief Stampa kalkulacije 14
 */

function StKalk14()
*{
local nCol1:=nCol2:=0,npom:=0

Private nPrevoz,nCarDaz,nZavTr,nBankTr,nSpedTr,nMarza,nMarza2
// iznosi troskova i marzi koji se izracunavaju u KTroskovi()

nStr:=0
cIdPartner:=IdPartner; cBrFaktP:=BrFaktP; dDatFaktP:=DatFaktP
dDatKurs:=DatKurs; cIdKonto:=IdKonto; cIdKonto2:=IdKonto2
P_10CPI
B_ON
if cidvd=="14".or.cidvd=="74"
  ?? "IZLAZ KUPCU PO VELEPRODAJI"
elseif cidvd=="15"
  ?? "OBRACUN VELEPRODAJE"
else
  ?? "STORNO IZLAZA KUPCU PO VELEPRODAJI"
endif
?
B_OFF
P_COND
??
? "KALK BR:",  cIdFirma+"-"+cIdVD+"-"+cBrDok,", Datum:",DatDok
@ prow(),125 SAY "Str:"+str(++nStr,3)
select PARTN; HSEEK cIdPartner

?  "KUPAC:",cIdPartner,"-",naz,SPACE(5),"DOKUMENT Broj:",cBrFaktP,"Datum:",dDatFaktP

if cidvd=="94"
 select konto; hseek cidkonto2
 ?  "Storno razduzenja KONTA:",cIdKonto,"-",naz
else
 select konto; hseek cidkonto2
 ?  "KONTO razduzuje:",pripr->mkonto , "-",naz
 if !empty(pripr->Idzaduz2); ?? " Rad.nalog:",pripr->Idzaduz2; endif
endif

select PRIPR
select koncij; seek trim(pripr->mkonto); select pripr
m:="--- ---------- ---------- ----------  ---------- ---------- ---------- ----------- --------- ----------"
if !(koncij->naz="P")
 m+=" ---------- ----------"
endif
if gMagacin=="1" ;m+=" ----------";endif

if koncij->naz="P2"
  m+=" ----------"
endif
? m

if koncij->naz=="P1"
   ? "*R * ROBA     * Kolicina *  C.KOST  *  Marza   *  Prod.Cj *  RABAT    *P.C-RABAT*   PPP    * P.C+PPP  *"
   ? "*BR*          *          *          *          *          *          *          *           *         *"
elseif koncij->naz=="P2"
   ? "*R * ROBA     * Kolicina *  C.KOST  *  Marza   *  Prod.Cj *  RABAT    * Prod.C  *   PPP    * Prod.C   *  Planska *"
   ? "*BR*          *          *          *          *          *           * -Rabat  *          * + PPP    *  Cijena  *"
else

 if gVarVP=="2"
   ? "*R * ROBA     * Kolicina *  NABAV.  *   RUC    *   PRUC   * RUC+PRUC *   VPC    *  RABAT    *VPC-RABAT*   PPP    * VPC+PPP  *"+iif(gmagacin=="1"," VPC+PPP  *","")
 else
   ? "*R * ROBA     * Kolicina *  NABAV.  *   RUC    *   PRUC   * RUC-PRUC *   VPC    *  RABAT    *VPC-RABAT*   PPP    * VPC+PPP  *"+iif(gmagacin=="1"," VPC+PPP  *","")
 endif

   ? "*BR*          *          *  CJENA   *          *          *          *          *           *         *          *          *"+iif(gmagacin=="1","  +PRUC   *","")

endif  // P1,P2
? m
nTot4:=nTot5:=nTot6:=nTot7:=nTot8:=nTot9:=nTota:=ntotb:=ntotc:=nTotd:=0

fNafta:=.f.

private cIdd:=idpartner+brfaktp+idkonto+idkonto2
do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD

    // !!!!!!!!!!!!!!!
    if idpartner+brfaktp+idkonto+idkonto2<>cidd
     set device to screen
     Beep(2)
     Msg("Unutar kalkulacije se pojavilo vise dokumenata !",6)
     set device to printer
    endif

    select ROBA; HSEEK PRIPR->IdRoba
    select TARIFA; HSEEK PRIPR->IdTarifa
    select PRIPR

    KTroskovi()

    if prow()>62+gPStranica; FF; @ prow(),125 SAY "Str:"+str(++nStr,3); endif

    if pripr->idvd="15"
      SKol:= - Kolicina
    else
      SKol:=Kolicina
    endif

    nVPCIzbij:=0
    if roba->tip=="X"
      nVPCIzbij:=(MPCSAPP/(1+tarifa->opp/100)*tarifa->opp/100)
    endif

    nTot4+=  (nU4:=round(NC*Kolicina*iif(idvd="15",-1,1) ,gZaokr)     )  // nv
    if gVarVP=="1"
      if (roba->tip $ "UTY")
        nU5:=0
      else
        nTot5+=  (round(nU5:=nMarza*Kolicina*iif(idvd="15",-1,1),gZaokr)  ) // ruc
      endif
      nTot6+=  (nU6:=round(TARIFA->VPP/100*iif(nMarza<0,0,nMarza)*Kolicina*iif(idvd="15",-1,1),gZaokr) )  //pruc
      nTot7+=  (nU7:=nU5-nU6  )    // ruc-pruc
    else
      // obracun poreza unazad - preracunata stopa
      if (roba->tip $ "UTY")
        nU5:=0
      else
      if nMarza>0
        (nU5:=round(nMarza*Kolicina*iif(idvd="15",-1,1)/(1+tarifa->vpp/100),gZaokr)) // ruc
      else
        (nU5:=round(nMarza*Kolicina*iif(idvd="15",-1,1),gZaokr)) // ruc
      endif
      endif

      nU6:=round(TARIFA->VPP/100/(1+tarifa->vpp/100) * iif(nMarza<0,0,nMarza)*Kolicina*iif(idvd="15",-1,1),gZaokr)
      //nU6 = pruc

      // franex 20.11.200 nasteliti ruc + pruc = bruto marza !!
      if round(nMarza*Kolicina*iif(idvd="15",-1,1),gZaokr) > 0 // pozitivna marza
        nU5 :=  round(nMarza*Kolicina*iif(idvd="15",-1,1),gZaokr)  - nU6
                 //  bruto marza               - porez na ruc
      endif
      nU7:=nU5+nU6      // ruc+pruc

      nTot5+= nU5
      nTot6+= nU6
      nTot7+= nU7

    endif

    nTot8+=  (nU8:=round( (VPC-nVPCIzbij)*Kolicina*iif(idvd="15",-1,1),gZaokr)       )

    nTot9+=  (nU9:=round(RABATV/100*VPC*Kolicina*iif(idvd="15",-1,1),gZaokr)  )

    if roba->tip=="X"
      // kod nafte prikazi bez poreza
      nTota+=  (nUa:=round(nU8-nU9,gZaokr))
      fnafta:=.t.
    else
      nTota+=  (nUa:=round(nU8-nU9,gZaokr))     // vpv sa ukalk rabatom
    endif
    if roba->tip=="X"
       nTotb:=nUb:=0
       nTotc+=  (nUc:=round(VPC*kolicina*iif(idvd="15",-1,1),gzaokr))   // vpv+ppp
    else
       if idvd=="15" // kod 15-ke nema poreza na promet
         nUb:=0
       else
         nUb:=round(nUa*mpc/100,gZaokr) // ppp
       endif
       nTotb+=  nUb
       nTotc+=  (nUc:=nUa+nUb )   // vpv+ppp
    endif

    if koncij->naz="P"
     nTotd+=  (nUd:=round(fcj*kolicina*iif(idvd="15",-1,1),gZaokr) )  // trpa se planska cijena
    else
     nTotd+=  (nUd:=nua+nub+nu6 )   //vpc+pornapr+pornaruc
    endif

    @ prow()+1,0 SAY  Rbr PICTURE "999"
    @ prow(),4 SAY  ""; ?? trim(ROBA->naz),"(",ROBA->jmj,")"
    if gRokTr=="D"; ?? space(4),"Rok Tr.:",RokTr; endif
    IF lPoNarudzbi
      IspisPoNar(.f.)
    ENDIF
    @ prow()+1,4 SAY IdRoba
    @ prow(),pcol()+1 SAY Kolicina*iif(idvd="15",-1,1)  PICTURE PicKol
    nC1:=pcol()+1
    @ prow(),pcol()+1 SAY NC                          PICTURE PicCDEM
    private nNc:=0
    if nc<>0
      nNC:=nc
    else
      nNC:=99999999
    endif
    if !(koncij->naz="P")
      @ prow(),pcol()+1 SAY nMarza/nNC*100              PICTURE PicProc
      @ prow(),pcol()+1 SAY tarifa->vpp                 PICTURE PicProc
      @ prow(),pcol()+1 SAY nMarza*(1-iif(nMarza<0,0,tarifa->vpp/100))/nNC*100  PICTURE Picproc
    else
      @ prow(),pcol()+1 SAY (VPC-nNC)/nNC*100               PICTURE PicProc
    endif
    @ prow(),pcol()+1 SAY VPC-nVPCIzbij       PICTURE PiccDEM
    @ prow(),pcol()+1 SAY RABATV              PICTURE PicProc
    @ prow(),pcol()+1 SAY VPC*(1-RABATV/100)-nVPCIzbij  PICTURE PiccDEM
    if roba->tip $ "VKX"
     @ prow(),pcol()+1 SAY padl("VT-"+str(tarifa->opp,5,2)+"%",len(picproc))
    else
     if idvd = "15"
        @ prow(),pcol()+1 SAY 0          PICTURE PicProc
     else
        @ prow(),pcol()+1 SAY MPC        PICTURE PicProc
     endif
    endif

    if roba->tip="X"  // nafta , kolona VPC SA PP
     @ prow(),pcol()+1 SAY VPC PICTURE PicCDEM
    else
     @ prow(),pcol()+1 SAY VPC*(1-RabatV/100)*(1+mpc/100) PICTURE PicCDEM
    endif

    if koncij->naz="P2"
      @ prow(),pcol()+1 SAY  FCJ pict piccdem
    else
      if gmagacin=="1"
       @ prow(),pcol()+1 SAY VPC*(1-RabatV/100)*(1+mpc/100)+nMarza*tarifa->vpp/100 PICTURE PicCDEM
      endif
    endif
    @ prow()+1,4 SAY IdTarifa+roba->tip
     @ prow(),nC1    SAY nU4  pict picdem
    if !(koncij->naz="P")
     @ prow(),pcol()+1 SAY nu5  pict picdem
     @ prow(),pcol()+1 SAY nU6  pict picdem
     @ prow(),pcol()+1 SAY nU7  pict picdem
    else
     @ prow(),pcol()+1 SAY nu8-nU4  pict picdem
    endif
    @ prow(),pcol()+1 SAY nu8  pict picdem
    @ prow(),pcol()+1 SAY nU9  pict picdem
    @ prow(),pcol()+1 SAY nUA  pict picdem
    @ prow(),pcol()+1 SAY nub  pict picdem
    @ prow(),pcol()+1 SAY nUC  pict picdem
    if koncij->naz="P2"
       @ prow(),pcol()+1 SAY nUd  pict picdem  // planska cijena
    else
      if gmagacin=="1"
        @ prow(),pcol()+1 SAY nUd  pict picdem
      endif
    endif

    skip

enddo

if prow()>61+gPStranica; FF; @ prow(),125 SAY "Str:"+str(++nStr,3); endif
? m
@ prow()+1,0        SAY "Ukupno:"
@ prow(),nc1      SAY nTot4  pict picdem
if !(koncij->naz="P")
  @ prow(),pcol()+1 SAY ntot5  pict picdem
  @ prow(),pcol()+1 SAY nTot6  pict picdem
  @ prow(),pcol()+1 SAY nTot7  pict picdem
else
  @ prow(),pcol()+1 SAY ntot8-nTot4  pict picdem
endif
@ prow(),pcol()+1 SAY ntot8  pict picdem
@ prow(),pcol()+1 SAY ntot9  pict picdem
@ prow(),pcol()+1 SAY nTotA  pict picdem
@ prow(),pcol()+1 SAY nTotB  pict picdem
@ prow(),pcol()+1 SAY nTotC  pict picdem
if koncij->naz="P2"
 @ prow(),pcol()+1 SAY nTotd  pict picdem
else
 if gmagacin=="1"
   @ prow(),pcol()+1 SAY nTotd  pict picdem
 endif
endif

? m

if fnafta
?
? "Napomena: PP se obracunava na osnovu definisane tekuce MP cijene !"
endif

return
*}



/*! \fn StKalk14_3()
 *  \brief Stampa kalkulacije 14 - varijanta za A3 papir
 */
 
function StKalk14_3()
*{
LOCAL i:=0,aNiz
Private nPrevoz:=0,nCarDaz:=0,nZavTr:=0,nBankTr:=0,nSpedTr:=0,nMarza:=0,nMarza2:=0
// iznosi troskova i marzi koji se izracunavaju u KTroskovi()

cIdPartner:=IdPartner; cBrFaktP:=BrFaktP; dDatFaktP:=DatFaktP
dDatKurs:=DatKurs; cIdKonto:=IdKonto; cIdKonto2:=IdKonto2
P_10CPI
B_ON
if cidvd=="14".or.cidvd=="74"
  ?? "IZLAZ KUPCU PO VELEPRODAJI"
else
  ?? "STORNO IZLAZA KUPCU PO VELEPRODAJI"
endif
?
B_OFF; P_COND
??
? "KALK BR:",  cIdFirma+"-"+cIdVD+"-"+cBrDok,", Datum:",DatDok
select PARTN; HSEEK cIdPartner

?  "KUPAC:",cIdPartner,"-",naz,SPACE(5),"DOKUMENT Broj:",cBrFaktP,"Datum:",dDatFaktP

if cidvd=="94"
 select konto; hseek cidkonto2
 ?  "Storno razduzenja KONTA:",cIdKonto,"-",naz
else
 select konto; hseek cidkonto2
 ?  "KONTO razduzuje:",pripr->mkonto,"-",naz
endif

select PRIPR

PRIVATE cIdd:=idpartner+brfaktp+idkonto+idkonto2, nNc:=99999999
PRIVATE nU4:=0, nU5:=0, nU6:=0, nU7:=0, nU8:=0, nU9:=0, nUA:=0, nUB:=0
PRIVATE nUC:=0, nUD:=0
i:=0
aNiz:= { {"R."        , {|| rbr}      , .f., "C",  3, 0, 1, ++i},;
         {"br."       , {|| "#"}      , .f., "C",  3, 0, 2,   i},;
         {"[ifra"     , {|| idroba}   , .f., "C", 10, 0, 1, ++i},;
         {"robe"      , {|| "#"}      , .f., "C", 10, 0, 2,   i},;
         {"Naziv robe", {|| ROBA->naz}, .f., "P", 30, 0, 1, ++i},;
         {"J."        , {|| ROBA->jmj}, .f., "C",  3, 0, 1, ++i},;
         {"mj."       , {|| "#"}      , .f., "C",  3, 0, 2,   i},;
         {"Tarifa"    , {|| PADC(ALLTRIM(idtarifa)+ROBA->tip,7)},;
                                        .f., "C",  7, 0, 1, ++i}  }
IF gRokTr=="D"
 AADD(aNiz, {"Rok tr.", {|| roktr}         , .f., "D",  8, 0, 1, ++i} )
ENDIF
AADD(aNiz, {"Koli~ina", {|| kolicina}      , .f., "N", 12, 3, 1, ++i} )
AADD(aNiz, {"Nabavna" , {|| nc}            , .f., "N",  9, 2, 1, ++i} )
AADD(aNiz, {"cijena"  , {|| "#"}           , .f., "C",  9, 0, 2,   i} )
AADD(aNiz, {"Nabavna" , {|| nU4}           , .t., "N",  9, 2, 1, ++i} )
AADD(aNiz, {"vrijed-" , {|| "#"}           , .f., "C",  9, 0, 2,   i} )
AADD(aNiz, {"nost"    , {|| "#"}           , .f., "C",  9, 0, 3,   i} )
AADD(aNiz, {"Razl.u"  , {|| nMarza/nNC*100}, .f., "N",  6, 2, 1, ++i} )
AADD(aNiz,{"cijeni"    ,{|| "#"}           , .f., "C",  6, 0, 2,   i} )
AADD(aNiz, {"RUC(%)"  , {|| "#"}           , .f., "C",  6, 0, 3,   i} )
AADD(aNiz, {"Iznos"   , {|| nU5}           , .t., "N",  9, 2, 1, ++i} )
AADD(aNiz, {"razlike" , {|| "#"}           , .f., "C",  9, 0, 2,   i} )
AADD(aNiz, {"u cijeni", {|| "#"}           , .f., "C",  9, 0, 3,   i} )
AADD(aNiz, {"Porez"   , {|| tarifa->vpp}   , .f., "N",  6, 2, 1, ++i} )
AADD(aNiz, {"na RUC"  , {|| "#"}           , .f., "C",  6, 0, 2,   i} )
AADD(aNiz, {"(%)"     , {|| "#"}           , .f., "C",  6, 0, 3,   i} )
AADD(aNiz, {"Iznos"   , {|| nU6}           , .t., "N",  9, 2, 1, ++i} )
AADD(aNiz, {"poreza"  , {|| "#"}           , .f., "C",  9, 0, 2,   i} )
AADD(aNiz, {"na RUC"  , {|| "#"}           , .f., "C",  9, 0, 3,   i} )
AADD(aNiz, {"RUC"+if(gVarVP=="2","+","-")+"PRUC",;
 {|| nMarza*(1-iif(nMarza<0,0,tarifa->vpp/100))/nNC*100},;
                                             .f., "N",  9, 2, 1, ++i} )
AADD(aNiz, {"Iznos",{|| nU7},                .t., "N",  9, 2, 1, ++i} )
AADD(aNiz, {"RUC"+if(gVarVP=="2","+","-")+"PRUC",;
                         {|| "#"}          , .f., "C",  9, 0, 2,   i} )
AADD(aNiz, {"Veleprod.", {|| vpc          }, .f., "N",  9, 2, 1, ++i} )
AADD(aNiz, {"cijena"   , {|| "#"}          , .f., "C",  9, 0, 2,   i} )
AADD(aNiz, {"Veleprod.", {|| nU8          }, .t., "N",  9, 2, 1, ++i} )
AADD(aNiz, {"iznos"    , {|| "#"}          , .f., "C",  9, 0, 2,   i} )
AADD(aNiz, {"Rabat"    , {|| rabatv       }, .f., "N",  6, 2, 1, ++i} )
AADD(aNiz, {"(%)"      , {|| "#"}          , .f., "C",  6, 0, 2,   i} )
AADD(aNiz, {"Iznos"    , {|| nU9          }, .t., "N",  9, 2, 1, ++i} )
AADD(aNiz, {"rabata"   , {|| "#"}          , .f., "C",  9, 0, 2,   i} )
AADD(aNiz, {"VPC-rabat", {|| vpc*(1-rabatv/100)},;
                                             .f., "N",  9, 2, 1, ++i} )
AADD(aNiz, {"Iznos"    , {|| nUA},           .t., "N",  9, 2, 1, ++i} )
AADD(aNiz, {"VPC-rabat", {|| "#"}          , .f., "C",  9, 0, 2,   i} )
AADD(aNiz, {"Porez"    ,;
 {|| if(roba->tip $ "VKX","VT-"+str(tarifa->opp,5,2)+"%",STR(mpc,9,2))},;
                                             .f., "C",  9, 0, 1, ++i} )
AADD(aNiz, {"na PP"    , {|| "#"}          , .f., "C",  9, 0, 2,   i} )
AADD(aNiz, {"(%)"      , {|| "#"}          , .f., "C",  9, 0, 3,   i} )
AADD(aNiz, {"Iznos"    , {|| nUB},           .t., "N",  9, 2, 1, ++i} )
AADD(aNiz, {"poreza"   , {|| "#"}          , .f., "C",  9, 0, 2,   i} )
AADD(aNiz, {"na PP"    , {|| "#"}          , .f., "C",  9, 0, 3,   i} )
AADD(aNiz, {"VPC+porez",;
        {|| VPC*(1-RabatV/100)*(1+mpc/100)}, .f., "N",  9, 2, 1, ++i} )
AADD(aNiz, {"na PP"    , {|| "#"}          , .f., "C",  9, 0, 2,   i} )
AADD(aNiz, {"Iznos"    , {|| nUC}          , .t., "N",  9, 2, 1, ++i} )
AADD(aNiz, {"VPC+porez", {|| "#"}          , .f., "C",  9, 0, 2,   i} )
AADD(aNiz, {"na PP"    , {|| "#"}          , .f., "C",  9, 0, 3,   i} )
IF gmagacin=="1"
 AADD(aNiz, {"VPC+porez",;
	{|| VPC*(1-RabatV/100)*(1+mpc/100)+nMarza*tarifa->vpp/100},;
                                             .f., "N", 10, 2, 1, ++i} )
 AADD(aNiz, {"na PP+por."    , {|| "#"}    , .f., "C", 10, 0, 2,   i} )
 AADD(aNiz, {"na RUC"        , {|| "#"}    , .f., "C", 10, 0, 3,   i} )
 AADD(aNiz, {"Iznos VPC+"    , {|| nUD}    , .t., "N", 10, 2, 1, ++i} )
 AADD(aNiz, {"por.na PP+"    , {|| "#"}    , .f., "C", 10, 0, 2,   i} )
 AADD(aNiz, {"por.na RUC"    , {|| "#"}    , .f., "C", 10, 0, 3,   i} )
ENDIF

  StampaTabele(aNiz,;
	      {|| Blok14_3()},;
              ,;
              gTabela,;                      // tip tabele
	      {|| cIdFirma==IdFirma.and.cBrDok==BrDok.and.cIdVD==IdVD},;  // "while" blok
              "3",;     // tip papira .t.-A4, .f.-A3, "POS"-40 zn. u redu
              ,;
              {|| .t.},;                 // "for" blok
              1,;
              ,;
              .f.,;
              ,;
              ,;
              ,.f.)                  // ne centrirati tabelu
return
*}



/*! \fn Blok14_3()
 *  \brief Koristi je StampaTabele() u StKalk14_3()
 */
function Blok14_3()
*{
    // !!!!!!!!!!!!!!!
    if idpartner+brfaktp+idkonto+idkonto2<>cidd
     set device to screen
     Beep(2)
     Msg("Unutar kalkulacije se pojavilo vise dokumenata !",6)
     set device to printer
    endif

    select ROBA; HSEEK PRIPR->IdRoba
    select TARIFA; HSEEK PRIPR->IdTarifa
    select PRIPR

    KTroskovi()

    SKol:=Kolicina

    nU4:=round( NC*Kolicina ,gZaokr)      // nv
    if gVarVP=="1"
      if (roba->tip $ "UT")
        nU5:=0
      else
        nU5:=round( nMarza*Kolicina ,gZaokr)  // ruc
      endif
      nU6:=round( TARIFA->VPP/100*iif(nMarza<0,0,nMarza)*Kolicina,gZaokr)   //pruc
      nU7:=nU5-nU6	// ruc-pruc
    else
      if (roba->tip $ "UT")
        nU5:=0
      else
       if nMarza>0
         nU5:=round(nMarza*Kolicina*1/(1+tarifa->vpp/100),gZaokr) // ruc
       else
         nU5:=round(nMarza*Kolicina,gZaokr) // ruc
       endif
      endif
      nU6:=round( TARIFA->VPP/100/(1+tarifa->vpp/100) * iif(nMarza<0,0,nMarza)*Kolicina ,gZaokr)  //pruc
      nU7:=nU5+nU6	// ruc+pruc
    endif
    nU8:=round( VPC*Kolicina ,gZaokr)
    nU9:=round( RABATV/100*VPC*Kolicina ,gZaokr)
    nUa:=nU8-nU9     // vpv sa ukalk rabatom
    if idvd="15"
     nUb:=0
    else
     nUb:=nUa*mpc/100   // ppp
    endif

    nUc:=nUa+nUb    // vpv+ppp
    nUd:=nua+nub+nu6	//vpc+pornapr+pornaruc

    if nc<>0
      nNC:=nc
    else
      nNC:=99999999
    endif
return .t.
*}

