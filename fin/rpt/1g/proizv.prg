#include "\cl\sigma\fmk\fin\fin.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fin/rpt/1g/proizv.prg,v $
 * $Author: sasa $ 
 * $Revision: 1.3 $
 * $Log: proizv.prg,v $
 * Revision 1.3  2002/06/20 13:31:52  sasa
 * no message
 *
 * Revision 1.2  2002/06/20 13:22:29  sasa
 * no message
 *
 *
 */


/*! \file fmk/fin/rpt/1g/proizv.prg
 *  \brief Proizvoljni izvjestaji
 */

/*! \fn ProIzv()
 *  \brief Proizvoljni izvjestaji
 */
 
function ProIzv()
*{
if !IzvrsenIn(,,"PROIZV", .t. )
  MsgBeep("Modul PROIZV nije registrovan !")
  return
endif

PRIVATE cDPnaz1 := "", cDPx1 :="", cDPf1 :="D"
PRIVATE cDPnaz2 := "", cDPx2 :="", cDPf2 :="D"
PRIVATE cDPnaz3 := "", cDPx3 :="", cDPf3 :="D"
PRIVATE cDPnaz4 := "", cDPx4 :="", cDPf4 :="D"
PRIVATE cDPnaz5 := "", cDPx5 :="", cDPf5 :="D"
PRIVATE cDPnaz6 := "", cDPx6 :="", cDPf6 :="D"
PRIVATE cDPnaz7 := "", cDPx7 :="", cDPf7 :="D"
PRIVATE cDPnaz8 := "", cDPx8 :="", cDPf8 :="D"
PRIVATE cDPnaz9 := "", cDPx9 :="", cDPf9 :="D"
PRIVATE cDPnaz10:= "", cDPx10:="", cDPf10:="D"

#IFDEF CAX
 close all
#ENDIF


PrIz()

RETURN
*}



/*! \fn OtBazPI()
 *  \brief Otvara baze proizvoljnih izvjestaja
 */

function OtBazPI()
*{
O_IZVJE
O_KONIZ
O_KOLIZ
O_ZAGLI
return
*}



/*! \fn GenProIzv()
 *  \brief Generisanje proizvoljnih izvjestaja
 */

