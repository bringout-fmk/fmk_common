#include "\cl\sigma\fmk\kalk\kalk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/rpt/1g/rpt_all.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.6 $
 * $Log: rpt_all.prg,v $
 * Revision 1.6  2004/05/25 13:53:17  sasavranic
 * Mogucnost evidentiranja tipa sredstva (donirano i kupljeno)
 *
 * Revision 1.5  2003/06/23 09:32:24  sasa
 * prikaz dobavljaca
 *
 * Revision 1.4  2002/06/28 08:40:10  ernad
 *
 *
 * Dokument inventure - primjer implementacije cl-sc build sistema
 *
 * Revision 1.3  2002/06/25 15:08:47  ernad
 *
 *
 * prikaz parovno - Planika
 *
 * Revision 1.2  2002/06/25 08:44:24  ernad
 *
 *
 * ostranicavanje planika, doxy - grupa: Planika
 *
 * Revision 1.1  2002/06/25 06:08:51  ernad
 *
 *
 * zajednicke funkcije za stampu, pogledaj koristenje u prod/dok/1g/rpt_19.prg
 *
 *
 */
 

function ViseDokUPripremi(cIdd)
*{

if field->idPartner+field->brFaktP+field->idKonto+field->idKonto2<>cIdd
     set device to screen
     Beep(2)
     Msg("Unutar kalkulacije se pojavilo vise dokumenata !",6)
     set device to printer
endif

return
*}


/*! \fn PrikaziDobavljaca(cIdRoba, nRazmak, lNeIspisujDob)
 *  \brief Funkcija vraca dobavljaca cIdRobe na osnovu polja roba->dob
 *  \param cIdRoba
 *  \param nRazmak - razmak prije ispisa dobavljaca
 *  \param lNeIspisujDob - ako je .t. ne ispisuje "Dobavljac:"
 *  \return cVrati - string "dobavljac: xxxxxxx"
 */

function PrikaziDobavljaca(cIdRoba, nRazmak, lNeIspisujDob)
*{
if lNeIspisujDob==NIL
	lNeIspisujDob:=.t.
else
	lNeIspisujDob:=.f.
endif

cIdDob:=Ocitaj(F_ROBA, cIdRoba, "SifraDob")

if lNeIspisujDob
	cVrati:=SPACE(nRazmak) + "Dobavljac: " + TRIM(cIdDob)
else
	cVrati:=SPACE(nRazmak) + TRIM(cIdDob)
endif

if !Empty(cIdDob)
	return cVrati
else
	cVrati:=""
	return cVrati
endif
*}


function PrikTipSredstva(cKalkTip)
*{
if !EMPTY(cKalkTip)
	? "Uslov po tip-u: "
	if cKalkTip=="D"
		?? cKalkTip, ", donirana sredstva"
	elseif cKalkTip=="K"
		?? cKalkTip, ", kupljena sredstva"
	else
		?? cKalkTip, ", --ostala sredstva"
	endif
endif

return
*}

