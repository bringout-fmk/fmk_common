#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/rpt/1g/izvj.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.13 $
 * $Log: izvj.prg,v $
 * Revision 1.13  2003/09/12 09:35:12  ernad
 * omoguceno biranje i VPC po RJ
 *
 * Revision 1.12  2003/09/12 09:01:57  ernad
 * no message
 *
 * Revision 1.11  2003/05/20 07:29:01  mirsad
 * Formatirao duzinu naziva robe za izvjestaje na 40 znakova.
 *
 * Revision 1.10  2003/01/19 23:44:17  ernad
 * test network speed (sa), korekcija bl.lnk
 *
 * Revision 1.9  2003/01/11 14:34:41  mirsad
 * ukinuo f-ju SezRad()
 *
 * Revision 1.8  2002/09/12 12:33:46  mirsad
 * dokumentovanje INI parametara
 *
 * Revision 1.7  2002/07/05 14:36:40  sasa
 * no message
 *
 * Revision 1.6  2002/07/05 08:23:07  ernad
 *
 *
 * parametar ExePath/Fakt_specif/Fakt_Kalk -> KumPath/Fakt/FaktKalk
 *
 * Revision 1.5  2002/07/04 08:34:19  mirsad
 * dokumentovanje ini parametara
 *
 * Revision 1.4  2002/07/03 12:40:53  sasa
 * izbacena f-ja izvj()
 *
 * Revision 1.3  2002/06/28 20:19:36  ernad
 *
 *
 * debug GenDokInv
 *
 * Revision 1.2  2002/06/19 08:47:21  sasa
 * no message
 *
 * Revision 1.1.1.1  2002/06/17 18:30:18  ernad
 * no message
 *
 *
 */

/*! \file fmk/fakt/rpt/1g/izvj.prg
 *  \brief Izvjestajni dio
 */

/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_Konsignacija
  * \brief Koriste li se specificnosti za konsignaciju?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_KumPath_FAKT_Konsignacija;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_Trgomarket
  * \brief Koriste li se specificnosti radjene za Trgomarket?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_KumPath_FAKT_Trgomarket;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_SifRoba_ID_J
  * \brief Koriste li se sifre robe ID_J?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_ExePath_SifRoba_ID_J;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_FaktKalk
  * \brief Koliko konta se moze obuhvatiti uslovom za konto u KALK u izvjestaju "poredi FAKT i KALK"
  * \param 11 - zadaje se samo jedan konto u KALK, default vrijednost
  * \param 1N - moze se uslovom obuhvatiti vise konta u KALK
  * \sa Fakt_Kalk
  */
*string FmkIni_KumPath_FAKT_FaktKalk;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_ZaIzvjestajeDefaultJeMPC
  * \brief Da li je default cijena koja se prikazuje u izvjestajima MPC?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_KumPath_FAKT_ZaIzvjestajeDefaultJeMPC;


/*! \ingroup ini
  * \var *string FmkIni_SifPath_FAKT_Opcine
  * \brief Koristi li se sifrarnik opcina i polje za sifru opcine u sifrarniku partnera
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_SifPath_FAKT_Opcine;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_NOVINE_NazivOpstineXY
  * \brief Setuje naziv opstine za opstinu pod sifrom XY. Ove opstine nemaju veze sa klasicnim sifrarnikom opstina
  * \param - -nije setovano, default vrijednost
  */
*string FmkIni_KumPath_NOVINE_NazivOpstineXY;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_NOVINE_USifriRobe_PocPozSifIzdavaca
  * \brief Od koje pozicije u sifri robe pocinje sifra izdavaca?
  * \param 1 - od prve pozicije, default vrijednost
  */
*string FmkIni_KumPath_NOVINE_USifriRobe_PocPozSifIzdavaca;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_NOVINE_USifriRobe_DuzinaSifIzdavaca
  * \brief Duzina sifre izdavaca
  * \param 3 - default vrijednost
  */
*string FmkIni_KumPath_NOVINE_USifriRobe_DuzinaSifIzdavaca;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_NOVINE_NazivIzdavacaXY
  * \brief Setuje naziv izdavaca za sifru izdavaca XY
  * \param - -nije setovano, default vrijednost
  */
*string FmkIni_KumPath_NOVINE_NazivIzdavacaXY;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_POREZI_PPUgostKaoPPU
  * \brief Odredjuje nacin obracuna poreza u maloprodaji (u ugostiteljstvu)
  * \param M - racuna PRUC iskljucivo koristeci propisani donji limit RUC-a, default vrijednost
  * \param R - racuna PRUC na osnovu stvarne RUC ili na osnovu pr.d.lim.RUC-a ako je stvarni RUC manji od propisanog limita
  * \param J - metoda koju koriste u Jerry-ju
  * \param D - racuna PPU a ne PRUC (stari sistem), s tim da se PP racuna na istu osnovicu kao i PPU
  * \param N - racuna PPU a ne PRUC (stari sistem), s tim da se PP racuna na istu osnovicu kao i PPP
  */
*string FmkIni_ExePath_POREZI_PPUgostKaoPPU;


/*! \ingroup ini
  * \var *string FmkIni_SifPath_FAKT_OstraniciKarticu
  * \brief Da li se ostranicava kartica artikla?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_SifPath_FAKT_OstraniciKarticu;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_FAKT_Sintet
  * \brief Da li se koriste sinteticke (skracene) sifre robe?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_ExePath_FAKT_Sintet;



/*! \fn RedniBroj(nRbr)
 *  \brief Dodavanje rednih brojeva na izvjestaju
 *  \param nRbr
 */
 
function RedniBroj(nRbr)
*{
local nOst
if nRbr>999
    nOst:=nRbr%100
    return Chr(int(nRbr/100)-10+65)+padl(alltrim(str(nOst,2)),2,"0")
else
    return str(nRbr,3)
endif
*}

/*! \fn UzmiMpcSif()
 *  \brief Uzmi maloprodajnu cijenu iz sifrarnika
 */
 
function UzmiMpcSif()
*{
local nCV:=0

if RJ->tip=="N1"
	nCV := roba->nc
elseif RJ->tip=="M1"
	nCV := roba->mpc
elseif RJ->tip=="M2"
	nCV := roba->mpc2
elseif RJ->tip=="M3"
    	nCV := roba->mpc3
elseif RJ->tip=="M4"
    	nCV := roba->mpc4
elseif RJ->tip=="M5"
    	nCV := roba->mpc5
elseif RJ->tip=="M6"
    	nCV := roba->mpc6
else
	if IzFMKINI("FAKT","ZaIzvjestajeDefaultJeMPC","N",KUMPATH)=="D"
      		nCV := roba->mpc
    	else
      		nCV := roba->vpc
    	endif
endif
return nCV
*}


/*! \fn UzmiVPCSif()
 *  \brief Uzmi veleprodajnu cijenu iz sifrarnika
 */
 
function UzmiVPCSif()
*{
local nCV:=0

if rj->tip=="V1"
    	nCV := roba->vpc
elseif rj->tip=="V2"
    	nCV := roba->vpc2
else
	if IzFMKINI("FAKT","ZaIzvjestajeDefaultJeMPC","N",KUMPATH)=="D"
      		nCV := roba->mpc
    	else
      		nCV := roba->vpc
    	endif
endif
return nCV
*}



/*! \fn Pregled1() 
 *  \brief Pregled isporucenog uglja po kupcima i asortimanu
 *  \brief Izvjestaj je specificno radjen za Rudnik
 */
 
function Pregled1()
*{
O_PARTN
O_FAKT

qqRoba:=space(60)
qqRoba1:=space(60); cRoba1:=SPACE(10)
qqRoba2:=space(60); cRoba2:=SPACE(10)
qqRoba3:=space(60); cRoba3:=SPACE(10)
qqRoba4:=space(60); cRoba4:=SPACE(10)
qqRoba5:=space(60); cRoba5:=SPACE(10)
qqRoba6:=space(60); cRoba6:=SPACE(10)
dDatOd:=ctod(""); dDatDo:=date(); gOstr:="D"
cProsCij:="N"

O_PARAMS
private cSection:="5",cHistory:=" "; aHistory:={}
Params1()
RPar("d1",@dDatOd); RPar("d2",@dDatDo)
RPar("O1",@cRoba1); RPar("O2",@cRoba2); RPar("O3",@cRoba3)
RPar("O4",@cRoba4); RPar("O5",@cRoba5); RPar("O6",@cRoba6)
RPar("F0",@qqRoba)
RPar("F1",@qqRoba1); RPar("F2",@qqRoba2); RPar("F3",@qqRoba3)
RPar("F4",@qqRoba4); RPar("F5",@qqRoba5); RPar("F6",@qqRoba6)
RPar("F9",@cProsCij)

qqRoba:=PADR(qqRoba,60)
qqRoba1:=PADR(qqRoba1,60); qqRoba2:=PADR(qqRoba2,60); qqRoba3:=PADR(qqRoba3,60)
qqRoba4:=PADR(qqRoba4,60); qqRoba5:=PADR(qqRoba5,60); qqRoba6:=PADR(qqRoba6,60)


Box(,12,70)
do while .t.

 @ m_X+1,m_Y+15 SAY "NAZIV               USLOV"

 @ m_X+2,m_Y+ 2 SAY "Asortiman 1" GET cRoba1
 @ m_X+2,m_Y+26 GET qqRoba1    pict "@!S30"
 @ m_X+3,m_Y+ 2 SAY "Asortiman 2" GET cRoba2
 @ m_X+3,m_Y+26 GET qqRoba2    pict "@!S30"
 @ m_X+4,m_Y+ 2 SAY "Asortiman 3" GET cRoba3
 @ m_X+4,m_Y+26 GET qqRoba3    pict "@!S30"
 @ m_X+5,m_Y+ 2 SAY "Asortiman 4" GET cRoba4
 @ m_X+5,m_Y+26 GET qqRoba4    pict "@!S30"
 @ m_X+6,m_Y+ 2 SAY "Asortiman 5" GET cRoba5
 @ m_X+6,m_Y+26 GET qqRoba5    pict "@!S30"
 @ m_X+7,m_Y+ 2 SAY "Asortiman 6" GET cRoba6
 @ m_X+7,m_Y+26 GET qqRoba6    pict "@!S30"

 @ m_X+ 8,m_Y+2 SAY "USLOV ZA POGON (prazno-svi)" GET qqRoba pict "@!S30"

 @ m_X+ 9,m_Y+2 SAY "Za period od" GET dDatOD
 @ m_X+ 9,col()+2 SAY "do" GET dDatDo

 @ m_X+10,m_y+2 SAY "Ukljuceno ostranicavanje ? (D/N)" GET gOstr VALID gOstr$"DN" PICT "@!"
 @ m_X+11,m_y+2 SAY "Prikazati prosjecne cijene ? (D/N)" GET cProsCij VALID cProsCij$"DN" PICT "@!"

 read; ESC_BCR
 aUsl0:=Parsiraj(qqRoba,"IDROBA")
 aUsl1:=Parsiraj(qqRoba1,"IDROBA")
 aUsl2:=Parsiraj(qqRoba2,"IDROBA")
 aUsl3:=Parsiraj(qqRoba3,"IDROBA")
 aUsl4:=Parsiraj(qqRoba4,"IDROBA")
 aUsl5:=Parsiraj(qqRoba5,"IDROBA")
 aUsl6:=Parsiraj(qqRoba6,"IDROBA")
 if aUsl0<>NIL .and. aUsl1<>NIL .and. aUsl2<>NIL .and. aUsl3<>NIL .and. aUsl4<>NIL .and. aUsl5<>NIL .and. aUsl6<>NIL
    exit
 endif
enddo
BoxC()

Params2()
qqRoba:=trim(qqRoba)
qqRoba1:=trim(qqRoba1); qqRoba2:=trim(qqRoba2); qqRoba3:=trim(qqRoba3)
qqRoba4:=trim(qqRoba4); qqRoba5:=trim(qqRoba5); qqRoba6:=trim(qqRoba6)

WPar("d1",dDatOd) ; WPar("d2",dDatDo)
WPar("O1",cRoba1) ; WPar("O2",cRoba2) ; WPar("O3",cRoba3)
WPar("O4",cRoba4) ; WPar("O5",cRoba5) ; WPar("O6",cRoba6)
WPar("F0",qqRoba)
WPar("F1",qqRoba1); WPar("F2",qqRoba2); WPar("F3",qqRoba3)
WPar("F4",qqRoba4); WPar("F5",qqRoba5); WPar("F6",qqRoba6)
WPar("F9",cProsCij)

select params; use

SELECT FAKT

cTMPFAKT:=""
Box(,2,30)
  nSlog:=0; nUkupno:=RECCOUNT2()
  cSort1 := "IDPARTNER"
  cFilt  := "DATDOK>=dDatOd .and. DATDOK<=dDatDo .and. "+aUsl0
  INDEX ON &cSort1 TO (cTMPFAKT:=TMPFAKT()) FOR &cFilt EVAL(TekRec()) EVERY 1
BoxC()

GO TOP
if eof(); Msg("Ne postoje trazeni podaci...",6); closeret; endif

START PRINT CRET

PRIVATE cIdPartner:="", cNPartnera:="", nUkRoba:=0, nUkIznos:=0
PRIVATE nRoba1:=0, nRoba2:=0, nRoba3:=0, nRoba4:=0, nRoba5:=0, nRoba6:=0
PRIVATE nPCR1:=nPCR2:=nPCR3:=nPCR4:=nPCR5:=nPCR6:=nPCRU:=0
PRIVATE nIzR1:=nIzR2:=nIzR3:=nIzR4:=nIzR5:=nIzR6:=0

IF cProsCij=="D"

aKol:={ { "SIFRA"       , {|| cIdPartner             }, .f., "C", 6, 0, 1, 1},;
        { "KUPAC"       , {|| cNPartnera             }, .f., "C",50, 0, 1, 2},;
        { cRoba1        , {|| nRoba1                 }, .t., "N",12, 2, 1, 3},;
        { cRoba2        , {|| nRoba2                 }, .t., "N",12, 2, 1, 4},;
        { cRoba3        , {|| nRoba3                 }, .t., "N",12, 2, 1, 5},;
        { cRoba4        , {|| nRoba4                 }, .t., "N",12, 2, 1, 6},;
        { cRoba5        , {|| nRoba5                 }, .t., "N",12, 2, 1, 7},;
        { cRoba6        , {|| nRoba6                 }, .t., "N",12, 2, 1, 8},;
        { "UKUPNO KOL." , {|| nUkRoba                }, .t., "N",12, 2, 1, 9},;
        { "UKUPNO IZNOS", {|| ROUND(nUkIznos,gFZaok) }, .t., "N",12, 2, 3, 9} }

  AADD(aKol, { "PROSJ.CIJ.", {|| nPCR1}, .f., "N",12,2,2,3 } )
  AADD(aKol, { "IZNOS"     , {|| nIzR1}, .t., "N",12,2,3,3 } )
  AADD(aKol, { "PROSJ.CIJ.", {|| nPCR2}, .f., "N",12,2,2,4 } )
  AADD(aKol, { "IZNOS"     , {|| nIzR2}, .t., "N",12,2,3,4 } )
  AADD(aKol, { "PROSJ.CIJ.", {|| nPCR3}, .f., "N",12,2,2,5 } )
  AADD(aKol, { "IZNOS"     , {|| nIzR3}, .t., "N",12,2,3,5 } )
  AADD(aKol, { "PROSJ.CIJ.", {|| nPCR4}, .f., "N",12,2,2,6 } )
  AADD(aKol, { "IZNOS"     , {|| nIzR4}, .t., "N",12,2,3,6 } )
  AADD(aKol, { "PROSJ.CIJ.", {|| nPCR5}, .f., "N",12,2,2,7 } )
  AADD(aKol, { "IZNOS"     , {|| nIzR5}, .t., "N",12,2,3,7 } )
  AADD(aKol, { "PROSJ.CIJ.", {|| nPCR6}, .f., "N",12,2,2,8 } )
  AADD(aKol, { "IZNOS"     , {|| nIzR6}, .t., "N",12,2,3,8 } )
  AADD(aKol, { "PROSJ.CIJ.", {|| nPCRU}, .f., "N",12,2,2,9 } )

ELSE

aKol:={ { "SIFRA"       , {|| cIdPartner             }, .f., "C", 6, 0, 1, 1},;
        { "KUPAC"       , {|| cNPartnera             }, .f., "C",50, 0, 1, 2},;
        { cRoba1        , {|| nRoba1                 }, .t., "N",10, 2, 1, 3},;
        { cRoba2        , {|| nRoba2                 }, .t., "N",10, 2, 1, 4},;
        { cRoba3        , {|| nRoba3                 }, .t., "N",10, 2, 1, 5},;
        { cRoba4        , {|| nRoba4                 }, .t., "N",10, 2, 1, 6},;
        { cRoba5        , {|| nRoba5                 }, .t., "N",10, 2, 1, 7},;
        { cRoba6        , {|| nRoba6                 }, .t., "N",10, 2, 1, 8},;
        { "UKUPNO KOL." , {|| nUkRoba                }, .t., "N",11, 2, 1, 9},;
        { "UKUPNO IZNOS", {|| ROUND(nUkIznos,gFZaok) }, .t., "N",12, 2, 1,10} }

ENDIF


?? space(gnLMarg); ?? "FAKT: Izvjestaj na dan",date()
? space(gnLMarg); IspisFirme("")
? space(gnLMarg); ?? "POGONI: " + IF( EMPTY(qqRoba) , "SVI" , qqRoba )

StampaTabele(aKol,{|| FSvaki1()},,gTabela,,;
     ,"Isporuceni asortiman - pregled po kupcima za period od "+DTOC(ddatod)+" do "+DTOC(ddatdo),;
                             {|| FFor1()},IF(gOstr=="D",,-1),,cProsCij=="D",,,)

FF
END PRINT
CLOSE ALL; MyFERASE(cTMPFAKT)

CLOSERET
return
*}


