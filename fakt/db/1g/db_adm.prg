#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/db/1g/db_adm.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.3 $
 * $Log: db_adm.prg,v $
 * Revision 1.3  2003/10/13 12:36:23  sasavranic
 * no message
 *
 * Revision 1.2  2003/01/18 12:08:50  ernad
 * no message
 *
 * Revision 1.1  2002/06/28 21:45:39  ernad
 *
 *
 * db_adm.prg - admin db-a funkcije
 *
 *
 */

function MnuAdmin()
*{
private opc
private opcexe
private Izbor

opc:={}
opcexe:={}
Izbor:=1

AADD(opc, "1. instalacija db-a            ")
AADD(opcexe, {|| goModul:oDatabase:install()}) 
AADD(opc, "2. skip speed db-a")
AADD(opcexe, {|| SpeedSkip()}) 
AADD(opc, "3. security")
AADD(opcexe, {|| MnuSecMain()})

Menu_SC("fain")

return
*}
