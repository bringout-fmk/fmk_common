#include "ld.ch"

static __PAGE_LEN


// ----------------------------------------
// topli obrok lista....
// ----------------------------------------
function to_list()

local cRj := gRj
local cMonthFrom := gMjesec
local cMonthTo := gMjesec
local cYear := gGodina
local cHours := PADR("S01;S10;", 200)
local nHourLimit := 0
local nMinHrLimit := 0
local nKoef := 7
local nAcontAmount := 70.00
local nRptVar1 := 1
local nRptVar2 := 1
local nDays := 7.5

__PAGE_LEN := 60

if _get_vars( @cRj, @cMonthFrom, @cMonthTo, @cYear, @nDays, ;
		@cHours, @nHourLimit, @nMinHrLimit, @nKoef, @nAcontAmount, ;
		@nRptVar1, @nRptVar2 ) == 0
	return
endif

// generisi listu...
if _gen_list( cRj, cMonthFrom, cMonthTo, cYear, nDays, ;
	cHours, nHourLimit, nMinHrLimit, nKoef, nAcontAmount ) == 0

	return
endif


// printaj izvjestaj....
_print_list( cMonthFrom, cMonthTo, cYear, nRptVar1, nRptVar2 )

close all

return


// --------------------------------------
// setuje parametre izvjestaja
// --------------------------------------
static function _get_vars( cRj, cMonthFrom, cMonthTo, cYear, nDays, ;
				cHours, nHourLimit, nMinHrLimit, ;
				nKoef, nAcontAmount, ;
				nRptVar1, nRptVar2 )
local nTArea := SELECT()
local nBoxX := 20
local nBoxY := 70
local nX := 1
local cColor := "BG+/B"

// procitaj parametre
O_PARAMS
private cHistory := "1"
private aHistory := {}
private cSection := "L"

RPar( "rj", @cRj )
RPar( "m1", @cMonthFrom )
RPar( "m2", @cMonthTo )
RPar( "d1", @nDays )
RPar( "y1", @cYear )
RPar( "s1", @cHours )
RPar( "s2", @nHourLimit )
RPar( "s3", @nMinHrLimit )
RPar( "k1", @nKoef )
RPar( "a1", @nAcontAmount )
RPar( "v1", @nRptVar1 )
RPar( "v2", @nRptVar2 )

Box(, nBoxX, nBoxY )
	
	@ m_x + nX, m_y + 2 SAY PADL("**** uslovi izvjestaja", (nBoxY - 1) ) COLOR cColor
	
	nX += 1

	// radna jedinica....
	@ m_x + nX, m_y + 2 SAY "RJ (prazno-sve):" GET cRj VALID EMPTY(cRj) .or.p_rj(@cRj)
	
	nX += 1
	
	@ m_x + nX, m_y + 2 SAY "Mjesec od:" GET cMonthFrom PICT "99" VALID cMonthFrom <= cMonthTo
	@ m_x + nX, col() + 1 SAY "do:" GET cMonthTo PICT "99"  VALID cMonthTo >= cMonthFrom

	nX += 1

	@ m_x + nX, m_y + 2 SAY "Godina:" GET cYear PICT "9999" VALID !EMPTY(cYear)
	
	nX += 2

	@ m_x + nX, m_y + 2 SAY "Sati primanja koja uticnu na isplatu:" GET cHours PICT "@S30" VALID !EMPTY(cHours)

	nX += 2

	@ m_x + nX, m_y + 2 SAY "Koeficijent:" GET nKoef PICT "99999.99"
	
	nX += 1

	@ m_x + nX, m_y + 2 SAY "Broj dana sa kojim se dijeli:" GET nDays PICT "99999.99"
	
	nX += 2

	@ m_x + nX, m_y + 2 SAY "Iznos akontacije:" GET nAcontAmount PICT "99999.99"
	@ m_x + nX, col() + 1 SAY "KM"

	nX += 1

	@ m_x + nX, m_y + 2 SAY "Minimalni limit za sate:" GET nMinHrLimit PICT "999999"

	nX += 1
	
	@ m_x + nX, m_y + 2 SAY "Maksimalni limit za sate:" GET nHourLimit PICT "999999"

	nX += 2
	
	@ m_x + nX, m_y + 2 SAY "Varijanta izvjestaja:" GET nRptVar1 PICT "9" VALID nRptVar1 > 0 .and. nRptVar1 < 3
	
	nX += 1
	
	@ m_x + nX, m_y + 2 SAY "(1) kompletan obracun" COLOR cColor

	nX += 1
	
	@ m_x + nX, m_y + 2 SAY "(2) samo lista sa radnicima za potpis" COLOR cColor
	
	nX += 1

	@ m_x + nX, m_y + 2 SAY SPACE(3) + "Varijanta prikaza:" GET nRptVar2 PICT "9" VALID nRptVar2 > 0 .and. nRptVar2 < 3 WHEN nRptVar1 == 2

	nX += 1
	
	@ m_x + nX, m_y + 2 SAY SPACE(3) + "(1) isplata akontacije" COLOR cColor

	nX += 1
	
	@ m_x + nX, m_y + 2 SAY SPACE(3) + "(2) isplata razlike" COLOR cColor


	read

