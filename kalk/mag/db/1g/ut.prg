#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/mag/db/1g/ut.prg,v $
 * $Author: ernadhusremovic $ 
 * $Revision: 1.4 $
 * $Log: ut.prg,v $
 * Revision 1.4  2003/11/04 02:13:28  ernadhusremovic
 * Planika Kranj - Robno poslovanje
 *
 * Revision 1.3  2003/07/18 07:24:54  mirsad
 * stavio u f-ju kontrolu stanja za varijantu po narudzbama za izlazne dokumente (14,41,42)
 *
 * Revision 1.2  2002/06/19 13:57:53  mirsad
 * no message
 *
 *
 */


/*! \file fmk/kalk/mag/db/1g/ut.prg
 *  \brief Razne funkcije vezane za magacin
 */


/*! \fn KalkNabP(cidfirma,cidroba,cidkonto,nkolicina,nKolZN,nNC,nSNC,dDatNab,dRokTr)
 *  \brief 
 *  \param nNC - zadnja nabavna cijena
 *  \param nSNC - srednja nabavna cijena
 *  \param nKolZN - kolicina koja je na stanju od zadnjeg ulaza u prodavnicu, a ako se radi sa prvom nabavkom - prvi ulaz u prodavnicu
 *  \param dDatNab - datum nabavke
 *  \param dRokTr  - rok trajanja
 */

