#include "\cl\sigma\fmk\kalk\kalk.ch"



/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/db/1g/ut.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.14 $
 * $Log: ut.prg,v $
 * Revision 1.14  2003/11/11 15:38:21  sasavranic
 * 10 -> 11
 *
 * Revision 1.13  2003/11/11 14:06:34  sasavranic
 * Uvodjenje f-je IspisNaDan()
 *
 * Revision 1.12  2003/11/07 08:08:24  sasavranic
 * korekcije 10->11
 *
 * Revision 1.11  2003/11/06 15:44:50  sasavranic
 * formiranje 11-ke na osnovu 10-ke
 *
 * Revision 1.10  2003/08/27 08:11:14  mirsad
 * nova opcija u pripremi: F11/4.obracun poreza pri uvozu
 *
 * Revision 1.9  2002/12/30 16:36:38  mirsad
 * no message
 *
 * Revision 1.8  2002/12/30 01:28:55  mirsad
 * ispravke bugova-Planika
 *
 * Revision 1.7  2002/11/22 10:41:45  mirsad
 * sredjivanje makroa za oblasti - ukidanje starog sistema
 *
 * Revision 1.6  2002/07/18 08:14:51  mirsad
 * uvedeno korištenje IsJerry() za specificnosti za Jerry Trade
 *
 * Revision 1.5  2002/07/12 10:15:55  ernad
 *
 *
 * debug ROBPR.DBF, ROBPR.CDX - uklonjena funkcija DodajRobPr()
 *
 * Revision 1.4  2002/07/03 23:55:19  ernad
 *
 *
 * ciscenja planika (tragao za nepostojecim bug-om u prelgedu finansijskog obrta)
 *
 * Revision 1.3  2002/06/25 15:08:46  ernad
 *
 *
 * prikaz parovno - Planika
 *
 * Revision 1.2  2002/06/18 14:02:38  mirsad
 * dokumentovanje (priprema za doxy)
 *
 *
 */
 
/*! \file fmk/kalk/db/1g/ut.prg
 *  \brief KALK utilities
 */

function ODbKalk()
*{
if IzFMKIni("Svi","Sifk")=="D"
   O_SIFK
   O_SIFV
endif
O_TARIFA
O_ROBA
O_KONCIJ
O_KONTO
O_PARTN
O_DOKS
O_KALK
return
*}



/*! \fn KalkNaF(cidroba,nKols)
 *  \brief Stanje zadanog artikla u FAKT
 */

function KalkNaF(cidroba,nKols)
*{
select (F_FAKT)
if !used(); XO_FAKT; endif

select xfakt; set order to 3 // idroba
nKols:=0
seek cidroba
do while !eof() .and. cidroba==idroba
     if idtipdok="0"  // ulaz
        nKols+=kolicina
     elseif idtipdok="1"   // izlaz faktura
       if !(serbr="*" .and. idtipdok=="10") // za fakture na osnovu otpremince ne ra~unaj izlaz
          nKols-=kolicina
       endif
     endif
     skip
enddo
select pripr
return
*}


// ako nije razduzeno kako bi trebalo po metodi NC

/*! \fn MsgNCRazd()
 *  \brief
 *  \todo ukinuti?
 */

function MsgNCRazd()
*{
//ne moze raditi
//if round(nab-> kalk->kolicina) .and. round(nab->nc-kalk->nc,3)<>0;  Msg("U dokumentu "+kalk->(idfirma+"-"+idvd+"-"+brdok)+" nije dobra NC po metodi razduzenja !"); endif
return
*}


/*! \fn P_Kalk(cIdFirma,cIdVD,cBrDok)
 *  \brief Ispituje postojanje zadanog dokumenta medju azuriranim
 */

function P_Kalk(cIdFirma,cIdVD,cBrDok)
*{
local nRez:=.f.
local nArr:=SELECT()
//PushWa()
SELECT KALK
set filter to
set order to 1
seek cIdFirma+cIdVD+cBrDok
if found()
  Beep(1)
  Msg("Dokument vec postoji !")
  nRez:=.t.
else
endif
//PopWa()
SELECT (nArr)
return nRez
*}


