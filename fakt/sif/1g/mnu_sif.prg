#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/sif/1g/mnu_sif.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.9 $
 * $Log: mnu_sif.prg,v $
 * Revision 1.9  2003/10/04 12:32:48  sasavranic
 * uveden security sistem
 *
 * Revision 1.8  2003/02/28 07:23:39  mirsad
 * ispravke
 *
 * Revision 1.7  2003/02/23 19:37:58  mirsad
 * ispravka buga
 *
 * Revision 1.6  2002/07/05 14:37:06  sasa
 * dodati sifranici ugovora, vindije
 *
 * Revision 1.5  2002/07/04 19:04:08  ernad
 *
 *
 * ciscenje sifrarnik fakt
 *
 * Revision 1.4  2002/07/04 08:17:32  sasa
 * napravljena varijanta sifrarnika vindija i obicnog.
 * To do: pregledati ima li jos koji specifican sifrarnik
 *
 * Revision 1.3  2002/07/04 07:00:17  sasa
 * dorade pregleda sifrarnika za vindiju
 *
 * Revision 1.2  2002/07/03 12:34:28  sasa
 * implementirani pozivi za opce i r-m sifrarnike
 *
 *
 */


/*! \file fmk/fakt/sif/1g/mnu_sif.prg
 *  \brief Menij sifrarnika
 */

/*! \fn Sifre()
 *  \brief Menij sifrarnika
 */
 
function Sifre()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. opci sifrarnici              ")
if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","OPCISIFOPEN"))
	AADD(opcexe,{|| SifFMKSvi()})
else
	AADD(opcexe,{|| MsgBeep(cZabrana)})
endif

AADD(opc,"2. robno-materijalno poslovanje ")
if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","ROBMATSIFOPEN"))
	AADD(opcexe,{|| SifFMKRoba()})
else
	AADD(opcexe,{|| MsgBeep(cZabrana)})
endif

AADD(opc,"3. fakt->txt")
if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","FTXTSIFOPEN"))
	AADD(opcexe,{|| OSifFtxt(), P_FTxt()} )
else
	AADD(opcexe,{|| MsgBeep(cZabrana)})
endif

if glDistrib
	// ovdje staviti sifrarnike koji su S P E C I F I C N I ZA  KORISNIKA
	// VINDIJA, a to su sifrarnici vezani za distribuciju 
	AADD(opc, "D. distribucija")
	AADD(opcexe,{|| SifOVindija()})
endif

if IsUgovori()
	AADD(opc,"U. ugovori")
	AADD(opcexe,{|| OSifUgov(), SifUgovori()})
endif

Menu_SC("fsif")
return
*}

