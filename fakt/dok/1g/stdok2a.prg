#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/dok/1g/stdok2a.prg,v $
 * $Author: sasa $ 
 * $Revision: 1.2 $
 * $Log: stdok2a.prg,v $
 * Revision 1.2  2002/06/18 13:01:05  sasa
 * no message
 *
 * Revision 1.1.1.1  2002/06/17 18:30:18  ernad
 * no message
 *
 *
 */

/*! \file fmk/fakt/dok/1g/stdok2a.prg
 *  \brief Stampa faktura u varijanti 2 a
 */
 
/*! \fn StDok2a()
 *  \brief Stampa fakture u varijanti 2 a 
 *  \param cIdFirma 
 *  \param cIdTipDok
 *  \param cBrDok
 */
 
function StDok2a()
*{
parameters cIdFirma,cIdTipDok,cBrDok
private i,nCol1:=0,cTxt1,cTxt2,aMemo,nMPVBP:=nVPVBP:=0
private cTi,nUk,nRab,nUk2:=nRab2:=0
private nStrana:=0,nCTxtR:=10

if gFormatA5<>"0" .and. Pitanje(,"Format izvjestaja A5 (D/N) ? ",gFormatA5)=="D"
  gFormatA5:="D"
  if pcount()==3
     stdok295(cidfirma,cidtipdok,cbrdok)
  else
     stdok295()
  endif
  return
else
//  gFormatA5:="N"
  nDuzForm:=53
endif


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

private M:=" ----- ---------- ------------------------------------------ -------- ---------- ------------------- ------------------"


select PRIPR
if pcount()==0  // poziva se faktura iz pripreme
 IF gNovine=="D"
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

if cidtipdok$"11#27"
 private m:="------ ---------- ---------------------------------------- ------- ------ ------- ----------- --- ----------- -----------"
endif

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
nDuzMemo:=nLtxt2
if idtipdok $ "10#11"; nLTxt2+=7; endif


POCNI STAMPU

P_10CPI

for i:=1 to gnTMarg  // Top Margina
  ?
next

cStr:=idtipdok+" "+trim(brdok)
cIdTipDok:=IdTipDok
private cpom:=""
if !(cIdTipDok $ "00#01#19")
 cStr:=trim(BrDok)
endif
? SPACE(38+gFPzag)
B_ON; Krizaj2a(); B_OFF

?
?
?  space(7+gFPzag)+gPB_ON+padc(alltrim(cTxt3a),30)+gPB_OFF; ?? padl(dtoc(datdok),38)
?  space(7+gFPzag)+gPB_ON+padc(alltrim(cTxt3b),30)+gPB_OFF
?  space(7+gFPzag)+gPB_ON+padc(alltrim(cTxt3c),30)+gPB_OFF


nUk:=0
nRab:=0
nZaokr:=ZAOKRUZENJE
cDinDEM:=dindem

FOR i:=1 TO gnTmarg2; ?; NEXT
P_COND
do while idfirma==cidfirma .and. idtipdok==cidtipdok .and. brdok==cbrdok .and. !eof()

   NSRNPIdRoba()   // Nastimaj (hseek) Sifr.Robe Na Pripr->IdRoba

   if alltrim(podbr)=="."   .or. roba->tip="U"
      aMemo:=ParsMemo(txt)
      cTxt1:=padr(aMemo[1],40)
   endif
   if roba->tip="U"
      cTxtR:=aMemo[1]
   endif
   if alltrim(podbr)=="."
    if prow()>gERedova+nDuzForm-nLTxt2  // prelaz na sljedecu stranicu ?
      NStr0({|| Zagl2a()})
    endif
    ? space(gnLMarg); ?? Rbr(),""
    ?? cTxt1,space(10),transform(kolicina,pickol),space(3)

    if cTI=="2"
       nRec:=recno()
       cRbr:=Rbr
       nUk2:=nRab2:=nPor2:=0
       do while !eof() .and. idfirma+idtipdok+brdok==cidfirma+cidtipdok+cbrdok .and. Rbr==cRbr
        if podbr=" ."
          skip; loop
        endif
        nUk2+=round(kolicina*cijena*Koef(cDinDem), nZaokr)
        nRab2+=round(kolicina*cijena*rabat/100*Koef(cDinDem) , nZaokr)
        nPor2+=round(kolicina*cijena*(1-rabat/100)*Porez/100*Koef(cDinDem), nZaokr)
        skip
       enddo
       nPorez:=nPor2/(nUk2-nRab2)*100
       go nRec

       if nRab2*100/nUk2-int(nRab2*100/nUk2) <> 0
          cRab:=str(nRab2*100/nUk2,5,2)
       else
         cRab:=str(nRab2*100/nUk2,5,0)
       endif
       @ prow(),pcol()+1 SAY iif(kolicina==0,0,nUk2/kolicina) pict picdem
       @ prow(),pcol()+1 SAY cRab+"%"
       @ prow(),pcol()+1 SAY iif(kolicina<>0,(nUk2-nRab2)/kolicina,0) pict picdem
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
     if idtipdok$"11#27"  // maloprodaja
       select tarifa; hseek roba->idtarifa
       nMPVBP:=pripr->(cijena*Koef(cDinDem)*kolicina)/(1+tarifa->ppp/100)/(1+tarifa->opp/100)
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
        select pripr
     endif

    aSbr:=Sjecistr(serbr,10)
    if roba->tip="U"
     aTxtR:=SjeciStr(aMemo[1],42)   // duzina naziva + serijski broj
    else
     aTxtR:=SjeciStr(trim(roba->naz)+Katbr(),42)
    endif

    if prow()>gERedova+nDuzForm-len(aSbr)-nLTxt2  // prelaz na sljedecu stranicu ?
      NStr0({|| Zagl2a()})
    endif

    if porez-int(porez)<>0
        cPor:=str(porez,3,1)
    else
        cPor:=str(porez,3,0)
    endif

    ? space(gnLMarg-3); ?? Rbr(),idroba
    nCTxtR:=pcol()+1
    @ prow(),nCTxtR SAY aTxtR[1]+" "
    if !cidtipdok$"11#27"
    else
      nCTxtR:=pcol()+1
      @ prow(),pcol()+1 SAY roba->idtarifa
      select tarifa;hseek roba->idtarifa
      @ prow(),pcol()+1 SAY tarifa->opp pict "9999.9%"
      @ prow(),pcol()+2 SAY tarifa->ppp pict "999.9%"
      select pripr
    endif
    @ prow(),pcol()+1 SAY PADC(lower(ROBA->jmj),7)
    @ prow(),pcol() SAY kolicina pict pickol
    ?? " "
    if empty(podbr) .or. (!empty(podbr) .and. cTI=="1")
           @ prow(),pcol()+1 SAY PADL(TRANSFORM(cijena*Koef(cDinDem),picdem),18)
           if rabat-int(rabat) <> 0
               cRab:=str(rabat,5,2)
           else
              cRab:=str(rabat,5,0)
           endif
           if !cidtipdok$"11#27"
//             @ prow(),pcol()+1 SAY cRab+"%"
//             @ prow(),pcol()+1 SAY cijena*(1-rabat/100)*Koef(cDinDem)  pict picdem
             if porez-int(porez)<>0
               cPor:=str(porez,3,1)
             else
               cPor:=str(porez,3,0)
             endif
//             @ prow(),pcol()+1 SAY cPor+"%"
           else
             //@ prow(),pcol()+1 SAY space(6)
           endif


           nCol1:=pcol()+1
           @ prow(),pcol()+1 SAY PADL(TRANSFORM(kolicina*cijena*Koef(cDinDem),picdem),18)

           nPor2:=kolicina*Koef(cDinDem)*cijena*(1-rabat/100)*Porez/100

           if roba->tip="U"
             for i:=2 to len(aTxtR)
               @ prow()+1,nCTxtR  SAY aTxtR[i]+" "
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


    nUk+=round (kolicina*cijena*Koef(cDinDem), nZaokr)
    nRab+=round(kolicina*cijena*Koef(cDinDem)*rabat/100, nZaokr)
   endif
   skip
enddo
nRab:=round(nRab,nZaokr)
nUk:= round(nUk, nZaokr)
? space(gnLMarg-3); ??  m

? space(gnLMarg); ??  padl("Ukupno :"+TRANSFORM(nUk,picdem),116)
if !cidtipdok$"11#27"
 ? space(gnLMarg); ??  padl("Rabat :"+TRANSFORM(nRab,picdem),116)
endif

nFZaokr:=round(nUk-nRab+nPor2,nZaokr)-round2(round(nUk-nRab+nPor2,nZaokr),gFZaok)
if gFZaok<>9 .and. round(nFzaokr,4)<>0
 ? space(gnLMarg); ??  padl("Zaokr :"+TRANSFORM(nFZaokr,picdem),116)
endif

cPor:=""
nPor2:=0
if !cidtipdok$"11#27"
 select por
 go top
 do while !eof()  // string poreza
  ? space(gnLMarg); ?? padl(trim(por)+":"+TRANSFORM(round(iznos,nzaokr),picdem),116)
  nPor2+=round(Iznos,nzaokr)
  skip
 enddo
endif
if !empty(picdem)
 cPom:=Slovima(round(nUk-nRab+nPor2-nFZaokr,nZaokr),cDinDem)
else
 cPom:=""
endif


ctxt2:=strtran(ctxt2,""+Chr(10),"")
ctxt2:=strtran(ctxt2,Chr(13)+Chr(10),Chr(13)+Chr(10)+space(gnLMarg+4))

if gFormatA5=="D"
  @ 27+gnTmarg3,pcol() SAY ""
else
  @ 56+gnTmarg3,pcol() SAY ""
endif

FOR i:=1 TO gnTmarg4; ?; NEXT
? space(gnLMarg+4); ?? ctxt2
setprc(prow()+nDuzmemo-1,pcol())

if gFormatA5=="D"
  @ 35+gnTmarg4,gnLMarg+1 SAY cPom
else
 if prow()>=61+gnTmarg4
   @ prow(),gnLMarg+1 SAY cPom
 else
   @ 61+gnTmarg4,gnLMarg+1 SAY cPom
 endif
endif

  B_ON; @ prow(),nCol1 SAY PADL(TRANSFORM(round(nUk-nRab+nPor2-nFZaokr,nzaokr),picdem),18); B_OFF

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
P_12CPI

private cpom:=""
FF

ZAVRSI STAMPU

CLOSERET
*}



