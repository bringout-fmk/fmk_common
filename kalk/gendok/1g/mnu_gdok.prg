#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/gendok/1g/mnu_gdok.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.2 $
 * $Log: mnu_gdok.prg,v $
 * Revision 1.2  2002/06/19 13:57:53  mirsad
 * no message
 *
 *
 */
 

/*! \file fmk/kalk/gendok/1g/mnu_gdok.prg
 *  \brief Meni opcija za generisanje dokumenata za modul KALK
 */

/*! \fn MGenDoks()
 *  \brief Meni opcija za generisanje dokumenata za modul KALK
 */

function MGenDoks()
*{
private Opc:={}
private opcexe:={}
AADD(opc,"1. magacin - generacija dokumenata    ")
AADD(opcexe, {|| GenMag()})
AADD(opc,"2. prodavnica - generacija dokumenata")
AADD(opcexe, {|| GenProd()})
AADD(opc,"3. proizvodnja - generacija dokumenata")
AADD(opcexe, {|| GenProizvodnja()})
AADD(opc,"4. storno dokument")
AADD(opcexe, {|| StornoDok()})
private Izbor:=1
Menu_SC("mgend")
CLOSERET
return
*}
