#include "\dev\fmk\ld\ld.ch"

// lijeva margina
static __left_marg


// --------------------------------------------
// specifikacija autorskih honorara
// --------------------------------------------
function ah_spec_rpt()
local cLine
private cIdRj := gRj
private cMjesec := gMjesec
private cGodina := gGodina
private cObracun := ""
private cTipPr := "01"
private cIdRadn
private cLeft

__left_marg := 4

cLeft := SPACE( __left_marg )

_o_tables()

cIdRadn := space(_LR_)

// uzmi parametre
if _get_vars(@cIdRj, @cIdRadn, @cMjesec, @cGodina, @cTipPr ) == 0
	return
endif

O_TIPPR

select tippr
hseek cTipPr
EOF CRET

select ld
set relation to idradn into radn
	
Box(,2,30)
     	
	cSort1 := "radn->idopsst+idradn"
	nSlog := 0
	
	nUkupno := RECCOUNT2()
	
	cFilt := IF(EMPTY(cMjesec), ".t.", "MJESEC==cMjesec" ) + ".and." + ;
       		IF(EMPTY(cGodina),".t.","GODINA==cGodina") + ".and." + ;
		IF(EMPTY(cIdRadn),".t.","IDRADN==cIdRadn")
     		
	if !EMPTY(cIdRj)
		cFilt += ".and. idrj == cIdRj"
	endif
	
     	INDEX ON &cSort1 TO "TMPLD" FOR &cFilt EVAL(TekRec2()) EVERY 1
    	
BoxC()

go top

EOF CRET

cPicProc := "99.99%"

// linija za izvjestaj
cLine := _g_line()

bAutor := {|| ahon_autor( cIdRadn ) }
bHeader := {|| ahon_header() }

select rj
hseek ld->idrj
select ld

START PRINT CRET

nRbr := 0

?
?

// prva tabela
EVAL( bAutor )

?
?
?
?
?

// druga tabela

nRbr := 0
nTBruto := 0
nTNeto := 0
nTPrTrosk := 0
nTPorOsn := 0
nTPorez := 0

do while !eof()
	
 	do while !eof() .and. cGodina==godina .and. idrj=cIdrj .and. cMjesec=mjesec .and. idradn == cIdRadn
 
 		Scatter()

		select ld

		do while .t.
   			
   			if _i&cTipPr <> 0 .and. !EMPTY(_izdanje)
     				
				nTBruto += _ubruto
				nTPrTrosk += _uprtrosk		
				nTPorOsn += _ubruto-_uprtrosk
				nTPorez += _uporez
				nTNeto += _i&cTipPr
				
   			endif
   			
			EXIT
 		ENDDO
		
		skip 1
	enddo
enddo

? cLeft, "II. PODACI O OSTVARENOM PRIHODU"

EVAL( bHeader )

cLine := _g_line()

select radn
hseek cIdRadn
select ops
hseek radn->idopsst
select ld


? cLeft + STR( ++nRbr, 5)
@ prow(),pcol()+1 SAY PADR("Pisana dijela", 20)
@ prow(),pcol()+1 SAY nTBruto pict gpici
@ prow(),pcol()+1 SAY ops->ah_prtr pict cPicProc
@ prow(),pcol()+1 SAY nTPrTrosk pict gpici
@ prow(),pcol()+1 SAY nTPorOsn pict gpici
@ prow(),pcol()+1 SAY ops->ah_por pict cPicProc
@ prow(),pcol()+1 SAY nTPorez pict gpici
@ prow(),pcol()+1 SAY nTNeto pict gpici

? cLine

?
?
?
?
?
?
? cLeft + "DATUM:", DATE()
? Lokal( PADL("Podnosilac prijave:", 70) )
? Lokal( PADL(REPLICATE("_", 30), 70) )

FF

END PRINT
CLOSERET

return



// -----------------------------------------
// ahonorar autor - podaci
// -----------------------------------------
static function ahon_autor( cIdRadn )
local cLine := _g_line()
local cSpace := SPACE(1)
local cTmp
local cNaslov := "PRIJAVA##ZA POREZ NA PRIHOD OD AUTORSKIH PRAVA, PATENATA I TEHNICKIH UNAPRIJEDJENJA"
local aTmp
local aBank
local nTArea := SELECT()
local i

// nadji radnika
select radn
hseek cIdRadn

// nadji opcinu
select ops
hseek radn->idopsst

// nadji banku
select kred
hseek radn->idbanka

// vrati se gdje si bio...
select (nTArea)

cRadnIme := RADNIK
cIdBroj := radn->matbr
cRadnAdr := ALLTRIM(radn->streetname) + " " + ALLTRIM(radn->streetnum)
cRadnAdr += " Opcina: " + ALLTRIM(ops->naz)
cRadnBank := ALLTRIM(kred->naz)
cRadnRn := ALLTRIM(radn->brtekr)
aBank := TokToNiz(cRadnRn, "#")
aTmp := TokToNiz( cNaslov, "##" )

?
? SPACE(__left_marg) + PADC( aTmp[1], 77 )
? SPACE(__left_marg) + PADC( aTmp[2], 77 )

?
?

P_COND

