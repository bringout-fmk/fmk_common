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
static function ld_sort(cRj, cGodina, cMjesec, cMjesecDo, cRadnik, cObr )
local cFilter := ""

private cObracun := cObr

if lViseObr
	if !EMPTY(cObracun)
		cFilter += "obr == " + cm2str(cObracun)
	endif
endif

if !EMPTY(cRj)

	if !EMPTY(cFilter)
		cFilter += " .and. "
	endif
	
	cFilter += Parsiraj(cRj,"IDRJ")

endif

if !EMPTY(cFilter)
	set filter to &cFilter
	go top
endif

if EMPTY(cRadnik) 
	INDEX ON str(godina)+SortPrez(idradn)+str(mjesec)+idrj TO "TMPLD"
	go top
	seek str(cGodina,4)
else
	set order to tag (TagVO("2"))
	go top
	seek str(cGodina,4)+str(cMjesec,2)+cRadnik
endif

return


// ---------------------------------------------
// upisivanje podatka u pomocnu tabelu za rpt
// ---------------------------------------------
static function _ins_tbl( cRadnik, cIme, nSati, nNeto, ;
		nBruto, nDoprIz, nDopPio, ;
		nDopZdr, nDopNez, nOporDoh, nLOdb, nPorez, ;
		nOdbici, nIsplata )

local nTArea := SELECT()

O_R_EXP
select r_export
append blank

replace idradn with cRadnik
replace naziv with cIme
replace sati with nSati
replace neto with nNeto
replace bruto with nBruto
replace dop_iz with nDoprIz
replace dop_pio with nDopPio
replace dop_zdr with nDopZdr
replace dop_nez with nDopNez
replace l_odb with nLOdb
replace izn_por with nPorez
replace opordoh with nOporDoh
replace odbici with nOdbici
replace isplata with nIsplata

select (nTArea)
return



// ---------------------------------------------
// kreiranje pomocne tabele
// ---------------------------------------------
static function cre_tmp_tbl()
local aDbf := {}

AADD(aDbf,{ "IDRADN", "C", 6, 0 })
AADD(aDbf,{ "NAZIV", "C", 20, 0 })
AADD(aDbf,{ "SATI", "N", 12, 2 })
AADD(aDbf,{ "NETO", "N", 12, 2 })
AADD(aDbf,{ "BRUTO", "N", 12, 2 })
AADD(aDbf,{ "DOP_IZ", "N", 12, 2 })
AADD(aDbf,{ "DOP_PIO", "N", 12, 2 })
AADD(aDbf,{ "DOP_ZDR", "N", 12, 2 })
AADD(aDbf,{ "DOP_NEZ", "N", 12, 2 })
AADD(aDbf,{ "IZN_POR", "N", 12, 2 })
AADD(aDbf,{ "OPORDOH", "N", 12, 2 })
AADD(aDbf,{ "L_ODB", "N", 12, 2 })
AADD(aDbf,{ "ODBICI", "N", 12, 2 })
AADD(aDbf,{ "ISPLATA", "N", 12, 2 })

t_exp_create( aDbf )
// index on ......

return


// ------------------------------------------
// obracunski list radnika
// ------------------------------------------
function ppl_vise()
local nC1:=20
local i
local cTPNaz
local cRj := SPACE(60)
local cRadnik := SPACE(_LR_) 
local cIdRj
local cMjesec
local cMjesecDo
local cGodina
local cDoprPio := "70"
local cDoprZdr := "80"
local cDoprNez := "90"
local cObracun := gObracun

// kreiraj pomocnu tabelu
cre_tmp_tbl()

cIdRj := gRj
cMjesec := gMjesec
cGodina := gGodina
cMjesecDo := cMjesec

// otvori tabele
o_tables()

Box("#PREGLED PLATA ZA VISE MJESECI (M4)", 15, 75)

@ m_x + 1, m_y + 2 SAY "Radne jedinice: " GET cRj PICT "@!S25"
@ m_x + 2, m_y + 2 SAY "Za mjesece od:" GET cMjesec pict "99"
@ m_x + 2, col() + 2 SAY "do:" GET cMjesecDo pict "99" ;
	VALID cMjesecDo >= cMjesec
