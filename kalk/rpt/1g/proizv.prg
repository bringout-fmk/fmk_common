#include "\cl\sigma\fmk\kalk\kalk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/rpt/1g/proizv.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.4 $
 * $Log: proizv.prg,v $
 * Revision 1.4  2002/07/03 23:55:19  ernad
 *
 *
 * ciscenja planika (tragao za nepostojecim bug-om u prelgedu finansijskog obrta)
 *
 * Revision 1.3  2002/06/25 08:44:24  ernad
 *
 *
 * ostranicavanje planika, doxy - grupa: Planika
 *
 * Revision 1.2  2002/06/24 08:42:35  sasa
 * no message
 *
 *
 */


/*! \file fmk/kalk/rpt/1g/proizv.prg
 *  \brief Proizvoljni izvjestaji
 */

/*! \fn Proizv()
 *  \brief 
 */
 
function Proizv()
*{
PrIz()
return
*}

/*! \fn OtBazPI()
 *  \brief Otvara baze proizvoljnih izvjestaja
 */

function OtBazPI()
*{
O_ROBA
O_TARIFA
OProizv()
return
*}


/*! \fn GenProIzv()
 *  \brief Generisanje proizvoljnih izvjestaja
 */
 
function GenProIzv()
*{ 
 local nPr:=1, lKumSuma:=.f.
 private lDvaKonta:=.f.  // ? ukinuti ovu var. ?
 private lKljuc:=.f.
 private lArtikli:=.f.
 // privatne var. koje bi trebalo inicijalizovati iz aplikacije
 // -----------------------------------------------------------

 // neophodne privatne varijable (pogodno za ELIB-a)
 // -------------------------------------------------
  dOd:=CTOD(""); dDo:=DATE()
  gTabela:=1; cPrikBezDec:="D"; cSaNulama:="D"; nKorZaLands:=-18

  lIzrazi:=.f.

  // --------------------------
  // POCETAK izvjestajnog upita
  // --------------------------
  O_PARAMS
  private cSection:="I", cHistory:=" ", aHistory:={}
  RPar("03",@dOd)
  RPar("04",@dDo)
  RPar("05",@gTabela)
  RPar("06",@cPrikBezDec)
  RPar("07",@cSaNulama)
  RPar("08",@nKorZaLands)
  SELECT PARAMS; USE

  Box(,10,70)
   @ m_x+4,m_y+2 SAY "Period izvjestavanja od" GET dOd
   @ m_x+5,m_y+2 SAY "                     do" GET dDo
   read
  BoxC()

  if LASTKEY()==K_ESC
    CLOSERET
  endif

  O_PARAMS
  private cSection:="I",cHistory:=" ",aHistory:={}
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
    if LEFT(KONIZ->fi,1)=="="; lIzrazi:=.t.; endif
//    if !EMPTY(K2) .or. !EMPTY(ID2) .or. !EMPTY(FI2); lDvaKonta:=.t.; endif
    if ri<>0 .and. UPPER(LEFT(k,1))=="K"; lKljuc:=.t.; endif
    SKIP 1
  ENDDO

  aKolS:={}
  i:=0
  SELECT KOLIZ
  SET FILTER TO
  SET FILTER TO id==cBrI
  SET ORDER TO TAG "1"
  GO TOP
  DO WHILE !EOF()
    if !EMPTY(KUSLOV)
      ++i
      AADD(aKolS,{"KOL"+ALLTRIM(STR(i)),TRIM(kuslov)+IF(UPPER(k1)=="K","",".and.DATDOK>="+cm2str(dOd)),0,TRIM(sizraz)})
    endif
    if "KUMSUMA" $ FORMULA
      lKumSuma:=.t.
    endif
    if "ROBA->" $ UPPER(KUSLOV)
      lArtikli:=.t.
    endif
    SKIP 1
  ENDDO


  // --------------------------------------
  // POCETAK kreiranja pomocne baze POM.DBF
  // --------------------------------------
  SELECT (F_POM)
  USE
  if ferase(PRIVPATH+"POM.DBF")==-1
    MsgBeep("Ne mogu izbrisati POM.DBF!")
    ShowFError()
  endif
  if ferase(PRIVPATH+"POM.CDX")==-1
    MsgBeep("Ne mogu izbrisati POM.CDX!")
    ShowFError()
  endif
  
  aDbf := {}
  AADD (aDbf, {"NRBR"      , "N",  5, 0})
  AADD (aDbf, {"KONTO"     , "C", 20, 0})
  AADD (aDbf, {"IMEKONTA"  , "C", 57, 0})
  if !lKljuc
    AADD (aDbf, {"KUMSUMA"   , "N", 15, 2})
    AADD (aDbf, {"TEKSUMA"   , "N", 15, 2})
    AADD (aDbf, {"KPGSUMA"   , "N", 15, 2})
    AADD (aDbf, {"DUGUJE"    , "N", 15, 2})
    AADD (aDbf, {"POTRAZUJE" , "N", 15, 2})
    AADD (aDbf, {"USLOV"     , "C", 80, 0})
    AADD (aDbf, {"SINT"      , "C",  2, 0})          // "Sn" ili "  "
  endif
  AADD (aDbf, {"PREDZNAK"  , "N",  2, 0})          // "-1" ili " 1"
  AADD (aDbf, {"PODVUCI"   , "C",  1, 0})
  AADD (aDbf, {"K1"        , "C",  1, 0})          //
  AADD (aDbf, {"U1"        , "C",  3, 0})          // npr. >0 ili <0
  AADD (aDbf, {"AOP"       , "C",  5, 0})

  // polja koja se koriste u situaciji kada je neophodno postavljanje
  // dva razlicita uslova(filtera) na jednoj izvjestajnoj stavci
  // ----------------------------------------------------------------
  if lDvaKonta
    AADD (aDbf, {"KONTO2"    , "C", 20, 0})
    AADD (aDbf, {"KUMSUMA2"  , "N", 15, 2})
    AADD (aDbf, {"TEKSUMA2"  , "N", 15, 2})
    AADD (aDbf, {"DUGUJE2"   , "N", 15, 2})
    AADD (aDbf, {"POTRAZUJE2", "N", 15, 2})
    AADD (aDbf, {"USLOV2"    , "C", 80, 0})
    AADD (aDbf, {"SINT2"     , "C",  2, 0})          // "Sn" ili "  "
    AADD (aDbf, {"PREDZNAK2" , "N",  2, 0})          // "-1" ili " 1"
  endif

  // polja koja su neophodna za slucaj razlicitih uslova(filtera) na
  // izvjestajnim kolonama
  // ---------------------------------------------------------------
  if !EMPTY(aKolS)
    FOR i:=1 TO LEN(aKolS)
      AADD (aDbf, {aKolS[i,1]     , "N", 15, 2})
    NEXT
  endif


  DBCREATE2 (PRIVPATH+"POM", aDbf)
  SELECT (F_POM)
#ifdef CAX
  if !used()
    AX_AutoOpen(.f.)
    usex (PRIVPATH+"pom")
    AX_AutoOpen(.t.)
  endif
#else
  usex (PRIVPATH+"pom")
#endif

  INDEX ON KONTO  TAG "1"
  if lDvaKonta
    INDEX ON KONTO2 TAG "2"
  endif
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
  cFilter := "DATDOK<="+cm2str(dDo)

  if !lKumSuma .and. !lKljuc
    cFilter += (".and.DATDOK>="+cm2str(dOd))
  endif

  // priprema kljucnih baza za izvjestaj (indeksi, filteri)
  // ------------------------------------------------------
  MsgO("Indeksiranje i filterisanje u toku...")
   PripKBPI()
  MsgC()

  MsgO("Counting ...")
  nStavki:=0
#ifdef CAX
  GO BOTTOM
  nStavki:=AX_KeyNo()
#else
  GO TOP
  nStavki:=cmxKeyCount()
  //COUNT TO nStavki
#endif
  Msgc()


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
    if KONIZ->ri == 0
      SKIP 1; LOOP
    endif

    // na osnovu tipa stavke u KONIZ-u odreÐujemo dalje akcije
    cTK11  := UPPER(LEFT(KONIZ->k,1))
    cTK12  := VAL(RIGHT(KONIZ->k,1))

    if cTK11=="K"     // idi po kljucu
      lKljuc:=.t.
      EXIT
    endif

    lDrugiKonto:=.f.
    if cTK11=="A"
      cUslovA := LEFT( KONIZ->id , cTK12 )
      Sel_KSif()
      SEEK cUslovA
      if LEFT( id , cTK12 ) != cUslovA .and. EMPTY(KONIZ->id2)
        SELECT KONIZ; SKIP 1; LOOP
      elseif !EMPTY(KONIZ->id2)
        lDrugiKonto:=.t.
      endif
    endif

    DO WHILE !lDrugiKonto            // ova petlja sluzi samo ako je cTK11="A"

      cIdKonto:=KONIZ->id

      if !EMPTY(KONIZ->fi)                                // po formuli
        if LEFT(KONIZ->fi,1)!="="
          aUslov:=Parsiraj(KONIZ->fi,cPIKPolje,"C")
        else
          aUslov:=".f."
        endif
        cTipK:="F"
        cNazKonta:=KONIZ->opis
      elseif cTK11=="A"
        cNazKonta:=IzKSif("naz")
        cIdKonto:=IzKSif("id")
        if RIGHT(ALLTRIM(cIdKonto),1)=="0"       // sintetika
          cTipK:="S"
          cUslov:=ALLTRIM(cIdKonto)
          DO WHILE RIGHT(cUslov,1)=="0"
            cUslov:=LEFT(cUslov,LEN(cUslov)-1)
          ENDDO
        else                                      // analitika
          cTipK:="A"
        endif
      elseif cTK11=="S"
        if EMPTY(KONIZ->opis)
          cNazKonta:=Ocitaj(F_KSif(),cIdKonto,"naz")
        else
          cNazKonta:=KONIZ->opis
        endif
        cTipK:="S"
        cUslov := LEFT( cIdKonto , cTK12 )
      elseif RIGHT(ALLTRIM(cIdKonto),1)=="0"       // sintetika
        if EMPTY(KONIZ->opis)
          cNazKonta:=Ocitaj(F_KSif(),cIdKonto,"naz")
        else
          cNazKonta:=KONIZ->opis
        endif
        cTipK:="S"
        cUslov:=ALLTRIM(cIdKonto)
        DO WHILE RIGHT(cUslov,1)=="0"
          cUslov:=LEFT(cUslov,LEN(cUslov)-1)
        ENDDO
      else                                          // analitika
        cNazKonta:=Ocitaj(F_KSif(),cIdKonto,"naz")
        cTipK:="A"
      endif

      SELECT POM
      APPEND BLANK
      REPLACE NRBR       WITH ++nPomRbr                        ,;
              KONTO      WITH cIdKonto                         ,;
              IMEKONTA   WITH cNazKonta                        ,;
              PODVUCI    WITH KONIZ->podvuci                   ,;
              K1         WITH KONIZ->k1                        ,;
              U1         WITH KONIZ->u1                        ,;
              AOP        WITH STR(KONIZ->RI,5)
      if cTipK!="P"
        REPLACE PREDZNAK   WITH KONIZ->predzn
      else
        REPLACE PREDZNAK   WITH 1
        RazvijUslove(KONIZ->fi)
      endif
      if cTipK=="F"
        REPLACE uslov WITH KONIZ->fi
      elseif cTipK=="S"
        REPLACE sint WITH "S"+ALLTRIM(STR(LEN(cUslov)))
      elseif cTipK=="P"
        REPLACE sint WITH "F"+ALLTRIM(STR(LEN(cUslov)))
      endif

      if cTK11!="A"
        EXIT
      else
        Sel_KSif()
        SKIP 1
        if LEFT( id , cTK12 ) != cUslovA
          EXIT
        endif
      endif

    ENDDO                          // ova petlja sluzi samo ako je cTK11="A"

    SELECT KONIZ

    if !lDvaKonta; SKIP 1; LOOP; endif

    cTK21  := UPPER(LEFT(KONIZ->k2,1))
    cTK22  := VAL(RIGHT(KONIZ->k2,1))

    if cTK21=="A"
      cUslovA2 := LEFT( KONIZ->id2 , cTK22 )
      Sel_KSif()
      SEEK cUslovA2
      if LEFT( id , cTK22 ) != cUslovA2
        SELECT KONIZ; SKIP 1; LOOP
      endif
    endif

    DO WHILE !EMPTY(KONIZ->id2+KONIZ->fi2)  // ova petlja se vrti samo ako je
                                            // cTK21="A"
      cIdKonto2:=KONIZ->id2

      if !EMPTY(KONIZ->fi2)                                // po formuli
        aUslov2:=Parsiraj(KONIZ->fi2,cPIKPolje,"C")
        cTipK2:="F"
        cNazKonta:=KONIZ->opis
      elseif cTK21=="A"
        cNazKonta:=IzKSif("naz")
        cIdKonto2:=IzKSif("id")
        if RIGHT(ALLTRIM(cIdKonto2),1)=="0"       // sintetika
          cTipK2:="S"
          cUslov2:=ALLTRIM(cIdKonto2)
          DO WHILE RIGHT(cUslov2,1)=="0"
            cUslov2:=LEFT(cUslov2,LEN(cUslov2)-1)
          ENDDO
        else                                      // analitika
          cTipK2:="A"
        endif
      elseif cTK21=="S"
        cNazKonta:=Ocitaj(F_KSif(),cIdKonto2,"naz")
        cTipK2:="S"
        cUslov2 := LEFT( cIdKonto2 , cTK22 )
      elseif RIGHT(ALLTRIM(cIdKonto2),1)=="0"       // sintetika
        cNazKonta:=Ocitaj(F_KSif(),cIdKonto2,"naz")
        cTipK2:="S"
        cUslov2:=ALLTRIM(cIdKonto2)
        DO WHILE RIGHT(cUslov2,1)=="0"
          cUslov2:=LEFT(cUslov2,LEN(cUslov2)-1)
        ENDDO
      else                                          // analitika
        cNazKonta:=Ocitaj(F_KSif(),cIdKonto2,"naz")
        cTipK2:="A"
      endif

      SELECT POM
      if lDrugiKonto
        APPEND BLANK
        REPLACE NRBR       WITH ++nPomRbr                        ,;
                KONTO      WITH KONIZ->id                        ,;
                IMEKONTA   WITH cNazKonta                        ,;
                PODVUCI    WITH KONIZ->podvuci                   ,;
                K1         WITH KONIZ->k1                        ,;
                U1         WITH KONIZ->u1                        ,;
                AOP        WITH STR(KONIZ->RI,5)
        REPLACE PREDZNAK   WITH KONIZ->predzn
      endif
      REPLACE KONTO2     WITH cIdKonto2
      REPLACE PREDZNAK2  WITH KONIZ->predzn2
      if cTipK2=="F"
        REPLACE uslov2 WITH KONIZ->fi2
      elseif cTipK2=="S"
        REPLACE sint2 WITH "S"+ALLTRIM(STR(LEN(cUslov2)))
      endif

      if cTK21!="A"
        EXIT
      else
        Sel_KSif()
        SKIP 1
        if LEFT( id , cTK22 ) != cUslovA2
          EXIT
        endif
      endif

    ENDDO                          // ova petlja sluzi samo ako je cTK21="A"

    SELECT KONIZ; SKIP 1
  ENDDO                                       // listam KONIZ.DBF
  // --------------------------
  // KRAJ pripreme baze POM.DBF
  // --------------------------


  // ---------------------------------------------------------------
  // konacno, uzimam podatke iz osnovnog izvora podataka (SUBAN.DBF)
  // i smjestam ih u POM.DBF prema postojecim formulama i uslovima
  // ---------------------------------------------------------------
  if lKljuc                               // varijanta KONIZ->K="K"


    nPomRbr:=0
    nPr:=KONIZ->predzn
    
    Sel_KBaza()
    GO TOP

    if lArtikli
      cLastArt:=idroba
      nArr:=SELECT()
      SELECT ROBA; HSEEK cLastArt
      SELECT (nArr)
    endif

    DO WHILE !EOF()
      cIdKonto:=&cPIKPolje
      nDug:=nPot:=0
      FOR i:=1 TO LEN(aKolS)
        aKolS[i,3]:=0
      NEXT
      DO WHILE !EOF() .and. cIdKonto==&cPIKPolje
        if lArtikli
          if cLastArt<>idroba
            cLastArt:=idroba
            nArr:=SELECT()
            SELECT ROBA; HSEEK cLastArt
            SELECT (nArr)
          endif
        endif
        Postotak(2,++nStavki)
        FOR i:=1 TO LEN(aKolS)
          cPom   := aKolS[i,2]
          cPomIS := aKolS[i,4]
          if EMPTY(cPomIS); cPomIS:="iznosbhd"; endif
          if &cPom
              aKolS[i,3] += (&cPomIS*nPr)
          endif
        NEXT
        SKIP 1
      ENDDO

      // formula 2 polje (fi2) u KONIZ.DBF iskoristeno za dodatni uslov po redovima
      if !empty(koniz->fi2)
       if ! &(koniz->fi2)
           Sel_KBaza()
           loop
       endif
      endif

      SELECT POM
      APPEND BLANK
      FOR i:=1 TO LEN(aKolS)
        cPom:=aKolS[i,1]
        REPLACE &cPom WITH aKolS[i,3]
      NEXT
      REPLACE KONTO WITH cIdKonto
      if cPIKSif!="BEZ"
        REPLACE IMEKONTA WITH Ocitaj( F_KSif(),;
                                      PADR(cIdKonto,LEN(IzKSif("ID"))),;
                                      "naz")
      endif
      REPLACE NRBR WITH ++nPomRbr

      Sel_KBaza()
    ENDDO

  else

    Sel_KBaza()
    GO TOP

    DO WHILE !EOF()
      cIdKonto:=&cPIKPolje
      nDug:=nPot:=nPrDug:=nPrPot:=0
      DO WHILE !EOF() .and. cIdKonto==&cPIKPolje
        Postotak(2,++nStavki)
        // çta sa DATDOK, IZNOSBHD i D_P ?!  VA¦NO!
        // ---------------
        if !lKumSuma .or. datdok>=dOd   // tekuci period (od datuma dOd)
          if D_P=="1"           // dug.
            nDug += iznosbhd
          else                  // pot.
            nPot += iznosbhd
          endif
        else             // bitno samo za kumul.period (od datuma "  .  .  ")
          if D_P=="1"           // dug.
            nPrDug += iznosbhd
          else                  // pot.
            nPrPot += iznosbhd
          endif
        endif
        SKIP 1
      ENDDO

      nTekSuma := nDug - nPot
      nKumSuma := nTekSuma + nPrDug - nPrPot

      SELECT POM; SET ORDER TO TAG "1"; GO TOP
      DO WHILE !EOF() .and. EMPTY(konto)
        if EMPTY(uslov).or.LEFT(uslov,1)=="="; SKIP 1; LOOP; endif
        aUslov:=PARSIRAJ(uslov,"cIdKonto","C")
        if &aUslov
           REPLACE kumsuma    WITH predznak * nKumSuma + kumsuma     ,;
                   teksuma    WITH predznak * nTekSuma + teksuma     ,;
                   duguje     WITH nDug + duguje                     ,;
                   potrazuje  WITH nPot + potrazuje
        endif
        SKIP 1
      ENDDO
      SEEK LEFT(cIdKonto,1)
      DO WHILE !EOF() .and. cIdKonto>=PADR(konto,LEN(cIdKonto))
        if LEFT(sint,1)=="S" .and. LEFT(cIdKonto,VAL(RIGHT(sint,1))) == LEFT(konto,VAL(RIGHT(sint,1))) .or. cIdKonto==PADR(konto,LEN(cIdKonto))
           REPLACE kumsuma    WITH predznak * nKumSuma + kumsuma     ,;
                   teksuma    WITH predznak * nTekSuma + teksuma     ,;
                   duguje     WITH nDug + duguje                     ,;
                   potrazuje  WITH nPot + potrazuje
        endif
        SKIP 1
      ENDDO

      if !lDvaKonta; Sel_KBaza(); LOOP; endif

      SELECT POM; SET ORDER TO TAG "2"; GO TOP
      DO WHILE !EOF() .and. EMPTY(konto2)
        if EMPTY(uslov2); SKIP 1; LOOP; endif
        aUslov:=PARSIRAJ(uslov2,"cIdKonto","C")
        if &aUslov
           REPLACE kumsuma2    WITH predznak2 * nKumSuma + kumsuma2     ,;
                   teksuma2    WITH predznak2 * nTekSuma + teksuma2     ,;
                   duguje2     WITH nDug + duguje2                      ,;
                   potrazuje2  WITH nPot + potrazuje2
        endif
        SKIP 1
      ENDDO
      SEEK LEFT(cIdKonto,1)
      DO WHILE !EOF() .and. cIdKonto>=PADR(konto2,LEN(cIdKonto))
        if LEFT(sint2,1)=="S" .and. LEFT(cIdKonto,VAL(RIGHT(sint2,1))) == LEFT(konto2,VAL(RIGHT(sint2,1))) .or. cIdKonto==PADR(konto2,LEN(cIdKonto))
           REPLACE kumsuma2    WITH predznak2 * nKumSuma + kumsuma2     ,;
                   teksuma2    WITH predznak2 * nTekSuma + teksuma2     ,;
                   duguje2     WITH nDug + duguje2                      ,;
                   potrazuje2  WITH nPot + potrazuje2
        endif
        SKIP 1
      ENDDO

      Sel_KBaza()
    ENDDO                                      // uzimam podatke iz SUBAN.DBF

  endif
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

  SELECT POM; USE

CLOSERET
return
*}