function KalkNabP(cIdFirma, cIdroba, cIdkonto, nKolicina, nKolZN, nNC, nSNC, dDatNab, dRokTr)
*{
local npom,fproso
local nIzlNV
local nIzlKol
local nUlNV
local nUlKol
local nSkiniKol

nKolicina:=0
select kalk
select kalk
set order to 4  //idFirma+pkonto+idroba+pu_i+IdVD
seek cidfirma+cidkonto+cidroba+chr(254)
skip -1
if cIdfirma+cIdkonto+cIdroba==idfirma+pkonto+idroba .and. _datdok<datdok
  Beep(2)
  Msg("Postoji dokument "+idfirma+"-"+idvd+"-"+brdok+" na datum: "+dtoc(datdok),4)
  _ERROR:="1"
endif

nLen:=1

nKolicina:=0

// ukupna izlazna nabavna vrijednost
nIzlNV:=0  

// ukupna izlazna kolicina
nIzlKol:=0  
nUlNV:=0

// ulazna kolicina
nUlKol:=0  

//  ovo je prvi prolaz
hseek cIdFirma+cIdKonto+cIdRoba
do while !eof() .and. cIdFirma+cIdKonto+cIdroba==idFirma+pkonto+idroba .and. _datdok>=datdok

  if pu_i=="1" .or. pu_i=="5"
    if (pu_i=="1" .and. kolicina>0) .or. (pu_i=="5" .and. kolicina<0)
      nKolicina += abs(kolicina)       // rad metode prve i zadnje nc moramo
      nUlKol    += abs(kolicina)       // sve sto udje u magacin strpati pod
      nUlNV     += (abs(kolicina)*nc)  // ulaznom kolicinom
    else
      nKolicina -= abs(kolicina)
      nIzlKol   += abs(kolicina)
      nIzlNV    += (abs(kolicina)*nc)
    endif
  elseif pu_i=="I"
     nKolicina-=gkolicin2
     nIzlKol+=gkolicin2
     nIzlNV+=nc*gkolicin2
  endif
  skip

enddo //  ovo je prvi prolaz



//gMetodaNC=="3"  // prva nabavka  se prva skida sa stanja
if gmetodanc=="3"
  hseek cidfirma+cidkonto+cidroba
  nSkiniKol:=nIzlKol+_Kolicina // skini sa stanja ukupnu izlaznu kolicinu+tekucu kolicinu
  nNabVr:=0  // stanje nabavne vrijednosti
  do while !eof() .and. cidfirma+cidkonto+cidroba==idFirma+pkonto+idroba .and. _datdok>=datdok

    if pu_i=="1" .or. pu_i=="5"
      if (pu_i=="1" .and. kolicina>0) .or. (pu_i=="5" .and. kolicina<0)
           if nSkiniKol>abs(kolicina)
             nNabVr   +=abs(kolicina*nc)
             nSkinikol-=abs(kolicina)
           else
             nNabVr   +=abs(nSkiniKol*nc)
             nSkinikol:=0
             dDatNab:=datdok
             nKolZN:=nSkiniKol
//             dRoktr:=
             exit // uzeta je potrebna nabavka, izadji iz do while
           endif
       endif
    elseif pu_i=="I" .and.  gkolicin2<0   // IP - storno izlaz

           if nSkiniKol>abs(gKolicin2)
             nNabVr   +=abs(gkolicin2*nc)
             nSkinikol-=abs(gkolicin2)
           else
             nNabVr   +=abs(nSkiniKol*nc)
             nSkinikol:=0
             dDatNab:=datdok
             nKolZN:=nSkiniKol
//             dRoktr:=
             exit // uzeta je potrebna nabavka, izadji iz do while
           endif

    endif
    skip
  enddo //  ovo je drugi prolaz , metoda "3"

  if _kolicina<>0
    nNC:=(nNabVr-nIzlNV)/_kolicina   // nabavna cijena po metodi prve
  else
    nNC:=0
  endif
endif

//gMetodaNC=="1"  // zadnja nabavka se prva skida sa stanja
if gmetodanc=="1"
  seek cidfirma+cidkonto+cidroba+chr(254)
  nSkiniKol:=nIzlKol+_Kolicina // skini sa stanja ukupnu izlaznu kolicinu+tekucu kolicinu
  nNabVr:=0  // stanje nabavne vrijednosti
  skip -1
  do while !bof() .and. cidfirma+cidkonto+cidroba==idFirma+pkonto+idroba

    if _datdok<=datdok // preskaci novije datume
      skip -1
      loop
    endif

    if pu_i=="1" .or. pu_i=="5"
      if (pu_i=="1" .and. kolicina>0) .or. (pu_i=="5" .and. kolicina<0) // ulaz
           if nSkiniKol>abs(kolicina)
             nNabVr   +=abs(kolicina*nc)
             nSkinikol-=abs(kolicina)
           else
             nNabVr   +=abs(nSkiniKol*nc)
             nSkinikol:=0
             dDatNab:=datdok
             nKolZN:=nSkiniKol
//             dRoktr:=
             exit // uzeta je potrebna nabavka, izadji iz do while
           endif
      endif
    elseif (pu_i=="I"  .and. gkolicin2<0)
           if nSkiniKol>abs(gkolicin2)
             nNabVr   +=abs(gkolicin2*nc)
             nSkinikol-=abs(gkolicin2)
           else
             nNabVr   +=abs(nSkiniKol*nc)
             nSkinikol:=0
             dDatNab:=datdok
             nKolZN:=nSkiniKol
//             dRoktr:=
             exit // uzeta je potrebna nabavka, izadji iz do while
           endif
    endif
    skip -1
  enddo //  ovo je drugi prolaz , metoda "1"

  if _kolicina<>0
    nNC:=(nNabVr-nIzlNV)/_kolicina   // nabavna cijena po metodi zadnje
  else
    nNC:=0
  endif
endif

if round(nKolicina, 5)==0
 nSNC:=0
else
 nSNC:=(nUlNV-nIzlNV)/nkolicina
endif

nKolicina:=round(nKolicina,4)
select pripr
return
*}



/*! \fn Marza(fmarza)
 *  \brief Proracun veleprodajne marze
 */

