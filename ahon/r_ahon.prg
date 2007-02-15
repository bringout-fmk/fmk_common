#include "\dev\fmk\ld\ld.ch"


// -----------------------------------------
// rpt: izvjestaj autorski honorari
// -----------------------------------------
function ah_list_rpt()
private cIdRj := gRj
private cMjesec := gMjesec
private cGodina := gGodina
private cObracun := ""
private cIzdanje := SPACE(10)
private cIzdNaz := ""
private cVarSort:="2"
private cOpsSt:=SPACE(4)
private cTipPr := "01"
private cOpcStanov := ""

_o_tables()

cIdRadn := space(_LR_)

// uzmi parametre
if _get_vars(@cIdRj, @cOpsSt, @cIzdanje, @cMjesec, @cGodina, ;
		@cTipPr, @cVarSort) == 0

	return
endif

CreRekLD()
O_REKLD

if EMPTY(cOpsSt)
	cOpcinaSt:=Lokal("SVE OPSTINE")
	cOpsSt:=""
else
	cOpcinaSt:=ALLTRIM(Ocitaj(F_OPS,cOpsSt,"naz"))
endif

if !EMPTY(cIzdanje)
	cIzdNaz := _get_izd( cIzdanje )
endif

O_TIPPR

select tippr
hseek cTipPr
EOF CRET

select ld
set relation to idradn into radn

if cVarSort=="1"
	cSort1 := "radn->idopsst+idradn"
else
	cSort1 := "radn->idOpsSt+SortPrez(IDRADN)"
endif
	
Box(,2,30)
     		
	nSlog := 0
	nUkupno := RECCOUNT2()
	cFilt := IF(EMPTY(cMjesec), ".t.", "MJESEC==cMjesec" ) + ".and." + ;
       		IF(EMPTY(cGodina),".t.","GODINA==cGodina")
     		
	if !EMPTY(cIdRj)
		cFilt += ".and. idrj == cIdRj"
	endif
	
	if !EMPTY(cOpsSt)
		cFilt += ".and. radn->idOpsSt=cOpsSt"
	endif
		
	if !EMPTY(cIzdanje)
		cFilt += ".and. izdanje=cIzdanje"
	endif
		
     	INDEX ON &cSort1 TO "TMPLD" FOR &cFilt EVAL(TekRec2()) EVERY 1
    	
BoxC()
go top

EOF CRET

nPage := 0
cPicProc := "(99.99%)"

// linija za izvjestaj
cLine := _g_line()

bHeader := {|| ahon_header() }

select rj
hseek ld->idrj
select ld

START PRINT CRET

nRbr:=0

EVAL(bHeader)

nRbr := 0
nTBruto := 0
nTNeto := 0
nTPrTrosk := 0
nTPorOsn := 0
nTPorez := 0

do while !eof()

 	cIdOpsSt:=radn->idOpsSt
 	
	cOpcinaSt:=ALLTRIM(Ocitaj(F_OPS,cIdOpsSt,"naz"))
 	
	nPage := 0
	
	P_COND
 	
	if prow() > 62 + gPStranica
		FF
		Eval(bHeader)
	endif
	
 	do while !eof() .and. cGodina==godina .and. idrj=cIdrj .and. cMjesec=mjesec .and. radn->idopsst=cIdOpsSt
 
 		Scatter()

		select ops
		go top
		seek cIdOpsSt
		
		select ld

		do while .t.
   			
			if prow() > 62 + gPStranica
				FF
				Eval(bHeader)
			endif

   			if _i&cTipPr <> 0 .and. !EMPTY(_izdanje)
     				
				? str( ++nRbr, 4) + "."
				
				// radnik - ime i prezime
				@ prow(),pcol()+1 SAY PADR(ALLTRIM(RADNIK) + " (" + radn->id + ")" , 40)
				
				// opcina
				@ prow(),pcol()+1 SAY PADR(ops->naz, 20)
				
				// maticni broj
				@ prow(),pcol()+1 SAY radn->matbr
     				
				// bruto
				@ prow(),pcol()+1 SAY _ubruto pict gpici
				nTBruto += _ubruto
			
				// priznati troskovi %
				@ prow(),pcol()+1 SAY ops->ah_prtr pict cPicProc
						
				// priznati troskovi
				@ prow(),pcol()+1 SAY _uprtrosk pict gpici
				nTPrTrosk += _uprtrosk		
						
				// poreska osnova
				@ prow(),pcol()+1 SAY _ubruto-_uprtrosk;
					pict gpici
				nTPorOsn += _ubruto-_uprtrosk
					
				// porez %
				@ prow(),pcol()+1 SAY ops->ah_por pict cPicProc
			
				// porez
				@ prow(),pcol()+1 SAY _uporez pict gpici
				nTPorez += _uporez
				
				// neto
				@ prow(),pcol()+1 SAY _i&cTipPr pict gpici
				nTNeto += _i&cTipPr
			
				cIzdInfo := _get_izd( _izdanje )
			
     				Rekapld( "NETO", cGodina, cMjesec, _i&cTipPr, 0, RADN->id, ALLTRIM(RADN->idbanka) + "#" + ALLTRIM(RADN->brtekr), RADNIK, .t. , cIzdInfo)
     				
				Rekapld( "BRUTO", cGodina, cMjesec , _ubruto, 0, RADN->id, ALLTRIM(RADN->idbanka) + "#" + ALLTRIM(RADN->brtekr), RADNIK, .t., cIzdInfo )
				
				Rekapld( "POR" + ops->id, cGodina, cMjesec , _uporez, 0, RADN->id, ALLTRIM(RADN->idbanka) + "#" + ALLTRIM(RADN->brtekr), RADNIK, .t., cIzdInfo )
   			
			endif
   			
			EXIT
 		
		ENDDO
		
		skip 1
	enddo

	if prow() > 60 + gPStranica
		FF
		Eval(bHeader)
	endif
	
