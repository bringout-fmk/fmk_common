#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/dok/1g/vknjiz.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.11 $
 * $Log: vknjiz.prg,v $
 * Revision 1.11  2003/12/10 11:57:59  sasavranic
 * no message
 *
 * Revision 1.10  2003/09/26 11:16:17  mirsadsubasic
 * debug: vratio u f-ju parametar za korištenje VPC
 *
 * Revision 1.9  2003/09/12 09:35:21  ernad
 * omoguceno biranje i VPC po RJ
 *
 * Revision 1.8  2003/08/21 08:12:08  mirsad
 * Specif.za Niagaru: - ukinuo setovanje mpc u sifr. pri unosu 13-ke, a uveo setovanje mpc u sifr. pri unosu 01-ice
 *
 * Revision 1.7  2003/04/25 10:44:36  ernad
 * ispravka za Planiku: parametar Cijena13MPC=D vise ne setuje MPC u sifrarniku pri promjeni cijene u unosu 13-ke
 *
 * Revision 1.6  2003/02/27 01:27:30  mirsad
 * male dorade za zips
 *
 * Revision 1.5  2002/07/08 08:27:47  ernad
 *
 *
 * debug - uzimanje teksta na kraju fakture
 *
 * Revision 1.4  2002/07/05 14:04:52  mirsad
 * no message
 *
 * Revision 1.3  2002/07/04 08:34:19  mirsad
 * dokumentovanje ini parametara
 *
 * Revision 1.2  2002/06/18 13:01:05  sasa
 * no message
 *
 * Revision 1.1.1.1  2002/06/17 18:30:18  ernad
 * no message
 *
 *
 */

/*! \file fmk/fakt/dok/1g/vknjiz.prg
 *  \brief
 */
 

/*! \ingroup ini
  * \var *string FmkIni_KumPath_PoljeZaNazivPartneraUDokumentu_Prosiriti
  * \brief Odredjuje da li ce se prosiriti polje za unos naziva partnera u dokumentu sa 30 na 60 znakova
  * \param N - ne, default vrijednost
  * \param D - da, prosiri na 60 znakova
  */
*string FmkIni_KumPath_PoljeZaNazivPartneraUDokumentu_Prosiriti;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_FAKT_NaslovPartnTelefon
  * \brief Odredjuje da li ce se u naziv partnera u dokumentu ubacivati telefon partnera ukoliko se partner unosi preko sifre
  * \param D - da, default vrijednost
  * \param N - ne ubacuj telefon partnera
  */
*string FmkIni_ExePath_FAKT_NaslovPartnTelefon;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_FAKT_NaslovPartnPTT
  * \brief Odredjuje da li ce se u naziv partnera u dokumentu ubacivati ptt broj i mjesto partnera ukoliko se partner unosi preko sifre
  * \param D - da, default vrijednost
  * \param N - ne ubacuj ptt i mjesto partnera
  */
*string FmkIni_ExePath_FAKT_NaslovPartnPTT;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_19KaoRacunParticipacije
  * \brief Odredjuje da li ce se dokument 19 koristiti kao racun participacije
  * \param N - ne, default vrijednost
  * \param D - da, 19-ka se koristi kao racun participacije
  */
*string FmkIni_KumPath_FAKT_19KaoRacunParticipacije;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_Cijena13MPC
  * \brief Odredjuje da li ce se u 13-ki pohranjivati MPC bez obzira na sve ostale parametre
  * \param N - ne, default vrijednost
  * \param D - da, u 13-ki se pohranjuju MPC cijene
  */
*string FmkIni_KumPath_FAKT_Cijena13MPC;



/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_ZaokruzenjeMPCuDiskontu
  * \brief Odredjuje na koju ce decimalu biti zaokruzena cijena u diskontnoj prodaji
  * \param 1 - na prvu decimalu, default vrijednost
  */
*string FmkIni_KumPath_FAKT_ZaokruzenjeMPCuDiskontu;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_NemaIzlazaBezUlaza
  * \brief Omogucava zabranu pravljenja dokumenata koji bi stanje robe doveli u minus
  * \param N - default vrijednost
  * \param D - zabrani pravljenje dokumenta koji "tjera robu u minus"
  */
*string FmkIni_KumPath_FAKT_NemaIzlazaBezUlaza;


/*! \ingroup Vindija
  * \var *string FmkIni_KumPath_FAKT_TXTIzjaveZaObracunPoreza
  * \brief Predvidjeno za navodjenje sifara FAKT txt-ova koje znace da se obracunava porez na promet proizvoda
  * \param ; - nijedna ne znaci da se obracunava porez, default vrijednost
  * \param 01,02 - sifre izjava 01 i 02 znace da se obracunava porez
  */
