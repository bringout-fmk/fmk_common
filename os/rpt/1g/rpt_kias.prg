#include "\cl\sigma\fmk\os\os.ch"


function PrKIAS()
*{
local cIdAmort:=space(8)
local cIdKonto:=qidkonto:=space(7), cidsk:="", ndug:=ndug2:=npot:=npot2:=ndug3:=npot3:=0
local nCol1:=10, qIdAm:=SPACE(8)
O_AMORT
O_KONTO
O_RJ
O_PROMJ
O_OS

cIdrj:=space(4)
cPromj:="2"
cPocinju:="N"
cFiltSadVr:="0"
cFiltK1:=SPACE(40)
cSamoSpec:=IzFMKIni("OS","DefaultSamoSpecZaIzv7","N")
cON:=" " // novo!

Box(,12,77)
 DO WHILE .t.
  @ m_x+ 1,m_y+2 SAY "Radna jedinica (prazno - svi):" get cidrj valid empty(cIdRj) .or. p_rj(@cIdrj)
  @ m_x+ 1,col()+2 SAY "sve koje pocinju " get cpocinju valid cpocinju $ "DN" pict "@!"
  @ m_x+ 2,m_y+2 SAY "Konto (prazno - svi):" get qIdKonto pict "@!" valid empty(qidkonto) .or. P_Konto(@qIdKonto)
  @ m_x+ 3,m_y+2 SAY "Grupa amort.stope (prazno - sve):" get qIdAm pict "@!" valid empty(qidAm) .or. P_Amort(@qIdAm)
  @ m_x+ 4,m_y+2 SAY "Za sredstvo prikazati vrijednost:"
  @ m_x+ 5,m_y+2 SAY "1 - bez promjena"
  @ m_x+ 6,m_y+2 SAY "2 - osnovni iznos + promjene"
  @ m_x+ 7,m_y+2 SAY "3 - samo promjene           " GET cPromj valid cpromj $ "123"
  @ m_x+ 8,m_y+2 SAY "Filter po sadasnjoj vr.(0-sve,1-samo koja je imaju,2-samo koja je nemaju):" GET cFiltSadVr valid cFiltSadVr $ "012" pict "9"
  @ m_x+ 9,m_y+2 SAY "Filter po grupaciji K1:" GET cFiltK1 pict "@!S20"
  @ m_x+10,m_y+2 SAY "Prikaz samo specifikacije (D/N):" GET cSamoSpec VALID cSamoSpec$"DN" pict "@!"
  @ m_x+11,m_y+2 SAY "Prikaz svih os ( )      /   neotpisanih (N)     / otpisanih   (O) "
  @ m_x+12,m_y+2 SAY "/novonabavljenih   (B) / iz proteklih godina (G)" get cON valid con $ "ONBG " pict "@!"
  read; ESC_BCR
  aUsl1:=Parsiraj(cFiltK1,"K1")
  if aUsl1<>NIL; exit; endif
 ENDDO
BoxC()

if empty(qidAm); qidAm:=""; endif
if empty(qidkonto); qidkonto:=""; endif
if empty(cIdrj); cidrj:=""; endif
if cpocinju=="D"
  cIdRj:=trim(cidrj)
endif


SELECT OS
cSort1:="idkonto+idam+id"

aUslS := ".t."
IF !EMPTY(cIdRJ)
  aUslS := aUslS + ".and." +;
           "IDRJ="+cm2str(cIdRJ)
ENDIF
IF !EMPTY(qIdKonto)
  aUslS := aUslS + ".and." +;
           "IDKONTO="+cm2str(qIdKonto)
ENDIF
IF !EMPTY(qIdAm)
  aUslS := aUslS + ".and." +;
           "IDKONTO="+cm2str(qIdAm)
ENDIF
IF !EMPTY(cFiltK1)
  aUslS := aUslS + ".and." +;
           aUsl1
ENDIF

SELECT OS
SET ORDER TO
SET FILTER TO
GO TOP

IF cPromj=="3" .or. cFiltSadVr!="0"
  cSort1:="FSVPROMJ()+idkonto+idam+id"
  INDEX ON &cSort1 TO "TMPOS" FOR &aUslS
  SET SCOPE TO " "
//  aUslS := aUslS + ".and." +;
//           "ImaPromjene()"
ELSE
  INDEX ON &cSort1 TO "TMPOS" FOR &aUslS
ENDIF
GO TOP

IF EOF()
  MsgBeep("Ne postoje trazeni podaci!")
  CLOSERET
ENDIF


DefIzvjVal()

START PRINT CRET
P_12CPI
? gTS+":",gnFirma
if !empty(cidrj)
 select rj; hseek cidrj; select os
 ? "Radna jedinica:",cidrj,rj->naz
endif
? "OS: Pregled obracuna amortizacije po kontima i amortizacionim grupama "
?? "",PrikazVal(),"    Datum:",gDatObr
if !EMPTY(cFiltK1); ? "Filter grupacija K1 pravljen po uslovu: '"+TRIM(cFiltK1)+"'"; endif
if con="N"
  ? "PRIKAZ NEOTPISANIH SREDSTAVA:"
elseif con=="B"
  ? "PRIKAZ NOVONABAVLJENIH SREDSTAVA:"
elseif con=="G"
  ? "PRIKAZ SREDSTAVA IZ PROTEKLIH GODINA:"
elseif con=="O"
  ? "PRIKAZ OTPISANIH SREDSTAVA:"
elseif   con==" "
  ? "PRIKAZ SVIH SREDSTAVA:"
endif

private nRbr:=0
altd()
aKol:={}
nKol:=0
nPI:=LEN(gPicI)
nPID:=0
j:=AT(".",gPicI)

IF (j>0)
	FOR i:=j TO LEN(gPicI)
    		IF SUBSTR(gPicI,i,1)=="9"
      			++nPID
    		ELSE
      			//EXIT
			loop
    		ENDIF
  	NEXT
ENDIF

IF cSamoSpec=="D"
 AADD(aKol, { "OtpVr"    , {|| otpvr*nBBK            }, .f., "N", nPI,nPID, 1, ++nKol } )
 AADD(aKol, { "Amort."   , {|| amp*nBBK              }, .f., "N", nPI,nPID, 1, ++nKol } )
 AADD(aKol, { "O+Am"     , {|| otpvr*nBBK+amp*nBBK        }, .f., "N", nPI,nPID, 1, ++nKol } )
 AADD(aKol, { "SadVr"    , {|| nabvr*nBBK-otpvr*nBBK-amp*nBBK  }, .f., "N", nPI,nPID, 1, ++nKol } )
ELSE
 AADD(aKol, { "Rbr."     , {|| STR(nRBr,4)+"."  }, .f., "C",   5,   0, 1, ++nKol } )
 AADD(aKol, { "Inv.broj" , {|| id               }, .f., "C",  10,   0, 1, ++nKol } )
 AADD(aKol, { "RJ"       , {|| idrj             }, .f., "C",   4,   0, 1, ++nKol } )
 AADD(aKol, { "Datum"    , {|| datum            }, .f., "D",   8,   0, 1, ++nKol } )
 AADD(aKol, { "Sredstvo" , {|| naz              }, .f., "C",  30,   0, 1, ++nKol } )
 AADD(aKol, { "jmj"      , {|| jmj              }, .f., "C",   3,   0, 1, ++nKol } )
 AADD(aKol, { "kol"      , {|| kolicina         }, .f., "N",   6,   1, 1, ++nKol } )
 AADD(aKol, { "NabVr"    , {|| nabvr*nBBK            }, .t., "N", nPI,nPID, 1, ++nKol } )
 AADD(aKol, { "OtpVr"    , {|| otpvr*nBBK            }, .t., "N", nPI,nPID, 1, ++nKol } )
 AADD(aKol, { "Amort."   , {|| amp*nBBK              }, .t., "N", nPI,nPID, 1, ++nKol } )
 AADD(aKol, { "O+Am"     , {|| otpvr*nBBK+amp*nBBK        }, .t., "N", nPI,nPID, 1, ++nKol } )
 AADD(aKol, { "SadVr"    , {|| nabvr*nBBK-otpvr*nBBK-amp*nBBK  }, .t., "N", nPI,nPID, 1, ++nKol } )
ENDIF

gnLMarg:=0; gTabela:=1; gOstr:="D"

cIdSK    := LEFT(IDKONTO,3)
cIdKonto := IDKONTO
cIdAm    := IDAM

nNab1:=nOtp1:=nAmo1:=0
nNab2:=nOtp2:=nAmo2:=0
nNab3:=nOtp3:=nAmo3:=0
nNab9:=nOtp9:=nAmo9:=0

gaSubTotal:={}
gaDodStavke:={}

IF cSamoSpec=="D"

  StampaTabele(aKol,,,gTabela,,;
               ,,;
               {|| FFor1s()},IF(gOstr=="D",,-1),,,,,)

ELSE

  StampaTabele(aKol,,,gTabela,,;
               ,,;
               {|| FFor1()},IF(gOstr=="D",,-1),,,,,)

ENDIF

FF
END PRINT
CLOSERET



FUNCTION FFor1()
  LOCAL lVrati:=.t., fIma:=.t., lImaSadVr:=.t.

  gaSubTotal  := {}
  gaDodStavke := {}

  if !( (cON=="N" .and. empty(datotp)) .or.;
        (con=="O" .and. !empty(datotp)) .or.;
        (con=="B" .and. year(datum)=year(gdatobr)) .or.;
        (con=="G" .and. year(datum)<year(gdatobr)) .or.;
         empty(con) )
    RETURN .f.
  endif

  // priprema za ispis dodatnih stavki
  // ---------------------------------
  ++nRbr
  if cPromj $ "23"  // prikaz promjena
    select promj; hseek os->id
    IF cPromj=="2" .and. !eof() .and. id==os->id .and. datum<=gDatObr .or.;
       cPromj=="3"
       IF cPromj=="3"
         AADD(gaDodStavke,;
              { STR(nRBr,4)+"." , OS->id , OS->idrj , OS->datum ,;
                OS->naz , OS->jmj , OS->kolicina , , , , , })
         lVrati:=.f.
       ENDIF
       do while !eof() .and. id==os->id .and. datum<=gDatObr
          AADD(gaDodStavke,;
               {,,,datum,opis,,,nabvr*nBBK,otpvr*nBBK,amp*nBBK,otpvr*nBBK+amp*nBBK,nabvr*nBBK-amp*nBBK-otpvr*nBBK})
          nNab3 += nabvr*nBBK;  nOtp3 += otpvr*nBBK;  nAmo3 += amp*nBBK
          nNab2 += nabvr*nBBK;  nOtp2 += otpvr*nBBK;  nAmo2 += amp*nBBK
          nNab1 += nabvr*nBBK;  nOtp1 += otpvr*nBBK;  nAmo1 += amp*nBBK
         skip 1
       enddo
    ENDIF
    select os
  endif

  cIdSK    := LEFT(IDKONTO,3)
  cIdKonto := IDKONTO
  cIdAm    := IDAM
  cST1:="UK.GRUPA AMORTIZ. '"+cIdAM+"'"
  cST2:="UK.ANALIT.KONTO '"+cIdKonto+"'"
  cST3:="UK.SINT.KONTO '"+cIdSK+"'"

  IF cPromj!="3"
    // sinteticki
     nNab3 += nabvr*nBBK;  nOtp3 += otpvr*nBBK;  nAmo3 += amp*nBBK
    // analiticki
     nNab2 += nabvr*nBBK;  nOtp2 += otpvr*nBBK;  nAmo2 += amp*nBBK
    // po grupi amortizacije
     nNab1 += nabvr*nBBK;  nOtp1 += otpvr*nBBK;  nAmo1 += amp*nBBK
  ENDIF

  SKIP 1
    IF cIdSK!=LEFT(IDKONTO,3) .or. EOF()
      // stampaj subtot.amort.
      // stampaj subtot.analit.
      // stampaj subtot.sint.
      gaSubTotal:={;
          {,,,,,,,  nNab1, nOtp1, nAmo1, nOtp1+nAmo1, nNab1-nOtp1-nAmo1 , cST1 },;
          {,,,,,,,  nNab2, nOtp2, nAmo2, nOtp2+nAmo2, nNab2-nOtp2-nAmo2 , cST2 },;
          {,,,,,,,  nNab3, nOtp3, nAmo3, nOtp3+nAmo3, nNab3-nOtp3-nAmo3 , cST3 } }
      nNab1:=nOtp1:=nAmo1:=0
      nNab2:=nOtp2:=nAmo2:=0
      nNab3:=nOtp3:=nAmo3:=0
    ELSEIF cIdKonto!=IDKONTO
      // stampaj subtot.amort.
      // stampaj subtot.analit.
      gaSubTotal:={;
          {,,,,,,,  nNab1, nOtp1, nAmo1, nOtp1+nAmo1, nNab1-nOtp1-nAmo1 , cST1 },;
          {,,,,,,,  nNab2, nOtp2, nAmo2, nOtp2+nAmo2, nNab2-nOtp2-nAmo2 , cST2 } }
      nNab1:=nOtp1:=nAmo1:=0
      nNab2:=nOtp2:=nAmo2:=0
    ELSEIF cIdAm!=IDAM
      // stampaj subtot.amort.
      gaSubTotal:={;
          {,,,,,,,  nNab1, nOtp1, nAmo1, nOtp1+nAmo1, nNab1-nOtp1-nAmo1 , cST1 } }
      nNab1:=nOtp1:=nAmo1:=0
    ELSE
      gaSubTotal:={}
    ENDIF
  SKIP -1
RETURN lVrati


FUNCTION FFor1s()
  LOCAL lVrati:=.t., fIma:=.t., lImaSadVr:=.t.

  gaSubTotal  := {}
  gaDodStavke := {}

  if !( (cON=="N" .and. empty(datotp)) .or.;
        (con=="O" .and. !empty(datotp)) .or.;
        (con=="B" .and. year(datum)=year(gdatobr)) .or.;
        (con=="G" .and. year(datum)<year(gdatobr)) .or.;
         empty(con) )
    RETURN .f.
  endif

  // priprema za ispis dodatnih stavki
  // ---------------------------------
  ++nRbr
  if cPromj $ "23"  // prikaz promjena
    select promj; hseek os->id
    IF cPromj=="2" .and. !eof() .and. id==os->id .and. datum<=gDatObr .or.;
       cPromj=="3"
       IF cPromj=="3"
         AADD(gaDodStavke,;
              { STR(nRBr,4)+"." , OS->id , OS->idrj , OS->datum ,;
                OS->naz , OS->jmj , OS->kolicina , , , , , })
         lVrati:=.f.
       ENDIF
       do while !eof() .and. id==os->id .and. datum<=gDatObr
          AADD(gaDodStavke,;
               {,,,datum,opis,,,nabvr*nBBK,otpvr*nBBK,amp*nBBK,otpvr*nBBK+amp*nBBK,nabvr*nBBK-amp*nBBK-otpvr*nBBK})
          nNab9 += nabvr*nBBK;  nOtp9 += otpvr*nBBK;  nAmo9 += amp*nBBK
          nNab3 += nabvr*nBBK;  nOtp3 += otpvr*nBBK;  nAmo3 += amp*nBBK
          nNab2 += nabvr*nBBK;  nOtp2 += otpvr*nBBK;  nAmo2 += amp*nBBK
          nNab1 += nabvr*nBBK;  nOtp1 += otpvr*nBBK;  nAmo1 += amp*nBBK
         skip 1
       enddo
    ENDIF
    select os
  endif

  cIdSK    := LEFT(IDKONTO,3)
  cIdKonto := IDKONTO
  cIdAm    := IDAM
  cST1:="                    UK.GRUPA AMORTIZACIJE '"+cIdAM+"'"
  cST2:="          UK.ANALITICKI KONTO '"+cIdKonto+"'"
  cST3:="UK.SINTETICKI KONTO '"+cIdSK+"'"
  cST9:="S V E    U K U P N O"

  IF cPromj!="3"
    // sveukupno
     nNab9 += nabvr*nBBK;  nOtp9 += otpvr*nBBK;  nAmo9 += amp*nBBK
    // sinteticki
     nNab3 += nabvr*nBBK;  nOtp3 += otpvr*nBBK;  nAmo3 += amp*nBBK
    // analiticki
     nNab2 += nabvr*nBBK;  nOtp2 += otpvr*nBBK;  nAmo2 += amp*nBBK
    // po grupi amortizacije
     nNab1 += nabvr*nBBK;  nOtp1 += otpvr*nBBK;  nAmo1 += amp*nBBK
  ENDIF

  SKIP 1
    IF cIdSK!=LEFT(IDKONTO,3) .or. EOF()
      // stampaj subtot.amort.
      // stampaj subtot.analit.
      // stampaj subtot.sint.
      gaSubTotal:={;
          {,  nNab1, nOtp1, nAmo1, nOtp1+nAmo1, nNab1-nOtp1-nAmo1 , cST1 },;
          {,  nNab2, nOtp2, nAmo2, nOtp2+nAmo2, nNab2-nOtp2-nAmo2 , cST2 },;
          {,  nNab3, nOtp3, nAmo3, nOtp3+nAmo3, nNab3-nOtp3-nAmo3 , cST3 } }
      nNab1:=nOtp1:=nAmo1:=0
      nNab2:=nOtp2:=nAmo2:=0
      nNab3:=nOtp3:=nAmo3:=0
      // stampaj sve ukupno
      IF EOF()
        AADD(gaSubTotal, {,  nNab9, nOtp9, nAmo9, nOtp9+nAmo9, nNab9-nOtp9-nAmo9 , cST9 } )
      ENDIF
    ELSEIF cIdKonto!=IDKONTO
      // stampaj subtot.amort.
      // stampaj subtot.analit.
      gaSubTotal:={;
          {,  nNab1, nOtp1, nAmo1, nOtp1+nAmo1, nNab1-nOtp1-nAmo1 , cST1 },;
          {,  nNab2, nOtp2, nAmo2, nOtp2+nAmo2, nNab2-nOtp2-nAmo2 , cST2 } }
      nNab1:=nOtp1:=nAmo1:=0
      nNab2:=nOtp2:=nAmo2:=0
    ELSEIF cIdAm!=IDAM
      // stampaj subtot.amort.
      gaSubTotal:={;
          {,  nNab1, nOtp1, nAmo1, nOtp1+nAmo1, nNab1-nOtp1-nAmo1 , cST1 } }
      nNab1:=nOtp1:=nAmo1:=0
    ELSE
      gaSubTotal:={}
    ENDIF
  SKIP -1
  gaDodStavke:={}
RETURN .f.


// filter za sadasnju vrijednost i prikaz promjena
// koristi se u sort-u izvjestaja po kontima i amort.grupama
// cPromj: 1-bez promjena/2-sa promjenama/3-samo promjene
// cFiltSadVr: 0-sve/1-koja imaju sadasnju vrijednost/2-koja nemaju sad.vrij.
// --------------------------------------------------------------------------
FUNCTION FSVPROMJ()
 LOCAL nArr:=SELECT(), cVrati:=CHR(255), lImaSadVr:=.f.
 if cPromj <> "3"   // osnovno sredstvo: ima li sad.vr.?
   if OS->(nabvr-otpvr-amp)>0
     lImaSadVr:=.t.
   endif
 endif
 if !lImaSadVr .and. cPromj == "2" .or. cPromj=="3" // promjene:ispitujemo ima
   SELECT PROMJ; SEEK OS->id                        // li sadasnju vrijednost
   IF FOUND()
     DO WHILE !EOF() .and. id==os->id .and. datum<=gDatObr
       IF nabvr-otpvr-amp>0
         lImaSadVr:=.t.
       ENDIF
       SKIP 1
     ENDDO
   ELSEIF cPromj=="3"
     SELECT (nArr)
     RETURN CHR(255)
   ENDIF
 ENDIF
 IF cFiltSadVr=="1" .and. !(lImaSadVr) .or. cFiltSadVr=="2" .and. lImaSadVr
   cVrati:=CHR(255)
 ELSE
   cVrati:=" "
 ENDIF
 SELECT (nArr)
RETURN cVrati

