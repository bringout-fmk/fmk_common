#include "ld.ch" 

// -----------------------------------------
// unos datuma isplate plaæe
// -----------------------------------------
function unos_disp()
local dDatPr 
local dDat1
local dDat2
local dDat3
local dDat4
local dDat5
local dDat6
local dDat7
local dDat8
local dDat9
local dDat10
local dDat11
local dDat12
local nGod := YEAR(DATE())
local cRj := "  "
local nX := 1
local cOk := "D"

O_OBRACUNI
if obracuni->(FIELDPOS("DAT_ISPL")) == 0
	MsgBeep("Potrebna modifikacija struktura LD.CHS !!!#Prekidam operaciju")
	return
endif


Box(, 19, 65)
	
	@ m_x + nX, m_y + 2 SAY "*** Unos datuma isplata placa" COLOR "I"
	
	++nX
	++nX
	
	@ m_x + nX, m_y + 2 SAY "Tekuca godina:" GET nGod PICT "9999"
	
	@ m_x + nX, col() + 2 SAY "Radna jedinica:" GET cRJ PICT "99" ;
		VALID EMPTY(cRJ) .or. P_RJ(@cRJ)
	++nX
	
	@ m_x + nX, m_y + 2 SAY "----------------------------------------"  
	++nX

	read

	// uzmi parametre postojece
	// prethodna godina
	dDatPr := g_isp_date( cRj, nGod - 1, 12 )
	// od mjeseca 1 do mjeseca 12 tekuce godine
	dDat1 := g_isp_date( cRj, nGod, 1 )
	dDat2 := g_isp_date( cRj, nGod, 2 )
	dDat3 := g_isp_date( cRj, nGod, 3 )
	dDat4 := g_isp_date( cRj, nGod, 4 )
	dDat5 := g_isp_date( cRj, nGod, 5 )
	dDat6 := g_isp_date( cRj, nGod, 6 )
	dDat7 := g_isp_date( cRj, nGod, 7 )
	dDat8 := g_isp_date( cRj, nGod, 8 )
	dDat9 := g_isp_date( cRj, nGod, 9 )
	dDat10 := g_isp_date( cRj, nGod, 10 )
	dDat11 := g_isp_date( cRj, nGod, 11 )
	dDat12 := g_isp_date( cRj, nGod, 12 )

	@ m_x + nX, m_y + 2 SAY " - 12." + ALLTRIM(STR(YEAR(DATE())-1)) + ;
		" => " GET dDatPr
	++nX
	
	@ m_x + nX, m_y + 2 SAY " - 01." + ALLTRIM(STR(YEAR(DATE()))) + ;
		" => " GET dDat1
	++nX
	
	@ m_x + nX, m_y + 2 SAY " - 02." + ALLTRIM(STR(YEAR(DATE()))) + ;
		" => " GET dDat2
	++nX
	
	@ m_x + nX, m_y + 2 SAY " - 03." + ALLTRIM(STR(YEAR(DATE()))) + ;
		" => " GET dDat3
	++nX
	
	@ m_x + nX, m_y + 2 SAY " - 04." + ALLTRIM(STR(YEAR(DATE()))) + ;
		" => " GET dDat4
	++nX
	
	@ m_x + nX, m_y + 2 SAY " - 05." + ALLTRIM(STR(YEAR(DATE()))) + ;
		" => " GET dDat5
	++nX
	
	@ m_x + nX, m_y + 2 SAY " - 06." + ALLTRIM(STR(YEAR(DATE()))) + ;
		" => " GET dDat6
	++nX
	
	@ m_x + nX, m_y + 2 SAY " - 07." + ALLTRIM(STR(YEAR(DATE()))) + ;
		" => " GET dDat7
	++nX
	
	@ m_x + nX, m_y + 2 SAY " - 08." + ALLTRIM(STR(YEAR(DATE()))) + ;
		" => " GET dDat8
	++nX
	
	@ m_x + nX, m_y + 2 SAY " - 09." + ALLTRIM(STR(YEAR(DATE()))) + ;
		" => " GET dDat9
	++nX
	
	@ m_x + nX, m_y + 2 SAY " - 10." + ALLTRIM(STR(YEAR(DATE()))) + ;
		" => " GET dDat10
	++nX
	
	@ m_x + nX, m_y + 2 SAY " - 11." + ALLTRIM(STR(YEAR(DATE()))) + ;
		" => " GET dDat11
	++nX
	
	@ m_x + nX, m_y + 2 SAY " - 12." + ALLTRIM(STR(YEAR(DATE()))) + ;
		" => " GET dDat12

	++nX
	++nX
	
	@ m_x + nX, m_y + 2 SAY "Unos ispravan (D/N)" GET cOk ;
		VALID cOK $ "DN" ;
		PICT "@!"

	read
BoxC()

if LastKey() <> K_ESC

	if cOk == "N"
		return
	endif
	
	nGodina := nGod

	// setuj promjene
	// prethodna godina
	s_isp_date( cRJ, nGodina - 1 , 12, dDatPr )
	// od 1 do 12 mjeseca tekuce
	s_isp_date( cRJ, nGodina, 1, dDat1 )
	s_isp_date( cRJ, nGodina, 2, dDat2 )
	s_isp_date( cRJ, nGodina, 3, dDat3 )
	s_isp_date( cRJ, nGodina, 4, dDat4 )
	s_isp_date( cRJ, nGodina, 5, dDat5 )
	s_isp_date( cRJ, nGodina, 6, dDat6 )
	s_isp_date( cRJ, nGodina, 7, dDat7 )
	s_isp_date( cRJ, nGodina, 8, dDat8 )
	s_isp_date( cRJ, nGodina, 9, dDat9 )
	s_isp_date( cRJ, nGodina, 10, dDat10 )
	s_isp_date( cRJ, nGodina, 11, dDat11 )
	s_isp_date( cRJ, nGodina, 12, dDat12 )

endif

return


// --------------------------------------------
// vraca tekuce isplate za godinu
// --------------------------------------------
function g_isp_date( cRj, nGod, nMjesec )
local dDate := CTOD("")
local nTArea := SELECT()
O_OBRACUNI

altd()

select obracuni
set order to tag "RJ"
go top
seek  cRJ + ALLTRIM(STR( nGod )) + FmtMjesec( nMjesec ) + "G"

if field->rj == cRj .and. ;
	field->mjesec = nMjesec .and. ;
	field->godina = nGod .and. ;
	field->status == "G"

	dDate := field->dat_ispl

else
	dDate := CTOD("")
endif

select (nTArea)
return dDate


// ----------------------------------------
// setuje datum isplate za mjesec
// ----------------------------------------
static function s_isp_date( cRj, nGod, nMjesec, dDatIspl )
local nTArea := SELECT()

O_OBRACUNI

altd()

select obracuni
set order to tag "RJ"
go top
seek  cRJ + ALLTRIM(STR( nGod )) + FmtMjesec( nMjesec ) + "G"


if field->rj == cRj .and. ;
	field->mjesec = nMjesec .and. ;
	field->godina = nGod .and. ;
	field->status == "G"
	
	replace dat_ispl with dDatIspl
else
	append blank
	replace rj with cRj
	replace godina with nGod
	replace mjesec with nMjesec
	replace status with "G"
	replace dat_ispl with dDatIspl
endif


select (nTArea)
return