/*! \fn PrikaziTI(cSif)
 *  \brief Prikazuje tekuci izvjestaj
 *  \param cSif - sifra izvjestaja
 */

function PrikaziTI(cSif)
*{
local nArr:=SELECT(), nKol:=COL(), nRed:=ROW()
   SELECT (F_IZVJE)
   SEEK cSif
   if FOUND()
     @ 1,0 SAY PADC("TEKUCI IZVJESTAJ: "+ID+"-"+TRIM(DoHasha(NAZ)),80) COLOR "GR+/N"
   else
     @ 1,0 SAY PADC("TEKUCI IZVJESTAJ: "+cSif+"-nije definisan",80) COLOR "GR+/N"
   endif
   cPIKPolje  := IF(FIELDPOS("KPOLJE" )==0.or.EMPTY(KPOLJE ),"IDKONTO",;
                                                             TRIM(KPOLJE ))
   cPIImeKP   := IF(FIELDPOS("IMEKP"  )==0.or.EMPTY(IMEKP  ),"KONTO"  ,;
                                                             TRIM(IMEKP  ))
   cPIKSif    := IF(FIELDPOS("KSIF"   )==0.or.EMPTY(KSif   ),"KONTO"  ,;
                                                             TRIM(KSif   ))
   cPIKBaza   := IF(FIELDPOS("KBAZA"  )==0.or.EMPTY(KBAZA  ),"KALK",;
                                                             TRIM(KBAZA  ))
   cPIKIndeks := IF(FIELDPOS("KINDEKS")==0.or.EMPTY(KINDEKS),"TAG1",;
                                                             TRIM(KINDEKS))
   cPITipTab  := IF(FIELDPOS("TIPTAB" )==0.or.EMPTY(TIPTAB ),"",;
                                                             TRIM(TIPTAB ))
   SELECT (nArr)
  SETPOS(nRed,nKol)
return
*}