@ m_x + 3, m_y + 2 SAY "Godina: " GET cGodina pict "9999"

if lViseObr
  	@ m_x+3,col()+2 SAY "Obracun:" GET cObracun WHEN HelpObr(.t.,cObracun) VALID ValObr(.t.,cObracun)
endif

@ m_x + 4, m_y + 2 SAY "Radnik (prazno-svi radnici): " GET cRadnik ;
	VALID EMPTY(cRadnik) .or. P_RADN(@cRadnik)
@ m_x + 6, m_y + 2 SAY "Dodatni doprinosi za prikaz na izvjestaju: " 
@ m_x + 7, m_y + 2 SAY " Sifra dodatnog doprinosa 1 : " GET cDoprPio 
@ m_x + 8, m_y + 2 SAY " Sifra dodatnog doprinosa 2 : " GET cDoprZdr
@ m_x + 9, m_y + 2 SAY " Sifra dodatnog doprinosa 3 : " GET cDoprNez

read
	
clvbox()
	
ESC_BCR

BoxC()

if lastkey() == K_ESC
	return
endif

select ld

// sortiraj tabelu i postavi filter
ld_sort( cRj, cGodina, cMjesec, cMjesecDo, cRadnik, cObracun )

// nafiluj podatke obracuna
fill_data( cRj, cGodina, cMjesec, cMjesecDo, cRadnik, ;
	cDoprPio, cDoprZdr, cDoprNez, cObracun )

// printaj izvjestaj
ppv_print( cRj, cGodina, cMjesec, cMjesecDo, cDoprPio, cDoprZdr, cDoprNez )

return



// ----------------------------------------------
// stampa pregleda plata za vise mjeseci
// ----------------------------------------------
static function ppv_print( cRj, cGodina, cMjOd, cMjDo, cDop1, cDop2, cDop3 )
local cT_radnik := ""
local cLine := ""

O_R_EXP
select r_export
go top

START PRINT CRET
?
? "#%LANDS#"
P_COND2

ppv_zaglavlje(cRj, cGodina, cMjOd, cMjDo )

cLine := ppv_header( cDop1, cDop2, cDop3 )

nUSati := 0
nUNeto := 0
nUBruto := 0
nUDoprPio := 0
nUDoprZdr := 0
nUDoprNez := 0
nUDoprIZ := 0
nUOpDoh := 0
nUPorez := 0
nUOdbici := 0
nULicOdb := 0
nUIsplata := 0

nRbr := 0
nPoc := 10
nCount := 0

do while !EOF()
	
	? STR(++nRbr, 4) + "."

	@ prow(), pcol()+1 SAY idradn
	
	@ prow(), pcol()+1 SAY naziv

	@ prow(), nPoc:=pcol()+1 SAY STR(sati,12,2)
	nUSati += sati

	@ prow(), pcol()+1 SAY STR(neto,12,2) 
	nUNeto += neto
	
	@ prow(), pcol()+1 SAY STR(bruto,12,2)
	nUBruto += bruto

	@ prow(), pcol()+1 SAY STR(dop_iz,12,2)
	nUDoprIz += dop_iz

	@ prow(), pcol()+1 SAY STR(opordoh,12,2)
	nUOpDoh += opordoh
	
	@ prow(), pcol()+1 SAY STR(l_odb,12,2)
	nULicOdb += l_odb

	@ prow(), pcol()+1 SAY STR(izn_por,12,2)
	nUPorez += izn_por
	
	@ prow(), pcol()+1 SAY STR(odbici,12,2)
	nUOdbici += odbici

	@ prow(), pcol()+1 SAY STR(isplata,12,2)
	nUIsplata += isplata
	
	@ prow(), pcol()+1 SAY STR(dop_pio,12,2)
	nUDoprPio += dop_pio
	
	@ prow(), pcol()+1 SAY STR(dop_zdr,12,2)
	nUDoprZdr += dop_zdr
	
	@ prow(), pcol()+1 SAY STR(dop_nez,12,2)
	nUDoprNez += dop_nez
	
	++nCount

	skip
enddo

? cLine

