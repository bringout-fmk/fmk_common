#ifdef CPOR
   gModul:="POR"
#else
   public gModul:="LD"
#endif


#include "ini0c52.ch"

PUBLIC cVer:='02.33e'

#ifdef C52
PUBLIC cNaslov:="LD:Install CDX, 06.96-02.02"
#else
PUBLIC cNaslov:="LD:Install AX, 06.96-02.02"
#endif

#ifdef CPOR
  cNaslov:="POR-"+cNaslov
#endif

#include "iini.ch"


#ifdef CPOR
   gModul:="POR"
#endif


*********************************************************
* ako je program pokrenut sa opcijom /I -> lInstal=.t.
* Uzima se da se tada vrsi kreiranje nepostojecih DBF-ova
*********************************************************
function Kreiraj()

PRIVATE lViseObr:=.f., lVOBrisiCDX := .f.

TestViseObr()

*********  RADN.DBF   ***********
aDbf:={}
#ifdef CPOR
AADD(aDBf,{ 'ID'                  , 'C' ,   13 ,  0 })
#else
AADD(aDBf,{ 'ID'                  , 'C' ,   6 ,  0 })
#endif
AADD(aDBf,{ 'NAZ'                 , 'C' ,  20 ,  0 })
AADD(aDBf,{ 'IMEROD'              , 'C' ,  15 ,  0 })
AADD(aDBf,{ 'IME'                 , 'C' ,  15 ,  0 })
#ifndef CPOR
AADD(aDBf,{ 'BRBOD'               , 'N' ,  11 ,  2 })
AADD(aDBf,{ 'KMINRAD'             , 'N' ,   7 ,  2 })
AADD(aDBf,{ 'IDVPOSLA'            , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'OSNBOL'              , 'N' ,  11 ,  4 })
#endif
AADD(aDBf,{ 'IDSTRSPR'            , 'C' ,   3 ,  0 })
AADD(aDBf,{ 'IDOPSST'             , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'IDOPSRAD'            , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'POL'                 , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'MATBR'               , 'C' ,  13 ,  0 })
AADD(aDBf,{ 'DATOD'               , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'brknjiz'             , 'C' ,  12,   0 })
AADD(aDBf,{ 'brtekr'              , 'C' ,  20,   0 })
AADD(aDBf,{ 'Isplata'             , 'C' ,   2,   0 })
AADD(aDBf,{ 'IdBanka'             , 'C' ,   6,   0 })
AADD(aDBf,{ 'K1'                  , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'K2'                  , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'K3'                  , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'K4'                  , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'POL'                 , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'RMJESTO'             , 'C' ,  30 ,  0 })
AADD(aDBf,{ 'POROL'               , 'N' ,   5 ,  2 })
#ifdef CPOR
  AADD(aDBf,{ 'ULICA'              , 'C' ,  35 ,  0 })
  AADD(aDBf,{ 'RBRPIO'             , 'C' ,  14 ,  0 })
#endif
if !file(KUMPATH+"RADN.dbf")
   DBCREATE2(KUMPATH+'RADN.DBF',aDbf)
endif
if !file(PRIVPATH+"_RADN.dbf")
   DBCREATE2(PRIVPATH+'_RADN.DBF',aDbf)
endif

CREATE_INDEX("1","id",KUMPATH+"RADN")
CREATE_INDEX("2","naz",KUMPATH+"RADN")

*********  RADKR.DBF   ***********
aDbf:={}
#IFDEF CPOR
AADD(aDBf,{ 'IDRadn'              , 'C' ,   13 ,  0 })
#ELSE
AADD(aDBf,{ 'IDRadn'              , 'C' ,   6 ,  0 })
#ENDIF
AADD(aDBf,{ 'Mjesec'              , 'N' ,   2 ,  0 })
AADD(aDBf,{ 'Godina'              , 'N' ,   4 ,  0 })
#ifdef CPOR
AADD(aDBf,{ 'IdKred'              , 'C' ,   10 ,  0 })
#else
AADD(aDBf,{ 'IdKred'              , 'C' ,   6 ,  0 })
#endif
AADD(aDBf,{ 'Iznos'               , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'Placeno'             , 'N' ,  12 ,  2 })
#ifdef CPOR
 AADD(aDBf,{ 'PMjesec'              , 'N' ,   2 ,  0 })
 AADD(aDBf,{ 'PGodina'              , 'N' ,   4 ,  0 })
 AADD(aDBf,{ 'NaOsnovu'            , 'C' ,  10 ,  0 })
#else
 AADD(aDBf,{ 'NaOsnovu'            , 'C' ,  20 ,  0 })
#endif

if !file(KUMPATH+"RADKR.dbf")
   DBCREATE2(KUMPATH+'RADKR.DBF',aDbf)
