#include "sc.ch"


// pos komande
static F_POS_RN := "POS_RN"
static MAX_QT := 99999.999
static MIN_QT := 1.000
static MAX_PRICE := 999999.99
static MIN_PRICE := 0.01
static MAX_PERC := 99.99
static MIN_PERC := -99.99

// ocekivana matrica
// aData
//
// 1 - broj racuna
// 2 - redni broj
// 3 - id roba
// 4 - roba naziv
// 5 - cijena
// 6 - kolicina
// 7 - tarifa
// 8 - broj racuna za storniranje
// 9 - roba plu
// 10 - plu cijena - cijena iz sifranika
// 11 - popust
// 12 - barkod
// 13 - vrsta placanja
// 14 - total racuna
// 15 - datum racuna

// --------------------------------------------------------
// fiskalni racun pos (FPRINT)
// cFPath - putanja do fajla
// cFName - naziv fajla
// aData - podaci racuna
// lStorno - da li se stampa storno ili ne (.T. ili .F. )
// --------------------------------------------------------
function fp_pos_rn( cFPath, cFName, aData, aKupac, lStorno, cError )
local cSep := ";"
local aPosData := {}
local aStruct := {}
local nErr := 0

if lStorno == nil
	lStorno := .f.
endif

if cError == nil
	cError := "N"
endif

// naziv fajla
cFName := fp_filename( aData[ 1, 1] )

// uzmi strukturu tabele za pos racun
aStruct := _g_f_struct( F_POS_RN )

// iscitaj pos matricu
aPosData := _fp_pos_rn( aData, aKupac, lStorno )

_a_to_file( cFPath, cFName, aStruct, aPosData )

return nErr


// ---------------------------------------------------------
// vrsi provjeru vrijednosti cijena, kolicina itd...
// ---------------------------------------------------------
function fp_check( aData, lStorno )
local nRet := 0
local nCijena := 0
local nPluCijena := 0
local nKolicina := 0
local cNaziv := ""
local nFix := 0

// aData[4] - naziv
// aData[5] - cijena
// aData[6] - kolicina

if lStorno == nil
	lStorno := .f.
endif

for i:=1 to LEN( aData )

	nCijena := aData[ i, 5 ]	
	nPluCijena := aData[i, 10]
	nKolicina := aData[ i, 6 ]	
	cNaziv := aData[i, 4]

	if ( !_chk_qtty( nKolicina ) .or. !_chk_price( nCijena ) ) ;
		.or. !_chk_price( nPluCijena )
		
		if gFc_chk > "1"
			
			// popravi kolicine, cijene
			_fix_qtty( @nKolicina, @nCijena, @nPluCijena, @cNaziv )
			
			// promjeni u matrici podatke takodjer
			aData[i, 5] := nCijena
			aData[i, 10] := nPluCijena
			aData[i, 6] := nKolicina
			aData[i, 4] := cNaziv
		
		endif

		++ nFix

	endif

next

if nFix > 0 .and. gFc_chk > "1"

	msgbeep("Pojedini artikli na racunu su prepakovani na 100 kom !")

elseif nFix > 0 .and. gFc_chk == "1"
	
	nRet := -99
	msgbeep("Pojedinim artiklima je kolicina/cijena van dozvoljenog ranga#Prekidam operaciju !!!!")

	if lStorno 
		// ako je rijec o storno dokumentu, prikazi poruku
		// ali ipak nastavi dalje...
		nRet := 0
	endif

endif

return nRet


// -------------------------------------------------
// provjerava da li zadovoljava kolicina
// -------------------------------------------------
function _chk_qtty( nQtty )
local lRet := .t.

if nQtty > MAX_QT .or. nQtty < MIN_QT
	lRet := .f.
endif

return lRet


// -------------------------------------------------
// provjerava da li zadovoljava cijena
// -------------------------------------------------
function _chk_price( nPrice )
local lRet := .t.

if nPrice > MAX_PRICE .or. nPrice < MIN_PRICE
	lRet := .f.
endif

return lRet


// -------------------------------------------------
// koriguj cijenu i kolicinu
// -------------------------------------------------
function _fix_qtty( nQtty, nPrice, nPPrice, cName )

nQtty := nQtty / 100
nPrice := nPrice * 100
nPPrice := nPPrice * 100
cName := LEFT( ALLTRIM( cName ), 5 ) + " x100"

return



// ----------------------------------------------------
// fprint: unos pologa u printer
// ----------------------------------------------------
function fp_polog( cFPath, cFName )
local cSep := ";"
local aPolog := {}
local aStruct := {}
local nPolog := 0

