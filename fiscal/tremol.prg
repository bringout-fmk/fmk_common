/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "sc.ch"

static _razmak1 := " "
static _inp_dir := ""
static _answ_dir := ""
static _nema_out := -20

// fiskalne funkcije TREMOL fiskalizacije 


// struktura matrice aData
//
// aData[1] - broj racuna (C)
// aData[2] - redni broj stavke (C)
// aData[3] - id roba
// aData[4] - roba naziv
// aData[5] - cijena
// aData[6] - kolicina
// aData[7] - tarifa
// aData[8] - broj racuna za storniranje
// aData[9] - roba plu
// aData[10] - plu cijena
// aData[11] - popust
// aData[12] - barkod
// aData[13] - vrsta placanja
// aData[14] - total
// aData[15] - datum racuna
// aData[16] - roba jmj

// struktura matrice aKupac
// 
// aKupac[1] - idbroj kupca
// aKupac[2] - naziv
// aKupac[3] - adresa
// aKupac[4] - postanski broj
// aKupac[5] - grad stanovanja


// --------------------------------------------------------------------------
// stampa fiskalnog racuna tring fiskalizacija
// --------------------------------------------------------------------------
function fc_trm_rn( cFPath, cFName, aData, aKupac, lStorno, cError, ;
	cContinue )
local cXML
local i
local cBr_zahtjeva 
local cVr_placanja
local nVr_placanja
local cRek_rn
local nKolicina
local nCijena
local cRoba_id
local cRoba_naz
local cRoba_jmj
local nRabat
local lKupac := .f.
local nErr_no := 0
local cOperacija := ""
local cCmd := ""
local cC_id 
local cC_name
local cC_addr
local cC_city
local nFisc_no := 0

// pobrisi tmp fajlove i ostalo sto je u input direktoriju
trm_d_tmp()

if cContinue == nil
	cContinue := "0"
endif

if aKupac <> nil .and. LEN( aKupac ) > 0
	lKupac := .t.
endif

// to je zapravo broj racuna !!!
cBr_zahtjeva := aData[1, 1]

cFName := trm_filename( cBr_zahtjeva )

// putanja do izlaznog xml fajla
cXML := cFPath + _inp_dir + SLASH + cFName

// otvori xml
open_xml( cXml )

// upisi header
xml_head()

cOF_txt := 'TremolFpServer Command="Receipt"'
cOFR_txt := ''
cOFC_txt := ''

if cContinue == "1"
	cOF_txt += ' Continue="' + cContinue + '"'
endif

// ukljuci storno triger
if lStorno == .t.
	cOFR_txt := ' RefundReceipt="' + ALLTRIM( aData[1, 8] ) + '"'
endif

// ukljuci kupac triger
if lKupac == .t.

	// aKupac[1] - idbroj kupca
	// aKupac[2] - naziv
	// aKupac[3] - adresa
	// aKupac[4] - postanski broj
	// aKupac[5] - grad stanovanja

	cC_id := ALLTRIM( aKupac[1, 1] )
	cC_name := strkznutf8( ALLTRIM( aKupac[1, 2] ), "8" )
	cC_addr := strkznutf8( ALLTRIM( aKupac[1, 3] ), "8" )
	cC_city := strkznutf8( ALLTRIM( aKupac[1, 5] ), "8" )

	cOFC_txt := _razmak1 + 'CompanyID="' + cC_id + '"'
	cOFC_txt += _razmak1 + 'CompanyName="' + cC_name + '"'
	cOFC_txt += _razmak1 + 'CompanyHQ="' + cC_city + '"'
	cOFC_txt += _razmak1 + 'CompanyAddress="' + cC_addr + '"'
	cOFC_txt += _razmak1 + 'CompanyCity="' + cC_city + '"'

endif

xml_subnode( cOF_txt + cOFR_txt + cOFC_txt )
  
