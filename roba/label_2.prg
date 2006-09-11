#include "sc.ch"



// -----------------------------------------
// labeliranje deklaracija...
// -----------------------------------------
function label_2_deklar(aStampati)
local cTxtOut
local cRoba
local nDKolicina
local lPrikBK
local lServRoba
local cLabDim
local cGrupa
local nIdString
local aStrings:={}
local cIdPartner
local nH
local aPrParams

// output fajl
cTxtOut := PRIVPATH + "LABEL.TXT"

// varijable reporta
if get_vars(@cIdPartner, @lServRoba, @lPrikBK, @cLabDim, @cGrupa) == 0
	close all
	return
endif

select pripr
go top

cLabDim := ALLTRIM(cLabDim)

// setuj dimenzije labele na osnovu cLabDim
if !set_lab_dim(cLabDim, @aPrParams)
	MsgBeep("Postoji problem sa dimenzijama labele!!!#Prekidam operaciju!")
	return
endif

Beep(1)

// kreiraj fajl
//create_file(cTxtOut, @nH)
epl2_start()

select pripr

do while !EOF()
	
	// preskoci ako ne treba stampati
	if aStampati[RECNO()] == "N"
		skip 1
		loop
	endif
	
	cRoba := field->idroba
	nDKolicina := field->kolicina
	
	
	// ako roba nema definisano strings - preskoci...
	if !is_roba_strings(cRoba)
		skip 1
		loop
	endif

	// serviser/uvoznik na osnovu robe...
	if !lServRoba
		// nastimaj se na partnera
		seek_partner(cIdPartner)
	else
		cRobaUsl := LEFT(cRoba, 2)
		
		if cRobaUsl == "99"
			// moa line....
			seek_partner(PADR("11", 6))
		else
			// planika...
			seek_partner(PADR("10", 6))
		endif
	endif

	select roba
	hseek cRoba

	nIdString := field->strings
	aStrings := get_str_val(nIdString)

	// ako je selektovana grupa, vidi da li pripada grupi artikal
	if !EMPTY( ALLTRIM(cGrupa) ) .and. ALLTRIM(aStrings[1, 5]) <> ALLTRIM(cGrupa)
		select pripr
		skip 1
		loop
	endif
	
	select pripr
	
	// print labele u txt
	pr_label2(cRoba, nDKolicina, aPrParams)
	
	select pripr
	skip 1
enddo

// zatvori fajl
//close_file(nH)

epl2_end()

close all

return


// -------------------------------------
// setovanje varijabli stampe
// -------------------------------------
static function get_vars(cPartner, lServRoba, lPrikBK, cLabDim, cGrupa)
local nTArea := SELECT()
local nX := 1
local nBoXMax := 10
local cPrikBK := "N"
local cServRoba := "D"

private GetList:={}

cPartner := SPACE(6)
cLabDim := PADR("40x30", 10)
cGrupa := PADR("Obuca", 20)

private cSection:="L"
private cHistory:=" "
private aHistory:={}

O_PARAMS

RPar("lD", @cLabDim)
RPar("lP", @cPartner)
RPar("lB", @cPrikBK)
RPar("lG", @cGrupa)
RPar("lR", @cServRoba)

Box(, nBoxMax, 60)
	
	@ m_x + nX, m_y + 2 SAY "USLOVI STAMPE:"
	
	nX := nX + 2
	
	@ m_x + nX, m_y + 2 SAY "Uvoznika prepoznati na osnovu sifre artikla (D/N)" GET cServRoba VALID cServRoba $ "DN" PICT "@!"

	++ nX

	@ m_x + nX, m_y + 2 SAY "Uvoznik/serviser:" GET cPartner VALID !EMPTY(cPartner) .and. p_firma(@cPartner) WHEN cServRoba == "N"

	++ nX
	
	@ m_x + nX, m_y + 2 SAY "Grupa artikala (prazno-sve):" GET cGrupa VALID EMPTY(cGrupa) .or. g_roba_grupe(@cGrupa)
	
	++ nX
	
	@ m_x + nX, m_y + 2 SAY "Dimenzije labele:" GET cLabDim VALID !EMPTY(cLabDim)
	
	++ nX
	
	@ m_x + nX, m_y + 2 SAY "Prikaz barkod-a (D/N)" GET cPrikBK VALID cPrikBK $ "DN" PICT "@!"
	
	read
BoxC()

if cPrikBK == "D"
	lPrikBK := .t.
else
	lPrikBK := .f.
endif

if cServRoba == "D"
	lServRoba := .t.
else
	lServRoba := .f.
endif

ESC_RETURN 0

cLabDim := PADR(cLabDim, 10)
cGrupa  := PADR(cGrupa, 20)

select params
// snimi parametre...
WPar("lD", @cLabDim)
WPar("lP", @cPartner)
WPar("lB", @cPrikBK)
WPar("lG", @cGrupa)
WPar("lR", @cServRoba)

return 1




// -----------------------------------------
// setovanje dimenzija labele
// -----------------------------------------
static function set_lab_dim(cDim, aPrParams)
local aDim := {}

// aPrParams := {}
// [1] = sirina
// [2] = duzine
// [3] = broj znakova
// [4] = velicina fonta
// [5] = lijeva margina mm
// [6] = gornja margina mm
// ...

aPrParams:={}

cDim := ALLTRIM(cDim)
aDim := TokToNiz(cDim, "x")

if LEN(aDim) <> 2
	return .f.
endif