Box(,1,60)
	@ m_x + 1, m_y + 2 SAY "Zaduzujem kasu za:" GET nPolog ;
		PICT "999999.99"
	read
BoxC()

if nPolog = 0
	msgbeep("Polog mora biti <> 0 !")
	return
endif

if LastKey() == K_ESC
	return
endif

// naziv fajla
cFName := fp_filename( "0" )

// uzmi strukturu tabele za pos racun
aStruct := _g_f_struct( F_POS_RN )

// iscitaj pos matricu
aPolog := _fp_polog( nPolog )

_a_to_file( cFPath, cFName, aStruct, aPolog )

return



// ----------------------------------------------------
// fprint: dupliciranje racuna
// ----------------------------------------------------
function fp_double( cFPath, cFName )
local cSep := ";"
local aDouble := {}
local aStruct := {}
local dD_from := DATE()
local dD_to := dD_from
local cTH_from := "12"
local cTM_from := "30"
local cTH_to := "12"
local cTM_to := "31"
local cT_from
local cT_to
local cType := "F"


Box(,10,60)
	
	@ m_x + 1, m_y + 2 SAY "Za datum od:" GET dD_from 
	@ m_x + 1, col() + 1 SAY "vrijeme od (hh:mm):" GET cTH_from
	@ m_x + 1, col() SAY ":" GET cTM_from
	
	@ m_x + 2, m_y + 2 SAY "         do:" GET dD_to
	@ m_x + 2, col() + 1 SAY "vrijeme do (hh:mm):" GET cTH_to
	@ m_x + 2, col() SAY ":" GET cTM_to

	@ m_x + 3, m_y + 2 SAY "--------------------------------------"

	@ m_x + 4, m_y + 2 SAY "A - duplikat svih dokumenata"
	@ m_x + 5, m_y + 2 SAY "F - duplikat fiskalnog racuna"
	@ m_x + 6, m_y + 2 SAY "R - duplikat reklamnog racuna"
	@ m_x + 7, m_y + 2 SAY "Z - duplikat Z izvjestaja"
	@ m_x + 8, m_y + 2 SAY "X - duplikat X izvjestaja"
	@ m_x + 9, m_y + 2 SAY "P - duplikat periodicnog izvjestaja" ;
		GET cType ;
		VALID cType $ "AFRZXP" PICT "@!"

	read
BoxC()

if LastKey() == K_ESC
	return
endif

// dodaj i sekunde na kraju
cT_from := cTH_from + cTM_from + "00"
cT_to := cTH_to + cTM_to + "00"

// naziv fajla
cFName := fp_filename( "0" )

// uzmi strukturu tabele za pos racun
aStruct := _g_f_struct( F_POS_RN )

// iscitaj pos matricu
aDouble := _fp_double( cType, dD_from, dD_to, cT_from, cT_to )

_a_to_file( cFPath, cFName, aStruct, aDouble )

return



// ----------------------------------------------------
// zatvori nasilno racun sa 0.0 KM iznosom
// ----------------------------------------------------
function fp_void( cFPath, cFName )
local cSep := ";"
local aVoid := {}
local aStruct := {}

// naziv fajla
cFName := fp_filename( "0" )

// uzmi strukturu tabele za pos racun
aStruct := _g_f_struct( F_POS_RN )

// iscitaj pos matricu
aVoid := _fp_void_rn()

_a_to_file( cFPath, cFName, aStruct, aVoid )

return



// ----------------------------------------------------
// print non-fiscal tekst
// ----------------------------------------------------
function fp_nf_txt( cFPath, cFName, cTxt )
local cSep := ";"
local aTxt := {}
local aStruct := {}

// naziv fajla
cFName := fp_filename( "0" )

// uzmi strukturu tabele za pos racun
aStruct := _g_f_struct( F_POS_RN )

// iscitaj pos matricu
aTxt := _fp_nf_txt( cTxt )

_a_to_file( cFPath, cFName, aStruct, aTxt )

return


// ----------------------------------------------------
// brisanje PLU iz uredjaja
// ----------------------------------------------------
function fp_del_plu( cFPath, cFName, lSilent )
local cSep := ";"
local aDel := {}
local aStruct := {}

if lSilent == nil
	lSilent := .t.
endif

if !lSilent 
	if !SIGMASIF("RESET")
		return
	endif
endif

// naziv fajla
cFName := fp_filename( "0" )

// uzmi strukturu tabele za pos racun
aStruct := _g_f_struct( F_POS_RN )

// iscitaj pos matricu
aDel := _fp_del_plu()

_a_to_file( cFPath, cFName, aStruct, aDel )

return