nVr_placanja := 0
    
    for i:=1 to LEN( aData )

	nRoba_plu := aData[i, 9]
	cRoba_bk := aData[i, 12]
	cRoba_id := aData[i, 3]
	cRoba_naz := PADR( aData[i, 4], gFc_alen )
	cRoba_jmj := _g_jmj( aData[i, 16] )
	nCijena := aData[i, 5]
	nKolicina := aData[i, 6]
	nRabat := aData[i, 11]
	cStopa := _g_tar ( aData[i, 7] )
	cDep := "1"
	cTmp := ""

	// naziv artikla
	cTmp += _razmak1 + 'Description="' + strkznutf8(cRoba_naz,"8") + '"'
	//  kolicina artikla 
	cTmp += _razmak1 + 'Quantity="' + ALLTRIM( STR( nKolicina, 12, 3)) + '"'
	// cijena artikla
	cTmp += _razmak1 + 'Price="' + ALLTRIM( STR( nCijena, 12, 2 )) + '"'
	// poreska stopa
	cTmp += _razmak1 + 'VatInfo="' + cStopa + '"'
	// odjeljenje
	cTmp += _razmak1 + 'Department="' + cDep + '"'
	// jedinica mjere
	cTmp += _razmak1 + 'UnitName="' + cRoba_jmj + '"'
	
	if nRabat > 0

		// vrijednost popusta
		cTmp += _razmak1 + 'Discount="' + ALLTRIM(STR(nRabat,12,2)) ;
			+ '%"'
	
	endif

	xml_snode( "Item", cTmp )
	
    next

    // vrste placanja, oznaka:
    //
    //   "GOTOVINA"
    //   "CEK"
    //   "VIRMAN"
    //   "KARTICA"
    // 
    // iznos = 0, ako je 0 onda sve ide tom vrstom placanja

    cVr_placanja := _g_v_plac( VAL( aData[1, 13] ) )
    nVr_placanja := 0

    if aData[1, 13] <> "0"

    	cTmp := 'Type="' + cVr_placanja + '"'
    	cTmp += _razmak1 + 'Amount="' + ALLTRIM( STR(nVr_placanja,12,2)) + '"'

    	xml_snode( "Payment", cTmp )	

    endif

    // dodatna linija, broj veznog racuna
    cTmp := 'Message="Vezni racun: ' + cBr_zahtjeva + '"'

    xml_snode( "AdditionalLine", cTmp )	

xml_subnode("TremolFpServer", .t.)

close_xml()

return nErr_no


// ----------------------------------------------
// brise fajlove iz ulaznog direktorija
// ----------------------------------------------
function trm_d_tmp()
local cTmp 

msgo("brisem tmp fajlove...")

cF_path := ALLTRIM( gFc_path )
cTmp := "*.*"

AEVAL( DIRECTORY(cF_path + cTmp), {|aFile| FERASE( cF_path + ;
	ALLTRIM( aFile[1]) ) })

sleep(1)

msgc()

return




// -------------------------------------------------------------------
// -------------------------------------------------------------------
function trm_polog( cFPath, cFName, cError, nValue )
local cXML
local cBr_zahtjeva 
local nErr_no := 0
local cCmd := ""

if nValue == nil
	nValue := 0
endif

if nValue = 0
  // box - daj iznos pologa
  Box(,1, 60)
	@ m_x + 1, m_y + 2 SAY "Unosim polog od:" GET nValue ;
		PICT "99999.99"
	read
  BoxC()

  if LastKey() == K_ESC .or. nValue = 0
	return
  endif

endif

if nValue < 0
	// polog komanda
	cCmd := 'Command="CashOut"'
else
	// polog komanda
	cCmd := 'Command="CashIn"'
endif

cBr_zahtjeva := "0"
cFName := trm_filename( cBr_zahtjeva )

// putanja do izlaznog xml fajla
cXML := cFPath + _inp_dir + SLASH + cFName

// otvori xml
open_xml( cXml )

// upisi header
xml_head()

xml_subnode("TremolFpServer " + cCmd )

cCmd := 'Amount="' +  ALLTRIM(STR( ABS(nValue), 12, 2)) + '"'

xml_snode("Cash", cCmd )

xml_subnode("/TremolFpServer")

close_xml()

return nErr_no


// -------------------------------------------------------------------
// tremol reset artikala
// -------------------------------------------------------------------
function fc_trm_rplu( cFPath, cFName, cError )
local cXML
local cBr_zahtjeva 
local nErr_no := 0
local cCmd := ""

if !SigmaSif("RPLU")
	return 0
endif

cBr_zahtjeva := "0"
cFName := trm_filename( cBr_zahtjeva )

// putanja do izlaznog xml fajla
cXML := cFPath + _inp_dir + SLASH + cFName

// otvori xml
open_xml( cXml )

// upisi header
xml_head()

cCmd := ""
cCmd += 'Command="DirectIO"'

xml_subnode("TremolFpServer " + cCmd )

cCmd := ""
cCmd += 'Command="1"'
cCmd += _razmak1 + 'Data="0"'
cCmd += _razmak1 + 'Object="K00000;F142HZ              ;0;$"'

xml_snode("DirectIO", cCmd )

xml_subnode("/TremolFpServer")

