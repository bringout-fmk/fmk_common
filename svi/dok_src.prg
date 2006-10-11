#include "sc.ch"


// ------------------------------------------------------
// kreiranje tabela DOKSRC i P_DOKSRC
// ------------------------------------------------------
function cre_doksrc()
local aDbf := {}
local cDokSrcName := "DOKSRC"
local cPDokSrcName := "P_" + cDokSrcName

// ako nije jedan od ponudjenih modula preskoci
if !(goModul:oDataBase:cName $ "FIN#KALK#FAKT#TOPS")
	return
endif

AADD(aDBf,{ "idfirma"             , "C" ,   2 ,  0 })
AADD(aDBf,{ "idvd"                , "C" ,   2 ,  0 })
AADD(aDBf,{ "brdok"               , "C" ,  10 ,  0 })
AADD(aDBf,{ "datdok"              , "D" ,   8 ,  0 })
AADD(aDBf,{ "src_modul"           , "C" ,  10 ,  0 })
AADD(aDBf,{ "src_idfirma"         , "C" ,   2 ,  0 })
AADD(aDBf,{ "src_idvd"            , "C" ,   2 ,  0 })
AADD(aDBf,{ "src_brdok"           , "C" ,  10 ,  0 })
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
CREATE_INDEX("1","idfirma+idvd+brdok+DTOS(datdok)", KUMPATH + cDokSrcName)

// kreiraj u PRIVPATH
if !FILE(PRIVPATH + cPDokSrcName + ".DBF")
	DBCREATE2(PRIVPATH + cPDokSrcName + ".DBF", aDbf)
endif
// indexi....
CREATE_INDEX("1","idfirma+idvd+brdok+DTOS(datdok)", PRIVPATH + cPDokSrcName)
CREATE_INDEX("2","src_modul+src_idfirma+src_idvd+src_brdok+DTOS(src_datdok)", PRIVPATH + cPDokSrcName)

return

// ------------------------------------------------------
// dodaj novi zapis u p_doksrc
// ------------------------------------------------------
function add_p_doksrc( cFirma, cTD, cBrDok, dDatDok, ;
		cSrcModName, cSrcFirma, cSrcTD, cSrcBrDok, ;
		dSrcDatDok, cSrcKto1, cSrcKto2, cSrcPartn, cSrcOpis )

local nTArea := SELECT()

// ako postoji zapis u tabeli... preskoci
if seek_p_doksrc(cSrcModName, cSrcFirma, cSrcTD, cSrcBrDok, dSrcDatDok)
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


// ------------------------------------------------------
// azuriraj p_doksrc -> doksrc
// ------------------------------------------------------
function p_to_doksrc()
local nTArea := SELECT()
local nTRecNR := (nTArea)->(RecNo())

O_P_DOKSRC
O_DOKSRC

select p_doksrc
go top

// provjeri broj zapisa...
if p_doksrc->(RecCount2()) == 0 
	select (nTArea)
	return
endif


do while !EOF()
	
	Scatter()
	
	select doksrc
	
	append blank
	
	Gather()
	
	select p_doksrc
	
	skip
enddo

select p_doksrc
zap

select (nTArea)
return


// ----------------------------------------------------
// seekuj p_doksrc za src dokumentom, da li postoji
// ----------------------------------------------------
function seek_p_doksrc(cModul, cFirma, cIdVd, cBrDok, dDatum)
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