? "UKUPNO:"
@ prow(), nPoc SAY STR(nUSati,12,2)
@ prow(), pcol()+1 SAY STR(nUNeto,12,2)
@ prow(), pcol()+1 SAY STR(nUBruto,12,2)
@ prow(), pcol()+1 SAY STR(nUDoprIz,12,2)
@ prow(), pcol()+1 SAY STR(nUOpDoh,12,2)
@ prow(), pcol()+1 SAY STR(nULicOdb,12,2)
@ prow(), pcol()+1 SAY STR(nUPorez,12,2)
@ prow(), pcol()+1 SAY STR(nUOdbici,12,2)
@ prow(), pcol()+1 SAY STR(nUIsplata,12,2)
@ prow(), pcol()+1 SAY STR(nUDoprPio,12,2)
@ prow(), pcol()+1 SAY STR(nUDoprZdr,12,2)
@ prow(), pcol()+1 SAY STR(nUDoprNez,12,2)
? cLine

FF
END PRINT

return


// ----------------------------------------
// stampa headera tabele
// ----------------------------------------
static function ppv_header( cDop1, cDop2, cDop3 )
local aLines := {}
local aTxt := {}
local i 
local cLine := ""
local cTxt1 := ""
local cTxt2 := ""
local cTxt3 := ""
local cTxt4 := ""

AADD( aLines, { REPLICATE("-", 5) } )
AADD( aLines, { REPLICATE("-", 6) } )
AADD( aLines, { REPLICATE("-", 20) } )
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

AADD( aTxt, { "Red.", "br", "", "1" })
AADD( aTxt, { "Sifra", "radn.", "", "2" })
AADD( aTxt, { "Naziv", "radnika", "", "3" })
AADD( aTxt, { "Sati", "", "", "4" })
AADD( aTxt, { "Neto", "", "", "5" })
AADD( aTxt, { "Bruto plata", "(5 x koef.)", "", "6" })
AADD( aTxt, { "Doprinos", "iz place", "( 31% )", "7" })
AADD( aTxt, { "Oporezivi", "dohodak", "( 6 - 7 )", "8" })
AADD( aTxt, { "Licni odbici", "", "", "9" })
AADD( aTxt, { "Porez", "na dohodak", "(8-9) x 10%", "10" })
AADD( aTxt, { "Odbici", "", "", "11" })
AADD( aTxt, { "Za isplatu", "", "", "12" })
AADD( aTxt, { "Dodatni", "dopr. 1", "D->"+cDop1, "13" })
AADD( aTxt, { "Dodatni", "dopr. 2", "D->"+cDop2, "14" })
AADD( aTxt, { "Dodatni", "dopr. 3", "D->"+cDop3, "15" })

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
static function ppv_zaglavlje( cRj, cGodina, cMjOd, cMjDo )

? UPPER(gTS) + ":", gnFirma
?

if EMPTY(cRj)
	? Lokal("Pregled za sve RJ ukupno:")
else
	? Lokal("RJ:"), cRj
endif

?? SPACE(2) + Lokal("Mjesec od:"),str(cMjOd,2),"do:",str(cMjDo,2)
?? SPACE(4) + Lokal("Godina:"),str(cGodina,5)

return


// ---------------------------------------------------------
// napuni podatke u pomocnu tabelu za izvjestaj
// ---------------------------------------------------------
static function fill_data( cRj, cGodina, cMjesec, cMjesecDo, ;
	cRadnik, cDoprPio, cDoprZdr, cDoprNez, cObracun )
local i
local cPom
local lInRS := .f.

select ld

