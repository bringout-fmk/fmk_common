#include "\cl\sigma\fmk\os\os.ch"

/*! \fn TOsModNew()
 *  \brief
 */

function TOsModNew()
*{
local oObj

#ifdef CLIP

#else
	oObj:=TOsMod():new()
#endif

oObj:self:=oObj
return oObj
*}


#ifdef CPP
/*! \class TOsMod
 *  \brief OS aplikacijski modul
 */

class TOsMod: public TAppMod
{
	public:
	*void dummy();
	*void setGVars();
	*void mMenu();
	*void mMenuStandard();
	*void sRegg();
	*void initdb();
	
#endif

#ifndef CPP
#include "class(y).ch"
CREATE CLASS TOsMod INHERIT TAppMod
	EXPORTED:
	method dummy 
	method setGVars
	method mMenu
	method mMenuStandard
	method sRegg
	method initdb
END CLASS
#endif


/*! \fn TOsMod::dummy()
 *  \brief dummy
 */

*void TOsMod::dummy()
*{
method dummy()
return
*}


*void TOsMod::initdb()
*{
method initdb()

::oDatabase:=TDBOsNew()

return nil
*}


/*! \fn *void TOsMod::mMenu()
 *  \brief Osnovni meni OS modula
 */
*void TOsMod::mMenu()
*{
method mMenu()

private Izbor
private lPodBugom


nPom:=VAL(IzFmkIni("SET","Epoch","1945",KUMPATH))
IF nPom>0
  SET EPOCH TO (nPom)
ENDIF

PUBLIC gSQL:="N"
PUBLIC gCentOn:=IzFmkIni("SET","CenturyOn","N",KUMPATH)
IF gCentOn=="D"
  SET CENTURY ON
ELSE
  SET CENTURY OFF
ENDIF

Pars0()


SETKEY(K_SH_F1,{|| Calc()})
Izbor:=1

O_OS
select os

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


*void TOsMod::mMenuStandard()
*{
method mMenuStandard

private opc:={}
private opcexe:={}

AADD(opc, "1. unos promjena na postojecem sredstvu                     ")
AADD(opcexe, {|| Unos()})
AADD(opc, "2. obracuni")
AADD(opcexe, {|| Obrac()})
AADD(opc, "3. izvjestaji")
AADD(opcexe, {|| Izvj()})
AADD(opc, "--------------")
AADD(opcexe, {|| RazdvojiDupleInvBr()})
//4. inventura"
AADD(opc, "5. sifrarnici")
AADD(opcexe, {|| Sifre()})
AADD(opc, "6. parametri")
AADD(opcexe, {|| Pars()})
AADD(opc, "7. zavrsio unose u sezonskom podrucju, prenesi u tekucu")
AADD(opcexe, {|| PrenosPodatakaUTekucePodrucje()})
AADD(opc, "8. generacija podataka za novu sezonu")
AADD(opcexe, {|| GenerisanjePodatakaZaNovuSezonu()})
AADD(opc, "9. regeneracija poc.stanja (nabavna i otpisana vrijednost)")
AADD(opcexe, {|| RegenerisanjePocStanja()})
AADD(opc, "A. administracija baze podataka")
AADD(opcexe, {|| MnuAdminDB()})

private Izbor:=1

Menu_SC("gos",.t.,lPodBugom)

return
*}

*void TOsMod::sRegg()
*{
method sRegg()
sreg("OS.EXE","OS")
return
*}



/*! \fn *void TOsMod::setGVars()
 *  \brief opste funkcije OS modula
 */
*void TOsMod::setGVars()
*{
method setGVars()
O_PARAMS

//::super:setGVars()

SetFmkSGVars()

SetSpecifVars()

O_PARAMS

private cSection:="1",cHistory:=" "; aHistory:={}
public gFirma:="10", gTS:="Preduzece"
public gNFirma:=space(20)  // naziv firme
public gNW:="D"  // new vawe
public gRJ:="00"
public gDatObr:=date()
public gValuta:="KM "
public gPicI:="99999999.99"
public gPickol:="99999.99"
public gVObracun:="2"
public gIBJ:="D", gDrugaVal:="N"
public gVarDio:="N", gDatDio:=CTOD("01.01.1999")

Rpar("ff",@gFirma)
Rpar("ts",@gTS)
Rpar("fn",@gNFirma)
Rpar("ib",@gIBJ)
Rpar("dv",@gDrugaVal)
Rpar("nw",@gNW)
Rpar("rj",@gRj)
Rpar("do",@gDatObr)
Rpar("va",@gValuta)
Rpar("pi",@gPicI)
Rpar("vd",@gVarDio)
Rpar("dd",@gDatDio)

return
*}


function RazdvojiDupleInvBr()
       if sigmasif("UNIF")
         if pitanje(,"Razdvojiti duple inv.brojeve ?","N")=="D"
           UnifId()
         endif
       endif
return

function PrenosPodatakaUTekucePodrucje()
        if empty(goModul:oDataBase:cSezonDir)
          Msgbeep("Ovo se radi u sezonskom podrucju !")
        else
          PrenesiUtekucu()
        endif
return

function GenerisanjePodatakaZaNovuSezonu()
        if empty(goModul:oDataBase:cSezonDir)  // nalazim se u radnom podrucju
          if val(goModul:oDataBase:cSezona)<>year(date())
             MsgBeep("U radnom podrucju se nalaze podaci iz protekle godine !")
          else
              PrenosOs()
          endif
        else
             MsgBeep("Ovo se radi u radnom podrucju !")
        endif
return

function RegenerisanjePocStanja()
        if empty(goModul:oDataBase:cSezonDir)  // nalazim se u radnom podrucju
          if val(goModul:oDataBase:cSezona)<>year(date())
             MsgBeep("U radnom podrucju se nalaze podaci iz protekle godine !")
          else
              RegenPS()
          endif
        else
             MsgBeep("Ovo se radi u radnom podrucju !")
        endif
return



