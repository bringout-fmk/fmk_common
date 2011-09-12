#include "sc.ch"


static LEN_KOLICINA := 8
static LEN_CIJENA := 10
static LEN_VRIJEDNOST := 12
static PIC_KOLICINA := ""
static PIC_VRIJEDNOST := ""
static PIC_CIJENA := ""

static __xml_head := 'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"'

// direktorij odgovora
static _d_answer := "odgovori"

// trigeri za naziv fajla
// stampa fiskalnog racuna
static _tr_rac := "sfr"
// stampa reklamnog racuna
static _tr_rrac := "srr"
// stampa dnevnog izvjestaja
static _tr_drep := "sdi"
// stampa periodicnog izvjestaja
static _tr_prep := "spi"
// stampa nefiskalni tekst
static _tr_ntxt := "snd"
// unos novca
static _tr_p_in := "un"
// povrat novca
static _tr_p_out := "pn"
// stampa duplikata
static _tr_dbl := "dup"
// reset data on PU server
static _tr_x := "rst"
// inicijalizacija
static _tr_init := "init"
// ponisti racun
static _tr_crac := "pon"
// presjek stanja
static _tr_xrpt := "sps"

// legenda nTrig vrijednosti za trigere...
// 1 - stampa racuna
// 2 - stampa reklamnog racuna
// 3 - stampa dnevnog izvjestaja
// 4 - stampa periodicnog izvjestaja
// 5 - stampa presjeka stanja x-rep
// 6 - polog ulaz
// 7 - polog izlaz
// 8 - duplikat
// 9 - reset podataka na serveru PU
// 10 - inicijalizacija
// 11 - ponisti racun

// ocekivana matrica aData:
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
// 16 - roba jmj


// struktura matrice aKupac
// 
// aKupac[1] - idbroj kupca
// aKupac[2] - naziv
// aKupac[3] - adresa
// aKupac[4] - postanski broj
// aKupac[5] - grad stanovanja


// -------------------------------------------------------------------
// stampa fiskalnog racuna tring fiskalizacija
// -------------------------------------------------------------------
function fc_trng_rn( cFPath, cFName, aData, aKupac, lStorno, cError )
local cXML
local i
local cBr_zahtjeva 
local cVr_zahtjeva
local cVr_placanja
local cVr_pl
local nVr_placanja
local dRn_datum
local nKolicina
local nCijena
local cRoba_id
local cRoba_naz
local cRoba_jmj
local nRabat
local lKupac := .f.
local nErr_no := 0
local cSt_rn := ""
local nTrigg

// stampanje racuna
cVr_zahtjeva := "0"

if lStorno == .t.
	// stampanje reklamnog racuna
	cVr_zahtjeva := "2"
	cSt_rn := ALLTRIM( aData[1, 8] )
endif

PIC_KOLICINA := "9999999.99"
PIC_VRIJEDNOST := "9999999.99"
PIC_CIJENA := "9999999.99"

if aKupac <> nil .and. LEN( aKupac ) > 0
	lKupac := .t.
endif

// to je zapravo broj racuna !!!
cBr_zahtjeva := aData[1, 1]

nTrigg := 1

// putanja do izlaznog xml fajla
if lStorno == .t.
	cFName := trg_filename( _tr_rrac )
	nTrigg := 2
else
	cFName := trg_filename( _tr_rac )
endif

// c:\tring\xml\sfr.001
cXML := cFPath + cFName

// brisi answer
trg_d_answ( nTrigg )

// otvori xml
open_xml( cXml )

// upisi header
xml_head()

