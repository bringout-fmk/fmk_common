#include "sc.ch"


// -----------------------------------------
// otvaranje tabele sastavnica
// -----------------------------------------
function p_sast(cId, dx, dy)
private ImeKol
private Kol

select roba

set_a_kol(@ImeKol, @Kol)

select roba
index on id+tip tag "IDUN" to robapro for tip="P"  
// samo lista robe
set order to tag "idun"
go top

return PostojiSifra(F_ROBA, "IDUN_ROBAPRO", 17, 77, "Gotovi proizvodi: <ENTER> Unos norme, <Ctrl-F4> Kopiraj normu, <F7>-lista norm.", @cId, dx, dy, {|Ch| key_handler(Ch)})


// ---------------------------------
// setovanje kolona tabele
// ---------------------------------
static function set_a_kol(aImeKol, aKol)
local cPom
local cPom2

aImeKol := {}
aKol := {}

AADD(aImeKol, {PADC("ID", 10), {|| id}, "id", {|| .t.}, {|| vpsifra(wId)}})
AADD(aImeKol, {PADC("Naziv", 20), {|| PADR(naz,20)}, "naz"})
AADD(aImeKol, {PADC("JMJ", 3), {|| jmj}, "jmj"})

// DEBLJINA i TIP
if roba->(fieldpos("DEBLJINA")) <> 0
	AADD(aImeKol, {PADC("Debljina", 10), {|| transform(debljina, "999999.99")}, "debljina", nil, nil, "999999.99" })
	//AADD(aImeKol, {PADC("Tip art.", 10), {|| tip_art}, "tip_art", {|| .t.}, {|| g_tip_art(@wTip_art) } })
endif

AADD(aImeKol, {PADC("VPC", 10), {|| transform(VPC, "999999.999")}, "vpc"})

// VPC2
if (roba->(fieldpos("vpc2")) <> 0)
	AADD(aImeKol, {PADC("VPC2", 10), {|| transform(VPC2,"999999.999")}, "vpc2"})
endif

AADD(aImeKol, {PADC("MPC", 10), {|| transform(MPC, "999999.999")}, "mpc"})

for i:=2 to 10
	cPom := "MPC" + ALLTRIM(STR(i))
  	cPom2 := '{|| transform(' + cPom + ',"999999.999")}'
  	if roba->(fieldpos(cPom))  <>  0
    		AADD (aImeKol, {PADC(cPom,10 ),;
                  &(cPom2) ,;
                  cPom })
  	endif
next

AADD(aImeKol, {PADC("NC", 10), {|| transform(NC,"999999.999")}, "NC"})
AADD(aImeKol, {"Tarifa", {|| IdTarifa}, "IdTarifa", {|| .t. }, {|| P_Tarifa(@wIdTarifa), EditOpis()}})

AADD(aImeKol, {"K1", {|| K1 }, "K1", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"Tip", {|| " " + Tip + " "}, "Tip", {|| .t.}, {|| wTip $ "P"}})

for i:=1 TO LEN(aImeKol)
	AADD(aKol, i)
next

return



// -------------------------------
// obrada tipki
// -------------------------------
static function key_handler(Ch)
local nUl
local nIzl
local nRezerv
local nRevers
local nIOrd
local nFRec
local aStanje

nTRec := RecNo()

nReturn := DE_CONT

do case
    case Ch == K_CTRL_F9
	// brisanje sastavnica i proizvoda
	bris_sast()
	nReturn := 7

    case Ch == K_ENTER 
	// prikazi sastavnicu
	show_sast()
	nReturn := DE_REFRESH
	
    case Ch == K_CTRL_F4
	// kopiranje sastavnica u drugi proizvod
	copy_sast()
	nReturn := DE_REFRESH

    case Ch == K_F7
	// lista sastavnica
	ISast()
  	nReturn := DE_REFRESH

    case Ch == K_F10  
	// ostale opcije
	ost_opc_sast()
	nReturn := DE_CONT

endcase

select roba
index on id+tip tag "IDUN" to robapro for tip="P"  
// samo lista robe
set order to tag "idun"
go (nTRec)


return nReturn

