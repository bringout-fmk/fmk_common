#include "\cl\sigma\fmk\kalk\kalk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/prod/dok/1g/frm_all.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.12 $
 * $Log: frm_all.prg,v $
 * Revision 1.12  2003/09/20 07:37:07  mirsad
 * sredj.koda za poreze u MP
 *
 * Revision 1.11  2003/02/10 02:19:01  mirsad
 * no message
 *
 * Revision 1.10  2002/12/30 01:34:44  mirsad
 * ispravke bugova-Planika
 *
 * Revision 1.9  2002/12/26 16:08:07  mirsad
 * no message
 *
 * Revision 1.8  2002/12/19 09:32:42  mirsad
 * nova opcija u meniju ost.opcije/2 (F11) "3. pretvori maloprod.popust u smanjenje MPC"
 *
 * Revision 1.7  2002/10/17 14:37:31  mirsad
 * nova opcija prenosa dokumenata: FAKT11->KALK42
 * dorada za Vindiju (sa rabatom u MP)
 *
 * Revision 1.6  2002/08/02 13:40:58  mirsad
 * za Jerry: da se i pri promjeni artikla u ispravci stavke osvjezi sifra tarife
 *
 * Revision 1.5  2002/07/18 14:05:40  mirsad
 * izolovanje specifiènosti pomoæu IsJerry()
 *
 * Revision 1.4  2002/07/08 23:03:54  ernad
 *
 *
 * trgomarket debug dok 80, 81, izvjestaj lager lista magacin po proizv. kriteriju
 *
 * Revision 1.3  2002/06/20 14:03:09  mirsad
 * dokumentovanje
 *
 * Revision 1.2  2002/06/19 19:48:40  ernad
 *
 *
 * ciscenje
 *
 *
 */
 

/*! \file fmk/kalk/prod/dok/1g/frm_all.prg
 *  \brief Funkcije koje se koriste pri unosu svih dokumenata u maloprodaji
 */


/*! \fn VRoba(lSay)
 *  \brief Setuje tarifu i poreze na osnovu sifrarnika robe i tarifa
 */

function VRoba(lSay)
*{
P_Roba(@_IdRoba)

if lSay==NIL
	lSay:=.t.
endif

if lSay
	Reci(11,23,trim(roba->naz)+" ("+ROBA->jmj+")",40)
endif

if fNovi .or. IsJerry() .or. IsPlanika()
	// nadji odgovarajucu tarifu regiona
	cTarifa:=Tarifa(_IdKonto,_IdRoba,@aPorezi)
else
	// za postojece dokumente uzmi u obzir unesenu tarifu
	SELECT TARIFA
	seek _IdTarifa
	SetAPorezi(@aPorezi)
endif

if fNovi .or. (gVodiSamoTarife=="D") .or. IsJerry() .or. IsPlanika()
	_IdTarifa:=cTarifa
endif

return .t.
*}


/*! \fn WMpc(fRealizacija,fMarza)
 *  \brief When blok za unos MPC
 *  \param fRealizacija -
 *  \param fMarza -
 */

function WMpc(fRealizacija, fMarza)
*{
if fRealizacija==nil
	fRealizacija:=.f.
endif

if fRealizacija
	fMarza:=" "
endif

if _mpcsapp<>0
	_marza2:=0
	_mpc:=MpcBezPor(_mpcsapp, aPorezi, , _nc)
endif

if fRealizacija
	if (_idvd=="47" .and. !(IsJerry().and._idvd="4"))
		_nc:=_mpc
	endif
endif

return .t.
*}




/*! \fn VMpc(fRealizacija,fMarza)
 *  \brief Valid blok za unos MPC
 *  \param fRealizacija -
 *  \param fMarza -
 */

function VMpc(fRealizacija, fMarza)
*{
if fRealizacija==NIL
	fRealizacija:=.f.
endif

if fRealizacija
	fMarza:=" "
endif

if fMarza==NIL 
	fMarza:=" "
endif

Marza2(fMarza)

if _mpcsapp==0
	_MPCSaPP:=round(MpcSaPor(_mpc, aPorezi),2)
endif
return .t.
*}




/*! \fn VMpcSaPP(fRealizacija,fMarza)
 *  \brief Valid blok za unos MpcSaPP
 *  \param fRealizacija -
 *  \param fMarza -
 */

function VMpcSaPP(fRealizacija,fMarza)
*{
local nRabat

if fRealizacija==NIL
	fRealizacija:=.f.
endif

if fRealizacija
	nRabat:=_rabatv
else
	nRabat:=0
endif

if fMarza==NIL 
	fMarza:=" "
endif

if _mpcsapp<>0 .and. empty(fMarza)
	_mpc:=MpcBezPor(_mpcsapp, aPorezi, nRabat, _nc)
	_marza2:=0
	if fRealizacija
		Marza2R()
	else  
		Marza2()
	endif
	ShowGets()

	if fRealizacija
		DuplRoba()
	endif
endif

fMarza:=" "
return .t.
*}