// ----------------------------------------------------
// zatvori racun
// ----------------------------------------------------
function fp_close( cFPath, cFName )
local cSep := ";"
local aClose := {}
local aStruct := {}

// naziv fajla
cFName := fp_filename( "0" )

// uzmi strukturu tabele za pos racun
aStruct := _g_f_struct( F_POS_RN )

// iscitaj pos matricu
aClose := _fp_close_rn()

_a_to_file( cFPath, cFName, aStruct, aClose )

return


// ----------------------------------------------------
// manualno zadavanje komandi
// ----------------------------------------------------
function fp_man_cmd( cFPath, cFName )
local cSep := ";"
local aManCmd := {}
local aStruct := {}
local nCmd := 0
local cCond := SPACE(150)
local cErr := "N"
local nErr := 0
private GetList:={}

Box(,4, 65)
	
	@ m_x+1, m_y+2 SAY "**** manuelno zadavanje komandi ****" 
	
	@ m_x+2, m_y+2 SAY "   broj komande:" GET nCmd PICT "999" ;
		VALID nCmd > 0
	@ m_x+3, m_y+2 SAY "        komanda:" GET cCond PICT "@S40"
	
	@ m_x+4, m_y+2 SAY "provjera greske:" GET cErr PICT "@!" ;
		VALID cErr $ "DN"
	read
BoxC()

if LastKey() == K_ESC
	return
endif

// naziv fajla
cFName := fp_filename( "0" )

// uzmi strukturu tabele za pos racun
aStruct := _g_f_struct( F_POS_RN )

// iscitaj pos matricu
aManCmd := _fp_man_cmd( nCmd, cCond )

_a_to_file( cFPath, cFName, aStruct, aManCmd )

if cErr == "D"
	
	// provjeri gresku
	nErr := fp_r_error( cFPath, gFC_tout, 0 )

	if nErr <> 0
		msgbeep("Postoji greska !!!")
	endif

endif

return



// ----------------------------------------------------
// izvjestaj o prodanim PLU
// ----------------------------------------------------
function fp_sold_plu( cFPath, cFName )
local cSep := ";"
local aPlu := {}
local aStruct := {}
local nErr := 0
local cType := "0"

Box(,4,50)
	@ m_x + 1, m_y + 2 SAY "**** pregled artikala ****" COLOR "I"
	@ m_x + 3, m_y + 2 SAY "0 - samo u danasnjem prometu "
	@ m_x + 4, m_y + 2 SAY "1 - svi programirani          -> " GET cType ;
		VALID cType $ "01"
	read
BoxC()

if LastKey() == K_ESC
	return
endif

// pobrisi answer fajl
fp_d_answer( cFPath )

// naziv fajla
cFName := fp_filename( "0" )

// uzmi strukturu tabele za pos racun
aStruct := _g_f_struct( F_POS_RN )

// iscitaj pos matricu
aPlu := _fp_sold_plu( cType )

_a_to_file( cFPath, cFName, aStruct, aPlu )


return


// ----------------------------------------------------
// dnevni fiskalni izvjestaj
// ----------------------------------------------------
function fp_daily_rpt( cFPath, cFName )
local cSep := ";"
local aDaily := {}
local aStruct := {}
local nErr := 0
local cType := "0"

if Pitanje(,"Stampati dnevni izvjestaj ?", "D") == "N"
	return
endif

// uslovi
Box(,4,50)
	@ m_x + 1, m_y + 2 SAY "**** dnevni izvjestaj ****" COLOR "I"
	@ m_x + 3, m_y + 2 SAY "0 - z-report"
	@ m_x + 4, m_y + 2 SAY "2 - x-report  -> " GET cType ;
		VALID cType $ "02"
	read
BoxC()

if LastKey() == K_ESC
	return
endif

// pobrisi answer fajl
fp_d_answer( cFPath )

// naziv fajla
cFName := fp_filename( "0" )

// uzmi strukturu tabele za pos racun
aStruct := _g_f_struct( F_POS_RN )

// iscitaj pos matricu
aDaily := _fp_daily_rpt( cType )

_a_to_file( cFPath, cFName, aStruct, aDaily )

// procitaj error
nErr := fp_r_error( cFPath, gFC_tout, 0 )

if nErr <> 0

	msgbeep("Postoji greska !!!")
	
	return

endif

// pokrecem komandu za brisanje artikala iz uredjaja
// ovo je bitno za FP550 uredjaj
// MP55LD ce ignorisati, nece se nista desiti!

