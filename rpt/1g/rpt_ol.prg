#include "ld.ch"

// ---------------------------------------
// otvara potrebne tabele
// ---------------------------------------
static function o_tables()

O_OBRACUNI
O_PAROBR
O_PARAMS
O_RJ
O_RADN
O_KBENEF
O_VPOSLA
O_TIPPR
O_KRED
O_DOPR
O_POR
O_LD

return

// ---------------------------------------------------------
// sortiranje tabele LD
// ---------------------------------------------------------
static function ld_sort(cRj, cGodina, cMjesec, cMjesecDo, cRadnik, cTipRpt )

if EMPTY(cRadnik) 
	if cTipRpt $ "1#2"
	  if EMPTY(cRj)
		INDEX ON str(godina)+SortPrez(idradn)+str(mjesec)+idrj TO "TMPLD"
		go top
		seek str(cGodina,4)
		
	  else
		INDEX ON str(godina)+idrj+SortPrez(idradn)+str(mjesec) TO "TMPLD"
		go top
		seek str(cGodina,4)+cRj
	  endif

	else
	  if EMPTY(cRj)
		INDEX ON str(godina)+str(mjesec)+SortPrez(idradn)+idrj TO "TMPLD"
		go top
		seek str(cGodina,4)+str(cMjesec,2)+cRadnik
		
	  else
		INDEX ON str(godina)+idrj+str(mjesec)+SortPrez(idradn) TO "TMPLD"
		go top
		seek str(cGodina,4)+cRj+str(cMjesec,2)+cRadnik
	  endif
	endif
else
	if EMPTY(cRj)
		set order to tag (TagVO("2"))
		go top
		seek str(cGodina,4)+str(cMjesec,2)+cRadnik
	else
		go top
		seek str(cGodina,4)+cRj+str(cMjesec,2)+cRadnik
	endif
ENDIF

return


// ---------------------------------------------
// upisivanje podatka u pomocnu tabelu za rpt
// ---------------------------------------------
static function _ins_tbl( cRadnik, cNazIspl, dDatIsplate, cMjesec, nPrihod, ;
		nPrihOst, nBruto, nDop_u_st, nDopPio, ;
		nDopZdr, nDopNez, nDop_uk, nNeto, nKLO, ;
		nLOdb, nOsn_por, nIzn_por, nUk )

local nTArea := SELECT()

O_R_EXP
select r_export
append blank

replace idradn with cRadnik
replace naziv with cNazIspl
replace mjesec with NazMjeseca( cMjesec )
replace datispl with dDatIsplate
replace prihod with nPrihod
replace prihost with nPrihOst
replace bruto with nBruto
replace dop_u_st with nDop_u_st
replace dop_pio with nDopPio
replace dop_zdr with nDopZdr
replace dop_nez with nDopNez
replace dop_uk with nDop_uk
replace neto with nNeto
replace klo with nKlo
replace l_odb with nLOdb
replace osn_por with nOsn_Por
replace izn_por with nIzn_Por
replace ukupno with nUk

select (nTArea)
return



// ---------------------------------------------
// kreiranje pomocne tabele
// ---------------------------------------------
static function cre_tmp_tbl()
local aDbf := {}

AADD(aDbf,{ "IDRADN", "C", 6, 0 })
AADD(aDbf,{ "NAZIV", "C", 15, 0 })
AADD(aDbf,{ "DATISPL", "D", 8, 0 })
AADD(aDbf,{ "MJESEC", "C", 15, 0 })
AADD(aDbf,{ "PRIHOD", "N", 12, 2 })
AADD(aDbf,{ "PRIHOST", "N", 12, 2 })
AADD(aDbf,{ "BRUTO", "N", 12, 2 })
AADD(aDbf,{ "DOP_U_ST", "N", 12, 2 })
AADD(aDbf,{ "DOP_PIO", "N", 12, 2 })
AADD(aDbf,{ "DOP_ZDR", "N", 12, 2 })
AADD(aDbf,{ "DOP_NEZ", "N", 12, 2 })
AADD(aDbf,{ "DOP_UK", "N", 12, 2 })
AADD(aDbf,{ "NETO", "N", 12, 2 })
AADD(aDbf,{ "KLO", "N", 5, 2 })
AADD(aDbf,{ "L_ODB", "N", 12, 2 })
AADD(aDbf,{ "OSN_POR", "N", 12, 2 })
AADD(aDbf,{ "IZN_POR", "N", 12, 2 })
AADD(aDbf,{ "UKUPNO", "N", 12, 2 })