function GenProIzv()
*{
LOCAL nPr:=1, lKumSuma:=.f., GetList:={}
 PRIVATE lDvaKonta:=.f.
 PRIVATE lKljuc:=.f.


 // privatne var. koje bi trebalo inicijalizovati iz aplikacije
 // -----------------------------------------------------------
  cGlava:=SPACE(6)
  cFunkc:=SPACE(5)

 // neophodne privatne varijable (pogodno za ELIB-a)
 // -------------------------------------------------
  dOd:=CTOD(""); dDo:=DATE()
  gTabela:=1; cPrikBezDec:="D"; cSaNulama:="D"; nKorZaLands:=-18

  lFunkcija:=.f.
  lIzrazi:=.f.

  aUPredzn  := PARSIRAJ(cPotrazKon,"KONTO","C")
  aUPredzn2 := PARSIRAJ(cPotrazKon,"KONTO2","C")

  // --------------------------
  // POCETAK izvjestajnog upita
  // --------------------------
  O_PARAMS
  Private cSection:="I", cHistory:=" ", aHistory:={}
  RPar("01",@cGlava)
  RPar("02",@cFunkc)
  RPar("03",@dOd)
  RPar("04",@dDo)
  RPar("05",@gTabela)
  RPar("06",@cPrikBezDec)
  RPar("07",@cSaNulama)
  RPar("08",@nKorZaLands)

  RPar("09",@cDPnaz1 )
  RPar("10",@cDPnaz2 )
  RPar("11",@cDPnaz3 )
  RPar("12",@cDPnaz4 )
  RPar("13",@cDPnaz5 )
  RPar("14",@cDPnaz6 )
  RPar("15",@cDPnaz7 )
  RPar("16",@cDPnaz8 )
  RPar("17",@cDPnaz9 )
  RPar("18",@cDPnaz10)
  RPar("19",@cDPx1 )
  RPar("20",@cDPx2 )
  RPar("21",@cDPx3 )
  RPar("22",@cDPx4 )
  RPar("23",@cDPx5 )
  RPar("24",@cDPx6 )
  RPar("25",@cDPx7 )
  RPar("26",@cDPx8 )
  RPar("27",@cDPx9 )
  RPar("28",@cDPx10)
  RPar("29",@cDPf1 )
  RPar("30",@cDPf2 )
  RPar("31",@cDPf3 )
  RPar("32",@cDPf4 )
  RPar("33",@cDPf5 )
  RPar("34",@cDPf6 )
  RPar("35",@cDPf7 )
  RPar("36",@cDPf8 )
  RPar("37",@cDPf9 )
  RPar("38",@cDPf10)
  SELECT PARAMS; USE

  cUIdKonto:=space(7)


  Box(,20,70)
   @ m_x+2,m_y+2 SAY "Glava/RJ (prazno-sve)  " GET cGlava
   @ m_x+3,m_y+2 SAY "Funkcija (prazno-sve)  " GET cFunkc

   @ m_x+4,m_y+2 SAY "Period izvjestavanja od" GET dOd
   @ m_x+5,m_y+2 SAY "                     do" GET dDo

   @ m_x+7,m_y+2 SAY "Konto (prazno svi)     " GET cUIdKonto


   if gNW=="N"
       cIdFirma:=gFirma
       @ m_x+7,m_y+2 SAY "Firma (prazno-sve) " GET cIDFirma
   endif

   if cDPf1=="N" .and. !EMPTY(cDPnaz1)
       cDPx1 :=PADR(cDPx1 , 40)
       @ m_x+ 9,m_y+2 SAY PADR(cDPnaz1,40) GET cDPx1 PICT "@S20"
   endif
   if cDPf2=="N" .and. !EMPTY(cDPnaz2)
       cDPx2 :=PADR(cDPx2 , 40)
       @ m_x+10,m_y+2 SAY PADR(cDPnaz2,40) GET cDPx2 PICT "@S20"
   endif
   if cDPf3=="N" .and. !EMPTY(cDPnaz3)
       cDPx3 :=PADR(cDPx3 , 40)
       @ m_x+11,m_y+2 SAY PADR(cDPnaz3,40) GET cDPx3 PICT "@S20"
   endif
   if cDPf4=="N" .and. !EMPTY(cDPnaz4)
       cDPx4 :=PADR(cDPx4 , 40)
       @ m_x+12,m_y+2 SAY PADR(cDPnaz4,40) GET cDPx4 PICT "@S20"
   endif
   if cDPf5=="N" .and. !EMPTY(cDPnaz5)
       cDPx5 :=PADR(cDPx5 , 40)
       @ m_x+13,m_y+2 SAY PADR(cDPnaz5,40) GET cDPx5 PICT "@S20"
   endif
   if cDPf6=="N" .and. !EMPTY(cDPnaz6)
       cDPx6 :=PADR(cDPx6 , 40)
       @ m_x+14,m_y+2 SAY PADR(cDPnaz6,40) GET cDPx6 PICT "@S20"
   endif
   if cDPf7=="N" .and. !EMPTY(cDPnaz7)
       cDPx7 :=PADR(cDPx7 , 40)
       @ m_x+15,m_y+2 SAY PADR(cDPnaz7,40) GET cDPx7 PICT "@S20"
   endif
   if cDPf8=="N" .and. !EMPTY(cDPnaz8)
       cDPx8 :=PADR(cDPx8 , 40)
       @ m_x+16,m_y+2 SAY PADR(cDPnaz8,40) GET cDPx8 PICT "@S20"
   endif
   if cDPf9=="N" .and. !EMPTY(cDPnaz9)
       cDPx9 :=PADR(cDPx9 , 40)
       @ m_x+17,m_y+2 SAY PADR(cDPnaz9,40) GET cDPx9 PICT "@S20"
   endif
   if cDPf10=="N" .and. !EMPTY(cDPnaz10)
       cDPx10:=PADR(cDPx10, 40)
       @ m_x+18,m_y+2 SAY PADR(cDPnaz10,40) GET cDPx10 PICT "@S20"
   endif

   read



   cDPx1 :=TRIM(cDPx1 )
   cDPx2 :=TRIM(cDPx2 )
   cDPx3 :=TRIM(cDPx3 )
   cDPx4 :=TRIM(cDPx4 )
   cDPx5 :=TRIM(cDPx5 )
   cDPx6 :=TRIM(cDPx6 )
   cDPx7 :=TRIM(cDPx7 )
   cDPx8 :=TRIM(cDPx8 )
   cDPx9 :=TRIM(cDPx9 )
   cDPx10:=TRIM(cDPx10)

  BoxC()

  IF LASTKEY()==K_ESC
    CLOSERET
  ENDIF

  O_PARAMS
  Private cSection:="I",cHistory:=" ",aHistory:={}
  WPar("01",cGlava)
  WPar("02",cFunkc)
  WPar("03",dOd)
  WPar("04",dDo)
  SELECT PARAMS; USE
  // -----------------------
  // KRAJ izvjestajnog upita
  // -----------------------


  // dobro je odmah znati koriste li se uslovi za konta u kolonama
  // jer ce to omoguciti brzi rad na jednostavnijim izvjestajima
  // -------------------------------------------------------------
  SELECT KONIZ
  SET ORDER TO TAG "1"
  SET FILTER TO
  SET FILTER TO izv==cBrI
  GO TOP
  DO WHILE !EOF()
    IF UPPER(LEFT(KONIZ->K,1))=="F"; lFunkcija:=.t.; ENDIF
    IF LEFT(KONIZ->fi,1)=="="; lIzrazi:=.t.; ENDIF
    IF !EMPTY(K2) .or. !EMPTY(ID2) .or. !EMPTY(FI2); lDvaKonta:=.t.; ENDIF
    IF ri<>0 .and. UPPER(LEFT(k,1))=="K"; lKljuc:=.t.; ENDIF
    SKIP 1
  ENDDO

  aKolS:={}
  i:=0
  SELECT KOLIZ
  SET FILTER TO
  SET FILTER TO id==cBrI
  SET ORDER TO TAG "1"
  GO TOP

  PRIVATE cSIzraz:=""

  DO WHILE !EOF()
    IF !EMPTY(KUSLOV)
      ++i
      AADD(aKolS,{"KOL"+ALLTRIM(STR(i)),TRIM(kuslov)+IF(UPPER(k1)=="K","",".and.DATDOK>="+cm2str(dOd)),0,TRIM(sizraz)})
    ENDIF
    IF "KUMSUMA" $ FORMULA
      lKumSuma:=.t.
    ENDIF
    IF !EMPTY(SIZRAZ).and.EMPTY(cSIzraz)
      cSIzraz:=TRIM(sizraz)
    ENDIF
    SKIP 1
  ENDDO


  // --------------------------------------
  // POCETAK kreiranja pomocne baze POM.DBF
  // --------------------------------------
  SELECT (F_POM); USE
  IF ferase(PRIVPATH+"POM.DBF")==-1
    MsgBeep("Ne mogu izbrisati POM.DBF!")
    ShowFError()
  ENDIF
  IF ferase(PRIVPATH+"POM.CDX")==-1
    MsgBeep("Ne mogu izbrisati POM.CDX!")
    ShowFError()
  ENDIF
  aDbf := {}
  AADD (aDbf, {"NRBR"      , "N",  5, 0})
  AADD (aDbf, {"KONTO"     , "C",  7, 0})
  AADD (aDbf, {"IMEKONTA"  , "C", 57, 0})
  IF !lKljuc
    AADD (aDbf, {"PLBUDZET"  , "N", 15, 2})
    AADD (aDbf, {"REBALANS"  , "N", 15, 2})
    AADD (aDbf, {"KUMSUMA"   , "N", 15, 2})
    AADD (aDbf, {"TEKSUMA"   , "N", 15, 2})
    AADD (aDbf, {"KPGSUMA"   , "N", 15, 2})
    AADD (aDbf, {"DUGUJE"    , "N", 15, 2})
    AADD (aDbf, {"POTRAZUJE" , "N", 15, 2})
    AADD (aDbf, {"USLOV"     , "C", 80, 0})
    AADD (aDbf, {"SINT"      , "C",  2, 0})          // "Sn" ili "  "
  ENDIF
  AADD (aDbf, {"PREDZNAK"  , "N",  2, 0})          // "-1" ili " 1"
  AADD (aDbf, {"PODVUCI"   , "C",  1, 0})
  AADD (aDbf, {"K1"        , "C",  1, 0})          //
  AADD (aDbf, {"U1"        , "C",  3, 0})          // npr. >0 ili <0
  AADD (aDbf, {"AOP"       , "C",  5, 0})

  // polja koja se koriste u situaciji kada je neophodno postavljanje
  // dva razlicita uslova(filtera) na jednoj izvjestajnoj stavci
  // ----------------------------------------------------------------
  IF lDvaKonta
    AADD (aDbf, {"KONTO2"    , "C",  7, 0})
    AADD (aDbf, {"PLBUDZET2" , "N", 15, 2})
    AADD (aDbf, {"REBALANS2" , "N", 15, 2})
    AADD (aDbf, {"KUMSUMA2"  , "N", 15, 2})
    AADD (aDbf, {"TEKSUMA2"  , "N", 15, 2})
    AADD (aDbf, {"DUGUJE2"   , "N", 15, 2})
    AADD (aDbf, {"POTRAZUJE2", "N", 15, 2})
    AADD (aDbf, {"USLOV2"    , "C", 80, 0})
    AADD (aDbf, {"SINT2"     , "C",  2, 0})          // "Sn" ili "  "
    AADD (aDbf, {"PREDZNAK2" , "N",  2, 0})          // "-1" ili " 1"
  ENDIF

  // polja koja su neophodna za slucaj razlicitih uslova(filtera) na
  // izvjestajnim kolonama
  // ---------------------------------------------------------------
  IF !EMPTY(aKolS)
    FOR i:=1 TO LEN(aKolS)
      AADD (aDbf, {aKolS[i,1]     , "N", 15, 2})
    NEXT
  ELSEIF lFunkcija
    AADD (aDbf, {"KOL1"      , "N", 15, 2})
    AADD (aDbf, {"KOL2"      , "N", 15, 2})
    AADD (aDbf, {"KOL3"      , "N", 15, 2})
    AADD (aDbf, {"KOL4"      , "N", 15, 2})
    AADD (aDbf, {"KOL5"      , "N", 15, 2})
    AADD (aDbf, {"KOL6"      , "N", 15, 2})
    AADD (aDbf, {"KOL7"      , "N", 15, 2})
    AADD (aDbf, {"KOL8"      , "N", 15, 2})
    AADD (aDbf, {"KOL9"      , "N", 15, 2})
    AADD (aDbf, {"KOL10"     , "N", 15, 2})
    AADD (aDbf, {"KOL11"     , "N", 15, 2})
    AADD (aDbf, {"KOL12"     , "N", 15, 2})
    AADD (aDbf, {"USL1"      , "C", 25, 0})
    AADD (aDbf, {"USL2"      , "C", 25, 0})
    AADD (aDbf, {"USL3"      , "C", 25, 0})
    AADD (aDbf, {"USL4"      , "C", 25, 0})
    AADD (aDbf, {"USL5"      , "C", 25, 0})
    AADD (aDbf, {"USL6"      , "C", 25, 0})
    AADD (aDbf, {"USL7"      , "C", 25, 0})
    AADD (aDbf, {"USL8"      , "C", 25, 0})
    AADD (aDbf, {"USL9"      , "C", 25, 0})
    AADD (aDbf, {"USL10"     , "C", 25, 0})
    AADD (aDbf, {"USL11"     , "C", 25, 0})
    AADD (aDbf, {"USL12"     , "C", 25, 0})
  ENDIF


  DBCREATE2 (PRIVPATH+"POM", aDbf)
  SELECT (F_POM)
#ifdef CAX
  if !used()
    AX_AutoOpen(.f.); usex (PRIVPATH+"pom")  ; AX_AutoOpen(.t.)
  endif
#else
  usex (PRIVPATH+"pom")
#endif

  private cTag:="1"
  INDEX ON KONTO  TAG "1"
  IF lDvaKonta
    private cTag:="2"
    INDEX ON KONTO2 TAG "2"
  ENDIF
  private cTag:="3"
  INDEX ON AOP    TAG "3"
  GO TOP
  // -----------------------------------
  // KRAJ kreiranja pomocne baze POM.DBF
  // -----------------------------------


  // otvorimo neophodne baze, filterisimo osnovni
  // izvor (bazu) podataka i zadajmo odgovarajuci sort
  // -------------------------------------------------

  // dio za aplikaciju
  // ------------------
   O_RJ
   O_FUNK


  SELECT FUNK

  cFilter := "DATDOK<="+cm2str(dDo)

  IF gNW=="N" .and. !EMPTY(cIdFirma)
    cFilter += (".and.IDFIRMA=="+cm2str(cIdFirma))
  ENDIF

  IF !lKumSuma .and. !lKljuc
    cFilter += (".and.DATDOK>="+cm2str(dOd))
  ENDIF
  IF !EMPTY(cGlava)
    cFilter += (".and.IDRJ=="+cm2str(cGlava))
    cNazRJ := Ocitaj( F_RJ , cGlava , "naz" )
  ELSE
    cNazRJ := "SVE"
  ENDIF
  IF !EMPTY(cFunkc)
    cFilter += (".and.FUNK=="+cm2str(cFunkc))
    cNazFK := Ocitaj( F_FUNK , cFunkc , "naz" )
  ELSE
    cNazFK := "SVI"
  ENDIF
  O_BUDZET
  IF !EMPTY(cGlava) .or. !EMPTY(cFunkc)
    SET FILTER TO
    SET FILTER TO IF( EMPTY(cGlava) , .t. , IDRJ==cGlava ) .and. IF( EMPTY(cFunkc) , .t. , FUNK==cFunkc )
  ENDIF

  // priprema kljucnih baza za izvjestaj (indeksi, filteri)
  // ------------------------------------------------------
  PripKBPI()

  nStavki:=0
#ifdef CAX
  GO BOTTOM
  nStavki:=AX_KeyNo()
#else
  GO TOP
  COUNT TO nStavki
#endif


  // -----------------------------------------
  // POCETAK pripreme baze POM.DBF (stavljanje
  // opisnih podataka, uslova i formula)
  // -----------------------------------------
  SELECT KONIZ
#ifdef CAX
  GO BOTTOM
  i:=AX_KeyNo()
#else
  GO TOP
  COUNT TO i
#endif
  Postotak(1,nStavki+i,"Priprema izvjestaja")
  nStavki:=0

  nPomRbr:=0
  GO TOP
  DO WHILE !EOF() .and. izv==cBrI                   // listam KONIZ.DBF
    Postotak(2,++nStavki)
    IF KONIZ->ri == 0
      SKIP 1; LOOP
    ENDIF

    // na osnovu tipa stavke u KONIZ-u odreÐujemo dalje akcije
    cTK11  := UPPER(LEFT(KONIZ->k,1))
    cTK12  := VAL(RIGHT(KONIZ->k,1))

    IF cTK11=="K"     // idi po kljucu
      lKljuc:=.t.
      EXIT
    ENDIF

    lDrugiKonto:=.f.
    IF cTK11=="A"
      cUslovA := LEFT( KONIZ->id , cTK12 )
      Sel_KSif()
      SEEK cUslovA
      IF LEFT( id , cTK12 ) != cUslovA .and. EMPTY(KONIZ->id2)
        SELECT KONIZ; SKIP 1; LOOP
      ELSEIF !EMPTY(KONIZ->id2)
        lDrugiKonto:=.t.
      ENDIF
    ENDIF



    DO WHILE !lDrugiKonto            // ova petlja sluzi samo ako je cTK11="A"

      cIdKonto:=KONIZ->id

      IF cTK11=="F"                              // po funkciji
        cTipK:="P"
        IF EMPTY(KONIZ->opis)
          cNazKonta:=Ocitaj(F_FUNK,PADR(cIdKonto,5),"naz")
        ELSE
          cNazKonta:=KONIZ->opis
        ENDIF
        cUslov := IF( cTK12>0 , LEFT( cIdKonto , cTK12 ) , TRIM(cIdKonto) )
      ELSEIF !EMPTY(KONIZ->fi)                                // po formuli
        IF LEFT(KONIZ->fi,1)!="="
          aUslov:=Parsiraj(KONIZ->fi,cPIKPolje,"C")
        ELSE
          aUslov:=".f."
        ENDIF
        cTipK:="F"
        cNazKonta:=KONIZ->opis
      ELSEIF cTK11=="A"
        cNazKonta:=IzKSif("naz")
        cIdKonto:=IzKSif("id")
        IF RIGHT(ALLTRIM(cIdKonto),1)=="0"       // sintetika
          cTipK:="S"
          cUslov:=ALLTRIM(cIdKonto)
          DO WHILE RIGHT(cUslov,1)=="0"
            cUslov:=LEFT(cUslov,LEN(cUslov)-1)
          ENDDO
        ELSE                                      // analitika
          cTipK:="A"
        ENDIF
      ELSEIF cTK11=="S"
        IF EMPTY(KONIZ->opis)
          cNazKonta:=Ocitaj(F_KSif(),cIdKonto,"naz")
        ELSE
          cNazKonta:=KONIZ->opis
        ENDIF
        cTipK:="S"
        cUslov := LEFT( cIdKonto , cTK12 )
      ELSEIF RIGHT(ALLTRIM(cIdKonto),1)=="0"       // sintetika
        IF EMPTY(KONIZ->opis)
          cNazKonta:=Ocitaj(F_KSif(),cIdKonto,"naz")
        ELSE
          cNazKonta:=KONIZ->opis
        ENDIF
        cTipK:="S"
        cUslov:=ALLTRIM(cIdKonto)
        DO WHILE RIGHT(cUslov,1)=="0"
          cUslov:=LEFT(cUslov,LEN(cUslov)-1)
        ENDDO
      ELSE                                          // analitika
        cNazKonta:=Ocitaj(F_KSif(),cIdKonto,"naz")
        cTipK:="A"
      ENDIF

      SELECT POM
      APPEND BLANK
      REPLACE NRBR       WITH ++nPomRbr                        ,;
              KONTO      WITH cIdKonto                         ,;
              IMEKONTA   WITH cNazKonta                        ,;
              PODVUCI    WITH KONIZ->podvuci                   ,;
              K1         WITH KONIZ->k1                        ,;
              U1         WITH KONIZ->u1                        ,;
              AOP        WITH STR(KONIZ->RI,5)
      IF cTipK!="P"
        REPLACE PLBUDZET   WITH PlBudzeta(cTipK,IF(cTipK=="A",cIdKonto,IF(cTipK=="S",cUslov,aUslov))) ,;
                REBALANS   WITH RebBudzeta(cTipK,IF(cTipK=="A",cIdKonto,IF(cTipK=="S",cUslov,aUslov)))
        REPLACE PREDZNAK   WITH IF( EMPTY(KONTO) .or. KONIZ->predzn<>0 , KONIZ->predzn , IF(&aUPredzn,-1,1) )
      ELSE
        REPLACE PREDZNAK   WITH 1
        RazvijUslove(KONIZ->fi)
      ENDIF
      IF cTipK=="F"
        REPLACE uslov WITH KONIZ->fi
      ELSEIF cTipK=="S"
        REPLACE sint WITH "S"+ALLTRIM(STR(LEN(cUslov)))
      ELSEIF cTipK=="P"
        REPLACE sint WITH "F"+ALLTRIM(STR(LEN(cUslov)))
      ENDIF

      IF cTK11!="A"
        EXIT
      ELSE
        Sel_KSif()
        SKIP 1
        IF LEFT( id , cTK12 ) != cUslovA
          EXIT
        ENDIF
      ENDIF

    ENDDO                          // ova petlja sluzi samo ako je cTK11="A"

    SELECT KONIZ

    IF !lDvaKonta; SKIP 1; LOOP; ENDIF

    cTK21  := UPPER(LEFT(KONIZ->k2,1))
    cTK22  := VAL(RIGHT(KONIZ->k2,1))

    IF cTK21=="A"
      cUslovA2 := LEFT( KONIZ->id2 , cTK22 )
      Sel_KSif()
      SEEK cUslovA2
      IF LEFT( id , cTK22 ) != cUslovA2
        SELECT KONIZ; SKIP 1; LOOP
      ENDIF
    ENDIF

    DO WHILE !EMPTY(KONIZ->id2+KONIZ->fi2)  // ova petlja se vrti samo ako je
                                            // cTK21="A"
      cIdKonto2:=KONIZ->id2

      IF !EMPTY(KONIZ->fi2)                                // po formuli
        aUslov2:=Parsiraj(KONIZ->fi2,cPIKPolje,"C")
        cTipK2:="F"
        cNazKonta:=KONIZ->opis
      ELSEIF cTK21=="A"
        cNazKonta:=IzKSif("naz")
        cIdKonto2:=IzKSif("id")
        IF RIGHT(ALLTRIM(cIdKonto2),1)=="0"       // sintetika
          cTipK2:="S"
          cUslov2:=ALLTRIM(cIdKonto2)
          DO WHILE RIGHT(cUslov2,1)=="0"
            cUslov2:=LEFT(cUslov2,LEN(cUslov2)-1)
          ENDDO
        ELSE                                      // analitika
          cTipK2:="A"
        ENDIF
      ELSEIF cTK21=="S"
        cNazKonta:=Ocitaj(F_KSif(),cIdKonto2,"naz")
        cTipK2:="S"
        cUslov2 := LEFT( cIdKonto2 , cTK22 )
      ELSEIF RIGHT(ALLTRIM(cIdKonto2),1)=="0"       // sintetika
        cNazKonta:=Ocitaj(F_KSif(),cIdKonto2,"naz")
        cTipK2:="S"
        cUslov2:=ALLTRIM(cIdKonto2)
        DO WHILE RIGHT(cUslov2,1)=="0"
          cUslov2:=LEFT(cUslov2,LEN(cUslov2)-1)
        ENDDO
      ELSE                                          // analitika
        cNazKonta:=Ocitaj(F_KSif(),cIdKonto2,"naz")
        cTipK2:="A"
      ENDIF

      SELECT POM
      IF lDrugiKonto
        APPEND BLANK
        REPLACE NRBR       WITH ++nPomRbr                        ,;
                KONTO      WITH KONIZ->id                        ,;
                IMEKONTA   WITH cNazKonta                        ,;
                PODVUCI    WITH KONIZ->podvuci                   ,;
                K1         WITH KONIZ->k1                        ,;
                U1         WITH KONIZ->u1                        ,;
                AOP        WITH STR(KONIZ->RI,5)
        REPLACE PREDZNAK   WITH IF( EMPTY(KONTO) .or. KONIZ->predzn<>0 , KONIZ->predzn , IF(&aUPredzn,-1,1) )
      ENDIF
      REPLACE KONTO2     WITH cIdKonto2                          ,;
              PLBUDZET2  WITH PlBudzeta(cTipK2,IF(cTipK2=="A",cIdKonto2,IF(cTipK2=="S",cUslov2,aUslov2))) ,;
              REBALANS2  WITH RebBudzeta(cTipK2,IF(cTipK2=="A",cIdKonto2,IF(cTipK2=="S",cUslov2,aUslov2)))
      REPLACE PREDZNAK2  WITH IF( EMPTY(KONTO2) .or. KONIZ->predzn2<>0 , KONIZ->predzn2 , IF(&aUPredzn2,-1,1) )
      IF cTipK2=="F"
        REPLACE uslov2 WITH KONIZ->fi2
      ELSEIF cTipK2=="S"
        REPLACE sint2 WITH "S"+ALLTRIM(STR(LEN(cUslov2)))
      ENDIF

      IF cTK21!="A"
        EXIT
      ELSE
        Sel_KSif()
        SKIP 1
        IF LEFT( id , cTK22 ) != cUslovA2
          EXIT
        ENDIF
      ENDIF

    ENDDO                          // ova petlja sluzi samo ako je cTK21="A"

    SELECT KONIZ; SKIP 1
  ENDDO                                       // listam KONIZ.DBF
  // --------------------------
  // KRAJ pripreme baze POM.DBF
  // --------------------------



   // proizvoljni izvjestaji
   cIniName:=EXEPATH+'ProIzvj.ini'
   select rj; hseek cGlava
   select FUNK; hseek cFunkc
   UzmiIzIni(cIniName,'Varijable','RJ',cGlava,'WRITE')
   UzmiIzIni(cIniName,'Varijable','RJNaz',rj->naz,'WRITE')
   UzmiIzIni(cIniName,'Varijable','Funkcija',cFunkc,'WRITE')
   UzmiIzIni(cIniName,'Varijable','FunkcijaNaz',funk->naz,'WRITE')

   UzmiIzIni(cIniName,'Varijable','DatumOd',dtoc(dOd),'WRITE')
   UzmiIzIni(cIniName,'Varijable','DatumDo',dtoc(dDo),'WRITE')
   UzmiIzIni(cIniName,'Varijable','Firma',gNFirma,'WRITE')

   if !empty(cUIdKonto)
     UzmiIzIni(cIniName,'Varijable','Konto',cUIdKonto,"WRITE")
     select (F_KONTO)
     if !used(); O_KONTO; endif
     select konto; hseek cUIdKonto
     UzmiIzIni(cIniName,'Varijable','KontoNaz',konto->naz, "WRITE")
     use
   else
     UzmiIzIni(cIniName,'Varijable','Konto',"","WRITE")
     UzmiIzIni(cIniName,'Varijable','KontoNaz',"", "WRITE")
   endif



  // ---------------------------------------------------------------
  // konacno, uzimam podatke iz osnovnog izvora podataka (SUBAN.DBF)
  // i smjestam ih u POM.DBF prema postojecim formulama i uslovima
  // ---------------------------------------------------------------
  IF lKljuc                               // varijanta KONIZ->K="K"

    nPomRbr:=0
    nPr:=KONIZ->predzn
    Sel_KBaza()
    if !empty(cUIdKonto)
      cUIdKonto:="Idkonto=='"+cUIDKonto+"'"
      set filter to &cUIdKonto

    endif

    GO TOP

    DO WHILE !EOF()
      cIdKonto:=&cPIKPolje
      nDug:=nPot:=0
      FOR i:=1 TO LEN(aKolS)
        aKolS[i,3]:=0
      NEXT
      DO WHILE !EOF() .and. cIdKonto==&cPIKPolje
        Postotak(2,++nStavki)
        FOR i:=1 TO LEN(aKolS)
          cPom   := aKolS[i,2]
          cPomIS := aKolS[i,4]
          IF EMPTY(cPomIS); cPomIS:="iznosbhd"; ENDIF
          IF &cPom
            IF D_P=="1"
              aKolS[i,3] += (&cPomIS*nPr)
            ELSE
              aKolS[i,3] -= (&cPomIS*nPr)
            ENDIF
          ENDIF
        NEXT
        SKIP 1
      ENDDO
      SELECT POM
      APPEND BLANK
      FOR i:=1 TO LEN(aKolS)
        cPom:=aKolS[i,1]
        REPLACE &cPom WITH aKolS[i,3]
      NEXT
      REPLACE KONTO WITH cIdKonto
      IF cPIKSif!="BEZ"
        REPLACE IMEKONTA WITH Ocitaj( F_KSif(),;
                                      PADR(cIdKonto,LEN(IzKSif("ID"))),;
                                      "naz")
      ENDIF
      REPLACE NRBR WITH ++nPomRbr

      Sel_KBaza()
    ENDDO

  ELSEIF !lFunkcija                       // varijanta KONIZ->K!="F"

    Sel_KBaza()
    GO TOP

    IF EMPTY(cSIzraz); cSIzraz:="IZNOSBHD"; ENDIF

    DO WHILE !EOF()
      cIdKonto:=&cPIKPolje
      nDug:=nPot:=nPrDug:=nPrPot:=0
      DO WHILE !EOF() .and. cIdKonto==&cPIKPolje
        Postotak(2,++nStavki)
        // çta sa DATDOK, IZNOSBHD i D_P ?!  VA¦NO!
        // ---------------

        IF !lKumSuma .or. datdok>=dOd   // tekuci period (od datuma dOd)
          IF D_P=="1"           // dug.
            nDug += (&cSIzraz)
          ELSE                  // pot.
            nPot += (&cSIzraz)
          ENDIF
        ELSE             // bitno samo za kumul.period (od datuma "  .  .  ")
          IF D_P=="1"           // dug.
            nPrDug += (&cSIzraz)
          ELSE                  // pot.
            nPrPot += (&cSIzraz)
          ENDIF
        ENDIF
        SKIP 1
      ENDDO

      nTekSuma := nDug - nPot
      nKumSuma := nTekSuma + nPrDug - nPrPot

      SELECT POM; SET ORDER TO TAG "1"; GO TOP
      DO WHILE !EOF() // .and. EMPTY(konto)
        IF LEFT(sint,1)=="S".or.EMPTY(uslov).or.LEFT(uslov,1)=="="; SKIP 1; LOOP; ENDIF
        aUslov:=PARSIRAJ(uslov,"cIdKonto","C")
        IF &aUslov
           REPLACE kumsuma    WITH predznak * nKumSuma + kumsuma     ,;
                   teksuma    WITH predznak * nTekSuma + teksuma     ,;
                   duguje     WITH nDug + duguje                     ,;
                   potrazuje  WITH nPot + potrazuje
        ENDIF
        SKIP 1
      ENDDO

      SEEK LEFT(cIdKonto,1)
      DO WHILE !EOF() .and. cIdKonto>=konto
        IF LEFT(sint,1)=="S" .and. LEFT(cIdKonto,VAL(RIGHT(sint,1))) == LEFT(konto,VAL(RIGHT(sint,1))) .or. cIdKonto==konto .and. EMPTY(uslov)
           REPLACE kumsuma    WITH predznak * nKumSuma + kumsuma     ,;
                   teksuma    WITH predznak * nTekSuma + teksuma     ,;
                   duguje     WITH nDug + duguje                     ,;
                   potrazuje  WITH nPot + potrazuje
        ENDIF
        SKIP 1
      ENDDO

      IF !lDvaKonta; Sel_KBaza(); LOOP; ENDIF

      SELECT POM; SET ORDER TO TAG "2"; GO TOP
      DO WHILE !EOF() // .and. EMPTY(konto2)
        IF LEFT(sint2,1)=="S".or.EMPTY(uslov2).or.LEFT(uslov2,1)=="="; SKIP 1; LOOP; ENDIF
        aUslov:=PARSIRAJ(uslov2,"cIdKonto","C")
        IF &aUslov
           REPLACE kumsuma2    WITH predznak2 * nKumSuma + kumsuma2     ,;
                   teksuma2    WITH predznak2 * nTekSuma + teksuma2     ,;
                   duguje2     WITH nDug + duguje2                      ,;
                   potrazuje2  WITH nPot + potrazuje2
        ENDIF
        SKIP 1
      ENDDO

      SEEK LEFT(cIdKonto,1)
      DO WHILE !EOF() .and. cIdKonto>=konto2
        IF LEFT(sint2,1)=="S" .and. LEFT(cIdKonto,VAL(RIGHT(sint2,1))) == LEFT(konto2,VAL(RIGHT(sint2,1))) .or. cIdKonto==konto2 .and. EMPTY(uslov2)
           REPLACE kumsuma2    WITH predznak2 * nKumSuma + kumsuma2     ,;
                   teksuma2    WITH predznak2 * nTekSuma + teksuma2     ,;
                   duguje2     WITH nDug + duguje2                      ,;
                   potrazuje2  WITH nPot + potrazuje2
        ENDIF
        SKIP 1
      ENDDO

      Sel_KBaza()
    ENDDO                                      // uzimam podatke iz SUBAN.DBF

  ELSE                // ako jeste lFunkcija   tj.   KONIZ->K="F"

    Sel_KBaza()
    GO TOP

    DO WHILE !EOF()
      nDug:=nPot:=nPrDug:=nPrPot:=0
      Postotak(2,++nStavki)
      IF EMPTY(funk); SKIP 1; LOOP; ENDIF
      IF !lKumSuma .or. datdok>=dOd   // tekuci period (od datuma dOd)
        IF D_P=="1"           // dug.
          nDug += iznosbhd
        ELSE                  // pot.
          nPot += iznosbhd
        ENDIF
      ELSE             // bitno samo za kumul.period (od datuma "  .  .  ")
        IF D_P=="1"           // dug.
          nPrDug += iznosbhd
        ELSE                  // pot.
          nPrPot += iznosbhd
        ENDIF
      ENDIF

      nTekSuma := nDug - nPot
      nKumSuma := nTekSuma + nPrDug - nPrPot

      SELECT POM; GO TOP
      DO WHILE !EOF()
        IF EMPTY(KONTO)
          aUslov1 := ".t."
        ELSEIF VAL(RIGHT(sint,1))>0
          aUslov1 := "LEFT(SUBAN->FUNK,"+RIGHT(sint,1)+")==LEFT(KONTO,"+RIGHT(sint,1)+")"
        ELSE
          aUslov1 := "LEFT(SUBAN->FUNK,"+STR(LEN(TRIM(KONTO)),1)+")==LEFT(KONTO,"+STR(LEN(TRIM(KONTO)),1)+")"
        ENDIF
        FOR i:=1 TO 12
          cPom:="USL"+ALLTRIM(STR(i))
          cPom2:="KOL"+ALLTRIM(STR(i))
          aUslov2:=PARSIRAJ(&cPom,"SUBAN->IDKONTO","C")
          IF &aUslov1 .and. &aUslov2
            REPLACE &cPom2     WITH &cPom2 + PREDZNAK * nTekSuma     ,;
                    kumsuma    WITH predznak * nKumSuma + kumsuma    ,;
                    duguje     WITH nDug + duguje                    ,;
                    potrazuje  WITH nPot + potrazuje
          ENDIF
        NEXT
        SKIP 1
      ENDDO

      Sel_KBaza()
      SKIP 1
    ENDDO                                      // uzimam podatke iz SUBAN.DBF

  ENDIF                  // lFunkcija
  Postotak(-1)
  // -----------------------------------------
  // KRAJ uzimanja podataka iz osnovnog izvora
  // -----------------------------------------


  // -----------------------------------------------------
  // odstampajmo zaglavlje i izvjestajnu tabelu iz POM.DBF
  // -----------------------------------------------------
  nBrRedStr := -99
  StZagPI()
  gnLMarg:=0; gOstr:="D"
  StTabPI()



// postoji RTM fajl za delhpi
altd()
cNazRTM:=trim(gmodul)+UzmiIzIni(EXEPATH+"proizvj.ini",'Varijable','OznakaIzvj',"XY",'READ')
altd()

if file(EXEPATH+cNazRTM+".RTM")

if Pitanje(,"Aktivirati Win report ?","D")=="D"


close all



KZNbazaWin(PRIVPATH+"pom")

private cKomLin:="DelphiRB "+cNazRTM+" "+PRIVPATH+"  pom  "+cTag
run &cKomLin

endif

endif

CLOSERET
*}



