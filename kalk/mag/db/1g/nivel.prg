#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/mag/db/1g/nivel.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.3 $
 * $Log: nivel.prg,v $
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
 


/*! \file fmk/kalk/mag/db/1g/nivel.prg
 *  \brief Generisanje dokumenta nivelacije cijena u magacinu
 */

/*! \fn Niv_10()
 *  \brief Generisanje dokumenta nivelacije cijena u magacinu
 */

function Niv_10()
*{
local nRVPC:=0

O_KONCIJ
O_PRIPR
O_PRIPR2
O_KALK
O_TARIFA
if IzFMKIni("Svi","Sifk")=="D"
   O_SIFK;O_SIFV
endif
O_ROBA

select pripr; go top
private cIdFirma:=idfirma,cIdVD:=idvd,cBrDok:=brdok

if !(cidvd $ "14#96#95#10#94#16") .and. !empty(gMetodaNC)
  closeret
endif

if pripr->idvd $ "14#94#96#95"
 select koncij; seek trim(pripr->idkonto2)
else
 select koncij; seek trim(pripr->idkonto)
endif
if koncij->naz $ "N1#P1#P2"
   closeret
endif

private cBrNiv:="0"
select kalk
seek cidfirma+"18ä"
skip -1
if idvd<>"18"
     cBrNiv:=space(8)
else
     cBrNiv:=brdok
endif
cBrNiv:=UBrojDok(val(left(cBrNiv,5))+1,5,right(cBrNiv,3))


select pripr
go top
private nRBr:=0
fNivelacija:=.f.
cPromCj:="N"
do while !eof() .and. cidfirma==idfirma .and. cidvd==idvd .and. cbrdok==brdok

  if pripr->idvd $ "14#94#96#95"   // ako je vise konta u igri - kao 16-ka
    select koncij; seek trim(pripr->idkonto2)
  else
    select koncij; seek trim(pripr->idkonto)
  endif
  select pripr
  if koncij->naz $ "N1#P1#P2"
      skip; loop
  endif



  scatter()
  select roba; hseek _idroba
  select tarifa; hseek roba->idtarifa
  frazlika:=.f.
  nRVPC:=KoncijVPC()
  if gCijene="2"  .and. gNiv14="1"
                        // nivel.se vrsi na ukupnu kolicinu
   /////// utvrdjivanje fakticke VPC
   faktVPC(@nRVPC,_idfirma+_mkonto+_idroba)
   select pripr
  endif
  if round(_vpc,3)<>round(nRVPC,3)  // izvrsiti nivelaciju

   if !fNivelacija  .and. ; // prva stavka za nivelaciju
      !(cidvd=="14" .and. gNiv14=="2")   //minex
      cPromCj:=Pitanje(,"Postoje promjene cijena. Staviti nove cijene u sifrarnik ?","D")
   endif
   fNivelacija:=.t.

   private nKolZn:=nKols:=nc1:=nc2:=0,dDatNab:=ctod("")
   if gKolicFakt=="D"
    KalkNaF(_idroba,@nKolS) // uzmi iz FAKTA
   else
    KalkNab(_idfirma,_idroba,_mkonto,@nKolS,@nKolZN,@nc1,@nc2,@dDatNab,@_RokTr)
   endif
   if dDatNab>_DatDok; Beep(1);Msg("Datum nabavke je "+dtoc(dDatNab),4);_ERROR:="1";endif


   select pripr2
   //append blank


   _idpartner:=""
   _rabat:=prevoz:=prevoz2:=_banktr:=_spedtr:=_zavtr:=_nc:=_marza:=_marza2:=_mpc:=0
   _gkolicina:=_gkolicin2:=_mpc:=0
   _VPC:=pripr->vpc-nRVPC
   _MPCSAPP:=nRVPC
   _kolicina:=nKolS
   _brdok:=cBrniv
   _idkonto:=_mkonto
   _idkonto2:=""
   _MU_I:="3"     // ninvelacija
   _PKonto:="";      _PU_I:=""
   _idvd:="18"

   _TBankTr:="X"    // izgenerisani dokument
   _ERROR:=""
   if cIdVD $ "94" // storno fakture,storno otpreme - niveli{i na stornirano
     _kolicina:=pripr->kolicina
     _vpc:=nRVPC - pripr->vpc
     _mpcsapp:=pripr->vpc
     _MKonto:=_Idkonto
   endif
   if   (cidvd=="14" .and. gNiv14=="2")  // minex,
     _kolicina:=pripr->kolicina
     _MKonto:=_Idkonto
     if _kolicina<0 // radi se storno fakture
       _kolicina:=-_kolicina
       _vpc:=-_vpc
       _mpcsapp:=pripr->vpc
     endif

   endif
   if round(_kolicina,4)<>0
     _rbr:=str(++nRbr,3)
     append ncnl
     gather2()
   endif
   if cPromCj=="D"
    if cIdVD $ "10#16#14#96" ;  // samo ako je ulaz,izlaz u magacin promjeni stanje VPC u sif.robe
     .and. !(cidvd=="14" .and. gNiv14=="2")   // minex
     select roba         // promjeni stanje robe !!!!
     ObSetVPC(pripr->vpc)

    endif
   endif
  endif
  select pripr
  skip
enddo

closeret
return
*}

