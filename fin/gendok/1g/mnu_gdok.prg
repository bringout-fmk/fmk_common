#include "\cl\sigma\fmk\fin\fin.ch"
/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fin/gendok/1g/mnu_gdok.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.4 $
 * $Log: mnu_gdok.prg,v $
 * Revision 1.4  2004/01/13 19:07:55  sasavranic
 * appsrv konverzija
 *
 *
 */
 
/*! \file fmk/fin/gendok/1g/mnu_gdok.prg
 *  \brief Generacija dokumenata - menij
 */

/*! \fn MnuGenDok()
 *  \brief Menij generacije dokumenata
 */


function MnuGenDok()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. generacija dokumenta poc.stanja   ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"UT","GENPOCSTANJA"))
	AADD(opcexe, {|| GenPocStanja()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "2. generisanje storna naloga ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"UT","STORNONALOGA"))
	AADD(opcexe, {|| StornoNaloga()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif


Menu_SC("gdk")

return
*}

