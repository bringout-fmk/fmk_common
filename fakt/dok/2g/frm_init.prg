#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/dok/2g/frm_init.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.7 $
 * $Log: frm_init.prg,v $
 * Revision 1.7  2002/09/13 11:51:52  mirsad
 * dokumentovanje INI parametara
 *
 * Revision 1.6  2002/07/04 08:34:19  mirsad
 * dokumentovanje ini parametara
 *
 * Revision 1.5  2002/06/28 09:56:27  ernad
 *
 *
 * nadogradnja objekat TFrmInv, prepravka funkcije IsDocExists
 *
 * Revision 1.4  2002/06/28 06:34:16  ernad
 *
 *
 * dokument inventure skeleton funkcija Generacija dokumenta viska, manjka
 *
 * Revision 1.3  2002/06/27 17:20:33  ernad
 *
 *
 * dokument inventure, razrada, uvedena generacija dokumenta
 *
 * Revision 1.2  2002/06/27 15:43:26  ernad
 *
 *
 * debug dokument inventure
 *
 * Revision 1.1  2002/06/27 14:03:05  ernad
 *
 *
 * dok/2g init
 *
 *
 */


/*! \ingroup ini
  * \var *string FmkIni_ExePath_FAKT_NaslovPartnTelefon
  * \brief Da li se uz naziv kupca upisuje i telefon?
  * \param D - da, default vrijednost
  * \param N - ne
  */
*string FmkIni_ExePath_FAKT_NaslovPartnTelefon;


 
function TFrmInvItNew(oOwner)
*{
local oObj

#ifdef CLIP

#else
	oObj:=TFrmInvIt():new()
#endif

oObj:oOwner:=oOwner
oObj:self:=oObj
oObj:lSilent:=.f.
oObj:lNovaStavka:=.f.

oObj:oOwner:lPartnerLoaded:=.f.
return oObj
*}


#ifdef CPP
/*! \class TFrmInvIt
 *  \brief Inventura Forma Item Inventura - definise stavku inventure
 *
 */
class TFrmInvIt
{
	public:
	
	*TObject self;
	*TFrmInv oOwner;
	*bool lNovaStavka;
	*TObject oFrmParent;
	
	*bool lSilent;
	// form varijable
	*string cIdRj;
	*string cIdVd;
	*string dDatDok;
	*string cBrDok;
	*string cValuta;
	*string cPartner;
	*string cMjesto;
	*string cAdresa;
	*string cValuta
	*int nRbr;
	*string cIdRoba;
	*int nPKolicina;
	*int nKKolicina;
	*int nKKolPrijeEdita;
	*int nPKolicina;
	*int nCijena;
	*int nUkupno;	
	
	//caclulated values
	*int nNaStanju;
	
	*void newItem();
	
	*void open();
	*void close();
	*void nextItem();
	*void deleteItem();
	*bool wheIdRoba();
	*bool vldIdRoba();
	*bool vldKKolicina();
	*bool wheKKolicina();
	*bool vldPKolicina();
	*bool vldRj();
	*bool vldRbr();
	*bool vldBrDok();
	*bool wheBrDok();
	*bool vldPartner();
	*bool whePartner();
	*void getPartner(int nRow);
	*void sayPartner(int nRow);
	*void showArtikal();
}

#endif


#ifndef CPP

#include "class(y).ch"
CREATE CLASS TFrmInvIt
	EXPORTED:
	var self
	var oOwner
	var lNovaStavka
	
	var nActionType
	var nCh
	var lSilent
	
	// form varijable
	var cIdRj
	var cIdVd
	var dDatDok
	var cBrDok
	var cValuta
	var cPartner
	var cMjesto
	var cAdresa
	var cValuta
	var nRbr
	var cIdRoba
	var nPKolicina
	var nKKolicina
	var nKKolPrijeEdita
	var nPKolicina
	var nCijena
	var nUkupno	
	
	//caclulated values
	var nNaStanju
	
	method newItem
	method deleteItem
	method open
	method close
	method nextItem
	method loadFromTbl
	method saveToTbl
	
	// when, validacija polja
	method wheIdRoba
	method vldIdRoba
	method vldKKolicina
	method wheKKolicina
	method vldPKolicina
	method vldRbr
	method vldRj
	method vldBrDok
	method wheBrDok
	method vldPartner
	method whePartner
	method getPartner
	method sayPartner
	method showArtikal

