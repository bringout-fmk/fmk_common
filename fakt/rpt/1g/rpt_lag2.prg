#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/rpt/1g/rpt_lag2.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.6 $
 * $Log: rpt_lag2.prg,v $
 * Revision 1.6  2003/05/20 07:29:01  mirsad
 * Formatirao duzinu naziva robe za izvjestaje na 40 znakova.
 *
 * Revision 1.5  2002/09/12 13:02:25  mirsad
 * dokumentovanje INI parametara
 *
 * Revision 1.4  2002/07/04 13:40:38  ernad
 *
 *
 * rbr(3 mjesta) -> (4) u prikazu
 *
 * Revision 1.3  2002/07/04 13:35:04  ernad
 *
 *
 * debug: Stanje robe uzima parametre iz lager liste (a oni se ne mogu ispraviti pri pozivu izvjestaja)
 *
 * Revision 1.2  2002/07/04 08:34:19  mirsad
 * dokumentovanje ini parametara
 *
 * Revision 1.1  2002/06/28 20:59:39  ernad
 *
 *
 * razbijanje izvj.prg
 *
 *
 */


/*! \ingroup ini
  * \var *string FmkIni_KumPath_IZVJESTAJI_BezUlaza
  * \brief Da li se na izvjestajima lager-liste i stanja robe prikazuju samo izlazi?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_KumPath_IZVJESTAJI_BezUlaza;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_Svi_SaberiKol
  * \brief Da li se na izvjestajima prikazuje zbir kolicina svih artikala
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_ExePath_Svi_SaberiKol;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_CROBA_GledajFakt
  * \brief Da li se FAKT-dokumenti koriste za utvrdjivanje stanja robe u centralnoj bazi robe CROBA?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_KumPath_CROBA_GledajFakt;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_CROBA_CROBA_RJ
  * \brief Lista radnih jedinica ciji se dokumenti odrazavaju na stanje u centralnoj bazi robe CROBA
  * \param 10#20 - radne jedinice 10 i 20, default vrijednost
  */
*string FmkIni_KumPath_CROBA_CROBA_RJ;



/*! \fn StanjeRobe()
 *  \brief Izvjestaj stanje robe
 */
 
