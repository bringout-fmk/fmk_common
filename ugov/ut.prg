#include "sc.ch"


// -------------------------------------------------------
// vraca naziv partnera
// -------------------------------------------------------
function NazPartn()
local cVrati
local cPom

cPom:=UPPER(ALLTRIM(mjesto))
if cPom$UPPER(naz) .or. cPom$UPPER(naz2)
	cVrati:=TRIM(naz)+" "+TRIM(naz2)
else
	cVrati:=TRIM(naz)+" "+TRIM(naz2)+" "+TRIM(mjesto)
endif

return PADR(cVrati,40)


// -----------------------------------
// ??????
// -----------------------------------
function MSAY2(x, y, c)
@ x,y SAY c
return .t.


// --------------------------------
// konvertuj string #ZA_MJ#
// --------------------------------
function str_za_mj(cStr, nMjesec, nGodina)
local cRet
local cPom
local cSrc := "#ZA_MJ#"
local cMjesec
local cGodina

cMjesec := ALLTRIM(STR(nMjesec))
cGodina := ALLTRIM(STR(nGodina))

cPom := "za mjesec "
cPom += cMjesec
cPom += "/"
cPom += cGodina

cRet := STRTRAN(cStr, cSrc, cPom )

return cRet


// ----------------------------------------
// _txt djokeri, obrada 
// ----------------------------------------
function txt_djokeri(nSaldoKup, nSaldoDob, ;
                     dPUplKup, dPPromKup, dPPromDob, dLUplata)

local cPom

// saldo
cPom := " Vas trenutni saldo je: "
cPom += ALLTRIM(STR(nSaldoKup))
cPom += "."
cPom += " U obzir uzete uplate do "
cPom += DToC(dLUplata)
cPom += ". "

_txt := STRTRAN(_txt, "#SALDO_KUP_DOB#", cPom)

// datum posljednje uplate kupca
cPom := " Datum posljednje uplate: "
cPom += DToC(dPUplKup)
cPom += ". "

_txt := STRTRAN(_txt, "#D_P_UPLATA_KUP#", cPom)

// datum posljednje promjene kupac
cPom := " Datum posljednje promjene na kontu: "
cPom += DToC(dPPromKup)
cPom += ". "

_txt := STRTRAN(_txt, "#D_P_PROMJENA_KUP#", cPom)

// datum posljednje promjene dobavljac
cPom := " Datum posljednje promjene na kontu: "
cPom += DToC(dPPromDob)
cPom += ". "

_txt := STRTRAN(_txt, "#D_P_PROMJENA_DOB#", cPom)

return


// ----------------------------------------
// pronadji i vrati tekst iz FTXT
// ----------------------------------------
function f_ftxt(cId)
local xRet := ""
select ftxt
hseek cId
xRet := TRIM(naz)
return xRet


// -----------------------------------
// dodaj u polje txt tekst
// lVise - vise tekstova
// -----------------------------------
function a_to_txt(cVal, lEmpty)
local nTArr
nTArr := SELECT()

if lEmpty == nil
	lEmpty := .f.
endif
// ako je prazno nemoj dodavati
if !lEmpty .and. EMPTY(cVal)
	return
endif
_txt += CHR(16) + cVal + CHR(17)

select (nTArr)
return


// ---------------------------------------------
// stampa dokumenta od do - iscitaj iz GEN_UG
// ---------------------------------------------
function ug_st_od_do()
local dDatGen:=DATE()
local cBrDokOd := SPACE(8)
local cBrDokDo := SPACE(8)

Box(, 5, 60)
	
	@ m_x + 2, m_y + 2 SAY "DATUM GENERACIJE" GET dDatGen
	read
	
	O_GEN_UG
	select gen_ug
	set order to tag "dat_gen"
	seek DTOS(dDatGen)

	if !FOUND()
		go bottom
	endif
	
	cBrDokOd := field->brdok_od
	cBrDokDo := field->brdok_do
	
	@ m_x + 4, m_y + 2 SAY "FAKTURE OD BROJA" GET cBrDokOd
	@ m_x + 4, COL() + 2 SAY "DO BROJA" GET cBrDokDo

	read
	
BoxC()

if LastKey() == K_ESC
	return
endif

// pozovi stampu...

cTipDok := "10"

StAzPeriod( gFirma, cTipDok, cBrDokOd, cBrDokDo )

return