BoxC()

if LastKey() == K_ESC

	select (nTArea)
	return 0
endif


// snimi parametre...
select params
WPar( "rj", cRj )
WPar( "m1", cMonthFrom )
WPar( "m2", cMonthTo )
WPar( "d1", nDays )
WPar( "y1", cYear )
WPar( "s1", cHours )
WPar( "s2", nHourLimit )
WPar( "s3", nMinHrLimit )
WPar( "k1", nKoef )
WPar( "a1", nAcontAmount )
WPar( "v1", nRptVar1 )
WPar( "v2", nRptVar2 )

select (nTArea)

return 1



// ----------------------------------------------------
// generise listu radnika... prema parmetrima
// ----------------------------------------------------
static function _gen_list( cRj, cMonthFrom, cMonthTo, cYear, nDays, ;
		cHours, nHourLimit, nMinHrLimit, nKoef, nAcontAmount )

local cIdRadn
local aHours := {}
local i
local nUSati
local nCount := 0

// napuni matricu aHours sa vrijednostima sati...
aHours := TokToNiz( ALLTRIM(cHours), ";" )

O_RJ
O_RADN
O_LD

// kreiraj _tmp tabelu
_cre_tmp()

select ld
set order to tag "2"
// godina + mjesec + idradn + idrj
go top
hseek STR(cYear, 4) + STR(cMonthFrom, 2)

Box(, 1, 60)

@ m_x + 1, m_y + 2 SAY "generacija izvjestaja u toku...."

do while !EOF() .and. field->godina == cYear ;
		.and. field->mjesec >= cMonthFrom ;
		.and. field->mjesec <= cMonthTo

	cIdRadn := field->idradn
	
	nUSati := 0
	
	select radn
	set order to tag "1"
	go top
	seek cIdRadn

	select ld

	do while !EOF() .and. field->godina == cYear ;
			.and. field->mjesec >= cMonthFrom ;
			.and. field->mjesec <= cMonthTo ;
			.and. field->idradn == cIdRadn

		if !EMPTY(cRj) .and. field->idrj <> cRj
			
			skip
			loop
			
		endif
	
		for i:=1 to LEN(aHours)
		
			// dodaj na sate
			
			nUSati += &(aHours[i])
			
		next
		
		skip
		
	enddo

	// ako ima sati i nije probijen limit ako postoji limit
	if ROUND( nUSati, 2 ) > 0  ;
		.and. ( nHourLimit == 0 .or. ;
		( nHourLimit <> 0 .and. nUSati <= nHourLimit ))
		
		select _tmp
		append blank
		
		Scatter()
		
		_r_ime := radn->ime
		_r_prezime := radn->naz
		_r_imeoca := radn->imerod
		_r_hours := nUSati
		_r_to := ROUND2( ( nUsati / nDays ) * nKoef , gZaok )
		
		if ROUND(nMinHrLimit, 2) <> 0
		
			if nUSati >= nMinHrLimit
				_r_acont := nAcontAmount
			else
				_r_acont := 0
			endif
		else
			_r_acont := nAcontAmount
		endif
		
		_r_total := _r_to - _r_acont
		
		Gather()

		++ nCount

		@ m_x + 1, m_y + 2 SAY PADR( PADL( STR( nCount), 5 ) + " " + ALLTRIM(radn->naz) + ", " + ALLTRIM(STR(nUSati)) , 60)
		
	endif

	select ld

enddo

BoxC()

return nCount



// -----------------------------------------
// printanje liste iz _tmp tabele
// -----------------------------------------
static function _print_list( cMFrom, cMTo, cYear, nRptVar1, nRptVar2 )

local nRbr := 0
local nUSati := 0
local nUTotal := 0
local nUAcont := 0
local nUTo := 0
local cLine

select _tmp
go top

// setuj liniju...
_get_line( @cLine, nRptVar1, nRptVar2 )

START PRINT CRET

// stampaj header
_p_header( cLine, nRptVar1, nRptVar2, cMFrom, cMTo, cYear )

