#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/ugov/1g/genug.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.12 $
 * $Log: genug.prg,v $
 * Revision 1.12  2003/12/12 12:10:27  sasavranic
 * no message
 *
 * Revision 1.11  2003/12/10 11:57:52  sasavranic
 * no message
 *
 * Revision 1.10  2003/12/10 10:57:32  sasavranic
 * prebaceno USEX na USE (POMGN), prebacen meni novina u  mnu_tir.prg
 *
 * Revision 1.9  2003/12/08 15:12:20  sasavranic
 * Dorada za opresu, polje remitenda
 *
 * Revision 1.8  2003/11/28 14:04:56  sasavranic
 * Korekcije kod-a opresa - stampa
 *
 * Revision 1.7  2003/07/07 14:09:44  sasa
 * Prebacene pomocne tabele POMGN i PPOMGN.DBF u KUMPATH
 *
 * Revision 1.6  2003/02/27 01:27:30  mirsad
 * male dorade za zips
 *
 * Revision 1.5  2003/01/19 23:44:17  ernad
 * test network speed (sa), korekcija bl.lnk
 *
 * Revision 1.4  2002/09/13 10:32:45  mirsad
 * dokumentovanje INI parametara
 *
 * Revision 1.3  2002/07/04 08:34:19  mirsad
 * dokumentovanje ini parametara
 *
 * Revision 1.2  2002/06/19 09:38:42  sasa
 * no message
 *
 * Revision 1.1.1.1  2002/06/17 18:30:18  ernad
 * no message
 *
 *
 */


/*! \file fmk/fakt/ugov/1g/genug.prg
 *  \brief Generacija ugovora
 */


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


/*! \ingroup ini
  * \var *string FmkIni_KumPath_STAMPA_RekSort
  * \brief Izraz koji se koristi za sortiranje izvjestaja "Rekapitulacija pripreme tiraza"
  * \param IDROBA - default vrijednost
  */
*string FmkIni_KumPath_STAMPA_RekSort;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_STAMPA_RekNaziv
  * \brief Izraz koji odredjuje sta ce se od podataka o artiklu ispisivati u izvjestaju "Rekapitulacija pripreme tiraza"
  * \param IDROBA+'-'+ROBA->naz - default vrijednost
  */
*string FmkIni_KumPath_STAMPA_RekNaziv;


/*! \fn GenUg()
 *  \brief Generacija ugovora
 */
 
function GenUg()
*{
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
//****************** izgenerisati n dokumenata ***********

altd()
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
    select PARTN; hseek ugov->idpartner
    _txt3b:=_txt3c:=""
    _txt3a:=ugov->idpartner+"."
    IzSifre()
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
   _kolicina:=nKolicina
   _idroba:=rugov->idroba
   select roba; hseek _idroba

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


//****************** izgenerisati n dokumenata ***********
next

closeret
return
*}

/*! \fn PripTiraz()
 *  \brief Priprema tiraza
 */
 
