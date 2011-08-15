#include "sc.ch"

// -------------------------------------------------
// generise novi plu kod za sifru
// -------------------------------------------------
function gen_plu( nVal )
local nTArea := SELECT()
local nTRec := RECNO()
local nPlu := 0

if ((Ch==K_CTRL_N) .or. (Ch==K_F4))

	if LastKey() == K_ESC
		return .f.
	endif

	set order to tag "plu"
	go top
	seek STR(99999999999, 10)
	skip -1

	nPlu := field->fisc_plu
	nVal := nPlu + 1

	select (nTArea)
	set order to tag "ID"
	go (nTRec)

	AEVAL(GetList,{|o| o:display()})

endif

return .t.


// -------------------------------------------------------
// generisi PLU kodove za postojece stavke sifraranika
// -------------------------------------------------------
function gen_all_plu( lSilent )
local nPLU := 0
local lReset := .f.
local nP_PLU := 0
local nCnt 

if lSilent == nil
	lSilent := .f.
endif

O_ROBA
select ROBA
go top

// ako nema polja PLU izadji!
if roba->(FIELDPOS("FISC_PLU")) = 0
	return .f.
endif

if lSilent == .f. .and. !SigmaSIF("GENPLU")
	msgbeep("NE DIRAJ !!!")
	return .f.
endif

if lSilent == .f. .and. Pitanje(,"Resetovati postojece PLU", "N") == "D"
	lReset := .t.
endif

if lSilent == .t.
	lReset := .f.
endif

// prvo mi nadji zadnji PLU kod
select roba
set order to tag "PLU"
go top
seek str(9999999999,10)
skip -1
nP_PLU := field->fisc_plu
nCnt := 0

select roba
set order to tag "ID"
go top

Box(,1,50)
do while !EOF()
	
	if lReset == .f.
		// preskoci ako vec postoji PLU i 
		// neces RESET
		if field->fisc_plu <> 0
			skip
			loop
		endif
	endif
	
	++ nCnt
	++ nP_PLU

	replace field->fisc_plu with nP_PLU

	@ m_x + 1, m_y + 2 SAY PADR( "idroba: " + field->id + ;
		" -> PLU: " + ALLTRIM( STR( nP_PLU ) ), 30 )
	
	skip

enddo
BoxC()

if nPLU > 0
	if lSilent == .f.
		msgbeep("Generisao " + ALLTRIM(STR(nCnt)) + " PLU kodova.")
	endif
	return .t.
else
	return .f.
endif

return


// ----------------------------------------------------
// sredjuje naziv fajla za fiskalni stampac
// ----------------------------------------------------
function f_filename( cPattern, nInvoice )
local cRet := ""
cRet := STRTRAN( cPattern, "*", ALLTRIM(STR(nInvoice)) )
return cRet


// ----------------------------------------
// fajl za pos fiskalni stampac
// ----------------------------------------
function f_filepos( cBrRn )
local cRet

if ALLTRIM( gFC_Type ) == "FPRINT"
	cRet := PADL( ALLTRIM( cBrRn ), 8, "0" ) + ".TXT"
else
	cRet := PADL( ALLTRIM( cBrRn ), 8, "0" ) + ".inp"
endif
return cRet


// --------------------------------------------------
// vraca iz parametara zadnji PLU broj
// --------------------------------------------------
function last_plu()
local nPLU := 0
private cSection:="X"
private cHistory:=" "
private aHistory:={}
O_KPARAMS
select kparams

RPar( "ap", @nPLU )

return nPLU


// --------------------------------------------------
// generisanje novog plug kod-a inkrementalno
// --------------------------------------------------
function auto_plu( lReset, lSilent )
local nGenPlu := 0
local nTArea := SELECT()

private cSection:="X"
private cHistory:=" "
private aHistory:={}

if lReset == nil
	lReset := .f.
endif

if lSilent == nil
	lSilent := .f.
endif

O_KPARAMS
select kparams

if lReset = .t.
	// uzmi inicijalni plu iz parametara
	nGenPlu := gFC_pinit
