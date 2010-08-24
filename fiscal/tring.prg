#include "sc.ch"


static LEN_KOLICINA := 8
static LEN_CIJENA := 10
static LEN_VRIJEDNOST := 12
static PIC_KOLICINA := ""
static PIC_VRIJEDNOST := ""
static PIC_CIJENA := ""


// fiskalne funkcije TRING fiskalizacije (www.kase.ba)

// struktura xml fajla
//
// <RacunZahtjev>
//   <BrojZahtjeva></BrojZahtjeva>
//   <VrstaZahtjeva></VrstaZahtjeva>
//   <Racun>
//     <Datum></Datum>
//     <Kupac>
//        <IdBroj></IdBroj>
//        <Naziv></Naziv>
//        <Adresa></Adresa>
//        <PostanskiBroj></PostanskiBroj>
//        <Grad></Grad>
//     </Kupac>
//     <StavkeRacuna>
//       <RacunStavka>
//          <Artikal>
//             <Sifra></Sifra>
//             <Naziv></Naziv>
//             <Cijena></Cijena>
//             <Stopa></Stopa>
//          </Artikal>
//          <Kolicina></Kolicina>
//          <Rabat></Rabat>
//       </RacunStavka>
//       <RacunStavka>
//          <.....
//       </RacunStavka>
//     </StavkeRacuna>
//     <VrstePlacanja>
//        <VrstaPlacanja>
//           <Oznaka></Oznaka>
//           <Iznos></Iznos>
//        </VrstaPlacanja>
//     </VrstePlacanja>
//     <Napomena></Napomena>
//   </Racun>
// </RacunZahtjev>


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
local cXML_tpl 
local i
local cBr_zahtjeva 
local cVr_zahtjeva
local cVr_placanja
local dRn_datum
local nKolicina
local nCijena
local cRoba_id
local cRoba_naz
local cRoba_jmj
local nRabat
local lKupac := .f.
local nErr_no := 0

PIC_KOLICINA := "9999999.99"
PIC_VRIJEDNOST := "9999999.99"
PIC_CIJENA := "9999999.99"

if aKupac <> nil .and. LEN( aKupac ) > 0
	lKupac := .t.
endif

cXML_tpl := 'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"'

// to je zapravo broj racuna !!!
cBr_zahtjeva := aData[1, 1]

// ako postoji ovaj joker, ubaci broj racuna
if "$" $ cFName
	cFName := ALLTRIM( STRTRAN( cFName, "$", cBr_zahtjeva ) )
endif

// putanja do izlaznog xml fajla
cXML := cFPath + cFName

// otvori xml
open_xml( cXml )
// upisi header
xml_head()

xml_subnode("RacunZahtjev " + cXML_tpl, .f.)

  xml_node("BrojZahtjeva", cBr_zahtjeva )
  
  // 0 - stampa sve stavke i zatvara racun
  // 1 - stampa stavku po stavku
  // 
  // Mi cemo koristiti varijantu "0"
  cVr_zahtjeva := "0"
  xml_node("VrstaZahtjeva", cVr_zahtjeva )

  xml_subnode("Racun", .f.)

    cRacun_datum := _fix_date( aData[1, 10] )
    xml_node("Datum", cRacun_datum )
    
    // ako ima podataka o kupcu
    if lKupac = .t.
    
  	xml_subnode("Kupac", .f.)

	  xml_node("IdBroj", aKupac[1, 1] )
	  xml_node("Naziv", strkzn( aKupac[1, 2], "8", "U" ) )
	  xml_node("Adresa", strkzn( aKupac[1, 3], "8", "U" ) )
	  xml_node("PostanskiBroj", aKupac[1, 4] )
	  xml_node("Grad", strkzn( aKupac[1, 5], "8", "U" ) )
  	
	xml_subnode("Kupac", .t.)	

    else

	// ako nema, onda se koristi prazan node
    	xml_node("Kupac", "" )
    
    endif
    
    xml_subnode("StavkeRacuna", .f.)

    for i:=1 to LEN( aData )

	cRoba_id := aData[i, 3]
	cRoba_naz := aData[i, 4]
	cRoba_jmj := aData[i, 11]
	nCijena := aData[i, 5]
	nKolicina := aData[i, 7]
	nRabat := aData[i, 6]
	cStopa := aData[i, 8]

	xml_subnode("RacunStavka", .f.)
	
	  xml_subnode("Artikal", .f.)
	
	    xml_node("Sifra", cRoba_id )
	    xml_node("Naziv", strkzn( cRoba_naz, "8", "U" ) )
	    xml_node("JM", cRoba_jmj )
	    xml_node("Cijena", show_number( nCijena, PIC_CIJENA ) )
	    xml_node("Stopa", cStopa )
	
	  xml_subnode("Artikal", .t.)

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

    cVr_placanja := _g_v_plac( 0 )

    xml_subnode("VrstePlacanja", .f.)
      xml_subnode("VrstaPlacanja", .f.)

         xml_node("Oznaka", cVr_placanja ) 
         xml_node("Iznos", "0" )

      xml_subnode("VrstaPlacanja", .t.)
    xml_subnode("VrstePlacanja", .t.)

    xml_node("Napomena", "" )

  xml_subnode("Racun", .t.)

xml_subnode("RacunZahtjev", .t.)

close_xml()

if cError == "D"
	// provjeri greske...
	// nErr_no := ...
endif

return nErr_no


// ------------------------------------------------
// vraca vrstu placanja na osnovu oznake
// ------------------------------------------------
static function _g_v_plac( nID )
local cRet := "GOTOVINA"
return cRet 


// ---------------------------------------------
// fiksiraj datum za xml
// ---------------------------------------------
static function _fix_date( dDate )
local cRet := ""

cRet := DTOC( dDate )

return cRet