function PripTiraz()
*{
local i:=0
private cIdRoba:=SPACE(10)
private _idtipdok:="01"
private ddatdok:=DATE()
private nKolicina:=0
private cIdPartner:=SPACE(6)

O_PARTN
O_PRIPR
O_FAKT
O_TARIFA
O_SIFK
O_SIFV
O_ROBA
 
if !FILE(KUMPATH+"POMGN.DBF")
	// napravimo pomocnu bazu
   	aDbf := {}
   	AADD (aDbf, {"IDROBA"    , "C", 10, 0})
   	AADD (aDbf, {"DATDOK"    , "D",  8, 0})
  	AADD (aDbf, {"LINIJA"    , "C",  2, 0})
   	AADD (aDbf, {"MARS"      , "C",  3, 0})
   	AADD (aDbf, {"IDPARTNER" , "C",  6, 0})
   	AADD (aDbf, {"NAZIV"     , "C", 30, 0})
   	AADD (aDbf, {"OTPREMKOL" , "N",  6, 0})
   	AADD (aDbf, {"KOLICINA"  , "N",  5, 0})
      	AADD (aDbf, {"VRACENKOL" , "N",  6, 0})
	
	DBCreate2(KUMPATH+"POMGN", aDbf)
   	USE (KUMPATH+"POMGN") NEW
   	INDEX ON BRISANO TAG "BRISAN"
   	INDEX ON IDPARTNER+IDROBA+DTOS(DATDOK) TAG "1"
   	INDEX ON DTOS(DATDOK)+IDPARTNER+IDROBA TAG "2"
   	INDEX ON LINIJA+MARS TAG "3"
   	INDEX ON IDROBA+DTOS(DATDOK)+LINIJA+MARS TAG "4"
   	use
endif

if !FILE(KUMPATH+"POMGN.CDX")
	USE (KUMPATH+"POMGN") NEW
   	INDEX ON BRISANO TAG "BRISAN"
   	INDEX ON IDPARTNER+IDROBA+DTOS(DATDOK) TAG "1"
   	INDEX ON DTOS(DATDOK)+IDPARTNER+IDROBA TAG "2"
  	INDEX ON LINIJA+MARS TAG "3"
   	INDEX ON IDROBA+DTOS(DATDOK)+LINIJA+MARS TAG "4"
   	use
endif

USE (KUMPATH+"POMGN") NEW

// SET ORDER TO TAG "3"
SET ORDER TO TAG "4"

// getuj datum tiraza i izdanje
altd()

nKolicina:=0
cIdRoba:=SPACE(10)
cIdPartner:=SPACE(6)

_idroba:=cIdRoba
_datdok:=dDatDok

Box("#IZBOR TIRAZA ZA PRIPREMU",5,70)
	@ m_x+2, m_y+2 SAY "Datum tiraza      :" GET _DatDok
  	@ m_x+3, m_y+2 SAY "Izdanje           :" GET _IdROba VALID {|| V_Roba(.f.) , IIF(EMPTY(RIGHT(_IdRoba,10-gnDS)),MsgBeep("Niste stavili broj izdanja artikla!"),) , IF(EMPTY(RIGHT(_IdRoba,10-gnDS)),.f.,.t.) } PICT "@!"
  	read
	ESC_BCR
	
	cIdRoba:=_IdRoba
  	dDatDok:=_datdok
  	NSRNPIdRoba(cIdRoba)  // nastimaj sif.robe na cIdRoba

  	select POMGN
	
	// postavi filter na uneseno
  	// SET ORDER TO TAG "3"
  	// SET FILTER TO IDROBA==cIdRoba .and. DATDOK==dDatDok
  	// GO TOP

  	// sada ipak indeks
  	SET ORDER TO TAG "4"
  	HSEEK cIdRoba+DTOS(dDatDok)

  	nUOtpKol:=0

  	// ako nema nista, ponudi automatsku generaciju
  	if EOF() .or. idRoba+DTOS(DATDOK)<>cIdRoba+DTOS(dDatDok)
		@ m_x+4, m_y+2 SAY "Primljena kolicina:" GET nKolicina VALID nKolicina>0 PICT "99999"
    		READ
		ESC_BCR
		lPrethodni:=.f.
    		dPrethodni:=CTOD("")
		if Pitanje(,"Priprema je prazna, zelite li preuzeti prethodni tiraz? (D/N)","D")=="D"
      			lPrethodni:=.t.
      			aNiz := { { "Datum (prazno-posljednji postojeci)", "dPrethodni" ,,, } }
      			VarEdit(aNiz, 10,1,14,78,'DATUM PRETHODNOG TIRAZA KOJI SE PREUZIMA',"B1")
    		endif
		SELECT POMGN
		PushWA()
    		if EMPTY(dPrethodni)
      			SET FILTER TO DATDOK<dDatDok
    		else
      			SET FILTER TO DATDOK=dPrethodni
    		endif
    		SET ORDER TO TAG "1"

    		// 1) formirati prazne stavke prodavnica
    		SELECT PARTN
    		GO TOP
    		do while !EOF()
      			cLinija:=IzSifK( "PARTN" , "LINI" , id , .f. )
      			cMars:=IzSifK( "PARTN" , "MARS" , id , .f. )
      			if !EMPTY(cLinija)
        			if lPrethodni
          				SELECT POMGN
          				SEEK PARTN->id+LEFT(cIdRoba,gnDS)+CHR(255)
          				SKIP -1
          				if LEFT(idroba,gnDS)==LEFT(cIdRoba,gnDS) .and. PARTN->id==idpartner
            					Scatter("q")
             					qIdRoba:=cIdRoba
             					qDatDok:=dDatDok
             					qLinija:=cLinija
             					qMars:=cMars
             					qKolicina:=nKolicina
             					APPEND BLANK
            					Gather("q")
            					nUOtpKol+=otpremkol
          				else
            					APPEND BLANK
            					Scatter("q")
						qIdRoba:=cIdRoba
             					qDatDok:=dDatDok
             					qLinija:=cLinija
             					qMars:=cMars
             					qIdPartner:=PARTN->id
             					qNaziv:=PARTN->naz
             					qKolicina:=nKolicina
            					Gather("q")
          				endif
        			else
          				SELECT POMGN
          				APPEND BLANK
          				Scatter("q")
           				qIdRoba    := cIdRoba
           				qDatDok    := dDatDok
           				qLinija    := cLinija
           				qMars      := cMars
           				qIdPartner := PARTN->id
           				qNaziv     := PARTN->naz
           				qKolicina  := nKolicina
          				Gather("q")
        			endif
      			endif
      			SELECT PARTN
      			SKIP 1
    		enddo
    		SELECT POMGN
		PopWA()
  	else
    		// a ako ima, uzmi kolicinu ukupnog zaduzenja
    		nKolicina := kolicina
    		// i rasporedjenu kolicinu za otpremu
    		nUOtpKol:=0
    		do while !EOF() .and. IDROBA+DTOS(DATDOK)==cIdRoba+DTOS(dDatDok)
      			nUOtpKol += otpremkol
      			SKIP 1
    		enddo
    		// GO TOP
    		HSEEK cIdRoba+DTOS(dDatDok)
  	endif
BoxC()

// browse - priprema tiraza za izabrani dan i izdanje
// --------------------------------------------------

ImeKol:={ { "SIF.PROD.",      {|| IdPartner  }  } ,{ "NAZIV PROD.",    {|| NAZIV      }  } ,{ "Kol.za otpremu", {|| OTPREMKOL  }, "OTPREMKOL", {|| .t.}, {|| IF(wOtpremKol>=0,nUOtpKol-=OtpremKol,),IF(wOtpremKol>=0,nUOtpKol+=wOtpremKol,),ShOtpKol(),wOtpremKol>=0}, "V"  }, {"REMIT.", {|| vracenkol}} }

// primjer polja za dir.edit:
//      ImeKol[6] := { "ID PARTNER" , {|| idpartner}, "idpartner", ;
//                    {|| .t.}, {|| P_Firma(@widpartner)}, "V" }

//             { "Kol.za povrat",  {|| VRACENKOL  }, "VRACENKOL" }   }

Kol:={}
for i:=1 to LEN(ImeKol)
	AADD(Kol,i)
next

Box(,20,77)
	ShOtpKol()
    	DO WHILE .t.
     		// GO TOP
      		SELECT POMGN
      		HSEEK cIdRoba+DTOS(dDatDok)
      		@ m_x+18,m_y+2 SAY "Datum: "+DTOC(ddatdok)+SPACE(44)+"  Kolicina:"+STR(nKolicina,6)
      		@ m_x+18,m_y+18 SAY " Artikal: "+cIDROBA+"-"+PADR(ROBA->naz,22) COLOR INVERT
      		@ m_x+19,m_y+2 SAY "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ"
      		@ m_x+20,m_y+2 SAY " <c-N>  Nove Stavke      ³ <ENT> Ispravi stavku   ³ <c-T> Brisi Stavku      "

      		adImeKol:={}
      		private gTBDir:="D"
      		private bGoreRed:=NIL
      		private bDoleRed:=NIL
      		private bDodajRed:=NIL
      		private fTBNoviRed:=.f. //trenutno smo u novom redu ?
      		private TBCanClose:=.t. //da li se moze zavrsiti unos podataka ?
      		private TBAppend:="N"  //mogu dodavati slogove
      		private bZaglavlje:=NIL
      		private TBSkipBlock:={|nSkip| SkipDB(nSkip, @nTBLine)}
      		private nTBLine:=1  //tekuca linija-kod viselinijskog browsa
      		private nTBLastLine:=1  //broj linija kod viselinijskog browsa
      		private TBPomjerise:="" //ako je ">2" pomjeri se lijevo dva
                              // ovo se mo§e setovati u when/valid fjama
      		private TBScatter:="N"  // uzmi samo teku†e polje
      for i:=1 TO LEN(ImeKol); AADD(adImeKol,ImeKol[i]); next
      adKol:={}; for i:=1 to len(adImeKol); AADD(adKol,i); next

      // napraviti pomocnu bazu: PPOMGN
      // ------------------------------
      SELECT POMGN

      // ExportBaze(KUMPATH+"PPOMGN")
      cBaza:=KUMPATH+"PPOMGN"
      FERASE(cBaza+".DBF")
      FERASE(cBaza+".CDX")
      cBaza+=".DBF"
      COPY STRUCTURE EXTENDED TO (KUMPATH+"struct")
      CREATE (cBaza) FROM (KUMPATH+"struct") NEW
      MsgO("Ubacujem slogove u pripremu...")
      // APPEND FROM (ALIAS(nArr))
      SELECT POMGN
      DO WHILE !EOF() .and. IDROBA+DTOS(DATDOK)==cIdRoba+DTOS(dDatDok)
        Scatter()
        SELECT PPOMGN
        APPEND BLANK
        Gather()
        SELECT POMGN; SKIP 1
      ENDDO
      MsgC()
      SELECT PPOMGN
      USE
      SELECT POMGN


      USE (KUMPATH+"PPOMGN") NEW
       INDEX ON BRISANO TAG "BRISAN"
       INDEX ON LINIJA+MARS TAG "3"
        USE
      USE (KUMPATH+"PPOMGN") NEW
       SET ORDER TO TAG "3"
        GO TOP

      KEYBOARD CHR(K_ALT_E)

      ObjDbedit("PNal",20,77,{|| EdRasp()},"","Unos raspodjele zaduzenog artikla po prodavnicama (priprema tiraza):", , , , ,3)

      // azurirati POMGN iz pomocne baze PPOMGN
      // --------------------------------------
      SELECT POMGN
      MsgO("Brisem stare slogove...")

      // ZapFiltSort()
      // GO TOP
      HSEEK cIdRoba+DTOS(dDatDok)
      DO WHILE !EOF() .and. IDROBA+DTOS(DATDOK)==cIdRoba+DTOS(dDatDok)
        SKIP 1; nRec:=RECNO(); SKIP -1
        DELETE
        GO (nRec)
      ENDDO

      MsgC()

      APPEND FROM PPOMGN

      // nUOtpKol:=0
      // SELECT POMGN; GO TOP
      // DO WHILE !EOF()
      //   nUOtpKol+=otpremkol
      //   SKIP 1
      // ENDDO
      SELECT POMGN
      IF nUOtpKol>nKolicina
        MsgBeep("Greska: otpremljena kolicina je veca od zaduzene!")
        IF Pitanje(,"Da li je pogresna otpremljena kolicina (D-da,N-pogresno je zaduzenje)?","D")=="N"
          @ m_x+18,m_y+73 GET nKolicina VALID nKolicina>0 PICT "99999"
          READ
          IF LASTKEY()!=K_ESC
            // GO TOP
            HSEEK cIdRoba+DTOS(dDatDok)
            DO WHILE !EOF() .and. IDROBA+DTOS(DATDOK)==cIdRoba+DTOS(dDatDok)
              REPLACE kolicina WITH nKolicina
              SKIP 1
            ENDDO
          ENDIF
        ENDIF
        SELECT PPOMGN; USE
        LOOP
      ENDIF
      EXIT
    ENDDO
   BoxC()
CLOSERET
return
*}