*string FmkIni_KumPath_FAKT_TXTIzjaveZaObracunPoreza;


/*! \ingroup ini
  * \var *string FmkIni_SifPath_Barkod_ENTERXY
  * \brief Broj entera koji se automatski ukucaju nakon ocitanja bar koda u editu dokumenta tipa XY
  * \param 0 - nijedan enter, default vrijednost
  */
*string FmkIni_SifPath_Barkod_ENTERXY;



/*! \fn IzSifre(fSilent)
 *  \brief 
 *  \param fSilent
 */
 
function IzSifre(fSilent)
*{
local nPos,cSif:=trim(_txt3a),cPom,fTel

if fSilent==NIL
  fSilent:=.f.
endif

fTel:=.f.
if right(cSif,1)="." .and. len(csif)<=7
   nPos:=RAT(".",cSif)
   cSif:=left(cSif,nPos-1)
   if !fsilent
     P_Firma(padr(cSif,6))
   endif
//   if IzFMkIni('FAKT',"IdPartnNaF",'N',KUMPATH)=="D" .or.;
   if lSpecifZips
     _Txt3a:=TRIM(partn->id)+"- "+TRIM(partn->naz)+" "+trim(partn->naz2)
   else
     IF IzFMKINI("PoljeZaNazivPartneraUDokumentu","Prosiriti","N",KUMPATH)=="D"
       _Txt3a:=padr(partn->naz,60)
     ELSE
       _Txt3a:=padr(partn->naz,30)
     ENDIF
   endif
   _txt3b:=trim(partn->adresa)
   cPom:=""
   if !empty(partn->telefon) .and. IzFmkIni('FAKT','NaslovPartnTelefon','D')=="D"
      cPom:=_txt3b+", Tel:"+trim(partn->telefon)
   else
      fTel:=.t.
   endif
   if !empty(cPom) .and. len(cPom)<=30
      _txt3b:=cPom
      ftel:=.t.
   endif
   if !empty(partn->ptt)
     if IzFmkIni('FAKT','NaslovPartnPTT','D')=="D"
        _txt3c:=trim(partn->ptt)+" "+trim(partn->mjesto)
     endif
   else
     _txt3c:=trim(partn->mjesto)
   endif

   if !ftel
       if IzFmkIni('FAKT','NaslovPartnTelefon','D')=="D"
          _txt3c:=_txt3c+", Tel:"+trim(partn->telefon)
       endif
   endif

   _txt3b:=padr(_txt3b,30)
   _txt3c:=padr(_txt3c,30)
   _IdPartner:=partn->id
endif
return  .t.
*}



/*! \fn V_Rj()
 *  \brief 
 */
 
function V_Rj ()
*{
IF gDetPromRj == "D" .and. gFirma <> _IdFirma
    Beep (3)
    Msg ("Mijenjate radnu jedinicu!!!#")
  EndIF
return .t.
*}


/*! \fn V_PodBr()
 *  \brief
 */
 