do while !eof() .and. field->godina = cGodina  

	if field->mjesec > cMjesecDo .or. ;
		field->mjesec < cMjesec 
		
		skip
		loop

	endif

	cT_radnik := field->idradn

	lInRS := in_rs(radn->idopsst, radn->idopsrad) 
	
	if !EMPTY(cRadnik)
		if cT_radnik <> cRadnik
			skip
			loop
		endif
	endif
	
	cTipRada := g_tip_rada( ld->idradn, ld->idrj )
	cOpor := g_oporeziv( ld->idradn, ld->idrj ) 

	// samo pozicionira bazu PAROBR na odgovarajuci zapis
	ParObr( cMjesec, IF(lViseObr, ld->obr,), ld->idrj )

	select radn
	seek cT_radnik
	cT_rnaziv := ALLTRIM( radn->ime ) + " " + ALLTRIM( radn->naz )
	
	select ld

	nSati := 0
	nNeto := 0
	nBruto := 0
	nUDopIz := 0
	nIDoprPio := 0
	nIDoprZdr := 0
	nIDoprNez := 0
	nOporDoh := 0
	nOdbici := 0
	nL_odb := 0
	nPorez := 0
	nIsplata := 0

	do while !eof() .and. field->mjesec <= cMjesecDo ;
		.and. field->mjesec >= cMjesec ;
		.and. field->godina = cGodina  ;
		.and. field->idradn == cT_radnik

		
		// uvijek provjeri tip rada, ako ima vise obracuna
		cTipRada := g_tip_rada( ld->idradn, ld->idrj )
		cTrosk := radn->trosk
		
		ParObr( cMjesec, IF(lViseObr, ld->obr,), ld->idrj )

		nPrKoef := 0
		
		// proisani koeficijent
		if cTipRada == "S"
			nPrKoef := radn->sp_koef
		endif
		
		// neto ?
		nNeto += field->uneto
		
		// odbici ?
		nOdbici += field->uodbici

		// sati ?
		nSati += field->usati
		
		// isplata ?
		nIsplata += field->uiznos

		// licni odbitak ?
		nLOdbitak := field->ulicodb
		nL_odb += nLOdbitak

		// bruto sa troskovima 
		nBrutoST := bruto_osn( ld->uneto, cTipRada, ld->ulicodb, nPrKoef, cTrosk ) 
		
		nTrosk := 0

		// ugovori o djelu
		if cTipRada == "U" .and. cTrosk <> "N"
			
			nTrosk := ROUND2( nBrutoST * (gUgTrosk / 100), gZaok2 )
			
			if lInRs == .t.
				nTrosk := 0
			endif
			
		endif

		// autorski honorar
		if cTipRada == "A" .and. cTrosk <> "N"
			
			nTrosk := ROUND2( nBrutoST * (gAhTrosk / 100), gZaok2 )
			
			if lInRs == .t.
				nTrosk := 0
			endif
			
		endif

		// bruto pojedinacno za radnika
		nBrPoj := nBrutoST - nTrosk

		// ukupni bruto
		nBruto += nBrPoj
		
		// ukupno dopr iz 31%
		nDoprIz := u_dopr_iz( nBrPoj , cTipRada )
		nUDopIz += nDoprIz

		// oporezivi dohodak
		nOporDoh += ( nBrPoj - nDoprIz )

		// osnovica za porez
		nPorOsnP := ( nBrPoj - nDoprIz ) - nLOdbitak
		
		if nPorOsnP < 0 .or. !radn_oporeziv( ld->idradn, ld->idrj )
			nPorOsnP := 0
		endif
		
		// porez je ?
		nPorez += izr_porez( nPorOsnP, "B" )
	
		// ocitaj doprinose, njihove iznose
		nDoprPIO := get_dopr( cDoprPIO, cTipRada ) 
		nDoprZDR := get_dopr( cDoprZDR, cTipRada ) 
		nDoprNEZ := get_dopr( cDoprNEZ, cTipRada ) 
		
		// izracunaj doprinose
		nIDoprPIO += round2(nBrPoj * nDoprPIO / 100, gZaok2)
		nIDoprZDR += round2(nBrPoj * nDoprZDR / 100, gZaok2)
		nIDoprNEZ += round2(nBrPoj * nDoprNEZ / 100, gZaok2)

		select ld
		skip

	enddo

	// ubaci u tabelu podatke
	_ins_tbl( cT_radnik, ;
		cT_rnaziv, ;
		nSati, ;
		nNeto, ;
		nBruto, ;
		nUDopIZ,;
		nIDoprPIO, ;
		nIDoprZDR, ;
		nIDoprNEZ, ;
		nOporDoh, ;
		nL_Odb, ;
		nPorez, ;
		nOdbici, ;
		nIsplata )
				
enddo

return