/*! \fn FFor1()
 *  \brief 
 */
 
function FFor1()
*{
cIdPartner:=idpartner
 nRoba1:=nRoba2:=nRoba3:=nRoba4:=nRoba5:=nRoba6:=nUkRoba:=nUkIznos:=0
 nIzR1:=nIzR2:=nIzR3:=nIzR4:=nIzR5:=nIzR6:=0
 cNPartnera:=Ocitaj(F_PARTN,idpartner,"TRIM(naz)+' '+TRIM(naz2)")

 DO WHILE !EOF() .and. idpartner==cIdPartner

   IF &aUsl1; nRoba1+=kolicina; nIzR1+=ROUND( kolicina*cijena*PrerCij()*(1-rabat/100)*(1+porez/100) , FIELD->zaokr ); ENDIF
   IF &aUsl2; nRoba2+=kolicina; nIzR2+=ROUND( kolicina*cijena*PrerCij()*(1-rabat/100)*(1+porez/100) , FIELD->zaokr ); ENDIF
   IF &aUsl3; nRoba3+=kolicina; nIzR3+=ROUND( kolicina*cijena*PrerCij()*(1-rabat/100)*(1+porez/100) , FIELD->zaokr ); ENDIF
   IF &aUsl4; nRoba4+=kolicina; nIzR4+=ROUND( kolicina*cijena*PrerCij()*(1-rabat/100)*(1+porez/100) , FIELD->zaokr ); ENDIF
   IF &aUsl5; nRoba5+=kolicina; nIzR5+=ROUND( kolicina*cijena*PrerCij()*(1-rabat/100)*(1+porez/100) , FIELD->zaokr ); ENDIF
   IF &aUsl6; nRoba6+=kolicina; nIzR6+=ROUND( kolicina*cijena*PrerCij()*(1-rabat/100)*(1+porez/100) , FIELD->zaokr ); ENDIF
   IF &(aUsl1+".or."+aUsl2+".or."+aUsl3+".or."+;
      aUsl4+".or."+aUsl5+".or."+aUsl6)
     nUkIznos += ROUND( kolicina*cijena*PrerCij()*(1-rabat/100)*(1+porez/100) , FIELD->zaokr )
   ENDIF

   SKIP 1

 ENDDO

 nPCR1 := ROUND( IF( nRoba1<>0 , nIzR1/nRoba1 , 0 ) , 2 )
 nPCR2 := ROUND( IF( nRoba2<>0 , nIzR2/nRoba2 , 0 ) , 2 )
 nPCR3 := ROUND( IF( nRoba3<>0 , nIzR3/nRoba3 , 0 ) , 2 )
 nPCR4 := ROUND( IF( nRoba4<>0 , nIzR4/nRoba4 , 0 ) , 2 )
 nPCR5 := ROUND( IF( nRoba5<>0 , nIzR5/nRoba5 , 0 ) , 2 )
 nPCR6 := ROUND( IF( nRoba6<>0 , nIzR6/nRoba6 , 0 ) , 2 )

 nUkRoba := nRoba1+nRoba2+nRoba3+nRoba4+nRoba5+nRoba6
 nPCRU := ROUND( IF( nUkRoba<>0 , nUkIznos/nUkRoba , 0 ) , 2 )

 SKIP -1
return .t.
*}


/*! \fn FSvaki1()
 *  \brief 
 */
 
function FSvaki1()
*{
RETURN
*}



/*! \fn TekRac()
 *  \brief
 */
 
function TekRec()
*{
nSlog++
 @ m_x+1, m_y+2 SAY PADC(ALLTRIM(STR(nSlog))+"/"+ALLTRIM(STR(nUkupno)),20)
 @ m_x+2, m_y+2 SAY "Obuhvaceno: "+STR(cmxKeysIncluded())
return (nil)
*}




/*! \fn Pregled2()
 *  \brief Pregled faktura asortimana za kupca
 *  \brief Izvjestaj specificno radjen za Rudnik
 */
 
function Pregled2()
*{
O_PARTN
O_FAKT

cVarijanta:="1"               // 1 - sa porezom i rabatom
                              // 2 - bez     - ll -
cIdFirma:=space(6)
qqRoba1:=space(60); cRoba1:=SPACE(10)
qqRoba2:=space(60); cRoba2:=SPACE(10)
qqRoba3:=space(60); cRoba3:=SPACE(10)
qqRoba4:=space(60); cRoba4:=SPACE(10)
qqRoba5:=space(60); cRoba5:=SPACE(10)
qqRoba6:=space(60); cRoba6:=SPACE(10)
dDatOd:=ctod(""); dDatDo:=date(); gOstr:="D"

O_PARAMS
private cSection:="5",cHistory:=" "; aHistory:={}
Params1()
RPar("d1",@dDatOd); RPar("d2",@dDatDo)
RPar("O1",@cRoba1); RPar("O2",@cRoba2); RPar("O3",@cRoba3)
RPar("O4",@cRoba4); RPar("O5",@cRoba5); RPar("O6",@cRoba6)
RPar("F7",@cIdFirma)
RPar("F1",@qqRoba1); RPar("F2",@qqRoba2); RPar("F3",@qqRoba3)
RPar("F4",@qqRoba4); RPar("F5",@qqRoba5); RPar("F6",@qqRoba6)

cIdFirma:=PADR(cIdFirma,6)
qqRoba1:=PADR(qqRoba1,60); qqRoba2:=PADR(qqRoba2,60); qqRoba3:=PADR(qqRoba3,60)
qqRoba4:=PADR(qqRoba4,60); qqRoba5:=PADR(qqRoba5,60); qqRoba6:=PADR(qqRoba6,60)


Box(,12,70)
do while .t.

 @ m_X+1,m_Y+15 SAY "NAZIV               USLOV"

 @ m_X+2,m_Y+ 2 SAY "Asortiman 1" GET cRoba1
 @ m_X+2,m_Y+26 GET qqRoba1    pict "@!S30"
 @ m_X+3,m_Y+ 2 SAY "Asortiman 2" GET cRoba2
 @ m_X+3,m_Y+26 GET qqRoba2    pict "@!S30"
 @ m_X+4,m_Y+ 2 SAY "Asortiman 3" GET cRoba3
 @ m_X+4,m_Y+26 GET qqRoba3    pict "@!S30"
 @ m_X+5,m_Y+ 2 SAY "Asortiman 4" GET cRoba4
 @ m_X+5,m_Y+26 GET qqRoba4    pict "@!S30"
 @ m_X+6,m_Y+ 2 SAY "Asortiman 5" GET cRoba5
 @ m_X+6,m_Y+26 GET qqRoba5    pict "@!S30"
 @ m_X+7,m_Y+ 2 SAY "Asortiman 6" GET cRoba6
 @ m_X+7,m_Y+26 GET qqRoba6    pict "@!S30"

 @ m_X+ 8,m_Y+2 SAY "KUPAC (prazno-svi)" GET cIdFirma VALID P_Firma(@cIdFirma) pict "@!S30"

 @ m_X+ 9,m_Y+2 SAY "Za period od" GET dDatOD
 @ m_X+ 9,col()+2 SAY "do" GET dDatDo

 @ m_X+10,m_y+2 SAY "Varijanta ( 1-sa por.i rab. , 2-bez por.i rab. ) ? " GET cVarijanta VALID cVarijanta$"12" PICT "9"
 @ m_X+11,m_y+2 SAY "Ukljuceno ostranicavanje ? (D/N)" GET gOstr VALID gOstr$"DN" PICT "@!"

 read; ESC_BCR
 aUsl1:=Parsiraj(qqRoba1,"IDROBA")
 aUsl2:=Parsiraj(qqRoba2,"IDROBA")
 aUsl3:=Parsiraj(qqRoba3,"IDROBA")
 aUsl4:=Parsiraj(qqRoba4,"IDROBA")
 aUsl5:=Parsiraj(qqRoba5,"IDROBA")
 aUsl6:=Parsiraj(qqRoba6,"IDROBA")
 if aUsl1<>NIL .and. aUsl2<>NIL .and. aUsl3<>NIL .and. aUsl4<>NIL .and. aUsl5<>NIL .and. aUsl6<>NIL
    exit
 endif
enddo
BoxC()

Params2()
// qqKupac:=trim(qqKupac)
qqRoba1:=trim(qqRoba1); qqRoba2:=trim(qqRoba2); qqRoba3:=trim(qqRoba3)
qqRoba4:=trim(qqRoba4); qqRoba5:=trim(qqRoba5); qqRoba6:=trim(qqRoba6)

WPar("d1",dDatOd) ; WPar("d2",dDatDo)
WPar("O1",cRoba1) ; WPar("O2",cRoba2) ; WPar("O3",cRoba3)
WPar("O4",cRoba4) ; WPar("O5",cRoba5) ; WPar("O6",cRoba6)
WPar("F7",cIdFirma)
WPar("F1",qqRoba1); WPar("F2",qqRoba2); WPar("F3",qqRoba3)
WPar("F4",qqRoba4); WPar("F5",qqRoba5); WPar("F6",qqRoba6)

select params; use

SELECT FAKT

cTMPFAKT:=""
Box(,2,30)
  nSlog:=0; nUkupno:=RECCOUNT2()
  cSort1 := "DTOS(DATDOK)+IDTIPDOK+BRDOK"
  cFilt  := "DATDOK>="+cm2str(dDatOd)+".and. DATDOK<="+cm2str(dDatDo)
  cFilt+=".and. (EMPTY("+cm2str(cIdFirma)+") .or. Idpartner=="+cm2str(cIdFirma)+")"
  cFilt+=".and. ("+aUsl1+".or."+aUsl2+".or."+aUsl3+".or."+aUsl4+".or."+aUsl5+".or."+aUsl6+")"
  INDEX ON &cSort1 TO (cTMPFAKT:=TMPFAKT()) FOR &cFilt EVAL(TekRec()) EVERY 1
BoxC()
GO TOP
if eof(); Msg("Ne postoje trazeni podaci...",6); closeret; endif

START PRINT CRET

PRIVATE nUkKol:=0, nUkIznos:=0
PRIVATE cIdTipDok:="", cBrDok:="", dDatum:=CTOD("")

aKol:={ { "DATUM"       ,   {|| dDatum                                        }, .f., "D", 8, 0, 1, 1},;
        { "TIP DOKUM."  ,   {|| cIdTipDok                                     }, .f., "C",10, 0, 1, 2},;
        { "BROJ DOKUMENTA", {|| cbrdok                                        }, .f., "C",14, 0, 1, 3},;
        { "KOLICINA"    ,   {|| nUkKol                                        }, .t., "N",13, 2, 1, 4},;
        { "CIJENA"      ,   {|| IF(nUkKol==0,0,ROUND(nUkIznos,gFZaok)/nUkKol) }, .f., "N",13, 2, 1, 5},;
        { "VRIJEDNOST"  ,   {|| ROUND(nUkIznos,gFZaok)                        }, .t., "N",14, 2, 1, 6} }

?? space(gnLMarg); ?? "FAKT: Izvjestaj na dan",date()
? space(gnLMarg); IspisFirme("")
? space(gnLMarg); ?? "KUPAC: " + IF( EMPTY(cIdFirma) , "SVI" , cIdFirma+" "+Ocitaj(F_PARTN,cIdFirma,"naz") )

StampaTabele(aKol,{|| FSvaki2()},,gTabela,,;
     ,"Isporuceni asortiman - pregled po fakturama za period od "+DTOC(ddatod)+" do "+DTOC(ddatdo),;
                             {|| FFor2()},IF(gOstr=="D",,-1),,,,,)
FF
END PRINT
CLOSE ALL; MyFERASE(cTMPFAKT)

CLOSERET
return
*}