else
	// iscitaj trenutni PLU KOD
	RPar( "ap", @nGenPlu )
	// uvecaj za 1
	++ nGenPlu 
endif

if lReset = .t. .and. !lSilent
	if !SigmaSif("RESET")
		select (nTArea)
		return nGenPlu
	endif
endif

// upisi generisani u parametre
WPar( "ap", nGenPlu )

select (nTArea)

return nGenPlu



// ---------------------------------------
// kreiranje tabele fdevice.dbf
// ---------------------------------------
function c_fdevice()
local aDbf := {}

AADD( aDbf, { "ID", "N", 3, 0 } )
AADD( aDbf, { "TIP", "C", 15, 0 } )
AADD( aDbf, { "OZNAKA", "C", 15, 0 } )
AADD( aDbf, { "IOSA", "C", 16, 0 } )
AADD( aDbf, { "VRSTA", "C", 1, 0 } )
AADD( aDbf, { "PATH", "C", 150, 0 } )
AADD( aDbf, { "PATH2", "C", 150, 0 } )
AADD( aDbf, { "SERIAL", "C", 15, 0 } )
AADD( aDbf, { "OUTPUT", "C", 20, 0 } )
AADD( aDbf, { "ANSWER", "C", 40, 0 } )
AADD( aDbf, { "DUZ_ROBA", "N", 3, 0 } )
AADD( aDbf, { "ERROR", "C", 1, 0 } )
AADD( aDbf, { "TIMEOUT", "N", 5, 0 } )
AADD( aDbf, { "ZBIRNI", "N", 5, 0 } )
AADD( aDbf, { "ST_PITANJE", "C", 1, 0 } )
AADD( aDbf, { "ST_BRRB", "C", 1, 0 } )
AADD( aDbf, { "ST_RAC", "C", 1, 0 } )
AADD( aDbf, { "CHECK", "N", 1, 0 } )
AADD( aDbf, { "ART_CODE", "C", 1, 0 } )
AADD( aDbf, { "INIT_PLU", "N", 6, 0 } )
AADD( aDbf, { "AUTO_P", "N", 10, 2 } )
AADD( aDbf, { "OPIS", "C", 150, 0 } )
AADD( aDbf, { "DOKUMENTI", "C", 100, 0 } )
AADD( aDbf, { "PDV", "C", 1, 0 } )
AADD( aDbf, { "D_PAR_1", "C", 10, 0 } )
AADD( aDbf, { "D_PAR_2", "C", 10, 0 } )
AADD( aDbf, { "D_PAR_3", "C", 10, 0 } )
AADD( aDbf, { "D_PAR_4", "C", 10, 0 } )
AADD( aDbf, { "D_PAR_5", "C", 10, 0 } )
AADD( aDbf, { "AKTIVAN", "C", 1, 0 } )

if !file((PRIVPATH+"FDEVICE.DBF"))
	DBCREATE2(PRIVPATH+"FDEVICE.DBF",aDbf)
endif

CREATE_INDEX("1","str(id)",PRIVPATH+"FDEVICE.DBF",.t.)

O_FDEVICE

if fdevice->(RECCOUNT()) = 0
	
	// append u tabelu FPRINT uredjaja
	select fdevice

	append blank
	replace field->id with 1
	replace field->tip with "FPRINT"
	replace field->oznaka with "FP-550"
	replace field->iosa with "1234567890123456"
	replace field->vrsta with "P"
	replace field->path with "c:\fiscal\"
	replace field->output with "out.txt"
	replace field->answer with "answer.txt"
	replace field->serial with "010730"
	replace field->duz_roba with 32
	replace field->pdv with "D"
	replace field->error with "D"
	replace field->timeout with 300
	replace field->zbirni with 0
	replace field->auto_p with 0
	replace field->st_pitanje with "D"
	replace field->st_brrb with "N"
	replace field->st_rac with "N"
	replace field->check with 1
	replace field->art_code with "D"
	replace field->init_plu with 10
	replace field->opis with "FPRINT uredjaj 1"
	replace field->dokumenti with "10#11#"
	replace field->aktivan with "N"

	
