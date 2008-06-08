#include "sc.ch"

// ---------------------------------------------
// Generacija faktura po ugovorima, v2 
// radjedno prvenstevno za potrebe sc-a
// ernad.husremovic@sigma-com.net, 2006
// ---------------------------------------------


// ------------------------------
// parametri generacije ugovora
// ------------------------------
static function g_ug_params(dDatObr, dDatGen, dDatVal, dDatLUpl, cKtoDug, cKtoPot, cOpis, cIdArt, nGenCh, cDestin, cDatLFakt )
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
// artikal
cIdArt := PADR("", 10)
// destinacije
cDestin := "N"
// datum posljednjeg fakturisanja partnera
cDatLFakt := "N"

// choice
nGenCh := 0

if dDatObr == nil
	dDatObr := DATE()
endif
if dDatVal == nil
	dDatVal := DATE()
endif

dPom := dDatObr

// mjesec na koji se odnosi fakturisanje
nMjesec := MONTH(dPom)
// godina na koju se odnosi fakturisanje
nGodina := YEAR(dPom)

Box("#PARAMETRI ZA GENERACIJU FAKTURA PO UGOVORIMA v2", 20, 70)

@ m_x + nX, m_y + 2 SAY PADL("Gen. ?/fakt/ponuda (0/1/2)", nBoxLen + 6 ) GET nGenCh ;
	PICT "9"

nX += 1

@ m_x + nX, m_y + 2 SAY PADL("Datum fakturisanja", nBoxLen) GET dDatGen 

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("Datum valute", nBoxLen) GET dDatVal 

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("Fakt.za mjesec", nBoxLen) GET nMjesec PICT "99" VALID nMjesec >= 1 .or. nMjesec <= 12
@ m_x + nX, col() + 2 SAY "godinu" GET nGodina PICT "9999"

nX += 2
@ m_x + nX, m_y + 2 SAY PADL("Konto duguje", nBoxLen) GET cKtoDug VALID P_Konto(@cKtoDug)

++ nX
@ m_x + nX, m_y + 2 SAY PADL("Konto potrazuje", nBoxLen) GET cKtoPot VALID P_Konto(@cKtoPot)

nX += 2
@ m_x + nX, m_y + 2 SAY PADL("Dat.zadnje upl.fin", nBoxLen) GET dDatLUpl ;
   WHEN {|| dDatLUpl := dDatGen - 1, .t. }

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("Fakturisati artikal (prazno-svi)", nBoxLen + 10) GET cIdArt VALID EMPTY(cIdArt) .or. p_roba( @cIdArt )

nX += 2

@ m_x + nX, m_y + 2 SAY PADL("Opis", nBoxLen) GET cOpis ;
   WHEN  {|| cOpis := IIF( EMPTY(cOpis), PADR("Obracun " + fakt_do(dDatObr), 100), cOpis), .t.} ;
   PICT "@S40"

if is_dest()

	nX += 2
	
	@ m_x + nX, m_y + 2 SAY PADL("Uzeti u obzir destinacije ?", nBoxLen + 10) GET cDestin VALID cDestin $ "DN" PICT "@!"

	nX += 1
	
	@ m_x + nX, m_y + 2 SAY PADL("Gledati datum zadnjeg fakturisanja ?", nBoxLen + 16) GET cDatLFakt VALID cDatLFakt $ "DN" PICT "@!"

else
	cDestin := nil
endif


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
local dDatVal
local dDatLUpl
local cKtoDug
local cKtoPot
local cOpis
local cFilter
local lSetParams := .f.
local cUId
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
local cIdArt
local cIdFirma
local nTArea
local cDestin
local nGenCh
local cGenTipDok := ""
local cDatLFakt

// otvori tabele
o_ugov()

// otvori parametre generacije
lSetParams := .t.

if lSetParams .and. g_ug_params(@dDatObr, @dDatGen, @dDatVal, @dDatLUpl, @cKtoDug, @cKtoPot, @cOpis, @cIdArt, @nGenCh, @cDestin, @cDatLFakt ) == 0
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
if lSetParams .and. postoji_generacija(dDatObr, cIdArt) == 0
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
	replace dat_gen with dDatGen
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