/*! \fn FFor2()
 *  \brief
 */
 
function FFor2()
*{
cIdTipDok:=idtipdok; cBrDok:=brdok; dDatum:=datdok
 nUkKol:=0; nUkIznos:=0
 DO WHILE !EOF() .and. datdok==dDatum .and. idtipdok==cIdTipDok .and. brdok==cBrDok
   nUkKol+=kolicina
   IF cVarijanta=="1"
     nUkIznos += ROUND( kolicina*cijena*PrerCij()*(1-rabat/100)*(1+porez/100) , ZAOKRUZENJE)
   ELSE
     nUkIznos += ROUND( kolicina*cijena*PrerCij() , ZAOKRUZENJE)
   ENDIF
   SKIP 1
 ENDDO
 SKIP -1
return .t.
*}



/*! \fn Pregled3()
 *  \brief Pregled isporucenog asortimana za kupca po pogonima
 *  \brief Izvjestaj specifican za rudnik
 */
 
function Pregled3()
*{
O_PARTN
O_RJ
O_FAKT

cVarijanta:="1"               // 1 - sa porezom i rabatom
                              // 2 - bez     - ll -
cIdFirma:=space(6)
qqRoba1:=space(60); cRoba1:=SPACE(10)
qqRoba2:=space(60); cRoba2:=SPACE(10)
qqRoba3:=space(60); cRoba3:=SPACE(10)
qqRoba4:=space(60); cRoba4:=SPACE(10)
qqRoba5:=space(60); cRoba5:=SPACE(10)
qqRoba6:=space(60); cRoba6:=SPACE(10)
dDatOd:=ctod(""); dDatDo:=date(); gOstr:="D"
cProsCij:="N"

O_PARAMS
private cSection:="5",cHistory:=" "; aHistory:={}
Params1()
RPar("d1",@dDatOd); RPar("d2",@dDatDo)
RPar("O1",@cRoba1); RPar("O2",@cRoba2); RPar("O3",@cRoba3)
RPar("O4",@cRoba4); RPar("O5",@cRoba5); RPar("O6",@cRoba6)
RPar("F7",@cIdFirma)
RPar("F1",@qqRoba1); RPar("F2",@qqRoba2); RPar("F3",@qqRoba3)
RPar("F4",@qqRoba4); RPar("F5",@qqRoba5); RPar("F6",@qqRoba6)
RPar("F9",@cProsCij)

cIdFirma:=PADR(cIdFirma,6)
qqRoba1:=PADR(qqRoba1,60); qqRoba2:=PADR(qqRoba2,60); qqRoba3:=PADR(qqRoba3,60)
qqRoba4:=PADR(qqRoba4,60); qqRoba5:=PADR(qqRoba5,60); qqRoba6:=PADR(qqRoba6,60)


Box(,13,70)
do while .t.

 @ m_X+1,m_Y+15 SAY "NAZIV               USLOV"

 @ m_X+2,m_Y+ 2 SAY "Asortiman 1" GET cRoba1
 @ m_X+2,m_Y+26 GET qqRoba1    pict "@!S30"
 @ m_X+3,m_Y+ 2 SAY "Asortiman 2" GET cRoba2
 @ m_X+3,m_Y+26 GET qqRoba2    pict "@!S30"
 @ m_X+4,m_Y+ 2 SAY "Asortiman 3" GET cRoba3
 @ m_X+4,m_Y+26 GET qqRoba3    pict "@!S30"
 @ m_X+5,m_Y+ 2 SAY "Asortiman 4" GET cRoba4
 @ m_X+5,m_Y+26 GET qqRoba4    pict "@!S30"
 @ m_X+6,m_Y+ 2 SAY "Asortiman 5" GET cRoba5
 @ m_X+6,m_Y+26 GET qqRoba5    pict "@!S30"
 @ m_X+7,m_Y+ 2 SAY "Asortiman 6" GET cRoba6
 @ m_X+7,m_Y+26 GET qqRoba6    pict "@!S30"

 @ m_X+ 8,m_Y+2 SAY "KUPAC (prazno-svi)" GET cIdFirma VALID P_Firma(@cIdFirma) pict "@!S30"

 @ m_X+ 9,m_Y+2 SAY "Za period od" GET dDatOD
 @ m_X+ 9,col()+2 SAY "do" GET dDatDo

 @ m_X+10,m_y+2 SAY "Varijanta ( 1-sa por.i rab. , 2-bez por.i rab. ) ? " GET cVarijanta VALID cVarijanta$"12" PICT "9"
 @ m_X+11,m_y+2 SAY "Ukljuceno ostranicavanje ? (D/N)" GET gOstr VALID gOstr$"DN" PICT "@!"
 @ m_X+12,m_y+2 SAY "Prikazati prosjecne cijene ? (D/N)" GET cProsCij VALID cProsCij$"DN" PICT "@!"

 read; ESC_BCR
 aUsl1:=Parsiraj(qqRoba1,"IDROBA")
 aUsl2:=Parsiraj(qqRoba2,"IDROBA")
 aUsl3:=Parsiraj(qqRoba3,"IDROBA")
 aUsl4:=Parsiraj(qqRoba4,"IDROBA")
 aUsl5:=Parsiraj(qqRoba5,"IDROBA")
 aUsl6:=Parsiraj(qqRoba6,"IDROBA")
 if aUsl1<>NIL .and. aUsl2<>NIL .and. aUsl3<>NIL .and. aUsl4<>NIL .and. aUsl5<>NIL .and. aUsl6<>NIL
    exit
 endif
enddo
BoxC()

Params2()
// qqKupac:=trim(qqKupac)
qqRoba1:=trim(qqRoba1); qqRoba2:=trim(qqRoba2); qqRoba3:=trim(qqRoba3)
qqRoba4:=trim(qqRoba4); qqRoba5:=trim(qqRoba5); qqRoba6:=trim(qqRoba6)

WPar("d1",dDatOd) ; WPar("d2",dDatDo)
WPar("O1",cRoba1) ; WPar("O2",cRoba2) ; WPar("O3",cRoba3)
WPar("O4",cRoba4) ; WPar("O5",cRoba5) ; WPar("O6",cRoba6)
WPar("F7",cIdFirma)
WPar("F1",qqRoba1); WPar("F2",qqRoba2); WPar("F3",qqRoba3)
WPar("F4",qqRoba4); WPar("F5",qqRoba5); WPar("F6",qqRoba6)
WPar("F9",cProsCij)

select params; use

SELECT FAKT

cTMPFAKT:=""
Box(,2,30)
  nSlog:=0; nUkupno:=RECCOUNT2()
  cSort1 := "IDROBA"
  cFilt  := "DATDOK>=dDatOd .and. DATDOK<=dDatDo .and. ( EMPTY(cIdFirma) .or. cIdFirma==IDPARTNER ) .and. ( "+aUsl1+".or."+aUsl2+".or."+aUsl3+".or."+aUsl4+".or."+aUsl5+".or."+aUsl6+")"
  INDEX ON &cSort1 TO (cTMPFAKT:=TMPFAKT()) FOR &cFilt EVAL(TekRec()) EVERY 1
BoxC()

GO TOP
if eof(); Msg("Ne postoje trazeni podaci...",6); closeret; endif

START PRINT CRET

PRIVATE cIdRj:="", cNazRj:="", nUkRoba:=0, nUkIznos:=0
PRIVATE nRoba1:=0, nRoba2:=0, nRoba3:=0, nRoba4:=0, nRoba5:=0, nRoba6:=0
PRIVATE nPCR1:=nPCR2:=nPCR3:=nPCR4:=nPCR5:=nPCR6:=nPCRU:=0
PRIVATE nIzR1:=nIzR2:=nIzR3:=nIzR4:=nIzR5:=nIzR6:=0

IF cProsCij=="D"

aKol:={ { "SIFRA"          , {|| cIdRj                   }, .f., "C", 6, 0, 1, 1},;
        { "POGON (R.JED.)" , {|| cNazRj                  }, .f., "C",30, 0, 1, 2},;
        { cRoba1           , {|| nRoba1                  }, .t., "N",12, 2, 1, 3},;
        { cRoba2           , {|| nRoba2                  }, .t., "N",12, 2, 1, 4},;
        { cRoba3           , {|| nRoba3                  }, .t., "N",12, 2, 1, 5},;
        { cRoba4           , {|| nRoba4                  }, .t., "N",12, 2, 1, 6},;
        { cRoba5           , {|| nRoba5                  }, .t., "N",12, 2, 1, 7},;
        { cRoba6           , {|| nRoba6                  }, .t., "N",12, 2, 1, 8},;
        { "UKUPNO KOL."    , {|| nUkRoba                 }, .t., "N",12, 2, 1, 9},;
        { "UKUPNO IZNOS"   , {|| ROUND(nUkIznos,gFZaok)  }, .t., "N",12, 2, 3, 9} }

  AADD(aKol, { "PROSJ.CIJ.", {|| nPCR1}, .f., "N",12,2,2,3 } )
  AADD(aKol, { "IZNOS"     , {|| nIzR1}, .t., "N",12,2,3,3 } )
  AADD(aKol, { "PROSJ.CIJ.", {|| nPCR2}, .f., "N",12,2,2,4 } )
  AADD(aKol, { "IZNOS"     , {|| nIzR2}, .t., "N",12,2,3,4 } )
  AADD(aKol, { "PROSJ.CIJ.", {|| nPCR3}, .f., "N",12,2,2,5 } )
  AADD(aKol, { "IZNOS"     , {|| nIzR3}, .t., "N",12,2,3,5 } )
  AADD(aKol, { "PROSJ.CIJ.", {|| nPCR4}, .f., "N",12,2,2,6 } )
  AADD(aKol, { "IZNOS"     , {|| nIzR4}, .t., "N",12,2,3,6 } )
  AADD(aKol, { "PROSJ.CIJ.", {|| nPCR5}, .f., "N",12,2,2,7 } )
  AADD(aKol, { "IZNOS"     , {|| nIzR5}, .t., "N",12,2,3,7 } )
  AADD(aKol, { "PROSJ.CIJ.", {|| nPCR6}, .f., "N",12,2,2,8 } )
  AADD(aKol, { "IZNOS"     , {|| nIzR6}, .t., "N",12,2,3,8 } )
  AADD(aKol, { "PROSJ.CIJ.", {|| nPCRU}, .f., "N",12,2,2,9 } )

ELSE

aKol:={ { "SIFRA"          , {|| cIdRj                   }, .f., "C", 6, 0, 1, 1},;
        { "POGON (R.JED.)" , {|| cNazRj                  }, .f., "C",30, 0, 1, 2},;
        { cRoba1           , {|| nRoba1                  }, .t., "N",10, 2, 1, 3},;
        { cRoba2           , {|| nRoba2                  }, .t., "N",10, 2, 1, 4},;
        { cRoba3           , {|| nRoba3                  }, .t., "N",10, 2, 1, 5},;
        { cRoba4           , {|| nRoba4                  }, .t., "N",10, 2, 1, 6},;
        { cRoba5           , {|| nRoba5                  }, .t., "N",10, 2, 1, 7},;
        { cRoba6           , {|| nRoba6                  }, .t., "N",10, 2, 1, 8},;
        { "UKUPNO KOL."    , {|| nUkRoba                 }, .t., "N",11, 2, 1, 9},;
        { "UKUPNO IZNOS"   , {|| ROUND(nUkIznos,gFZaok)  }, .t., "N",12, 2, 1,10} }

ENDIF

?? space(gnLMarg); ?? "FAKT: Izvjestaj na dan",date()
? space(gnLMarg); IspisFirme("")
? space(gnLMarg); ?? "KUPAC: " + IF( EMPTY(cIdFirma) , "SVI" , cIdFirma+" "+Ocitaj(F_PARTN,cIdFirma,"naz") )

StampaTabele(aKol,{|| FSvaki3()},,gTabela,,;
     ,"Isporuceni asortiman - pregled za kupca po pogonima od "+DTOC(ddatod)+" do "+DTOC(ddatdo),;
                             {|| FFor3()},IF(gOstr=="D",,-1),,cProsCij=="D",,,)
FF
END PRINT
CLOSE ALL; MyFERASE(cTMPFAKT)

CLOSERET
return
*}