/*! \fn PrikaziTI(cSif)
 *  \brief Prikazuje tekuci izvjestaj
 *  \param cSif - sifra
 */

function PrikaziTI(cSif)
*{
LOCAL nArr:=SELECT(), nKol:=COL(), nRed:=ROW()
   SELECT (F_IZVJE)
   SEEK cSif
   IF FOUND()
     @ 1,0 SAY PADC("TEKUCI IZVJESTAJ: "+ID+"-"+TRIM(DoHasha(NAZ)),80) COLOR "GR+/N"
   ELSE
     @ 1,0 SAY PADC("TEKUCI IZVJESTAJ: "+cSif+"-nije definisan",80) COLOR "GR+/N"
   ENDIF
   cPIKPolje  := IF(FIELDPOS("KPOLJE" )==0.or.EMPTY(KPOLJE ),"IDKONTO",;
                                                             TRIM(KPOLJE ))
   cPIImeKP   := IF(FIELDPOS("IMEKP"  )==0.or.EMPTY(IMEKP  ),"KONTO"  ,;
                                                             TRIM(IMEKP  ))
   cPIKSif    := IF(FIELDPOS("KSIF"   )==0.or.EMPTY(KSIF   ),"KONTO"  ,;
                                                             TRIM(KSIF   ))
   cPIKBaza   := IF(FIELDPOS("KBAZA"  )==0.or.EMPTY(KBAZA  ),"SUBAN",;
                                                             TRIM(KBAZA  ))
   cPIKIndeks := IF(FIELDPOS("KINDEKS")==0.or.EMPTY(KINDEKS),"TAG6",;
                                                             TRIM(KINDEKS))
   cPITipTab  := IF(FIELDPOS("TIPTAB" )==0.or.EMPTY(TIPTAB ),"",;
                                                             TRIM(TIPTAB ))
   SELECT (nArr)
  SETPOS(nRed,nKol)
RETURN
*}


