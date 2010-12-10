#include "sc.ch"

// ----------------------------------------------
// kopiranje fajlova
// ----------------------------------------------
function _txt_copy( cFile, cDest )
local cScreen

save screen to cScreen

cKLin := "copy " + PRIVPATH + cFile + " " + cDest
run &cKLin

restore screen from cScreen

return


// -------------------------------------------------
// vraca strukturu za generisanje fajlova 
// -------------------------------------------------
function _g_f_struct( cFileName )
local aRet := {}

// iza opisa u komentarima su date pozicije u txt fajlu

do case

	case cFileName == "RACUN_TXT"
		
		// fiskalni racun broj (1-5)
		AADD( aRet, { "N", 5, 0 } )
		// tip racuna (6)
		AADD( aRet, { "N", 1, 0 } )
		// storno stavka identifikator (7)
		AADD( aRet, { "N", 1, 0 } )
		// fiskalna sifra robe (8-12)
		AADD( aRet, { "N", 5, 0 } )
		// naziv robe (13-44)
		AADD( aRet, { "C", 32, 0 } )
		// barkod (45-58)
		AADD( aRet, { "C", 14, 0 } )
		// sifra grupe robe (59-60)
		AADD( aRet, { "N", 2, 0} )
		// sifra poreske stope (61)
		AADD( aRet, { "N", 1, 0 } )
		// cijena robe (62-74)
		AADD( aRet, { "N", 12, 2 } )
		// kolicina robe (75-87)
		AADD( aRet, { "N", 12, 2 } )

	case cFileName == "RACUN_PLA"

		// fiskalni racun broj (1-5)
		AADD( aRet, { "N", 5, 0 } )
		// tip racuna (6)
		AADD( aRet, { "N", 1, 0 } )
		// nacin placanja (7)
		AADD( aRet, { "N", 1, 0 } )
		// uplaceno (8-12)
		AADD( aRet, { "N", 12, 2 } )
		// total racuna (13-20)
		AADD( aRet, { "N", 12, 2 } )
		// povrat novca (21-33)
		AADD( aRet, { "N", 12, 2 } )

	case cFileName == "RACUN_MEM"
		
		// slobodan red teksta
		AADD( aRet, { "C", 32, 0 })

	case cFileName == "SEMAFOR"

		// redni broj racuna-nivelacije-operacije (1-5)
		AADD( aRet, { "N", 5, 0 })
		// tip knjizenja - komanda operacije (6-10)
		AADD( aRet, { "N", 5, 0 })
		// print memo identifikator od broja (11-15)
		AADD( aRet, { "N", 5, 0 })
		// print memo identifikator do broja (16-20)
		AADD( aRet, { "N", 5, 0 })
		// fiskalna sifra kupca za veleprodaju ili 0 (21-25)
		AADD( aRet, { "N", 5, 0 })
		// broj reklamnog racuna (26-31)
		AADD( aRet, { "N", 5, 0 })
	
	case cFileName == "NIVELACIJA"

		// redni broj nivelacije (1-5)
		AADD( aRet, { "N", 5, 0 })
		// fiskalna sifra robe (6-10)
		AADD( aRet, { "N", 5, 0 })
		// naziv robe (11-42)
		AADD( aRet, { "C", 32, 0 })
		// barkod (43-56)
		AADD( aRet, { "C", 14, 0 })
		// sifra grupe (57-58)
		AADD( aRet, { "N", 2, 0 })
		// sifra poreske stope (59)
		AADD( aRet, { "N", 1, 0 })
		// cijena robe (60-72)
		AADD( aRet, { "N", 12, 2 })

	case cFileName == "POREZI"
	
		// sifra stope (1)
		AADD( aRet, { "N", 1, 0 })
		// naziv poreske stope u pravilniku (2-17)
		AADD( aRet, { "C", 16, 0 })
		// poreska stopa procenat (18-22)
		AADD( aRet, { "N", 5, 2 })

	case cFileName == "ROBA"
		
		// sifra robe (1-5)
		AADD( aRet, { "N", 5, 0 })
		// naziv robe (6-37)
		AADD( aRet, { "C", 32, 0 })
		// barkod (38-51)
		AADD( aRet, { "C", 14, 0 })
		// sifra grupe (52-53)
		AADD( aRet, { "N", 2, 0 })
		// sifra poreske stope (54)
		AADD( aRet, { "N", 1, 0 })
		// cijena robe (55-67)
		AADD( aRet, { "N", 12, 2 })
	
	case cFileName == "ROBAGRUPE"
	
		// sifra  (1-2)
		AADD( aRet, { "N", 2, 0 })
		// naziv  (3-19)
		AADD( aRet, { "C", 17, 0 })

	case cFileName == "PARTNERI"
	
		// sifra  (1-5)
		AADD( aRet, { "N", 5, 0 })
		// naziv  (6-36)
		AADD( aRet, { "C", 31, 0 })
		// adresa A (37-67)
		AADD( aRet, { "C", 31, 0 })
		// adresa B (68-98)
		AADD( aRet, { "C", 31, 0 })
		// adresa C (99-129)
		AADD( aRet, { "C", 31, 0 })
		// IBO (130-150)
		AADD( aRet, { "C", 21, 2 })

	case cFileName == "OPERATERI"
		
		// sifra operatera (1-2)
		AADD( aRet, { "N", 2, 0 })
		// naziv operatera (3-18)
		AADD( aRet, { "C", 16, 0 })
		// lozinka (19-38)
		AADD( aRet, { "C", 20, 0 })

	case cFileName == "OBJEKTI"
		
		// sifra  (1-5)
		AADD( aRet, { "N", 5, 0 })
		// naziv  (6-36)
		AADD( aRet, { "C", 31, 0 })
		// telefonski broj (37-67)
		AADD( aRet, { "C", 31, 0 })
		// naziv firme (68-98)
		AADD( aRet, { "C", 31, 0 })
		// adresa firme (99-129)
		AADD( aRet, { "C", 31, 0 })
		// poreski broj (130-160)
		AADD( aRet, { "C", 31, 0 })

	case cFileName == "POS_RN"
		
		// pos racun - stavke
		AADD( aRet, { "C", 100, 0 } )
		
