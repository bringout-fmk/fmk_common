#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/proizvod/1g/fak_kal.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.2 $
 * $Log: fak_kal.prg,v $
 * Revision 1.2  2002/06/21 13:07:28  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/proizvod/1g/fak_kal.prg
 *  \brief Prenos dokumenata FAKT->KALK za proizvode
 */


/*! \fn FaKaProizvodnja()
 *  \brief Meni opcija za prenos dokumenata FAKT->KALK za proizvode
 */

function FaKaProizvodnja()
*{
private Opc:={}
private opcexe:={}
AADD(Opc,"1. fakt->kalk 96 po normativima za period            ")
AADD(opcexe,{||          PrenosNo()  })
AADD(Opc,"2. fakt->kalk 10 got.proizv po normativima za period")
AADD(opcexe,{||          PrenosNo2() })
private Izbor:=1
Menu_SC("fkno")
return
*}





/*! \fn PrenosNo()
 *  \brief Prenos FAKT -> KALK 96 po normativima
 */

function PrenosNo()
*{
local cIdFirma:=gFirma,cIdTipDok:="10;11;12;      ",cBrDok:=cBrKalk:=space(8)

O_PRIPR
O_KALK
O_ROBA
O_KONTO
O_PARTN
O_TARIFA
O_SAST
XO_FAKT

dDatKalk:=date()
cIdKonto:=padr("",7)
cIdKonto2:=padr("1310",7)
cIdZaduz2:=space(6)

cBrkalk:=space(8)
if gBrojac=="D"
 select kalk
 select kalk; set order to 1;seek cidfirma+"96X"
 skip -1
 if idvd<>"96"
   cbrkalk:=space(8)
 else
   cbrkalk:=brdok
 endif
endif
Box(,15,60)

if gBrojac=="D"
 cbrkalk:=UBrojDok(val(left(cbrkalk,5))+1,5,right(cBrKalk,3))
endif

do while .t.

  nRBr:=0
  @ m_x+1,m_y+2   SAY "Broj kalkulacije 96 -" GET cBrKalk pict "@!"
  @ m_x+1,col()+2 SAY "Datum:" GET dDatKalk
  @ m_x+3,m_y+2   SAY "Konto razduzuje:" GET cIdKonto2 pict "@!" valid P_Konto(@cIdKonto2)
  if gNW<>"X"
    @ m_x+3,col()+2 SAY "Razduzuje:" GET cIdZaduz2  pict "@!"      valid empty(cidzaduz2) .or. P_Firma(@cIdZaduz2)
  endif
  @ m_x+4,m_y+2   SAY "Konto zaduzuje :" GET cIdKonto  pict "@!" valid P_Konto(@cIdKonto)

  cFaktFirma:=cIdFirma
  dDatFOd:=ctod("")
  dDatFDo:=date()
  @ m_x+6,m_y+2 SAY "RJ u FAKT: " GET  cFaktFirma
  @ m_x+7,m_Y+2 SAY "Dokumenti tipa iz fakt:" GET cidtipdok
  @ m_x+8,m_y+2 SAY "period od" GET dDAtFOd
  @ m_x+8,col()+2 SAY "do" GET dDAtFDo
  read
  if lastkey()==K_ESC; exit; endif

  select xfakt
  seek cFaktFirma
  IF !ProvjeriSif("!eof() .and. '"+cFaktFirma+"'==IdFirma","IDROBA",F_ROBA,"idtipdok $ '"+cIdTipdok+"' .and. dDatFOd<=datdok .and. dDatFDo>=datdok")
    MsgBeep("U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!")
    LOOP
  ENDIF
  do while !eof() .and. cFaktFirma==IdFirma

    if idtipdok $ cIdTipdok .and. dDatFOd<=datdok .and. dDatFDo>=datdok // pripada odabranom intervalu

       select ROBA; hseek xfakt->idroba
       if roba->tip="P"  // radi se o proizvodu

          select sast
          hseek  xfakt->idroba
          do while !eof() .and. id==xFakt->idroba // setaj kroz sast
            select roba; hseek sast->id2
            select pripr
            locate for idroba==sast->id2
            if found()
              replace kolicina with kolicina + xfakt->kolicina*sast->kolicina
            else
              select pripr
              append blank
              replace idfirma with cIdFirma,;
                      rbr     with str(++nRbr,3),;
                       idvd with "96",;   // izlazna faktura
                       brdok with cBrKalk,;
                       datdok with dDatKalk,;
                       idtarifa with ROBA->idtarifa,;
                       brfaktp with "",;
                       datfaktp with dDatKalk,;
                       idkonto   with cidkonto,;
                       idkonto2  with cidkonto2,;
                       idzaduz2  with cidzaduz2,;
                       datkurs with dDatKalk,;
                       kolicina with xfakt->kolicina*sast->kolicina,;
                       idroba with sast->id2,;
                       nc  with ROBA->nc,;
                       vpc with xfakt->cijena,;
                       rabatv with xfakt->rabat,;
                       mpc with xfakt->porez
              PrenPoNar()
            endif
            select sast
            skip
          enddo

       endif // roba->tip == "P"
    endif  // $ cidtipdok
    select xfakt
    skip
  enddo

  @ m_x+10,m_y+2 SAY "Dokumenti su preneseni !!"
  if gBrojac=="D"
   cbrkalk:=UBrojDok(val(left(cbrkalk,5))+1,5,right(cBrKalk,3))
  endif
  inkey(4)
  @ m_x+8,m_y+2 SAY space(30)

enddo
Boxc()
closeret
return
*}





