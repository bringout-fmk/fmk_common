#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/dok/1g/stdok.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.9 $
 * $Log: stdok.prg,v $
 * Revision 1.9  2003/11/21 08:46:51  sasavranic
 * Opresa - stampa, stampa samo jedne dostavnice
 * FMK.INI/PRIVPATH
 * [Stampa]
 *  JednaDostavnica=D
 *
 * Revision 1.8  2003/10/04 08:11:49  sasavranic
 * no message
 *
 * Revision 1.7  2003/08/01 09:42:25  sasa
 * nove karakteristike na nar
 *
 * Revision 1.6  2003/07/16 11:08:42  sasa
 * broj rjesenja
 *
 * Revision 1.5  2003/03/26 14:55:15  mirsad
 * umjesto "Reg.br." i "Por.br." svuda stavljen ispis "Ident.br."
 *
 * Revision 1.4  2002/09/13 12:52:31  mirsad
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
 
/*! \todo Izbaciti POCNI STAMPU ... ZAVRSI STAMPU
 */


/*! \ingroup ini
  * \var *string FmkIni_ExePath_FAKT_DelphiRB
  * \brief Da li se koristi stampa dokumenata kroz Delphi RB?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_ExePath_FAKT_DelphiRB;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_FAKT_StampaViseDokumenata
  * \brief Moze li se stampati vise od jednog dokumenta iz pripreme?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_ExePath_FAKT_StampaViseDokumenata;


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


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_BiratiUplatniRacunZaPrikazUZaglavlju
  * \brief Omoguciti izbor uplatnog racuna koji se prikazuje u zaglavlju?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_KumPath_FAKT_BiratiUplatniRacunZaPrikazUZaglavlju;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_UplatniRacuni_SifraVrstePlacanja_XY
  * \brief Definise uplatni racun koji se pridruzuje sifri vrste placanja XY
  * \param ? - nije definisan, default vrijednost
  */
*string FmkIni_KumPath_FAKT_UplatniRacuni_SifraVrstePlacanja_XY;


/*! \ingroup ini
  * \var *string FmkIni_PrivPath_UpitFax_FaxText
  * \brief Tekst koji se ispisuje na kraju dokumenta za slanje faksom
  * \param UpisiProizvoljanText - default vrijednost
  */
*string FmkIni_PrivPath_UpitFax_FaxText;


/*! \ingroup ini
  * \var *string FmkIni_PrivPath_UpitFax_Slati
  * \brief Da li se dokument salje faksom?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_PrivPath_UpitFax_Slati;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_STAMPA_Opresa
  * \brief Da li se koriste specificnosti radjene za Opresu (stampa) ?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_KumPath_STAMPA_Opresa;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_STAMPA_Opresa13ka_A4
  * \brief Da li se dokument tipa 13 u varijanti za Opresu(stampa) ispisuje na formatu papira A4
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_KumPath_STAMPA_Opresa13ka_A4;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_IdPartnNaF
  * \brief Da li se u okviru naziva kupca na fakturi ispisuje i sifra kupca
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_KumPath_FAKT_IdPartnNaF;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_RegBrPorBr
  * \brief Da li se na dokumentu ispisuju registarski i poreski broj partnera?
  * \param D - da, default vrijednost
  * \param N - ne
  */
*string FmkIni_KumPath_FAKT_RegBrPorBr;


/*! \fn StDok(cIdFirma,cIdTipDok,cBrDok)
 *  \brief Stampa dokumenata
 *  \param cIdFirma
 *  \param cIdTipDok
 *  \param cBrDok
 */

