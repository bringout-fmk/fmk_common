#include "sc.ch"

static _cmdok := "CMD.OK"
static _razmak1 := " "
static _answ_dir := "FROM_FP"
static _inp_dir := "TO_FP"

// trigeri
static _tr_cmd := "CMD"
static _tr_plu := "PLU"
static _tr_txt := "TXT"
static _tr_rcp := "RCP"


// fiskalne funkcije HCP fiskalizacije 


// struktura matrice aData
//
// aData[1] - broj racuna (C)
// aData[2] - redni broj stavke (C)
// aData[3] - id roba
// aData[4] - roba naziv
// aData[5] - cijena
// aData[6] - rabat
// aData[7] - kolicina
// aData[8] - tarifa
// aData[9] - broj racuna za storniranje
// aData[10] - datum racuna
// aData[11] - roba jmj
// aData[12] - roba plu
// aData[13] - plu cijena
// aData[14] - popust
// aData[15] - barkod

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
function fc_hcp_rn( cFPath, cFName, aData, aKupac, lStorno, cError, nTotal )
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

if nTotal == nil
	nTotal := 0
endif

// ako je storno posalji pred komandu
if lStorno = .t.
	
	// daj mi storno komandu
	cRek_rn := ALLTRIM( aData[1, 9] )
	cCmd := _on_storno( cRek_rn )
	// posalji storno komandu
	nErr_no := fc_hcp_cmd( cFPath, cFName, cCmd, cError, _tr_cmd )	
	
	if nErr_no > 0
		return nErr_no
	endif

endif

// programiraj artikal prije nego izdas racun
if !lStorno
	nErr_no := fc_hcp_plu( cFPath, cFName, aData, cError )

	if nErr_no > 0
		return nErr_no
	endif
endif

if aKupac <> nil .and. LEN( aKupac ) > 0
	lKupac := .t.
endif

if lKupac = .t.
	
	// setuj triger za izdavanje racuna sa partnerom
	// ....
	cIBK := aKupac[1, 1]
	cCmd := _on_partn( cIBK )

endif

// to je zapravo broj racuna !!!
cBr_zahtjeva := aData[1, 1]

cFName := hcp_filename( cBr_zahtjeva, _tr_rcp )

// putanja do izlaznog xml fajla
cXML := cFPath + _inp_dir + SLASH + cFName

// otvori xml
open_xml( cXml )

// upisi header
xml_head()

xml_subnode("RECEIPT")
  
nVr_placanja := 0
    
    for i:=1 to LEN( aData )

	nRoba_plu := aData[i, 12]
	cRoba_bk := aData[i, 15]
	cRoba_id := aData[i, 3]
	cRoba_naz := PADR( aData[i, 4], 32 )
	cRoba_jmj := _g_jmj( aData[i, 11] )
	nCijena := aData[i, 5]
	nKolicina := aData[i, 7]
	nRabat := aData[i, 6]
	cStopa := _g_tar ( aData[i, 8] )
	cDep := "0"
	cTmp := ""

	// sta ce se koristiti za 'kod' artikla
	if gFc_acd == "P"
		// PLU artikla
		cTmp := 'BCR="' + ALLTRIM(STR(nRoba_plu)) + '"'
	elseif gFc_acd == "I"
		// ID artikla
		cTmp := 'BCR="' + ALLTRIM(cRoba_id) + '"'
	elseif gFc_acd == "B"
		// barkod artikla
		cTmp := 'BCR="' + ALLTRIM(cRoba_bk) + '"'
	endif
	
	// poreska stopa
	cTmp += _razmak1 + 'VAT="' + cStopa + '"'
	// jedinica mjere
	cTmp += _razmak1 + 'MES="' + cRoba_jmj + '"'
	// odjeljenje
	cTmp += _razmak1 + 'DEP="' + cDep + '"'
	// naziv artikla
	cTmp += _razmak1 + 'DSC="' + strkznutf8(cRoba_naz,"8") + '"'
	// cijena artikla
	cTmp += _razmak1 + 'PRC="' + ALLTRIM( STR( nCijena, 12, 2 )) + '"'
	//  kolicina artikla 
	cTmp += _razmak1 + 'AMN="' + ALLTRIM( STR( nKolicina, 12, 2)) + '"'
	
	if nRabat > 0

		// vrijednost popusta
		cTmp += _razmak1 + 'DS_VALUE="' + ALLTRIM(STR(nRabat,12,2)) ;
			+ '"'
		// vrijednost popusta
		cTmp += _razmak1 + 'DISCOUNT="' + "true" + '"'
	
	endif

	xml_snode( "DATA", cTmp )
	
    next


    // vrste placanja, oznaka:
    //
    //   "GOTOVINA"
    //   "CEK"
    //   "VIRMAN"
    //   "KARTICA"
    // 
    // iznos = 0, ako je 0 onda sve ide tom vrstom placanja

    cVr_placanja := _g_v_plac( 0 )
    nVr_placanja := nTotal

    cTmp := 'PAY="' + cVr_placanja + '"'
    cTmp += _razmak1 + 'AMN="' + ALLTRIM( STR(nVr_placanja,12,2)) + '"'

    xml_snode( "DATA", cTmp )	