endif
if !file(PRIVPATH+"_RADKR.dbf")
   DBCREATE2(PRIVPATH+'_RADKR.DBF',aDbf)
endif


CREATE_INDEX("1","str(godina)+str(mjesec)+idradn+idkred+naosnovu",KUMPATH+"RADKR")
CREATE_INDEX("2","idradn+idkred+naosnovu+str(godina)+str(mjesec)",KUMPATH+"RADKR")
CREATE_INDEX("3","idkred+naosnovu+idradn+str(godina)+str(mjesec)",KUMPATH+"RADKR")

// radi POR-LD
CREATE_INDEX("4","naosnovu",KUMPATH+"RADKR")

#ifdef CPOR
CREATE_INDEX("PGM","idradn+str(pgodina)+str(pmjesec)",KUMPATH+"RADKR")
CREATE_INDEX("PGM2","str(pgodina)+str(pmjesec)",KUMPATH+"RADKR")
#endif


#ifdef CPOR

aDbf:={}
AADD(aDBf,{ 'NaOsnovu'             , 'C' ,  10 ,  0 })
// varijanta -1 standardno
// varijanta -2 starateljstvo
AADD(aDBf,{ 'IDRADN'               , 'C' ,  13 ,  0 })
AADD(aDBf,{ 'Varijanta'            , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'Datum'                , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'DatPodn'              , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'DatPPra'              , 'D' ,   8 ,  0 })
// datum podnoçenja zahtjeva
AADD(aDBf,{ 'DatKPra'              , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'DatRodj'              , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'DatZapos'             , 'D' ,   8 ,  0 })
AADD(aDBf,{ 'PREZDJETE'            , 'C' ,  20 ,  0 })
AADD(aDBf,{ 'IMEDJETE'             , 'C' ,  15 ,  0 })
AADD(aDBf,{ 'POL'                  , 'C' ,   1 ,  0 })
// prosjecna plata
AADD(aDBf,{ 'dokazi'               , 'M' ,  10 ,  0 })
AADD(aDBf,{ 'PREKBroj'             , 'C' ,  10 ,  0 })
AADD(aDBf,{ 'PREKDatRj'            , 'D' ,   8 ,  0 })  // datum rjesenja prekida
AADD(aDBf,{ 'PREKDatPoc'           , 'D' ,   8 ,  0 })  // datum pocetka prestanka prava
AADD(aDBf,{ 'RazlPrek'             , 'M' ,  10 ,  0 })
if !file(KUMPATH+"RJES.DBF")
   DBCREATE2(KUMPATH+'RJES.DBF',aDbf)
endif
CREATE_INDEX("NAOSNOVU","NAOSNOVU+IDRADN",KUMPATH+"RJES")
CREATE_INDEX("PREKBROJ","PREKBROJ+IDRADN",KUMPATH+"RJES")
#endif


if !file(KUMPATH+"REKLD.DBF")
  ************ rekapitulacija *************
  aDbf:={  {"GODINA"     ,  "C" ,  4, 0} ,;
           {"MJESEC"     ,  "C" ,  2, 0} ,;
           {"ID"         ,  "C" , 30, 0} ,;
           {"opis"       ,  "C" , 20, 0} ,;
           {"iznos1"     ,  "N" , 18, 4} ,;
           {"iznos2"     ,  "N" , 18, 4} ;
          }
  #ifdef CPOR
    AADD( aDbf , {"idpartner"  ,  "C" , 10, 0} )
  #else
    AADD( aDbf , {"idpartner"  ,  "C" ,  6, 0} )
  #endif
  DBCREATE2(KUMPATH+"REKLD.DBF",aDbf)
endif

  CREATE_INDEX("1","godina+mjesec+id",KUMPATH+"REKLD")


if !file(PRIVPATH+"OPSLD.DBF")
  aDbf:={   {"ID"    , "C" ,  1, 0},;
            {"IDOPS" , "C" ,  4, 0},;
            {"IZNOS" , "N" , 18, 4},;
            {"IZNOS2", "N" , 18, 4},;
            {"LJUDI" , "N" ,  4, 0};
          }
  DBCREATE2(PRIVPATH+"OPSLD.DBF",aDbf)
endif

  CREATE_INDEX("1","id+idops",PRIVPATH+"OPSLD")


if !file(SIFPATH+"PAROBR.DBF")
   ************ tipovi primanja *************
   aDBf:={}
   AADD(aDBf,{ 'ID'                  , 'C' ,   2 ,  0 })  // mjesec
   AADD(aDBf,{ 'NAZ'                 , 'C' ,  10 ,  0 })
   AADD(aDBf,{ 'IDRJ'                , 'C' ,   2 ,  0 })
   AADD(aDBf,{ 'VrBod'               , 'N' ,  15 ,  5 })
   AADD(aDBf,{ 'K1'                  , 'N' ,   11 ,  6 })
   AADD(aDBf,{ 'K2'                  , 'N' ,   11 ,  6 })
   AADD(aDBf,{ 'K3'                  , 'N' ,   9 ,  5 })
   AADD(aDBf,{ 'K4'                  , 'N' ,   6 ,  3 })
   AADD(aDBf,{ 'PROSLD'              , 'N' ,  12 ,  2 })
   DBCREATE2(SIFPATH+'PAROBR.DBF',aDbf)