xml_subnode("RacunZahtjev " + __xml_head, .f.)

  xml_node("BrojZahtjeva", cBr_zahtjeva )
  
  // 0 - stampa sve stavke i zatvara racun
  // 1 - stampa stavku po stavku
  // 
  // Mi cemo koristiti varijantu "0"
  xml_node("VrstaZahtjeva", cVr_zahtjeva )
  
  xml_subnode("NoviObjekat", .f.)

    // datum cini se ne treba !!!
    //cRacun_datum := _fix_date( aData[1, 10] )
    //xml_node("Datum", cRacun_datum )
    
    // ako ima podataka o kupcu
    if lKupac = .t.
    
  	xml_subnode("Kupac", .f.)

	  xml_node("IDbroj", aKupac[1, 1] )
	  xml_node("Naziv", strkznutf8( aKupac[1, 2], "8" ) )
	  xml_node("Adresa", strkznutf8( aKupac[1, 3], "8" ) )
	  xml_node("PostanskiBroj", aKupac[1, 4] )
	  xml_node("Grad", strkznutf8( aKupac[1, 5], "8" ) )
  	
	xml_subnode("Kupac", .t.)	

    endif
    
    xml_subnode("StavkeRacuna", .f.)

    for i:=1 to LEN( aData )

	cRoba_id := aData[i, 3]
	cRoba_naz := ALLTRIM( PADR( aData[i, 4], 36 ))
	cRoba_jmj := aData[i, 16]
	nCijena := aData[i, 5]
	nKolicina := aData[i, 6]
	nRabat := aData[i, 11]
	cStopa := _g_tar ( aData[i, 7] )
	cGrupa := ""
	cPLU := ALLTRIM( STR( aData[ i, 9 ] ))

	xml_subnode("RacunStavka", .f.)
	
	  xml_subnode("artikal", .f.)
	
	    xml_node("Sifra", cPLU )
	    xml_node("Naziv", strkznutf8( cRoba_naz , "8" ) )
	    xml_node("JM", strkznutf8( PADR( cRoba_jmj, 2 ), "8" ) )
	    xml_node("Cijena", show_number( nCijena, PIC_CIJENA ) )
	    xml_node("Stopa", cStopa )
	    //xml_node("Grupa", cGrupa )
	    //xml_node("PLU", cPLU )

	  xml_subnode("artikal", .t.)

	  xml_node("Kolicina", show_number( nKolicina, PIC_KOLICINA ) )
	  xml_node("Rabat", show_number( nRabat, PIC_VRIJEDNOST ) )

	xml_subnode("RacunStavka", .t.)

    next

    xml_subnode("StavkeRacuna", .t.)

    // vrste placanja, oznaka:
    //
    //   "GOTOVINA"
    //   "CEK"
    //   "VIRMAN"
    //   "KARTICA"
    // 
    // iznos = 0, ako je 0 onda sve ide tom vrstom placanja

    cVr_pl := ALLTRIM( aData[1, 13] )

    if cVr_pl == "3" .and. lStorno == .f.
       cVr_placanja := _g_v_plac( 2 )
    else
       cVr_placanja := _g_v_plac( 0 )
    endif

    nVr_placanja := 0

    xml_subnode("VrstePlacanja", .f.)
      xml_subnode("VrstaPlacanja", .f.)

         xml_node("Oznaka", cVr_placanja ) 
         xml_node("Iznos", ALLTRIM(STR(nVr_placanja)) )

      xml_subnode("VrstaPlacanja", .t.)
    xml_subnode("VrstePlacanja", .t.)

    xml_node("Napomena", "racun br: " + cBr_zahtjeva )
    
    if lStorno == .t.
       xml_node("BrojRacuna", cSt_rn )
    else
       xml_node("BrojRacuna", cBr_zahtjeva )
    endif

  xml_subnode("NoviObjekat", .t.)

xml_subnode("RacunZahtjev", .t.)

close_xml()

return nErr_no


// ----------------------------------------------
// polog novca u uredjaj
// ----------------------------------------------
function trg_polog( cFPath, cFName )
local cF_out
local cXml
local cBr_zahtjeva := "0"
local cVr_zahtjeva := "7"
local nCash := 0
local nTrigg := 6 

Box(,1,50)
	@ m_x + 1, m_y + 2 SAY "Unesi polog:" GET nCash ;
		PICT "999999.99"
	read
BoxC()

if nCash = 0 .or. LastKey() == K_ESC
	return
endif

cF_out := trg_filename( _tr_p_in )

