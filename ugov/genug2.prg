#include "sc.ch"

// ---------------------------------------------
// Generacija faktura po ugovorima, v2 
// radjedno prvenstevno za potrebe sc-a
// ernad.husremovic@sigma-com.net, 2006
// ---------------------------------------------


// ------------------------------
// parametri generacije ugovora
// ------------------------------
static function g_ug_params(dDatObr, dDatGen, dDatLUpl, cKtoDug, cKtoPot, cOpis)
local dPom
local nX := 2
local nBoxLen := 20

dDatGen := DATE()

// datum posljenje uplate u fin
dDatLUpl := CToD("")
// konto kupac
cKtoDug := PADR("2120", 7)
// konto dobavljac
cKtoPot := PADR("5430", 7)
// opis
cOpis := PADR("", 100)

if dDatObr == nil
	dPom := DATE()
else
	dPom := dDatObr
endif

// mjesec na koji se odnosi fakturisanje
nMjesec := MONTH(dPom)
// godina na koju se odnosi fakturisanje
nGodina := YEAR(dPom)

Box("#PARAMETRI ZA GENERACIJU FAKTURA PO UGOVORIMA v2", 12, 70)

@ m_x + nX, m_y + 2 SAY PADL("Datum fakturisanja", nBoxLen) GET dDatGen 
nX += 2

@ m_x + nX, m_y + 2 SAY PADL("Fakt.za mjesec", nBoxLen) GET nMjesec PICT "99" VALID nMjesec >= 1 .or. nMjesec <= 12
@ m_x + nX, col() + 2 SAY "godinu" GET nGodina PICT "9999"

nX += 2
@ m_x + nX, m_y + 2 SAY PADL("Konto duguje", nBoxLen) GET cKtoDug VALID P_Konto(@cKtoDug)

++ nX
@ m_x + nX, m_y + 2 SAY PADL("Konto potrazuje", nBoxLen) GET cKtoPot VALID P_Konto(@cKtoPot)

nX += 2
@ m_x + nX, m_y + 2 SAY PADL("Dat.zadnje upl.fin", nBoxLen) GET dDatLUpl 

nX += 2
@ m_x + nX, m_y + 2 SAY PADL("Opis", nBoxLen) GET cOpis VALID !Empty(cOpis) PICT "@S40"

read

BoxC()

ESC_RETURN 0

dDatObr := mo_ye(nMjesec, nGodina)

return 1


// -------------------------------------------
// generacija ugovora - varijanta 2
// -------------------------------------------
function gen_ug_2()
local dDatObr
local dDatLUpl
local cKtoDug
local cKtoPot
local cOpis
local cFilter
local lSetParams := .f.
local cUPartner
local nSaldo
local nSaldoPDV
local cNBrDok
local nFaktBr
local nMjesec
local nGodina
local dDatGen := DATE()

local cFaktOd
local cFaktDo
// otvori tabele
o_ugov()

if Pitanje(, "Nova obracun (D), ponovi posljednji (N)", "D") == "D"
	// otvori parametre generacije
	lSetParams := .t.
else
	// uzmi posljednju generaciju
	select gen_ug
	set order to tag "dat_gen"
	if RecCount2() == 0
		// nema zapisa
		// setuj parametre
		MsgBeep("Generacije ne postoje ipak setujem parametre!")
		lSetParams := .t.
	else
		go bottom
		if !EOF()
			dDatObr := gen_ug->dat_obr
			dDatlUpl := gen_ug->dat_u_fin
			cKtoDug := gen_ug->kto_kup
			cKtoPot := gen_ug->kto_dob
			cOpis := ALLTRIM(gen_ug->opis)
		endif
	endif
endif

if lSetParams .and. g_ug_params(@dDatObr, @dDatGen, @dDatLUpl, @cKtoDug, @cKtoPot, @cOpis) == 0
	return
endif

// otvori i fakt
O_FAKT
O_PRIPR

if RecCount2() <> 0
	MsgBeep("U pripremi postoje dokumenti#Prekidam generaciju!")
	closeret
endif