/*! \fn VVT()
 *  \brief Prikaz PPP i proracun marze za visokotarifnu robu
 */

function VVT()
*{
@ m_x+13,m_y+2 SAY "PPP:"
@ m_x+13,col()+2 SAY tarifa->opp pict "99.99%"
if roba->tip="X"
 @ m_x+13,col()+2 SAY roba->mpc/(1+tarifa->opp/100)*tarifa->opp/100 pict picdem
 _marza:=roba->mpc/(1+tarifa->opp/100)-_nc
else
 @ m_x+13,col()+2 SAY _vpc/(1+tarifa->opp/100)*tarifa->opp/100 pict picdem
 _marza:=_vpc/(1+tarifa->opp/100)-_nc
endif
_tmarza:="A"
return .t.
*}




/*! \fn DuplRoba()
 *  \brief Obrada slucaja pojavljivanja duplog unosa robe u dokumentu
 */

function DuplRoba()
*{
local nRREC,fdupli:=.f.,dkolicina:=0,dfcj:=0
private GetList:={}
 // pojava robe vise puta unutar kalkulacije!!!
 if ( (roba->tip $ "UTY") .or. empty(gMetodaNC) .or. gmagacin=="1" .or. (IsJerry() .and. _idvd="4") )
 	return .t.
 endif
 select pripr; set order to 3
 nRRec:=recno()
 seek _idfirma+_idvd+_brdok+_idroba
 fdupli:=.f.
 dkolicina:=_kolicina
 dfcj:=_fcj
 do while !eof() .and. _idfirma+_idvd+_brdok+_idroba== idfirma+idvd+brdok+idroba
   if val(rbr)<>nRbr .and. (nRRec<>recno() .or. fnovi)
     Beep(2)
     // skocio je na donji zapis
     if Pitanje(,"Artikal "+_idroba+" se pojavio vise puta unutar - spojiti ?","N")=="D"
        fdupli:=.t.
        dfcj:=(dfcj*dkolicina+fcj*kolicina)/(dkolicina+kolicina)
        dkolicina+=kolicina
        delete
     else
        _ERROR:="1"
     endif
   endif
   skip
 enddo
 go nRRec
 if fdupli
   _kolicina:=dkolicina
   _fcj:=dfcj
 endif
 select pripr
 set order to 1
return .t.
*}



/*! \fn DatPosljK()
 *  \brief Ispituje da li je datum zadnje promjene na zadanom magacinu i za zadani artikal noviji od one koja se unosi
 */

function DatPosljK()
*{
select kalk
set order to 3
seek _idfirma+_mkonto+_idroba+"X"
skip -1
if _idfirma+_idkonto+_idroba==idfirma+mkonto+idroba .and. _datdok<datdok
   Beep(2)
   Msg("Zadnji dokument za ovaj artikal radjen je: "+dtoc(datdok))
   _ERROR:="1"
endif
select pripr
return
*}


/*! \fn DatPosljP()
 *  \brief Ispituje da li je datum zadnje promjene na zadanoj prodavnici i za zadani artikal noviji od one koja se unosi
 */

function DatPosljP()
*{
select kalk
set order to 4

if _idroba="T"
 go bottom
 if _datdok<datdok
   Msg("Zadji dokument je radjen: "+dtoc(datdok))
   _ERROR:="1"
 endif
else
 seek _idfirma+_idkonto+_idroba+"X"
 skip -1
 if _idfirma+_idkonto+_idroba==idfirma+pkonto+idroba .and. _datdok<datdok
   Beep(2)
   Msg("Zadnji dokument za ovaj artikal radjen je: "+dtoc(datdok))
   _ERROR:="1"
 endif
endif
select pripr
return
*}



/*! \fn SljBroj(cidfirma,cIdvD,nMjesta)
 *  \brief Sljedeci slobodan broj dokumenta za zadanu firmu i vrstu dokumenta
 */

