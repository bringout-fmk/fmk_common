
#include "\cl\sigma\fmk\kalk\kalk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/specif/planika/1g/db.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.4 $
 * $Log: db.prg,v $
 * Revision 1.4  2003/01/09 16:29:52  mirsad
 * ispravka bug-a u planici (gen.p.st.prod.)
 *
 * Revision 1.3  2002/07/06 12:29:01  ernad
 *
 *
 * kalk, planika GenRekap1, GenRekap2
 *
 * Revision 1.2  2002/07/03 18:37:49  ernad
 *
 *
 * razbijanje dugih funkcija, kategorizacija: planika.prg -> db_cre.prg, db_gen1.prg, db_gen2.prg
 *
 * Revision 1.1  2002/06/26 12:17:35  ernad
 *
 *
 * db funkcije init
 *
 *
 */

function SumirajKolicinu(nUlaz, nIzlaz, nTotalUlaz, nTotalIzlaz, fPocStanje)
*{
if fPocStanje==nil
	fPocStanje:=.f.
endif
if (IsPlanika() .and. !fPocStanje)
	if roba->k2<>PADR("X",4)
		nTotalUlaz+=nUlaz
		nTotalIzlaz+=nIzlaz
	endif
else
	nTotalUlaz+=nUlaz
	nTotalIzlaz+=nIzlaz
endif

return
*}

function FillPObjekti()
*{

SELECT pobjekti    
GO TOP
do while !eof()
	// prodaja tarifa ukupno
	REPLACE prodtu with 0
	// prodaja ukupno
	REPLACE produ  with 0
	REPLACE zaltu  with 0
	REPLACE zalu   with 0
	skip
enddo

return
*}
