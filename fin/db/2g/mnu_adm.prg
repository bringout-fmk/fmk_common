#include "\cl\sigma\fmk\fin\fin.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fin/db/2g/mnu_adm.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.5 $
 * $Log: mnu_adm.prg,v $
 * Revision 1.5  2004/01/13 19:07:55  sasavranic
 * appsrv konverzija
 *
 *
 */


/*! \file fmk/fin/db/2g/mnu_adm.prg
 *  \brief Administrativni menij
 */

/*! \fn MnuAdminDB()
 *  \brief Administrativni menij
 */

function MnuAdminDB()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. install db-a                         ")
AADD(opcexe, {|| goModul:oDatabase:install()})
AADD(opc, "2. security")
AADD(opcexe, {|| MnuSecMain()})

Menu_SC("adm")

return
*}

