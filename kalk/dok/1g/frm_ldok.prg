#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/dok/1g/frm_ldok.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.2 $
 * $Log: frm_ldok.prg,v $
 * Revision 1.2  2002/06/18 14:02:39  mirsad
 * dokumentovanje (priprema za doxy)
 *
 *
 */
 

/*! \file fmk/kalk/dok/1g/frm_ldok.prg
 *  \brief Pregled dokumenata, podataka u modulu KALK
 */

/*! \fn BrowseHron()
 *  \brief Hronoloski browse azuriranih dokumenata
 */

function BrowseHron()
*{
O_ROBA
O_KONCIJ
O_KALK
O_KONTO
cIdFirma:=gFirma

cIdFirma:=left(cIdFirma,2)

O_DOKS

select kalk
select doks; set order to 3
//CREATE_INDEX("DOKSi3","IdFirma+dtos(datdok)+podbr","DOKS")


Box(,19,77)

ImeKol:={}
AADD(ImeKol,{ "Dat.Dok.",   {|| DatDok}                          })
AADD(ImeKol,{ "Podbr",      {|| IF(LEN(podbr)>1,str(asc256(podbr),5),str(asc(podbr),3)) }                          })
AADD(ImeKol,{ "VD  ",       {|| IdVD}                           })
AADD(ImeKol,{ "Broj  ",     {|| BrDok}                           })
AADD(ImeKol,{ "M.Konto",    {|| mkonto}                    })
AADD(ImeKol,{ "P.Konto",    {|| pkonto}                    })
AADD(ImeKol,{ "Nab.Vr",     {|| transform(nv,gpicdem)}                          })
AADD(ImeKol,{ "VPV",        {|| transform(vpv,gpicdem)}                          })
AADD(ImeKol,{ "MPV",        {|| transform(mpv,gpicdem)}                          })
Kol:={}
for i:=1 to len(ImeKol); AADD(Kol,i); next

set cursor on
@ m_x+2,m_y+1 SAY "<SPACE> pomjeri dokument nagore"
BrowseKey(m_x+4,m_y+1,m_x+19,m_y+77,ImeKol,{|Ch| EdHron(Ch)},"idFirma=cidFirma",cidFirma,2,,,{|| .f.})

BoxC()

closeret
*}



/*! \fn EdHron(Ch)
 *  \brief Obrada opcija u hronoloskom browsu dokumenata
 */

function EdHron(Ch)
*{
local cDn:="N",nTrecDok:=0,nRet:=DE_CONT
do case
  CASE Ch==K_CTRL_PGUP
     Tb:GoTop()
    nRet:=DE_REFRESH
  CASE Ch==K_CTRL_PGDN
     Tb:GoBottom()
    nRet:=DE_REFRESH
  case Ch==K_ESC
    nRet:=DE_ABORT
  case Ch==ASC(" ")

     select doks
     cPodbr:=podbr
     cIdvd:=idvd
     cBrdok:=brdok
     nTrecDok:=recno()
     dDatdok:=datdok
     skip -1
     if bof() .or. datdok<>dDatDok
        Msgbeep("Dokument je prvi unutar zadatog datuma")
        go nTrecDok; return DE_CONT
     endif
     cGPodbr:=PodBr
     cGIdvd:=idvd
     cGBrdok:=brdok

     if cGPodbr==cPodbr
       if len(podbr)>1
         if (asc(cPodbr)-1)>5
           cPodbr  := chr256(asc256(cPodbr)-1)
         else
           cGPodbr := chr256(asc256(cPodbr)+1)
         endif
       else
         if (asc(cPodbr)-1)>5
           cPodbr:=chr(asc(cPodbr)-1)
         else
           cGPodbr:=chr( asc(cPodbr)+1)
         endif
       endif
     endif

     go nTrecDok

     select doks;  set order to 1
     seek cidfirma+cidvd+cbrdok
     replace podbr with cGPodbr

     seek cidfirma+cgidvd+cgbrdok
     replace podbr with cPodbr

     select kalk; set order to 1
     seek cidfirma+cidvd+cbrdok
     do while !eof() .and. cIdFirma+cidvd+cbrdok=idfirma+idvd+brdok
       replace podbr with cGPodbr
       skip
     enddo
     seek cidfirma+cgidvd+cgbrdok
     do while !eof() .and. cIdFirma+cgidvd+cgbrdok=idfirma+idvd+brdok
       replace podbr with cPodbr
       skip
     enddo

     select doks; set order to 3
     go nTrecDok

     nRet:=DE_REFRESH

 case Ch==K_ENTER
     BrowseDok()
     select doks
     nRet:=DE_CONT
 case Ch==K_CTRL_P
     PushWa()
     cSeek:=idfirma+idvd+brdok
     close all
     Stkalk(.t.,cSeek)
     O_KALK
     O_DOKS
     PopWA()
     nRet:=DE_REFRESH
endcase
return nRet
*}