// ako je dinamicki PLU
if gFC_acd == "D"

	msgo("Nuliram stanje uredjaja ...")

	// ako je printer onda posalji ovu komandu !
	if gFC_device == "P"

		// pobrisi answer fajl
		fp_d_answer( cFPath )

		// daj mu malo prostora
		sleep(10)

		// posalji komandu za reset PLU u uredjaju
		fp_del_plu( cFPath, cFName, .t. )


		// prekontrolisi gresku
		// ovdje cemo koristiti veci timeout
		nErr := fp_r_error( cFPath, 500, 0 )

		if nErr <> 0
			msgbeep("Postoji greska !!!")
			return
		endif
	endif
	
	msgc()

	// setuj brojac PLU na 0 u parametrima !
	auto_plu( .t., .t. )
	msgbeep("Stanje fiskalnog uredjaju je nulirano.")



endif

return


// ----------------------------------------------------
// fiskalni izvjestaj za period
// ----------------------------------------------------
function fp_per_rpt( cFPath, cFName  )
local cSep := ";"
local aPer := {}
local aStruct := {}
local nErr := 0
local dD_from := DATE() - 30
local dD_to := DATE()
private GetList:={}

Box(,1,50)
	@ m_x + 1, m_y + 2 SAY "Za period od" GET dD_from 
	@ m_x + 1, col() + 1 SAY "do" GET dD_to
	read
BoxC()

if LastKey() == K_ESC
	return
endif

// naziv fajla
cFName := fp_filename( "0" )

// uzmi strukturu tabele za pos racun
aStruct := _g_f_struct( F_POS_RN )

// iscitaj pos matricu
aPer := _fp_per_rpt( dD_from, dD_to )

_a_to_file( cFPath, cFName, aStruct, aPer )

// procitaj error
nErr := fp_r_error( cFPath, gFC_tout, 0 )

if nErr <> 0
	msgbeep("Postoji greska !!!")
endif

return




// -----------------------------------------------------
// fiskalno upisivanje robe (FPRINT)
// cFPath - putanja do fajla
// aData - podaci racuna
// -----------------------------------------------------
function fp_pos_art( cFPath, cFName, aData )
local cSep := ";"
local aPosData := {}
local aStruct := {}

// uzmi strukturu tabele za pos racun
aStruct := _g_f_struct( F_POS_RN )

// iscitaj pos matricu
aPosData := _fp_p_art( aData )

_a_to_file( cFPath, cFName, aStruct, aPosData )

return


// ------------------------------------------------------
// vraca popunjenu matricu za upis artikla u memoriju
// (FPRINT)
// ------------------------------------------------------
static function _fp_p_art( aData )
local aArr := {}
local cTmp := ""
local cLogic
local cLogSep := ","
local cSep := ";"
local i
local cOption := "2"

// ocekivana struktura
// aData = { idroba, nazroba, cijena, kolicina, porstopa, plu }

cLogic := "1"

for i := 1 to LEN( aData )
	
	cTmp := "107"
	cTmp += cLogSep
	cTmp += cLogic
	cTmp += cLogSep
	cTmp += REPLICATE("_", 6) 
	cTmp += cLogSep
	cTmp += REPLICATE("_", 1) 
	cTmp += cLogSep
	cTmp += REPLICATE("_", 2)
	cTmp += cSep
	
	cTmp += cOption
	cTmp += cSep

	// poreska grupa artikala 1 - 5
	cTmp += _g_tar( aData[i, 5] )
	cTmp += cSep
	
	// kod PLU
	cTmp += ALLTRIM( aData[i, 1] )
	cTmp += cSep
	
	// cjena 0-99999.99
	cTmp += ALLTRIM(STR( aData[i, 3], 12, 2 ))
	cTmp += cSep

	// naziv artikla
	cTmp += PADR( ALLTRIM(aData[i, 2]), 32 )
	cTmp += cSep

	AADD( aArr, { cTmp } )

next

return aArr



// ------------------------------------------
// vraca tarifu
// ------------------------------------------
static function _g_tar( cStopa )
local xRet := "2"

do case
	// obracun pdv-a
	case ALLTRIM( cStopa ) $ "PDV17#PDV7NP#"
		xRet := "2"
	// nema pdv-a
	case ALLTRIM( cStopa ) $ "PDV0#PDV0IZ#"
		xRet := "4"
endcase

// ako nije PDV obveznik onda je stopa "1" uvijek
if gFC_pdv == "N"
	xRet := "1"
endif

return xRet


// ----------------------------------------
// vraca popunjenu matricu za ispis raèuna
// FPRINT driver
// ----------------------------------------
static function _fp_pos_rn( aData, aKupac, lStorno )
local aArr := {}
local cTmp := ""
local cLogic
local cLogSep := ","
local cSep := ";"
local i
local cRek_rn := ""
local cRnBroj
local cOperator := "1"
local cOp_pwd := "000000"
local nTotal := 0
local cVr_placanja := "0"

