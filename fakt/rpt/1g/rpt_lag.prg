#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/rpt/1g/rpt_lag.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.11 $
 * $Log: rpt_lag.prg,v $
 * Revision 1.11  2003/09/17 15:14:00  mirsad
 * sitni debug: uklonio poruku na kraju izvj.lager liste "gcnt1=x"
 *
 * Revision 1.10  2003/05/20 07:29:01  mirsad
 * Formatirao duzinu naziva robe za izvjestaje na 40 znakova.
 *
 * Revision 1.9  2003/04/28 13:39:12  mirsad
 * omogucen prikaz rekapitulacije po tarifama na lager listi (za Opresu)
 *
 * Revision 1.8  2003/01/21 15:01:58  ernad
 * probelm excl fakt - kalk ?! direktorij kalk
 *
 * Revision 1.7  2003/01/19 23:44:17  ernad
 * test network speed (sa), korekcija bl.lnk
 *
 * Revision 1.6  2003/01/14 03:23:33  ernad
 * exclusiv ... probelm mreza W2K ...
 *
 * Revision 1.5  2002/09/28 15:49:48  mirsad
 * prenos pocetnog stanja za evid.uplata dovrsen
 *
 * Revision 1.4  2002/09/12 12:58:23  mirsad
 * dokumentovanje INI parametara
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
  * \var *string FmkIni_ExePath_FAKT_Sintet
  * \brief Da li se koriste sinteticke (skracene) sifre robe?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_ExePath_FAKT_Sintet;



/*! \fn Lager()
 *  \brief Izvjestaj lager lista
 */
 
