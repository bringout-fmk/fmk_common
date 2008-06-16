#include "fmk.ch"


/*! \ingroup ini
  * \var *string FmkIni_ExePath_Fakt_Ugovori_Dokumenata_Izgenerisati
  * \brief Broj ugovora koji se obrade pri jednom pozivu opcije generisanja faktura na osnovu ugovora
  * \param 1 - default vrijednost
  */
*string FmkIni_ExePath_Fakt_Ugovori_Dokumenata_Izgenerisati;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_Fakt_Ugovori_N1
  * \brief Koristi li se za generaciju faktura po ugovorima parametar N1 ?
  * \param D - da, default vrijednost
  * \param N - ne
  */
*string FmkIni_ExePath_Fakt_Ugovori_N1;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_Fakt_Ugovori_N2
  * \brief Koristi li se za generaciju faktura po ugovorima parametar N2 ?
  * \param D - da, default vrijednost
  * \param N - ne
  */
*string FmkIni_ExePath_Fakt_Ugovori_N2;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_Fakt_Ugovori_N3
  * \brief Koristi li se za generaciju faktura po ugovorima parametar N3 ?
  * \param D - da, default vrijednost
  * \param N - ne
  */
*string FmkIni_ExePath_Fakt_Ugovori_N3;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_FAKT_Ugovori_SumirajIstuSifru
  * \brief Da li ce se pri generisanju fakture na osnovu ugovora sabirati kolicine stavki iz ugovora koje sadrze isti artikal u jednu stavku na dokumentu
  * \param D - da, default vrijednost
  * \param N - ne
  */
*string FmkIni_ExePath_FAKT_Ugovori_SumirajIstuSifru;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_Fakt_Ugovori_UNapomenuSamoBrUgovora
  * \brief Da li ce se pri generisanju faktura na osnovu ugovora u napomenu dodati iza teksta "VEZA:" samo broj ugovora 
  * \param D - da, default vrijednost
  * \param N - ne, ispisace se i tekst "UGOVOR:", te datum ugovora
  */
*string FmkIni_ExePath_Fakt_Ugovori_UNapomenuSamoBrUgovora;


// ----------------------------------------------
// funkcija za poziv generacije ugovora
// ----------------------------------------------
function m_gen_ug()

private DFTkolicina:=1
private DFTidroba:=PADR("",10)
private DFTvrsta:="1"
private DFTidtipdok:="10"
private DFTdindem:="KM "
private DFTidtxt:="10"
private DFTzaokr:=2
private DFTiddodtxt:="  "
private gGenUgV2:="1"
private gFinKPath:=SPACE(50)

DFTParUg(.t.)

if gGenUgV2 == "1"
	gen_ug()
else
	// nova varijanta generisanja ugovora
	gen_ug_2()
endif

return


// -----------------------------------------
// generacija ugovora varijanta 1
// -----------------------------------------
function gen_ug()

// otvori tabele
o_ugov()

nN1:=0
nN2:=0
nN3:=0
O_PARAMS
private cSection:="U"
private cHistory:=" "
private aHistory:={}
private cUPartner:=space(IF(gVFU=="1",16,20))
private dDatDok:=ctod(""), cFUArtikal:=SPACE(LEN(ROBA->id))
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

  if lSpecifZips
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

SELECT UGOV

if nTekug=1
  cUPartner:=lefT(cUPartner,IF(gVFU=="1",15,19))+chr(254)
else
  // ne browsaj
  skip 1 // saltaj ugovore
  IF EOF(); EXIT; ENDIF
endif

if empty(cUPartner) // eof()
  exit
endif

if nTekug=1 // kada je vise ugovora, samo prvi browsaj
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

//****** snimi promjene u params.........
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
//******** utvrdjivanje broja dokumenta **************

    cIdTipdok:=ugov->idtipdok

   if lSpecifZips
      if nn3=1 .and. ugov->idtipdok="20" // konverzija 20->10
         cIdTipDok:="10"
      endif
   endif

   select pripr
   seek gFirma+cidtipdok+"È"
   skip -1
   if idtipdok <> cIdTipdok
     seek "È" // idi na kraj, nema zeljenih dokumenata
   endif

   select fakt
   seek gFirma+cidtipdok+"È"
   skip -1

   if idtipdok <> cIdTipdok
     seek "È" // idi na kraj, nema zeljenih  dokumenata
   endif

   if pripr->brdok > fakt->brdok
     select pripr  // odaberi tabelu u kojoj ima vise dokumenata
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
    IF nTekUg>2 
    	--nTekUg
    ENDIF
    loop
endif

cIdUgov:=id



// !!! vrtim kroz rugov
select rugov
nRbr:=0

seek cidugov

// prvi krug odredjuje glavnicu
nGlavnica:=0  // jedna stavka mo§e biti glavnica za ostale
do while !eof() .and. id==cidugov
   select roba; hseek rugov->idroba
   select rugov
   if K1=="G"
//     nGlavnica+=kolicina*roba->vpc
     nGlavnica+=kolicina*10
   endif
   skip
enddo

seek cidugov

// RUGOV.DBF
// ---------
do while !eof() .and. id==cidugov

   IF lSpecifZips .and. !( EMPTY(cFUArtikal) .or. idroba==cFUArtikal )
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
     SELECT RUGOV; SKIP 1; LOOP
   ELSE
     append blank; Scatter()
   ENDIF

   if nRbr==0
    select PARTN
    hseek ugov->idpartner
    _txt3b := _txt3c:=""
    _txt3a := PADR(ugov->idpartner+".", 30)
    
    IzSifre(.t.)
    
    select ftxt; hseek ugov->iddodtxt; cDodTxt:=TRIM(naz)
    hseek ugov->idtxt
    private _Txt1:=""

    select roba; hseek rugov->idroba
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
         Chr(16)+trim(ftxt->naz)+chr(13)+chr(10)+;
         IF(gNovine=="D","",cVezaUgovor+chr(13)+chr(10))+;
         cDodTxt+Chr(17)+Chr(16)+_Txt3a+ Chr(17)+ Chr(16)+_Txt3b+Chr(17)+;
         Chr(16)+_Txt3c+Chr(17)

   endif


   select pripr

   private nKolicina:=rugov->kolicina


   if rugov->k1="A"  // onda je kolicina= A2-A1  (novo stanje - staro stanje)
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
   elseif rugov->k1="B"
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
   elseif rugov->k1="%"   // procenat na neku stavku
      nKolicina:=1
      nCijena:=rugov->kolicina*nGlavnica/100
   elseif rugov->k1="1"   // kolicinu popunjava ulazni parametar n1
       nKolicina:=nn1
   elseif rugov->k1="2"   // kolicinu popunjava ulazni parametar n2
       nKolicina:=nn2
   elseif rugov->k1="3"   // kolicinu popunjava ulazni parametar n3
       nKolicina:=nn3
   endif

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
   _datpl:=dDatDok
   _kolicina:=nKolicina
   _idroba:=rugov->idroba
   select roba; hseek _idroba

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


//****************** izgenerisati n dokumenata ***********
next

closeret
return
*}


