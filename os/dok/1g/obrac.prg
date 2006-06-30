#include "\cl\sigma\fmk\os\os.ch"

function Obrac()
*{
private Izbor:=1,opc[2]
Opc[1]:="1. amortizacija   "
Opc[2]:="2. revalorizacija"

cTip:=IF(gDrugaVal=="D",ValDomaca(),"")

do while .t.

  h[1]:=".."
  h[2]:=".."

  Izbor:=menu("osob",opc,Izbor,.f.)

  cBBV:=cTip; nBBK:=1

  do case
    case Izbor==0
        EXIT
    case izbor == 1
        ObrAm()
    case izbor == 2
        ObrRev()
  endcase

enddo

return
*}

***********************
***********************
function ObrAm()
*{
local  cAGrupe:="N",nRec,dDatObr,nMjesOd,nMjesDo

O_AMORT
O_OS
O_PROMJ

dDatObr:=gDatObr
private nGStopa:=100
cFiltK1:=SPACE(40)

Box("#OBRACUN AMORTIZACIJE",5,60)
 DO WHILE .t.
  @ m_x+1,m_y+2 SAY "Datum obracuna:" GET dDatObr
  @ m_x+2,m_y+2 SAY "Varijanta ubrzane amortizacije po grupama ?" GET cAGrupe pict "@!"
  @ m_x+4,m_y+2 SAY "Pomnoziti obracun sa koeficijentom (%)" GET nGStopa pict "999.99"
  @ m_x+5,m_y+2 SAY "Filter po grupaciji K1:" GET cFiltK1 pict "@!S20"
  read; ESC_BCR
  aUsl1:=Parsiraj(cFiltK1,"K1")
  if aUsl1<>NIL; exit; endif
 ENDDO
BoxC()

select os; set order to 5  //idam+idrj+id
if !EMPTY(cFiltK1)
  set filter to &aUsl1
endif
go top

DefIzvjVal()

start print cret
m:="---------- -------- ----------------------------- ------------ ----------- -----------  --------"
P_COND
? "OS: Pregled obracuna amortizacije",PrikazVal(),space(9),"Datum obracuna:",dDatObr
?
? m
? " INV.BR     DatNab     Sredstvo                    Nab. vr        Otp. vr    Amortiz.    Dat.Otp"
? m
?

if  nGStopa<>100
 ?
 ? "Obracun se mnozi sa koeficijentom (%) ",transform(nGStopa,"999.99")
 ?
endif

if !EMPTY(cFiltK1); ? "Filter grupacija K1 pravljen po uslovu: '"+TRIM(cFiltK1)+"'"; endif

private nOstalo:=0,nukupno:=0

do while !eof()

 cIdam:=idam; select amort; hseek cidam; select os
 ? m
 ? "Amortizaciona stopa:",cidam,amort->naz,"  Stopa:",amort->iznos,"%"
 if nGStopa<>100
   ?? " ","efektivno ",transform(round(amort->iznos*nGStopa/100,3),"999.999%")
 endif
 ? m

 private nRGr:=0
 nRGr:=recno()
 nOstalo:=0
 do while !eof() .and. idam==cidam
  Scatter()
  select amort; hseek _idam; select os
  if !empty(_datotp) .and. year(_datotp)<year(ddatobr)    // otpisano sredstvo, ne amortizuj
     skip
     loop
  endif
  IzrAm(_datum,iif(!empty(_datotp),min(dDatOBr,_datotp),dDatObr),nGStopa)     // napuni _amp
  if cAGrupe=="N"
   ? _id,_datum,naz
   @ prow(),pcol()+1 SAY _nabvr*nBBK     pict gpici
   @ prow(),pcol()+1 SAY _otpvr*nBBK     pict gpici
   @ prow(),pcol()+1 SAY _amp*nBBK       pict gpici
   @ prow(),pcol()+1 SAY _datotp    pict gpici
   nUkupno+=round(_amp,2)
  endif
  Gather()
  // amortizacija promjena
  private cId:=_id
  select promj; hseek cid
  do while !eof() .and. id==cid .and. datum<=dDatObr
    Scatter()
    IzrAm(_datum,iif(!empty(_datotp),min(dDatOBr,_datotp),dDatObr),ngStopa)
    if cAGrupe=="N"
      ? space(10),_datum,opis
      @ prow(),pcol()+1 SAY _nabvr*nBBK      pict gpici
      @ prow(),pcol()+1 SAY _otpvr*nBBK      pict gpici
      @ prow(),pcol()+1 SAY _amp*nBBK        pict gpici
      @ prow(),pcol()+1 SAY _datotp    pict gpici
      nUkupno+=round(_amp,2)
    endif
    Gather()
    skip
  enddo  // promjene


  select os
  skip
 enddo   // cidam==idam

 if cAGrupe=="D" //.and. round(nOstalo,2)<>0  // drugi prolaz !!!
   select os
   go nRGr
   do while !eof() .and. idam==cidam
     Scatter()
     if !empty(_datotp)  .and. year(_datotp)<year(dDatobr)    // otpisano sredstvo, ne amortizuj
       skip
       loop
     endif

     if _nabvr>0

       if _nabvr-_otpvr-_amp>0  // ostao je neamortizovani dio
         private nAm2:= min( _nabvr-_otpvr-_amp , nOstalo)
         nOstalo:=nOstalo-nAm2
         _amp:=_amp+nAm2
       endif

     else

       _nabvr:=-_nabvr
       _otpvr:=-_otpvr
       _amp := -_amp
       if _nabvr-_otpvr-_amp > 0  // ostao je neamortizovani dio
         private nAm2:= min(  (_nabvr-_otpvr-_amp) , nOstalo)
         nOstalo:=nOstalo-nAm2
         _amp:=_amp+nAm2
       endif
       _nabvr:=-_nabvr
       _otpvr:=-_otpvr
       _amp := -_amp

     endif

     ? _id,_datum,naz
     @ prow(),pcol()+1 SAY _nabvr*nBBK      pict gpici
     @ prow(),pcol()+1 SAY _otpvr*nBBK      pict gpici
     @ prow(),pcol()+1 SAY _amp*nBBK        pict gpici
     @ prow(),pcol()+1 SAY _datotp     pict gpici
     nUkupno+=round(_amp,2)
     Gather()
     // amortizacija promjena
     private cId:=_id
     select promj; hseek cid
     do while !eof() .and. id==cid .and. datum<=dDatObr
       Scatter()

       if _nabvr>0

         if _nabvr-_otpvr-_amp>0  // ostao je neamortizovani dio
           private nAm2:= min( _nabvr-_otpvr-_amp , nOstalo)
           nOstalo:=nOstalo-nAm2
           _amp:=_amp+nAm2
         endif

       else

         _nabvr:=-_nabvr
         _otpvr:=-_otpvr
         _amp := -_amp
         if _nabvr-_otpvr-_amp>0  // ostao je neamortizovani dio
           private nAm2:= min( _nabvr-_otpvr-_amp , nOstalo)
           nOstalo:=nOstalo-nAm2
           _amp:=_amp+nAm2
         endif
         _nabvr:=-_nabvr
         _otpvr:=-_otpvr
         _amp := -_amp

       endif

       ? space(10),_datum,_opis
       @ prow(),pcol()+1 SAY _nabvr*nBBK    pict gpici
       @ prow(),pcol()+1 SAY _otpvr*nBBK     pict gpici
       @ prow(),pcol()+1 SAY _amp*nBBK       pict gpici
       nUkupno+=round(_amp,2)
       Gather()
       skip
     enddo // promjene

     select os
     skip
   enddo
   ? m
   ? "Za grupu ",cidam,"ostalo je nerasporedjeno",transform(nOstalo*nBBK,gpici)
   ? m
 endif // grupa


enddo  // eof()
? m
?
?
? "Ukupan iznos amortizacije:"
@ prow(),pcol()+1 SAY nukupno*nBBK pict "99,999,999,999,999"
end print
closeret
return
*}