function V_Podbr()
*{
local fRet:=.f.,nTRec,nPrec,nPkolicina:=1,nPRabat:=0
private GetList:={}
if (left(_podbr,1) $ " .0123456789") .and. (right(_podbr,1) $ " .0123456789")
  fRet:=.t.
endif

if val(_podbr)>0; _podbr:= str(val(_podbr),2); endif
if alltrim(_podbr)=="."
  _podbr:=" ."
  cPRoba:=""  // proizvod sifra
  nPKolicina:=_kolicina
  _idroba:=space(len(_idroba))
  Box(,5,50)
    @ m_x+1,m_y+2 SAY "Proizvod:" GET _idroba valid {|| empty(_idroba) .or. P_roba(@_idroba)} pict "@!"
    read
    if !empty(_idroba)
       @ m_x+3,m_y+2 SAY "kolicina        :" GET nPkolicina pict pickol
       @ m_x+4,m_y+2 SAY "rabat %         :" GET nPRabat    pict "999.999"
       @ m_x+5,m_y+2 SAY "Varijanta cijene:" GET cTipVPC
       read
    endif
  BoxC()
  // idemo na sastavnicu
  if !empty(_idroba)
   _txt1:=padr(roba->naz,40)
   nTRec:=recno()
   go top
   nTRbr:=nRbr
   do while !eof()
     skip; nPRec:=recno(); skip -1
     if nTrbr==val(rbr) .and. alltrim(podbr)<>"."
       // pobrisi stare zapise
       delete
     endif
     go nPrec
   enddo
   // nafiluj iz sastavnice
   select sast
   cPRoba:=_idroba
   cptxt1:=_txt1
   seek cPRoba
   nPbr:=0
   do while !eof() .and. cPRoba==id
     select roba
     hseek sast->id2  // pozicioniraj se na materijal
     select pripr
     append ncnl
     _rbr:=str(nTrbr,3)
     _podbr:=str(++npbr,2)
     _idroba:=sast->id2
     _kolicina:=sast->kolicina*npkolicina
     _rabat:=nPRabat
     SetujCijenu()

     if roba->tip=="U"
       _txt1:=trim(roba->naz)
     else
       _txt1:=""
     endif
     if _podbr==" ." .or.  roba->tip="U"
         _txt:=Chr(16)+trim(_txt1)+Chr(17) + Chr(16)+_txt2+Chr(17)+;
           Chr(16)+trim(_txt3a)+Chr(17) + Chr(16)+_txt3b+Chr(17)+;
           Chr(16)+trim(_txt3c)+Chr(17) +;
           Chr(16)+_BrOtp+Chr(17) +;
           Chr(16)+dtoc(_DatOtp)+Chr(17) +;
           Chr(16)+_BrNar+Chr(17) +;
           Chr(16)+dtoc(_DatPl)+Chr(17)
     endif
     Gather()
     select sast
     skip
   enddo
   select pripr
   go nTRec
   _podbr:=" ."
   _cijena:=0
   _idroba:=cPRoba
   _kolicina:=npkolicina
   _txt1:=cptxt1
  endif
  _txt1:=padr(_txt1,40)
  _porez:=_rabat:=0
  if empty(cPRoba)
   _idroba:=""
   _Cijena:=0
  endif
  _SerBr:=""
endif
return fRet
*}

/*! \fn SetujCijenu()
 *  \brief postavi _cijena
 */
 
function SetujCijenu()
*{
LOCAL lRJ:=.f.

select (F_RJ)
IF USED()
  lRJ:=.t.
  hseek _idfirma
ENDIF
select  roba

if _idtipdok=="13" .and. ( gVar13=="2" .or. glCij13Mpc ) .or. _idtipdok=="19" .and. IzFMKIni("FAKT","19KaoRacunParticipacije","N",KUMPATH)=="D" .or. _idtipdok=="01" .and. IsNiagara()
  IF g13dcij=="6"
    _cijena:=MPC6
  ELSEIF g13dcij=="5"
    _cijena:=MPC5
  ELSEIF g13dcij=="4"
    _cijena:=MPC4
  ELSEIF g13dcij=="3"
    _cijena:=MPC3
  ELSEIF g13dcij=="2"
    _cijena:=MPC2
  ELSE
    _cijena:=MPC
  ENDIF
elseif lRJ .and. rj->tip="M"  // baratamo samo sa mp.cijenama
   _cijena:=UzmiMPCsif()

elseif _idtipdok$"11#15#27"
  // ako je na RJ->tip stavljeno M1 - maloprodajne cijene
  // magacin barata sa mpc cijenama
  if gMP=="1"
    _Cijena:=MPC
  elseif gMP=="2"
    _Cijena:=round(VPC * (1+ tarifa->opp/100) * (1+tarifa->ppp/100),;
                   VAL(IzFMKIni("FAKT","ZaokruzenjeMPCuDiskontu","1",KUMPATH)))
  elseif gMP=="3"
    _Cijena:=MPC2
  elseif gMP=="4"
    _Cijena:=MPC3
  elseif gMP=="5"
    _Cijena:=MPC4
  elseif gMP=="6"
    _Cijena:=MPC5
  elseif gMP=="7"
    _Cijena:=MPC6
  endif
else
  if cTipVPC=="1"
    _Cijena:=vpc
  elseif fieldpos("vpc2")<>0
   if gVarC=="1"
     _Cijena:=vpc2
   elseif gVarc=="2"
     _Cijena:=vpc
     if vpc<>0; _Rabat:= (vpc-vpc2) / vpc * 100; endif
   elseif gVarc=="3"
     _Cijena:=nc
   endif
  else
    _Cijena:=0
  endif
endif

select pripr
return
*}



/*! \fn V_Kolicina()
 *  \brief
 */
 
