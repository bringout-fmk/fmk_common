#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/dok/1g/mnu_dok.prg,v $
 * $Author: ernadhusremovic $ 
 * $Revision: 1.6 $
 * $Log: mnu_dok.prg,v $
 * Revision 1.6  2003/11/20 16:17:52  ernadhusremovic
 * Planika Kranje Robno poslovanje / 2
 *
 * Revision 1.5  2003/11/04 02:13:27  ernadhusremovic
 * Planika Kranj - Robno poslovanje
 *
 * Revision 1.4  2003/10/04 11:07:20  sasavranic
 * uveden security sistem
 *
 * Revision 1.3  2003/07/06 22:20:23  mirsad
 * prenos fakt12->kalk96 obuhvata i varijantu unosa radnog naloga u fakt12
 *
 * Revision 1.2  2002/06/19 13:57:53  mirsad
 * no message
 *
 *
 */

/*! \file fmk/kalk/dok/1g/mnu_dok.prg
 *  \brief Meni opcija za stampu i pregled dokumenata
 */

/*! \fn mBrDoks()
 *  \brief Meni opcija za stampu i pregled dokumenata
 */

function mBrDoks()
*{
PRIVATE opc:={}
PRIVATE opcexe:={}

AADD(opc,"1. stampa azuriranog dokumenta              ")
AADD(opcexe, {|| Stkalk(.t.)})
AADD(opc,"2. stampa liste dokumenata")
AADD(opcexe, {|| StDoks()})
AADD(opc,"3. pregled dokumenata po hronologiji obrade")
AADD(opcexe, {|| BrowseHron()})
AADD(opc,"4. radni nalozi ")
AADD(opcexe, {|| BrowseRn()})
AADD(opc,"5. analiza kartica ")
AADD(opcexe, {|| AnaKart()})
AADD(opc,"6. stampa OLPP-a za azurirani dokument")
AADD(opcexe, {|| StOLPPAz()})

private Izbor:=1
Menu_SC("razp")
CLOSERET
return
*}

/*! \fn MAzurDoks()
 *  \brief Meni - opcija za povrat azuriranog dokumenta
 */

function MAzurDoks()
*{
private Opc:={}
private opcexe:={}
AADD(opc,"1. povrat dokumenta u pripremu")
if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","POVRATDOK"))
	AADD(opcexe, {|| Povrat()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

IF IsPlanika()
AADD(opc,"2. generacija tabele prodnc")
if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","GENPRODNC"))
	AADD(opcexe, {|| GenProdNc()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc,"3. Set roba.idPartner")
if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","SETIDPARTN"))
	AADD(opcexe, {|| SetIdPartnerRoba()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

endif

private Izbor:=1
Menu_SC("mazd")
CLOSERET
return
*}

