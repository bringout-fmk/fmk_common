#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/dok/1g/stdok13.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.8 $
 * $Log: stdok13.prg,v $
 * Revision 1.8  2003/11/28 15:12:07  sasavranic
 * Opresa - stampa, stampa dostavnica u jedan red
 *
 * Revision 1.7  2003/11/21 08:46:40  sasavranic
 * Opresa - stampa, stampa samo jedne dostavnice
 * FMK.INI/PRIVPATH
 * [Stampa]
 *  JednaDostavnica=D
 *
 * Revision 1.6  2003/04/25 10:44:36  ernad
 * ispravka za Planiku: parametar Cijena13MPC=D vise ne setuje MPC u sifrarniku pri promjeni cijene u unosu 13-ke
 *
 * Revision 1.5  2002/09/14 07:25:36  mirsad
 * dokumentovanje INI parametara
 *
 * Revision 1.4  2002/07/04 19:04:08  ernad
 *
 *
 * ciscenje sifrarnik fakt
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

/*! \file fmk/fakt/dok/1g/stdok13.prg
 *  \brief Stampa dokumenata tipa 13
 */


/*! \ingroup ini
  * \var *string FmkIni_ExePath_Svi_SaberiKol
  * \brief Da li se prikazuje suma kolicina u svim stavkama bez obzira na to sto se radi o stavkama sa razlicitim artiklima ?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_ExePath_Svi_SaberiKol;


/*! \ingroup ini
  * \var *string FmkIni_SifPath_SifRoba_PBarkod
  * \brief Da li se mogu ispisivati bar-kodovi u dokumentima ?
  * \param 0 - ne, default vrijednost
  * \param 1 - da, na upit "Zelite li ispis bar-kodova?" ponudjen je odgovor "N"
  * \param 2 - da, na upit "Zelite li ispis bar-kodova?" ponudjen je odgovor "D"
  */
*string FmkIni_SifPath_SifRoba_PBarkod;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_Cijena13MPC
  * \brief Da li je MPC cijena koja se pamti u dokumentu tipa 13 ?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_KumPath_FAKT_Cijena13MPC;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_KupacDesno
  * \brief Da li se podaci o kupcu ispisuju uz desnu marginu dokumenta ?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_KumPath_FAKT_KupacDesno;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_Uska13ka
  * \brief Da li se 13-ka ispisuje u suzenoj varijanti (kolona sifre tarife umjesto naziva tarife, naziv robe 25 umjesto 28 znakova, kolicina 8 umjesto 11) ?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_KumPath_FAKT_Uska13ka;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_PrikazVPCu13ki
  * \brief Da li se prikazuje kolona VPC u 13-ki ?
  * \param D - da, default vrijednost
  * \param N - ne
  */
*string FmkIni_KumPath_FAKT_PrikazVPCu13ki;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_Uska13sirinaVPC
  * \brief Sirina kolone VPC u uskoj varijanti 13-ke
  * \param 5 - default vrijednost
  */
*string FmkIni_KumPath_FAKT_Uska13sirinaVPC;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_Uska13sirinaMPC
  * \brief Sirina kolone MPC u uskoj varijanti 13-ke
  * \param 5 - default vrijednost
  */
*string FmkIni_KumPath_FAKT_Uska13sirinaMPC;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_STAMPA_OpresaPicKol
  * \brief Format za prikaz kolicine u varijanti za Opresu (stampa)
  * \param 9999 - default vrijednost
  */
*string FmkIni_KumPath_STAMPA_OpresaPicKol;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_STAMPA_OpresaPicCij
  * \brief Format za prikaz cijene u varijanti za Opresu (stampa)
  * \param 999.99 - default vrijednost
  */
*string FmkIni_KumPath_STAMPA_OpresaPicCij;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_STAMPA_OpresaPicIzn
  * \brief Format za prikaz iznosa u varijanti za Opresu (stampa)
  * \param 99999.99 - default vrijednost
  */
