#include "sc.ch"
#include "rabat.ch"


/*! \fn P_Rabat(cid, dx, dy)
 *  \brief Vraca ID rabata ukoliko postoji, u suprotnom izvali prozor za odabir iz sif.
 *  \param cid - ??
 *  \param dx - ??
 *  \return dy - ??
 */
function P_Rabat(cid,dx,dy)
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

FOR i:=1 TO LEN(ImeKol)
	AADD(Kol,i)
NEXT

return PostojiSifra(F_RABAT,1,10,70,"Rabatne skale",@cId,dx,dy,{|Ch| RabatBlock(Ch)},,,,,{"ID"})
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


/*! \fn CopyRabat()
 *  \brief Kopiraj rabat 
 */
function CopyRabat()
*{



return
*}



function GetIdRabat(cIdRabat, cTipRabat)
*{
private GetList:={}

Box(, 2, 40)
	@ 1+m_x, 2+m_y SAY "ID Rabat :" GET cIdRabat VALID !Empty(cIdRabat)
	@ 2+m_x, 2+m_y SAY "Tip rabat:" GET cTipRabat VALID !Empty(cTipRabat)
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