if nCash < 0
	// ovo je povrat
	cVr_zahtjeva := "8"
	cF_out := trg_filename( _tr_p_out )
	nTrigg := 7
endif

// brisi answer
trg_d_answ( nTrigg )

// c:\tring\xml\unosnovca.001
cXML := cFPath + cF_out

// otvori xml
open_xml( cXml )

// upisi header
xml_head()

xml_subnode("RacunZahtjev " + __xml_head, .f.)

  xml_node("BrojZahtjeva", cBr_zahtjeva )
  xml_node("VrstaZahtjeva", cVr_zahtjeva )
  
  xml_subnode("NoviObjekat", .f. )
     
        xml_node( "Oznaka", "Gotovina" )
        xml_node( "Iznos", ALLTRIM(STR(nCash,12,2)) )
     
  xml_subnode("NoviObjekat", .t. )
  
xml_subnode("RacunZahtjev", .t.)

// zatvori fajl...
close_xml()

return

// ----------------------------------------------
// prepis dokumenata
// ----------------------------------------------
function trg_double( cFPath, cFName )
local cF_out
local cXml
local cBr_zahtjeva := "0"
local cVr_zahtjeva := "3"
local nFisc_no := 0
local nTrigg := 8

Box(,1,50)
	@ m_x + 1, m_y + 2 SAY "Duplikat racuna:" GET nFisc_no
	read
BoxC()

if nFisc_no = 0 .or. LastKey() == K_ESC
	return
endif

cF_out := trg_filename( _tr_dbl )

// c:\tring\xml\stampatiperiodicniizvjestaj.001
cXML := cFPath + cF_out

// brisi answer
trg_d_answ( nTrigg )

// otvori xml
open_xml( cXml )

// upisi header
xml_head()

xml_subnode("Zahtjev " + __xml_head, .f.)

  xml_node("BrojZahtjeva", ALLTRIM(STR(nFisc_no)) )
  xml_node("VrstaZahtjeva", cVr_zahtjeva )
  xml_node("Parametri", "" )
 
xml_subnode("Zahtjev", .t.)

// zatvori fajl...
close_xml()

return


// ----------------------------------------------
// periodicni izvjestaj
// ----------------------------------------------
function trg_per_rpt( cFPath, cFName )
local cF_out
local cXml
local cBr_zahtjeva := "0"
local cVr_zahtjeva := "5"
local cDatumOd := ""
local cDatumDo := ""
local dD_od := DATE()-30
local dD_do := DATE()
local nTrigg := 4

Box(,1,50)
	@ m_x + 1, m_y + 2 SAY "Od datuma:" GET dD_od
	@ m_x + 1, col() + 1 SAY "do:" GET dD_do
	read
BoxC()

cDatumOd := _fix_date( dD_od )
cDatumDo := _fix_date( dD_do )

cF_out := trg_filename( _tr_prep )

// c:\tring\xml\stampatiperiodicniizvjestaj.001
cXML := cFPath + cF_out

// brisi answer
trg_d_answ( nTrigg )

// otvori xml
open_xml( cXml )

// upisi header
xml_head()

xml_subnode("Zahtjev " + __xml_head, .f.)

  xml_node("BrojZahtjeva", cBr_zahtjeva )
  xml_node("VrstaZahtjeva", cVr_zahtjeva )
  
  xml_subnode("Parametri", .f. )
     
     xml_subnode("Parametar", .f. )
        xml_node( "Naziv", "odDatuma" )
        xml_node( "Vrijednost", cDatumOd )
     xml_subnode("Parametar", .t. )
     
     xml_subnode("Parametar", .f. )
        xml_node( "Naziv", "doDatuma" )
        xml_node( "Vrijednost", cDatumDo )
     xml_subnode("Parametar", .t. )
    
  xml_subnode("Parametri", .t. )
  
xml_subnode("Zahtjev", .t.)

// zatvori fajl...
close_xml()

return

// ----------------------------------------------
// reset zahtjeva
// ----------------------------------------------
function trg_reset( cFPath, cFName )
local cF_out
local cXml
local nTrigg := 9