if nGenCh == 1
	cGenTipDok := "10"
endif

if nGenCh == 2
	cGenTipDok := "20" 
endif

Box(,3, 60)

@ m_x + 1, m_y + 2 SAY "Generacija ugovora u toku..."

cFaktOd := ""
cFaktDo := ""

// precesljaj ugovore u UGOV
do while !EOF()

	altd()

	// da li ima stavki za fakturisanje ???
	if !ima_u_rugov( ugov->id, cIdArt )
		skip
		loop
	endif
	
	select ugov
	
	// provjeri da li treba fakturisati ???
	if !treba_generisati( ugov->id, dDatObr, cDatLFakt )
		skip
		loop
	endif
	
	if !EMPTY( cIdArt )
		// uzmi firmu na osnovu artikla
		cIdFirma := g_idfirma( cIdArt )
	else
		cIdFirma := gFirma
	endif

	// nadji novi broj dokumenta
	if EMPTY(cNBrDok)
		
		if EMPTY(cGenTipDok)
			cGenTipDok := ugov->idtipdok
		endif
		
		cNBrDok := FaNoviBroj( cIdFirma, cGenTipDok)
		cFaktOd := cNBrDok
	else
		// uvecaj stari
		cNBrDok := UBrojDok( VAL(LEFT(cNBrDok, gNumDio))+1, gNumDio, RIGHT(cNBrDok, LEN(cNBrDok) - gNumDio))
	endif

	cUId := ugov->id
	cUPartner := ugov->idpartner

	// destinacije ...
	if cDestin <> nil .and. cDestin == "D"
		cDefDest := ugov->def_dest 
	else
		cDefDest := nil
	endif

	@ m_x + 2, m_y + 2 SAY "Ug / Partner -> " + cUId + " / " + cUPartner
	
	// generisi ugovor za partnera
	g_ug_f_partner(cUId, cUPartner, dDatObr, dDatVal, @nSaldo, @nSaldoPDV, @nFaktBr, @cNBrDok, cIdArt, cIdFirma, cDefDest, cGenTipDok )
	
	select ugov
	skip

enddo

cFaktDo := cNBrDok


// upisi u gen_ug salda
select gen_ug
set order to tag "dat_obr"
go top
seek DTOS(dDatObr) + cIdArt
if Found()
	replace fakt_br with nFaktBr
	replace saldo with nSaldo
	replace saldo_pdv with nSaldoPDV
	replace dat_gen with dDatGen
	replace dat_val with dDatVal
	replace brdok_od with cFaktOd
	replace brdok_do with cFaktDo
endif

BoxC()

// prikazi info generacije
s_gen_info( dDatObr )

Azur(.t.)

return


// --------------------------------------------
// vraca firmu na osnovu roba->k2
// --------------------------------------------
static function g_idfirma( cArt_id )
local nTArea := SELECT()
local cFirma := gFirma

select roba
go top
seek cArt_id

if FOUND()
	if !EMPTY( field->k2 ) ;
		.and. LEN( ALLTRIM(field->k2) ) == 2 
		
		cFirma := ALLTRIM( field->k2 )
	
	endif
endif

select (nTArea)

return cFirma


// ------------------------------------------
// da li partnera treba generisati
// ------------------------------------------
static function treba_generisati( cUgovId, dDatObr, cDatLFakt )
local nPMonth
local nPYear
local i
local lNasaoObracun
// predhodni obracun
local dPObr
local cNFakt

if cDatLFakt == nil
	cDatLFakt := "N"
endif

PushWa()

dPom := dDatObr

SELECT ugov
SEEK cUgovId


// pogledaj datum zadnjeg fakturisanja....
if cDatLFakt == "D" .and. !EMPTY( ugov->dat_l_fakt )
	PopWa()
	return .f.
endif

// istekao je krajnji rok trajanja ugovora
if ugov->datdo < dDatObr
	PopWa()
	return .f.
endif

// nivo fakturisanja
cFNivo := ugov->f_nivo

SELECT gen_ug_p
SET ORDER TO TAG "DAT_OBR"

// GODISNJI NIVO...
if ugov->f_nivo == "G"

	dPObr := ugov->dat_l_fakt
	
	PopWa()

	if dDatObr - 365 >= dPObr
		return .t.
	else
		return .f.
	endif