*************************
* d1 - od mjeseca, d2 do
* nostalo se uvecava za onaj dio koji se na
* nekom sredstvu ne moze amortizovati
*************************
function IzrAm(d1,d2,nGAmort)
*{
local nMjesOD,nMjesDo,nIzn, fStorno

  fStorno:=.f.

  IF gVarDio=="D" .and. !EMPTY(gDatDio)
    d1 := MAX( d1 , gDatDio )
  ENDIF

  if year(d1) < year(d2)
    nMjesOd:=1
  else
    //nMjesOd:=iif(day(d1)>1,month(d1)+1,month(d1))
    nMjesOd:=month(d1)+1
  endif
  if day(d2)>=28 .or. gVObracun=="2"
    nMjesDo:=month(d2)+1
  else
    nMjesDo:=month(d2)
  endif
  if _nabvr<0 // stornirani dio
     fStorno:=.t.
     _nabvr:=-_nabvr
     _otpvr:=-_otpvr
  endif

  nIzn:=round(_nabvr * round(amort->iznos * iif(nGamort<>100,nGamort/100,1),3) /100 * (nMjesDo-nMjesOD)/12,2)
  _AMD:=0
  if (_nabvr - _otpvr - nIzn)<0
    _AmP:=_nabvr-_otpvr
    nOstalo+=nizn - (_nabvr-_otpvr)
  else
    _AmP:=nIzn
  endif

  if _amp<0
     _amp:=0
  endif

  if fStorno
    _nabvr:=-_nabvr
    _optvr:=-_otpvr
    _AmP:=-_AmP
  endif
return
*}