endcase

return aRet



// ----------------------------------------------------------
// upisi u fajl
// ----------------------------------------------------------
function _a_to_file( cFilePath, cFileName, aStruct, aData, ;
	cSeparator, lTrim, lLastSep )
local i 
local ii
local cLine := ""
local nCount := 0
local cNumFill := "0"

if cSeparator == nil
	cSeparator := ""
endif

if lTrim == nil
	lTrim := .f.
endif

if lLastSep == nil
	lLastSep := .t.
endif

cFile := ALLTRIM( cFilePath ) + ALLTRIM( cFileName )

set printer to (cFile)
set printer on
set console off

// prodji kroz podatke u aData
for i := 1 to LEN( aData )
	
	cLine := ""

	// prodji kroz strukturu jednog zapisa u matrici
	// i napuni liniju...
	for ii := 1 to LEN( aStruct )
		
		cType := aStruct[ii, 1]
		nLen := aStruct[ii, 2]
		nDec := aStruct[ii, 3]

		if cType == "C"
			xVal := PADR( aData[i, ii], nLen )
		elseif cType == "N"
			
			if nDec > 0
				xVal := ALLTRIM(STR(aData[i, ii], nLen, nDec))
			else
				xVal := ALLTRIM(STR(aData[i, ii]))
			endif
		
			if lTrim == .f.	
				xVal := PADL( xVal, nLen, cNumFill )
			endif

			if lTrim == .t.
				// zamjeni "." sa ","
				xVal := STRTRAN( xVal, ".", "," )
			endif

		endif

		if lTrim == .t.
			xVal := ALLTRIM( xVal )
		endif
		
		if ii = LEN( aStruct ) .and. lLastSep == .f.
			cLine += xVal
		else
			cLine += xVal + cSeparator
		endif

	next

	?? cLine
	? 
	
	++ nCount

next

set printer to
set printer off
set console on

return


// ----------------------------------------------------------
// upisi u fajl iz DBF tabele
// ----------------------------------------------------------
function _dbf_to_file( cFilePath, cFileName, aStruct, cDBF, ;
	cSeparator, lTrim, lLastSep )
local i 
local ii
local cLine := ""
local nCount := 0
local cNumFill := "0"

if cSeparator == nil
	cSeparator := ""
endif

if lTrim == nil
	lTrim := .f.
endif

if lLastSep == nil
	lLastSep := .t.
endif

cFile := ALLTRIM( cFilePath ) + ALLTRIM( cFileName )

set printer to (cFile)
set printer on
set console off

// zakaci se na dbf
select (249)
use (PRIVPATH + cDBF) alias "exp"
go top

do while !EOF()

	cLine := ""

	// prodji kroz strukturu jednog zapisa u matrici
	// i napuni liniju...
	for ii := 1 to LEN( aStruct )
		
		cType := aStruct[ii, 1]
		nLen := aStruct[ii, 2]
		nDec := aStruct[ii, 3]

		if cType == "C"
			xVal := PADR( &(exp->(fieldname(ii))), nLen )
		elseif cType == "N"
			
			if nDec > 0
				xVal := ALLTRIM(STR( &(exp->(fieldname(ii))), nLen, nDec))
			else
				xVal := ALLTRIM(STR( &(exp->(fieldname(ii)))))
			endif
		
			if lTrim == .f.	
				xVal := PADL( xVal, nLen, cNumFill )
			endif

			if lTrim == .t.
				// zamjeni "." sa ","
				xVal := STRTRAN( xVal, ".", "," )
			endif

		endif

		if lTrim == .t.
			xVal := ALLTRIM( xVal )
		endif
		
		if ii = LEN( aStruct ) .and. lLastSep == .f.
			cLine += xVal
		else
			cLine += xVal + cSeparator
		endif

	next

	?? cLine
	? 
	
	++ nCount

	skip

enddo

set printer to
set printer off
set console on

select (249)
use

return

