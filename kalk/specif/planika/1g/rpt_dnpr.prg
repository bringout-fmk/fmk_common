#include "\cl\sigma\fmk\kalk\kalk.ch"

*string
static cLinija
*;

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/specif/planika/1g/rpt_dnpr.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.1 $
 * $Log: rpt_dnpr.prg,v $
 * Revision 1.1  2002/06/29 14:43:18  ernad
 *
 *
 * prebacen rpt_dnp.prg, init rpt_ppp.prg
 *
 * Revision 1.4  2002/06/24 09:04:20  ernad
 *
 * ciscenja
 *
 * Revision 1.3  2002/06/24 08:57:02  ernad
 *
 *
 * skratiti dijalog, promjena imena parametra
 *
 * Revision 1.2  2002/06/21 12:12:43  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/prod/rpt/1g/rpt_dnpr.prg
 *  \brief Izvjestaj dnevnog prometa
 */


/*! \fn DnevProm()
 *  \brief Izvjestaj dnevnog prometa
 *  \todo Ovaj izvjestaj nije dobro uradjen - formira se matrica, koja ce puci na velikom broju artikala
 */

function DnevProm()
*{
local i
local cOldIni
local dDan
local cTops
local cPodvuci
local aR

private cFilter

gPINI:=""
dDan:=DATE()
cTops:="D"
cPodvuci:="N"
cFilterDn:="D"

cLinija:="----- ---------- ---------------------------------------- --- ---------- -------------"

cFilter:=IzFmkIni("KALK","UslovPoRobiZaDnevniPromet","(IDROBA=01)", KUMPATH)

if GetVars(@dDan, @cTops, @cPodvuci, @cFilterDn, @cFilter)==0
	return
endif

aR:={}
if (cTops=="D")
	if ScanTops(dDan, @aR)==0
		return
	endif
else
	if ScanKalk(dDan, @aR)==0
		return
	endif
endif

cOldIni:=gPINI
StartPrint(.t.)
nStr:=1
Header(dDan, @nStr)

nUk:=0
for i:=1 TO LEN(aR)
	? STR(i,4)+"."
	?? "", PADR(aR[i,1],10)
	?? "", PADR(aR[i,2],40)
	?? "", PADR(aR[i,3], 3)
	?? "", TRANS(aR[i,4],"999999999")
	?? "", TRANS(aR[i,5],"9999999999.99")
	if (cPodvuci=="D")
		?  cLinija
	endif
	nUk+=aR[i,6]
next
Footer(cPodvuci, nUk)
EndPrint()
  
gPINI:=cOldIni
CopyZaSlanje(dDan)

CLOSERET
return
*}


static function ScanTops(dDan, aR)
*{
local cTSifP
local nSifP
local cTKumP
local nMpcBp

O_TARIFA
O_KONCIJ

if FIELDPOS("KUMTOPS")=0
	MsgBeep("Prvo izvrsite modifikaciju struktura pomocu KALK.CHS !")
	CLOSE ALL
	return 0
endif
GO TOP

do while (!EOF())
	cTSifP:=TRIM(SIFTOPS)
	cTKumP:=TRIM(KUMTOPS)
	if EMPTY(cTSifP) .or. EMPTY(cTKumP)
		SKIP 1
		loop
	endif
	AddBs(@cTKumP)
	AddBs(@cTKumP)
	AddBs(@cTSifP)
	
	if (!FILE(cTKumP+"POS.DBF") .or. !FILE(cTKumP+"POS.CDX"))
		SKIP 1
		loop
	endif
	
	SELECT 0
	if !FILE(cTSifP+"ROBA.DBF") .or. !FILE(cTSifP+"ROBA.CDX")
		use (SIFPATH+"ROBA")
		set order to tag "ID"
	else
		use (cTSifP+"ROBA")
		set order to tag "ID"
	endif
	
	SELECT 0
	use (cTKumP+"POS")
	// dtos(datum)
	SET ORDER TO TAG "4" 

	SEEK dtos(dDan)
	do while !EOF() .and. dtos(datum)==dtos(dDan)
		if field->idvd<>"42"
			skip
			loop
		endif
		if (cFilterDn=="D")
			if .not. &cFilter 
				SKIP 1
				loop
			endif
		endif

		SELECT roba
		SEEK pos->idroba
		SELECT tarifa
		SEEK roba->idtarifa
		SELECT POS

		nMpcBP:=ROUND(cijena/(1+tarifa->zpp/100+tarifa->ppp/100)/(1+tarifa->opp/100),2)
		SELECT POS
		if !LEN(aR)>0 .or. !((nPom:=ASCAN(aR,{|x| x[1]==idroba}))>0)
			AADD(aR,{idroba,ROBA->naz,ROBA->jmj,kolicina, nMpCBP , cijena*kolicina})
		else
			aR[nPom,4] += kolicina
			aR[nPom,6] += nMpCBP*kolicina
		endif
		SKIP 1
	enddo

	SELECT roba
	USE
	SELECT pos
	USE
	SELECT koncij
	SKIP 1
enddo

ASORT(aR,,,{|x,y|x[1]<y[1]})

return 1
*}