t_exp_create( aDbf )
// index on ......

return


// ------------------------------------------
// obracunski list radnika
// ------------------------------------------
function r_obr_list()
local nC1:=20
local i
local cTPNaz
local nKrug:=1
local cRj := SPACE(60)
local cRadnik := SPACE(_LR_) 
local cPrihodi := SPACE(100)
local cIdRj
local cMjesec
local cMjesecDo
local cGodina
local cDopr10 := "10"
local cDopr11 := "11"
local cDopr12 := "12"
local cDopr1X := "1X"
local cTipRpt := "1"

// kreiraj pomocnu tabelu
cre_tmp_tbl()

cIdRj := gRj
cMjesec := gMjesec
cGodina := gGodina
cMjesecDo := cMjesec

cPredNaz := SPACE(50)
cPredAdr := SPACE(50)
cPredJMB := SPACE(13)

// otvori tabele
o_tables()

select params

private cSection:="4"
private cHistory:=" "
private aHistory:={}

RPar("i1",@cPredNaz)
RPar("i2",@cPredAdr)  

cPredJMB := IzFmkIni("Specif","MatBr","--",KUMPATH)
cPredJMB := PADR(cPredJMB, 13)

Box("#OBRACUNSKI LISTOVI RADNIKA", 15, 75)

@ m_x + 1, m_y + 2 SAY "Radne jedinice: " GET cRj PICT "@!S25"
@ m_x + 2, m_y + 2 SAY "Za mjesece od:" GET cMjesec pict "99"
@ m_x + 2, col() + 2 SAY "do:" GET cMjesecDo pict "99" ;
	VALID cMjesecDo >= cMjesec
@ m_x + 3, m_y + 2 SAY "Godina: " GET cGodina pict "9999"
@ m_x + 4, m_y + 2 SAY "Radnik (prazno-svi radnici): " GET cRadnik ;
	VALID EMPTY(cRadnik) .or. P_RADN(@cRadnik)
@ m_x + 5, m_y + 2 SAY "Prihodi u stvarima kolone: " GET cPrihodi pict "@S30"
@ m_x + 7, m_y + 2 SAY "   Doprinos iz pio: " GET cDopr10 
@ m_x + 8, m_y + 2 SAY "   Doprinos iz zdr: " GET cDopr11
@ m_x + 9, m_y + 2 SAY "   Doprinos iz nez: " GET cDopr12
@ m_x + 10, m_y + 2 SAY "Doprinos iz ukupni: " GET cDopr1X

@ m_x + 12, m_y + 2 SAY "Naziv preduzeca: " GET cPredNaz pict "@S30"
@ m_x + 12, col()+1 SAY "JID: " GET cPredJMB
@ m_x + 13, m_y + 2 SAY "Adresa: " GET cPredAdr pict "@S30"

@ m_x + 15, m_y + 2 SAY "(1) OLP-1021 / (2) GIP-1022: " GET cTipRpt ;
	VALID cTipRpt $ "12" 

read
	
clvbox()
	
ESC_BCR

BoxC()

if lastkey() == K_ESC
	return
endif

// upisi vrijednosti
select params
WPar("i1", cPredNaz)
WPar("i2", cPredAdr)  


select ld

// sortiraj tabelu i postavi filter
ld_sort( cRj, cGodina, cMjesec, cMjesecDo, cRadnik, cTipRpt )