// -----------------------------------------
// zamjena sastavnice u svim proizvodima
// -----------------------------------------
static function sast_repl_all()
local cOldS
local cNewS
local nKolic

cOldS:=SPACE(10)
cNewS:=SPACE(10)
nKolic:=0

Box(,6,70)
@ m_x+1, m_y+2 SAY "'Stara' sirovina :" GET cOldS PICT "@!" VALID P_Roba(@cOldS)
@ m_x+2, m_y+2 SAY "'Nova'  sirovina :" GET cNewS PICT "@!" VALID cNewS <> cOldS .and. P_Roba(@cNewS)
@ m_x+4, m_y+2 SAY "Kolicina u normama (0 - zamjeni bez obzira na kolicinu)" GET nKolic PICT "999999.99999"
read
BoxC()

if ( LastKey() <> K_ESC )
	select sast
	set order to
        go top
        do while !eof()
        	if id2 == cOldS
                	if (nKolic = 0 .or. ROUND(nKolic - kolicina, 5) = 0)
                        	replace id2 with cNewS
                       	endif
                endif
                skip
        enddo
        set order to tag "idrbr"
endif

return


// ------------------------
// promjena ucesca 
// ------------------------
static function pr_uces_sast()
local cOldS
local cNewS
local nKolic
local nKolic2

cOldS:=SPACE(10)
cNewS:=SPACE(10)
nKolic:=0
nKolic2:=0

Box(,6,65)
@ m_x+1, m_y+2 SAY "Sirovina :" GET cOldS pict "@!" valid P_Roba(@cOldS)
@ m_x+4, m_y+2 SAY "postojeca kolicina u normama " GET nKolic pict "999999.99999"
@ m_x+5, m_y+2 SAY "nova kolicina u normama      " GET nKolic2 pict "999999.99999"   valid nKolic<>nKolic2
read
BoxC()

if (LastKey() <> K_ESC)
	select sast
	set order to
        go top
        do while !EOF()
        	if id2 == cOldS
                	if ROUND(nKolic - kolicina, 5) = 0
                        	replace kolicina with nKolic2
                       	endif
                endif
                skip
        enddo
        set order to tag "idrbr"
endif

return



// ----------------------------------------
// ostale opcije nad sastavnicama
// ----------------------------------------
static function ost_opc_sast()
private opc:={}
private opcexe:={}
private izbor:=1
private am_x:=m_x
private am_y:=m_y

AADD(opc, "1. zamjena sirovine u svim sastavnicama                 ")
AADD(opcexe, {|| sast_repl_all() })
AADD(opc, "2. promjena ucesca pojedine sirovine u svim sastavnicama")
AADD(opcexe, {|| pr_uces_sast() })
AADD(opc, "------------------------------------")
AADD(opcexe, {|| notimp() })
AADD(opc, "L. pregled sastavnica sa pretpostavkama sirovina")
AADD(opcexe, {|| pr_pr_sast() })
AADD(opc, "M. lista sastavnica koje (ne)sadrze sirovinu x")
AADD(opcexe, {|| pr_ned_sast() })
AADD(opc, "D. sifre sa duplim sastavnicama")
AADD(opcexe, {|| pr_dupl_sast() })
AADD(opc, "P. pregled brojnog stanja sastavnica")
AADD(opcexe, {|| pr_br_sast() })
AADD(opc, "E. export sastavnice -> dbf")
AADD(opcexe, {|| _exp_sast_dbf() })
AADD(opc, "F. export roba -> dbf")
AADD(opcexe, {|| _exp_roba_dbf() })


Menu_SC("o_sast")
                		
m_x:=am_x
m_y:=am_y
  
return


// ---------------------------------
// kopiranje sastavnica
// ---------------------------------
static function copy_sast()
local nTRobaRec
local cNoviProizvod
local cIdTek
local nTRec
local nCnt := 0

nTRobaRec:=recno()

