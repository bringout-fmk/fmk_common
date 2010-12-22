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
function gen_all_plu()
local nPLU := 0
local lReset := .f.
local nP_PLU := 0
local nCnt 

O_ROBA
select ROBA
go top

if !SigmaSIF("GENPLU")
	msgbeep("NE DIRAJ !!!")
	return .f.
endif

if Pitanje(,"Resetovati postojece PLU", "N") == "D"
	lReset := .t.
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
	msgbeep("Generisao " + ALLTRIM(STR(nCnt)) + " PLU kodova.")
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