/*! \fn FForPI()
 *  \brief
 */

function FForPI()
*{
LOCAL lVrati:=.f.
 IF cSaNulama=="D" .or.;
    !lKljuc .and. ( PLBUDZET<>0 .or. REBALANS<>0 .or. KUMSUMA<>0 .or.;
                    TEKSUMA<>0 .or. KPGSUMA<>0 .or. DUGUJE<>0 .or.;
                    POTRAZUJE<>0 .or.;
                    lDvaKonta .and. ( PLBUDZET2<>0 .or. REBALANS2<>0 .or.;
                                      KUMSUMA2<>0 .or. TEKSUMA2<>0 .or.;
                                      DUGUJE2<>0 .or. POTRAZUJE2<>0 ) ) .or.;
    lFunkcija .and. ( KOL1<>0 .or. KOL2<>0 .or. KOL3<>0 .or. KOL4<>0 .or.;
    KOL5<>0 .or. KOL6<>0 .or. KOL7<>0 .or. KOL8<>0 .or. KOL9<>0 .or.;
    KOL10<>0 .or. KOL11<>0 .or. KOL12<>0 ) .or.;
    lKljuc .and. VidiUaKolS()
   lVrati:=.t.
 ENDIF
RETURN lVrati
*}


/*! \fn VidiUaKolS()
 *  \brief
 */

