#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/prod/db/1g/ut.prg,v $
 * $Author: mirsadsubasic $ 
 * $Revision: 1.5 $
 * $Log: ut.prg,v $
 * Revision 1.5  2003/09/29 13:26:55  mirsadsubasic
 * sredjivanje koda za poreze u ugostiteljstvu
 *
 * Revision 1.4  2003/09/20 07:37:07  mirsad
 * sredj.koda za poreze u MP
 *
 * Revision 1.3  2003/07/18 07:24:54  mirsad
 * stavio u f-ju kontrolu stanja za varijantu po narudzbama za izlazne dokumente (14,41,42)
 *
 * Revision 1.2  2002/06/20 14:03:09  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/prod/db/1g/ut.prg
 *  \brief Razne funkcije
 */


/*! \fn Marza2(fMarza)
 *  \brief Postavi _Marza2, _mpc, _mpcsapp
 */

function Marza2(fMarza)
*{
local nPrevMP, nPPP

if fMarza==nil
	fMarza:=" "
endif

if roba->tip=="K"  // samo za tip k
	nPPP:=1/(1+tarifa->opp/100)
else
	nPPP:=1
endif

// ako je prevoz u MP rasporedjen uzmi ga u obzir
if _TPrevoz=="A"
	nPrevMP:=_Prevoz
else
	nPrevMP:=0
endif

if _fcj==0
	_fcj:=_mpc
endif

if  _Marza2==0 .and. empty(fmarza)
	nMarza2:=_MPC-_VPC*nPPP-nPrevMP
	if _TMarza2=="%"
		if round(_vpc,5)<>0
			_Marza2:=100*(_MPC/(_VPC*nPPP+nPrevMP)-1)
		else
			_Marza2:=0
		endif
	elseif _TMarza2=="A"
		_Marza2:=nMarza2
	elseif _TMarza2=="U"
		_Marza2:=nMarza2*(_Kolicina)
	endif

elseif _MPC==0 .or. !empty(fMarza)
	if _TMarza2=="%"
		nMarza2:=_Marza2/100*(_VPC*nPPP+nPrevMP)
	elseif _TMarza2=="A"
		nMarza2:=_Marza2
	elseif _TMarza2=="U"
		nMarza2:=_Marza2/(_Kolicina)
	endif
	_MPC:=round(nMarza2+_VPC,2)
	if !empty(fMarza)
		if roba->tip=="V"
			_mpcsapp:=round(_mpc*(1+TARIFA->PPP/100),2)
		elseif roba->tip="X"
			// ne diraj _mpcsapp
		else
			_mpcsapp:=round(MpcSaPor(_mpc,aPorezi),2)
		endif
	endif

else
	nMarza2:=_MPC-_VPC*nPPP-nPrevMP
endif

AEVAL(GetList,{|o| o:display()})
return
*}




/*! \fn Marza2R()
 *  \brief Marza2 pri realizaciji prodavnice je MPC-NC
 */

function Marza2R()
*{
local nPPP

nPPP:=1/(1+tarifa->opp/100)

if _nc==0
   _nc:=_mpc
endif

if  _Marza2==0
  nMarza2:=_MPC-_NC
  if roba->tip=="V"
    nMarza2:=(_MPC-roba->VPC)+roba->vpc*nPPP-_NC
  endif

  if _TMarza2=="%"
    _Marza2:=100*(_MPC/_NC-1)
  elseif _TMarza2=="A"
    _Marza2:=nMarza2
  elseif _TMarza2=="U"
    _Marza2:=nMarza2*(_Kolicina)
  endif
elseif _MPC==0
  if _TMarza2=="%"
     nMarza2:=_Marza2/100*_NC
  elseif _TMarza2=="A"
     nMarza2:=_Marza2
  elseif _TMarza2=="U"
     nMarza2:=_Marza2/(_Kolicina)
  endif
  _MPC:=nMarza2+_NC
else
 nMarza2:=_MPC-_NC
endif
AEVAL(GetList,{|o| o:display()})
return
*}




/*! \fn FaktMPC(nMPC,cseek,dDatum)
 *  \brief Fakticka maloprodajna cijena
 */

function FaktMPC(nMPC,cseek,dDatum)
*{
local nOrder
  nMPC:=UzmiMPCSif()
  select kalk
  PushWa()
  set filter to
  //nOrder:=indexord()
  set order to 4 //idFirma+pkonto+idroba+dtos(datdok)
  seek cseek+"X"
  skip -1
  do while !bof() .and. idfirma+pkonto+idroba==cseek
    if dDatum<>NIL .and. dDatum<datdok
       skip -1; loop
    endif
    if idvd $ "11#80#81"
      nMPC:=mpcsapp
      exit
    elseif idvd=="19"
      nMPC:=fcj+mpcsapp
      exit
    endif
    skip -1
  enddo
  PopWa()
  //dbsetorder(nOrder)
return
*}




/*! \fn UzmiMPCSif()
 *  \brief
 */

