#include "\cl\sigma\fmk\fin\fin.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fin/rpt/1g/ostalo.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.3 $
 * $Log: ostalo.prg,v $
 * Revision 1.3  2003/01/08 03:12:30  mirsad
 * specificnosti za rama glas - pogonsko
 *
 * Revision 1.2  2002/06/20 12:03:40  sasa
 * no message
 *
 *
 */


/*! \file fmk/fin/rpt/1g/ostalo.prg
 *  \brief Ostali izvjestaji
 */

/*! \fn Ostalo()
 *  \brief Menij ostalih izvjestaja
 */
 
function Ostalo()
*{
private Izbor:=1
private opc:={}
private opcexe:={}
//private picBHD:=FormPicL(gPicBHD,16)
//private picDEM:=FormPicL(gPicDEM,12)

cSecur:=SecurR(KLevel,"Ostalo")
if ImaSlovo("X",cSecur)
  MsgBeep("Opcija nedostupna !")
  return
endif

AADD(opc,"1. pregled promjena na racunu               ")
AADD(opcexe,{|| PrPromRn()})

if IzFMKIni("FIN","Bilansi_Jerry","N",KUMPATH)=="D"
	lBilansi:=.t.
  	AADD(opc,"2. bilans stanja")
	AADD(opcexe,{|| if (lBilansi,BilansS(),nil)})
  	AADD(opc,"3. bilans uspjeha")
	AADD(opcexe,{|| if (lBilansi,BilansU(),nil)})
else
  	lBilansi:=.f.
  	AADD(opc,"2. ---------------------")
	AADD(opcexe,{|| nil})
  	AADD(opc,"3. ---------------------")
	AADD(opcexe,{|| nil})
endif

if (IsRamaGlas())
	AADD(opc,"4. specifikacije za pogonsko knjigovodstvo")
	AADD(opcexe,{|| IzvjPogonK() })
endif

Menu_SC("ost")
return .f.
*}