*string FmkIni_KumPath_STAMPA_OpresaPicIzn;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_STAMPA_OpresaPicPor
  * \brief Format za prikaz poreza u procentima u varijanti za Opresu (stampa)
  * \param 99.99% - default vrijednost
  */
*string FmkIni_KumPath_STAMPA_OpresaPicPor;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_STAMPA_Opresa13ka_A4
  * \brief Da li se otpremnica (13-ka) u varijanti za Opresu (stampa) ispisuje na formatu papira A4 ?
  * \param N - ne nego na A3, default vrijednost
  * \param D - da, na A4
  */
*string FmkIni_KumPath_STAMPA_Opresa13ka_A4;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_STAMPA_Opresa13kaDuzinaNazivaRobe
  * \brief Sirina kolone naziva robe u otpremnici (13-ki) u varijanti za Opresu (stampa)
  * \param 18 - default vrijednost
  */
*string FmkIni_KumPath_STAMPA_Opresa13kaDuzinaNazivaRobe;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_STAMPA_Opresa13ka_3kolonski_P_COND
  * \brief Da li se koristi kondezovana gustoca ispisa u trokolonskoj varijanti otpremnice (13-ke) u varijanti za Opresu (stampa) ?
  * \param D - da, default vrijednost
  * \param N - ne
  */
*string FmkIni_KumPath_STAMPA_Opresa13ka_3kolonski_P_COND;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_STAMPA_Opresa13ka_2kolonski_P_12CPI
  * \brief Da li se koristi gustoca ispisa 12 CPI u dvokolonskoj varijanti otpremnice (13-ke) u varijanti za Opresu (stampa) ?
  * \param D - da, default vrijednost
  * \param N - ne
  */
*string FmkIni_KumPath_STAMPA_Opresa13ka_2kolonski_P_12CPI;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_STAMPA_Opresa13kaRedova
  * \brief Broj redova koji se ispisuju na jednoj otpremnici (13-ki) u varijanti za Opresu (stampa)
  * \param 36 - default vrijednost
  */
*string FmkIni_KumPath_STAMPA_Opresa13kaRedova;


/*! \fn StDok13()
 *  \brief Stampa dokumenta tipa 13
 */
 
