#include "\cl\sigma\fmk\fin\fin.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fin/main/2g/app.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.26 $
 * $Log: app.prg,v $
 * Revision 1.26  2004/05/27 09:27:10  sasavranic
 * Koristenje zajednickog sifranika valuta
 *
 * Revision 1.25  2004/04/27 11:02:37  sasavranic
 * PartnSt prenos - bugix
 *
 * Revision 1.24  2004/01/29 12:53:45  sasavranic
 * Ispravljena greska za SECUR.DBF
 *
 * Revision 1.23  2004/01/19 09:05:16  sasavranic
 * Na komenzaciji uvedena polja za fax #32# i #33#
 *
 * Revision 1.22  2004/01/13 19:07:55  sasavranic
 * appsrv konverzija
 *
 * Revision 1.21  2003/10/13 12:36:33  sasavranic
 * no message
 *
 * Revision 1.20  2003/10/04 12:34:40  sasavranic
 * uveden security sistem
 *
 * Revision 1.19  2003/09/08 08:41:43  ernad
 * porezi u ugostiteljstvu
 *
 * Revision 1.18  2003/07/24 10:31:05  sasa
 * prenos stanja partnera na HH
 *
 * Revision 1.17  2003/04/12 06:46:19  mirsad
 * ispravka: gBrojac sada je PUBLIC varijabla
 *
 * Revision 1.16  2002/11/22 09:32:12  mirsad
 * Login za security prebacen u SCLIB
 *
 * Revision 1.15  2002/11/18 12:12:58  mirsad
 * dorade i korekcije-security
 *
 * Revision 1.14  2002/11/18 04:28:38  mirsad
 * dorade-security
 *
 * Revision 1.13  2002/11/17 11:01:57  sasa
 * no message
 *
 * Revision 1.12  2002/11/16 23:24:30  sasa
 * korekcija koda
 *
 * Revision 1.11  2002/11/15 18:46:39  sasa
 * korekcija koda
 *
 * Revision 1.10  2002/11/15 16:45:25  sasa
 * korekcija koda
 *
 * Revision 1.9  2002/11/15 10:28:27  mirsad
 * ispravke
 *
 * Revision 1.8  2002/11/14 15:17:22  mirsad
 * doradjivanje u toku
 *
 * Revision 1.7  2002/09/26 08:02:15  sasa
 * Ispravka bug-a izbor:=1
 *
 * Revision 1.6  2002/08/05 11:03:58  ernad
 *
 *
 * Fin/SQLLog funkcije, debug bug RJ/KUMPATH
 *
 * Revision 1.5  2002/07/30 17:40:59  ernad
 * SqlLog funkcije - Fin modul
 *
 * Revision 1.4  2002/07/03 07:31:12  ernad
 *
 *
 * planika, debug na terenu
 *
 * Revision 1.3  2002/06/20 07:09:16  sasa
 * no message
 *
 *
 */
 

/*! \file fmk/fin/main/2g/app.prg
 *  \brief TFinMod objekat - glavni objekat FIN modula
 * 
 */
 
 
/*! \fn TFinModNew()
 *  \brief funkcija koja kreira TFinMod objekat
 */

function TFinModNew()
*{
local oObj

#ifdef CLIP
	oObj:=TAppModNew()
	oObj:setName:=@setName()
	oObj:setGVars:=@setGVars()
	oObj:mMenu:=@mMenu()
	oObj:mMenuStandard:=@mMenuStandard()
	oObj:run:=@run()
	//oObj:gProc:=@gProc()

#else
	oObj:=TFinMod():new()
#endif

oObj:self:=oObj
return oObj
*}

#ifdef CPP

/*! \class TFinMod
 *  \brief FIN aplikacijski modul
 */

class TFinMod: public TAppMod 
{
	public:
	*TSqlLog oSqlLog;
	*void dummy();
	*void setGVars();
	*void mMenu();
	*void mMenuStandard();
	//*void gProc(char Ch);
	*void sRegg();
	*void initdb();
	*void srv();
}
#endif


#ifndef CPP
#include "class(y).ch"
CREATE CLASS TFinMod INHERIT TAppMod
	EXPORTED: 
	var oSqlLog
	method dummy
	method setGVars
	method mMenu
	method mMenuStandard
	method sRegg
	method initdb
	method srv
END CLASS
#endif

/*! \fn TFinMod::dummy()
 *  \brief dummy
 */

*void TFinMod::dummy()
*{
method dummy()
return
*}


*void TFinMod::initdb()
*{
method initdb()

//Logg("kreiram database POS objekt")
::oDatabase:=TDBFinNew()

return NIL
*}


/*! \fn *void TFinMod::mMenu()
 *  \brief Osnovni meni FIN modula
 *  \todo meni prebaciti na Menu_SC!
 */

*void TFinMod::mMenu()
*{
method mMenu()

//goModul:oDataBase:setSigmaBD(IzFmkIni("Svi","SigmaBD","c:"+SLASH+"sigma",EXEPATH))

::oSqlLog:=TSqlLogNew()

PID("START")
if gSql=="D"
	::oSqlLog:open()
	::oDatabase:scan()
endif

close all

SETKEY(K_SH_F1,{|| Calc()})

O_NALOG
select NALOG
TrebaRegistrovati(20)
use

// ? ne znam zasto ovo
OKumul(F_SUBAN,KUMPATH,"SUBAN",5,"D")
OKumul(F_ANAL,KUMPATH,"ANAL", 2,"D")
OKumul(F_SINT,KUMPATH,"SINT", 2,"D")
OKumul(F_NALOG,KUMPATH,"NALOG", 2,"D")

close all

@ 1,2 SAY padc(gTS+": "+gNFirma,50,"*")
@ 4,5 SAY ""

::mMenuStandard()

::quit()

return nil
*}