function StanjeRobe()
*{
local fSaberiKol, nKU, nKI
private cidfirma,qqroba,ddatod,ddatdo,nRezerv,nRevers
private nul,nizl,nRbr,cRR,nCol1:=0,nCol0:=50
private m:=""
private nStr:=0
private cProred:="N"
private fCRoba:=.f.
private cRJCR:=IzFmkIni('CROBA','CROBA_RJ','10#20',KUMPATH)

lBezUlaza := ( IzFMKINI("IZVJESTAJI","BezUlaza","N",KUMPATH)=="D" )

O_DOKS
O_TARIFA
O_PARTN
O_SIFK
O_SIFV
O_ROBA
O_RJ
O_FAKT
// idroba
set order to 3 

cIdfirma=gFirma
qqRoba:=""
dDatOd:=ctod("")
dDatDo:=date()
cSaldo0:="N"
qqPartn:=space(20)
private qqTipdok:="  "

Box (,12+IF(lBenjo,3,0)+IF(lPoNarudzbi,2,0),66)
O_PARAMS
private cSection:="5",cHistory:=" "; aHistory:={}
Params1()
RPar("c1",@cIdFirma)
RPar("c2",@qqRoba)
RPar("d1",@dDatOd)
RPar("d2",@dDatDo)

fSaberikol:=(IzFMKIni('Svi','SaberiKol','N')=='D')


if gNW$"DR"
 //cIdfirma:=gFirma
endif
qqRoba:=padr(qqRoba,60)
qqPartn:=padr(qqPartn,20)
qqTipDok:=padr(qqTipDok,2)

cRR:="N"

private cTipVPC:="1"

cK1:=cK2:=space(4)

private cMink:="N"

if lBenjo
  qqTarife:=qqNRobe:=""
  cSort:="S"
endif

do while .t.
 if gNW$"DR"
   @ m_x+1,m_y+2 SAY "RJ (prazno svi) " GET cIdFirma valid {|| empty(cIdFirma) .or. cidfirma==gFirma .or. P_RJ(@cIdFirma) }
 else
  @ m_x+1,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 endif

   @ m_x+2,m_y+2 SAY "Roba   "  GET qqRoba   pict "@!S40"
   @ m_x+3,m_y+2 SAY "Od datuma "  get dDatOd
   @ m_x+3,col()+1 SAY "do"  get dDatDo
   cRR := "N"
   xPos := 4
@ m_x+xPos,m_y+2 SAY "Prikaz stavki sa stanjem 0 (D/N)    "  get cSaldo0 pict "@!" valid cSaldo0 $ "DN"
if gVarC $ "12"
   @ m_x+xPos+1,m_y+2 SAY "Stanje prikazati sa Cijenom 1/2 (1/2) "  get cTipVpc pict "@!" valid cTipVPC $ "12"
endif

if fakt->(fieldpos("K1"))<>0 .and. gDK1=="D"
   @ m_x+xPos+3,m_y+2 SAY "K1" GET  cK1 pict "@!"
   @ m_x+xPos+4,m_y+2 SAY "K2" GET  cK2 pict "@!"
endif

@ m_x+xPos+5,m_y+2 SAY "Prikaz samo kriticnih zaliha (D/N/O) ?" GET cMinK pict "@!" valid cMink$"DNO"
if glDistrib
  cIdDist:=SPACE(6)
  @ m_x+xPos+6,m_y+2 SAY "Distributer (prazno-svi)  "  get cIdDist pict "@!" valid EMPTY(cIdDist).or.P_Firma(@cIdDist)
endif
@ m_x+xPos+7,m_y+2 SAY "Napraviti prored (D/N)    "  get cProred pict "@!" valid cProred $ "DN"

if lBenjo
  qqTarife := PADR( qqTarife , 80 )
  qqNRobe  := PADR( qqNRobe  , 80 )
  @ m_x+xPos+ 8,m_y+2 SAY "Tarife      :" GET qqTarife PICT "@!S30"
  @ m_x+xPos+ 9,m_y+2 SAY "Roba (naziv):" GET qqNRobe  PICT "@!S30"
  @ m_x+xPos+10,m_y+2 SAY "Sortiranje (S-sifra robe/N-naziv robe/T-tarifa/J-jed.mjere)" GET cSort  PICT "@!" VALID cSort$"SNTJ"
endif

if lPoNarudzbi
  qqIdNar := SPACE(60)
  cPKN    := "N"
  @ row()+1,m_y+2 SAY "Uslov po sifri narucioca:" GET qqIdNar PICT "@!S30"
  @ row()+1,m_y+2 SAY "Prikazati kolonu 'narucilac' ? (D/N)" GET cPKN VALID cPKN$"DN" pict "@!"
endif

read

 ESC_BCR

if IzFmkIni('CROBA','GledajFakt','N',KUMPATH)=='D'
  if qqRoba = 'CROBA1284#'
    if pitanje(,'Azurirati u CROBA (D/N)?','N')=='D'
      fCROBA:=.t.
    endif
    qqRoba:=""
  endif
endif


 aUsl1:=Parsiraj(qqRoba,"IdRoba")
 if lBenjo
   aUslT   := Parsiraj(qqTarife,"IdTarifa")
   qqNRobe := TRIM(qqNRobe)
 endif

 if lPoNarudzbi
   aUslN := Parsiraj(qqIdNar,"idnar")
 endif

 if aUsl1<>NIL .and. (!lBenjo.or.aUslT<>NIL) .and.;
    (!lPoNarudzbi.or.aUslN<>NIL)
   exit
 endif
enddo

if cMink=="O"; cSaldo0:="D"; endif

if lBezUlaza
   m:="---- ---------- ----------------------------------------"+IF(lPoNarudzbi.and.cPKN=="D"," ------","")+" ----------- ---"
else
   m:="---- ---------- ----------------------------------------"+IF(lPoNarudzbi.and.cPKN=="D"," ------","")+" ----------- --- --------- -----------"
endif
// endif

SELECT PARAMS
Params2()
qqRoba:=trim(qqRoba)
WPar("c1",cIdFirma)
WPar("c2",qqRoba)
WPar("c7",qqPartn)
WPar("c8",qqTipDok)
WPar("d1",dDatOd)
WPar("d2",dDatDo)
select params; use

BoxC()

fSMark:=.f.
if (right(qqRoba,1)=="*")
  // izvrsena je markacija robe ..
  fSMark:=.t.
endif

select FAKT

if lPoNarudzbi .and. cPKN=="D"
  SET ORDER TO TAG "3N"
endif

private cFilt:=".t."

if glDistrib .and. !EMPTY(cIdDist)
  cFilt += ".and.IDDIST=="+cm2str(cIdDist)
endif

if aUsl1<>".t."
  cFilt+=".and."+aUsl1
endif

if !empty(dDatOd) .or. !empty(dDatDo)
  cFilt+= ".and. DatDok>="+cm2str(dDatOd)+".and. DatDok<="+cm2str(dDatDo)
endif

if lPoNarudzbi .and. aUslN<>".t."
  cFilt+=".and."+aUslN
endif

cTMPFAKT:=""
if lBenjo .and. cSort<>"S"
  Box(,2,30)
   nSlog:=0; nUkupno:=RECCOUNT2()
   cSort1:="SortFakt(IDROBA,'"+cSort+"')"
   INDEX ON &cSort1 TO (cTMPFAKT:=TMPFAKT()) FOR &cFilt EVAL(TekRec2()) EVERY 1
  BoxC()
else
  if cFilt==".t."
   set filter to
  else
   set filter to &cFilt
  endif
endif

go top
EOF CRET

cSintetika:="N"

nKU := nKI := 0

START PRINT CRET

ZaglSrobe()

_cijena:=0

nRbr:=0
nIzn:=0
nRezerv:=nRevers:=0
qqPartn:=trim(qqPartn)
cidfirma:=trim(cidfirma)



nH:=0
if fCRoba
 cSQLFile:="c:\sigma\sql"
 ASQLCRoba(@nH,cSQLFile)
endif

do while !eof()

  if fSMark .and. SkLoNMark("ROBA",SiSiRo()) // skip & loop gdje je roba->_M1_ != "*"
    skip; loop
  endif

  cIdRoba := IdRoba

  if lPoNarudzbi .and. cPKN=="D"
    cIdNar:=idnar
  endif

  nStanjeCR := nUl := nIzl := 0
  nRezerv := nRevers := 0

  do while !eof()  .and. cIdRoba==IdRoba .and.;
           IF(lPoNarudzbi.and.cPKN=="D",cIdNar==idnar,.t.)

    if fSMark .and. SkLoNMark("ROBA",SiSiRo()) // skip & loop gdje je roba->_M1_ != "*"
      skip; loop
    endif

    if !empty(qqTipDok)
      if idtipdok<>qqTipDok
        skip; loop
      endif
    endif

    if !empty(cidfirma)
     if idfirma<>cidfirma; skip; loop; endif
    endif

    if !empty(qqPartn)
     select doks; hseek fakt->(IdFirma+idtipdok+brdok)
     select fakt
     if !(doks->partner=qqPartn)
        skip
	loop
      endif
    endif

    // atributi!!!!!!!!!!!!!
    if !empty(cK1)
       if ck1<>K1
           skip; loop
       endif
    endif
    if !empty(cK2)
       if ck2<>K2
           skip; loop
       endif
    endif

    if !empty(cIdRoba)
    if cRR<>"F"
     if idtipdok="0"  // ulaz
        nUl+=kolicina
        if idfirma$cRJCR
          nStanjeCR += kolicina
        endif
        if fSaberikol .and. !( roba->K2 = 'X')
             nKU+=kolicina
        endif
     elseif idtipdok="1"   // izlaz faktura
       if !(serbr="*" .and. idtipdok=="10") // za fakture na osnovu optpremince ne ra~unaj izlaz
         if idfirma$cRJCR
           nStanjeCR -= kolicina
         endif
         nIzl+=kolicina
         if fSaberikol .and. !( roba->K2 = 'X')
           nKI+=kolicina
         endif
       endif
     elseif idtipdok$"20#27"
        if serbr="*"
          nRezerv+=kolicina
          if idfirma$cRJCR
            nStanjeCR -= kolicina
          endif
          if fSaberikol .and. !( roba->K2 = 'X')
             nKI+=kolicina
          endif
        endif
     elseif idtipdok=="21"
        nRevers+=kolicina
        if idfirma$cRJCR
          nStanjeCR -= kolicina
        endif
        if fSaberikol .and. !( roba->K2 = 'X')
             nKI+=kolicina
        endif
     endif
    else
     if (serbr="*" .and. idtipdok=="10") // za fakture na osnovu otpremince ne ra~unaj izlaz
       nIzl+=kolicina
       if fSaberikol .and. !( roba->K2 = 'X')
         nKI+=kolicina
       endif
     endif
    endif // crr=="F"
    endif  // empty(
    skip
  enddo

  if !empty(cIdRoba)
   NSRNPIdRoba(cIdRoba, cSintetika=="D" )
   SELECT ROBA
   if (fieldpos("MINK"))<>0
      nMink:=roba->mink
   else
      nMink:=0
   endif
   SELECT FAKT
   if prow()>61-iif(cProred="D",1,0); ZaglSRobe(); endif

   if (cMink<>"D" .and. (cSaldo0=="D" .or. round(nUl-nIzl,4)<>0)) .or. ; //ne prikazuj stavke 0
      (cMink=="D" .and. nMink<>0 .and. (nUl-nIzl-nMink)<0)

     if cMink=="O" .and. nMink==0 .and. round(nUl-nIzl,4)==0
       loop
     endif

     if lBenjo
       if !( ROBA->(&aUslT) .and. ROBA->naz=qqNRobe )
         loop
       endif
     endif

     if cProred=="D"
       ? space(gnLMarg); ?? m
     endif
     if cMink=="O" .and. nMink<>0 .and. (nUl-nIzl-nMink)<0
        B_ON
     endif
     ? space(gnLMarg); ?? str(++nRbr,4),cidroba,PADR(ROBA->naz,40)

     if lPoNarudzbi .and. cPKN=="D"
       ?? "", cIdNar
     endif

     nCol0:=pcol()-11

     if fSaberiKol .and. lBezUlaza
       nCol1:=pcol()+1
     endif
     @ prow(),pcol()+1 SAY nUl-nIzl pict pickol
     @ prow(),pcol()+1 SAY roba->jmj
     if cTipVPC=="2" .and.  roba->(fieldpos("vpc2")<>0)
       _cijena:=roba->vpc2
     else
       _cijena := if ( !EMPTY(cIdFirma) , UzmiMPCSif(), roba->vpc )
     endif

     if !lBezUlaza
       @ prow(),pcol()+1 SAY _cijena  pict "99999.999"
       nCol1:=pcol()+1
       @ prow(),nCol1 SAY (nUl-nIzl)*_cijena   pict picdem
     endif

     nIzn+=(nUl-nIzl)*_cijena

     if cMink<>"N" .and. nMink>0
      ?
      @ prow(),ncol0    SAY padr("min.kolic:",len(pickol))
      @ prow(),pcol()+1 SAY nMink  pict pickol
     endif

     if cMink=="O" .and. nMink<>0 .and. (nUl-nIzl-nMink)<0
        B_OFF
     endif
   endif

   if cRR<>"F" .and. fCROBA
     ASQLCRoba(@nH,"#CONT",cIdroba, 'V', '0',nStanjeCR)
   endif

  endif

enddo

if prow()>59; ZaglSRobe(); endif

if !lBezUlaza
  ? space(gnLMarg); ?? m
  ? space(gnLMarg); ?? " Ukupno:"
  @ prow(),nCol1 SAY nIzn  pict picdem
endif

? space(gnLMarg); ?? m

if fSaberikol
? space(gnLMarg); ?? " Ukupno (kolicine):"
 @ prow(),nCol1    SAY nKU-nKI   picture pickol
endif
? space(gnLMarg); ?? m
FF

END PRINT
CLOSE ALL; MyFERASE(cTMPFAKT)


if fCRoba
  MsgO("Azuriram SQL-CROBA")
    ASQLCRoba(@nH,"#END#"+cSQLFile)
  MsgC()
endif

CLOSERET
return
*}