END CLASS
#endif



/*! \fn TFrmInvIt::runAction()
 *
 */

*void TFrmInvIt::open()
*{
method open()

Box(,20,77)
SET CURSOR ON

if ::lNovaStavka
	::newItem()
else
	::loadFromTbl()
endif	
 
@ m_x+1,col()+2   SAY " RJ:" GET ::cIdRj  pict "@!" VALID ::vldRj()
READ

do while .t.
	@  m_x+3,m_y+40  SAY "Datum:"   GET ::dDatDok
	@  m_x+3,m_y+col()+2  SAY "Broj:" GET ::cBrDok WHEN ::wheBrDok() VALID ::vldBrDok()

	if ::nRbr>1
		::sayPartner(5)
	else
		::getPartner(5)
	endif
	
	@ m_x+9, m_y+2  SAY Valdomaca()+"/"+VAlPomocna() GET ::cValuta PICT "@!" VALID ::cValuta $ ValDomaca()+"#"+ValPomocna()

	READ
	ESC_RETURN 0
	if IsDocExists(::cIdRj, ::cIdVd, ::cBrDok)
		MsgBeep("Dokument vec postoji !!??")
	else
		exit
	endif

enddo

@  m_x+11,m_y+2  SAY "R.br:" get ::nRbr picture "9999"
@  m_x+11, col()+2  SAY "Artikal  " get ::cIdRoba pict "@!S10" WHEN ::wheIdRoba() VALID ::vldIdRoba()
@  m_x+13, m_y+2 SAY "Knjizna kolicina " GET ::nKKolicina PICT pickol WHEN ::wheKKolicina() VALID ::vldKKolicina()
@  m_x+13, col()+2 SAY "popisana kolicina " GET ::nPKolicina PICT pickol VALID ::vldPKolicina()

READ

if (LASTKEY()==K_ESC)
	return 0
endif

::saveToTbl()
 
return 1
*}

 
*void TFrmInvIt::close()
*{
method close
BoxC()
return
*}


/*! \fn TFrmInvIt::newItem()
 /*  \brief Dodaj novu stavku u dokument inventure
 */
method newItem()

SET ORDER TO TAG "1"
SELECT pripr

GO BOTTOM
::loadFromTbl()

APPEND BLANK
++::nRbr

::cIdRoba:=SPACE(LEN(::cIdRoba))
::nKKolicina:=0
::nPKolicina:=0
::nCijena:=0
::cIdVd:="IM"
::cIdRj:=gFirma

if ::nRbr==nil
	::nRbr:=1
endif
if ::nRbr<2
	::dDatDok:=DATE()
endif

return
*}


/*! \fn TFrmInvIt::deleteItem()
 /*  \brief izbrisi stavku
 */
method deleteItem()
DELETE
return
*}


/*! \fn TFrmInvIt::nextItem()
 *  \brief Sljedeca stavka
 */

*int TFrmInvIt::nextItem()
*{
method nextItem()

SELECT pripr
SKIP

if EOF()
	SKIP -1
	return 0
endif
::loadFromTbl()

return 1
*}


*void TFrmInvIt::loadFromTbl()
*{
method loadFromTbl()
local aMemo

SELECT pripr

::cIdRj:=field->idFirma
::cIdVd:=field->idTipDok
::cBrDok:=field->brDok
::nRbr:=RbrUNum(field->rBr)
::nPKolicina:=field->kolicina
::cIdRoba:=field->idRoba
::cValuta:=field->dinDem
::dDatDok:=field->datDok
::nKKolicina:=VAL(field->serBr)

// partner nije ucitan
if !::oOwner:lPartnerLoaded
	if ::nRbr>1 
		// memo polje sa podacima partnera je popunjeno samo u prvoj stavci
		PushWa()
		GO TOP
	endif
	aMemo:=ParsMemo(field->txt)
	::cPartner:=""
	::cMjesto:=""
	::cAdresa:=""
	if LEN(aMemo)>=5
	  ::cPartner:=aMemo[3]
	  ::cAdresa:=aMemo[4]
	  ::cMjesto:=aMemo[5]
	endif
	::oOwner:lPartnerLoaded:=.t.
	if ::nRbr>1
		PopWa()
	endif
endif
return
*}