/*! \fn FFor3()
 *  \brief
 */
 
function FFor3()
*{
cIdRj:=LEFT(IDROBA,2)
 nRoba1:=nRoba2:=nRoba3:=nRoba4:=nRoba5:=nRoba6:=nUkRoba:=nUkIznos:=0
 nIzR1:=nIzR2:=nIzR3:=nIzR4:=nIzR5:=nIzR6:=0
 cNazRJ:=Ocitaj(F_RJ,cIdRj,"TRIM(naz)")

 DO WHILE !EOF() .and. cIdRj==LEFT(IDROBA,2)

   IF &aUsl1; nRoba1+=kolicina; nIzR1+=ROUND( kolicina*cijena*PrerCij()*(1-rabat/100)*(1+porez/100) , ZAOKRUZENJE ); ENDIF
   IF &aUsl2; nRoba2+=kolicina; nIzR2+=ROUND( kolicina*cijena*PrerCij()*(1-rabat/100)*(1+porez/100) , ZAOKRUZENJE ); ENDIF
   IF &aUsl3; nRoba3+=kolicina; nIzR3+=ROUND( kolicina*cijena*PrerCij()*(1-rabat/100)*(1+porez/100) , ZAOKRUZENJE ); ENDIF
   IF &aUsl4; nRoba4+=kolicina; nIzR4+=ROUND( kolicina*cijena*PrerCij()*(1-rabat/100)*(1+porez/100) , ZAOKRUZENJE ); ENDIF
   IF &aUsl5; nRoba5+=kolicina; nIzR5+=ROUND( kolicina*cijena*PrerCij()*(1-rabat/100)*(1+porez/100) , ZAOKRUZENJE ); ENDIF
   IF &aUsl6; nRoba6+=kolicina; nIzR6+=ROUND( kolicina*cijena*PrerCij()*(1-rabat/100)*(1+porez/100) , ZAOKRUZENJE ); ENDIF
   IF &(aUsl1+".or."+aUsl2+".or."+aUsl3+".or."+;
        aUsl4+".or."+aUsl5+".or."+aUsl6)
     nUkIznos += ROUND( kolicina*cijena*PrerCij()*(1-rabat/100)*(1+porez/100) , ZAOKRUZENJE)
   ENDIF

   SKIP 1

 ENDDO

 nPCR1 := ROUND( IF( nRoba1<>0 , nIzR1/nRoba1 , 0 ) , 2 )
 nPCR2 := ROUND( IF( nRoba2<>0 , nIzR2/nRoba2 , 0 ) , 2 )
 nPCR3 := ROUND( IF( nRoba3<>0 , nIzR3/nRoba3 , 0 ) , 2 )
 nPCR4 := ROUND( IF( nRoba4<>0 , nIzR4/nRoba4 , 0 ) , 2 )
 nPCR5 := ROUND( IF( nRoba5<>0 , nIzR5/nRoba5 , 0 ) , 2 )
 nPCR6 := ROUND( IF( nRoba6<>0 , nIzR6/nRoba6 , 0 ) , 2 )

 nUkRoba := nRoba1+nRoba2+nRoba3+nRoba4+nRoba5+nRoba6
 nPCRU := ROUND( IF( nUkRoba<>0 , nUkIznos/nUkRoba , 0 ) , 2 )

 SKIP -1
return .t.
*}


/*! \fn FSvaki3()
 *  \brief
 */
function FSvaki3()
*{
RETURN
*}



/*! \fn Pregled4()
 *  \brief Pregled faktura usluga za kupca
 *  \brief Izvjestaj specifican za runik
 */

function Pregled4()
*{
O_PARTN
O_FAKT

cVarijanta:="1"               // 1 - sa porezom i rabatom
                              // 2 - bez     - ll -
cIdFirma:=space(6)
gZaokP4:=2
qqUsluge:="U;"+SPACE(58)
dDatOd:=ctod(""); dDatDo:=date(); gOstr:="D"
private aUsl1

O_PARAMS
private cSection:="5",cHistory:=" "; aHistory:={}
Params1()
RPar("d1",@dDatOd); RPar("d2",@dDatDo)
RPar("F7",@cIdFirma)
RPar("F8",@qqUsluge)

cIdFirma:=PADR(cIdFirma,6)
qqUsluge:=PADR(qqUsluge,60)

Box(,11,70)
do while .t.

 @ m_X+ 2,m_Y+ 2 SAY "Uslov za usluge (po sifri)" GET qqUsluge PICT "@!S30"

 @ m_X+ 4,m_Y+2 SAY "KUPAC (prazno-svi)" GET cIdFirma VALID P_Firma(@cIdFirma) pict "@!S30"

 @ m_X+ 6,m_Y+2 SAY "Za period od" GET dDatOD
 @ m_X+ 6,col()+2 SAY "do" GET dDatDo

 @ m_X+ 8,m_y+2 SAY "Varijanta ( 1-sa por.i rab. , 2-bez por.i rab. ) ? " GET cVarijanta VALID cVarijanta$"12" PICT "9"
 @ m_X+ 9,m_y+2 SAY "Ukljuceno ostranicavanje ? (D/N)" GET gOstr VALID gOstr$"DN" PICT "@!"
 @ m_X+10,m_y+2 SAY "Zaokruzivanje na (br.decimala)" GET gZaokP4  PICT "9"

 read; ESC_BCR
 aUsl1:=Parsiraj(qqUsluge,"IDROBA")
 if aUsl1<>NIL
    exit
 endif
enddo
BoxC()

Params2()
// qqKupac:=trim(qqKupac)
qqUsluge:=trim(qqUsluge)

WPar("d1",dDatOd) ; WPar("d2",dDatDo)
WPar("F7",cIdFirma)
WPar("F8",qqUsluge)

select params; use

SELECT FAKT
cTMPFAKT:=""
Box(,2,30)
  nSlog:=0; nUkupno:=RECCOUNT2()
  cSort1 := "DTOS(DATDOK)+IDTIPDOK+BRDOK"
  cFilt  := "DATDOK>=dDatOd .and. DATDOK<=dDatDo .and. ( EMPTY(cIdFirma) .or. cIdFirma==IDPARTNER ).and."+aUsl1
  INDEX ON &cSort1 TO (cTMPFAKT:=TMPFAKT()) FOR &cFilt EVAL(TekRec()) EVERY 1
BoxC()

GO TOP
if eof(); Msg("Ne postoje trazeni podaci...",6); closeret; endif

START PRINT CRET

PRIVATE nUkKol:=0, nUkIznos:=0
PRIVATE cIdTipDok:="", cBrDok:="", dDatum:=CTOD("")

aKol:={ { "DATUM"       ,   {|| DTOC(dDatum)            }, .f., "C",12, 0, 1, 1},;
        { "TIP DOKUM."  ,   {|| cIdTipDok               }, .f., "C",12, 0, 1, 2},;
        { "BROJ DOKUMENTA", {|| cbrdok                  }, .f., "C",20, 0, 1, 3},;
        { "VRIJEDNOST"  ,   {|| ROUND(nUkIznos,gZaokP4) }, .t., "N",20, 2, 1, 4} }

?? space(gnLMarg); ?? "FAKT: Izvjestaj na dan",date()
? space(gnLMarg); IspisFirme("")
? space(gnLMarg); ?? "KUPAC: " + IF( EMPTY(cIdFirma) , "SVI" , cIdFirma+" "+Ocitaj(F_PARTN,cIdFirma,"naz") )

StampaTabele(aKol,{|| FSvaki4()},,gTabela,,;
     ,"Fakture usluga - pregled za kupca za period od "+DTOC(ddatod)+" do "+DTOC(ddatdo),;
                             {|| FFor4()},IF(gOstr=="D",,-1),,,,,)
FF
END PRINT
CLOSE ALL; MyFERASE(cTMPFAKT)

CLOSERET
return
*}


/*! \fn FFor4()
 *  \brief
 */
 
function FFor4()
*{
cIdTipDok:=idtipdok; cBrDok:=brdok; dDatum:=datdok
 nUkKol:=0; nUkIznos:=0
 DO WHILE !EOF() .and. datdok==dDatum .and. idtipdok==cIdTipDok .and. brdok==cBrDok
   nUkKol+=kolicina
   IF cVarijanta=="1"
     nUkIznos += ROUND( kolicina*cijena*PrerCij()*(1-rabat/100)*(1+porez/100) , ZAOKRUZENJE )
   ELSE
     nUkIznos += ROUND( kolicina*cijena*PrerCij() , ZAOKRUZENJE )
   ENDIF
   SKIP 1
 ENDDO
 SKIP -1
return .t.
*}

/*! \fn FSvaki4()
 */
 
function FSvaki4()
*{
RETURN
*}


/*! \fn Pregled5()
 *  \brief Pregled poreza po fakturama
 *  \brief Izvjestaj specifican za rudnik
 */