// ako postoji vec generisano za datum sta izadji ili nastavi
if lSetParams .and. postoji_generacija(dDatObr) == 0
	return
endif

// dodaj u gen_ug novu generaciju
if lSetParams
	select gen_ug
	set order to tag "dat_obr"
	seek DTOS(dDatObr)
	if !FOUND()
		append blank
	endif
	replace dat_obr with dDatObr
	replace dat_u_fin with dDatLUpl
	replace kto_kup with cKtoDug
	replace kto_dob with cKtoPot
	replace opis with cOpis
endif

// filter na samo aktivne ugovore
cFilter := "aktivan == 'D'"

select ugov
set order to tag "ID"
set filter to &cFilter
go top

nSaldo := 0
nSaldoPDV := 0
nNBrDok := ""

// ukupni broj faktura
nFaktBr := 0

Box(,3, 60)

@ m_x + 1, m_y + 2 SAY "Generacija ugovora u toku..."

cFaktOd := ""
cFaktDo := ""

// precesljaj ugovore u UGOV
do while !EOF()
	
	// da li ima stavki za fakturisanje ???
	if !ima_u_rugov(ugov->id)
		skip
		loop
	endif
	
	select ugov
	
	// provjeri da li treba fakturisati ???
	if !treba_generisati(ugov->id, dDatObr)
		skip
		loop
	endif

	// nadji novi broj dokumenta
	if EMPTY(cNBrDok)
		cNBrDok := FaNoviBroj( gFirma, ugov->idtipdok)
		cFaktOd := cNBrDok
	else
		// uvecaj stari
		cNBrDok := UBrojDok( VAL(LEFT(cNBrDok, gNumDio))+1, gNumDio, RIGHT(cNBrDok, LEN(cNBrDok) - gNumDio))
	endif

	
	
	cUPartner := ugov->idpartner
	
	@ m_x + 2, m_y + 2 SAY "Partner -> " + cUPartner
	
	// generisi ugovor za partnera
	g_ug_f_partner(cUPartner, dDatObr, @nSaldo, @nSaldoPDV, @nFaktBr, cNBrDok)
	select ugov
	skip

enddo
cFaktDo := cNBrDok

// upisi u gen_ug salda
select gen_ug
set order to tag "dat_obr"
go top
seek DTOS(dDatObr)
if Found()
	replace fakt_br with nFaktBr
	replace saldo with nSaldo
	replace saldo_pdv with nSaldoPDV
	replace dat_gen with dDatGen
	replace brdok_od with cFaktOd
	replace brdok_do with cFaktDo
endif

BoxC()

// prikazi info generacije
s_gen_info(dDatObr)

Azur(.f.)
return


// ------------------------------------------
// da li partnera treba generisati
// ------------------------------------------
static function treba_generisati(cUgovId, dDatObr)
local nPMonth
local nPYear
local i
local lNasaoObracun
// predhodni obracun
local dPObr

PushWa()

dPom := dDatObr

SELECT ugov
SEEK cUgovId

SELECT gen_ug_p
SET ORDER TO TAG "DAT_OBR"

lNasaoObracun := .f.
// gledamo obracune u predhodnih 6 mjeseci
for i:=1 to 6

	// predhodni mjesec (datum) u odnosu na dPom
	dPObr := pr_mjesec(dPom)

	// ima li ovaj obracun pohranjen
	SELECT gen_ug_p
	SEEK DTOS(dPObr) + cUgovId + ugov->IdPartner

	if found()
  		lNasaoObracun :=.t.
		exit
	else
		// nisam nasao ovaj obracun, pokusaj ponovo mjesec ispred ...
		dPom := dPObr
	endif

next

if !lNasaoObracun
	// nisam nasao obracun, ovo je prva generacija
	// pa je u ugov upisan datum posljednjeg obracuna
	dPObr := ugov->dat_l_fakt

else
	// ako su rucno pravljene fakture (unaprijed)
	// u ugov se upisuje do kada je to pravljeno
	if ugov->dat_l_fakt >= dDatObr
		dPObr := ugov->dat_l_fakt
	endif
endif

PopWa()

if dDatObr > dPObr
	return .t.
else
	return .f.
