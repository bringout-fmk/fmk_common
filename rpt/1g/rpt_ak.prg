#include "ld.ch"

// ---------------------------------------
// otvara potrebne tabele
// ---------------------------------------
static function o_tables()

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
static function ld_sort(cRj, cGodina, cMjesec, cMjesecDo )

if EMPTY(cRj)
	INDEX ON str(godina)+SortPrez(idradn)+str(mjesec)+idrj TO "TMPLD"
	go top
	seek str(cGodina,4)
		
else
	INDEX ON str(godina)+idrj+SortPrez(idradn)+str(mjesec) TO "TMPLD"
	go top
	seek str(cGodina,4)+cRj
endif

return


// ---------------------------------------------
// upisivanje podatka u pomocnu tabelu za rpt
// ---------------------------------------------
static function _ins_tbl( cJMB, cRadnNaz, nPrihod, ;
		nRashod, nDohodak, nDopZdr, ;
		nOsn_por, nIzn_por, nDoprPio )

local nTArea := SELECT()

O_R_EXP
select r_export
append blank

replace jmb with cJMB
replace naziv with cRadnNaz
replace prihod with nPrihod
replace rashod with nRashod
replace dohodak with nDohodak
replace dop_zdr with nDopZdr
replace osn_por with nOsn_Por
replace izn_por with nIzn_Por
replace dop_pio with nDopPio

select (nTArea)
return



// ---------------------------------------------
// kreiranje pomocne tabele
// ---------------------------------------------
static function cre_tmp_tbl()
local aDbf := {}

AADD(aDbf,{ "JMB", "C", 13, 0 })
AADD(aDbf,{ "NAZIV", "C", 30, 0 })
AADD(aDbf,{ "PRIHOD", "N", 12, 2 })
AADD(aDbf,{ "RASHOD", "N", 12, 2 })
AADD(aDbf,{ "DOHODAK", "N", 12, 2 })
AADD(aDbf,{ "DOP_ZDR", "N", 12, 2 })
AADD(aDbf,{ "OSN_POR", "N", 12, 2 })
AADD(aDbf,{ "IZN_POR", "N", 12, 2 })
AADD(aDbf,{ "DOP_PIO", "N", 12, 2 })

t_exp_create( aDbf )
// index on ......

return


// ------------------------------------------
// akontacija poreza po odbitku....
// ------------------------------------------
function r_ak_list()
local i
local cRj := SPACE(60)
local cRadnik := SPACE(_LR_) 
local cIdRj
local cMjesec
local cMjesecDo
local cGodina
local cDopr1X := "1X"
local cDopr2X := "2X"
local cTipRada := "1"

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

Box("#RPT: AKONTACIJA POREZA PO ODBITKU...", 12, 75)

@ m_x + 1, m_y + 2 SAY "Radne jedinice: " GET cRj PICT "@!S25"
@ m_x + 2, m_y + 2 SAY "Za mjesece od:" GET cMjesec pict "99"
@ m_x + 2, col() + 2 SAY "do:" GET cMjesecDo pict "99" ;
	VALID cMjesecDo >= cMjesec
@ m_x + 3, m_y + 2 SAY "Godina: " GET cGodina pict "9999"
@ m_x + 5, m_y + 2 SAY "   Doprinos zdr: " GET cDopr1X
@ m_x + 6, m_y + 2 SAY "   Doprinos pio: " GET cDopr2X

@ m_x + 8, m_y + 2 SAY "Naziv preduzeca: " GET cPredNaz pict "@S30"
@ m_x + 9, col()+1 SAY "JID: " GET cPredJMB
@ m_x + 10, m_y + 2 SAY "Adresa: " GET cPredAdr pict "@S30"

@ m_x + 12, m_y + 2 SAY "(1) povremene samost.dj. (2) druge samost.dj." ;
	GET cTipRada ;
	VALID cTipRada $ "1#2" 

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
ld_sort( cRj, cGodina, cMjesec, cMjesecDo )

// nafiluj podatke obracuna
fill_data( cRj, cGodina, cMjesec, cMjesecDo, ;
	cDopr1X, cDopr2X, cTipRada )

// printaj obracunski list
ak_print( cMjesec, cMjesecDo, cTipRada )

return



// ----------------------------------------------
// stampa akontacije ....
// ----------------------------------------------
static function ak_print( cMjesec, cMjesecDo, cTipRada )
local cLine := ""
local nPageNo := 0

