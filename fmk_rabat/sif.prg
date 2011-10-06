/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "fmk.ch"
#include "rabat.ch"


/*! \fn P_Rabat(cid, dx, dy)
 *  \brief Vraca ID rabata ukoliko postoji, u suprotnom izvali prozor za odabir iz sif.
 *  \param cid - ??
 *  \param dx - ??
 *  \return dy - ??
 */
function P_Rabat(cId, dx, dy)
*{
private ImeKol,Kol

ImeKol:={}
Kol:={}

O_RABAT

AADD(Imekol,{ "ID"         , {|| idRabat  } , "idRabat"  })
AADD(Imekol,{ "Tip rabata" , {|| tipRabat } , "tipRabat" })
AADD(Imekol,{ "Datum"      , {|| datum    } , "datum"    })
AADD(Imekol,{ "Broj dana"  , {|| dana     } , "dana"     })
AADD(Imekol,{ "Roba"       , {|| idRoba   } , "idRoba"   })
AADD(Imekol,{ "Iznos 1"    , {|| iznos1   } , "iznos1"   })
AADD(Imekol,{ "Iznos 2"    , {|| iznos2   } , "iznos2"   })
AADD(Imekol,{ "Iznos 3"    , {|| iznos3   } , "iznos3"   })
AADD(Imekol,{ "Iznos 4"    , {|| iznos4   } , "iznos4"   })
AADD(Imekol,{ "Iznos 5"    , {|| iznos5   } , "iznos5"   })
AADD(Imekol,{ "Skonto"     , {|| skonto   } , "skonto"   })

for i:=1 to LEN(ImeKol)
	AADD(Kol,i)
next

return PostojiSifra(F_RABAT, 1, 10, 70, "Rabatne skale", @cId, dx, dy, {|Ch| RabatBlock(Ch)}, , , , , {"ID"})
*}


/*! \fn RabatBlock()
 *  \brief Opcije sifrarnika rabata
 */
function RabatBlock(Ch)
*{

do case
	case (Ch==K_ALT_B) // fill rabat from roba
		FillRabats()
		return DE_REFRESH
	case (Ch==K_ALT_G) // kopiraj postojeci rabat
		CopyRabat()
		return DE_REFRESH
endcase

return DE_CONT
*}


/*! \fn FillRabats()
 *  \brief Napuni rabate iz sifrarnika robe
 */
function FillRabats()
*{
private cIdRabat:=SPACE(10)
private cTipRabat:=SPACE(10)

if !GetIdRabat(@cIdRabat, @cTipRabat)
	return
endif

O_ROBA
O_RABAT

select roba
go top

nCnt:=0

Box(, 5, 60)
@ 1+m_x, 2+m_y SAY "Generisem rabatnu skalu iz ROBA..."
@ 2+m_x, 2+m_y SAY "ID rabat  : " + cIdRabat
@ 3+m_x, 2+m_y SAY "Tip rabata: " + cTipRabat
do while !EOF()
	if EMPTY(field->id)
		skip
		loop
	endif
	
	// dodaj zapis u rabatne skale
	select rabat
	
	if RabSExist(PADR(cIdRabat, 10), PADR(cTipRabat, 10), roba->id)
		select roba
		skip
		loop
	endif
	
	append blank
	replace idrabat with cIdRabat
	replace tiprabat with cTipRabat
	replace idroba with roba->id
	replace datum with DATE()
	++ nCnt
	@ 4+m_x, 2+m_y SAY "ID roba   : " + roba->id
	@ 5+m_x, 2+m_y SAY "Kopirano  : " + ALLTRIM(STR(nCnt))
	select roba
	skip
enddo

BoxC()

MsgBeep("Preneseno " + ALLTRIM(STR(nCnt)) + " zapisa...")

select rabat

return
*}


/*! \fn RabSExist(cRabId, cRabType, cArticle)
 *  \brief provjerava da li rabatna skala postoji
 */
function RabSExist(cRabId, cRabType, cArticle)
*{
local nRec
nRec := RecNo()
bRet := .f.

go top
seek cRabId + cRabType + cArticle

if Found()
	bRet := .t.
endif

go nRec

return bRet
*}


/*! \fn CopyRabat()
 *  \brief Kopiraj rabat 
 */
function CopyRabat()
*{
private cFIdRab:=SPACE(10) // copy from
private cFTipRab:=SPACE(10) // copy from
private cTTipRab:=SPACE(10) // copy to
private cTIdRab:=SPACE(10) // copy to

if !GetCpRabat(@cFIdRab, @cFTipRab, @cTIdRab, @cTTipRab)
	return
endif

cFIdRab := PADR(cFIdRab, 10)
if Empty(cFTipRab)
	cFTipRab := ""
else 
	cFTipRab := PADR(cFTipRab, 10)
endif

go top
seek cFIdRab + cFTipRab

nCnt:=0

Box(, 5, 60)
@ 1+m_x, 2+m_y SAY "Kopiram stake u:"
@ 2+m_x, 2+m_y SAY "ID rabat  : " + cTIdRab
@ 3+m_x, 2+m_y SAY "Tip rabata: " + cTTipRab
do while !EOF() .and. idrabat = cFIdRab .and. IIF(!Empty(cFTipRab), tiprabat = cFTipRab, .t.)
	skip
	nRecNo := RecNo()
	skip -1
	
	Scatter()
	append blank
	_idrabat := PADR(cTIdRab, 10)
	// ako je popunjena vrijednost cTTipRab
	if !Empty(cTTipRab)
		_tiprabat := PADR(cTTipRab, 10)
	endif
	Gather()
	++ nCnt
	@ 4+m_x, 2+m_y SAY "Trenutno kopirano: " + ALLTRIM(STR(nCnt))
	
	go nRecNo
enddo

BoxC()
MsgBeep("Kopirano " + ALLTRIM(STR(nCnt)) + " zapisa...")

return
*}



function GetIdRabat(cIdRabat, cTipRabat)
*{
private GetList:={}

Box(, 2, 40)
	@ 1+m_x, 2+m_y SAY "ID Rabat :" GET cIdRabat VALID !Empty(cIdRabat)
	@ 2+m_x, 2+m_y SAY "Tip rabat:" GET cTipRabat
	read
BoxC()

if LastKey() == K_ESC
	return .f.
endif

return .t.
*}


function GetCpRabat(cFIdRab, cFTipRab, cTIdRab, cTTipRab)
*{
private GetList:={}

Box("#Kopiranje rabatnih skala", 6, 60)
	@ 1+m_x, 2+m_y SAY "Kopiraj rabat na osnovu:" COLOR "I"
	@ 2+m_x, 2+m_y SAY "ID Rabat :" GET cFIdRab VALID !Empty(cFIdRab)
	@ 3+m_x, 2+m_y SAY "Tip rabat:" GET cFTipRab
	@ 4+m_x, 2+m_y SAY "u rabatnu skalu:" COLOR "I"
	@ 5+m_x, 2+m_y SAY "ID Rabat :" GET cTIdRab VALID !Empty(cTIdRab)
	@ 6+m_x, 2+m_y SAY "Tip rabat:" GET cTTipRab
	read
BoxC()

if LastKey() == K_ESC
	return .f.
endif

return .t.
*}



function GetTRabat(cTipRab)
*{
private GetList:={}

Box(, 1, 40)
	@ 1+m_x, 2+m_y SAY "Tip rabata:" GET cTipRab VALID !Empty(cTipRab)
	read
BoxC()

if LastKey() == K_ESC
	return .f.
endif

return .t.
*}

