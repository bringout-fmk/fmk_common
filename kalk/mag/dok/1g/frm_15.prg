#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/mag/dok/1g/frm_15.prg,v $
 *
 *
 */


/*! \file fmk/kalk/mag/dok/1g/frm_15.prg
 *  \brief Maska za unos dokumenta tipa 15
 */
 

/*! \fn Get1_15()
 *  \brief Prva strana maske za unos dokumenta tipa 15
 */


****************************************
****************************************
function Get1_15()
*{
private aPorezi:={}
pIzgSt:=.f.   // izgenerisane stavke jos ne postoje

if nRbr==1 .and. fnovi
  _DatFaktP:=_datdok
endif

if nRbr==1  .or. !fnovi
 _GKolicina:=_GKolicin2:=0
   @  m_x+6,m_y+2   SAY "KUPAC:" get _IdPartner pict "@!" valid empty(_IdPartner) .or. P_Firma(@_IdPartner,6,18)
   @  m_x+7,m_y+2   SAY "Faktura Broj:" get _BrFaktP
   @  m_x+7,col()+2 SAY "Datum:" get _DatFaktP   ;
    valid {|| _DatKurs:=_DatFaktP,.t.}
 _DatKurs:=_DatFaktP

 @ m_x+8,m_y+2   SAY "Prodavnicki Konto zaduzuje" GET _IdKonto valid  P_Konto(@_IdKonto,24) pict "@!"
 if gNW<>"X"
   @ m_x+8,m_y+42  SAY "Zaduzuje: "   GET _IdZaduz  pict "@!" valid empty(_idZaduz) .or. P_Firma(@_IdZaduz,24)
 endif

 @ m_x+9,m_y+2   SAY "Magacinski konto razduzuje"  GET _IdKonto2 ;
            valid empty(_IdKonto2) .or. P_Konto(@_IdKonto2,24)
 if gNW<>"X"
   @ m_x+9,m_y+42 SAY "Razduzuje:" GET _IdZaduz2   pict "@!"  valid empty(_idZaduz2) .or. P_Firma(@_IdZaduz2,24)
 endif
 read; ESC_RETURN K_ESC
else
 if _IdVD $ "11#12#13#22"
   @  m_x+6,m_y+2   SAY "Otpremnica - Broj: "; ?? _BrFaktP
   @  m_x+6,col()+2 SAY "Datum: "; ?? _DatFaktP
 endif
 @ m_x+8,m_y+2   SAY "Prodavnicki Konto zaduzuje "; ?? _IdKonto
 if gNW<>"X"
   @ m_x+8,m_y+42  SAY "Zaduzuje: "; ?? _IdZaduz
 endif
 @ m_x+9,m_y+2   SAY "Magacinski konto razduzuje "; ?? _IdKonto2
 if gNW<>"X"
   @ m_x+9,m_y+42  SAY "Razduzuje: "; ?? _IdZaduz2
 endif
endif

 @ m_x+10,m_y+66 SAY "Tarif.brÄ¿"
 
 if lKoristitiBK
	@ m_x+11,m_y+2   SAY "Artikal  " GET _IdRoba pict "@!S10" when {|| _IdRoba:=PADR(_idroba,VAL(gDuzSifIni)),.t.} valid VRoba()
 else
	@ m_x+11,m_y+2   SAY "Artikal  " GET _IdRoba pict "@!" valid VRoba()
 endif
 
 @ m_x+11,m_y+70 GET _IdTarifa when gPromTar=="N" valid P_Tarifa(@_IdTarifa)

 IF !lPoNarudzbi
   @ m_x+12,m_y+2   SAY "Kolicina " GET _Kolicina PICTURE PicKol valid _Kolicina<>0
 ENDIF
 read
 ESC_RETURN K_ESC
 if lKoristitiBK
 	_idRoba:=Left(_idRoba, 10)
 endif

 select TARIFA; hseek _IdTarifa  // postavi TARIFA na pravu poziciju
 select koncij; seek trim(_idkonto)
 select PRIPR  // napuni tarifu

 _MKonto:=_Idkonto2
 _PKonto:=_Idkonto
 DatPosljK()
 DatPosljP()
 DuplRoba()


_GKolicina:=_GKolicin2:=0
if fNovi
 select roba
 _MPCSaPP:=UzmiMPCSif()

 if koncij->naz<>"N1"
   _FCJ:=NC; _VPC:=UzmiVPCSif(_mkonto)
 else
   _FCJ:=NC; _VPC:=NC
 endif

 select koncij; seek trim(_pkonto); select roba
 if gcijene=="2"
   FaktMPC(@_MPCSAPP,_idfirma+_Pkonto+_idroba)
 endif

 select PRIPR
 _Marza2:=0; _TMarza2:="A"
endif

*if gcijene=="2" .OR. ROUND(_VPC,3)=0 // uvijek nadji
*  select koncij; seek trim(_mkonto); select pripr  // magacin
*  FaktVPC(@_VPC,_idfirma+_mkonto+_idroba)
*  select koncij; seek trim(_pkonto); select pripr  // magacin
*endif

VTPorezi()

_VPC:=  _mpcsapp / (1+_zpp+_ppp) /(1+_opp)
_MPC:=  _VPC


//////// kalkulacija nabavne cijene u magacinu
//////// nKolZN:=kolicina koja je na stanju a porijeklo je od zadnje nabavke

nKolS:=0;nKolZN:=0;nc1:=nc2:=0
lGenStavke:=.f.
if _TBankTr<>"X" .or. lPoNarudzbi   // ako je X onda su stavke vec izgenerisane
if !empty(gMetodaNC) .or. lPoNarudzbi
 nc1:=nc2:=0
 dDatNab:=ctod("")
 if lPoNarudzbi
   aNabavke:={}
   IF !fNovi
     AADD( aNabavke , {0,_nc,_kolicina,_idnar,_brojnar} )
   ENDIF
   IF !fNovi
     IF _kolicina<0
       KalkNab3p(_idfirma,_idroba,_idkonto,aNabavke)
     ELSE
       KalkNab3m(_idfirma,_idroba,_idkonto2,aNabavke)
     ENDIF
   ELSEIF Pitanje(,"1-storno MP putem VP , 2-prodaja MP putem VP (1/2) ?","2","12")=="2"
     KalkNab3p(_idfirma,_idroba,_idkonto,aNabavke)
   ELSE
     KalkNab3m(_idfirma,_idroba,_idkonto2,aNabavke)
   ENDIF
   IF LEN(aNabavke)>1; lGenStavke:=.t.; ENDIF
   IF LEN(aNabavke)>0
     // - teku†a -
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
   if _kolicina>0
    MsgO("Racunam stanje na skladistu")
      KalkNab(_idfirma,_idroba,_idkonto2,@nKolS,@nKolZN,@nc1,@nc2,@dDatNab,@_RokTr)
    MsgC()
   else
    MsgO("Racunam stanje prodavnice")
      KalkNabP(_idfirma,_idroba,_idkonto,@nKolS,@nKolZN,@nc1,@nc2,dDatNab,@_RokTr)
    MsgC()
   endif
   if dDatNab>_DatDok; Beep(1);Msg("Datum nabavke je "+dtoc(dDatNab),4);endif
   if gMetodaNC $ "13"; _fcj:=nc1; elseif gMetodaNC=="2"; _fcj:=nc2; endif
 endif
endif
endif

if !lPoNarudzbi
  if _kolicina>0
    @ m_x+12,m_y+30   SAY "Na stanju magacin "; @ m_x+12,col()+2 SAY nkols pict pickol
  else
    @ m_x+12,m_y+30   SAY "Na stanju prodavn "; @ m_x+12,col()+2 SAY nkols pict pickol
  endif
endif

select koncij; seek trim(_idkonto2); select pripr
if  koncij->naz=="N1"
  _VPC:=_NC
endif

if koncij->naz<>"N1"
 if _kolicina>0
  @ m_x+14,m_y+2    SAY "NC  :"  GET _fcj picture gPicNC valid V_KolMag()
 else // storno zaduzenja
  @ m_x+14,m_y+2    SAY "NC  :"  GET _fcj picture gPicNC valid V_KolPro()
 endif
  @ m_x+14,col()+2  SAY "VPC :"  GET _vpc picture picdem ;
             when {|| iif(gCijene=="2",.f.,.t.)}
else
  _vpc:=_fcj
  @ m_x+14,m_y+2    SAY "NABAVNA CIJENA (NC)       :"  
  if _kolicina>0
    @ m_x+14,m_y+50   get _fcj    picture gPicNC ;
                        VALID {|| V_KolMag(),;
                        _vpc:=_Fcj,.t.}
  else // storno zaduzenja prodavnice
    @ m_x+14,m_y+50   get _FCJ    picture PicDEM;
                     VALID {|| V_KolPro(),;
                               _vpc:=_fcj, .t.}
  endif
endif

select koncij; seek trim(_idkonto); select pripr

if fnovi
 _TPrevoz:="R"
endif
if nRbr==1 .or. !fnovi //prva stavka
 *  @ m_x+16,m_y+2    SAY "MP trosak (A,R):" get _TPrevoz valid _TPrevoz $ "AR" pict "@!"
 *  @ m_x+16,col()+2  GET _prevoz pict picdem
else
 *  @ m_x+16,m_y+2    SAY "MP trosak:"; ?? "("+_TPrevoz+") "; ?? _prevoz
endif

private fMarza:=" "
_Tmarza:="A"
_marza:=_vpc/(1+_PORVT)-_fcj


@ m_x+18,m_y+2  SAY "MALOPROD. CJENA (MPC):"

@ m_x+18,m_y+50 GET _MPC PICT PicDEM WHEN WMpc(.t.) VALID VMpc(.t.)

//                 _mpc:=iif(_mpcsapp<>0 .and. empty(fmarza),_mpcsapp/(1+_opp)/(1+_ppp),_mpc),.t.} ;
//                _mpcsapp:=iif(_mpcsapp==0,_MPCSaPP:=round((1+_opp)*_MPC*(1+_ppp),2),_mpcsapp),.t.}

@ m_x+19,m_y+2  SAY "PPP (%):"; @ row(),col()+2 SAY  _opp*100   PICTURE "99.99"
@ m_x+19,col()+8  SAY "PPU (%):"; @ row(),col()+2  SAY _ppp*100 PICTURE "99.99"
@ m_x+19,col()+8  SAY "PP (%):"; @ row(),col()+2  SAY _zpp*100 PICTURE "99.99"

@ m_x+20,m_y+2 SAY "MPC SA POREZOM:"

@ m_x+20,m_y+50 GET _MPCSaPP  picture PicDEM VALID VMpcSaPP(.f.)

read
ESC_RETURN K_ESC

_Tmarza:="A"
_marza:=_vpc/(1+_PORVT)-_fcj

select koncij; seek trim(_idkonto)
StaviMPCSif(_mpcsapp,.t.)       // .t. znaci sa upitom
select pripr

IF lPoNarudzbi
  _MKonto:=_Idkonto2; _MU_I:= "8"     //  - 1 * ulaz , -1 *  izlaz
  _PKonto:=_Idkonto;  _PU_I:= "1"     // ulaz u prodavnicu
  IF lGenStavke
    pIzgSt:=.t.
    // viçe od jedne stavke
    FOR i:=1 TO LEN(aNabavke)-1
      // generiçi sve izuzev posljednje
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
    // posljednja je teku†a
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
      // nije izabrana koliŸina -> kao da je prekinut unos tipkom Esc
      RETURN (K_ESC)
    ENDIF
  ENDIF
ENDIF

_MKonto:=_Idkonto2; _MU_I:= "8"     //  - 1 * ulaz , -1 *  izlaz
_PKonto:=_Idkonto;  _PU_I:= "1"     // ulaz u prodavnicu

nStrana:=2

if pIzgSt .and. _kolicina>0 .and. lastkey()<>K_ESC // izgenerisane stavke postoje
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
    replace nc with pripr->fcj,;
          vpc with _vpc,;
          tprevoz with _tprevoz,;
          prevoz with _prevoz,;
          mpc    with _mpc,;
          mpcsapp with _mpcsapp,;
          tmarza  with _tmarza,;
          marza  with _vpc/(1+_PORVT)-pripr->fcj,;      // konkretna vp marza
          tmarza2  with _tmarza2,;
          marza2  with _marza2,;
          mkonto with _mkonto,;
          mu_i with  _mu_i,;
          pkonto with _pkonto,;
          pu_i with  _pu_i ,;
          error with "0"
  endif
  skip
 enddo
 go nRRec
endif

return lastkey()
*}