cVr_placanja := ALLTRIM( aData[1, 13] )
nTotal := aData[1, 14]

// ocekuje se matrica formata
// aData { brrn, rbr, idroba, nazroba, cijena, kolicina, porstopa, 
//         rek_rn, plu, plu_cijena, popust, barkod, vrsta plac, total racuna }

// prvo dodaj artikle za prodaju...
_a_fp_articles( @aArr, aData, lStorno )

// broj racuna
cRnBroj := ALLTRIM( aData[1,1] )

// logic je uvijek "1"
cLogic := "1"

// 1) otvaranje fiskalnog racuna

cTmp := "48"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep
cTmp += ALLTRIM( gIOSA )
cTmp += cSep
cTmp += cOperator
cTmp += cSep
cTmp += cOp_pwd
cTmp += cSep

if lStorno == .t.
	
	cRek_rn := ALLTRIM( aData[ 1, 8 ] )
	cTmp += cSep
	cTmp += cRek_rn
	cTmp += cSep
else
	cTmp += cSep
endif

// dodaj ovu stavku u matricu...
AADD( aArr, { cTmp } )

// 2. prodaja stavki

for i := 1 to LEN( aData )

	cTmp := "52"
	cTmp += cLogSep
	cTmp += cLogic
	cTmp += cLogSep
	cTmp += REPLICATE("_", 6) 
	cTmp += cLogSep
	cTmp += REPLICATE("_", 1) 
	cTmp += cLogSep
	cTmp += REPLICATE("_", 2)
	cTmp += cSep
	
	// kod PLU
	cTmp += ALLTRIM( STR( aData[i, 9] ) )
	cTmp += cSep
	
	// kolicina 0-99999.99
	cTmp += ALLTRIM(STR( aData[i, 6], 12, 2 ))
	cTmp += cSep

	// popust 0-99.99%
	if aData[i, 10] > 0
		cTmp += "-" + ALLTRIM(STR( aData[i, 11], 10, 2 ))
	endif
	cTmp += cSep

	// dodaj u matricu prodaju...
	AADD( aArr, { cTmp } )
	
next

// 3. subtotal

cTmp := "51"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep

AADD( aArr, { cTmp } )


// 4. nacin placanja
cTmp := "53"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep

// 0 - cash
// 1 - card
// 2 - chek
// 3 - virman

if cVr_placanja <> "0" .and. !lStorno 
 	
	// imamo drugu vrstu placanja...
	cTmp += cVr_placanja
	cTmp += cSep
	cTmp += ALLTRIM( STR( nTotal, 12, 2 ) )
	cTmp += cSep

else

	cTmp += cSep
	cTmp += cSep

endif

AADD( aArr, { cTmp } )

// radi zaokruzenja kod virmanskog placanja 
// salje se jos jedna linija 53 ali prazna
if cVr_placanja <> "0" .and. !lStorno 
	
	cTmp := "53"
	cTmp += cLogSep
	cTmp += cLogic
	cTmp += cLogSep
	cTmp += REPLICATE("_", 6) 
	cTmp += cLogSep	
	cTmp += REPLICATE("_", 1) 
	cTmp += cLogSep
	cTmp += REPLICATE("_", 2)
	cTmp += cSep
	cTmp += cSep
	cTmp += cSep

	AADD( aArr, { cTmp } )

endif


// 5. kupac - podaci
if LEN( aKupac ) > 0

	// aKupac = { idbroj, naziv, adresa, ptt, mjesto }

	// postoje podaci...
	cTmp := "55"
	cTmp += cLogSep
	cTmp += cLogic
	cTmp += cLogSep
	cTmp += REPLICATE("_", 6) 
	cTmp += cLogSep
	cTmp += REPLICATE("_", 1) 
	cTmp += cLogSep
	cTmp += REPLICATE("_", 2)
	cTmp += cSep
	
	// 1. id broj
	cTmp += ALLTRIM( aKupac[ 1, 1 ] )
	cTmp += cSep

	// 2. naziv
	cTmp += ALLTRIM( PADR( aKupac[ 1, 2 ], 36 ) )
	cTmp += cSep

	// 3. adresa
	cTmp += ALLTRIM( PADR( aKupac[ 1, 3 ], 36 ) )
	cTmp += cSep
	
	// 4. ptt, mjesto
	cTmp += ALLTRIM( aKupac[ 1, 4 ] ) + " " + ;
		ALLTRIM( aKupac[ 1, 5 ] )

	cTmp += cSep
	cTmp += cSep
	cTmp += cSep

	AADD( aArr, { cTmp } )