// Vidljive slogove tekuce baze kopira u bazu cBaza. Prije toga izbrise
// bazu cBaza i pripadajuce indekse ukoliko postoje. cBaza ostaje zatvorena
// a tekuca baza i dalje ostaje ista
// ------------------------------------------------------------------------
/*! \fn ExportBaze(cBaza)
 *  \brief Vidljive slogove tekuce baze kopira u bazu cBaza
 *  \param cBaza   - naziv baze
 */
 
function ExportBaze(cBaza)
*{
LOCAL nArr:=SELECT()
  FERASE(cBaza+".DBF")
  FERASE(cBaza+".CDX")
  cBaza+=".DBF"
  COPY STRUCTURE EXTENDED TO (KUMPATH+"struct")
  CREATE (cBaza) FROM (KUMPATH+"struct") NEW
  MsgO("apendujem...")
  APPEND FROM (ALIAS(nArr))
  MsgC()
  USE
  SELECT (nArr)
RETURN
*}


/*! \fn GenDostav()
 *  \brief Generisanje dostavnica
 */
 
function GenDostav()
*{
dDatDok := DATE()
 qqArtik := ""
 qqLinija := ""

 O_PARAMS
 private cSection:="S",cHistory:=" "; aHistory:={}
 Params1()
 RPar("c1",@qqArtik)
 qqArtik  := PADR(qqArtik,180)
 qqLinija := PADR(qqLinija,30)

 Box("#USLOVI ZA GENERISANJE DOSTAVNICA",6,70)
  DO WHILE .t.
   @ m_x+2, m_y+2 SAY "Datum pripreme tiraza:" GET dDatDok
   @ m_x+3, m_y+2 SAY "Izdanja (prazno-sva) :" GET qqArtik PICT "@S30"
   @ m_x+4, m_y+2 SAY "Linije (prazno-sve)  :" GET qqLinija
   READ; ESC_BCR
   aUsl1 := Parsiraj( qqArtik , "IDROBA" )
   aUsl2 := Parsiraj( qqLinija , "LINIJA" )
   IF aUsl1<>NIL .and. aUsl2<>NIL; EXIT; ENDIF
  ENDDO
 BoxC()

 select params
 qqArtik  := TRIM(qqArtik)
 qqLinija := TRIM(qqLinija)
 WPar("c1",qqArtik)
 use

 aAS := TUN(qqArtik)
 altd()
 O_ROBA
 O_TARIFA
 O_PARTN
 O_PRIPR
 O_FAKT
 USE (KUMPATH+"POMGN") NEW
 cSort   := "LINIJA+MARS+AAS(IDROBA)"
 cFilter := "otpremkol>0 .and. DATDOK==dDatDok .and. " + aUsl1
 IF !EMPTY(qqLinija)
   cFilter += ( " .and. " + aUsl2 )
 ENDIF
 INDEX ON &cSort TO "TMPPGN" FOR &cFilter
 GO TOP
 
 if EMPTY(field->idroba) .and. EMPTY(field->datDok)
 	MsgBeep("Set Filter nije uspjesan !!!##Nesto od uslova nije korektno.")
 	return
 endif
 // napravimo otpremnice / dostavnice (10-13-XXXXX)
 lPrviPut:=.t.
 DO WHILE !EOF()
   if lPrviPut
     lPrviPut:=.f.
     SELECT FAKT
     SEEK gFirma+"13"+"È"
     SKIP -1
     IF idfirma+idtipdok<>gFirma+"13"
        cBrDok:=UBrojDok(1,gNumDio,"")
     ELSE
        cBrDok:=UBrojDok( val(left(brdok,gNumDio))+1, ;
                          gNumDio, ;
                          right(brdok,len(brdok)-gNumDio) ;
                        )
     ENDIF
     SELECT POMGN
   else
     cBrDok:=UBrojDok( val(left(cbrdok,gNumDio))+1, ;
                       gNumDio, ;
                       right(cbrdok,len(cbrdok)-gNumDio) ;
                     )
   endif

   cIdPartner:=IDPARTNER
   nRbr:=0
   SELECT POMGN

   DO WHILE !EOF() .and. IdPartner==cIDPARTNER

     IF nRBr>20
       EXIT
     ENDIF

     SELECT PRIPR; APPEND BLANK; Scatter()

     IF nRbr==0
       select PARTN; hseek cIdPartner
       _txt3b:=_txt3c:=""
       _txt3a:=cIdPartner+"."
       IzSifre()
       private _Txt1:=" "
       _txt:=Chr(16)+_txt1 +Chr(17)+;
            Chr(16)+""+chr(13)+chr(10)+;
            ""+;
            ""+Chr(17)+Chr(16)+_Txt3a+ Chr(17)+ Chr(16)+_Txt3b+Chr(17)+;
            Chr(16)+_Txt3c+Chr(17)
     ENDIF

     private _Txt1:=""
     NSRNPIdRoba(POMGN->idroba)

     if nRbr<>0 .and. roba->tip=="U"
        _txt1:=roba->naz
        _txt:=Chr(16)+_txt1 +Chr(17)
     endif

     _idfirma   := gFirma
     _zaokr     := 2
     _rbr       := str(++nRbr,3)
     _idtipdok  := "13"
     _brdok     := cBrDok
     _datdok    := POMGN->datdok
     _kolicina  := POMGN->otpremkol
     _idroba    := POMGN->idroba
     _idpartner := cIdPartner

     nCijena:=0
     setujcijenu()
     if ncijena<>0
       _cijena:=nCijena
     endif
     _rabat:=0
     _porez:=0
     _dindem:="KM"
     select pripr
     Gather()

     SELECT POMGN
     SKIP 1

   ENDDO

 ENDDO

CLOSERET
return
*}