function Pregled5()
*{
O_PARTN
O_FAKT

cIdFirma:=space(6)
qqPorez1:=10
qqPorez2:=15
qqPorez3:=20
qqPorez4:=qqPorez5:=0

dDatOd:=ctod(""); dDatDo:=date(); gOstr:="D"

O_PARAMS
private cSection:="5",cHistory:=" "; aHistory:={}
Params1()

RPar("d1",@dDatOd); RPar("d2",@dDatDo); RPar("F7",@cIdFirma)
RPar("o7",@qqPorez1); RPar("o8",@qqPorez2); RPar("o9",@qqPorez3)
RPar("oA",@qqPorez4); RPar("oB",@qqPorez5)

cIdFirma:=PADR(cIdFirma,6)

Box(,12,70)
do while .t.

 @ m_X+1,m_Y+19 SAY "(%)"

 @ m_X+2,m_Y+ 2 SAY "Iznos poreza 1" GET qqPorez1  PICT "999.99"
 @ m_X+3,m_Y+ 2 SAY "Iznos poreza 2" GET qqPorez2  PICT "999.99"
 @ m_X+4,m_Y+ 2 SAY "Iznos poreza 3" GET qqPorez3  PICT "999.99"
 @ m_X+5,m_Y+ 2 SAY "Iznos poreza 4" GET qqPorez4  PICT "999.99"
 @ m_X+6,m_Y+ 2 SAY "Iznos poreza 5" GET qqPorez5  PICT "999.99"

 @ m_X+ 8,m_Y+2 SAY "KUPAC (prazno-svi)" GET cIdFirma VALID P_Firma(@cIdFirma) pict "@!S30"

 @ m_X+ 9,m_Y+2 SAY "Za period od" GET dDatOD
 @ m_X+ 9,col()+2 SAY "do" GET dDatDo

 @ m_X+11,m_y+2 SAY "Ukljuceno ostranicavanje ? (D/N)" GET gOstr VALID gOstr$"DN" PICT "@!"

 read; ESC_BCR
 exit
enddo
BoxC()

Params2()
// qqKupac:=trim(qqKupac)

WPar("d1",dDatOd) ; WPar("d2",dDatDo)
WPar("F7",cIdFirma)
WPar("o7",qqPorez1); WPar("o8",qqPorez2); WPar("o9",qqPorez3)
WPar("oA",qqPorez4); WPar("oB",qqPorez5)

select params; use

SELECT FAKT
cTMPFAKT:=""

Box(,2,30)
  nSlog:=0; nUkupno:=RECCOUNT2()
  cSort1 := "DTOS(DATDOK)+IDTIPDOK+BRDOK"
  cFilt  := "DATDOK>=dDatOd .and. DATDOK<=dDatDo .and. ( EMPTY(cIdFirma) .or. cIdFirma==IDPARTNER ) .and. ( porez==qqPorez1.and.qqPorez1>0 .or. porez==qqPorez2.and.qqPorez2>0 .or. porez==qqPorez3.and.qqPorez3>0 .or. porez==qqPorez4.and.qqPorez4>0 .or. porez==qqPorez5.and.qqPorez5>0 )"
  INDEX ON &cSort1 TO (cTMPFAKT:=TMPFAKT()) FOR &cFilt EVAL(TekRec()) EVERY 1
BoxC()

GO TOP
if eof(); Msg("Ne postoje trazeni podaci...",6); closeret; endif

START PRINT CRET

PRIVATE cIdTipDok:="", cBrDok:="", dDatum:=CTOD("")
PRIVATE nPor1:=nPor2:=nPor3:=nPor4:=nPor5:=nUkPor:=0
PRIVATE nKPor1:=nKPor2:=nKPor3:=nKPor4:=nKPor5:=nKUkPor:=0

aKol:={ { "DATUM"          , {|| dDatum       }, .f., "D", 8, 0, 1, 1},;
        { "TIP DOKUM."     , {|| cIdTipDok    }, .f., "C",10, 0, 1, 2},;
        { "BROJ DOKUMENTA" , {|| cbrdok       }, .f., "C",14, 0, 1, 3} }

i:=3
IF qqPorez1>0
 AADD(aKol,{ "POREZ "+STR(qqPorez1,6,2)+"%" , {|| nPor1 }, .t., "N",13, 2, 1, ++i})
ENDIF
IF qqPorez2>0
 AADD(aKol,{ "POREZ "+STR(qqPorez2,6,2)+"%" , {|| nPor2 }, .t., "N",13, 2, 1, ++i})
ENDIF
IF qqPorez3>0
 AADD(aKol,{ "POREZ "+STR(qqPorez3,6,2)+"%" , {|| nPor3 }, .t., "N",13, 2, 1, ++i})
ENDIF
IF qqPorez4>0
 AADD(aKol,{ "POREZ "+STR(qqPorez4,6,2)+"%" , {|| nPor4 }, .t., "N",13, 2, 1, ++i})
ENDIF
IF qqPorez5>0
 AADD(aKol,{ "POREZ "+STR(qqPorez5,6,2)+"%" , {|| nPor5 }, .t., "N",13, 2, 1, ++i})
ENDIF
AADD(aKol,{ "UKUPNO POREZI", {|| nUkPor }, .t., "N",13, 2, 1, ++i})

IF qqPorez1>0
 AADD(aKol,{ "POREZ "+STR(qqPorez1,6,2)+"%" , {|| nKPor1 }, .f., "N",13, 2, 1, ++i})
 AADD(aKol,{ "KUMULATIVNO" , {|| "#" }, .f., "N",13, 2, 2, i})
ENDIF
IF qqPorez2>0
 AADD(aKol,{ "POREZ "+STR(qqPorez2,6,2)+"%" , {|| nKPor2 }, .f., "N",13, 2, 1, ++i})
 AADD(aKol,{ "KUMULATIVNO" , {|| "#" }, .f., "N",13, 2, 2, i})
ENDIF
IF qqPorez3>0
 AADD(aKol,{ "POREZ "+STR(qqPorez3,6,2)+"%" , {|| nKPor3 }, .f., "N",13, 2, 1, ++i})
 AADD(aKol,{ "KUMULATIVNO" , {|| "#" }, .f., "N",13, 2, 2, i})
ENDIF
IF qqPorez4>0
 AADD(aKol,{ "POREZ "+STR(qqPorez4,6,2)+"%" , {|| nKPor4 }, .f., "N",13, 2, 1, ++i})
 AADD(aKol,{ "KUMULATIVNO" , {|| "#" }, .f., "N",13, 2, 2, i})
ENDIF
IF qqPorez5>0
 AADD(aKol,{ "POREZ "+STR(qqPorez5,6,2)+"%" , {|| nKPor5 }, .f., "N",13, 2, 1, ++i})
 AADD(aKol,{ "KUMULATIVNO" , {|| "#" }, .f., "N",13, 2, 2, i})
ENDIF
AADD(aKol,{ "UKUPNO POREZI", {|| nKUkPor }, .f., "N",13, 2, 1, ++i})
AADD(aKol,{ "KUMULATIVNO" , {|| "#" }, .f., "N",13, 2, 2, i})


?? space(gnLMarg); ?? "FAKT: Izvjestaj na dan",date()
? space(gnLMarg); IspisFirme("")
? space(gnLMarg); ?? "KUPAC: " + IF( EMPTY(cIdFirma) , "SVI" , cIdFirma+" "+Ocitaj(F_PARTN,cIdFirma,"naz") )

StampaTabele(aKol,{|| FSvaki5()},,gTabela,,;
     ,"Pregled poreza po fakturama za period od "+DTOC(ddatod)+" do "+DTOC(ddatdo),;
                             {|| FFor5()},IF(gOstr=="D",,-1),,,,,)
FF
END PRINT
CLOSE ALL; MyFERASE(cTMPFAKT)

CLOSERET
return
*}


/*! \fn FFor5()
 *  \brief
 */
 
function FFor5()
*{
cIdTipDok:=IDTIPDOK; cBrDok:=BRDOK; dDatum:=DATDOK
 nPor1:=nPor2:=nPor3:=nPor4:=nPor5:=nUkPor:=0
 DO WHILE !EOF() .and. datdok==dDatum .and. idtipdok==cIdTipDok .and. brdok==cBrDok
   IF qqPorez1==ROUND(porez,0)
     nPor1 += round( CIJENA*KOLICINA*PrerCij()*(1-RABAT/100)*POREZ/100 ,ZAOKRUZENJE)
   ENDIF
   IF qqPorez2==ROUND(porez,0)
     nPor2 += round( CIJENA*KOLICINA*PrerCij()*(1-RABAT/100)*POREZ/100 ,ZAOKRUZENJE)
   ENDIF
   IF qqPorez3==ROUND(porez,0)
     nPor3 += round( CIJENA*KOLICINA*PrerCij()*(1-RABAT/100)*POREZ/100 ,ZAOKRUZENJE)
   ENDIF
   IF qqPorez4==ROUND(porez,0)
     nPor4 += round( CIJENA*KOLICINA*PrerCij()*(1-RABAT/100)*POREZ/100 ,ZAOKRUZENJE)
   ENDIF
   IF qqPorez5==ROUND(porez,0)
     nPor5 += round( CIJENA*KOLICINA*PrerCij()*(1-RABAT/100)*POREZ/100 ,ZAOKRUZENJE)
   ENDIF
   SKIP 1
 ENDDO
 SKIP -1
 nPor1 := ROUND( nPor1 , FIELD->zaokr )
 nPor2 := ROUND( nPor2 , FIELD->zaokr )
 nPor3 := ROUND( nPor3 , FIELD->zaokr )
 nPor4 := ROUND( nPor4 , FIELD->zaokr )
 nPor5 := ROUND( nPor5 , FIELD->zaokr )
 nUkPor := nPor1+nPor2+nPor3+nPor4+nPor5
 nKUkPor += nUkPor; nKPor1 += nPor1; nKPor2 += nPor2
 nKPor3  += nPor3;  nKPor4 += nPor4; nKPor5 += nPor5
return .t.
*}


/*! \fn FSvaki5()
 */
function FSvaki5()
*{
RETURN
*}


/*! \fn VRobPoPar()
 *  \brief Vrijednost robe po partnerima/prodavnicama
 */
 
function VRobPoPar()
*{
IF IzFmkIni("FAKT","Opcine","N",SIFPATH)=="D"
    O_OPS
  ENDIF
  O_SIFK; O_SIFV
  O_ROBA
  O_TARIFA
  O_RJ
  O_PARTN
  O_FAKT

  cTMPFAKT:=""

  cIdfirma:=gFirma
  qqRoba:=""
  dDatOd:=ctod("")
  dDatDo:=date()
  qqTipdok:="  "
  qqPartn:=SPACE(60)
  cVarSubTot:="1"        // 1-po PARTN->idops    2-po left(idpartner,2)

  O_PARAMS
  private cSection:="5",cHistory:=" "; aHistory:={}
  Params1()
  RPar("c1",@cIdFirma); RPar("c2",@qqRoba)
  RPar("c4",@cVarSubTot)
  RPar("c8",@qqTipDok)
  RPar("d1",@dDatOd) ; RPar("d2",@dDatDo)
  qqRoba:=PADR(qqRoba,80)

  Box(,8,75)
  DO WHILE .t.
   if gNW$"DR"
     @ m_x+1,m_y+2 SAY "RJ (prazno svi) " GET cIdFirma valid {|| empty(cIdFirma) .or. cidfirma==gFirma .or. P_RJ(@cIdFirma) }
   else
     @ m_x+1,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
   endif
   @ m_x+2,m_y+2 SAY "Roba   "  GET qqRoba   pict "@!S40"
   @ m_x+4,m_y+2 SAY "Tip dokumenta (prazno - svi)"  GET qqTipdok
   @ m_x+5,m_y+2 SAY "Obuhvatiti sifre partnera (prazno - svi)"  GET qqPartn PICT "@!S25"
   @ m_x+6,m_y+2 SAY "Od datuma "  get dDatOd
   @ m_x+6,col()+1 SAY "do"  get dDatDo
   IF IzFmkIni("FAKT","Opcine","N",SIFPATH)<>"D"
     cVarSubTot:="2"
   ELSE
     @ m_x+8,m_y+2 SAY "Varijanta subtotala po opcinama (1/2)"  get cVarSubTot VALID cVarSubTot$"12"
   ENDIF
   READ; ESC_BCR
   aUsl1:=Parsiraj(qqRoba,"IDROBA")
   aUsl2:=Parsiraj(qqPartn,"IDPARTNER")
   IF aUsl1<>NIL; EXIT; ENDIF
  ENDDO
  BoxC()

  select params
  qqRoba:=trim(qqRoba)
  WPar("c1",cIdFirma); WPar("c2",qqRoba)
  WPar("c4",cVarSubTot)
  WPar("c8",qqTipDok)
  WPar("d1",dDatOd); WPar("d2",dDatDo)
  use

  fSMark:=.f.
  if right(qqRoba,1)="*"
    // izvrsena je markacija robe ..
    fSMark:=.t.
  endif

  SELECT FAKT

  IF cVarSubTot=="1"
    SET RELATION TO idpartner INTO PARTN
    cSort1 := "PARTN->idops+idpartner"
  ELSE
    cSort1 := "idpartner"
  ENDIF
  cFilt1 := aUsl1
  if !empty(dDatOd) .or. !empty(dDatDo)
    cFilt1 += ".and. DatDok>="+cm2str(dDatOd)+".and. DatDok<="+cm2str(dDatDo)
  endif
  IF !EMPTY(qqTipDok)
    cFilt1 += ".and. IDTIPDOK=="+cm2str(qqTipDok)
  ENDIF
  IF !EMPTY(cIdFirma)
    cFilt1 += ".and. IDFIRMA=="+cm2str(cIdFirma)
  ENDIF
  IF !EMPTY(qqPartn)
    cFilt1 += (".and."+aUsl2)
  ENDIF

  INDEX ON &cSort1 TO (cTMPFAKT:=TMPFAKT()) FOR &cFilt1

  START PRINT CRET

  PRIVATE cIdPartner:="", cNPartnera:="", nUkIznos:=0, lSubTot6:=.f.
  PRIVATE cSubTot6:="", cIdOps:=""
  gOstr:="D"
  nOpor:=nNeOpor:=0

aKol:={ { "SIFRA"        , {|| cIdPartner             }, .f., "C", 6, 0, 1, 1},;
        { "PARTNER"      , {|| cNPartnera             }, .f., "C",50, 0, 1, 2},;
        { "Neoporezovani", {|| ROUND(nNeOpor ,gFZaok) }, .t., "N",13, 2, 1, 3},;
        { "iznos"        , {|| "#"                    }, .f., "C",13, 0, 2, 3},;
        { "Oporezovani"  , {|| ROUND(nOpor ,gFZaok)   }, .t., "N",13, 2, 1, 4},;
        { "iznos"        , {|| "#"                    }, .f., "C",13, 0, 2, 4},;
        { "UKUPNO IZNOS" , {|| ROUND(nUkIznos,gFZaok) }, .t., "N",13, 2, 1, 5} }

  ?? space(gnLMarg); ?? "FAKT: Izvjestaj na dan",date()
  ? space(gnLMarg); IspisFirme("")
  ? space(gnLMarg); ?? "RJ: " + IF( EMPTY(cIdFirma) , "SVE" , cIdFirma )
  IF !EMPTY(qqPartn)
    ? space(gnLMarg); ?? "OBUHVACENI PARTNERI: "+TRIM(qqPartn)
  ENDIF

  StampaTabele(aKol,{|| FSvaki6()},,gTabela,,;
       ,"Vrijednost isporuke partnerima za period od "+DTOC(ddatod)+" do "+DTOC(ddatdo),;
                               {|| FFor6()},IF(gOstr=="D",,-1),,,{|| SubTot6()},,)

  FF
  END PRINT
CLOSE ALL; MyFERASE(cTMPFAKT)
CLOSERET
return
*}


