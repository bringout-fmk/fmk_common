#include "\cl\sigma\fmk\kalk\kalk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/mag/gendok/1g/gen_im.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.4 $
 * $Log: gen_im.prg,v $
 * Revision 1.4  2004/01/19 13:13:55  sasavranic
 * Pri generaciji IM magacina, pita za cijene VPC ili NC
 *
 * Revision 1.3  2004/01/13 19:07:58  sasavranic
 * appsrv konverzija
 *
 * Revision 1.2  2004/01/09 14:22:35  sasavranic
 * Dorade za dom zdravlja
 *
 * Revision 1.1  2002/06/28 22:32:08  ernad
 *
 *
 * Generacija dokumenta inventure
 *
 *
 */
 
/*! \fn IM()
 *  \brief Generisanje dokumenta tipa IM
 */

function IM()
*{
lOsvjezi := .f.

O_PRIPR
GO TOP
IF idvd=="IM"
	IF Pitanje(,"U pripremi je dokument IM. Generisati samo knjizne podatke?","D")=="D"
    		lOsvjezi := .t.
  	ENDIF
ENDIF

O_KONTO
O_TARIFA
if IzFMKIni("Svi","Sifk")=="D"
   	O_SIFK
   	O_SIFV
endif
O_ROBA

IF lOsvjezi
 	cIdFirma:=gFirma
 	cIdKonto:=pripr->idKonto
 	dDatDok:=pripr->datDok
ELSE
	Box(,6,70)
 	cIdFirma:=gFirma
 	cIdKonto:=padr("1310",gDuzKonto)
 	dDatDok:=date()
	cArtikli:=SPACE(30)
	cPosition:="2"
	cCijenaTIP:="1"
 	@ m_x+1,m_Y+2 SAY "Magacin:" GET  cIdKonto valid P_Konto(@cIdKonto)
 	@ m_x+2,m_Y+2 SAY "Datum:  " GET  dDatDok
 	@ m_x+3,m_Y+2 SAY "Uslov po grupaciji robe" 
 	@ m_x+4,m_Y+2 SAY "(prazno-sve):" GET cArtikli 
 	@ m_x+5,m_Y+2 SAY "(Grupacija broj mjesta) :" GET cPosition
 	@ m_x+6,m_Y+2 SAY "Cijene (1-VPC, 2-NC) :" GET cCijenaTIP VALID cCijenaTIP$"12"
 	read
 	ESC_BCR
 	BoxC()
ENDIF

O_KONCIJ
O_KALK

IF lOsvjezi
	private cBrDok:=pripr->brdok
ELSE
  	private cBrDok:=SljBroj(cIdFirma,"IM",8)
ENDIF

nRbr:=0
set order to 3

MsgO("Generacija dokumenta IM - "+cBrdok)

select koncij
seek trim(cIdKonto)

SELECT kalk
hseek cIdFirma+cIdKonto

do while !EOF() .and. cIdFirma+cIdKonto==field->idfirma+field->mkonto
	cIdRoba:=field->idRoba
	altd()
	if !EMPTY(cArtikli) .and. AT(SubSTR(cIdRoba, 1, VAL(cPosition)), ALLTRIM(cArtikli))==0
		skip 
		loop
	endif
	nUlaz:=0
	nIzlaz:=0
	nVPVU:=0
	nVPVI:=0
	nNVU:=0
	nNVI:=0
	nRabat:=0
	do while !EOF() .and. cIdFirma+cIdKonto+cIdRoba==idFirma+mkonto+idroba
	  	if dDatdok<field->datdok
	      		skip
	      		loop
	  	endif
		RowVpvRabat(@nVpvU, @nVpvI, @nRabat)
		if cCijenaTIP=="2"
			RowNC(@nNVU, @nNVI)
		endif
		RowKolicina(@nUlaz, @nIzlaz)
	  	skip
	enddo

	if (ROUND(nUlaz-nIzlaz,4)<>0) .or. (ROUND(nVpvU-nVpvI,4)<>0)
		SELECT roba
		HSEEK cIdroba
		SELECT pripr
		if lOsvjezi
			// trazi unutar dokumenta
			AzurPostojece(cIdFirma, cIdKonto, cBrDok, dDatDok, @nRbr, cIdRoba, nUlaz, nIzlaz, nVpvU, nVpvI, nNvU, nNvI)
		else
			// dodaj, formira se novi dokument
			DodajImStavku(cIdFirma, cIdKonto, cBrDok, dDatDok, @nRbr, cIdRoba, nUlaz, nIzlaz, nVpvU, nVpvI, nNvU, nNvI)
			
		endif
		select kalk
	
	elseif lOsvjezi
		// prije je ova stavka bila <>0 , sada je 0 pa je treba izbrisati
		select PRIPR
		SET ORDER TO TAG "3"
		GO TOP
		SEEK cIdFirma+"IM"+cBrDok+cIdRoba
		if FOUND()
			DELETE
		endif
		SELECT KALK
	endif

enddo
MsgC()
closeret

return
*}