/*! \fn EdRasp()
 *  \brief 
 */
 
function EdRasp()
*{

SELECT PPOMGN

if (Ch==K_CTRL_T .or. Ch==K_ENTER) .and. reccount2()==0
	return DE_CONT
endif


DO CASE

case Ch==K_ALT_E
IF gTBDir=="D"
	gTBDir:="N"
	NeTBDirektni()  
ELSE

gTBDir:="D"
select(F_PARTN)
if !used()
	O_PARTN
endif
select PPOMGN

DaTBDirektni() 
ENDIF

case Ch==K_CTRL_T // .and. gTBDir=="N"
if Pitanje(,"Zelite izbrisati tekucu stavku ?","D")=="D"
nUOtpKol -= otpremkol
ShOtpKol()
DELETE
return DE_REFRESH
endif
return DE_CONT

case Ch==K_ENTER
	
	Box("ist",6,70,.f.)
	Scatter()

	if EditRasp(.f.)==0
		BoxC()
		return DE_CONT
	else
		nUOtpKol -= otpremkol
		nUOtpKol += _otpremkol
		Gather()
		BoxC()
		ShOtpKol()
		return DE_REFRESH
	endif

case Ch==K_CTRL_A 
	
	PushWA()
	select PPOMGN
	go top
	Box("anal",6,70,.f.,"Ispravka svih stavki redom")
	DO WHILE !EOF()
	skip; nTR2:=RECNO(); skip-1
	Scatter()
	@ m_x+1,m_y+1 CLEAR to m_x+6,m_y+70
	if EditRasp(.f.)==0
	exit
	endif
	select PPOMGN
	nUOtpKol -= otpremkol
	nUOtpKol += _otpremkol
	Gather()
	GO (nTR2)
	ENDDO
	PopWA()
	BoxC()
	ShOtpKol()
	return DE_REFRESH

case Ch==K_CTRL_N 
	
	GO BOTTOM
	Box("knjn",6,70,.f.,"Unos nove stavke")
	do while .t.
	Scatter()
	@ m_x+1,m_y+1 CLEAR to m_x+6,m_y+70
	if EditRasp(.t.)==0
	exit
	endif
	select PPOMGN
	APPEND BLANK
	Gather()
	nUOtpKol += otpremkol
	enddo

	BoxC()
	ShOtpKol()
	return DE_REFRESH

case Ch=K_CTRL_F9
	
	if Pitanje(,"Zelite li izbrisati sve stavke ?!","N")=="D"
		ZapFiltSort()
		nUOtpKol := 0
		ShOtpKol()
	endif
	return DE_REFRESH

ENDCASE

RETURN DE_CONT
*}