function StDok13()
*{
PARAMETERS cIdFirma,cIdTipDok,cBrDok
local aKol:={}, cZag:="",i:=0,nI:=0,nK:=0

private cPMP:="1"

private nMPC2,nMPC1,nPPP,nPPU,nMPCSAPP
private cRegion:=GetRegion()

O_SIFK
O_SIFV
O_ROBA
O_TARIFA

fSaberikol:=(IzFMKIni('Svi','SaberiKol','N')=='D')

// fPBarkod - .t. stampati barkod, .f. ne stampati
private cPombk:=IzFmkIni("SifRoba","PBarkod","0",SIFPATH)
private fPBarkod:=.f.
if cPombk $ "12"  // pitanje, default "N"
   fPBarkod := ( Pitanje(,"Zelite li ispis barkodova ?",iif(cPombk=="1","N","D"))=="D")
endif

#ifdef CAX
  select (F_PRIPR)
  use
#endif

if pcount()==0
   O_PRIPR
   if gNovine=="D"
     FilterPrNovine()
   endif
   go top
else
   O_PFAKT
   seek cIdFirma+cIdTipDok+cBrDok
   NFOUND CRET
endif

if glCij13Mpc
  cpmp:="9"
elseif EMPTY(g13dcij) .and. gVar13!="2"
 Box(,1,50)
  cpmp:="9"
  @ m_x+1,m_y+2 SAY "Prikaz MPC ( 1/2/3/4/5/6/9 iz fakt-a) " GET cPMP valid cpmp $ "1234569"
  read
 BoxC()
else
 cPMP:=g13dcij
endif

POCNI STAMPU

//private cIdFirma,cBrDok,cIdTipDok
cIdFirma:=IdFirma
cBrDok:=BRDok
dDatDok:=DatDok
cIdTipDok:=IdTipDok
cidpartner:=Idpartner

cTxt1:=cTxt2:=cTxt3a:=cTxt3b:=cTxt3c:=""

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

nLTxt2:=1
for i:=1 to len(cTxt2)
  if substr(cTxt2,i,1)=chr(13); ++nLTxt2; endif
next
if idtipdok $ "10#11"; nLTxt2+=7; endif
 P_10CPI
 StZaglav2(gVlZagl,PRIVPATH)


if gVarF=="3"
 if IzFMKINI("FAKT","KupacDesno","N",KUMPATH)=="D"
   @ prow(),6 SAY padr(Mjesto(cIdFirma)+", "+dtoc(datdok)+" godine",36)
   ?
   ?
   ? space(5+39),gPB_ON+"ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿"+gPB_OFF
   ? space(6+39),gPB_ON+padc(alltrim(cTxt3a),30)+gPB_OFF
   ? space(6+39),gPB_ON+padc(alltrim(cTxt3b),30)+gPB_OFF
   ? space(6+39),gPB_ON+padc(alltrim(cTxt3c),30)+gPB_OFF
   ? space(5+39),gPB_ON+"ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ"+gPB_OFF
   cStr:=idtipdok+" "+trim(brdok)
   cIdTipDok:=IdTipDok
   private cpom:=""
   if !(cIdTipDok $ "00#01#19")
     cPom:="G"+cidtipdok+"STR"
     cStr:=&cPom+" "+trim(BrDok)
   endif
   ?
   ShowIdPar(cIdPartner,46,.f.)
   ?
   ? space(12)
   B_ON; ?? padc(cStr,50); B_OFF
 else
   @ prow(),36 SAY padl(Mjesto(cIdFirma)+", "+dtoc(datdok)+" godine",36)
   ?
   ?
   ? space(5),gPB_ON+"ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿"+gPB_OFF
   ? space(6),gPB_ON+padc(alltrim(cTxt3a),30)+gPB_OFF
   ? space(6),gPB_ON+padc(alltrim(cTxt3b),30)+gPB_OFF
   ? space(6),gPB_ON+padc(alltrim(cTxt3c),30)+gPB_OFF
   ? space(5),gPB_ON+"ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ"+gPB_OFF
   cStr:=idtipdok+" "+trim(brdok)
   cIdTipDok:=IdTipDok
   private cpom:=""
   if !(cIdTipDok $ "00#01#19")
     cPom:="G"+cidtipdok+"STR"
     cStr:=&cPom+" "+trim(BrDok)
   endif
   ?
   ShowIdPar(cIdPartner,7,.f.)
   ?
   ? space(12)
   B_ON
   U_ON
   ?? padl(cStr,30)
   U_OFF
   B_OFF
 endif
 ?
 ?
else
 if IzFMKINI("FAKT","KupacDesno","N",KUMPATH)=="D"
   ?? space(4),padr(Mjesto(cIdFirma)+", "+SrediDat(datdok),39) ; ?? gPB_ON+padc(alltrim(cTxt3a),30)+gPB_OFF
   ?  space(4+39),gPB_ON+padc(alltrim(cTxt3b),30)+gPB_OFF
   ?  space(4+39),gPB_ON+padc(alltrim(cTxt3c),30)+gPB_OFF
   cStr:=idtipdok+" "+trim(brdok)
   cIdTipDok:=IdTipDok

   private cpom:=""
   if !(cIdTipDok $ "00#01#19")
    cPom:="G"+cidtipdok+"STR"
    cStr:=&cPom+" "+trim(BrDok)
   endif
   ?
   ShowIdPar(cIdPartner,44,.f.)
   ? SPACE(12)
   B_ON; ??  padc(cStr,50); B_OFF
 else
   ?? space(4),gPB_ON+padc(alltrim(cTxt3a),30)+gPB_OFF; ?? padl(Mjesto(cIdFirma)+", "+SrediDat(datdok),39)
   ?  space(4),gPB_ON+padc(alltrim(cTxt3b),30)+gPB_OFF
   ?  space(4),gPB_ON+padc(alltrim(cTxt3c),30)+gPB_OFF
   cStr:=idtipdok+" "+trim(brdok)
   cIdTipDok:=IdTipDok

   private cpom:=""
   if !(cIdTipDok $ "00#01#19")
    cPom:="G"+cidtipdok+"STR"
    cStr:=&cPom+" "+trim(BrDok)
   endif
   B_ON; ??  padl(cStr,39); B_OFF
   ShowIdPar(cIdPartner,5,.t.)
 endif


   for i:=1 to gOdvT2; ?; next

endif




 if cPMP=="1"
   nMPCSAPP:=roba->mpc
 elseif cPMP=="2"
   nMPCSAPP:=roba->mpc2
 elseif cPMP=="3"
   nMPCSAPP:=roba->mpc3
 elseif cPMP=="4"
   nMPCSAPP:=roba->mpc4
 elseif cPMP=="5"
   nMPCSAPP:=roba->mpc5
 elseif cPMP=="6"
   nMPCSAPP:=roba->mpc6
 else
   nMPCSAPP:=pripr->cijena
 endif
 i:=1
 nC:=BrDecimala(piccdem)
 nI:=BrDecimala(picdem)
 nK:=BrDecimala(pickol)

AADD(aKol,{ "Redni"     , {|| rbr+"."               }, .f., "C",  5, 0, 1,   i} )
AADD(aKol,{ "broj"      , {|| "#"                   }, .f., "C",  5, 0, 2,   i} )

cTarifa:=TARIFA->id
if IzFMKINI("FAKT","Uska13ka","N",KUMPATH)=="D"
  AADD(aKol,{ "Tarifa"    , {|| cTarifa          }, .f., "C", 6, 0, 1, ++i} )
else
  AADD(aKol,{ "Tarifa"    , {|| tarifa->naz           }, .f., "C", 13, 0, 1, ++i} )
endif

AADD(aKol,{ "Sifra"     , {|| pripr->idroba         }, .f., "C", 10, 0, 1, ++i} )
AADD(aKol,{ "robe"      , {|| "#"                   }, .f., "C", 10, 0, 2,   i} )

if IzFMKINI("FAKT","Uska13ka","N",KUMPATH)=="D"
  AADD(aKol,{ "Naziv robe", {|| Rob13Naz()            }, .f., "P", 25, 0, 1, ++i} )
else
  AADD(aKol,{ "Naziv robe", {|| Rob13Naz()            }, .f., "P", 28, 0, 1, ++i} )
endif


if fSaberikol
  if IzFMKINI("FAKT","Uska13ka","N",KUMPATH)=="D"
    AADD(aKol,{ "Kolicina"  , {|| kolicina     }, .t., "N",  8,nK, 1, ++i,  ;
                                { || iif(roba->K2 = 'X',0, kolicina) } ;
            } )
  else
    AADD(aKol,{ "Kolicina"  , {|| kolicina     }, .t., "N", 11,nK, 1, ++i,  ;
                                { || iif(roba->K2 = 'X',0, kolicina) } ;
            } )
  endif
else
  if IzFMKINI("FAKT","Uska13ka","N",KUMPATH)=="D"
    AADD(aKol,{ "Kolicina"  , {|| kolicina     }, .f., "N",  8,nK, 1, ++i} )
  else
    AADD(aKol,{ "Kolicina"  , {|| kolicina     }, .f., "N", 11,nK, 1, ++i} )
  endif
endif

AADD(aKol,{ "J.mj."     , {|| roba->jmj             }, .f., "C",  5, 0, 1, ++i} )

if IzFMKINI("FAKT","PrikazVPCu13ki","D",KUMPATH)=="D"
  if gVar13!="2".or.gProtu13=="D".and.gVar13=="2"
   if IzFMKINI("FAKT","Uska13ka","N",KUMPATH)=="D"
     AADD(aKol,{ "VPC"       , {|| roba->vpc            }, .f., "N",  VAL(IzFMKINI("FAKT","Uska13sirinaVPC","5",KUMPATH)),nC, 1, ++i} )
   else
     AADD(aKol,{ "VPC"       , {|| roba->vpc            }, .f., "N", 11,nC, 1, ++i} )
   endif
   AADD(aKol,{ "VP iznos"  , {|| kolicina*roba->vpc   }, .t., "N", 11,nI, 1, ++i} )
  endif
endif

if IzFMKINI("FAKT","Uska13ka","N",KUMPATH)=="D"
  AADD(aKol,{ "PPP"       , {|| nPPP                  }, .t., "N", 10,nI, 1, ++i} )
  AADD(aKol,{ "PP"        , {|| nPPU                  }, .t., "N", 10,nI, 1, ++i} )
else
  AADD(aKol,{ "PPP"       , {|| nPPP                  }, .t., "N", 11,nI, 1, ++i} )
  AADD(aKol,{ "PP"        , {|| nPPU                  }, .t., "N", 11,nI, 1, ++i} )
endif

if IzFMKINI("FAKT","Uska13ka","N",KUMPATH)=="D"
  AADD(aKol,{ "MPC"       , {|| nMPCSAPP              }, .f., "N",  VAL(IzFMKINI("FAKT","Uska13sirinaMPC","5",KUMPATH)),nC, 1, ++i} )
else
  AADD(aKol,{ "MPC"       , {|| nMPCSAPP              }, .f., "N", 11,nC, 1, ++i} )
endif

AADD(aKol,{ "MP iznos"  , {|| kolicina*nMPCSAPP     }, .t., "N", 11,nI, 1, ++i} )

StampaTabele(aKol, {|| NadjiVr()}, gnLMarg, gTabela, {|| ForDok13()},,,,,,if(gHLinija=="D",.t.,.f.),)

if gRekTar=="D" .and. cidTipdok=="13"
   select pripr
   private cFilTarifa:="idfirma=="+cm2str(cidfirma)+".and. idtipdok=="+cm2str(cidtipdok)+".and. brdok=="+cm2str(cbrdok)
   set relation to idroba into roba
   if cRegion=="3"
     index on roba->idtarifa3  to fakttar2 for &cFilTarifa
   elseif cRegion=="2"
     index on roba->idtarifa2  to fakttar2 for &cFilTarifa
   else
     index on roba->idtarifa  to fakttar2 for &cFilTarifa
   endif
   P_COND
   RekTarife(cPmP,cRegion)
   select pripr
   use
endif

 P_12CPI
 ?
 ?

PrStr2T(cIdTipDok)

 FF

 ZAVRSI STAMPU

CLOSERET
*}