function VidiUaKolS()
*{
LOCAL lVrati:=.f., i:=0
  FOR i:=1 TO LEN(aKolS)
    cPom777:=aKolS[i,1]
    IF &cPom777<>0
      lVrati:=.t.
      EXIT
    ENDIF
  NEXT
RETURN lVrati
*}



/*! \fn FSvakiPI()
 *  \brief
 */

function FSvakiPI()
*{
IF !lKljuc
   IF EMPTY(U1)
     uTekSuma:=TEKSUMA
   ELSE
     PRIVATE cPUTS
     cPUTS:="TEKSUMA"+TRIM(U1)
     IF &cPUTS
       uTekSuma:=ABS(TEKSUMA)
     ELSE
       uTekSuma:=0
     ENDIF
   ENDIF
 ENDIF
RETURN IF(!EMPTY(PODVUCI),"PODVUCI"+PODVUCI,NIL)
*}


/*! \fn PlBudzeta(cTipK,cKonto)
 *  \brief Plan budzeta, specificno za budzetske korisnike
 *  \param cTipK
 *  \param cKonto
 */

function PlBudzeta(cTipK,cKonto)
*{
 LOCAL nVrati:=0, nArr:=SELECT()
 IF cKonto==".f."; RETURN 0; ENDIF
 SELECT BUDZET
 SET ORDER TO TAG "2"
 GO TOP
 IF cTipK=="A" .or. cTipK=="S"
   SEEK cKonto
 ENDIF
 DO WHILE !EOF() .and.;
          ( cTipK=="A" .and. idkonto==cKonto .or.;
            cTipK=="S" .and. LEFT(idkonto,LEN(cKonto))==cKonto .or.;
            cTipK=="F" )
   IF cTipK=="F" .and. !(&cKonto); SKIP 1; LOOP; ENDIF
   nVrati += iznos
   SKIP 1
 ENDDO
 SELECT (nArr)
RETURN nVrati
*}


