#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/prod/dok/1g/frm_19.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.8 $
 * $Log: frm_19.prg,v $
 * Revision 1.8  2003/10/11 09:26:52  sasavranic
 * Ispravljen bug pri unosu izlaznih kalkulacija, na stanju uvije 0 robe, varijanta barkod
 *
 * Revision 1.7  2003/10/06 15:00:27  sasavranic
 * Unos podataka putem barkoda
 *
 * Revision 1.6  2003/09/29 13:26:55  mirsadsubasic
 * sredjivanje koda za poreze u ugostiteljstvu
 *
 * Revision 1.5  2002/12/26 16:08:07  mirsad
 * no message
 *
 * Revision 1.4  2002/07/12 10:15:55  ernad
 *
 *
 * debug ROBPR.DBF, ROBPR.CDX - uklonjena funkcija DodajRobPr()
 *
 * Revision 1.3  2002/06/25 08:44:24  ernad
 *
 *
 * ostranicavanje planika, doxy - grupa: Planika
 *
 * Revision 1.2  2002/06/20 14:03:09  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/prod/dok/1g/frm_19.prg
 *  \brief Maska za unos dokumenta tipa 19
 */


/*! \fn Get1_19()
 *  \brief Prva strana maske za unos dokumenta tipa 19
 */

function Get1_19()
*{
_DatFaktP:=_datdok
_DatKurs:=_DatFaktP
private aPorezi:={}

@ m_x+8,m_y+2   SAY "Konto koji zaduzuje" GET _IdKonto valid  P_Konto(@_IdKonto,24) pict "@!"

if gNW<>"X"
	@ m_x+8,m_y+35  SAY "Zaduzuje: "   GET _IdZaduz  pict "@!" valid empty(_idZaduz) .or. P_Firma(@_IdZaduz,24)
endif

read
ESC_RETURN K_ESC

@ m_x+10,m_y+66 SAY "Tarif.br->"

if lKoristitiBK
	@ m_x+11,m_y+2   SAY "Artikal  " GET _IdRoba pict "@!S10" when {|| _IdRoba:=PADR(_idroba,VAL(gDuzSifIni)),.t.} valid VRoba()
else
	@ m_x+11,m_y+2   SAY "Artikal  " GET _IdRoba pict "@!" valid VRoba()
endif

@ m_x+11,m_y+70 GET _IdTarifa when gPromTar=="N" valid P_Tarifa(@_IdTarifa)

read
ESC_RETURN K_ESC
if lKoristitiBK
	_idRoba:=Left(_idRoba,10)
endif


_MKonto:=_Idkonto
DatPosljP()

select koncij
seek trim(_idkonto)
select PRIPR  // napuni tarifu

DatPosljP()
DuplRoba()

dDatNab:=ctod("")
if fnovi
	_Kolicina:=0
endif

lGenStavke:=.f.
if !empty(gmetodaNC) .and. _TBankTr<>"X" .or. lPoNarudzbi
	if lPoNarudzbi
		aNabavke:={}
		if !fNovi
			AADD( aNabavke , {0,_nc,_kolicina,_idnar,_brojnar} )
		endif
		KalkNab3p(_idfirma,_idroba,_idkonto,aNabavke)
		if LEN(aNabavke)>1
			lGenStavke:=.t.
		endif
		if LEN(aNabavke)>0
			// - tekuca -
			i:=LEN(aNabavke)
			// _nc       := aNabavke[i,2]
			_kolicina := aNabavke[i,3]
			_idnar    := aNabavke[i,4]
			_brojnar  := aNabavke[i,5]
			// ----------
		endif
	else
		MsgO("Racunam kolicinu u prodavnici")
		KalkNabP(_idfirma,_idroba,_idkonto,@_kolicina,NIL,NIL,@_nc,@dDatNab)
		MsgC()
	endif
endif

if !lPoNarudzbi
	@ m_x+12,m_y+2   SAY "Kolicina " GET _Kolicina PICTURE PicKol valid _kolicina>=0
else
	@ m_x+12,m_y+2   SAY "Kolicina " GET _Kolicina PICTURE PicKol when .f.
	@ row(),col()+2 SAY IspisPoNar(,,.t.)
endif

_idpartner:=""

read

nStCj:=nNCJ:=0

if fnovi
	select koncij
	seek trim(_idkonto)
	nStCj:=ROUND(UzmiMPCSif(),3)
else
	nStCj:=_fcj
endif

_PKonto:=_Idkonto
_PU_I:="3"     // nivelacija

if fnovi .and.  gCijene="2"
	FaktMPC(@nStCj,_idfirma+_pkonto+_idroba)
endif

VTPorezi()
select pripr


nNCJ:=nStCj+_MPCSaPP

@ m_x+16,m_y+2  SAY "STARA CIJENA (MPCSAPP):"
@ m_x+16,m_y+50 GET nStCj    pict "999999.9999"
@ m_x+17,m_y+2  SAY "NOVA CIJENA  (MPCSAPP):"
@ m_x+17,m_y+50 GET nNCj     pict "999999.9999"

SayPorezi(19)

read
ESC_RETURN K_ESC

_MPCSaPP:=nNCj-nStCj
_MPC:=0
_fcj:=nStCj

_mpc:=MpcBezPor(nNCj, aPorezi, , _nc)-MpcBezPor(nStCj, aPorezi, , _nc)

if Pitanje(,"Staviti u sifrarnik novu cijenu",gDefNiv)=="D"
	select koncij
	seek trim(_idkonto)
	select roba
	StaviMPCSif(_fcj+_mpcsapp)
	select pripr
endif

nStrana:=3
_VPC:=0
_GKolicina:=_GKolicin2:=0
_Marza2:=0
_TMarza2:="A"

if lPoNarudzbi
	_PKonto:=_Idkonto
	_PU_I:="3"     // nivelacija
	_MKonto:=""
	_MU_I:=""
	if lGenStavke
		pIzgSt:=.t.
		// vise od jedne stavke
		for i:=1 to LEN(aNabavke)-1
			// generisi sve izuzev posljednje
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
		next
		// posljednja je teku†a
		// _nc       := aNabavke[i,2]
		_kolicina := aNabavke[i,3]
		_idnar    := aNabavke[i,4]
		_brojnar  := aNabavke[i,5]
		// _vpc      := _nc
	else
		// jedna ili nijedna
		if LEN(aNabavke)>0
			// jedna
			// _nc:=aNabavke[1,2]
			_kolicina:=aNabavke[1,3]
			_idnar:=aNabavke[1,4]
			_brojnar:=aNabavke[1,5]
			// _vpc      := _nc
		else
			// nije izabrana kolicina -> kao da je prekinut unos tipkom Esc
			return (K_ESC)
		endif
	endif
endif

_MKonto:=""
_MU_I:=""
return lastkey()
*}