function SljBroj(cidfirma,cIdvD,nMjesta)
*{
private cReturn:="0"
select kalk
seek cidfirma+cidvd+"ä"
skip -1
if idvd<>cidvd
     cReturn:=space(8)
else
     cReturn:=brdok
endif
return cReturn:=UBrojDok(val(left(cReturn,5))+1,5,right(cReturn))
*}





/*! \fn MMarza2()
 *  \brief Daje iznos maloprodajne marze
 */

function MMarza2()
*{
  if TMarza2=="%".or.EMPTY(tmarza2)
     nMarza2:=kolicina*Marza2/100*VPC
  elseif TMarza2=="A"
     nMarza2:=Marza2*kolicina
  elseif TMarza2=="U"
     nMarza2:=Marza2
  endif
return nMarza2
*}



/*! \fn KnjizSt()
 *  \brief Proracun knjiznog stanja za zadanu robu i prodavnicu 
 */

function KnjizSt()
*{
local nUlaz:=nIzlaz:=0
local nMPVU:=nMPVI:=nNVU:=nNVI:=0
local cIdRoba:=_Idroba
local cidfirma:=_idfirma
local cidkonto:=_idkonto
local nRabat:=0
select roba; hseek cidroba; select kalk
PushWa()
set order to 4
hseek cidfirma+cidkonto+cidroba
do while !eof() .and. cidfirma+cidkonto+cidroba==idFirma+pkonto+idroba

  if _Datdok<datdok  // preskoci
      skip; loop
  endif
  if roba->tip $ "UT"
      skip; loop
  endif

  if pu_i=="1"
    nUlaz+=kolicina-GKolicina-GKolicin2
    nMPVU+=mpcsapp*kolicina
    nNVU+=nc*kolicina

  elseif pu_i=="5"  .and. !(idvd $ "12#13#22")
    nIzlaz+=kolicina
    nMPVI+=mpcsapp*kolicina
    nNVI+=nc*kolicina


  elseif pu_i=="5"  .and. (idvd $ "12#13#22")    // povrat
    nUlaz-=kolicina
    nMPVU-=mpcsapp*kolicina
    nnvu-=nc*kolicina

  elseif pu_i=="3"    // nivelacija
    nMPVU+=mpcsapp*kolicina

  elseif pu_i=="I"
    nIzlaz+=gkolicin2
    nMPVI+=mpcsapp*gkolicin2
    nNVI+=nc*gkolicin2
  endif

  skip
enddo

_gkolicina:=nUlaz-nIzlaz
_fcj:=nmpvu-nmpvi // stanje mpvsapp
if round(nulaz-nizlaz,4)<>0
  _mpcsapp:=round((nMPVU-nMPVI)/(nulaz-nizlaz),3)
  _nc:=round((nnvu-nnvi)/(nulaz-nizlaz),3)
else
  _mpcsapp:=0
endif

PopWa()
select pripr
return
*}



/*! \fn RenumPripr(cDok,cidvd)
 *  \brief Prenumerisanje stavki zadanog dokumenta u pripremi
 */

function RenumPripr(cDok,cidvd)
*{
select pripr
set order to 0
go top

nRbr:=0
do while !eof()
  if Brdok==cDok .and. cidvd==idvd
   replace rbr with RedniBroj(++nrbr)

  endif
  skip
enddo

select pripr
set order to 1
go top
return
*}



/*! \fn IspitajPrekid()
 *  \brief Ispituje da li je pritisnuta tipka ESC. Koristi se u do while uslovu
 *  \return Ako je pritisnut ESC vraca .f., u suprotnom .t.
 */

function IspitajPrekid()
*{
 INKEY()
return IF(LASTKEY()==27,PrekSaEsc(),.t.)
*}


// ----------------------------------
// svedi na standardnu jedinicu mjere
// ( npr. KOM->LIT ili KOM->KG )
// ----------------------------------