/*! \fn RebBudzeta(cTipK,cKonto)
 *  \brief Rebalans budzeta
 *  \param cTipK
 *  \param cKonto
 */

 
function RebBudzeta(cTipK,cKonto)
*{
LOCAL nVrati:=0, nArr:=SELECT()
 IF cKonto==".f."; RETURN 0; ENDIF
 SELECT BUDZET
 SET ORDER TO TAG "2"
 GO TOP
 IF cTipK=="A" .or. cTipK=="S"
   SEEK cKonto
 ENDIF
 DO WHILE !EOF() .and.;
          ( cTipK=="A" .and. idkonto==cKonto .or.;
            cTipK=="S" .and. LEFT(idkonto,LEN(cKonto))==cKonto .or.;
            cTipK=="F" )
   IF cTipK=="F" .and. !(&cKonto); SKIP 1; LOOP; ENDIF
   nVrati += rebiznos
   SKIP 1
 ENDDO
 SELECT (nArr)
RETURN nVrati
*}




/*! \fn ParSviIzvj()
 *  \brief Parametri za sve izvjestaje
 */
 
function ParSviIzvj()
*{
LOCAL GetList:={}
cPotrazKon:=PADR(cPotrazKon,120)

gTabela:=1; cPrikBezDec:="D"; cSaNulama:="D"; nKorZaLands:=-18

O_PARAMS
Private cSection:="I", cHistory:=" ", aHistory:={}
RPar("05",@gTabela)
RPar("06",@cPrikBezDec)
RPar("07",@cSaNulama)
RPar("08",@nKorZaLands)

RPar("09",@cDPnaz1 )
RPar("10",@cDPnaz2 )
RPar("11",@cDPnaz3 )
RPar("12",@cDPnaz4 )
RPar("13",@cDPnaz5 )
RPar("14",@cDPnaz6 )
RPar("15",@cDPnaz7 )
RPar("16",@cDPnaz8 )
RPar("17",@cDPnaz9 )
RPar("18",@cDPnaz10)
RPar("19",@cDPx1 )
RPar("20",@cDPx2 )
RPar("21",@cDPx3 )
RPar("22",@cDPx4 )
RPar("23",@cDPx5 )
RPar("24",@cDPx6 )
RPar("25",@cDPx7 )
RPar("26",@cDPx8 )
RPar("27",@cDPx9 )
RPar("28",@cDPx10)
RPar("29",@cDPf1 )
RPar("30",@cDPf2 )
RPar("31",@cDPf3 )
RPar("32",@cDPf4 )
RPar("33",@cDPf5 )
RPar("34",@cDPf6 )
RPar("35",@cDPf7 )
RPar("36",@cDPf8 )
RPar("37",@cDPf9 )
RPar("38",@cDPf10)

cDPnaz1 :=PADR(cDPnaz1 , 40); cDPx1 :=PADR(cDPx1 , 40)
cDPnaz2 :=PADR(cDPnaz2 , 40); cDPx2 :=PADR(cDPx2 , 40)
cDPnaz3 :=PADR(cDPnaz3 , 40); cDPx3 :=PADR(cDPx3 , 40)
cDPnaz4 :=PADR(cDPnaz4 , 40); cDPx4 :=PADR(cDPx4 , 40)
cDPnaz5 :=PADR(cDPnaz5 , 40); cDPx5 :=PADR(cDPx5 , 40)
cDPnaz6 :=PADR(cDPnaz6 , 40); cDPx6 :=PADR(cDPx6 , 40)
cDPnaz7 :=PADR(cDPnaz7 , 40); cDPx7 :=PADR(cDPx7 , 40)
cDPnaz8 :=PADR(cDPnaz8 , 40); cDPx8 :=PADR(cDPx8 , 40)
cDPnaz9 :=PADR(cDPnaz9 , 40); cDPx9 :=PADR(cDPx9 , 40)
cDPnaz10:=PADR(cDPnaz10, 40); cDPx10:=PADR(cDPx10, 40)


Box(,22,75)
 USTIPKE()
 @ m_x+2, m_y+2 SAY "Uslov kojim se obuhvataju sva konta ciji saldo treba da bude potrazni:"
 @ m_x+3, m_y+2 GET cPotrazKon PICT "@S70"
 @ m_x+4, m_y+2 SAY "Porez na dobit (gnPorDob) u % :" GET gnPorDob PICT "999.99"

 @ m_x+6,m_y+2 SAY "TABELA(0/1/2)          " GET gTabela VALID gTabela>=0.and.gTabela<=2 PICT "9"
 @ m_x+7,m_y+2 SAY "Gdje moze, prikaz bez decimala? (D/N)" GET cPrikBezDec VALID cPrikBezDec $ "DN" PICT "@!"
 @ m_x+8,m_y+2 SAY "Prikazivati stavke bez prometa? (D/N)" GET cSaNulama VALID cSaNulama $ "DN" PICT "@!"
 @ m_x+9,m_y+2 SAY "Korekcija broja redova (za lendskejp)" GET nKorZaLands PICT "999"

 @ m_x+10,m_y+ 2 SAY "Dodatni (proizvoljni parametri):"
 @ m_x+11,m_y+ 2 SAY "Varijabla      Naziv(opis)         Vrijednost         Fiksan(D/N)"

 @ m_x+12,m_y+ 2 SAY "  cDPx1  " GET cDPnaz1 PICT "@S20"
 @ m_x+12,m_y+33 GET cDPx1 PICT "@S20"
 @ m_x+12,m_y+55 GET cDPf1 VALID cDPf1$"DN" PICT "@!"

 @ m_x+13,m_y+ 2 SAY "  cDPx2  " GET cDPnaz2 PICT "@S20"
 @ m_x+13,m_y+33 GET cDPx2 PICT "@S20"
 @ m_x+13,m_y+55 GET cDPf2 VALID cDPf2$"DN" PICT "@!"

 @ m_x+14,m_y+ 2 SAY "  cDPx3  " GET cDPnaz3 PICT "@S20"
 @ m_x+14,m_y+33 GET cDPx3 PICT "@S20"
 @ m_x+14,m_y+55 GET cDPf3 VALID cDPf3$"DN" PICT "@!"

 @ m_x+15,m_y+ 2 SAY "  cDPx4  " GET cDPnaz4 PICT "@S20"
 @ m_x+15,m_y+33 GET cDPx4 PICT "@S20"
 @ m_x+15,m_y+55 GET cDPf4 VALID cDPf4$"DN" PICT "@!"

 @ m_x+16,m_y+ 2 SAY "  cDPx5  " GET cDPnaz5 PICT "@S20"
 @ m_x+16,m_y+33 GET cDPx5 PICT "@S20"
 @ m_x+16,m_y+55 GET cDPf5 VALID cDPf5$"DN" PICT "@!"

 @ m_x+17,m_y+ 2 SAY "  cDPx6  " GET cDPnaz6 PICT "@S20"
 @ m_x+17,m_y+33 GET cDPx6 PICT "@S20"
 @ m_x+17,m_y+55 GET cDPf6 VALID cDPf6$"DN" PICT "@!"

 @ m_x+18,m_y+ 2 SAY "  cDPx7  " GET cDPnaz7 PICT "@S20"
 @ m_x+18,m_y+33 GET cDPx7 PICT "@S20"
 @ m_x+18,m_y+55 GET cDPf7 VALID cDPf7$"DN" PICT "@!"

 @ m_x+19,m_y+ 2 SAY "  cDPx8  " GET cDPnaz8 PICT "@S20"
 @ m_x+19,m_y+33 GET cDPx8 PICT "@S20"
 @ m_x+19,m_y+55 GET cDPf8 VALID cDPf8$"DN" PICT "@!"

 @ m_x+20,m_y+ 2 SAY "  cDPx9  " GET cDPnaz9 PICT "@S20"
 @ m_x+20,m_y+33 GET cDPx9 PICT "@S20"
 @ m_x+20,m_y+55 GET cDPf9 VALID cDPf9$"DN" PICT "@!"

 @ m_x+21,m_y+ 2 SAY "  cDPx10 " GET cDPnaz10 PICT "@S20"
 @ m_x+21,m_y+33 GET cDPx10 PICT "@S20"
 @ m_x+21,m_y+55 GET cDPf10 VALID cDPf10$"DN" PICT "@!"

 READ
 BOSTIPKE()


BoxC()
cPotrazKon:=TRIM(cPotrazKon)

cDPnaz1 :=TRIM(cDPnaz1 ) ; cDPx1 :=TRIM(cDPx1 )
cDPnaz2 :=TRIM(cDPnaz2 ) ; cDPx2 :=TRIM(cDPx2 )
cDPnaz3 :=TRIM(cDPnaz3 ) ; cDPx3 :=TRIM(cDPx3 )
cDPnaz4 :=TRIM(cDPnaz4 ) ; cDPx4 :=TRIM(cDPx4 )
cDPnaz5 :=TRIM(cDPnaz5 ) ; cDPx5 :=TRIM(cDPx5 )
cDPnaz6 :=TRIM(cDPnaz6 ) ; cDPx6 :=TRIM(cDPx6 )
cDPnaz7 :=TRIM(cDPnaz7 ) ; cDPx7 :=TRIM(cDPx7 )
cDPnaz8 :=TRIM(cDPnaz8 ) ; cDPx8 :=TRIM(cDPx8 )
cDPnaz9 :=TRIM(cDPnaz9 ) ; cDPx9 :=TRIM(cDPx9 )
cDPnaz10:=TRIM(cDPnaz10) ; cDPx10:=TRIM(cDPx10)

IF LASTKEY()!=K_ESC
  O_PARAMS
  Private cSection:="I",cHistory:=" ",aHistory:={}
  WPar("pk",cPotrazKon)
  WPar("pd",gnPorDob)
  WPar("05",gTabela)
  WPar("06",cPrikBezDec)
  WPar("07",cSaNulama)
  WPar("08",nKorZaLands)

  WPar("09",cDPnaz1 )
  WPar("10",cDPnaz2 )
  WPar("11",cDPnaz3 )
  WPar("12",cDPnaz4 )
  WPar("13",cDPnaz5 )
  WPar("14",cDPnaz6 )
  WPar("15",cDPnaz7 )
  WPar("16",cDPnaz8 )
  WPar("17",cDPnaz9 )
  WPar("18",cDPnaz10)
  WPar("19",cDPx1 )
  WPar("20",cDPx2 )
  WPar("21",cDPx3 )
  WPar("22",cDPx4 )
  WPar("23",cDPx5 )
  WPar("24",cDPx6 )
  WPar("25",cDPx7 )
  WPar("26",cDPx8 )
  WPar("27",cDPx9 )
  WPar("28",cDPx10)
  WPar("29",cDPf1 )
  WPar("30",cDPf2 )
  WPar("31",cDPf3 )
  WPar("32",cDPf4 )
  WPar("33",cDPf5 )
  WPar("34",cDPf6 )
  WPar("35",cDPf7 )
  WPar("36",cDPf8 )
  WPar("37",cDPf9 )
  WPar("38",cDPf10)

  SELECT PARAMS; USE
ENDIF
*}



