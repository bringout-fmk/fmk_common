#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/prod/dok/1g/frm_12.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.6 $
 * $Log: frm_12.prg,v $
 * Revision 1.6  2004/05/25 13:53:17  sasavranic
 * Mogucnost evidentiranja tipa sredstva (donirano i kupljeno)
 *
 * Revision 1.5  2003/10/11 09:26:52  sasavranic
 * Ispravljen bug pri unosu izlaznih kalkulacija, na stanju uvije 0 robe, varijanta barkod
 *
 * Revision 1.4  2003/10/06 15:00:27  sasavranic
 * Unos podataka putem barkoda
 *
 * Revision 1.3  2003/08/01 16:19:23  mirsad
 * tvin, debug, 11-ka i 12-ka, kontrola stanja robe pri unosu
 *
 * Revision 1.2  2002/06/20 14:03:09  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/prod/dok/1g/frm_12.prg
 *  \brief Maska za unos dokumenta tipa 12
 */


/*! \fn Get1_12()
 *  \brief Prva strana maske za unos dokumenta tipa 12
 */

function Get1_12()
*{
pIzgSt:=.f.   // izgenerisane stavke jos ne postoje
private aPorezi:={}

_GKolicina:=_GKolicin2:=0
_IdPartner:=""
if nRbr==1 .or. !fnovi
 @ m_x+6,m_y+2   SAY "Otpremnica - Broj:" get _BrFaktP
 @ m_x+6,col()+2 SAY "Datum:" get _DatFaktP
 _DatFaktP:=_datdok
 _DatKurs:=_DatFaktP

 @ m_x+8,m_y+2   SAY "Prodavnicki konto razduzuje " GET _IdKonto valid P_Konto(@_IdKonto,24) pict "@!"

 if gNW<>"X"
  @ m_x+8,m_y+40  SAY "Razduzuje "   GET _IdZaduz  pict "@!" valid empty(_idZaduz) .or. P_Firma(@_IdZaduz,24)
 endif

 @ m_x+9,m_y+2   SAY "Magacinski konto zaduzuje   "  GET _IdKonto2 ;
                    valid empty(_IdKonto2) .or. P_Konto(@_IdKonto2,24)
 if gNW<>"X"
  @ m_x+9,m_y+40  SAY "Zaduzuje  " GET _IdZaduz2   pict "@!"  valid empty(_idZaduz2) .or. P_Firma(@_IdZaduz2,24)
 endif
 read; ESC_RETURN K_ESC
else
 @ m_x+6,m_y+2   SAY "Otpremnica - Broj: "; ?? _BrFaktP
 @ m_x+6,col()+2 SAY "Datum: "; ??  _DatFaktP

 @ m_x+8,m_y+2   SAY "Prodavnicki konto razduzuje "; ?? _IdKonto

 @ m_x+9,m_y+2   SAY "Magacinski konto zaduzuje   "; ?? _IdKonto2
endif
@ m_x+10,m_y+66 SAY "Tarif.br->"
if lKoristitiBK
	@ m_x+11,m_y+2   SAY "Artikal  " GET _IdRoba pict "@!S10" when {|| _IdRoba:=PADR(_idroba,VAL(gDuzSifIni)),.t.} valid VRoba()
else
	@ m_x+11,m_y+2   SAY "Artikal  " GET _IdRoba pict "@!" valid VRoba()
endif
@ m_x+11,m_y+70 GET _IdTarifa when gPromTar=="N" valid P_Tarifa(@_IdTarifa)

IF !lPoNarudzbi
  @ m_x+12,m_y+2   SAY "Kolicina " GET _Kolicina PICTURE PicKol valid _Kolicina<>0
ENDIF

IF IsDomZdr()
   @ m_x+13+IF(lPoNarudzbi,1,0),m_y+2   SAY "Tip sredstva (prazno-svi) " GET _Tip PICT "@!"
ENDIF

read
ESC_RETURN K_ESC

if lKoristitiBK
	_idRoba:=Left(_idRoba,10)
endif

select koncij; seek trim(_idkonto)
select pripr

_PKonto:=_Idkonto
_MKonto:=_Idkonto2
DatPosljP()
DatPosljK()
DuplRoba()

_GKolicina:=0

if fNovi
 select koncij; seek trim(_idkonto)
 select ROBA; HSEEK _IdRoba

 _MPCSaPP:=UzmiMPCSif()

 if koncij->naz<>"N2"
   _FCJ:=NC
   _VPC:=UzmiVPCSif(_mkonto)
 else
   _FCJ:=NC
   _VPC:=NC
 endif

 select PRIPR
 _Marza2:=0; _TMarza2:="A"
endif

if gCijene=="2"
  FaktMPC(@_Mpcsapp,_idfirma+_pkonto+_idroba)
  FaktVPC(@_VPC,_idfirma+_mkonto+_idroba)
endif

VTPOREZI()

///////////// kalkulacija nabavne cijene
//////// nKolZN:=kolicina koja je na stanju a porijeklo je od zadnje nabavke
nKolS:=0;nKolZN:=0;nc1:=nc2:=0;dDatNab:=ctod("")
lGenStavke:=.f.
if _TBankTr<>"X" .or. lPoNarudzbi   // ako je X onda su stavke vec izgenerisane
  if !empty(gMetodaNC) .or. lPoNarudzbi
    if lPoNarudzbi
      aNabavke:={}
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
    else
      MsgO("Racunam stanje na skladistu")
      KalkNabP(_idfirma,_idroba,_idkonto,@nKolS,@nKolZN,@nc1,@nc2,dDatNab,@_RokTr)
      MsgC()
      if dDatNab>_DatDok; Beep(1);Msg("Datum nabavke je "+dtoc(dDatNab),4);endif
      if gMetodaNC $ "13"; _fcj:=nc1; elseif gMetodaNC=="2"; _fcj:=nc2; endif
    endif
  endif
endif

IF !lPoNarudzbi
  @ m_x+12,m_y+30   SAY "Ukupno na stanju "; @ m_x+12,col()+2 SAY nkols pict pickol
ENDIF

if koncij->naz<>"N1"
  @ m_x+14,m_y+2    SAY "NC  :"  GET _fcj picture picdem valid V_KolPro()
  @ m_x+14,col()+4  SAY "VPC :"  GET _vpc picture picdem valid _vpc>0
else
  @ m_x+14,m_y+2    SAY "NABAVNA CIJENA (NC)         :"
  @ m_x+14,m_y+50   get _FCJ    picture PicDEM;
                     VALID {|| V_KolPro(),;
                               _vpc:=_fcj, .t.}
endif

_TPrevoz:="R"

@ m_x+16,m_y+2  SAY "MP marza:" GET _TMarza2  VALID _Tmarza2 $ "%AU" PICTURE "@!"
@ m_x+16,col()+1  GET _Marza2 PICTURE  PicDEM ;
    valid {|| _nc:=_fcj+iif(_TPrevoz=="A",_Prevoz,0),;
              _Tmarza:="A",;                // VP marza
              _marza:=_vpc/(1+_PORVT)-_fcj, .t.}       // VP marza

@ m_x+17,m_y+2  SAY "MALOPROD. CJENA (MPC):"
@ m_x+17,m_y+50 GET _MPC picture PicDEM ;
               WHEN WMpc() VALID VMpc()
	      
@ m_x+19,m_y+2  SAY "PPP (%):"; @ row(),col()+2 SAY  _opp*100   PICTURE "99.99"
@ m_x+19,col()+8  SAY "PPU (%):"; @ row(),col()+2  SAY _ppp*100 PICTURE "99.99"

@ m_x+19,m_y+2 SAY "MPC SA POREZOM:"
@ m_x+19,m_y+50 GET _MPCSaPP  picture PicDEM ;
            valid VMpcSaPP()
read; ESC_RETURN K_ESC
nStrana:=2

IF lPoNarudzbi
  _MKonto:=_Idkonto2;_MU_I:="1"     // ulaz u magacin
  _PKonto:=_Idkonto; _PU_I:="5"     // izlaz iz prodavnice
  IF lGenStavke
    pIzgSt:=.t.
    // vise od jedne stavke
    FOR i:=1 TO LEN(aNabavke)-1
      // generisi sve izuzev posljednje
      APPEND BLANK
      _error    := IF(_error<>"1","0",_error)
      _rbr      := RedniBroj(nRBr)
      _fcj := _nc := aNabavke[i,2]
      _kolicina := aNabavke[i,3]
      _idnar    := aNabavke[i,4]
      _brojnar  := aNabavke[i,5]
      // _vpc      := _nc
      Gather()
      ++nRBr
    NEXT
    // posljednja je tekuca
    _fcj := _nc := aNabavke[i,2]
    _kolicina := aNabavke[i,3]
    _idnar    := aNabavke[i,4]
    _brojnar  := aNabavke[i,5]
    // _vpc      := _nc
  ELSE
    // jedna ili nijedna
    IF LEN(aNabavke)>0
      // jedna
      _fcj := _nc := aNabavke[1,2]
      _kolicina := aNabavke[1,3]
      _idnar    := aNabavke[1,4]
      _brojnar  := aNabavke[1,5]
      // _vpc      := _nc
    ELSE
      // nije izabrana kolicina -> kao da je prekinut unos tipkom Esc
      RETURN (K_ESC)
    ENDIF
  ENDIF
ENDIF

_MKonto:=_Idkonto2;_MU_I:="1"     // ulaz u magacin
_PKonto:=_Idkonto; _PU_I:="5"     // izlaz iz prodavnice

FillIzgStavke(pIzgSt)
return lastkey()
*}