/*! \fn SJMJ(nKol,cIdRoba,cJMJ)
 *  \brief Preracun zadane kolicine artikla na osnovnu/baznu jedinicu mjere
 */

function SJMJ(nKol,cIdRoba,cJMJ)
*{
 LOCAL nVrati:=0, nArr:=SELECT(), aNaz:={}, cKar:="SJMJ", nKO:=1, n_Pos:=0
  SELECT SIFV; SET ORDER TO TAG "ID"
  HSEEK "ROBA    "+cKar+PADR(cIdRoba,15)
  DO WHILE !EOF().and.id+oznaka+idsif=="ROBA    "+cKar+PADR(cIdRoba,15)
    IF !EMPTY(naz)
      AADD( aNaz , naz )
    ENDIF
    SKIP 1
  ENDDO
  IF LEN(aNaz)>0
    // slijedi preracunavanje
    // ----------------------
    n_Pos := AT( "_" , aNaz[1] )
    cPom   := ALLTRIM( SUBSTR( aNaz[1] , n_Pos+1 ) )
    nKO    := &cPom
    nVrati := nKol*nKO
    cJMJ   := ALLTRIM( LEFT( aNaz[1] , n_Pos-1 ) )
  ELSE
    // valjda je ve† u osnovnoj JMJ
    // ----------------------------
    nVrati:=nKol
  ENDIF
  SELECT (nArr)
return nVrati
*}



/*! \fn KaKaProd(nUlaz,nIzlaz,nMPV,nNV)
 *  \brief Kalkulacija stanja za karticu artikla u prodavnici
 */

function KaKaProd(nUlaz,nIzlaz,nMPV,nNV)
*{
  if pu_i=="1"
    nUlaz+=kolicina-GKolicina-GKolicin2
    nMPV+=mpcsapp*kolicina
    nNV+=nc*kolicina
  elseif pu_i=="5"  .and. !(idvd $ "12#13#22")
    nIzlaz+=kolicina
    nMPV-=mpcsapp*kolicina
    nNV-=nc*kolicina
  elseif pu_i=="I"
    nIzlaz+=gkolicin2
    nMPV-=mpcsapp*gkolicin2
    nNV-=nc*gkolicin2
  elseif pu_i=="5"  .and. (idvd $ "12#13#22")    // povrat
    nUlaz-=kolicina
    nMPV-=mpcsapp*kolicina
    nNV-=nc*kolicina
  elseif pu_i=="3"    // nivelacija
    nMPV+=mpcsapp*kolicina
  endif
return
*}



/*! \fn NCuMP(_idfirma,_idroba,_idkonto,nKolicina,dDatDok)
 *  \brief Proracun stanja i nabavne vrijednosti za zadani artikal i prodavnicu
 */

function NCuMP(_idfirma,_idroba,_idkonto,nKolicina,dDatDok)
*{
 LOCAL nArr:=SELECT()
  nKolS:=0
  nKolZN:=0
  nc1:=nc2:=0
  dDatNab:=ctod("")
  _kolicina := nKolicina
  _datdok   := dDatDok
  SELECT KALK
  PushWA()
  MsgO("Racunam stanje u prodavnici")
  	KalkNabP(_idfirma,PADR(_idroba,LEN(idroba)),_idkonto,@nKolS,@nKolZN,@nc1,@nc2,@dDatNab)
  MsgC()
  SELECT KALK
  PopWA()
  SELECT (nArr)
return nc2
*}



/*! \fn KalkTrUvoz()
 *  \brief Proracun carine i ostalih troskova koji se javljaju pri uvozu
 *  \todo samo otvorena f-ja
 */

function KalkTrUvoz()
*{
 LOCAL nT1:=0 , nT2:=0 , nT3:=0 , nT4:=0 , nT5:=0, CP:="999999999.999999999"
  Box("#Unos troskova",7,75)
    @ m_x+2, m_y+2 SAY c10T1 GET nT1 PICT CP
    @ m_x+3, m_y+2 SAY c10T2 GET nT2 PICT CP
    @ m_x+4, m_y+2 SAY c10T3 GET nT3 PICT CP
    @ m_x+5, m_y+2 SAY c10T4 GET nT4 PICT CP
    @ m_x+6, m_y+2 SAY c10T5 GET nT5 PICT CP
    READ
  BoxC()
  MsgBeep("Opcija jos nije u funkciji jer je dorada u toku!")
CLOSERET
*}


