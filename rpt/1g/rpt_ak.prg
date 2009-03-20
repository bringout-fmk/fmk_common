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
O_DOPR
O_POR
O_LD

return

// ---------------------------------------------------------
// sortiranje tabele LD
// ---------------------------------------------------------
static function ld_sort( cRj, cGodina, cMjesec, cObr )
local cFilter := ""

if lViseObr
	if !EMPTY(cObr)
		cFilter += "ld->obr == " + cm2str(cObr)
	endif
endif
	
if !EMPTY(cRj)
	cFilter += Parsiraj(cRj, "IDRJ")
endif

if !EMPTY(cFilter)
	set filter to &cFilter
	go top
endif

index on str(godina)+str(mjesec)+SortPrez(idradn)+idrj TO "TMPLD"
go top
seek str(cGodina,4)+str(cMjesec,2)	

return


// ---------------------------------------------
// upisivanje podatka u pomocnu tabelu za rpt
// ---------------------------------------------
static function _ins_tbl( cJMB, cRadnNaz, nPrihod, ;
		nRashod, nDohodak, nDopZdr, ;
		nOsn_por, nIzn_por, nDopPio )

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
local cRj := SPACE(65)
local cIdRj
local cMjesec
local cGodina
local cDopr1X := "1X"
local cDopr2X := "2X"
local cTipRada := "1"
local cVarPrn := "2"
local cObracun := gObracun

// kreiraj pomocnu tabelu
cre_tmp_tbl()

cIdRj := gRj
cMjesec := gMjesec
cGodina := gGodina

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

Box("#RPT: AKONTACIJA POREZA PO ODBITKU...", 13, 75)

@ m_x + 1, m_y + 2 SAY "Radne jedinice: " GET cRj pict "@S25"
@ m_x + 2, m_y + 2 SAY "Za mjesec:" GET cMjesec pict "99"
@ m_x + 3, m_y + 2 SAY "Godina: " GET cGodina pict "9999"

if lViseObr
  	@ m_x+3,col()+2 SAY "Obracun:" GET cObracun WHEN HelpObr(.t.,cObracun) VALID ValObr(.t.,cObracun)
endif

@ m_x + 5, m_y + 2 SAY "   Doprinos zdr: " GET cDopr1X
@ m_x + 6, m_y + 2 SAY "   Doprinos pio: " GET cDopr2X

@ m_x + 8, m_y + 2 SAY "Naziv preduzeca: " GET cPredNaz pict "@S30"
@ m_x + 8, col()+1 SAY "JID: " GET cPredJMB
@ m_x + 9, m_y + 2 SAY "Adresa: " GET cPredAdr pict "@S30"

@ m_x + 11, m_y + 2 SAY "(1) AUG-1031 (2) ASD-1032 (3) PDN-1033" ;
	GET cTipRada ;
	VALID cTipRada $ "1#2#3" 

@ m_x + 12, m_y + 2 SAY "Varijanta stampe (txt/drb):" GET cVarPrn PICT "@!" VALID cVarPrn $ "12"

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
ld_sort( cRj, cGodina, cMjesec, cObracun )

// nafiluj podatke obracuna
fill_data( cRj, cGodina, cMjesec, ;
	cDopr1X, cDopr2X, cTipRada, cObracun )


dDatIspl := DATE()
if obracuni->(fieldpos("DAT_ISPL")) <> 0
	dDatIspl := g_isp_date( "  ", cGodina, cMjesec )
endif

cPeriod := ALLTRIM(STR(cMjesec)) + "/" + ALLTRIM(STR(cGodina))

if cVarPrn == "1" 
	// printaj obracunski list
	ak_print( dDatIspl, cPeriod, cTipRada )
endif

if cVarPrn == "2"
	// printaj u delphi
	ak_d_print( dDatIspl, cPeriod, cTipRada )
endif

return