/*! \fn *void TFinMod::mStandardMenu()
 *  \brief Osnovni meni FIN modula
 *  \todo meni prebaciti na Menu_SC!
 */

*void TFinMod::mMenuStandard()
*{
method mMenuStandard()

private Izbor:=1
private opc:={}
private opcexe:={}

AADD(opc, "1. unos/ispravka dokumenta                   ")
if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","KNJIZNALOGA"))
	AADD(opcexe, {|| Knjiz()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif
AADD(opc, "2. izvjestaji")
AADD(opcexe, {|| Izvjestaji()})

AADD(opc, "3. pregled dokumenata")
AADD(opcexe, {|| MnuPregledDokumenata()})

AADD(opc, "4. generacija dokumenata")
if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","GENDOK"))
	AADD(opcexe, {|| MnuGenDok()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "5. moduli - razmjena podataka")
if (ImaPravoPristupa(goModul:oDataBase:cName,"RAZDB","MODULIRAZMJENA"))
	AADD(opcexe, {|| MnuRazmjenaPodataka()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "6. ostale operacije nad dokumentima")
AADD(opcexe, {|| MnuOstOperacije()})

AADD(opc, "7. udaljene lokacije - razmjena podataka ")
if (ImaPravoPristupa(goModul:oDataBase:cName,"RAZDB","UDLOKRAZMJENA"))
	AADD(opcexe, {|| MnuUdaljeneLokacije()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "------------------------------------")
AADD(opcexe, {|| nil})

AADD(opc, "8. sifrarnici")
AADD(opcexe, {|| MnuSifrarnik()})

AADD(opc, "9. administracija baze podataka")
if (ImaPravoPristupa(goModul:oDataBase:cName,"MAIN","DBADMIN"))
	AADD(opcexe, {|| MnuAdminDB()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "------------------------------------")
AADD(opcexe, {|| nil})

AADD(opc, "K. kontrola zbira datoteka")
AADD(opcexe, {|| KontrZb()})

AADD(opc, "P. povrat dokumenta u pripremu")
if (ImaPravoPristupa(goModul:oDatabase:cName,"UT","POVRATNALOGA"))
	AADD(opcexe, {|| PovratNaloga()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "------------------------------------")
AADD(opcexe, {|| nil})

if IsTigra()
	AADD(opc, "T. generacija stanja partnera")
	AADD(opcexe, {|| GeneracijaStPartnera()})
endif

AADD(opc, "X. parametri")
if (ImaPravoPristupa(goModul:oDataBase:cName,"PARAM","PARAMETRI"))
	AADD(opcexe, {|| Pars()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

if IzFMKINI("ZASTITA","PodBugom","N",KUMPATH)=="D"
  	lPodBugom:=.t.
  	gaKeys:={{K_ALT_O,{|| OtkljucajBug()}}}
else
	lPodBugom:=.f.
endif

Menu_SC("gfin",.t.,lPodBugom)

return
*}



*void TFinMod::sRegg()
*{
method sRegg()
sreg("FIN.EXE","FIN")
return
*}


*void TFinMod::srv()
*{
method srv()
? "Pokrecem FIN aplikacijski server"
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


/*! \fn *void TFinMod::setGVars()
 *  \brief opste funkcije FIN modula
 */

*void TFinMod::setGVars()
*{

method setGVars()

altd()

SetFmkSGVars()
SetFmkRGVars()

private cSection:="1"
private cHistory:=" "
private aHistory:={}

public gFirma:="10"
public gTS:="Preduzece"
public gNFirma:=space(20)  // naziv firme
public gRavnot:="D"
public gDatNal:="N"
public gSAKrIz:="N"
public gNW:="D"  // new wave
public gBezVracanja:="N"  // parametar zabrane povrata naloga u pripremu
public gBuIz:="N"  // koristenje konta-izuzetaka u FIN-BUDZET-u
public gPicDEM:= "9999999.99"
public gPicBHD:= "999999999999.99"
public gVar1:="0"
public gRj:="N"
public gTroskovi:="N"
public gnRazRed:=3
public gVSubOp:="N"
public gnLMONI:=120
public gFKomp:=PADR("KOMP.TXT",13)

public gDUFRJ:="N"
public gBrojac:="1"


::super:setTGVars()

O_PARAMS
Rpar("br",@gBrojac)
Rpar("ff",@gFirma)
Rpar("ts",@gTS)
RPar("du",@gDUFRJ)
Rpar("fk",@gFKomp)
Rpar("fn",@gNFirma)
Rpar("Ra",@gRavnot)
Rpar("dn",@gDatNal)
Rpar("nw",@gNW)
Rpar("bv",@gBezVracanja)
Rpar("bi",@gBuIz)
Rpar("p1",@gPicDEM)
Rpar("p2",@gPicBHD)
Rpar("v1",@gVar1)

Rpar("tr",@gTroskovi)
Rpar("rj",@gRj)
Rpar("rr",@gnRazRed)
Rpar("so",@gVSubOp)
Rpar("lm",@gnLMONI)
Rpar("si",@gSAKrIz)

if empty(gNFirma)
	Beep(1)
  	Box(,1,50)
    		@ m_x+1,m_y+2 SAY "Unesi naziv firme:" GET gNFirma pict "@!"
    		read
  	BoxC()
  	WPar("fn",gNFirma)
endif
select (F_PARAMS)

#ifndef CAX
	use
#endif

public gModul
public gTema
public gGlBaza

gModul:="FIN"
gTema:="OSN_MENI"
gGlBaza:="SUBAN.DBF"

public cZabrana:="Opcija nedostupna za ovaj nivo !!!"

return
*}