endif

// -----------------------------------
// predhodni mjesec
// -----------------------------------
static function pr_mjesec(dPom)
local nPMonth
local nPYear

nPMonth := Month(dPom) - 1
nPYear := Year(dPom)

if nPMonth == 0
	// dPom je bio 01/YYYY
	nPMonth := 12
	nPYear --
endif
return	dPObr := mo_ye(nPMonth, nPYear)


// -----------------------------------------
// da li ima stavki u rugovu za ugovor
// -----------------------------------------
static function ima_u_rugov(cIdUgovor)
local nTArr
local lRet := .f.
nTArr := SELECT()
select rugov
seek cIdUgovor
if Found()
	lRet := .t.
endif
select (nTArr)
return lRet


// --------------------------------
// prikazi info o generaciji
// --------------------------------
static function s_gen_info(dDat)
local cPom

select gen_ug
set order to tag "dat_obr"
go top
seek DTOS(dDat)

if Found()
	
	cPom := "Generisani ugovor za " + DToC(dDat)
	cPom += "##"
	cPom += "Broj faktura: " + ALLTRIM(STR(field->fakt_br))
	cPom += "#"
	cPom += "Saldo: " + ALLTRIM(STR(field->saldo))
	cPom += "#"
	cPom += "PDV: " + ALLTRIM(STR(field->saldo_pdv))
	cPom += "#"
	cPom += "Fakture od: " + gen_ug->brdok_od + " - " + gen_ug->brdok_do

	MsgBeep(cPom)
endif

return


// ------------------------------------
// nastimaj partnera u PARTN
// ------------------------------------
static function n_partner(cId)
local nTArr
nTArr := SELECT()
select partn
seek cId
select (nTArr)
return

// ------------------------------------
// nastimaj roba u ROBI
// ------------------------------------
static function n_roba(cId)
local nTArr
nTArr := SELECT()
select roba
seek cId
select (nTArr)
return


// --------------------------------------------------
// generacija ugovora za jednog partnera
// --------------------------------------------------
static function g_ug_f_partner(cUPartn, dDatObr, nGSaldo, nGSaldoPDV, nFaktBr, cBrDok)
local dDatGen
local cFTipDok
local cIdUgov
local nRbr
local nCijena
local nFaktIzn:=0
local nFaktPDV:=0
local cTxt1
local cTxt2
local cTxt3
local cTxt4
local cTxt5
local nSaldoKup:=0
local nSaldoDob:=0
local dPUplKup:=CTOD("")
local dPPromKup:=CTOD("")
local dPPRomDob:=CTOD("")
local cPom
local nCount
local nPorez
local cKtoPot
local cKtoDug
local dDatLFakt
local nMjesec
local nGodina

select gen_ug
set order to tag "dat_obr"
seek DTOS(dDatObr)

cKtoPot := gen_ug->kto_dob
cKtoDug := gen_ug->kto_kup
dDatLUpl := gen_ug->dat_u_fin
dDatGen := gen_ug->dat_gen
nMjesec := gen_ug->(MONTH(dat_obr))
nGodina := gen_ug->(YEAR(dat_obr))

// nastimaj PARTN na partnera
n_partner(cUPartn)

select ugov

cFTipdok := field->idtipdok
nRbr:=0
cIdUgov := field->id

select rugov
seek cIdUgov

nCount := 0