function Lager()
*{
parameters lPocStanje, cIdFirma,qqRoba,dDatOd,dDatDo

local nKU,nKI, fSaberiKol
local aPorezi:={}, cPoTar:="N"

private nRezerv,nRevers
private nul,nizl,nRbr,cRR,nCol1:=0
private m:=""
private nStr:=0  // tekuca strana
private cProred:="N"
private nGrZn:=99
private cLastIdRoba:=""

//testni counter globalna varijabla
gCnt1:=0

lBezUlaza := ( IzFMKINI("IZVJESTAJI","BezUlaza","N",KUMPATH)=="D" )


if lPocStanje==NIL
   lPocStanje:=.f.
else
   lPocStanje:=.t.
   O_PRIPR
   nRbrPst:=0
   cBrPSt:="00001   "
   Box(,2,60)
     @ m_x+1,m_y+2 SAY "Generacija poc. stanja  - broj dokumenta 00 -" GET cBrPSt
     read
   BoxC()
endif

if lPocStanje
	private fId_J:=.f.
	if IzFmkIni("SifRoba","ID_J","N")=="D"
		fId_J:=.t.
	endif
endif

O_DOKS
O_TARIFA
O_PARTN
O_SIFK
O_SIFV
O_ROBA
O_RJ

if fId_J
	O_FAKT
	// idroba+dtos(datDok)
	set order to tag "3J" 
else
	O_FAKT
	// idroba+dtos(datDok)
	set order to 3 
endif


fSaberikol:=(IzFMKIni('Svi','SaberiKol','N')=='D')
nKU:=nKI:=0

if !gAppSrv
	 cIdfirma:=gFirma
	 qqRoba:=""
	 dDatOd:=ctod("")
	 dDatDo:=date()
endif

cSaldo0:="N"
qqPartn:=space(20)
private qqTipdok:="  "

Box(,20+IIF(lBenjo,3,0)+IIF(lPoNarudzbi,2,0),66)


O_PARAMS
private cSection:="5"
private cHistory:=" "
private aHistory:={}
Params1()

if !gAppSrv
	RPar("c1",@cIdFirma)
	RPar("c2",@qqRoba)
	RPar("c7",@qqPartn)
	RPar("c8",@qqTipDok)
	RPar("d1",@dDatOd)
	RPar("d2",@dDatDo)
endif


select fakt


if gNW$"DR"
 //cIdfirma:=gFirma
endif
qqRoba:=padr(qqRoba,60)
qqPartn:=padr(qqPartn,20)
qqTipDok:=padr(qqTipDok,2)

cRR:="N"
cUI:="S"

private cTipVPC:="1"

cK1:=cK2:=space(4)

IF lBenjo
  qqTarife:=qqNRobe:=""
  cSort:="S"
ENDIF

do while .t.
 if gNW$"DR"
   @ m_x+1,m_y+2 SAY "RJ (prazno svi) " GET cIdFirma valid {|| empty(cIdFirma) .or. cidfirma==gFirma .or. P_RJ(@cIdFirma) }
 else
  @ m_x+1,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 endif
@ m_x+2,m_y+2 SAY "Roba   "  GET qqRoba   pict "@!S40"
IF gNovine=="D"
  @ m_x+3,m_y+2 SAY "Uslov po sifri partnera (prazno - svi)"  GET qqPartn   pict "@!"
ELSE
  @ m_x+3,m_y+2 SAY "Naziv partnera (prazno - svi)"  GET qqPartn   pict "@!"
ENDIF
@ m_x+4,m_y+2 SAY "Tip dokumenta (prazno - svi)"  GET qqTipdok
@ m_x+5,m_y+2 SAY "Od datuma "  get dDatOd
@ m_x+5,col()+1 SAY "do"  get dDatDo
IF lBezUlaza
  cRR:="N"
ELSE
  @ m_x+6,m_y+2 SAY "Prikaz rezervacija, reversa (D)"
  @ m_x+7,m_y+2 SAY "Prikaz bez rezervacija, reversa (N)"
  @ m_x+8,m_y+2 SAY "Prikaz fakturisanog na osnovu otpremnica (F) "  get cRR   pict "@!" valid cRR $ "DNF"
ENDIF
@ m_x+10,m_y+2 SAY "Prikaz stavki sa stanjem 0 (D/N)    "  get cSaldo0 pict "@!" valid cSaldo0 $ "DN"
if gVarC $ "12"
 @ m_x+11,m_y+2 SAY "Stanje prikazati sa Cijenom 1/2 (1/2) "  get cTipVpc pict "@!" valid cTipVPC $ "12"
endif
@ m_x+12,m_y+2 SAY "Napraviti prored (D/N)    "  get cProred pict "@!" valid cProred $ "DN"
if !lPocStanje
 @ m_x+13,m_y+ 2 SAY "Prikaz grupacija, grupa ima (99-ne prikazivati)" GET nGrZn pict "99"
 @ m_x+13,m_y+53 SAY "znakova"
endif
if fakt->(fieldpos("K1"))<>0 .and. gDK1=="D"
 @ m_x+14,m_y+ 2 SAY "K1" GET  cK1 pict "@!"
 @ m_x+14,m_y+15 SAY "K2" GET  cK2 pict "@!"
endif

cPopis:="N"
@ m_x+15,m_y+2 SAY "Prikazati obrazac za popis D/N" GET  cPopis pict "@!" valid cPopis $ "DN"

cRealizacija:="N"
IF !lBezUlaza
  @ row()+1,m_y+2 SAY "Prikazati realizaciju " GET  cRealizacija pict "@!" valid cRealizacija $ "DN"
ENDIF

//cSintetika:=gNovine
cSintetika:=IzFmkIni("FAKT","Sintet","N")

IF !lPocStanje .and. cSintetika=="D"
  @ row()+1,m_y+2 SAY "Sinteticki prikaz? (D/N) " GET  cSintetika pict "@!" valid cSintetika $ "DN"
ELSE
  cSintetika:="N"
ENDIF

IF !lBezUlaza
  @ row()+1,m_y+2 SAY "Prikaz kolicina (U-samo ulaz, I-samo izlaz, S-sve)" GET cUI VALID cUI$"UIS" PICT "@!"
ELSE
  cUI:="S"
ENDIF

IF gNovine=="D"
  cvOpor := "S"
  @ row()+1,m_y+2 SAY "Izdvojiti (O-oporezovane,N-neoporezovane,S-sve)" GET cvOpor VALID cvOpor$"ONS" PICT "@!"
ENDIF

IF lBenjo
  qqTarife := PADR( qqTarife , 80 )
  qqNRobe  := PADR( qqNRobe  , 80 )
  @ row()+1,m_y+2 SAY "Tarife      :" GET qqTarife PICT "@!S30"
  @ row()+1,m_y+2 SAY "Roba (naziv):" GET qqNRobe  PICT "@!S30"
  @ row()+1,m_y+2 SAY "Sortiranje (S-sifra robe/N-naziv robe/T-tarifa/J-jed.mjere)" GET cSort  PICT "@!" VALID cSort$"SNTJ"
ENDIF

IF lPoNarudzbi
  qqIdNar := SPACE(60)
  cPKN    := "N"
  @ row()+1,m_y+2 SAY "Uslov po sifri narucioca:" GET qqIdNar PICT "@!S30"
  @ row()+1,m_y+2 SAY "Prikazati kolonu 'narucilac' ? (D/N)" GET cPKN VALID cPKN$"DN" pict "@!"
ENDIF

@ row()+1, m_y+2 SAY "Prikaz stanja po tarifama? (D/N)" GET cPoTar VALID cPoTar$"DN" PICT "@!"

read

 ESC_BCR
 if fID_J
   aUsl1:=Parsiraj(qqRoba,"IdRoba_J")
 else
   aUsl1:=Parsiraj(qqRoba,"IdRoba")
 endif

 IF gNovine=="D"
   aUsl2:=Parsiraj(qqPartn,"IdPartner")
 ENDIF

 IF lBenjo
   aUslT   := Parsiraj(qqTarife,"IdTarifa")
   qqNRobe := TRIM(qqNRobe)
 ENDIF

 IF lPoNarudzbi
   aUslN := Parsiraj(qqIdNar,"idnar")
 ENDIF

 if aUsl1<>NIL .and. IF(gNovine=="D",aUsl2<>NIL,.t.) .and.;
    (!lBenjo.or.aUslT<>NIL) .and.;
    (!lPoNarudzbi.or.aUslN<>NIL)
   exit
 endif
enddo

IF lBezUlaza
  m:="---- ---------- ----------------------------------------"+IF(lPoNarudzbi.and.cPKN=="D"," ------","")+" ----------- ---"
ELSE

  if cRR $ "NF"
   m:="---- ---------- ----------------------------------------"+IF(lPoNarudzbi.and.cPKN=="D"," ------","")+IF(cUI=="S"," ----------- -----------","")+" ----------- --- --------- -----------"
  else
   m:="---- ---------- ----------------------------------------"+IF(lPoNarudzbi.and.cPKN=="D"," ------","")+" ----------- ----------- ----------- ----------- --- --------- -----------"
  endif

  if gVarC=="4"
    m+=" "+replicate("-",12)
  endif

  if cRealizacija=="D"
   m+=" "+replicate("-",12)+" "+replicate("-",12)
  endif
ENDIF


//Params2()
select params
qqRoba:=trim(qqRoba)


if !gAppSrv
 WPar("c1",cIdFirma)
 WPar("c2",qqRoba)
 WPar("c7",qqPartn)
 WPar("c8",qqTipDok)
 WPar("d1",dDatOd)
 WPar("d2",dDatDo)
endif

use

BoxC()

fSMark:=.f.
if right(qqRoba,1)="*"
  // izvrsena je markacija robe ..
  fSMark:=.t.
endif

select FAKT

IF lPoNarudzbi .and. cPKN=="D"
  SET ORDER TO TAG "3N"
ENDIF

private cFilt:=".t."

if aUsl1<>".t."
  cFilt+=".and."+aUsl1
endif

if lPoNarudzbi .and. aUslN<>".t."
  cFilt+=".and."+aUslN
endif

if gAppSrv
  ? DTOS(dDatOd),DTOS(dDatDo)
endif

if !empty(dDatOd) .or. !empty(dDatDo)
    cFilt+= ".and. DatDok>="+cm2str(dDatOd)+".and. DatDok<="+cm2str(dDatDo)
endif

cTMPFAKT:=""
IF lBenjo .and. cSort<>"S"
  Box(,2,30)
   nSlog:=0; nUkupno:=RECCOUNT2()
   cSort1:="SortFakt(IDROBA,'"+cSort+"')"
   INDEX ON &cSort1 TO (cTMPFAKT:=TMPFAKT()) FOR &cFilt EVAL(TekRec2()) EVERY 1
  BoxC()
ELSE
  if cFilt==".t."
   set filter to
  else
   set filter to &cFilt
  endif
ENDIF

if gAppSrv
  ? "Filter:", cFilt
  //set filter to
endif

go top


EOF CRET


START PRINT CRET

ZaglLager()

_cijena:=0
_cijena2:=0

nRbr:=0
nIzn:=0
nIzn2:=0
nIznR:=0 // iznos rabata
nRezerv:=nRevers:=0
qqPartn:=trim(qqPartn)
cidfirma:=trim(cidfirma)

if cSintetika=="D"
    bWhile1:= {|| !eof() .and. LEFT(cIdroba,gnDS)==LEFT(IdRoba,gnDS)  }
else
    if fId_J
      bWhile1:= {|| !eof() .and. cIdRoba==IdRoba_J+IdRoba }
    else
      bWhile1:= {|| !eof() .and. cIdRoba==IdRoba }
    endif
endif

do while !eof()
  if fID_J
    cIdRoba:=IdRoba_J+IdRoba
  else
    cIdRoba:=IdRoba
  endif

  IF lBenjo
    NSRNPIdRoba(cIdRoba,(cSintetika=="D")); SELECT FAKT
  ELSEIF cSintetika=="D"
    NSRNPIdRoba(cIdRoba,.t.); SELECT FAKT
  ENDIF

  IF lPoNarudzbi .and. cPKN=="D"
    cIdNar:=idnar
  ENDIF

  nUl:=nIzl:=0
  nRezerv:=nRevers:=0
  nReal1:=0; nReal2:=0  // nReal1 realizacija , nReal2 - rabat

  if cSintetika=="D"
      bWhile1:= {|| !eof() .and.;
                    LEFT(cIdroba,gnDS)==LEFT(IdRoba,gnDS) .and.;
                    IF(lPoNarudzbi.and.cPKN=="D",cIdNar==idnar,.t.)  }
  else
      if fId_J
        bWhile1:= {|| !eof() .and. cIdRoba==IdRoba_J+IdRoba .and.;
                      IF(lPoNarudzbi.and.cPKN=="D",cIdNar==idnar,.t.)  }
      else
        bWhile1:= {|| !eof() .and. cIdRoba==IdRoba .and.;
                      IF(lPoNarudzbi.and.cPKN=="D",cIdNar==idnar,.t.)  }
      endif
  endif

  if fSMark .and. SkLoNMark("ROBA",SiSiRo()) // skip & loop gdje je roba->_M1_ != "*"
      skip; loop
  endif

  if gNovine=="D" .and. cvOpor<>"S"
    if cvOpor=="N" .and. Oporezovana(ROBA->idtarifa) .or.;
       cvOpor=="O" .and. !Oporezovana(ROBA->idtarifa)
      skip 1; loop
    endif
  endif

  if lBenjo
    if !( ROBA->(&aUslT) .and. ROBA->naz=qqNRobe )
      skip 1
      loop
    endif
  endif

  do while eval(bWhile1)

    
    if fSMark .and. SkLoNMark("ROBA",SiSiRo()) 
    // skip & loop gdje je roba->_M1_ != "*"
        skip
	loop
    endif

    if gNovine=="D" .and. cvOpor<>"S"
      if cvOpor=="N" .and. Oporezovana(ROBA->idtarifa) .or.;
         cvOpor=="O" .and. !Oporezovana(ROBA->idtarifa)
        skip 1
	loop
      endif
    endif

    if !empty(qqTipDok)
       if idtipdok<>qqTipDok
         skip
	 loop
       endif
    endif
    if !empty(cidfirma)
     if idfirma<>cidfirma
     	skip
	loop
	endif
    endif

    if !empty(qqPartn)
      IF gNovine=="D"
        if !(&aUsl2)
          skip
	  loop
        endif
      ELSE
        select doks
	hseek fakt->(IdFirma+idtipdok+brdok)
        select fakt
        if !(doks->partner=qqPartn)
          skip
	  loop
        endif
      ENDIF
    endif

    // atributi!!!!!!!!!!!!!
    if !empty(cK1); if ck1<>K1; skip; loop; end; end
    if !empty(cK2); if ck2<>K2;  skip; loop; end; end

    if !empty(cIdRoba)
    if cRR<>"F"
     if idtipdok="0"  // ulaz
        nUl+=kolicina
        if fSaberikol .and. !( roba->K2 = 'X')
         nKU+=kolicina
        endif
     elseif idtipdok="1"   // izlaz faktura
       if !(serbr="*" .and. idtipdok=="10") // za fakture na osnovu otpremnice ne racunaj izlaz
          nIzl+=kolicina
          nReal1+=round( kolicina*Cijena, ZAOKRUZENJE)
          nReal2+=round( kolicina*Cijena*(Rabat/100) , ZAOKRUZENJE)
          if fSaberikol .and. !( roba->K2 = 'X')
            nKI+=kolicina
          endif
       endif
     elseif idtipdok$"20#27"
        if serbr="*"
          nRezerv+=kolicina
        endif
     elseif idtipdok=="21"
        nRevers+=kolicina
        if fSaberikol .and. !( roba->K2 = 'X')
            nKI+=kolicina
        endif
     endif
    else
     if (serbr="*" .and. idtipdok=="10") // za fakture na osnovu otpremince ne ra~unaj izlaz
          nIzl+=kolicina
          // finansijski da !
          nReal1+=round( kolicina*Cijena , ZAOKRUZENJE)
          nReal2+=round( kolicina*Cijena*(Rabat/100) , ZAOKRUZENJE)
          if fSaberikol .and. !( roba->K2 = 'X')
            nKI+=kolicina
          endif
     endif
    endif // crr=="F"
    endif  // empty(
    skip
  enddo
  	
	if prow()>61-iif(cProred="D",1,0)
  		ZaglLager()
	endif
	OL_Yield()

  // TODO !!!!!!!!! rijesiti ID_J za sinteticku robu

  if !empty(cIdRoba)
   if !(cSaldo0=="N" .and. (nUl-nIzl)==0)
     if fID_J
         NSRNPIdRoba(substr(cIdRoba,11), (cSintetika=="D"))  
	 // desni dio sifre je interna sifra
     else
         NSRNPIdRoba(cIdRoba, (cSintetika=="D") )
     endif
     IF gNovine=="D" .and. cvOpor<>"S"
     	Oporezovana(ROBA->idtarifa)  // ?nepotrebno?
     ENDIF
    IF nGrZn<>99 .and. ( EMPTY(cLastIdRoba) .or. LEFT(cLastIdRoba,nGrZn)<>LEFT(cIdRoba,nGrZn) )
      SELECT ROBA
      PushWA()
      SEEK LEFT(cIdRoba,nGrZn)
      IF FOUND() .and. RIGHT(TRIM(id),1)=="."
        cNazivGrupacije := LEFT(cIdRoba,nGrZn)+" "+naz
      ELSE
        cNazivGrupacije := LEFT(cIdRoba,nGrZn)
      ENDIF
      PopWA()
      if cProred=="D"
        ? space(gnLMarg); ?? m
      endif
      ? space(gnLMarg)
      ?? "GRUPA ARTIKALA: "+cNazivGrupacije
      cLastIdRoba:=cIdRoba
    ENDIF
    select FAKT
    if cProred=="D"
       ? space(gnLMarg); ?? m
    endif
    ? space(gnLMarg)
    ?? str(++nRbr,4),;
      IF(cSintetika=="D".and.ROBA->tip=="S",;
         ROBA->id, Left(cidroba,10)), PADR(ROBA->naz,40)

    if lPoNarudzbi .and. cPKN=="D"
      ?? "", cIdNar
    endif

    if cRR $ "NF" .and. !lBezUlaza
     IF cUI $ "US"
       @ prow(),pcol()+1 SAY nUl  pict iif(cPopis=="N",pickol,replicate("_",len(PicKol)) )
     ENDIF
     IF cUI $ "IS"
       @ prow(),pcol()+1 SAY nIzl pict iif(cPopis=="N",pickol,replicate("_",len(PicKol)) )
     ENDIF
    endif

    IF lBezUlaza
      nCol1 := pcol()+1
    ENDIF
    IF cUI == "S"
      @ prow(),pcol()+1 SAY nUl-nIzl pict iif(cPopis=="N",pickol,replicate("_",len(PicKol)) )
    ENDIF

    if cRR=="D"
      @ prow(),pcol()+1 SAY nRevers pict iif(cPopis=="N",pickol,replicate("_",len(PicKol)) )
      @ prow(),pcol()+1 SAY nRezerv pict iif(cPopis=="N",pickol,replicate("_",len(PicKol)) )
      @ prow(),pcol()+1 SAY nUl-nIzl-nRevers-nRezerv pict iif(cPopis=="N",pickol,replicate("_",len(PicKol)) )
    endif
    @ prow(),pcol()+1 SAY roba->jmj
    if cTipVPC=="2" .and.  roba->(fieldpos("vpc2")<>0)
      _cijena:=roba->vpc2
    else
      _cijena := if ( !EMPTY(cIdFirma) , UzmiMPCSif(), roba->vpc )
    endif
    if gVarC=="4"
     _cijena2:=roba->mpc
    endif

    if lPocStanje
      select pripr
      if cRR="D"
        nPrenesi:=-nRevers-nRezerv
      else
        nPrenesi:=nUl-nIzl
      endif
      if round(nPrenesi,4)<>0
         append blank
         replace idfirma with cidfirma, idroba with left(cIdRoba,10),;
                 datdok with dDatDo+1,;
                 idtipdok with "00", brdok with cBRPST ,;
                 cijena with _cijena,;
                 dindem with "DEM",;
                 Rbr with Rednibroj(++nRbrPst),;
                 kolicina with nPrenesi

         if fId_J
           replace idroba_J with left(cIdRoba,10),;
                   idroba with substr(cIdroba,11)
         endif
        replace txt   with chr(16)+""+chr(17)+;
                      chr(16)+""+chr(17)+chr(16)+"POCETNO STANJE"+chr(17)+;
                      chr(16)+""+chr(17)+chr(16)+""+chr(17)

      endif
      select fakt
    endif

    if cPoTar=="D"
	nMpv:=(nUl-nIzl)*roba->mpc
	nPom:=ASCAN(aPorezi,{|x| x[1]==roba->idTarifa})
	if nPom>0
		aPorezi[nPom,2]:=aPorezi[nPom,2]+nMpv
	else
		AADD(aPorezi, {roba->idTarifa, nMpv})
	endif
    endif

    if cRealizacija=="D"
       if nIzl>0
         @ prow(),pcol()+1 SAY (nReal1-nReal2)/nIzl  pict "99999.999"
       else
         @ prow(),pcol()+1 SAY 0  pict "99999.999"
       endif
       nCol1:=pcol()+1
       @ prow(),nCol1 SAY nReal1  pict picdem
       @ prow(),pcol()+1 SAY nReal2  pict picdem
       @ prow(),pcol()+1 SAY nReal1-nReal2  pict picdem
       nIzn+=nReal1
       nIznR+=nReal2
    else
       nPomSt := IF( cUI=="S" , nUl-nIzl , IF( cUI=="I" , nIzl , nUl ) )
       IF !lBezUlaza
         @ prow(),pcol()+1 SAY _cijena  pict "99999.999"
         nCol1:=pcol()+1
         @ prow(),nCol1 SAY nPomSt*_cijena   pict iif(cPopis=="N",picdem,replicate("_",len(Picdem)) )
       ENDIF
       nIzn += nPomSt*_cijena
       if gVarC=="4" // uporedo
         IF !lBezUlaza
           @ prow(),pcol()+1 SAY _cijena2   pict picdem
         ENDIF
         nIzn2 += nPomSt*_cijena2
       endif
    endif
   endif
  endif

enddo

if prow()>59
	ZaglLager()
endif

IF !lBezUlaza
  ? space(gnLMarg)
  ?? m
  ? space(gnLMarg)
  ?? " Ukupno:"
  if cPopis=="N"
    @ prow(),nCol1 SAY nIzn  pict picdem
    if cRealizacija=="D"
      @ prow(),pcol()+1 SAY nIznR  pict picdem
      @ prow(),pcol()+1 SAY nIzn-nIznR  pict picdem
    endif
    if gVarC=="4"
      ? space(gnLMarg); ?? " Ukupno MPV:"
      @ prow(),nCol1 SAY nIzn2  pict picdem
    endif
  endif
ENDIF

? space(gnLMarg)
?? m

if fSaberikol
 ? space(gnLMarg); ?? " Ukupno (kolicine):"
 IF lBezUlaza
   @ prow(),nCol1 SAY nKU-nKI picture iif(cPopis=="N",pickol,replicate("_",len(PicKol)) )
 ELSE
   IF cUI $ "US"
     @ prow(), nCol1 - ( len(picdem)+1 )* 4 - 2  SAY nKU  picture iif(cPopis=="N",pickol,replicate("_",len(PicKol)) )
   ENDIF
   IF cUI $ "IS"
     IF cUI == "I"
       @ prow(),nCol1 - ( len(picdem)+1 )* 4 - 2 SAY nKI  picture iif(cPopis=="N",pickol,replicate("_",len(PicKol)) )
     ELSE
       @ prow(),pcol()+1 SAY nKI  picture iif(cPopis=="N",pickol,replicate("_",len(PicKol)) )
     ENDIF
   ENDIF
   IF cUI == "S"
     @ prow(),pcol()+1 SAY nKU-nKI picture iif(cPopis=="N",pickol,replicate("_",len(PicKol)) )
   ENDIF
 ENDIF
 ? space(gnLMarg)
 ?? m
endif

if cPoTar=="D"
	if prow()>59
		ZaglLager()
	endif
	?
	z0:="Rekapitulacija stanja po tarifama:"
	? z0
	m:="------"+REPL(" "+REPL("-",LEN(gPicProc)),3)+REPL(" "+REPL("-",LEN(gPicDem)),5)
	? m
	z1:="Tarifa"+PADC("PPP%",LEN(gPicProc)+1)+PADC("PPU%",LEN(gPicProc)+1)+PADC("PP%",LEN(gPicProc)+1)+PADC("MPV",LEN(gPicDem)+1)+PADC("PPP",LEN(gPicDem)+1)+PADC("PPU",LEN(gPicDem)+1)+PADC("PP",LEN(gPicDem)+1)+PADC("MPV+por",LEN(gPicDem)+1)
	? z1
	? m
	ASORT(aPorezi,{|x,y| x[1]<y[1]})
	nUMPV:=nUMPV0:=nUPor1:=nUPor2:=nUPor3:=0
	for i:=1 to len(aPorezi)
		if prow()>59
			ZaglLager()
			?
			? z0
			? m
			? z1
			? m
		endif
		select tarifa
		hseek aPorezi[i,1]
		VTPorezi()
		nMPV:=aPorezi[i,2]
		nMPV0:=ROUND(nMPV/(_ZPP+(1+_OPP)*(1+_PPP)), ZAOKRUZENJE)
		nPor1:=ROUND(nMPV/(_ZPP+(1+_OPP)*(1+_PPP))*_OPP, ZAOKRUZENJE)
		nPor2:=ROUND(nMPV/(_ZPP+(1+_OPP)*(1+_PPP)*(1+_OPP))*_PPP, ZAOKRUZENJE)
		nPor3:=ROUND(nMPV/(_ZPP+(1+_OPP)*(1+_PPP))*_ZPP, ZAOKRUZENJE)
		? aPorezi[i,1], TRANS(100*_OPP,gPicProc), TRANS(100*_PPP,gPicProc), TRANS(100*_ZPP,gPicProc), TRANS(nMPV0,gPicDem), TRANS(nPor1,gPicDem), TRANS(nPor2,gPicDem), TRANS(nPor3,gPicDem), TRANS(nMPV,gPicDem)
		nUMPV+=nMPV
		nUMPV0+=nMPV0
		nUPor1+=nPor1
		nUPor2+=nPor2
		nUPor3+=nPor3
	next
	? m
	? PADR("UKUPNO:",3*(LEN(gPicProc)+1)+6), TRANS(nUMPV0,gPicDem), TRANS(nUPor1,gPicDem), TRANS(nUPor2,gPicDem), TRANS(nUPor3,gPicDem), TRANS(nUMPV,gPicDem)
	?
endif

FF
END PRINT


CLOSE ALL
MyFERASE(cTMPFAKT)

// MsgBeep("gCnt1="+STR(gCnt1,6))

CLOSERET
return
*}



