#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/mag/dok/1g/frm_10.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.6 $
 * $Log: frm_10.prg,v $
 * Revision 1.6  2004/05/25 13:27:22  sasavranic
 * Dom Zdravlja SA:
 * evidentiranje tipa sredstva pri pravljenju ulaza,
 * mogucnost prikaza tipa sredstva na izvjestajima
 *
 * Revision 1.5  2003/11/22 15:26:45  sasavranic
 * planika robno poslovanje, prodnc
 *
 * Revision 1.4  2003/10/11 09:26:51  sasavranic
 * Ispravljen bug pri unosu izlaznih kalkulacija, na stanju uvije 0 robe, varijanta barkod
 *
 * Revision 1.3  2003/10/06 15:00:26  sasavranic
 * Unos podataka putem barkoda
 *
 * Revision 1.2  2002/06/19 13:57:53  mirsad
 * no message
 *
 *
 */
 
// privatne varijable: 
//  - fNovi
//  - nRbr


/*! \file fmk/kalk/mag/dok/1g/frm_10.prg
 *  \brief Maska za unos dokumenta tipa 10
 */


/*! \fn Get1_10()
 *  \brief Prvi ekran maske za unos dokumenta tipa 10
 */

function Get1_10()
*{
// ovim funkcijama je proslijedjen parametar fnovi kao privatna varijabla

if nRbr==1 .and. fnovi
	_DatFaktP:=_datdok
endif

if nRbr==1  .or. !fnovi .or. gMagacin=="1"
	@  m_x+6,m_y+2   SAY "DOBAVLJAC:" get _IdPartner pict "@!" valid empty(_IdPartner) .or. P_Firma(@_IdPartner,6,22)
 	@  m_x+7,m_y+2   SAY "Faktura dobavljaca - Broj:" get _BrFaktP
 	@  m_x+7,col()+2 SAY "Datum:" get _DatFaktP
 	_DatKurs:=_DatFaktP
 	@ m_x+10,m_y+2   SAY "Magacinski Konto zaduzuje" GET _IdKonto valid  P_Konto(@_IdKonto,24) pict "@!"
 	if gNW<>"X"
  		@ m_x+10,m_y+42  SAY "Zaduzuje: "   GET _IdZaduz  pict "@!" valid empty(_idZaduz) .or. P_Firma(@_IdZaduz,24)
 	endif
 	if !empty(cRNT1)
   		@ m_x+10,m_y+42  SAY "Rad.nalog:"   GET _IdZaduz2  pict "@!"
 	endif
 	read
	ESC_RETURN K_ESC
else
	@ m_x+6,m_y+2 SAY "DOBAVLJAC: "
	?? _IdPartner
 	@ m_x+7,m_y+2 SAY "Faktura dobavljaca - Broj: "
	?? _BrFaktP
 	@ m_x+7,col()+2 SAY "Datum: "
	?? _DatFaktP
	@ m_x+10,m_y+2 SAY "Magacinski Konto zaduzuje "
	?? _IdKonto
 	if gNW<>"X"
   		@ m_x+10,m_y+42 SAY "Zaduzuje: "
		?? _IdZaduz
 	endif
endif

@ m_x+11,m_y+66 SAY "Tarif.brĿ"

if lKoristitiBK
	@ m_x+12,m_y+2  SAY "Artikal  " GET _IdRoba pict "@!S10" when { || _idroba:=padr(_idroba,VAL(gDuzSifIni)),.t. } valid  {|| _idroba:=iif(len(trim(_idroba))<10,left(_idroba,10),_idroba), P_Roba(@_IdRoba),Reci(12,23,trim(roba->naz)+" ("+ROBA->jmj+")",40),_IdTarifa:=iif(fnovi,ROBA->idtarifa,_IdTarifa),.t.}
else
	@ m_x+12,m_y+2  SAY "Artikal  " GET _IdRoba pict "@!" valid  {|| _idroba:=iif(len(trim(_idroba))<10,left(_idroba,10),_idroba), P_Roba(@_IdRoba),Reci(12,23,trim(roba->naz)+" ("+ROBA->jmj+")",40),_IdTarifa:=iif(fnovi,ROBA->idtarifa,_IdTarifa),.t.}
endif

@ m_x+12,m_y+70 GET _IdTarifa when gPromTar=="N" valid P_Tarifa(@_IdTarifa)

if lPoNarudzbi
	@ m_x+13,m_y+2 SAY "Po narudzbi br." GET _brojnar
  	@ m_x+13,col()+2 SAY "za narucioca" GET _idnar pict "@!" valid empty(_idnar) .or. P_Firma(@_idnar,13,50)
endif

read
ESC_RETURN K_ESC

if lKoristitiBK
	_idRoba:=Left(_idRoba, 10)
endif

// Bas i nije pametno ovo raditi pri unosu
//if IsPlanika()
//	PlFillIdPartner(_idpartner, _idroba)
//endif

select koncij
seek trim(_idkonto)
select pripr

_MKonto:=_Idkonto
_MU_I:="1"
DatPosljK()

select TARIFA
hseek _IdTarifa  // postavi TARIFA na pravu poziciju
select PRIPR  // napuni tarifu

@ m_x+13+IF(lPoNarudzbi,1,0),m_y+2   SAY "Kolicina " GET _Kolicina PICTURE PicKol valid _Kolicina<>0

if gRokTr=="D"
	@ m_x+13+IF(lPoNarudzbi,1,0),col()+1 SAY "Rok trajanja" GET _RokTr
endif

if IsDomZdr()
	@ m_x+14+IF(lPoNarudzbi,1,0),m_y+2 SAY "Tip sredstva (prazno-svi) " GET _Tip PICT "@!"
endif

if fNovi
	select ROBA
	HSEEK _IdRoba
 	_VPC := KoncijVPC()
	if Carina<>0
    		_TCarDaz:="%"
    		_CarDaz:=carina
 	endif
 	if roba->tip="X"
   		_MPCSAPP:=roba->mpc   // pohraniti za naftu MPC !!!!
 	endif
endif

select PRIPR

if _tmarza<>"%"  // procente ne diraj
	_Marza:=0
endif

if gVarEv=="1"
	@ m_x+15+IF(lPoNarudzbi,1,0),m_y+2   SAY "F.CJ.(DEM/JM):"
 	@ m_x+15+IF(lPoNarudzbi,1,0),m_y+50  GET _FCJ PICTURE gPicNC valid _fcj>0 when V_kol10()
	@ m_x+17+IF(lPoNarudzbi,1,0),m_y+2   SAY "KASA-SKONTO(%):"
 	@ m_x+17+IF(lPoNarudzbi,1,0),m_y+40 GET _Rabat PICTURE PicDEM when DuplRoba()
	if gNW<>"X"   .or. gVodiKalo=="D"
   		@ m_x+18+IF(lPoNarudzbi,1,0),m_y+2   SAY "Normalni . kalo:"
   		@ m_x+18+IF(lPoNarudzbi,1,0),m_y+40  GET _GKolicina PICTURE PicKol
		@ m_x+19+IF(lPoNarudzbi,1,0),m_y+2   SAY "Preko  kalo:    "
   		@ m_x+19+IF(lPoNarudzbi,1,0),m_y+40  GET _GKolicin2 PICTURE PicKol
	endif
endif

read
ESC_RETURN K_ESC

_FCJ2:=_FCJ*(1-_Rabat/100)

return lastkey()
*}