function V_Kolicina()
*{
local cRjTip
local nUl:=nIzl:=0
local nRezerv:=nRevers:=0

if _kolicina==0
	return .f.
endif

if JeStorno10()
  _kolicina := - ABS(_kolicina)
endif

if _podbr<>" ."
	select RJ
	hseek _idfirma
	cRjTip:=rj->tip
  	IF gVarNum=="1" .and. gVar13=="2" .and. _idtipdok=="13"
    		hseek RJIzKonta(_idpartner+" ")
  	ENDIF

	NSRNPIdRoba(_IDROBA)
  	select ROBA
if !(roba->tip="U")  // usluge ne diraj
  	if _idtipdok=="13".and.(gVar13=="2".or.glCij13Mpc).and.gVarNum=="1" .or. _idtipdok=="01" .and. IsNiagara()
      		if gVar13=="2" .and. _idtipdok=="13"
        		_cijena := UzmiMPCSif()
      		else
        		if g13dcij=="6"
          			_cijena:=MPC6
        		elseif g13dcij=="5"
          			_cijena:=MPC5
        		elseif g13dcij=="4"
          			_cijena:=MPC4
        		elseif g13dcij=="3"
          			_cijena:=MPC3
        		elseif g13dcij=="2"
          			_cijena:=MPC2
        		else
          			_cijena:=MPC
        		endif
      		endif
    	elseif _idtipdok=="13".and.(gVar13=="2".or.glCij13Mpc).and.gVarNum=="2" .or. _idtipdok=="19".and.IzFMKIni("FAKT","19KaoRacunParticipacije","N",KUMPATH)=="D"
      		if g13dcij=="6"
        		_cijena:=MPC6
      		elseif g13dcij=="5"
        		_cijena:=MPC5
      		ELSEIF g13dcij=="4"
       			_cijena:=MPC4
      		ELSEIF g13dcij=="3"
        		_cijena:=MPC3
      		ELSEIF g13dcij=="2"
        		_cijena:=MPC2
      		else
        		_cijena:=MPC
      		endif
    	elseif cRjtip="M"
       		_cijena:=UzmiMPCSif()
    	elseif _idtipdok$"11#15#27"
      		if gMP=="1"
        		_Cijena:=MPC
      		elseif gMP=="2"
        		_Cijena:=round(VPC * (1+ tarifa->opp/100) * (1+tarifa->ppp/100),VAL(IzFMKIni("FAKT","ZaokruzenjeMPCuDiskontu","1",KUMPATH)))
      		elseif gMP=="3"
        		_Cijena:=MPC2
      		elseif gMP=="4"
        		_Cijena:=MPC3
      		elseif gMP=="5"
        		_Cijena:=MPC4
      		elseif gMP=="6"
        		_Cijena:=MPC5
      		elseif gMP=="7"
        		_Cijena:=MPC6
      		endif
    	elseif _idtipdok=="25" .and. _cijena<>0
      	// za knji§nu obavijest: ne dirati cijenu ako je ve† odreÐena
    	elseif cRjTip="V".and._idTipDok $ "10#20" //ako se radi o racunima i predracunima
		_cijena:=UzmiVPCSif()
	else
      		if cTipVPC=="1"
        		_Cijena:=vpc
      		elseif fieldpos("vpc2")<>0
       			if gVarC=="1"
         			_Cijena:=vpc2
       			elseif gVarc=="2"
         			_Cijena:=vpc
         			if vpc<>0
					_Rabat:= (vpc-vpc2) / vpc * 100
				endif
       			elseif gVarc=="3"
         			_Cijena:=nc
       			endif
      		else
        		_Cijena:=0
      		endif
    	endif
endif

if _DINDEM==left(ValSekund(),3)   // preracunaj u sekundarnu valutu
	_Cijena:=_Cijena/UBaznuValutu(_datdok)
endif

endif

IF lPoNarudzbi
  SELECT PRIPR
  RETURN .t.
ENDIF

select fakt; set order to 3
//"FAKTi3","idroba+dtos(datDok)","FAKT"

lBezMinusa := ( IzFMKIni("FAKT","NemaIzlazaBezUlaza","N",KUMPATH) == "D" )

if !(roba->tip="U") .and. !empty(_IdRoba) .and.  left(_idtipdok,1) $ "12"  .and. (gPratiK=="D".or.lBezMinusa) .and.;
   !(left(_idtipdok,1) == "1" .and. left(_serbr,1)="*")  // ovo je onda faktura
                                                        // na osnovu otpremnice


if gTBDir="N"
  MsgO("Izracunavam trenutno stanje ...")
endif
 seek _idroba
 nUl:=nIzl:=nRezerv:=nRevers:=0
 do while !eof()  .and. roba->id==IdRoba
   // ovdje provjeravam samo za tekucu firmu
   IF FAKT->IdFirma <> _IdFirma
     SKIP; LOOP
   EndIF
   if idtipdok="0"  // ulaz
     nUl  += kolicina
   elseif idtipdok="1"   // izlaz faktura
     if !(left(serbr,1)=="*" .and. idtipdok=="10")  // za fakture na osnovu otpremnice ne raŸunaj izlaz
       nIzl += kolicina
     endif
   elseif idtipdok$"20#27"
     if serbr="*"
       nRezerv += kolicina
     endif
   elseif idtipdok=="21"
     nRevers += kolicina
   endif
   skip
 enddo

if gTBDir="N"
  MsgC()
else
  @ m_x+17, m_y+1   SAY "Artikal: "; ?? _idRoba ; ?? "("+roba->jmj+")"
  @ m_x+18, m_y+1   SAY "Stanje :"
  @ m_x+18, col()+1 SAY nUl-nIzl-nRevers-nRezerv  picture pickol
  @ m_x+19, m_y+1   SAY "Tarifa : " ; ?? roba->idtarifa
endif

if nUl-nIzl-nRevers-nRezerv-_Kolicina<0
 // Msg("Na stanju je "+str(nUl-nIzl,12,3)+" robe")
 BoxStanje({{_IdFirma, nUl,nIzl,nRevers,nRezerv}},_idroba)
 IF _idtipdok="1" .and. lBezMinusa
   SELECT PRIPR
   RETURN .f.
 ENDIF
endif


endif //

select pripr

IF _idtipdok=="26" .and. glDistrib .and. !UGenNar()
  RETURN .f.
ENDIF

return .t.
*}



