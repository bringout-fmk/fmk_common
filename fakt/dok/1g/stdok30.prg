#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/dok/1g/stdok30.prg,v $
 * $Author: sasa $ 
 * $Revision: 1.2 $
 * $Log: stdok30.prg,v $
 * Revision 1.2  2002/06/18 13:01:05  sasa
 * no message
 *
 * Revision 1.1.1.1  2002/06/17 18:30:18  ernad
 * no message
 *
 *
 */

/*! \file fmk/fakt/dok/1g/stdok30.prg
 *  \brief Stampa faktura u varijanti 3 0
 */
 
/*! \fn StDok30()
 *  \brief Stampa fakture u varijanti 3 0
 *  \param cIdFirma
 *  \param cIdTipDok
 *  \param cBrdok
 */
 

function StDok30()
*{
parameters cIdFirma,cIdTipDok,cBrDok
private aMemo,nUk:=0,nCol1:=Znakova(gnlmarg,10,17)+117,nUkCar:=0,nUkPor:=0
private nLMRek:=Znakova(gnlmarg,10,17)+107
private aCarTar:={},aPorezi:={}
m:=REPLICATE("-",129)
// m:=""
if pcount()==3
 O_Edit(.t.)
else
 O_Edit()
endif

select PRIPR
if pcount()==0  // poziva se faktura iz pripreme
 cIdTipdok:=idtipdok; cIdFirma:=IdFirma; cBrDok:=BrDok
 select roba; hseek pripr->idroba ; select pripr
 _principal:=roba->principal
 do while !eof()
   select roba; hseek pripr->idroba; select pripr
   if roba->principal<>_principal
     Msg("U stavki rbr: "+rbr+"."+podbr+" pojavljuje se principal "+roba->principal)
     closeret
   endif
   skip
 enddo
endif
seek cidfirma+cidtipdok+cbrdok
NFOUND CRET

dDatDok:=DatDok
cidpartner:=Idpartner
nZaokr:=ZAOKRUZENJE
cDinDEM:=dindem

cTxt1:=""
cTxt2:=""
cTxt3a:=""
cTxt3b:=""
cTxt3c:=""
nLTxt2:=1

IF !StFD0(); RETURN; ENDIF

 POCNI STAMPU
  StFD1()
  StFD2()
  StFD3()
  StFD4()
  StFD5()
  FF
 ZAVRSI STAMPU
CLOSERET
*}


/*! \fn StFD0()
 *  \brief Uslovi za stampu fakture
 */
 
function StFD0() 
*{
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
   return .f.
 endif
 // duzina slobodnog teksta
 for i:=1 to len(cTxt2)
   if substr(cTxt2,i,1)=chr(13); ++nLTxt2; endif
 next
return .t.
*}



/*! \fn StFD1()
 *  \brief Zaglavlje (naziv firme, broj ziro racuna, telefon)
 */
 
function StFD1() 
*{
P_10CPI
 StZaglav2(gVlZagl,PRIVPATH)
return
*}


/*! \fn StFD2()
 *  \brief Broj fakture, datum, kupac, dobavljac, valuta itd..
 */
 
function StFD2()    
*{
?? space(gnLmarg)+gPB_ON+padc(alltrim(cTxt3a),30)+gPB_OFF; ?? padl(Mjesto(cIdFirma)+", "+dtoc(datdok)+" godine",39)
 ?  space(gnLmarg)+gPB_ON+padc(alltrim(cTxt3b),30)+gPB_OFF
 ?  space(gnLmarg)+gPB_ON+padc(alltrim(cTxt3c),30)+gPB_OFF
 cStr:=idtipdok+" "+trim(brdok)

 private cpom:=""
 cPom:="G"+"10"+"STR"
 cStr:=&cPom+" "+trim(BrDok)
 B_ON; ??  padl(cStr,39); B_OFF
 ?
 ?
 SELECT ROBA
 SEEK pripr->idroba
 ? space(gnLmarg)+"PRINCIPAL : "+PADR(principal,10)+" "+Ocitaj(F_PARTN,principal,"naz")
 ? space(gnLmarg)+"VALUTA    : "+PADR(valuta,10)+" KURS VALUTE : "+STR(Ocitaj(F_VALUTE,valuta,"kurs1"),10,3)
 SELECT PRIPR
return
*}



/*! \fn StFD3()
 *  \brief Tabela (stavke)
 */
 
function StFD3() 
*{
LOCAL aKol
 aKol:={  { "Redni"        , {|| rbr+"."               }, .f., "C",  5, 0, 1, 1},;
          { "broj"         , {|| "#"                   }, .f., "C",  5, 0, 2, 1},;
          { "[ifra"        , {|| roba->id              }, .f., "C", 10, 0, 1, 2},;
          { "artikla"      , {|| "#"                   }, .f., "C", 10, 0, 2, 2},;
          { "UCD"          , {|| roba->ucd             }, .f., "C", 10, 0, 1, 3},;
          { "Carinska"     , {|| roba->cartar          }, .f., "C",  9, 0, 1, 4},;
          { "tarifa"       , {|| "#"                   }, .f., "C",  9, 0, 2, 4},;
          { "Naziv artikla", {|| roba->naz             }, .f., "P", 28, 0, 1, 5},;
          { "J.mj."        , {|| roba->jmj             }, .f., "C",  5, 0, 1, 6},;
          { "Koli~ina"     , {|| kolicina              }, .f., "N", 11, 2, 1, 7},;
          { "Cijena"       , {|| cijena                }, .f., "N", 11, 2, 1, 8},;
          { "Carina"       , {|| carina                }, .f., "N",  6, 2, 1, 9},;
          { "(%)"          , {|| "#"                   }, .f., "C",  6, 0, 2, 9},;
          { "PPP(%)"       , {|| porez                 }, .f., "N",  6, 2, 1,10},;
          { "Iznos"        , {|| kolicina*cijena       }, .t., "N", 11, 2, 1,11} }

 StampaTabele(aKol,{|| Blok30()},Znakova(gnLMarg,10,17),gTabela,;
              {|| cIdFirma+cIdTipDok+cBrDok==IdFirma+IdTipDok+BrDok},;
              ,,,,,,)
return
*}