/*! \fn SayPorezi(nRow)
 *  \brief Ispisuje poreze
 *  \param nRow - relativna kooordinata reda u kojem se ispisuju porezi
 */

function SayPorezi(nRow)
*{
@ m_x+nRow,m_y+2  SAY "PPP (%):"
@ row(),col()+2 SAY  aPorezi[POR_PPP] PICTURE "99.99"

@ m_x+nRow,col()+8  SAY "PPU (%):"
@ row(),col()+2  SAY PrPPUMP() PICTURE "99.99"

@ m_x+nRow,col()+8  SAY "PP (%):"
@ row(),col()+2  SAY aPorezi[POR_PP] PICTURE "99.99"
return
*}




/*! \fn FillIzgStavke(pIzgStavke)
 *  \brief Puni polja izgenerisane stavke
 *  \param pIzgStavke - .f. ne puni, .t. puni
 */

function FillIzgStavke(pIzgStavke)
*{
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

return
*}



/*! \fn VRoba_lv(fNovi, aPorezi)
 *  \brief Setuje tarifu i poreze na osnovu sifrarnika robe i tarifa
 *  \note koristi lokalne varijable
 */

function VRoba_lv(fNovi, aPorezi)
*{
P_Roba(@_IdRoba)
Reci(11,23,trim(roba->naz)+" ("+ROBA->jmj+")",40)

if fNovi .or. IsJerry()
  // nadji odgovarajucu tarifu regiona
  cTarifa:=Tarifa(_IdKonto,_IdRoba,@aPorezi)
else
  // za postojece dokumente uzmi u obzir unesenu tarifu
  SELECT TARIFA
  seek _IdTarifa
  SetAPorezi(@aPorezi)
endif

if fNovi .or. (gVodiSamoTarife=="D") .or. IsJerry()
   _IdTarifa:=cTarifa
endif
return .t.
*}



/*! \fn WMpc_lv(fRealizacija, fMarza, aPorezi)
 *  \brief When blok za unos MPC
 *  \param fRealizacija -
 *  \param fMarza -
 *  \note koriste se lokalne varijable
 */

function WMpc_lv(fRealizacija, fMarza, aPorezi)
*{
if fRealizacija==nil
  fRealizacija:=.f.
endif

if fRealizacija
   fMarza:=" "
endif

if _mpcsapp<>0
  _marza2:=0
  _mpc:=MpcBezPor(_mpcsapp, aPorezi, , _nc)
endif

if fRealizacija
  if (_idvd=="47" .and. !(IsJerry().and._idvd="4"))
     _nc:=_mpc
  endif
endif

return .t.
*}




/*! \fn VMpc_lv(fRealizacija, fMarza, aPorezi)
 *  \brief Valid blok za unos MPC
 *  \param fRealizacija -
 *  \param fMarza -
 *  \note koriste se lokalne varijable
 */

function VMpc_lv(fRealizacija, fMarza, aPorezi)
*{
if fRealizacija==NIL
  fRealizacija:=.f.
endif
if fRealizacija
  fMarza:=" "
endif
if fMarza==NIL 
  fMarza:=" "
endif

Marza2(fMarza)
if _mpcsapp==0
 _MPCSaPP:=round(MpcSaPor(_mpc, aPorezi),2)
endif
return .t.
*}


/*! \fn VMpcSaPP_lv(fRealizacija, fMarza, aPorezi)
 *  \brief Valid blok za unos MpcSaPP
 *  \param fRealizacija -
 *  \param fMarza -
 *  \note koriste se lokalne varijable
 */

function VMpcSaPP_lv(fRealizacija, fMarza, aPorezi)
*{
local nPom

if fRealizacija==NIL
  fRealizacija:=.f.
endif
if fRealizacija
   nPom:=_mpcsapp - _rabatv
else
   nPom:=_mpcsapp
endif

if fMarza==NIL 
  fMarza:=" "
endif
altd()
if _mpcsapp<>0 .and. empty(fMarza)
  _mpc:=MpcBezPor(nPom, aPorezi, , _nc)
  _marza2:=0
  if fRealizacija
    Marza2R()
  else  
    Marza2()
  endif
  ShowGets()

  if fRealizacija
     DuplRoba()
  endif
endif

fMarza:=" "
return .t.
*}


/*! \fn SayPorezi_lv(nRow, aPorezi)
 *  \brief Ispisuje poreze
 *  \param nRow - relativna kooordinata reda u kojem se ispisuju porezi
 *  \aPorezi - koristi lokalne varijable
 */

function SayPorezi_lv(nRow, aPorezi)
*{
@ m_x+nRow,m_y+2  SAY "PPP (%):"
@ row(),col()+2 SAY  aPorezi[POR_PPP] PICTURE "99.99"

@ m_x+nRow,col()+8  SAY "PPU (%):"
@ row(),col()+2  SAY PrPPUMP() PICTURE "99.99"

@ m_x+nRow,col()+8  SAY "PP (%):"
@ row(),col()+2  SAY aPorezi[POR_PP] PICTURE "99.99"
return
*}


