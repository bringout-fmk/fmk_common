#include "\cl\sigma\fmk\kalk\kalk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/specif/planika/1g/planika.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.8 $
 * $Log: planika.prg,v $
 * Revision 1.8  2002/07/03 18:37:49  ernad
 *
 *
 * razbijanje dugih funkcija, kategorizacija: planika.prg -> db_cre.prg, db_gen1.prg, db_gen2.prg
 *
 * Revision 1.7  2002/06/30 08:57:26  ernad
 *
 *
 * Rekapitulacija - planika -> rpt_rekp.prg
 *
 * Revision 1.6  2002/06/26 08:11:21  ernad
 *
 *
 * razbijanje prg-ova
 *
 * Revision 1.5  2002/06/25 08:58:07  ernad
 *
 *
 * \group Planika, var tbl_roba_k2
 *
 * Revision 1.4  2002/06/25 08:44:24  ernad
 *
 *
 * ostranicavanje planika, doxy - grupa: Planika
 *
 * Revision 1.3  2002/06/24 09:20:25  sasa
 * no message
 *
 * Revision 1.2  2002/06/20 16:52:06  ernad
 *
 *
 * ciscenje planika, uvedeno fmk/svi/specif.prg
 *
 *
 */

/*! \defgroup Planika Specificne nadogradnje za korisnika Planika
 *  @{
 *  @}
 */



function KesirajKalks(dDatOd, dDatDo, cIdKPovrata, cKartica, cVarijanta, cKesiraj)
*{
local cPom

// ugasena funkcija !!
return 0

if gKalks
	cPom:="KALKS"
else
	cPom:="KALK"
endif

if fSMark==nil
	fSMark:=.f.
endif

if cKesiraj=="D" .and. ( !FILE(GSCTEMP+iif(gKalks,"kalks.dbf","kalk.dbf")) .or. Pitanje(,"Osvjeziti lokalnu kopiju "+cPom+" ?","N")=="D")

	Dirmak2(GSCTEMP)
	O_KALKREP
	if FLOCK()
		MsgO("Kopiram "+cPom)
		copy file (KUMPATH+cPom+".dbf") to (GSCTEMP+cPom+".dbf")
		MsgC()
		MsgO("Kopiram kalks.cdx")
		copy file (KUMPATH+cPom+".cdx") to (GSCTEMP+cPom+".cdx")
		MsgC()
	else
		MsgBeep("Neko vec koristi"+cpom+", pokusajte kasnije")
		closeret

	endif
	USE
endif

return
*}


