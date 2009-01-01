#include "ld.ch"


function TLDModNew()
local oObj

#ifdef CLIP

#else
	oObj:=TLDMod():new()
#endif

oObj:self:=oObj
return oObj


#ifdef CPP
/*! \class TLDMod
 *  \brief LD aplikacijski modul
 */

class TLDMod: public TAppMod
{
	public:
	*void dummy();
	*void setGVars();
	*void mMenu();
	*void mMenuStandard();
	*void sRegg();
	*void initdb();
	*void srv();
	*void chk_db();
#endif

#ifndef CPP
#include "class(y).ch"
CREATE CLASS TLDMod INHERIT TAppMod
	EXPORTED:
	method dummy 
	method setGVars
	method mMenu
	method mMenuStandard
	method sRegg
	method initdb
	method srv
	method chk_db
END CLASS
#endif


/*! \fn TLDMod::dummy()
 *  \brief dummy
 */

*void TLDMod::dummy()
*{
method dummy()
return
*}


*void TLDMod::initdb()
*{
method initdb()

::oDatabase:=TDBLDNew()

return nil
*}


/*! \fn *void TLDMod::chk_db()
 *  \brief provjera tabela
 */
*void TLDMod::chk_db()
*{
method chk_db()
local cModStru:=""
// provjeri postojanje specificnih polja LD.DBF
// HIREDFROM
O_RADN
select radn
if radn->(FieldPOS("HIREDFROM")) == 0
	// obavjesti za modifikaciju
	cModStru += "DP.CHS, "
endif

// provjeri nadogradnje 2009
if radn->(FieldPOS("KLO")) == 0
	cModStru += "LD.CHS (zakon.promj.2009), "
endif

// provjeri KRED->FIL polje
O_KRED
select kred
if kred->(FieldPos("FIL")) == 0
	cModStru += "KRED.CHS, "
endif

if !EMPTY(cModStru)
	MsgBeep("Upozorenje!##Odraditi modifikacije struktura:#" + cModStru)
endif

return


/*! \fn *void TLDMod::mMenu()
 *  \brief Osnovni meni LD modula
 */
*void TLDMod::mMenu()
*{
method mMenu()

private Izbor
private lPodBugom

CheckROnly(KUMPATH + "\LD.DBF")

SETKEY(K_SH_F1,{|| Calc()})
Izbor:=1

O_LD
select ld

TrebaRegistrovati(10)

::chk_db()

use

#ifdef PROBA
	KEYBOARD "213"
#endif

@ 1,2 SAY padc(gTS+": "+gNFirma,50,"*")
@ 4,5 SAY ""

ParObracun()

::mMenuStandard()

::quit()

return nil
*}


*void TLDMod::mMenuStandard()
*{
method mMenuStandard
private opc:={}
private opcexe:={}

AADD(opc,   Lokal("1. obracun (unos, ispravka...)              "))
AADD(opcexe, {|| MnuObracun()} )
AADD(opc,   Lokal("2. brisanje"))
AADD(opcexe, {|| MnuBrisanje()})
AADD(opc,   Lokal("3. rekalkulacija"))
AADD(opcexe, {|| MnuRekalk()})
AADD(opc,   Lokal("4. izvjestaji"))
AADD(opcexe, {|| MnuIzvj()})
AADD(opc,   Lokal("5. krediti"))
AADD(opcexe, {|| MnuKred()})

if IzFmkIni("LD", "Korekcije", "N", KUMPATH)=="D"
	AADD(opc,   "6. ostalo - korekcije obracuna ")
	AADD(opcexe, {|| MnuOstOp()})
endif

AADD(opc,"------------------------------------")
AADD(opcexe, nil)
AADD(opc,   Lokal("7. sifrarnici"))
AADD(opcexe, {|| MnuSifre()})
AADD(opc,   Lokal("9. administriranje baze podataka")) 
AADD(opcexe, {|| MnuAdmin()})
AADD(opc,"------------------------------------")
AADD(opcexe, nil)
// najcesece koristenje opcije
AADD(opc,   Lokal("A. rekapitulacija"))
AADD(opcexe, {|| Rekap(.t.)})
AADD(opc,   Lokal("B. kartica plate")) 
AADD(opcexe, {|| KartPl()})
AADD(opc,"------------------------------------")
AADD(opcexe, nil)
AADD(opc,   Lokal("X. parametri     "))
AADD(opcexe, {|| MnuParams()})

private Izbor:=1

say_fmk_ver()
say_ahonorar()

Menu_SC("gld",.t.,lPodBugom)

return



*void TLDMod::sRegg()
*{
method sRegg()
sreg("LD.EXE","LD")
return
*}

*void TLDMod::srv()
*{
method srv()
? "Pokrecem LD aplikacijski server"
if (MPar37("/KONVERT", goModul))
	if LEFT(self:cP5,3)=="/S="
		cKonvSez:=SUBSTR(self:cP5,4)
		? "Radim sezonu: " + cKonvSez
		if cKonvSez<>"RADP"
			// prebaci se u sezonu cKonvSez
			goModul:oDataBase:cSezonDir:=SLASH+cKonvSez
 			goModul:oDataBase:setDirKum(trim(goModul:oDataBase:cDirKum)+SLASH+cKonvSez)
 			goModul:oDataBase:setDirSif(trim(goModul:oDataBase:cDirSif)+SLASH+cKonvSez)
 			goModul:oDataBase:setDirPriv(trim(goModul:oDataBase:cDirPriv)+SLASH+cKonvSez)
		endif
	endif
	goModul:oDataBase:KonvZN()
	goModul:quit(.f.)
endif
return
*}


/*! \fn *void TLDMod::setGVars()
 *  \brief opste funkcije LD modula
 */
*void TLDMod::setGVars()
*{
method setGVars()
O_PARAMS

//::super:setGVars()

SetFmkSGVars()

//SetLDSpecifVars()

public cSection:="1"
public cHistory:=" "
public aHistory:={}
public cFormula:=""
public gRJ:="01"
public gnHelpObr:=0
public gMjesec:=1
public gObracun := " "
// varijanta obracuna u skladu sa zak.promjenama
public gVarObracun := " "
// default vrijednost osnovnog licnog odbitka 
public gOsnLOdb := 300
public gIzdanje := SPACE(10)
public gGodina := YEAR( DATE() )
public gZaok:=2
public gZaok2:=2
public gValuta:="KM "
public gPicI:="99999999.99"
public gPicS:="99999999"
public gTipObr:="1"
public gVarSpec:="1"
public cVarPorOl:="1"
public gSihtarica:="N"
public gAHonorar := "N"
public gFUPrim:=PADR("UNETO+I24+I25",50)
public gBFForm:=PADR("",100)
public gFURaz:=PADR("",60)
public gFUSati:=PADR("USATI",50)
public gFURSati:=PADR("",50)
public gFUGod:=PADR("I06",40)
public gNFirma:=SPACE(20)  // naziv firme
public gListic:="N"
public gTS:="Preduzece"
public gUNMjesec:="N"
public gMRM:=0
public gMRZ:=0
public gPDLimit:=0
public gSetForm:="1"
public gPrBruto:="N"
public gMinR:="%"
public gPotp:="D"
public gBodK:="1"
public gDaPorol:="N" // pri obracunu uzeti u obzir poreske olaksice
public gFSpec:=PADR("SPEC.TXT",12)
public gReKrOs:="X"
public gReKrKP:="1"
public gVarPP:="1"
public gPotpRpt:="N"
public gPotp1:=PADR("PADL('Potpis:',70)",150)
public gPotp2:=PADR("PADL('_________________',70)",150)
public _LR_:=6
public _LK_:=6
public lViseObr:=.f.
public lVOBrisiCDX:=.f.
public cLdPolja:=40
//public nBo:=0
public cZabrana:="Opcija nedostupna za ovaj nivo !!!"
public gZastitaObracuna:=IzFmkIni("LD","ZastitaObr","N",KUMPATH)

O_PARAMS
select (F_PARAMS)

RPar("bk",@gBodK)      // opisno: 1-"bodovi" ili 2-"koeficijenti"
Rpar("fn",@gNFirma)
Rpar("ts",@gTS)
RPar("fo",@gSetForm)   // set formula
Rpar("gd",@gFUGod)
Rpar("go",@gGodina)
Rpar("kp",@gReKrKP)
Rpar("pp",@gVarPP)
Rpar("li",@gListic)
RPar("m1",@gMRM)
RPar("m2",@gMRZ)
RPar("dl",@gPDLimit)
Rpar("mj",@gMjesec)
Rpar("ob",@gObracun)
Rpar("ov",@gVarObracun)
RPar("mr",@gMinR)      // min rad %, Bodovi
RPar("os",@gFSpec)     // fajl-obrazac specifikacije
RPar("p9",@gDaPorOl)   // praviti poresku olaksicu D/N
RPar("pb",@gPrBruto)   // set formula
RPar("pi",@gPicI)
RPar("po",@gPotp)      // potpis na listicu
RPar("ps",@gPicS)
RPar("rj",@gRj)
RPar("rk",@gReKrOs)
Rpar("to",@gTipObr)
Rpar("vo",@cVarPorOl)
Rpar("uH",@gFURSati)
Rpar("uS",@gFUSati)
Rpar("uB",@gBFForm)
RPar("um",@gUNMjesec)
Rpar("up",@gFUPrim)
Rpar("ur",@gFURaz)
Rpar("va",@gValuta)
Rpar("vs",@gVarSpec)
Rpar("Si",@gSihtarica)
Rpar("aH",@gAHonorar)
Rpar("z2",@gZaok2)
Rpar("zo",@gZaok)
Rpar("lo",@gOsnLOdb)
Rpar("pr",@gPotpRpt)
Rpar("P1",@gPotp1)
Rpar("P2",@gPotp2)

//Rpar("tB",@gTabela)

select (F_PARAMS)
use

LDPoljaINI()

//definisano u SC_CLIB-u
gGlBaza:="LD.DBF"

public lPodBugom:=.f.
IF IzFMKINI("ZASTITA","PodBugom","N",KUMPATH)=="D"
  lPodBugom:=.t.
  gaKeys := { { K_ALT_O , {|| OtkljucajBug()} } }
ELSE
  lPodBugom:=.f.
ENDIF

// setuj gVarObracun na vrijednost prema tekucim zak.promjenama
// set_obr_2009()

return


// --------------------------------------------------------
// prikaz informacije da se radi o autorskim honorarima
// --------------------------------------------------------
static function say_ahonorar()
if gAHonorar <> nil .and. gAHonorar == "D"
	@ 24, 10 SAY "AUTORSKI HONORARI" COLOR "BG+/B"
endif
return


function RadnikJeProizvodni()
private cPom
cPom:=IzFmkIni("ProizvodniRadnik","Formula",'"P"$RADN->K4',KUMPATH)
return (&cPom)