function ObrRev()
*{
local  cAGrupe:="D",nRec,dDatObr,nMjesOd,nMjesDo
local nKoef

O_REVAL
O_OS
O_PROMJ

dDatObr:=gDatObr
cFiltK1:=SPACE(40)

Box("#OBRACUN REVALORIZACIJE",3,60)
 DO WHILE .t.
  @ m_x+1,m_y+2 SAY "Datum obracuna:" GET dDatObr
  @ m_x+2,m_y+2 SAY "Filter po grupaciji K1:" GET cFiltK1 pict "@!S20"
  read; ESC_BCR
  aUsl1:=Parsiraj(cFiltK1,"K1")
  if aUsl1<>NIL; exit; endif
 ENDDO
BoxC()

select os; set order to 5
if !EMPTY(cFiltK1)
  set filter to &aUsl1
endif
go top


m:="---------- -------- ---- ---------------------------- ------------- ----------- ----------- ----------- ----------- -------"

DefIzvjVal()

start print cret

P_COND
? "OS: Pregled obracuna revalorizacije",PrikazVal(),space(9),"Datum obracuna:",dDatObr

if !EMPTY(cFiltK1); ? "Filter grupacija K1 pravljen po uslovu: '"+TRIM(cFiltK1)+"'"; endif

? m
? " INV.BR     DatNab  S.Rev     Sredstvo                  Nab.vr      Otp.vr+Am   Reval.DUG    Rev.POT    Rev.Am    Stopa"
? m

nURevDug:=0
nURevPot:=0
nURevAm:=0
do while !eof()
  Scatter()
  if !empty(_datotp)  .and. year(_datotp)<year(dDatobr)    // otpisano sredstvo, ne amortizuj
        skip
        loop
  endif
  select reval; hseek _idrev; select os
  nRevAm:=0
  nKoef:=IzrRev(_datum,iif(!empty(_datotp),min(dDatOBr,_datotp),dDatObr),@nRevAm)     // napuni _revp,_revd
   ? _id,_datum,_idrev,_naz
   @ prow(),pcol()+1 SAY _nabvr*nBBK     pict gpici
   @ prow(),pcol()+1 SAY _otpvr*nBBK+_amp*nBBK     pict gpici
   @ prow(),pcol()+1 SAY _revd*nBBK       pict gpici
   @ prow(),pcol()+1 SAY _revp*nBBK-nRevAm*nBBK  pict gpici
   @ prow(),pcol()+1 SAY nRevAm*nBBK       pict gpici
   @ prow(),pcol()+1 SAY nkoef       pict "9999.999"
   nURevDug+=_revd
   nURevPot+=_revp
   nURevAm+=nRevAm
  Gather()
  private cId:=_id
  select promj; hseek cid
  do while !eof() .and. id==cid .and. datum<=dDatObr
    Scatter()
    nRevAm:=0
    nKoef:=IzrRev(_datum,iif(!empty(_datotp),min(dDatOBr,_datotp),dDatObr),@nRevAm)
    ? space(10),_datum,_idrev,_opis
    @ prow(),pcol()+1 SAY _nabvr*nBBK      pict gpici
    @ prow(),pcol()+1 SAY _otpvr*nBBK+_amp*nBBK pict gpici
    @ prow(),pcol()+1 SAY _revd*nBBK       pict gpici
    @ prow(),pcol()+1 SAY _revp*nBBK-nRevAm*nBBK  pict gpici
    @ prow(),pcol()+1 SAY nRevAm*nBBK       pict gpici
    @ prow(),pcol()+1 SAY nkoef       pict "9999.999"
    nURevDug+=_revd
    nURevPot+=_revp
    nURevAm+=nRevAm
    Gather()
    skip
  enddo

  select os
  skip
enddo
? m
?
?
? "Revalorizacija duguje           :", nURevDug*nBBK
?
? "Revalorizacija otp.vr potrazuje :", nURevPot*nBBK-nURevAm*nBBK
? "Revalorizacija amortizacije     :", nURevAm*nBBK
? "Ukupno revalorizacija potrazuje :", nURevPot*nBBK

? "------------------------------------------------------"
? "UKUPNO EFEKAT REVALORIZACIJE :", nURevDug*nBBK-nURevPot*nBBK
? "------------------------------------------------------"
?
FF
end print
closeret
return
*}



