#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/razdb/1g/ka_ka.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.2 $
 * $Log: ka_ka.prg,v $
 * Revision 1.2  2002/06/24 09:19:02  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/razdb/1g/ka_ka.prg
 *  \brief Preuzimanje kalkulacije iz druge firme
 */


/*! \fn IzKalk2f()
 *  \brief Preuzimanje kalkulacije iz druge firme
 */

function IzKalk2f()
*{
 LOCAL cDir:=KUMPATH, cF
 cDir := IzFMKIni( "KALK"                                            ,;
                   "PutanjaKumulativaDrugeFirmeKaoIzvoraKalkulacija" ,;
                   cDir                                              ,;
                   KUMPATH )
 IF RIGHT(cDir,1)!="\"; cDir+="\"; ENDIF
 cDir:=UPPER(cDir)
 cF:=RIGHT(cDir,3); cF:=LEFT(cF,2); cF:=IF(cF="M",RIGHT(cF,1),cF)

 cFirma:="  "

 O_KONTO
 O_PARTN
 O_PRIPR
 IF RECCOUNT2()>0
   MsgBeep("Prvo ispraznite tabelu pripreme!")
   CLOSERET
 ENDIF

 // otvorimo DOKS
 // -------------
 SELECT 0
 USE (cDir+"DOKS.DBF")

 Box("#PRENOS KALK DOKUMENTA IZ FIRME "+cF,10,75)
  DO WHILE .t.

    // biraj magacin (IDFIRMA)
    // -----------------------
    @ m_x+2, m_y+2 SAY "Oznaka firme/magacina" GET cFirma PICT "@!"
    READ
    IF LASTKEY()==K_ESC; EXIT; ENDIF

    // naÐi najstariju KALK koja nikad nije prenoçena (marker<>"PP")
    // -------------------------------------------------------------
    SELECT DOKS
    SET ORDER TO TAG "3" // IdFirma+dtos(datdok)+podbr+idvd+brdok
    HSEEK cFirma
    DO WHILE !EOF() .and. idfirma==cFirma
      IF podbr<>"PP"
        EXIT
      ENDIF
      SKIP 1
    ENDDO

    IF EOF()
      MsgBeep("Za firmu/magacin '"+cFirma+"' ne postoji nijedan dokument "+;
              "koji nije vec prenosen!#Ukucajte sami broj kalkulacije koju "+;
              "zelite ponovo prenijeti!")
      cIDVD:="  "; cBrDok:=SPACE(8)
    ELSE
      cIDVD:=idvd; cBrDok:=brdok
    ENDIF

    // potvrdi ponuÐeni ili unesi broj kalkulacije idfirma-idvd-brkalk
    // ---------------------------------------------------------------
    @ m_x+2, m_y+27 SAY "-" GET cIdVd
    @ m_x+2, m_y+32 SAY "-" GET cBrDok
    READ
    IF LASTKEY()==K_ESC; EXIT; ENDIF

    // provjeri ima li takva kalkulacija i ako je ve† prenoçena daj upozorenje
    // -----------------------------------------------------------------------
    SET ORDER TO TAG "1"  // IdFirma+idvd+brdok
    HSEEK cFirma+cIdVd+cBrDok
    IF !FOUND()
      MsgBeep("Zadana kalkulacija ne postoji!")
      LOOP
    ELSE
      cMKONTO    := MKONTO
      cPKONTO    := PKONTO
      cIDPARTNER := IDPARTNER
      cPom:=" "
      // provjeri da li su ispravni konto i partner
      @ m_x+4, m_y+2 SAY "Provjerite sljedece sifre i ako treba ispravite ih:"
      @ m_x+5, m_y+2 SAY "Magacinski konto " GET cMKONTO    VALID P_Konto(@cMKONTO)
      @ m_x+6, m_y+2 SAY "Prodavnicki konto" GET cPKONTO    VALID P_Konto(@cPKONTO)
      @ m_x+7, m_y+2 SAY "Partner          " GET cIDPARTNER VALID P_Firma(@cIDPARTNER)
      @ m_x+8, m_y+2 SAY "--------<Esc> prekid-----<Enter> nastavak-------" GET cPom
      READ
      IF LASTKEY()==K_ESC; EXIT; ENDIF
    ENDIF

    // poçto je utvrÐeno da postoji, otvaramo KALK radi prenosa
    // --------------------------------------------------------
    SELECT 0
    USE (cDir+"KALK.DBF")
    SET ORDER TO TAG "1" // idFirma+IdVD+BrDok+RBr
    HSEEK cFirma+cIdVd+cBrDok

    DO WHILE !EOF() .and. cFirma+cIdVd+cBrDok==IdFirma+IdVd+BrDok
      Scatter()
      SELECT PRIPR
      APPEND BLANK
      Gather()
      SELECT KALK
      SKIP 1
    ENDDO

    // u DOKS stavimo marker "PP" da je kalkulacija ve† jednom prenoçena
    // -----------------------------------------------------------------
    SELECT KALK
     USE
    SELECT DOKS
     Scatter(); _podbr:="PP"; Gather()
     USE

    // utvrdimo broj nove kalkulacije
    // ------------------------------
    O_DOKS
    SET ORDER TO TAG "1"
    SEEK gFirma+cIdVd+CHR(255); SKIP -1
    IF gFirma+cIdVd == IDFIRMA+IDVD
       cBrDokI := brdok
    ELSE
       cBrDokI := space(8)
    ENDIF
    cBrDokI := UBrojDok(val(left(cBrDokI,5))+1,5,right(cBrDokI,3))

    SELECT PRIPR; SET ORDER TO
    GO TOP
    DO WHILE !EOF()
      Scatter()
       _idfirma   := gFirma
       _brdok     := cBrDokI
       IF _idkonto==_mkonto
         _idkonto := cMKONTO
       ELSEIF _idkonto==_pkonto
         _idkonto := cPKONTO
       ENDIF
       IF _idkonto2==_mkonto
         _idkonto2 := cMKONTO
       ELSEIF _idkonto2==_pkonto
         _idkonto2 := cPKONTO
       ENDIF
       _mkonto    := cMKONTO
       _pkonto    := cPKONTO
       _idpartner := cIDPARTNER
      Gather()
      SKIP 1
    ENDDO

    MsgBeep("Dokument je prenesen. Predjite u tabelu pripreme!")
    EXIT

  ENDDO
 BoxC()

CLOSERET
return
*}

