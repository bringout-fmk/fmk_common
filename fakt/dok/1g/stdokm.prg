#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/dok/1g/stdokm.prg,v $
 * $Author: sasa $ 
 * $Revision: 1.2 $
 * $Log: stdokm.prg,v $
 * Revision 1.2  2002/06/18 13:01:05  sasa
 * no message
 *
 * Revision 1.1.1.1  2002/06/17 18:30:18  ernad
 * no message
 *
 *
 */
 
/*! \file fmk/fakt/dok/1g/stdokm.prg
 *  \brief 
 */




/*! \fn StDokM()
 *  \brief
 *  \param cIdFirma
 *  \param cIdTipDok
 *  \param cBrDok
 */

function StDokM()
*{
parameters cIdFirma,cIdTipDok,cBrDok
PRIVATE aZagl:={}, aZagl2:={}, aKol:={}, aPodn:={}, yKor:=0

if pcount()==3
 O_Edit(.t.)
else
 O_Edit()
endif

select PRIPR
if pcount()==0  // poziva se faktura iz pripreme
 IF gNovine=="D"
   FilterPrNovine()
 ENDIF
 cIdTipdok:=idtipdok;cIdFirma:=IdFirma;cBrDok:=BrDok
endif
seek cidfirma+cidtipdok+cbrdok
NFOUND CRET

aDbf:={ {"POR","C",10,0},;
          {"IZNOS","N",17,8} ;
         }
dbcreate2(PRIVPATH+"por",aDbf)
O_POR   // select 95
index  on BRISANO TAG "BRISAN"
index  on POR  TAG "1" ;  set order to tag "1"
select pripr

dDatDok:=DatDok
cidpartner:=Idpartner

cTxt1:=""
cTxt2:=""
cTxt3a:=""
cTxt3b:=""
cTxt3c:=""

_BrOtp:=space(8); _DatOtp:=ctod(""); _BrNar:=space(8); _DatPl:=ctod("")

if val(podbr)=0  .and. val(rbr)==1
   aMemo:=ParsMemo(txt)
   if len(aMemo)>0
     cTxt1:=padr(aMemo[1],40)
   endif
   if len(aMemo)>=5
    cTxt2:=aMemo[2]
    cTxt3a:=aMemo[3]
    cTxt3b:=aMemo[4]
    cTxt3c:=aMemo[5]
   endif
   if len(aMemo)>=9
    _BrOtp:=aMemo[6]; _DatOtp:=ctod(aMemo[7]); _BrNar:=amemo[8]; _DatPl:=ctod(aMemo[9])
   endif
else
  Beep(2)
  Msg("Prva stavka mora biti  '1.'  ili '1 ' !",4)
  return
endif

nUk:=0
nRab:=0
nZaokr:=ZAOKRUZENJE
cDinDEM:=dindem

O_FADO
O_FADE

SELECT FADO
SEEK cIdTipDok

SELECT FADE
SET FILTER TO ID==cIdTipDok
SET ORDER TO TAG "SXY"
GO TOP

// -----------------------------------
// ZAGLAVLJE1: PODACI O MATICNOJ FIRMI
// -----------------------------------
DO WHILE !EOF() .and. sekcija=="A"
  AADD(aZagl,trim(formula))
  SKIP 1
ENDDO

// --------------------------------------------------------
// ZAGLAVLJE2: PODACI O PARTNERU, BROJ I DATUM DOKUMENTA...
// --------------------------------------------------------
DO WHILE !EOF() .and. sekcija=="B"
  AADD(aZagl2,{kx,ky,TRIM(tipslova),TRIM(formula)})
  SKIP 1
ENDDO

// --------------------------------------------------------
// TABELA: RBR, SIFRA, NAZIV, JMJ, KOLICINA, CIJENA, ...
// --------------------------------------------------------
i:=0
DO WHILE !EOF() .and. sekcija=="C"
  cPom:="{|| "+TRIM(formula)+" }"
  AADD(aKol,{ TRIM(opis), &cPom., (sumirati=="D"), TRIM(tipkol) , sirkol, sirdec, 1, ++i})
  SKIP 1
ENDDO

// --------------------------------------------------------
// PODNO¦JE: UKUPNO, SLOVIMA, NAPOMENA, U POTPISU, ...
// --------------------------------------------------------
DO WHILE !EOF() .and. sekcija=="D"
  AADD(aPodn,{kx,ky,TRIM(tipslova),TRIM(formula)})
  SKIP 1
ENDDO

SELECT PRIPR

PRIVATE nCijena:=0, cRab:="", cPor:="", nIznosS:=0, nCijBezRab:=0

POCNI STAMPU

IspisiZaglavlje()

StampaTabele(aKol,{|| UkupneVrijednosti()},gnLMarg,gTabela,{|| idfirma==cidfirma .and. idtipdok==cidtipdok .and. brdok==cbrdok},;
             .t.,,,1,.f.,.f.,,,,.f.,{|| IspisiZaglavlje()})

IspisiPodnozje()

ZAVRSI STAMPU

CLOSERET
*}


/*! \fn UkupneVrijednosti()
 *  \brief 
 */
 