// ----------------------------------------------
// stampa akontacije ....
// ----------------------------------------------
static function ak_print( dDatIspl, cPeriod, cTipRada )
local cLine := ""
local nPageNo := 0
local nPoc := 1

O_R_EXP
select r_export
go top

START PRINT CRET
? "#%LANDS#"

// zaglavlje izvjestaja
ak_zaglavlje( ++nPageNo, cTipRada, dDatIspl, cPeriod )
P_COND
// zaglavlje tabele
cLine := ak_t_header( cTipRada )

nUprihod := 0
nUrashod:= 0
nUdohodak := 0
nUDopPio := 0
nUDopZdr := 0
nUOsnPor := 0
nUIznPor := 0

// sracunaj samo total
do while !EOF()
	nUPrihod += prihod
	nURashod += rashod
	nUDohodak += dohodak
	nUDopPio += dop_pio
	nUDopZdr += dop_zdr
	nUOsnPor += osn_por
	nUIznPor += izn_por
	skip
enddo

go top

// sada ispisi izvjestaj
do while !EOF()

	? jmb
	
	@ prow(), pcol() + 1 SAY PADR( naziv, 30 )
	
	if cTipRada == "1"
		@ prow(), nPoc:=pcol()+1 SAY STR(prihod,12,2)
		@ prow(), pcol()+1 SAY STR(rashod,12,2)
		@ prow(), pcol()+1 SAY STR(dohodak,12,2)
	else
		@ prow(), nPoc:=pcol()+1 SAY STR(dohodak,12,2)
	endif

	if cTipRada $ "1#2"
		@ prow(), pcol()+1 SAY STR(dop_zdr,12,2)
		@ prow(), pcol()+1 SAY STR(osn_por,12,2)
		@ prow(), pcol()+1 SAY STR(izn_por,12,2)
		@ prow(), pcol()+1 SAY STR(dop_pio,12,2)
	else
		@ prow(), pcol()+1 SAY STR(izn_por,12,2)
	endif

	if ( nPageNo = 1 .and. prow() > 38 ) .or. ;
		( nPageNo <> 1 .and. prow() > 40 )
		
		? cLine

		? "UKUPNO ZA SVE STRANICE:"
		
		if cTipRada == "1"
			@ prow(), nPoc SAY STR(nUPrihod,12,2)
			@ prow(), pcol()+1 SAY STR(nUrashod,12,2)
			@ prow(), pcol()+1 SAY STR(nUdohodak,12,2)
		else
			@ prow(), nPoc SAY STR(nUdohodak,12,2)
		endif
		
		if cTipRada $ "1#2"
			@ prow(), pcol()+1 SAY STR(nUDopZdr,12,2)
			@ prow(), pcol()+1 SAY STR(nUOsnPor,12,2)
			@ prow(), pcol()+1 SAY STR(nUIznPor,12,2)
			@ prow(), pcol()+1 SAY STR(nUDopPio,12,2)
		else
			@ prow(), pcol()+1 SAY STR(nUIznPor,12,2)
		endif

		? cLine
		
		if nPageNo = 1
			ak_potpis()
		endif

		FF
	
		ak_zaglavlje( ++nPageNo, cTipRada, dDatIspl, cPeriod )
		P_COND
		ak_t_header( cTipRada )
	
	endif

	skip
enddo

? cLine

? "UKUPNO:"

if cTipRada == "1"
	
	@ prow(), nPoc SAY STR(nUPrihod,12,2)
	@ prow(), pcol()+1 SAY STR(nUrashod,12,2)
	@ prow(), pcol()+1 SAY STR(nUdohodak,12,2)

else
	
	@ prow(), nPoc SAY STR(nUdohodak,12,2)

endif

if cTipRada $ "1#2"
	@ prow(), pcol()+1 SAY STR(nUDopZdr,12,2)
	@ prow(), pcol()+1 SAY STR(nUOsnPor,12,2)
	@ prow(), pcol()+1 SAY STR(nUIznPor,12,2)
	@ prow(), pcol()+1 SAY STR(nUDopPio,12,2)