*function StDok(cIdFirma,cIdTipDok,cBrDok)
*{
function StDok
parameters cIdFirma,cIdTipDok,cBrDok

local i
private nCol1:=0,cTxt1,cTxt2,aMemo,nCTxtR,cpom,cpombk
private cTi,nUk,nRab,nUk2:=nRab2:=0
private nStrana:=0

if pcount()==3
 O_Edit(.t.)
else
 O_Edit()
endif

fDelphiRB:=.f.
cIniName:=""
if IzFmkIni('FAKT','DelphiRB','N')=='D'
  fDelphiRB:=.t.
  cIniName:=EXEPATH+'ProIzvj.ini'
endif

cTI:="1"  // tip izvjestaja  1,2
O_PARAMS
private cSection:="1",cHistory:=" "; aHistory:={}
RPar("c1",@cTI)
select params; use

if gVarF=="1"
  if gRabProc=="D"
    M:="------ ---------- ---------------------------------------- -------------------- ----------- --- ----------- ------ -----------"
  else
    M:="------ ---------- ---------------------------------------- -------------------- ----------- --- ----------- -----------"
  endif
else
  if gRabProc=="D"
    M:="------ ---------- ---------------------------------------- ----------- --- ----------- ------ ----------- -----------"
  else
    M:="------ ---------- ---------------------------------------- ----------- --- ----------- ----------- -----------"
  endif
endif

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

dDatDok:=DatDok
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
//if idtipdok == "11"; nLTxt2+=7; endif

POCNI STAMPU

P_10CPI
for i:=1 to gnTMarg  // Top Margina
  ?
next


// ---------------- MS 07.04.01
// ?? space(4),gPB_ON+padc(alltrim(cTxt3a),30)+gPB_OFF; ?? padl(Mjesto(cIdFirma)+", "+dtoc(datdok)+" godine",39)
aPom:=Sjecistr(cTxt3a,30)
?? space(4),gPB_ON+padc(alltrim(aPom[1]),30)+gPB_OFF; ?? padl(Mjesto(cIdFirma)+", "+dtoc(datdok)+" godine",39)
for i:=2 to len(aPom)
  ? space(4),gPB_ON+padc(alltrim(aPom[i]),30)+gPB_OFF
next
// ---------------- MS 07.04.01


?  space(4),gPB_ON+padc(alltrim(cTxt3b),30)+gPB_OFF
?  space(4),gPB_ON+padc(alltrim(cTxt3c),30)+gPB_OFF
cStr:=idtipdok+" "+trim(brdok)
cIdTipDok:=IdTipDok

private cpom:=""
if !(cIdTipDok $ "00#01#19")
 cPom:="G"+cidtipdok+"STR"
 cStr:=&cPom+" "+trim(BrDok)
else
 if cIdTipDok $ "01"
   cStr:="PRIJEM U MAGACIN "+cIdFirma
 endif
endif

B_ON; ?? padl(cStr,39) ;B_OFF
ShowIDPar(cIdPartner,5)
for i:=1 to gOdvT2; ?; next

Zagl()

nUk:=0
nRab:=0
nZaokr:=ZAOKRUZENJE
cDinDEM:=dindem

//idfirma+idtipdok+brdok==cidfirma+cidtipdok+cbrdok

do while idfirma==cidfirma .and. idtipdok==cidtipdok .and. brdok==cbrdok .and. !eof()

   NSRNPIdRoba()   // Nastimaj (hseek) Sifr.Robe Na Pripr->IdRoba

   if alltrim(podbr)=="." .or.  roba->tip="U"
      aMemo:=ParsMemo(txt)
      cTxt1:=padr(aMemo[1],40)
   endif
   if roba->tip="U"
      cTxtR:=aMemo[1]
   endif

   if alltrim(podbr)=="."
    if prow()>48-nLTxt2  // prelaz na sljedecu stranicu ?
      NStr0({|| Zagl()})
    endif
    ? space(gnLMarg); ?? Rbr(),""
    if gVarF=="1"
      ?? space(10),cTxt1,space(20),transform(kolicina,pickol),space(3)
    else
      ?? space(10),cTxt1,transform(kolicina,pickol),space(3)
    endif
    if cTI=="2"
       nRec:=recno()
       cRbr:=Rbr
       nUk2:=nRab2:=nPor2:=0
       do while !eof() .and. idfirma+idtipdok+brdok==cidfirma+cidtipdok+cbrdok .and. Rbr==cRbr
        if podbr=" ."
          skip; loop
        endif
        nUk2+=round(kolicina*cijena*Koef(cDinDem),nzaokr)
        nRab2+=round(kolicina*cijena*Koef(cDinDem)*rabat/100,nzaokr)
        nPor2+=round(kolicina*cijena*Koef(cDinDem)*(1-rabat/100)*Porez/100,nzaokr)
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
       if gRabProc=="D"
         @ prow(),pcol()+1 SAY cRab+"%"
       endif
       if gVarF=="2"
        @ prow(),pcol()+1 SAY iif(kolicina<>0,(nUk2-nRab2)/kolicina,0) pict picdem
       endif
       nCol1:=pcol()+1
       @ prow(),pcol()+1 SAY nUk2 pict picdem

       if nPor2<>0
         @  prow()+1,18+gnLMarg SAY "Porez "+str(nporez,5,2)+"%"
         @  prow(),nCol1 SAY round(nPor2,nZaokr) pict picdem
       endif
    endif //
   else   // podbr nije "."
     if idtipdok $ "11#15#27"  // maloprodaja ili izlaz iz MP putem VP
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

     aSbr:=Sjecistr(serbr,20)
     if roba->tip="U"
       aTxtR:=SjeciStr(aMemo[1],if(gVarF=="1",61,40))   // duzina naziva + serijski broj
     else
       aTxtR:=SjeciStr(roba->naz,40)
     endif


    if prow()>49-len(aSbr)-nLTxt2  // prelaz na sljedecu stranicu ?
      NStr0({|| Zagl()})
    endif
    ? space(gnLMarg); ?? Rbr(),idroba
    nCTxtR:=pcol()+1
    @ prow(),nCTxtR SAY aTxtR[1]
    if !(roba->tip="U") .and. gVarF=="1"
     nCTxtR:=pcol()+1
     @ prow(),pcol()+1 SAY aSbr[1]
    endif
    @ prow(),pcol()+1 SAY kolicina pict pickol
    @ prow(),pcol()+1 SAY lower(ROBA->jmj)
    if empty(podbr) .or. (!empty(podbr) .and. cTI=="1")
      @ prow(),pcol()+1 SAY cijena*Koef(cDinDem) pict picdem
      if rabat-int(rabat) <> 0
          cRab:=str(rabat,5,2)
      else
         cRab:=str(rabat,5,0)
      endif
      //if idtipdok=="11"
      //  @ prow(),pcol()+1 SAY roba->idtarifa
      //else
      //  @ prow(),pcol()+1 SAY cRab+"%"
      //endif
      if gRabProc=="D"
        @ prow(),pcol()+1 SAY cRab+"%"
      endif
      if gVarF=="2"
        @ prow(),pcol()+1 SAY cijena*(1-rabat/100)  pict picdem
      endif
      nCol1:=pcol()+1
      @ prow(),pcol()+1 SAY kolicina*cijena*Koef(cDinDem) pict picdem

      nPor2:=kolicina*cijena*Koef(cDinDem)*(1-rabat/100)*Porez/100

      if roba->tip="U"
        for i:=2 to len(aTxtR)
          @ prow()+1,nCTxtR  SAY aTxtR[i]
        next
      else
       if gVarF=="1"
        for i:=2 to len(aSbr)
         @ prow()+1,nCTxtR  SAY aSbr[i]
        next
       endif
      endif
      if nPor2<>0
          @  prow()+1,18+gnLMarg SAY "Porez "+str(porez,5,2)+"%"
          @  prow(),nCol1 SAY nPor2 pict picdem
      endif
    endif


    nUk+=round(kolicina*cijena*Koef(cDinDem)+nPor2,nZaokr)
    nRab+=round(kolicina*cijena*Koef(cDinDem)*rabat/100,nZaokr)
   endif
   skip
enddo
nRab:=round(nRab,nZaokr)
nUk:= round(nUk, nZaokr)

if !fDelphiRB
 ? space(gnLMarg); ??  m
endif

nPor2:=0 // treba mi iznos poreza da bih vidio da li cu stampati red "Ukupno"
select por; go top
do while !eof()
 nPor2+=round(Iznos,nZaokr); skip
enddo

if gSamokol!="D"

if ((nRab<>0) .or. (nPor2<>0))
   ? space(gnLMarg); ??  padl("Ukupno ("+cDinDem+") :",98); @ prow(),nCol1 SAY nUk pict picdem
endif

if nRab<>0
  if !cidtipdok$"11#15#27"
    ? space(gnLMarg); ??  padl("Rabat ("+cDinDem+") :",98);  @ prow(),nCol1 SAY nRab pict picdem
  endif
endif

cPor:=""
nPor2:=0
fStamp:=.f.
if ! ( cidtipdok $ "11#27" )
 select por
 go top
 nPorI:=0

 do while !eof()  // string poreza
  // odstampaj ukupno - rabat kada ima poreza
  nPor2+=round(Iznos,nZaokr)
  if nPor2<>0 .and. !fStamp .and. gFormatA5<>"0" .and. nRab<>0   // koristim ovaj parametar za varijantu 2
                      // jer se samo koristi za 22
    ? space(gnLMarg); ??  padl("Ukupno - Rab ("+cDinDem+") :",98);  @ prow(),nCol1 SAY nUk-nRab pict picdem
   fStamp:=.t.
  endif
  ? space(gnLMarg); ?? padl(trim(por)+":",98); @ prow(),nCol1 SAY round(IF(cIdTipDok=="15",-1,1)*iznos,nzaokr) pict picdem
  skip
 enddo
 nPor2 := IF(cIdTipDok=="15",-1,1) * nPor2
endif

nFZaokr:=round(nUk-nRab+nPor2,nZaokr)-round2(round(nUk-nRab+nPor2,nZaokr),gFZaok)

? space(gnLMarg); ??  m

if gFZaok<>9 .and. round(nFzaokr,4)<>0
 ? space(gnLMarg); ?? padl("Zaokruzenje:",98); @ prow(),nCol1 SAY nFZaokr pict picdem
endif

? space(gnLMarg); ??  m
? space(gnLMarg); ??  padl("U K U P N O  ("+cDinDem+") :",98); @ prow(),nCol1 SAY round(nUk-nRab+nPor2-nFZaokr,nzaokr) pict picdem
if !empty(picdem)
 ? space(gnLmarg); ?? "slovima: ",Slovima(round(nUk-nRab+nPor2-nFZaokr,nZaokr),cDinDem)
else
 ?
endif

endif // gsamokol!="D"

? space(gnLMarg); ?? m
?
ctxt2:=strtran(ctxt2,""+Chr(10),"")
ctxt2:=strtran(ctxt2,Chr(13)+Chr(10),Chr(13)+Chr(10)+space(gnLMarg))
? space(gnLMarg); ?? ctxt2
?
?
?
select por; use
select pripr

P_12CPI

PrStr2T(cIdTipDok)

FF

ZAVRSI STAMPU

closeret
*}