/*! \fn BrowseDok()
 *  \brief Pregled dokumenta u vidu browse tabele
 */

function BrowseDok()
*{
select kalk; set order to 1

Box(,15,77,.t.,"Pregled dokumenta")

ImeKol:={}
AADD(ImeKol,{ "Rbr",       {|| Rbr}                         })
AADD(ImeKol,{ "M.Konto",    {|| mkonto}                     })
AADD(ImeKol,{ "P.Konto",    {|| pkonto}                     })
AADD(ImeKol,{ "Roba",       {|| IdRoba}                     })
AADD(ImeKol,{ "Kolicina",   {|| transform(Kolicina,gpickol)} })
AADD(ImeKol,{ "Nc",         {|| transform(nc,gpicdem)}  })
AADD(ImeKol,{ "VPC",        {|| transform(vpc,gpicdem)}  })
AADD(ImeKol,{ "MPCSAPP",    {|| transform(mpcsapp,gpicdem)} })

Kol:={}
for i:=1 to len(ImeKol); AADD(Kol,i); next

set cursor on
@ m_x+2,m_y+1 SAY "Pregled dokumenta: "; ?? doks->idfirma,"-",doks->idvd,"-",doks->brdok," od",doks->datdok
BrowseKey(m_x+4,m_y+1,m_x+15,m_y+77,ImeKol,{|Ch| EdDok(Ch)},"idFirma+idvd+brdok=doks->(idFirma+idvd+brdok)",doks->(idFirma+idvd+brdok),2,,,{|| .f.})

BoxC()
*}



/*! \fn EdDOK(Ch)
 *  \brief Obrada opcija u browsu odredjenog dokumenta
 */

function EdDOK(Ch)
*{
local cDn:="N",nTrecDok:=0,nRet:=DE_CONT
do case
  case Ch==K_ENTER
     BrowseKart()
     nRet:=DE_CONT

 case Ch==K_CTRL_P
     nRet:=DE_REFRESH
endcase
return nRet
*}



/*! \fn BrowseKart()
 *  \brief Browse prikaz kartice artikla 
 */

