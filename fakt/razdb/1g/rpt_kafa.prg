#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/razdb/1g/rpt_kafa.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.5 $
 * $Log: rpt_kafa.prg,v $
 * Revision 1.5  2003/01/21 15:01:58  ernad
 * probelm excl fakt - kalk ?! direktorij kalk
 *
 * Revision 1.4  2003/01/21 13:28:23  ernad
 * korekcije direktorij
 *
 * Revision 1.3  2002/07/05 13:01:02  ernad
 *
 *
 * debug: varijanta za vise konta je "1N"
 *
 * Revision 1.2  2002/07/05 08:23:07  ernad
 *
 *
 * parametar ExePath/Fakt_specif/Fakt_Kalk -> KumPath/Fakt/FaktKalk
 *
 * Revision 1.1  2002/07/05 08:03:02  ernad
 *
 *
 * Izjestaj usporednog prikaza kalk <-> fakt prebacen u razdb iz izvj.prg
 *
 *
 */
 
/*! \fn Fakt_Kalk(lFaktKalk)
 *  \brief Uporedni prikaz stanja Kalk<->Fakt 
 *  \param lFaktKalk
 */
 
function Fakt_Kalk(lFaktFakt)
*{
local cIdFirma,qqRoba,nRezerv,nRevers
local nul,nizl,nRbr,cRR,nCol1:=0
local m:=""
local cDirFakt, cDirKalk

local cViseKonta
private dDatOd, dDatDo
private gDirKalk := ""
private cOpis1:=PADR("F A K T",12)
private cOpis2:="FAKT 2.FIRMA"

if lFaktFakt==nil
	lFaktFakt:=.f.
endif

O_DOKS
O_KONTO
O_TARIFA
O_SIFK
O_SIFV
O_ROBA
O_RJ


O_FAKT
// idroba
set order to 3


cKalkFirma:=gFirma
cIdfirma:=gFirma

//direktorij kumulativ FAKT-a
cF2F:=PADR(ToUnix("C:\SIGMA\FAKT\KUM1\"),40)

cF2FS:=PADR(TRIM(goModul:oDatabase:cDirSif)+SLASH,40)
qqRoba:=""
dDatOd:=ctod("")
dDatDo:=date()
cRazlKol := "D"
cRazlVr  := "D"
cMP := "M"

cViseKonta:=IzFmkIni("FAKT_Specif","Fakt_Kalk","11", nil, .f.)
//prebacujem ovaj parametar na KumPath
if EMPTY(cViseKonta)
	cViseKonta:="11"
endif
cViseKonta:=IzFmkIni("FAKT","FaktKalk", cViseKonta, KUMPATH)

lViseKonta:=.f.

if cViseKonta=="1N"
	lViseKonta:=.t.
endif

if lViseKonta
  cIdKonto := qqKonto := "1310 ;"
else
  cIdKonto := qqKonto := "1310   "
endif
*
qqPartn:=space(20)
private qqTipdok:="  "

Box(,16,66)
O_PARAMS
private cSection:="6"
private cHistory:=" "
private aHistory:={}
Params1()
RPar("U1",@cIdFirma)
RPar("U2",@qqRoba)
RPar("U3",@dDatOd)
RPar("U4",@dDatDo)
RPar("U5",@cRazlKol)
RPar("U6",@cRazlVr)
RPar("U7",@cMP)
RPar("U8",@qqKonto)
RPar("U9",@cKalkFirma)
RPar("t1",@cOpis1)
RPar("t2",@cOpis2)
RPar("fd",@cF2F)

//RPar("fs",@cF2FS)
cSection:="T"
cHistory:=" "
aHistory:={}

//RPar("dk",@gDirKalk)
if empty(gDirKalk)
  gDirKalk:=trim(StrTran(goModul:oDatabase:cDirKum,"FAKT","KALK"))+"\"
  WPar("dk",gDirKalk)
//elseif .t.
endif
cSection:="6"
cHistory:=" "
aHistory:={}


if lFaktFakt
  if Pitanje(,"Podesiti direktorij FAKT-a druge firme? (D/N)","N")=='D'
    Box(,6,70)
     @ m_x+1, m_y+2 SAY "Kum.dir.drugog FAKT-a:" GET cF2F  PICT "@!"
     @ m_x+2, m_y+2 SAY "Sif.dir.drugog FAKT-a:" GET cF2FS PICT "@!"
     @ m_x+3, m_y+2 SAY "Zaglavlje stanja u FAKT:" GET cOpis1 PICT "@!"
     @ m_x+4, m_y+2 SAY "Zaglav.st.FAKT 2.firme :" GET cOpis2 PICT "@!"
     READ
    BoxC()
  endif
endif


if gNW$"DR"
 //cIdfirma:=gFirma
endif
qqRoba:=padr(qqRoba,60)
qqKonto:=padr(qqKonto,IF(lViseKonta,60,7))
qqPartn:=padr(qqPartn,20)
qqTipDok:=padr(qqTipDok,2)

cRR:="N"

private cTipVPC:="1"


cK1:=cK2:=space(4)

do while .t.
  if lFaktFakt
    @ m_x+1,m_y+2 SAY "RJ" GET cIdFirma valid cidfirma==gFirma .or. P_RJ(@cIdFirma)
    @ m_x+3,m_y+2 SAY "RJ u FAKT druge firme"  GET cKalkFirma pict "@!S40"
    @ m_x+4,m_y+2 SAY "Roba   "  GET qqRoba   pict "@!S40"
    @ m_x+5,m_y+2 SAY "Od datuma"  get dDatOd
    @ m_x+5,col()+1 SAY "do datuma"  get dDatDo
    cRazlKol:="D"
    cRazlVr:="N"
  else
    @ m_x+1,m_y+2 SAY "RJ" GET cIdFirma valid cidfirma==gFirma .or. P_RJ(@cIdFirma)
    if lViseKonta
      @ m_x+2,m_y+2 SAY "Konto u KALK"  GET qqKonto ;
                        WHEN  {|| cIdKonto:=KontoIzRj (cIdFirma), qqKonto:=Iif (!Empty(cIdKonto),cIdKonto+" ;",qqKonto), .T.} PICT "@!S20"
    else
      @ m_x+2,m_y+2 SAY "Konto u KALK"  GET qqKonto ;
                        WHEN  {|| cIdKonto:=KontoIzRj (cIdFirma), qqKonto:=Iif (!Empty(cIdKonto),cIdKonto,qqKonto), .T.} ;
                        VALID P_Konto (@qqKonto)
    endif
    @ m_x+3,m_y+2 SAY "Oznaka firme u KALK"  GET cKalkFirma pict "@!S40"
    @ m_x+4,m_y+2 SAY "Roba   "  GET qqRoba   pict "@!S40"
    @ m_x+5,m_y+2 SAY "Od datuma"  get dDatOd
    @ m_x+5,col()+1 SAY "do datuma"  get dDatDo
    @ m_x+6,m_y+2 SAY "Prikazi ako se razlikuju kolicine (D/N)" GET cRazlKol pict "@!" VALID cRazlKol $ "DN"
    @ m_x+7,m_y+2 SAY "Prikazi ako se razlikuju vrijednosti (D/N)" GET cRazlVr pict "@!" VALID cRazlVr $ "DN"
    if gVarC $ "12"
      @ m_x+9,m_y+2 SAY "Stanje u FAKT prikazati sa Cijenom 1/2 (1/2) "  get cTipVpc pict "@!" valid cTipVPC $ "12"
    endif

    if fakt->(fieldpos("K1"))<>0 .and. gDK1=="D"
     @ m_x+10,m_y+2 SAY "K1" GET  cK1 pict "@!"
     @ m_x+10,m_y+2 SAY "K2" GET  cK2 pict "@!"
    endif
  endif

  read
  ESC_BCR
  aUsl1:=Parsiraj(qqRoba,"IdRoba")
  if lViseKonta
    aUsl2:=Parsiraj(qqKonto,"MKONTO")
    if aUsl1<>nil .and. (lFaktFakt .or. aUsl2<>nil); exit; endif
  else
    if aUsl1<>nil
    	exit
    endif
  endif
enddo

cSintetika:="N"

Params2()
if lViseKonta
  qqKonto:=TRIM(qqKonto)
endif
qqRoba:=trim(qqRoba)
WPar("U1",@cIdFirma)
WPar("U2",@qqRoba)
WPar("U3",@dDatOd)
WPar("U4",@dDatDo)
WPar("U5",@cRazlKol)
WPar("U6",@cRazlVr)
WPar("U7",@cMP)
WPar("U8",@qqKonto)
WPar("U9",@cKalkFirma)
WPar("fd",@cF2F)
WPar("fs",@cF2FS)
WPar("t1",@cOpis1)
WPar("t2",@cOpis2)
select params; use

if lFaktFakt
  //fakt-fakt uporedi
  cDirFakt:=SezRad(TRIM(cF2F))
  USE (cDirFakt+"FAKT") ALIAS KALK NEW
  SET ORDER to TAG "3"
  if TRIM(cF2FS) != TRIM(goModul:oDataBase:cDirSif)
    USE (SezRad(TRIM(cF2FS))+"ROBA") ALIAS ROBA2 NEW
  endif
  
else

	cDirKalk:=PADR(SezRad(gDirKalk),60)
	Box(,2,60)
	//@ m_x+1, m_y+2 SAY "Fakt kum:" GET cDirFakt  PICTURE "@S40"
	@ m_x+1, m_y+2 SAY "Kalk kum:" GET cDirKalk  PICTURE "@S40"
	READ
	BoxC()
	
	cDirKalk:=ALLTRIM(cDirKalk)

	//fakt-kalk uporedi
	USE (cDirKalk+"KALK")
endif

aDbf := {}
AADD (aDbf, {"IdRoba", "C", 10, 0})
AADD (aDbf, {"FST",    "N", 15, 5})
AADD (aDbf, {"FVR",    "N", 15, 5})
AADD (aDbf, {"KST",    "N", 15, 5})
AADD (aDbf, {"KVR",    "N", 15, 5})
DBCREATE2 (PRIVPATH+"POM", aDbf)

USE (PRIVPATH+"POM") NEW
Index On IdRoba to (PRIVPATH+"POMi1")
SET INDEX to (PRIVPATH+"POMi1")
BoxC()

select FAKT

private cFilt1:=""
cFilt1 := aUsl1+IF(EMPTY(dDatOd),"",".and.DATDOK>="+cm2str(dDatOd))+;
                IF(EMPTY(dDatDo),"",".and.DATDOK<="+cm2str(dDatDo))
cFilt1 := STRTRAN(cFilt1,".t..and.","")

if !(cFilt1==".t.")
  SET FILTER to &cFilt1
else
  SET FILTER TO
endif


*
* samo da pozicioniram RJ
*
SELECT RJ
HSEEK cIdFirma


select KALK

private cFilt2:=""

if !lFaktFakt .and. lViseKonta
  if ! RJ->(Found()) .or. Empty (RJ->Tip) .or. RJ->Tip="V"
    // veleprodajna cijena u FAKT, uzimam MKONTO u KALK
    cTipC := "V"
  else
    // u suprotnom, uzimam PKONTO
    aUsl2:=Parsiraj(qqKonto,"PKONTO")
    cTipC := "M"
  endif
endif

cFilt2 := aUsl1+IF(EMPTY(dDatOd),"",".and.DATDOK>="+cm2str(dDatOd))+;
                IF(EMPTY(dDatDo),"",".and.DATDOK<="+cm2str(dDatDo))
if !lFaktFakt .and. lViseKonta
  cFilt2 += ".and."+aUsl2+".and.IDFIRMA=="+cm2str(cKalkFirma)
  set order to tag "7"
endif

cFilt2 := STRTRAN(cFilt2,".t..and.","")

if !(cFilt2==".t.")
  SET FILTER to &cFilt2
else
  SET FILTER TO
endif

SELECT FAKT
go top
FaktEof := EOF()

SELECT KALK
GO TOP
KalkEof := EOF()

if FaktEof .and. KalkEof
  Beep (3)
  Msg ("Ne postoje trazeni podaci")
  CLOSERET
endif

START PRINT CRET
SELECT FAKT
do while ! Eof()
  cIdRoba:=IdRoba
  nSt := nVr :=0
  While !eof() .and. cIdRoba==IdRoba
    if idfirma<>cidfirma
    	skip
	loop
    endif
    // atributi!!!!!!!!!!!!!
    if !empty(cK1)
      if ck1<>K1
      	skip
	loop
      endif
    endif
    if !empty(cK2)
      if ck2<>K2
      	skip
	loop
      endif
    endif

    if !empty(cIdRoba)
      if idtipdok="0"  // ulaz
         nSt += kolicina
         ** nVr += Kolicina*Cijena
      elseif idtipdok="1"   // izlaz faktura
        if !(serbr="*" .and. idtipdok=="10") // za fakture na osnovu optpremince ne ra~unaj izlaz
           nSt -= kolicina
           ** nVr -= Kolicina*Cijena
        endif
      endif
    endif  // empty(
    skip
  enddo
  if !empty(cIdRoba)
    NSRNPIdRoba(cIdRoba, cSintetika=="D")
    SELECT ROBA
    if cTipVPC=="2" .and.  roba->(fieldpos("vpc2")<>0)
          _cijena:=roba->vpc2
    else
      _cijena := if ( !EMPTY(cIdFirma) , UzmiMPCSif(), roba->vpc )
    endif
    SELECT POM
    APPEND BLANK
    REPLACE IdRoba WITH cIdRoba, FST WITH nSt, FVR WITH nSt*_cijena
    SELECT FAKT
  endif
enddo

//  zatim prodjem KALK (jer nesto moze biti samo u jednom)
SELECT KALK
if lFaktFakt
  GO TOP
  While ! Eof()
    cIdRoba:=IdRoba
    nSt := nVr :=0
    While !eof() .and. cIdRoba==IdRoba
      	if idfirma<>cKalkFirma
      		skip
		loop
	endif
      // atributi!!!!!!!!!!!!!
      if !empty(cK1)
        if ck1<>K1; skip; loop; endif
      endif
      if !empty(cK2)
        if ck2<>K2; skip; loop; endif
      endif

      if !empty(cIdRoba)
        if idtipdok="0"  // ulaz
           nSt += kolicina
           ** nVr += Kolicina*Cijena
        elseif idtipdok="1"   // izlaz faktura
          if !(serbr="*" .and. idtipdok=="10") // za fakture na osnovu otpremnice ne racunaj izlaz
             nSt -= kolicina
             ** nVr -= Kolicina*Cijena
          endif
        endif
      endif  // empty(
      skip
    enddo
    if !empty(cIdRoba)
      SELECT POM
      HSEEK cIdRoba
      if ! Found()
        APPEND BLANK
        REPLACE IdRoba WITH cIdRoba
      endif
      REPLACE KST WITH nSt
      SELECT KALK
    endif
  enddo
else
  if !lViseKonta
   if ! RJ->(Found()) .or. Empty (RJ->Tip) .or. RJ->Tip="V"
     // veleprodajna cijena u FAKT, uzimam MKONTO u KALK
     cTipC := "V"
     Set order to 3
   else
     // u suprotnom, uzimam PKONTO
     cTipC := "M"
     SET ORDER TO 4
   endif
  endif

  GO TOP
  if !lViseKonta
   Seek (cKalkFirma+qqKonto)
  endif
  do while !EOF() .and. IF(lViseKonta, .t., KALK->(IdFirma+Iif (cTipC=="V",MKonto,PKonto))==cKalkFirma+qqKonto)
    cIdRoba := KALK->IdRoba
    nSt := nVr := 0
    do while !EOF() .and. KALK->IdRoba==cIdRoba .and. IF(lViseKonta, .t., KALK->(IdFirma+Iif (cTipC=="V",MKonto,PKonto))==cKalkFirma+qqKonto)
      if cTipC=="V"
        // magacin
        if mu_i=="1" .and. !(idvd $ "12#22#94")    // ulaz
          nSt += kolicina-gkolicina-gkolicin2
          nVr += vpc*(kolicina-gkolicina-gkolicin2)
        elseif mu_i=="5"                           // izlaz
          nSt -= kolicina
          nVr -= vpc*(kolicina)
        elseif mu_i=="1" .and. (idvd $ "12#22#94")    // povrat
          nSt += kolicina
          nVr += vpc*(kolicina)
        elseif mu_i=="3"    // nivelacija
          nVr += vpc*(kolicina)
        endif
      else  // cTipC=="M"
        // prodavnica
        if pu_i=="1"
          nSt += kolicina-GKolicina-GKolicin2
          nVr += round(mpcsapp*kolicina,ZAOKRUZENJE)
        elseif pu_i=="5"  .and. !(idvd $ "12#13#22")
          nSt -= kolicina
          nVr -= ROUND(mpcsapp*kolicina,ZAOKRUZENJE)
        elseif pu_i=="I"
          nSt += gkolicin2
          nVr -= mpcsapp*gkolicin2
        elseif pu_i=="5"  .and. (idvd $ "12#13#22")    // povrat
          nSt -= kolicina
          nVr -= ROUND( mpcsapp*kolicina ,ZAOKRUZENJE)
        elseif pu_i=="3"    // nivelacija
          nVr += round( mpcsapp*kolicina ,ZAOKRUZENJE)
        endif
      endif // cTipC=="V"
      SKIP
    enddo
    SELECT POM
    HSEEK cIdRoba
    if ! Found()
      Append Blank
      REPLACE IdRoba WITH cIdRoba
    endif
    REPLACE KST WITH nSt, KVR WITH nVr
    SELECT KALK
  enddo
endif

P_COND
?? space(gnLMarg); IspisFirme(cidfirma)
if lFaktFakt
  ? space(gnLMarg)
  ?? "FAKT: Uporedna lager lista u FAKT i FAKT druge firme na dan",date(),"   za period od",dDatOd,"-",dDatDo
else
  ? space(gnLMarg); ?? "FAKT: Usporedna lager lista u FAKT i KALK na dan",date(),"   za period od",dDatOd,"-",dDatDo
endif
if !empty(qqRoba)
  ?
  ? space(gnLMarg)
  ?? "Roba:",qqRoba
endif

if !empty(cK1) .and. !lFaktFakt
  ?
  ? space(gnlmarg), "- Roba sa osobinom K1:",ck1
endif
if !empty(cK2) .and. !lFaktFakt
  ?
  ? space(gnlmarg), "- Roba sa osobinom K2:",ck2
endif

?
if cTipVPC=="2" .and.  roba->(fieldpos("vpc2")<>0) .and. !lFaktFakt
  ? space(gnlmarg); ??"U IZVJESTAJU SU PRIKAZANE CIJENE: "+cTipVPC
endif
?
if lFaktFakt
  m:="----------------------------------------- --- ------------ ------------ ------------"

  ? space(gnLMarg); ?? m
  ? space(gnLMarg)
  ?? "                                         *   *"+Padc(ALLTRIM(cOpis1),12)+"*"+Padc(ALLTRIM(cOpis2),12)+"*  RAZLIKA"
  ? space(gnLMarg)
  ?? "Sifra i naziv artikla                    *JMJ*   STANJE   *   STANJE   *  KOLICINA  "
  ? space(gnLMarg); ?? m

  SELECT POM
  GO TOP
  do while !EOF()
    if (cRazlKol=="D" .and. ROUND (FST,4) <> ROUND (KST, 4)) .or. ;
       (cRazlVr=="D" .and. ROUND (FVR,4) <> ROUND (KVR, 4))
      SELECT ROBA
      HSEEK POM->IdRoba
      if !FOUND() .and. TRIM(cF2FS)!=TRIM(goModul:oDataBase:cDirSif)
        SELECT ROBA2
        HSEEK POM->IdRoba
        SELECT POM
        ? SPACE (gnLMarg)
        ?? ROBA2->Id, LEFT (ROBA2->Naz, 30), ROBA2->Jmj, ;
           STR (FST, 12, 3), STR (KST, 12, 3), STR (FST-KST, 12, 3)
      else
        SELECT POM
        ? SPACE (gnLMarg)
        ?? ROBA->Id, LEFT (ROBA->Naz, 30), ROBA->Jmj, ;
           STR (FST, 12, 3), STR (KST, 12, 3), STR (FST-KST, 12, 3)
      endif
    endif
    SKIP
  enddo
  ? space(gnLMarg); ?? m
else
  m:="----------------------------------------- --- ------------ ------------ ------------ ------------ ------------ ------------"

  ? space(gnLMarg); ?? m
  ? space(gnLMarg)
  ?? "                                         *   *      F   A   K   T      *      K   A   L   K      *      R A Z L I K A"
  ? space(gnLMarg)
  ?? "Sifra i naziv artikla                    *JMJ*   STANJE   * VRIJEDNOST *   STANJE   * VRIJEDNOST *  KOLICINA  * VRIJEDNOST"
  ? space(gnLMarg); ?? m

  SELECT POM
  GO TOP
  While !Eof()
    if (cRazlKol=="D" .and. ROUND (FST,4) <> ROUND (KST, 4)) .or. ;
       (cRazlVr=="D" .and. ROUND (FVR,4) <> ROUND (KVR, 4))
      SELECT ROBA
      HSEEK POM->IdRoba
      SELECT POM
      ? SPACE (gnLMarg)
      ?? ROBA->Id, LEFT (ROBA->Naz, 30), ROBA->Jmj, ;
         STR (FST, 12, 3), STR (FVR, 12, 2),;
         STR (KST, 12, 3), STR (KVR, 12, 2),;
         STR (FST-KST, 12, 3), STR (FVR-KVR, 12, 2)
    endif
    SKIP
  enddo
  ? space(gnLMarg); ?? m
endif

FF
END PRINT

#ifdef CAX
if lfaktfakt
   	select roba2
	use
endif
select kalk
use
select pom
use
#endif
closeret
return
*}


