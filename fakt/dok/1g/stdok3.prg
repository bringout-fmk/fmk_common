#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/dok/1g/stdok3.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.5 $
 * $Log: stdok3.prg,v $
 * Revision 1.5  2002/09/16 08:57:51  mirsad
 * dokumentovanje INI parametara
 *
 * Revision 1.4  2002/09/16 08:49:49  mirsad
 * dokumentovanje INI parametara
 *
 * Revision 1.3  2002/07/04 08:34:19  mirsad
 * dokumentovanje ini parametara
 *
 * Revision 1.2  2002/06/18 13:01:05  sasa
 * no message
 *
 * Revision 1.1.1.1  2002/06/17 18:30:18  ernad
 * no message
 *
 *
 */
 

/*! \file fmk/fakt/dok/1g/stdok3.prg
 *  \brief Stampa faktura u varijanti 3
 */


/*! \ingroup ini
  * \var *string FmkIni_ExePath_FAKT_StampaViseDokumenata
  * \brief Da li se moze stampati vise od jednog dokumenta u pripremi ?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_ExePath_FAKT_StampaViseDokumenata;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_KupacDesno
  * \brief Da li se podaci o kupcu ispisuju uz desnu marginu dokumenta ?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_KumPath_FAKT_KupacDesno;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_I19jeOtpremnica
  * \brief Da li se i dokument tipa 19 tretira kao otpremnica ?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_KumPath_FAKT_I19jeOtpremnica;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_POREZI_PPUgostKaoPPU
  * \brief Odredjuje nacin obracuna poreza u maloprodaji (u ugostiteljstvu)
  * \param M - racuna PRUC iskljucivo koristeci propisani donji limit RUC-a, default vrijednost
  * \param R - racuna PRUC na osnovu stvarne RUC ili na osnovu pr.d.lim.RUC-a ako je stvarni RUC manji od propisanog limita
  * \param J - metoda koju koriste u Jerry-ju
  * \param D - racuna PPU a ne PRUC (stari sistem), s tim da se PP racuna na istu osnovicu kao i PPU
  * \param N - racuna PPU a ne PRUC (stari sistem), s tim da se PP racuna na istu osnovicu kao i PPP
  */
*string FmkIni_ExePath_POREZI_PPUgostKaoPPU;


/*! \fn StDok3()
 *  \brief Stampa fakture u varijanti 3
 *  \param cIdFirma
 *  \param cIdTipDok
 *  \param cBrDok
 */
 
