#include "sc.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/roba/sast.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.3 $
 * $Log: sast.prg,v $
 * Revision 1.3  2003/05/27 15:32:26  mirsad
 * vraæanje posljednje verzije pregleda normativa
 *
 * Revision 1.2  2002/06/16 14:16:54  ernad
 * no message
 *
 *
 */
 
function P_Sast(cid,dx,dy)
PRIVATE ImeKol,Kol
ImeKol:={ }
Kol:={}
AADD (ImeKol,{ padc("ID",10),  {|| id },     "id"   , {|| .t.}, {|| vpsifra(wId)} })
AADD (ImeKol,{ padc("Naziv",40), {|| naz},     "naz"      })
AADD (ImeKol,{ padc("JMJ",3), {|| jmj},       "jmj"    })
AADD (ImeKol,{ padc("VPC",10 ), {|| transform(VPC,"999999.999")}, "vpc"   })
if roba->(fieldpos("vpc2"))<>0
  AADD (ImeKol,{ padc("VPC2",10 ), {|| transform(VPC2,"999999.999")}, "vpc2"   })
endif
AADD (ImeKol,{ padc("MPC",10 ), {|| transform(MPC,"999999.999")}, "mpc"   })
for i:=2 to 10
  cPom:="MPC"+ALLTRIM(STR(i))
  cPom2:='{|| transform('+cPom+',"999999.999")}'
  if roba->( fieldpos( cPom ) )  <>  0
    AADD (ImeKol,{ padc(cPom,10 ),;
                  &(cPom2) ,;
                  cPom })
  endif
next
AADD (ImeKol,{ padc("NC",10 ), {|| transform(NC,"999999.999")}, "NC"   })
AADD (ImeKol,{ "Tarifa",{|| IdTarifa}, "IdTarifa", {|| .t. }, {|| P_Tarifa(@wIdTarifa), EditOpis() }   })
AADD (ImeKol,{ "Tip",{|| " "+Tip+" "}, "Tip", {|| .t.}, {|| wTip $ "P" } } )
FOR i:=1 TO LEN(ImeKol); AADD(Kol,i); NEXT

#ifdef CAX

select roba
index on id+tip to (SIFPATH+"robapro") for tip="P"  additive // samo lista robe
set index to (SIFPATH+"robapro")
go top
return PostojiSifra(F_ROBA,"_ROBAPRO",17,77,"Gotovi proizvodi: <ENTER> Unos norme, <Ctrl-F4> Kopiraj normu, <F7>-lista norm.",@cid,dx,dy,{|Ch| SastBlok(Ch)})

#else
select roba
index on id+tip tag "IDUN" to robapro for tip="P"  // samo lista robe
set order to tag "idun"
go top
return PostojiSifra(F_ROBA,"IDUN_ROBAPRO",17,77,"Gotovi proizvodi: <ENTER> Unos norme, <Ctrl-F4> Kopiraj normu, <F7>-lista norm.",@cid,dx,dy,{|Ch| SastBlok(Ch)})
#endif


function SastBlok(Ch)
local nUl,nIzl,nRezerv,nRevers,fOtv:=.f.,nIOrd,nFRec, aStanje

if Ch==K_CTRL_F9 // zabrani brisanje
  cDN:="0"
  Box(,5,40)
   @ m_x+1,m_Y+2 SAY "Sta ustvari zelite:"
   @ m_x+3,m_Y+2 SAY "0. Nista !"
   @ m_x+4,m_Y+2 SAY "1. Izbrisati samo sastavnice ?"
   @ m_x+5,m_Y+2 SAY "2. Izbrisati i artikle i sastavnice "
   @ m_x+5,col()+2 GET cDN valid cdn $ "012"
   read
  BoxC()

  if lastkey()=K_ESC
    return 7
  endif

  if cdn$"12" .and. pitanje(,"Sigurno zelite izbrisati definisane sastavnice ?","N")=="D"
      select sast
      zap
  endif
  if cdn$"2" .and. pitanje(,"Sigurno zelite izbrisati proizvode ?","N")=="D"
    select roba  // filter je na roba->tip="P"
    do while !eof()
      skip; nTrec:=recno(); skip -1
      delete
      go nTrec
    enddo
  endif

  return 7