/*! \fn Zagl()
 *  \brief Ispis zaglavlja
 */
 
function Zagl()
*{
P_COND
? space(gnLMarg); ?? m
if gVarF=="1"
 if gRabProc=="D"
   ? space(gnLMarg); ?? " R.br   Sifra      Naziv                                    "+JokSBr()+"             kolicina   jmj   Cijena    Rabat    Ukupno"
 else
   ? space(gnLMarg); ?? " R.br   Sifra      Naziv                                    "+JokSBr()+"             kolicina   jmj   Cijena      Ukupno"
 endif
else
 if gRabProc=="D"
   ? space(gnLMarg); ?? " R.br   Sifra      Naziv                                     kolicina   jmj   Cijena    Rabat Cijena-Rab    Ukupno"
 else
   ? space(gnLMarg); ?? " R.br   Sifra      Naziv                                     kolicina   jmj   Cijena   Cijena-Rab    Ukupno"
 endif
endif
? space(gnLMarg); ?? m
return
*}


/*! \fn NStr0(bZagl)
 *  \brief Nova strana, prelazak na novu stranu
 */
 
function NStr0(bZagl)
*{
? space(gnLmarg); ?? m
? space(gnLmarg+IF(gVarF=="9".and.gTipF=="2",14,0)),"Ukupno na strani "+str(++nStrana,3)+":"; @ prow(),nCol1  SAY nUk  pict picdem
? space(gnLmarg); ?? m
FF
Eval(bZagl)
? space(gnLmarg+IF(gVarF=="9".and.gTipF=="2",14,0)),"Prenos sa strane "+str(nStrana,3)+":"; @ prow(),nCol1  SAY nUk pict picdem
? space(gnLmarg); ?? m
*}


