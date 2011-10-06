/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "fmk.ch"


/*! \fn GetKalkVars(cFirma, cKonto, cPath)
 *  \brief Vraca osnovne var.za rad sa kalk-om
 *  \param cFirma - id firma kalk
 *  \param cKonto - konto prodavnice u kalk-u
 *  \param cPath - putanja do kalk.dbf
 */
function GetKalkVars(cFirma, cKonto, cPath)
// firma je uvijek 50
cFirma:="50"
// konto prodavnicki
cKonto := IzFmkIni("TOPS", "TopsKalkKonto", "13270", KUMPATH)
cKonto := PADR(cKonto, 7)
// putanja
cPath := IzFmkIni("TOPS", "KalkKumPath", "i:\sigma", KUMPATH)
return



/*! \fn IntegTekGod()
 *  \brief Vraca tekucu godinu, ako je tek.datum veci od 10.01.TG onda je godina = TG, ako je tek.datum <= 10.01.TG onda je godina (TG - 1)
 *  \return string cYear
 */
function IntegTekGod()
*{
local dTDate
local dPDate
local dTYear
local cYear

dTYear := YEAR(DATE()) // tekuca godina
dPDate := SToD(ALLTRIM(STR(dTYear))+"0110") // preracunati datum
dTDate := DATE() // tekuci datum

if dTDate > dPDate
	cYear := ALLTRIM( STR( YEAR( DATE() ) ))	
else
	cYear := ALLTRIM( STR( YEAR( DATE() ) - 1 ))
endif

return cYear
*}

/*! \fn IntegTekDat() 
 *  \brief Vraca datum od kada pocinje tekuca godina TOPS, 01.01.TG
 */
function IntegTekDat()
*{
local dYear
local cDate

dYear := YEAR(DATE())
cDate := ALLTRIM( IntegTekGod() ) + "0101"

return SToD(cDate)
*}

/*! \fn AddToErrors(cType, cIdRoba, cDoks, cOpis)
 *  \brief dodaj zapis u tabelu errors
 */
function AddToErrors(cType, cIDroba, cDoks, cOpis)
*{
O_ERRORS
append blank
replace field->type with cType
replace field->idroba with cIdRoba
replace field->doks with cDoks
replace field->opis with cOpis

return
*}


/*! \fn GetErrorDesc(cType)
 *  \brief Vrati naziv greske po cType
 *  \param cType - tip greske, C, W, N ...
 */
function GetErrorDesc(cType)
*{
cRet := ""
do case
	case cType == "C"
		cRet := "Critical:"
	case cType == "N"
		cRet := "Normal:  "
	case cType == "W"
		cRet := "Warrning:"
	case cType == "P"
		cRet := "Probably OK:"
endcase

return cRet
*}


/*! \fn RptInteg()
 *  \brief report nakon testa integ1
 *  \param lFilter - filter za kriticne greske
 *  \param lAutoSent - automatsko slanje email-a
 */
function RptInteg(lFilter, lAutoSent)
*{
if (lFilter == nil)
	lFilter := .f.
endif
if (lAutoSent == nil)
	lAutoSent := .f.
endif

O_ERRORS
select errors
set order to tag "1"
if RecCount() == 0
	MsgBeep("Integritet podataka ok")
	//return
endif

lOnlyCrit:=.f.
if lFilter .and. Pitanje(,"Prikazati samo critical errors (D/N)?","N")=="D"
	lOnlyCrit:=.t.
endif

START PRINT CRET

? "Rezultati analize integriteta podataka"
? "===================================================="
?

nCrit:=0
nNorm:=0
nWarr:=0
nPrOk:=0
nCnt:=1
cTmpDoks:="XXXX"


go top
do while !EOF()
	cErRoba := field->idroba
	if lOnlyCrit .and. ALLTRIM(field->type) == "C"
		? STR(nCnt, 4) + ". " + ALLTRIM(field->idroba)
	endif
	if !lOnlyCrit
		? STR(nCnt, 4) + ". " + ALLTRIM(field->idroba)
	endif
	
	do while !EOF() .and. field->idroba == cErRoba
		
		if lOnlyCrit .and. ALLTRIM(field->type) <> "C"
			skip
			loop
		endif
		
		// ako je prazno DOKSERR onda fali doks
		if cErRoba = "DOKSERR"
			if ALLTRIM(field->doks) == cTmpDoks
				skip
				loop
			endif
		endif
		
		cTmpDoks := ALLTRIM(field->doks)
		
		++nCnt
		
		? SPACE(5) + GetErrorDesc(ALLTRIM(field->type)), ALLTRIM(field->doks), ALLTRIM(field->opis)	
	
		if ALLTRIM(field->type) == "C"
			++ nCrit 
		endif
		if ALLTRIM(field->type) == "N"
			++ nNorm 
		endif
		if ALLTRIM(field->type) == "W"
			++ nWarr 
		endif
		if ALLTRIM(field->type) == "P"
			++ nPrOk
		endif
	
		skip
	enddo
enddo

?
? "-----------------------------------------"
? "Critical errors:", ALLTRIM(STR(nCrit))
? "Normal errors:", ALLTRIM(STR(nNorm))
? "Warrnings:", ALLTRIM(STR(nWarr))
? "Probably OK:", ALLTRIM(STR(nPrOK))
?
?

FF
END PRINT

RptSendEmail(lAutoSent)

return
*}

