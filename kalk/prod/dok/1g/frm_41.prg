#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/prod/dok/1g/frm_41.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.8 $
 * $Log: frm_41.prg,v $
 * Revision 1.8  2003/10/11 09:26:52  sasavranic
 * Ispravljen bug pri unosu izlaznih kalkulacija, na stanju uvije 0 robe, varijanta barkod
 *
 * Revision 1.7  2003/10/06 15:00:28  sasavranic
 * Unos podataka putem barkoda
 *
 * Revision 1.6  2003/09/20 07:37:07  mirsad
 * sredj.koda za poreze u MP
 *
 * Revision 1.5  2003/07/24 14:25:44  mirsad
 * omogucio unos procenta popusta na KALK 41 i 42
 *
 * Revision 1.4  2003/07/18 07:24:54  mirsad
 * stavio u f-ju kontrolu stanja za varijantu po narudzbama za izlazne dokumente (14,41,42)
 *
 * Revision 1.3  2002/07/18 14:05:45  mirsad
 * izolovanje specifiènosti pomoæu IsJerry()
 *
 * Revision 1.2  2002/06/20 14:03:09  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/prod/dok/1g/frm_41.prg
 *  \brief Maska za unos dokumenata tipa 41,42,43,47,49
 */


/*! \fn Get1_41()
 *  \brief Prva strana maske za unos dokumenata tipa 41,42,43,47,49
 */

//realizacija prodavnice  41-fakture maloprodaje
//                        42-kesh
//                        43-izlaz iz prodavnice-komisiona
//                        49-izlaz po ostalim osnovama
//                        47-pregled prodaje - ne interesuje me stanja
//                           na lageru, nabavna cijena
//                           izuzev u varijanti "Jerry"

