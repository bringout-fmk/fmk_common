#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/mag/dok/1g/frm_18.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.6 $
 * $Log: frm_18.prg,v $
 * Revision 1.6  2003/10/11 09:26:51  sasavranic
 * Ispravljen bug pri unosu izlaznih kalkulacija, na stanju uvije 0 robe, varijanta barkod
 *
 * Revision 1.5  2003/10/07 11:48:31  sasavranic
 * Brisanje sifara za artikle koji nisu u prometu! Dorada
 *
 * Revision 1.4  2003/10/06 15:00:26  sasavranic
 * Unos podataka putem barkoda
 *
 * Revision 1.3  2002/07/12 10:15:55  ernad
 *
 *
 * debug ROBPR.DBF, ROBPR.CDX - uklonjena funkcija DodajRobPr()
 *
 * Revision 1.2  2002/06/19 13:57:53  mirsad
 * no message
 *
 *
 */


/*! \file fmk/kalk/mag/dok/1g/frm_18.prg
 *  \brief Maska za unos dokumenta tipa 18
 */


/*! \fn Get1_18()
 *  \brief Prva strana maske za unos dokumenta tipa 18
 */

function Get1_18()
*{
_DatFaktP:=_datdok

_DatKurs:=_DatFaktP

 @ m_x+8,m_y+2   SAY "Konto koji zaduzuje" GET _IdKonto valid  P_Konto(@_IdKonto,24) pict "@!"
 if gNW<>"X"
   @ m_x+8,m_y+35  SAY "Zaduzuje: "   GET _IdZaduz  pict "@!" valid empty(_idZaduz) .or. P_Firma(@_IdZaduz,24)
 endif
 read; ESC_RETURN K_ESC

 @ m_x+10,m_y+66 SAY "Tarif.brÄ¿"
 if lKoristitiBK
 	@ m_x+11,m_y+2   SAY "Artikal  " GET _IdRoba pict "@!S10" when {|| _idRoba:=PADR(_idRoba,VAL(gDuzSifIni)),.t.} valid  {|| P_Roba(@_IdRoba),Reci(11,23,trim(roba->naz)+" ("+ROBA->jmj+")",40),_IdTarifa:=iif(fnovi,ROBA->idtarifa,_IdTarifa),.t.}
 else
  	@ m_x+11,m_y+2   SAY "Artikal  " GET _IdRoba pict "@!" valid  {|| P_Roba(@_IdRoba),Reci(11,23,trim(roba->naz)+" ("+ROBA->jmj+")",40),_IdTarifa:=iif(fnovi,ROBA->idtarifa,_IdTarifa),.t.}
 endif
 @ m_x+11,m_y+70 GET _IdTarifa when gPromTar=="N" valid P_Tarifa(@_IdTarifa)

 read
 ESC_RETURN K_ESC
 if lKoristitiBK
 	_idRoba:=Left(_idRoba, 10)
 endif

 select TARIFA
 hseek _IdTarifa  // postavi TARIFA na pravu poziciju
 select koncij
 seek trim(_idkonto)
 select PRIPR  // napuni tarifu

 _MKonto:=_Idkonto
 DatPosljK()
 DuplRoba()

 dDatNab:=ctod("")
 if fnovi
    _Kolicina:=0
 endif
 lGenStavke:=.f.
 if !empty(gmetodaNC) .and. _TBankTr<>"X" .or. lPoNarudzbi  // X - izgenerisana stavka
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
       // _nc       := aNabavke[i,2]
       _kolicina := aNabavke[i,3]
       _idnar    := aNabavke[i,4]
       _brojnar  := aNabavke[i,5]
       // ----------
     ENDIF
   ELSE
     MsgO("Racunam kolicinu robe na skladistu")
      if gKolicFakt=="D"
        KalkNaF(_idroba,@_kolicina) // uzmi iz FAKTA
      else
        KalkNab(_idfirma,_idroba,_idkonto,@_kolicina,NIL,NIL,NIL,@dDatNab)
      endif
     MsgC()
   ENDIF
 endif
 IF !lPoNarudzbi
   if dDatNab>_DatDok; Beep(1);Msg("Datum nabavke je "+dtoc(dDatNab),4);endif
   @ m_x+12,m_y+2   SAY "Kolicina " GET _Kolicina PICTURE PicKol valid _kolicina>0
 ELSE
   @ m_x+12,m_y+2   SAY "Kolicina " GET _Kolicina PICTURE PicKol when .f.
   @ row(),col()+2 SAY IspisPoNar(,,.t.)
 ENDIF
 ** kod nivelacije moze biti i  valid _Kolicina<>0

 if fnovi .and. gMagacin=="2" .and. _TBankTr<>"X"
    nStCj:=KoncijVPC()
 else
    nStCj:=_MPCSAPP
 endif

 if fnovi
   nNCj:=0
 else
   nNCJ:=_VPC+nStCj   // sadrzi NOVU CIJENU
 endif

 if roba->tip="X"
    MsgBeep("Za robu tipa X ne rade se nivelacije")
 endif

 if roba->tip $ "VK"
   cNaziv:="VPCVT"
 else
   cNaziv:="VPC"
 endif
 if gmagacin=="1"
   cNaziv:="NC"
 endif
 @ m_x+17,m_y+2    SAY "STARA CIJENA  ("+ cnaziv +") :"  GET nStCj  picture PicDEM
 @ m_x+18,m_y+2    SAY "NOVA CIJENA   ("+ cnaziv +") :"  GET nNCj   picture PicDEM

 if gMPCPomoc=="D"
     private _MPCPom:=0
     @ m_x+18,m_y+42    SAY "NOVA CIJENA  MPC :"  GET _mpcpom   picture PicDEM ;
            valid {|| nNcj:=iif(nNcj=0,round(_mpcpom/(1+TARIFA->opp/100)/(1+TARIFA->PPP/100),2),nNcj), .t. }
 endif

 read
 ESC_RETURN K_ESC

 if _TBankTr<>"X"

   select roba
   SetujVPC(nNCJ , .t. )

   select pripr
 endif


 if gMPCPomoc=="D"
     if (roba->mpc==0 .or. roba->mpc<>round(_mpcpom,2)) .and. round(_mpcpom,2)<>0 .and. Pitanje(,"Staviti MPC u sifrarnik")=="D"
         select roba
	 replace mpc with _mpcpom
         select pripr
     endif
 endif

 if roba->tip $ "VK"
  _VPC:=(nNCJ-nStCj)
  _MPCSAPP:=nStCj
 else
  _VPC:=nNCJ-nStCj
  _MPCSAPP:=nStCj
 endif

_idpartner:=""
_rabat:=prevoz:=prevoz2:=_banktr:=_spedtr:=_zavtr:=_nc:=_marza:=_marza2:=_mpc:=0
_gkolicina:=_gkolicin2:=_mpc:=0

IF lPoNarudzbi
  _MKonto:=_Idkonto;_MU_I:="3"     // ninvelacija
  _PKonto:="";      _PU_I:=""
  IF lGenStavke
    pIzgSt:=.t.
    // viçe od jedne stavke
    FOR i:=1 TO LEN(aNabavke)-1
      // generiçi sve izuzev posljednje
      APPEND BLANK
      _error    := IF(_error<>"1","0",_error)
      _rbr      := RedniBroj(nRBr)
      // _nc       := aNabavke[i,2]
      _kolicina := aNabavke[i,3]
      _idnar    := aNabavke[i,4]
      _brojnar  := aNabavke[i,5]
      // _vpc      := _nc
      Gather()
      ++nRBr
    NEXT
    // posljednja je teku†a
    // _nc       := aNabavke[i,2]
    _kolicina := aNabavke[i,3]
    _idnar    := aNabavke[i,4]
    _brojnar  := aNabavke[i,5]
    // _vpc      := _nc
  ELSE
    // jedna ili nijedna
    IF LEN(aNabavke)>0
      // jedna
      // _nc       := aNabavke[1,2]
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

_MKonto:=_Idkonto
_MU_I:="3"     // nivelacija
_PKonto:=""
_PU_I:=""

nStrana:=3
return lastkey()
*}

