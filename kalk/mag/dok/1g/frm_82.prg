#include "\cl\sigma\fmk\kalk\kalk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/mag/dok/1g/frm_82.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.6 $
 * $Log: frm_82.prg,v $
 * Revision 1.6  2004/05/25 13:53:16  sasavranic
 * Mogucnost evidentiranja tipa sredstva (donirano i kupljeno)
 *
 * Revision 1.5  2003/10/11 09:26:51  sasavranic
 * Ispravljen bug pri unosu izlaznih kalkulacija, na stanju uvije 0 robe, varijanta barkod
 *
 * Revision 1.4  2003/10/06 15:00:26  sasavranic
 * Unos podataka putem barkoda
 *
 * Revision 1.3  2002/06/19 13:57:53  mirsad
 * no message
 *
 * Revision 1.2  2002/06/17 14:48:21  ernad
 *
 *
 * ciscenje
 *
 *
 */


/*! \file fmk/kalk/mag/dok/1g/frm_82.prg
 *  \brief Maska za unos dokumenta tipa 82
 */


/*! \fn Get1_82()
 *  \brief Prva strana maske za unos dokumenta tipa 82
 */

function Get1_82()
*{
pIzgSt:=.f.   // izgenerisane stavke jos ne postoje
//private cisMarza:=0

set key K_ALT_K to KM2()
if nRbr==1 .and. fnovi
  _DatFaktP:=_datdok
endif
if nRbr==1 .or. !fnovi
 @  m_x+7,m_y+2   SAY "Faktura Broj:" get _BrFaktP
 @  m_x+7,col()+2 SAY "Datum:" get _DatFaktP   ;
    valid {|| _DatKurs:=_DatFaktP,.t.}
 _IdZaduz:=""
 
 _Idkonto2:=""

 @ m_x+9,m_y+2 SAY "Magacinski konto razduzuje"  GET _IdKonto ;
            valid empty(_IdKonto) .or. P_Konto(@_IdKonto,24)
 if gNW<>"X"
   @ m_x+9,m_y+40 SAY "Razduzuje:" GET _IdZaduz   pict "@!"  valid empty(_idZaduz) .or. P_Firma(@_IdZaduz,24)
 endif
else
 //@  m_x+6,m_y+2   SAY "KUPAC: "; ?? _IdPartner
 @  m_x+7,m_y+2   SAY "Faktura Broj: "; ?? _BrFaktP
 @  m_x+7,col()+2 SAY "Datum: "; ?? _DatFaktP
 _IdZaduz:=""
 _DatKurs:=_DatFaktP
 _Idkonto2:=""
 @ m_x+9,m_y+2 SAY "Magacinski konto razduzuje "; ?? _IdKonto
 if gNW<>"X"
   @ m_x+9,m_y+40 SAY "Razduzuje: "; ?? _IdZaduz
 endif
endif

 @ m_x+10,m_y+66 SAY "Tarif.brÄ¿"
 
 if lKoristitiBK
 	@ m_x+11,m_y+2   SAY "Artikal  " GET _IdRoba pict "@!S10" when {|| _idRoba:=PADR(_idRoba,VAL(gDuzSifIni)),.t.} valid  {|| P_Roba(@_IdRoba),Reci(11,23,trim(roba->naz)+" ("+ROBA->jmj+")",40),_IdTarifa:=iif(fnovi,ROBA->idtarifa,_IdTarifa),.t.}
 else
 	@ m_x+11,m_y+2   SAY "Artikal  " GET _IdRoba pict "@!" valid  {|| P_Roba(@_IdRoba),Reci(11,23,trim(roba->naz)+" ("+ROBA->jmj+")",40),_IdTarifa:=iif(fnovi,ROBA->idtarifa,_IdTarifa),.t.}
 endif
 @ m_x+11,m_y+70 GET _IdTarifa when gPromTar=="N" valid P_Tarifa(@_IdTarifa)

 read; ESC_RETURN K_ESC
 if lKoristitiBK
 	_idRoba:=Left(_idRoba, 10)
 endif

 select TARIFA; hseek _IdTarifa  // postavi TARIFA na pravu poziciju
 select koncij; seek trim(_idkonto)
 select PRIPR  // napuni tarifu

 _MKonto:=_Idkonto2
 DuplRoba()
 DatPosljK()

 IF !lPoNarudzbi
   @ m_x+12,m_y+2   SAY "Kolicina " GET _Kolicina PICTURE PicKol valid _Kolicina<>0
 ENDIF

 IF IsDomZdr()
   @ m_x+13+IF(lPoNarudzbi,1,0),m_y+2   SAY "Tip sredstva (prazno-svi) " GET _Tip PICT "@!"
 ENDIF


_GKolicina:=0
if fNovi
 select ROBA; HSEEK _IdRoba
 _VPC:=KoncijVPC()
 _NC:=NC
endif
if gCijene="2" .and. fNovi
  /////// utvrdjivanje fakticke VPC
   faktVPC(@_VPC,_idfirma+_idkonto+_idroba)
   select pripr
endif
VtPorezi()

///////////// kalkulacija nabavne cijene
//////// nKolZN:=kolicina koja je na stanju a porijeklo je od zadnje nabavke
nKolS:=0
nKolZN:=0
nc1:=nc2:=0
dDatNab:=ctod("")

lGenStavke:=.f.
if _TBankTr<>"X" .or. lPoNarudzbi   // ako je X onda su stavke vec izgenerisane
 IF lPoNarudzbi
   aNabavke:={}
   IF !fNovi
     AADD( aNabavke , {0,_nc,_kolicina,_idnar,_brojnar} )
   ENDIF
   KalkNab3m(_idfirma,_idroba,_idkonto,aNabavke)
   IF LEN(aNabavke)>1; lGenStavke:=.t.; ENDIF
   IF LEN(aNabavke)>0
     // - teku†a -
     i:=LEN(aNabavke)
     _nc := aNabavke[i,2]
     _kolicina := aNabavke[i,3]
     _idnar    := aNabavke[i,4]
     _brojnar  := aNabavke[i,5]
     // ----------
   ENDIF
   @ m_x+12,m_y+2   SAY "Kolicina " GET _Kolicina PICTURE PicKol when .f.
   @ row(),col()+2 SAY IspisPoNar(,,.t.)
 ELSE
   if !empty(gMetodaNC)
    MsgO("Racunam stanje na skladistu")
    KalkNab(_idfirma,_idroba,_idkonto,@nKolS,@nKolZN,@nc1,@nc2,@dDatNab,@_RokTr)
    MsgC()
   endif
   if dDatNab>_DatDok; Beep(1);Msg("Datum nabavke je "+dtoc(dDatNab),4);endif
   if gMetodaNC $ "13"; _nc:=nc1; elseif gMetodaNC=="2"; _nc:=nc2; endif
 ENDIF
endif
select PRIPR

IF !lPoNarudzbi
  @ m_x+12,m_y+30   SAY "Ukupno na stanju "; @ m_x+12,col()+2 SAY nkols pict pickol
ENDIF

@ m_x+13,m_y+2    SAY "NAB.CJ   "  GET _NC  picture PicDEM      valid V_KolMag()

private _vpcsappp:=0

 @ m_x+14,m_y+2   SAY "VPC      " get _VPC    picture PicDEM ;
                 valid {|| iif(gVarVP=="2" .and. (_vpc-_nc)>0,cisMarza:=(_vpc-_nc)/(1+tarifa->vpp),_vpc-_nc),;
                _mpcsapp:=_MPCSaPP:=(1+_OPP)*_VPC*(1-_Rabatv/100)*(1+_PPP),;
                _mpcsapp:=round(_mpcsapp,2),.t.}

_RabatV:=0

@ m_x+19,m_y+2  SAY "PPP (%):"; @ row(),col()+2 SAY  _OPP*100 PICTURE "99.99"
@ m_x+19,col()+8  SAY "PPU (%):"; @ row(),col()+2  SAY _PPP*100 PICTURE "99.99"

@ m_x+20,m_y+2 SAY "MPC SA POREZOM:"
@ m_x+20,m_y+50 GET _MPCSaPP  picture PicDEM ;
            valid {|| _mpc:=iif(_mpcsapp<>0 ,_mpcsapp/(1+_opp)/(1+_PPP),_mpc),;
                      _marza2:=0,;
                      Marza2R(),ShowGets(),.t.}
read; ESC_RETURN K_ESC


nStrana:=2
_marza:=_vpc-_nc

IF lPoNarudzbi
  _MKonto:=_Idkonto;_MU_I:="5"     // izlaz iz magacina
  _PKonto:=""; _PU_I:=""
  IF lGenStavke
    pIzgSt:=.t.
    // viçe od jedne stavke
    FOR i:=1 TO LEN(aNabavke)-1
      // generiçi sve izuzev posljednje
      APPEND BLANK
      _error    := IF(_error<>"1","0",_error)
      _rbr      := RedniBroj(nRBr)
      _nc       := aNabavke[i,2]
      _kolicina := aNabavke[i,3]
      _idnar    := aNabavke[i,4]
      _brojnar  := aNabavke[i,5]
      // _vpc      := _nc
      Gather()
      ++nRBr
    NEXT
    // posljednja je teku†a
    _nc       := aNabavke[i,2]
    _kolicina := aNabavke[i,3]
    _idnar    := aNabavke[i,4]
    _brojnar  := aNabavke[i,5]
    // _vpc      := _nc
  ELSE
    // jedna ili nijedna
    IF LEN(aNabavke)>0
      // jedna
      _nc       := aNabavke[1,2]
      _kolicina := aNabavke[1,3]
      _idnar    := aNabavke[1,4]
      _brojnar  := aNabavke[1,5]
      // _vpc      := _nc
    ELSE
      // nije izabrana koliŸina -> kao da je prekinut unos tipkom Esc
      RETURN (K_ESC)
    ENDIF
  ENDIF
ENDIF

_MKonto:=_Idkonto;_MU_I:="5"     // izlaz iz magacina
_PKonto:=""; _PU_I:=""

if pIzgSt   .and. _kolicina>0 .and. lastkey()<>K_ESC // izgenerisane stavke postoje
 private nRRec:=recno()
 go top
 do while !eof()  // nafiluj izgenerisane stavke
  if kolicina==0
     skip
     private nRRec2:=recno()
     skip -1
     dbdelete2()
     go nRRec2
     loop
  endif
  if brdok==_brdok .and. idvd==_idvd .and. val(Rbr)==nRbr
    nMarza:=_VPC*(1-_RabatV/100)-_NC
    replace vpc with _vpc,;
          rabatv with _rabatv,;
          mkonto with _mkonto,;
          tmarza  with _tmarza,;
          mpc     with  _MPC,;
          marza  with _vpc-pripr->nc,;   // mora se uzeti nc iz ove stavke
          mu_i with  _mu_i,;
          pkonto with _pkonto,;
          pu_i with  _pu_i ,;
          error with "0"
  endif
  skip
 enddo
 go nRRec
endif

set key K_ALT_K to
return lastkey()
*}
