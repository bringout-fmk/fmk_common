#include "\cl\sigma\fmk\fin\fin.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fin/budzet/1g/budzet.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.6 $
 * $Log: budzet.prg,v $
 * Revision 1.6  2004/01/13 19:07:54  sasavranic
 * appsrv konverzija
 *
 * Revision 1.5  2003/03/24 10:28:49  mirsad
 * uvedeni parametri za podesavanje broja redova po stranici u pregledu rashoda
 *
 * Revision 1.4  2003/03/22 13:49:46  mirsad
 * podeseno ostranicavanje na pregledu rashoda za min.fin. zdk
 *
 * Revision 1.3  2003/02/21 09:45:59  mirsad
 * ispravka lomljenja stranica na izvj. "pregled rashoda"
 *
 * Revision 1.2  2002/06/19 12:04:08  sasa
 * no message
 *
 *
 */
 

/*! \file fmk/fin/budzet/1g/budzet.prg
 *  \brief Budzet
 */

/*! \fn IzvrsBudz()
 *  \brief Izvrsenje budzeta
 */

function IzvrsBudz()
*{
local cLM:=SPACE (5)
local fKraj
local n
private picBHD:=FormPicL(gPicBHD, 15)
private picDEM:=FormPicL(gPicDEM, 12)
private cIdKonto
private cIdFirma:=SPACE(LEN(gFirma))
private cIdRj:=SPACE(50)
private cFunk:=SPACE(60)
private dDatOd:=CTOD("")
private dDatDo:=DATE()
private aUslK
private aUslRj
private aUslFunk
private cSpecKonta
private nProc:=0
private cBuIz:="N"
private cPeriod:=PADR("JANUAR - ", 40)

private nKorRed1:=VAL(IzFmkIni("FinBudzet","KorRed1","0",KUMPATH))
private nKorRed2:=VAL(IzFmkIni("FinBudzet","KorRed2","0",KUMPATH))
private nKorRed3:=VAL(IzFmkIni("FinBudzet","KorRed3","0",KUMPATH))
private nKorRed4:=VAL(IzFmkIni("FinBudzet","KorRed4","0",KUMPATH))

cIdKonto:=PADR("6;", 60)
cSpecKonta:=PADR("", 60)

cI1:="D"
cI2:="D"
cI3:="D"
cI4:="D"

cSTKI1:="N"
cProv:="D"

private cBRZaZ:=PADR(IzFMKIni('BUDZET','BrRedZaZagl','0',KUMPATH),2)

IF gBuIz=="D"
	O_BUIZ
ENDIF
O_PARTN

do while .t.

	Box (, 22, 75)  // 19
	@ m_x,m_y+15 SAY "IZVRSENJE BUDZETA / PREGLED RASHODA"

	//  procenat ucesca perioda u godisnjem planu
	if gNW=="D"
		cIdFirma:=gFirma
		@ m_x+1,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
	else
		@ m_x+1,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
	endif

	@ m_x+3,m_y+2 SAY "         Konta (prazno-sva)" GET cIdKonto PICT "@S30@!" VALID {|| aUslK := Parsiraj (cIdKonto, "IdKonto"), IIF (aUslK==NIL, .F., .T.)}
	@ m_x+4,m_y+2 SAY " Razdjel/glava (prazno-svi)" GET cIdRj PICT "@S30@!" VALID {|| aUslRj := Parsiraj (cIdRj, "IdRj"), IIF (aUslRj==NIL, .F., .T.)}
	@ m_x+5,m_y+2 SAY "Funkc. klasif  (prazno-sve)" GET cFunk PICT "@S30@!" VALID {|| aUslFunk := Parsiraj (cFunk, "Funk", "C"), IIF (aUslFunk==NIL, .F., .T.)}
	@ m_x+6,m_y+2 SAY "                 Pocevsi od" GET dDatOd VALID dDatOd <= dDatDo
	@ m_x+7,m_y+2 SAY "               Zakljucno sa" GET dDatDo VALID dDatOd <= dDatDo
	@ m_x+10,m_y+2 SAY "Procenat u odnosu god. plan" GET nProc PICT "999.99"

	@ m_x+13,m_y+2 SAY "          Obuhvaceni period" GET cPeriod PICT "@!"
	@ m_x+14,m_y+2 SAY "Izvjestaj 1" GET cI1 pict "@!" valid ci1 $ "DN"
	@ row(),col()+2 SAY "2:" GET cI2 pict "@!" valid ci2 $ "DN"
	@ row(),col()+2 SAY "3:" GET cI3 pict "@!" valid ci3 $ "DN"
	@ row(),col()+2 SAY "4:" GET cI4 pict "@!" valid ci4 $ "DN"
	@ m_x+16,m_y+2 SAY "Subtotali po analitici za izvjestaj 1 ? (D/N)" GET cSTKI1 pict "@!" valid cSTKI1 $ "DN"
	@ m_x+18,m_Y+2 SAY "Provjeriti stavke koje nisu definisane u budzetu" GET cProv pict "@!" valid cprov $"DN"

	if gBuIz=="D"
		cBuIz:="D"
		@ m_x+19,m_Y+2 SAY "U izvjestaju koristiti korekciju za sortiranje konta? (D/N)" GET cBuIz pict "@!" valid cBuIz $"DN"
	endif

	@ m_x+20,m_Y+2 SAY "Broj redova za zaglavlje na izvjest. (0 - nista): " get cBRZaZ
	read
	ESC_BCR
	BoxC()

	UzmiIzIni(KUMPATH+'fmk.ini','BUDZET','BrRedZaZagl',cBRZaZ,'WRITE')

	if (aUslK==NIL .or. aUslRJ==NIL .or. aUslFunk==NIL)
		loop
	else
		exit
	endif

enddo

O_BUDZET
SET ORDER TO TAG "2"

O_KONTO
O_RJ
O_FUNK
O_SUBAN

SELECT SUBAN
cFilter := ""
IF aUslK<>".t."
	cFilter += aUslK
EndIF
IF aUslRj<>".t."
	cFilter += IF (!Empty (cFilter), ".and.", "") + aUslRj  // cidrj
EndIF
IF aUslFunk<>".t."
	cFilter += IF (!Empty (cFilter), ".and.", "") + aUslFunk
EndIF
IF !Empty (dDatOd)
	cFilter += IF (!Empty (cFilter), ".and.", "") + "DatDok>="+cm2str(dDatOd)
EndIF
IF !Empty (dDatDo)
	cFilter += IF (!Empty (cFilter), ".and.", "") + "DatDok<="+cm2str(dDatDo)
EndIF

IF !Empty (cFilter)
	set Filter to &cFilter
EndIF

select budzet
private cFiltB:=""
IF aUslK<>".t."
	cFiltB += IF (!Empty (cFiltB), ".and.", "") + aUslK
EndIF
IF aUslRj<>".t."
	cFiltB += IF (!Empty (cFiltB), ".and.", "") + aUslRj
EndIF
IF aUslFunk<>".t."
	cFiltB += IF (!Empty (cFiltB), ".and.", "") + aUslFunk
EndIF
set filter to &cFiltB

START PRINT CRET
P_INI
F10CPI

select budzet
if cBuIz=="D"
	INDEX ON idrj+BuIz(idkonto) TO IZBUD
	set order to tag "IZBUD"
else
	set order to 1  //"1","IdRj+Idkonto"
endif

SELECT suban
IF cBuIz=="D"
	INDEX ON idFirma+BuIz(IdKonto)+dtos(DatDok)+idpartner TO IZSUB
	set order to tag "IZSUB"
ELSE
	set order to 5
ENDIF

nTotal:=0
nVanBudzeta:=0
nVanB2:=0

seek cidfirma

do while !eof() .and. idfirma==cidfirma
	if d_p=="1"
		nTotal+=iznosbhd
	else
		nTotal-=iznosbhd
	endif
	select budzet
	seek suban->idrj
	if !found()
		if cprov=="D"
			msgbeep(" RJ:"+suban->idrj+"## <ESC> suti")
			if lastkey()==K_ESC
				cProv:="N"
			endif
		endif
		select suban
		if d_p=="1"
			nVanBudzeta+=iznosbhd
		else
			nVanBudzeta-=iznosbhd
		endif
	else // rj postoji
		select budzet
		seek suban->(idrj+idkonto)
		if !found() // potrazi one koje se nece pojaviti u izvjestaju 4
			skip -1 // idi na predh stavku budzeta
			if idrj<>suban->idrj
				if cProv=="D"
					MsgBeep("Nema u planu:"+suban->idrj+"/"+suban->idkonto+"## <ESC> suti")
					if lastkey()==K_ESC
						cProv:="N"
					endif
				endif
				select suban
				if d_p=="1"
					nVanB2+=iznosbhd
				else
					nVanB2-=iznosbhd
				endif
			endif
		endif
	endif
	select suban
	skip 1
enddo


if cI1=="D"
	select suban
	if cBuIz=="D"
		INDEX ON idFirma+BuIz(IdKonto)+dtos(DatDok)+idpartner TO IZSUB
		set order to tag "IZSUB"
	else
		set order to 5
	endif

	// izvjestaj 1
	GO TOP
	INI
	F10CPI
	B_ON

	Razmak(VAL(cBRZaZ))

	?? PADC ("P R E G L E D   R A S H O D A", 80)
	? PADC ("PO SKUPINAMA TROSKOVA", 80)
	? PADC ("ZA PERIOD "+ AllTrim (cPeriod), 80)
	B_OFF
	?

	P_COND
	cLM := SPACE (10)
	th1 := cLM+"                                                                                                                   Ucesce"
	th2 := cLM+"Ekonom.                                                   Plan za                          Izvrsenje     Procenat  u ukup."
	th3 := cLM+" kod    Skupina troskova                               tekucu godinu    Plan za period     za period     izvrsenja trosk."
	th4 := cLM+"                                                         (KM)               (KM)            (KM)          (%)      (%)"
	  m := cLM+"------- --------------------------------------------- ---------------- ---------------- ---------------- --------- -------"

	fPrvaStr := .T.
	nPageNo := 2
	IB_Zagl1()
	nSlob:=nKorRed1+46-VAL(cBrZaZ)
	nTot1:=nTot2:=nTot3:=0

	SELECT BUDZET
	if cBuIz=="D"
		INDEX ON BuIz(idkonto) TO IZBUD2
		set order to tag "IZBUD2"
	else
		set order to 2    //"2", "Idkonto"
	endif

	aSTKI1 := { 0, 0, 0, "" }

	GO TOP
	do While !Eof()
		cSk := Left (Idkonto, 2)
		nTotSk := 0
		nTotPlSk := 0
		do While !Eof() .and. left(Idkonto,2)=cSk
			cKto := BuIz(IdKonto)
			cKtoStvarni := IdKonto
			IF nSlob = 0
				IB_Zagl1()
			EndIF

			// Izracunaj plan za tekucu godinu

			nPlan := 0
			do While !Eof() .and. BuIz(Idkonto)==cKto
				nPlan += (Iznos+RebIznos)
				SKIP 1
			EndDO

			cBudzetNext:=BuIz(idkonto) // sljedeca stavka u budzetu
			if eof()
				cBudzetNext:="XXX"
			endif

			nTotPlSk += nPlan
			nPlanPer := nPlan*nProc/100
			select suban
			seek cidfirma+cKtoStvarni
			fUBudzetu:=.t.

			do while fUbudzetu .or. !eof() .and. cidfirma==idfirma .and. BuIz(idkonto)>=cKto .and. BuIz(idkonto)<cBudzetNext

				nTotEK := 0
				cSKonto:=BuIz(idkonto)
				cSKontoStvarni:=idkonto

				IF EMPTY(aSTKI1[4])
					aSTKI1[4] := iif(fUBudzetu,cKtoStvarni,cSKontoStvarni)
				ENDIF

				do While !Eof() .and. cidfirma==idfirma .and. BuIz(IdKonto)==iif(fUBudzetu,cKto,cSKonto)
					if d_p=="1"
						nTotEK += IznosBHD
					else
						nTotEK -= IznosBHD
					endif
					SKIP 1
				EndDO

				IF nSlob = 0
					IB_Zagl1()
				EndIF

				? cLM
				SELECT konto
				HSEEK iif(fUBudzetu,cKtoStvarni,cSKontoStvarni)
				select suban
				?? iif(fUBudzetu,cKtoStvarni,cSKontoStvarni), PADR (Konto->Naz, 46)
				?? TRANSFORM(nPlan,    "9,999,999,999.99"), TRANSFORM(nPlanPer, "9,999,999,999.99"), TRANSFORM(nTotEK,   "9,999,999,999.99")
				IF nPlanPer > 0
					?? " "+TRANSFORM(nTotEK*100/nPlanPer, "99,999.99")
				Else
					?? SPACE (1+9)
				EndIF
				IF nTotal > 0
					?? " ", STR (nTotEK*100/nTotal, 6, 2)
				EndIF

				IF cSTKI1=="D"
					aSTKI1[1] += nPlan
					aSTKI1[2] += nPlanPer
					aSTKI1[3] += nTotEk
					// ispitati (MS)
					IF EOF() .or. SUBSTR(idkonto,6,2)=="0 " .or. LEFT(aSTKI1[4],5)<>LEFT(idkonto,5)
						? cLM
						?? aSTKI1[4], PADR ("UKUPNO", 46, "_")
						?? TRANSFORM(aSTKI1[1], "9,999,999,999.99"), TRANSFORM(aSTKI1[2], "9,999,999,999.99"), TRANSFORM(aSTKI1[3], "9,999,999,999.99")
						IF aSTKI1[2] > 0
							?? " "+TRANSFORM( aSTKI1[3]*100/aSTKI1[2] , "99,999.99")
						Else
							?? SPACE (1+9)
						EndIF
						IF nTotal > 0
							?? " ", STR ( aSTKI1[3]*100/nTotal , 6, 2)
						EndIF
						aSTKI1[1] := 0
						aSTKI1[2] := 0
						aSTKI1[3] := 0
						aSTKI1[4] := ""
						nSlob--
					ENDIF
				ENDIF

				fUBudzetu:=.f.
				nSlob --
				nTotSk += nTotEK
				nPlan:=0
				nPlanPer:=0

			enddo // suban
			select budzet
		EndDO  //cSK

		IF nSlob < 3
			IB_Zagl1 ()
		EndIF

		? m
		nPlanPer := nTotPlSk*nProc/100
		?
		B_ON
		?? cLM, SPACE (6), PADL ("   UKUPNO SKUPINA TROSKOVA "+cSk+": ", 45), TRANSFORM(nTotPlSk, "9,999,999,999.99"), TRANSFORM(nPlanPer, "9,999,999,999.99"), TRANSFORM(nTotSk,   "9,999,999,999.99")
		IF nPlanPer > 0
			?? " "+TRANSFORM(nTotSk*100/nPlanPer, "99,999.99")
		Else
			?? SPACE(10)
		EndIF
		IF nTotal > 0
			?? " ", STR (nTotSk*100/nTotal, 5, 2)
		EndIF
		nTot1 += nTotPlSk
		nTot2 += nPlanPer
		nTot3 += nTotSk

		B_OFF
		? m
		nSlob -= 3
	EndDO // eof

	?
	B_ON
	?? cLM, SPACE (6), PADL (" UKUPNI TROSKOVI PO SKUPINAMA: ", 45), TRANSFORM(nTot1, "9,999,999,999.99"), TRANSFORM(nTot2, "9,999,999,999.99"), TRANSFORM(nTot3, "9,999,999,999.99")
	IF nTot2 > 0
		?? " "+TRANSFORM(nTot3*100/nTot2, "99,999.99")
	Else
		?? SPACE (10)
	EndIF
	IF nTotal>0
		?? " ", STR (nTot3*100/nTotal, 5, 2)
	EndIF
	B_OFF
	? m

	cLM := SPACE (5)

	if !"D" $ ci2 + ci3 + ci4
		?
		?
		?
		?
		? Space(80) + "Ministar: _________________________________"
	endif

	FF

endif // kraj izvjestaja 1


if ci2=="D"
	// izvjestaj 2

	// struktura troçkova po vrstama

	F10CPI
	B_ON

//	if !"D" $ ci1   //mjesto za zaglavlje
		Razmak(VAL(cBRZaZ))
//	endif

	?? PADC ("STRUKTURA TROSKOVA PO VRSTAMA", 80)
	? PADC ("ZA PERIOD "+ AllTrim (cPeriod), 80)
	?
	B_OFF
	th1 := cLM+" "+"Vrsta  "+" "+PADR ("Naziv vrste troska", LEN (KONTO->Naz))+" "+PADC ("Iznos ("+AllTrim (ValDomaca())+")", 16)

	m := cLM+" "+REPL ("-", 7)+" "+REPL ("-", LEN(KONTO->Naz))+" "+REPL ("-", 16)

	F12CPI
	fPrvaStr := .T.
	nPageNo := 2
	IB_Zagl2 ()

	nSlob := nKorRed2+50-VAL(cBrZaZ)
	nTotTr := 0

	select suban
	if cBuIz=="D"
		INDEX ON idFirma+BuIz(IdKonto)+dtos(DatDok)+idpartner TO IZSUB
		set order to tag "IZSUB"
	else
		set order to 5
	endif

	seek cidfirma
	do While !Eof() .and. idfirma==cidfirma
		_IdKonto := BuIz(IdKonto)
		_IdKontoStvarni := IdKonto
		IF nSlob == 0
			FF
			IB_Zagl2 ()
			nSlob := nKorRed2+50-VAL(cBrZaZ)
		EndIF
		SELECT KONTO
		HSEEK _IdKontoStvarni
		select suban
		? cLM, _IdKontoStvarni, KONTO->Naz

		nTotKonto := 0
		do While !eof() .and. idfirma==cidfirma .and. BuIz(IdKonto)==_IdKonto
			if d_p=="1"
				nTotKonto += IznosBHD
			else
				nTotKonto -= IznosBHD
			endif
			SKIP 1
		EndDO
		?? " " + TRANSFORM(nTotKonto, "9,999,999,999.99")
		nSlob --
		nTotTr += nTotKonto
	EndDO

	? m
	?
	B_ON
	?? cLM,PADL("UKUPNI TROSKOVI PO VRSTAMA: ",7+LEN(KONTO->naz)+1)
	?? " " + TRANSFORM(nTotTr, "9,999,999,999.99")
	B_OFF
	? m

	if !"D" $ ci3 + ci4
		?
		?
		?
		?
		? Space(80) + "Ministar: _________________________________"
	endif

	FF

endif // izvjestaj 2


if ci3=="D" .or. cI4=="D"
	select suban
	MsgO("Kreiram pomocni index ...")
	set filter to
	index on idfirma+idrj+BuIz(idkonto) to subrj  for &cFilter// privremeni index
	set order to tag "SUBRJ"
	MsgC()
endif

if ci3=="D"
	// izvjestaj 3

	// rashodi po potr. jedinicama

	F10CPI
	B_ON

//	if !"D" $ ci1 + ci2   //mjesto za zaglavlje
		Razmak(VAL(cBRZaZ))
//	endif

	?? PADC ("RASHODI PO BUDZETSKIM KORISNICIMA",80)
	? PADC ("ZA PERIOD "+ AllTrim (cPeriod), 80)
	?
	? PADC ("UKUPNI RASHODI PO POTROSACKIM JEDINICAMA", 80)
	?
	B_OFF

	cLM := Space (12)
	th1 := cLM+"                                                       Plan za                          Izvrsenje      Procenat"
	th2 := cLM+"Razdjel Glava  NAZIV BUDZETSKOG KORISNIKA           tekucu godinu     Plan za period    za period      izvrsenja"
	th3 := cLM+"                                                          (KM)             (KM)             (KM)          (%)"
	  m := cLM+"------- ------ ------------------------------------ ---------------- ---------------- ---------------- ---------"

	P_COND
	fPrvaStr := .T.
	nPageNo := 2
	IB_Zagl3()
	nSlob := nKorRed3+49-VAL(cBrZaZ)
	nTot1:=nTot2:=nTot3:=0

	SELECT BUDZET
	if cBuIz=="D"
		INDEX ON idrj+BuIz(idkonto) TO IZBUD
		set order to tag "IZBUD"
	else
		set order to 1
	endif
	//"1","IdRj+Idkonto",KUMPATH+"BUDZET"

	go top
	do while !eof()
		cRazd := LEFT (IdRj, 2)
		nTotRazd := 0
		nTotPlan := 0
		fPrvi := .T.
		do While !Eof() .and. IdRj=cRazd
			cIdRj:=IdRj

			IF fPrvi
				IF nSlob = 0
					FF
					IB_Zagl3 ()
					nSlob := nKorRed3+49-VAL(cBrZaZ)
				EndIF
				? cLM
				B_ON
				SELECT RJ
				HSEEK PADR (cRazd, LEN (RJ->Id))
				cRazdNaz := RJ->Naz
				?? PADR (cRazd, 7), SPACE (6), cRazdNaz
				B_OFF
				nSlob --
				fPrvi := .F.
				SELECT budzet
			EndIF

			IF nSlob==0
				FF
				IB_Zagl3 ()
				nSlob := nKorRed3+49-VAL(cBrZaZ)
				? cLM
				B_ON
				?? PADR (cRazd, 7), SPACE (6), cRazdNaz, "(nastavak)"
				B_OFF
				nSlob --
			EndIF
			? cLM + Space (8)  // 7+1
			SELECT RJ
			HSEEK cIdRj
			select budzet
			?? cIdRj, RJ->Naz," "

			nPlan := 0
			do While !Eof() .and. IdRj==cIdRj
				nPlan+=(Iznos+RebIznos)
				SKIP 1
			EndDO
			nTotPlan += nPlan

			SELECT suban
			seek cidfirma+cidrj
			nIzvr := 0

			do While !eof() .and. idfirma==cidfirma .and. IdRj==cIdRj
				if d_p=="1"
					nIzvr += IznosBHD
				else
					nIzvr -= IznosBHD
				endif
				SKIP 1
			EndDO

			select budzet
			nTotRazd+=nIzvr

			nPlanProc := nPlan*nProc/100
			?? TRANSFORM (nPlan, "9,999,999,999.99"), TRANSFORM (nPlanProc, "9,999,999,999.99"), TRANSFORM (nIzvr, "9,999,999,999.99")
			IF nPlanProc > 0
				?? " "+TRANSFORM (nIzvr*100/nPlanProc, "99,999.99")
			EndIF
			nSlob --
		EndDO  // cRazd
		IF nSlob < 2
			FF
			IB_Zagl3 ()
			nSlob := nKorRed3+49-VAL(cBrZaZ)
			? cLM
			B_ON
			?? PADR (cRazd, 7), SPACE (6), cRazdNaz, "(nastavak)"
			B_OFF
			nSlob --
		EndIF
		?
		B_ON
		nPlanProc := nTotPlan*nProc/100
		?? cLM, space (7), space (6), PADL ("UKUPNO RAZDJEL "+cRazd+":", LEN (RJ->Naz)), TRANSFORM (nTotPlan, "9,999,999,999.99"), TRANSFORM (nPlanProc, "9,999,999,999.99"), TRANSFORM (nTotRazd, "9,999,999,999.99")
		IF nPlanProc > 0
			?? " "+TRANSFORM (nTotRazd*100/nPlanProc, "99,999.99")
		EndIF
		B_OFF
		nTot1 += nTotPlan
		nTot2 += nPlanProc
		nTot3 += nTotRazd
		? m
		nSlob -= 2
	EndDO  // eof

	?
	B_ON
	if nVanBudzeta<>0
		?? cLM, space (7), space (6), PADL ("STAVKE VAN PLANA BUDZETA:", LEN (RJ->Naz)), TRANSFORM (0, "9,999,999,999.99"), TRANSFORM (0, "9,999,999,999.99"), TRANSFORM (nVanBudzeta, "9,999,999,999.99")
		?
	endif
	?? cLM, space (7), space (6), PADL ("UKUPNO RASHODI PO JEDINICAMA:", LEN (RJ->Naz)), TRANSFORM (nTot1, "9,999,999,999.99"), TRANSFORM (nTot2, "9,999,999,999.99"), TRANSFORM (nTot3+nVanBudzeta, "9,999,999,999.99")
	IF nTot2 > 0
		?? " "+TRANSFORM ((nTot3+nVanBudzeta)*100/nTot2, "99,999.99")
	EndIF
	B_OFF
	? m

	if !"D" $ ci4
		?
		?
		?
		?
		? Space(80) + "Ministar: _________________________________"
	endif


	//  detaljni izvjestaj

	FF

endif // izvjestaj 3


if ci4=="D"
	// izvjestaj 4
	F10CPI
	B_ON

//	if !"D" $ ci1 + ci2 + ci3   //mjesto za zaglavlje
		Razmak(VAL(cBRZaZ))
//	endif

	?? PADC ("RASHODI PO BUDZETSKIM KORISNICIMA",80)
	? PADC ("ZA PERIOD "+ AllTrim (cPeriod), 80)
	?
	? PADC ("RASHODI PO POTROSACKIM JEDINICAMA, SKUPINAMA I VRSTAMA TROSKOVA", 80)
	?
	B_OFF
	cLM := SPACE (5)
	th1 := cLM+"                                                                    Plan za                          Izvrsenje     Procenat"
	th2 := cLM+"                                                                 tekucu godinu    Plan za period     za period     izvrsenja"
	th3 := cLM+"NAZIV BUDZETSKOG KORISNIKA, SKUPINA I VRSTA TROSKOVA                 (KM)             (KM)             (KM)           (%)"
	  m := cLM+"--------------------------------------------------------------- ---------------- ---------------- ---------------- ---------"
	SELECT BUDZET
	if cBuIz=="D"
		INDEX ON idrj+BuIz(idkonto) TO IZBUD
		SET ORDER TO TAG "IZBUD"
	else
		SET ORDER TO 1
	endif
	//"1","IdRj+Idkonto",KUMPATH+"BUDZET"

	P_COND
	fPrvaStr := .T.
	nPageNo := 2
	IB_Zagl4()
	nSlob := nKorRed4+49-VAL(cBrZaZ)
	nTot1:=nTot2:=nTot3:=0

	SELECT budzet
	GO TOP
	cRazdjel:=""
	nTotIRa:=0
	nTotPlanRa:=0
	nURazdjelu:=1

	do While !Eof()

		cIdRj := IdRj
		SELECT RJ
		HSEEK cIdRj
		SELECT budzet

		IF nSlob ==0
			IB_Zagl4 ()
		EndIF
		?
		B_ON
		?? cLM + cIdRj, RJ->Naz
		B_OFF
		nSlob --
		cRazdjel:=left(cidrj,2)
		nTotPlanRj := 0
		nTotIRJ := 0
		do while !eof() .and. idrj==cidrj
			cKto:=BuIz(idkonto)
			cKtoStvarni:=idkonto
			nPlan := 0
			do While !Eof() .and. idrj==cidrj .and. BuIz(Idkonto)==cKto
				nPlan += BUDZET->(Iznos+RebIznos)
				SKIP 1
			EndDO
			if idrj==cidrj
				cBudzetNext:=BuIz(idkonto) // sljedeca stavka u budzetu
			else
				cBudzetNext:="XXXXX"
			endif
			if eof()
				cBudzetNext:="XXXXX"
			endif

			select konto
			hseek cKtoStvarni
			IF nSlob==0
				IB_Zagl4()
				?
				B_ON
				?? cLM + cIdRj, RJ->Naz, "(nastavak)"
				B_OFF
				nSlob --
			endif

			?
			B_ON
			?? cLM + Space (6), cKtoStvarni, konto->Naz
			B_OFF
			nSlob --

			fUBudzetu:=.t.
			select suban
			seek cidfirma+cidrj+cKtoStvarni
			nTotek2:=0

			do while fUbudzetu .or. !eof() .and. idfirma==cidfirma .and. idrj==cIdrj .and. BuIz(idkonto)>=cKto .and. BuIz(idkonto)<cBudzetNext
				cSkonto := BuIz(IdKonto)
				cSkontoStvarni := IdKonto
				SELECT konto
				seek  cSKontoStvarni
				select suban
				nTotEk:=0
				do While !Eof() .and. cidfirma==idfirma .and. idrj==cidrj .and. BuIz(IdKonto)==iif(fUBudzetu,cKto,cSKonto)
					if d_p=="1"
						nTotEK += IznosBHD
					else
						nTotEK -= IznosBHD
					endif
					SKIP 1
				enddo
				if nTotEk<>0
					? cLM+Space (6), cSkontoStvarni, Left (KONTO->Naz, 49)
					?? Space (16), Space (16), TRANSFORM(nTotEk, "9,999,999,999.99")
				endif
				nTotEK2 += nTotEk
				nSlob --
				IF nSlob <= 0
					IB_Zagl4()
					?
					B_ON
					?? cLM + cIdRj, RJ->Naz, "(nastavak)"
					B_OFF
					nSlob --
				EndIF

				fubudzetu:=.f.
			enddo //fubudzetu

			select budzet
			?
			nPlanProc := nPlan * nProc / 100
			B_ON
			?? cLM + PADL ("UKUPNO SKUPINA TROSKOVA " + AllTrim (cKtoStvarni), 13+LEN (KONTO->Naz)-7), TRANSFORM(nPlan, "9,999,999,999.99"), TRANSFORM(nPlanProc, "9,999,999,999.99"), TRANSFORM(nTotEK2, "9,999,999,999.99")
			IF nPlanProc > 0
				?? " " + TRANSFORM(nTotEk2 * 100 / nPlanProc, "99,999.99")
			EndIF
			B_OFF
			nSlob --

			nTotPlanRj += nPlan
			nTotIRJ += nTotEK2

			IF nSlob<3
				IB_Zagl4 ()
				?
				B_ON
				?? cLM + cIdRj, RJ->Naz, "(nastavak)"
				B_OFF
				nSlob --
			EndIF
		enddo // cidrj
		nPlanProc := nTotPlanRj * nProc / 100
		? m
		?
		B_ON
		?? cLM + PADL ("UKUPNO BUDZETSKI KORISNIK " + AllTrim (cIdRj), 13+LEN (KONTO->Naz)-7), TRANSFORM(nTotPlanRj, "9,999,999,999.99"), TRANSFORM(nPlanProc, "9,999,999,999.99"), TRANSFORM(nTotIRJ, "9,999,999,999.99")
		IF nPlanProc > 0
			?? " " + TRANSFORM(nTotIRJ * 100 / nPlanProc, "99,999.99")
		EndIF

		nTotIRa+=nTotIRj
		nTotPlanRa+=nTotPlanRj

		if left(idrj,2)<>cRazdjel
			if nURazdjelu>1
				?
				nPlanProcRa := nTotPlanRa * nProc / 100
				?? cLM + PADL ("UKUPNO RAZDJEL " + cRazdjel, 13+LEN (KONTO->Naz)-7), TRANSFORM(nTotPlanRa, "9,999,999,999.99"), TRANSFORM(nPlanProcRa, "9,999,999,999.99"), TRANSFORM(nTotIRa, "9,999,999,999.99")
				IF nPlanProcRa > 0
					?? " " + TRANSFORM(nTotIRa * 100 / nPlanProcRa, "99,999.99")
				endif
			EndIF
			nTotIRa:=0
			nTotPlanRa:=0
			nURazdjelu:=1
		else
			nURazdjelu++
		endif

		B_OFF
		nTot1 += nTotPlanRj
		nTot2 += nPlanProc
		nTot3 += nTotIRJ
		? m
		nSlob -= 3

	enddo  //eof()

	? m
	?
	B_ON

	if nVanBudzeta<>0
		?? cLM + PADL ("STAVKE VAN PLANA BUDZETA:", 13+LEN (KONTO->Naz)-7), TRANSFORM(0, "9,999,999,999.99"), TRANSFORM(0, "9,999,999,999.99"), TRANSFORM(nVanBudzeta+nVanB2, "9,999,999,999.99")
		?
	endif

	?? cLM + PADL ("UKUPNO SVI BUDZETSKI KORISNICI:", 13+LEN (KONTO->Naz)-7), TRANSFORM(nTot1, "9,999,999,999.99"), TRANSFORM(nTot2, "9,999,999,999.99"), TRANSFORM(nTot3+nVanBudzeta+nVanB2, "9,999,999,999.99")
	IF nTot2 > 0
		?? " " + TRANSFORM((nTot3+nVanBudzeta+nVanB2) * 100 / nTot2, "99,999.99")
	EndIF
	B_OFF
	? m

	?
	?
	?
	?
	? Space(80) + "Ministar: _________________________________"

	FF

	// izvjestaj 4
endif


END PRINT
CLOSERET
return
*}