cF_out := trg_filename( _tr_x )

// c:\tring\xml\reset.001
cXML := cFPath + cF_out

// brisi answer
trg_d_answ( nTrigg )

// otvori xml
open_xml( cXml )

// upisi header
xml_head()

xml_node("boolean", "false" )

// zatvori fajl...
close_xml()

return


// ----------------------------------------------
// inicijalizacija
// ----------------------------------------------
function trg_init( cFPath, cFName, cOper, cPwd )
local cF_out
local cXml
local nTrigg := 10

cF_out := trg_filename( _tr_init )

// c:\tring\xml\inicijalizacija.001
cXML := cFPath + cF_out

// brisi answer
trg_d_answ( nTrigg )

// otvori xml
open_xml( cXml )

// upisi header
xml_head()

xml_subnode("Operator " + __xml_head, .f.)

  xml_node("BrojOperatora", cOper )
  xml_node("Lozinka", cPwd )
  
xml_subnode("Operator", .t.)

// zatvori fajl...
close_xml()

return





// ----------------------------------------------
// prekini racun
// ----------------------------------------------
function trg_close_rn( cFPath, cFName )
local cF_out
local cXml
local cBr_zahtjeva := "0"
local cVr_zahtjeva := "9"
local nTrigg := 11

cF_out := trg_filename( _tr_crac )

// c:\tring\xml\prekiniracun.001
cXML := cFPath + cF_out

// brisi out
trg_d_answ( nTrigg )

// otvori xml
open_xml( cXml )

// upisi header
xml_head()

xml_subnode("Zahtjev " + __xml_head, .f.)

  xml_node("BrojZahtjeva", cBr_zahtjeva )
  xml_node("VrstaZahtjeva", cVr_zahtjeva )
  xml_node("Parametri", "" )
  
xml_subnode("Zahtjev", .t.)

// zatvori fajl...
close_xml()

return


// ----------------------------------------------
// presjek stanja
// ----------------------------------------------
function trg_x_rpt( cFPath, cFName )
local cF_out
local cXml
local cBr_zahtjeva := "0"
local cVr_zahtjeva := "3"
local nTrigg := 5 

cF_out := trg_filename( _tr_xrpt )

// c:\tring\xml\stampatidnevniizvjestaj.001
cXML := cFPath + cF_out

trg_d_answ( nTrigg )

// otvori xml
open_xml( cXml )

// upisi header
xml_head()

xml_subnode("Zahtjev " + __xml_head, .f.)

  xml_node("BrojZahtjeva", cBr_zahtjeva )
  xml_node("VrstaZahtjeva", cVr_zahtjeva )
  xml_node("Parametri", "" )
  
xml_subnode("Zahtjev", .t.)

// zatvori fajl...
close_xml()

return


// ----------------------------------------------
// dnevni izvjestaj
// ----------------------------------------------
function trg_daily_rpt( cFPath, cFName )
local cF_out
local cXml
local cBr_zahtjeva := "0"
local cVr_zahtjeva := "4"
local nTrigg := 3

if Pitanje(,"Stampati dnevni izvjestaj", "D") == "N"
	return
endif

cF_out := trg_filename( _tr_drep )

// c:\tring\xml\stampatidnevniizvjestaj.001
cXML := cFPath + cF_out

trg_d_answ( nTrigg )

// otvori xml
open_xml( cXml )

// upisi header
xml_head()

xml_subnode("Zahtjev " + __xml_head, .f.)

  xml_node("BrojZahtjeva", cBr_zahtjeva )
  xml_node("VrstaZahtjeva", cVr_zahtjeva )
  xml_node("Parametri", "" )
  
xml_subnode("Zahtjev", .t.)

// zatvori fajl...
close_xml()


// nakon ovoga provjeri
return


// ----------------------------------------------
// brise fajlove iz ulaznog direktorija
// ----------------------------------------------
function trg_d_out( nTrigger )
local cTrig := trg_trig( nTrigger ) 
cF_path := ALLTRIM( gFc_path ) + trg_filename( cTrig )