function UkupneVrijednosti()
*{
NSRNPIdRoba()   // Nastimaj (hseek) Sifr.Robe Na Pripr->IdRoba
   if alltrim(podbr)=="."   .or. roba->tip="U"
      aMemo:=ParsMemo(txt)
      cTxt1:=padr(aMemo[1],40)
   endif
   if roba->tip="U"
      cTxtR:=aMemo[1]
   endif
   if alltrim(podbr)=="."
    cSifra:=BLANK(idroba)
    if cTI=="2"
       nRec:=recno()
       cRbr:=Rbr
       nUk2:=nRab2:=nPor2:=0
       do while !eof() .and. idfirma+idtipdok+brdok==cidfirma+cidtipdok+cbrdok.and. Rbr==cRbr
        if podbr=" ."
          skip; loop
        endif
        nUk2+=round(kolicina*cijena*PrerCij()*Koef(cDinDem),nZaokr)
        nRab2+=round(cijena*kolicina*PrerCij()*rabat/100*Koef(cDinDem),nZaokr)
        nPor2+=round(kolicina*cijena*PrerCij()*(1-rabat/100)*Porez/100*Koef(cDinDem),nZaokr)
        skip
       enddo
       nPorez:=nPor2/(nUk2-nRab2)*100
       go nRec
       if nRab2*100/nUk2-int(nRab2*100/nUk2) <> 0
         cRab:=str(nRab2*100/nUk2,5,2)
       else
         cRab:=str(nRab2*100/nUk2,5,0)
       endif
       if nporez-int(nporez)<>0
         cPor:=str(nporez,3,1)
       else
         cPor:=str(nporez,3,0)
       endif
       if nPor2<>0
         select por
         if roba->tip="U"
           cPor:="PPU "+ str(nPorez,5,2)+"%"
         else
           cPor:="PPP "+ str(nPorez,5,2)+"%"
         endif
         seek cPor
         if !found(); append blank; replace por with cPor ; endif
         replace iznos with iznos+nPor2
         select pripr
       endif
       nCijena:=IF(kolicina<>0,nUk2/kolicina,0)
       nIznosS:=nUk2
    endif //tip=="2" - prikaz vrijednosti u . stavci
   else   // podbr nije "."
     if idtipdok$"11#27"  // maloprodaja
       select tarifa; hseek roba->idtarifa
       nMPVBP:=round( pripr->(cijena*Koef(cDinDem)*PrerCij()*kolicina)/(1+tarifa->ppp/100)/(1+tarifa->opp/100) , nZaokr)
       if tarifa->opp<>0
         select por
         seek "PPP "+str(tarifa->opp,6,2)
         if !found(); append blank; replace por with "PPP "+str(tarifa->opp,6,2) ;endif
         replace iznos with iznos+nMPVBP*tarifa->opp/100
       endif
       if tarifa->ppp<>0
         select por
         seek "PPU "+str(tarifa->ppp,6,2)
         if !found(); append blank; replace por with "PPU "+str(tarifa->ppp,6,2); endif
         replace iznos with iznos+nMPVBP*(1+tarifa->opp/100)*tarifa->ppp/100
       endif
        select pripr
     endif
    aSbr:=Sjecistr(serbr,10)
    if roba->tip="U"
      aTxtR:=SjeciStr(aMemo[1],iif(gVarF $ "13".and.!idtipdok$"11#27",51,40-IF(gNW=="R".and.idtipdok$"11#27",6,0)))   // duzina naziva + serijski broj
    else
      aTxtR:=SjeciStr(trim(roba->naz)+Katbr(),40-IF(gNW=="R".and.idtipdok$"11#27",6,0))
    endif
    if porez-int(porez)<>0
        cPor:=str(porez,3,1)
    else
        cPor:=str(porez,3,0)
    endif
    cSifra:=idroba
//    @ prow(),nCTxtR SAY aTxtR[1]
    if !cidtipdok$"11#27"
      if !(roba->tip="U") .and. gVarF $ "13"
//        @ prow(),pcol()+1 SAY aSbr[1]
      endif
    else
      IF gNW=="R"
//        @ prow(),pcol()+1 SAY PADR(ALLTRIM(serbr),5)
      ENDIF
//      @ prow(),pcol()+1 SAY roba->idtarifa
      select tarifa;hseek roba->idtarifa
//      @ prow(),pcol()+1 SAY tarifa->opp pict "9999.9%"
//      @ prow(),pcol()+2 SAY tarifa->ppp pict "999.9%"
      select pripr
    endif
//    @ prow(),pcol()+1 SAY kolicina pict pickol
//    @ prow(),pcol()+1 SAY lower(ROBA->jmj)
    if empty(podbr) .or. (!empty(podbr) .and. cTI=="1")
           nCijena:=cijena*Koef(cDinDem)
//           @ prow(),pcol()+1 SAY cijena*Koef(cDinDem) pict piccdem
           if rabat-int(rabat) <> 0
               cRab:=str(rabat,5,2)
           else
              cRab:=str(rabat,5,0)
           endif
           if !cidtipdok$"11#27"
             if !(gVarF=="3" .and. cidtipdok=="12")
//               @ prow(),pcol()+1 SAY cRab+"%"
             endif
             if gVarF=="2"
               nCijBezRab:=cijena*(1-rabat/100)*Koef(cDinDem)
//               @ prow(),pcol()+1 SAY cijena*(1-rabat/100)*Koef(cDinDem)  pict piccdem
             endif
             if porez-int(porez)<>0
               cPor:=str(porez,3,1)
             else
               cPor:=str(porez,3,0)
             endif
             if !(gVarF=="3" .and. cidtipdok=="12")
//               @ prow(),pcol()+1 SAY cPor+"%"
             endif
           else
             //@ prow(),pcol()+1 SAY space(6)
           endif
           nCol1:=pcol()+1
           nIznosS:=round( kolicina*cijena*Koef(cDinDem)*PrerCij(), nZaokr)
//           @ prow(),pcol()+1 SAY round( kolicina*cijena*Koef(cDinDem)*PrerCij(), nZaokr) pict picdem
           nPor2:=round( kolicina*Koef(cDinDem)*PrerCij()*cijena*(1-rabat/100)*Porez/100, nZaokr)
             for i:=2 to len(aTxtR)
//               @ prow()+1,nCTxtR  SAY aTxtR[i]
             next
           if nPor2<>0
              select por
              if roba->tip="U"
               cPor:="PPU "+ str(pripr->Porez,5,2)+"%"
              else
               cPor:="PPP "+ str(pripr->Porez,5,2)+"%"
              endif
              seek cPor
              if !found(); append blank; replace por with cPor ;endif
              replace iznos with iznos+nPor2
              select pripr
           endif
    endif
    nUk+=round(PrerCij()*kolicina*cijena*Koef(cDinDem),nZaokr)
    altd()
    nRab+=round( Cijena*kolicina*PrerCij()*Rabat/100 , nZaokr)
   endif
return .t.
*}