close_xml()

if cError == "D"
	// provjeri greske...
	// nErr_no := ...
	if _read_out( cFPath, cFName )
		
		// procitaj poruku greske
		nErr_no := trm_r_error( cFPath, cFName, gFc_tout ) 

	endif

endif

return nErr_no



// -------------------------------------------------------------------
// tremol komanda
// -------------------------------------------------------------------
function fc_trm_cmd( cFPath, cFName, cCmd, cError )
local cXML
local cBr_zahtjeva 
local nErr_no := 0

cBr_zahtjeva := "0"
cFName := trm_filename( cBr_zahtjeva )

// putanja do izlaznog xml fajla
cXML := cFPath + _inp_dir + SLASH + cFName

// otvori xml
open_xml( cXml )

// upisi header
xml_head()

xml_subnode("TremolFpServer " + cCmd )

close_xml()

if cError == "D"
	// provjeri greske...
	// nErr_no := ...
	if _read_out( cFPath, cFName )
		
		// procitaj poruku greske
		nErr_no := trm_r_error( cFPath, cFName, gFc_tout ) 

	else
		nErr_no := _nema_out
	endif

endif

return nErr_no


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
		cRet := "Kartica"
	case nId = 3
		cRet := "Virman"

endcase

return cRet 


// ------------------------------------------
// vraca jedinicu mjere
// ------------------------------------------
static function _g_jmj( cJmj )
cF_jmj := ""
do case
	case UPPER(ALLTRIM(cJmj)) = "KOM"
		cF_jmj := ""
	case UPPER(ALLTRIM(cJmj)) = "LIT"
		cF_jmj := "l"
	case UPPER(ALLTRIM(cJmj)) = "GR"
		cF_jmj := "g"
	case UPPER(ALLTRIM(cJmj)) = "KG"
		cF_jmj := "kg"

	// case 
	// ....

endcase

return cF_jmj




// ------------------------------------------
// vraca tarifu za fiskalni stampac
// ------------------------------------------
static function _g_tar( cIdTar )
cF_tar := "2"
do case
	case UPPER(ALLTRIM(cIdTar)) == "PDV17"
		// PDV je tarifna skupina "2"
		cF_tar := "2"
	
	case UPPER(ALLTRIM(cIdTar)) == "PDV0"
		// nePDV 
		cF_tar := "1"
	// case 
	// ....

endcase

return cF_tar



// ----------------------------------------
// fajl za pos fiskalni stampac
// ----------------------------------------
function trm_filename( cBrRn )
local cRet
local cF_name := ALLTRIM( gFC_name )

do case

	case "$rn" $ cF_name
		// broj racuna.xml
		cRN := PADL( ALLTRIM( cBrRn ), 8, "0" )
		// ukini znak "/" ako postoji
		cRN := STRTRAN( cRN, "/", "" )
		cRet := STRTRAN( cF_name, "$rn", cRN )
		cRet := UPPER( cRet )
	
	otherwise 
		// ono sta je navedeno u parametrima
		cRet := cF_name

endcase

return cRet



// -----------------------------------------------------
// ItemZ
// -----------------------------------------------------
function trm_z_item( cFPath, cFName, cError )
local cCmd

cCmd := 'Command="Report" Type="ItemZ" /'
nErr := fc_trm_cmd( cFPath, cFName, cCmd, cError )

return


// -----------------------------------------------------
// ItemX
// -----------------------------------------------------
function trm_x_item( cFPath, cFName, cError )
local cCmd

cCmd := 'Command="Report" Type="ItemX" /'
nErr := fc_trm_cmd( cFPath, cFName, cCmd, cError )

return


// -----------------------------------------------------
// dnevni fiskalni izvjestaj
// -----------------------------------------------------
function trm_z_rpt( cFPath, cFName, cError )
local cCmd

if Pitanje(,"Stampati dnevni izvjestaj", "D") == "N"
	return
endif

cCmd := 'Command="Report" Type="DailyZ" /'
nErr := fc_trm_cmd( cFPath, cFName, cCmd, cError )

// ako se koristi opcija automatskog pologa
if gFc_pauto > 0
	
	msgo("Automatski unos pologa u uredjaj... sacekajte.")
	
	// daj mi malo prostora
	sleep(10)
	
	// pozovi opciju pologa
	nErr := trm_polog( cFPath, cFName, cError, gFc_pauto)
	
	msgc()

endif

return


// -----------------------------------------------------
// presjek stanja
// -----------------------------------------------------
function trm_x_rpt( cFPath, cFName, cError )
local cCmd