/*! \fn Koef(cDinDem)
 *  \brief
 *  \param cDinDem
 */
 
function Koef(cdindem)
*{
local nNaz,nRet,nArr,dDat

if cdindem==left(ValSekund(),3)
 return 1/UbaznuValutu(datdok)
else
 return 1
endif
*}


/*! \fn Mjesto(cRJ)
 *  \brief Uzima mjesto
 *  \todo Postoji nesto slicno u db.prg, treba pogledati
 *  \param cRJ
 */


function Mjesto(cRJ)
*{
LOCAL cVrati:=""
  IF gMjRJ=="D"
    PushWA()
    SELECT (F_RJ)
    PushWA()
    IF !USED();  O_RJ; ENDIF
    HSEEK cRJ
    cVrati:=RJ->grad
    PopWA()
    PopWA()
  ELSE
    cVrati:=gMjStr
  ENDIF
return TRIM(cVrati)
*}



/*! \fn StZaglav2(c1,c2)
 *  \brief Stampa zaglavlja druga varijanta
 *  \param c1
 *  \param c2
 */
 
function StZaglav2(c1,c2)
*{
LOCAL cPom, i
  IF IzFMKIni("FAKT","BiratiUplatniRacunZaPrikazUZaglavlju","N",KUMPATH)=="D"
    cPom := IzFMKIni("FAKT_UplatniRacuni",;
                     "SifraVrstePlacanja_"+PRIPR->idvrstep,;
                     "?",;
                     KUMPATH)
    IF cPom="#"
      cPom:=SUBSTR(cPom,2)
      gzP1:=TUN(cPom,"#")
      FOR i:=1 TO LEN(gzP1)
        gzP1[i] := IzFMKIni("FAKT_UplatniRacuni",;
                            "SifraVrstePlacanja_"+gzP1[i],;
                            "?",;
                            KUMPATH)
        gzP1[i] := PADR( gzP1[i] , 65 )
      NEXT
      altd()
    ELSE
      gzP1 := PADC(ALLTRIM(cPom),65)
    ENDIF
  ELSE
    gzP1 := NIL
  ENDIF
  IF cIdFirma!="10".and.gMjRJ=="D"
    StZaglavlje("zagl"+cIdFirma+".txt",c2,gzP1)
  ELSE
    StZaglavlje(c1,c2,gzP1)
  ENDIF
return
*}


