#include "fmk.ch"


// ----------------------------------------
// otvaranje tabele suban
// ----------------------------------------
function use_suban()
local cUse

if EMPTY(gFinKPath)
	return 0
endif

cUse := ALLTRIM(gFinKPath) + "SUBAN.DBF"

select 130
use (cUse) alias ug_suban

return 1



// ----------------------------------------
// vraca saldo partnera
// ----------------------------------------
function g_p_saldo(cPartn, cKto)
local nDuguje
local nPotrazuje
local nSaldo

// otvori suban kao ug_suban
if use_suban() == 0
	return 0
endif

select ug_suban
set order to tag "2"
// idfirma + idpartner + idkonto
seek gFirma + cPartn + cKto

nSaldo := 0
nDuguje := 0
nPotrazuje := 0

do while !EOF() .and. ug_suban->( idfirma + idpartner + idkonto ) == gFirma + cPartn + cKto  
	
	if ug_suban->d_p == "1"
		nDuguje += ug_suban->iznosbhd
	endif
	
	if ug_suban->d_p == "2"
		nPotrazuje += ug_suban->iznosbhd
	endif
	
	skip
	
enddo

nSaldo := nDuguje - nPotrazuje

// klasa 5 potrazuje
if LEFT( cKto, 1 ) == "5"
	nSaldo := nPotrazuje - nDuguje
endif

return nSaldo


// -----------------------------------------
// datum posljednje uplate partnera
// -----------------------------------------
function g_dpupl_part(cKupac, cKto)
local dDatum

// otvori suban kao ug_suban
if use_suban() == 0
	return 0
endif

select ug_suban
set order to tag "1"
// idfirma + idkonto + idpartner + DTOS(datdok)
seek gFirma + cKto + cKupac

dDatum := CToD("")

do while !EOF() .and. ug_suban->( idfirma + idkonto + idPartner ) == gFirma + cKto + cKupac  
	
	if ug_suban->d_p == "2"
		dDatum := ug_suban->datdok
	endif
	
	skip
	
enddo

return dDatum


// --------------------------------------------
// datum posljednje promjene kupac / dobavljac
// --------------------------------------------
function g_dpprom_part(cKupac, cKto)
local dDatum

// otvori suban kao ug_suban
if use_suban() == 0
	return 0
endif

select ug_suban
set order to tag "1"
// idfirma + idkonto + idpartner + DTOS(datdok)
seek gFirma + cKto + cKupac

dDatum := CToD("")

do while !EOF() .and. ug_suban->( idfirma + idkonto + idPartner ) == gFirma + cKto + cKupac  
	dDatum := ug_suban->datdok
	skip
enddo

return dDatum