/*! \fn FFor6()
 *  \brief
 */
 
function FFor6()
*{
LOCAL nIznos:=0
 IF fSMark .and. SkLoNMark("ROBA",SiSiRo()) 
   RETURN .f.
 ENDIF
 IF cVarSubTot=="1"
   IF PARTN->idops <> cIdOps .and. LEN(cIdOps)>0
     lSubTot6:=.t.
     cSubTot6:=cIdOps
   ENDIF
 ELSE
   IF SUBSTR(idpartner,2,2) <> SUBSTR(cIdPartner,2,2) .and. LEN(cIdPartner)>0
     lSubTot6:=.t.
     cSubTot6:=SUBSTR(cIdPartner,2,2)
   ENDIF
 ENDIF
 cIdPartner:=idpartner
 cIdOps:=PARTN->idops
 nUkIznos:=0
 nOpor:=nNeOpor:=0
 IF cVarSubTot=="1"
   cNPartnera:=PARTN->(TRIM(naz)+' '+TRIM(naz2))
 ELSE
   cNPartnera:=Ocitaj(F_PARTN,idpartner,"TRIM(naz)+' '+TRIM(naz2)")
 ENDIF
 DO WHILE !EOF() .and. idpartner==cIdPartner
   IF fSMark .and. SkLoNMark("ROBA",SiSiRo()) // skip+loop gdje je roba->_M1_ != "*"
     SKIP 1; LOOP
   ENDIF
   nIznos := ROUND( kolicina*cijena*PrerCij()*(1-rabat/100)*(1+porez/100) , FIELD->zaokr )
   nUkIznos += nIznos
   SELECT ROBA; HSEEK PADR(LEFT(FAKT->idroba,gnDS),LEN(id))
   SELECT TARIFA; HSEEK ROBA->idtarifa; SELECT FAKT
   IF !Oporezovana()
     nNeOpor += nIznos
   ELSE
     nOpor   += nIznos
   ENDIF
   SKIP 1
 ENDDO
 SKIP -1
RETURN .t.
*}


/*! \fn FSvaki6()
 *  \brief 
 */
 
function FSvaki6()
*{
RETURN
*}


/*! \fn SubTot6()
 *  \brief
 */
 
function SubTot6()
*{
LOCAL aVrati:={.f.,""}, cOps:="", cIdOpc:=""
  IF lSubTot6 .or. EOF()
    IF cVarSubTot=="1"
      cIdOpc := IF(EOF(),cIdOps,cSubTot6)
      cOps   := TRIM( Ocitaj(F_OPS,cIdOpc,"naz") )
    ELSE
      cIdOpc := IF(EOF(),SUBSTR(cIdPartner,2,2),cSubTot6)
      cOps   := IzFMKINI("NOVINE","NazivOpstine"+cIdOpc,"-",KUMPATH)
    ENDIF
    aVrati := { .t. , "OPSTINA "+cIdOpc+"-"+cOps }
    lSubTot6:=.f.
  ENDIF
RETURN aVrati
*}


/*! \fn VRobPoIzd()
 *  \brief Vrijednost robe po izdavacima/dobavljacima
 */
 
function VRobPoIzd()
*{
O_SIFK; O_SIFV
  O_RJ
  O_ROBA
  O_TARIFA
  O_FAKT

  cTMPFAKT:=""

  cIdfirma:=gFirma
  qqRoba:=""
  dDatOd:=ctod("")
  dDatDo:=date()
  qqTipdok:="  "

  O_PARAMS
  private cSection:="5",cHistory:=" "; aHistory:={}
  Params1()
  RPar("c1",@cIdFirma); RPar("c2",@qqRoba)
  RPar("c8",@qqTipDok)
  RPar("d1",@dDatOd) ; RPar("d2",@dDatDo)
  qqRoba:=PADR(qqRoba,80)

  Box(,5,75)
  DO WHILE .t.
   if gNW$"DR"
     @ m_x+1,m_y+2 SAY "RJ (prazno svi) " GET cIdFirma valid {|| empty(cIdFirma) .or. cidfirma==gFirma .or. P_RJ(@cIdFirma) }
   else
     @ m_x+1,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
   endif
   @ m_x+2,m_y+2 SAY "Roba   "  GET qqRoba   pict "@!S40"
   @ m_x+4,m_y+2 SAY "Tip dokumenta (prazno - svi)"  GET qqTipdok
   @ m_x+5,m_y+2 SAY "Od datuma "  get dDatOd
   @ m_x+5,col()+1 SAY "do"  get dDatDo
   READ; ESC_BCR
   aUsl1:=Parsiraj(qqRoba,"IDROBA")
   IF aUsl1<>NIL; EXIT; ENDIF
  ENDDO
  BoxC()

  select params
  qqRoba:=trim(qqRoba)
  WPar("c1",cIdFirma); WPar("c2",qqRoba)
  WPar("c8",qqTipDok)
  WPar("d1",dDatOd); WPar("d2",dDatDo)
  use

  fSMark:=.f.
  if right(qqRoba,1)="*"
    // izvrsena je markacija robe ..
    fSMark:=.t.
  endif

  SELECT FAKT

  cSort1 := "idroba"
  cFilt1 := aUsl1
  if !empty(dDatOd) .or. !empty(dDatDo)
    cFilt1 += ".and. DatDok>="+cm2str(dDatOd)+".and. DatDok<="+cm2str(dDatDo)
  endif
  IF !EMPTY(qqTipDok)
    cFilt1 += ".and. IDTIPDOK=="+cm2str(qqTipDok)
  ENDIF
  IF !EMPTY(cIdFirma)
    cFilt1 += ".and. IDFIRMA=="+cm2str(cIdFirma)
  ENDIF

  INDEX ON &cSort1 TO (cTMPFAKT:=TMPFAKT()) FOR &cFilt1

  START PRINT CRET

  PRIVATE cIdRoba:="", cNRobe:="", nUkIznos:=0, lSubTot7:=.f., cSubTot7:=""
  gOstr:="D"
  nOpor:=nNeOpor:=0

  nPP7 := VAL( IzFMKINI("NOVINE","USifriRobe_PocPozSifIzdavaca","1",KUMPATH) )
  nDS7 := VAL( IzFMKINI("NOVINE","USifriRobe_DuzinaSifIzdavaca","3",KUMPATH) )

aKol:={ { "SIFRA"        , {|| cIdRoba                }, .f., "C",10, 0, 1, 1},;
        { "IZDANJE"      , {|| cNRobe                 }, .f., "C",50, 0, 1, 2},;
        { "Neoporezovani", {|| ROUND(nNeOpor ,gFZaok) }, .t., "N",13, 2, 1, 3},;
        { "iznos"        , {|| "#"                    }, .f., "C",13, 0, 2, 3},;
        { "Oporezovani"  , {|| ROUND(nOpor ,gFZaok)   }, .t., "N",13, 2, 1, 4},;
        { "iznos"        , {|| "#"                    }, .f., "C",13, 0, 2, 4},;
        { "UKUPNO IZNOS" , {|| ROUND(nUkIznos,gFZaok) }, .t., "N",13, 2, 1, 5} }

  ?? space(gnLMarg); ?? "FAKT: Izvjestaj na dan",date()
  ? space(gnLMarg); IspisFirme("")
  ? space(gnLMarg); ?? "RJ: " + IF( EMPTY(cIdFirma) , "SVE" , cIdFirma )

  StampaTabele(aKol,{|| FSvaki7()},,gTabela,,;
       ,"Vrijednost isporuke robe po izdavacima za period od "+DTOC(ddatod)+" do "+DTOC(ddatdo),;
                               {|| FFor7()},IF(gOstr=="D",,-1),,,{|| SubTot7()},,)

  FF
  END PRINT
CLOSE ALL; MyFERASE(cTMPFAKT)
CLOSERET
return
*}


/*! \fn FFor7()
 *  \brief
 */
 
function FFor7()
*{
LOCAL nIznos:=0
IF fSMark .and. SkLoNMark("ROBA",SiSiRo()) //skip+loop gdje je roba->_M1_ != "*"
   RETURN .f.
 ENDIF
 IF SUBSTR(idroba,nPP7,nDS7) <> SUBSTR(cIdRoba,nPP7,nDS7) .and. LEN(cIdRoba)>0
   lSubTot7:=.t.
   cSubTot7:=SUBSTR(cIdRoba,nPP7,nDS7)
 ENDIF
 cIdRoba:=LEFT(idroba,gnDS)
 nUkIznos:=0
 nOpor:=nNeOpor:=0
 cNRobe:=Ocitaj(F_ROBA,PADR(cidroba,LEN(idroba)),"TRIM(naz)")
 DO WHILE !EOF() .and. LEFT(idroba,gnDS)==cIdRoba
   nIznos := ROUND( kolicina*cijena*PrerCij()*(1-rabat/100)*(1+porez/100) , FIELD->zaokr )
   nUkIznos += nIznos
   SELECT ROBA; HSEEK PADR(LEFT(FAKT->idroba,gnDS),LEN(id))
   SELECT TARIFA; HSEEK ROBA->idtarifa; SELECT FAKT
   IF TARIFA->opp=0 .and. TARIFA->ppp=0 .and. TARIFA->zpp=0
     nNeOpor += nIznos
   ELSE
     nOpor   += nIznos
   ENDIF
   SKIP 1
 ENDDO
 SKIP -1
RETURN .t.
*}


/*! \fn FSvaki7()
 */
 
function FSvaki7()
*{
RETURN
*}



/*! \fn SubTot7()
 *  \brief
 */
 
function SubTot7()
*{
LOCAL aVrati:={.f.,""}, cIzd:="", cIdIzd:=""
  IF lSubTot7 .or. EOF()
    cIdIzd := IF(EOF(),SUBSTR(cIdRoba,nPP7,nDS7),cSubTot7)
    cIzd := IzFMKINI("NOVINE","NazivIzdavaca"+cIdIzd,"-",KUMPATH)
    aVrati := { .t. , "IZDAVAC "+cIdIzd+"-"+cIzd }
    lSubTot7:=.f.
  ENDIF
RETURN aVrati
*}


/*! \fn PorPoOps()
 *  \brief Porezi po tarifama i po opstinama
 */