/*! \fn ObracunPorezaUvoz()
 *  \brief Proracun poreza pri uvozu
 */

function ObracunPorezaUvoz()
*{
local nTP, qqT1, qqT2, aUT1, aUT2

O_PRIPR

if !(pripr->idvd $ "10#81")
	MsgBeep("Ova opcija vrijedi samo za dokumente tipa 10 i 81 !")
	CLOSERET
endif

nTP:=5
qqT1:=PADR(IzFmkIni("RasporedTroskova","UslovPoTarifamaT1","",KUMPATH),40)
qqT2:=PADR(IzFmkIni("RasporedTroskova","UslovPoTarifamaT2","",KUMPATH),40)

Box("#Obracun poreza pri uvozu",7,75)
do while .t.
	@ m_x+2, m_y+2 SAY "Porez je u trosku br.(1-5)" GET nTP PICT "9" VALID nTP>0 .and. nTP<6
	@ m_x+3, m_y+2 SAY "Uslov za sifre tarifa grupe 1 (20%)" GET qqT1 PICT "@!S30"
	@ m_x+4, m_y+2 SAY "Uslov za sifre tarifa grupe 2 (10%)" GET qqT2 PICT "@!S30"
	read
	aUT1:=Parsiraj(qqT1,"idTarifa")
	aUT2:=Parsiraj(qqT2,"idTarifa")
	if aUT1<>nil .and. aUT2<>nil
		exit
	endif
enddo
BoxC()

if lastkey()<>K_ESC
	// proracun poreza
	select pripr
	go top
	do while !eof()
		Scatter()
		private cPom:=ImePoljaTroska(nTP)
		
		if gKalo=="1"
			skol:=_kolicina-_gkolicina-_gkolicin2
		else
			skol:=_kolicina
		endif
		
		if &aUT1
			_t&cPom:="U"
			_&cPom:=skol*_nc*0.2
		elseif &aUT2
			_t&cPom:="U"
			_&cPom:=skol*_nc*0.1
		endif
		
		NabCj()
		
		Gather()
		skip 1
	enddo
endif

CLOSERET
return
*}


function ImePoljaTroska(n)
*{
local aTros
aTros:={"Prevoz","BankTr","SpedTr","CarDaz","ZavTr"}
return aTros[n]
*}


/*! \fn KTroskovi()
 *  \brief Proracun iznosa troskova pri unosu u pripremi
 */

