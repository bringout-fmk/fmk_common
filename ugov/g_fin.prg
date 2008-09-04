#include "sc.ch"


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

// -------------------------------------------------------
// ispisuje na ekranu box sa stanjem kupca
// -------------------------------------------------------
function g_box_stanje( cPartner, cKKup, cKDob )
local nTArea
local nSKup := 0
local nSDob := 0
local dDate := CTOD("")
local nSaldo := 0
local lClose
local cGet := " "
private GetList:={}

nTArea := SELECT()

nSKup := g_p_saldo( cPartner, cKKup )
nSDob := g_p_saldo( cPartner, cKDob )
dDate := g_dpupl_part( cPartner, cKKup )

nSaldo := nSKup - nSDob

if nSaldo = 0
	select (nTArea)
	return
endif

lClose := .f.

Box(, 9, 50)
  do while lClose == .f.
    @ m_x + 1, m_y + 2 SAY "Trenutno stanje partnera:"
    @ m_x + 2, m_y + 2 SAY "-----------------------------------------------"
    @ m_x + 3, m_y + 2 SAY "    saldo kupac = " + ALLTRIM(STR(nSKup, 12, 2)) + " KM"
    @ m_x + 4, m_y + 2 SAY "saldo dobavljac = " + ALLTRIM(STR(nSDob,12,2)) + " KM"
    @ m_x + 5, m_y + 2 SAY "-----------------------------------------------"
    @ m_x + 6, m_y + 2 SAY "Total: " + ALLTRIM(STR(nSaldo,12,2)) + " KM"
    @ m_x + 8, m_y + 2 SAY "Datum zadnje uplate: " + DTos(dDate)
    @ m_x + 9, m_y + 2 GET cGet
    read
		
    if LastKey() == K_ENTER
	lClose := .t.
    endif

  enddo

BoxC()

select (nTArea)

return