else
	@ prow(), pcol()+1 SAY STR(nUIznPor,12,2)
endif

? cLine

ak_potpis()

FF
END PRINT

return


// ----------------------------------------------
// stampa akontacije delphirb ....
// ----------------------------------------------
static function ak_d_print( dDatIspl, cPeriod, cTipRada )
local cLine := ""
local nPageNo := 0
local nPoc := 1
local cIni := EXEPATH + "proizvj.ini"
local cRtmFile := ""

private cKom := ""

O_R_EXP
select r_export
index on naziv tag "1"
go top

// upisi podatke za header
UzmiIzIni( cIni, "Varijable", "ISP_NAZ", cPredNaz, "WRITE" )
UzmiIzIni( cIni, "Varijable", "ISP_ADR", cPredAdr, "WRITE" )
UzmiIzIni( cIni, "Varijable", "ISP_JMB", cPredJMB, "WRITE" )
UzmiIzIni( cIni, "Varijable", "ISP_PER", cPeriod, "WRITE" )
UzmiIzIni( cIni, "Varijable", "ISP_DAT", DTOC(dDatIspl), "WRITE" )

nUprihod := 0
nUrashod:= 0
nUdohodak := 0
nUDopPio := 0
nUDopZdr := 0
nUOsnPor := 0
nUIznPor := 0

// sracunaj samo total
do while !EOF()
	nUPrihod += prihod
	nURashod += rashod
	nUDohodak += dohodak
	nUDopPio += dop_pio
	nUDopZdr += dop_zdr
	nUOsnPor += osn_por
	nUIznPor += izn_por
	skip
enddo

// upisi totale
UzmiIzIni( cIni, "Varijable", "TOT_PRIH", nUPrihod, "WRITE" )
UzmiIzIni( cIni, "Varijable", "TOT_RAS", nURashod, "WRITE" )
UzmiIzIni( cIni, "Varijable", "TOT_DOH", nUDohodak, "WRITE" )
UzmiIzIni( cIni, "Varijable", "TOT_ZDR", nUDopZdr, "WRITE" )
UzmiIzIni( cIni, "Varijable", "TOT_OP", nUOsnPor, "WRITE" )
UzmiIzIni( cIni, "Varijable", "TOT_IP", nUIznPor, "WRITE" )
UzmiIzIni( cIni, "Varijable", "TOT_PIO", nUDopPio, "WRITE" )

select r_export
use

if cTipRada == "1"
	cRtm := "aug1031"
elseif cTipRada == "2"
	cRtm := "asd1032"
elseif cTipRada == "3"
	cRtm := "pdn1033"
endif

cKom := "delphirb " + cRtm + " " + PRIVPATH + "  r_export  1" 

if pitanje(,"Aktivirati drb (D/N)", "D") == "D"
	run &cKom
endif

return




// ---------------------------------------
// potpis za obrazac GIP
// ---------------------------------------
static function ak_potpis()

P_12CPI
P_COND
? "Upoznat sam sa sankicajama propisanim Zakonom o Poreznoj upravi FBIH i izjavljujem"
? "da su svi podaci navedeni u ovoj prijavi tacni, potpuni i jasni", SPACE(10) + "Potpis poreznog obveznika", SPACE(5) + "Datum:"

return


// ----------------------------------------
// stampa headera tabele
// ----------------------------------------
static function ak_t_header( cVRada )
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
if cVRada == "1"
	AADD( aLines, { REPLICATE("-", 12) } )
	AADD( aLines, { REPLICATE("-", 12) } )
endif
AADD( aLines, { REPLICATE("-", 12) } )
if cVRada $ "1#2"
	AADD( aLines, { REPLICATE("-", 12) } )
	AADD( aLines, { REPLICATE("-", 12) } )
	AADD( aLines, { REPLICATE("-", 12) } )