/*! \fn NadjiVr()
 *  \brief Nadji vrijednost
 */
 
function NadjiVr()
*{
local nPor

// Nastimaj (hseek) Sifr.Robe Na Pripr->IdRoba
NSRNPIdRoba()   
aPorezi:={}
SELECT PRIPR
PushWa()
cTar:=cTarifa:=TarifaR(cRegion, ROBA->id, @aPorezi)


if gVar13<>"2"
if cPMP=="2"
nMPCSAPP:=roba->mpc2
elseif cPMP=="3"
nMPCSAPP:=roba->mpc3
elseif cPMP=="4"
nMPCSAPP:=roba->mpc4
elseif cPMP=="5"
nMPCSAPP:=roba->mpc5
elseif cPMP=="6"
nMPCSAPP:=roba->mpc6
elseif cpmp=="1"
nMPCSAPP:=roba->mpc
else
nMPCSAPP:=pripr->cijena
endif
else
nMPCSaPP:=cijena
endif

nMPC1 := MpcBezPor( nMPCSaPP , aPorezi )
nMPC2 := nMPC1 + Izn_P_PPP( nMPC1 , aPorezi )

nPPP := Izn_P_PPP(nMPC1*kolicina, aPorezi)


nPPU := Izn_P_PP(nMPC1*kolicina, aPorezi)

nPor:=  Izn_P_PPP(nMPC1, aPorezi) + Izn_P_PP(nMPC1, aPorezi)

PopWa()
SELECT pripr
return
*}