function Marza(fmarza)
*{
local SKol:=0,nPPP

if fmarza==NIL
  fMarza:=" "
endif

if _nc==0
  _nc:=9999
endif

if roba->tip $ "VKX"
  nPPP:=1/(1+tarifa->opp/100)
  if roba->tip="X"; nPPP:=nPPP*_mpcsapp/_vpc; endif
else
  nPPP:=1
endif


if gKalo=="1" .and. _idvd=="10"
 Skol:=_Kolicina-_GKolicina-_GKolicin2
else
 Skol:=_Kolicina
endif

if  _Marza==0 .or. _VPC<>0 .and. empty(fMarza)
  nMarza:=_VPC*nPPP-_NC
  if roba->tip="X"
    nMarza -= roba->mpc-_VPC
    // nmarza:= _vpc*npp-_nc - (roba->mpc-_vpc)
    // nmarza/_nc := (_vpc*nppp/nc-1 - (roba->mpc-_Vpc)/nc)
    // nmarza/_nc := ( (_vpc*nppp - roba->mpc -_vpc)/_nc-1)
  endif
  if _TMarza=="%"
     if roba->tip="X"
      _Marza:=100*( (_VPC*nPPP - roba->mpc - _vpc)/_NC-1)
     else
      _Marza:=100*(_VPC*nPPP/_NC-1)
     endif
  elseif _TMarza=="A"
    _Marza:=nMarza
  elseif _TMarza=="U"
    _Marza:=nMarza*SKol
  endif

elseif round(_VPC,4)==0  .or. !empty(fMarza)
  if _TMarza=="%"
     nMarza:=_Marza/100*_NC
  elseif _TMarza=="A"
     nMarza:=_Marza
  elseif _TMarza=="U"
     nMarza:=_Marza/SKol
  endif
  _VPC:=round((nMarza+_NC)/nPPP,2)
else
  if _idvd $ "14#94"
   if roba->tip=="V"
     nMarza:=_VPC*nPPP-_VPC*_Rabatv/100-_NC
   else
     nMarza:=_VPC*nPPP*(1-_Rabatv/100)-_NC
   endif
  else
   nMarza:=_VPC*nPPP-_NC
  endif
endif
AEVAL(GetList,{|o| o:display()})
return
*}



/*! \fn FaktVPC(nVPC,cseek,dDatum)
 *  \brief Fakticka veleprodajna cijena
 */

function FaktVPC(nVPC,cseek,dDatum)
*{
local nOrder
  if koncij->naz=="V2" .and. roba->(fieldpos("vpc2"))<>0
    nVPC:=roba->vpc2
  elseif koncij->naz=="P2"
    nVPC:=roba->plc
  elseif roba->(fieldpos("vpc"))<>0
    nVPC:=roba->vpc
  else
    nVPC:=0
  endif

  select kalk
  PushWa()
  set filter to
  //nOrder:=indexord()
  set order to 3 //idFirma+mkonto+idroba+dtos(datdok)
  seek cseek+"X"
  skip -1

  do while !bof() .and. idfirma+mkonto+idroba==cseek

    if dDatum<>NIL .and. dDatum<datdok
       skip -1; loop
    endif
    //if mu_i=="1" //.or. mu_i=="5"
    if idvd $ "RN#10#16#12#13"
      if koncij->naz<>"P2"
        nVPC:=vpc
      endif
      exit
    elseif idvd=="18"
      nVPC:=mpcsapp+vpc
      exit
    endif
    skip -1
  enddo
  PopWa()
  //dbsetorder(nOrder)
return
*}



/*! \fn PratiKMag(cidfirma,cidkonto,cidroba)
 *  \brief Prati karticu magacina
 */
 
function PratiKMag(cidfirma,cidkonto,cidroba)
*{
local nPom
select kalk ; set order to 3
hseek cidfirma+cidkonto+cidroba
//"KALKi3","idFirma+mkonto+idroba+dtos(datdok)+PODBR+MU_I+IdVD",KUMPATH+"KALK")

nVPV:=0
nKolicina:=0
do while !eof() .and.  cidfirma+cidkonto+cidroba==idfirma+idkonto+idroba

   dDatDok:=datdok
   do while !eof() .and.  cidfirma+cidkonto+cidroba==idfirma+idkonto+idroba ;
                   .and. datdok==dDatDok


       nVPC:=vpc   // veleprodajna cijena
       if mu_i=="1"
          nPom:=kolicina-gkolicina-gkolicin2
          nKolicina+= nPom
          nVPV+=nPom*vpc
       elseif mu_i=="3"
          nPom:=kolicina
          nVPV+=nPom*vpc
          // kod ove kalk mpcsapp predstavlja staru vpc
          nVPC:=vpc+mpcsapp
       elseif mu_i=="5"
          nPom:=kolicina
          nVPV-=nPom*VPC
       endif

       if round(nKolicina,4)<>0
          if round(nVPV/nKolicina,2) <> round(nVPC,2)

          endif
       endif

   enddo

enddo
return
*}