cCmd := 'Command="Report" Type="DailyX" /'
nErr := fc_trm_cmd( cFPath, cFName, cCmd, cError )

return


// -----------------------------------------------------
// periodicni izvjestaj
// -----------------------------------------------------
function trm_p_rpt( cFPath, cFName, cError )
local cCmd
local cStart
local cEnd
local dStart := DATE()-30
local dEnd := DATE()

if Pitanje(,"Stampati periodicni izvjestaj", "D") == "N"
	return
endif

Box(,1,60)
	@ m_x+1, m_y+2 SAY "Od datuma:" GET dStart
	@ m_x+1, col()+1 SAY "do datuma:" GET dEnd
	read
BoxC()

if LastKey() == K_ESC
	return
endif

// 2010-10-01 : YYYY-MM-DD je format datuma
cStart := _tfix_date( dStart )
cEnd := _tfix_date( dEnd )

cCmd := 'Command="Report" Type="Date" Start="' + cStart + ;
	'" End="' + cEnd + '" /'

nErr := fc_trm_cmd( cFPath, cFName, cCmd, cError )


return


// ------------------------------------------------
// sredjuje datum za tremol uredjaj xml
// ------------------------------------------------
static function _tfix_date( dDate )
local xRet := ""
local cTmp

cTmp := ALLTRIM( STR( YEAR( dDate ) ))

xRet += cTmp
xRet += "-"

cTmp := PADL( ALLTRIM( STR( MONTH( dDate )) ), 2, "0" )

xRet += cTmp
xRet += "-"

cTmp := PADL( ALLTRIM( STR( DAY( dDate )) ), 2, "0" )
xRet += cTmp

return xRet


// ---------------------------------------------------
// stampa kopije racuna
// ---------------------------------------------------
function trm_rn_copy( cFPath, cFName, cError )
local cCmd
local cBrRn := SPACE(10)
local cRefund := "N"

// box - daj broj racuna
Box(,2, 50)
	@ m_x + 1, m_y + 2 SAY "Broj racuna:" GET cBrRn ;
		VALID !EMPTY( cBrRn )
	@ m_x + 2, m_y + 2 SAY "racun je reklamni (D/N)?" GET cRefund ;
		VALID cRefund $ "DN" PICT "@!"
	read
BoxC()

if LastKey() == K_ESC
	return
endif

// <TremolFpServer Command="PrintDuplicate" Type="0" Document="2"/>

cCmd := 'Command="PrintDuplicate"'

if cRefund == "N"
	// obicni racun
	cCmd += _razmak1 + 'Type="0"'
else
	// reklamni racun
	cCmd += _razmak1 + 'Type="1"'
endif

cCmd += _razmak1 + 'Document="' +  ALLTRIM(cBrRn) + '" /'

nErr := fc_trm_cmd( cFPath, cFName, cCmd, cError )

return



// --------------------------------------------------------
// cekanje na fajl odgovora, poziv za ostale module
// --------------------------------------------------------
function trm_read_out( cFPath, cFName, nTimeOut )
return _read_out( cFPath, cFName, nTimeOut )



// --------------------------------------------
// cekanje na fajl odgovora
// --------------------------------------------
static function _read_out( cFPath, cFName, nTimeOut )
local lOut := .t.
local cTmp
local nTime
local cAnswer := ""

if nTimeOut == nil
	nTimeOut := gFC_tout
endif

nTime := nTimeOut

if !EMPTY( _answ_dir )
	cAnswer := _answ_dir + SLASH
endif

cTmp := cFPath + cAnswer + STRTRAN( cFName, "XML", "OUT" )

Box(,1,50)

do while nTime > 0
	
	-- nTime

	if FILE( cTmp )
		// fajl se pojavio - izadji iz petlje !
		exit
	endif

	@ m_x + 1, m_y + 2 SAY PADR( "Cekam odgovor... " + ;
		ALLTRIM( STR(nTime) ), 48)

	sleep(1)
enddo

BoxC()

if !FILE( cTmp )
	msgbeep("Ne postoji fajl odgovora (OUT) !!!!")
	lOut := .f.
endif

return lOut



// ------------------------------------------------
// citanje gresaka za TREMOL driver
// 
// nTimeOut - time out fiskalne operacije
// nFisc_no - broj fiskalnog isjecka
//
// ------------------------------------------------
function trm_r_error( cFPath, cFName, nTimeOut, nFisc_no )
local nErr := 0
local cF_name
local i
local n
local x
local nBrLin
local nStart
local cErr
local aLinija 
local aErr := {}
local aErr2
local aErr_read
local aErr_data
local aF_err := {}
local cErrCode := ""
local cErrDesc := ""