if FILE( cF_path )
	if FERASE( cF_path ) <> 0
	endif
endif

return


// ----------------------------------------------
// brise fajlove iz direktorija odgovora
// ----------------------------------------------
function trg_d_answ( nTrigger )
local cTrig := trg_trig( nTrigger )

cF_path := ALLTRIM( gFc_path ) + ;
	_d_answer + SLASH + trg_filename( cTrig )

if FILE( cF_path )
	if FERASE( cF_path ) <> 0
	endif
endif

return


// ----------------------------------------------
// brise fajlove iz ulaznog direktorija
// ----------------------------------------------
function trg_d_tmp( cPodDir )
local cTmp 

if cPodDir == nil
	cPodDir := ""
endif

msgo("brisem tmp fajlove...")

cF_path := ALLTRIM( gFc_path )

if !EMPTY(cPoddir)
	cF_path += cPodDir + SLASH
endif

cTmp := "*.*"

AEVAL( DIRECTORY(cF_path + cTmp), {|aFile| FERASE( cF_path + ;
	ALLTRIM( aFile[1]) ) })

sleep(1)

msgc()

return


// ----------------------------------------
// fajl za pos fiskalni stampac
// ----------------------------------------
static function trg_filename( cTriger )
local cRet
local cF_name := ALLTRIM( gFC_name )

if cTriger == nil
	cTriger := ""
endif

cTriger := ALLTRIM(cTriger)

do case
	
	case "TR$" $ cF_name
		// odredjuje koja komanda ce biti zadata
		// "sfr", "srr" i slicno...
		cRet := STRTRAN( cF_name, "TR$", cTriger )
		cRet := UPPER( cRet )
	
	otherwise 
		// ono sta je navedeno u parametrima
		cRet := cF_name

endcase

return cRet


// ------------------------------------------------
// vraca vrstu placanja na osnovu oznake
// ------------------------------------------------
static function _g_v_plac( nID )
local cRet := "-"

do case 
	case nId = 0
		cRet := "Gotovina"
	case nId = 1
		cRet := "Cek"		
	case nId = 2
		cRet := "Virman"
	case nId = 3
		cRet := "Kartica"

endcase

return cRet 


// ---------------------------------------------
// fiksiraj datum za xml
// ---------------------------------------------
static function _fix_date( dDate , cPattern )
local cRet := ""
local nYear := YEAR( dDate )
local nMonth := MONTH ( dDate )
local nDay := DAY ( dDate )

if cPattern == nil
	cPattern := ""
endif

if Empty( cPattern )

	cRet := ALLTRIM( STR ( nDay ) ) + "." + ;
		ALLTRIM( STR( nMonth) ) + "." + ;
		ALLTRIM( STR( nYear ) )
	
	return cRet

endif

// MM.DD.YYYY

cPattern := STRTRAN( cPattern, "MM", ALLTRIM(STR(nMonth))) 
cPattern := STRTRAN( cPattern, "DD", ALLTRIM(STR(nDay))) 
cPattern := STRTRAN( cPattern, "YYYY", ALLTRIM(STR(nYear))) 
// if .YY in pattern
cPattern := STRTRAN( cPattern, "YY", ALLTRIM(PADL(STR(nYear),2))) 

cRet := cPattern

return cRet



// ------------------------------------------
// vraca tarifu za fiskalni stampac
// ------------------------------------------
static function _g_tar( cIdTar )
local cF_tar := "E"

do case
	case UPPER(ALLTRIM(cIdTar)) = "PDV17" .and. gFC_pdv == "D"
		// PDV je tarifna skupina "E"
		cF_tar := "E"
	case UPPER(ALLTRIM(cIdTar)) = "PDV0" .and. gFC_pdv == "D"
		// bez PDV-a je tarifna skupina "K"
		cF_tar := "K"
	case gFC_pdv == "N"
		// ne-pdv obveznik, skupina "A"
		cF_tar := "A"
endcase

return cF_tar