/*! \fn RptSendEmail()
 *  \brief Slanje reporta na email
 */
function RptSendEmail(lAuto)
*{
local cScript
local cPSite
local cRptFile

if (lAuto == nil)
	lAuto := .f.
endif
// postavi pitanje ako nije lAuto
if !lAuto .and. Pitanje(,"Proslijediti report email-om (D/N)?", "D") == "N"
	return
endif

// setuj varijable
GetSendVars(@cScript, @cPSite, @cRptFile)
// komanda je sljedeca
cKom := cScript + " " + cPSite + " " + cRptFile 

// snimi sliku i ocisti ekran
save screen to cRbScr
clear screen

? "err2mail send..."
// pokreni komandu
run &cKom

Sleep(3)
// vrati staro stanje ekrana
restore screen from cRbScr

return
*}


/*! \fn GetSendVars(cScript)
 *  \param cScript - ruby skripta
 *  \param cPSite - prodavnicki site
 *  \param cRptFile - report fajl
 */
function GetSendVars(cScript, cPSite, cRptFile)
*{
cScript := IzFmkIni("Ruby","Err2Mail","c:\sigma\err2mail.rb", EXEPATH)
cPSite := ALLTRIM(STR(gSqlSite))
cRptFile := PRIVPATH + "outf.txt"
return
*}



/*! \fn BrisiError()
 *  \brief Brisanje tabele Errors.dbf
 */
function BrisiError()
*{
O_ERRORS
select errors
zap
return
*}




/*! \fn EmptDInt(nInteg)
 *  \brief Da li je prazna tabela dinteg
 */
function EmptDInt(nInteg)
*{
local cInteg := ALLTRIM(STR(nInteg))
local cTbl := "DINTEG" + cInteg
O_DINTEG1
O_DINTEG2
select &cTbl

if RecCount() == 0
	MsgBeep("Tabela " + cTbl + " je prazna !!!")
	return .t.
else
	return .f.
endif

return
*}



function SetGenSif1()
*{
// da li je generisan log
if ALLTRIM(integ1->c3) == "G"
	return .t.
else
	replace integ1->c3 with "G"
	return .f.
endif
return .f.
*}


function SetGenSif2()
*{
// da li je generisan log
if ALLTRIM(integ2->c3) == "G"
	return .t.
else
	replace integ2->c3 with "G"
	return .f.
endif
return .f.
*}


// provjera tabele robe
function roba_integ(cPKonto, cFmkSifPath, cPosSifPath, cPosKumPath)
local cRobaName := "ROBA"
local cPosName := "POS"

cFmkSifPath := ALLTRIM(cFmkSifPath)
AddBS(@cFmkSifPath)

cPosSifPath := ALLTRIM(cPosSifPath)
AddBS(@cPosSifPath)

cPosKumPath := ALLTRIM(cPosKumPath)
AddBS(@cPosKumPath)

// FMK roba
select (F_ROBA)
use (cFmkSifPath + cRobaName)
set order to tag "ID"

// POS roba
select (0)
use (cPosSifPath + cRobaName) alias P_ROBA
set order to tag "ID"

// POS kumulativ
select (249)
use (cPosKumPath + cPosName) alias P_POS
// idroba
set order to tag "6"

MsgO("integritet roba pos->fmk....")
// provjeri u smijeru pos->fmk
pos_fmk_roba(cPKonto)
MsgC()

// zatvori tabele
select roba
use

select p_roba
use

select p_pos
use

return


// provjera u smijeru pos->fmk
static function pos_fmk_roba(cPKonto)
local cRTemp

select p_roba
go top

do while !EOF() 

	cRTemp := field->id

	// provjeri da li se spominje u POS-u
	select p_pos
	hseek cRTemp
	
	// ako se ne spominje i preskoci ga, ovo je nebitna sifra...
	if !FOUND()
		select p_roba
		skip
		loop
	endif
	
	select roba
	hseek cRTemp
	
	if !FOUND()
		AddToErrors("C", cRTemp, "", "Konto: " + ALLTRIM(cPKonto) + ", FMK, nepostojeca sifra artikla !!!")
	endif
	
	select p_roba
	skip
enddo

return


// provjera u smijeru fmk->pos
static function fmk_pos_roba(cSifra)
select p_roba
go top
seek cSifra

if !Found()
	AddToErrors("C", cSifra, "", "TOPSK, nepostojeca sifra artikla !!!")
endif
return