static function ScanKalk()
*{

O_ROBA
O_KALK
// idFirma+dtos(datdok)+podbr+idvd+brdok
SET ORDER TO TAG "5"      

SEEK gFirma+dtos(dDan)
do while !EOF() .and. dtos(datdok)==dtos(dDan)
	if !(field->pkonto="132" .and. LEFT(field->idVd,1)=="4")
		SKIP 1
		loop
	endif
	if !LEN(aR)>0 .or. !((nPom:=ASCAN(aR,{|x| x[1]==idroba}))>0)
		AADD(aR,{ field->idRoba,"","", field->kolicina, field->mpc , field->mpc* field->kolicina})
	else
		aR[nPom,4] += field->kolicina
		aR[nPom,6] += field->mpc*field->kolicina
	endif
	SKIP 1
enddo

ASORT(aR,,,{|x,y|x[1]<y[1]})
SELECT ROBA
for i:=1 to LEN(aR)
	HSEEK aR[i,1]
	aR[i,2] := field->naz
	aR[i,3] := field->jmj
next

return 1
*}

static function GetVars(dDan, cTops, cPodvuci, cFilterDn, cFilter)
*{
local cIspraviFilter

cIspraviFilter:="N"
cFilterDn:="N"
Box("#DNEVNI PROMET", 9, 60)

@ m_x+2, m_y+2 SAY "Za dan" GET dDan
@ m_x+3, m_y+2 SAY "Izvor podataka su kase tj. TOPS (D/N) ?" GET cTops VALID cTops $ "DN" PICT "@!"
@ m_x+4, m_y+2 SAY "Linija ispod svakog reda (D/N) ?" GET cPodvuci VALID cPodvuci $ "DN" PICT "@!"
@ m_x+5, m_y+2 SAY "Uzeti u obzir filter (D/N) ?" GET cFilterDn VALID cFilterDn $ "DN" PICT "@!"
READ

if (cFilterDn=="D")
	@ m_x+7, m_y+2 SAY "Pregled, ispravka filtera " GET cIspraviFilterDn VALID cIspraviFilter $ "DN" PICTURE "@!"
	READ
	cFilter:=PADR(cFilter,200)
	if (cIspraviFilter=="D")
		@ m_x+8, m_y+2 SAY "Filter " GET cFilter PICTURE "@S30"
		READ
	endif
	cFilter:=TRIM(cFilter)
endif

if (LASTKEY()==K_ESC)
	BoxC()
	return 0
endif

BoxC()

return 1
*}


static function Header(dDan, nStr)
*{
local b1
local b2
local b3

b1 := {|| QOUT( "KALK: EVIDENCIJA DNEVNOG PROMETA U MALOPRODAJI NA DAN "+dtoc(dDan),"    Str."+LTRIM(STR(nStr))  ) }

b2 := {|| QOUT( "ID PM:",IzFMKIni("ZaglavljeDnevnogPrometa","IDPM" ,"01    - Planika Flex BiH",EXEPATH)          ) }

b3 := {|| QOUT( "KONTO:",IzFMKIni("ZaglavljeDnevnogPrometa","KONTO","132   - ROBA U PRODAVNICI",EXEPATH)         ) }

EVAL(b1)
EVAL(b2)
EVAL(b3)

? cLinija
? " R.  *  SIFRA   *      N A Z I V    A R T I K L A        *JMJ* KOLICINA *   MPC-PPP  *"
? " BR. * ARTIKLA  *                                        *   *          *            *"
? cLinija
return
*}

static function Footer(cPodvuci, nUk)
*{
? cLinija
? PADR("UKUPNO:",72), TRANS(nUk,"999999999.99")
? cLinija

return
*}

static function CopyZaSlanje(dDan)
*{
local cS
local cLokS
local cNf
local cDirDest

private cPom

cNF:="FL"+STRTRAN(DTOC(dDan),".","")+".TXT"

if Pitanje(,"Zelite li snimiti dokument radi slanja ?","N")=="N"
	return 0
endif

SAVE SCREEN TO cS
CLS

cDirDest:=ToUnix("C:"+SLASH+"SIGMA"+SLASH+"SALJI"+SLASH)
cLokS:=IzFMKIni("FMK", "LokacijaZaSlanje", cDirDest , EXEPATH)
cPom:="copy "+PRIVPATH+"OUTF.TXT "+cLokS+cNf

RUN &cPom

RESTORE SCREEN FROM cS
if FILE(cLokS+cNf)
	MsgBeep("Kopiranje dokumenta zavrseno!")
else
	MsgBeep("KOPIRANJE FAJLA-IZVJESTAJA NIJE USPJELO!")
endif

return
*}