function AzurPostojece(cIdFirma, cIdKonto, cBrDok, dDatDok, nRbr, cIdRoba, nUlaz, nIzlaz, nVpvU, nVpvI, nNvU, nNvI)
*{

SET ORDER TO TAG "3"
GO TOP
SEEK cIdFirma+"IM"+cBrDok+cIdRoba

if found()
	Scatter()
	_gkolicina:=nUlaz-nIzlaz
	_ERROR:=""
	// knjizno stannje
	_fcj:=nVpvu-nVpvi 
	Gather()
else
	GO BOTTOM
	nRbr:=VAL(ALLTRIM(field->rbr))
	Scatter()
	APPEND NCNL
	_idfirma:=cIdFirma
	_idkonto:=cIdKonto
	_mkonto:=cIdKonto
	_mu_i:="I"
	_idroba:=cIdroba
	_idtarifa:=roba->idTarifa
	_idvd:="IM"
	_brdok:=cBrdok
	_rbr:=RedniBroj(++nRbr)
	_kolicina:=nUlaz-nIzlaz
	_gkolicina:=nUlaz-nIzlaz
	_DatDok:=dDatDok
	_DatFaktP:=dDatdok
	_ERROR:=""
	_fcj:=nVpvU-nVpvI 
	if ROUND(nUlaz-nIzlaz,4)<>0
		_vpc:=ROUND((nVPVU-nVPVI)/(nUlaz-nIzlaz),3)
	else
		_vpc:=0
	endif
	if ROUND(nUlaz-nIzlaz,4)<>0
		_nc:=ROUND((nNvU-nNvI)/(nUlaz-nIzlaz),3)
	else
		_nc:=0
	endif

	Gather2()
endif
return
*}

static function DodajImStavku(cIdFirma, cIdKonto, cBrDok, dDatDok, nRbr, cIdRoba, nUlaz, nIzlaz, nVpvU, nVpvI, nNcU, nNcI)
*{			

Scatter()
APPEND NCNL
_IdFirma:=cIdFirma
_IdKonto:=cIdKonto
_mKonto:=cIdKonto
_mU_I:="I"
_IdRoba:=cIdroba
_IdTarifa:=roba->idtarifa
_IdVd:="IM"
_Brdok:=cBrdok
_RBr:=RedniBroj(++nRbr)
_kolicina:=_gkolicina:=nUlaz-nIzlaz
_datdok:=dDatDok
_DatFaktP:=dDatdok
_ERROR:=""
_fcj:=nVpvu-nVpvi 
if round(nUlaz-nIzlaz,4)<>0
	_vpc:=round((nVPVU-nVPVI)/(nUlaz-nIzlaz),3)
else
	_vpc:=0
endif
if round(nUlaz-nIzlaz,4)<>0 .and. nNcI<>nil .and. nNcU<>nil
	_nc:=round((nNcU-nNcI)/(nUlaz-nIzlaz),3)
else
	_nc:=0
endif

Gather2()

return
*}


function RowKolicina(nUlaz, nIzlaz)
*{ 
  
if field->mu_i=="1" .and. !(field->idVd $ "12#22#94")
	nUlaz+=field->kolicina-field->gkolicina-field->gkolicin2
elseif field->mu_i=="1" .and. (field->idVd $ "12#22#94")
	nIzlaz-=field->kolicina
elseif field->mu_i=="5"
	nIzlaz+=field->kolicina
elseif mu_i=="3"    
	// nivelacija
endif

return
*}


function RowVpvRabat(nVpvU, nVpvI, nRabat)
*{
if mu_i=="1" .and. !(idvd $ "12#22#94")
	nVPVU+=vpc*(kolicina-gkolicina-gkolicin2)
elseif mu_i=="5"
	nVPVI+=vpc*kolicina
	nRabat+=vpc*rabatv/100*kolicina
elseif mu_i=="1" .and. (idvd $ "12#22#94")    
	// povrat
	nVPVI-=vpc*kolicina
	nRabat-=vpc*rabatv/100*kolicina
elseif mu_i=="3"    
	nVPVU+=vpc*kolicina
endif
*}


/*! \fn RowNC(nNcU, nNcI)
 *  \brief Popunjava polja NC
 */
 
function RowNC(nNcU, nNcI)
*{
if mu_i=="1" .and. !(idvd $ "12#22#94")
	nNcU+=nc*(kolicina-gkolicina-gkolicin2)
elseif mu_i=="5"
	nNcI+=nc*kolicina
elseif mu_i=="1" .and. (idvd $ "12#22#94")    
	// povrat
	nNcI-=nc*kolicina
elseif mu_i=="3"    
	nNcU+=nc*kolicina
endif
*}

