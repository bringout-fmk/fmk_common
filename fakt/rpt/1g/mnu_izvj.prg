#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/rpt/1g/mnu_izvj.prg,v $
 * $Author: sasa $ 
 * $Revision: 1.4 $
 * $Log: mnu_izvj.prg,v $
 * Revision 1.4  2002/07/05 14:36:32  sasa
 * ubaceni izvjestaji za korisnike: rudnik, vindija, konsignacija
 *
 * Revision 1.3  2002/07/05 08:35:40  ernad
 *
 *
 * fakt <-> kalk opcija nedostajala
 *
 * Revision 1.2  2002/07/03 12:40:41  sasa
 * implementirana f-ja izvj()
 *
 * Revision 
 *
 *
 */

/*! \file fmk/fakt/rpt/1g/mnu_izvj.prg
 *  \brief Izvjestajni dio
 */
 
/*! \fn Izvj()
 *  \brief Menij izvjestaja
 */

function Izvj()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. stanje robe                               ")
AADD(opcexe,{|| StanjeRobe()})
AADD(opc,"2. lager lista - specifikacija   ")
AADD(opcexe,{|| Lager()})
AADD(opc,"3. kartica")
AADD(opcexe,{|| Kartica()})
AADD(opc,"4. uporedna lager lista fakt1 <-> fakt2")
AADD(opcexe,{|| Fakt_Kalk(.t.)})
AADD(opc,"5. uporedna lager lista fakt <-> kalk")
AADD(opcexe,{|| Fakt_Kalk(.f.)})
AADD(opc,"6. realizacija kumulativno po partnerima")
AADD(opcexe,{|| RealPartn()})
AADD(opc,"7. specifikacija prodaje")
AADD(opcexe,{|| RealKol()})

if IsRudnik() 
	AADD(opc,"R. rudnik")
	AADD(opcexe,{|| MnuRudnik()})
endif
	
if IsStampa()
	AADD(opc,"S. stampa")
	AADD(opcexe,{|| MnuStampa()})
endif

if IsKonsig()
	AADD(opc,"K. konsignacija")
	AADD(opcexe,{|| KarticaKons()})
endif    	

if IsVindija()
	AADD(opc,"T. teretni list")
	AADD(opcexe,{|| TeretniList()})
endif

private fID_J:=.f.
if IzFmkIni('SifRoba','ID_J','N')=="D"
	private fId_J:=.t.
  	AADD(opc,"C. osvjezi promjene sifarskog sistema u prometu")
	AADD(opcexe,{|| OsvjeziIdJ()})
endif

Menu_SC("izvj")

return
*}