function KTroskovi()
*{
local Skol:=0,nPPP:=0

if gKalo=="1"
  Skol:=Kolicina-GKolicina-GKolicin2
else
  Skol:=Kolicina
endif
if roba->tip $ "VKX"
  nPPP:=1/(1+tarifa->opp/100)
  //if roba->tip="X"; nPPP:=nPPP*roba->mpc/vpc; endif
else
  nPPP:=1
endif

if TPrevoz=="%"
  nPrevoz:=Prevoz/100*FCj2
elseif TPrevoz=="A"
  nPrevoz:=Prevoz
elseif TPrevoz=="U"
  if skol<>0
   nPrevoz:=Prevoz/SKol
  else
   nPrevoz:=0
  endif
else
  nPrevoz:=0
endif
if TCarDaz=="%"
  nCarDaz:=CarDaz/100*FCj2
elseif TCarDaz=="A"
  nCarDaz:=CarDaz
elseif TCarDaz=="U"
  if skol<>0
   nCarDaz:=CarDaz/SKol
  else
   nCarDaz:=0
  endif
else
  nCarDaz:=0
endif
if TZavTr=="%"
  nZavTr:=ZavTr/100*FCj2
elseif TZavTr=="A"
  nZavTr:=ZavTr
elseif TZavTr=="U"
  if skol<>0
   nZavTr:=ZavTr/SKol
  else
   nZavTr:=0
  endif
else
  nZavTr:=0
endif
if TBankTr=="%"
  nBankTr:=BankTr/100*FCj2
elseif TBankTr=="A"
  nBankTr:=BankTr
elseif TBankTr=="U"
  if skol<>0
   nBankTr:=BankTr/SKol
  else
   nBankTr:=0
  endif
else
  nBankTr:=0
endif
if TSpedTr=="%"
  nSpedTr:=SpedTr/100*FCj2
elseif TSpedTr=="A"
  nSpedTr:=SpedTr
elseif TSpedTr=="U"
  if skol<>0
   nSpedTr:=SpedTr/SKol
  else
   nSpedTr:=0
  endif
else
  nSpedTr:=0
endif

if IdVD $ "14#94#15"   // izlaz po vp
  if roba->tip=="V"
    nMarza:=VPC*nPPP-VPC*Rabatv/100-NC
  elseif roba->tip=="X"
    nMarza:=VPC*(1-Rabatv/100)-NC- mpcsapp*nPPP*tarifa->opp/100
  else
    nMarza:=VPC*nPPP*(1-Rabatv/100)-NC
  endif
elseif idvd=="24"  // usluge
  nMarza:=marza
elseif idvd $ "11#12#13"
  nMarza:=VPC*nPPP-FCJ
else
 if roba->tip=="X"
   nMarza:=VPC-NC-mpcsapp*nPPP*tarifa->opp/100
 else
   nMarza:=VPC*nPPP-NC
 endif
endif

if (idvd $ "11#12#13")
	if (roba->tip=="K")
		nMarza2:=MPC-VPC*nPPP-nPrevoz
	elseif (roba->tip=="X")
		msgbeep("nije odradjeno")
	else
		nMarza2:=MPC-VPC-nPrevoz
	endif
elseif ( (idvd $ "41#42#43#81") .or. (IsJerry() .and. idvd="4") )
	if (roba->tip=="V")
		nMarza2:=(MPC-roba->VPC)+roba->vpc*nPPP-NC
	elseif (roba->tip=="X")
		msgbeep("nije odradjeno")
	else
		nMarza2:=MPC-NC
	endif
else
	nMarza2:=MPC-VPC
endif
return
*}




/*! \fn Preduzece()
 *  \brief Ispis naziva preduzeca/firme
 */

function Preduzece()
*{
P_INI
P_10CPI
P_B_ON
?? space(8), replicate("-",31)
? space(8),gTS+": "+gNFirma
? space(8), replicate("-",31)
B_OFF
?
?
return
*}



/*! \fn ImaUKumul(cKljuc,cTag)
 *  \brief Ispituje postojanje zadanog kljuca u zadanom indeksu kumulativa KALK
 */

function ImaUKumul(cKljuc,cTag)
*{
 local lVrati:=.f.
 local lUsed:=.t.
 local nArr:=SELECT()
  SELECT (F_KALK)
  IF !USED()
    lUsed:=.f.
    O_KALK
  ELSE
    PushWA()
  ENDIF
  IF !EMPTY(INDEXKEY(VAL(cTag)+1))
    SET ORDER TO TAG (cTag)
    seek cKljuc
    lVrati:=found()
  ENDIF
  IF !lUsed
    USE
  ELSE
    PopWA()
  ENDIF
  select (nArr)
return lVrati
*}



/* \fn UkupnoKolP(nTotalUlaz, nTotalIzlaz)
 * \brief Obracun kolicine za prodavnicu 
 * \note funkciju staviti unutar petlje koja prolazi kroz kalk
 * \code
 *    nUlazKP:=0
 *    nIzlazKP:=0
 *    do while .t. 
 *      SELECT KALK
 *      UkupnoKolP(@nUlazKP,@nIzlazKP)
 *      SKIP
 *    enddo
 *    ? nUlazKP, nIzlazKP
 * \endcode
 */
 