/*! \fn W_Roba()
 *  \brief
 */
 
function W_Roba()
*{
private Getlist:={}

if _podbr==" ."
     @  m_x+13,m_y+2  SAY "Roba     " get _txt1 pict "@!"
     read
     return .f.
else
     return .t.
endif
*}



/*! \fn V_Roba(lPrikTar)
 *  \brief
 *  \param lPrikTar
 */
 
function V_Roba(lPrikTar)
*{
local cPom , nArr
altd()
private cVarIDROBA
if fID_J
  cVarIDROBA:="_IDROBA_J"
else
  cVarIDROBA:="_IDROBA"
endif

IF lPrikTar==NIL; lPrikTar:=.t.; ENDIF

if right(trim(&cVarIdRoba),2)="++"
  cPom:=padr(left(&cVarIdRoba,len(trim(&cVarIdRoba))-2),len(&cVarIdRoba))
  select roba; seek cPom
  if found()
      BrowseKart(cPom)    // prelistaj kalkulacije
      &cVarIdRoba:=cPom
  endif
endif

if right(trim(&cVarIdRoba),2)="--"
  cPom:=padr(left(&cVarIdRoba,len(trim(&cVarIdRoba))-2),len(&cVarIdRoba))
  select roba; seek cPom
  if found()
      FaktStanje(roba->id)    // prelistaj kalkulacije
      &cVarIdRoba:=cPom
  endif
endif

if fId_J
 P_Roba(@ _Idroba_J)
 // proba uvijek setuje varijablu _IdRoba
 _IdRoba:= _IdRoba_J
 _IdRoba_J:=ID_J()
else
 P_Roba(@ _Idroba)
endif
select roba
if gNovine!="D"
   go SIF_TEKREC()
endif
select pripr

select tarifa
seek roba->idtarifa
IF lPrikTar
  if gTBDir=="N"
    @ m_X+14,m_y+28 SAY "TBr: "; ?? roba->idtarifa, "PPP",str(tarifa->opp,7,2)+"%","PPU",str(tarifa->ppp,7,2)
  endif
  if _IdTipdok=="13"
     @ m_X+16,m_y+45 SAY "MPC u sifraniku: "; ?? str(roba->mpc,8,2)
  endif
ENDIF

Odredi_IDROBA()

SELECT PRIPR
return .t.
*}



/*! \fn V_Porez()
 *  \brief
 */
 
function V_Porez()
*{
local nPor
if _porez<>0

  if roba->tip="U"
    nPor:=tarifa->ppp
  else
    nPor:=tarifa->opp
  endif
  if nPor<>_Porez
    Beep(2)
    Msg("Roba pripada tarifnom stavu "+roba->idtarifa+;
      "#kod koga je porez "+str(nPor,5,2)  ;
       )
  endif
endif
return .t.
*}



