#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/ostalo/1g/kalk.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.3 $
 * $Log: kalk.prg,v $
 * Revision 1.3  2002/09/12 07:31:58  mirsad
 * ispravka putanje u opisu fajla (otalo->ostalo)
 *
 * Revision 1.2  2002/06/18 13:23:38  sasa
 * no message
 *
 * Revision 1.1.1.1  2002/06/17 18:30:18  ernad
 * no message
 *
 *
 */


/*! \file fmk/fakt/ostalo/1g/kalk.prg
 *  \brief Funkcije ukradene iz Kalk-a
 */



/*! \fn BrowseKart()
 *  \brief Browsanje kartice
 *  \param cIdRoba
 */
 
function BrowseKart()
*{
parameters cIdRoba

cSecur:=SecurR(KLevel,"FKKARTICA")
if ImaSlovo("TX",cSecur)
    MsgBeep("Opcija nedostupna !")
    return
endif

nTreckalk:=recno()

//select (F_RJ); if !used(); O_RJ; endif
// iz rj saznajem magacinski konto
//seek gFirma
//cMkonto:=konto

select (F_KONCIJ); if !used(); O_KONCIJ; endif

cIdFirma:=""
cMKonto:=""
cPKonto:=""
gDirKalk:=""
select (F_PARAMS); if !used(); O_PARAMS; endif
private cSection:="6",cHistory:=" "; aHistory:={}
RPar("U9",@cIdFirma)
RPar("U8",@cMKonto)
private cSection:="T",cHistory:=" "; aHistory:={}
RPar("dk",@gDirKalk)

select (F_KALK); use (gDirKalk+"KALK")
set order to 3

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

private cPicUl:=strtran(pickol,"9","*")
private cPicUlDem:=strtran(picdem,"9","*")
private ImeKol:={}
AADD(ImeKol,{ "Broj",     {|| padr(idvd+"-"+trim(brdok)+"/"+alltrim(RBr),13)}      })
AADD(ImeKol,{ "Datum",    {|| DatDok}                         })
AADD(ImeKol,{ "Kolicina", {|| transform(kolicina,iif(mu_i=="1",cPicUl,pickol))} })
AADD(ImeKol,{ "Nc",       {|| transform(nc,iif(mu_i=="1",cPicUlDem,picdem))}  })
AADD(ImeKol,{ "VPC",      {|| transform(vpc,picdem)}  })
if !empty(cPKonto)
 AADD(ImeKol,{ "MPV",    {|| transform(mpcsapp*kolicina,picdem)} })
 AADD(ImeKol,{ "NV po kartici", {|| kartica->nv} })
 AADD(ImeKol,{ "Stanje", {|| kartica->stanje} })
 AADD(ImeKol,{ "MPC po Kartici", {|| kartica->mpc} })
 AADD(ImeKol,{ "MPV po kartici", {|| kartica->mpv} })
else
 AADD(ImeKol,{ "Stanje", {|| kartica->stanje} })
 AADD(ImeKol,{ "NV po kartici", {|| kartica->nv} })
 AADD(ImeKol,{ "VPV",    {|| transform(vpc*kolicina,picdem)} })
 AADD(ImeKol,{ "VPC po Kartici", {|| kartica->vpc} })
 AADD(ImeKol,{ "VPV po kartici", {|| kartica->vpv} })
endif

Kol:={}
for i:=1 to len(ImeKol); AADD(Kol,i); next

set cursor on

NSRNPIdRoba(cIdRoba)
select kalk
if empty(cPkonto)
 select koncij; seek trim(cmkonto); select kalk
 @ m_x+2,m_y+1 SAY "Kartica magacin: "; ?? trim(cMkonto), "-", trim(cidroba) ,"-",roba->naz
 BrowseKey(m_x+4,m_y+1,m_x+15,m_y+77,ImeKol,{|Ch| EdKart(Ch)},;
          "idFirma+mkonto+idroba=cidFirma+cmkonto+cidroba",;
           cidFirma+cmkonto+cidroba,2,,,{|| OznaciMag(.t.)})
else
 select koncij; seek trim(cpkonto) ; select kalk
 @ m_x+2,m_y+1 SAY "Kartica prodavnica: "; ?? cPkonto, "-", cidroba,"-",roba->naz
 BrowseKey(m_x+4,m_y+1,m_x+15,m_y+77,ImeKol,{|Ch| EdKart(Ch)},;
         "idFirma+pkonto+idroba=cidFirma+cpkonto+cidroba",;
         cidFirma+cpkonto+cidroba,2,,,{|| OznaciPro(.t.)})
endif

select kartica; use  // kartica
select kalk; set order to 1
go nTreckalk

BoxC()
*}



/*! \fn OznaciMag(fSilent)
 *  \brief Oznaci/markiraj stavke koje su vjerovatno neispravne
 *  \param fSilent
 */
 
function OznaciMag(fSilent)
*{
return .f.
*}


/*! \fn OznaciPro(fSilent)
 *  \brief Oznaci/markiraj stavke koje su vjerovatno neispravne
 *  \param fSilent
 */
 
function OznaciPro(fSilent)
*{
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
 *  \brief
 *  \param Ch
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

