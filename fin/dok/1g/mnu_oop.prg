#include "\cl\sigma\fmk\fin\fin.ch"
/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fin/dok/1g/mnu_oop.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.4 $
 * $Log: mnu_oop.prg,v $
 * Revision 1.4  2004/01/13 19:07:55  sasavranic
 * appsrv konverzija
 *
 *
 *
 */

/*! \file fmk/fin/dok/1g/mnu_oop.prg
 *  \brief Menij ostalih operacija
 */

/*! \fn MnuOstOperacije()
 *  \brief Menij ostalih operacija
 */

function MnuOstOperacije()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. povrat dokumenta u pripremu          ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"UT","POVRATNALOGA"))
	AADD(opcexe, {|| PovratNaloga()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "2. preknjizenje     ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"UT","PREKNJIZENJE"))
	AADD(opcexe, {|| Preknjizenje()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "3. prebacivanje kartica")
if (ImaPravoPristupa(goModul:oDatabase:cName,"UT","PREBKARTICA"))
	AADD(opcexe, {|| PrebKartica()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "4. ima u suban nema u nalog")
AADD(opcexe, {|| ImaUSubanNemaUNalog()})

AADD(opc, "5. otvorene stavke")
AADD(opcexe, {|| OStav()})

Menu_SC("oop")

return
*}

