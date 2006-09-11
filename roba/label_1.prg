#include "sc.ch"


// -----------------------------------
// labeliranje delphi 
// -----------------------------------
function label_1_delphi(aStampati)
local nRezerva
local cIBK
local cLinija1
local cLinija2
local cPrefix
local cSPrefix
local nRobNazLen
local cIdTipDok
local lBKBrDok := .f.
local lBKJmj := .f.
local cBrDok

if IzFmkIni("Barkod", "JMJ", "D", SIFPATH) == "D"
	lBKJmj := .t.
endif

if IzFmkIni("Barkod", "BrDok", "D", SIFPATH) == "D"
	lBKBrDok := .t.
endif

if goModul:oDataBase:cName == "KALK"
	cIdTipDok := "IDVD"
else
	cIdTipDok := "IDTIPDOK"
endif

nRezerva := 0

cLinija1 := PADR("Proizvoljan tekst", 45)
cLinija2 := PADR("Uvoznik:" + gNFirma, 45)

Box(,4,75)
	@ m_x+0, m_y+25 SAY " LABELIRANJE BAR KODOVA "
	@ m_x+2, m_y+ 2 SAY "Rezerva (broj komada):" GET nRezerva VALID nRezerva>=0 PICT "99"
	if !lBKBrDok
		@ m_x+3, m_y+2 SAY "Linija 1  :" GET cLinija1
	endif
	@ m_x+4, m_y+ 2 SAY "Linija 2  :" GET cLinija2
	READ
	ESC_BCR
BoxC()

cPrefix := IzFmkIni("Barkod","Prefix","",SIFPATH)
cSPrefix := Pitanje(,"Stampati barkodove koji NE pocinju sa +'"+cPrefix+"' ?","N")

SELECT BARKOD
ZAP
SELECT PRIPR
GO TOP

do while !EOF()

	if aStampati[ RECNO() ]=="N"
		SKIP 1
		loop
	endif
	
	SELECT ROBA
	HSEEK PRIPR->idroba
	
	if empty(barkod).and.(IzFmkIni("BarKod","Auto","N",SIFPATH)=="D")
		
		private cPom:=IzFmkIni("BarKod","AutoFormula","ID",SIFPATH)
		
		// kada je barkod prazan, onda formiraj sam interni barkod
		cIBK:=IzFmkIni("BARKOD","Prefix","",SIFPATH) + &cPom
		
		if IzFmkIni("BARKOD","EAN","",SIFPATH) == "13"
			cIBK := NoviBK_A()
		endif
		
		PushWa()
		
		set order to tag "BARKOD"
		seek cIBK
		
		if found()
			PopWa()
			MsgBeep("Prilikom formiranja internog barkoda##vec postoji kod: "+cIBK+"??##"+"Moracete za artikal "+pripr->idroba+" sami zadati jedinstveni barkod !")
			replace barkod with "????"
		else
			PopWa()
			replace barkod with cIBK
		endif
	endif
	
	if cSprefix=="N"
		// ne stampaj koji nemaju isti prefix
		if left(barkod,len(cPrefix))!=cPrefix
			select pripr
			skip
			loop
		endif
	endif

	SELECT BARKOD
	for i:=1 to pripr->kolicina+IF(pripr->kolicina>0, nRezerva, 0)
		
		APPEND BLANK
		REPLACE id WITH KonvZnWin(pripr->idRoba)
		
		if lBKBrDok
			cBrDok := TRIM(pripr->(idfirma + "-" + &cIdTipDok + "-" + brdok))
			REPLACE l1 WITH KonvZnWin( DTOC(PRIPR->datdok) + ", " + cBrDok )
		else
			REPLACE l1 WITH KonvZnWin(cLinija1)
		endif
		
		REPLACE l2 WITH KonvZnWin(cLinija2)
		
		REPLACE vpc WITH ROBA->vpc
		REPLACE mpc WITH ROBA->mpc
		REPLACE barkod WITH roba->barkod
	
		nRobNazLen := LEN(roba->naz)
		
		if !lBKJmj
			REPLACE naziv WITH KonvZnWin(TRIM(LEFT(ROBA->naz, nRobNazLen)))
		else
			REPLACE naziv WITH KonvZnWin(TRIM(LEFT(ROBA->naz, nRobNazLen)) + " ("+TRIM(ROBA->jmj)+")")
		endif
	next
	SELECT PRIPR
	SKIP 1
enddo
close all

if Pitanje(,"Aktivirati Win Report ?","D")=="D"
	cKomLin := "DelphiRB "+IzFmkIni("BARKOD","NazRTM","barkod", SIFPATH)+" "+PRIVPATH+"  barkod 1"
	run &cKomLin
endif

return