// nafiluj podatke obracuna
fill_data( cRj, cGodina, cMjesec, cMjesecDo, cRadnik, cPrihodi, ;
	cDopr10, cDopr11, cDopr12, cDopr1X, cTipRpt )

// printaj obracunski list
if cTipRpt == "1"
	olp_print( cMjesec, cMjesecDo )
else
	gip_print( )
endif

return



// ----------------------------------------------
// stampa obracunskog lista
// ----------------------------------------------
static function gip_print()
local cT_radnik := ""
local cLine := ""

O_R_EXP
select r_export
go top

START PRINT CRET
? "#%LANDS#"

do while !EOF()

	cT_radnik := field->idradn

	// zaglavlje izvjestaja
	gip_zaglavlje( cT_radnik )

	P_COND2
	// zaglavlje tabele
	cLine := gip_t_header()

	nCount := 0

	nUprihod := 0
	nUPrihOst := 0
	nUBruto := 0
	nUDopSt := 0
	nUDopPio := 0
	nUDopZdr := 0
	nUDopNez := 0
	nUDopUk := 0
	nUNeto := 0
	nUKLO := 0
	nULODb := 0
	nUOsnPor := 0
	nUIznPor := 0

	do while !EOF() .and. field->idradn == cT_radnik

		? mjesec

		@ prow(), nPoc:=pcol()+1 SAY STR(prihod,12,2)
		nUPrihod += prihod
		@ prow(), pcol()+1 SAY STR(prihost,12,2)
		nUPrihOst += prihost
		@ prow(), pcol()+1 SAY STR(bruto,12,2)
		nUBruto += bruto
		@ prow(), pcol()+1 SAY STR(dop_u_st,12,2) 
		nUDopSt := dop_u_st
		@ prow(), pcol()+1 SAY STR(dop_pio,12,2)
		nUDopPio += dop_pio
		@ prow(), pcol()+1 SAY STR(dop_zdr,12,2)
		nUDopZdr += dop_zdr
		@ prow(), pcol()+1 SAY STR(dop_nez,12,2)
		nUDopNez += dop_nez
		@ prow(), pcol()+1 SAY STR(dop_uk,12,2)
		nUDopUk += dop_uk
		@ prow(), pcol()+1 SAY STR(neto,12,2)
		nUNeto += neto
		@ prow(), pcol()+1 SAY STR(klo,12,2)
		nUKLO += klo
		@ prow(), pcol()+1 SAY STR(l_odb,12,2)
		nULOdb += l_odb
		@ prow(), pcol()+1 SAY STR(osn_por,12,2)
		nUOsnPor += osn_por
		@ prow(), pcol()+1 SAY STR(izn_por,12,2)
		nUIznPor += izn_por
		@ prow(), pcol()+1 SAY datispl

		skip
	enddo

	? cLine

	? "UKUPNO:"
	@ prow(), nPoc SAY STR(nUPrihod,12,2)
	@ prow(), pcol()+1 SAY STR(nUPrihOst,12,2)
	@ prow(), pcol()+1 SAY STR(nUBruto,12,2)
	@ prow(), pcol()+1 SAY STR(nUDopSt,12,2)
	@ prow(), pcol()+1 SAY STR(nUDopPio,12,2)
	@ prow(), pcol()+1 SAY STR(nUDopZdr,12,2)
	@ prow(), pcol()+1 SAY STR(nUDopNez,12,2)
	@ prow(), pcol()+1 SAY STR(nUDopUk,12,2)
	@ prow(), pcol()+1 SAY STR(nUNeto,12,2)
	@ prow(), pcol()+1 SAY STR(nUKLO,12,2)
	@ prow(), pcol()+1 SAY STR(nULOdb,12,2)
	@ prow(), pcol()+1 SAY STR(nUOsnPor,12,2)
	@ prow(), pcol()+1 SAY STR(nUIznPor,12,2)

	? cLine

	gip_potpis()

	FF
		
enddo

END PRINT

return