/*! \fn ObSetVPC(nNovaVrijednost)
 *  \brief Obavezno setuj VPC
 */

function ObSetVPC(nNovaVrijednost)
*{
  local nArr:=SELECT()
  private cPom:="VPC"
  if koncij->naz=="P2"
    cPom:="PLC"
  elseif koncij->naz=="V2"
    cPom:="VPC2"
  else
    cPom:="VPC"
  endif
  select roba
   replace &cPom with nNovaVrijednost
  select (nArr)
return .t.
*}



/*! \fn UzmiVPCSif(cMKonto,lKoncij)
 *  \brief Za zadani magacinski konto daje odgovarajucu VPC iz sifrarnika robe
 */

function UzmiVPCSif(cMKonto,lKoncij)
*{
 LOCAL nCV:=0, nArr:=SELECT()
 IF lKoncij=NIL; lKoncij:=.f.; ENDIF
  SELECT KONCIJ
   nRec:=RECNO()
    SEEK TRIM(cMKonto)
    nCV:=KoncijVPC()
   IF !lKoncij
     GO (nRec)
   ENDIF
  SELECT (nArr)
return nCV
*}



/*! \fn NabCj()
 *  \brief Proracun nabavne cijene za ulaznu kalkulaciju 10
 */

function NabCj()
*{
local Skol

if gKalo=="1"
 Skol:=_Kolicina-_GKolicina-_GKolicin2
else
 Skol:=_Kolicina
endif


if _TPrevoz=="%"
  nPrevoz:=_Prevoz/100*_FCj2
elseif _TPrevoz=="A"
  nPrevoz:=_Prevoz
elseif _TPrevoz=="U"
  nPrevoz:=_Prevoz/SKol
elseif _TPrevoz=="R"
  nPrevoz:=0
else
  nPrevoz:=0
endif
if _TCarDaz=="%"
  nCarDaz:=_CarDaz/100*_FCj2
elseif _TCarDaZ=="A"
 nCarDaz:=_CarDaz
elseif _TCArDaz=="U"
 nCarDaz:=_CarDaz/SKol
elseif _TCArDaz=="R"
 nCarDaz:=0
else
 nCardaz:=0
endif
if _TZavTr=="%"
  nZavTr:=_ZavTr/100*_FCj2
elseif _TZavTr=="A"
  nZavTr:=_ZavTr
elseif _TZavTr=="U"
  nZavTr:=_ZavTr/SKol
elseif _TZavTr=="R"
  nZavTr:=0
else
  nZavTr:=0
endif
if _TBankTr=="%"
   nBankTr:=_BankTr/100*_FCj2
elseif _TBankTr=="A"
   nBankTr:=_BankTr
elseif _TBankTr=="U"
   nBankTr:=_BankTr/SKol
else
   nBankTr:=0
endif
if _TSpedTr=="%"
   nSpedTr:=_SpedTr/100*_FCj2
elseif _TSpedTr=="A"
   nSpedTr:=_SpedTr
elseif _TSpedTr=="U"
   nSpedTr:=_SpedTr/SKol
else
   nSpedTr:=0
endif

_NC:=_FCj2+nPrevoz+nCarDaz+nBanktr+nSpedTr+nZavTr

return
*}



/*! \fn NabCj2(n1,n2)  
 *  \param n1 - ukucana NC
 *  \param n2 - izracunata NC
 *  \brief Ova se f-ja koristi samo za 10-ku bez troskova (gVarijanta="1")
 */

function NabCj2(n1,n2)  
*{
 IF glEkonomat
   _fcj:=_fcj2:=_nc
   _rabat:=0
 ELSEIF ABS(n1-n2)>0.00001   // tj. ako je ukucana drugacija NC
   _rabat:=100-100*_NC/_FCJ
   _FCJ2:=_NC
   ShowGets()
 ENDIF
return .t.
*}