/*! \fn IB_Zagl1()
 *  \brief Zaglavlje izvrsenje budzeta 1
 */
 
function IB_Zagl1()
*{
IF fPrvaStr
	fPrvaStr := .F.
Else
	FF
	Razmak(VAL(cBRZaZ))
	?
	? Space (9), "Pregled rashoda po vrstama i skupinama troskova", Space (60), "Strana", STR (nPageNo++, 3)
	?
EndIF
? m
? th1
? th2
? th3
? th4
? m
nSlob := nKorRed1+46-VAL(cBrZaZ)
RETURN
*}


/*! \fn IB_Zagl2()
 *  \brief Zaglavlje izvjestaja izvrsenje budzeta 2
 */
 
function IB_Zagl2()
*{
IF fPrvaStr
	fPrvaStr := .F.
Else
	Razmak(VAL(cBRZaZ))
	? Space (5), "Struktura troskova po vrstama", Space (41), "Strana", STR (nPageNo++, 3)
	?
EndIF
? m
? th1
? m
RETURN
*}


/*! \fn IB_Zagl3()
 *  \brief Zaglavlje izvjestaja izvrsenje budzeta varijanta 3
 */
 
function IB_Zagl3()
*{
IF fPrvaStr
	fPrvaStr := .F.
Else
	Razmak(VAL(cBRZaZ))
	? Space (11), "Ukupni rashodi po potrosackim jedinicama", Space (61), "Strana", STR (nPageNo++, 3)
	?
EndIF
? m
? th1
? th2
? th3
? m
RETURN
*}