/*! \fn Zagl2a()
 *  \brief Stampa zaglavlja za 2 a 
 */
 
function Zagl2a()
*{
P_10CPI
 for i:=1 to gnTMarg  // Top Margina
   ?
 next

 cStr:=idtipdok+" "+trim(brdok)
 cIdTipDok:=IdTipDok
 private cpom:=""
 if !(cIdTipDok $ "00#01#19")
  cStr:=trim(BrDok)
 endif
 ? SPACE(38+gFPzag)
 B_ON; Krizaj2a(); B_OFF

 ?
 ?
 ?  space(7+gFPzag)+gPB_ON+padc(alltrim(cTxt3a),30)+gPB_OFF; ?? padl(dtoc(datdok),38)
 ?  space(7+gFPzag)+gPB_ON+padc(alltrim(cTxt3b),30)+gPB_OFF
 ?  space(7+gFPzag)+gPB_ON+padc(alltrim(cTxt3c),30)+gPB_OFF
 FOR i:=1 TO gnTmarg2; ?; NEXT
 P_COND
return .t.
*}


/*! \fn Krizaj2a()
 *  \brief 
 */
 
function Krizaj2a()
*{
IF cidtipdok$"20#27"
  ?? "  PRED         "+REPLICATE(gZnPrec,13)
  ??  padl(cStr,37-28)
elseif cidtipdok=="12"
  ?? "               "+REPLICATE(gZnPrec,5)
  ??  padl(cStr,37-28)
elseif cidtipdok=="10" .and. m1="X"  // izgenerisan racun
  ?? "               "+space(5)+REPLICATE(gZnPrec,8)
  ??  padl(cStr,37-28)
else
  ??  padl(cStr,37)
ENDIF

return
*}


