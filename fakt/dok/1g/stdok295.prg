#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/dok/1g/stdok295.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.4 $
 * $Log: stdok295.prg,v $
 * Revision 1.4  2002/09/14 13:55:34  mirsad
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

/*! \file fmk/fakt/dok/1g/stdok295.prg
 *  \brief Stampa faktura u varijanti 2 9 5
 */


/*! \ingroup ini
  * \var *string FmkIni_PrivPath_Fakt295_Stavki
  * \brief Broj stavki koje mogu stati na jednu stranicu u varijanti fakture za A5 papir
  * \param 6 - default vrijednost
  */
*string FmkIni_PrivPath_Fakt295_Stavki;


/*! \ingroup ini
  * \var *string FmkIni_PrivPath_Fakt295_KorekcijaFooter
  * \brief Korekcija footer-a po vertikali (broj redova)
  * \param 0 - default vrijednost
  */
*string FmkIni_PrivPath_Fakt295_KorekcijaFooter;


/*! \ingroup ini
  * \var *string FmkIni_PrivPath_Fakt295_F1
  * \brief 1.red footer-a u varijanti fakture za format papira A5
  * \param  - nije definisano, default vrijednost
  */
*string FmkIni_PrivPath_Fakt295_F1;


/*! \ingroup ini
  * \var *string FmkIni_PrivPath_Fakt295_F2
  * \brief 2.red footer-a u varijanti fakture za format papira A5
  * \param  - nije definisano, default vrijednost
  */
*string FmkIni_PrivPath_Fakt295_F2;


/*! \ingroup ini
  * \var *string FmkIni_PrivPath_Fakt295_F3
  * \brief 3.red footer-a u varijanti fakture za format papira A5
  * \param  - nije definisano, default vrijednost
  */
*string FmkIni_PrivPath_Fakt295_F3;


/*! \ingroup ini
  * \var *string FmkIni_PrivPath_Fakt295_F4
  * \brief 4.red footer-a u varijanti fakture za format papira A5
  * \param  - nije definisano, default vrijednost
  */
*string FmkIni_PrivPath_Fakt295_F4;


/*! \ingroup ini
  * \var *string FmkIni_PrivPath_Fakt295_F5
  * \brief 5.red footer-a u varijanti fakture za format papira A5
  * \param  - nije definisano, default vrijednost
  */
*string FmkIni_PrivPath_Fakt295_F5;


/*! \ingroup ini
  * \var *string FmkIni_PrivPath_Fakt295_SirFTXT
  * \brief Broj kolona sirine za ispis teksta na kraju fakture za varijantu fakture za format papira A5
  * \param 80 - default vrijednost
  */
*string FmkIni_PrivPath_Fakt295_SirFTXT;


/*! \ingroup ini
  * \var *string FmkIni_PrivPath_Fakt295_GMarg
  * \brief Broj redova gornje margine za varijantu fakture za format papira A5
  * \param 3 - default vrijednost
  */
*string FmkIni_PrivPath_Fakt295_GMarg;


/*! \ingroup ini
  * \var *string FmkIni_PrivPath_Fakt295_Meridijan
  * \brief Da li se koristi varijanta fakture za format papira A5 radjena za Meridijan?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_PrivPath_Fakt295_Meridijan;


/*! \ingroup ini
  * \var *string FmkIni_PrivPath_Fakt295_L1
  * \brief Sablon za ispis podataka u 1.redu zaglavlja fakture varijanta za A5 papir radjena za Meridijan
  * \param  - nije definisano, default vrijednost
  */
*string FmkIni_PrivPath_Fakt295_L1;


/*! \ingroup ini
  * \var *string FmkIni_PrivPath_Fakt295_L2
  * \brief Sablon za ispis podataka u 2.redu zaglavlja fakture varijanta za A5 papir radjena za Meridijan
  * \param  - nije definisano, default vrijednost
  */
*string FmkIni_PrivPath_Fakt295_L2;


/*! \ingroup ini
  * \var *string FmkIni_PrivPath_Fakt295_L3
  * \brief Sablon za ispis podataka u 3.redu zaglavlja fakture varijanta za A5 papir radjena za Meridijan
  * \param  - nije definisano, default vrijednost
  */
*string FmkIni_PrivPath_Fakt295_L3;


/*! \ingroup ini
  * \var *string FmkIni_PrivPath_Fakt295_L4
  * \brief Sablon za ispis podataka u 4.redu zaglavlja fakture varijanta za A5 papir radjena za Meridijan
  * \param  - nije definisano, default vrijednost
  */
*string FmkIni_PrivPath_Fakt295_L4;


/*! \ingroup ini
  * \var *string FmkIni_PrivPath_Fakt295_L5
  * \brief Sablon za ispis podataka u 5.redu zaglavlja fakture varijanta za A5 papir radjena za Meridijan
  * \param  - nije definisano, default vrijednost
  */