enddo

? cLine
	
? SPACE(5), Lokal("UKUPNO:"), SPACE(67)

@ prow(),pcol()+1 SAY nTBruto pict gpici
@ prow(),pcol()+1 SAY SPACE(LEN(cPicProc))
@ prow(),pcol()+1 SAY nTPrTrosk pict gpici
@ prow(),pcol()+1 SAY nTPorOsn pict gpici
@ prow(),pcol()+1 SAY SPACE(LEN(cPicProc))
@ prow(),pcol()+1 SAY nTPorez pict gpici
@ prow(),pcol()+1 SAY nTNeto pict gpici
	
? cLine

if prow() > 60 + gPStranica
	FF
	Eval(bHeader)
endif

?
? Lokal("REKAPITULACIJA, PREGLED IZNOSA")
? REPLICATE("-", 60)

if prow() > 60 + gPStranica
	FF
	Eval(bHeader)
endif

nTotal := 0
cPicTotal := "9999999999.99"

? PADL("NETO:", 30), TRANSFORM(nTNeto, cPicTotal)
? PADL("BRUTO:", 30), TRANSFORM(nTBruto, cPicTotal)
? PADL("POREZ:", 30), TRANSFORM(nTPorez, cPicTotal)
? PADL("UPLACENO:", 30), REPLICATE("_", LEN(cPicTotal))
?
? Lokal( PADL("Direktor preduzeca:", 130) )
? Lokal( PADL(REPLICATE("_", 20), 130) )

FF

END PRINT

CLOSERET

return



// -----------------------------------------
// zaglavlje
// -----------------------------------------
static function ahon_header()
local cLine := _g_line()
local cTxt1 := ""
local cTxt2 := ""
local cSpace := SPACE(1)
local cFirNaz := ""
local cFirAdr := ""
local cFirIdBr := ""
local cPom

cFirNaz := IzFmkIni("AUTORSKIHONORAR","FirmaNaziv","Privredna stampa d.d. Sarajevo", KUMPATH)
cFirAdr := IzFmkIni("AUTORSKIHONORAR","FirmaAdresa","Dzemala Bijedica 185", KUMPATH)
cFirIdBr := IzFmkIni("AUTORSKIHONORAR","FirmaIdBroj","4200088140005", KUMPATH)


? "#%LANDS#"
P_COND
B_ON

cPom := cFirNaz + SPACE(10) + cFirAdr + SPACE(10) + "Identifikacijski broj: " + cFirIdBr

? cPom

B_OFF

? Lokal("AUTORSKI HONORAR")

U_ON

if EMPTY(cIzdanje)
	?? PADC( Lokal("Izdanje: sva izdanja") , 30)
else
	?? PADC( Lokal("Izdanje: " + cIzdanje + ", " + cIzdNaz ), 70)
endif

U_OFF
? Lokal("Opcina prebivalista: ")
U_ON
?? PADC( cOpcinaSt, 30 )
U_OFF

if EMPTY(cIdRj)
	? Lokal("Pregled za sve RJ ukupno:")
else
 	? Lokal("RJ:"), cIdRj, ALLTRIM(rj->naz)