xml_subnode("RECEIPT", .t.)

close_xml()

// kreiraj cmd.ok
c_cmdok( cFPath )

if cError == "D"
	
	// provjeri greske...
	// nErr_no := ...
	
	if _read_ok( cFPath, cFName ) = .f.
		
		// procitaj poruku greske
		nErr_no := hcp_r_error( cFPath, cFName, gFc_tout, _tr_rcp ) 
		
	endif
endif

// ispis nefiskalnog teksta
nErr_no := fc_hcp_txt( cFPath, cFName, cBr_Zahtjeva, cError )  

return nErr_no


// -------------------------------------------------------------------
// hcp programiranje klijenti
// -------------------------------------------------------------------
function fc_hcp_cli( cFPath, cFName, aKupac, cError )
local cXML
local cBr_zahtjeva 
local nErr_no := 0

cBr_zahtjeva := "0"
cFName := hcp_filename( cBr_zahtjeva, _tr_cli )

// putanja do izlaznog xml fajla
cXML := cFPath + _inp_dir + SLASH + cFName

// otvori xml
open_xml( cXml )

// upisi header
xml_head()

xml_subnode("CLIENTS")

for i:=1 to LEN( aKupac )
	

	cTmp := 'IBK="' + aKupac[i, 1] + '"'
	cTmp += _razmak1 + 'NAME="' + ;
		ALLTRIM( strkznutf8( aKupac[i, 2],"8") ) + '"'
	cTmp += _razmak1 + 'ADDRESS="' + ;
		ALLTRIM( strkznutf8( aKupac[i, 3], "8") ) + '"'
	cTmp += _razmak1 + 'TOWN="' + ;
		ALLTRIM( strkznutf8( aKupac[i, 5], "8" )) + '"'
	
	xml_snode( "DATA", cTmp )

next

xml_subnode("CLIENTS", .t.)

close_xml()

// kreiraj triger cmd.ok
c_cmdok( cFPath )

if cError == "D"
	// provjeri greske...
	// nErr_no := ...
	if _read_ok( cFPath, cFName ) = .f.
		
		// procitaj poruku greske
		nErr_no := hcp_r_error( cFPath, cFName, gFc_tout, _tr_cli )

	endif

endif

return nErr_no


// ----------------------------------------------------
// posalji cmd.ok
// ----------------------------------------------------
function hcp_s_cmd( cFPath )

// kreiraj triger cmd.ok
c_cmdok( cFPath )

return


// -------------------------------------------------------------------
// hcp programiranje PLU
// -------------------------------------------------------------------
function fc_hcp_plu( cFPath, cFName, aData, cError )
local cXML
local cBr_zahtjeva 
local nErr_no := 0
local i

cBr_zahtjeva := "0"
cFName := hcp_filename( cBr_zahtjeva, _tr_plu )

// putanja do izlaznog xml fajla
cXML := cFPath + _inp_dir + SLASH + cFName

// otvori xml
open_xml( cXml )

// upisi header
xml_head()

xml_subnode("PLU")

for i:=1 to LEN( aData )
	
	nRoba_plu := aData[i, 12]
	// cRoba_id := aData[i, 3]
	cRoba_naz := PADR( aData[i, 4], 32 )
	cRoba_jmj := _g_jmj( aData[i, 11] )
	nCijena := aData[i, 5]
	cStopa := _g_tar ( aData[i, 8] )
	cDep := "0"
	nLager := 0

	cTmp := 'BCR="' + ALLTRIM(STR(nRoba_plu)) + '"'
	cTmp += _razmak1 + 'VAT="' + cStopa + '"'
	cTmp += _razmak1 + 'MES="' + cRoba_jmj + '"'
	cTmp += _razmak1 + 'DEP="' + cDep + '"'
	cTmp += _razmak1 + 'DSC="' + ALLTRIM( strkznutf8(cRoba_naz,"8") ) + '"'
	cTmp += _razmak1 + 'PRC="' + ALLTRIM(STR(nCijena, 12, 2)) + '"'
	cTmp += _razmak1 + 'LGR="' + ALLTRIM(STR(nLager, 12, 2)) + '"'
	
	xml_snode( "DATA", cTmp )

