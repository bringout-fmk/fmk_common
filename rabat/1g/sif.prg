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

return PostojiSifra(F_RABAT,1,10,70,"Rabatne skale",@cId,dx,dy,{|Ch| RabatBlock(Ch)},,,,,{"IDRABAT"})
*}


/*! \fn RabatBlock()
 *  \brief Opcije sifrarnika rabata
 */
function RabatBlock(Ch)
*{
if (Ch==K_ALT_U)
	return DE_REFRESH
endif


return DE_CONT
*}


/*! \fn FillRabats()
 *  \brief Napuni rabate iz sifrarnika robe
 */
function FillRabats()
*{





return
*}

