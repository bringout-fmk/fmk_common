#include "\cl\sigma\fmk\kalk\kalk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/vt/1g/ut.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.3 $
 * $Log: ut.prg,v $
 * Revision 1.3  2002/07/22 09:18:59  mirsad
 * dodao dio za poreze u ugostiteljstvu
 *
 * Revision 1.2  2002/06/24 09:38:25  sasa
 * no message
 *
 *
 */


/*! \file fmk/kalk/vt/1g/ut.prg
 *  \brief Visokotarifni artikli
 */

/*! \fn VtPorezi()
 *  \brief Porezi za visokotarifne artikle
 */
 
function VTPOREZI()
*{
public _ZPP:=0
if roba->tip $ "VX"
	public _OPP:=0,_PPP:=tarifa->ppp/100
	public _PORVT:=tarifa->opp/100
elseif roba->tip=="K"
	public _OPP:=tarifa->opp/100,_PPP:=tarifa->ppp/100
	public _PORVT:=tarifa->opp/100
else
	public _OPP:=tarifa->opp/100
	public _PPP:=tarifa->ppp/100
	public _ZPP:=tarifa->zpp/100
	public _PORVT:=0
endif
if tarifa->(FIELDPOS("MPP")<>0)
	public _MPP   := tarifa->mpp/100
	public _DLRUC := tarifa->dlRuc/100
else
	public _MPP   := 0
	public _DLRUC := 0
endif
return
*}