endif

IF lVOBrisiCDX
  DelSve("PAROBR.CDX",trim(cDirSif))
ENDIF
IF lViseObr
  CREATE_INDEX("ID","id+obr",SIFPATH+"PAROBR")
ELSE
  CREATE_INDEX("ID","id",SIFPATH+"PAROBR")
ENDIF

************ tipovi primanja *************
aDBf:={}
AADD(aDBf,{ 'ID'                  , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'NAZ'                 , 'C' ,  20 ,  0 })
AADD(aDBf,{ 'Aktivan'             , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'Fiksan'              , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'UFS'                 , 'C' ,   1 ,  0 })  // u fond sati
AADD(aDBf,{ 'UNeto'               , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'Koef1'               , 'N' ,   5 ,  2 })
AADD(aDBf,{ 'Formula'             , 'C' , 200 ,  0 })
AADD(aDBf,{ 'OPIS'                , 'C' ,   8 ,  0 })

if !file(SIFPATH+"TIPPR.DBF")
   DBCREATE2(SIFPATH+'TIPPR.DBF',aDbf)
endif
CREATE_INDEX("ID","id",SIFPATH+"TIPPR")

if !file(SIFPATH+"TIPPR2.DBF")
   DBCREATE2(SIFPATH+'TIPPR2.DBF',aDbf)
endif
CREATE_INDEX("ID","id",SIFPATH+"TIPPR2")

if !file(KUMPATH+"RJ.DBF")
   ************ tipovi primanja *************
   aDBf:={}
   AADD(aDBf,{ 'ID'                  , 'C' ,   2 ,  0 })
   AADD(aDBf,{ 'NAZ'                 , 'C' ,  35 ,  0 })
   DBCREATE2(KUMPATH+'RJ.DBF',aDbf)
endif
CREATE_INDEX("ID","id",KUMPATH+"RJ")

************ kreditori *************
aDBf:={}
#ifdef CPOR
AADD(aDBf,{ 'ID'                  , 'C' ,   10 ,  0 })
#else
AADD(aDBf,{ 'ID'                  , 'C' ,   6 ,  0 })
#endif
AADD(aDBf,{ 'NAZ'                 , 'C' ,  30 ,  0 })
AADD(aDBf,{ 'ZIRO'                , 'C' ,  20 ,  0 })
AADD(aDBf,{ 'ZIROD'               , 'C' ,  20 ,  0 })
AADD(aDBf,{ 'TELEFON'             , 'C' ,  20 ,  0 })
AADD(aDBf,{ 'ADRESA'              , 'C' ,  30 ,  0 })
if !file(SIFPATH+"KRED.DBF")
   DBCREATE2(SIFPATH+'KRED.DBF',aDbf)
endif
if !file(PRIVPATH+"_KRED.DBF")
   DBCREATE2(PRIVPATH+'_KRED.DBF',aDbf)
endif
CREATE_INDEX("ID","id",SIFPATH+"KRED")
CREATE_INDEX("NAZ","naz",SIFPATH+"KRED")

if !file(SIFPATH+"OPS.DBF")
   ************ tipovi primanja *************
   aDBf:={}
   AADD(aDBf,{ 'ID'                  , 'C' ,   4 ,  0 })
   AADD(aDBf,{ 'IDJ'                 , 'C' ,   3 ,  0 })
   AADD(aDBf,{ 'IDKAN'               , 'C' ,   2 ,  0 })
   AADD(aDBf,{ 'IDN0'                , 'C' ,   1 ,  0 })
   AADD(aDBf,{ 'NAZ'                 , 'C' ,  20 ,  0 })
   DBCREATE2(SIFPATH+'OPS.DBF',aDbf)
endif

CREATE_INDEX("ID","id",SIFPATH+"OPS")
CREATE_INDEX("IDJ","idj",SIFPATH+"OPS")
CREATE_INDEX("IDKAN","idkan",SIFPATH+"OPS")
CREATE_INDEX("IDN0","idN0",SIFPATH+"OPS")
CREATE_INDEX("NAZ","naz",SIFPATH+"OPS")

if !file(SIFPATH+"POR.DBF")
   ************ tipovi primanja *************
   aDBf:={}
   AADD(aDBf,{ 'ID'                  , 'C' ,   2 ,  0 })
   AADD(aDBf,{ 'NAZ'                 , 'C' ,  20 ,  0 })
   AADD(aDBf,{ 'IZNOS'               , 'N' ,   5 ,  2 })
   AADD(aDBf,{ 'DLIMIT'              , 'N' ,  12 ,  2 })
   AADD(aDBf,{ 'POOPST'              , 'C' ,   1 ,  0 })
   DBCREATE2(SIFPATH+'POR.DBF',aDbf)