endif

// 6. otvaranje ladice
cTmp := "106"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep

AADD( aArr, { cTmp } )



// 7. zatvaranje racuna
cTmp := "56"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep

AADD( aArr, { cTmp } )

return aArr



// ---------------------------------------------------
// manualno zadavanje komandi
// ---------------------------------------------------
static function _fp_man_cmd( nCmd, cCond )
local cTmp := ""
local cLogic
local cLogSep := ","
local cSep := ";"
local aArr := {}

cLogic := "1"

// broj komande
cTmp := ALLTRIM(STR(nCmd))

// ostali regularni dio
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep

if !EMPTY( cCond )
	// ostatak komande
	cTmp += ALLTRIM(cCond)
endif

AADD( aArr, { cTmp } )

return aArr



// ---------------------------------------------------
// printanje non-fiscal teksta na uredjaj
// ---------------------------------------------------
static function _fp_nf_txt( cTxt )
local cTmp := ""
local cLogic
local cLogSep := ","
local cSep := ";"
local aArr := {}

cLogic := "1"

// otvori non-fiscal racun
cTmp := "38"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep

AADD( aArr, { cTmp } )


// ispisi tekst
cTmp := "42"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep
cTmp += ALLTRIM( PADR( cTxt, 30 ) )
cTmp += cSep

AADD( aArr, { cTmp } )


// zatvori non-fiscal racun
cTmp := "39"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep

AADD( aArr, { cTmp } )

return aArr



// ---------------------------------------------------
// brisi artikle iz uredjaja
// ---------------------------------------------------
static function _fp_del_plu()
local cTmp := ""
local cLogic
local cLogSep := ","
local cSep := ";"
local aArr := {}
// komanda za brisanje artikala je 3
local cCmd := "3"
local cCmdType := ""
local nTArea := SELECT()
local nLastPlu := 0

// uzmi zadnji PLU iz parametara
nLastPlu := last_plu()

select (nTArea)

// brisat ces sve od plu = 1 do zadnji plu
cCmdType := "1;" + ALLTRIM(STR(nLastPlu))

cLogic := "1"

// brisanje PLU kodova iz uredjaja
cTmp := "107"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep
cTmp += cCmd
cTmp += cSep
cTmp += cCmdType
cTmp += cSep

AADD( aArr, { cTmp } )

return aArr



// ---------------------------------------------------
// zatvori racun
// ---------------------------------------------------
static function _fp_close_rn()
local cTmp := ""
local cLogic
local cLogSep := ","
local cSep := ";"
local aArr := {}

cLogic := "1"

// 7. zatvaranje racuna
cTmp := "56"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep

AADD( aArr, { cTmp } )

return aArr

// --------------------------------------------------------
// vraca formatiran datum za opcije izvjestaja
// --------------------------------------------------------
static function _fix_date( dDate )
local cRet := ""
local nM := MONTH( dDate )
local nD := DAY( dDate )
local nY := YEAR( dDate )

// format datuma treba da bude DDMMYY
cRet := PADL( ALLTRIM(STR(nD)), 2, "0" )
cRet += PADL( ALLTRIM(STR(nM)), 2, "0" )
cRet += RIGHT( ALLTRIM(STR(nY)), 2 )

return cRet


// ---------------------------------------------------
// dnevni fiskalni izvjestaj
// ---------------------------------------------------
static function _fp_per_rpt( dD_from, dD_to )
local cTmp := ""
local cLogic
local cLogSep := ","
local cSep := ";"
local cD_from
local cD_to
local aArr := {}

// konvertuj datum
cD_from := _fix_date( dD_from )
cD_to := _fix_date( dD_to )

cLogic := "1"

cTmp := "79"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep
cTmp += cD_from
cTmp += cSep
cTmp += cD_to
cTmp += cSep
cTmp += cSep
cTmp += cSep
	
AADD( aArr, { cTmp } )

return aArr



// ---------------------------------------------------
// izvjestaj o prodanim PLU-ovima
// ---------------------------------------------------
static function _fp_sold_plu( cType )
local cTmp := ""
local cLogic
local cLogSep := ","
local cSep := ";"
local aArr := {}

// 0 - samo u toku dana
// 1 - svi programirani

if cType == nil
	cType := "0"
endif

cLogic := "1"

cTmp := "111"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep
cTmp += cType
cTmp += cSep
	
AADD( aArr, { cTmp } )

return aArr