/*! \fn EditRasp()
 *  \brief
 */
 
function EditRasp()
*{
PARAMETERS fNovi
  SET CURSOR ON

  _IdRoba   := cIdRoba
  _DatDok   := dDatDok
  _IdDobav  := cIdPartner
  _kolicina := nKolicina
  @ m_x+2, m_y+2  SAY "Sifra prodavnice:   "  GET _IdPartner VALID P_Firma(@_IdPartner) PICT "@!"
  @ m_x+3, m_y+2  SAY "Naziv prodavnice:   "  GET _NAZIV WHEN {|| _naziv:=PARTN->naz , .f. }
  @ m_x+4, m_y+2  SAY "Kolicina za otpremu:"  GET _OTPREMKOL PICT "999999"
  @ m_x+5, m_y+2  SAY "Kolicina za povrat: "  GET _VRACENKOL PICT "999999"

  READ; ESC_RETURN 0

RETURN 1
*}


/*! \fn UzmiPostojZad()
 *  \brief
 */
 
function UzmiPostojZad()
*{
private aPom:={}, h

SELECT POMGN; SET ORDER TO TAG "2"; GO TOP

DO WHILE !EOF()
 cPomKljuc:=DTOS(DATDOK)+IDDOBAV+LEFT(IDROBA,LEN(IDROBA)-1)+CHR(ASC(RIGHT(IDROBA,1))+1)
 AADD(aPom,DTOC(DATDOK)+"³"+IDDOBAV+"³"+IDROBA+"³"+STR(KOLICINA,5))
 SEEK cPomKljuc
ENDDO

IF !( LEN(aPom)>0 ); RETURN; ENDIF

h:=ARRAY(LEN(aPom)); AFILL(h,"")

Box(,LEN(aPom)+3,33)
@ m_x+1, m_y+2 SAY " DATUM  *DOBAV.* ARTIKAL  *KOL. "
@ m_x+2, m_y+2 SAY "--------------------------------"
nPom:=Menu2(m_x+2,m_y+1,aPom,1)
BoxC()

IF nPom>0
  cIdPartner := SUBSTR(aPom[nPom],10,6)
  nKolicina  := VAL(ALLTRIM(RIGHT(aPom[nPom],5)))
  _idroba    := SUBSTR(aPom[nPom],17,10)
  _datdok    := CTOD(LEFT(aPom[nPom],8))
  KEYBOARD CHR(K_PGDN)
ENDIF

RETURN
*}