/*! \fn Get2_10()
 *  \brief Drugi ekran maske za unos dokumenta tipa 10
 */

function Get2_10()
*{
local cSPom:=" (%,A,U,R) "
private getlist:={}

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
@ m_x+8,m_y+50    GET _NC     PICTURE gPicNC

if koncij->naz<>"N1"  // vodi se po vpc
  private fMarza:=" "
  @ m_x+10,m_y+2    SAY "Magacin. Marza            :" GET _TMarza VALID _Tmarza $ "%AU" PICTURE "@!"
  @ m_x+10,m_y+40 GET _Marza PICTURE PicDEM
  @ m_x+10,col()+1 GET fMarza pict "@!" valid {|| Marza(fMarza),fMarza:=" ",.t.}

  if roba->tip $ "VKX"
    @ m_x+14,m_y+2  SAY "VELEPRODAJNA CJENA VT          :"
    @ m_x+14,m_y+40 GET _VPC pict picdem ;
      valid {|| Marza(fMarza),vvt()}
  else
    if koncij->naz=="P2"
     @ m_x+12,m_y+2    SAY "PLANSKA CIJENA  (PLC)       :"
    else
     @ m_x+12,m_y+2    SAY "VELEPRODAJNA CIJENA (VPC)   :"
    endif
    @ m_x+12,m_y+50 get _VPC    picture PicDEM;
                       VALID {|| Marza(fMarza),.t.}

  endif

  if gMPCPomoc=="D"
    _mpcsapp:=roba->mpc
   // VPC se izracunava pomocu MPC cijene !!
       @ m_x+16,m_y+2 SAY "MPC SA POREZOM:"
       @ m_x+16,m_y+50 GET _MPCSaPP  picture PicDEM ;
             valid {|| _mpcsapp:=iif(_mpcsapp=0,round(_vpc*(1+TARIFA->opp/100)/(1+TARIFA->PPP/100),2),_mpcsapp),_mpc:=_mpcsapp/(1+TARIFA->opp/100)/(1+TARIFA->PPP/100),;
                       iif(_mpc<>0,_vpc:=round(_mpc,2),_vpc), ShowGets(),.t.}

  endif
  read

  if gmpcpomoc=="D"
     if (roba->mpc==0 .or. roba->mpc<>round(_mpcsapp,2)) .and. Pitanje(,"Staviti MPC u sifrarnik")=="D"
         select roba; replace mpc with _mpcsapp
         select pripr
     endif
  endif

  SetujVPC(_VPC , .f. )    // .f. - setuj samo ako je vpc u sifraniku 0

else
  read
  _Marza:=0; _TMarza:="A"; _VPC:=_NC
endif

_MKonto:=_Idkonto; _MU_I:="1"
nStrana:=3
return lastkey()
*}



