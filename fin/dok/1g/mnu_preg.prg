#include "\cl\sigma\fmk\fin\fin.ch"
/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fin/dok/1g/mnu_preg.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.4 $
 * $Log: mnu_preg.prg,v $
 * Revision 1.4  2004/01/13 19:07:55  sasavranic
 * appsrv konverzija
 *
 *
 *
 */

/*! \file fmk/fin/dok/1g/mnu_preg.prg
 *  \brief Menij pregled dokumenata
 */

/*! \fn MnuOstOperacije()
 *  \brief Menij pregled dokumenata
 */


function MnuPregledDokumenata()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. kontrola zbira datoteka                  ")
AADD(opcexe, {|| KontrZb()})

AADD(opc, "2. stampanje azuriranog dokumenta")
if (ImaPravoPristupa(goModul:oDatabase:cName,"DOK","MNUSTAMPAAZURNALOGA"))
	AADD(opcexe, {|| MnuStampaAzurNaloga()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "3. stampa liste dokumenata")
AADD(opcexe, {|| StDatN()})

Menu_SC("pgl")

return
*}