/*! \fn ZapFiltSort()
 *  \brief
 */
 
function ZapFiltSort()
*{
LOCAL nRec:=0
  GO TOP
  DO WHILE !EOF()
    SKIP 1; nRec:=RECNO(); SKIP -1
    DELETE
    GO (nRec)
  ENDDO
RETURN
*}


/*! \fn RekPripTir()
 *  \brief Rekapitulacija pripreme tiraza
 */

function RekPripTir()
*{
dDatDok:=DATE()
 qqArtik:=""

 O_PARAMS
 private cSection:="S",cHistory:=" "; aHistory:={}
 Params1()
 RPar("c1",@qqArtik)
 qqArtik:=PADR(qqArtik,180)

 Box("#USLOVI ZA REKAPITULACIJU PRIPREME TIRAZA",5,70)
  DO WHILE .t.
   @ m_x+2, m_y+2 SAY "Datum pripreme tiraza:" GET dDatDok
   @ m_x+3, m_y+2 SAY "Izdanja(prazno-sva)  :" GET qqArtik PICT "@S30"
   READ; ESC_BCR
   aUsl1 := Parsiraj( qqArtik , "IDROBA" )
   IF aUsl1<>NIL; EXIT; ENDIF
  ENDDO
 BoxC()

 select params
 qqArtik:=TRIM(qqArtik)
 WPar("c1",qqArtik)
 use

 O_RJ
 O_ROBA
 O_TARIFA
 O_PARTN
 O_PRIPR
 O_FAKT
 cFilter := "DATDOK==dDatDok .and." + aUsl1
 cSort   := IzFMKINI("STAMPA","RekSort","IDROBA",KUMPATH)
 cNaziv  := IzFMKINI("STAMPA","RekNaziv","IDROBA+'-'+ROBA->naz",KUMPATH)
 USE (KUMPATH+"POMGN") NEW
 SET RELATION TO PADR(LEFT(idroba,gnDS),10) INTO ROBA, idpartner INTO PARTN
 INDEX ON &cSort TO "TMPPGN" FOR &cFilter

 START PRINT CRET

 ? "FAKT,",date(),", REKAPITULACIJA PRIPREME TIRAZA"
 ? ; IspisFirme(PRIPR->idfirma)
 ?
 ? "DATUM TIRAZA    :", dDatDok
 ? "USLOV ZA IZDANJA:", "'"+qqArtik+"'"
 ?
 ? PADC("NAZIV",50)+PADC("KOLICINA",20)
 ? REPL("-",70)

 GO TOP
 DO WHILE !EOF()
   cKljuc:=&cSort
   nKol:=0
   ? PADR(XTOC(&cNaziv),50,".")
   DO WHILE !EOF() .and. &cSort==cKljuc
     nKol += otpremkol
     SKIP 1
   ENDDO
   ?? STR(nKol,20,0)
 ENDDO
 ? REPL("-",70)

 FF
 END PRINT

CLOSERET
*}