if Pitanje(, "Kopirati postojece sastavnice u novi proizvod", "N") == "D"
	cNoviProizvod:=space(10)
     	cIdTek:=field->id
     		
	Box(,2,60)
       	@ m_x+1, m_y+2 SAY "Kopirati u proizvod:" GET cNoviProizvod VALID cNoviProizvod <> cIdTek .and. p_roba(@cNoviProizvod) .and. roba->tip == "P"
       	read
     	BoxC()
     		
	if ( LastKey() <> K_ESC )
       		select sast
		set order to tag "idrbr"
		seek cIdTek
		nCnt := 0
       		do while !eof() .and. (id == cIdTek)
          		++ nCnt
			nTRec:=recno()
          		scatter()
          		_id := cNoviProizvod
          		append blank
			Gather()
          		go (nTrec)
			skip
       		enddo
       		select roba
         	set order to tag "idun"
     	endif
endif

go (nTrobaRec)

if (nCnt > 0)
	MsgBeep("Kopirano sastavnica: " + ALLTRIM(STR(nCnt)) )
else
	MsgBeep("Ne postoje sastavnice na uzorku za kopiranje!")
endif

return


// --------------------------------
// brisanje sastavnica
// --------------------------------
static function bris_sast()
local cDN
local nTRec

cDN:="0"
Box(,5,40)
@ m_x+1,m_Y+2 SAY "Sta ustvari zelite:"
@ m_x+3,m_Y+2 SAY "0. Nista !"
@ m_x+4,m_Y+2 SAY "1. Izbrisati samo sastavnice ?"
@ m_x+5,m_Y+2 SAY "2. Izbrisati i artikle i sastavnice "
@ m_x+5,col()+2 GET cDN valid cDN $ "012"
read
BoxC()

if LastKey() == K_ESC
	return 7
endif

if cDN $ "12" .and. Pitanje(,"Sigurno zelite izbrisati definisane sastavnice ?","N")=="D"
	select sast
      	zap
endif

if cDN $ "2" .and. Pitanje(,"Sigurno zelite izbrisati proizvode ?","N")=="D"
    	select roba  
	// filter je na roba->tip="P"
    	do while !eof()
      		skip
		nTrec := RecNo()
		skip -1
      		delete
      		go (nTrec)
    	enddo
endif

return


// ---------------------------
// prikaz sastavnice
// ---------------------------
static function show_sast()
local nTRobaRec
private cIdTek
private ImeKol
private Kol
	
// roba->id
cIdTek := field->id
nTRobaRec := RecNo()

select sast
set order to tag "idrbr"
set filter to id = cIdTek
go top

// setuj kolone sastavnice tabele
sast_a_kol(@ImeKol, @Kol)
	
PostojiSifra(F_SAST, "IDRBR", 10, 70, cIdTek + "-" + LEFT(roba->naz, 40),,,,{|Char| EdSastBlok(Char)},,,,.f.)

// ukini filter
set filter to
	
select roba
set order to tag "idun"
 	
go nTrobaRec
return



// ------------------------------------
// ispravka sastavnice
// ------------------------------------
static function EdSastBlok(char)

do case
	case char == K_CTRL_F9
		MsgBeep("Nedozvoljena opcija")
   		return 7  
		// kao de_refresh, ali se zavrsava izvr{enje f-ja iz ELIB-a
endcase

return DE_CONT


// --------------------------------
// sastavnice setovanje kolona
// --------------------------------
static function sast_a_kol(aImeKol, aKol)

aImeKol := {}
aKol := {}

// redni broj
AADD(aImeKol, { "rbr", {|| r_br}, "r_br", {|| .t.}, {|| .t.} })

// id roba
AADD(aImeKol, { "Id2", {|| id2}, "id2", {|| .t.}, {|| wId := cIdTek, p_roba(@wId2)} })

// kolicina
AADD(aImeKol, { "kolicina", {|| kolicina}, "kolicina" })

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return

// ----------------------------------------------------------
// lista sastavnica sa pretpostavljenim sirovinama
// ----------------------------------------------------------
function pr_pr_sast()
local cSirovine := SPACE(200)
local cArtikli := SPACE(200)
local cIdRoba
local aSast := {}
local i
local nScan
local aError := {}
local aArt := {}