// ------------------------------------------
// procitaj gresku
// ------------------------------------------
function trg_r_err( cPath, cName, nTimeOut, nFisc_no, nTrig )
local nErr := 0
local cTrig := trg_trig( nTrig )
local cF_name
local i
local nBrLin
local nStart
local cErr
local aErr_read
local aErr_data := {}
local nTime 
local lOk

nTime := nTimeOut

// primjer: c:\tring\xml\odgovori\sfr.001
cF_name := cPath + _d_answer + SLASH + trg_filename( cTrig )

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
lOk := .f.

// prodji kroz svaku liniju i procitaj zapise
for i:=1 to nBrLin
	
	aErr_read := SljedLin( cF_name, nStart )
      	nStart := aErr_read[ 2 ]

	// uzmi u cErr liniju fajla
	cErr := aErr_read[ 1 ]

	// ovo je dodavanje artikla
	if ( "<?xml" $ cErr ) .or. ;
		( "<KasaOdgovor" $ cErr ) .or. ; 
		( "</KasaOdgovor" $ cErr ) .or. ;
		( "<Odgovor" $ cErr ) .or. ;
		( "</Odgovor" $ cErr )
		// preskoci
		loop
	endif

	AADD( aErr_data, cErr )	
next

// sad imam matricu sa linijama
// aErr_data[1, "<Naziv>OK</Naziv>"]
// aErr_data[2, "<Vrijednost></Vrijednost>"]
// aErr_data[3, "<Naziv>BrojFiskalnogRacuna</Naziv>"]
// aErr_data[4, "<Vrijednost>5</Vrijednost>"]
// ... itd...

// prvo provjeri da li je komanda ok
nFind := ASCAN( aErr_data, {|xVar| "<VrstaOdgovora>OK" $ xVar })
if nFind <> 0
	// ovo je ok racun ili bilo koja komanda
	lOk := .t.
endif

if lOk == .f.
	// nije ispravna komanda
	nErr := 1
	return nErr
endif

// sada cemo potraziti broj fiskalnog racuna
nFind := ASCAN( aErr_data, ;
	{|xVar| "<Naziv>BrojFiskalnogRacuna" $ xVar })

if nFind <> 0
	// imamo racun
	// ali se krije na sljedecoj liniji
	// zato + 1
	nFisc_no := _g_fisc_no( aErr_data[ nFind + 1 ] )
endif

return nErr

// ------------------------------------------------------
// vraca broj fiskalnog racuna iz linije fajla
// ------------------------------------------------------
static function _g_fisc_no( cXmlLine )
local nFisc := 0

cXmlLine := STRTRAN( cXmlLine, '<Vrijednost xsi:type="xsd:long">', '' )
cXmlLine := STRTRAN( cXmlLine, '</Vrijednost>', '' )

// ostatak bi trebao da bude samo broj fiskalnog racuna :)

if !EMPTY( cXmlLine )
	nFisc := VAL( ALLTRIM(cXmlLine) )
endif

return nFisc





// ------------------------------------------
// vraca triger za tring filename
// ------------------------------------------
function trg_trig( nTrig )
local cTrig := ""

do case
	case nTrig = 1
		// stampa racuna
		cTrig := _tr_rac
	case nTrig = 2
		// stampa reklamnog racuna
		cTrig := _tr_rrac
	case nTrig = 3
		// stampa dnevnog izvjestaja
		cTrig := _tr_drep
	case nTrig = 4
		// stampa periodicnog izvjestaja
		cTrig := _tr_prep
	case nTrig = 5
		// stampa presjeka stanja
		cTrig := _tr_xrep
	case nTrig = 6
		// polog in
		cTrig := _tr_p_in
	case nTrig = 7
		// polog out
		cTrig := _tr_p_out
	case nTrig = 8
		// duplikat
		cTrig := _tr_dbl
	case nTrig = 9
		// reset podataka na serveru
		cTrig := _tr_x
	case nTrig = 10
		// inicijalizacija
		cTrig := _tr_init
	case nTrig = 11
		// ponisti racun
		cTrig := _tr_crac
	otherwise
		// u drugom slucaju nema trigera
		cTrig := "xxx"
endcase

return cTrig


