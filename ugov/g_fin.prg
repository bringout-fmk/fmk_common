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
	return CTOD("")
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
	return CTOD("")
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
local nX
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

nX := 1

Box(, 9, 50)

	@ m_x + nX, m_y + 2 SAY "Trenutno stanje partnera:"

    	++nX

    	@ m_x + nX, m_y + 2 SAY "-----------------------------------------------"
    		
	++nX

	@ m_x + nX, m_y + 2 SAY PADR( "(1) stanje na kontu " + cKKup + ": " + ALLTRIM(STR(nSKup, 12, 2)) + " KM", 45 ) COLOR IF(nSKup > 100, "W/R+", "W/G+")
    	
    	++nX

	@ m_x + nX, m_y + 2 SAY PADR( "(2) stanje na kontu " + cKDob + ": " + ALLTRIM(STR(nSDob,12,2)) + " KM", 45 ) COLOR "W/GB+"

	++nX

	@ m_x + nX, m_y + 2 SAY "-----------------------------------------------"
    	++nX

	@ m_x + nX, m_y + 2 SAY "Total (1-2) = " + ALLTRIM(STR(nSaldo,12,2)) + " KM" COLOR IF(nSaldo > 100, "W/R+", "W/G+")
	
	nX += 2

    	@ m_x + nX, m_y + 2 SAY "Datum zadnje uplate: " + DToC(dDate)
		
    	inkey(0)

BoxC()

select (nTArea)

return