box(,2,65)
	@ m_x + 1, m_y + 2 SAY "pr.sirovine:" GET cSirovine PICT "@S40" ;
		VALID !EMPTY( cSirovine )
	@ m_x + 2, m_y + 2 SAY "uslov za artikle:" GET cArtikli PICT "@S40"
	read
boxc()

if lastkey() == K_ESC
	return
endif

// sastavnice u matricu...
aSast := TokToNiz( ALLTRIM(cSirovine), ";" )

if !EMPTY(cArtikli)
	bUsl := PARSIRAJ( ALLTRIM(cArtikli), "ID" )
endif

select roba
set order to tag "ID"
go top

do while !EOF()

	if field->tip <> "P"
		skip
		loop
	endif
	
	if !EMPTY( cArtikli )
		if &bUsl
			// idi dalje...
		else
			skip
			loop
		endif
	endif
	
	cIdRoba := field->id
	cRobaNaz := ( field->naz )

	select sast
	set order to tag "ID"
	go top
	seek cIdRoba

	if !FOUND()

		AADD( aError, { 1, cIdRoba, cRobaNaz, ;
			"ne postoji sastavnica !!!" } )

		select roba
		skip
		loop
	
	endif
	
	i := 0

	cUzorak := ""
	lPostoji := .f.

	do while !EOF() .and. field->id == cIdRoba
		
		// sirovina za 
		cUzorak := alltrim( field->id2 )

		lPostoji := .f.

		for i := 1 to LEN( aSast )
			
			cPretp := aSast[ i ]

			if cPretp $ cUzorak
				lPostoji := .t.
				exit
			endif
		
		next

		if lPostoji == .f.
		  AADD( aError, { 2, cIdRoba, roba->naz, "uzorak " + ;
		  	"se ne poklapa !"  } )
		endif

		skip
	
	enddo

	select roba
	skip

enddo

if LEN(aError) == 0
	msgbeep( "sve ok :)" )
	return
endif

START PRINT CRET

i:=0

?

cLine := REPLICATE("-", 5)
cLine += SPACE(1)
cLine += REPLICATE("-", 15)
cLine += SPACE(1)
cLine += REPLICATE("-", 50)
cLine += SPACE(1)
cLine += REPLICATE("-", 50)

cTxt := PADR("rbr", 5)
cTxt += SPACE(1)
cTxt += PADR("uzrok", 15)
cTxt += SPACE(1)
cTxt += PADR("artikal / sirovina", 50)
cTxt += SPACE(1)
cTxt += PADR("opis", 50)

P_COND
? cLine
? cTxt
? cLine

nCnt := 0

for i := 1 to LEN( aError )
	
	? PADL( ALLTRIM( STR( ++nCnt ) ) + ")", 5 )

	if aError[i, 1] == 1
		cPom := "nema sastavnice"
	else
		cPom := "  fale sirovine"
	endif

	@ prow(), pcol()+1 SAY cPom
	@ prow(), pcol()+1 SAY PADR( alltrim( aError[i, 2] ) + "-" + ;
		alltrim( aError[i, 3] ), 50 )
	@ prow(), pcol()+1 SAY PADR( aError[i, 4] , 50)
	
next

FF
END PRINT

return


// -----------------------------------------------
// pregled brojnog stanja sastavnica
// -----------------------------------------------
function pr_br_sast()
local nMin := 5
local nMax := 15
local cArtikli := SPACE(200)
local cIdRoba
local i
local aError := {}

box(,3,65)
	@ m_x + 1, m_y + 2 SAY "min.broj sastavnica:" GET nMin PICT "999" 
	@ m_x + 2, m_y + 2 SAY "max.broj sastavnica:" GET nMax PICT "999"
	@ m_x + 3, m_y + 2 SAY "uslov za artikle:" GET cArtikli PICT "@S40"
	read
boxc()

if lastkey() == K_ESC
	return
endif

if !EMPTY(cArtikli)
	bUsl := PARSIRAJ( ALLTRIM(cArtikli), "ID" )
endif

select roba
set order to tag "ID"
go top