next

xml_subnode("PLU", .t.)

close_xml()

// kreiraj triger cmd.ok
c_cmdok( cFPath )

if cError == "D"
	// provjeri greske...
	// nErr_no := ..
	if _read_ok( cFPath, cFName ) = .f.
		
		// procitaj poruku greske
		nErr_no := hcp_r_error( cFPath, cFName, gFc_tout, _tr_plu ) 

	endif
endif

return nErr_no



// -------------------------------------------------------------------
// ispis nefiskalnog teksta
// -------------------------------------------------------------------
function fc_hcp_txt( cFPath, cFName, cBrDok, cError )
local cCmd := ""
local cXML
local cBr_zahtjeva 
local nErr_no := 0

cCmd := 'TXT="POS RN: ' + ALLTRIM( cBrDok ) + '"'

cBr_zahtjeva := "0"
cFName := hcp_filename( cBr_zahtjeva, _tr_txt )

// putanja do izlaznog xml fajla
cXML := cFPath + _inp_dir + SLASH + cFName

// otvori xml
open_xml( cXml )

// upisi header
xml_head()

xml_subnode("USER_TEXT")

if !EMPTY( cCmd )
	
	cData := "DATA"
	cTmp := cCmd
	
	xml_snode( cData, cTmp )

endif

xml_subnode("USER_TEXT", .t.)

close_xml()

// kreiraj triger cmd.ok
c_cmdok( cFPath )

if cError == "D"
	// provjeri greske...
	// nErr_no := ...
	if _read_ok( cFPath, cFName ) = .f.
		
		// procitaj poruku greske
		nErr_no := hcp_r_error( cFPath, cFName, gFc_tout, _tr_txt ) 

	endif

endif

return nErr_no



// -------------------------------------------------------------------
// hcp komanda
// -------------------------------------------------------------------
function fc_hcp_cmd( cFPath, cFName, cCmd, cError, cTriger )
local cXML
local cBr_zahtjeva 
local nErr_no := 0

cBr_zahtjeva := "0"
cFName := hcp_filename( cBr_zahtjeva, cTriger )

// putanja do izlaznog xml fajla
cXML := cFPath + _inp_dir + SLASH + cFName

// otvori xml
open_xml( cXml )

// upisi header
xml_head()

xml_subnode("COMMAND")

if !EMPTY( cCmd )
	
	cData := "DATA"
	cTmp := cCmd
	
	xml_snode( cData, cTmp )

endif

xml_subnode("COMMAND", .t.)

close_xml()

// kreiraj triger cmd.ok
c_cmdok( cFPath )

if cError == "D"
	// provjeri greske...
	// nErr_no := ...
	if _read_ok( cFPath, cFName ) = .f.
		
		// procitaj poruku greske
		nErr_no := hcp_r_error( cFPath, cFName, gFc_tout, cTriger ) 

	endif

endif

return nErr_no


// -------------------------------------------------
// ukljuci storno racuna
// -------------------------------------------------
static function _on_storno( cBrRn )
local cCmd 

cCmd := 'CMD="REFUND_ON"'
cCmd += _razmak1 + 'NUM="' + ALLTRIM(cBrRn) + '"'

return cCmd


// -------------------------------------------------
// iskljuci storno racuna
// -------------------------------------------------
static function _off_storno()
local cCmd 

cCmd := 'CMD="REFUND_OFF"'

return cCmd


// -------------------------------------------------
// ukljuci racun za klijenta
// -------------------------------------------------
static function _on_partn( cIBK )
local cCmd 

cCmd := 'CMD="SET_CLIENT"'
cCmd += _razmak1 + 'NUM="' + ALLTRIM( cIBK )+ '"'

return cCmd



// ------------------------------------------------
// vraca vrstu placanja na osnovu oznake
// ------------------------------------------------
static function _g_v_plac( nID )
local cRet := "-"

do case 
	case nId = 0
		cRet := "0"
	case nId = 1
		cRet := "1"		
	case nId = 2
		cRet := "2"
	case nId = 3
		cRet := "3"

endcase

return cRet 


