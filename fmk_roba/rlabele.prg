/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "fmk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/roba/rlabele.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.6 $
 * $Log: rlabele.prg,v $
 * Revision 1.6  2002/07/16 11:12:29  ernad
 *
 *
 * rlabele: uvedena GetVars() radi preglednosti, te jednostavnijeg uvodjenja novih varijanti
 *
 * Revision 1.5  2002/07/16 09:19:56  mirsad
 * razne korekcije po Ernadovim instrukcijama od 15.7.
 *
 * Revision 1.4  2002/07/12 14:02:57  mirsad
 * zavrsena dorada za labeliranje robe za Aden
 *
 * Revision 1.3  2002/07/12 10:50:00  mirsad
 * zavrseno kodiranje centralne funkcije labeliranja robe
 *
 * Revision 1.2  2002/07/12 09:28:37  mirsad
 * zavrseno kodiranje centralne funkcije labeliranja
 *
 * Revision 1.1  2002/07/11 13:36:00  mirsad
 * no message
 *
 *
 */
 

/*! \file fmk/roba/rlabele.prg
 *  \brief Pravljenje labela robe
 *  Omogucava izradu naljepnica u dvije varijante:
 *  1 - prikaz naljepnica sa tekucom cijenom
 *  2 - prikaz naljepnica sa novom cijenom, kao i prekrizenom starom cijenom
 */


/*! \fn RLabele()
 *  \brief Centralna funkcija za pravljenje labela robe
 */
function RLabele()
*{
local cVarijanta

cVarijanta:="1"

// kreiraj tabelu rLabele
CreTblRLabele()

if (GetVars(@cVarijanta)==0)
	CLOSE ALL
	return
endif

// izvrsi funkciju koja filuje tabelu rLabele podacima a vraca varijantu (1-5)
if (gModul=="KALK")
	KaFillRLabele()
else
	FaFillRLabele()
endif

CLOSE ALL

if (cVarijanta>"0" .and. cVarijanta<"3")
	PrintRLabele(cVarijanta)
endif

return
*}


static function GetVars(cVarijanta)
*{
local lOpened
local cIdVd

cIdVd:="XX"
cVarijanta:="1"

lOpened:=.t.
if (gModul=="KALK")

	SELECT(F_PRIPR)
	if !USED()
		O_PRIPR
		lOpened:=.f.
	endif

	PushWa()
	SELECT pripr
	GO TOP
	cIdVd:=pripr->idVd
	
	PopWa()
	
	if (cIdVd=="19")
		cVarijanta:="2"
	endif
endif

Box(,4,50)
@ m_x+1, m_y+2 SAY "1 - standardna naljepnica"
@ m_x+2, m_y+2 SAY "2 - sa prikazom stare cijene (prekrizeno)"
@ m_x+4, m_y+3 SAY "Odaberi zeljenu varijantu " GET cVarijanta VALID cVarijanta $ "12"
READ
BoxC()

if (gModul=="KALK")
	if (!lOpened)
		USE
	endif
endif

if (LASTKEY()==K_ESC)
	return 0
endif

return 1
*}


/*! \var
 *  \brief tabela labela - naljepnica za artikle
 *  \ingroup db_fmk
 *  
 * \code
 *
 * CREATE TABLE (
 * 	idRoba Char(10),
 *	naz Char(40),
 * 	idTarifa Char(6),
 *	evBr Char(10),
 *	cijena Numeric(10,2),
 *	sCijena Numeric(10,2),
 *	skrNaziv Char(20),
 *	brojLabela Numeric(6,0),
 *	jmj Char(3),
 *	katBr Char(20),
 *	cAtribut Char(30),
 *	cAtribut2 Char(30),
 *	nAtribut  Numeric(10,2),
 *	nAtribut2 Numeric(10,2),
 *	vpc Numeric(8,2),
 *	mpc Numeric(8,2),
 *	porez Numeric(8,2),
 *	porez2 Numeric(8,2),
 *	porez3 Numeric(8,2)
 * );
 *
 * \endcode
 *
 * evBr - evidencioni broj tj. broj dokumenta
 *
 * sCijena - stara cijena tj. cijena prije tekuceg dokumenta nivelacije
 *
 * cijena - nova cijena tj. cijena koja se obavezno prikazuje na labeli robe
 *
 * porez    - iznos poreza u procentima
 *
 * cAtribut, cAtribut2 - karakteristike artikla koju treba prikazati na naljepnici (npr zelimo prikazati proizvodjaca: "Microsoft", "Ibm", "HP")
 * nAtribut, nAtribut2 - numericke karakteristike artikla koje treba prikazati (npr. Maksimalna temperatura pranja
 *
 * \note Lokacija tabele: privpath
 */
