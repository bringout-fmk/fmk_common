#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/prod/db/1g/nivel.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.3 $
 * $Log: nivel.prg,v $
 * Revision 1.3  2002/07/12 10:15:55  ernad
 *
 *
 * debug ROBPR.DBF, ROBPR.CDX - uklonjena funkcija DodajRobPr()
 *
 * Revision 1.2  2002/06/20 14:03:09  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/prod/db/1g/nivel.prg
 *  \brief Automatsko generisanje dokumenta nivelacije pri azuriranju 11 ili 81
 */


/*! \fn Niv_11()
 *  \brief Automatsko generisanje dokumenta nivelacije pri azuriranju 11 ili 81
 */

function Niv_11()
*{
O_TARIFA
O_KONCIJ
O_PRIPR
O_PRIPR2
O_KALK
if IzFMKIni("Svi","Sifk")=="D"
   O_SIFK;O_SIFV
endif
O_ROBA

select pripr; go top
private cIdFirma:=idfirma,cIdVD:=idvd,cBrDok:=brdok
if !(cidvd $ "11#81") .and. !empty(gMetodaNC)
  closeret
endif

private cBrNiv:="0"
select kalk
seek cidfirma+"19"+Chr(254)
skip -1
if idvd<>"19"
     cBrNiv:=space(8)
else
     cBrNiv:=brdok
endif
cBrNiv:=UBrojDok(val(left(cBrNiv,5))+1,5,right(cBrNiv,3))

select pripr
go top
private nRBr:=0
cPromjCj:="D"
fNivelacija:=.f.
do while !eof() .and. cidfirma==idfirma .and. cidvd==idvd .and. cbrdok==brdok
  scatter()
  select koncij; seek trim(_idkonto)
  select roba; hseek _idroba
  select tarifa; hseek roba->idtarifa
  select roba

  privat nMPC:=0
  nMPC:=UzmiMPCSif()
  if gCijene="2"
   /////// utvrdjivanje fakticke mpc
   faktMPC(@nMPC,_idfirma+_pkonto+_idroba)
   select pripr
  endif

  if _mpcsapp<>nMPC // izvrsiti nivelaciju

   if !fNivelacija   // prva stavka za nivelaciju
     cPromCj:=Pitanje(,"Postoje promjene cijena. Staviti nove cijene u sifrarnik ?","D")
   endif
   fNivelacija:=.t.

   private nKolZn:=nKols:=nc1:=nc2:=0,dDatNab:=ctod("")
   KalkNabP(_idfirma,_idroba,_idkonto,@nKolS,@nKolZN,@nc1,@nc2,@dDatNab,@_RokTr)
   if dDatNab>_DatDok; Beep(1);Msg("Datum nabavke je "+dtoc(dDatNab),4);_ERROR:="1";endif

   select pripr2
   //append blank

   _idpartner:=""
   _VPC:=0
   _GKolicina:=_GKolicin2:=0
   _Marza2:=0; _TMarza2:="A"
    private cOsn:="2",nStCj:=nNCJ:=0

    nStCj:=nMPC

    nNCJ:=pripr->MPCSaPP

    _MPCSaPP:=nNCj-nStCj
    _MPC:=0
    _fcj:=nStCj

    if _mpc<>0
      _MPCSaPP:=(1+TARIFA->Opp/100)*_MPC*(1+TARIFA->PPP/100)
    else
      _mpc:=_mpcsapp/(1+TARIFA->Opp/100)/(1+TARIFA->PPP/100)
    endif

    if cPromCj=="D"
     select koncij; seek trim(_idkonto)
     select roba
     StaviMPCSif(_fcj+_mpcsapp)
    endif
    select pripr2

    _PKonto:=_Idkonto;_PU_I:="3"     // nivelacija
    _MKonto:="";      _MU_I:=""

    _kolicina:=nKolS
    _brdok:=cBrniv
    _idvd:="19"

    _TBankTr:="X"    // izgenerisani dokument
    _ERROR:=""
    if round(_kolicina,3)<>0
     append ncnl
     _rbr:=str(++nRbr,3)
     gather2()
    endif
  endif

  select pripr;  skip

enddo
closeret
return
*}