cTmp := "JEDINSTVENI IDENTIFIKACIJSKI BROJ: "

? SPACE(__left_marg) + cTmp
B_ON
?? cIdBroj
B_OFF

cTmp := "Ime (ocevo ime) prezime: "

? SPACE(__left_marg) + cTmp
B_ON
?? cRadnIme
B_OFF

cTmp := "Adresa: "

? SPACE(__left_marg) + cTmp
B_ON
?? cRadnAdr
B_OFF

cTmp := "Naziv banke kod koje se vodi racun: "

? SPACE(__left_marg) + cTmp
B_ON
?? cRadnBank
B_OFF

cTmp := "Broj racuna: "

? SPACE(__left_marg) + cTmp
B_ON

for i:=1 to LEN(aBank)

	if i == 2
		?? " Partija: "
	endif
	
	?? " " + aBank[i]
next

B_OFF

?

return



// --------------------------------------
// vraca opis headera izvjestaja
// --------------------------------------
static function ahon_header()
local cTxt1 := ""
local cTxt2 := ""
local cTxt3 := ""
local cSpace := SPACE(1)
local cLine := _g_line()

cTxt1 += SPACE(__left_marg)
cTxt2 += SPACE(__left_marg)
cTxt3 += SPACE(__left_marg)

cTxt1 += REPLICATE(" ", 5) + cSpace
cTxt2 += PADC("R.br", 5) + cSpace
cTxt3 += REPLICATE(" ", 5) + cSpace

cTxt1 += REPLICATE(" ", 20) + cSpace
cTxt2 += PADC("OPIS", 20) + cSpace
cTxt3 += REPLICATE(" ", 20) + cSpace

cTxt1 += REPLICATE(" ", LEN(gPici)) + cSpace
cTxt2 += PADC("Ostvareni", LEN(gPici)) + cSpace
cTxt3 += PADC("prihod", LEN(gPici)) + cSpace

cTxt1 += PADC("Troskovi nuzni za", LEN(gPici) + 7 ) + cSpace
cTxt2 += PADC("ostvarenje prihoda", LEN(gPici) + 7 ) + cSpace
cTxt3 += PADC( PADC("%", 3) + PADC("iznos", 5) , LEN(gPici) + 7 ) + cSpace

cTxt1 += REPLICATE(" ", LEN(gPici)) + cSpace
cTxt2 += PADC("Porezna", LEN(gPici)) + cSpace
cTxt3 += PADC("osnovica", LEN(gPici)) + cSpace

cTxt1 += REPLICATE(" ", 6) + cSpace
cTxt2 += PADC("Stopa", 6) + cSpace
cTxt3 += PADC("%", 6) + cSpace

cTxt1 += REPLICATE(" ", LEN(gPici)) + cSpace
cTxt2 += PADC("Iznos", LEN(gPici)) + cSpace
cTxt3 += PADC("poreza", LEN(gPici)) + cSpace

cTxt1 += PADC("ZA", LEN(gPici)) + cSpace
cTxt2 += REPLICATE(" ", LEN(gPici)) + cSpace
cTxt3 += PADC("ISPLATU", LEN(gPici)) + cSpace

? cLine
? cTxt1
? cTxt2
? cTxt3
? cLine

return 




// --------------------------------------
// vraca liniju za izvjestaj
// --------------------------------------
static function _g_line()
local cLine := ""
local cSpace := SPACE(1)

cLine += SPACE(__left_marg)
cLine += REPLICATE("-", 5) 
cLine += cSpace
cLine += REPLICATE("-", 20)
cLine += cSpace
cLine += REPLICATE("-", LEN(gPici))
cLine += cSpace
cLine += REPLICATE("-", LEN(gPici) + 7 )
cLine += cSpace
cLine += REPLICATE("-", LEN(gPici))
cLine += cSpace
cLine += REPLICATE("-", 6 )
cLine += cSpace
cLine += REPLICATE("-", LEN(gPici))
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
O_KRED
O_LD

return



// --------------------------------------------------
// uslovi izvjestaja
// --------------------------------------------------
static function _get_vars(cIdRj, cIdRadn, cMjesec, cGodina, cTipPr )

O_PARAMS

private cSection:="4"
private cHistory:=" "
private aHistory:={}

RPar("Ra", @cIdRadn)
RPar("AH", @cTipPr)

Box("#IZVJESTAJ: SPACIFIKACIJA AUTORSKIH HONORARA",10,65)
	
	@ m_x+1,m_y+2 SAY "Radna jedinica (prazno sve): " GET cIdRJ
	@ m_x+3,m_y+2 SAY "Mjesec: " GET cMjesec PICT "99"
	@ m_x+4,m_y+2 SAY "Godina: " GET cGodina PICT "9999"
	@ m_x+6,m_y+2 SAY "Tip primanja: " GET cTipPr
	@ m_x+8,m_y+2 SAY "Autor: " GET cIdradn VALID p_radn(@cIdRadn)
	read
	
	clvbox()
	
BoxC()

if LastKey() <> K_ESC
	select params
	WPar("AH", cTipPr)
	WPar("Ra", cIdRadn)
	use
endif

if LastKey() == K_ESC
	return 0
endif

return 1





