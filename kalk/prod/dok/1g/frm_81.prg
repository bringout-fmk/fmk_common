#include "\cl\sigma\fmk\kalk\kalk.ch"

*array
static aPorezi:={}
*;


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/prod/dok/1g/frm_81.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.6 $
 * $Log: frm_81.prg,v $
 * Revision 1.6  2004/05/25 13:53:17  sasavranic
 * Mogucnost evidentiranja tipa sredstva (donirano i kupljeno)
 *
 * Revision 1.5  2003/10/11 09:26:52  sasavranic
 * Ispravljen bug pri unosu izlaznih kalkulacija, na stanju uvije 0 robe, varijanta barkod
 *
 * Revision 1.4  2003/10/06 15:00:28  sasavranic
 * Unos podataka putem barkoda
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
 

/*! \file fmk/kalk/prod/dok/1g/frm_81.prg
 *  \brief Maska za unos dokumenata tipa 81
 */


/*! \fn Get1_81()
 *  \brief Prva strana maske za unos dokumenta tipa 81
 */

// direktni ulaz u prodavnicu
function Get1_81()
*{

if nRbr==1 .and. fnovi
  _DatFaktP:=_datdok
endif

if nRbr==1  .or. !fnovi
 @  m_x+6,m_y+2   SAY "DOBAVLJAC:" get _IdPartner pict "@!" valid empty(_IdPartner) .or. P_Firma(@_IdPartner,6,30)
 @  m_x+7,m_y+2   SAY "Faktura dobavljaca - Broj:" get _BrFaktP
 @  m_x+7,col()+2 SAY "Datum:" get _DatFaktP

 @ m_x+10,m_y+2   SAY "Konto koji zaduzuje" GET _IdKonto valid  P_Konto(@_IdKonto,24) pict "@!"
 if gNW<>"X"
   @ m_x+10,m_y+35  SAY "Zaduzuje: "   GET _IdZaduz  pict "@!" valid empty(_idZaduz) .or. P_Firma(@_IdZaduz,24)
 endif
 read; ESC_RETURN K_ESC
 _DatKurs:=_DatFaktP
else
 @  m_x+6,m_y+2   SAY "DOBAVLJAC: "; ?? _IdPartner
 @  m_x+7,m_y+2   SAY "Faktura dobavljaca - Broj: "; ?? _BrFaktP
 @  m_x+7,col()+2 SAY "Datum: "; ?? _DatFaktP
 @  m_x+10,m_y+2  SAY "Konto koji zaduzuje "; ?? _IdKonto
 if gNW<>"X"
   @  m_x+10,m_y+35 SAY "Zaduzuje: "; ?? _IdZaduz
 endif
 read; ESC_RETURN K_ESC
endif

@ m_x+11,m_y+66 SAY "Tarif.br->"
if lKoristitiBK
	@ m_x+11,m_y+2   SAY "Artikal  " GET _IdRoba pict "@!S10" when {|| _IdRoba:=PADR(_idroba,VAL(gDuzSifIni)),.t.} valid VRoba_lv(fNovi, @aPorezi)
else
	@ m_x+12,m_y+2  SAY "Artikal  " GET _IdRoba pict "@!"  valid  VRoba_lv(fNovi, @aPorezi)

endif

@ m_x+12,m_y+70 GET _IdTarifa when gPromTar=="N" valid P_Tarifa(@_IdTarifa)

IF lPoNarudzbi
  @ m_x+13,m_y+2 SAY "Po narudzbi br." GET _brojnar
  @ m_x+13,col()+2 SAY "za narucioca" GET _idnar pict "@!" valid empty(_idnar) .or. P_Firma(@_idnar,13,50)
ENDIF

read
ESC_RETURN K_ESC

if lKoristitiBK
	_idRoba:=Left(_idRoba,10)
endif

//select TARIFA
//hseek _IdTarifa  // postavi TARIFA na pravu poziciju

select koncij; seek trim(_idkonto)
select PRIPR  // napuni tarifu

_PKonto:=_Idkonto
DatPosljP()

// IF !lPoNarudzbi
  @ m_x+13+IF(lPoNarudzbi,1,0),m_y+2   SAY "Kolicina " GET _Kolicina PICTURE PicKol valid _Kolicina<>0
// ENDIF

 IF IsDomZdr()
   @ m_x+14+IF(lPoNarudzbi,1,0),m_y+2   SAY "Tip sredstva (prazno-svi) " GET _Tip PICT "@!"
 ENDIF


if fNovi
 select koncij; seek trim(_idkonto)
 select ROBA; HSEEK _IdRoba
 _MPCSapp:=UzmiMPCSif()
 _TMarza2:="%"
 if Carina<>0
    _TCarDaz:="%"
    _CarDaz:=carina
  endif
endif


select PRIPR

@ m_x+15+IF(lPoNarudzbi,1,0),m_y+2   SAY "F.CJ.(DEM/JM):"
@ m_x+15+IF(lPoNarudzbi,1,0),m_y+50  GET _FCJ PICTURE PicDEM    valid _fcj>0  when VKol()

@ m_x+17+IF(lPoNarudzbi,1,0),m_y+2   SAY "KASA-SKONTO(%):"
@ m_x+17+IF(lPoNarudzbi,1,0),m_y+40 GET _Rabat PICTURE PicDEM when DuplRoba()

if gNW<>"X"
 @ m_x+18+IF(lPoNarudzbi,1,0),m_y+2   SAY "Transport. kalo:"
 @ m_x+18+IF(lPoNarudzbi,1,0),m_y+40  GET _GKolicina PICTURE PicKol

 @ m_x+19+IF(lPoNarudzbi,1,0),m_y+2   SAY "Ostalo kalo:    "
 @ m_x+19+IF(lPoNarudzbi,1,0),m_y+40  GET _GKolicin2 PICTURE PicKol
endif

read; ESC_RETURN K_ESC
_FCJ2:=_FCJ*(1-_Rabat/100)

return lastkey()
*}