/*! \fn FForPI()
 *  \brief 
 */
 
function FForPI()
*{
local lVrati:=.f.
 if cSaNulama=="D" .or.;
    !lKljuc .and. ( KUMSUMA<>0 .or. TEKSUMA<>0 .or. KPGSUMA<>0 .or.;
                    DUGUJE<>0 .or. POTRAZUJE<>0 .or.;
                    lDvaKonta .and. ( KUMSUMA2<>0 .or. TEKSUMA2<>0 .or.;
                                      DUGUJE2<>0 .or. POTRAZUJE2<>0 ) ) .or.;
    lKljuc .and. VidiUaKolS()
   lVrati:=.t.
 endif
return lVrati
*}


/*! \fn VidiUaKolS()
 *  \brief
 */
 
function VidiUaKolS()
*{
local lVrati:=.f., i:=0
  FOR i:=1 TO LEN(aKolS)
    cPom777:=aKolS[i,1]
    if &cPom777<>0
      lVrati:=.t.
      EXIT
    endif
  NEXT
return lVrati
*}


/*! \fn FSvakiPI()
 *  \brief
 */

function FSvakiPI()
*{
if !lKljuc
   if EMPTY(U1)
     uTekSuma:=TEKSUMA
   else
     private cPUTS
     cPUTS:="TEKSUMA"+TRIM(U1)
     if &cPUTS
       uTekSuma:=ABS(TEKSUMA)
     else
       uTekSuma:=0
     endif
   endif
 endif
return IF(!EMPTY(PODVUCI),"PODVUCI"+PODVUCI,NIL)
*}



