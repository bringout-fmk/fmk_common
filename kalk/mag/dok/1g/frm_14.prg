#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/mag/dok/1g/frm_14.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.6 $
 * $Log: frm_14.prg,v $
 * Revision 1.6  2004/05/25 13:53:16  sasavranic
 * Mogucnost evidentiranja tipa sredstva (donirano i kupljeno)
 *
 * Revision 1.5  2003/10/11 09:26:51  sasavranic
 * Ispravljen bug pri unosu izlaznih kalkulacija, na stanju uvije 0 robe, varijanta barkod
 *
 * Revision 1.4  2003/10/06 15:00:26  sasavranic
 * Unos podataka putem barkoda
 *
 * Revision 1.3  2003/07/18 07:24:54  mirsad
 * stavio u f-ju kontrolu stanja za varijantu po narudzbama za izlazne dokumente (14,41,42)
 *
 * Revision 1.2  2002/06/19 13:57:53  mirsad
 * no message
 *
 *
 */


/*! \file fmk/kalk/mag/dok/1g/frm_14.prg
 *  \brief Maska za unos dokumenta tipa 14
 */
 

/*! \fn Get1_14()
 *  \brief Prva strana maske za unos dokumenta tipa 14
 */

function Get1_14()
*{
pIzgSt:=.f.   // izgenerisane stavke jos ne postoje
//private cisMarza:=0

set key K_ALT_K to KM2()
if nRbr==1 .and. fnovi
  _DatFaktP:=_datdok
endif
if nRbr==1 .or. !fnovi
 @  m_x+6,m_y+2   SAY "KUPAC:" get _IdPartner pict "@!" valid empty(_IdPartner) .or. P_Firma(@_IdPartner,6,18)
 @  m_x+7,m_y+2   SAY "Faktura Broj:" get _BrFaktP
 @  m_x+7,col()+2 SAY "Datum:" get _DatFaktP   ;
    valid {|| _DatKurs:=_DatFaktP,.t.}
 _IdZaduz:=""
 
 _Idkonto:="1200"
 private cNBrDok:=_brdok
 @ m_x+9,m_y+2 SAY "Magacinski konto razduzuje"  GET _IdKonto2 ;
            valid ( empty(_IdKonto2) .or. P_Konto(@_IdKonto2,24) ) .and.;
                  MarkBrDok(fNovi)
 if gNW<>"X"
  @ m_x+9,m_y+40 SAY "Razduzuje:" GET _IdZaduz2   pict "@!"  valid empty(_idZaduz2) .or. P_Firma(@_IdZaduz2,24)
 endif
else
 @  m_x+6,m_y+2   SAY "KUPAC: "; ?? _IdPartner
 @  m_x+7,m_y+2   SAY "Faktura Broj: "; ?? _BrFaktP
 @  m_x+7,col()+2 SAY "Datum: "; ?? _DatFaktP
 _IdZaduz:=""
 _DatKurs:=_DatFaktP
 _Idkonto:="1200"
 @ m_x+9,m_y+2 SAY "Magacinski konto razduzuje "; ?? _IdKonto2
 if gNW<>"X"
  @ m_x+9,m_y+40 SAY "Razduzuje: "; ?? _IdZaduz2
 endif
endif

 @ m_x+10,m_y+66 SAY "Tarif.brÄ¿"
 if lKoristitiBK
 	@ m_x+11,m_y+2   SAY "Artikal  " GET _IdRoba pict "@!S10" when {|| _IdRoba:=PADR(_idroba,VAL(gDuzSifIni)),.t.} valid  {|| P_Roba(@_IdRoba),Reci(11,23,trim(roba->naz)+" ("+ROBA->jmj+")",40),_IdTarifa:=iif(fnovi,ROBA->idtarifa,_IdTarifa),.t.}
 else
 	@ m_x+11,m_y+2   SAY "Artikal  " GET _IdRoba pict "@!" valid  {|| P_Roba(@_IdRoba),Reci(11,23,trim(roba->naz)+" ("+ROBA->jmj+")",40),_IdTarifa:=iif(fnovi,ROBA->idtarifa,_IdTarifa),.t.}
 endif
 @ m_x+11,m_y+70 GET _IdTarifa when gPromTar=="N" valid P_Tarifa(@_IdTarifa)

 // IF lPoNarudzbi
 //   @ m_x+12,m_y+2 SAY "Po narudzbi br." GET _brojnar WHEN {|| _idnar:=_idpartner,.t.}
 // ENDIF

 IF !lPoNarudzbi
   @ m_x+12+IF(lPoNarudzbi,1,0),m_y+2   SAY "Kolicina " GET _Kolicina PICTURE PicKol valid _Kolicina<>0
 ENDIF

 IF IsDomZdr()
   @ m_x+13+IF(lPoNarudzbi,1,0),m_y+2   SAY "Tip sredstva (prazno-svi) " GET _Tip PICT "@!"
 ENDIF

 read; ESC_RETURN K_ESC

 _MKonto:=_Idkonto2
 
 if lKoristitiBK
 	_idRoba:=Left(_idRoba, 10)
 endif

 select TARIFA; hseek _IdTarifa  // postavi TARIFA na pravu poziciju
 select ROBA; HSEEK _IdRoba
 select koncij; seek trim(_idkonto2)
 select PRIPR  // napuni tarifu

 if koncij->naz="P"
     _FCJ:=roba->PlC
 endif
 DatPosljK()
 DuplRoba()
 if fNovi
  select roba
  _VPC:=KoncijVPC()
  _NC:=NC
  if roba->tip="X"
   _MPCSAPP:=roba->mpc   // pohraniti za naftu MPC !!!!
  endif
  select pripr
 endif
 if gCijene="2" .and. fNovi
  /////// utvrdjivanje fakticke VPC
   faktVPC(@_VPC,_idfirma+_idkonto2+_idroba)
   select pripr
 endif
 VtPorezi()

 if roba->tip="X" .and. _MPCSAPP=0
   _MPCSAPP:=roba->mpc   // pohraniti za naftu MPC !!!!
 endif

_GKolicina:=0
//////// kalkulacija nabavne cijene
//////// nKolZN:=kolicina koja je na stanju a porijeklo je od zadnje nabavke
nKolS:=0;nKolZN:=0;nc1:=nc2:=0; dDatNab:=ctod("")
lGenStavke:=.f.
if _TBankTr<>"X" .or. lPoNarudzbi   // ako je X onda su stavke vec izgenerisane
 if !empty(gMetodaNC) .or. lPoNarudzbi
   if lPoNarudzbi
     aNabavke:={}
     IF !fNovi
       AADD( aNabavke , {0,_nc,_kolicina,_idnar,_brojnar} )
     ENDIF
     KalkNab3m(_idfirma,_idroba,_idkonto2,aNabavke,@nKolS)
     IF LEN(aNabavke)>1; lGenStavke:=.t.; ENDIF
     IF LEN(aNabavke)>0
       // - teku†a -
       i:=LEN(aNabavke)
       _nc       := aNabavke[i,2]
       _kolicina := aNabavke[i,3]
       _idnar    := aNabavke[i,4]
       _brojnar  := aNabavke[i,5]
       // ----------
     ENDIF
     @ m_x+12+IF(lPoNarudzbi,1,0),m_y+2   SAY "Kolicina " GET _Kolicina PICTURE PicKol when .f.
     @ row(),col()+2 SAY IspisPoNar(,,.t.)
   else
     MsgO("Racunam stanje na skladistu")
     KalkNab(_idfirma,_idroba,_idkonto2,@nKolS,@nKolZN,@nc1,@nc2,@dDatNab,@_RokTr)
     MsgC()
     @ m_x+12+IF(lPoNarudzbi,1,0),m_y+30   SAY "Ukupno na stanju "; @ m_x+12+IF(lPoNarudzbi,1,0),col()+2 SAY nkols pict pickol
   endif
 endif
 IF !lPoNarudzbi
   if dDatNab>_DatDok; Beep(1);Msg("Datum nabavke je "+dtoc(dDatNab),4);endif
   if _kolicina>=0
    if gMetodaNC $ "13"; _nc:=nc1; elseif gMetodaNC=="2"; _nc:=nc2; endif
   endif
 ENDIF
endif
select PRIPR

@ m_x+13+IF(lPoNarudzbi,1,0),m_y+2    SAY "NAB.CJ   "  GET _NC  picture PicDEM      valid V_KolMag()

private _vpcsappp:=0

@ m_x+14+IF(lPoNarudzbi,1,0),m_y+2   SAY "VPC      " get _VPC  valid {|| iif(gVarVP=="2" .and. (_vpc-_nc)>0,cisMarza:=(_vpc-_nc)/(1+tarifa->vpp),_vpc-_nc),.t.}  picture PicDEM

private cTRabat:="%"
@ m_x+15+IF(lPoNarudzbi,1,0),m_y+2    SAY "RABAT    " GET  _RABATV pict picdem
@ m_x+15+IF(lPoNarudzbi,1,0),col()+2  GET cTRabat  pict "@!" ;
     valid {|| PrerRab(), V_RabatV(), ctrabat $ "%AU" }

_PNAP:=0
@ m_x+16+IF(lPoNarudzbi,1,0),m_y+2    SAY "PPP (%)  " get _MPC pict "99.99" ;
 when {|| iif(roba->tip $ "VKX",_mpc:=0,NIL),iif(roba->tip $ "VKX",ppp14(.f.),.t.)} ;
 valid ppp14(.t.)

@ m_x+17+IF(lPoNarudzbi,1,0),m_y+2    SAY "PRUC (%) "; qqout(transform(TARIFA->VPP,"99.99"))

if gVarVP=="1"
 _VPCsaPP:=0
 @ m_x+19+IF(lPoNarudzbi,1,0),m_y+2  SAY "VPC + PPP  "
 @ m_x+19+IF(lPoNarudzbi,1,0),m_Y+50 GET _vpcSaPP picture picdem ;
      when {|| _VPCSAPP:=iif(_VPC<>0,_VPC*(1-_RabatV/100)*(1+_MPC/100),0),ShowGets(),.t.} ;
      valid {|| _vpcsappp:=iif(_VPCsap<>0,_vpcsap+_PNAP,_VPCSAPPP),.t.}

else  // preracunate stope
 _VPCsaPP:=0
 @ m_x+19+IF(lPoNarudzbi,1,0),m_y+2  SAY "VPC + PPP  "
 @ m_x+19+IF(lPoNarudzbi,1,0),m_Y+50 GET _vpcSaPP picture picdem ;
      when {|| _VPCSAPP:=iif(_VPC<>0,_VPC*(1-_RabatV/100)*(1+_MPC/100),0),ShowGets(),.t.} ;
      valid {|| _vpcsappp:=iif(_VPCsap<>0,_vpcsap+_PNAP,_VPCSAPPP),.t.}
endif

if gMagacin=="1"  // ovu cijenu samo prikazati ako se vodi po nabavnim cijenama
_VPCSAPPP:=0
@ m_x+20+IF(lPoNarudzbi,1,0),m_y+2 SAY "VPC + PPP + PRUC:"
@ m_x+20+IF(lPoNarudzbi,1,0),m_Y+50 GET _vpcSaPPP picture picdem  ;
     VALID {||  VPCSAPPP()}

endif
read
nStrana:=2
if roba->tip="X"
 _marza:=_vpc-_mpcsapp/(1+_PORVT)*_PORVT-_nc
else
 _mpcsapp:=0
 _marza:=_vpc/(1+_PORVT)-_nc
endif

IF lPoNarudzbi
  _MKonto:=_Idkonto2;_MU_I:="5"     // izlaz iz magacina
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

_MKonto:=_Idkonto2;_MU_I:="5"     // izlaz iz magacina
_PKonto:=""; _PU_I:=""

if pIzgSt  .and. _kolicina>0 .and. lastkey()<>K_ESC // izgenerisane stavke postoje
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

    nMarza:=_VPC/(1+_PORVT)*(1-_RabatV/100)-_NC  // ??????????
    replace vpc with _vpc,;
          rabatv with _rabatv,;
          mkonto with _mkonto,;
          tmarza  with _tmarza,;
          mpc     with  _MPC,;
          marza  with _vpc/(1+_PORVT)-pripr->nc,;   // mora se uzeti nc iz ove stavke
          vpcsap with _VPC/(1+_PORVT)*(1-_RABATV/100)+iif(nMarza<0,0,nMarza)*TARIFA->VPP/100,;
          mu_i with  _mu_i,;
          pkonto with "",;
          pu_i with  "",;
          error with "0"
  endif
  skip
 enddo
 go nRRec
endif

set key K_ALT_K to
return lastkey()
*}