/*! \fn SetujVPC(nNovaVrijednost,fUvijek)
 *  \param fUvijek -.f. samo ako je vrijednost u sifrarniku 0, .t. uvijek setuj
 *  \brief Utvrdi varijablu VPC. U sifrarnik staviti novu vrijednost
 */

function SetujVPC(nNovaVrijednost,fUvijek)
*{
 private cPom:="VPC" ,  nVal
 if koncij->naz=="P2"
   cPom:="PLC"
   nVal:=roba->plc
 elseif koncij->naz=="V2"
   cPom:="VPC2"
   nVal:=roba->VPC2
 else
   cPom:="VPC"
   nVal:=roba->VPC
 endif
 if nVal=0  .or. fUvijek
   if Pitanje(,"Staviti Cijenu ("+cPom+")"+" u sifrarnik ?","D")=="D"
     select roba
     replace &cPom with nNovaVrijednost
     select pripr
   endif
 endif
return .t.
*}



/*! \fn KoncijVPC()
 *  \brief Daje odgovarajucu VPC iz sifrarnika robe
 */

function KoncijVPC()
*{
 // podrazumjeva da je nastimana tabela koncij
 // ------------------------------------------
 if koncij->naz=="P2"
   return roba->plc
 elseif koncij->naz=="V2"
   return roba->VPC2
 elseif koncij->naz=="V3"
   return roba->VPC3
 else
   return roba->VPC
 endif
return (nil)
*}



/*! \fn VPCuSif(nNovaVrijednost)
 *  \brief Smjesta zadanu cijenu u odgovarajucu VPC u sifrarniku robe 
 */

function VPCuSif(nNovaVrijednost)
*{
 private cPom:="VPC", nVal
 if koncij->naz=="P2"
   cPom:="PLC"
   nVal:=roba->plc
 elseif koncij->naz=="V2"
   cPom:="VPC2"
   nVal:=roba->VPC2
 else
   cPom:="VPC"
   nVal:=roba->VPC
 endif
 if nVal=0
   if Pitanje(,"Staviti Cijenu ("+cPom+") "+iif(roba->tip=="V","VT","")+" u sifrarnik ?","D")=="D"
     select roba
     replace &cPom with nNovaVrijednost
     select pripr
   endif
 else
   if nNovaVrijednost<>nVal; Beep(1);Msg(cPom+" u sifrarniku je "+str(nVal,11,3),6); endif
 endif
return
*}



/*! \fn MMarza()
 *  \brief Preracunava iznos veleprodajne marze
 */

function MMarza()
*{
local SKol:=0
Skol:=Kolicina-GKolicina-GKolicin2
  if TMarza=="%".or.empty(tmarza)
     nMarza:=Skol*Marza/100*NC
  elseif TMarza=="A"
     nMarza:=Marza*Skol
  elseif TMarza=="U"
     nMarza:=Marza
  endif
return nMarza
*}



/*! \fn PrerRab()
 *  \brief Rabat veleprodaje - 14
 */

function PrerRab()
*{
local nPrRab
if cTRabat=="%"
   nPrRab:=_rabatv
elseif cTRabat=="A"
  if _VPC<>0
   nPrRab:=_RABATV/_VPC*100
  else
   nPrRab:=0
  endif
elseif cTRabat=="U"
 if _vpc*_kolicina<>0
   nprRab:=_rabatV/(_vpc*_kolicina)*100
 else
   nPrRab:=0
 endif
else
  return .f.
endif
_rabatv:=nPrRab
cTrabat:="%"
showgets()
return .t.
*}



/*! \fn V_KolMag()
 *  \brief Kontrola stanja robe u magacinu
 */

// Koristi sljedece privatne varijable:
// nKols   
// gMetodaNC
// _TBankTr - "X"  - ne provjeravaj - vrati .t.
// ---------------------------------------------
// Daje poruke:
// Nabavna cijena manja od 0 ??
// Ukupno na stanju samo XX robe !!