/*! \fn JokSBr()
 *  \brief
 */
 
function JokSBr()
*{
IF "U"$TYPE("BK_SB"); BK_SB:=.f.; ENDIF
return IF(gNW=="R","  KJ/KG ",IF(glDistrib," Tarifa ",IF(BK_SB,"  BARKOD   ","Ser.broj")))
*}


/*! \fn NSRNPIIdRoba(cSR,fSint)
 *  \brief Nasteli sif->roba na pripr->idroba
 *  \param cSR
 *  \param fSint  - ako je fSint:=.t. sinteticki prikaz
 */
 
function NSRNPIdRoba(cSR,fSint)
*{
if fSint=NIL
  fSint:=.f.
endif

IF cSR==NIL; cSR:=PRIPR->IdRoba; ENDIF
SELECT ROBA
IF (gNovine=="D" .or.  fSint)
  hseek PADR(LEFT(cSR,gnDS),LEN(cSR))
  IF !FOUND() .or. ROBA->tip!="S"
    hseek cSR
  ENDIF
ELSE
  hseek cSR
ENDIF
IF SELECT("PRIPR")!=0
  SELECT PRIPR
ELSE
  SELECT (F_PRIPR)
ENDIF

return
*}


/*! \fn PrStr2T(cIdTipDok)
 *  \brief Stampa potpisa na kraju fakture
 *  \param cIdTipDok
 */
 