function PorPoOps()
*{
O_SIFK; O_SIFV
  O_ROBA
  O_TARIFA
  O_RJ
  O_PARTN
  O_FAKT

  cTMPFAKT:=""

  cIdfirma:=gFirma
  qqRoba:=""
  dDatOd:=ctod("")
  dDatDo:=date()
  qqTipdok:="  "

  O_PARAMS
  private cSection:="5",cHistory:=" "; aHistory:={}
  Params1()
  RPar("c1",@cIdFirma); RPar("c2",@qqRoba)
  RPar("c8",@qqTipDok)
  RPar("d1",@dDatOd) ; RPar("d2",@dDatDo)
  qqRoba:=PADR(qqRoba,80)

  Box(,5,75)
  DO WHILE .t.
   if gNW$"DR"
     @ m_x+1,m_y+2 SAY "RJ (prazno svi) " GET cIdFirma valid {|| empty(cIdFirma) .or. cidfirma==gFirma .or. P_RJ(@cIdFirma) }
   else
     @ m_x+1,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
   endif
   @ m_x+2,m_y+2 SAY "Roba   "  GET qqRoba   pict "@!S40"
   @ m_x+4,m_y+2 SAY "Tip dokumenta (prazno - svi)"  GET qqTipdok
   @ m_x+5,m_y+2 SAY "Od datuma "  get dDatOd
   @ m_x+5,col()+1 SAY "do"  get dDatDo
   READ; ESC_BCR
   aUsl1:=Parsiraj(qqRoba,"IDROBA")
   IF aUsl1<>NIL; EXIT; ENDIF
  ENDDO
  BoxC()

  select params
  qqRoba:=trim(qqRoba)
  WPar("c1",cIdFirma); WPar("c2",qqRoba)
  WPar("c8",qqTipDok)
  WPar("d1",dDatOd); WPar("d2",dDatDo)
  use

  fSMark:=.f.
  if right(qqRoba,1)="*"
    // izvrsena je markacija robe ..
    fSMark:=.t.
  endif

  SELECT FAKT

  cSort1 := "idpartner"
  cFilt1 := aUsl1
  if !empty(dDatOd) .or. !empty(dDatDo)
    cFilt1 += ".and. DatDok>="+cm2str(dDatOd)+".and. DatDok<="+cm2str(dDatDo)
  endif
  IF !EMPTY(qqTipDok)
    cFilt1 += ".and. IDTIPDOK=="+cm2str(qqTipDok)
  ENDIF
  IF !EMPTY(cIdFirma)
    cFilt1 += ".and. IDFIRMA=="+cm2str(cIdFirma)
  ENDIF

  INDEX ON &cSort1 TO (cTMPFAKT:=TMPFAKT()) FOR &cFilt1

  // kreiranje pomocne izvjestajne baze
  // ----------------------------------
  aDbf:={  { "OPS"   ,"C" , 10 , 0 },;
           { "POR"   ,"C" , 10 , 0 },;
           { "PPP"   ,"N" , 17 , 8 },;
           { "PPU"   ,"N" , 17 , 8 },;
           { "PP"    ,"N" , 17 , 8 },;
           { "IZNOS" ,"N" , 17 , 8 } ;
          }
  dbcreate2(PRIVPATH+"por",aDbf)
  O_POR   // select 95
  index  on BRISANO TAG "BRISAN"
  index  on OPS+POR  TAG "1" ;  set order to tag "1"
  SELECT FAKT
  GO TOP
  DO WHILE !EOF()
    IF fSMark .and. SkLoNMark("ROBA",SiSiRo()) // skip+loop gdje je roba->_M1_ != "*"
      SKIP 1; LOOP
    ENDIF
    aPor := {}
    cOps := SUBSTR(idpartner,2,2)
    DO WHILE !EOF() .and. cOps==SUBSTR(idpartner,2,2)
      IF fSMark .and. SkLoNMark("ROBA",SiSiRo()) // skip+loop gdje je roba->_M1_ != "*"
        SKIP 1; LOOP
      ENDIF
      SELECT ROBA; HSEEK PADR(LEFT(FAKT->idroba,gnDS),LEN(id))
      SELECT TARIFA; HSEEK ROBA->idtarifa; SELECT FAKT

      IF IzFMKINI("POREZI","PPUgostKaoPPU","D")=="D"
        n0 := (cijena*Koef(DinDem)*kolicina)/(1+tarifa->zpp/100+tarifa->ppp/100)/(1+tarifa->opp/100)
        n1 := n0*tarifa->opp/100
        n2 := n0*(1+tarifa->opp/100)*tarifa->ppp/100
        n3 := n0*(1+tarifa->opp/100)*tarifa->zpp/100
      ELSE
        n0 := (cijena*Koef(DinDem)*kolicina)/((1+tarifa->opp/100)*(1+tarifa->ppp/100)+tarifa->zpp/100)
        n1 := n0*tarifa->opp/100
        n2 := n0*(1+tarifa->opp/100)*tarifa->ppp/100
        n3 := n0*tarifa->zpp/100
      ENDIF

      IF LEN(aPor)<1
        AADD(aPor, {TARIFA->id,kolicina*cijena,n1,n2,n3} )
      ELSE
        nPom:=ASCAN(aPor,{|x| x[1]==TARIFA->id})
        IF nPom>0
          aPor[nPom,2] += kolicina*cijena
          aPor[nPom,3] += n1
          aPor[nPom,4] += n2
          aPor[nPom,5] += n3
        ELSE
          AADD(aPor, {TARIFA->id,kolicina*cijena,n1,n2,n3} )
        ENDIF
      ENDIF
      SKIP 1
    ENDDO
    SELECT POR
    nU1:=0
    nU2:=0
    nU3:=0
    nU4:=0
    FOR i:=1 TO LEN(aPor)
      nU1 += aPor[i,2]
      nU2 += aPor[i,3]
      nU3 += aPor[i,4]
      nU4 += aPor[i,5]
      APPEND BLANK
      REPLACE ops WITH cOps, por WITH aPor[i,1], iznos WITH aPor[i,2],;
              ppp WITH aPor[i,3], ppu WITH aPor[i,4], pp  WITH aPor[i,5]
      HSEEK "UKUPNO  T."+aPor[i,1]
      IF FOUND()
        REPLACE iznos WITH iznos+aPor[i,2],;
                ppp   WITH ppp+aPor[i,3],;
                ppu   WITH ppu+aPor[i,4],;
                pp    WITH pp+aPor[i,5]
      ELSE
        APPEND BLANK
        REPLACE ops WITH "UKUPNO  T.", por WITH aPor[i,1], iznos WITH aPor[i,2],;
              ppp WITH aPor[i,3], ppu WITH aPor[i,4], pp  WITH aPor[i,5]
      ENDIF
    NEXT
    APPEND BLANK
    REPLACE ops   WITH cOps,;
            por   WITH "ƒUKUPNO",;
            iznos WITH nU1 ,;
            ppp   WITH nU2 ,;
            ppu   WITH nU3 ,;
            pp    WITH nU4
    HSEEK "UKUPNO SVE"
    IF FOUND()
      REPLACE iznos WITH iznos + nU1 ,;
              ppp   WITH ppp   + nU2 ,;
              ppu   WITH ppu   + nU3 ,;
              pp    WITH pp    + nU4
    ELSE
      APPEND BLANK
      REPLACE ops   WITH "UKUPNO SVE",;
              por   WITH "",;
              iznos WITH nU1 ,;
              ppp   WITH nU2 ,;
              ppu   WITH nU3 ,;
              pp    WITH nU4
    ENDIF
    SELECT FAKT
  ENDDO
  // -----------------------------------------------

  SELECT POR
  GO TOP

  START PRINT CRET

  PRIVATE cIdPartner:="", cNPartnera:="", nUkIznos:=0
  gOstr:="D"
  nOpor:=nNeOpor:=0

aKol:={ { "OPSTINA"      , {|| ops                 }, .f., "C",10, 0, 1, 1},;
        { "TARIFA"       , {|| por                 }, .f., "C",10, 0, 1, 2},;
        { "PPP"          , {|| STR(ppp,13,2)       }, .f., "C",13, 0, 1, 3},;
        { "PPU"          , {|| STR(ppu,13,2)       }, .f., "C",13, 0, 1, 4},;
        { "PP"           , {|| STR(pp ,13,2)       }, .f., "C",13, 0, 1, 5},;
        { "MPV"          , {|| STR(iznos,13,2)     }, .f., "C",13, 0, 1, 6} }

  ?? space(gnLMarg); ?? "FAKT: Izvjestaj na dan",date()
  ? space(gnLMarg); IspisFirme("")
  ? space(gnLMarg); ?? "RJ: " + IF( EMPTY(cIdFirma) , "SVE" , cIdFirma )

  SELECT POR

  StampaTabele(aKol,{|| FSvaki8()},,gTabela,,;
       ,"Porezi po tarifama i opstinama za period od "+DTOC(ddatod)+" do "+DTOC(ddatdo),;
                               {|| FFor8()},IF(gOstr=="D",,-1),,,,,)

  END PRINT
CLOSE ALL; MyFERASE(cTMPFAKT)
CLOSERET
return
*}


/*! \fn FFor8()
 */

function FFor8()
*{
RETURN .t.
*}


/*! \fn FSvaki8()
 *  \brief
 */

function FSvaki8()
*{
IF por="ƒUKUPNO"
    RETURN "PODVUCI="
  ENDIF
  SKIP 1
  IF por="ƒUKUPNO".or.ops="UKUPNO SVE"
    SKIP -1
    RETURN "PODVUCI "
  ELSE
    SKIP -1
  ENDIF
RETURN (NIL)
*}


/*! \fn SiSiRo()
 *  \brief Sirina sifre robe
 *  \brief specificno za opresu - novine
 */

function SiSiRo()
*{
LOCAL cSR:=FAKT->idroba
  IF gNovine=="D"
    cSR := PADR(LEFT(cSR,gnDS),LEN(cSR))
  ENDIF
RETURN cSR
*}



/*! \fn KarticaKons()
 *  \brief Kartica konsignacije
 */
 
