#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/razdb/1g/topsfakt.prg,v $
 *
 *
 */

/*! \file fmk/fakt/razdb/1g/topsfakt.prg
 *  \brief Tops 2 Fakt
 */


 
/*! \fn TopsFakt()
 *  \brief Prenos dokumenata TOPS->FAKT
 */
 
function TopsFakt()
*{
local cLokacija:=PADR("A:\",40)
local cTopsFakt
local nRBr
local cIdRj:=gFirma
local cCijeneIzSif:="D"
local cRabatDN:="N"
local nRacuna:=0
local nIznosR:=0

Box("#PREUZIMANJE TOPS->FAKT",6,70)
	@ m_x+2, m_y+2 SAY "Lokacija datoteke TOPSFAKT je:" GET cLokacija
	@ m_x+4, m_y+2 SAY "Uzeti cijene iz sifrarnika ? (D/N)" GET cCijeneIzSif VALID cCijeneIzSif$"DN" PICT "@!"
	@ m_x+5, m_y+2 SAY "Ostaviti rabat (ako ga je bilo)? (D/N)" GET cRabatDN VALID cRabatDN$"DN" PICT "@!"
	read
	if LASTKEY()==K_ESC
		BoxC()
		return
	endif
	cTopsFakt:=trim(cLokacija)+"TOPSFAKT.DBF"
	if !file(cTopsFakt)
		MsgBeep("Na zadanoj lokaciji ne postoji datoteka TOPSFAKT.DBF")
		BoxC()
		return
	endif
BoxC()

O_ROBA
O_PARTN
O_DOKS
O_PRIPR

use (trim(cLokacija)+"TOPSFAKT.DBF") new
set order to tag "1"
go top

cBrFakt:=SPACE(8)
cIdVdLast:="  "

do while !eof()
	cIdVd:=idVd
	cIdPartner:=idPartner
	nRBr:=1
	if empty(cBrFakt) .or. cIdVdLast<>cIdVd
		cBrFakt:=SljedBrFakt(cIdRj,cIdVd,datum,cIdPartner)
	else
		cBrFakt:=UBrojDok( val(left(cBrFakt,gNumDio))+1, gNumDio, right(cBrFakt,len(cBrFakt)-gNumDio))
	endif
	cIdVdLast:=cIdVd
	do while !eof() .and. idVd==cIdVd .and. idPartner==cIdPartner

		if cCijeneIzSif=="D"
			select roba
			hseek topsfakt->idRoba
		endif

		select pripr
		append blank

		if nRBr==1
			if cIdVd=="10"
				++nRacuna
			endif
			select partn
			hseek cIdPartner
			_Txt3a:=padr(cIdPartner+".",30)
			_txt3b:=_txt3c:=""
			IzSifre(.t.)
			cTxta:=_txt3a
			cTxtb:=_txt3b
			cTxtc:=_txt3c
			ctxt:=Chr(16)+" "+Chr(17) + Chr(16)+" "+Chr(17) + Chr(16)+cTxta+Chr(17) + Chr(16)+cTxtb+Chr(17) + Chr(16)+cTxtc+Chr(17)
			select pripr
			replace txt with ctxt
		endif
		
		replace idfirma   with cIdRj
		replace rbr       with STR(nRBr,3)
		replace idtipdok  with cIdVd
		replace brdok     with cBrFakt
		replace datdok    with topsfakt->datum
		replace idpartner with cIdPartner
		replace kolicina  with topsfakt->kolicina
		replace idroba    with topsfakt->idRoba
		if cCijeneIzSif=="D"
			replace cijena    with roba->vpc
		else
			replace cijena    with topsfakt->mpc
		endif
		if cRabatDN=="D"
			replace rabat     with topsfakt->stMpc
		endif
		replace dindem    with "KM"

		if cIdVd=="10" 
			nIznosR+=pripr->(kolicina*(cijena-rabat))
		endif

		select topsfakt

		++nRBr
		skip 1
	enddo
enddo


MsgBeep("Dokumenti su preneseni u pripremu!#"+"Broj formiranih racuna: "+ALLTRIM(STR(nRacuna))+"#Ukupan iznos racuna:"+ALLTRIM(STR(nIznosR,15,2)))

CLOSERET
return
*}



/*! \fn SljedBrFakt()
 *  \brief Sljedeci broj fakture
 */
 
static function SljedBrFakt(cIdRj,cIdVd,dDo,cIdPartner)
*{
local nArr:=SELECT()
local cBrFakt
_datdok:=dDo
_idpartner:=cIdPartner
cBrFakt:=OdrediNBroj(cIdRJ,cIdVd)
select (nArr)
return cBrFakt
*}