endif
AADD( aLines, { REPLICATE("-", 12) } )

if cVRada == "1"
	AADD( aTxt, { "JMB poreznog", "obveznika", "", "7" })
	AADD( aTxt, { "Prezime i ime", "poreznog obveznika", "", "8" })	
	AADD( aTxt, { "Iznos", "prihoda", "", "9" })
	AADD( aTxt, { "Iznos", "rashoda", "(20% ili 30%)", "10" })
	AADD( aTxt, { "Iznos", "dohotka", "(9 - 10)", "11" })
	AADD( aTxt, { "Zdravstveno", "osiguranje", "(11 x 0.04)", "12" })
	AADD( aTxt, { "Osnovica", "za porez", "(11 - 12)", "13" })
	AADD( aTxt, { "Iznos", "poreza", "(13 x 0.1)", "14" })
	AADD( aTxt, { "PIO", "", "(11 x 0.06)", "15" })
elseif cVRada == "2"
	AADD( aTxt, { "JMB poreznog", "obveznika", "", "6" })
	AADD( aTxt, { "Prezime i ime", "poreznog obveznika", "", "7" })	
	AADD( aTxt, { "Iznos", "dohotka", "", "8" })
	AADD( aTxt, { "Zdravstveno", "osiguranje", "(8 x 0.04)", "9" })
	AADD( aTxt, { "Osnovica", "za porez", "(8 - 9)", "10" })
	AADD( aTxt, { "Iznos", "poreza", "(10 x 0.1)", "11" })
	AADD( aTxt, { "PIO", "", "(8 x 0.06)", "12" })
elseif cVRada == "3"
	AADD( aTxt, { "JMB poreznog", "obveznika", "", "6" })
	AADD( aTxt, { "Prezime i ime", "poreznog obveznika", "", "7" })	
	AADD( aTxt, { "Isplaceni", "iznos", "", "8" })
	AADD( aTxt, { "Iznos", "poreza", "(8 x 0.1)", "9" })
endif

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
static function ak_zaglavlje( nPage, cTipRada, dDIspl, cPeriod )
local cObrazac 
local cInfo

if cTipRada == "1"
	cObrazac := "Obrazac AUG-1031"
	cInfo := "ZA POVREMENE SAMOSTALNE DJELATNOSTI"
elseif cTipRada == "2"
	cObrazac := "Obrazac ASD-1032"
	cInfo := "NA PRIHODE OD DRUGIH SAMOSTALNIH DJELATNOSTI"
elseif cTipRada == "3"
	cObrazac := "Obrazac PDN-1033"
	cInfo := "POVREMENE DJELATNOSTI U REPUBLICI SRPSKOJ"
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
	? "  1) Vrsta prijave:"
	? "     a) Povremene samostalne djelatnosti   b) autorski honorari"
	?
else
	?
endif

? "Dio 1 - podaci o isplatiocu"
P_12CPI

? PADR( "Naziv: " + cPredNaz, 60 ), "JIB/JMB: " + cPredJmb 
? PADR( "Adresa: " + cPredAdr, 60 ), "Datum isplate: " + DTOC(dDIspl), ;
	"Period: " + cPeriod

?
P_10CPI
P_COND
? SPACE(1) + "Dio 2 - podaci o prihodima, porezu i doprinosima"

return



// ---------------------------------------------------------
// napuni podatke u pomocnu tabelu za izvjestaj
// ---------------------------------------------------------
static function fill_data( cRj, cGodina, cMjesec, ;
	cDopr1X, cDopr2X, cVRada, cObr )

local cPom

select ld