/*! \fn IB_Zagl4()
 *  \brief Zaglavlje izvjestaja izvrsenje budzeta varijanta 4
 */
 
function IB_Zagl4()
*{
IF fPrvaStr
	fPrvaStr := .F.
Else
	FF
	Razmak(VAL(cBRZaZ))
	? Space (5), "Rashodi po potrosackim jedinicama, skupinama i vrstama troskova",  Space (48), "Strana", STR (nPageNo++, 3)
	?
EndIF
? m
? th1
? th2
? th3
? m
nSlob := nKorRed4+49-VAL(cBrZaZ)
RETURN
*}


/*! \fn Prihodi()
 *  \brief Prihodi
 */
 
function Prihodi()
*{
local fKraj
local n
private picBHD:=FormPicL(gPicBHD,15)
private picDEM:=FormPicL(gPicDEM,12)
private cIdKonto
private cIdFirma:=SPACE(LEN(gFirma))
private cIdRj:=SPACE(50)
private cFunk:=SPACE(60)
private dDatOd:=CTOD("")
private dDatDo:=DATE()
private aUslK
private aUslRj
private aUslFunk
private cSpecKonta
private nProc:=0

//private cPeriod := PADR ("JANUAR - ", 40)

cIdKonto := PADR ("7;", 60)
cSpecKonta := PADR ("", 60)

private cPeriod := PADR ("JANUAR - ", 40)


cProv:="D"

O_PARTN

do while .t.

	Box (, 22, 70)  // 19
	@ m_x,m_y+15 SAY "PREGLED PRIHODA"

	//  procenat ucesca perioda u godisnjem planu

	if gNW=="D"
		cIdFirma:=gFirma
		@ m_x+1,m_y+2 SAY "Firma "
		?? gFirma,"-",gNFirma
	else
		@ m_x+1,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
	endif
	@ m_x+3,m_y+2 SAY "         Konta (prazno-sva)" GET cIdKonto PICT "@S30@!" VALID {|| aUslK := Parsiraj (cIdKonto, "IdKonto", "C"), IIF (aUslK==NIL, .F., .T.)}
	@ m_x+4,m_y+2 SAY " Razdjel/glava (prazno-svi)" GET cIdRj PICT "@S30@!" VALID {|| aUslRj := Parsiraj (cIdRj, "IdRj"), IIF (aUslRj==NIL, .F., .T.)}
	@ m_x+5,m_y+2 SAY "Funkc. klasif  (prazno-sve)" GET cFunk PICT "@S30@!" VALID {|| aUslFunk := Parsiraj (cFunk, "Funk", "C"), IIF (aUslFunk==NIL, .F., .T.)}
	@ m_x+6,m_y+2 SAY "                 Pocevsi od" GET dDatOd VALID dDatOd <= dDatDo
	@ m_x+7,m_y+2 SAY "               Zakljucno sa" GET dDatDo VALID dDatOd <= dDatDo
	@ m_x+12,m_y+2 SAY "Procenat u odnosu god. plan" GET nProc PICT "999.99"
	@ m_x+18,m_y+2 SAY "          Obuhvaceni period" GET cPeriod PICT "@!"
	
	@ m_x+22,m_Y+2 SAY "Provjeriti stavke koje nisu definisane u budzetu" GET cProv pict "@!" valid cprov $"DN"
	READ
	ESC_BCR
	BoxC()

	if (aUslK==NIL .or. aUslRJ==NIL .or. aUslFunk==NIL)
		loop
	else
		exit
	endif

enddo

O_BUDZET
O_KONTO
O_SUBAN


SELECT SUBAN
cFilter := ""
IF aUslK<>".t."
	cFilter += aUslK
EndIF
IF aUslRj<>".t."
	cFilter += IF (!Empty (cFilter), ".and.", "") + aUslRj  // cidrj
EndIF
IF aUslFunk<>".t."
	cFilter += IF (!Empty (cFilter), ".and.", "") + aUslFunk
EndIF
IF !Empty (dDatOd)
	cFilter += IF (!Empty (cFilter), ".and.", "") + "DatDok>="+cm2str(dDatOd)
EndIF
IF !Empty (dDatDo)
	cFilter += IF (!Empty (cFilter), ".and.", "") + "DatDok<="+cm2str(dDatDo)
EndIF

IF !Empty (cFilter)
	set Filter to &cFilter
EndIF

SELECT SUBAN
set order to 1
//"1","IdFirma+IdKonto+IdPartner+dtos(DatDok)+BrNal+RBr",KUMPATH+"SUBAN") //subanaliti
GO TOP

select budzet
private cFiltB:=""
IF aUslK<>".t."
	cFiltB += IF (!Empty (cFiltB), ".and.", "") + aUslK
EndIF
IF aUslRj<>".t."
	cFiltB += IF (!Empty (cFiltB), ".and.", "") + aUslRj
EndIF
IF aUslFunk<>".t."
	cFiltB += IF (!Empty (cFiltB), ".and.", "") + aUslFunk
EndIF
set filter to &cFiltB
SET ORDER TO TAG "2" // IDKONTO

EOF CRET

START PRINT CRET

SELECT BUDZET
SET ORDER TO 1
SELECT suban
set order to 5
GO TOP
nTotal:=0
nVanBudzeta:=0
nVanB2:=0
seek cidfirma
//cLast:=IDKONTO

do while !eof() .and. idfirma==cidfirma
	if d_p=="2"
		nTotal+=iznosbhd
	else
		nTotal-=iznosbhd
	endif
	skip 1
enddo

nTotal:=nTotal-nVanBudzeta-nVanB2

SELECT BUDZET
SET ORDER TO TAG "2"
SELECT SUBAN
SET ORDER TO 1
GO TOP

INI
F10CPI

// ispis izvjestaja

F10CPI
B_ON
?? PADC ("P R E G L E D   P R I H O D A", 80)
? PADC ("ZA PERIOD "+AllTrim (cPeriod), 80)
?
? PADC ("STRUKTURA PRIHODA PO VRSTAMA", 80)
B_OFF
?

cLM := SPACE (10)

th1:=cLM+"                                                                                                                      Ucesce "
th2:=cLM+"                                                          Plan za                          Izvrsenje      Procenat    u ukup."
th3:=cLM+"Sifra i naziv ekonomske kategorije prihoda             tekucu godinu    Plan za period     za period      izvrsenja   prihod."
th4:=cLM+"                                                            (KM)             (KM)             (KM)           (%)        (%)  "
  m:=cLM+"----------------------------------------------------- ---------------- ---------------- ---------------- ------------ -------"
m1:= StrTran (m, "-", "*")

P_COND
fPrvaStr := .T.
nPageNo := 2
PR_Zagl()

SELECT KONTO

SELECT BUDZET
go top

cIdRj := SPACE (LEN (BUDZET->IdRj)) // zbog BUDZET-a - prihodi ne idu po RJ
nLen1 := 53
nLen2 := LEN (konto->Naz)-5-1

nTotPlan:=0
nTotPr:=0
nL1:=nL2:=nPlanL1:=nPlanL2:=0
fneman3:=.f.

do while !eof()

	IF prow() > 63+gPStranica
		PR_Zagl()
	EndIF

  
	cLev1:=idkonto
	fLev1:=.t.
	select konto
	hseek clev1
	select budzet
	? cLM
	B_ON
	?? cLev1, (cLev1Naz:=konto->naz)
	B_OFF

	if fond="N1"
		skip 1
	endif

	nPlanL1:=0
	nL1:=0
	do while !eof() .and. fLev1

		cLev2:=idkonto
		fLev2:=.t.
		select konto
		hseek clev2
		select budzet
		? cLM
		B_ON
		?? cLev2, (cLev2Naz:=konto->naz)
		B_OFF
		if fond="N2" .and. !fneman3
			skip
		endif
		if fond="N2"
			if !fneman3
				skip -1
			endif
			fneman3:=.t.   // ponovo se desava n2, NEMA N3
		else
			fneman3:=.f.
		endif
		nPlanL2:=0
		nL2:=0
		do while !eof() .and. fLev2
			cKto := IdKonto
			IF prow() > 62+gPStranica
				FF
				Pr_Zagl()
			EndIF
  
			// Izracunaj plan za tekucu godinu

			nPlan := 0
			do While !Eof() .and. Idkonto==cKto
				nPlan += (Iznos+RebIznos)
				SKIP 1
			EndDO

			nPlanL2 += nPlan
			cBudzetNext:=idkonto // sljedeca stavka u budzetu
			if eof()
				cBudzetNext:="XXX"
			endif

			nPlanPer := nPlan*nProc/100
			select suban   // IDI NA SUBANALITIKU .........................
			seek cidfirma+ckto
			fUBudzetu:=.t.
			do while fUbudzetu .or. !eof() .and. cidfirma==idfirma .and. idkonto>=cKto .and. idkonto<cBudzetNext

				nTotEK := 0
				cSKonto:=idkonto
				do While !Eof() .and. cidfirma==idfirma .and. IdKonto==iif(fUBudzetu,cKto,cSKonto)
					if d_p=="2"
						nTotEK += IznosBHD
					else
						nTotEK -= IznosBHD
					endif
					SKIP 1
				EndDO

				? cLM
				SELECT konto
				HSEEK iif(fUBudzetu,cKto,cSKonto)
				select suban
				?? SPACE(8)
				?? iif(fUBudzetu,cKto,cSKonto), PADR (Konto->Naz, 38)
				?? TRANSFORM(nPlan,    "9,999,999,999.99"), TRANSFORM(nPlanPer, "9,999,999,999.99"), TRANSFORM(nTotEK,   "9,999,999,999.99")
				IF nPlanPer > 0
					?? " "+TRANSFORM(nTotEK*100/nPlanPer, "99,999.99")
				Else
					?? SPACE (1+9)
				EndIF
				IF nTotal > 0
					?? "   ", STR (nTotEK*100/nTotal, 6, 2)
				EndIF
				fUBudzetu:=.f.
				nL2 += nTotEK
				nPlan:=0
				nPlanPer:=0

			enddo // suban
			select budzet
			if fond="N2" .or. fond="N1"
				fLev2:=.f.  // prekini level 2
			endif

		enddo // fLev2 prekid

		IF prow()>62+gPStranica
			PR_Zagl()
			? cLM
			B_ON
			?? cLev2, cLev2Naz, "(nastavak)"
			B_OFF
		EndIF

		IF prow() > 60+gPStranica
			PR_Zagl()
		Else
			? m
		EndIF

		? cLM
		B_ON
		nPom := nPlanL2*nProc/100
		?? PADL ("UKUPNO "+cLev2+" "+cLev2Naz, nLen1), TRANSFORM(nPlanL2, "9,999,999,999.99"), TRANSFORM(nPom, "9,999,999,999.99"), TRANSFORM(nL2, "9,999,999,999.99")
		IF nPom > 0
			?? " "+TRANSFORM(nL2*100/nPom, "99,999.99")
		EndIF
		IF nTotal > 0
			?? "   ", STR (nL2*100/nTotal, 6, 2)
		EndIF
		B_OFF
		? m

		if fond="N1"
			flev1:=.f.
		endif

		nPlanL1+=nPlanL2
		nL1+=nL2

	enddo // fLEv1 prekid

	IF prow() > 63+gPStranica
		PR_Zagl()
		? cLM
		B_ON
		?? cLev1, cLev1Naz, "(nastavak)"
		B_OFF
	EndIF

	IF prow() > 60+gPStranica
		PR_Zagl()
	Else
		? m1
	EndIF

	? cLM
	B_ON

	nPom := nPlanL1*nProc/100
	?? PADL ("UKUPNO "+cLev1+" "+cLev1Naz, nLen1), TRANSFORM(nPlanL1, "9,999,999,999.99"), TRANSFORM(nPom, "9,999,999,999.99"), TRANSFORM(nL1, "9,999,999,999.99")
	IF nPom > 0
		?? " "+TRANSFORM(nL1*100/nPom, "99,999.99")
	EndIF
	IF nTotal > 0
		?? "   ", STR (nL1*100/nTotal, 6, 2)
	EndIF
	B_OFF
	? m1
	nTotPlan+=nPlanL1
	// nTotPr+=nL2
	nTotPr+=nL1

EndDO

IF prow() > 60+gPStranica
	PR_Zagl()
Else
	? m1
EndIF

nPom := nTotPlan*nProc/100
? cLM
B_ON
?? PADL ("U  K  U  P  N  O   P R I H O D I", nLen1), TRANSFORM(nTotPlan, "9,999,999,999.99"), TRANSFORM(nPom, "9,999,999,999.99"), TRANSFORM(nTotPR, "9,999,999,999.99")

IF nPom > 0
	?? " "+TRANSFORM(nTotPR*100/nPom, "99,999.99")
EndIF
IF nTotal > 0
	?? "   ", STR (nTotPR*100/nTotal, 6, 2)
EndIF
B_OFF
? m1
FF
END PRINT
return
*}


/*! \fn PR_Zagl()
 *  \brief Zaglavlje prihoda 
 */
 
function PR_Zagl()
*{
IF fPrvaStr
	fPrvaStr := .F.
Else
	FF
	? cLM+"Struktura prihoda po vrstama", Space (59), "Strana", STR (nPageNo++, 3)
EndIF
? m
? th1
? th2
? th3
? th4
? m
RETURN
*}



/*! \fn Razmak(nBrRed)
 *  \brief Daje nBrRed praznih redova
 *  \todo Treba prebaciti u /sclib
 *  \param nBrRed  - broj redova
 */
 
function Razmak(nBrRed)
*{
private i

for i:=1 to nBrRed
	?
next

return
*}



/*! \fn BuIz(cKonto)
 *  \brief Sortiraj izuzetke u budzetu
 *  \param cKonto
 */
 
function BuIz(cKonto)
*{
// primjer BUIZ: ID=6138931 , NAZ=6138910030
//                7 cifri,     10 cifri
local nselect
if cBuIz=="N"
	return cKonto
endif

nSelect:=select()
select buiz
seek cKonto
if found()
	cKonto:=naz
endif

select (nSelect)
return PADR(cKonto,10)
*}