// ------------------------------------------
// vraca jedinicu mjere
// ------------------------------------------
static function _g_jmj( cJmj )
cF_jmj := "0"
do case
	case UPPER(ALLTRIM(cJmj)) = "KOM"
		// PDV je tarifna skupina "3"
		cF_jmj := "0"
	
	case UPPER(ALLTRIM(cJmj)) = "LIT"
		// nePDV 
		cF_jmj := "1"
	// case 
	// ....

endcase

return cF_jmj




// ------------------------------------------
// vraca tarifu za fiskalni stampac
// ------------------------------------------
static function _g_tar( cIdTar )
cF_tar := "3"
do case
	case UPPER(ALLTRIM(cIdTar)) == "PDV17"
		// PDV je tarifna skupina "3"
		cF_tar := "1"
	
	case UPPER(ALLTRIM(cIdTar)) == "PDV0"
		// nePDV 
		cF_tar := "0"
	// case 
	// ....

endcase

return cF_tar



// ----------------------------------------
// fajl za pos fiskalni stampac
// ----------------------------------------
static function hcp_filename( cBrRn, cTriger )
local cRet
local cF_name := ALLTRIM( gFC_name )

if cTriger == nil
	cTriger := ""
endif

cTriger := ALLTRIM(cTriger)

do case

	case "$rn" $ cF_name
		// broj racuna.xml
		cRN := PADL( ALLTRIM( cBrRn ), 8, "0" )
		cRet := STRTRAN( cF_name, "$rn", cRN )
		cRet := UPPER( cRet )
	
	case "TR$" $ cF_name
		// odredjuje PLU ili CLI ili RCP na osnovu trigera
		cRet := STRTRAN( cF_name, "TR$", cTriger )
		cRet := UPPER( cRet )
	
	otherwise 
		// ono sta je navedeno u parametrima
		cRet := cF_name

endcase

return cRet


// -----------------------------------------------------
// dnevni fiskalni izvjestaj
// -----------------------------------------------------
function hcp_z_rpt( cFPath, cFName, cError )
local cCmd

cCmd := 'CMD="Z_REPORT"'
nErr := fc_hcp_cmd( cFPath, cFName, cCmd, cError, _tr_cmd )

return


// -----------------------------------------------------
// presjek stanja
// -----------------------------------------------------
function hcp_x_rpt( cFPath, cFName, cError )
local cCmd

cCmd := 'CMD="X_REPORT"'
nErr := fc_hcp_cmd( cFPath, cFName, cCmd, cError, _tr_cmd )

return


// -----------------------------------------------------
// reset prodaje
// -----------------------------------------------------
function hcp_reset( cFPath, cFName, cError )
local cCmd

cCmd := 'CMD="RESET_SOLD_PLU"'
nErr := fc_hcp_cmd( cFPath, cFName, cCmd, cError, _tr_cmd )

return


// ---------------------------------------------------
// polog pazara
// ---------------------------------------------------
function hcp_polog( cFPath, cFName, cError )
local cCmd
local nValue := 0

// box - daj broj racuna
Box(,1, 60)
	@ m_x + 1, m_y + 2 SAY "Unosim polog od:" GET nValue ;
		PICT "99999.99"
	read
BoxC()

if LastKey() == K_ESC .or. nValue = 0
	return
endif

if nValue < 0
	// polog komanda
	cCmd := 'CMD="CASH_OUT"'
else
	// polog komanda
	cCmd := 'CMD="CASH_IN"'
endif

cCmd += _razmak1 + 'VALUE="' +  ALLTRIM(STR( ABS(nValue), 12, 2)) + '"'

nErr := fc_hcp_cmd( cFPath, cFName, cCmd, cError, _tr_cmd )

return




// ---------------------------------------------------
// stampa kopije racuna
// ---------------------------------------------------
function hcp_rn_copy( cFPath, cFName, cError )
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

if cRefund == "N"
	// obicni racun
	cCmd := 'CMD="RECEIPT_COPY"'
else
	// reklamni racun
	cCmd := 'CMD="REFOUND_RECEIPT_COPY"'
endif

cCmd += _razmak1 + 'NUM="' +  ALLTRIM(cBrRn) + '"'

nErr := fc_hcp_cmd( cFPath, cFName, cCmd, cError, _tr_cmd )

return



// --------------------------------------------
// cekanje na fajl odgovora
// --------------------------------------------
static function _read_ok( cFPath, cFName, nTimeOut )
local lOk := .t.
local cTmp
local nTime

if nTimeOut == nil
	nTimeOut := 30
endif

nTime := nTimeOut

cTmp := cFPath + _answ_dir + SLASH + STRTRAN( cFName, "XML", "OK" )