function BrowseKart()
*{
// tekuca baza: KALK
// prikaz kartice koja je odredjena tekucim zapisom u KALK

nTreckalk:=recno()

cId:=idfirma+idvd+brdok+rbr

cIDFirma:=idfirma
cIdRoba:=idroba
cMkonto:=mkonto
cPkonto:=pkonto

if !empty(cpkonto)
   if !empty(cMkonto) .and. Pitanje(,"Pregled magacina - D, prodavnica - N")=="D"
       cPKonto:=""
   else
       cMkonto:=""
   endif
endif
if empty(cPkonto)
   set order to 3
else
   set order to 4
endif

Box(,15,77,.t.,"Pregled  kartice "+iif(empty(cPkonto),cMKonto,cPKonto))

nArr:=select()

aDbf:={}
AADD(aDbf, {"ID", "C", 15, 0 } )
AADD(aDbf, {"stanje", "N", 15, 3 } )
AADD(aDbf, {"VPV", "N", 15, 3 } )
AADD(aDbf, {"NV", "N", 15, 3 } )
AADD(aDbf, {"VPC", "N", 15, 3 } )
AADD(aDbf, {"MPC", "N", 15, 3 } )
AADD(aDbf, {"MPV", "N", 15, 3 } )
dbcreate2(PRIVPATH+"Kartica",aDbf)

select 66
usex (PRIVPATH+"kartica")
index on id tag "ID"
index on brisano tag "BRISAN"
set order to tag "ID"

if !empty(cMkonto)
    select kalk
    seek cidfirma+cmkonto+cidroba
    nStanje:=nNV:=nVPV:=0
    do while !eof() .and. idfirma+mkonto+idroba==cidfirma+cmkonto+cidroba
      cId:=idfirma+idvd+brdok+rbr
      if mu_i=="1"
          nStanje+=(kolicina-gkolicina-gkolicin2)
          nVPV+=vpc*(kolicina-gkolicina-gkolicin2)
          nNV+=nc*(kolicina-gkolicina-gkolicin2)
       elseif mu_i=="3"
          nVPV+=vpc*kolicina
       elseif mu_i=="5"
          nStanje-=kolicina
          nVPV-=vpc*kolicina
          nNV-=nc*kolicina
       endif
       select kartica
       append blank
       replace id with cid, stanje with nStanje , VPV with nVPV, NV with nNV
       if nStanje<>0
         replace VPC with nVPV/nStanje
       endif
       select kalk
       skip
    enddo
else
    select kalk
    seek cidfirma+cpkonto+cidroba
    nStanje:=nNV:=nMPV:=0
    do while !eof() .and. idfirma+pkonto+idroba==cidfirma+cpkonto+cidroba
      cId:=idfirma+idvd+brdok+rbr
      if pu_i=="1"
          nStanje+=(kolicina-gkolicina-gkolicin2)
          nMPV+=mpcsapp*(kolicina-gkolicina-gkolicin2)
          nNV+=nc*(kolicina-gkolicina-gkolicin2)
       elseif pu_i=="3"
          nMPV+=mpcsapp*kolicina
       elseif pu_i=="5"
          nStanje-=kolicina
          nMPV-=Mpcsapp*kolicina
          nNV-=nc*kolicina
       elseif pu_i=="I"
          nStanje-=gkolicin2
          nMPV-=Mpcsapp*gkolicin2
          nNV-=nc*gkolicin2
       endif
       select kartica
       append blank
       replace id with cid, stanje with nStanje , MPV with nMPV, NV with nNV
       if nStanje<>0
         replace MPC with nMPV/nStanje
       endif
       select kalk
       skip
    enddo

endif

set relation to idfirma+idvd+brdok+rbr into kartica

ImeKol:={}
AADD(ImeKol,{ "VD",       {|| idvd}                         })
AADD(ImeKol,{ "Brdok",    {|| brdok}                         })
AADD(ImeKol,{ "Rbr",      {|| Rbr}                         })
AADD(ImeKol,{ "Kolicina", {|| transform(Kolicina,gpickol)} })
AADD(ImeKol,{ "Nc",       {|| transform(nc,gpicdem)}  })
AADD(ImeKol,{ "VPC",      {|| transform(vpc,gpicdem)}  })
if !empty(cPKonto)
 AADD(ImeKol,{ "MPV",    {|| transform(mpcsapp*kolicina,gpicdem)} })
 AADD(ImeKol,{ "NV po kartici", {|| kartica->nv} })
 AADD(ImeKol,{ "Stanje", {|| kartica->stanje} })
 AADD(ImeKol,{ "MPC po Kartici", {|| kartica->mpc} })
 AADD(ImeKol,{ "MPV po kartici", {|| kartica->mpv} })
else
 AADD(ImeKol,{ "VPV",    {|| transform(vpc*kolicina,gpicdem)} })
 AADD(ImeKol,{ "NV po kartici", {|| kartica->nv} })
 AADD(ImeKol,{ "Stanje", {|| kartica->stanje} })
 AADD(ImeKol,{ "VPC po Kartici", {|| kartica->vpc} })
 AADD(ImeKol,{ "VPV po kartici", {|| kartica->vpv} })
endif

Kol:={}
for i:=1 to len(ImeKol); AADD(Kol,i); next

set cursor on

select roba; hseek cidroba; select kalk
if empty(cPkonto)
 select koncij; seek trim(cmkonto); select kalk
 @ m_x+2,m_y+1 SAY "Pregled kartice magacin: "; ?? cMkonto, "-", cidroba ,"-",roba->naz
 BrowseKey(m_x+4,m_y+1,m_x+15,m_y+77,ImeKol,{|Ch| EdKart(Ch)},;
          "idFirma+mkonto+idroba=cidFirma+cmkonto+cidroba",;
           cidFirma+cmkonto+cidroba,2,,,{|| OznaciMag(.t.)})
else
 select koncij; seek trim(cpkonto) ; select kalk
 @ m_x+2,m_y+1 SAY "Pregled kartice prodavnica: "; ?? cPkonto, "-", cidroba,"-",roba->naz
 BrowseKey(m_x+4,m_y+1,m_x+15,m_y+77,ImeKol,{|Ch| EdKart(Ch)},;
         "idFirma+pkonto+idroba=cidFirma+cpkonto+cidroba",;
         cidFirma+cpkonto+cidroba,2,,,{|| OznaciPro(.t.)})
endif

select kartica; use  // kartica
select kalk; set order to 1
go nTreckalk

BoxC()
return
*}



