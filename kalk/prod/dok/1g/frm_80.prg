#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/prod/dok/1g/frm_80.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.8 $
 * $Log: frm_80.prg,v $
 * Revision 1.8  2004/05/25 13:53:17  sasavranic
 * Mogucnost evidentiranja tipa sredstva (donirano i kupljeno)
 *
 * Revision 1.7  2003/10/11 09:26:52  sasavranic
 * Ispravljen bug pri unosu izlaznih kalkulacija, na stanju uvije 0 robe, varijanta barkod
 *
 * Revision 1.6  2003/10/07 11:48:31  sasavranic
 * Brisanje sifara za artikle koji nisu u prometu! Dorada
 *
 * Revision 1.5  2003/10/06 15:00:28  sasavranic
 * Unos podataka putem barkoda
 *
 * Revision 1.4  2003/09/29 13:26:55  mirsadsubasic
 * sredjivanje koda za poreze u ugostiteljstvu
 *
 * Revision 1.3  2002/07/08 23:03:54  ernad
 *
 *
 * trgomarket debug dok 80, 81, izvjestaj lager lista magacin po proizv. kriteriju
 *
 * Revision 1.2  2002/06/20 14:03:09  mirsad
 * dokumentovanje
 *
 *
 */
 


/*! \file fmk/kalk/prod/dok/1g/frm_80.prg
 *  \brief Maska za unos dokumenta tipa 80
 */


/*! \fn Get1_80()
 *  \brief Prva strana maske za unos dokumenta tipa 80
 */

// prijem prodavnica, predispozicija