*string FmkIni_PrivPath_Fakt295_L5;

 
/*! \fn StDok295()
 *  \brief Stampa fakture u varijanti 2 9 5
 *  \param cIdFirma
 *  \param cIdTipDok
 *  \param cBrDok
 */
 
function StDok295()
*{
parameters cIdFirma,cIdTipDok,cBrDok
private i,nCol1:=0,cTxt1,cTxt2,aMemo,nMPVBP:=nVPVBP:=0
private cTi,nUk,nRab,nUk2:=nRab2:=0
private nStrana:=0,nCTxtR:=10
private M:="  ----- ---------- ----------------------------------------  ----------- --- ----------- ------ ----------- ---- -----------"

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

select PRIPR
if pcount()==0  // poziva se faktura iz pripreme
 IF gNovine=="D"
   FilterPrNovine()
 ENDIF
 cIdTipdok:=idtipdok;cIdFirma:=IdFirma;cBrDok:=BrDok
endif
seek cidfirma+cidtipdok+cbrdok
NFOUND CRET

nDuzform:=27  // format a5

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
   if len(aMemo)>=9
    _DatPl:=aMemo[9]
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

private nStavki:= val(IzFmkIni("Fakt295","Stavki","6",PRIVPATH))

Zagl295()


nUk:=0
nRab:=0
nZaokr:=ZAOKRUZENJE
cDinDEM:=dindem

P_COND
do while idfirma==cidfirma .and. idtipdok==cidtipdok .and. brdok==cbrdok .and. !eof()

   NSRNPIdRoba()   // Nastimaj (hseek) Sifr.Robe Na Pripr->IdRoba

   if alltrim(podbr)=="." .or. roba->tip="U"
      aMemo:=ParsMemo(txt)
      cTxt1:=padr(aMemo[1],40)
   endif
   if roba->tip="U"
      cTxtR:=aMemo[1]
   endif
   if alltrim(podbr)=="."
    if prow()>nStavki-8+nDuzForm-nLTxt2  // prelaz na sljedecu stranicu ? // geredova
      NStr0({|| zagl295()})
    endif
    ? space(gnLmargA5); ?? Rbr(),""
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
        nRab2+=round(kolicina*cijena*rabat/100*Koef(cDinDem), nZaokr)
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
     aTxtR:=SjeciStr(aMemo[1],40)   // duzina naziva + serijski broj
    else
     aTxtR:=SjeciStr(trim(roba->naz)+katbr(),40)
    endif

    if prow()>nStavki-8+nDuzForm-len(aSbr)-nLTxt2  // prelaz na sljedecu stranicu ? // geredova
      NStr0({|| zagl295()})
    endif

    if porez-int(porez)<>0
        cPor:=str(porez,3,1)
    else
        cPor:=str(porez,3,0)
    endif


    ? space(gnLmargA5+2); ?? Rbr(); ?? idroba
    nCTxtR:=pcol()+1
    @ prow(),nCTxtR SAY aTxtR[1]
    if !cidtipdok$"11#27"
    else
      nCTxtR:=pcol()+1
      @ prow(),pcol()+1 SAY roba->idtarifa
      select tarifa;hseek roba->idtarifa
      @ prow(),pcol()+1 SAY tarifa->opp pict "9999.9%"
      @ prow(),pcol()+2 SAY tarifa->ppp pict "999.9%"
      select pripr
    endif
    @ prow(),pcol()+2 SAY kolicina pict pickol
    @ prow(),pcol()+1 SAY lower(ROBA->jmj)
    if empty(podbr) .or. (!empty(podbr) .and. cTI=="1")
           @ prow(),pcol()+1 SAY cijena*Koef(cDinDem) pict picdem
           if rabat-int(rabat) <> 0
               cRab:=str(rabat,5,2)
           else
              cRab:=str(rabat,5,0)
           endif
           if !cidtipdok$"11#27"
             @ prow(),pcol()+1 SAY cRab+"%"
             @ prow(),pcol()+1 SAY cijena*(1-rabat/100)*Koef(cDinDem)  pict picdem
             if porez-int(porez)<>0
               cPor:=str(porez,3,1)
             else
               cPor:=str(porez,3,0)
             endif
             @ prow(),pcol()+1 SAY cPor+"%"
           else
             // @ prow(),pcol()+1 SAY space(6)
           endif


           nCol1:=pcol()+1
           @ prow(),pcol()+1 SAY kolicina*cijena*Koef(cDinDem) pict picdem

           nPor2:=kolicina*Koef(cDinDem)*cijena*(1-rabat/100)*Porez/100

           if roba->tip="U"
             for i:=2 to len(aTxtR)
               @ prow()+1,nCTxtR  SAY aTxtR[i]
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


    nUk+=round(kolicina*cijena*Koef(cDinDem),nZaokr)
    nRab+=round(kolicina*cijena*Koef(cDinDem)*rabat/100,nZaokr)
   endif
   skip
enddo
nRab:=round(nRab,nZaokr)
nUk:= round(nUk, nZaokr)
? space(gnLMargA5); ??  m

 ? space(gnLMargA5); ??  padl("Ukupno :",105); @ prow(),nCol1 SAY nUk pict picdem
 if !cidtipdok$"11#27"
  ? space(gnLMargA5); ??  padl("Rabat :",105); @ prow(),nCol1 SAY nRab pict picdem
 endif

nFZaokr:=round(nUk-nRab+nPor2,nZaokr)-round2(round(nUk-nRab+nPor2,nZaokr),gFZaok)
if gFZaok<>9 .and. round(nFzaokr,4)<>0
 ? space(gnLMargA5); ?? padl("Zaokruzenje:",105); @ prow(),nCol1 SAY nFZaokr pict picdem
endif



cPor:=""
nPor2:=0
if !cidtipdok$"11#27"
 select por
 go top
 do while !eof()  // string poreza
  ? space(gnLMargA5); ?? padl(trim(por)+":",105); @ prow(),nCol1 SAY round(iznos,nzaokr) pict picdem
  nPor2+=round(Iznos,nzaokr)
  skip
 enddo
endif

if IzFmkIni("Fakt295","Meridijan","N",PRIVPATH)=="D"

 nKraj:= nDuzForm- prow() - 4 + val(IzFmkIni("Fakt295","KorekcijaFooter","0",PRIVPATH))
 for i:=1 to nKraj
   // pomjeri se uvijek na dno strane za footer !
   ?
 next
 private aLinija[5]
 aLinija[1]:=IzFmkIni("Fakt295","F1","",PRIVPATH)
 aLinija[2]:=IzFmkIni("Fakt295","F2","",PRIVPATH)
 aLinija[3]:=IzFmkIni("Fakt295","F3","",PRIVPATH)
 aLinija[4]:=IzFmkIni("Fakt295","F4","",PRIVPATH)
 aLinija[5]:=IzFmkIni("Fakt295","F5","",PRIVPATH)
 nSirFTXT:=val(IzFmkIni("Fakt295","SirFTXT","80",PRIVPATH))
 

 if !empty(picdem)
  cPom:=Slovima(round(nUk-nRab+nPor2-nFZaokr,nZaokr),cDinDem)
 else
  cPom:=""
 endif

 for i:=1 to 5

   cPom:=transform(round(nUk-nRab+nPor2-nFZaokr,nzaokr),PicDEM)
   aLinija[i]:=strtran(aLinija[i],"#1#",cPom)

   ctxt2:=strtran(ctxt2,""+Chr(10),"")
   // ctxt2 - tekst na kraju fakture u formatu : Linija1 + chr(13)+chr(10) + Linija2 itdd

   cPom:=token(cTxt2,Chr(13)+Chr(10),1)
   cPom:=padr(cPom,nSirFTXT)
   aLinija[i]:=strtran(aLinija[i],"#2###########",cPom)

   cPom:=token(cTxt2,Chr(13)+Chr(10),2)
   cPom:=padr(cPom,nSirFTXT)
   aLinija[i]:=strtran(aLinija[i],"#3###########",cPom)

   cPom:=Slovima(round(nUk-nRab+nPor2-nFZaokr,nZaokr),cDinDem)
   aLinija[i]:=strtran(aLinija[i],"#5#",cPom)

   cPom:=token(cTxt2,Chr(13)+Chr(10),3)
   cPom:=padr(cPom,nSirFTXT)
   aLinija[i]:=strtran(aLinija[i],"#4###########",cPom)

   aLinija[i]:=strtran(aLinija[i],"#"," ")
 next
 for i:=1 to 5
   ? aLinija[i]
 next


else // Meridijan

if !empty(picdem)
 cPom:=Slovima(round(nUk-nRab+nPor2-nFZaokr,nZaokr),cDinDem)
else
 cPom:=""
endif

B_ON; @ 27+gnTMarg3A5,nCol1 SAY round(nUk-nRab+nPor2-nFZaokr,nzaokr) pict picdem; B_OFF  // -4=gnTmarg3

ctxt2:=strtran(ctxt2,""+Chr(10),"")
ctxt2:=strtran(ctxt2,Chr(13)+Chr(10),Chr(13)+Chr(10)+space(gnLMargA5+6))
FOR i:=1 TO gnTmarg4A5; ?; NEXT    // 0=gnTmarg4
? space(gnLMargA5+6); ?? ctxt2

if gDatVal=="D" .and. gVarF=="9"
  ?? " Datum DPO: "+_datpl
endif

setprc(prow()+nDuzmemo-1,pcol())

  @ 35-7+gnTmarg4A5,gnLMargA5+14 SAY cPom        // -7=gnTmarg4
?
if cidtipdok$"11#27"
 select por ; go top
 ? space(gnLMargA5); ?? "- Od toga porez: ----------"
 nUkPorez:=0
 do while !eof()
  ? space(gnLMargA5); ?? por+"%   :"
  @ prow(),pcol()+1 SAY  iznos pict  "9999999.999"
  nukporez+=iznos
  skip
 enddo
 ? space(gnLMargA5); ?? "Ukupno :  "+space(5)
 @ prow(),pcol()+1 SAY nUkPorez pict "9999999.999"
 ? space(gnLMargA5); ?? "---------------------------"
 select pripr
select por; use
endif

endif  // Meridijan

P_12CPI

private cpom:=""
FF

ZAVRSI STAMPU

CLOSERET
*}