// primjer: c:\fiscal\00001.out
cF_name := cFPath + _answ_dir + SLASH + STRTRAN( cFName, "XML", "OUT" )

// ova opcija podrazumjeva da je ukljuèena opcija 
// prikaza greske tipa OUT fajlovi...

nFisc_no := 0
nBrLin := BrLinFajla( cF_name )
nStart := 0

cFisc_txt := ""

// prodji kroz svaku liniju i procitaj zapise
// 1 liniju preskoci zato sto ona sadrzi 
// <?xml version="1.0"...>
for i:=1 to nBrLin

	aErr_read := SljedLin( cF_name, nStart )
      	nStart := aErr_read[ 2 ]

	// uzmi u cErr liniju fajla
	cErr := aErr_read[ 1 ]

	if "?xml" $ cErr
		// prvu liniju preskoci !
		loop
	endif

	// skloni "<" i ">"
	cErr := STRTRAN( cErr, ">", "" )
	cErr := STRTRAN( cErr, "<", "" )
	cErr := STRTRAN( cErr, "/", "" )
	cErr := STRTRAN( cErr, '"', "" )
	cErr := STRTRAN( cErr, "TremolFpServerOutput", "" )
	cErr := STRTRAN( cErr, "Output Change", "OutputChange" )

	// dobijamo npr.
	//
	// ErrorCode=0 ErrorPOS=OPOS_SUCCESS ErrorDescription=Uspjesno kreiran
	// Output Change=0.00 ReceiptNumber=00552 Total=51.20

	aLinija := TokToNiz( cErr, SPACE(1) )

	// dobit cemo
	// 
	// aLinija[1] = "ErrorCode=0"
	// aLinija[2] = "ErrorPOS=OPOS_SUCCESS"
	// ...
	
	// dodaj u generalnu matricu aErr
	for m := 1 to LEN( aLinija )
		AADD( aErr, aLinija[m] )
	next

next

// potrazimo gresku...
nScan := ASCAN( aErr, {|xVal| "OPOS_SUCCESS" $ xVal } )

if nScan > 0

	// nema greske, komanda je uspjela !
	// ako je rijec o racunu uzmi broj fiskalnog racuna
        	
	nScan := ASCAN( aErr, {|xVal| "ReceiptNumber" $ xVal } )
	
	if nScan <> 0
		
		// ReceiptNumber=241412
		aTmp2 := {}
		aTmp2 := TokToNiz( aErr[ nScan ], "=" )
		
		// ovo ce biti broj racuna
		cTmp := ALLTRIM( aTmp2[2] )
		
		if !EMPTY( cTmp )
			nFisc_no := VAL( cTmp )
		endif

	endif
	
	// pobrisi fajl, izdaji
	FERASE( cF_name )
	return nErr
	
endif

// imamo gresku !!! ispisi je
cTmp := ""

nScan := ASCAN( aErr, {|xVal| "ErrorCode" $ xVal } )
	
if nScan <> 0
		
	// ErrorCode=241412
	aTmp2 := {}
	aTmp2 := TokToNiz( aErr[ nScan ], "=" )
		
	cTmp += "ErrorCode: " + ALLTRIM( aTmp2[2] )
		
	// ovo je ujedino i error kod
	nErr := VAL( aTmp2[2] )

endif
	
nScan := ASCAN( aErr, {|xVal| "ErrorOPOS" $ xVal } )
if nScan <> 0
		
	// ErrorOPOS=xxxxxxx
	aTmp2 := {}
	aTmp2 := TokToNiz( aErr[ nScan ], "=" )
	
	cTmp += " ErrorOPOS: " + ALLTRIM( aTmp2[2] )

endif
	
nScan := ASCAN( aErr, {|xVal| "ErrorDescription" $ xVal } )
if nScan <> 0
		
	// ErrorDescription=xxxxxxx
	aTmp2 := {}
	aTmp2 := TokToNiz( aErr[ nScan ], "=" )
	
	cTmp += " Description: " + ALLTRIM( aTmp2[2] )

endif

if !EMPTY( cTmp )
	msgbeep( cTmp )
endif

// obrisi fajl out na kraju !!!
FERASE( cF_name )

return nErr



// ----------------------------------------------
// provjera ispravnosti matrice sa podacima
// kolicine, cijene
// ----------------------------------------------
function trm_check( aData )
return hcp_check( @aData )