/*! \fn IspisiZaglavlje()
 *  \brief Ispisuje zaglavlje
 */
 
function IspisiZaglavlje()
*{
LOCAL i:=0
 P_10CPI
 if gBold=="1"; B_ON; endif
 FOR i:=1 TO LEN(aZagl)
   StZaglav2(aZagl[i],PRIVPATH)
 NEXT
 xKA:=prow()
 FOR i:=1 TO LEN(aZagl2)
   //  aZagl2 : { kx , ky , tipslova , formula }
   cPom:=aZagl2[i,4]
   MSay( &cPom , aZagl2[i,1] , aZagl2[i,2] , aZagl2[i,3] )
 NEXT
 for i:=1 to gOdvT2; ?; next
RETURN
*}

/*! \fn IspisiPodnozje()
 *  \brief Ispisuje podnozje
 */
 
function IspisiPodnozje()
*{
xKA:=prow()
 FOR i:=1 TO LEN(aPodn)
   //  aPodn : { kx , ky , tipslova , formula }
   cPom:=aPodn[i,4]
   MSay( &cPom , aPodn[i,1] , aPodn[i,2] , aPodn[i,3] )
 NEXT
 if gBold=="1"; B_OFF; endif
 FF
RETURN
*}



/*! \fn MSay(cTxt,x,y,cKod)
 *  \brief 
 *  \param cTxt
 *  \param x
 *  \param y
 *  \param cKod
 */
 
function MSay(cTxt,x,y,cKod)
*{
STATIC nLine:=0
  IF nLine<>x; yKor:=0; ENDIF
  @ xKA+x,y+ykor SAY ""
  yKor += PljuniKod(cKod); QQOUT(cTxt); yKor+=LiziKod(cKod)
  nLine:=x
RETURN


/*! \fn PljuniKod(cKod)
 *  \brief Daje neke sekvence stampaca...
 *  \param cKod
 */
 
function PljuniKod(cKod)
*{
LOCAL i:=0, nKol:=PCOL()
  FOR i:=1 TO LEN(cKod)
    DO CASE
      CASE SUBSTR(cKod,i,1)=="U"
         gPU_ON()
      CASE SUBSTR(cKod,i,1)=="I"
         gPI_ON()
      CASE SUBSTR(cKod,i,1)=="B"
         gPB_ON()
    ENDCASE
  NEXT
RETURN (PCOL()-nKol)
*}


/*! \fn LiziKod(cKod)
 *  \brief Nesto lize
 *  \param cKod
 */
 
function LiziKod(cKod)
*{
LOCAL i:=0, nKol:=PCOL()
  FOR i:=1 TO LEN(cKod)
    DO CASE
      CASE SUBSTR(cKod,i,1)=="U"
         gPU_OFF()
      CASE SUBSTR(cKod,i,1)=="I"
         gPI_OFF()
      CASE SUBSTR(cKod,i,1)=="B"
         gPB_OFF()
    ENDCASE
  NEXT
RETURN (PCOL()-nKol)
*}


/*! \fn MjestIDat()
 *  \brief 
 */
 
function MjestIDat()
*{
RETURN ( padl(Mjesto(cIdFirma)+", "+dtoc(ddatdok)+" godine",39) )
*}