/*! \fn BrDecimala(cFormat)
 *  \brief 
 *  \param cFormat
 *  \return nVrati
 */
 
function BrDecimala(cFormat)
*{
local i:=0,cPom,nVrati:=0
 i:=AT(".",cFormat)
 if i!=0
   cPom:=ALLTRIM(SUBSTR(cFormat,i+1))
   FOR i:=1 TO LEN(cPom)
     if SUBSTR(cPom,i,1)=="9"
       nVrati+=1
     else
       EXIT
     endif
   NEXT
 endif
return nVrati
*}


/*! \fn Rob13Naz()
 *  \brief Naziv robe 
 */
 
function Rob13Naz()
*{
if fPBarkod
  return PADR(trim(roba->naz)+" ("+TRIM(roba->barkod)+")",49)
else
  return PADR(roba->naz,49)
endif
*}


/*! \fn StDok13s()
 *  \brief Stampa otpremnice - Opresa magacin stampe
 */
 
function StDok13s()
*{
PARAMETERS cIdFirma,cIdTipDok,cBrDok
local aKol:={}, cZag:="",i:=0,nI:=0,nK:=0

pickolx  := IzFMKINI( "STAMPA" , "OpresaPicKol" , "9999"     , KUMPATH )
piccdemx := IzFMKINI( "STAMPA" , "OpresaPicCij" , "999.99"   , KUMPATH )
picdemx  := IzFMKINI( "STAMPA" , "OpresaPicIzn" , "99999.99" , KUMPATH )
picporx  := IzFMKINI( "STAMPA" , "OpresaPicPor" , "99.99%"   , KUMPATH )

O_SIFK
O_SIFV
O_ROBA
O_TARIFA

fSaberikol:=(IzFMKIni('Svi','SaberiKol','N')=='D')

private cPombk:=IzFmkIni("SifRoba","PBarkod","0",SIFPATH)
private fPBarkod:=.f.
if cPombk $ "12"  // pitanje, default "N"
   fPBarkod := ( Pitanje(,"Zelite li ispis barkodova ?",iif(cPombk=="1","N","D"))=="D")
endif

#ifdef CAX
  select (F_PRIPR); use
#endif

if pcount()==0
   O_PRIPR
   FilterPrNovine()
   go top
else
   O_PFAKT
   seek cIdFirma+cIdTipDok+cBrDok
   NFOUND CRET
endif

cpmp:="9"

POCNI STAMPU

if !lSSIP99
  gRPL_gusto()
endif

cIdFirma:=IdFirma
cBrDok:=BRDok
dDatDok:=DatDok
cIdTipDok:=IdTipDok
cidpartner:=Idpartner

cTxt1:=cTxt2:=cTxt3a:=cTxt3b:=cTxt3c:=""

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

//  duzina slobodnog teksta
nLTxt2:=1

for i:=1 to len(cTxt2)
	if substr(cTxt2,i,1)==chr(13)
		++nLTxt2
	endif
next

if idtipdok $ "10#11"
	nLTxt2+=7
endif

P_10CPI
StZaglav2(gVlZagl,PRIVPATH)

cStr:=idtipdok+" "+trim(brdok)
cIdTipDok:=IdTipDok
private cpom:=""
if !(cIdTipDok $ "00#01#19")
	cPom:="G"+cidtipdok+"STR"
   	cStr:=&cPom+" "+trim(BrDok)
endif

if IzFMKINI("STAMPA","Opresa13ka_A4","N",KUMPATH)=="D"
	nPomak:=44+0
else
   	nPomak:=44+30
endif
?? space(nPomak),gPB_ON+"ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿"+gPB_OFF
? space(1+nPomak),gPB_ON+padc(alltrim(cTxt3a),30)+gPB_OFF
? padr(Mjesto(cIdFirma)+", "+dtoc(datdok)+" godine",42)
?? space(1+nPomak-42),gPB_ON+padc(alltrim(cTxt3b),30)+gPB_OFF
? space(1+nPomak),gPB_ON+padc(alltrim(cTxt3c),30)+gPB_OFF
?
B_ON
?? padr(cStr,44)
B_OFF
?? space(nPomak-44),gPB_ON+"ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ"+gPB_OFF

?
ShowIdPar(cIdPartner,46,.f.)

private nMPC2,nMPC1,nPPP,nPPU,nMPCSAPP

i:=1

nZaokr:=ZAOKRUZENJE
cDinDEM:=dindem
nDNRobe:=VAL(IzFMKINI("STAMPA","Opresa13kaDuzinaNazivaRobe","18",KUMPATH))

aKol:={}
nUkupno:=0
do while !EOF() .and. cIdFirma+cIdTipDok+cBrDok==IdFirma+IdTipDok+BrDok
   NSRNPIdRoba()   // Nastimaj (hseek) Sifr.Robe Na Pripr->IdRoba
   select tarifa
   hseek (cTar:=roba->idtarifa)
   select pripr
   nMPCSaPP := cijena
   nMPC2    := nMPCSAPP/(1+tarifa->ppp/100)
   nMPC1    := nMPC2/(1+tarifa->opp/100)
   nPPP     := (nMPC2-nMPC1)*kolicina
   nPor     := nMPC1*tarifa->opp/100+nMPC2*tarifa->ppp/100
   nPPU     := nPor*kolicina-nPPP
   AADD( aKol , { idroba, PADR(ROBA->naz,nDNRobe),;
                  TRANSFORM(tarifa->opp    ,picporx   ),;
                  TRANSFORM(kolicina       ,pickolx   ),;
                  TRANSFORM(cijena         ,piccdemx  ),;
                  TRANSFORM(kolicina*cijena,picdemx   ) } )
   nUkupno+=kolicina*cijena
   SKIP 1
 enddo

 m := REPL( "-" , LEN(idroba)             )+" "+;
      REPL( "-" , nDNRobe                 )+" "+;
      REPL( "-" , LEN(TRANS(0,picporx))   )+" "+;
      REPL( "-" , LEN(TRANS(0,pickolx))   )+" "+;
      REPL( "-" , LEN(TRANS(0,piccdemx))  )+" "+;
      REPL( "-" , LEN(TRANS(0,picdemx))   )

 z := PADC( "Izdanje"       , LEN(idroba)             )+" "+;
      PADC( "Naziv izdanja" , nDNRobe                 )+" "+;
      PADC( "Porez"         , LEN(TRANS(0,picporx))   )+" "+;
      PADC( "Kol."          , LEN(TRANS(0,pickolx))   )+" "+;
      PADC( "Cij."          , LEN(TRANS(0,piccdemx))  )+" "+;
      PADC( "Iznos"         , LEN(TRANS(0,picdemx))   )


nStavki:=LEN(aKol)
nRedova:=7
cRIK:=SPACE(5)  // razmak izmeÐu kolona

if IzFmkIni("Stampa","StUJedanRed","N",KUMPATH)=="N"
 if nStavki>14
   nKolona := 3
   if IzFMKINI("STAMPA","Opresa13ka_3kolonski_P_COND","D",KUMPATH)=="D"
     P_COND
   else
     P_COND2
   endif
   ? m+cRIK+m+cRIK+m
   ? z+cRIK+z+cRIK+z
   ? m+cRIK+m+cRIK+m
 elseif nStavki>7
   if IzFMKINI("STAMPA","Opresa13ka_A4","N",KUMPATH)=="D"
     P_COND2
   else
     if IzFMKINI("STAMPA","Opresa13ka_2kolonski_P_12CPI","D",KUMPATH)=="D"
       P_12CPI
     else
       P_COND
     endif
   endif
   nKolona := 2
   ? m+cRIK+m
   ? z+cRIK+z
   ? m+cRIK+m
 else
   P_10CPI
   nKolona := 1
   ? m
   ? z
   ? m
 endif

 FOR i:=1 TO nRedova
   if i<=nStavki
     ?  aKol[i,1]+" "+gpB_ON +gpI_ON
     ?? aKol[i,2]+" "+gpB_OFF+gpI_OFF
     ?? aKol[i,3]+" "+gpB_ON +gpI_ON
     ?? aKol[i,4]+" "+gpB_OFF+gpI_OFF
     ?? aKol[i,5]+" "
     ?? aKol[i,6]
   else
     EXIT
   endif
   if nRedova+i<=nStavki
     ?? cRIK
     ?? aKol[nRedova+i,1]+" "+gpB_ON +gpI_ON
     ?? aKol[nRedova+i,2]+" "+gpB_OFF+gpI_OFF
     ?? aKol[nRedova+i,3]+" "+gpB_ON +gpI_ON
     ?? aKol[nRedova+i,4]+" "+gpB_OFF+gpI_OFF
     ?? aKol[nRedova+i,5]+" "
     ?? aKol[nRedova+i,6]
   endif
   if 2*nRedova+i<=nStavki
     ?? cRIK
     ?? aKol[2*nRedova+i,1]+" "+gpB_ON +gpI_ON
     ?? aKol[2*nRedova+i,2]+" "+gpB_OFF+gpI_OFF
     ?? aKol[2*nRedova+i,3]+" "+gpB_ON +gpI_ON
     ?? aKol[2*nRedova+i,4]+" "+gpB_OFF+gpI_OFF
     ?? aKol[2*nRedova+i,5]+" "
     ?? aKol[2*nRedova+i,6]
   endif
   ?
 NEXT


else
	nKolona:=1
	? m
  	? z
   	? m
	for i:=1 to nStavki
		? aKol[i,1]+" "+gpB_ON +gpI_ON
     		?? aKol[i,2]+" "+gpB_OFF+gpI_OFF
     		?? aKol[i,3]+" "+gpB_ON +gpI_ON
     		?? aKol[i,4]+" "+gpB_OFF+gpI_OFF
     		?? aKol[i,5]+" "
     		?? aKol[i,6]
	next
endif

nDokle := nKolona*LEN(m)+(nKolona-1)*LEN(cRIK)
? m+IF(nKolona>1,cRIK+m,"")+IF(nKolona>2,cRIK+m,"")
? gpB_ON+PADL( "U K U P N O  ("+cDinDem+") :"+TRANS(round(nUkupno,nZaokr),picdemx) , nDokle )
 ? "slovima: ",Slovima(round(nUkupno,nZaokr),cDinDem)+gpB_OFF
 ? m+IF(nKolona>1,cRIK+m,"")+IF(nKolona>2,cRIK+m,"")

 P_10CPI
 ?
 PrStr2T(cIdTipDok)

if !lSSIP99
	gRPL_normal()
  	FF
else
	if IzFmkIni("STAMPA", "JednaDostavnica","N",PRIVPATH)=="N" 
  		++nDokumBr
  		if nDokumBr%3==0
    			FF
  		else
			nJosRedova := (nDokumBr%3)*VAL(IzFMKINI("STAMPA","Opresa13kaRedova","36",KUMPATH)) - PROW()
    			FOR i:=1 TO nJosRedova
    				?
    			NEXT
  		endif
 	else
		FF
	endif
endif

ZAVRSI STAMPU

CLOSERET
*}


/*! \fn GetRegion()
 *  \brief 
 *  \return cRegion
 */
 
function GetRegion()
*{
local cRegion:=" "
local nArr

nArr:=SELECT()
SELECT (F_ROBA)
if !USED()
  O_ROBA
endif
if ROBA->(FIELDPOS("IDTARIFA2")<>0)
   cRegion := Pitanje( , "Porezi za region (1/2/3) ?" , "1" , " 123" )
endif
SELECT (nArr)
return cRegion
*}

function ForDok13()
*{
local lPom

lPom:=cIdFirma+cIdTipDok+cBrDok==pripr->IdFirma+pripr->IdTipDok+pripr->brDok

return lPom
*}


