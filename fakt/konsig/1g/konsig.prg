#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/konsig/1g/konsig.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.1 $
 * $Log: konsig.prg,v $
 * Revision 1.1  2002/06/26 18:06:43  ernad
 *
 *
 * ciscenja fakt
 *
 *
 */
 
/*! \fn GKRacun()
 *  \brief Generisi Konsignacioni Racun
 */
 
function GKRacun()
*{
O_PRIPR
O_FAKT
SET ORDER TO TAG "3"
O_PARTN
O_FTXT
O_ROBA
O_SIFK
O_SIFV

dOd := dDo := CTOD("")
cIdPrinc := SPACE(6)
cIdKupac := SPACE(6)
qqTipDok := PADR("10;",20)
qqRJ     := PADR("10;",20)
cIdRj    := "20"
dDatDok  := DATE()
cFTXT    := "16"

O_PARAMS
private cSection:="G",cHistory:=" "; aHistory:={}
Params1()
RPar("c1",@qqRJ    )
RPar("c2",@dOd     )
  RPar("c3",@dDo     )
  RPar("c4",@cIdPrinc)
  RPar("c5",@qqTipDok)
  RPar("c6",@cIdRJ   )
  RPar("c7",@cIdKupac)
  RPar("c8",@cFTXT   )

  Box(,11,75)
    DO WHILE .t.

      @ m_x+ 0, m_y+2 SAY "GENERISANJE KONSIGNACIONOG RACUNA NA OSNOVU PRODAJE"

      @ m_x+ 2,   m_y+2 SAY "Uslov za RJ" GET qqRJ
      @ m_x+ 3,   m_y+2 SAY "Za period od" GET dOd
      @ m_x+ 3, col()+2 SAY "do" GET dDo
      @ m_x+ 4,   m_y+2 SAY "Principal" GET cIdPrinc VALID P_Firma(@cIdPrinc,4,20)
      @ m_x+ 5,   m_y+2 SAY "Vrste dokumenata prodaje" GET qqTipDok

      @ m_x+ 7,   m_y+2 SAY "Konsignacija se vodi na RJ:" GET cIdRJ // P_RJ(@cIdRJ,7,35)
      @ m_x+ 8,   m_y+2 SAY "Kome se fakturise (partner):" GET cIdKupac VALID P_Firma(@cIdKupac,8,39)
      @ m_x+ 9,   m_y+2 SAY "Datum konsignacionog racuna:" GET dDatDok
      @ m_x+10,   m_y+2 SAY "Napomena na kraju racuna(ID)" GET cFTXT

      READ; ESC_BCR

      aUsl1 := Parsiraj( qqRJ     , "IdFirma"  )
      aUsl2 := Parsiraj( qqTipDok , "IdTipDok" )

      IF aUsl1<>NIL .and. aUsl2<>NIL; EXIT; ENDIF

    ENDDO
  BoxC()

  select params
  WPar("c1",qqRJ    )
  WPar("c2",dOd     )
  WPar("c3",dDo     )
  WPar("c4",cIdPrinc)
  WPar("c5",qqTipDok)
  WPar("c6",cIdRJ   )
  WPar("c7",cIdKupac)
  WPar("c8",cFTXT   )
  use

  SELECT FAKT
  cFilt := "DATDOK<=" + cm2str(dDo) + " .and. DATDOK>=" + cm2str(dOd)
  cFilt += (".and. " + aUsl1)
  cFilt += (".and. " + aUsl2)

  SET FILTER TO &cFilt
  GO TOP

  // matrica pripreme (IDROBA,CARTAR,KOLICINA,CIJENA,ROBA->naz)
  aPrip := {}

  DO WHILE !EOF()
    nKolicina := 0
    cIdRoba:=IDROBA
    DO WHILE !EOF() .and. IDROBA==cIdRoba
      nKolicina += kolicina
      SKIP 1
    ENDDO
    cPom := IzSifK("ROBA","CTAR",cIdRoba,.f.)
    AADD( aPrip , { cIdRoba , cPom , nKolicina , 0 , Ocitaj(F_ROBA,cIdRoba,"naz") } )
  ENDDO

  SET FILTER TO
  SET ORDER TO TAG "1"

  // odredimo novi broj racuna
  // ----------------------------
   select fakt
   seek cIdRJ+"16"+"È"
   skip -1

   if idfirma+idtipdok <> cIdRJ+"16"
      cBrDok:=UBrojDok(1,gNumDio,"")
   else
      cBrDok:=UBrojDok( val(left(brdok,gNumDio))+1, ;
                        gNumDio, ;
                        right(brdok,len(brdok)-gNumDio) ;
                      )
   endif
  // ----------------------------

  SET ORDER TO TAG "3"
  cFilt := "IDFIRMA=" + cm2str(cIdRJ) +;
           " .and. ( IDPARTNER=" + cm2str(cIdPrinc) +;
           " .and. IDTIPDOK='06' .or. IDTIPDOK='16' )"
  SET FILTER TO &cFilt

  cVal:=""   // valuta

  FOR i:=LEN(aPrip) TO 1 STEP -1
    SEEK aPrip[i,1]

    IF !FOUND() .or. idtipdok="16" // tj. ako nema ulaza
      ADEL( aPrip , i )
      ASIZE( aPrip , LEN(aPrip)-1 )
    ELSE
      nCijena := cijena
      cDindem := dindem
      aKart   := {}  // cijena, datum, ulaz, izlaz
      DO WHILE !EOF() .and. IDROBA==aPrip[i,1]
        nPom := ASCAN( aKart , {|x| x[1]=cijena} )
        IF nPom>0
          if idtipdok="06"
            aKart[nPom,2] := datdok
            aKart[nPom,3] += kolicina
          else
            aKart[nPom,4] += kolicina
          endif
        ELSE
          if idtipdok="06"
            AADD( aKart , { cijena , datdok , kolicina , 0 } )
          else
            AADD( aKart , { cijena ,  , 0 , kolicina } )
          endif
        ENDIF
        SKIP 1
      ENDDO
      nProdano := aPrip[i,3]
      aSt      := {}
      FOR j:=1 TO LEN(aKart)
        nStanje := aKart[j,3] - aKart[j,4]
        IF nStanje > 0 .and. nProdano > 0
          nPoSt := IF( nProdano>=nStanje , nStanje , nProdano )
          AADD( aSt , { aKart[j,1] , nPoSt } )
          nProdano -= nPoSt
        ENDIF
      NEXT
      cVal       := cDinDem
      FOR j:=1 TO LEN( aSt )
        IF j==1
          aPrip[i,3] := aSt[j,2]
          aPrip[i,4] := aSt[j,1]
        ELSE
          AADD( aPrip , { , , , , } )
          aPrip[ LEN(aPrip) , 1 ] := aPrip[ i , 1 ]
          aPrip[ LEN(aPrip) , 2 ] := aPrip[ i , 2 ]
          aPrip[ LEN(aPrip) , 3 ] := aSt[ j , 2 ]
          aPrip[ LEN(aPrip) , 4 ] := aSt[ j , 1 ]
          aPrip[ LEN(aPrip) , 5 ] := aPrip[ i , 5 ]
        ENDIF
      NEXT
      IF LEN(aSt)<1
        aPrip[i,4] := nCijena
      ENDIF
    ENDIF
  NEXT

  ASORT( aPrip , , , {|x,y| x[2] < y[2] } )

  SELECT PRIPR
  FOR i:=1 TO LEN(aPrip)
    APPEND BLANK
    Scatter()
     _idfirma   := cIdRj
     _idtipdok  := "16"
     _brdok     := cBrDok
     _datdok    := dDatDok
     _idpartner := cIdKupac
     _dindem    := cVal
     _zaokr     := 2
     _rbr       := STR(i,3)
     _idroba    := aPrip[i,1]
     _serbr     := aPrip[i,2]      // serbr cu iskoristiti za carinsku tarifu
     _kolicina  := aPrip[i,3]
     _cijena    := aPrip[i,4]
     IF i==1
       _txt3a   := cIdKupac+"."
       _txt3b   := ""
       _txt3c   := ""
        IzSifre(.T.)  // da nafiluje _txt3a, _txt3b i _txt3c - NAZIV KUPCA
       _txt1    := aPrip[i,5]                            //  - NAZIV ROBE
       _txt2    := TRIM(Ocitaj(F_FTXT,cFTXT,"naz"))      //  - TXT (NAPOMENA)
       _BrOtp   := ""
       _DatOtp  := CTOD("")
       _BrNar   := ""
       _DatPl   := CTOD("")
       _VezOtpr := ""
       _txt := Chr(16)+trim(_txt1)+Chr(17) + Chr(16)+_txt2+Chr(17)+;
               Chr(16)+trim(_txt3a)+Chr(17) + Chr(16)+_txt3b+Chr(17)+;
               Chr(16)+trim(_txt3c)+Chr(17) +;
               Chr(16)+_BrOtp+Chr(17) +;
               Chr(16)+dtoc(_DatOtp)+Chr(17) +;
               Chr(16)+_BrNar+Chr(17) +;
               Chr(16)+dtoc(_DatPl)+Chr(17) +;
               IIF (Empty (_VezOtpr), "", Chr(16)+_VezOtpr+Chr(17))
     ELSE
       _txt := ""
     ENDIF
    Gather()
  NEXT

CLOSERET
*}

