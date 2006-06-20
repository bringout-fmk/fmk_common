#include "sc.ch"


// --------------------------
// --------------------------
function V_Rugov( cId )
private cIdUgov
private GetList:={}
private ImeKol
private Kol

cIdUgov := cId

Box(,15,50)

select rugov

set_a_kol(@ImeKol, @Kol)

set cursor on

@ m_x+1,m_y+1 SAY ""

?? "Ugovor:", ugov->id, ugov->naz, ugov->DatOd

BrowseKey(m_x+3, m_y+1, m_x+14, m_y+50, ImeKol, {|Ch| key_handler(Ch, cIdUgov)}, ;
          "id+brisano==cIdUgov+' '", cIdUgov, 2,,,{|| .f.})

select ugov
BoxC()

return .t.


// -------------------------------------
// setovanje kolona pregleda
// -------------------------------------
static function set_a_kol(aImeKol, aKol)
aImeKol := {}
aKol := {}

AADD(aImeKol, { "IDRoba",   {|| IdRoba} })
AADD(aImeKol, { "Kolicina", {|| Kolicina} })

if IzFMkIni('Fakt_Ugovori', "Rabat_Porez", 'D' )=="D"
	AADD(aImeKol,{ "Rabat",   {|| Rabat}  })
 	AADD(aImeKol,{ "Porez",   {|| Porez}  })
endif

if rugov->(fieldpos("K1"))<>0
	if IzFMkIni('Fakt_Ugovori',"K1",'D')=="D"
  		AADD(aImeKol, { "K1", {|| K1},    "K1"    } )
 	endif
 	if IzFMkIni('Fakt_Ugovori',"K2",'D')=="D"
  		AADD(aImeKol,{ "K2",  {|| K2},    "K2"    } )
 	endif
endif

//if RUGOV->(FIELDPOS("DESTIN"))<>0
//	AADD(aImeKol, { "DESTINACIJA",  {|| DESTIN},    "DESTIN"    } )
//endif

for i:=1 to len(aImeKol)
	AADD(aKol, i)
next

return


//------------------------------------------------
// key handler
//------------------------------------------------
static function key_handler(Ch, cIdUgov)
local lK1:=.f.
//local lDestin:=.f.
local nRet:=DE_CONT

do case

  case Ch==K_F2  .or. Ch==K_CTRL_N
     cIdRoba:=IdRoba
     nKolicina:=kolicina
     nRabat:=rabat
     nPorez:=porez
     //IF rugov->(FIELDPOS("DESTIN"))<>0
       //lDestin:=.t.
       //cDestin:=DESTIN
     //ENDIF
     if fieldpos("K1")<>0
       cK1:=k1
       cK2:=k2
       lK1:=.t.
     endif

     Box(,7,75,.f.)
       @ m_x+1,m_y+2 SAY "Roba       " GET cIdRoba   pict "@!" valid P_Roba(@cIDRoba)
       @ m_x+2,m_y+2 SAY "Kolicina   " GET nKolicina pict "99999999.999"

       if IzFMkIni('Fakt_Ugovori',"Rabat_Porez",'D')=="D"
         @ m_x+3,m_y+2 SAY "Rabat      " GET nRabat pict "99.999"
         @ m_x+4,m_y+2 SAY "Porez      " GET nPorez pict "99.99"
       endif

       if lK1
         if IzFMkIni('Fakt_Ugovori',"K1",'D')=="D"
           @ m_x+5,m_y+2 SAY "K1         " GET cK1 PICT "@!"
         endif
         if IzFMkIni('Fakt_Ugovori',"K2",'D')=="D"
           @ m_x+6,m_y+2 SAY "K2         " GET cK2 PICT "@!"
         endif
       endif

       //if lDestin
        //@ m_x+7,m_y+2 SAY "Destinacija" GET cDestin PICT "@!" VALID EMPTY(cDestin) .or. P_Destin(@cDestin)
       //endif
       read

     BoxC()

     if Ch==K_CTRL_N .and. lastkey()<>K_ESC
       append blank
       replace id with cIdUgov
     endif
     if lastkey()<>K_ESC
       replace idroba with cIdRoba, kolicina with nKolicina, rabat with nRabat,;
               porez with nPorez
       if lK1
         replace k1 with ck1, k2 with ck2
       endif
       
       //if lDestin
         //REPLACE DESTIN WITH cDestin
       //endif
     endif
     nRet:=DE_REFRESH

  case Ch==K_CTRL_T
     if Pitanje(,"Izbrisati stavku ?","N")=="D"
        delete
     endif
     nRet:=DE_DEL

endcase
return nRet