function UkupnoKolP(nTotalUlaz, nTotalIzlaz)
*{
local cIdRoba
local lUsedRoba

cIdRoba:=field->idRoba

nSelect:=SELECT()

lUsedRoba:=.t.
SELECT(F_ROBA)
if !USED()
	lUsedRoba:=.f.
	O_ROBA
else
	SELECT(F_ROBA)
endif
SEEK cIdRoba

SELECT (nSelect)

if field->pu_i=="1"
	SumirajKolicinu(kolicina, 0, @nTotalUlaz,0)
elseif field->pu_i=="5"
    	if field->idvd $ "12#13"
     		SumirajKolicinu(-kolicina, 0, @nTotalUlaz,0)
    	else
     		SumirajKolicinu(0, kolicina, 0, @nTotalIzlaz)
    	endif
elseif field->pu_i=="3"    
	// nivelacija
elseif field->pu_i=="I"
    	SumirajKolicinu(0, gkolicin2, 0, @nTotalIzlaz)
endif


return
*}

/*! \fn UkupnoKolM(nTotalUlaz, nTotalIzlaz)
 *  \sa UkupnoKolP
 */
 
function UkupnoKolM(nTotalUlaz, nTotalIzlaz)
*{
local cIdRoba
local lUsedRoba

cIdRoba:=field->idRoba

nSelect:=SELECT()

lUsedRoba:=.t.
SELECT(F_ROBA)
if !USED()
	lUsedRoba:=.f.
	O_ROBA
else
	SELECT(F_ROBA)
endif
SEEK cIdRoba

SELECT (nSelect)
if field->mu_i=="1"
	if !(field->idVd $ "12#22#94")
		SumirajKolicinu(field->kolicina-field->gKolicina-field->gKolicin2, 0, @nTotalUlaz, 0)

	else
		SumirajKolicinu(0, -field->kolicina, 0, @nTotalIzlaz)
	endif
     
elseif field->mu_i=="5"
	SumirajKolicinu(0, field->kolicina, 0, @nTotalIzlaz)
	
elseif field->mu_i=="3"    

elseif field->mu_i=="8"
	// sta je mu_i==8 ??
	SumirajKolicinu(-field->kolicina, -field->kolicina, @nTotUlaz, @nTotalIzlaz)
endif

return
*}


function RptSeekRT()
*{
local nArea

nArea:=SELECT()
select ROBA
HSEEK (nArea)->IdRoba
SELECT tarifa
HSEEK (nArea)->IdTarifa
SELECT (nArea)

return
*}


/*! \fn UzmiIzP(cSta)
 *  \brief Uzmi iz parametara
 *  \param cSta - "KOL", "NV", "MPV", MPVBP"...
 */
function UzmiIzP(cSta)  
*{
LOCAL nVrati:=0, nArr:=0
  IF cSta=="KOL"
    if pu_i=="1"
      nVrati := kolicina-GKolicina-GKolicin2
    elseif pu_i=="5"  .and. !(idvd $ "12#13#22")
      nVrati := -kolicina
    elseif pu_i=="I"
      nVrati := -gkolicin2
    elseif pu_i=="5"  .and. (idvd $ "12#13#22")    // povrat
      nVrati := -kolicina
    elseif pu_i=="3"    // nivelacija
    endif
  ELSEIF cSta=="NV"
    if pu_i=="1"
      nVrati := +nc*kolicina
    elseif pu_i=="5"  .and. !(idvd $ "12#13#22")
      nVrati := -nc*kolicina
    elseif pu_i=="I"
      nVrati := -nc*gkolicin2
    elseif pu_i=="5"  .and. (idvd $ "12#13#22")    // povrat
      nVrati := -nc*kolicina
    elseif pu_i=="3"    // nivelacija
    endif
  ELSEIF cSta=="MPV"
    if pu_i=="1"
      nVrati := +mpcsapp*kolicina
    elseif pu_i=="5"  .and. !(idvd $ "12#13#22")
      nVrati := -mpcsapp*kolicina
    elseif pu_i=="I"
      nVrati := -mpcsapp*gkolicin2
    elseif pu_i=="5"  .and. (idvd $ "12#13#22")    // povrat
      nVrati := -mpcsapp*kolicina
    elseif pu_i=="3"    // nivelacija
      nVrati := +mpcsapp*kolicina
    endif
  ELSEIF cSta=="MPVBP"
    if pu_i=="1"
      nVrati := +mpc*kolicina
    elseif pu_i=="5"  .and. !(idvd $ "12#13#22")
      nVrati := -mpc*kolicina
    elseif pu_i=="I"
      nArr:=SELECT()
      SELECT TARIFA; HSEEK (nArr)->IDTARIFA; VTPorezi()
      SELECT (nArr)
      nVrati := -mpcsapp/((1+_OPP)*(1+_PPP))*gkolicin2
    elseif pu_i=="5"  .and. (idvd $ "12#13#22")    // povrat
      nVrati := -mpc*kolicina
    elseif pu_i=="3"    // nivelacija
      nVrati := +mpc*kolicina
    endif
  ENDIF
RETURN nVrati
*}