/*! \fn W_BrOtp(fNovi)
 *  \brief
 *  \param fNovi
 */
 
function W_BrOtp(fnovi)
*{
if fnovi
     _datotp:=_datdok;_datpl:=_datdok
  endif
return .t.
*}



/*! \fn V_Rabat()
 *  \brief
 */
 
function V_Rabat()
*{
if trabat $ " U"
  if _Cijena*_Kolicina<>0
   _rabat:=_rabat*100/(_Cijena*_Kolicina)
  else
   _rabat:=0
  endif
elseif trabat="A"
  if _Cijena<>0
   _rabat:=_rabat*100/_Cijena
  else
   _rabat:=0
  endif
elseif trabat="C" // zadata je nova cijena
  if _Cijena<>0
   _rabat:= (_cijena-_rabat)/_cijena*100
  else
   _rabat:=0
  endif
elseif trabat="I" // zadat je zeljeni iznos (kolicina*cijena)
  if _kolicina*_Cijena<>0
   _rabat:= (_kolicina*_cijena-_rabat)/(_kolicina*_cijena)*100
  else
   _rabat:=0
  endif
endif

if _Rabat>99
  Beep(2)
  Msg("Rabat ne moze biti ovoliki !!",6)
  _rabat:=0
endif
if _idtipdok$"11#15#27"
   _porez:=0
else
 if roba->tip=="V"
  _porez:=0
 endif
endif

ShowGets()
return .t.
*}




/*! \fn UzorTxt()
 *  \brief Uzorak txt fajla
 */
 
function UzorTxt()
*{
local cId

cId:="  "
if (nRbr==1 .and. val(_podbr)<1)
 Box(,9,75)
 @ m_x+1,m_Y+1  SAY "Uzorak teksta (<c-W> za kraj unosa teksta):"  GET cId pict "@!"
 read
 if lastkey()<>K_ESC .and. !empty(cId)
   P_Ftxt(@cId)
   SELECT ftxt
   SEEK cId
   SELECT pripr
   _txt2 := trim(ftxt->naz)
  select PRIPR
  IF glDistrib .and. _IdTipdok=="26"
    IF cId $ IzFMKIni("FAKT","TXTIzjaveZaObracunPoreza",";",KUMPATH)
      _k2 := "OPOR"
    ELSE
      _k2 := ""
    ENDIF
  ENDIF
 endif
 setcolor(Invert)
 UsTipke()
 private fUMemu:=.t.
 _txt2:=MemoEdit(_txt2,m_x+3,m_y+1,m_x+9,m_y+76)
 fUMemu:=NIL
 BosTipke()
 setcolor(Normal)
 BoxC()
endif
return
*}


/*! \fn GetUsl(fNovi)
 *  \brief get usluga
 *  \param fNovi
 */
 
function GetUsl(fNovi)
*{
private GetList:={}

if gTBDir="N"
if !(roba->tip="U")
 devpos(m_x+13,m_y+25)
 ?? space(40)
 devpos(m_x+13,m_y+25)

 ?? trim(roba->naz),"("+roba->jmj+")"
endif
endif

if roba->tip $ "UT" .and. fnovi
  _kolicina:=1
endif
if roba->tip=="U"
  _txt1 := PADR( IF( fNovi , ROBA->naz , _txt1 ) , 320 )
  IF fNovi
    _cijena := ROBA->vpc
    if !_idtipdok$"11#15#27"
      _porez  := TARIFA->ppp
    endif
  ENDIF
  UsTipke()
  if gTBDir=="D"
    @ row(),col()-15 GET _txt1 pict "@S40"
  else
    @ row(),m_y+25 GET _txt1 pict "@S40"
  endif
  read
  BosTipke()
  _txt1:=trim(_txt1)
else
  _txt1:=""
endif

return .t.
*}



/*! \fn Nijedupla(fNovi)
 *  \brief
 *  \param fNovi
 */
 