do while !EOF()

	if field->tip <> "P"
		skip
		loop
	endif

	if !EMPTY(cArtikli)
		if &bUsl
			// idi dalje...
		else
			skip
			loop
		endif
	endif

	cIdRoba := field->id

	select sast
	set order to tag "ID"
	go top
	seek cIdRoba

	if !FOUND()
		select roba
		skip
		loop
	endif

	nTmp := 0

	// koliko ima sastavnica ?
	do while !EOF() .and. field->id == cIdRoba
		++ nTmp
		skip
	enddo

	if (nTmp < nMin) .or. (nTmp > nMax)

		AADD( aError, {  ALLTRIM( cIdRoba ) + " - " + ;
			ALLTRIM( roba->naz ), nTmp  } )
	endif

	select roba
	skip

enddo

if LEN(aError) == 0
	msgbeep( "sve ok :)" )
	return
endif

START PRINT CRET

i:=0

?

cLine := REPLICATE("-", 5)
cLine += SPACE(1)
cLine += REPLICATE("-", 5)
cLine += SPACE(1)
cLine += REPLICATE("-", 50)

cTxt := PADR("rbr", 5)
cTxt += SPACE(1)
cTxt += PADR("broj", 5)
cTxt += SPACE(1)
cTxt += PADR("roba", 50)

P_COND
? cLine
? cTxt
? cLine

nCnt := 0

for i := 1 to LEN( aError )
	
	? PADL( ALLTRIM( STR( ++nCnt ) ) + ")", 5 )
	@ prow(), pcol() + 1 SAY STR( aError[ i, 2 ], 5 )
	@ prow(), pcol() + 1 SAY PADR( aError[ i, 1 ], 50 )

next

FF
END PRINT

return





// -----------------------------------------------
// pregled sastavnica koje nedostaju
// -----------------------------------------------
function pr_ned_sast()
local cSirovine := SPACE(200)
local cArtikli := SPACE(200)
local cPostoji := "P"
local cIdRoba
local aSast := {}
local i
local nScan
local aError := {}

box(,3,65)
	@ m_x + 1, m_y + 2 SAY "tr.sirovine:" GET cSirovine PICT "@S40" ;
		VALID !EMPTY( cSirovine )
	@ m_x + 2, m_y + 2 SAY "[P]ostoji / [N]epostoji" GET cPostoji ;
		PICT "@!" ;
		VALID cPostoji $ "PN" 
	@ m_x + 3, m_y + 2 SAY "uslov za artikle:" GET cArtikli PICT "@S40"

	read
boxc()

if lastkey() == K_ESC
	return
endif

// sastavnice u matricu...
aSast := TokToNiz( cSirovine, ";" )

if !EMPTY(cArtikli)
	bUsl := PARSIRAJ( ALLTRIM(cArtikli), "ID" )
endif

select roba
set order to tag "ID"
go top

do while !EOF()

	if field->tip <> "P"
		skip
		loop
	endif

	if !EMPTY(cArtikli)
		if &bUsl
		else
			skip
			loop
		endif
	endif

	cIdRoba := field->id

	select sast
	set order to tag "ID"
	go top
	seek cIdRoba

	if !FOUND()

		select roba
		skip
		loop
	
	endif
	
	i := 0

	lPostoji := .f.

	do while !EOF() .and. field->id == cIdRoba
		
		// sirovina za 
		cUzorak := alltrim( field->id2 )
		nScan := ASCAN( aSast, { |xVal| xVal $ cUzorak })
		
		if nScan <> 0
			lPostoji := .t.			
			exit
		endif

		skip
	
	enddo

	if cPostoji == "N" .and. lPostoji == .f.
		AADD( aError, {  ALLTRIM( cIdRoba ) + " - " + ;
			ALLTRIM( roba->naz )  } )
	endif
	
	if cPostoji == "P" .and. lPostoji == .t.
		AADD( aError, {  ALLTRIM( cIdRoba ) + " - " + ;
			ALLTRIM( roba->naz )  } )
	endif


	select roba
	skip

enddo

if LEN(aError) == 0
	msgbeep( "sve ok :)" )
	return
endif

START PRINT CRET

i:=0

?

cLine := REPLICATE("-", 5)
cLine += SPACE(1)
cLine += REPLICATE("-", 50)