function Stdok3()
*{
parameters cIdFirma,cIdTipDok,cBrDok
private i,nCol1:=0,cTxt1,cTxt2,aMemo,nMPVBP:=nVPVBP:=0
private cTi,nUk,nRab,nUk2:=nRab2:=0
private nStrana:=0,nCTxtR:=10

if pcount()==3
 O_Edit(.t.)
else
 O_Edit()
endif

cTI:="1"  // tip izvjestaja  1,2
O_PARAMS
private cSection:="1",cHistory:=" "; aHistory:={}
RPar("c1",@cTI)
select params; use

private M:="------ ---------- ---------- ---------------------------------------- --- ----------- ----------- ------ ---- -----------"


select PRIPR
if pcount()==0  // poziva se faktura iz pripreme
 IF gNovine=="D" .or. (IzFMKINI('FAKT','StampaViseDokumenata','N')=="D")
   FilterPrNovine()
 ENDIF
 cIdTipdok:=idtipdok;cIdFirma:=IdFirma;cBrDok:=BrDok
endif
seek cidfirma+cidtipdok+cbrdok
NFOUND CRET

aDbf:={ {"POR","C",10,0},;
          {"IZNOS","N",17,8} ;
         }
dbcreate2(PRIVPATH+"por",aDbf)
O_POR   // select 95
index  on BRISANO TAG "BRISAN"
index  on POR  TAG "1" ;  set order to tag "1"
select pripr

cIdFirma:=IdFirma
cBrDok:=BRDok
dDatDok:=DatDok
cIdTipDok:=IdTipDok
cidpartner:=Idpartner

cTxt1:=""
cTxt2:=""
cTxt3a:=""
cTxt3b:=""
cTxt3c:=""


if val(podbr)=0  .and. val(rbr)==1
   aMemo:=ParsMemo(txt)
   if len(aMemo)>0
     cTxt1:=padr(aMemo[1],40)
   endif
   if len(aMemo)>=5
    cTxt2:=aMemo[2]
    cTxt3a:=aMemo[3]
    cTxt3b:=aMemo[4]
    cTxt3c:=aMemo[5]
   endif
else
  Beep(2)
  Msg("Prva stavka mora biti  '1.'  ili '1 ' !",4)
  return
endif

// duzina slobodnog teksta
nLTxt2:=1
for i:=1 to len(cTxt2)
  if substr(cTxt2,i,1)=chr(13)
   ++nLTxt2
  endif
next
if idtipdok $ "10#11"; nLTxt2+=7; endif


POCNI STAMPU

P_10CPI
StZaglav2(gVlZagl,PRIVPATH)


// ---------------- MS 07.04.01
// ?? space(5);gPB_ON();?? padc(alltrim(cTxt3a),30);gPB_OFF(); ?? padl(Mjesto(cIdFirma)+", "+dtoc(datdok)+" godine",39)

aPom:=Sjecistr(cTxt3a,30)
IF IzFMKINI("FAKT","KupacDesno","N",KUMPATH)=="D"
  ?? space(5); ?? padr(Mjesto(cIdFirma)+", "+dtoc(datdok)+" godine",39); gPB_ON(); ?? padc(alltrim(aPom[1]),30); gPB_OFF()
  for i:=2 to len(aPom)
    ? space(5+39);gPB_ON();?? padc(alltrim(aPom[i]),30);gPB_OFF()
  next
  // ---------------- MS 07.04.01
  ?  space(5+39);gPB_ON();?? padc(alltrim(cTxt3b),30);gPB_OFF()
  ?  space(5+39);gPB_ON();?? padc(alltrim(cTxt3c),30);gPB_OFF()
ELSE
  ?? space(5);gPB_ON();?? padc(alltrim(aPom[1]),30);gPB_OFF(); ?? padl(Mjesto(cIdFirma)+", "+dtoc(datdok)+" godine",39)
  for i:=2 to len(aPom)
    ? space(5);gPB_ON();?? padc(alltrim(aPom[i]),30);gPB_OFF()
  next
  // ---------------- MS 07.04.01
  ?  space(5);gPB_ON();?? padc(alltrim(cTxt3b),30);gPB_OFF()
  ?  space(5);gPB_ON();?? padc(alltrim(cTxt3c),30);gPB_OFF()
ENDIF
cStr:=idtipdok+" "+trim(brdok)
cIdTipDok:=IdTipDok

private cpom:=""
if !(cIdTipDok $ "00#01#19")
 cPom:="G"+cidtipdok+"STR"
 cStr:=&cPom+" "+trim(BrDok)
elseif cIdTipDok=="19" .and. IzFMKIni("FAKT","I19jeOtpremnica","N",KUMPATH)=="D"
 cStr := "OTPREMNICA "+cStr
endif

IF IzFMKINI("FAKT","KupacDesno","N",KUMPATH)=="D"
  ?
  ShowIdPar(cIdPartner,44,.f.)
  ? SPACE(12)
  B_ON; ??  padc(cStr,50); B_OFF
ELSE
  ShowIdPar(cIdPartner,5,.t.)
  B_ON; ??  padl(cStr,39); B_OFF
ENDIF

for i:=1 to gOdvT2; ?; next

Zagl3()

nUk:=0
nRab:=0
nZaokr:=ZAOKRUZENJE
cDinDEM:=dindem

do while idfirma==cidfirma .and. idtipdok==cidtipdok .and. brdok==cbrdok .and. !eof()

   NSRNPIdRoba()   // Nastimaj (hseek) Sifr.Robe Na Pripr->IdRoba

   if alltrim(podbr)=="."   .or. roba->tip="U"
      aMemo:=ParsMemo(txt)
      cTxt1:=padr(aMemo[1],40)
   endif
   if roba->tip="U"
      cTxtR:=aMemo[1]
   endif
   select TARIFA; hseek roba->idtarifa
   select PRIPR

   if alltrim(podbr)=="."
    if prow()>gERedova+48-nLTxt2  // prelaz na sljedecu stranicu ?
      NStr0({|| Zagl3()})
    endif
    ? space(gnLMarg); ?? Rbr(),""
    ?? space(10),space(10),cTxt1,space(3),transform(kolicina,pickol)
    if cTI=="2"
       nRec:=recno()
       cRbr:=Rbr
       nUk2:=nRab2:=nPor2:=0
       do while !eof() .and. idfirma+idtipdok+brdok==cidfirma+cidtipdok+cbrdok.and. Rbr==cRbr
        if podbr=" ."
          skip; loop
        endif
        nUk2+=round(kolicina*cijena*Koef(cDinDem), nZaokr)
        nRab2+=round(kolicina*cijena*rabat/100*Koef(cDinDem) , nZaokr)
        nPor2+=round(kolicina*cijena*(1-rabat/100)*Porez/100*Koef(cDinDem) , nZaokr)
        skip
       enddo
       nPorez:=nPor2/(nUk2-nRab2)*100
       go nRec

       if nRab2*100/nUk2-int(nRab2*100/nUk2) <> 0
          cRab:=str(nRab2*100/nUk2,5,2)
       else
         cRab:=str(nRab2*100/nUk2,5,0)
       endif
       @ prow(),pcol()+1 SAY iif(kolicina==0,0,nUk2/kolicina) pict piccdem
       @ prow(),pcol()+1 SAY cRab+"%"
       if nporez-int(nporez)<>0
        cPor:=str(nporez,3,1)
       else
        cPor:=str(nporez,3,0)
       endif
       @ prow(),pcol()+1 SAY cPor+"%"
       nCol1:=pcol()+1
       @ prow(),pcol()+1 SAY nUk2 pict picdem

       if nPor2<>0
         select por
         if roba->tip="U"
          cPor:="PPU "+ str(nPorez,5,2)+"%"
         else
          cPor:="PPP "+ str(nPorez,5,2)+"%"
         endif
         seek cPor
         if !found(); append blank; replace por with cPor ;endif
         replace iznos with iznos+nPor2
         select pripr
       endif

    endif //tip=="2" - prikaz vrijednosti u . stavci
   else   // podbr nije "."
     if idtipdok $ "11#15#27"  // maloprodaja ili izlaz iz MP putem VP ili predr.MP
       select tarifa; hseek roba->idtarifa
       IF IzFMKINI("POREZI","PPUgostKaoPPU","D")=="D"
         nMPVBP:=pripr->(cijena*Koef(cDinDem)*kolicina)/(1+tarifa->zpp/100+tarifa->ppp/100)/(1+tarifa->opp/100)
       ELSE
         nMPVBP:=pripr->(cijena*Koef(cDinDem)*kolicina)/((1+tarifa->opp/100)*(1+tarifa->ppp/100)+tarifa->zpp/100)
       ENDIF
       if tarifa->opp<>0
         select por
         seek "PPP "+str(tarifa->opp,6,2)
         if !found(); append blank; replace por with "PPP "+str(tarifa->opp,6,2) ;endif
         replace iznos with iznos+nMPVBP*tarifa->opp/100
       endif
       if tarifa->ppp<>0
         select por
         seek "PPU "+str(tarifa->ppp,6,2)
         if !found(); append blank; replace por with "PPU "+str(tarifa->ppp,6,2); endif
         replace iznos with iznos+nMPVBP*(1+tarifa->opp/100)*tarifa->ppp/100
       endif
       if tarifa->zpp<>0
         select por
         seek "PP  "+str(tarifa->zpp,6,2)
         if !found(); append blank; replace por with "PP  "+str(tarifa->zpp,6,2); endif
         IF IzFMKINI("POREZI","PPUgostKaoPPU","D")=="D"
           replace iznos with iznos+nMPVBP*(1+tarifa->opp/100)*tarifa->zpp/100
         ELSE
           replace iznos with iznos+nMPVBP*tarifa->zpp/100
         ENDIF
       endif
       select pripr
     endif

    aSbr:=Sjecistr(serbr,10)
    if roba->tip="U"
     aTxtR:=SjeciStr(aMemo[1],40)   // duzina naziva + serijski broj
    else
     aTxtR:=SjeciStr(trim(roba->naz)+Katbr(),40)
    endif

    if prow()>gERedova+48-len(aSbr)-nLTxt2  // prelaz na sljedecu stranicu ?
      NStr0({|| Zagl3()})
    endif


    if porez-int(porez)<>0
        cPor:=str(porez,3,1)
    else
        cPor:=str(porez,3,0)
    endif


    ? space(gnLMarg); ?? Rbr(),idroba,padr(iif(roba->tip="U","",trim(tarifa->naz)),10)
    nCTxtR:=pcol()+1
    @ prow(),pcol()+1 SAY aTxtR[1]
    @ prow(),pcol()+1 SAY lower(ROBA->jmj)
    @ prow(),pcol()+1 SAY kolicina pict pickol
    if empty(podbr) .or. (!empty(podbr) .and. cTI=="1")
           @ prow(),pcol()+1 SAY cijena*Koef(cDinDem) pict piccdem
           if rabat-int(rabat) <> 0
               cRab:=str(rabat,5,2)
           else
              cRab:=str(rabat,5,0)
           endif
           if !idtipdok$"11#27"
             @ prow(),pcol()+1 SAY cRab+"%"
           else
             @ prow(),pcol()+1 SAY space(6)
           endif

           if porez-int(porez)<>0
             cPor:=str(porez,3,1)
           else
             cPor:=str(porez,3,0)
           endif
           @ prow(),pcol()+1 SAY cPor+"%"

           nCol1:=pcol()+1
           @ prow(),pcol()+1 SAY kolicina*cijena*Koef(cDinDem) pict picdem

           nPor2:=kolicina*Koef(cDinDem)*cijena*(1-rabat/100)*Porez/100

           if roba->tip="U"
             for i:=2 to len(aTxtR)
               @ prow()+1,nCTxtR  SAY aTxtR[i]
             next
           else
             for i:=2 to len(aSbr)
              @ prow()+1,nCTxtR  SAY aSbr[i]
             next
           endif

           if nPor2<>0
              select por
              if roba->tip="U"
               cPor:="PPU "+ str(pripr->Porez,5,2)+"%"
              else
               cPor:="PPP "+ str(pripr->Porez,5,2)+"%"
              endif
              seek cPor
              if !found(); append blank; replace por with cPor ;endif
              replace iznos with iznos+nPor2
              select pripr
           endif
    endif


    nUk+=  round( kolicina*cijena*Koef(cDinDem) , nZaokr)
    nRab+= round( kolicina*cijena*Koef(cDinDem)*rabat/100 , nZaokr)
   endif
   skip
enddo
nRab:=round(nRab,nZaokr)
nUk:= round(nUk, nZaokr)
? space(gnLMarg); ??  m

if nRab<>0
 ? space(gnLMarg); ??  padl("Ukupno ("+cDinDem+") :",98); @ prow(),nCol1 SAY nUk pict picdem
 if !cidtipdok$"11#27"
  ? space(gnLMarg); ??  padl("Rabat ("+cDinDem+") :",98);  @ prow(),nCol1 SAY nRab pict picdem
 endif
endif

cPor:=""
nPor2:=0
if !cidtipdok$"11#27"
 select por
 go top
 do while !eof()  // string poreza
  ? space(gnLMarg); ?? padl(trim(por)+":",98); @ prow(),nCol1 SAY round(IF(cIdTipDok=="15",-1,1)*iznos,nZaokr) pict picdem
  nPor2+=round(Iznos,nZaokr)
  skip
 enddo
 nPor2 := IF(cIdTipDok=="15",-1,1) * nPor2
endif

nFZaokr:=round(nUk-nRab+nPor2,nZaokr)-round2(round(nUk-nRab+nPor2,nZaokr),gFZaok)
if gFZaok<>9 .and. round(nFzaokr,4)<>0
 ? space(gnLMarg); ?? padl("Zaokruzenje:",98); @ prow(),nCol1 SAY nFZaokr pict picdem
endif


? space(gnLMarg); ??  m
? space(gnLMarg); ??  padl("U K U P N O  ("+cDinDem+") :",98); @ prow(),nCol1 SAY round(nUk-nRab+nPor2-nFzaokr,nzaokr) pict picdem
if !empty(picdem)
 ? space(gnLmarg); ?? "slovima: ",Slovima(round(nUk-nRab+nPor2-nFZaokr,nZaokr),cDinDem)
else
 ?
endif
? space(gnLMarg); ?? m
?
ctxt2:=strtran(ctxt2,"ç"+Chr(10),"")
ctxt2:=strtran(ctxt2,Chr(13)+Chr(10),Chr(13)+Chr(10)+space(gnLMarg))
? space(gnLMarg); ?? ctxt2
?
if cidtipdok$"11#27"
 select por ; go top
 ? space(gnLMarg); ?? "- Od toga porez: ----------"
 nUkPorez:=0
 do while !eof()
  ? space(gnLMarg); ?? por+"%   :"
  @ prow(),pcol()+1 SAY iznos pict  "9999999.999"
  nukporez+=iznos
  skip
 enddo
 ? space(gnLMarg); ?? "Ukupno :  "+space(5)
 @ prow(),pcol()+1 SAY nUkPorez pict "9999999.999"
 ? space(gnLMarg); ?? "---------------------------"
 select pripr
select por; use
endif
?
?
P_12CPI

PrStr2T(cIdTipDok)

FF

ZAVRSI STAMPU

closeret
*}


/*! \fn Zagl3()
 *  \brief Stampa zaglavlja za varijantu 3
 */
 
function Zagl3()
*{
P_COND
? space(gnLMarg); ?? m
? space(gnLMarg); ?? " R.br   Sifra    Tarifa u MP         Naziv                            jmj   kolicina      Cijena   Rabat  Por    Ukupno"
? space(gnLMarg); ?? m
return
*}


