#include "\cl\sigma\fmk\virm\virm.ch"

/*! \fn TVirmModNew()
 *  \brief
 */

function TVirmModNew()
*{
local oObj

#ifdef CLIP

#else
	oObj:=TVirmMod():new()
#endif

oObj:self:=oObj
return oObj
*}


#ifdef CPP
/*! \class TVirmMod
 *  \brief VIRM aplikacijski modul
 */

class TVirmMod: public TAppMod
{
	public:
	*void dummy();
	*void setGVars();
	*void mMenu();
	*void mMenuStandard();
	*void sRegg();
	*void initdb();
	*void srv();	
#endif

#ifndef CPP
#include "class(y).ch"
CREATE CLASS TVirmMod INHERIT TAppMod
	EXPORTED:
	method dummy 
	method setGVars
	method mMenu
	method mMenuStandard
	method sRegg
	method initdb
	method srv
END CLASS
#endif


/*! \fn TVirmMod::dummy()
 *  \brief dummy
 */

*void TVirmMod::dummy()
*{
method dummy()
return
*}


*void TVirmMod::initdb()
*{
method initdb()

::oDatabase:=TDBVirmNew()

return nil
*}


/*! \fn *void TVirmMod::mMenu()
 *  \brief Osnovni meni VIRM modula
 */
*void TVirmMod::mMenu()
*{
method mMenu()

private Izbor
private lPodBugom

public gSQL:="N"

SETKEY(K_SH_F1,{|| Calc()})
Izbor:=1

O_VRPRIM
select vrprim

TrebaRegistrovati(10)
use

#ifdef PROBA
	KEYBOARD "213"
#endif

@ 1,2 SAY padc(gTS+": "+gNFirma,50,"*")
@ 4,5 SAY ""

::mMenuStandard()

::quit()

return nil
*}


*void TVirmMod::mMenuStandard()
*{
method mMenuStandard

private opc:={}
private opcexe:={}

AADD(opc,   "1. priprema virmana                 ")
AADD(opcexe, {|| Unos()} )
AADD(opc,   "2. izvjestaji")
AADD(opcexe, {|| StDok()})
AADD(opc,   "3. moduli - razmjena podataka")
AADD(opcexe, {|| MnuRazDB()})
AADD(opc,"------------------------------------")
AADD(opcexe, nil)
AADD(opc,   "4. sifrarnici")
AADD(opcexe, {|| MnuSifrarnik()})
AADD(opc,   "5. administriranje baze podataka") 
AADD(opcexe, {|| goModul:oDataBase:install()})
AADD(opc,"------------------------------------")
AADD(opcexe, nil)
AADD(opc,   "X. parametri")
AADD(opcexe, {|| MnuParams()})

private Izbor:=1

Menu_SC("gvir",.t.,lPodBugom)

return
*}

*void TVirmMod::sRegg()
*{
method sRegg()
sreg("VIRM.EXE","VIRM")
return
*}

*void TVirmMod::srv()
*{
method srv()
? "Pokrecem VIRM aplikacijski server"
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


/*! \fn *void TVirmMod::setGVars()
 *  \brief opste funkcije Virm modula
 */
*void TVirmMod::setGVars()
*{
method setGVars()
O_PARAMS

::super:setTGVars()

SetFmkRGVars()

SetFmkSGVars()

SetSpecifVars()

public gDirFin:=""
public gDirLD :=""
public gDirKALK :=""
public gnLMarg:=0          // lijeva margina teksta
public gTabela:=1          // fino crtanje tabele
public gA43:="4"           // format papira
public gZaglav:=SPACE(12)  // ime fajla zaglavlja
public gDatum:=DATE(),gFirma:=SPACE(6),gMjesto:=SPACE(16),gOrgJed:=SPACE(17)
public gnRazmak:=VAL("00.00"), gNumT:="D"
public gKLpomak:=PADR("27\74",30)
public gnInca:=216
public gNazad:="8         ", gINulu:="N"
public gPici:="9,999,999,999,999,999.99"
public gnTMarg:=-12.5         // gornja margina - virmani
public gKpocet0:=PADR("24\27\120\1\27\107\0\27\48\18\27\80",40)
public gKKraj0 :=PADR("27\107\0\27\120\0\27\48\18\27\80",40)
public gKpocet1:=PADR("",40)
public gKpocet2:=PADR("",40)
public gPrecrt1:="V",gPrecrt2:="V"
public gTrakas:="D",gnRazTrak:=VAL("101.56")
public gnUTMarg:=-12.5         // gornja margina - uplatnice
public gUKpocet0:=PADR("24\27\120\1\27\107\0\27\48\18\27\80",40)
public gUKKraj0 :=PADR("27\107\0\27\120\0\27\48\18\27\80",40)
public gUKpocet1:=PADR("",40)
public gUKpocet2:=PADR("",40)
public gUPrecrt1:="V",gUPrecrt2:="V"
public gUTrakas:="D", gnURazTrak:=VAL("101.56"), gIDU:="D"

O_PARAMS
private cSection:="1"
private cHistory:=" "
private aHistory:={}

Rpar("Pi",@gPici)
Rpar("a4",@gA43)
RPar("bn",@gINulu)
Rpar("da",@gDatum)
RPar("df",@gDirFIN)
RPar("dl",@gDirLD)
RPar("dk",@gDirKALK)
Rpar("e3",@gNazad)
Rpar("fi",@gFirma)
Rpar("fz",@gZaglav)
Rpar("i'",@gnInca)
Rpar("mj",@gMjesto)
Rpar("nt",@gNumT)
Rpar("oj",@gOrgJed)
Rpar("pm",@gKLpomak)
RPar("pr",@gnLMarg)
Rpar("ra",@gnRazmak)
RPar("tb",@gTabela)
RPar("du",@gIDU)
Rpar("c0",@gKpocet0)
Rpar("c1",@gKpocet1)
Rpar("c2",@gKpocet2)
Rpar("c9",@gKKraj0)
Rpar("e1",@gPrecrt1)
Rpar("e2",@gPrecrt2)
RPar("pt",@gnTMarg)
Rpar("r1",@gnRazTrak)
Rpar("r2",@gTrakas)
Rpar("u0",@gUKpocet0)
Rpar("u1",@gUKpocet1)
Rpar("u2",@gUKpocet2)
Rpar("u3",@gUKKraj0)
Rpar("u4",@gUPrecrt1)
Rpar("u5",@gUPrecrt2)
RPar("u6",@gnUTMarg)
Rpar("u7",@gnURazTrak)
Rpar("u8",@gUTrakas)
cOdradjeno:="D"
if file(EXEPATH+'scshell.ini')
        cOdradjeno:=R_IniRead('ShemePromjena',alltrim(strtran(strtran(cDirPriv,"\","_"),":","_")),  "N" ,EXEPATH+'scshell.INI' )
        R_IniWrite ( 'ShemePromjena',alltrim(strtran(strtran(cDirPriv,"\","_"),":","_")),  "D" ,EXEPATH+'scshell.INI' )
endif
if empty(gDirFin) .or. cOdradjeno="N"
  gDirFin:=strtran(cDirPriv,"VIRM","FIN")+"\"
  WPar("df",gDirfin)
endif
if empty(gDirLD ) .or. cOdradjeno="N"
  gDirLD :=strtran(cDirRad,"VIRM","LD")+"\"
  WPar("dl",gDirLD)
endif
if empty(gDirKALK ) .or. cOdradjeno="N"
  gDirKALK :=strtran(cDirRad,"VIRM","KALK")+"\"
  WPar("dk",gDirKALK)
endif

select params; use
release cSection,cHistory,aHistory
return
*}


/*
#ifdef CAX
function truename(cc)  // sklonjena iz CTP
return cc
#endif
#ifdef EXT
function truename(cc)  // sklonjena iz CTP
return cc
#endif
*/