/*! \fn VKol()
 *  \brief Validacija kolicine pri unosu dokumenta tipa 81
 */

static function VKol()
*{
if _kolicina<0  // storno
//////// kalkulacija nabavne cijene
//////// nKolZN:=kolicina koja je na stanju a porijeklo je od zadnje nabavke
nKolS:=0;nKolZN:=0;nc1:=nc2:=0; dDatNab:=ctod("")
 if !empty(gMetodaNC)
  MsgO("Racunam stanje na u prodavnici")
  KalkNabP(_idfirma,_idroba,_idkonto,@nKolS,@nKolZN,@nc1,@nc2,@dDatNab,@_RokTr)
  MsgC()
  @ m_x+12,m_y+30   SAY "Ukupno na stanju "; @ m_x+12,col()+2 SAY nkols pict pickol
 endif
 if dDatNab>_DatDok; Beep(1);Msg("Datum nabavke je "+dtoc(dDatNab),4);endif
 //if _nc==0; _nc:=nc2; endif
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




/*! \fn Get2_81()
 *  \brief Druga strana maske za unos dokumenta tipa 81
 */

function Get2_81()
*{
local cSPom:=" (%,A,U,R) "
private getlist:={}

private fMarza:=" "

if empty(_TPrevoz); _TPrevoz:="%"; endif
if empty(_TCarDaz); _TCarDaz:="%"; endif
if empty(_TBankTr); _TBankTr:="%"; endif
if empty(_TSpedTr); _TSpedtr:="%"; endif
if empty(_TZavTr);  _TZavTr:="%" ; endif
if empty(_TMarza);  _TMarza:="%" ; endif

@ m_x+2,m_y+2     SAY c10T1+cSPom GET _TPrevoz VALID _TPrevoz $ "%AUR" PICTURE "@!"
@ m_x+2,m_y+40    GET _Prevoz PICTURE  PicDEM

@ m_x+3,m_y+2     SAY c10T2+cSPom  GET _TBankTr VALID _TBankTr $ "%AUR" pict "@!"
@ m_x+3,m_y+40    GET _BankTr PICTURE PicDEM

@ m_x+4,m_y+2     SAY c10T3+cSPom GET _TSpedTr valid _TSpedTr $ "%AUR" pict "@!"
@ m_x+4,m_y+40    GET _SpedTr PICTURE PicDEM

@ m_x+5,m_y+2     SAY c10T4+cSPom GET _TCarDaz VALID _TCarDaz $ "%AUR" PICTURE "@!"
@ m_x+5,m_y+40    GET _CarDaz PICTURE PicDEM

@ m_x+6,m_y+2     SAY c10T5+cSPom GET _TZavTr VALID _TZavTr $ "%AUR" PICTURE "@!"
@ m_x+6,m_y+40    GET _ZavTr PICTURE PicDEM ;
                    VALID {|| NabCj(),.t.}

@ m_x+8,m_y+2     SAY "NABAVNA CJENA:"
@ m_x+8,m_y+50    GET _NC     PICTURE PicDEM

@ m_x+10,m_y+2 SAY "Marza:" GET _TMarza2  VALID _Tmarza2 $ "%AU" PICTURE "@!"
@ m_x+10,col()+2  GET _Marza2 PICTURE  PicDEM ;
    valid {|| _vpc:=_nc, .t.}
@ m_x+10,col()+1 GET fMarza pict "@!"

@ m_x+12,m_y+2  SAY "MALOPROD. CJENA (MPC):"

  @ m_x+12,m_y+50 GET _MPC picture PicDEM;
          WHEN WMpc_lv(nil, nil, aPorezi) VALID VMpc_lv(nil, nil, aPorezi)
	 
@ m_x+14,m_y+2  SAY "PPP (%):"; @ row(),col()+2 SAY  TARIFA->OPP PICTURE "99.99"
@ m_x+14,col()+8  SAY "PPU (%):"; @ row(),col()+2  SAY TARIFA->PPP PICTURE "99.99"
@ m_x+14,col()+8  SAY "PP (%):"; @ row(),col()+2  SAY TARIFA->ZPP PICTURE "99.99"

@ m_x+16,m_y+2 SAY "MPC SA POREZOM:"

  @ m_x+16,m_y+50 GET _MPCSaPP  picture PicDEM ;
            VALID VMpcSaPP_lv(nil, nil, aPorezi)

read; ESC_RETURN K_ESC

select koncij; seek trim(_idkonto)

StaviMPCSif(_mpcsapp,.t.)

select pripr

_PKonto:=_Idkonto; _PU_I:="1"
_MKonto:="";_MU_I:=""
nStrana:=3
return lastkey()
*}