// ---------------------------------------
// potpis za obrazac GIP
// ---------------------------------------
static function gip_potpis()

P_12CPI
P_COND
? "Upoznat sam sa sankicajama propisanim Zakonom o Poreznoj upravi FBIH i izjavljujem"
? "da su svi podaci navedeni u ovoj prijavi tacni, potpuni i jasni, te potvrdjujem da su svi"
? "porezi i doprinosi za ovog uposlenika uplaceni."
? SPACE(80) + "Potpis poslodavca/isplatioca", SPACE(5) + "Datum:"

return



// ----------------------------------------------
// stampa obracunskog lista
// ----------------------------------------------
static function olp_print(cMjesec, cMjesecDo)
local cT_radnik := ""
local cLine := ""

O_R_EXP
select r_export
go top

START PRINT CRET
? "#%LANDS#"

nCntPrint := 0

do while !EOF()

	cT_radnik := field->idradn
	//nMjesec := field->mjesec

	// zaglavlje izvjestaja
	olp_zaglavlje( cT_radnik )

	P_COND2

	// zaglavlje tabele
	cLine := olp_t_header()

	nCount := 0

	do while !EOF() .and. field->idradn == cT_radnik 
	//	.and. IF(cMjesec<>cMjesecDo, field->mjesec = nMjesec, .t.)

		? PADL( ALLTRIM( STR(++nCount)), 3 ) + ")"

		@ prow(), pcol()+1 SAY datispl
		@ prow(), pcol()+1 SAY PADR(ALLTRIM(naziv) + "/" + ALLTRIM(mjesec), 15)
		@ prow(), pcol()+1 SAY STR(prihod,12,2)
		@ prow(), pcol()+1 SAY STR(prihost,12,2)
		@ prow(), pcol()+1 SAY STR(bruto,12,2)
		@ prow(), pcol()+1 SAY STR(dop_u_st,12,2) PICT "999999999.99%"
		@ prow(), pcol()+1 SAY STR(dop_pio,12,2)
		@ prow(), pcol()+1 SAY STR(dop_zdr,12,2)
		@ prow(), pcol()+1 SAY STR(dop_nez,12,2)
		@ prow(), pcol()+1 SAY STR(dop_uk,12,2)
		@ prow(), pcol()+1 SAY STR(neto,12,2)
		@ prow(), pcol()+1 SAY STR(klo,12,2)
		@ prow(), pcol()+1 SAY STR(l_odb,12,2)
		@ prow(), pcol()+1 SAY STR(osn_por,12,2)
		@ prow(), pcol()+1 SAY STR(izn_por,12,2)
		@ prow(), pcol()+1 SAY STR(ukupno,12,2)

		++ nCntPrint
		
		skip
	enddo

	? cLine

	FF
		
enddo

END PRINT

return


// ----------------------------------------
// stampa headera tabele
// ----------------------------------------
static function gip_t_header()
local aLines := {}
local aTxt := {}
local i 
local cLine := ""
local cTxt1 := ""
local cTxt2 := ""
local cTxt3 := ""
local cTxt4 := ""

AADD( aLines, { REPLICATE("-", 15) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 8) } )

AADD( aTxt, { "Mjesec", "", "", "1" })
AADD( aTxt, { "Prihod", "u KM", "", "2" })
AADD( aTxt, { "Prih.u ost.", "stvarima ili", "uslugama", "3" })
AADD( aTxt, { "Bruto placa", "(2+3)", "", "4" })
AADD( aTxt, { "Ukupna stopa", "doprinosa", "iz place", "5" })
AADD( aTxt, { "Iznos dopr.", "za pio", "", "6" })
AADD( aTxt, { "Iznos dopr.", "za", "zdravstvo", "7" })
AADD( aTxt, { "Iznos dopr.", "za", "nezaposl.", "8" })
AADD( aTxt, { "Ukupno", "doprinosi", "(6+7+8)", "9" })
AADD( aTxt, { "Neto placa", "(4-9)", "", "10" })
AADD( aTxt, { "Faktor licnog", "odbitka", "", "11" })
AADD( aTxt, { "Iznos odbitka", "(11 x 300)", "", "12" })
AADD( aTxt, { "Osnovica", "poreza (10-12)", "", "13" })
AADD( aTxt, { "Iznos", "poreza", "(13 x 0.1)",  "14" })
AADD( aTxt, { "Datum", "uplate", "", "15" })