O_R_EXP
select r_export
go top

START PRINT CRET
? "#%LANDS#"

// zaglavlje izvjestaja
ak_zaglavlje( ++nPageNo, cTipRada, "" )
P_COND2
// zaglavlje tabele
cLine := ak_t_header()


nUprihod := 0
nUrashod:= 0
nUdohodak := 0
nUDopPio := 0
nUDopZdr := 0
nUOsnPor := 0
nUIznPor := 0

do while !EOF()

	if prow() > 54
		// nova strana
		FF
		ak_zaglavlje( ++nPageNo, cTipRada, "" )
		P_COND2
		ak_t_header()
	endif

	? jmb

	@ prow(), pcol() + 1 SAY PADR( naziv, 30 )

	@ prow(), nPoc:=pcol()+1 SAY STR(prihod,12,2)
	
	nUPrihod += prihod
	
	@ prow(), pcol()+1 SAY STR(rashod,12,2)
	
	nUrashod += rashod
	
	@ prow(), pcol()+1 SAY STR(dohodak,12,2)
	
	nUDohodak += dohodak
	
	@ prow(), pcol()+1 SAY STR(dop_zdr,12,2)
	
	nUDopZdr += dop_zdr
	
	@ prow(), pcol()+1 SAY STR(osn_por,12,2)

	nUOsnPor += osn_por
	
	@ prow(), pcol()+1 SAY STR(izn_por,12,2)
	
	nUIznPor += izn_por
	
	@ prow(), pcol()+1 SAY STR(dop_pio,12,2)
	
	nUDopPio += dop_pio
	
	skip
enddo

? cLine

? "UKUPNO:"
@ prow(), nPoc SAY STR(nUPrihod,12,2)
@ prow(), pcol()+1 SAY STR(nUrashod,12,2)
@ prow(), pcol()+1 SAY STR(nUdohodak,12,2)
@ prow(), pcol()+1 SAY STR(nUDopSt,12,2)
@ prow(), pcol()+1 SAY STR(nUDopZdr,12,2)
@ prow(), pcol()+1 SAY STR(nUOsnPor,12,2)
@ prow(), pcol()+1 SAY STR(nUIznPor,12,2)
@ prow(), pcol()+1 SAY STR(nUDopPio,12,2)

? cLine

at_potpis()

FF
END PRINT

return

// ---------------------------------------
// potpis za obrazac GIP
// ---------------------------------------
static function at_potpis()

P_12CPI
P_COND
? "Upoznat sam sa sankicajama propisanim Zakonom o Poreznoj upravi FBIH i izjavljujem"
? "da su svi podaci navedeni u ovoj prijavi tacni, potpuni i jasni"
? SPACE(80) + "Potpis poreznog obveznika", SPACE(5) + "Datum:"

return


// ----------------------------------------
// stampa headera tabele
// ----------------------------------------
static function at_t_header()
local aLines := {}
local aTxt := {}
local i 
local cLine := ""
local cTxt1 := ""
local cTxt2 := ""
local cTxt3 := ""
local cTxt4 := ""

