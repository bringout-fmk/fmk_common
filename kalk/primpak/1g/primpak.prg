#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/primpak/1g/primpak.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.2 $
 * $Log: primpak.prg,v $
 * Revision 1.2  2002/06/20 13:14:14  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/primpak/1g/primpak.prg
 *  \brief Operacija svodjenja artikala na primarno pakovanje
 */


/*! \fn NaPrimPak()
 *  \brief Svedi artikle na primarno pakovanje
 */

function NaPrimPak()
*{
 LOCAL nStavki:=0, nKolicina:=0, nUlaz:=0, nIzlaz:=0, dDatKalk, cBrDok
  IF IzFMKIni("Svi","Sifk")<>"D"
    MsgBeep("Sifrarnik dodatnih karakteristika nedostupan! (Sifk<>'D')")
    RETURN
  ENDIF

  O_KONCIJ
  O_ROBA
  O_PRIPR
  O_DOKS
  O_KALK
  O_SIFK; O_SIFV

  dDatKalk:=DATE()
  qqProd:=PADR("132;",80)
  qqRoba:=SPACE(80)

  Box("#USLOVI ZA GENERISANJE DOKUMENTA SVODJENJA NA PRIMARNO PAKOVANJE",5,70)
   DO WHILE .t.
    @ m_x+2, m_y+2 SAY "PRODAVNICE:" GET qqProd PICT "@S30"
    @ m_x+3, m_y+2 SAY "ROBA      :" GET qqRoba PICT "@S30"
    @ m_x+4, m_y+2 SAY "DATUM DOK.:" GET dDatKalk
    READ; ESC_BCR
    aUsl1 := Parsiraj(qqProd,"PKONTO")
    // aUsl1 := Parsiraj(qqProd,"MKONTO")
    aUsl2 := Parsiraj(qqRoba,"IDROBA")
    IF aUsl1<>NIL .and. aUsl2<>NIL; EXIT; ENDIF
   ENDDO
  BoxC()

  // utvrdimo broj nove kalkulacije
  // ------------------------------
  cIdVdI:="80"
  cIdFirma:=gFirma
  SELECT DOKS; SEEK cIdFirma+cIdVdI+CHR(255); SKIP -1
  IF cIdFirma+cIdVdI == IDFIRMA+IDVD
     cBrDok := brdok
  ELSE
     cBrDok := space(8)
  ENDIF
  cBrDok := UBrojDok(val(left(cBrDok,5))+1,5,right(cBrDok,3))
  nRBr:=0

  // postavimo odgovarajuci indeks i filter na KALK
  // ----------------------------------------------
  cFilter:=aUsl1+".and."+aUsl2+".and. !EMPTY(PKONTO)"
  // cFilter:=aUsl1+".and."+aUsl2+".and. !EMPTY(MKONTO)"
  SELECT KALK
  SET ORDER TO TAG "4"
  // SET ORDER TO TAG "3"       // "3" - magacin
  SET FILTER TO &cFilter

#ifdef CAX
  GO BOTTOM
  nStavki:=AX_KeyNo()
#else
  GO TOP
  COUNT TO nStavki
//  nStavki:=RECCOUNT()
#endif

  Postotak(1,nStavki,"Generacija dokumenata")
  nStavki:=0
  GO TOP
  DO WHILE !EOF()
    cIdKonto := PKONTO
    SELECT KONCIJ; HSEEK cIdKonto
    SELECT KALK
    DO WHILE !EOF() .and. PKONTO==cIdKonto
      cIdRoba:=IDROBA
      nUlaz:=nIzlaz:=nMPV:=nNV:=0
      // kartica artikla
      // ---------------
      DO WHILE !EOF() .and. PKONTO==cIdKonto .and. IDROBA==cIdRoba
        KaKaProd(@nUlaz,@nIzlaz,@nMPV,@nNV)
        Postotak(2,++nStavki)
        SKIP 1
      ENDDO
      select sifv   // "ID","id+oznaka+IdSif+Naz"
      set order to tag "ID"
      seek padr("ROBA",8)+"PAKO"+padr(cIdRoba,15)
      aSastav:={}
      // napuni matricu aSastav parovima ("SIFRA",KOLICINA)
      // --------------------------------------------------
      do while !eof() .and. (id+oznaka+idsif=PADR("ROBA",8)+"PAKO" + padr(cIdRoba,15) )
        cPom:=trim(naz)
        if numtoken(cPom,"_")=2
          AADD (aSastav, { token(cPom,"_",1) , val(token(cPom,"_",2))  } )
        endif
        skip
      enddo
      select pripr
      // generisi stavke storna zaduzenja primarnih pakovanja ("sirovina")
      // -----------------------------------------------------------------
      nUkNV:=0
      FOR i:=1 TO LEN(aSastav)
        cIdPrim:=aSastav[i,1]
        select ROBA; seek cIdPrim
        nKolicina:=aSastav[i,2]
        nNC := NCuMP(cIdFirma,cIdPrim,cIdKonto,;
                     (nUlaz-nIzlaz) * nKolicina,dDatKalk)
        select PRIPR
        if ( (nulaz-nizlaz)*nkolicina  <> 0 )
          append blank
          nRBr++
          replace idfirma    with cIdFirma       ,;
                  rbr        with str(nRbr,3)    ,;
                  idvd       with cIdVdI         ,;
                  brdok      with cBrDok         ,;
                  datdok     with dDatKalk       ,;
                  idtarifa   with ROBA->idtarifa ,;
                  brfaktp    with ""             ,;
                  datfaktp   with dDatKalk       ,;
                  idkonto    with cidkonto       ,;
                  idzaduz    with ""             ,;
                  idkonto2   with ""             ,;
                  idzaduz2   with ""             ,;
                  datkurs    with dDatKalk       ,;
                  nc         with nNC            ,;
                  mpc        with 0              ,;
                  tmarza2    with "A"            ,;
                  tprevoz    with "A"            ,;
                  mpcsapp    with UzmiMPCSif()   ,;
                  idroba     with cidPrim        ,;
                  KOLICINA   with (nUlaz-nIzlaz) * nKolicina
          nUkNV += kolicina*nc
        endif
      NEXT
      // generisi stavku zaduzenja sekundarnog pakovanja
      // -----------------------------------------------
      if len(aSastav) != 0
        select ROBA; hseek cidroba
        select PRIPR        // priprema dokumenta
        if ( (nulaz-nizlaz)  <> 0 )
          nRBr++
          append blank
          // zaduzi sekundarno pakovanje, uobicajeno je nulaz-nizlaz = -50 pak
          replace idfirma    with cIdFirma             ,;
                  rbr        with str(nRbr,3)          ,;
                  idvd       with cIdVdI               ,;
                  brdok      with cBrDok               ,;
                  datdok     with dDatKalk             ,;
                  idtarifa   with ROBA->idtarifa       ,;
                  brfaktp    with ""                   ,;
                  datfaktp   with dDatKalk             ,;
                  idkonto    with cidkonto             ,;
                  idzaduz    with ""                   ,;
                  idkonto2   with ""                   ,;
                  idzaduz2   with ""                   ,;
                  datkurs    with dDatKalk             ,;
                  nc         with nUkNV/(nUlaz-nIzlaz) ,;
                  mpc        with 0                    ,;
                  tmarza2    with "A"                  ,;
                  tprevoz    with "A"                  ,;
                  mpcsapp    with UzmiMPCSif()         ,;
                  idroba     with cidroba              ,;
                  KOLICINA   with -(nUlaz-nIzlaz)
        endif
      endif
      SELECT KALK
    ENDDO
    cBrDok := UBrojDok(val(left(cBrDok,5))+1,5,right(cBrDok,3))
    nRBr:=0
  ENDDO
  Postotak(-1)
  MsgBeep("Obradite izgenerisane dokumente u pripremi!")
CLOSERET
return
*}