*tbl tbl_rlabele;




/*! \fn CreTblRLabele()
 *  \brief Kreira tabelu rLabele u privatnom direktoriju
 */
static function CreTblRLabele()
*{
local cPom, aDbf

SELECT(F_RLABELE)
cPom:=PRIVPATH+"rLabele"
if (FILE(cPom+".dbf") .and. FERASE(cPom+".dbf")==-1)
	MsgBeep("Ne mogu izbrisati"+cPom+".dbf !")
	ShowFError()
endif
if (FILE(cPom+".cdx") .and. FERASE(cPom+".cdx")==-1)
	MsgBeep("Ne mogu izbrisati"+cPom+".cdx !")
	ShowFError()
endif

aDBf:={}
AADD(aDBf,{ 'idRoba'		, 'C', 10, 0 })
AADD(aDBf,{ 'naz'		, 'C', 40, 0 })
AADD(aDBf,{ 'idTarifa'		, 'C',  6, 0 })
AADD(aDBf,{ 'evBr'		, 'C', 10, 0 })
AADD(aDBf,{ 'cijena'		, 'N', 10, 2 })
AADD(aDBf,{ 'sCijena'		, 'N', 10, 2 })
AADD(aDBf,{ 'skrNaziv'		, 'C', 20, 0 })
AADD(aDBf,{ 'brojLabela'	, 'N',  6, 0 })
AADD(aDBf,{ 'jmj'		, 'C',  3, 0 })
AADD(aDBf,{ 'katBr'		, 'C', 20, 0 })
AADD(aDBf,{ 'cAtribut'		, 'C', 30, 0 })
AADD(aDBf,{ 'cAtribut2'		, 'C', 30, 0 })
AADD(aDBf,{ 'nAtribut'		, 'N', 10, 2 })
AADD(aDBf,{ 'nAtribut2'		, 'N', 10, 2 })
AADD(aDBf,{ 'vpc'		, 'N',  8, 2 })
AADD(aDBf,{ 'mpc'		, 'N',  8, 2 })
AADD(aDBf,{ 'porez'		, 'N',  8, 2 })
AADD(aDBf,{ 'porez2'		, 'N',  8, 2 })
AADD(aDBf,{ 'porez3'		, 'N',  8, 2 })

DbCreate2(cPom+'.dbf',aDbf)
usex (cPom)
index on idRoba tag "1"
set order to tag "1"
return nil
*}



/*! \fn KaFillRLabele()
 *  \brief Puni tabelu rLabele podacima na osnovu dokumenta iz pripreme modula KALK
 */
static function KaFillRLabele()
*{
local cDok
O_PRIPR
O_ROBA
select pripr
go top
cDok:=field->idFirma+field->idVd+field->brDok
do while (!eof() .and. cDok==field->idFirma+field->idVd+field->brDok)
	select rLabele
	seek pripr->idRoba
	if (!found())
		select roba
		seek pripr->idRoba
		select rLabele
		append blank
		Scatter()
		_idRoba:=pripr->idRoba
		_naz:=LEFT(roba->naz, 40)
		_idTarifa:=pripr->idTarifa
		_evBr:=pripr->brDok
		if (pripr->idVd=="19")
			_cijena:=pripr->mpcSaPP+pripr->fCj
			_sCijena:=pripr->fCj
		else
			_cijena:=pripr->mpcSaPP
			_sCijena:=_cijena
		endif
		Gather()
	endif
	select pripr
	skip 1
enddo
return nil
*}




/*! \fn FaFillRLabele()
 *  \brief Prodji kroz pripremu FAKT-a i napuni tabelu rLabele
 */
static function FaFillRLabele()
*{

return nil
*}



/*! \fn PrintRLabele(cVarijanta)
 *  \brief Stampaj RLabele (delphirb)
 *  \param cVarijanta - varijanta izgleda labele robe: "1" - standardna; "2" - za dokument nivelacije - prikazuju snizenje, gdje se vidi i precrtana stara cijena
 */ 
static function PrintRLabele(cVarijanta)
*{
// pozovi delphi rb i odgovarajuci rtm-fajl (rlab1 / rlab2) za kreiranje labela
private cKomLin
cKomLin:="DelphiRB "+"rlab"+cVarijanta+" "+PRIVPATH+"  rlabele 1"
run &cKomLin
return nil
*}