function UzmiMPCSif()
*{
 LOCAL nCV:=0
  if koncij->naz=="M2" .and. roba->(fieldpos("mpc2"))<>0
    nCV:=roba->mpc2
  elseif koncij->naz=="M3" .and. roba->(fieldpos("mpc3"))<>0
    nCV:=roba->mpc3
  elseif koncij->naz=="M4" .and. roba->(fieldpos("mpc4"))<>0
    nCV:=roba->mpc4
  elseif koncij->naz=="M5" .and. roba->(fieldpos("mpc5"))<>0
    nCV:=roba->mpc5
  elseif koncij->naz=="M6" .and. roba->(fieldpos("mpc6"))<>0
    nCV:=roba->mpc6
  elseif roba->(fieldpos("mpc"))<>0
    nCV:=roba->mpc
  endif
return nCV
*}




/*! \fn StaviMPCSif(nCijena,lUpit)
 *  \brief
 */

function StaviMPCSif(nCijena,lUpit)
*{
 IF lUpit==NIL; lUpit:=.f.; ENDIF
 if koncij->naz=="M2" .and. roba->(fieldpos("mpc2"))<>0
   IF lUpit
     if roba->mpc2==0
      if Pitanje(,"Staviti MPC2 u sifrarnik ?","D")=="D"
        select roba
        replace mpc2 with nCijena
      endif
     endif
   ELSE
     replace mpc2 with nCijena
   ENDIF
 elseif koncij->naz=="M3" .and. roba->(fieldpos("mpc3"))<>0
   IF lUpit
     if roba->mpc3==0
      if Pitanje(,"Staviti MPC3 u sifrarnik ?","D")=="D"
        select roba
        replace mpc3 with nCijena
      endif
     endif
   ELSE
     replace mpc3 with nCijena
   ENDIF
 elseif koncij->naz=="M4" .and. roba->(fieldpos("mpc4"))<>0
   IF lUpit
     if roba->mpc4==0
      if Pitanje(,"Staviti MPC4 u sifrarnik ?","D")=="D"
        select roba
        replace mpc4 with nCijena
      endif
     endif
   ELSE
     replace mpc4 with nCijena
   ENDIF
 elseif koncij->naz=="M5" .and. roba->(fieldpos("mpc5"))<>0
   IF lUpit
     if roba->mpc5==0
      if Pitanje(,"Staviti MPC5 u sifrarnik ?","D")=="D"
        select roba
        replace mpc5 with nCijena
      endif
     endif
   ELSE
     replace mpc5 with nCijena
   ENDIF
 elseif koncij->naz=="M6" .and. roba->(fieldpos("mpc6"))<>0
   IF lUpit
     if roba->mpc6==0
      if Pitanje(,"Staviti MPC6 u sifrarnik ?","D")=="D"
        select roba
        replace mpc6 with nCijena
      endif
     endif
   ELSE
     replace mpc6 with nCijena
   ENDIF
 elseif roba->(fieldpos("mpc"))<>0
   IF lUpit
     if roba->mpc==0
      if Pitanje(,"Staviti MPC u sifrarnik ?","D")=="D"
        select roba
        replace mpc with nCijena
      endif
     endif
   ELSE
     replace mpc with nCijena
   ENDIF
 endif
return nil
*}




/*! \fn V_KolPro()
 *  \brief
 */

function V_KolPro()
*{
local ppKolicina

if empty(gMetodaNC) .or. _TBankTr=="X" // .or. lPoNarudzbi
	return .t.
endif  // bez ograde

if roba->tip $ "UTY"; return .t. ; endif

ppKolicina:=_Kolicina
if _idvd=="11"
  ppKolicina:=abs(_Kolicina)
endif

if nKolS<ppKolicina
     Beep(2);clear typeahead
     Msg("U prodavnici je samo"+str(nKolS,10,3)+" robe !!",6)
     _ERROR:="1"
endif
return .t.
*}




/*! \fn StanjeProd(cKljuc,ddatdok)
 *  \brief
 */

function StanjeProd(cKljuc,ddatdok)
*{
 LOCAL nUlaz:=0, nIzlaz:=0
 SELECT KALK
 SET ORDER TO 4
 GO TOP
 SEEK cKljuc
 DO WHILE !EOF() .and. cKljuc==idfirma+pkonto+idroba
   if ddatdok<datdok  // preskoci
       skip; loop
   endif
   if roba->tip $ "UT"
       skip; loop
   endif

   if pu_i=="1"
     nUlaz+=kolicina-GKolicina-GKolicin2

   elseif pu_i=="5"  .and. !(idvd $ "12#13#22")
     nIzlaz+=kolicina

   elseif pu_i=="5"  .and. (idvd $ "12#13#22")    // povrat
     nUlaz-=kolicina

   elseif pu_i=="I"
     nIzlaz+=gkolicin2
   endif

   SKIP 1
 ENDDO
return (nUlaz-nIzlaz)
*}