AADD( aLines, { REPLICATE("-", 13) } )
AADD( aLines, { REPLICATE("-", 30) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )
AADD( aLines, { REPLICATE("-", 12) } )

AADD( aTxt, { "JMB poreznog", "obveznika", "", "7" })
AADD( aTxt, { "Prezime i ime", "poreznog obveznika", "", "8" })
AADD( aTxt, { "Iznos", "prihoda", "", "9" })
AADD( aTxt, { "Iznos", "rashoda", "(20% ili 30%)", "10" })
AADD( aTxt, { "Iznos", "dohotka", "(9 - 10)", "11" })
AADD( aTxt, { "Zdravstveno", "osiguranje", "(11 x 0.04)", "12" })
AADD( aTxt, { "Osnovica", "za porez", "(11 - 12)", "13" })
AADD( aTxt, { "Iznos", "poreza", "(13 x 0.1)", "14" })
AADD( aTxt, { "PIO", "", "(11 x 0.06)", "15" })

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
// stampa zaglavlja izvjestaja
// ----------------------------------------
static function at_zaglavlje( nPage, cDatIspl, cTipRada )
local cObrazac 
local cInfo

if cTipRada == "1"
	cObrazac := "Obrazac AUG-1031"
	cInfo := "ZA POVREMENE SAMOSTALNE DJELATNOSTI"
elseif cTipRada == "2"
	cObrazac := "Obrazac ASD-1032"
	cInfo := "NA PRIHODE OD DRUGIH SAMOSTALNIH DJELATNOSTI"
	cInfo := 
endif

?
P_10CPI
B_ON
? SPACE(10) + cObrazac
? SPACE(2) + "AKONTACIJA POREZA PO ODBITKU"
? SPACE(2) + cInfo
B_OFF
P_10CPI
@ prow(), pcol() + 10 SAY "Stranica: " + ALLTRIM(STR(nPage))
P_COND

if cTipRada == "1"
	? "1) Vrsta prijave:"
	? "   a) Povremene samostalne djelatnosti   b) autorski honorari"
	?
else
	?
endif

? "Dio 1 - podaci o isplatiocu"
P_12CPI

? PADR( "Naziv: " + cPredNaz, 60 ), "JIB/JMB: " + cPredJmb 
? PADR( "Adresa: " + cPredAdr, 60 ), "Datum isplate: " + cDatIspl

?
P_10CPI
P_COND
? SPACE(1) + "Dio 2 - podaci o prihodima, porezu i doprinosima"

return



// ---------------------------------------------------------
// napuni podatke u pomocnu tabelu za izvjestaj
// ---------------------------------------------------------
static function fill_data( cRj, cGodina, cMjesec, cMjesecDo, ;
	cDopr1X, cDopr2X, cTipRada )
local i
local cPom

select ld

do while !eof() .and. field->godina = cGodina  

	if field->mjesec > cMjesecDo .or. ;
		field->mjesec < cMjesec 
		
		skip
		loop

	endif

	cT_radnik := field->idradn

	// samo pozicionira bazu PAROBR na odgovarajuci zapis
	ParObr( cMjesec )

	select radn
	seek cT_radnik
	
	// uzmi samo odgovarajuce tipove rada
	if cTipRada == "1" .and. !(radn->tiprada $ "A#U") .or. ;
		cTipRada == "2" .and. !(radn->tiprada $ "P")
		select ld
		skip
		loop
	endif

	cR_jmb := radn->matbr
	cR_naziv := ALLTRIM( radn->naz ) + " " + ALLTRIM( radn->ime ) 

	select ld

	nRashod := 0
	nPrihod := 0
	nDohodak := 0
	nDopPio := 0
	nDopZdr := 0
	nPorOsn := 0
	nPorIzn := 0
	nTrosk := 0

	do while !eof() .and. field->mjesec <= cMjesecDo ;
		.and. field->mjesec >= cMjesec ;
		.and. field->godina = cGodina  ;
		.and. field->idradn == cT_radnik

		nNeto := field->uneto
		
		cTipRada := radn->tiprada

		cTrosk := radn->trosk
		
		nKLO := radn->klo
		
		nL_odb := field->ulicodb
		
		if cTipRada == "A"
			nTrosk := gAhTrosk
		elseif cTipRada == "U"
			nTrosk := gUgTrosk
		endif

		// prihod
		nPrihod := bruto_osn( nNeto, cTipRada, nL_odb, nil, cTrosk ) 
		
		// rashod
		nRashod := nPrihod * (nTrosk / 100)

		// dohodak
		nDohodak := nPrihod - nRashod

		// ukupno dopr iz 
		nDoprIz := u_dopr_iz( nDohodak, cTipRada )
		
		// osnovica za porez
		nPorOsn := ( nDohodak - nDoprIz ) - nL_odb
		
		// porez je ?
		nPorez := izr_porez( nPorOsn, "B" )
		
		select ld
		
		// ocitaj doprinose, njihove iznose
		nDopr1X := g_dopr( cDopr1X, cTipRada )
		nDopr2X := g_dopr( cDopr2X, cTipRada )
		
		// izracunaj doprinose
		nIDopr1X := round2( nDohodak * nDopr1X / 100, gZaok2 )
		nIDopr2X := round2( nDohodak * nDopr2X / 100, gZaok2 )
 
		// ubaci u tabelu podatke
		_ins_tbl( cR_jmb, ; 
				cR_naziv, ;
				nPrihod, ;
				nRashod, ;
				nDohodak, ;
				nIDopr1X, ;
				nPorOsn, ;
				nPorez, ;
				nIDopr2X )
				
		select ld
		skip

	enddo

enddo

return