/*! \fn Get1_10s()
 *  \brief
 */

function Get1_10s()
*{
LOCAL nNCpom:=0
if nRbr==1  .or. !fnovi
 _DatFaktP:=_datdok
 @  m_x+6,m_y+2   SAY "DOBAVLJAC:" get _IdPartner pict "@!" valid empty(_IdPartner) .or. P_Firma(@_IdPartner,6,22)
 @  m_x+7,m_y+2   SAY "Faktura dobavljaca - Broj:" get _BrFaktP
 @  m_x+7,col()+2 SAY "Datum:" get _DatFaktP
 _DatKurs:=_DatFaktP
 @ m_x+10,m_y+2   SAY "Magacinski Konto zaduzuje" GET _IdKonto valid  P_Konto(@_IdKonto,24) pict "@!"
 if gNW<>"X"
  @ m_x+10,m_y+42  SAY "Zaduzuje: "   GET _IdZaduz  pict "@!" valid empty(_idZaduz) .or. P_Firma(@_IdZaduz,24)
 endif
 read; ESC_RETURN K_ESC
else
 @  m_x+6,m_y+2   SAY "DOBAVLJAC: "; ?? _IdPartner
 @  m_x+7,m_y+2   SAY "Faktura dobavljaca - Broj: "; ?? _BrFaktP
 @  m_x+7,col()+2 SAY "Datum: "; ?? _DatFaktP
 // @  m_x+8,m_y+2   SAY "Dat kursa: "; ?? _DatKurs ;

 @ m_x+10,m_y+2   SAY "Magacinski Konto zaduzuje ";?? _IdKonto
 if gNW<>"X"
  @ m_x+10,m_y+42  SAY "Zaduzuje: "; ?? _IdZaduz
 endif
endif

IF !glEkonomat
  @ m_x+11,m_y+66 SAY "Tarif.brĿ"
ENDIF
@ m_x+12,m_y+2  SAY "Artikal  " GET _IdRoba pict "@!" ;
                  valid  {|| P_Roba(@_IdRoba),Reci(12,23,trim(roba->naz)+" ("+ROBA->jmj+")",40),_IdTarifa:=iif(fnovi,ROBA->idtarifa,_IdTarifa),.t.}
IF !glEkonomat
  @ m_x+12,m_y+70 GET _IdTarifa when gPromTar=="N" valid P_Tarifa(@_IdTarifa)
ENDIF

read; ESC_RETURN K_ESC

select koncij; seek trim(_IdKonto)
select TARIFA; hseek _IdTarifa  // postavi TARIFA na pravu poziciju
select PRIPR  // napuni tarifu
_MKonto:=_Idkonto; _MU_I:="1"

DatPosljK()
DuplRoba()

if roba->tip $ "VKX"
  Beep(1)
  Msg("Za robu VT ne moze se koristiti skracena varijanta kalk 10")
endif

@ m_x+13,m_y+2   SAY "Kolicina " GET _Kolicina PICTURE PicKol valid _Kolicina<>0
if gRokTr=="D"
 @ m_x+13,col()+1 SAY "Rok trajanja" GET _RokTr
endif
if fNovi
 select ROBA; HSEEK _IdRoba
 _VPC := KoncijVPC()
endif

select PRIPR
if _tmarza<>"%"  // procente ne diraj
 _Marza:=0
endif

IF gVarEv=="1"

 IF !glEkonomat
   @ m_x+15,m_y+2   SAY "F.CJ.(DEM/JM):"
   @ m_x+15,col()+2 GET _FCJ PICTURE gPicNC valid _fcj>0 when V_kol10()

   @ m_x+15,m_y+36   SAY "Rabat(%):"
   @ m_x+15,col()+2 GET _Rabat PICTURE PicDEM valid {|| _FCJ2:=_FCJ*(1-_Rabat/100),NabCj(),nNCpom:=_NC,.t.}
 ENDIF

 @ m_x+17,m_y+2     SAY "NABAVNA CJENA:"
 @ m_x+17,col()+2    GET _NC     PICTURE gPicNC VALID NabCj2(_NC,nNCpom)

 if empty(_TPrevoz); _TPrevoz:="%"; endif
 if empty(_TCarDaz); _TCarDaz:="%"; endif
 if empty(_TBankTr); _TBankTr:="%"; endif
 if empty(_TSpedTr); _TSpedtr:="%"; endif
 if empty(_TZavTr);  _TZavTr:="%" ; endif
 if empty(_TMarza);  _TMarza:="%" ; endif

 if koncij->naz<>"N1"  // vodi se po vpc
   private fMarza:=" "
   @ m_x+17,m_y+36   SAY "Magacin. Marza   :" GET _TMarza VALID _Tmarza $ "%AU" PICTURE "@!"
   @ m_x+17,col()+1  GET _Marza PICTURE PicDEM
   @ m_x+17,col()+1 GET fMarza pict "@!" valid {|| Marza(fMarza),fMarza:=" ",.t.}
   @ m_x+19,m_y+2    SAY "VELEPRODAJNA CJENA:"
   @ m_x+19,col()+2  get _VPC    picture PicDEM;
                    VALID {|| Marza(fMarza),.t.}
   read

   VPCuSif(_vpc)

 else
   read
   _Marza:=0; _TMarza:="A"; _VPC:=_NC
 endif

ELSE   // tj. gVarEv=="2" (bez cijena)
  read
ENDIF

_MKonto:=_Idkonto; _MU_I:="1"
nStrana:=3
return lastkey()
*}



/*! \fn V_kol10()
 *  \brief Validacija unosa kolicine
 */

function V_kol10()
*{
if _kolicina<0  // storno
nKolS:=0;nKolZN:=0;nc1:=nc2:=0; dDatNab:=ctod("")
 if !empty(gMetodaNC)
  MsgO("Racunam stanje na skladistu")
  KalkNab(_idfirma,_idroba,_mkonto,@nKolS,@nKolZN,@nc1,@nc2,@dDatNab,@_RokTr)
  MsgC()
  @ m_x+12,m_y+30   SAY "Ukupno na stanju "; @ m_x+12,col()+2 SAY nkols pict pickol
 endif
 if dDatNab>_DatDok; Beep(1);Msg("Datum nabavke je "+dtoc(dDatNab),4);endif
 if _idvd == "16"  // storno prijema
   if gMetodaNC $ "13"; _nc:=nc1; elseif gMetodaNC=="2"; _nc:=nc2; endif
 endif
 if nkols < abs(_kolicina)
   _ERROR:="1"
   Beep(2)
   Msg("Na stanju je samo kolicina:"+str(nkols,12,3))
 endif
select PRIPR
endif
return .t.
*}