/*! \fn ShOtpKol()
 *  \brief Prikazije otpremnu kolicinu
 */
 
function ShOtpKol()
*{
@ m_x, m_y+50  SAY "Kolicina za otpremu:"
@ m_x, col()+1 SAY TRANSFORM(nUOtpKol,"999999") COLOR "N/W"
RETURN
*}


/*! \fn StDnTiraz()
 *  \brief Stampa dnevnog tiraza
 */
 
function StDnTiraz()
*{
lOCAL aKol2:={}, aKol3:={}
 dDatDok:=DATE()
 // cSaRekap:="D"
 Box("#STAMPA DNEVNOG TIRAZA",5,70)
   @ m_x+2, m_y+2 SAY "Datum tiraza:" GET dDatDok
 //  @ m_x+3, m_y+2 SAY "Rekapitulacija finansijski? (D/N)" GET cSaRekap VALID cSaRekap$"DN" PICT "@!"
   READ; ESC_BCR
 BoxC()
 O_RJ
 O_ROBA
 O_TARIFA
 O_PARTN
 O_PRIPR
 O_FAKT
 cFilter := "DATDOK==dDatDok"
 cSort   := "linija+mars+idpartner+idroba"
 USE (KUMPATH+"POMGN") NEW
 nSlog:=0; nUkupno:=RECCOUNT2()
 SET RELATION TO PADR(LEFT(idroba,gnDS),10) INTO ROBA, idpartner INTO PARTN
 aIzd:={}
 Box("#IZDVAJANJE IZ BAZE SVIH TIRAZA U TOKU...",2,60)
  INDEX ON &cSort TO "TMPPGN" FOR &cFilter EVAL(DnTirTR()) EVERY 1
 BoxC()
 ASORT( aIzd ,,, {|x,y| x[1]<y[1]} )

 START PRINT CRET

 ? "FAKT,",date(),", DNEVNI TIRAZ"
 ? ; IspisFirme(PRIPR->idfirma)
 ?
 ? "DATUM TIRAZA    :", dDatDok
 ?

  gnLMarg:=0; gOstr:="D"; gTabela:=1
  cPartner:=""
  nUkZad:=0

  aKol:={}; nKol:=0
  aKolIzd:={}
  aCijIzd:={}
  aIznIzd:={}

  nSZ:=5
  AADD(aKol, { "Prodavnica"  , {|| cPartner  }, .f., "C",   20,   0, 1, ++nKol } )
  FOR i:=1 TO LEN(aIzd)
    IF i==31
      nKol:=0
      AADD( aKol2 , { "Prodavnica"  , {|| cPartner  }, .f., "C",   20,   0, 1, ++nKol } )
    ELSEIF i==61
      nKol:=0
      AADD( aKol3 , { "Prodavnica"  , {|| cPartner  }, .f., "C",   20,   0, 1, ++nKol } )
    ENDIF
    nRNA:=INT(LEN(aIzd[i,2])/nSZ)+1
    FOR j:=1 TO nRNA
      IF j==1
        cPom:="n7Kol"+ALLTRIM(STR(i))
        PRIVATE &cPom:=0
        AADD(IF(i>60,aKol3,IF(i>30,aKol2,aKol)),;
             { SUBSTR(aIzd[i,2],nSZ*(j-1)+1,nSZ)  , {|| &cPom.  }, .t., "N",   nSZ,   0, j, ++nKol } )
      ELSE
        AADD(IF(i>60,aKol3,IF(i>30,aKol2,aKol)),;
             { SUBSTR(aIzd[i,2],nSZ*(j-1)+1,nSZ)  , {|| "#"     }, .f., "C",   nSZ,   0, j,   nKol } )
      ENDIF
    NEXT
    AADD(IF(i>60,aKol3,IF(i>30,aKol2,aKol)),;
     { REPL("-",nSZ)       , {|| "#"     }, .f., "C",   nSZ,   0,   j,   nKol } )
    AADD(IF(i>60,aKol3,IF(i>30,aKol2,aKol)),;
     { "Cij."              , {|| "#"     }, .f., "C",   nSZ,   0, j+1,   nKol } )
    AADD(IF(i>60,aKol3,IF(i>30,aKol2,aKol)),;
     { STR(aIzd[i,3],nSZ,2), {|| "#"     }, .f., "C",   nSZ,   0, j+2,   nKol } )
    AADD( aKolIzd , 0 )
    AADD( aCijIzd , aIzd[i,3] )
    AADD( aIznIzd , 0 )
  NEXT

  IF i-1>60
    AADD(aKol3, { "UKUPNO"   , {|| nUkZad  }, .t., "N",   9,   2, 1, ++nKol } )
    AADD(aKol3, { "ZADUZENJE", {|| "#"     }, .f., "C",   9,   0, 2,   nKol } )
  ELSEIF i-1>30
    AADD(aKol2, { "UKUPNO"   , {|| nUkZad  }, .t., "N",   9,   2, 1, ++nKol } )
    AADD(aKol2, { "ZADUZENJE", {|| "#"     }, .f., "C",   9,   0, 2,   nKol } )
  ELSE
    AADD(aKol, { "UKUPNO"   , {|| nUkZad  }, .t., "N",   9,   2, 1, ++nKol } )
    AADD(aKol, { "ZADUZENJE", {|| "#"     }, .f., "C",   9,   0, 2,   nKol } )
  ENDIF

  gaSubTotal:={}

  StampaTabele(aKol,,,gTabela,,;
               ,,;
               {|| FDnevTir()},IF(gOstr=="D",,-1),,,,,,.f.)
  FF
  IF LEN(aKol2)>0
    GO TOP
    StampaTabele(aKol2,,,gTabela,,;
                 ,,;
                 {|| FDnevTir()},IF(gOstr=="D",,-1),,,,,,.f.)
    FF
  ENDIF
  IF LEN(aKol3)>0
    GO TOP
    StampaTabele(aKol3,,,gTabela,,;
                 ,,;
                 {|| FDnevTir()},IF(gOstr=="D",,-1),,,,,,.f.)
    FF
  ENDIF

 END PRINT
CLOSERET
return
*}