/*! \fn PrenosNo2()
 *  \brief Prenos FAKT -> KALK 10 po normativima
 */

function PrenosNo2()
*{
local cIdFirma:=gFirma,cIdTipDok:="10;11;12;      ",cBrDok:=cBrKalk:=space(8)

O_PRIPR
O_KALK
O_ROBA
O_KONTO
O_PARTN
O_TARIFA
O_SAST
XO_FAKT

dDatKalk:=date()
cIdKonto:=padr("5100",7)
cIdZaduz2:=space(6)

cBrkalk:=space(8)
if gBrojac=="D"
 select kalk
 select kalk; set order to 1;seek cidfirma+"10X"
 skip -1
 if idvd<>"10"
   cbrkalk:=space(8)
 else
   cbrkalk:=brdok
 endif
endif
Box(,15,60)

if gBrojac=="D"
 cbrkalk:=UBrojDok(val(left(cbrkalk,5))+1,5,right(cBrKalk,3))
endif

do while .t.

  nRBr:=0
  nRbr2:=900
  @ m_x+1,m_y+2   SAY "Broj kalkulacije 10 -" GET cBrKalk pict "@!"
  @ m_x+1,col()+2 SAY "Datum:" GET dDatKalk
  @ m_x+4,m_y+2   SAY "Konto got. proizvoda zaduzuje :" GET cIdKonto  pict "@!" valid P_Konto(@cIdKonto)

  cFaktFirma:=cIdFirma
  dDatFOd:=ctod("")
  dDatFDo:=date()
  @ m_x+6,m_y+2 SAY "RJ u FAKT: " GET  cFaktFirma
  @ m_x+7,m_Y+2 SAY "Dokumenti tipa iz fakt:" GET cidtipdok
  @ m_x+8,m_y+2 SAY "period od" GET dDAtFOd
  @ m_x+8,col()+2 SAY "do" GET dDAtFDo
  read
  if lastkey()==K_ESC; exit; endif

  select xfakt
  seek cFaktFirma
  IF !ProvjeriSif("!eof() .and. '"+cFaktFirma+"'==IdFirma","IDROBA",F_ROBA,"idtipdok $ '"+cIdTipdok+"' .and. dDatFOd<=datdok .and. dDatFDo>=datdok")
    MsgBeep("U ovom dokumentu nalaze se sifre koje ne postoje u tekucem sifrarniku!#Prenos nije izvrsen!")
    LOOP
  ENDIF
  do while !eof() .and. cFaktFirma==IdFirma

    if idtipdok $ cIdTipdok .and. dDatFOd<=datdok .and. dDatFDo>=datdok // pripada odabranom intervalu

       select ROBA; hseek xfakt->idroba
       if roba->tip="P"  // radi se o proizvodu

          select roba; hseek xfakt->idroba
          select pripr
          locate for idroba==xfakt->idroba
          if found()
            replace kolicina with kolicina + xfakt->kolicina
          else
            select pripr
            append blank
            replace idfirma with cIdFirma,;
                     rbr     with str(++nRbr,3),;
                     idvd with "10",;   // izlazna faktura
                     brdok with cBrKalk,;
                     datdok with dDatKalk,;
                     idtarifa with ROBA->idtarifa,;
                     brfaktp with "",;
                     datfaktp with dDatKalk,;
                     idkonto   with cidkonto,;
                     datkurs with dDatKalk,;
                     idroba with xfakt->idroba,;
                     vpc with xfakt->cijena,;
                     rabatv with xfakt->rabat,;
                     kolicina with xfakt->kolicina,;
                     mpc with xfakt->porez
            PrenPoNar()
          endif

       endif // roba->tip == "P"
    endif  // $ cidtipdok
    select xfakt
    skip
  enddo

  select pripr   ; go top
  do while !eof()
     select sast
     hseek  pripr->idroba
     do while !eof() .and. id==pripr->idroba // setaj kroz sast
       // utvr|ivanje nabavnih cijena po sastavnici !!!!!
       select roba; hseek sast->id2
       select pripr
       // roba->nc - nabavna cijena sirovine
       // sast->kolicina - kolicina po jedinici mjera
       replace fcj with fcj + (roba->nc*sast->kolicina)
       select sast
       skip
     enddo
     select roba // nafiluj nabavne cijene proizvoda u sifrarnik robe!!!
     hseek pripr->idroba
     replace nc with pripr->fcj
     select pripr
     skip
  enddo
  @ m_x+10,m_y+2 SAY "Dokumenti su preneseni !!"
  if gBrojac=="D"
   cbrkalk:=UBrojDok(val(left(cbrkalk,5))+1,5,right(cBrKalk,3))
  endif
  inkey(4)
  @ m_x+8,m_y+2 SAY space(30)

enddo
Boxc()
closeret
return
*}