function V_KolMag()
*{
if _nc<0 .and. !(_idvd $ "11#12#13#22") .or.;
  _fcj<0 .and. _idvd $ "11#12#13#22"
 Msg("Nabavna cijena manja od 0 ??")
 _ERROR:="1"
endif

if roba->tip $ "UTY"; return .t. ; endif
if empty(gMetodaNC) .or. _TBankTR=="X"   // .or. lPoNarudzbi  
	return .t.
endif  // bez ograde

if nKolS<_Kolicina
 Beep(2);clear typeahead
 Msg("Ukupno na stanju je samo"+str(nKolS,10,4)+" robe !!",6)
 _ERROR:="1"
endif

return .t.
*}



/*! \fn V_RabatV()
 *  \brief Ispisuje vrijednost rabata u VP
 */
 
// Trenutna pozicija u tabeli KONCIJ (na osnovu koncij->naz ispituje cijene)
// Trenutan pozicija u tabeli ROBA (roba->tip)

function V_RabatV()
*{
local nPom, nMPCVT
local nRVPC:=0
private getlist:={}, cPom:="VPC"

 if koncij->naz=="P2"
   cPom:="PLC"
 elseif koncij->naz=="V2"
   cPom:="VPC2"
 else
   cPom:="VPC"
 endif

 if roba->tip $ "UTY"
    return .t.
 endif

 nRVPC:=KoncijVPC()
 if round(nRVPC-_vpc,4)<>0  .and. gMagacin=="2"
   if nRVPC==0
      Beep(1)
      Box(,3,60)
      @ m_x+1,m_Y+2 SAY "Roba u sifrarniku ima "+cPom+" = 0 !??"
      @ m_x+3,m_y+2 SAY "Unesi "+cPom+" u sifrarnik:" GET _vpc pict picdem
      read
      select roba; replace &cPom with _VPC
      select pripr
      BoxC()
   endif
 endif
 if roba->tip=="V" // roba tarife
   nMarza:=_VPC/(1+_PORVT)-_VPC*_RabatV/100-_NC
 elseif roba->tip="X"
   nMarza:=_VPC*(1-_RabatV/100)-_NC- _MPCSAPP/(1+_PORVT)*_porvt
 else
   nMarza:=_VPC/(1+_PORVT)*(1-_RabatV/100)-_NC
 endif
 @ m_x+15,m_y+41  SAY "VPC b.p.-RAB:"

 if roba->tip=="V"
   @ m_x+15,col()+1 SAY _Vpc/(1+_PORVT)-_VPC*_RabatV/100 pict picdem
 elseif roba->tip=="X"
   @ m_x+15,col()+1 SAY _Vpc*(1-_RabatV/100) - _MPCSAPP/(1+_PORVT)*_PORVT pict picdem
 else
   @ m_x+15,col()+1 SAY _Vpc/(1+_PORVT)*(1-_RabatV/100) pict picdem
 endif
 ShowGets()

return .t.
*}



/*! \fn KalkNab(cidfirma,cidroba,cidkonto,nkolicina,nKolZN,nNC,nSNC,dDatNab,dRokTr)
 *  \param nNC - zadnja nabavna cijena
 *  \param nSNC - srednja nabavna cijena
 *  \param nKolZN - kolicina koja je na stanju od zadnje nabavke
 *  \param dDatNab - datum nabavke
 *  \param dRokTr - rok trajanja
 *  \brief Racuna nabavnu cijenu i stanje robe u magacinu
 */