do case
	case cDim == "40x30"
		//1 - sirina u mm
		AADD(aPrParams, 40 )
		//2 - duzina u mm
		AADD(aPrParams, 30 )

		//3 - max znakova u redu
		AADD(aPrParams, 32 )
		//4 - najmanji font
		AADD(aPrParams,  1 )
		//5 - lijeva marg (nX)
		AADD(aPrParams,  mm2dot(1.7) )

		//6 - gornja margina (nY)
		AADD(aPrParams,  mm2dot(1.2) )
		//7 - velicina reda 
		AADD(aPrParams,  mm2dot(1.65))
		//8 - max redova na etiketi
		AADD(aPrParams,  17)
		
endcase

if LEN(aPrParams) == 0
	return .f.
endif

return .t.


// -------------------------------------------------------------------
// stampa labele: var 2
// cArtikal - id artikla
// cPartner - id partnera
// nKolicina - koliko komada labela
// aPrParams - [] sa parametrima stampe
// -------------------------------------------------------------------

static function pr_label2(cArtikal, nKolicina, aPrParams)
local cPom := ""
local cFPom := ""
local nIdString
local aStrings:={}
local aPom := {}
local nPom
local i
local nLabLen 
local nBrRed
local aText:={}
local nText
local nX
local nY
local nDodajRedova

// duzina karaketera
nLabLen := aPrParams[3]

nIdString := roba->strings
// napuni matricu sa atributima...
aStrings := get_str_val(nIdString)


// napuni u aText redove deklaracije.....

cFPom := "DEKLARACIJA"
AADD(aText, cFPom)

cPom := "Uvoznik: " + ALLTRIM(partn->naz)
aPom := SjeciStr(cPom, nLabLen)
for nPom:=1 to LEN(aPom)
	cFPom := aPom[nPom]
	AADD(aText, cFPom)
next

cPom := ALLTRIM(partn->adresa)
aPom := SjeciStr(cPom, nLabLen)
for nPom:=1 to LEN(aPom)
	cFPom := aPom[nPom]
	AADD(aText, cFPom)
next

cPom := "Sifra: " + cArtikal
aPom := SjeciStr(cPom, nLabLen)
for nPom:=1 to LEN(aPom)
	cFPom := aPom[nPom]
	AADD(aText, cFPom)
next

cPom := "Art: " + ALLTRIM(roba->naz)
aPom := SjeciStr(cPom, nLabLen)
for nPom:=1 to LEN(aPom)
	cFPom := aPom[nPom]
	AADD(aText, cFPom)
next

// uzmi i vrijednosti iz matrice...
if LEN(aStrings) > 0
	for i:=1 to LEN(aStrings)
		
		if ALLTRIM(aStrings[i, 3]) == "R_G_ATTRIB" .and. ;
		   ALLTRIM(aStrings[i, 5]) <> "-"
			
			cPom := ALLTRIM(aStrings[i, 4])
			cPom += " "
			cPom += ALLTRIM(aStrings[i, 5])
			
			aPom := SjeciStr(cPom, nLabLen)
			
			for nPom:=1 to LEN(aPom)
				cFPom := aPom[nPom]
				AADD(aText, cFPom)
			next
		endif
	next
endif

cPom := "Serviser: " + ALLTRIM(partn->naz)
aPom := SjeciStr(cPom, nLabLen)
for nPom:=1 to LEN(aPom)
	cFPom := aPom[nPom]
	AADD(aText, cFPom)
next


// broj redova je ?
nBrRed := LEN(aText)

//cFPom := "br_redova=" + ALLTRIM(STR(nBrRed, 20, 0))
//write_2_file(nH, cFPom, .t.)


// start nove forme
epl2_f_start()

epl2_cp852()

epl2_f_width(aPrParams[1])

// lijeva, gornja margina
epl2_f_init(aPrParams[5], aPrParams[6])

altd()
// aPrParams[8] - max redova na etiketi
nDodajRedova := redova_za_centriranje(nBrRed, aPrParams[8])

nX := 0
nY := 0

for nText:=1 to nDodajRedova
	epl2_string(nX, nY, "", .f. , aPrParams[4])
	nY := aPrParams[7]
next

// evo napokon teksta etikete
for nText:=1 to LEN(aText)
	cFPom := aText[nText]
	// aPrParams[4] - nFontSize
	epl2_string(nX, nY, TRIM(aText[nText]), .f. , aPrParams[4])
	// aPrParams[7] - velicina reda 
	nY := aPrParams[7]
next

// komada stampaj ?
//cFPom := "cnt=" + ALLTRIM(STR(nKolicina, 20, 0))
epl2_f_print(nKolicina)

return


// -----------------------------------------------------
// koliko treba dodati redova da etiketa bude centirana
// -----------------------------------------------------
static function redova_za_centriranje(nBrRed, nMaxRedova)
local nPom

local nGap
nGap := nMaxRedova - nBrRed

if nGap < 0
	return -1
endif
// popolovi ga
nGap := nGap/2

// round(3.4) = 4
nDodaj := ROUND(nGap, 0)
if ROUND(nDodaj, 2) > ROUND(nGap, 2)
	// preletice ako uzmemo ovoliko
	nDodaj--
endif

if (nDodaj < 0.0)
	nDodaj := 0
endif

// provjeri da ne preleti
if ROUND((nDodaj*2 + nBrRed), 2) > ROUND(nMaxRedova, 2)
	nDodaj := 0
endif

return nDodaj