for i := 1 to LEN( aLines )
	cLine += aLines[ i, 1 ] + SPACE(1)
next

for i := 1 to LEN( aTxt )
	
	// koliko je sirok tekst ?
	nTxtLen := LEN( aLines[i, 1] )

	// prvi red
	cTxt1 += PADC( "(" + aTxt[i, 4] + ")", nTxtLen ) + SPACE(1)
	cTxt2 += PADC( aTxt[i, 1], nTxtLen ) + SPACE(1)
	cTxt3 += PADC( aTxt[i, 2], nTxtLen ) + SPACE(1)
	cTxt4 += PADC( aTxt[i, 3], nTxtLen ) + SPACE(1)

next

// ispisi zaglavlje tabele
? cLine
? cTxt1
? cTxt2
? cTxt3
? cTxt4
? cLine

return cLine




// ----------------------------------------
// stampa headera tabele
// ----------------------------------------
static function olp_t_header()
local aLines := {}
local aTxt := {}
local i 
local cLine := ""
local cTxt1 := ""
local cTxt2 := ""
local cTxt3 := ""
local cTxt4 := ""

AADD( aLines, { REPLICATE("-", 4) } )
AADD( aLines, { REPLICATE("-", 8) } )
AADD( aLines, { REPLICATE("-", 15) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )

AADD( aTxt, { "R.br", "", "", "1" })
AADD( aTxt, { "Datum", "isplate", "", "2" })
AADD( aTxt, { "Vrsta", "isplate", "", "3" })
AADD( aTxt, { "Prihod", "u KM", "", "4" })
AADD( aTxt, { "Prih.u ost.", "stvarima ili", "uslugama", "5" })
AADD( aTxt, { "Bruto placa", "(4+5)", "", "6" })
AADD( aTxt, { "Ukupna stopa", "doprinosa", "iz place", "7" })
AADD( aTxt, { "Iznos dopr.", "za pio", "", "8" })
AADD( aTxt, { "Iznos dopr.", "za", "zdravstvo", "9" })
AADD( aTxt, { "Iznos dopr.", "za", "nezaposl.", "10" })
AADD( aTxt, { "Ukupno", "doprinosi", "(8+9+10)", "11" })
AADD( aTxt, { "Neto placa", "(6-11)", "", "12" })
AADD( aTxt, { "Faktor licnog", "odbitka", "", "13" })
AADD( aTxt, { "Iznos odbitka", "(13 x 300)", "", "14" })
AADD( aTxt, { "Osnovica", "poreza (12-14)", "", "15" })
AADD( aTxt, { "Iznos", "poreza", "(15 x 0.1)",  "16" })
AADD( aTxt, { "Iznos place", "za isplatu", "(12-16)", "17" })

for i := 1 to LEN( aLines )
	cLine += aLines[ i, 1 ] + SPACE(1)
next

for i := 1 to LEN( aTxt )
	
	// koliko je sirok tekst ?
	nTxtLen := LEN( aLines[i, 1] )

	// prvi red
	cTxt1 += PADC( "(" + aTxt[i, 4] + ")", nTxtLen ) + SPACE(1)
	cTxt2 += PADC( aTxt[i, 1], nTxtLen ) + SPACE(1)
	cTxt3 += PADC( aTxt[i, 2], nTxtLen ) + SPACE(1)
	cTxt4 += PADC( aTxt[i, 3], nTxtLen ) + SPACE(1)

next

// ispisi zaglavlje tabele
? cLine
? cTxt1
? cTxt2
? cTxt3
? cTxt4
? cLine

return cLine

// ---------------------------------------
// vraca string poreznog perioda
// ---------------------------------------
static function g_por_per()

local cRet := ""

cRet += "1/1 - 31/12 "  
cRet += ALLTRIM(STR(YEAR(DATE())))
cRet += " godine"

return cRet



// ----------------------------------------
// stampa zaglavlja izvjestaja
// ----------------------------------------
static function olp_zaglavlje( cRadnik )
local nTArea := SELECT()

cPorPer := g_por_per()

?
P_10CPI
B_ON
? SPACE(10) + "Obrazac OLP-1021"
? SPACE(5) + "OBRACUNSKI LIST PLACA"
B_OFF
@ prow(), pcol() + 10 SAY "Porezni period: " + cPorPer
?
P_COND
? "Dio 1 - podaci o poslodavcu/isplatiocu i poreznom obvezniku"
P_12CPI

select radn
seek cRadnik

? PADR( "JIB/JMB isplatioca: " + cPredJmb, 60 ), "JMB zaposlenika: " + radn->matbr
? PADR( "Naziv: " + cPredNaz, 60 ), "Ime: " + ALLTRIM(radn->ime) + " (" + ;
	ALLTRIM(radn->imerod) + ") " + ALLTRIM(radn->naz) 
? PADR( "Adresa: " + cPredAdr, 60 ), "Adresa: " + ;
	ALLTRIM(radn->streetname) + " " + ;
	ALLTRIM(radn->streetnum)

?
P_COND
? SPACE(1) + "Dio 2 - podaci o isplacenim placama i drugim oporezivim naknadama, obracunatim, obustavljenim, i uplacenim doprinosima i porezu"

select (nTArea)
return

// ----------------------------------------
// stampa zaglavlja izvjestaja
// ----------------------------------------
static function gip_zaglavlje( cRadnik )
local nTArea := SELECT()

cPorPer := g_por_per()

?
P_10CPI
B_ON
? SPACE(10) + "Obrazac GIP-1022"
? SPACE(2) + "GODISNJI IZVJESTAJ O UKUPNO ISPLACENIM"
? SPACE(2) + "PLACAMA I DRUGIM LICNIM PRIMANJIMA"
B_OFF
P_10CPI
@ prow(), pcol() + 10 SAY "Porezni period: " + cPorPer
?
P_COND
? "Dio 1 - podaci o poslodavcu/isplatiocu i poreznom obvezniku"
P_12CPI

select radn
seek cRadnik

? PADR( "JIB/JMB isplatioca: " + cPredJmb, 60 ), "JMB zaposlenika: " + ;
	radn->matbr
? PADR( "Naziv: " + cPredNaz, 60 ), "Ime: " + ALLTRIM(radn->ime) + " (" + ;
	ALLTRIM(radn->imerod) + ") " + ALLTRIM(radn->naz) 
? PADR( "Adresa: " + cPredAdr, 60 ), "Adresa: " + ALLTRIM(radn->streetname) + ;
	" " + ;
	ALLTRIM(radn->streetnum)

?
P_10CPI
P_COND
? SPACE(1) + "Dio 2 - podaci o prihodima, doprinosima, porezu"

select (nTArea)
return



// ---------------------------------------------------------
// napuni podatke u pomocnu tabelu za izvjestaj
// ---------------------------------------------------------
static function fill_data( cRj, cGodina, cMjesec, cMjesecDo, ;
	cRadnik, cPrihodi, cDopr10, cDopr11, cDopr12, cDopr1X, cRptTip )
local i
local cPom
local aPrim := {}

// prihodi ostali
local nPrihOst := 0

if !EMPTY( cPrihodi )
	aPrim := TokToNiz( ALLTRIM( cPrihodi ) , ";" )
endif

lDatIspl := .f.
if obracuni->(fieldpos("DAT_ISPL")) <> 0
	lDatIspl := .t.
endif

select ld

do while !eof() .and. field->godina = cGodina  

	if field->mjesec > cMjesecDo .or. ;
		field->mjesec < cMjesec 
		
		skip
		loop

	endif

	cT_radnik := field->idradn

	if !EMPTY(cRadnik)
		if cT_radnik <> cRadnik
			skip
			loop
		endif
	endif

	// samo pozicionira bazu PAROBR na odgovarajuci zapis
	ParObr( cMjesec )

	select radn
	seek cT_radnik
	
	if !(radn->tiprada $ " #I#N") 
		select ld
		skip
		loop
	endif

	select ld

	nBruto := 0
	nPrihod := 0
	nPrihOst := 0
	nDoprStU := 0
	nDopPio := 0
	nDopZdr := 0
	nDopNez := 0
	nDopUk := 0
	nNeto := 0
	
	do while !eof() .and. field->mjesec <= cMjesecDo ;
		.and. field->mjesec >= cMjesec ;
		.and. field->godina = cGodina  ;
		.and. field->idradn == cT_radnik

		// koliki je iznos prihoda
		if !EMPTY( cPrihodi )
			for i := 1 to LEN( aPrim )
				if EMPTY( aPrim[i] )
					loop
				endif
				nPrihOst += &(aPrim[i]) 
			next
		endif

		nNeto := field->uneto
		cTipRada := radn->tiprada
		nKLO := radn->klo
		nL_odb := field->ulicodb
		
		// bruto 
		nBruto := bruto_osn( nNeto, cTipRada, nL_odb ) 
		// ukupno dopr iz 31%
		nDoprIz := u_dopr_iz( nBruto + nPrihOst, cTipRada )
		
		// osnovica za porez
		nPorOsn := ( (nBruto + nPrihOst) - nDoprIz ) - nL_odb
		
		// ako je neoporeziv radnik, nema poreza
		if radn->opor == "N" .or. ;
			( (nBruto-nPrihOst) - nDoprIz ) < nL_odb
			nPorOsn := 0
		endif
		
		// porez je ?
		nPorez := izr_porez( nPorOsn, "B" )
		
		select ld
		
		// na ruke je
		nNaRuke := ( (nBruto + nPrihOst) - nDoprIz ) - nPorez

		// ocitaj doprinose, njihove iznose
		nDopr10 := Ocitaj( F_DOPR , cDopr10 , "iznos" , .t. )
		nDopr11 := Ocitaj( F_DOPR , cDopr11 , "iznos" , .t. )
		nDopr12 := Ocitaj( F_DOPR , cDopr12 , "iznos" , .t. )
		nDopr1X := Ocitaj( F_DOPR , cDopr1X , "iznos" , .t. )
		
		// izracunaj doprinose
		nIDopr10 := round2((nBruto + nPrihOst) * nDopr10 / 100, gZaok2)
		nIDopr11 := round2((nBruto + nPrihOst) * nDopr11 / 100, gZaok2)
		nIDopr12 := round2((nBruto + nPrihOst) * nDopr12 / 100, gZaok2)
		nIDopr1X := round2((nBruto + nPrihOst) * nDopr1X / 100, gZaok2)

		dDatIspl := DATE()
		if lDatIspl 
			dDatIspl := g_isp_date( field->idrj, ;
					field->godina, ;
					field->mjesec )
		endif

		// ubaci u tabelu podatke
		_ins_tbl( cT_radnik, ;
				"placa", ;
				dDatIspl, ;
				ld->mjesec, ;
				nBruto, ;
				nPrihOst, ;
				(nBruto + nPrihOst), ;
				nDopr1X,;
				nIDopr10, ;
				nIDopr11, ;
				nIDopr12, ;
				nIDopr1X, ;
				(nBruto + nPrihOst) - nIDopr1X, ;
				nKLO, ;
				nL_Odb, ;
				nPorOsn, ;
				nPorez, ;
				((nBruto + nPrihOst) - nIDopr1X) - nPorez)
				
		select ld
		skip

	enddo

enddo

return


