#include "\cl\sigma\fmk\fin\fin.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fin/rpt/1g/mnu_rpt.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.3 $
 * $Log: mnu_rpt.prg,v $
 * Revision 1.3  2003/12/12 12:09:26  sasavranic
 * poziv specif() zamjenjen sa mnuspecif()
 *
 * Revision 1.2  2002/06/20 11:50:55  sasa
 * no message
 *
 *
 */


/*! \file fmk/fin/rpt/1g/mnu_rpt.prg
 *  \brief Menij izvjestaja
 */

/*! \fn Izvjestaji()
 *  \brief Glavni menij za izbor izvjestaja
 *  \param 
 */
 
function Izvjestaji()
*{
private Izbor:=1
private opc:={}
private opcexe:={}

AADD(opc,"1. kartica                      ")
AADD(opcexe,{|| Kartica()})
AADD(opc,"2. bruto bilans")
AADD(opcexe,{|| Bilans()})
AADD(opc,"3. specifikacija")
AADD(opcexe,{|| MnuSpecif()})
AADD(opc,"4. proizvoljni izvjestaji")
AADD(opcexe,{|| Proizv()})
AADD(opc,"5. dnevnik naloga")
AADD(opcexe,{|| DnevnikNaloga()})
AADD(opc,"6. ostali izvjestaji")
AADD(opcexe,{|| Ostalo()})

Menu_SC("izvj")

return .f.
*}