function PrStr2T(cIdTipDok)
*{
LOCAL cPom2:=""
 IF "U" $ TYPE("fDelphiRB"); fDelphiRB:=.f.; ENDIF
 IF "U" $ TYPE("lUgRab"); lUgRab:=.f.; ENDIF
 private cpom:=""
 private cFaxT:=""
 //cIniName:=PRIVPATH+'fmk.ini'
 cFaxT:=IzFmkIni('UpitFax','FaxText','UpisiProizvoljanText',PRIVPATH)
 if lUgRab
   cPom2:=SPACE(gnlMarg)+PADC("KUPAC",22)+SPACE(29)+PADC("PRODAVAC",22)
   if fDelphiRB
     UzmiIzIni(cIniName,'Varijable','Potpis',cPom2,'WRITE')
   else
     if IzFmkIni('UpitFax','Slati','N',PRIVPATH)=='D'
       ? cFaxT
     else
       ? cPom2
     endif
   endif
 elseif cidtipdok $ "00#01#19"

   altd()
   if fDelphiRB
     UzmiIzIni(cIniName,'Varijable','Potpis',g10Str2T,'WRITE')
   else
     if IzFmkIni('UpitFax','Slati','N',PRIVPATH)=='D'
       ? cFaxT
     else
       ? g10Str2T
     endif
   endif
 else
   cpom:="G"+cidtipdok+"STR2T"
   if fDelphiRB
     UzmiIzIni(cIniName,'Varijable','Potpis',&cPom,'WRITE')
   else
     if IzFmkIni('UpitFax','Slati','N',PRIVPATH)=='D'
       ? cFaxT
     else
        IF cIdTipDok=="13".and.IzFMKIni("STAMPA","Opresa","N",KUMPATH)=="D".and.;
           IzFMKINI("STAMPA","Opresa13ka_A4","N",KUMPATH)<>"D"
          ? SPACE(10)+&cPom
        ELSE
          ? &cPom
        ENDIF
     endif
   endif
 endif
return
*}


/*! \fn PrStr2R(cIdTipDok)
 *  \brief Vraca tekst potpisa RTF
 *  \param cIdTipDok
 *  \return cVrati
 */
 
function PrStr2R(cIdTipDok)
*{
LOCAL cVrati:=""
 // IF "U" $ TYPE("fDelphiRB"); fDelphiRB:=.f.; ENDIF
 private cpom:=""
 if cidtipdok $ "00#01#19"
   cVrati:=g10Str2R
 else
   cpom:="G"+cidtipdok+"STR2R"
   cVrati:=&cPom
 endif
return (cVrati)
*}


/*! \fn ShowIdPar(cId,n,lNoviRed,lVratiRPBNiz)
 *  \brief Prikazi ID partnera na fakturi
 *  \param cId
 *  \param n
 *  \param lNoviRed
 *  \param lVratiRPBNiz
 */
 