/*! \fn PPP14(fret)
 *  \brief Prikaz poreza pri unosu 14-ke
 */

function PPP14(fret)
*{
devpos(m_x+16+IF(lPoNarudzbi,1,0),m_y+41)
if roba->tip $ "VKX"
  // nista ppp
else
  qqout("    PPP:",transform(_PNAP:=_VPC*(1-_RabatV/100)*_MPC/100,picdem) )
endif
devpos(m_x+17+IF(lPoNarudzbi,1,0),m_y+41)
qqout("   PRUC:",transform(iif(nmarza<0,0,nmarza)*;
        iif(gVarVP=="1",tarifa->vpp/100,tarifa->vpp/100/(1+tarifa->vpp/100)),picdem))
_VPCSaP:=iif(_VPC<>0, _VPC*(1-_RABATV/100)+iif(nMarza<0,0,nMarza)*TARIFA->VPP/100,0)
return fret
*}




/*! \fn KM2()
 *  \brief Magacinska kartica kao pomoc pri unosu 14-ke
 */

function KM2()
*{
 local nR1,nR2,nR3
  private GetList:={}
  select  roba
  nR1:=recno()
  select pripr
  nR2:=recno()
  select tarifa
  nR3:=recno()
  close all
  Karticam(_IdFirma,_idroba,_IdKonto2)
  OEdit()
  select roba
  go nR1
  select pripr
  go nR2
  select tarifa
  go nR3
  select pripr
return nil
*}




/*! \fn MarkBrDok(fNovi)
 *  \brief Odredjuje sljedeci broj dokumenta uzimajuci u obzir marker definisan u polju koncij->m1
 */

function MarkBrDok(fNovi)
*{
 LOCAL nArr:=SELECT()
  _brdok:=cNBrDok
  IF fNovi .and. KONCIJ->(FIELDPOS("M1"))<>0
    SELECT KONCIJ; HSEEK _idkonto2
    IF !EMPTY(m1)
      select kalk; set order to 1; seek _idfirma+_idvd+"X"
      skip -1
      _brdok:=space(8)
      do while !bof() .and. idvd==_idvd
        if UPPER(right(brdok,3))==UPPER(KONCIJ->m1)
          _brdok:=brdok
          exit
        endif
        skip -1
      enddo
      _Brdok:=UBrojDok(val(left(_brdok,5))+1,5,KONCIJ->m1)
    ENDIF
    SELECT (nArr)
  ENDIF
  @  m_x+2,m_y+46  SAY _BrDok COLOR INVERT
return .t.
*}