else
	
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
			// nisam nasao ovaj obracun, 
			// pokusaj ponovo mjesec ispred ...
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
endif

return

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
static function ima_u_rugov( cIdUgovor, cArt_id )
local nTArr
local lRet := .f.
nTArr := SELECT()
select rugov

if cArt_id == nil
	cArt_id := ""
endif

if EMPTY( cArt_id )
	seek cIdUgovor
else
	seek cIdUgovor + cArt_id
endif

if Found()
	lRet := .t.
endif

select (nTArr)

return lRet


// --------------------------------
// prikazi info o generaciji
// --------------------------------
static function s_gen_info( dDat )
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


// ------------------------------------
// nastimaj destinaciju u DEST
// ------------------------------------
static function n_dest(cPartn, cDest)
local nTArr
local lRet := .f.
nTArr := SELECT()
select dest
set order to tag "ID"
go top
seek cPartn + cDest

if FOUND()
	lRet := .t.
endif

select (nTArr)
return lRet


// --------------------------------------------------
// generacija ugovora za jednog partnera
// --------------------------------------------------
static function g_ug_f_partner(cUId, cUPartn, dDatObr, dDatVal, nGSaldo, nGSaldoPDV, nFaktBr, cBrDok, cArtikal, cFirma, cDestin, cFTipDok )
local dDatGen
local cIdUgov
local i
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
local lFromDest

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

if EMPTY(cFTipDok)
	cFTipdok := ugov->idtipdok
endif

nRbr := 0
cIdUgov := ugov->id

select rugov
nCount := 0

// prodji kroz rugov
do while !EOF() .and. (id == cUId)
	
	lFromDest := .f.

	if !EMPTY( cArtikal )
		
		// ako postoji zadata roba... 
		// ako rugov->idroba nije predmet fakturisanja
		// preskoci tu stavku ...
		
		if cArtikal <> rugov->idroba
			
			select rugov
			skip
			loop
			
		endif
		
	endif

	nCijena := rugov->cijena
	nKolicina := rugov->kolicina
	nRabat := rugov->rabat
	nPorez := rugov->porez

	// nastimaj destinaciju
	if cDestin <> nil .and. !EMPTY( cDestin )
	
		// postoji def. destinacija za svu robu
		if n_dest( cUPartn, cDestin )
			lFromDest := .t.
		endif
		
	elseif cDestin <> nil .and. EMPTY( cDestin )
		
		// za svaku robu treba posebna faktura
		if n_dest( cUPartn, rugov->dest )
			lFromDest := .t.
		endif
		
		// daj novi broj dokumenta....
		if lFromDest == .t. .and. nCount > 0
			
			// uvecaj uk.broj gen.faktura
			++ nFaktBr

			// resetuj brojac stavki na 0
			nRbr := 0
			
			// uvecaj broj dokumenta
			cBrDok := UBrojDok( VAL(LEFT(cBrDok, gNumDio)) + 1, gNumDio, RIGHT(cBrDok, LEN(cBrDok) - gNumDio))

		endif
		
	endif
	
	// nastimaj roba na rugov-idroba
	n_roba(rugov->idroba)
	
	select pripr
	append blank
	
	++ nCount
	
	Scatter()
	
	// ako je roba tip U
	if roba->tip == "U"
		
		// aMemo[1]
		// pronadji djoker #ZA_MJ#
		cPom := str_za_mj(roba->naz, nMjesec, nGodina)
		
		// dodaj ovo u _txt
		a_to_txt( cPom )
	else
		// aMemo[1]
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
	
		// aMemo[2]
		cPom := cTxt1 + cTxt2 + cTxt3 + cTxt4 + cTxt5
		// dodaj u polje _txt
		a_to_txt(cPom)
		
		// dodaj podatke o partneru
		
		// aMemo[3]
		// naziv partnera
		cPom := ALLTRIM(partn->naz)
		a_to_txt(cPom)
		
		// adresa
		// aMemo[4]
		cPom := ALLTRIM(partn->adresa)
		a_to_txt(cPom)
		
		// ptt i mjesto
		// aMemo[5]
		cPom := ALLTRIM(partn->ptt)
		cPom += " "
		cPom += ALLTRIM(partn->mjesto)
		a_to_txt(cPom)

		// br.otpremnice i datum
		// aMemo[6,7]
		a_to_txt("", .t.)	
		a_to_txt("", .t.)	
		
		// br. ugov
		// aMemo[8]
		a_to_txt(ugov->id, .t.)	

		cPom := DToC(dDatGen)

		// datum isporuke 
		// aMemo[9]
		cPom := DTOC(dDatVal)
		a_to_txt(cPom)
	
		// datum valute
		// aMemo[10]
		a_to_txt(cPom)

		if lFromDest == .t.
			
			// dodaj prazne zapise
			cPom := " "
			for i:=11 to 17
				a_to_txt(cPom, .t.)
			next
			
			// uzmi iz destinacije
			cPom := ""
			cPom += ALLTRIM( dest->naziv ) 
			
			if !EMPTY( dest->naziv2 )
				cPom += " "
				cPom += ALLTRIM( dest->naziv2 )
			endif
			
			if !EMPTY( dest->mjesto )
				cPom += ", "
				cPom += ALLTRIM( dest->mjesto )
			endif
			
			if !EMPTY( dest->adresa )
				cPom += ", "
				cPom += ALLTRIM( dest->adresa )
			endif
			
			if !EMPTY( dest->ptt )
				cPom += ", "
				cPom += ALLTRIM( dest->ptt )
			endif
			
			if !EMPTY( dest->telefon )
				cPom += ", tel: "
				cPom += ALLTRIM( dest->telefon )
			endif
			
			if !EMPTY( dest->fax ) 
				cPom += ", fax: "
				cPom += ALLTRIM( dest->fax )
			endif

			a_to_txt( cPom, .t. )
			
		endif

	endif
	
	select pripr
	
   	_idfirma := cFirma
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
	
	// resetuj _txt
	_txt := ""

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
a_to_gen_p(dDatObr, cUId, cUPartn, nSaldoKup,;
           nSaldoDob, dPUplKup, dPPromKup, dPPromDob,;
	   nFaktIzn, nFaktPdv )

