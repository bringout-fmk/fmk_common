#include "fmk.ch"


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
                     dPUplKup, dPPromKup, ;
		     dPPromDob, dLUplata, ;
		     cPartner )

local cPom

// saldo
cPom := ALLTRIM(STR(nSaldoKup))
_txt := STRTRAN(_txt, "#SALDO_KUP_DOB#", cPom)

// datum posljednje uplate kupca
cPom := DToC(dPUplKup)
_txt := STRTRAN(_txt, "#D_P_UPLATA_KUP#", cPom)

// datum posljednje promjene kupac
cPom := DToC(dPPromKup)
_txt := STRTRAN(_txt, "#D_P_PROMJENA_KUP#", cPom)

// datum posljednje promjene dobavljac
cPom := DToC(dPPromDob)
_txt := STRTRAN(_txt, "#D_P_PROMJENA_DOB#", cPom)

// id partner
cPom := cPartner
_txt := STRTRAN(_txt, "#U_PARTNER#", cPom )

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
function ug_st_od_do(cBrOd, cBrDo)
dDatGen:=DATE()
cBrOd := SPACE(8)
cBrDo := SPACE(8)

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
	
	cBrOd := field->brdok_od
	cBrDo := field->brdok_do
	
	@ m_x + 4, m_y + 2 SAY "FAKTURE OD BROJA" GET cBrOd
	@ m_x + 4, COL() + 2 SAY "DO BROJA" GET cBrDo

	read
	
BoxC()

if LastKey() == K_ESC
	return 0
endif

return 1


// ----------------------------------------------------------
// promjena cijene na artiklu unutar ugovora - grupno
// ----------------------------------------------------------
function ug_ch_price()
local cArtikal := SPACE(10)
local nCijena := 0
local nCnt
local GetList:={}

Box(,1,60)
	@ m_x + 1, m_y + 2 SAY "Artikal:" GET cArtikal VALID !EMPTY(cArtikal)
	@ m_x + 1, col() + 2 SAY "-> cijena:" GET nCijena PICT "99999.999"
	read
BoxC()

if LastKey() == K_ESC
	return
endif

// ako je sve ok
O_RUGOV
select rugov
go top

nCnt := 0

Box(,1, 50)
do while !EOF()

	if field->idroba == cArtikal
		replace field->cijena with nCijena
		
		++nCnt
		@ m_x + 1, m_y + 2 SAY "zamjenjeno ukupno: " + ALLTRIM(STR(nCnt))
	endif
	
	skip

enddo
BoxC()

return



