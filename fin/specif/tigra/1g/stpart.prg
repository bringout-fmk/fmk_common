#include "\cl\sigma\fmk\fin\fin.ch"
#include "\cl\sigma\fmk\fin\specif\tigra\1g\fin_tgr.ch"

function Rpt_StanjePartnera()
*{
O_PRENHH
O_PARTN

Box(,5,60)
	cDN:="N"
	cPartner:=SPACE(6)
	@ 1+m_x, 2+m_y SAY "Partner: " GET cPartner VALID EMPTY(cPartner) .or. P_Firma(@cPartner)
	@ 2+m_x, 2+m_y SAY "Prikazati samo ukupno stanje " GET cDN VALID cDN$"DN" PICT "@!"
	read
BoxC()

if LastKey()==K_ESC
	return
endif

select prenhh
set order to tag "1"
go top

START PRINT CRET

if !EMPTY(cPartner)
	seek cPartner	
endif

nUkupno:=0
nBrojac:=0

? "Izvjestaj izgenerisanih podataka o stanju partnera"
? "na dan: ", Date()
?
if cDN=="N"
	? "Legenda: "
	? "         F-POCST   - pocetno stanje FIN"
	? "         F-61-0022 - FIN nalog 61-0022 (primjer)"   
endif
?
? "----------------------------------------------------------------------------------------------"
? "Rbr. IDPartner/Naziv                    Datum    DatVal    Dok.    Veza       Dug/Pot   Iznos "
? "----------------------------------------------------------------------------------------------"
do while !EOF() .and. if(!EMPTY(cPartner), idpartner==cPartner, .t.)
	if cDN=="N"
		if ALLTRIM(field->dokument)=="STPART"
			skip
			loop
		endif
	else
		if ALLTRIM(field->dokument)<>"STPART"
			skip
			loop
		endif
	endif
	
	select partn
	hseek PADR(prenhh->idpartner, 6)
	cNazPartn:=field->naz
	
	select prenhh

	
	++nBrojac
	
	? STR(nBrojac, 4) + ". "
	?? field->idpartner
	?? cNazPartn
	?? field->datum, " "
	?? field->datval, " "
	if cDN=="N"
		?? field->dokument
	else
		?? SPACE(10)
	endif
	?? field->veza, SPACE(3)
	?? field->d_p
	?? field->iznos
	
	if field->d_p=="D"
		nUkupno+=field->iznos
	else
		nUkupno-=field->iznos
	endif
	
	skip
enddo

?
? "-------------------------------------------------------------------------------------------"
? "UKUPNO: " + SPACE(60), nUkupno
?

FF

END PRINT

return
*}