function Get1_41()
*{
pIzgSt:=.f.   // izgenerisane stavke jos ne postoje
private aPorezi:={}
lVoSaTa := ( gVodiSamoTarife =="D" )

IF fNovi
  _DatFaktP:=_datdok
ENDIF
altd()
if _idvd=="41"

 if !lVoSaTa
   @  m_x+6,  m_y+2 SAY "KUPAC:" get _IdPartner pict "@!" valid empty(_IdPartner) .or. P_Firma(@_IdPartner,5,30)
   @  m_x+7,  m_y+2 SAY "Faktura Broj:" get _BrFaktP
 endif

 @  m_x+7,col()+2 SAY "Datum:" get _DatFaktP
elseif _idvd=="43"
 @  m_x+6,  m_y+2 SAY "DOBAVLJAC KOMIS.ROBE:" get _IdPartner pict "@!" valid empty(_IdPartner) .or. P_Firma(@_IdPartner,5,30)
elseif lVoSaTa .and. _idvd=="42"
 @  m_x+7,  m_y+2 SAY "Faktura Broj:" get _BrFaktP
 @  m_x+7,col()+2 SAY "Datum:" get _DatFaktP
else
 _idpartner:=""
 _brfaktP:=""
endif

_DatKurs:=_DatFaktP
@ m_x+8,m_y+2   SAY "Prodavnicki Konto razduzuje" GET _IdKonto valid  P_Konto(@_IdKonto,24) pict "@!"
if gNW<>"X"
 @ m_x+8,m_y+50  SAY "Razduzuje: "   GET _IdZaduz  pict "@!" valid empty(_idZaduz) .or. P_Firma(@_IdZaduz,24)
endif
_idkonto2:=""
_idzaduz2:=""
read
ESC_RETURN K_ESC
//@ m_x+10,m_y+2   SAY "R.br" GET nRBr PICT '999' valid {|| CentrTxt("",24),.t.}
@ m_x+10,m_y+66 SAY "Tarif.br->"
if lKoristitiBK
	@ m_x+11,m_y+2   SAY "Artikal  " GET _IdRoba pict "@!S10" when {|| _IdRoba:=PADR(_idroba,VAL(gDuzSifIni)),.t.} valid VRoba()
else
	@ m_x+11,m_y+2   SAY "Artikal  " GET _IdRoba pict "@!" valid VRoba()
endif

@ m_x+11,m_y+70 GET _IdTarifa when gPromTar=="N".and.!lVoSaTa valid P_Tarifa(@_IdTarifa)

if lVoSaTa
 if fnovi
    _kolicina:=1
 endif
else
 IF !lPoNarudzbi
   @ m_x+12,m_y+2   SAY "Kolicina " GET _Kolicina PICTURE PicKol valid _Kolicina<>0
 ENDIF
endif

read
ESC_RETURN K_ESC

if lKoristitiBK
	_idRoba:=Left(_idRoba,10)
endif

if lVoSaTa
  _Fcj:=0
  _nc:=0
  _Tmarza2:="A"
  _Marza2:=0
endif

select TARIFA; hseek _IdTarifa  // postavi TARIFA na pravu poziciju
select koncij; seek trim(_idkonto)
select PRIPR  // napuni tarifu

_PKonto:=_Idkonto

// provjerava kada je radjen zadnji dokument za ovaj artikal
DatPosljK()
DatPosljP()

_GKolicina:=0
_GKolicin2:=0

if fNovi
 if !lVoSaTa
  select koncij; seek trim(_idkonto)
  select ROBA; HSEEK _IdRoba
  _MPCSaPP:=UzmiMPCSif()

  if gMagacin=="2"
   _FCJ:=NC
   _VPC:=0
  else
   _FCJ:=NC
   _VPC:=0
  endif
 endif

 select PRIPR
 _Marza2:=0; _TMarza2:="A"
endif

if ((_idvd<>'47'.or.(IsJerry().and._idvd="4")) .and. !fnovi .and. gcijene=="2" .and. roba->tip!="T" .and. _mpcsapp=0)
   // uzmi mpc sa kartice
   FaktMPC(@_MPCSAPP,_idfirma+_idkonto+_idroba)
endif


if roba->(fieldpos("PLC"))<>0  // stavi plansku cijenu
 _vpc:=roba->plc
endif
VTPorezi()

if ((_idvd<>'47'.or.(IsJerry().and._idvd="4")) .and. roba->tip!="T")
//////// kalkulacija nabavne cijene
//////// nKolZN:=kolicina koja je na stanju a porijeklo je od zadnje nabavke
nKolS:=0;nKolZN:=0;nc1:=nc2:=0;dDatNab:=ctod("")
lGenStavke:=.f.
if _TBankTr<>"X" .or. lPoNarudzbi   // ako je X onda su stavke vec izgenerisane
if !empty(gMetodaNC) .or. lPoNarudzbi
 IF lPoNarudzbi
   private aNabavke:={}
   IF !fNovi
     AADD( aNabavke , {0,_nc,_kolicina,_idnar,_brojnar} )
   ENDIF
   KalkNab3p(_idfirma,_idroba,_idkonto,aNabavke,@nKolS)
   IF LEN(aNabavke)>1; lGenStavke:=.t.; ENDIF
   IF LEN(aNabavke)>0
     // - tekuca -
     i:=LEN(aNabavke)
     _fcj := _nc := aNabavke[i,2]
     _kolicina := aNabavke[i,3]
     _idnar    := aNabavke[i,4]
     _brojnar  := aNabavke[i,5]
     // ----------
   ENDIF
   @ m_x+12,m_y+2   SAY "Kolicina " GET _Kolicina PICTURE PicKol when .f.
   @ row(),col()+2 SAY IspisPoNar(,,.t.)
 ELSE
   nc1:=nc2:=0
   MsgO("Racunam stanje u prodavnici")
    KalkNabP(_idfirma,_idroba,_idkonto,@nKolS,@nKolZN,@nc1,@nc2,@_RokTr)
   MsgC()
   if dDatNab>_DatDok; Beep(1);Msg("Datum nabavke je "+dtoc(dDatNab),4);endif
   if gMetodaNC $ "13"; _fcj:=nc1; elseif gMetodaNC=="2"; _fcj:=nc2; endif
 ENDIF
endif
endif

IF !lPoNarudzbi
  @ m_x+12,m_y+30   SAY "Ukupno na stanju "; @ m_x+12,col()+2 SAY nkols pict pickol
ENDIF

if !lVoSaTa
  @ m_x+14,m_y+2    SAY "NC  :"  GET _fcj picture picdem ;
               valid {|| V_KolPro(),;
                      _tprevoz:="A",_prevoz:=0,;
                      _nc:=_fcj,.t.}

 @ m_x+15,m_y+40   SAY "MP marza:" GET _TMarza2  VALID _Tmarza2 $ "%AU" PICTURE "@!"
 @ m_x+15,col()+1  GET _Marza2 PICTURE  PicDEM

endif

endif

@ m_x+17,m_y+2  SAY "MALOPROD. CJENA (MPC):"

@ m_x+17,m_y+50 GET _MPC picture PicDEM WHEN WMpc(.t.) VALID VMpc(.t.)

SayPorezi(18)

private cRCRP:="C"
@ m_x+19,m_y+2 SAY "POPUST (C-CIJENA,P-%)" GET cRCRP VALID cRCRP$"CP" PICT "@!"
@ m_x+19,m_y+50 GET _Rabatv picture picdem  VALID RabProcToC()

@ m_x+20,m_y+2 SAY "MPC SA POREZOM:"

@ m_x+20,m_y+50 GET _MPCSaPP  picture PicDEM  VALID VMpcSapp(.t.)
	     
read
ESC_RETURN K_ESC

if lPoNarudzbi
	_PKonto:=_Idkonto
	_PU_I:="5"     // izlaz iz prodavnice
	_MKonto:=""
	_MU_I:=""
	nRet:= GenStPoNarudzbi(lGenStavke)
	if nRet==K_ESC
		return K_ESC
	endif
endif

_PKonto:=_Idkonto
_PU_I:="5"     // izlaz iz prodavnice
nStrana:=2

FillIzgStavke(pIzgSt)
return lastkey()
*}


static function RabProcToC()
*{
if cRCRP=="P"
	_rabatv:=_mpcsapp*_rabatv/100
	cRCRP:="C"
	ShowGets()
endif
return .t.
*}