endif

?? SPACE(2) + Lokal("Mjesec:"),str(cMjesec,2)
?? SPACE(4) + Lokal("Godina:"),str(cGodina,5)

devpos(prow(), 74)

?? Lokal("Str."), str( ++ nPage, 3)
?

cTxt1 += PADC("Rbr", 5) + cSpace
cTxt2 += SPACE(5) + cSpace

cTxt1 += PADC("Ime i prezime autora", 40) + cSpace
cTxt2 += SPACE(40) + cSpace

cTxt1 += PADC("Opcina", 20 ) + cSpace
cTxt2 += PADC("stanovanja", 20 ) + cSpace

cTxt1 += PADC("JMBG", 13) + cSpace
cTxt2 += SPACE(13) + cSpace

cTxt1 += PADC("BRUTO", LEN(gPici)) + cSpace
cTxt2 += PADC("iznos", LEN(gPici)) + cSpace

cTxt1 += PADC("Priznati", LEN(gPici) + 9 ) + cSpace
cTxt2 += PADC("trosak", LEN(gPici) + 9 ) + cSpace

cTxt1 += PADC("Poreska", LEN(gPici)) + cSpace
cTxt2 += PADC("osnova", LEN(gPici)) + cSpace

cTxt1 += PADC("POREZ", LEN(gPici) + 9 ) + cSpace
cTxt2 += SPACE(LEN(gPici) + 9 ) + cSpace

cTxt1 += PADC("NETO", LEN(gPici))
cTxt2 += PADC("za isplatu", LEN(gPici)) 

? cLine
? Lokal(cTxt1)
? Lokal(cTxt2)
? cLine

return




// --------------------------------------
// vraca liniju za izvjestaj
// --------------------------------------
static function _g_line()
local cLine := ""
local cSpace := SPACE(1)

cLine += REPLICATE("-", 5) 
cLine += cSpace
cLine += REPLICATE("-", 40)
cLine += cSpace
cLine += REPLICATE("-", 20)
cLine += cSpace
cLine += REPLICATE("-", 13)
cLine += cSpace
cLine += REPLICATE("-", LEN(gPici))
cLine += cSpace
cLine += REPLICATE("-", LEN(gPici) + 9 )
cLine += cSpace
cLine += REPLICATE("-", LEN(gPici))
cLine += cSpace
cLine += REPLICATE("-", LEN(gPici) + 9 )
cLine += cSpace
cLine += REPLICATE("-", LEN(gPici))

return cLine


// -----------------------------------------
// otvori sve potrebne tabele
// -----------------------------------------
static function _o_tables()

O_OPS
O_IZDANJA
O_RJ
O_RADN
O_LD
O_REKLD

return



// --------------------------------------------------
// uslovi izvjestaja
// --------------------------------------------------
static function _get_vars(cIdRj, cOpsSt, cIzdanje, cMjesec, cGodina, ;
		cTipPr, cVarSort)

O_PARAMS

private cSection:="4"
private cHistory:=" "
private aHistory:={}

RPar("VS", @cVarSort)
RPar("AH", @cTipPr)
RPar("IZ", @cIzdanje)

Box("#IZVJESTAJ: LISTA AUTORSKIH HONORARA",10,65)
	
	@ m_x+1,m_y+2 SAY "Radna jedinica (prazno sve): " GET cIdRJ
	@ m_x+2,m_y+2 SAY "Opstina stanovanja (prazno-sve): " GET cOpsSt PICT "@!" VALID EMPTY(cOpsSt).or.P_Ops(@cOpsSt)
	@ m_x+3,m_y+2 SAY "Izdanje (prazno-sva): " GET cIzdanje VALID EMPTY(cIzdanje) .or. p_izdanja(@cIzdanje)
	@ m_x+4,m_y+2 SAY "Mjesec: " GET cMjesec PICT "99"
	@ m_x+5,m_y+2 SAY "Godina: " GET cGodina PICT "9999"
	@ m_x+6,m_y+2 SAY "Tip primanja: " GET cTipPr
	@ m_x+9,m_y+2 SAY "Sortirati po (1-sifri radn., 2-prezime+ime radn.)" GET cVarSort VALID cVarSort $ "12" PICT "9"
	read
	
	clvbox()
BoxC()

if LastKey() <> K_ESC
	select params
	WPar("VS", cVarSort)
	WPar("AH", cTipPr)
	WPar("IZ", cIzdanje)
	use
endif

if LastKey() == K_ESC
	return 0
endif

return 1