/*! \fn Blok30()
 *  \brief 
 */
 
function Blok30()
*{
LOCAL nPom,nPoz
  select roba; hseek pripr->idroba; select pripr
  nUk+=round(kolicina*cijena , nZaokr)

  // izracunajmo koliki je iznos carine po carinskoj tarifi
  nPom:=round( kolicina*cijena*carina/100 , nZaokr)
  nUkCar+=nPom
  // ako ima carine, rasporedimo je u niz prema tarifi
  IF EMPTY(aCarTar).and.nPom>0
    AADD(aCarTar,{roba->cartar,carina,nPom})
  ELSEIF nPom>0
    nPoz:=ASCAN(aCarTar,{|x| x[1]==roba->cartar.and.x[2]==carina})
    IF nPoz==0
      AADD(aCarTar,{roba->cartar,carina,nPom})
    ELSE
      aCarTar[nPoz][3]+=nPom
    ENDIF
  ENDIF

  // izracunajmo PPP
  nPom:=round( kolicina*cijena*(1+carina/100)*(1+gCarEv/100)*porez/100 , nZaokr)
  nUkPor+=nPom
  // ako ima poreza, rasporedimo ga u niz prema stopi
  IF EMPTY(aPorezi).and.nPom>0
    AADD(aPorezi,{porez,nPom})
  ELSEIF nPom>0
    nPoz:=ASCAN(aPorezi,{|x| x[1]==porez})
    IF nPoz==0
      AADD(aPorezi,{porez,nPom})
    ELSE
      aPorezi[nPoz][2]+=nPom
    ENDIF
  ENDIF
return
*}


/*! \fn StFD4()
 *  \brief Rekapitulacije
 */
 
function StFD4()
*{
nUk:= round(nUk, nZaokr)
 ? space(Znakova(gnLMarg,10,17)); ??  m
 ? space(Znakova(gnLMarg,10,17)); ??  padl("Ukupno ("+cDinDem+") :",nLMRek); @ prow(),nCol1 SAY nUk pict picdem
 ? space(Znakova(gnLMarg,10,17)); ??  padl("Carinsko evidentiranje ("+ALLTRIM(STR(gCarEv))+"%) :",nLMRek); @ prow(),nCol1 SAY nUk*gCarEv/100 pict picdem
 IF !EMPTY(aCarTar)
   ASORT(aCarTar,,,{|x,y| STR(x[2],6,2)+x[1]<STR(y[2],6,2)+y[1]})
   FOR i:=1 TO LEN(aCarTar)
     ? space(Znakova(gnLMarg,10,17)); ??  padl("Carina "+STR(aCarTar[i,2],6,2)+"% ("+aCarTar[i,1]+") :",nLMRek); @ prow(),nCol1 SAY aCarTar[i,3] pict picdem
   NEXT
 ENDIF
 IF !EMPTY(aPorezi)
   ASORT(aPorezi,,,{|x,y| x[1]<y[1]})
   FOR i:=1 TO LEN(aPorezi)
     ? space(Znakova(gnLMarg,10,17)); ??  padl("Porez na promet proizvoda "+STR(aPorezi[i,1],6,2)+"% :",nLMRek); @ prow(),nCol1 SAY aPorezi[i,2] pict picdem
   NEXT
 ENDIF
RETURN
*}


/*! \fn StFD5()
 *  \brief Tekst na kraju fakture (napomena, odobrio, primio ...)
 */
 
function StFD5()    
*{
nUk:=nUk*(1+gCarEv/100)+nUkCar+nUkPor
 if !empty(picdem)
  cPom:=Slovima(round(nUk,nZaokr),cDinDem)
 else
  cPom:=""
 endif
 ? space(Znakova(gnLMarg,10,17)); ?? m+gPB_ON
 ? space(Znakova(gnLMarg,10,17)); ?? padl("U K U P N O  ("+cDinDem+") :",nLMRek); @ prow(),nCol1 SAY round(nUk,nzaokr) pict picdem; ?? gPB_OFF
 if !empty(picdem)
  ? space(Znakova(gnLmarg,10,17)); ?? "slovima: ",cPom
 else
  ?
 endif
 ? space(Znakova(gnLMarg,10,17)); ?? m
 ?
 ctxt2:=strtran(ctxt2,""+Chr(10),"")
 ctxt2:=strtran(ctxt2,Chr(13)+Chr(10),Chr(13)+Chr(10)+space(Znakova(gnLMarg,10,17)))
 ? space(Znakova(gnLMarg,10,17)); ?? ctxt2
 ?; ?; P_12CPI
 private cpom:=""
 ? g10Str2T
RETURN
*}

/*! \fn Znakova(nZnakova,nModIz,nModU)
 *  \brief Modovi: npr. 10, 12, 17, 20
 *  \param nZnakova
 *  \param nModIz
 *  \param nModU
 */
 
function Znakova(nZnakova,nModIz,nModU)  
*{
RETURN ROUND(nZnakova*nModU/nModIz,0)
*}


