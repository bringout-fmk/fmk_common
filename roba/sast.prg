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

add_mcode(@aImeKol)

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

do case
    case Ch == K_CTRL_F9
	// brisanje sastavnica i proizvoda
	bris_sast()
	return 7

    case Ch == K_ENTER 
	// prikazi sastavnicu
	show_sast()
	return DE_REFRESH
	
    case Ch == K_CTRL_F4
	// kopiranje sastavnica u drugi proizvod
	copy_sast()
	return DE_REFRESH

    case Ch == K_F7
	// lista sastavnica
	ISast()
  	return DE_REFRESH

    case Ch == K_F10  
	// ostale opcije
	ost_opc_sast()
	return DE_CONT

endcase

return DE_CONT

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
local nCnt

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