/*! \fn Zagl295()
 *  \brief Stampa zaglavlja za varijantu fakture 2 9 5
 */
 
static function zagl295()
*{
P_10CPI
for i:=1 to val(IzFmkIni("Fakt295","GMarg","3",PRIVPATH)) // 3=gnTMarg  // Top Margina
  ?
next

if IzFmkIni("Fakt295","Meridijan","N",PRIVPATH)=="D"

private aLinija[5]

aLinija[1]:=IzFmkIni("Fakt295","L1","",PRIVPATH)
aLinija[2]:=IzFmkIni("Fakt295","L2","",PRIVPATH)
aLinija[3]:=IzFmkIni("Fakt295","L3","",PRIVPATH)
aLinija[4]:=IzFmkIni("Fakt295","L4","",PRIVPATH)
aLinija[5]:=IzFmkIni("Fakt295","L5","",PRIVPATH)


for i:=1 to 5
aLinija[i]:=strtran(aLinija[i],"#1##",gPB_ON+padc(alltrim(cTxt3a),30)+gPB_OFF)
aLinija[i]:=strtran(aLinija[i],"#2##",gPB_ON+padc(alltrim(cTxt3b),30)+gPB_OFF)
aLinija[i]:=strtran(aLinija[i],"#3##",gPB_ON+padc(alltrim(cTxt3c),30)+gPB_OFF)
aLinija[i]:=strtran(aLinija[i],"#4####",dtoc(datdok))
aLinija[i]:=strtran(aLinija[i],"#5####",trim(BrDok))
if gKrizA5>0
  aLinija[i]:=strtran( aLinija[i], "#6#", replicate("=",gKriza5) )
else
  aLinija[i]:=strtran( aLinija[i],"#6#",space(3))
endif
aLinija[i]:=strtran(aLinija[i],"#"," ")
next
for i:=1 to 5
  ? aLinija[i]
next

else // Nije meridijan

 ?? space(gnLmargA5+1+0+30)+padl(dtoc(datdok),38)
 IF gKrizA5>0
   FOR i:=1 TO gKrizA5; ?; NEXT
 ENDIF
 ?  space(gnLmargA5-1+gFPZagA5)+gPB_ON+padc(alltrim(cTxt3a),30)+gPB_OFF   // gfpzag
 ?  space(gnLmargA5-1+gFPZagA5)+gPB_ON+padc(alltrim(cTxt3b),30)+gPB_OFF   // gfpzag
 cStr:=idtipdok+" "+trim(brdok)
 cIdTipDok:=IdTipDok

 private cpom:=""
 if !(cIdTipDok $ "00#01#19")
  cStr:=trim(BrDok)
 endif
 B_ON
 Krizaj2()
 B_OFF
 ?  space(gnLmargA5-1+gFPZagA5)+gPB_ON+padc(alltrim(cTxt3c),30)+gPB_OFF   // gfpzag

endif // Meridijan

FOR i:=1 TO gnTMarg2A5; ?; NEXT        // 3=gnTmarg2
P_COND
RETURN .t.
*}



/*! \fn Krizaj2()
 *  \brief
 */
 
function Krizaj2()
*{
IF cidtipdok$"20#27"
  ?? "  PRED         "+REPLICATE(gZnPrec,13)
  ??  padl(cStr,37-28)
elseif cidtipdok=="12"
  ?? "      "+REPLICATE(gZnPrec,7)+SPACE(15)
  ??  padl(cStr,37-28)
elseif cidtipdok=="10" .and. m1="X"  // izgenerisan racun
  ?? "             "+REPLICATE(gZnPrec,15)
  ??  padl(cStr,37-28)
else
  ??  padl(cStr,37)
ENDIF

return
*}