/*! \fn UKucice(cSta,nKucica)
 *  \brief
 *  \param cSta
 *  \param nKucica
 */
 
function UKucice(cSta,nKucica)
*{
RETURN ( "I"+CHARMIX(PADL(TRIM(cSta),nKucica,IF(EMPTY(cSta)," ","0")),"I") )
*}




/*! \fn KonvZnWin(cTekst,cWinKonv)
 *  \brief Konverzija znakova za Windows
 *  \param cTekst
 *  \param cWinKonv
 */
 
function KonvZnWin(cTekst,cWinKonv)
*{
LOCAL aNiz:={  {"[","æ",chr(138),"S"}, {"{","ç",chr(154),"s"}, {"}","†",chr(230),"c"}, {"]","", chr(198),"C"}, {"^","¬", chr(200),"C"},;
                {"~","Ÿ",chr(232),"c"}, {"`","§",chr(158),"z"}, {"@","¦",chr(142),"Z"}, {"|","Ð", chr(240),"dj"}, {"\","Ñ", chr(208),"DJ"}  }
 LOCAL i,j

 if cWinKonv=NIL
  cWinKonv:=IzFmkIni("DelphiRb","Konverzija","5")
 endif

 i:=1; j:=1
 if cWinKonv=="1"
    i:=1; j:=2
 elseif cWinKonv=="2"
    i:=1; j:=4  // 7->A
 elseif cWinKonv=="3"
    i:=2; j:=1   // 852->7
 elseif cWinKonv=="4"
    i:=2; j:=4  // 852->A
 elseif cWinKonv=="5"
    i:=2; j:=3  // 852->win1250
 elseif cWinKonv=="6"
    i:=1; j:=3  // 7->win1250
 endif

 if i<>j
  AEVAL(aNiz,{|x| cTekst:=STRTRAN(cTekst,x[i],x[j])})
 endif

RETURN cTekst
*}



/*! \fn KZnBazaWin(cDbf)
 *  \brief Konverzija znakova u bazama
 */
 
function KZnbazaWin(cDbf)
*{
local cWinKonv

cWinKonv:=IzFmkIni("DelphiRb","Konverzija","5")

if cWinKonv>"0" // ima konverzije

usex (cDBF) new
beep(1)
ordsetfocus(0)
GO TOP
anPolja:={}
FOR k:=1 TO FCOUNT()
  xVar:=FIELDGET(k)
  IF VALTYPE(xVar)$"CM"
    AADD(anPolja,k)
  ENDIF
NEXT
DO WHILE !EOF()
  FOR k:=1 TO LEN(anPolja)
    xVar:=FIELDGET(anPolja[k])
    FIELDPUT(anPolja[k],KonvZnWin(xVar, cWinKonv))
  NEXT
  SKIP 1
ENDDO
use

endif //cWinKonv

return
*}