// ---------------------------------------------------
// dnevni fiskalni izvjestaj
// ---------------------------------------------------
static function _fp_daily_rpt( cType )
local cTmp := ""
local cLogic
local cLogSep := ","
local cSep := ";"
local aArr := {}
// "N" - bez ciscenja prodaje
// "A" - sa ciscenjem prodaje
local cOper := "A"

// 0 - "Z"
// 2 - "X"
if cType == nil
	cType := "0"
endif

cLogic := "1"

cTmp := "69"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep
cTmp += cType
cTmp += cSep
cTmp += cOper
cTmp += cSep
	
AADD( aArr, { cTmp } )

return aArr




// ------------------------------------------------------------------
// dupliciranje dokumenta
// ------------------------------------------------------------------
static function _fp_double( cType, dD_from, dD_to, cT_from, cT_to )
local cTmp := ""
local cLogic
local cLogSep := ","
local cSep := ";"
local aArr := {}
local cStart := ""
local cEnd := ""
local cParam := "0"

// sredi start i end linije
cStart := _fix_date(dD_from) + cT_from
cEnd := _fix_date(dD_to) + cT_to

cLogic := "1"

cTmp := "109"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep
cTmp += cType
cTmp += cSep
cTmp += cStart
cTmp += cSep
cTmp += cEnd
cTmp += cSep
cTmp += cParam
cTmp += cSep
	
AADD( aArr, { cTmp } )

return aArr

// ---------------------------------------------------
// unos pologa u printer
// ---------------------------------------------------
static function _fp_polog( nIznos )
local cTmp := ""
local cLogic
local cLogSep := ","
local cSep := ";"
local aArr := {}
local cZnak := "+"

if nIznos < 0
	cZnak := ""
endif

cLogic := "1"

cTmp := "70"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep
cTmp += cZnak + ALLTRIM(STR( nIznos ))
cTmp += cSep
	
AADD( aArr, { cTmp } )

return aArr


// ---------------------------------------------------
// zatvori nasilno racun sa 0.0 iznosom
// ---------------------------------------------------
static function _fp_void_rn()
local cTmp := ""
local cLogic
local cLogSep := ","
local cSep := ";"
local aArr := {}

cLogic := "1"

cTmp := "301"
cTmp += cLogSep
cTmp += cLogic
cTmp += cLogSep
cTmp += REPLICATE("_", 6) 
cTmp += cLogSep
cTmp += REPLICATE("_", 1) 
cTmp += cLogSep
cTmp += REPLICATE("_", 2)
cTmp += cSep
	
AADD( aArr, { cTmp } )

return aArr


// ----------------------------------------------------
// dodaj artikle za racun
// ----------------------------------------------------
static function _a_fp_articles( aArr, aData, lStorno )
local i
local cTmp := ""
// opcija dodavanja artikla u printer <1|2> 
// 1 - dodaj samo jednom
// 2 - mozemo dodavati vise puta
local cOp_add := "2"
// opcija promjene cijene u printeru
local cOp_ch := "4"
local cLogic
local cLogSep := ","
local cSep := ";"

// ocekuje se matrica formata
// aData { brrn, rbr, idroba, nazroba, cijena, kolicina, porstopa, 
//         rek_rn, plu, plu_cijena, popust }

cLogic := "1"

//if lStorno == .t.
//	return
//endif

for i:=1 to LEN( aData )
	
	// 1. dodavanje artikla u printer
	
	cTmp := "107"
	cTmp += cLogSep
	cTmp += cLogic
	cTmp += cLogSep
	cTmp += REPLICATE("_", 6) 
	cTmp += cLogSep
	cTmp += REPLICATE("_", 1) 
	cTmp += cLogSep
	cTmp += REPLICATE("_", 2)
	cTmp += cSep
	
	// opcija dodavanja "2"
	cTmp += cOp_add
	cTmp += cSep
	
	// poreska stopa
	cTmp += _g_tar( aData[ i, 7 ] )
	cTmp += cSep
	
	// plu kod 
	cTmp += ALLTRIM( STR( aData[ i, 9 ]) )
	cTmp += cSep

	// plu cijena
	cTmp += ALLTRIM(STR( aData[ i, 10 ], 12, 2 ))
	cTmp += cSep
	
	// plu naziv
	cTmp += ALLTRIM( PADR( aData[ i, 4 ], gFC_alen ) ) 
	cTmp += cSep

	AADD( aArr, { cTmp } )
	
	// 2. dodavanje stavke promjena cijene - ako postoji
	
	cTmp := "107"
	cTmp += cLogSep
	cTmp += cLogic
	cTmp += cLogSep
	cTmp += REPLICATE("_", 6) 
	cTmp += cLogSep
	cTmp += REPLICATE("_", 1) 
	cTmp += cLogSep
	cTmp += REPLICATE("_", 2)
	cTmp += cSep
	
	// opcija dodavanja "4"
	cTmp += cOp_ch
	cTmp += cSep
	
	// plu kod 
	cTmp += ALLTRIM( STR( aData[ i, 9 ]) )
	cTmp += cSep
	
	// plu cijena
	cTmp += ALLTRIM(STR( aData[ i, 10 ], 12, 2 ))
	cTmp += cSep

	AADD( aArr, { cTmp } )