do while !eof() .and. field->godina = cGodina .and. ;
	field->mjesec = cMjesec

	cT_radnik := field->idradn
	cT_tiprada := g_tip_rada( field->idradn, field->idrj )

	select radn
	seek cT_radnik
	
	lInRS := in_rs(radn->idopsst, radn->idopsrad) .and. cT_tipRada $ "A#U"

	// uzmi samo odgovarajuce tipove rada
	if ( cVRada $ "1#3" .and. !(cT_tiprada $ "A#U") )
		select ld
		skip
		loop
	endif
	
	if ( cVRada == "2" .and. !(cT_tiprada $ "P") )
		select ld
		skip
		loop
	endif

	// da li je u rs-u, koji obrazac ?
	if ( lInRS == .t. .and. cVRada <> "3" ) .or. ;
		( lInRS == .f. .and. cVRada == "3" )
		select ld
		skip 
		loop
	endif

	cR_jmb := radn->matbr
	cR_naziv := ALLTRIM( radn->naz ) + " " + ALLTRIM( radn->ime ) 


	// samo pozicionira bazu PAROBR na odgovarajuci zapis
	ParObr( cMjesec, IF(lViseObr, ld->obr,), ld->idrj )

	select ld

	nRashod := 0
	nPrihod := 0
	nDohodak := 0
	nDopPio := 0
	nDopZdr := 0
	nPorOsn := 0
	nPorIzn := 0
	nTrosk := 0

	do while !eof() .and. field->godina = cGodina ;
		.and. field->mjesec = cMjesec ;
		.and. field->idradn == cT_radnik

		// uvijek provjeri tip rada
		cT_tiprada := g_tip_rada( field->idradn, field->idrj )
		
		lInRS := in_rs(radn->idopsst, radn->idopsrad) .and. cT_tipRada $ "A#U"
	
		// samo pozicionira bazu PAROBR na odgovarajuci zapis
		ParObr( cMjesec, IF(lViseObr, ld->obr,), ld->idrj )
	
		// uzmi samo odgovarajuce tipove rada
		if ( cVRada == "1" .and. !(cT_tiprada $ "A#U") )
			skip
			loop
		endif
	
		if ( cVRada == "2" .and. !(cT_tiprada $ "P") )
			skip
			loop
		endif

		nNeto := field->uneto
		
		cTrosk := radn->trosk
		
		nKLO := radn->klo
		
		nL_odb := field->ulicodb
		
		nTrosk := 0

		if cT_tiprada == "A"
			nTrosk := gAhTrosk
		elseif cT_tiprada == "U"
			nTrosk := gUgTrosk
		endif

		if lInRS == .t.
			nTrosk := 0
		endif

		// ako se ne koriste troskovi onda ih i nema !
		if cTrosk == "N"
			nTrosk := 0
		endif

		// prihod
		nPrihod := bruto_osn( nNeto, cT_tiprada, nL_odb, nil, cTrosk ) 
		
		// rashod
		nRashod := nPrihod * (nTrosk / 100)

		// dohodak
		nDohodak := nPrihod - nRashod

		// ukupno dopr iz 
		nDoprIz := u_dopr_iz( nDohodak, cT_tiprada )
		
	
		// osnovica za porez
		nPorOsn := ( nDohodak - nDoprIz ) - nL_odb

		// porez je ?
		nPorez := izr_porez( nPorOsn, "B" )
	
		if lInRS == .t.
			nDoprIz := 0
			nPorOsn := 0
			nPorez := 0
		endif
	
		select ld
		
		// ocitaj doprinose, njihove iznose
		nDopr1X := get_dopr( cDopr1X, cT_tipRada )
		nDopr2X := get_dopr( cDopr2X, cT_tipRada )
		
		// izracunaj doprinose
		nIDopr1X := round2( nDohodak * nDopr1X / 100, gZaok2 )
		nIDopr2X := round2( nDohodak * nDopr2X / 100, gZaok2 )
 
		if lInRS == .t.
			// nema doprinosa za zdravstvo !
			nIDopr1X := 0
		endif

 		select ld

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