/*! \fn TFrmInvIt::saveToTbl()
 *  \brief
 */
method saveToTbl()
local cTxt

SELECT pripr

REPLACE idFirma WITH ::cIdRj
REPLACE idTipDok WITH ::cIdVd
REPLACE rBr WITH RedniBroj(::nRbr,3)
REPLACE kolicina WITH ::nPKolicina
REPLACE idRoba WITH ::cIdRoba
REPLACE brDok WITH ::cBrDok
REPLACE dinDem WITH ::cValuta
cTxt:=""
AddTxt(@cTxt, "")
AddTxt(@cTxt, "")
AddTxt(@cTxt, ::cPartner)
AddTxt(@cTxt, ::cAdresa)
AddTxt(@cTxt, ::cMjesto)
REPLACE txt WITH cTxt
REPLACE serBr WITH STR(::nKKolicina,15,4) 
REPLACE datDok WITH ::dDatDok
return
*}

static function AddTxt(cTxt, cStr)
*{
cTxt:=cTxt+Chr(16)+cStr+Chr(17)
return nil
*}

/*! \fn TFrmInvIt::vIdRj()
 *  \brief Validacija radne jedinice
 */
method vldRj()
local cPom

if EMPTY(::cIdRj)
	return .f.
endif
if ::cIdRj==gFirma 
	return .t.
endif

cPom:=::cIdRj
P_RJ(@cPom)
::cIdRj:=cPom

return .t.
*}

/*! \fn TFrmInvIt::wheBrDok()
 *  \brief Prije ulaska u BrDok
 */
 
*bool TFrmInvIt::wheBrDok()
*{
method wheBrDok()
return .t.
*}


/*! \fn TFrmInvIt::vldRbr()
 *  \brief Validacija Redni broj
 */
*bool TFrmInvIt::vldRbr()
*{
method vldRbr()
return .f.
*}


/*! \fn TFrmInvIt::vldBrDok()
 *  \brief Validacija BrDok
 */
*bool TFrmInvIt::vldBrDok()
*{
method vldBrDok()
if !EMPTY(::cBrDok)
	return .t.
else
	return .f.
endif
*}

/*! \fn TFrmInvIt::vldIdRoba()
 *  \brief validacija IdRoba
 */
method vldIdRoba()
*{
local cPom

if LEN(TRIM(::cIdRoba))<10
	::cIdroba:=LEFT(::cIdRoba,10)
endif

cPom:=::cIdRoba
P_Roba(@cPom)
::cIdRoba:=cPom

if ::lSilent
	@ m_x+14,m_y+28 SAY "TBr: "
	?? roba->idtarifa, "PPP", str(tarifa->opp,7,2)+"%", "PPU", str(tarifa->ppp,7,2)
endif

SELECT pripr
return .t.
*}


/*! \fn TFrmInvIt::wheIdRoba()
 *  \brief When (pred ulazak u) IdRoba
 */
method wheIdRoba()
*{
private GetList

::cIdRoba:=PADR(::cIdroba, goModul:nDuzinaSifre)

/*
if ::cPodbr==" ."
	GetList:={}
	@  m_x+13,m_y+2  SAY "Roba     " get _txt1 pict "@!"
    	READ
	return .f.
else
	return .t.
endif
*/

return .t.
*}


/*! \fn TFrmInvIt::getPartner(int nRow)
 *  \brief Uzmi Podatke partnera
 */
