#include "sc.ch"


// ------------------------------------------------------
// kreiranje tabela DOKSRC i P_DOKSRC
// ------------------------------------------------------
function cre_doksrc()
local aDbf := {}
local cDokSrcName := "DOKSRC"
local cPDokSrcName := "P_" + cDokSrcName
local nBrDokLen := 8

if goModul:oDataBase:cName == "TOPS"
	nBrDokLen := 6
endif

// ako nije jedan od ponudjenih modula preskoci
if !(goModul:oDataBase:cName $ "FIN#KALK#FAKT#TOPS")
	return
endif

AADD(aDBf,{ "idfirma"             , "C" ,   2 ,  0 })
AADD(aDBf,{ "idvd"                , "C" ,   2 ,  0 })
AADD(aDBf,{ "brdok"               , "C" ,  nBrDokLen ,  0 })
AADD(aDBf,{ "datdok"              , "D" ,   8 ,  0 })
AADD(aDBf,{ "src_modul"           , "C" ,  10 ,  0 })
AADD(aDBf,{ "src_idfirma"         , "C" ,   2 ,  0 })
AADD(aDBf,{ "src_idvd"            , "C" ,   2 ,  0 })
AADD(aDBf,{ "src_brdok"           , "C" ,   8 ,  0 })
AADD(aDBf,{ "src_datdok"          , "D" ,   8 ,  0 })
AADD(aDBf,{ "src_kto_raz"         , "C" ,   7 ,  0 })
AADD(aDBf,{ "src_kto_zad"         , "C" ,   7 ,  0 })
AADD(aDBf,{ "src_partner"         , "C" ,   6 ,  0 })
AADD(aDBf,{ "src_opis"            , "C" ,  30 ,  0 })

// kreiraj u KUMPATH
if !FILE(KUMPATH + cDokSrcName + ".DBF")
	DBCREATE2(KUMPATH + cDokSrcName + ".DBF", aDbf)
endif
// indexi....
CREATE_INDEX("1","idfirma+idvd+brdok+DTOS(datdok)+src_modul+src_idfirma+src_idvd+src_brdok+DTOS(src_datdok)", KUMPATH + cDokSrcName)
CREATE_INDEX("2","src_modul+src_idfirma+src_idvd+src_brdok+DTOS(src_datdok)", KUMPATH + cDokSrcName)

// kreiraj u PRIVPATH
if !FILE(PRIVPATH + cPDokSrcName + ".DBF")
	DBCREATE2(PRIVPATH + cPDokSrcName + ".DBF", aDbf)
endif
// indexi....
CREATE_INDEX("1","idfirma+idvd+brdok+DTOS(datdok)+src_modul+src_idfirma+src_idvd+src_brdok+DTOS(src_datdok)", PRIVPATH + cPDokSrcName)
CREATE_INDEX("2","src_modul+src_idfirma+src_idvd+src_brdok+DTOS(src_datdok)", PRIVPATH + cPDokSrcName)

return

// ------------------------------------------------------
// dodaj novi zapis u p_doksrc
// ------------------------------------------------------
function add_p_doksrc( cFirma, cTD, cBrDok, dDatDok, ;
		cSrcModName, cSrcFirma, cSrcTD, cSrcBrDok, ;
		dSrcDatDok, cSrcKto1, cSrcKto2, cSrcPartn, ;
		cSrcOpis )

local nTArea := SELECT()

// ako ne postoji doksrc, ne radi nista!
if !is_doksrc()
	return
endif

cSrcModName := PADR(cSrcModName, 10)
cSrcBrDok := PADR(ALLTRIM(cSrcBrDok), 8)

// ako postoji zapis source-a u tabeli... preskoci
if seek_p_src(cSrcModName, cSrcFirma, cSrcTD, cSrcBrDok, dSrcDatDok)
	select (nTArea)
	return
endif

O_P_DOKSRC
select p_doksrc
append blank

replace field->idfirma with cFirma
replace field->idvd with cTD
replace field->brdok with cBrDok
replace field->datdok with dDatDok
replace field->src_modul with cSrcModName
replace field->src_idfirma with cSrcFirma
replace field->src_idvd with cSrcTD
replace field->src_brdok with cSrcBrDok
replace field->src_datdok with dSrcDatDok
replace field->src_kto_raz with cSrcKto1
replace field->src_kto_zad with cSrcKto2
replace field->src_partner with cSrcPartn
replace field->src_opis with cSrcOpis

select (nTArea)

return