next

return


// ----------------------------------------
// fajl za pos fiskalni stampac
// ----------------------------------------
static function fp_filename( cBrRn )
local cRet
local cF_name := ALLTRIM( gFC_name )

do case

	case "$rn" $ cF_name
		// broj racuna.txt
		cRN := PADL( ALLTRIM( cBrRn ), 8, "0" )
		cRet := STRTRAN( cF_name, "$rn", cRN )
		cRet := UPPER( cRet )
	otherwise 
		// ono sta je navedeno u parametrima
		cRet := cF_name

endcase

return cRet



// ----------------------------------------------
// pobrisi answer fajl
// ----------------------------------------------
function fp_d_answer( cPath )
local cF_name

cF_name := cPath + "ANSWER" + SLASH + "ANSWER.TXT"

if FERASE( cF_name ) = -1
	msgbeep("Greska sa brisanjem answer.txt !")
endif

return


// ----------------------------------------------
// pobrisi out fajl
// ----------------------------------------------
function fp_d_out( cFile )

if FERASE( cFile ) = -1
	msgbeep("Greska sa brisanjem izlaznog fajla !")
endif

return


// ------------------------------------------------
// citanje gresaka za FPRINT driver
// vraca broj
// 0 - sve ok
// -9 - ne postoji answer fajl
// 
// nTimeOut - time out fiskalne operacije
// nFisc_no - broj fiskalnog isjecka
// ------------------------------------------------
function fp_r_error( cPath, nTimeOut, nFisc_no )
local nErr := 0
local cF_name
local i
local nBrLin
local nStart
local cErr
local aErr_read
local aErr_data
local nTime 

nTime := nTimeOut

// primjer: c:\fprint\answer\answer.txt
cF_name := cPath + "ANSWER" + SLASH + "ANSWER.TXT"

// ova opcija podrazumjeva da je ukljuèena opcija 
// prikaza greske tipa ER,OK...

Box(,1,50)

do while nTime > 0
	
	-- nTime

	if FILE( cF_name )
		// fajl se pojavio - izadji iz petlje !
		exit
	endif

	@ m_x + 1, m_y + 2 SAY PADR( "Cekam na fiskalni uredjaj: " + ;
		ALLTRIM( STR(nTime) ), 48)

	sleep(1)
enddo

BoxC()

if !FILE( cF_name )
	msgbeep("Fajl " + cF_name + " ne postoji !!!")
	nFisc_no := 0
	nErr := -9
	return nErr
endif

nFisc_no := 0
nBrLin := BrLinFajla( cF_name )
nStart := 0

cFisc_txt := ""

// prodji kroz svaku liniju i procitaj zapise
for i:=1 to nBrLin
	
	aErr_read := SljedLin( cF_name, nStart )
      	nStart := aErr_read[ 2 ]

	// uzmi u cErr liniju fajla
	cErr := aErr_read[ 1 ]

	// ovo je dodavanje artikla
	if "107,1,00" $ cErr
		// preskoci
		loop
	endif
	
	// ovu liniju zapamti, sadrzi fiskalni racun broj
	// komanda 56, zatvaranje racuna
	if "56,1,00" $ cErr
		cFisc_txt := cErr
	endif

	// ima neka greska !
	if "Er;" $ cErr
		msgbeep( ALLTRIM(cErr) )
		nRet := 1
		return nRet
	endif
	
next

// ako je sve ok, uzmi broj fiskalnog isjecka
if !EMPTY( cFisc_txt )
	nFisc_no := _g_fisc_no( cFisc_txt )
endif

return nErr



// ------------------------------------------------
// vraca broj fiskalnog isjecka
// ------------------------------------------------
static function _g_fisc_no( cTxt )
local nFiscNO := 0
local aTmp := {}
local aFisc := {}
local cFisc := ""

aTmp := toktoniz( cTxt, ";" )
cFisc := aTmp[2]
aFisc := toktoniz( cFisc, "," )
nFiscNO := VAL( aFisc[2] )

return nFiscNO