/*! \fn NaPrPak2()
 *  \brief Svedi artikle na primarno pakovanje v.2
 */

function NaPrPak2()
*{
 LOCAL nStavki:=0, nKolicina:=0, nUlaz:=0, nIzlaz:=0, dDatKalk, cBrDok
  IF IzFMKIni("Svi","Sifk")<>"D"
    MsgBeep("Sifrarnik dodatnih karakteristika nedostupan! (Sifk<>'D')")
    RETURN
  ENDIF

  O__KALK
  O_KONCIJ
  O_ROBA
  O_PRIPR
  O_DOKS
  O_KALK
  O_SIFK; O_SIFV

  dDatKalk:=PRIPR->datdok

  Box("#USLOVI ZA GENERISANJE DOKUMENTA SVODJENJA NA PRIMARNO PAKOVANJE",5,70)
    @ m_x+2, m_y+2 SAY "DATUM DOK.:" GET dDatKalk
    READ; ESC_BCR
  BoxC()

  // PRIPR -> _KALK
  // --------------
  SELECT _KALK
  ZAP
  APPEND FROM PRIPR
  SELECT PRIPR
  ZAP

  // utvrdimo broj nove kalkulacije
  // ------------------------------
  cIdVdI:="80"
  cIdFirma:=gFirma
  SELECT DOKS; SEEK cIdFirma+cIdVdI+CHR(255); SKIP -1
  IF cIdFirma+cIdVdI == IDFIRMA+IDVD
     cBrDok := brdok
  ELSE
     cBrDok := space(8)
  ENDIF
  cBrDok := UBrojDok(val(left(cBrDok,5))+1,5,right(cBrDok,3))
  nRBr:=0

  // postavimo odgovarajuci indeks i filter na KALK
  // ----------------------------------------------
  SELECT _KALK
  INDEX ON idFirma+idkonto+idroba+dtos(datdok)+podbr+PU_I+IdVD TO "4"
  SET ORDER TO TAG "4"

#ifdef CAX
  GO BOTTOM
  nStavki:=AX_KeyNo()
#else
  GO TOP
  COUNT TO nStavki
//  nStavki:=RECCOUNT()
#endif

  Postotak(1,nStavki,"Generacija dokumenata")
  nStavki:=0
  GO TOP
  DO WHILE !EOF()
    IF idvd!="42"; SKIP 1; LOOP; ENDIF
    cIdKonto := IDKONTO
    SELECT KONCIJ; HSEEK cIdKonto
    SELECT _KALK
    DO WHILE !EOF() .and. IDKONTO==cIdKonto
      cIdRoba:=IDROBA
      nUlaz:=nIzlaz:=nMPV:=nNV:=0
      // realizacija artikla
      // -------------------
      DO WHILE !EOF() .and. IDKONTO==cIdKonto .and. IDROBA==cIdRoba
        nIzlaz += kolicina
        Postotak(2,++nStavki)
        SKIP 1
      ENDDO
      select sifv   // "ID","id+oznaka+IdSif+Naz"
      set order to tag "ID"
      seek padr("ROBA",8)+"PAKO"+padr(cIdRoba,15)
      aSastav:={}
      // napuni matricu aSastav parovima ("SIFRA",KOLICINA)
      // --------------------------------------------------
      do while !eof() .and. (id+oznaka+idsif=PADR("ROBA",8)+"PAKO" + padr(cIdRoba,15) )
        cPom:=trim(naz)
        if numtoken(cPom,"_")=2
          AADD (aSastav, { token(cPom,"_",1) , val(token(cPom,"_",2))  } )
        endif
        skip
      enddo
      SELECT PRIPR
      // generisi stavke storna zaduzenja primarnih pakovanja ("sirovina")
      // -----------------------------------------------------------------
      nUkNV:=0
      FOR i:=1 TO LEN(aSastav)
        cIdPrim:=aSastav[i,1]
        select ROBA; seek cIdPrim
        nKolicina:=aSastav[i,2]
        nNC := NCuMP(cIdFirma,cIdPrim,cIdKonto,;
                     (nUlaz-nIzlaz) * nKolicina,dDatKalk)
        select PRIPR
        if ( (nulaz-nizlaz)*nkolicina  <> 0 )
          append blank
          nRBr++
          replace idfirma    with cIdFirma       ,;
                  rbr        with str(nRbr,3)    ,;
                  idvd       with cIdVdI         ,;
                  brdok      with cBrDok         ,;
                  datdok     with dDatKalk       ,;
                  idtarifa   with ROBA->idtarifa ,;
                  brfaktp    with ""             ,;
                  datfaktp   with dDatKalk       ,;
                  idkonto    with cidkonto       ,;
                  idzaduz    with ""             ,;
                  idkonto2   with ""             ,;
                  idzaduz2   with ""             ,;
                  datkurs    with dDatKalk       ,;
                  nc         with nNC            ,;
                  mpc        with 0              ,;
                  tmarza2    with "A"            ,;
                  tprevoz    with "A"            ,;
                  mpcsapp    with UzmiMPCSif()   ,;
                  idroba     with cidPrim        ,;
                  KOLICINA   with (nUlaz-nIzlaz) * nKolicina
          nUkNV += kolicina*nc
        endif
      NEXT
      // generisi stavku zaduzenja sekundarnog pakovanja
      // -----------------------------------------------
      if len(aSastav) != 0
        select ROBA; hseek cidroba
        select PRIPR        // priprema dokumenta
        if ( (nulaz-nizlaz)  <> 0 )
          nRBr++
          append blank
          // zaduzi sekundarno pakovanje, uobicajeno je nulaz-nizlaz = -50 pak
          replace idfirma    with cIdFirma             ,;
                  rbr        with str(nRbr,3)          ,;
                  idvd       with cIdVdI               ,;
                  brdok      with cBrDok               ,;
                  datdok     with dDatKalk             ,;
                  idtarifa   with ROBA->idtarifa       ,;
                  brfaktp    with ""                   ,;
                  datfaktp   with dDatKalk             ,;
                  idkonto    with cidkonto             ,;
                  idzaduz    with ""                   ,;
                  idkonto2   with ""                   ,;
                  idzaduz2   with ""                   ,;
                  datkurs    with dDatKalk             ,;
                  nc         with nUkNV/(nUlaz-nIzlaz) ,;
                  mpc        with 0                    ,;
                  tmarza2    with "A"                  ,;
                  tprevoz    with "A"                  ,;
                  mpcsapp    with UzmiMPCSif()         ,;
                  idroba     with cidroba              ,;
                  KOLICINA   with -(nUlaz-nIzlaz)
        endif
      endif
      SELECT _KALK
    ENDDO
    cBrDok := UBrojDok(val(left(cBrDok,5))+1,5,right(cBrDok,3))
    nRBr:=0
  ENDDO
  Postotak(-1)

  SELECT PRIPR
  IF RECCOUNT()>0
    UzmiIzINI(PRIVPATH+"FMK.INI","Indikatori","ImaU_KALK","D","WRITE")
    MsgBeep("Stavke iz pripreme su privremeno sklonjene!"+;
           "#Prvo obradite izgenerisane stavke u pripremi, a nakon"+;
           "#azuriranja sklonjene stavke bice vracene u pripremu!")
  ELSE
    APPEND FROM _KALK
    MsgBeep("Nema stavki za generaciju dokumenta "+cIdVdI+"!")
  ENDIF

CLOSERET
return
*}