function KalkNab(cidfirma,cidroba,cidkonto,nkolicina,nKolZN,nNC,nSNC,dDatNab,dRokTr)
*{
local npom,fproso
local nIzlNV
local nIzlKol
local nUlNV
local nUlKol
local nSkiniKol
local nKolNeto

nKolicina:=0
select kalk
set order to 3
seek cidfirma+cidkonto+cidroba+"X"
skip -1
if cidfirma+cidkonto+cidroba==idfirma+mkonto+idroba .and. _datdok<datdok
  Beep(2)
  Msg("Postoji dokument "+idfirma+"-"+idvd+"-"+brdok+" na datum: "+dtoc(datdok),4)
  _ERROR:="1"
endif

nLen:=1

nKolicina:=0
nIzlNV:=0   // ukupna izlazna nabavna vrijednost
nUlNV:=0
nIzlKol:=0  // ukupna izlazna kolicina
nUlKol:=0  // ulazna kolicina
//  ovo je prvi prolaz
hseek cidfirma+cidkonto+cidroba
do while !eof() .and. cidfirma+cidkonto+cidroba==idFirma+mkonto+idroba .and. _datdok>=datdok

  if mu_i=="1" .or. mu_i=="5"
    if idvd=="10"
      nKolNeto:=abs(kolicina-gkolicina-gkolicin2)
    else
      nKolNeto:=abs(kolicina)
    endif

    if (mu_i=="1" .and. kolicina>0) .or. (mu_i=="5" .and. kolicina<0)
         nKolicina+=nKolNeto    // rad metode prve i zadnje nc moramo
         nUlKol   +=nKolNeto    // sve sto udje u magacin strpati pod
//         nUlNV    +=abs(nKolNeto*nc)      // ulaznom kolicinom
         nUlNV    += (nKolNeto*nc)      // ulaznom kolicinom
    else
         nKolicina-=nKolNeto
         nIzlKol  +=nKolNeto
//         nIzlNV   +=abs(nKolNeto*nc)
         nIzlNV   += (nKolNeto*nc)
    endif
  endif
  skip

enddo //  ovo je prvi prolaz


//gMetodaNC=="3"  // prva nabavka  se prva skida sa stanja
if gmetodanc=="3"
  hseek cidfirma+cidkonto+cidroba
  nSkiniKol:=nIzlKol+_Kolicina // skini sa stanja ukupnu izlaznu kolicinu+tekucu kolicinu
  nNabVr:=0  // stanje nabavne vrijednosti
  do while !eof() .and. cidfirma+cidkonto+cidroba==idFirma+mkonto+idroba .and. _datdok>=datdok

    if mu_i=="1" .or. mu_i=="5"
      if (mu_i=="1" .and. kolicina>0) .or. (mu_i=="5" .and. kolicina<0) // ulaz
           if nSkiniKol>abs(kolicina)
             nNabVr   +=abs(kolicina*nc)
             nSkinikol-=abs(kolicina)
           else
             nNabVr   +=abs(nSkiniKol*nc)
             nSkinikol:=0
             dDatNab:=datdok
             nKolZN:=nSkiniKol
//             dRoktr:=
             exit // uzeta je potrebna nabavka, izadji iz do while
           endif
      endif
    endif
    skip
  enddo //  ovo je drugi prolaz , metoda "3"

  if _kolicina<>0
    nNC:=(nNabVr-nIzlNV)/_kolicina   // nabavna cijena po metodi prve
  else
    nNC:=0
  endif
endif

//gMetodaNC=="1"  // zadnja nabavka se prva skida sa stanja
if gmetodanc=="1"
  seek cidfirma+cidkonto+cidroba+chr(254)
  nSkiniKol:=nIzlKol+_Kolicina // skini sa stanja ukupnu izlaznu kolicinu+tekucu kolicinu
  nNabVr:=0  // stanje nabavne vrijednosti
  skip -1
  do while !bof() .and. cidfirma+cidkonto+cidroba==idFirma+mkonto+idroba

    if _datdok<=datdok // preskaci novije datume
      skip -1; loop
    endif

    if mu_i=="1" .or. mu_i=="5"
      if (mu_i=="1" .and. kolicina>0) .or. (mu_i=="5" .and. kolicina<0) // ulaz
           if nSkiniKol>abs(kolicina)
             nNabVr   +=abs(kolicina*nc)
             nSkinikol-=abs(kolicina)
           else
             nNabVr   +=abs(nSkiniKol*nc)
             nSkinikol:=0
             dDatNab:=datdok
             nKolZN:=nSkiniKol
//             dRoktr:=
             exit // uzeta je potrebna nabavka, izadji iz do while
           endif
      endif
    endif
    skip -1
  enddo //  ovo je drugi prolaz , metoda "1"

  if _kolicina<>0
    nNC:=(nNabVr-nIzlNV)/_kolicina   // nabavna cijena po metodi zadnje
  else
    nNC:=0
  endif
endif

if round(nkolicina,5)==0
 nSNC:=0
else
 nSNC:=(nUlNV-nIzlNV)/nkolicina
endif

nKolicina:=round(nKolicina,4)
select pripr
return
*}