function Generisi11ku_iz10ke(cBrDok)
*{
local nArr
nArr:=SELECT()
O_TARIFA
O_KONCIJ
O_ROBA
O_PRIPR9
cOtpremnica:=SPACE(10)
cIdKonto:="1320   "
nBrojac:=0
Box(,2,50)
	@ 1+m_x, 2+m_y SAY "Prod.konto zaduzuje: " GET cIdKonto VALID !Empty(cIdKonto)
	@ 2+m_x, 2+m_y SAY "Po otpremnici: " GET cOtpremnica
	read
BoxC()

select pripr
go top
do while !EOF()
	aPorezi:={}
	fMarza:=" "
	++nBrojac
	cKonto:=pripr->idKonto
	cRoba:=pripr->idRoba
	cTarifa:=pripr->idtarifa
	select roba
	seek cRoba
	select tarifa
	seek cTarifa
	SetAPorezi(@aPorezi)
	VTPorezi()
	select pripr
	Scatter()
	select pripr9
	append blank
	_idvd:="11"
	_brDok:=cBrDok
	_idKonto:=cIdKonto
	_idKonto2:=cKonto
	_brFaktP:=cOtpremnica
	_tPrevoz:="R"
	_tMarza:="A"
	_marza:=_vpc/(1+_PORVT)-_fcj
	_tMarza2:="A"
	_mpcsapp:=UzmiMpcSif()
	VMPC(.f., fMarza)
	VMPCSaPP(.f.,fMarza)
	_MU_I:="5"
	_PU_I:="1"
	_mKonto:=cKonto
	_pKonto:=cIdKonto
	Gather()
	select pripr
	skip

enddo

select (nArr)

MsgBeep("Formirao dokument " + ALLTRIM(gFirma) + "-11-" + ALLTRIM(cBrDok))
return
*}


function Get11FromSmece(cBrDok)
*{
local nArr
nArr:=SELECT()

O_PRIPR9
select pripr9
go top
do while !EOF()
	if (field->idvd=="11" .and. field->brdok==cBrDok)
		Scatter()
		select pripr
		append blank
		Gather()
		select pripr9
		delete
		skip
	else
		skip
	endif
enddo

select (nArr)
MsgBeep("Asistentom obraditi dokument !")
return
*}


function Generisati11_ku()
*{
// daj mi vrstu dokumenta pripreme
nTRecNo:=RECNO()
go top
cIdVD:=pripr->idvd
go (nTRecNo)
// ako se ne radi o 10-ci nista
if (cIdVD <> "10")
	return .f.
endif
if IzFmkIni("KALK","AutoGen11","N",KUMPATH)=="D" .and. Pitanje(,"Formirati 11-ku (D/N)?","D")=="D"
	return .t.
else
	return .f.
endif
return
*}