function ShowIDPar(cId,n,lNoviRed,lVratiRPBNiz)
*{
local cRegBr
local cPorBr
local lPar:=.f.
local lRegB:=.f.

lBrojRjesenja:=IzFmkIni("FAKT","BrojRjes","N",KUMPATH)=="D"

if n==nil
	n:=0
endif
if lVratiRPBNiz==nil
	lVratiRPBNiz:=.f.
endif
if lNoviRed==nil
	lNoviRed:=.t.
endif
if !lVratiRPBNiz .and. IzFMkIni("FAKT","IdPartnNaF","N",KUMPATH)=="D"
	if lNoviRed
      		? (SPACE(n) + PADC("ID:"+cId,30))
    	else
      		?? (SPACE(n) + PADC("ID:"+cId,30))
      		lPar:=.t.
    	endif
endif

if IzFMkIni("FAKT","RegBrPorBr","D",KUMPATH)=="D" .or. lVratiRPBNiz
	cRegBr:=IzSifK("PARTN","REGB",cId,.f.)
    	cPorBr:=IzSifK("PARTN","PORB",cId,.f.)
    	if lBrojRjesenja
    		cBrojRjesenja:=IzSifK('PARTN','BRJS',cId,.f.)
		cBrojUpisa:=IzSifK('PARTN','BRUP',cId,.f.)
    	endif	
    	if lNoviRed
      		if !EMPTY(cRegBr)
        		? (SPACE(n) + PADC("Ident.br:"+cRegBr,30))
      		endif
      		if !EMPTY(cPorBr)
        		? (SPACE(n) + PADC("Por.br:"+cPorBr,30))
      		endif
      		if (lBrojRjesenja .and. !Empty(cBrojRjesenja))
        		? (SPACE(n+4)+ + PADC("Br.Sud.Rj:"+cBrojRjesenja,30))
      			if !Empty(cBrojUpisa)
				? (SPACE(n+4) + PADC("Br.Upisa:"+cBrojUpisa,30))
			endif
		endif		
    	else
      		if !EMPTY(cRegBr)
        		if lPar
          			?
        		endif
        		?? (SPACE(n) + PADC("Ident.br:"+cRegBr,30))
        		lRegB:=.t.
      		endif
      		if !EMPTY(cPorBr)
        		if lPar .or. lRegB
          			?
        		endif
        		?? (SPACE(n) + PADC("Por.br:"+cPorBr,30))
      		endif
    	endif
	if lVratiRPBNiz
      		return {cRegBr,cPorBr}
    	endif
    	
endif
return (nil)
*}


/*! \fn StAzFakt()
 *  \brief Stampa azurirane fakture
 */
 
function StAzFakt()
*{
private opc[2],Izbor:=1,cIdFirma,cIdTipDok,cBrDok

Opc[1]:="1. izlaz TXT format     "
Opc[2]:="2. izlaz RTF format"

do while .t.

 h[1]:="Stampanje azurirane fakture u TXT formatu"
 h[2]:="Stampanje azurirane fakture u RTF formatu"

 Izbor:=menu("safa",opc,Izbor,.f.)

   do case
     case Izbor==0
       EXIT
     otherwise
       cIdFirma:=gFirma; cIdTipDok:="10"; cBrdok:=space(8)
       Box("",1,35)
        @ m_x+1,m_y+2 SAY "Dokument:"
        //if gnw $ "DR"
        // @ m_x+1,col()+1 SAY cIdFirma
        //else
         @ m_x+1,col()+1 GET cIdFirma
        //endif
        @ m_x+1,col()+1 SAY "-" GET cIdTipDok
        @ m_x+1,col()+1 SAY "-" GET cBrDok
        read
       BoxC()
       close all

       if izbor==1
         StampTXT(cidfirma,cIdTipdok,cbrdok)
       else
          StampRtf(PRIVPATH+"fakt.rtf",cIdFirma,cIdTipDok,cBrDok)
       endif
   endcase

enddo

#Ifdef CAX
  select (F_PRIPR)
  if used();  select pripr; use; endif
#endif
return
*}


/*! \fn RbrUNum(cRBr)
 *  \brief 
 *  \param cRBr
 */
 
function RbrUNum(cRBr)
*{
if left(cRbr,1)>"9"
   return  (asc(left(cRbr,1))-65+10)*100  + val(substr(cRbr,2,2))
else
   return val(cRbr)
endif
*}

