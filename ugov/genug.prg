#include "sc.ch"

// -------------------------
// Generisi ugovore
// -------------------------
PROCEDURE GenUg()
O_FTXT
O_SIFK
O_SIFV
O_ROBA
O_PARTN
O_UGOV
O_RUGOV


// browsaj ugovor
nN1:=0
nN2:=0
nN3:=0
O_PARAMS
private cSection:="U",cHistory:=" "; aHistory:={}

private cUPartner:=space(IIF(gVFU=="1", 16, 20))

private dDatDok:=ctod("")
private cFUArtikal:=SPACE(LEN(ROBA->id))
private cSamoAktivni:="D"

RPar("uP",@cUPartner)
RPar("dU",@dDatDok)
RPar("P1",@nn1)
RPar("P2",@nn2)
RPar("P3",@nn3)
RPar("P4",@cFUArtikal)
RPar("P5",@cSamoAktivni)
use

nDokGen:=val(IzFMkIni('Fakt_Ugovori',"Dokumenata_Izgenerisati",'1'))

if nDokgen=0
  nDokGen:=1
endif

Box("#PARAMETRI ZA GENERACIJU FAKTURA PO UGOVORIMA",7,70)
  @ m_X+1,m_y+2 SAY "Datum fakture" GET dDAtDok
  if IzFMkIni('Fakt_Ugovori',"N1",'D')=="D"
   @ m_X+2,m_y+2 SAY "Parametar N1 " GET nn1 pict "999999.999"
  endif
  if IzFMkIni('Fakt_Ugovori',"N2",'D')=="D"
   @ m_X+3,m_y+2 SAY "Parametar N2 " GET nn2 pict "999999.999"
  endif
  if IzFMkIni('Fakt_Ugovori',"N3",'D')=="D"
    @ m_X+4,m_y+2 SAY "Parametar N3 " GET nn3 pict "999999.999"
  endif

  if IzFMkIni('FAKT_Specif',"ZIPS",'N')=="D" // specifiŸno zips
    // nn3 varijablu koristim kao indikator konverzije 20->10
    @ m_x+5,m_y+2 SAY "Predracun ili racun (0/1) ? " GET nn3  pict "@!"
    @ m_x+6,m_y+2 SAY "Artikal (prazno-svi)" GET cFUArtikal VALID EMPTY(cFUArtikal).or.P_Roba(@cFUArtikal) pict "@!"
  endif
  @ m_x+7, m_y+2 SAY "Generisati fakture samo na osnovu aktivnih ugovora? (D/N)" GET cSamoAktivni VALID cSamoAktivni$"DN" PICT "@!"

  read
BoxC()

lSamoAktivni := (cSamoAktivni=="D")
SELECT UGOV
if lSamoAktivni
  set filter to aktivan=="D"
endif
GO TOP

for nTekUg:=1 to nDokGen

altd()
SELECT UGOV

if nTekug=1
  cUPartner:=lefT(cUPartner,IF(gVFU=="1",15,19))+chr(254)
else
  // ne browsaj
  skip 1
  IF EOF()
  	EXIT
  ENDIF
endif

// eof()
if empty(cUPartner)
  exit
endif

// kada je vise ugovora, samo prvi browsaj
if nTekug=1 
  P_ugov(cUPartner)
endif

IF gVFU=="1"
  cUPartner:=ugov->(id+idpartner)
ELSE
  cUPartner:=ugov->(naz)
ENDIF

O_FAKT
O_PRIPR
if reccount2()<>0 .and. nTekug=1
  Msg("Neki dokument vec postoji u pripremi")
  closeret
endif

O_PARAMS
private cSection:="U",cHistory:=" "; aHistory:={}
WPar("uP",cUPartner)
WPar("dU",dDatDok)
WPar("P1",nn1)
WPar("P2",nn2)
WPar("P3",nn3)
WPar("P4",cFUArtikal)
WPar("P5",cSamoAktivni)
use

SELECT PRIPR

cIdTipdok:=ugov->idtipdok

// specificno zips
if IzFMkIni('FAKT_Specif',"ZIPS",'N')=="D" 
      // konverzija 20->10
      if nn3=1 .and. ugov->idtipdok="20" 
         cIdTipDok:="10"
      endif
endif

select pripr
seek gFirma+cidtipdok+"È"
skip -1
if idtipdok <> cIdTipdok
     // idi na kraj, nema zeljenih dokumenata
     seek "È" 
endif

select fakt
seek gFirma+cidtipdok+"È"
skip -1

if idtipdok <> cIdTipdok
     seek "È" 
endif

if pripr->brdok > fakt->brdok
   // odaberi tabelu u kojoj ima vise dokumenata
   select pripr  
endif


if cidtipdok<>idtipdok
      cBrDok:=UBrojDok(1,gNumDio,"")
else
      cBrDok:=UBrojDok( val(left(brdok,gNumDio))+1, ;
                        gNumDio, ;
                        right(brdok,len(brdok)-gNumDio) ;
                      )
endif

select ugov
if lSamoAktivni .and. aktivan!="D"
    altd()
    IF nTekUg>2; --nTekUg; ENDIF
    loop
endif

cIdUgov:=id


// !!! vrtim kroz rugov
select rugov
nRbr:=0

seek cidugov