Box(,1,50)

do while nTime > 0
	
	-- nTime

	if FILE( cTmp )
		// fajl se pojavio - izadji iz petlje !
		exit
	endif

	@ m_x + 1, m_y + 2 SAY PADR( "Cekam odgovor OK: " + ;
		ALLTRIM( STR(nTime) ), 48)

	sleep(1)
enddo

BoxC()

if !FILE(cTmp)
	lOk := .f.
else
	// obrisi fajl "OK"
	FERASE( cTmp )
endif

return lOk


// ----------------------------------
// create cmd.ok file
// ----------------------------------
function c_cmdok( cFPath )
local cTmp 

cTmp := ALLTRIM(cFPath) + _inp_dir + SLASH + _cmdok

// iskoristit cu postojecu funkciju za kreiranje xml fajla...
open_xml( cTmp )

close_xml()

return


// ----------------------------------
// delete cmd.ok file
// ----------------------------------
function d_cmdok( cFPath )
local cTmp 

cTmp := ALLTRIM(cFPath) + _inp_dir + SLASH + _cmdok

if FERASE( cTmp ) < 0
	// ...
	msgbeep("greska sa brisanjem fajla CMD.OK !")
endif

return


// --------------------------------------------------
// brise fajl greske
// --------------------------------------------------
function hcp_d_error( cFPath, cFName )
local nErr := 0
local cF_name

// primjer: c:\hcp\from_fp\RAC001.ERR
cF_name := cFPath + _answ_dir + SLASH + STRTRAN( cFName, "XML", "ERR" )

if FERASE( cF_name ) < 0
	// ...
	msgbeep("greska sa brisanjem fajla...")
endif

return



// ------------------------------------------------
// citanje gresaka za HCP driver
// 
// nTimeOut - time out fiskalne operacije
// nFisc_no - broj fiskalnog isjecka
// ------------------------------------------------
function hcp_r_error( cFPath, cFName, nTimeOut, cTriger )
local nErr := 0
local cF_name
local i
local nBrLin
local nStart
local cErr
local aErr_read
local aErr_data
local nTime 
local cErrCode := ""
local cErrDesc := ""

nTime := nTimeOut

// primjer: c:\hcp\from_fp\RAC001.ERR
cF_name := cFPath + _answ_dir + SLASH + STRTRAN( cFName, "XML", "ERR" )

// ova opcija podrazumjeva da je uklju�ena opcija 
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

	aErr := TokToNiz( cErr, "-" )

	// ovo je kod greske, npr. 1
	cErrCode := ALLTRIM( aErr[1] )
	cErrDesc := ALLTRIM( aErr[2] )

	if !EMPTY( cErrCode )
		exit
	endif

next

if !EMPTY( cErrCode )
	msgbeep("Greska: " + cErrCode + " - " + cErrDesc )
	nErr := VAL( cErrCode )
	FERASE( cF_name )
endif



return nErr



// -------------------------------------------
// programiranje artikala
// -------------------------------------------
function hcp_pr_plu( cFPath, cFName, cErr )
local nTARea := SELECT()

O_SIFV
O_SIFK
O_ROBA
select roba

go top

do while !EOF()


	AADD( aArr, { "", "", field->id, field->naz,  ;
		field->cijena, "", "", field->idtarifa, ;
		"", "", field->jmj, field->fisc_plu } )


	skip
enddo

if LEN( aArr ) > 0
	// posalji komandu za programiranje
	fc_hcp_plu( cFName, cFPath, aArr, cErr )
endif

select (nTArea)

return


// -------------------------------------------
// programiranje klijenata
// -------------------------------------------
function hcp_pr_cli( cFPath, cFName, cErr )
local nTArea := SELECT()
local aArr := {}

O_SIFV
O_SIFK
O_PARTN
select partn

go top

do while !EOF()

	if goModul:oDataBase:cModul == "TOPS"

		if !EMPTY( field->jib )
	  		AADD( aArr, { field->jib, field->naz, ;
				field->adresa, field->ptt, field->mjesto } )
		endif

	else
		cJib := IzSifK( "PARTN", "REGB", field->id, .f. )
		if !EMPTY( cJib )
	  		AADD( aArr, { cJib, field->naz, ;
				field->adresa, field->ptt, field->mjesto } )
		endif

	endif

	skip
enddo

if LEN( aArr ) > 0
	// posalji komandu za programiranje
	fc_hcp_client( cFName, cFPath, aArr, cErr )
endif

select (nTArea)
return