/*! \fn ZaglLager()
 *  \brief Zaglavlje lager liste
 */
 
function ZaglLager()
*{
local cPomZK

if nStr>0
	FF
endif

P_COND
set century on
? space(4),"   FAKT: Lager lista robe na dan", DATE(), "      za period od",dDatOd,"-",dDatDo, space(6), "Strana:",str(++nStr,3)
set century off
?

IF cUI=="U"
  ? space(4),"         (prikaz samo ulaza)"
  ?
ELSEIF cUI=="I"
  ? space(4),"         (prikaz samo izlaza)"
  ?
ENDIF

IF gNovine=="D" .and. cvOpor<>"S"
  ? space(4),"         (prikaz samo "+IF(cvOpor=="N","ne","")+"oporezovanih artikala)"
  ?
ENDIF

IF cRR=="D"
  P_COND2
ELSE
  P_COND
ENDIF



if cRealizacija=="D"
 P_COND2
 ?
 ? space(gnLMarg)
 ?? "**** FINANSIJSKI: PRIKAZ REALIZACIJE *****"
 ?
endif

? space(gnLMarg)
IspisFirme(cidfirma)

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

if lPoNarudzbi .and. !EMPTY(qqIdNar)
  ?
  ? "Prikaz za sljedece narucioce:",TRIM(qqIdNar)
endif

?
if cRealizacija=="N" .and. cTipVPC=="2" .and.  roba->(fieldpos("vpc2")<>0)
  ? space(gnlmarg)
  ?? "U CJENOVNIKU SU PRIKAZANE CIJENE: "+cTipVPC
endif

?
? space(gnLMarg)
?? m
? space(gnLMarg)

IF lBezUlaza
   ?? "R.br  Sifra       Naziv                                  "+IIF(lPoNarudzbi.and.cPKN=="D","Naruc. ","")+"  Stanje    jmj     "
ELSE
  cPomZK := IF( cUI $ "US" , PADC("Ulaz",12) , "" )+;
            IF( cUI $ "IS" , PADC("Izlaz",12) , "" )+;
            IF( cUI $ "S" , PADC("Stanje",12) , "" )
  if cRR $ "NF"
   ?? "R.br  Sifra       Naziv                                  "+IIF(lPoNarudzbi.and.cPKN=="D","Naruc. ","")+cPomZK+"jmj     "+IIF(RJ->tip$"N1#M1#M2".and.!EMPTY(cIdFirma),"Cij.",iif(cRealizacija=="D","PR.C","VPC "))+;
      iif(cREalizacija=="N","      Iznos","      VPV        Rabat      Realizovano")
  else
   ?? "R.br  Sifra       Naziv                                  "+IIF(lPoNarudzbi .and. cPKN=="D","Naruc. ","")+"  Stanje       Revers    Rezervac.   Ostalo     jmj     "+IF(RJ->tip$"N1#M1#M2" .and. !EMPTY(cIdFirma),"Cij.  Cij.","VPC    VPC")+"*Stanje"
  endif
  if gVarC=="4"
   ?? padc("MPV",13)
  endif
ENDIF

? space(gnLMarg)
?? m

ShowKorner(nStr,1,16)

return
*}