// -----------------------------------
// zapuje p_doksrc
// -----------------------------------
function zap_p_doksrc()
local nTArea := SELECT()
// ako postoji tabela...
if is_doksrc()
	O_P_DOKSRC
	select p_doksrc
	zap
	select (nTArea)
endif
return


// --------------------------------------------------
// vrati iz kumulativa u pripr
// --------------------------------------------------
static function doksrc_to_p(cFirma, cIdVd, cBrDok, dDatDok)
local nTArea := SELECT()
O_DOKSRC

zap_p_doksrc()

select doksrc
set order to tag "1"
go top
seek cFirma + cIdVd + cBrDok

do while !EOF() .and. field->idfirma == cFirma ;
		.and. field->idvd == cIdVd ;
		.and. field->brdok == cBrDok
	
	Scatter()
	select p_doksrc
	append blank
	Gather()
	select doksrc
	skip
enddo

select (nTArea)
return

// ---------------------------------------------------
// brisanje zapisa iz tabele DOKSRC
// ---------------------------------------------------
static function d_doksrc(cFirma, cIdVd, cBrDok, dDatDok)
local nTArea := SELECT()

select doksrc
set order to tag "1"
go top

seek cFirma + cIdVd + cBrDok

// izbrisi iz doksrc
do while !EOF() .and. field->idfirma == cFirma ;
		.and. field->idvd == cIdVd ;
		.and. field->brdok == cBrDok
	delete
	skip
enddo

select (nTArea)
return

// -----------------------------------------------------
// povrat doksrc...
// -----------------------------------------------------
function povrat_doksrc(cFirma, cIdVd, cBrDok, dDatDok)
// doksrc -> p_doksrc
doksrc_to_p(cFirma, cIdVd, cBrDok, dDatDok)
// brisi doksrc
d_doksrc(cFirma, cIdVd, cBrDok, dDatDok)
return




// -----------------------------------------
// provjerava da li postoje tabele DOKSRC
// -----------------------------------------
function is_doksrc()
local lRet := .f.
if FILE(KUMPATH + "DOKSRC.DBF")
	lRet := .t.
endif
return lRet


// ------------------------------------------------------
// azuriraj p_doksrc -> doksrc
// ------------------------------------------------------
function p_to_doksrc()
local nTArea := SELECT()
local nTRecNR := (nTArea)->(RecNo())

// ako ne postoji doksrc, ne radi nista!
if !is_doksrc()
	return
endif

O_P_DOKSRC
O_DOKSRC

select p_doksrc
go top

// provjeri broj zapisa...
if p_doksrc->(RecCount2()) == 0 
	select (nTArea)
	return
endif

// izbrisi ako vec postoji taj dokument...
d_doksrc(p_doksrc->idfirma, p_doksrc->idvd, p_doksrc->brdok, p_doksrc->datdok)

select p_doksrc
go top

MsgO("Azuriram DOKSRC....")

do while !EOF()
	
	Scatter()
	
	select doksrc
	
	append blank
	
	Gather()
	
	select p_doksrc
	
	skip
enddo

MsgC()

select p_doksrc
zap

select (nTArea)
return


// ----------------------------------------------------
// seekuj p_doksrc za dokumentom, da li postoji
// ----------------------------------------------------
static function seek_p_dok(cFirma, cIdVd, cBrDok, dDatum)
local nTArea := SELECT()
local cSeek 
local lReturn := .f.

O_P_DOKSRC
select p_doksrc
set order to tag "1"
go top

cSeek := cFirma

if cIdVD <> nil
	cSeek += cIdVd
endif
if cBrDok <> nil
	cSeek += cBrDok
endif
if dDatum <> nil
	cSeek += DTOS(dDatum)
endif

seek cSeek

if FOUND()
	lReturn := .t.
endif

select (nTArea)

return lReturn



// ----------------------------------------------------
// seekuj p_doksrc za src dokumentom, da li postoji
// ----------------------------------------------------
static function seek_p_src(cModul, cFirma, cIdVd, cBrDok, dDatum)
local nTArea := SELECT()
local cSeek 
local lReturn := .f.

O_P_DOKSRC
select p_doksrc
set order to tag "2"
go top

cSeek := cModul + cFirma

if cIdVD <> nil
	cSeek += cIdVd
endif

if cBrDok <> nil
	cSeek += cBrDok
endif

if dDatum <> nil
	cSeek += DTOS(dDatum)
endif

seek cSeek

if FOUND()
	lReturn := .t.
endif

set order to tag "1"

select (nTArea)

return lReturn