endif

CREATE_INDEX("ID","id",SIFPATH+"POR")

if !file(SIFPATH+"DOPR.DBF")
   ************ tipovi primanja *************
   aDBf:={}
   AADD(aDBf,{ 'ID'                  , 'C' ,   2 ,  0 })
   AADD(aDBf,{ 'NAZ'                 , 'C' ,  20 ,  0 })
   AADD(aDBf,{ 'IZNOS'               , 'N' ,   5 ,  2 })
   AADD(aDBf,{ 'IdKBenef'            , 'C' ,   1 ,  0 })
   AADD(aDBf,{ 'DLIMIT'              , 'N' ,  12 ,  2 })
   AADD(aDBf,{ 'POOPST'              , 'C' ,   1 ,  0 })
   DBCREATE2(SIFPATH+'DOPR.DBF',aDbf)
endif

CREATE_INDEX("ID","id",SIFPATH+"DOPR")


************ tabela ld *************
aDBf:={}
AADD(aDBf,{ 'Godina'              , 'N' ,   4 ,  0 })
AADD(aDBf,{ 'IDRJ'                , 'C' ,   2 ,  0 })
#IFDEF CPOR
AADD(aDBf,{ 'IDRADN'              , 'C' ,   13 ,  0 })
#ELSE
AADD(aDBf,{ 'IDRADN'              , 'C' ,   6 ,  0 })
#ENDIF
AADD(aDBf,{ 'Mjesec'              , 'N' ,   2 ,  0 })
AADD(aDBf,{ 'BRBOD'               , 'N' ,  11 ,  2 })
AADD(aDBf,{ 'IdStrSpr'            , 'C' ,   3 ,  0 })
AADD(aDBf,{ 'IdVPosla'            , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'KMinRad'             , 'N' ,   5 ,  2 })
AADD(aDBf,{ 'S01'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I01'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S02'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I02'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S03'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I03'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S04'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I04'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S05'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I05'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S06'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I06'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S07'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I07'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S08'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I08'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S09'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I09'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S10'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I10'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S11'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I11'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S12'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I12'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S13'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I13'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S14'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I14'                 , 'N' ,  12 ,  2 })
#ifndef CPOR
// ako nije POR-LD
AADD(aDBf,{ 'S15'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I15'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S16'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I16'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S17'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I17'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S18'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I18'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S19'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I19'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S20'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I20'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S21'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I21'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S22'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I22'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S23'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I23'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S24'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I24'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S25'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I25'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S26'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I26'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S27'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I27'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S28'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I28'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S29'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I29'                 , 'N' ,  12 ,  2 })
AADD(aDBf,{ 'S30'                 , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'I30'                 , 'N' ,  12 ,  2 })
#else
 AADD(aDBf,{ 'IDKRED'                 , 'C' ,  10 ,  0 })
#endif
AADD(aDBf,{ 'USATI'               , 'N' ,   8 ,  1 })
AADD(aDBf,{ 'UNETO'               , 'N' ,  13 ,  2 })
AADD(aDBf,{ 'UODBICI'             , 'N' ,  13 ,  2 })
AADD(aDBf,{ 'UIZNOS'              , 'N' ,  13 ,  2 })
if !file(KUMPATH+'LD.DBF')
 DBCREATE2(KUMPATH+'LD.DBF',aDbf)
endif

IF lVOBrisiCDX
  DelSve("LD.CDX",trim(cDirRad))
ENDIF

IF lViseObr
  // polje OBR koristimo u indeksima
  CREATE_INDEX("1","str(godina)+idrj+str(mjesec)+obr+idradn",KUMPATH+"LD")
  CREATE_INDEX("2","str(godina)+str(mjesec)+obr+idradn+idrj",KUMPATH+"LD")
  CREATE_INDEX("3","str(godina)+idrj+idradn",KUMPATH+"LD")
  CREATE_INDEX("4","str(godina)+idradn+str(mjesec)+obr",KUMPATH+"LD")
  CREATE_INDEX("1U","str(godina)+idrj+str(mjesec)+idradn",KUMPATH+"LD")
  CREATE_INDEX("2U","str(godina)+str(mjesec)+idradn+idrj",KUMPATH+"LD")
ELSE
  // standardno: ne postoji polje OBR
  CREATE_INDEX("1","str(godina)+idrj+str(mjesec)+idradn",KUMPATH+"LD")
  CREATE_INDEX("2","str(godina)+str(mjesec)+idradn+idrj",KUMPATH+"LD")
  CREATE_INDEX("3","str(godina)+idrj+idradn",KUMPATH+"LD")
  CREATE_INDEX("4","str(godina)+idradn+str(mjesec)",KUMPATH+"LD")
ENDIF

// #ifdef CPOR
CREATE_INDEX("RADN","idradn",KUMPATH+"LD")
// #endif

#ifdef CPOR
 if !file(KUMPATH+"LDNO.DBF")
    AADD(aDBf, { "RAZLOG","C",20,0 } )      // razlog neisplacivanja
    DBCREATE2(KUMPATH+"LDNO.DBF",aDbf)
    ASIZE(aDbf,LEN(aDbf)-1)
 endif
 CREATE_INDEX("1","str(godina)+idrj+str(mjesec)+idradn",KUMPATH+"LDNO")
 CREATE_INDEX("2","str(godina)+str(mjesec)+idradn+idrj",KUMPATH+"LDNO")
 CREATE_INDEX("3","str(godina)+idrj+idradn",KUMPATH+"LDNO")
 CREATE_INDEX("4","str(godina)+idradn+str(mjesec)",KUMPATH+"LDNO")
#endif

if !file(PRIVPATH+"LDSM.DBF")
   AADD(aDBf, { "Obr","C",1,0 } )      // obracun
   DBCREATE2(PRIVPATH+"LDSM.DBF",aDbf)
endif


CREATE_INDEX("1","Obr+str(godina)+str(mjesec)+idradn+idrj",PRIVPATH+"LDSM")
CREATE_INDEX("RADN","idradn",PRIVPATH+"LDSM")

if !file(PRIVPATH+"_LD.DBF")
   DBCREATE2(PRIVPATH+"_LD.DBF",aDbf)
endif


if !file(SIFPATH+"STRSPR.DBF")
    aDbf:={ {"id","C",3,0} ,;
            {"naz","C",20,0} ,;
            {"naz2","C",6,0} ;
                }
     DBCREATE2(SIFPATH+"STRSPR.DBF",aDbf)
endif


CREATE_INDEX("ID","id",SIFPATH+"strspr")

if !file(SIFPATH+"KBENEF.DBF")
   aDbf:={ {"id","C",1,0} ,;
           {"naz","C",8,0} ,;
           {"iznos","N",5,2} ;
         }
   DBCREATE2(SIFPATH+"KBENEF",aDbf)
endif
CREATE_INDEX("ID","id",SIFPATH+"KBENEF")


if !file(SIFPATH+"VPOSLA.DBF")  // vrste posla
   aDbf:={  {"id","C",2,0}   ,;
            {"naz","C",20,0} ,;
            {"idkbenef","C",1,0} ;
         }
   DBCREATE2(SIFPATH+"VPOSLA",aDbf)
endif
CREATE_INDEX("ID","id",SIFPATH+"VPOSLA")

#ifdef CPOR
 if !file(PRIVPATH+"PRIPNO.DBF")
   aDbf:={ { "MJESEC"    , "N" ,  2 ,  0 } ,;
           { "GODINA"    , "N" ,  4 ,  0 } ,;
           { "IDRADN"    , "C" , 13 ,  0 } ,;
           { "IDRJ"      , "C" ,  2 ,  0 } ,;
           { "RBR"       , "C" ,  4 ,  0 } ,;
           { "RAZLOG"    , "C" , 20 ,  0 } ;
         }
    DBCREATE2(PRIVPATH+"PRIPNO.DBF",aDbf)
 endif
#endif

//RADSIHT
aDbf:={}
AADD(aDBf,{ 'Godina'              , 'N' ,   4 ,  0 })
AADD(aDBf,{ 'Mjesec'              , 'N' ,   2 ,  0 })
AADD(aDBf,{ 'Dan'                 , 'N' ,   2 ,  0 })
AADD(aDBf,{ 'DanDio'              , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'IDRJ'                , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'IDRADN'              , 'C' ,   6 ,  0 })
AADD(aDBf,{ 'IDTipPR'             , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'BRBOD'               , 'N' ,  11 ,  2 })
AADD(aDBf,{ 'IdNorSiht'           , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'Izvrseno'            , 'N' ,  14 ,  3 })
AADD(aDBf,{ 'Bodova'              , 'N' ,  14 ,  2 })
if !file(KUMPATH+"RADSIHT.DBF")
   DBCREATE2(KUMPATH+"RADSIHT.DBF",aDBF)
endif

CREATE_INDEX("1","str(godina)+str(mjesec)+idradn+idrj+str(dan)+dandio+idtippr",KUMPATH+"RADSIHT")


//NORSIHT - norme u sihtarici - koristi se vjerovatno samo kod rada u normi
aDbf:={}
AADD(aDBf,{ 'ID'                , 'C' ,   4 ,  0 })
AADD(aDBf,{ 'NAZ'               , 'C' ,  30 ,  0 })
AADD(aDBf,{ 'JMJ'               , 'C' ,   3 ,  0 })
AADD(aDBf,{ 'Iznos'             , 'N' ,   8 ,  2 })
AADD(aDBf,{ 'N1'                , 'N' ,   6 ,  2 })
AADD(aDBf,{ 'K1'                , 'C' ,   1 ,  0 })
AADD(aDBf,{ 'K2'                , 'C' ,   2 ,  0 })
if !file(KUMPATH+"NORSIHT.DBF")
   DBCREATE2(KUMPATH+"NORSIHT.DBF",aDBF)
endif
CREATE_INDEX("ID","id",KUMPATH+"NORSIHT")
CREATE_INDEX("NAZ","NAZ",KUMPATH+"NORSIHT")

//TPRSIHT   - tipovi primanja koji odradjuju sihtaricu
aDbf:={}
AADD(aDBf,{ 'ID'                , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'NAZ'               , 'C' ,  30 ,  0 })
AADD(aDBf,{ 'K1'                , 'C' ,   1 ,  0 })
// K1="F" - po formuli
//    " " - direktno se unose bodovi
AADD(aDBf,{ 'K2'                , 'C' ,   2 ,  0 })
AADD(aDBf,{ 'K3'                , 'C' ,   3 ,  0 })
AADD(aDBf,{ 'FF'                , 'C' ,  30 ,  0 })
if !file(KUMPATH+"TPRSIHT.DBF")
   DBCREATE2(KUMPATH+"TPRSIHT.DBF",aDBF)
endif

CREATE_INDEX("ID","id",KUMPATH+"TPRSIHT")
CREATE_INDEX("NAZ","NAZ",KUMPATH+"TPRSIHT")


if !file(SIFPATH+"SIFK.dbf")
   aDbf:={}
   AADD(aDBf,{ 'ID'                  , 'C' ,   8 ,  0 })
   AADD(aDBf,{ 'SORT'                , 'C' ,   2 ,  0 })
   AADD(aDBf,{ 'NAZ'                 , 'C' ,  25 ,  0 })
   AADD(aDBf,{ 'Oznaka'              , 'C' ,   4 ,  0 })
   AADD(aDBf,{ 'Veza'                , 'C' ,   1 ,  0 })
   AADD(aDBf,{ 'Unique'              , 'C' ,   1 ,  0 })
   AADD(aDBf,{ 'Izvor'               , 'C' ,  15 ,  0 })
   AADD(aDBf,{ 'Uslov'               , 'C' , 100 ,  0 })
   AADD(aDBf,{ 'Duzina'              , 'N' ,   2 ,  0 })
   AADD(aDBf,{ 'Decimal'             , 'N' ,   1 ,  0 })
   AADD(aDBf,{ 'Tip'                 , 'C' ,   1 ,  0 })
   AADD(aDBf,{ 'KVALID'              , 'C' , 100 ,  0 })
   AADD(aDBf,{ 'KWHEN'               , 'C' , 100 ,  0 })
   AADD(aDBf,{ 'UBROWSU'             , 'C' ,   1 ,  0 })
   AADD(aDBf,{ 'EDKOLONA'            , 'N' ,   2 ,  0 })
   AADD(aDBf,{ 'K1'                  , 'C' ,   1 ,  0 })
   AADD(aDBf,{ 'K2'                  , 'C' ,   2 ,  0 })
   AADD(aDBf,{ 'K3'                  , 'C' ,   3 ,  0 })
   AADD(aDBf,{ 'K4'                  , 'C' ,   4 ,  0 })

   // Primjer:
   // ID   = ROBA
   // NAZ  = Barkod
   // Oznaka = BARK
   // VEZA  = N ( 1 - moze biti samo jedna karakteristika, N - n karakteristika)
   // UNIQUE = D - radi se o jedinstvenom broju
   // Izvor =  ( sifrarnik  koji sadrzi moguce vrijednosti)
   // Uslov =  ( za koje grupe artikala ova karakteristika je interesantna
   // DUZINA = 13
   // Tip = C ( N numericka, C - karakter, D datum )
   // Valid = "ImeFje()"
   // validacija  mogu biti vrijednosti A,B,C,D
   //             aktiviraj funkciju ImeFje()
   dbcreate2(SIFPATH+'SIFK.DBF',aDbf)
endif
CREATE_INDEX("ID","id+SORT+naz",SIFPATH+"SIFK")
CREATE_INDEX("ID2","id+oznaka",SIFPATH+"SIFK")
CREATE_INDEX("NAZ","naz",SIFPATH+"SIFK")




if !file(SIFPATH+"SIFV.dbf")  // sifrarnici - vrijednosti karakteristika
   aDbf:={}
   AADD(aDBf,{ 'ID'                  , 'C' ,   8 ,  0 })
   AADD(aDBf,{ 'Oznaka'              , 'C' ,   4 ,  0 })
   AADD(aDBf,{ 'IdSif'               , 'C' ,  15 ,  0 })
   AADD(aDBf,{ 'NAZ'                 , 'C' ,  50 ,  0 })
   // Primjer:
   // ID  = ROBA
   // OZNAKA = BARK
   // IDSIF  = 2MON0005
   // NAZ = 02030303030303

   dbcreate2(SIFPATH+'SIFV.DBF',aDbf)
endif
CREATE_INDEX("ID","id+oznaka+IdSif+Naz",SIFPATH+"SIFV")
CREATE_INDEX("IDIDSIF","id+IdSif",SIFPATH+"SIFV")
//  ROBA + BARK + 2MON0001

CREATE_INDEX("NAZ","id+oznaka+naz",SIFPATH+"SIFV")


if !file(SIFPATH+"BANKE.DBF")
        *********  BANKE.DBF   ***********
        aDbf:={}
        AADD(aDBf,{ 'ID'                  , 'C' ,   3 ,  0 })
        AADD(aDBf,{ 'NAZ'                 , 'C' ,  45 ,  0 })
        AADD(aDBf,{ 'Mjesto'              , 'C' ,  20 ,  0 })
        DBCREATE2(SIFPATH+'BANKE.DBF',aDbf)
endif

CREATE_INDEX("ID","id", SIFPATH+"BANKE")
CREATE_INDEX("NAZ","naz", SIFPATH+"BANKE")



*********************************
function Obaza(i)
*
*********************************

#include "p:\clp52\include\obaz.ch"

if i==F_RADN  ; O_RADN  ; endif
if i==F_PAROBR; O_PAROBR; endif
if i==F_TIPPR ; O_TIPPR ; endif
if i==F_TIPPR2; O_TIPPR2; endif
if i==F_LD    ; O_LD    ; endif
if i==F_STRSPR; O_STRSPR; endif
if i==F_KBENEF; O_KBENEF; endif
if i==F_VPOSLA; O_VPOSLA; endif
if i==F_OPS   ; O_OPS   ; endif
if i==F_POR   ; O_POR   ; endif
if i==F_DOPR  ; O_DOPR  ; endif
if i==F_RJ    ; O_RJ    ; endif
if i==F_KRED  ; O_KRED  ; endif
if i==F_RADKR ; O_RADKR ; endif
if i==F_LDSM  ; O_LDSM  ; endif
if i==F__LD   ; O__LD   ; endif
if i==F__RADN ; O__RADN ; endif

if i==F__RADKR; O__RADKR; endif
if i==95      ; O_OPSLD ; endif
if i==F_REKLD ; O_REKLD ; endif
if i==F__KRED ; O__KRED ; endif

#ifdef CPOR
 if i==F_PRIPNO ; O_PRIPNO ; endif
 if i==F_LDNO   ; O_LDNO   ; endif

#else

 if i==F_TPRSIHT  ;  O_TPRSIHT ; endif
 if i==F_NORSIHT  ;  O_NORSIHT ; endif
 if i==F_RADSIHT  ;  O_RADSIHT ; endif
 if i==F_SIFK     ;  O_SIFK    ; endif
 if i==F_SIFV     ;  O_SIFV    ; endif

#endif

return NIL

******************
function UcitajParams()
*
******************
return

****************************
function Sregg()
*
* registracija modula
****************************

sreg("LD.EXE","LD")
return


#include "RDDINIT.CH"

#ifdef CAX
function truename(cc)  // sklonjena iz CTP
return cc
#endif

#ifdef EXT
function truename(cc)  // sklonjena iz CTP
return cc
#endif


#ifdef C52
********************************
function OKumul(nArea,cStaza,cIme,nIndexa,cDefault)
*
* F:\SIGMA\FIN -> C:\SIGMA\FIN
* 5.2
*********************************
local cPath,cScreen

if cDefault==NIL
  cDefault:="0"
endif

select (nArea)
if gKesiraj $ "CD"
  cPath:=strtran(cStaza,LEFT(cStaza,3),gKesiraj+":\")

  DirMak2(cPath)  // napravi odrediçni direktorij

  if cDefault!="0"
    if !file( cPath+cIme+".DBF") .or. Pitanje(,"Osvjeziti podatke za "+cIme, cDefault )=="D"
     save screen to cScr
     cls
     ? "Molim sacekajte prenos podataka na vas racunar "
     ? "radi brzeg pregleda podataka"
     ?
     ? "Ovaj racunar NE KORISTITE za unos novih podataka !"
     ?
     close all
     Copysve(cIme+"*.DB?",cStaza,cPath)
     Copysve(cIme+"*.CDX",cStaza,cPath)
     ?
     ? "pritisni nesto za nastavak ..."
     inkey(10)
     restore screen from cScr
   endif
  endif

else
  cPath:=cStaza
endif
cPath:=cPath+cIme
use  (cPath)
return NIL

#else

********************************

function OKumul(nArea,cStaza,cIme,nIndexa,cDefault)
*
* F:\SIGMA\FIN -> C:\SIGMA\FIN
* CAX !!!
*********************************
local cPath,cScreen

if cDefault==NIL
  cDefault:="0"
endif

select (nArea)

if used(); return; endif
// CAX - samo jednom otvori !!!!!!!!!!!!!!!!!

if gKesiraj $ "CD"
  cPath:=strtran(cStaza,LEFT(cStaza,3),gKesiraj+":\")

  DirMak2(cPath)  // napravi odrediçni direktorij

  if cDefault!="0"
    if !file( cPath+cIme+".DBF") .or. Pitanje(,"Osvjeziti podatke za "+cIme, cDefault )=="D"
     save screen to cScr
     cls
     ? "Molim sacekajte prenos podataka na vas racunar "
     ? "radi brzeg pregleda podataka"
     ?
     ? "Ovaj racunar NE KORISTITE za unos novih podataka !"
     ?
     close all
     Copysve(cIme+"*.DB?",cStaza,cPath)
     Copysve(cIme+"*.CDX",cStaza,cPath)
     ?
     ? "pritisni nesto za nastavak ..."
     inkey(10)
     restore screen from cScr
   endif
  endif

else
  cPath:=cStaza
endif
cPath:=cPath+cIme
use  (cPath)
return NIL

#endif


PROCEDURE KonvZn()
 LOCAL cIz:="7", cU:="8", aPriv:={}, aKum:={}, aSif:={}
 LOCAL GetList:={}, cSif:="D", cKum:="D", cPriv:="D"

 IF !SigmaSif("KZ      ")
   RETURN
 ENDIF

 cSamoid:="2"
 Box(,8,55)
  @ m_x+2, m_y+2 SAY "Trenutni standard (7/8)           " GET cIz   VALID   cIz$"78"  PICT "9"
  @ m_x+3, m_y+2 SAY "Konvertovati u standard (7/8/A)   " GET cU    VALID    cU$"78A" PICT "@!"
  @ m_x+5, m_y+2 SAY "Konvertovati sifrarnike (D/N)     " GET cSif  VALID  cSif$"DN"  PICT "@!"
  @ m_x+6, m_y+2 SAY "Konvertovati radne baze (D/N)     " GET cKum  VALID  cKum$"DN"  PICT "@!"
  @ m_x+7, m_y+2 SAY "Konvertovati priv.baze  (D/N)  " GET cPriv VALID cPriv$"DN"  PICT "@!"
  @ m_x+8, m_y+2 SAY "Konvertovati ID/OPISE/SVE (1/2/3) " GET cSamoid VALID cSamoid$"123"  PICT "@!"
  READ
  IF LASTKEY()==K_ESC; BoxC(); RETURN; ENDIF
  IF Pitanje(,"Jeste li sigurni da zelite izvrsiti konverziju (D/N)","N")=="N"
    BoxC(); RETURN
  ENDIF
 BoxC()

 aSif  := { F_RADN, F_PAROBR, F_TIPPR, F_TIPPR2, F_LD, F_STRSPR, F_KBENEF,;
            F_VPOSLA, F_OPS, F_POR, F_DOPR, F_RJ, F_KRED, F_RADKR, F_LDSM }
 aPriv := { }
 aKum  := { }

 IF cSif  == "N"; aSif  := {}; ENDIF
 IF cKum  == "N"; aKum  := {}; ENDIF
 IF cPriv == "N"; aPriv := {}; ENDIF

 KZNbaza(aPriv,aKum,aSif,cIz,cU, cSamoid)
RETURN


function ostalef()


PROC TestViseObr()

  IF !FILE(KUMPATH+'LD.DBF')
    lViseObr:=.f.
    lVOBrisiCDX := .f.
    RETURN
  ELSE
    select (F_LD); use (KUMPATH+"LD")
  ENDIF
  IF FIELDPOS("OBR")<>0
    lViseObr:=.t.
  ELSE
    lViseObr:=.f.
  ENDIF
  IF lViseObr .and. ! ( "OBR" $ UPPER(INDEXKEY(3)) )
    lVOBrisiCDX := .t.
    IF Pitanje(,"Polje obr=' ' u LD.DBF zamijeniti sa '1' ? (D/N)","N") == "D"
      GO TOP
      DO WHILE !EOF()
        IF EMPTY(obr)
          Scatter(); _obr:="1"; Gather()
        ENDIF
        SKIP 1
      ENDDO
    ENDIF
  ELSE
    lVOBrisiCDX := .f.
  ENDIF
  USE
RETURN

function sklonisezonu()

function O_log()

function reindex_all()

function o_nar()

proc help2()