/*! \fn ZaglSRobe()
 *  \brief Zaglavlje izvjestaja stanje robe
 */
 
function ZaglSRobe()
*{
if nstr>0; FF; endif
P_COND
? space(4), "FAKT: "
?? "Stanje"
?? " robe na dan", date(), "      za period od", dDatOd, "-", dDatDo,space(6),"Strana:",str(++nStr,3)

?
if cRR=="D"
  P_COND2
else
  P_COND
endif

? space(gnLMarg); IspisFirme(cidfirma)
if !empty(qqRoba)
  ? space(gnLMarg)
  ?? "Roba:",qqRoba
endif

if !empty(cK1)
  ?
  ? space(gnlmarg), "- Roba sa osobinom K1:",ck1
endif
if !empty(cK2)
  ?
  ? space(gnlmarg), "- Roba sa osobinom K2:",ck2
endif

if glDistrib .and. !empty(cIdDist)
  ?
  ? space(gnlmarg), "- kontrola distributera:",cIdDist
endif

if lPoNarudzbi .and. !EMPTY(qqIdNar)
  ?
  ? "Prikaz za sljedece narucioce:",TRIM(qqIdNar)
endif

?
if cTipVPC=="2" .and.  roba->(fieldpos("vpc2")<>0)
  ? space(gnlmarg)
  ?? "U CJENOVNIKU SU PRIKAZANE CIJENE: "+cTipVPC
endif
?
? space(gnLMarg)
?? m
? space(gnLMarg)
if lBezUlaza
   ?? "R.br  Sifra       Naziv                                 "+IF(lPoNarudzbi.and.cPKN=="D","Naruc. ","")+"   Stanje    jmj     "
else
   ?? "R.br  Sifra       Naziv                                 "+IF(lPoNarudzbi.and.cPKN=="D","Naruc. ","")+"   Stanje    jmj     "+IF(RJ->tip$"M1#M2".and.!EMPTY(cIdFirma),"Cij.","VPC ")+"      Iznos"
endif
// endif

? space(gnLMarg)
?? m
return
*}