function KarticaKons()
*{
local cidfirma,nRezerv,nRevers
local nul,nizl,nRbr,nCol1:=0,cKolona,cBrza:="N"
local lpickol:="@Z "+pickol

private m:=""

O_SIFK; O_SIFV
O_PARTN; O_ROBA
O_SIFK; O_SIFV
O_TARIFA; O_RJ
O_DOKS; O_FAKT
if fId_J
  set order to tag "3J" // idroba_J+Idroba+dtos(datDok)
else
  set order to 3 // idroba+dtos(datDok)
endif

cIdfirma:=gFirma
PRIVATE qqRoba:=""
PRIVATE dDatOd:=ctod("")
PRIVATE dDatDo:=date()
private qqPartn:=space(60)

Box("#KARTICA ISPORUCENE KONSIGNACIONE ROBE",17,60)

cOstran := IzFMKINI("FAKT","OstraniciKarticu","N",SIFPATH)

O_PARAMS
private cSection:="5",cHistory:=" "; aHistory:={}
Params1()
RPar("c1",@cIdFirma)
RPar("c9",@qqPartn)
RPar("d1",@dDatOd)
RPar("d2",@dDatDo)

qqPartn:=PADR(qqPartn,60)

private cTipVPC:="1"

private ck1:=cK2:=space(4)   // atributi

do while .t.
 @ m_x+1,m_y+2 SAY "Brza kartica (D/N)" GET cBrza pict "@!" valid cBrza $ "DN"
 read
 if gNW$"DR"
   @ m_x+2,m_y+2 SAY "RJ (prazno svi) " GET cIdFirma valid {|| empty(cIdFirma) .or. cidfirma==gFirma .or.P_RJ(@cIdFirma) }
 else
   @ m_x+2,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 endif

if cBrza=="D"
 RPar("c3",@qqRoba)
 qqRoba:=padr(qqRoba,10)
 if fID_J
   @ m_x+3,m_y+2 SAY "Roba " GET qqRoba pict "@!" valid {|| P_Roba(@qqRoba), qqRoba:=roba->id_j, .t.}
 else
   @ m_x+3,m_y+2 SAY "Roba " GET qqRoba pict "@!" valid P_Roba(@qqRoba)
 endif
else
 RPar("c2",@qqRoba)
 qqRoba:=padr(qqRoba,60)
 @ m_x+3,m_y+2 SAY "Roba " GET qqRoba pict "@!S40"
endif

@ m_x+4,m_y+2 SAY "Od datuma "  get dDatOd
@ m_x+4,col()+1 SAY "do"  get dDatDo
if gVarC $ "12"
 @ m_x+7,m_y+2 SAY "Stanje prikazati sa Cijenom 1/2 (1/2) "  get cTipVpc pict "@!" valid cTipVPC $ "12"
endif
@ m_x+8,m_y+2 SAY "Partneri kupci (prazno - svi)"  GET qqPartn   pict "@!S20"
if fakt->(fieldpos("K1"))<>0 .and. gDK1=="D"
  @ m_x+ 9,m_y+2 SAY "K1" GET  cK1 pict "@!"
  @ m_x+10,m_y+2 SAY "K2" GET  cK2 pict "@!"
endif

if cBrza=="N"
  @ m_x+15,m_y+2 SAY "Svaka kartica na novu stranicu? (D/N)"  get cOstran VALID cOstran$"DN" PICT "@!"
else
  cOstran:="N"
endif

read; ESC_BCR

aUsl2:=Parsiraj(qqPartn,"IdPartner")

if fID_J .and. cBrza=="D"
  qqRoba:=roba->(ID_J+ID)
endif

cSintetika:=IzFmkIni("FAKT","Sintet","N")
IF cSintetika=="D" .and.  IF(cBrza=="D",ROBA->tip=="S",.t.)
  @ m_x+17,m_y+2 SAY "Sinteticki prikaz? (D/N) " GET  cSintetika pict "@!" valid cSintetika $ "DN"
ELSE
  cSintetika:="N"
ENDIF
read; ESC_BCR

 if cBrza=="N"
   if fID_J
    aUsl1:=Parsiraj(qqRoba,"IdRoba_J")
   else
    aUsl1:=Parsiraj(qqRoba,"IdRoba")
   endif
 endif
 if IF(cBrza=="N",aUsl1<>NIL,.t.) .and. aUsl2<>NIL
   exit
 endif
enddo
m:="---- ------------------ -------- ------ "+replicate("-",20)+;
   " ----------- ----------- ----------- ----------- ----- -----------"
Params2()
qqPartn:=TRIM(qqPartn)
WPar("c1",cIdFirma)
WPar("c9",qqPartn); WPar("d1",dDatOd); WPar("d2",dDatDo)
qqRoba:=TRIM(qqRoba)
IF cBrza=="D"
 WPar("c3",qqRoba)
ELSE
 WPar("c2",qqRoba)
ENDIF
select params; use

BoxC()

fSMark:=.f.
if right(qqRoba,1)="*"
  // izvrsena je markacija robe ..
  fSMark:=.t.
endif

O_DOKS  // otvori datoteku dokumenata

select FAKT

PRIVATE cFilt1:=""
cFilt1 := IF(cBrza=="N",aUsl1,".t.")+IF(EMPTY(dDatOd),"",".and.DATDOK>="+cm2str(dDatOd))+;
                IF(EMPTY(dDatDo),"",".and.DATDOK<="+cm2str(dDatDo))+".and. IDTIPDOK='1'"+;
                ".and. left(serbr,1)<>'*'"

IF !EMPTY(cIdFirma)
  cFilt1 += ( ".and. IDFIRMA=="+cm2str(cIdFirma) )
ENDIF
IF !EMPTY(qqPartn)
  cFilt1 += ( ".and."+aUsl2 )
ENDIF

cFilt1 := STRTRAN(cFilt1,".t..and.","")
IF !(cFilt1==".t.")
  SET FILTER TO &cFilt1
ELSE
  SET FILTER TO
ENDIF

IF cBrza=="N"
 go top
 EOF CRET
ELSE
 seek qqRoba
ENDIF

START PRINT CRET
P_12CPI
?? space(gnLMarg); ?? "FAKT: Kartica isporuke robe na dan",date(),"      za period od",dDatOd,"-",dDatDo
? space(gnLMarg); IspisFirme(cidfirma)
if !empty(qqRoba)
 ? space(gnLMarg)
 if !empty(qqRoba) .and. cBrza="N"
   ?? "Uslov za artikal:",qqRoba
 endif
endif
?
if cTipVPC=="2" .and.  roba->(fieldpos("vpc2")<>0)
  ? space(gnlmarg); ?? "U CJENOVNIKU SU PRIKAZANE CIJENE: "+cTipVPC
endif
if !empty(cK1)
  ?
  ? space(gnlmarg),"- Roba sa osobinom K1:",ck1
endif
if !empty(cK2)
  ?
  ? space(gnlmarg),"- Roba sa osobinom K2:",ck2
endif

_cijena:=0
_cijena2:=0
nRezerv:=nRevers:=0

qqPartn:=trim(qqPartn)
if !empty(qqPartn)
  ?
  ? space(gnlmarg),"- Prikaz za partnere obuhvacene sljedecim uslovom (sifre):"
  ? space(gnlmarg)," ",qqPartn
  ?
endif

P_COND

nStrana := 1
lPrviProlaz:=.t.
 
do while !eof()
  if cBrza=="D"
    if qqRoba<>iif(fID_j,IdRoba_J+IdRoba,IdRoba) .and.;
       IF(cSintetika=="D",LEFT(qqRoba,gnDS)!=LEFT(IdRoba,gnDS),.t.)
      // tekuci slog nije zeljena kartica
      exit
    endif
  endif
  if fId_j
   cIdRoba:=IdRoba_J+IdRoba
  else
   cIdRoba:=IdRoba
  endif
  nUl:=nIzl:=nIznos:=0
  nRezerv:=nRevers:=0
  nRbr:=0
  nIzn:=0

  if fId_j
   NSRNPIdRoba(substr(cIdRoba,11), cSintetika=="D")
  else
   NSRNPIdRoba(cIdRoba, cSintetika=="D" )
  endif
  select FAKT

  if fSMark .and. SkLoNMark("ROBA",SiSiRo()) // skip & loop gdje je roba->_M1_ != "*"
    skip; loop
  endif

  if cTipVPC=="2" .and. roba->(fieldpos("vpc2")<>0)
    _cijena := roba->vpc2
  else
    _cijena := if ( !EMPTY(cIdFirma) , UzmiMPCSif() , roba->vpc )
  endif

  if gVarC=="4" // uporedo vidi i mpc
    _cijena2 := roba->mpc
  endif

  if prow()-gPStranica>50; FF; ++nStrana; endif

  ZagKartKons(lPrviProlaz)
  lPrviProlaz:=.f.

  // GLAVNA DO-WHILE
  aUkKol:={}
  do while !eof() .and. IF(cSintetika=="D".and.ROBA->tip=="S",;
                           LEFT(cIdRoba,gnDS)==LEFT(IdRoba,gnDS),;
                           cIdRoba==iif(fID_J,IdRoba_J+IdRoba,IdRoba))
    cKolona:="N"

    if !empty(cidfirma); if idfirma<>cidfirma; skip; loop; end; end
    if !empty(cK1); if ck1<>K1 ; skip; loop; end; end // uslov ck1
    if !empty(cK2); if ck2<>K2; skip; loop; end; end // uslov ck2

    // if !empty(qqPartn)
    //   select doks; hseek fakt->(IdFirma+idtipdok+brdok)
    //   select fakt; if !(doks->partner=qqPartn); skip; loop; endif
    // endif

    if !empty(cIdRoba)
     if !(left(serbr,1)=="*" .and. idtipdok=="10")  // za fakture na osnovu otpremnice ne racunaj izlaz
       nIzl+=kolicina
       nIznos += kolicina*cijena*(1-Rabat/100)
       cKolona:="I"
     endif

     if cKolona!="N"

      if prow()-gPStranica>55; FF; ++nStrana; ZagKartKons(); endif

      ? space(gnLMarg); ?? str(++nRbr,3)+".   "+idfirma+"-"+idtipdok+"-"+brdok+left(serbr,1)+"  "+DTOC(datdok)

      select doks; hseek fakt->(IdFirma+idtipdok+brdok); select fakt
      @ prow(),pcol()+1 SAY doks->idPartner
      @ prow(),pcol()+1 SAY padr(doks->Partner,20)

      @ prow(),pcol()+1 SAY kolicina pict lpickol

      IF LEN(aUkKol)<1 .or.;
         ( nPK := ASCAN(aUkKol,{|x| ROUND(x[1],4)==ROUND(cijena,4)}) ) <=0
        AADD(aUkKol,{cijena,kolicina})
      ELSE
        aUkKol[nPK,2] += kolicina
      ENDIF

      @ prow(),pcol()+1 SAY ROBA->nc pict picdem
      @ prow(),pcol()+1 SAY _cijena pict picdem
      @ prow(),pcol()+1 SAY Cijena pict picdem
      @ prow(),pcol()+1 SAY Rabat  pict "99.99"
      @ prow(),pcol()+1 SAY kolicina*Cijena*(1-Rabat/100) pict picdem
     endif

     if fieldpos("k1")<>0  .and. gDK1=="D"
       @ prow(),pcol()+1 SAY k1
     endif
     if fieldpos("k2")<>0  .and. gDK2=="D"
       @ prow(),pcol()+1 SAY k2
     endif

     if roba->tip="U"
       aMemo:=ParsMemo(txt)
       aTxtR:=SjeciStr(aMemo[1],60)   // duzina naziva + serijski broj
       for ui=1 to len(aTxtR)
         ? space(gNLMarg)
         @ prow(),pcol()+7 SAY aTxtR[ui]
       next
     endif

    endif

    skip
  enddo
  // GLAVNA DO-WHILE

  if prow()-gPStranica>55; FF; ++nStrana; ZagKartKons(); endif

  ? space(gnLMarg); ?? m
  ? space(gnLMarg)+PADL("UKUPNO IZNOS: ",115)+TRANS(nIznos,picdem)
  ? space(gnLMarg); ?? m
  FOR i:=1 TO LEN(aUkKol)
    ? space(gnLMarg)
    ?? PADL("UKUPNO KOLICINE PO CIJENAMA",60),TRANS(aUkKol[i,2],lPicKol)
    ?? SPACE(24),TRANS(aUkKol[i,1],picdem)
  NEXT
  ? space(gnLMarg); ?? m
  ?
  if cOstran=="D"    // kraj kartice => zavrsavam stranicu
    FF; ++nStrana
  endif
enddo

if cOstran!="D"
  FF
endif

END PRINT
closeret
return
*}


/*! \fn ZagKartKons(lIniStrana)
 *  \brief Zaglavlje kartice konsignacije
 */
 
static function ZagKartKons(lIniStrana)
*{

*static integer
static nZStrana:=0
*;

IF lIniStrana=NIL; lIniStrana:=.f.; ENDIF
  IF lIniStrana; nZStrana:=0; ENDIF
  B_ON
  IF nStrana>nZStrana
    ?? SPACE(66)+"Strana: "+ALLTRIM(STR(nStrana))
  ENDIF
  ?
  ? space(gnLMarg); ?? m
  ? space(gnLMarg); ?? "SIFRA:"
  if fID_J
   ?? IF(cSintetika=="D".and.ROBA->tip=="S",ROBA->ID_J,left(cidroba,10)),PADR(ROBA->naz,40)
  else
   ?? IF(cSintetika=="D".and.ROBA->tip=="S",ROBA->id,cidroba),PADR(ROBA->naz,40)
  endif
  ? space(gnLMarg); ?? m
  B_OFF
  ? space(gnLMarg)
  ?? "R.br  RJ Br.dokumenta   Dat.dok. "
  ?? " Sifra "
  ?? padc("i naziv partnera",21)
  ?? "  Kolicina  "+PADC("NC(sifr.)",12)+PADC("VPC(sifr.)",12)+"  Cijena    Rab%     Iznos  "

  ? space(gnLMarg); ?? m
  nZStrana=nStrana
return
*}


/*! \fn Oporezovana(cIdTarifa)
 *  \brief 
 */
 
function Oporezovana(cIdTarifa)
*{
LOCAL nArr
 IF cIdTarifa<>NIL
   nArr:=SELECT()
   SELECT TARIFA; HSEEK cIdTarifa
   SELECT (nArr)
 ENDIF
return (TARIFA->opp<>0 .or. TARIFA->ppp<>0 .or. TARIFA->zpp<>0)
*}


/*! \fn TekRac2()
 *  \brief
 */
 
function TekRec2()
*{
nSlog++
 @ m_x+1, m_y+2 SAY PADC(ALLTRIM(STR(nSlog))+"/"+ALLTRIM(STR(nUkupno)),20)
 @ m_x+2, m_y+2 SAY "Obuhvaceno: "+STR(cmxKeysIncluded())
return (nil)
*}



/*! \fn SortFakt(cId,cSort)
 *  \brief Sortiranje faktura
 *  \param cId
 *  \param cSort
 */
 
function SortFakt(cId,cSort)
*{
LOCAL cVrati:="", nArr:=SELECT()
 SELECT ROBA
 HSEEK cId
 DO CASE
   CASE cSort=="N"
     cVrati := BHSORT(naz)+id
   CASE cSort=="T"
     cVrati := BHSORT(idtarifa)+id
   CASE cSort=="J"
     cVrati := BHSORT(jmj)+id
 ENDCASE
 SELECT (nArr)
RETURN cVrati
*}


/*! \fn BhSort(cInput)
 *  \brief
 */
 
function BhSort(cInput)
*{
IF gKodnaS=="7"
   cInput:=STRTRAN(cInput,"[","S"+CHR(255))
   cInput:=STRTRAN(cInput,"\","D"+CHR(255))
   cInput:=STRTRAN(cInput,"^","C"+CHR(254))
   cInput:=STRTRAN(cInput,"]","C"+CHR(255))
   cInput:=STRTRAN(cInput,"@","Z"+CHR(255))
   cInput:=STRTRAN(cInput,"{","s"+CHR(255))
   cInput:=STRTRAN(cInput,"|","d"+CHR(255))
   cInput:=STRTRAN(cInput,"~","c"+CHR(254))
   cInput:=STRTRAN(cInput,"}","c"+CHR(255))
   cInput:=STRTRAN(cInput,"`","z"+CHR(255))
 ELSE  // "8"
   cInput:=STRTRAN(cInput,"Ê","S"+CHR(255))
   cInput:=STRTRAN(cInput,"—","D"+CHR(255))
   cInput:=STRTRAN(cInput,"¨","C"+CHR(254))
   cInput:=STRTRAN(cInput,"è","C"+CHR(255))
   cInput:=STRTRAN(cInput,"¶","Z"+CHR(255))
   cInput:=STRTRAN(cInput,"Á","s"+CHR(255))
   cInput:=STRTRAN(cInput,"–","d"+CHR(255))
   cInput:=STRTRAN(cInput,"ü","c"+CHR(254))
   cInput:=STRTRAN(cInput,"Ü","c"+CHR(255))
   cInput:=STRTRAN(cInput,"ß","z"+CHR(255))
 ENDIF
RETURN PADR(cInput,100)
*}

/*! \fn TmpFakt()
 *  \brief
 */
 
function TmpFakt()
*{
RETURN TEMPFILE(KUMPATH,"CDX",0)
*}


/*! \fn MyFErase()
 *  \brief
 */
 
function MyFErase()
*{
PARAMETERS cFajl
  IF !(cFajl==NIL .or. "U" $ TYPE("cFajl") )
    FERASE(cFajl)
  ENDIF
RETURN
*}