method getPartner(nRow)
*{

@  m_x+nRow, m_y+2  SAY "Partner " get ::cPartner  picture "@S30" WHEN ::whePartner() VALID ::vldPartner()

@  m_x+nRow+1,m_y+2  SAY "        " get ::cAdresa  picture "@"
@  m_x+nRow+2,m_y+2  SAY "Mjesto  " get ::cMjesto  picture "@"

return
*}

/*! \fn TFrmInvIt::sayPartner(int nRow)
 *  \brief Odstampaj podatke o partneru
 */

*void TFrmInvIt::sayPartner(int nRow)
*{
method sayPartner(nRow)

@  m_x+nRow, m_y+2  SAY "Partner " 
??::cPartner
@  m_x+nRow+1,m_y+2  SAY "        "
?? ::cAdresa 
@  m_x+nRow+2,m_y+2  SAY "Mjesto  " 
?? ::cMjesto

return
*}

/*! \fn TFrmInvIt::whePartner()
 *  \brief When Partner polja
 */
method whePartner()
*{

::cPartner:=PADR(::cPartner, 30)
::cAdresa:=PADR(::cAdresa, 30)
::cMjesto:=PADR(::cMjesto, 30)

return .t.
*}

/*! \fn TFrmInvIt::vldPartner()
 *  \brief Validacija nakon unosa Partner polja - vidi je li sifra
 */
method vldPartner()
*{
local cSif
local nPos

cSif:=TRIM(::cPartner)

if (RIGHT(cSif,1)="." .and. LEN(csif)<=7)
	nPos:=RAT(".",cSif)
	cSif:=LEFT(cSif,nPos-1)
	P_Firma(PADR(cSif,6))
	::cPartner:=PADR(partn->naz, 30)

	if IzFmkIni('FAKT','NaslovPartnTelefon','D')=="D"
		::cMjesto:=::cMjesto+", Tel:"+trim(partn->telefon)
	endif

	::cAdresa:=PADR(partn->adresa,30)
	::cMjesto:=PADR(partn->mjesto,30)

endif
return  .t.
*}


/*! \fn TFrmInvIt::vldPKolicina()
 *  \brief Validacija Popisane Kolicine
 */

method vldPKolicina()
*{
local cRjTip
local nUl
local nIzl
local nRezerv
local nRevers


/*
if ::nPKolicina==0
	MsgBeep("Kolicina mora biti <> 0")
	return .f.
endif

FaStanje(::cIdRj, ::cIdRoba, @nUl, @nIzl, @nRezerv, @nRevers)

::nNaStanju:=nUl-nIzl-nRevers-nRezerv  

SELECT pripr

::showArtikal()

if ((::nNaStanju - ::nKolicina)<0)
	BoxStanje({{::cIdRj, nUl, nIzl, nRevers, nRezerv}},::cIdRoba)
endif
*/

return .t.
*}


/*! \fn TFrmInvIt::vldKKolicina()
 *  \brief Validacija Knjizne Kolicine
 */
method vldKKolicina()
*{

if ::nKKolPrijeEdita<>::nKKolicina
	MsgBeep("Zasto mjenjate knjiznu kolicinu ??")
	if Pitanje(,"Ipak to zelite uciniti ?","N")=="N"
		::nKKolicina:=::nKKolPrijeEdita
	endif
endif
return .t.
*}


/*! \fn TFrmInvIt::wheKKolicina()
 *  \brief Prije ulaska u polje Knjizne Kolicine
 */
method wheKKolicina()
*{
::nKKolPrijeEdita:=::nKKolicina
return .t.
*}

/*! \fn TFrmInvIt::showArtikal()
 *  \brief Pokazi podatke o artiklu na formi ItemInventure
 */

method showArtikal()

@ m_x+17, m_y+1   SAY "Artikal: "
?? ::cIdRoba 
?? "("+roba->jmj+")"

@ m_x+18, m_y+1   SAY "Stanje :"
@ m_x+18, col()+1 SAY ::nNaStanju PICTURE pickol

@ m_x+19, m_y+1   SAY "Tarifa : " 
?? roba->idtarifa


return
*}


