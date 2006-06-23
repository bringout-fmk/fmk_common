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
function str_za_mj(cStr, dDat)
local cRet
local cPom
local cSrc := "#ZA_MJ#"
local cMjesec
local cGodina

cMjesec := ALLTRIM(STR(MONTH(dDat)))
cGodina := ALLTRIM(STR(YEAR(dDat)))

cPom := "Za mjesec "
cPom += cMjesec
cPom += "/"
cPom += cGodina

cRet := STRTRAN(cStr, cSrc, cPom )

return cRet

// ----------------------------------------
// _txt djokeri, obrada 
// ----------------------------------------
function txt_djokeri(nSaldoKup, nSaldoDob, ;
                     dPUplKup, dPPromKup, dPPromDob)

local cPom

// saldo
cPom := " ( Saldo kupca: "
cPom += ALLTRIM(STR(nSaldoKup))
cPom += " "
cPom += "saldo dobavljaca: "
cPom += ALLTRIM(STR(nSaldoDob))
cPom += " ) "

_txt := STRTRAN(_txt, "#SALDO_KUP_DOB#", cPom)

// datum posljednje uplate kupca
cPom := " ( Datum posljednje uplate kupca: "
cPom += DToC(dPUplKup)
cPom += " ) "

_txt := STRTRAN(_txt, "#D_P_UPLATA_KUP#", cPom)

// datum posljednje promjene kupac
cPom := " ( Datum posljednje promjene na kontu kupca: "
cPom += DToC(dPPromKup)
cPom += " ) "

_txt := STRTRAN(_txt, "#D_P_PROMJENA_KUP#", cPom)

// datum posljednje promjene dobavljac
cPom := " ( Datum posljednje promjene na kontu dobavljaca: "
cPom += DToC(dPPromDob)
cPom += " ) "

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