do while !EOF()

	// ako je ispis akontacije i spisak radnika, r_acont == 0, preskoci
	if ROUND(r_acont, 2) == 0 .and. nRptVar1 == 2 .and. nRptVar2 == 1
		
		skip
		loop
		
	endif

	// provjeri za novu stranu
	_new_page()
	
	if nRptVar1 == 2
		
		? 
		
	endif

	// r.br
	? PADL( STR( ++nRbr , 3 ) + ".", 5 )
	
	?? " "
	
	// prezime + ime
	?? PADR( ALLTRIM(field->r_prezime) + " (" + ALLTRIM(field->r_imeoca) + ") " + ALLTRIM(field->r_ime),  30)
	
	?? " "
	
	if nRptVar1 == 1
	
		// usati...
		?? field->r_hours
	
		nUSati += field->r_hours

		?? " "
	
		// to
		?? field->r_to
	
		nUTo += field->r_to

		?? " "
	
		// akontacija
		?? field->r_acont

		nUAcont += field->r_acont
		

		?? " "
	
		// razlika
		?? field->r_total

		nUTotal += field->r_total

	else

		if nRptVar2 == 1
			
			// isplata akontacije...
			
			?? field->r_acont
			?? " "
			?? _get_mp()

			nUAcont += field->r_acont
			
		else
		
			// isplata ostatka
			?? field->r_total
			?? " "
			?? _get_mp()
		
			nUTotal += field->r_total
			
		endif
	
	endif


	skip
	
enddo

// print total

_new_page()

? cLine

? "UKUPNO:"
?? SPACE(30)

if nRptVar1 == 1

	?? nUSati
	?? nUTo
	?? nUAcont
	?? nUTotal
	
elseif nRptVar1 == 2
	
	if nRptVar2 == 1
	
		?? nUAcont
	
	else
	
		?? nUTotal
	
	endif
	
endif

? cLine

FF
END PRINT

return


// ----------------------------------------------------
// vraca liniju za izvjestaj...
// ----------------------------------------------------
static function _get_line( cLine, nVar1 )
local cTmp

cTmp := ""
// rbr
cTmp += REPLICATE("-", 5)
cTmp += " "
// ime i prezime
cTmp += REPLICATE("-", 30)
cTmp += " "

if nVar1 == 1

	// sati
	cTmp += REPLICATE("-", 10)
	cTmp += " "
	// to
	cTmp += REPLICATE("-", 12)
	cTmp += " "
	// akontacija
	cTmp += REPLICATE("-", 12)
	cTmp += " "
	// razlika
	cTmp += REPLICATE("-", 12)

else
	
	// iznos
	cTmp += REPLICATE("-", 12)
	cTmp += " "
	// potpis
	cTmp += REPLICATE("-", 20)

endif

cLine := cTmp

return



// ----------------------------------------
// vraca liniju za mjesto potpisa....
// ----------------------------------------
static function _get_mp()
return REPLICATE("_", 20)



// -----------------------------------------------
// stampa headera...
// -----------------------------------------------
static function _p_header( cLine, nVar1, nVar2, cMonthFrom, cMonthTo, cYear )
local cTmp
local cPom := "Akontacija"

if nVar2 == 2
	cPom := "Izn.ostatka"
endif

cTmp := ""
cTmp += PADC("Rbr", 5)
cTmp += " "
cTmp += PADC("Prezime (ime oca) ime", 30)
cTmp += " "

if nVar1 == 1

	cTmp += PADC("Sati", 10)
	cTmp += " "
	cTmp += PADC("Topli obrok", 12)
	cTmp += " "
	cTmp += PADC("Akontacija", 12)
	cTmp += " "
	cTmp += PADC("Razlika", 12)

else

	cTmp += PADC(cPom, 12)
	cTmp += " "
	cTmp += PADR("Potpis radnika", 20)

endif

// header

? "---------------------------------"
? "LISTA ZA ISPLATU TOPLOG OBROKA"
? "---------------------------------"
? "na dan: " + DTOC( DATE() )
? "za mjesec od " + STR(cMonthFrom, 2) + " do " + STR(cMonthTo, 2) + ", " + STR(cYear, 4) + " godine" 

?

// header tablele
? cLine
? cTmp
? cLine

return




// -----------------------------
// kreiraj tmp tabelu...
// -----------------------------
static function _cre_tmp()
local aDbf := {}

AADD(aDbf, { "r_ime", "C", 30, 0 })
AADD(aDbf, { "r_prezime", "C", 30, 0 })
AADD(aDbf, { "r_imeoca", "C", 30, 0 })
AADD(aDbf, { "r_hours", "N", 10, 0 })
AADD(aDbf, { "r_to", "N", 12, 2 })
AADD(aDbf, { "r_acont", "N", 12, 2 })
AADD(aDbf, { "r_total", "N", 12, 2 })

if FILE( PRIVPATH + "_TMP.DBF")
	FERASE( PRIVPATH + "_TMP.DBF")
endif

if !FILE( PRIVPATH + "_TMP.DBF" )
	DbCreate2( PRIVPATH + "_TMP.DBF", aDbf )
endif

select (240)
use ( PRIVPATH + "_TMP.DBF" ) alias _tmp


return


// --------------------------------------
// nova stranica...
// --------------------------------------
static function _new_page()

if prow() > __PAGE_LEN
	FF
endif

return



