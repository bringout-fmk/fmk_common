#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/mag/dok/1g/frm_94.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.4 $
 * $Log: frm_94.prg,v $
 * Revision 1.4  2003/10/11 09:26:51  sasavranic
 * Ispravljen bug pri unosu izlaznih kalkulacija, na stanju uvije 0 robe, varijanta barkod
 *
 * Revision 1.3  2003/10/06 15:00:27  sasavranic
 * Unos podataka putem barkoda
 *
 * Revision 1.2  2002/06/19 13:57:53  mirsad
 * no message
 *
 *
 */
 


/*! \file fmk/kalk/mag/dok/1g/frm_94.prg
 *  \brief Maska za unos dokumenta tipa 94
 */

// prijem robe 16
// storno 14-ke fakture !!!!!!!!!! - 94
// storno otpreme  - 97

/*! \fn Get1_94()
 *  \brief Prva strana maske za unos dokumenta tipa 94
 */

function Get1_94()
*{
local nRVPC
pIzgSt:=.f.   // izgenerisane stavke jos ne postoje

set key K_ALT_K to KM94()

if nRbr==1 .and. fnovi
  _DatFaktP:=_datdok
endif

if nRbr==1 .or. !fnovi .or. gMagacin=="1"
 if _idvd $ "94#97"
  @  m_x+6,m_y+2   SAY "KUPAC:" get _IdPartner pict "@!" valid empty(_IdPartner) .or. P_Firma(@_IdPartner,6,18)
 endif
 @  m_x+7,m_y+2   SAY "Faktura/Otpremnica Broj:" get _BrFaktP
 @  m_x+7,col()+2 SAY "Datum:" get _DatFaktP   ;
    valid {|| _DatKurs:=_DatFaktP,.t.}

  @ m_x+9,m_y+2 SAY "Magacinski konto zaduzuje"  GET _IdKonto ;
              valid empty(_IdKonto) .or. P_Konto(@_IdKonto,24)
  if gNW<>"X"
    @ m_x+9,m_y+40 SAY "Zaduzuje:" GET _IdZaduz   pict "@!"  valid empty(_idZaduz) .or. P_Firma(@_IdZaduz,24)
  else
    if !empty(cRNT1)
      @ m_x+9,m_y+40 SAY "Rad.nalog:"   GET _IdZaduz2  pict "@!"
    endif
  endif

  if _idvd=="16"
   @ m_x+10,m_y+2   SAY "Prenos na konto          " GET _IdKonto2   valid empty(_idkonto2) .or. P_Konto(@_IdKonto2,24) pict "@!"
   if gNW<>"X"
     @ m_x+10,m_y+35  SAY "Zaduzuje: "   GET _IdZaduz2  pict "@!" valid empty(_idZaduz) .or. P_Firma(@_IdZaduz2,24)
   endif
  endif

else
 @  m_x+6,m_y+2   SAY "KUPAC: "; ?? _IdPartner
 @  m_x+7,m_y+2   SAY "Faktura Broj: "; ?? _BrFaktP
 @  m_x+7,col()+2 SAY "Datum: "; ?? _DatFaktP
 _DatKurs:=_DatFaktP
 @ m_x+9,m_y+2 SAY "Magacinski konto zaduzuje "; ?? _IdKonto
 if gNW<>"X"
  @ m_x+9,m_y+40 SAY "Zaduzuje: "; ?? _IdZaduz
 endif

endif

 @ m_x+10,m_y+66 SAY "Tarif.brĿ"
 if lKoristitiBK
 	@ m_x+11,m_y+2   SAY "Artikal  " GET _IdRoba pict "@!S10" when {|| _idRoba:=PADR(_idRoba,VAL(gDuzSifIni)),.t.} valid  {|| P_Roba(@_IdRoba),Reci(11,23,trim(roba->naz)+" ("+ROBA->jmj+")",40),_IdTarifa:=iif(fnovi,ROBA->idtarifa,_IdTarifa),.t.}
 else
  	@ m_x+11,m_y+2   SAY "Artikal  " GET _IdRoba pict "@!" valid  {|| P_Roba(@_IdRoba),Reci(11,23,trim(roba->naz)+" ("+ROBA->jmj+")",40),_IdTarifa:=iif(fnovi,ROBA->idtarifa,_IdTarifa),.t.}
 endif
 
 @ m_x+11,m_y+70 GET _IdTarifa when gPromTar=="N" valid P_Tarifa(@_IdTarifa)

IF lPoNarudzbi
  @ m_x+12,m_y+2 SAY "Po narudzbi br." GET _brojnar
  @ m_x+12,col()+2 SAY "za narucioca" GET _idnar pict "@!" valid empty(_idnar) .or. P_Firma(@_idnar,12,50)
ENDIF

 // IF !lPoNarudzbi
   @ m_x+12+IF(lPoNarudzbi,1,0),m_y+2   SAY "Kolicina " GET _Kolicina PICTURE PicKol valid _Kolicina<>0
 // ENDIF
 read; ESC_RETURN K_ESC
 if lKoristitiBK
 	_idRoba:=Left(_idRoba, 10)
 endif

 select koncij; seek trim(_idkonto)  // postavi TARIFA na pravu poziciju
 select TARIFA; hseek _IdTarifa  // postavi TARIFA na pravu poziciju
 select PRIPR  // napuni tarifu
 _MKonto:=_Idkonto; _MU_I:="1"

IF gVarEv=="1"          ///////////////////////////// sa cijenama

 DatPosljK()
 DuplRoba()

 _GKolicina:=0
 if fNovi
  select ROBA; HSEEK _IdRoba
  if koncij->naz=="P2"
    _nc:=plc
    _vpc:=plc
  else
   _VPC:=KoncijVPC()
   _NC:=NC
  endif
 endif

 VTPorezi()

 select PRIPR

 @ m_x+13+IF(lPoNarudzbi,1,0),m_y+2    SAY "NAB.CJ   "  GET _NC  picture gPicNC  when V_kol10()

 private _vpcsappp:=0


 if koncij->naz<>"N1"

   if koncij->naz=="P2"
      @ m_x+14+IF(lPoNarudzbi,1,0),m_y+2   SAY "PLAN. C. " GET _VPC    picture picdem
   else
      @ m_x+14+IF(lPoNarudzbi,1,0),m_y+2   SAY "VPC      " get _VPC    picture PicDEM
   endif

 if _IdVD $ "94"   // storno fakture

 @ m_x+15+IF(lPoNarudzbi,1,0),m_y+2    SAY "RABAT (%)" get _RABATV    picture picdem ;
      valid V_RabatV()

 _PNAP:=0
 @ m_x+16+IF(lPoNarudzbi,1,0),m_y+2    SAY "PPP (%)  " get _MPC pict "99.99" ;
  when {|| iif(roba->tip=="V",_mpc:=0,NIL),iif(roba->tip=="V",ppp14(.f.),.t.)} ;
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

 endif // _idvd $ "94"

 read // vodi se po vpc

 else // vodi se po nc
  read
  _VPC:=_nc; marza:=0
 endif

 if koncij->naz<>"N1"
   VPCuSif(_vpc)
 endif

ENDIF    // kraj IF gVarEv=="1"

 _mpcsapp:=0
nStrana:=2

_marza:=_vpc-_nc
_MKonto:=_Idkonto;_MU_I:="1"
_PKonto:=""; _PU_I:=""
set key K_ALT_K to
return lastkey()
*}



/*! \fn KM94()
 *  \brief Magacinska kartica kao pomoc pri unosu 94-ke
 */

// koristi se stkalk14   za stampu kalkulacije
// stkalk 95 za stampu 16-ke
function KM94()
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
Karticam(_IdFirma,_idroba,_IdKonto)
OEdit()
select roba
go nR1
select pripr
go nR2
select tarifa
go nR3
select pripr
return
*}