elseif Ch==K_ENTER // pregled sastavnice

 nTRobaRec:=recno()
 private cIdTek:=id
 select sast
 set order to tag "id"
 set scope to cidTEk
 private ImeKol:={;
          { "Id2"       , {|| id2 }  , "id2", {|| .t.}, {|| wid:=cIdTek, p_roba(@wid2)} },;
          { "kolicina"  , {|| kolicina}  , "kolicina"      };
        }
 private Kol:={1,2}
 PostojiSifra(F_SAST,1,10,70,cIDTEK+"-"+roba->naz, , , ,{|Ch| EdSastBlok(Ch)},,,,.f.)

 set scope to
 // samo lista robe

 select roba
#ifdef CAX
 set index to (SIFPATH+"robapro")
#else
 set order to tag "idun"
#endif
 go nTrobaRec
 return DE_REFRESH
elseif Ch=K_CTRL_F4
  nTRobaRec:=recno()
  if pitanje(,"Formirati novi normativ po uzoru na postojeci","N")=="D"
     cNoviProizvod:=space(10)
     cIdTek:=id
     Box(,2,60)
       @m_x+1,m_y+2 SAY "Proizvod:" GET cNoviProizvod pict "@!" valid cNoviProizvod<>cIdTek .and. p_Roba(@cNoviProizvod) .and. roba->tip=="P"
       read
     BoxC()
     if lastkey()<>K_ESC
       select sast; set order to tag id
       seek cidtek
       do while !eof() .and. id==cIdTek
          nTRec:=recno()
          scatter()
          _id:=cNoviProizvod
          append blank; Gather()
          go nTrec; skip
       enddo
       select roba
        #ifdef CAX
         set index to (SIFPATH+"robapro")
        #else
         set order to tag idun
        #endif
     endif
  endif
  go nTrobaRec
  return DE_REFRESH

elseif Ch=K_F7
  ISast()
  return DE_REFRESH


elseif Ch=K_F10  // ostale opcije
       private opc[2]
       opc[1]:="1. zamjena sirovine u svim sastavnicama                 "
       opc[2]:="2. promjena ucesca pojedine sirovine u svim sastavnicama"
       h[1]:=h[2]:=""
       private am_x:=m_x,am_y:=m_y
       private Izbor:=1
       do while .t.
          Izbor:=menu("o_sast",opc,Izbor,.f.)
          do case
            case Izbor==0
                EXIT
            case izbor == 1
                cOldS:=space(10)
                cNewS:=space(10)
                nKolic:=0
                Box(,6,70)
                  @ m_x+1,m_y+2 SAY "'Stara' sirovina :" GET cOldS pict "@!" valid P_Roba(@cOldS)
                  @ m_x+2,m_y+2 SAY "'Nova'  sirovina :" GET cNewS pict "@!" valid cNews<>cOldS .and. P_Roba(@cNewS)
                  @ m_x+4,m_y+2 SAY "Kolicina u normama (0 - zamjeni bez obzira na kolicinu)" GET nKolic pict "999999.99999"
                  read
                BoxC()
                if lastkey()<>K_ESC
                  select sast; set order to
                  go top
                  do while !eof()
                    if id2==cOldS
                       if nKolic=0 .or. round(nKolic-kolicina,5)=0
                            replace id2 with cNewS
                       endif
                    endif
                    skip
                  enddo
                  set order to tag ID
                endif
            case izbor == 2
                cOldS:=space(10)
                cNewS:=space(10)
                nKolic:=0
                nKolic2:=0
                Box(,6,65)
                  @ m_x+1,m_y+2 SAY "Sirovina :" GET cOldS pict "@!" valid P_Roba(@cOldS)
                  @ m_x+4,m_y+2 SAY "postojeca kolicina u normama " GET nKolic pict "999999.99999"
                  @ m_x+5,m_y+2 SAY "nova kolicina u normama      " GET nKolic2 pict "999999.99999"   valid nKolic<>nKolic2
                  read
                BoxC()
                if lastkey()<>K_ESC
                  select sast; set order to
                  go top
                  do while !eof()
                    if id2==cOldS
                       if round(nKolic-kolicina,5)=0
                            replace kolicina with nKolic2
                       endif
                    endif
                    skip
                  enddo
                  set order to tag ID
                endif

          endcase
       enddo
       m_x:=am_x; m_y:=am_y
  return DE_CONT

endif


return DE_CONT


function EdSastBlok(ch)

if ch=K_CTRL_F9
   MsgBeep("Nedozvoljena opcija")
   return 7  // kao de_refresh, ali se zavrsava izvr{enje f-ja iz ELIB-a
endif
return DE_CONT