// uvecaj broj faktura
++ nFaktBr

select gen_ug
set order to tag "dat_obr"
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
txt_djokeri(nSaldoKup, nSaldoDob, dPUplKup, dPPromKup, dPPromDob, dDatLUpl, cUPartn )

Gather()

go (nTRec)

return




// --------------------------------------------
// provjerava da li postoji generacija u GEN_UG
// --------------------------------------------
static function postoji_generacija( dDatObr, cIdArt )

if !EMPTY( cIdArt )
	return 1
endif

select gen_ug
set order to tag "dat_obr"
seek DTOS(dDatObr)

if !FOUND()
	return 1
endif

if Pitanje(,"Obracun " + fakt_do(dDatObr) + " postoji, ponoviti (D/N)?", "D") == "D"
	vrati_nazad( dDatObr, cIdArt )

	close all
	o_ugov()
	// otvori i fakt
	O_FAKT
	O_PRIPR
	SELECT gen_ug
	set order to tag "dat_obr"
	seek DTOS(dDatObr)
	return 1
endif

return 0


// ---------------------------------------------
// vrati obracun nazad
// ---------------------------------------------
static function vrati_nazad( dDatObr, cIdArt )
local cBrDokOdDo
local cFirma := gFirma

select gen_ug
set order to tag "dat_obr"
go top
seek DTOS(dDatObr)

if !found()
	MsgBeep("Obracun " + fakt_do(dDatObr) + " ne postoji")
	return
endif

if !EMPTY(cIdArt)
	cFirma := g_idfirma( cIdArt )
endif

if IsDocExists(cFirma, "10", gen_ug->brdok_od) .and. ;
	IsDocExists(cFirma, "10", gen_ug->brdok_do)
	
	cBrDokOdDo := gen_ug->brdok_od + "--" +  gen_ug->brdok_do + ";"
	PovSvi(cBrDokOdDo, nil, nil, cFirma)

endif

// izbrisi pripremu
O_PRIPR
BrisiPripr()

return