// prodji kroz rugov
do while !EOF() .and. (id == cIdUgov)

	nCijena := field->cijena
	nKolicina := field->kolicina
	nRabat := field->rabat
	nPorez := field->porez
	
	// nastimaj roba na rugov-idroba
	n_roba(rugov->idroba)
	
	select pripr
	append blank
	
	++ nCount
	
	Scatter()

	// ako je roba tip U
	if roba->tip == "U"
		
		// pronadji djoker #ZA_MJ#
		cPom := str_za_mj(roba->naz, nMjesec, nGodina)
		
		// dodaj ovo u _txt
		a_to_txt(cPom)
	else
		a_to_txt("", .t.)
	endif

	// samo na prvoj stavci generisi txt
	if nRbr == 0
    		
		// nadji tekstove
		cTxt1 := f_ftxt(ugov->idtxt)
		cTxt2 := f_ftxt(ugov->iddodtxt)
		cTxt3 := f_ftxt(ugov->txt2)
		cTxt4 := f_ftxt(ugov->txt3)
		cTxt5 := f_ftxt(ugov->txt4)
		
		select pripr
		
		cPom := cTxt1 + cTxt2 + cTxt3 + cTxt4 + cTxt5
		// dodaj u polje _txt
		a_to_txt(cPom)
		
		// dodaj podatke o partneru
		
		// naziv partnera
		cPom := ALLTRIM(partn->naz)
		a_to_txt(cPom)
		
		// adresa
		cPom := ALLTRIM(partn->adresa)
		a_to_txt(cPom)
		
		// ptt i mjesto
		cPom := ALLTRIM(partn->ptt)
		cPom += " "
		cPom += ALLTRIM(partn->mjesto) 
		a_to_txt(cPom)

		// datum otpremnice
		cPom := DToC(dDatGen)
		a_to_txt(cPom)
		
		// br.otpremnice
		a_to_txt("", .t.)	
		
		// datum isporuke
		a_to_txt(cPom)
		
	endif
	
	select pripr
	
   	_idfirma := gFirma
   	_idpartner := cUPartn
  	_zaokr := ugov->zaokr
   	_rbr := STR(++nRbr, 3)
   	_idtipdok := cFTipDok
   	_brdok := cBrDok
   	_datdok := dDatGen
   	_datpl := dDatGen
   	_kolicina := nKolicina
   	_idroba := rugov->idroba
	
	_cijena := nCijena
	
	// setuj iz sifrarnika
	if _cijena == 0
   		setujcijenu()
		nCijena := _cijena
	endif
		
	_rabat := rugov->rabat
   	_porez := rugov->porez
   	_dindem := ugov->dindem
   		
	nFaktIzn += nKolicina * nCijena
	nFaktPDV += nFaktIzn * (nPorez/100)
	
	nGSaldo += nFaktIzn
	nGSaldoPDV += nFaktPDV
	
	Gather()
	
	select rugov
   	skip
enddo

// saldo kupca
nSaldoKup := g_p_saldo(cUPartn, cKtoDug)
// saldo dobavljaca
nSaldoDob := g_p_saldo(cUPartn, cKtoPot)
// datum zadnje uplate kupca
dPUplKup := g_dpupl_part(cUPartn, cKtoDug)
// datum zadnje promjene kupac
dPPromKup := g_dpprom_part(cUPartn, cKtoDug)
// datum zadnje promjene dobavljac
dPPromDob := g_dpprom_part(cUPartn, cKtoPot)

// dodaj stavku u gen_ug_p
a_to_gen_p(dDatObr, cUPartn, cIdUgov, nSaldoKup,;
           nSaldoDob, dPUplKup, dPPromKup, dPPromDob,;
	   nFaktIzn, nFaktPdv)

// uvecaj broj faktura
++ nFaktBr

select gen_ug
set order to tag "dat_gen"
seek DTOS(dDatGen)

if Found()
	// broj prve fakture
	if EMPTY(field->brdok_od)
		replace field->brdok_od with cBrDok
	endif
	replace field->brdok_do with cBrDok
endif

// vrati se na pripremu i pregledaj djokere na _TXT
select pripr
nTRec := RecNo()

// vrati se na prvu stavku ove fakture
skip -(nCount - 1)

Scatter()

// obradi djokere
txt_djokeri(nSaldoKup, nSaldoDob, dPUplKup, dPPromKup, dPPromDob, dDatLUpl)

Gather()

go (nTRec)

return




// --------------------------------------------
// provjerava da li postoji generacija u GEN_UG
// --------------------------------------------
static function postoji_generacija(dDatGen)

select gen_ug
set order to tag "dat_gen"
seek DTOS(dDatGen)
if !FOUND()
	return 1
endif

if Pitanje(,"Obracun " + fakt_do(dDatGen) + " postoji, ponoviti (D/N)?", "D") == "D"
	return 1
endif

return 0