/*! \fn OznaciMag(fsilent)
 *  \brief Markira sumnjive stavke na magac.kartici i daje poruku o indikacijama
 */

function OznaciMag(fsilent)
*{
// oznaci markiraj stavke koje su
// vjerovatno neispravne

if round(kartica->stanje,4)<>0

   if idvd <> "18"
     if koncij->naz<>"N1" .and. round(VPC-kartica->vpc,2)<>0  // po kartici i po stavci razlika
        if !fsilent
           MsgBeep("vpc stavke <> vpc kumulativno po kartici ??")
        endif
        return .t.
     endif
   else
     if round(mpcsapp+vpc - kartica->vpc,4) <> 0  // vpc iz nivelacije
        if !fsilent
          MsgBeep("vpc stavke <> vpc kumulativno po kartici ??")
        endif
        return .t.
     endif

     if mpcsapp<>0  .and. abs(vpc+MPCSAPP)/mpcsapp * 100 > 80
        if !fsilent
          MSgBeep("Promjena cijene za "+str(abs(vpc+MPCSAPP)/mpcsapp * 100,5,0)+"??")
        endif
     endif

   endif

else
  if round(kartica->vpv,4)<>0
      if !fsilent
       MsgBeep("kolicina 0 , vpv <> 0 ??")
      endif
      return .t.
  endif
  if round(kartica->nv,4)<>0
      if !fsilent
       MsgBeep("kolicina 0 , NV <> 0 ??")
      endif
      return .t.
  endif
endif

if kartica->nv<0
  if !fsilent
    MsgBeep("Nabavna cijena < 0 ???")
  endif
  return .t.
endif

if kartica->vpv<>0 .and. kartica->(nv/vpv)*100 > 150
   if !fsilent
    MsgBeep("VPV za "+str(kartica->(nv/vpv)*100,4,0)+" veca od nabavne ??")
   endif
endif

if kartica->stanje<0
  if !fsilent
    MsgBeep("Stanje negativno ????? ")
  endif
  return .t.
endif

return .f.
*}



/*! \fn OznaciPro(fsilent)
 *  \brief Markira sumnjive stavke na prod.kartici i daje poruku o indikacijama
 */

function OznaciPro(fsilent)
*{
// oznaci markiraj stavke koje su
// vjerovatno neispravne

if round(kartica->stanje,4)<>0

   if idvd <> "19"
     if koncij->naz<>"N1" .and. round(MPCSAPP-kartica->mpc,2)<>0  // po kartici i po stavci razlika
        if !fsilent
           MsgBeep("vpc stavke <> vpc kumulativno po kartici ??")
        endif
        return .t.
     endif
   else
     if round(fcj+mpcsapp - kartica->mpc,4) <> 0  // vpc iz nivelacije
        if !fsilent
          MsgBeep("mpc stavke <> mpc kumulativno po kartici ??")
        endif
        return .t.
     endif

     if fcj<>0  .and. abs(mpcsapp+fcj)/fcj * 100 > 80
        if !fsilent
          MSgBeep("Promjena cijene za "+str(abs(mpcsapp+fcj)/fcj * 100,5,0)+"??")
        endif
     endif

   endif

else
  if round(kartica->mpv,4)<>0
      if !fsilent
       MsgBeep("kolicina 0 , mpv <> 0 ??")
      endif
      return .t.
  endif
  if round(kartica->nv,4)<>0
      if !fsilent
       MsgBeep("kolicina 0 , NV <> 0 ??")
      endif
      return .t.
  endif
endif

if kartica->nv<0
  if !fsilent
    MsgBeep("Nabavna cijena < 0 ???")
  endif
  return .t.
endif


if kartica->stanje<0
  if !fsilent
    MsgBeep("Stanje negativno ????? ")
  endif
  return .t.
endif

return .f.
*}



/*! \fn EdKart(Ch)
 *  \brief Obrada opcija u browsu kartice
 */

function EdKart(Ch)
*{
local cDn:="N",nTrecDok:=0,nRet:=DE_CONT
do case
  case Ch==K_ENTER
     if !empty(cPkonto)
       OznaciPro(.f.)
     else
       OznaciMag(.f.)
     endif

     nRet:=DE_REFRESH

  case Ch==K_CTRL_P
     nRet:=DE_REFRESH
endcase
return nRet
*}