*************************
* d1 - od mjeseca, d2 do
*************************
function IzrRev(d1,d2,nRevAm)
*{
// nRevAm - iznos revalorizacije amortizacije
local nTrecRev
local nMjesOD,nMjesDo,nIzn,nIzn2,nk1,nk2,nkoef

  if year(d1) < year(d2)
    PushWa()
    select reval
    nTrecRev:=recno()
    seek str(year(d1),4)
    if found()
      nMjesOd:=month(d1)+1
      c1:="I"+alltrim(str(nMjesOd-1))
      nk1:=reval->&c1
      nMjesod:=-100
    else
      nMjesOd:=1
    endif
    go nTrecRev // vrati se na tekucu poziciju
    PopWa()
  else
    //nMjesOd:=iif(day(d1)>1,month(d1)+1,month(d1))
    nMjesOd:=month(d1)+1
  endif
  if day(d2)>=28 .or. gVObracun=="2"
    nMjesDo:=month(d2)+1
  else
    nMjesDo:=month(d2)
  endif
  private c1,c2:=""
  c1:="I"+alltrim(str(nMjesOd-1))
  c2:="I"+alltrim(str(nMjesDo-1))
  if nMjesOd<>-100  // ako je -100 onda je vec formiran nK1
   if (nMjesod-1)<1
     nk1:=0
   else
     nk1:=reval->&c1
   endif
  endif

  if (nMjesdo-1)<1
     nk2:=0
  else
     nk2:=reval->&c2
  endif
  nkoef:=(nk2+1)/(nk1+1) - 1
  nIzn :=round( _nabvr * nkoef   ,2)
  nIzn2:=round( (_otpvr+_amp) * nkoef  ,2)
  nRevAm:=round(_amp*nkoef,2)
  _RevD:=nIzn
  _RevP:=nIzn2
  if d2<d1 // mjesdo < mjesod
   _REvd:=0
   _revp:=0
   nkoef:=0
  endif
return nkoef
*}