function Get1_80()
*{
private aPorezi:={}
if nRbr==1 .and. fnovi
  _DatFaktP:=_datdok
endif

if nRbr==1  .or. !fnovi
 @  m_x+7,m_y+2   SAY "Dokument - Broj:" get _BrFaktP
 @  m_x+7,col()+2 SAY "Datum:" get _DatFaktP

 @ m_x+9,m_y+2   SAY "Konto koji zaduzuje" GET _IdKonto valid  P_Konto(@_IdKonto,24) pict "@!"
 if gNW<>"X"
   @ m_x+9,m_y+35  SAY "Zaduzuje: "   GET _IdZaduz  pict "@!" valid empty(_idZaduz) .or. P_Firma(@_IdZaduz,24)
 endif
 @ m_x+10,m_y+2   SAY "Prenos na konto    " GET _IdKonto2   valid empty(_idkonto2) .or. P_Konto(@_IdKonto2,24) pict "@!"
 if gNW<>"X"
   @ m_x+10,m_y+35  SAY "Zaduzuje: "   GET _IdZaduz2  pict "@!" valid empty(_idZaduz) .or. P_Firma(@_IdZaduz2,24)
 endif

 read
 ESC_RETURN K_ESC
 _DatKurs:=_DatFaktP
else
 @  m_x+7,m_y+2   SAY "Dokument - Broj: "; ?? _BrFaktP
 @  m_x+7,col()+2 SAY "Datum: "; ?? _DatFaktP
 @  m_x+9 ,m_y+2  SAY "Konto koji zaduzuje "; ?? _IdKonto
 @  m_x+10,m_y+2  SAY "Prenos na konto     "; ?? _IdKonto2
 if gNW<>"X"
   @  m_x+9,m_y+35  SAY "Zaduzuje: "; ?? _IdZaduz
   @  m_x+10,m_y+35 SAY "Zaduzuje: "; ?? _IdZaduz2
 endif
 read
 ESC_RETURN K_ESC
endif

@ m_x+11,m_y+66 SAY "Tarif.br->"

if lKoristitiBK
	@ m_x+11,m_y+2   SAY "Artikal  " GET _IdRoba pict "@!S10" when {|| _IdRoba:=PADR(_idroba,VAL(gDuzSifIni)),.t.} valid VRoba_lv(fNovi, @aPorezi)
else
	@ m_x+12,m_y+2  SAY "Artikal  " GET _IdRoba pict "@!"  valid  VRoba_lv(fNovi, @aPorezi)
endif
@ m_x+12,m_y+70 GET _IdTarifa when gPromTar=="N" valid P_Tarifa(@_IdTarifa)

VTPorezi()

IF lPoNarudzbi
  @ m_x+13,m_y+2 SAY "Po narudzbi br." GET _brojnar
  @ m_x+13,col()+2 SAY "za narucioca" GET _idnar pict "@!" valid empty(_idnar) .or. P_Firma(@_idnar,13,50)
ENDIF

// IF !lPoNarudzbi
  @ m_x+13+IF(lPoNarudzbi,1,0),m_y+2   SAY "Kolicina " GET _Kolicina PICTURE PicKol valid _Kolicina<>0
// ENDIF

IF IsDomZdr()
   @ m_x+13+IF(lPoNarudzbi,1,0),m_y+2   SAY "Tip sredstva (prazno-svi) " GET _Tip PICT "@!"
ENDIF

read
ESC_RETURN K_ESC

if lKoristitiBK
	_idRoba:=Left(_idRoba,10)
endif

select TARIFA
//hseek _IdTarifa  // postavi TARIFA na pravu poziciju

select koncij
seek trim(_idkonto)
select PRIPR  // napuni tarifu

_PKonto:=_Idkonto
DatPosljP()
DuplRoba()

private fMarza:=" "

if fNovi
 select koncij
 seek trim(_idkonto)
 select ROBA
 HSEEK _IdRoba

 _MPCSapp:=UzmiMPCSif()

 _TMarza2:="%"
 if Carina<>0
    _TCarDaz:="%"
    _CarDaz:=carina
  endif
endif

select PRIPR

@ m_x+14+IF(lPoNarudzbi,1,0),m_y+2     SAY "NABAVNA CJENA:"
@ m_x+14+IF(lPoNarudzbi,1,0),m_y+50    GET _NC     PICTURE PicDEM when VKol()

@ m_x+16+IF(lPoNarudzbi,1,0),m_y+2 SAY "Marza:" GET _TMarza2  VALID _Tmarza2 $ "%AU" PICTURE "@!"
@ m_x+16+IF(lPoNarudzbi,1,0),col()+2  GET _Marza2 PICTURE  PicDEM ;
    valid {|| _vpc:=_nc, .t.}
@ m_x+16+IF(lPoNarudzbi,1,0),col()+1 GET fMarza pict "@!"

@ m_x+17+IF(lPoNarudzbi,1,0),m_y+2  SAY "MALOPROD. CJENA (MPC):"
@ m_x+17+IF(lPoNarudzbi,1,0),m_y+50 GET _MPC picture PicDEM;
           WHEN WMpc_lv(nil, nil, aPorezi) VALID VMpc_lv(nil, nil, aPorezi)

SayPorezi_lv(19, aPorezi)

@ m_x+20+IF(lPoNarudzbi,1,0),m_y+2 SAY "MPC SA POREZOM:"
@ m_x+20+IF(lPoNarudzbi,1,0),m_y+50 GET _MPCSaPP  picture PicDEM ;
           valid VMpcSaPP_lv(nil, nil, aPorezi)

read
ESC_RETURN K_ESC

select koncij
seek trim(_idkonto)

StaviMPCSif(_mpcsapp,.t.)

select pripr

_PKonto:=_Idkonto; _PU_I:="1"
_MKonto:="";_MU_I:=""

nStrana:=3
return lastkey()
*}





/*! \fn Get1_80b()
 *  \brief Druga strana maske za unos dokumenta tipa 80 - protustavka
 */

// _odlval nalazi se u knjiz, filuje staru vrijenost
// _odlvalb nalazi se u knjiz, filuje staru vrijenost nabavke