cTxt := PADR("rbr", 5)
cTxt += SPACE(1)
cTxt += PADR("roba", 50)

P_COND
? cLine
? cTxt
? cLine

nCnt := 0

for i := 1 to LEN( aError )
	
	? PADL( ALLTRIM( STR( ++nCnt ) ) + ")", 5 )
	@ prow(), pcol() + 1 SAY PADR( aError[ i, 1 ], 50 )

next

FF
END PRINT


return


// ---------------------------------------------
// pregled duplih sastavnica
// ---------------------------------------------
function pr_dupl_sast()
local cIdRoba
local cArtikli := SPACE(200)
local aSast := {}
local i
local nScan
local aError := {}
local aDbf := {}

box(,1,65)
	@ m_x + 1, m_y + 2 SAY "uslov za artikle:" GET cArtikli PICT "@S40"
	read
boxc()

if lastkey() == K_ESC
	return
endif

AADD(aDbf, { "IDROBA", "C", 10, 0 })
AADD(aDbf, { "ROBANAZ", "C", 200, 0 })
AADD(aDbf, { "SAST", "C", 150, 0 })
AADD(aDbf, { "MARK", "C", 1, 0 })

t_exp_create( aDbf )
O_R_EXP
index on sast tag "1"

O_SAST
O_ROBA
select roba
set order to tag "ID"
go top

if !EMPTY(cArtikli)
	bUsl := PARSIRAJ( ALLTRIM(cArtikli), "ID" )
endif


box(,1,50)

// prvo mi daj svu robu u p.tabelu sa sastavnicama
do while !EOF()

	if field->tip <> "P"
		skip
		loop
	endif

	if !EMPTY(cArtikli)
		if &bUsl
		else
			skip
			loop
		endif
	endif

	cIdRoba := field->id
	cRobaNaz := ALLTRIM( field->naz )

	@ m_x + 1, m_y + 2 SAY "generisem uzorak: " + cIdRoba

	select sast
	set order to tag "ID"
	go top
	seek cIdRoba

	if !FOUND()
		select roba
		skip
		loop
	endif
	
	cUzorak := ""

	do while !EOF() .and. field->id == cIdRoba
		
		cUzorak += ALLTRIM( field->id2 ) 
	
		skip
	enddo

	// upisi u pomocnu tabelu
	select r_export
	append blank
	replace field->idroba with cIdRoba
	replace field->robanaz with cRobaNaz
	replace field->sast with cUzorak

	select roba
	skip

enddo

// sada provjera na osnovu uzoraka

select roba
go top
	
do while !EOF()

	cTmpRoba := field->id	
	cTmpNaz := ALLTRIM( field->naz )
	
	if field->tip <> "P"
		skip
		loop
	endif

	if !EMPTY(cArtikli)
		if &bUsl
		else
			skip
			loop
		endif
	endif

	@ m_x + 1, m_y + 2 SAY "provjeravam uzorke: " + cTmpRoba

	select sast
	set order to tag "ID"
	go top
	seek cTmpRoba

	if !FOUND()
		select roba
		skip
		loop
	endif
	
	cTmp := ""

	do while !EOF() .and. field->id == cTmpRoba
		cTmp += ALLTRIM( field->id2 )
		skip
	enddo

	select r_export
	set order to tag "1"
	go top
	seek PADR( cTmp, 150 )

	do while !EOF() .and. field->sast == PADR(cTmp, 150)
		
		if field->mark == "1"
			skip
			loop
		endif

		if field->idroba == cTmpRoba 
			// ovo je ta sifra, preskoci
			replace field->mark with "1"
			skip
			loop
		endif
		
		// markiraj da sam ovaj artikal prosao
		replace field->mark with "1"

		AADD( aError, { ALLTRIM(cTmpRoba) + " - " + ;
			ALLTRIM( cTmpNaz ), ALLTRIM( r_export->idroba ) + ;
			" - " + ALLTRIM( r_export->robanaz ) } )
		skip
	enddo


	select roba
	skip
enddo

boxc()

if LEN(aError) == 0
	msgbeep( "sve ok :)" )
	return