// prvi krug odredjuje glavnicu
// jedna stavka moze biti glavnica za ostale
nGlavnica:=0 
do while !eof() .and. id==cidugov
   select roba; hseek rugov->idroba
   select rugov
   if K1=="G"
      nGlavnica+=kolicina*10
   endif
   skip
enddo

seek cidugov

// RUGOV.DBF
// ---------
do while !eof() .and. id==cidugov

   IF IzFMKIni('FAKT_Specif',"ZIPS",'N')=="D" .and.;
      !( EMPTY(cFUArtikal) .or. idroba==cFUArtikal )
     SKIP 1; LOOP
   ENDIF

   nCijena:=0

   SELECT PRIPR

   IF IzFMKIni('FAKT_Ugovori',"SumirajIstuSifru",'D')=="D" .and.;
      IdFirma+idtipdok+brdok+idroba==gFirma+cIDTipDok+PADR(cBrDok,LEN(brdok))+RUGOV->idroba
     Scatter()
     _kolicina += RUGOV->kolicina
     // tag "1": "IdFirma+idtipdok+brdok+rbr+podbr"
     Gather()
     SELECT RUGOV
     SKIP 1
     LOOP
   ELSE
     append blank; Scatter()
   ENDIF

   if nRbr==0
    select PARTN; hseek ugov->idpartner
    _txt3b:=_txt3c:=""
    _txt3a:=ugov->idpartner+"."
    IzSifre()
    select ftxt
    HSEEK ugov->iddodtxt
    cDodTxt:=TRIM(naz)
    hseek ugov->idtxt
    private _Txt1:=""

    select roba
    HSEEK rugov->idroba
    if roba->tip=="U"
      _txt1:=roba->naz
    else
      _txt1:=" "
    endif
    
    IF IzFMKINI("Fakt_Ugovori","UNapomenuSamoBrUgovora","D")=="D"
      cVezaUgovor := "Veza: "+trim(ugov->id)
    ELSE
      cVezaUgovor := "Veza: UGOVOR: "+trim(ugov->id)+" od "+dtoc(ugov->datod)
    ENDIF
    _txt:=Chr(16)+_txt1 +Chr(17)+;
         Chr(16)+trim(ftxt->naz)+ chr(13)+chr(10)+;
         IF(gNovine=="D","", cVezaUgovor + chr(13)+chr(10)) + ;
         cDodTxt + Chr(17)+ Chr(16)+ _Txt3a + Chr(17)+ Chr(16)+ _Txt3b + Chr(17)+;
         Chr(16)+_Txt3c+Chr(17)

   endif


   select pripr

   private nKolicina:=rugov->kolicina

   do case
     case rugov->k1="A" 
      // onda je kolicina= A2-A1  (novo stanje - staro stanje)
      nA2:=0
      Box(,5,60)
        @ M_X+1,M_Y+2 say ugov->naz
        @ m_x+3,m_y+2 SAY "A: Stara vrijednost:"; ?? ugov->A2
        @ m_x+5,m_y+2 SAY "A: Nova vrijednost (0 ne mjenjaj):" GET nA2 pict "999999.99"
        read
      BoxC()
      if na2<>0
         select ugov
         replace a1 with a2 , a2 with nA2
         select pripr
      endif

      nKolicina:=ugov->(a2-a1)
   
      case rugov->k1="B"
       nB2:=0
       Box(,5,60,,ugov->naz)
         @ M_X+1,M_Y+2 say ugov->naz
         @ m_x+3,m_y+2 SAY "B: Stara vrijednost:"; ?? ugov->B2
         @ m_x+5,m_y+2 SAY "B: Nova vrijednost (0 ne mjenjaj):" GET nB2 pict "999999.99"
         read
       BoxC()
       if nB2<>0
         select ugov
         replace B1 with B2 , B2 with nB2
         select pripr
       endif
       nKolicina:=ugov->(b2-b1)
   
      case rugov->k1="%"  
            // procenat na neku stavku
            nKolicina:=1
            nCijena:=rugov->kolicina*nGlavnica/100
   
      case rugov->k1="1"   
            // kolicinu popunjava ulazni parametar n1
            nKolicina:=nn1

      case rugov->k1="2"   
            // kolicinu popunjava ulazni parametar n2
            nKolicina:=nn2

      case rugov->k1="3"   
            // kolicinu popunjava ulazni parametar n3
            nKolicina:=nn3
   endcase

   private _Txt1:=""

   select roba; hseek rugov->idroba
   if nRbr<>0 .and. roba->tip=="U"
      _txt1:=roba->naz
      _txt:=Chr(16)+_txt1 +Chr(17)
   endif

   _idfirma:= gFirma
   _zaokr:=ugov->zaokr
   _rbr:=str(++nRbr,3)
   _idtipdok:=cidtipdok
   _brdok:=cBrDok
   _datdok:=dDatDok
   _kolicina:=nKolicina
   _idroba:=rugov->idroba
   select roba
   HSEEK _idroba

   Odredi_IDROBA()

   SELECT PRIPR
   setujcijenu()
   if ncijena<>0
     _cijena:=nCijena
   endif
   _rabat:=rugov->rabat
   _porez:=rugov->porez
   _dindem:=ugov->dindem
   select pripr
   Gather()


   select rugov
   skip
enddo


next

closeret