function Get1_80b()
*{
local cSvedi:=" "
private aPorezi:={}

fnovi:=.t.
private PicDEM:="9999999.99999999",PicKol:="999999.999"
Beep(1)
@ m_x+2,m_Y+2 SAY "PROTUSTAVKA   (svedi na staru vrijednost - kucaj S):"
@ m_x+2,col()+2 GET cSvedi valid csvedi $ " S" pict "@!"
read

@ m_x+11,m_y+66 SAY "Tarif.br->"
@ m_x+12,m_y+2  SAY "Artikal  " GET _IdRoba pict "@!" ;
                  valid  VRoba_lv(fNovi, @aPorezi)
@ m_x+12,m_y+70 GET _IdTarifa when gPromTar=="N" valid P_Tarifa(@_IdTarifa)

read
ESC_RETURN K_ESC
select koncij
seek trim(_idkonto)
select PRIPR  // napuni tarifu

_PKonto:=_Idkonto
DatPosljP()
DuplRoba()

private fMarza:=" "

@ m_x+13,m_y+2   SAY "Kolicina " GET _Kolicina PICTURE PicKol valid _Kolicina<>0

select koncij
seek trim(_idkonto)
select ROBA
HSEEK _IdRoba
if _mpcsapp=0  // ako nije popunjeno
 _MPCSapp:=UzmiMPCSif()
endif

_TMarza2:="%"
if Carina<>0
    _TCarDaz:="%"
    _CarDaz:=carina
endif

select PRIPR

@ m_x+14,m_y+2     SAY "NABAVNA CJENA:"
@ m_x+14,m_y+50    GET _NC     PICTURE PicDEM when VKol()

@ m_x+16,m_y+2 SAY "Marza:" GET _TMarza2  VALID _Tmarza2 $ "%AU" PICTURE "@!"
@ m_x+16,col()+2  GET _Marza2 PICTURE  PicDEM valid {|| _vpc:=_nc, .t.}
@ m_x+16,col()+1 GET fMarza pict "@!"

@ m_x+17,m_y+2  SAY "MALOPROD. CJENA (MPC):"
@ m_x+17,m_y+50 GET _MPC picture PicDEM WHEN WMpc_lv(nil, nil, aPorezi) VALID VMpc_lv(nil, nil, aPorezi)
	       
SayPorezi_lv(19, aPorezi)

@ m_x+20,m_y+2 SAY "MPC SA POREZOM:"
@ m_x+20,m_y+50 GET _MPCSaPP  picture PicDEM ;
     valid {|| Svedi(cSvedi), VMpcSapp_lv(nil, nil, aPorezi) }

read
ESC_RETURN K_ESC

select koncij
seek trim(_idkonto)

StaviMPCSif(_mpcsapp,.t.)

select pripr

_PKonto:=_Idkonto
_PU_I:="1"
_MKonto:=""
_MU_I:=""

nStrana:=3
return lastkey()
*}




/*! \fn Svedi(cSvedi)
 *  \brief Svodi vrijednost protustavke na vrijednost stavke
 */

function Svedi(cSvedi)
*{
if csvedi=="S"
   if _mpcsapp<>0
    _kolicina:=-round(_oldval/_mpcsapp,4)
   else
    _kolicina:=99999999
   endif
   if _kolicina<>0
    _nc:=abs(_oldvaln/_kolicina)
   else
    _nc:=0
   endif
endif
return .t.
*}




/*! \fn VKol()
 *  \brief Validacija unesene kolicine u dokumentu tipa 80
 */

static function VKol()
*{
if _kolicina<0  // storno
//////// kalkulacija nabavne cijene
//////// nKolZN:=kolicina koja je na stanju a porijeklo je od zadnje nabavke
nKolS:=0;nKolZN:=0;nc1:=nc2:=0; dDatNab:=ctod("")
 if !empty(gMetodaNC)
  MsgO("Racunam stanje u prodavnici")
  KalkNabP(_idfirma,_idroba,_idkonto,@nKolS,@nKolZN,@nc1,@nc2,@dDatNab,@_RokTr)
  MsgC()
  @ m_x+12,m_y+30   SAY "Ukupno na stanju "; @ m_x+12,col()+2 SAY nkols pict pickol
 endif
 if dDatNab>_DatDok; Beep(1);Msg("Datum nabavke je "+dtoc(dDatNab),4);endif
 if _nc==0; _nc:=nc2; endif
 //if gMetodaNC $ "13"; _nc:=nc1; elseif gMetodaNC=="2"; _nc:=nc2; endif
 if nkols < abs(_kolicina)
   _ERROR:="1"
   Beep(2)
   Msg("Na stanju je samo kolicina:"+str(nkols,12,3))
 endif
select PRIPR
endif
return .t.
*}

