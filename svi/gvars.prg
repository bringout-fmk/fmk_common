#include "sc.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/svi/gvars.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.11 $
 * $Log: gvars.prg,v $
 * Revision 1.11  2004/04/05 09:40:02  sasavranic
 * Uvedena globalna varijabla gNoReg koja odredjuje da li se modul treba registrovati ili ne
 *
 * Revision 1.10  2004/03/23 15:47:26  sasavranic
 * Uveo novu globalnu varijablu gOznVal (oznaka valute)
 *
 * Revision 1.9  2003/12/01 13:27:41  sasavranic
 * uvedena var. gNovine
 *
 * Revision 1.8  2003/10/08 15:07:12  sasavranic
 * Uvedene varijable:
 * -  gnDebug
 * -  gOpSist
 *
 * Revision 1.7  2003/10/04 12:35:02  sasavranic
 * uveden security sistem
 *
 * Revision 1.6  2002/11/18 12:12:58  mirsad
 * dorade i korekcije-security
 *
 * Revision 1.5  2002/10/01 12:44:13  mirsad
 * korekcije na ucitavanju globalnih varijabli naziv firme, tip subjekta, sifra firme
 *
 * Revision 1.4  2002/06/26 10:34:54  ernad
 *
 *
 * ne pitaj ime firme za POS modul
 *
 * Revision 1.3  2002/06/20 16:52:06  ernad
 *
 *
 * ciscenje planika, uvedeno fmk/svi/specif.prg
 *
 * Revision 1.2  2002/06/16 11:44:53  ernad
 * unos header-a
 *
 *
 */
 

function SetFmkSGVars()
*{

SetSpecifVars()
SetValuta()

public gFirma:="10"
public gTS:="Preduzece"
private cSection:="K",cHistory:=" "; aHistory:={}
public gNFirma:=space(20)  // naziv firme
public gZaokr:=2
public gTabela:=0
public gPDV:=""

if gModul=="FAKT" .or. gModul=="FIN"
	cSection:="1"
endif

select (F_PARAMS)
if !used()
	O_PARAMS
endif

RPar("za",@gZaokr)
Rpar("fn",@gNFirma)
Rpar("ts",@gTS)
Rpar("tt",@gTabela)

if gModul=="FAKT"
	Rpar("fi",@gFirma)
else
	Rpar("ff",@gFirma)
endif

if (gModul<>"POS" .and. gModul<>"TOPS" .and. gModul<>"HOPS")
	if empty(gNFirma)
	  Box(,1,50)
	    Beep(1)
	    @ m_x+1,m_y+2 SAY "Unesi naziv firme:" GET gNFirma pict "@!"
	    read
	  BoxC()
	  WPar("fn",gNFirma)
	endif
endif

// u sekciji 1 je pdv parametar
cSection := "1"

altd()

RPar("PD",@gPDV)
ParPDV()
WPar("PD",gPDV)

select (F_PARAMS)
use

public gPartnBlock
gPartnBlock:=NIL

public gSecurity
gSecurity:=IzFmkIni("Svi","Security","N",EXEPATH)

public gnDebug
gnDebug:=VAL(IzFmkIni("Svi","Debug","0",EXEPATH))

public gNoReg
if IzFmkIni("Svi","NoReg","N",EXEPATH)=="D"
	gNoReg:=.t.
elseif IzFmkIni("Svi","NoReg","N",EXEPATH)=="N"
	gNoReg:=.f.
else
	gNoReg:=.f.
endif

public gOpSist
gOpSist:=IzFmkIni("Svi","OS","-",EXEPATH)

public cZabrana:="Opcija nedostupna za ovaj nivo !!!"

public gNovine
gNovine:=IzFmkIni("STAMPA","Opresa","N",KUMPATH)


return
*}


function SetValuta()
*{
// ako se radi o planici Novi Sad onda je naziv valute DIN
public gOznVal
if IsPlNS()
	gOznVal:="DIN"
else
	gOznVal:="KM"
endif

return
*}


/*! \fn ParPDV()
 *  \brief Provjeri parametar pdv
 */
function ParPDV()
*{
if (gPDV == "")
	// ako je tekuci datum >= 01.01.2006
	if DATE() >= CToD("01.01.2006")
		gPDV := "D"
	else
		gPDV := "N"
	endif
endif
return
*}


/*! \fn IsPDV()
 *  \brief Da li je pdv rezim rada ili ne
 *  \ret .t. or .f.
 */
function IsPDV()
*{
if gPDV=="D"
	return .t.
endif
return .f.
*}