endif

START PRINT CRET

i:=0

?

cLine := REPLICATE("-", 5)
cLine += SPACE(1)
cLine += REPLICATE("-", 50)
cLine += SPACE(1)
cLine += REPLICATE("-", 50)

cTxt := PADR("rbr", 5)
cTxt += SPACE(1)
cTxt += PADR("roba uzorak", 50)
cTxt += SPACE(1)
cTxt += PADR("ima i u", 50)

P_COND
? cLine
? cTxt
? cLine

nCnt := 0

for i := 1 to LEN( aError )
	
	? PADL( ALLTRIM( STR( ++nCnt ) ) + ")", 5 )
	@ prow(), pcol() + 1 SAY PADR( aError[ i, 1 ], 50 )
	@ prow(), pcol() + 1 SAY PADR( aError[ i, 2 ], 50 )
	
next

FF
END PRINT


return

// -----------------------------------------------
// eksport sastavnica u dbf fajl
// -----------------------------------------------
function _exp_sast_dbf()
local aDbf := {}

AADD(aDbf, {"R_ID", "C", 10, 0 })
AADD(aDbf, {"R_NAZ", "C", 200, 0 })
AADD(aDbf, {"R_JMJ", "C", 3, 0 })
AADD(aDbf, {"S_ID", "C", 10, 0 })
AADD(aDbf, {"S_NAZ", "C", 200, 0 })
AADD(aDbf, {"S_JMJ", "C", 3, 0 })
AADD(aDbf, {"KOL", "N", 12, 2 })
AADD(aDbf, {"NC", "N", 12, 2 })
AADD(aDbf, {"VPC", "N", 12, 2 })
AADD(aDbf, {"MPC", "N", 12, 2 })

t_exp_create( aDbf )

O_R_EXP
O_SAST
O_ROBA

select sast
set order to tag "ID"
go top

box(,1,50)
do while !EOF()
	
	cIdRoba := field->id

	if EMPTY(cIdROba)
		skip
		loop
	endif

	select roba
	go top
	seek cIdRoba

	cR_naz := field->naz
	cR_jmj := field->jmj

	select sast
	
	do while !EOF() .and. field->id == cIdRoba

		cSast := field->id2
		nKol := field->kolicina

		select roba
		go top
		seek cSast
			
		cNaz := field->naz
		nCjen := field->nc

		select sast
		
		@ m_x + 1, m_y + 2 SAY "upisujem: " + cIdRoba
		
		select r_export
		append blank

		replace field->r_id with cIdRoba
		replace field->r_naz with cR_naz
		replace field->r_jmj with cR_jmj
		replace field->s_id with cSast
		replace field->s_naz with cNaz
		replace field->kol with nKol
		replace field->nc with nCjen
		
		select sast
		skip

	enddo

enddo

boxc()

msgbeep("Podaci se nalaze u " + PRIVPATH + "r_export.dbf tabeli !")

select r_export
use

return



// -----------------------------------------------
// export robe u dbf
// -----------------------------------------------
function _exp_roba_dbf()
local aDbf := {}

AADD(aDbf, {"ID", "C", 10, 0 })
AADD(aDbf, {"NAZIV", "C", 200, 0 })
AADD(aDbf, {"JMJ", "C", 3, 0 })
AADD(aDbf, {"NC", "N", 12, 2 })
AADD(aDbf, {"VPC", "N", 12, 2 })
AADD(aDbf, {"MPC", "N", 12, 2 })

t_exp_create( aDbf )
O_R_EXP
O_ROBA
select roba
set order to tag "ID"
go top

box(,1,50)
do while !EOF()
	
	@ m_x + 1, m_y + 2 SAY "upisujem: " + roba->id

	select r_export
	append blank

	replace field->id with roba->id
	replace field->naziv with roba->naz
	replace field->jmj with roba->jmj
	replace field->nc with roba->nc
	replace field->vpc with roba->vpc
	replace field->mpc with roba->mpc

	select roba
	skip
enddo

boxc()

msgbeep("Podaci se nalaze u " + PRIVPATH + "r_export.dbf tabeli !")

select r_export
use

return