function NijeDupla(fNovi)
*{
local nEntBK,ibk,uEntBK
local nPrevRec 

    // ako se radi o stornu fakture -> preuzimamo rabat i porez iz fakture
    if JeStorno10()
      RabPor10()
    endif

    if gOcitBarkod .and. nRbr>1

        nEntBK:=val(IzFmkIni("Barkod","ENTER"+_IdTipdok,"0",SIFPATH))
        // otiltaj entere ako je barkod ocitan !!
        cEntBK:=""
        for ibk:=1 to nEntBK
          cEntBK+=Chr(K_ENTER)
        next
        if nEntBK>0
          KEYBOARD cEntBK
        endif

        return .t.
    endif

    SELECT PRIPR
    nPrevRec:=RECNO()
    LOCATE FOR idfirma+idtipdok+brdok+idroba==_idfirma+_idtipdok+_brdok+_idroba .and. (recno()<>nPrevrec .or. fnovi)
    IF FOUND ()
      if !(roba->tip $ "UT")
       Beep (2)
       Msg ("Roba se vec nalazi na dokumentu, stavka "+ALLTRIM (PRIPR->Rbr), 30)
      endif
    ENDIF
    GO nPrevRec
RETURN (.t.)
*}



/*! \fn OdsjPLK(cTxt)
 *  \brief Odsjeca prazne linije na kraju stringa
 *  \param cTxt
 */
 
function OdsjPLK(cTxt)
*{
local i
for i:=len(cTxt) to 1 step -1
  if !(substr(cTxt,i,1) $ Chr(13)+Chr(10)+" ")
       exit
  endif
next
return left(cTxt,i)
*}


/*! \fn ParsMemo(cTxt)
 *  \brief Struktura cTxt-a je: Chr(16) txt1 Chr(17) Chr(16) txt2 Chr(17)...
 *  \param cTxt
 *  \return aMemo
 */
 
function ParsMemo(cTxt)
*{
local aMemo:={}
local i,cPom,fPoc

 fPoc:=.f.
 cPom:=""
 for i:=1 to len(cTxt)
   if  substr(cTxt,i,1)==Chr(16)
     fPoc:=.t.
   elseif  substr(cTxt,i,1)==Chr(17)
     fPoc:=.f.
     AADD(aMemo,cPom)
     cPom:=""
   elseif fPoc
      cPom:=cPom+substr(cTxt,i,1)
   endif
 next

return aMemo
*}

// u ovoj funkciji se nalazi metoda utvrdjivanja narednog izdanja novina
/*! \fn Odredi_IdRoba()
 *  \brief U ovoj funkciji se nalazi metoda utvrdjivanja narednog izdanja novina *  \todo Prebaciti u OPRESA
 */
 
function Odredi_IdRoba()
*{
  IF gNovine=="D" .and. ROBA->tip=="S" .and. LEN(RTRIM(_idroba))<=gnDS
    SELECT FAKT
    PushWA()
    SET ORDER TO TAG "3"
    SEEK PADR(LEFT(_idroba,gnDS),10,"9")
    SKIP -1
    DO WHILE !BOF() .and. LEFT(idroba,gnDS)==LEFT(_idroba,gnDS)
      IF LEFT(IDROBA,gnDS)==LEFT(_idroba,gnDS)
        IF _idtipdok=="01"  // ulaz u skladiçte -> novi broj artikla (novina)
          IF DTOS(_datdok)>DTOS(DATDOK) .or. IDTIPDOK=="13".and.IDFIRMA=="99"
            _idroba:=LEFT(IDROBA,gnDS)+PADL(ALLTRIM(STR(VAL(RIGHT(IDROBA,10-gnDS))+1)),10-gnDS,"0")
          ELSE
            _idroba:=IDROBA
          ENDIF
          EXIT
        ELSEIF _idtipdok=="13" .and. _idpartner==IDPARTNER
          IF _idfirma=="99"  // prodavnica -> skladiçte vra†enih artikala (RJ 99)
           IF DTOS(_datdok)>DTOS(DATDOK)
             IF IDTIPDOK=="13" .and. IDFIRMA=="99"
              _idroba:=LEFT(IDROBA,gnDS)+PADL(ALLTRIM(STR(VAL(RIGHT(IDROBA,10-gnDS))+1)),10-gnDS,"0")
             ELSE
              _idroba:=IDROBA
             ENDIF
           ELSE
             IF IDTIPDOK=="13" .and. IDFIRMA=="99"
              _idroba:=IDROBA
             ELSE
              _idroba:=LEFT(IDROBA,gnDS)+PADL(ALLTRIM(STR(VAL(RIGHT(IDROBA,10-gnDS))-1)),10-gnDS,"0")
             ENDIF
           ENDIF
          ELSE               // skladiçte -> prodavnica
           _idroba:=IDROBA
          ENDIF
          exit
        ENDIF
      ENDIF
      SKIP -1
    ENDDO
    PopWA()
  ENDIF
RETURN
*}