/*! \fn ParSviIzvj()
 *  \brief Parametri za sve proizvoljne izvjestaje
 */
 
function ParSviIzvj()
*{
gTabela:=1; cPrikBezDec:="D"; cSaNulama:="D"; nKorZaLands:=-18

O_PARAMS
private cSection:="I", cHistory:=" ", aHistory:={}
RPar("05",@gTabela)
RPar("06",@cPrikBezDec)
RPar("07",@cSaNulama)
RPar("08",@nKorZaLands)

Box(,10,75)
 @ m_x+6,m_y+2 SAY "TABELA(0/1/2)          " GET gTabela VALID gTabela>=0.and.gTabela<=2 PICT "9"
 @ m_x+7,m_y+2 SAY "Gdje moze, prikaz bez decimala? (D/N)" GET cPrikBezDec VALID cPrikBezDec $ "DN" PICT "@!"
 @ m_x+8,m_y+2 SAY "Prikazivati stavke bez prometa? (D/N)" GET cSaNulama VALID cSaNulama $ "DN" PICT "@!"
 @ m_x+9,m_y+2 SAY "Korekcija broja redova (za lendskejp)" GET nKorZaLands PICT "999"
 READ


 READ
BoxC()
if LASTKEY()!=K_ESC
  O_PARAMS
  private cSection:="I",cHistory:=" ",aHistory:={}
  WPar("05",gTabela)
  WPar("06",cPrikBezDec)
  WPar("07",cSaNulama)
  WPar("08",nKorZaLands)
  SELECT PARAMS; USE
endif
return
*}