endif

return



// -----------------------------------------------------
// vraca listu uredjaja i biramo zeljeni uredjaj
// -----------------------------------------------------
function list_device( cTipDok )
local nDevice := 0
local nTArea := SELECT()

if gFc_dlist == "N"
	return -1
endif

if cTipDok == nil
	cTipDok := ""
endif

// izvuci mi listu uredjaja na osnovu tipa dokumenta
O_FDEVICE
select fdevice

nStat := fdevice->(RECCOUNT())

if nStat = 0
	
	// nema uredjaja, izadji...
	nDevice := 0
	return nDevice

elseif nStat = 1

	go top
	
	nDevice := field->id

	if field->aktivan == "D"
		if !EMPTY( cTipDok )
			if cTipDok $ field->dokumenti
				return nDevice
			endif
		endif
		return nDevice
	else
		return 0
	endif

else
	
	// sacuvaj ove varijable
	nX := m_x
	nY := m_y

	// odaberi listu, ima vise uredjaja
	aFD_list := _afd_list( cTipDok )
	
	nSelect := _fd_list( aFD_list )
	
	if nSelect >= 0
		// izaberi uredjaj iz liste
		nDevice := aFD_list[ nSelect, 2 ]
	else
		nDevice := nSelect
	endif

	m_x := nX
	m_y := nY

	return nDevice

endif

select (nTArea)

return nDevice


// -----------------------------------
// daj listu uredjaja
// -----------------------------------
static function _fd_list( aDevice )
local cTmp := ""
local i
local nSelected
private opc := {}
private opcexe := {}
private izbor := 1
private GetList := {}

for i:=1 to LEN(aDevice)

	cTmp := PADR( ALLTRIM( STR( aDevice[i, 1] )), 3 ) + ;
		"- " + PADR( ALLTRIM( aDevice[i, 3]), 50 )
	AADD( opc, cTmp )
	AADD( opcexe, { || nSelected := izbor, izbor := 0 })
next

menu_sc("fdev")

if nSelected = nil
	nSelected := -99
endif

return nSelected


// -----------------------------------
// vraca listu uredjaja
// -----------------------------------
static function _afd_list( cTipDok )
local aDevice := {}
local nCnt := 0

select fdevice
go top

do while !EOF()
		
	if field->aktivan == "N"
		skip
		loop
	endif

	if !EMPTY( cTipDok ) 
		if cTipDok $ field->dokumenti
			// ovo je ok...
			// idi dalje
		else
			skip
			loop
		endif
	endif

	// dodaj u fdevice matricu
	AADD( aDevice, { ++nCnt, field->id, ALLTRIM(field->opis) } )
	
	skip

enddo

// dodaj i stavku za ponistavanje
AADD( aDevice, { ++nCnt, -99, "--- ponisti operaciju ---"} )

return aDevice



// ------------------------------------------------------
// setuje globalne parametre stampe na osnovu uredjaja
// ------------------------------------------------------
function fdev_params( nDevice )
local nTArea := SELECT()
local nReturn := 0

O_FDEVICE

select fdevice
go top
seek str( nDevice, 3 )

if FOUND()

	nReturn := field->id
	
	// pronasao uredjaj, koristim njegove parametre
	
	// set global params...

	gFc_type := ALLTRIM( field->tip )
	gFc_device := field->vrsta 
	gFC_Path := field->path
	gFC_Path2 := field->path2
	gFC_answ := field->answer
	gFC_Name := field->output
	gFc_pitanje := field->st_pitanje
	gFc_error := field->error
	gFc_serial := field->serial
	gFc_tout := field->timeout
	gIOSA := field->iosa
	gFc_alen := field->duz_roba
	gFc_pdv := field->pdv
	gFc_nftxt := field->st_brrb
	gFc_acd := field->art_code
	gFC_pinit := field->init_plu
	gFc_chk := field->check
	gFc_faktura := field->st_rac
	gFc_zbir := field->zbirni
	gFc_pauto := field->auto_p

endif

select (nTArea)
return nReturn




