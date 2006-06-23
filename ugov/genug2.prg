#include "sc.ch"


// ------------------------------
// parametri generacije ugovora
// ------------------------------
static function g_ug_params(dDatGen, nMjesec, nGodina, dDatLUpl, cKtoDug, cKtoPot, cOpis)
local nX := 2
local nBoxLen := 20

// datum generisanja
dDatGen := DATE()
// datum posljenje uplate u fin
dDatLUpl := CToD("")
// konto kupac
cKtoDug := PADR("2120", 7)
// konto dobavljac
cKtoPot := PADR("5430", 7)
// opis
cOpis := PADR("", 100)
// mjesec na koji se odnosi fakturisanje
nMjesec := MONTH(DATE())
// godina na koju se odnosi fakturisanje
nGodina := YEAR(DATE())

Box("#PARAMETRI ZA GENERACIJU FAKTURA PO UGOVORIMA v2",12,70)

@ m_x + nX, m_y + 2 SAY PADL("Datum generisanja", nBoxLen) GET dDatGen

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

return 1


// -------------------------------------------
// generacija ugovora - varijanta 2
// -------------------------------------------
function gen_ug_2()
local dDatGen
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

// otvori tabele
o_ugov()

if Pitanje(, "Nova generacija ugovora ili uzmi posljednju", "D") == "D"
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
			dDatGen := field->dat_gen
			dDatlUpl := field->dat_u_fin
			cKtoDug := field->kto_kup
			cKtoPot := field->kto_dob
			nMjesec := field->mjesec
			nGodina := field->godina
			cOpis := ALLTRIM(field->opis)
		endif
	endif
endif

if lSetParams .and. g_ug_params(@dDatGen, @nMjesec, @nGodina, @dDatLUpl, @cKtoDug, @cKtoPot, @cOpis) == 0
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
if lSetParams .and. postoji_generacija(dDatGen) == 0
	return
endif

// dodaj u gen_ug novu generaciju
if lSetParams
	select gen_ug
	set order to tag "dat_gen"
	seek DTOS(dDatGen)
	if !FOUND()
		append blank
	endif
	replace dat_gen with dDatGen
	replace dat_u_fin with dDatLUpl
	replace kto_kup with cKtoDug
	replace kto_dob with cKtoPot
	replace opis with cOpis
	replace mjesec with nMjesec
	replace godina with nGodina
endif

// filter na samo aktivne ugovore
cFilter := "aktivan == " + Cm2Str("D")

select ugov
set filter to &cFilter
go top

nSaldo := 0
nSaldoPDV := 0
nNBrDok := ""
nFaktBr := 0

Box(,3, 60)

@ m_x + 1, m_y + 2 SAY "Generacija ugovora u toku..."

// precesljaj ugovore u UGOV
do while !EOF()
	
	// da li ima stavki za fakturisanje ???
	if !ima_u_rugov(ugov->id)
		skip
		loop
	endif
	
	select ugov
	
	// provjeri da li treba fakturisati ???
	if !treba_generisati(nMjesec, nGodina, ugov->dat_l_fakt, ugov->f_nivo, ugov->f_p_d_nivo)
		skip
		loop
	endif

	// nadji novi broj dokumenta
	if EMPTY(cNBrDok)
		cNBrDok := FaNoviBroj( gFirma, ugov->idtipdok)
	else
		// uvecaj stari
		cNBrDok := UBrojDok( VAL(LEFT(cNBrDok, gNumDio))+1, gNumDio, RIGHT(cNBrDok, LEN(cNBrDok) - gNumDio))
	endif
	
	select ugov
	
	cUPartner := field->idpartner
	
	@ m_x + 2, m_y + 2 SAY "Partner -> " + cUPartner
	
	// generisi ugovor za partnera
	g_ug_f_partner(cUPartner, dDatGen, @nSaldo, @nSaldoPDV, @nFaktBr, cNBrDok)
	
	select ugov
	
	// upisi podatak o ovom generisanju ako je datum manji od datuma
	// generisanja
	
	if field->dat_l_fakt < dDatGen
		replace field->dat_l_fakt with dDatGen
	endif
	
	skip

enddo

// upisi u gen_ug salda
select gen_ug
set order to tag "dat_gen"
go top
seek DTOS(dDatGen)
if Found()
	replace fakt_br with nFaktBr
	replace saldo with nSaldo
	replace saldo_pdv with nSaldoPDV
endif

BoxC()

// prikazi info generacije
s_gen_info(dDatGen)

return


// ------------------------------------------
// da li partnera treba generisati
// ------------------------------------------
static function treba_generisati(nMjesec, nGodina, dDatLFakt, cNivo, nPNivo)
local dPom

// datum zadnjeg fakturisanja
if STR(YEAR(dDatLFakt), 4) + STR(MONTH(dDatLFakt), 2) >= STR(nGodina, 4) + STR(nMjesec, 2)
	// ne treba generisati
	return .f.
endif

// godisnji nivo generisanja
if cNivo == "G"
	dPom := (dDatLFakt + 365)
	if STR(YEAR(dPom), 4) + STR(MONTH(dPom), 2) > STR(nGodina, 4) + STR(nMjesec, 2)
		// ne generisi
		return .f.
	endif
endif

// mjesecni nivo generisanja
if cNivo == "M"
	if STR(nGodina, 4) + STR(nMjesec, 2) <= STR(YEAR(dDatLFakt), 4) + STR(MONTH(dDatLFakt), 2) 
		// ne generisi
		return .f.
	endif
endif

// proizvoljni nivo generisanja
if cNivo == "P"
	dPom := dDatLFakt + nPNivo
	if STR(YEAR(dPom), 4) + STR(MONTH(dPom), 2) > STR(nGodina, 4) + STR(nMjesec, 2)
		return .f.
	endif
endif

return .t.



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
set order to tag "dat_gen"
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
static function g_ug_f_partner(cUPartn, dDatGen, nGSaldo, nGSaldoPDV, nFaktBr, cBrDok)

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

select gen_ug
set order to tag "dat_gen"
seek DTOS(dDatGen)

cKtoPot := field->kto_dob
cKtoDug := field->kto_kup
dDatLUpl := field->dat_u_fin
nMjesec := field->mjesec
nGodina := field->godina

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
a_to_gen_p(dDatGen, cUPartn, cIdUgov, nSaldoKup,;
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

if Pitanje(,"Generacija za ovaj datum postoji, prepisati je (D/N)?", "N") == "D"
	return 1
endif

return 0