/*! \fn Prepak(cIdRoba,cPako,nPak,nKom,nKol,lKolUPak)
 *  \brief Preracunavanje paketa i komada ...
 *  \param cIdRoba  - sifra artikla
 *  \param nPak     - broj paketa/kartona
 *  \param nKom     - broj komada u ostatku (dijelu paketa/kartona)
 *  \param nKol     - ukupan broj komada
 *  \param nKOLuPAK - .t. -> preracunaj pakete (nPak,nKom) .f. -> preracunaj komade (nKol)
 */
 
function Prepak(cIdRoba,cPako,nPak,nKom,nKol,lKolUPak)
*{
LOCAL lVrati:=.f., nArr:=SELECT(), aNaz:={}, cKar:="AMB ", nKO:=1, n_Pos:=0
  IF lKOLuPAK==NIL; lKOLuPAK:=.t.; ENDIF
  SELECT SIFV; SET ORDER TO TAG "ID"
  HSEEK "ROBA    "+cKar+PADR(cIdRoba,15)
  DO WHILE !EOF() .and.;
           id+oznaka+idsif=="ROBA    "+cKar+PADR(cIdRoba,15)
    IF !EMPTY(naz)
      AADD( aNaz , naz )
    ENDIF
    SKIP 1
  ENDDO
  IF LEN(aNaz)>0
    nOpc  := 1  // za sad ne uvodim meni
    n_Pos := AT( "_" , aNaz[nOpc] )
    cPako := "(" + ALLTRIM( LEFT( aNaz[nOpc] , n_Pos-1 ) ) + ")"
    nKO   := VAL( ALLTRIM( SUBSTR( aNaz[nOpc] , n_Pos+1 ) ) )
    IF nKO<>0
      IF lKOLuPAK
        nPak := INT(nKol/nKO)
        nKom := nKol-nPak*nKO
      ELSE
        nKol := nPak*nKO+nKom
      ENDIF
    ENDIF
    lVrati:=.t.
  ELSEIF lKOLuPAK
    nPak := 0
    nKom := nKol
  ENDIF
  SELECT (nArr)
RETURN lVrati
*}



/*! \fn UGenNar()
 *  \brief U Generalnoj Narudzbi
 */
 
function UGenNar()
*{
LOCAL lVrati:=.t., nArr:=SELECT(), nIsporuceno, nNaruceno, dNajstariji:=CTOD("")
  SELECT (F_UGOV)
  IF !USED()
    O_UGOV
  ENDIF
  SET ORDER TO TAG "1"
  HSEEK "D"+"G"+_idpartner
  IF FOUND()
    SELECT (F_RUGOV)
    IF !USED()
      O_RUGOV
    ENDIF
    SET ORDER TO TAG "ID"
    SELECT UGOV
    nNaruceno:=0
    // izracunajmo ukupnu narucenu kolicinu i utvrdimo datum najstarije
    // narudzbe
    DO WHILE !EOF() .and. aktivan+vrsta+idpartner=="D"+"G"+_idpartner
      SELECT RUGOV
      HSEEK UGOV->id+_idroba
      IF FOUND()
        IF EMPTY(dNajstariji)
          dNajstariji := UGOV->datod
        ELSE
          dNajstariji := MIN( UGOV->datod , dNajstariji )
        ENDIF
        nNaruceno += kolicina
      ENDIF
      SELECT UGOV
      SKIP 1
    ENDDO
    // izracunati dosadasnju isporuku (nIsporuceno)
    nIsporuceno:=0
    SELECT FAKT
    SET ORDER TO TAG "6"
    // sabiram sve isporuke od datuma vazenja najstarijeg ugovora do danas
    SEEK _idfirma+_idpartner+_idroba+"10"+DTOS(dNajstariji)
    DO WHILE !EOF() .and. idfirma+idpartner+idroba+idtipdok==;
                          _idfirma+_idpartner+_idroba+"10"
      nIsporuceno += kolicina
      SKIP 1
    ENDDO
    IF _kolicina+nIsporuceno > nNaruceno
      lVrati:=.f.
      MsgBeep("Kolicina: "+ALLTRIM(TRANS(_kolicina,PicKol))+". Naruceno: "+ALLTRIM(TRANS(nNaruceno,PicKol))+". Dosad isporuceno: "+ALLTRIM(TRANS(nIsporuceno,PicKol))+". #"+;
              "Za ovoliku isporuku artikla morate imati novu generalnu narudzbenicu!")
    ENDIF
  ENDIF
  SELECT (nArr)
RETURN lVrati
*}