/*! \fn FDnevTir()
 *  \brief
 */
 
function FDnevTir()
*{
cPartner:=PARTN->naz
  cIdPar:=idpartner
  nUkZad:=0
  FOR i:=1 TO LEN(aIzd)
    cPom:="n7Kol"+ALLTRIM(STR(i))
    &cPom = 0
  NEXT
  DO WHILE !EOF() .and. idpartner==cIdPar
    cIdRoba:=idroba
    nPom:=ASCAN(aIzd,{|x| x[1]==IDROBA})
    cPom:="n7Kol"+ALLTRIM(STR(nPom))
    DO WHILE !EOF() .and. idpartner==cIdPar .and. idroba==cIdRoba
      &cPom += otpremkol
      SKIP 1
    ENDDO
    aKolIzd[nPom] += &cPom
    nUkZad += ( &cPom * aCijIzd[nPom] )
  ENDDO
    gaSubTotal:={}
  SKIP -1
RETURN .t.
*}


/*! \fn DnTirTR()
 *  \brief Dnevni tiraz
 */
 
function DnTirTR()
*{
nSlog++
 @ m_x+1, m_y+2 SAY PADC(ALLTRIM(STR(nSlog))+"/"+ALLTRIM(STR(nUkupno)),20)
 IF DATDOK==dDatDok
   IF LEN(aIzd)<=0
     AADD(aIzd,{IDROBA,TRIM(ROBA->naz),ROBA->mpc})
   ELSE
     nPom:=ASCAN(aIzd,{|x| x[1]==IDROBA})
     IF nPom<=0
       AADD(aIzd,{IDROBA,TRIM(ROBA->naz),ROBA->mpc})
     ENDIF
   ENDIF
 ENDIF
 @ m_x+2, m_y+2 SAY "Obuhvaceno: "+STR(cmxKeysIncluded())
RETURN (NIL)
*}


/*! \fn TUN(cUslov,cSep)
 *  \brief
 *  \param cUslov
 *  \param cSep
 */
 
function TUN(cUslov,cSep)
*{
LOCAL aVrati:={}, i:=0, nTok:=0, cTok:=""
  IF cSep==NIL; cSep:=";"; ENDIF
  cUslov:=RTRIM(cUslov)
  IF !EMPTY(cUslov)
    nTok := NUMTOKEN( cUslov , cSep , 1 )
    FOR i:= 1 TO nTok
      cTok := TOKEN( cUslov , cSep , i , 1 )
      AADD(aVrati,cTok)
    NEXT
  ENDIF
RETURN aVrati
*}


/*! \fn AAS(cIdRoba)
 *  \brief
 *  \param cIdRoba
 */
 
function AAS(cIdRoba)
*{
LOCAL cVrati:="   "
  nPom := ASCAN(aAS,{|x| cIdRoba=TRIM(x)})
  IF nPom>0
    cVrati:=PADL(nPom,3)
  ELSE
    cVrati:="999"
  ENDIF
RETURN cVrati
*}

function InsertIntoPOMGN(dDatDok, cIdRoba, cIdPartner, nKolicina, nDana)
*{
local nArr
nArr:=SELECT()
// ubaci u pomgn za trazenu robu  -kolicinu
O_POMGN
select pomgn
set order to tag "1"
hseek cIdPartner+cIdRoba+DToS(dDatDok+nDana)

if Found()
	replace field->vracenkol with nKolicina
endif

select (nArr)
return
*}

