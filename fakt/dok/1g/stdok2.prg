#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/dok/1g/stdok2.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.18 $
 * $Log: stdok2.prg,v $
 * Revision 1.18  2003/12/04 11:11:43  sasavranic
 * Uvedena konverzija i za varijantu "2" fakture
 *
 * Revision 1.17  2003/10/02 09:08:29  sasavranic
 * no message
 *
 * Revision 1.16  2003/09/08 13:18:14  mirsad
 * sitne dorade za Hano - radni nalozi
 *
 * Revision 1.15  2003/08/06 17:44:49  mirsad
 * dorada za Tvin, varijanta faktura 2/2, prikaz iznosa poreza za svaku stavku
 *
 * Revision 1.14  2003/07/11 06:43:26  sasa
 * trebovanje kada je popunjeno polje radnog naloga
 *
 * Revision 1.13  2003/07/11 06:29:15  sasa
 * trebovanje kada je popunjeno polje radnog naloga
 *
 * Revision 1.12  2003/05/23 13:08:10  ernad
 * haaktrans rtm faktura
 *
 * Revision 1.11  2003/05/20 09:14:37  ernad
 * - RTM faktura za tip dokumenta 11
 *
 * Revision 1.10  2003/05/14 15:25:14  sasa
 * ispravka buga sa stampom kroz delphirb ako je podesen parametar 10Duplo=D
 *
 * Revision 1.9  2003/05/10 18:57:58  ernad
 * dodat opis za artikle u dokumentu
 *
 * Revision 1.8  2003/05/10 15:07:57  mirsad
 * dodatna polja za robne karakteristike u kumulativnoj bazi C1,C2,C3,N1,N2
 *
 * Revision 1.7  2003/03/28 15:38:10  mirsad
 * 1) ispravka bug-a pri gen.fakt.na osnovu otpremnica: sada se korektno setuje datum u svim stavkama
 * 2) ukinuo setovanje u proizvj.ini parametra "Broj" jer opet smeta (zbog njega se u reg.broj upisuje broj fakture)
 *
 * Revision 1.6  2003/03/26 14:55:11  mirsad
 * umjesto "Reg.br." i "Por.br." svuda stavljen ispis "Ident.br."
 *
 * Revision 1.5  2002/09/14 12:04:47  mirsad
 * dokumentovanje INI parametara
 *
 * Revision 1.4  2002/09/14 09:24:19  mirsad
 * dokumentovanje INI parametara
 *
 * Revision 1.3  2002/07/04 08:34:19  mirsad
 * dokumentovanje ini parametara
 *
 * Revision 1.2  2002/06/18 13:01:05  sasa
 * no message
 *
 * Revision 1.1.1.1  2002/06/17 18:30:18  ernad
 * no message
 *
 *
 */

/*! \file fmk/fakt/dok/1g/stdok2.prg
 *  \brief Stampa fakture u varijanti 2
 */


/*! \ingroup ini
  * \var *string FmkIni_ExePath_FAKT_KrozDelphi
  * \brief Da li se dokumenti stampaju kroz Delphi RB ?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_ExePath_FAKT_KrozDelphi;


/*! \ingroup ini
  * \var *string FmkIni_SifPath_SifRoba_PBarkod
  * \brief Da li se mogu ispisivati bar-kodovi u dokumentima ?
  * \param 0 - ne, default vrijednost
  * \param 1 - da, na upit "Zelite li ispis bar-kodova?" ponudjen je odgovor "N"
  * \param 2 - da, na upit "Zelite li ispis bar-kodova?" ponudjen je odgovor "D"
  */
*string FmkIni_SifPath_SifRoba_PBarkod;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_FAKT_NazRTM
  * \brief Naziv RTM fajla koji se koristi za stampu dokumenta kroz Delphi RB
  * \param fakt1 - default vrijednost
  */
*string FmkIni_ExePath_FAKT_NazRTM;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_FAKT_NazRTMFax
  * \brief Naziv RTM fajla koji se koristi za stampu dokumenta za slanje faksom
  * \param fax1 - default vrijednost
  */
*string FmkIni_ExePath_FAKT_NazRTMFax;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_FAKT_StampaWin2000
  * \brief Da li je operativni sistem Windows 2000 ?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_ExePath_FAKT_StampaWin2000;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_FAKT_PozivDelphiRB
  * \brief Komanda za poziv Delphi RB-a za operativni sistem Windows 2000 
  * \param DelphiRB - default vrijednost
  */
*string FmkIni_ExePath_FAKT_PozivDelphiRB;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_FAKT_10Duplo
  * \brief Da li se koristi dupli prored fakture ako faktura ima do 10 stavki?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_ExePath_FAKT_10Duplo;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_FAKT_StampaViseDokumenata
  * \brief Da li se moze stampati vise od jednog dokumenta u pripremi ?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_ExePath_FAKT_StampaViseDokumenata;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_Zaglavlje_Linija1
  * \brief 1.red zaglavlja dokumenta pri stampanju kroz Delphi RB
  * \param gNFirma - default vrijednost
  */
*string FmkIni_KumPath_Zaglavlje_Linija1;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_Zaglavlje_Linija2
  * \brief 2.red zaglavlja dokumenta pri stampanju kroz Delphi RB
  * \param - - nije definisano, default vrijednost
  */
*string FmkIni_KumPath_Zaglavlje_Linija2;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_Zaglavlje_Linija3
  * \brief 3.red zaglavlja dokumenta pri stampanju kroz Delphi RB
  * \param - - nije definisano, default vrijednost
  */
*string FmkIni_KumPath_Zaglavlje_Linija3;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_Zaglavlje_Linija4
  * \brief 4.red zaglavlja dokumenta pri stampanju kroz Delphi RB
  * \param - - nije definisano, default vrijednost
  */
*string FmkIni_KumPath_Zaglavlje_Linija4;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_Zaglavlje_Linija5
  * \brief 5.red zaglavlja dokumenta pri stampanju kroz Delphi RB
  * \param - - nije definisano, default vrijednost
  */
*string FmkIni_KumPath_Zaglavlje_Linija5;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_CekanjeNaSljedeciPozivDRB
  * \brief Broj sekundi cekanja na provjeru da li je Delphi RB zavrsio posljednji zadani posao 
  * \param 6 - default vrijednost
  */
*string FmkIni_KumPath_FAKT_CekanjeNaSljedeciPozivDRB;


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
  * \var *string FmkIni_SifPath_SifRoba_PDRazmak
  * \brief Ako se stampaju bar-kodovi u dokumentu, da li se pravi razmak izmedju stavki u dokumentu ?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_SifPath_SifRoba_PDRazmak;


/*! \ingroup ini
  * \var *string FmkIni_PrivPath_UpitFax_Slati
  * \brief Ako se stampa preko Delphi RB-a, da li se pravi dokument za slanje faksom ?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_PrivPath_UpitFax_Slati;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_DELPHIRB_Aktivan
  * \brief Indikator aktivnosti Delphi RB-a
  * \param 1 - aktivan
  * \param 0 - nije aktivan
  */
*string FmkIni_ExePath_DELPHIRB_Aktivan;


/*! \ingroup ini
  * \var *string FmkIni_SifPath_FAKT_Opcine
  * \brief Koristi li se sifrarnik opcina i sifra opcine u sifrarniku partnera?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_SifPath_FAKT_Opcine;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_KupacDesno
  * \brief Da li se podaci o kupcu ispisuju uz desnu marginu dokumenta ?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_KumPath_FAKT_KupacDesno;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_I19jeOtpremnica
  * \brief Da li se i dokument tipa 19 tretira kao otpremnica ?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_KumPath_FAKT_I19jeOtpremnica;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_PrikaziNaruciocaAkoJeRazlicitOdKupca
  * \brief Ako je narucilac razlicit od kupca, da li se stampa narucilac?
  * \param D - da, default vrijednost
  * \param N - ne
  */
*string FmkIni_KumPath_FAKT_PrikaziNaruciocaAkoJeRazlicitOdKupca;


/*! \ingroup ini
 *  \var *string FmkIni_ExePath_FAKT_DelphiRB
 *  \brief Da li ce se fakture stampati kroz DelphiRB ?
 *  \param D  - Prilikom poziva stampe dokumenti se stampaju kroz DelphiRB
 *  \param N  - Obicna stampa dokumenata
 *  \param P  - Pitanje prilikom poziva stampe DelphiRB ili obicni TXT
 */
*string FmkIni_ExePath_FAKT_DelphiRB;


/*! \fn StDok2()
 *  \brief Stampa fakture u varijanti 2
 *  \param cIdFirma
 *  \param cIdTipDok
 *  \param cBrDok
 */
 
function StDok2()
*{
parameters cIdFirma,cIdTipDok,cBrDok
private i,nCol1:=0,cTxt1,cTxt2,aMemo,nMPVBP:=nVPVBP:=0
private cpom,cpombk
private cTi,nUk,nRab,nUk2:=nRab2:=0

private nStrana:=0,nCTxtR:=10,nPorZaIspis:=0

IF "U" $ TYPE("lUgRab"); lUgRab:=.f.; ENDIF

if gAppSrv
   nH:=fcreate(PRIVPATH+"outf.txt")
   fwrite(nH,"-nepostojeci podaci-")
   fclose(nH)
endif

if pcount()==3
 O_Edit(.t.)
else
 O_Edit()
endif

fDelphiRB:=.f.
cIniName:=""

if (glRadNal .and. IzFmkIni('FAKT','Trebovanje','N',KUMPATH)=='D')
	lTrebovanje:=.t.
else
	lTrebovanje:=.f.
endif

if !gAppSrv .and. IzFmkIni('FAKT','DelphiRB','N')=='D'
  fDelphiRB:=.t.
  cIniName:=EXEPATH+'ProIzvj.ini'
endif

if !gAppSrv .and. IzFmkIni('FAKT','KrozDelphi','N')=='D'
  fDelphiRB:=.t.
  cIniName:=EXEPATH+'ProIzvj.ini'
endif


// fPBarkod - .t. stampati barkod, .f. ne stampati
private cPombk:=IzFmkIni("SifRoba","PBarkod","0",SIFPATH)
private fPBarkod:=.f.
if cPombk $ "12"  // pitanje, default "N"
   fPBarkod := ( Pitanje(,"Zelite li ispis barkodova ?",iif(cPombk=="1","N","D"))=="D")
endif

if fDelphiRb
  cRTM:=IzFmkIni('FAKT','NazRTM','fakt1')
  cRTMF:=IzFmkIni('FAKT','NazRTMFax','fax1')
  if IzFmkIni('FAKT','StampaWin2000','N',EXEPATH)=='D'
    cPoziv:=IzFmkIni('FAKT','PozivDelphiRB','DelphiRB',EXEPATH)
  endif
  if fPBarkod
     cRTM := ALLTRIM(cRTM) + "bk"
  endif
  if IzFmkIni('FAKT','10Duplo','N')=='D' .and. pripr->(reccount2())<=10
     // dupli prored fakture do deset stavki !!!
     cRTM := ALLTRIM(cRTM) + "dp"
  endif
endif

cTI:="1"  // tip izvjestaja  1,2
O_PARAMS
private cSection:="1",cHistory:=" "; aHistory:={}
RPar("c1",@cTI)
select params
use

select PRIPR
// za fakture maloprodaje dodaj "mp" kao nastavak na RTM filename
if fDelphiRb .and. (IdTipDok $ "11#27")
	cRTM := ALLTRIM(cRTM) + "mp"
endif
	
if pcount()==0  // poziva se faktura iz pripreme
 IF gNovine=="D" .or. (IzFMKINI('FAKT','StampaViseDokumenata','N')=="D")
   FilterPrNovine()
 ENDIF
 cIdTipdok:=idtipdok;cIdFirma:=IdFirma;cBrDok:=BrDok
endif
seek cidfirma+cidtipdok+cbrdok
NFOUND CRET

IF idtipdok=="01" .and. kolicina<0 .and. gPovDob$"DN"
  lPovDob := ( Pitanje(,"Stampati dokument povrata dobavljacu? (D/N)",gPovDob)=="D" )
ELSE
  lPovDob:=.f.
ENDIF

IF glDistrib .and. cIdTipDok $ "10#21"
  mamb := " -------"
ELSE
  mamb := ""
ENDIF

if gVarF=="1"
  private M:="------ ---------- ---------------------------------------- ---------- ----------- ---"+mamb+" ----------- ------ ---- -----------"
else

  if IsTvin()
	cPR:=" -------------------------------"
  	cP:=" --------"  // za iznos poreza
  else
	cPR:=" ----------------------------------------"
  	cP:=""
  endif

  if gRabProc=="D"
    private M:="------ ----------"+cPR+" ----------- ---"+mamb+" ----------- ------ ----------- ----"+cP+" -----------"
  else
    private M:="------ ----------"+cPR+" ----------- ---"+mamb+" ----------- ----------- ----"+cP+" -----------"
  endif

endif

aDbf:={ {"POR","C",10,0},;
          {"IZNOS","N",17,8} ;
         }
dbcreate2(PRIVPATH+"por",aDbf)
O_POR   // select 95
index  on BRISANO TAG "BRISAN"
index  on POR  TAG "1" 
set order to tag "1"
select pripr

cIdFirma:=IdFirma
cBrDok:=BRDok
dDatDok:=DatDok
cIdTipDok:=IdTipDok
cidpartner:=Idpartner

if fDelphiRB
  select partn
  seek cIdpartner
  if IzFmkIni("FAKT","Opcine","N",SIFPATH)=="D"
    //set relation to idops into ops
    cOpcina:=Idops
  endif
  select pripr
endif

if !fDelphiRB
  if cidtipdok=="19" .and. lPartic
    private m:="------ ---------- ---------------------------------------- ------- ------ ------- ----------- --- ----------- ----------------"
  elseif cidtipdok$"11#27"
    if IsTvin()
	cPR:=" ----------------------" //  -18 za naziv robe
	cP:=" --------" // za iznose poreza 2*9 = +18
    else
	cPR:=" ----------------------------------------"
	cP:=""
    endif
    private m:="------ ----------"+cPR+" ------- ------"+cP+" -------"+cP+" ----------- --- ----------- -----------"
  endif
endif

cTxt1:=""
cTxt2:=""
cTxt3a:=""
cTxt3b:=""
cTxt3c:=""

cRegBr:=cPorDjBr:=""
//pri pozivu DelphiRb-a uzima iz Sifk por. i reg. broj
RegPorBrGet(@cRegBr,@cPorDjBr)

if fDelphiRB
  if IzFmkIni("FAKT","Opcine","N",SIFPATH)=="D"
    cKanton:="K: " + cOpcina
  endif
endif

if val(podbr)=0  .and. val(rbr)==1
   aMemo:=ParsMemo(txt)
   if len(aMemo)>0
     cTxt1:=padr(aMemo[1],40)
   endif
   if len(aMemo)>=5
    IF lUgRab
      cTxt2:=UgRabTXT()
    ELSE
      cTxt2:=aMemo[2]
    ENDIF
    IF glDistrib
      cIDPM:=TRIM(IDPM)
      IF !EMPTY(cIDPM)
        cIDPM:="(Prod.mjesto: "+cIDPM+")"
      ENDIF
    ENDIF
    cTxt3a:=aMemo[3]
    cTxt3b:=aMemo[4]
    cTxt3c:=aMemo[5]
   endif
else
  Beep(2)
  Msg("Prva stavka mora biti  '1.'  ili '1 ' !",4)
  return
endif


if fDelphiRB
  _BrOtp:=space(8); _DatOtp:=ctod(""); _BrNar:=space(8); _DatPl:=ctod("")

  if val(podbr)=0  .and. val(rbr)==1
     aMemo:=ParsMemo(txt)
     if len(aMemo)>0
       cTxt1:=padr(aMemo[1],40)
     endif
     if len(aMemo)>=5
      IF lUgRab
        cTxt2:=UgRabTXT()
      ELSE
        cTxt2:=aMemo[2]
      ENDIF
      cTxt3a:=aMemo[3]
      cTxt3b:=aMemo[4]
      cTxt3c:=aMemo[5]
     endif
     if len(aMemo)>=9
      _BrOtp:=aMemo[6]; _DatOtp:=ctod(aMemo[7]); _BrNar:=amemo[8]; _DatPl:=ctod(aMemo[9])
     endif
  else
    Beep(2)
    Msg("Prva stavka mora biti  '1.'  ili '1 ' !",4)
    return
  endif

   UzmiIzIni(cIniName,'Varijable','BrOtp',_BrOtp,'WRITE')
   UzmiIzIni(cIniName,'Varijable','DatOtp',dtoc(_DatOtp),'WRITE')
   UzmiIzIni(cIniName,'Varijable','BrNar',_BrNar,'WRITE')
   UzmiIzIni(cIniName,'Varijable','DatPl',dtoc(_DatPl),'WRITE')
   UzmiIzIni(cIniName,'Varijable','Linija1',IzFmkIni("Zaglavlje","Linija1",gNFirma,KUMPATH),'WRITE')
   UzmiIzIni(cIniName,'Varijable','Linija2',IzFmkIni("Zaglavlje","Linija2","-",KUMPATH),'WRITE')
   UzmiIzIni(cIniName,'Varijable','Linija3',IzFmkIni("Zaglavlje","Linija3","-",KUMPATH),'WRITE')
   UzmiIzIni(cIniName,'Varijable','Linija4',IzFmkIni("Zaglavlje","Linija4","-",KUMPATH),'WRITE')
   UzmiIzIni(cIniName,'Varijable','Linija5',IzFmkIni("Zaglavlje","Linija5","-",KUMPATH),'WRITE')

endif


// duzina slobodnog teksta
nLTxt2:=1
for i:=1 to len(cTxt2)
  if substr(cTxt2,i,1)=chr(13)
   ++nLTxt2
  endif
next
if idtipdok $ "10#11"
	nLTxt2+=7
endif

if fDelphiRB
   aDBf:={}
   AADD(aDBf,{ 'RBR'                 , 'C' ,   4 ,  0 })
   AADD(aDBf,{ 'SIFRA'               , 'C' ,  10 ,  0 })
   AADD(aDBf,{ 'BARKOD'              , 'C' ,  13 ,  0 })
   if gDest
   AADD(aDBf,{ 'DEST'                , 'C' ,  20 ,  0 })
   endif
   AADD(aDBf,{ 'NAZIV'               , 'C' ,  200 ,  0 })
   AADD(aDBf,{ 'JMJ'                 , 'C' ,   3 ,  0 })
   AADD(aDBf,{ 'Cijena'              , 'C' ,  12 ,  0 })
   AADD(aDBf,{ 'KOLICINA'            , 'C' ,  12 ,  0 })
   AADD(aDBf,{ 'SERBR'               , 'C' ,  15 ,  0 })
   AADD(aDBf,{ 'POREZ1'              , 'C' ,  12 ,  0 })
   AADD(aDBf,{ 'POREZ2'              , 'C' ,  12 ,  0 })
   AADD(aDBf,{ 'POREZ3'              , 'C' ,  12 ,  0 })
   AADD(aDBf,{ 'RABAT'               , 'C' ,  12 ,  0 })
   AADD(aDBf,{ 'POR'                 , 'C' ,  12 ,  0 })
   AADD(aDBf,{ 'UKUPNO'              , 'C' ,  12 ,  0 })
   AADD(aDBf,{ 'CijenaMR'               , 'C' ,  12 ,  0 })  // cijena-rabat


   nSek0 := SECONDS()
   nSekW := VAL( IzFMKIni("FAKT","CekanjeNaSljedeciPozivDRB","6",KUMPATH) )
   DO WHILE FILE(PRIVPATH+"POM.DBF")
     FERASE(PRIVPATH+"POM.DBF")
     IF SECONDS()-nSek0 > nSekW
       IF Pitanje(,"Zauzet POM.DBF (112). Pokusati ponovo? (D/N)","D")=="D"
         nSek0 := SECONDS()
         LOOP
       ELSE
         goModul:quit()
       ENDIF
     ENDIF
   ENDDO

   dbcreate2(PRIVPATH+'POM.DBF',aDbf)
   select ( F_POM )
   usex (PRIVPATH+'POM')
   INDEX ON RBR  TAG "1"
   select pripr
else
 POCNI STAMPU
 P_10CPI
 StZaglav2(gVlZagl,PRIVPATH)
endif



cIdTipdok:=idtipdok
cBrDok:=brdok



StKupac(fDelphiRb)

if !fDelphiRB
 	for i:=1 to gOdvT2
 		?
	next
 	IF glDistrib .and. cIdTipDok $ "10#21"
   		DiVoRel()
 	ENDIF
 	Zagl2()
endif

nUk:=0
nRab:=0
nZaokr:=ZAOKRUZENJE
cDinDEM:=dindem

do while idfirma==cidfirma .and. idtipdok==cidtipdok .and. brdok==cbrdok .and. !eof()

   NSRNPIdRoba()   // Nastimaj (hseek) Sifr.Robe Na Pripr->IdRoba

   if alltrim(podbr)=="."   .or. roba->tip="U"
      aMemo:=ParsMemo(txt)
      cTxt1:=padr(aMemo[1],40)
   endif
   if roba->tip="U"
      cTxtR:=aMemo[1]
   endif

   if alltrim(podbr)=="."
    if prow()>gERedova+48-nLTxt2  // prelaz na sljedecu stranicu ?
      if prow()>50  // nemoj na pola strane na novu stranu
         NStr0({|| Zagl2()})
      endif
    endif
    if fDelphiRB
      select pripr
      select pom
      append blank
      replace rbr with pripr->(Rbr())
      replace naziv with KonvZnWin(@cTxt1, gKonvZnWin), kolicina with transform(PRIPR->(kolicina()),pickol)
      select pripr
    else
     ? space(gnLMarg); ?? Rbr(),""
     if gVarF=="1"
       ?? space(10),cTxt1,space(10),transform(kolicina(),pickol),space(3)
     else
       ?? cTxt1,space(10),transform(kolicina(),pickol),space(3)
     endif
    endif

    if cTI=="2"
       nRec:=recno()
       cRbr:=Rbr
       nUk2:=nRab2:=nPor2:=0
       do while !eof() .and. idfirma+idtipdok+brdok==cidfirma+cidtipdok+cbrdok .and. Rbr==cRbr
        if podbr=" ."
          skip
	  loop
        endif
        nUk2+=round(kolicina()*cijena*Koef(cDinDem),nZaokr)
        nRab2+=round(kolicina()*cijena*rabat/100*Koef(cDinDem),nZaokr)
        nPor2+=round(kolicina()*cijena*(1-rabat/100)*Porez/100*Koef(cDinDem),nZaokr)
        skip
       enddo
       nPorez:=nPor2/(nUk2-nRab2)*100
       go nRec

       if nRab2*100/nUk2-int(nRab2*100/nUk2) <> 0
          cRab:=str(nRab2*100/nUk2,5,2)
       else
         cRab:=str(nRab2*100/nUk2,5,0)
       endif
       if fDelphiRB
        select pom
        replace  kolicina with pripr->(transform(iif(kolicina==0,0,nUk2/kolicina()) , piccdem)) ,;
                 rabat with pripr->(cRab+"%"), dest with pripr->dest
        if nporez-int(nporez)<>0
         cPor:=str(nporez,3,1)
        else
         cPor:=str(nporez,3,0)
        endif
        replace Por with   cPor+"%"
        select pripr
       else // fdelphirb
        @ prow(),pcol()+1 SAY iif(kolicina==0,0,nUk2/kolicina()) pict piccdem
        if gRabProc=="D"
          @ prow(),pcol()+1 SAY cRab+"%"
        endif
        if gVarF=="2"
         @ prow(),pcol()+1 SAY iif(kolicina<>0,(nUk2-nRab2)/kolicina(),0) pict picdem
        endif
        if nporez-int(nporez)<>0
         cPor:=str(nporez,3,1)
        else
         cPor:=str(nporez,3,0)
        endif
        @ prow(),pcol()+1 SAY cPor+"%"
	if IsTvin()
		// ispis iznosa poreza
        	@ prow(),pcol()+1 SAY nPor2 pict "99999.99"
	endif
        nCol1:=pcol()+1
        @ prow(),pcol()+1 SAY nUk2 pict picdem
       endif

       if nPor2<>0
         select por
         if roba->tip="U"
          cPor:="PPU "+ str(nPorez,5,2)+"%"
         else
          cPor:="PPP "+ str(nPorez,5,2)+"%"
         endif
         seek cPor
         if !found(); ++nPorZaIspis; append blank; replace por with cPor ;endif
         replace iznos with iznos+nPor2
         select pripr
       endif

    endif //tip=="2" - prikaz vrijednosti u . stavci
   else   // podbr nije "."
     // maloprodaja ili izlaz iz MP putem VP ili predr.MP
     // ili racun participacije
     if idtipdok $ "11#15#27" .or. idtipdok=="19" .and. lPartic
       select tarifa; hseek roba->idtarifa
       IF IzFMKINI("POREZI","PPUgostKaoPPU","D")=="D"
         nMPVBP:=pripr->(cijena*Koef(cDinDem)*kolicina())/(1+tarifa->zpp/100+tarifa->ppp/100)/(1+tarifa->opp/100)
       ELSE
         nMPVBP:=pripr->(cijena*Koef(cDinDem)*kolicina())/((1+tarifa->opp/100)*(1+tarifa->ppp/100)+tarifa->zpp/100)
       ENDIF
       if tarifa->opp<>0
         select por
         seek "PPP "+str(tarifa->opp,6,2)
         if !found()
	 ++nPorZaIspis
	 append blank
	 replace por with "PPP "+str(tarifa->opp,6,2)
	 endif
         replace iznos with iznos+(nIznPPP:=nMPVBP*tarifa->opp/100)
       else
	 nIznPPP:=0
       endif
       if tarifa->ppp<>0
         select por
         seek "PPU "+str(tarifa->ppp,6,2)
         if !found(); ++nPorZaIspis; append blank; replace por with "PPU "+str(tarifa->ppp,6,2); endif
         replace iznos with iznos+(nIznPPU:=nMPVBP*(1+tarifa->opp/100)*tarifa->ppp/100)
       else
	 nIznPPU:=0
       endif
       if tarifa->zpp<>0
         select por
         seek "PP  "+str(tarifa->zpp,6,2)
         if !found(); append blank; replace por with "PP  "+str(tarifa->zpp,6,2); endif
         IF IzFMKINI("POREZI","PPUgostKaoPPU","D")=="D"
           replace iznos with iznos+nMPVBP*(1+tarifa->opp/100)*tarifa->zpp/100
         ELSE
           replace iznos with iznos+nMPVBP*tarifa->zpp/100
         ENDIF
       endif
       select pripr
     endif

    aSbr:=Sjecistr(serbr,10)
    if roba->tip="U"
     aTxtR:=SjeciStr(aMemo[1],iif(gVarF=="1".and.!idtipdok$"11#27",51,if(IsTvin(),if(idtipdok$"11#27",22,31),40)))   // duzina naziva + serijski broj
     if fdelphiRB
       select pom
       append blank  //prvo se stavlja naziv!!!
       replace naziv with pripr->(aMemo[1])
       select pripr
     endif
    else

     cK1:=""
     cK2:=""
     	if pripr->(fieldpos("k1"))<>0 
     		cK1:=k1
		cK2:=k2
	endif
     aTxtR:=SjeciStr(trim(roba->naz)+iif(!empty(ck1+ck2)," "+ck1+" "+ck2,"")+Katbr()+IspisiPoNar(),if(IsTvin(),if(idtipdok$"11#27",22,31),40))
     if fdelphiRB
       select pom
       append blank // prvo se stavlja naziv!!
       replace naziv with pripr->(trim(roba->naz)+iif(!empty(ck1+ck2)," "+ck1+" "+ck2,"")+Katbr()+IspisiPoNar())
       replace serbr with pripr->serbr
       select pripr
     endif

    endif

    if !fDelphiRB
     ** izbacujem iz igre serijski broj
     // if prow()>gERedova+49-len(aSbr)- nLTxt2  // prelaz na sljedecu stranicu ?
     if prow()>gERedova+48-nLTxt2  // prelaz na sljedecu stranicu ?
      if prow()>50  // nemoj na pola strane na novu stranu
       NStr0({|| Zagl2()})
      endif
     endif
    endif


    if porez-int(porez)<>0
        cPor:=str(porez,3,1)
    else
        cPor:=str(porez,3,0)
    endif


    if fDelphiRB
      select pom
      replace rbr with pripr->(RBr()) ,;
              Sifra  with pripr->(StIdROBA(idroba))
      select pripr
    else
     ? space(gnLMarg)
     ?? Rbr(), StIdROBA(idroba)
     nCTxtR:=pcol()+1
     @ prow(),nCTxtR SAY aTxtR[1]
    endif

    if !( cidtipdok $ "11#27" .or. cidtipdok=="19" .and. lPartic )
       if roba->tip<>"U" .and. gVarF=="1"
         //nCTxtR:=pcol()+1
         if !fDelphiRB
          @ prow(),pcol()+1 SAY aSbr[1]
         endif
       endif
    else
       //nCTxtR:=pcol()+1
     if fDelphiRB
       select tarifa
       hseek roba->idtarifa
       select pom
       replace POREZ1 with transform(tarifa->opp,"9999.9%")
       replace POREZ2 with transform(tarifa->ppp,"999.9%")
       select pripr
     else
       @ prow(),pcol()+1 SAY roba->idtarifa
       select tarifa
       hseek roba->idtarifa
       @ prow(),pcol()+1 SAY tarifa->opp pict "9999.9%"
       if IsTvin()
        	@ prow(),pcol()+1 SAY nIznPPP pict "99999.99"
       endif
       @ prow(),pcol()+2 SAY tarifa->ppp pict "999.9%"
       if IsTvin()
        	@ prow(),pcol()+1 SAY nIznPPU pict "99999.99"
       endif
       select pripr
     endif
    endif
    if fDelphiRB
      select pom
      replace kolicina with transform(pripr->(kolicina()),pickol),;
              jmj with lower(ROBA->jmj)
      select pripr
    else
     @ prow(),pcol()+1 SAY kolicina() pict pickol
     @ prow(),pcol()+1 SAY lower(ROBA->jmj)
     IF glDistrib .and. cIdTipDok $ "10#21"
       IspisiAmbalazu()
     ENDIF
    endif

     if gSamokol!="D"
     if empty(podbr) .or. (!empty(podbr) .and. cTI=="1")
           if fDelphiRB
            select pom
            replace cijena with pripr->(transform(cijena*Koef(cDinDem),piccdem))
            select pripr
           else
            if !(cidtipdok=="19".and.lPartic)
              @ prow(),pcol()+1 SAY cijena*Koef(cDinDem) pict piccdem
            endif
           endif

           if rabat-int(rabat) <> 0
             cRab:=str(rabat,5,2)
           else
             cRab:=str(rabat,5,0)
           endif
           if !( cidtipdok$ "11#27" .or. cidtipdok=="19" .and. lPartic )
             if gRabProc=="D"
               if fDelphiRB
                select pom
                replace Rabat with pripr->(cRab+"%")
                select pripr
               else
                @ prow(),pcol()+1 SAY cRab+"%"
               endif
             endif
             if gVarF=="2" .or. gVarF=="3"
               if fDelphiRB
                select pom
                replace CijenaMR with pripr->(transform(cijena*(1-rabat/100)*Koef(cDinDem),piccdem))
                select pripr
               else
                @ prow(),pcol()+1 SAY cijena*(1-rabat/100)*Koef(cDinDem)  pict piccdem
               endif
             endif
             if porez-int(porez)<>0
               cPor:=str(porez,3,1)
             else
               cPor:=str(porez,3,0)
             endif
             if fDelphiRB
                select pom
                replace POR with pripr->(cPor+"%")
                select pripr
             else
               @ prow(),pcol()+1 SAY cPor+"%"
	       if IsTvin()
                 @ prow(),pcol()+1 SAY kolicina()*Koef(cDinDem)*cijena*(1-rabat/100)*Porez/100 pict "99999.99"
	       endif
             endif
           else
             //@ prow(),pcol()+1 SAY space(6)
           endif


           nCol1:=pcol()+1
           if fDelphiRB
                select pom
                replace UKUPNO with pripr->(transform(round(kolicina()*cijena*Koef(cDinDem),nZaokr),picdem))
                select pripr
           else
             @ prow(),pcol()+1 SAY round(kolicina()*cijena*Koef(cDinDem),nZaokr) pict picdem
             if cidtipdok=="19" .and. lPartic
               @ prow(),pcol()+1 SAY SPACE(4)
               nCol1:=pcol()+1
               @ prow(),pcol()+1 SAY round(kolicina()*cijena*Koef(cDinDem)*(1-rabat/100),nZaokr) pict picdem
             endif
           endif
           nPor2:=kolicina()*Koef(cDinDem)*cijena*(1-rabat/100)*Porez/100

           if !fDelphiRB
           //if roba->tip="U"
             for i:=2 to len(aTxtR)
               @ prow()+1,nCTxtR  SAY aTxtR[i]
             next
           //else
           endif

            ** izbacujem iz igre serijski broj
            //if gVarF=="1" .and. cidtipdok<>"11"
             //for i:=2 to len(aSbr)
              //@ prow()+1,nCTxtR  SAY aSbr[i]
             //next
            //endif
           //endif

           if nPor2<>0
              select por
              if roba->tip="U"
               cPor:="PPU "+ str(pripr->Porez,5,2)+"%"
              else
               cPor:="PPP "+ str(pripr->Porez,5,2)+"%"
              endif
              seek cPor
              if !found()
	      	++nPorZaIspis
	      	append blank
	      	replace por with cPor
	      	endif
              	replace iznos with iznos+nPor2
              	select pripr
              endif
     if fDelphiRB
       select pom
       if fPBarKod
         replace BARKOD with roba->barkod
       endif
       select pripr
     else // fdelphirb
      if fPBarkod .and. (!empty(roba->barkod) .or. ImaC1_3())
       ? space(gnLMarg)
       ?? space(6),""
       if !empty(roba->barkod)
         ?? roba->barkod,""
       endif
       PrintC1_3()
       if izfmkini("SifRoba","PDRazmak","N",SIFPATH)=="D"
         ?
       endif
      endif
      if gHLinija=="D"
        ? space(gNLMarg)
	?? m
      endif
     endif // fdelphirb

    endif

    endif  // gsamokol!="D"

    nUk+=round(kolicina()*cijena*Koef(cDinDem),nZaokr)
    nRab+=round(kolicina()*cijena*Koef(cDinDem)*rabat/100,nZaokr)
   endif
   skip
enddo
nRab:=round(nRab,nZaokr)
nUk:= round(nUk, nZaokr)

if !fDelphiRB
 ? space(gnLMarg)
 ??  m
endif

nPor2:=0 // treba mi iznos poreza da bih vidio da li cu stampati red "Ukupno"
select por
go top
do while !eof()
 nPor2+=round(Iznos,nZaokr)
 skip
enddo

if gSamokol!="D"

if fDelphiRB
   UzmiIzIni(cIniName,'Varijable','UkupnoRabat',transform(0,picdem),'WRITE')
   UzmiIzIni(cIniName,'Varijable','DINDEM',cDinDEM,'WRITE')
   UzmiIzIni(cIniName,'Varijable','Ukupno',transform(nUk,picdem),'WRITE')
endif

if ((nRab<>0) .or. (nPor2<>0))
  if !fDelphiRB
   if !(cidtipdok=="19".and.lPartic)
     ? space(gnLMarg); ??  padl("Ukupno ("+cDinDem+") :",98); @ prow(),nCol1 SAY nUk pict picdem
   endif
  endif
endif


if nRab<>0
  if !( cidtipdok$ "11#15#27" .or. cidtipdok=="19".and.lPartic )
   if fDelphiRB
    UzmiIzIni(cIniName,'Varijable','DINDEM',cDinDEM,'WRITE')
    UzmiIzIni(cIniName,'Varijable','UkupnoRabat',transform(nRab,picdem),'WRITE')
   else
    ? space(gnLMarg)
    ??  padl("Rabat ("+cDinDem+") :",98)
    @ prow(),nCol1 SAY nRab pict picdem
   endif
  endif
endif

cPor:=""
nPor2:=0
fStamp:=.f.
if ! ( cidtipdok $ "11#27" .or. cidtipdok=="19".and. lPartic )
 select por
 go top
 nPorI:=0

 UzmiIzIni(cIniName,'Varijable','PorezStopa1',"-",'WRITE')
 UzmiIzIni(cIniName,'Varijable','Porez1',"0",'WRITE')
 for i:=2 to 5
    UzmiIzIni(cIniName,'Varijable','Porez'+alltrim(str(i)),"",'WRITE')
 next

 do while !eof()  // string poreza
  // odstampaj ukupno - rabat kada ima poreza
  nPor2 += round(Iznos,nZaokr)
  if nPor2<>0 .and. !fStamp .and. gFormatA5<>"0" .and. nRab<>0   // koristim ovaj parametar za varijantu 2
                      // jer se samo koristi za 22
   if !fDelphiRB
    ? space(gnLMarg)
    ??  padl("Ukupno - Rab ("+cDinDem+") :",98);  @ prow(),nCol1 SAY nUk-nRab pict picdem
   endif
   fStamp:=.t.
  endif
  if fDelphiRB
    UzmiIzIni(cIniName,'Varijable','PorezStopa'+alltrim(str(++nPori)),trim(por),'WRITE')
    UzmiIzIni(cIniName,'Varijable','Porez'+alltrim(str(nPori)),transform(round(IF(cIdTipDok=="15",-1,1)*iznos,nzaokr),picdem),'WRITE')
  else
   ? space(gnLMarg); ?? padl(trim(por)+":",98); @ prow(),nCol1 SAY round(IF(cIdTipDok=="15",-1,1)*iznos,nzaokr) pict picdem
  endif
  skip
 enddo
 nPor2 := IF(cIdTipDok=="15",-1,1) * nPor2
endif

nFZaokr:=round(nUk-nRab+nPor2,nZaokr)-round2(round(nUk-nRab+nPor2,nZaokr),gFZaok)

if gFZaok<>9 .and. round(nFzaokr,4)<>0 .and. !(cidtipdok=="19".and.lPartic)
 if fDelphiRB
   UzmiIzIni(cIniName,'Varijable','Zaokruzenje',transform(nFZaokr,picdem),'WRITE')
 else
  ? space(gnLMarg); ?? padl("Zaokruzenje:",98); @ prow(),nCol1 SAY nFZaokr pict picdem
 endif
endif

cPom:=Slovima(round(nUk-nRab+nPor2-nFzaokr,nZaokr),cDinDem)

if fDelphiRB
   UzmiIzIni(cIniName,'Varijable','UkupnoMRabat',transform(round(nUk-nRab,nzaokr),picdem),'WRITE')
   UzmiIzIni(cIniName,'Varijable','UkupnoPorez',transform(round(nPor2,nzaokr),picdem),'WRITE')
   UzmiIzIni(cIniName,'Varijable','Ukupno2',transform(round(nUk-nRab+nPor2-nFzaokr,nzaokr),picdem),'WRITE')
   UzmiIzIni(cIniName,'Varijable','Slovima',cPom,'WRITE')
else
? space(gnLMarg); ??  m
? space(gnLMarg); ??  padl("U K U P N O  ("+cDinDem+") :",98); @ prow(),nCol1 SAY round(nUk-nRab+nPor2-nFzaokr,nzaokr) pict picdem
if !empty(picdem)
 ? space(gnLmarg); ?? "slovima: ",cPom
else
 ?
endif
endif // fdelphirb
endif // gsamokol!="D"

if !fDelphiRB
	? space(gnLMarg)
	?? m
	?
	if prow()>gERedova+48-nLTxt2  // prelaz na sljedecu stranicu ?
   		NStr0({|| Zagl2()},.f.)
	endif
endif

IF lUgRab
 cTxt2 := STRTRAN( cTxt2 , "#01#" , ALLTRIM(gNFirma)                         )
 cTxt2 := STRTRAN( cTxt2 , "#02#" , ALLTRIM(cTxt3a)                          )
 cTxt2 := STRTRAN( cTxt2 , "#03#" , ALLTRIM(transform(nRab,picdem))          )
 cTxt2 := STRTRAN( cTxt2 , "#04#" , ALLTRIM(cBrDok)                          )
 cTxt2 := STRTRAN( cTxt2 , "#05#" , DTOC(dDatDok)                            )
ENDIF

if fDelphiRB

  cTxt2:=strtran(cTxt2,"ç"+Chr(10),"")
  cTxt2:=strtran(cTxt2, Chr(13)+Chr(10), "####"+Chr(200))

  for i:=1 to 25
   UzmiIzIni(cIniName,'Varijable','KrajTxt'+alltrim(str(i)),"",'WRITE')
  next


  for i:=1 to numtoken(cTxt2, Chr(200) )
	UzmiIzIni(cIniName,'Varijable','KrajTxt'+alltrim(str(i)), token(KonvZnWin(@cTxt2, gKonvZnWin), Chr(200), i) ,'WRITE')
  next
  
else
	cTxt2:=strtran(ctxt2,"ç"+Chr(10),"")
	cTxt2:=strtran(ctxt2,Chr(13)+Chr(10),Chr(13)+Chr(10)+space(gnLMarg))
	? space(gnLMarg)
	?? ctxt2
	?
endif

if !fDelphiRB 
  if cidtipdok$"11#27" .and. !( gRekTar=="D" .and. gVarC="X" )
   select por
   go top
   ? space(gnLMarg)
   ?? "- Od toga porez: ----------"
   nUkPorez:=0
   do while !eof()
     ? space(gnLMarg)
     ?? por+"%   :"
     @ prow(),pcol()+1 SAY iznos pict  "9999999.999"
     nukporez+=iznos
     skip
   enddo
   ? space(gnLMarg)
   ?? "Ukupno :  "+space(5)
   @ prow(),pcol()+1 SAY nUkPorez pict "9999999.999"
   ? space(gnLMarg)
   ?? "---------------------------"
   select pripr
   select por
   use
 endif
endif

if fDelphiRB .and. cIdTipDok $ "11#27" 
//.and. !( gRekTar=="D" .and. gVarC="X" )
   		
	select por
   	go top
   
   
   	i10:=0
   	UzmiIzIni(cIniName,'Varijable','MPPorez'+alltrim(str(i10)), ;
     		"- Od toga porez: ----------","WRITE")
   	
	i10:=i10+1
   		
	nUkPorez:=0
	do while !eof()
 		
   		UzmiIzIni(cIniName,'Varijable','MPPorez'+alltrim(str(i10)), ;
		 	por+"%   : " + TRANSFORM(iznos, "9999999.999"), "WRITE" )
     	

		i10:=i10+1
		nUkporez+=iznos
     		skip
	enddo
 


   	UzmiIzIni(cIniName,'Varijable','MPPorez'+alltrim(str(i10)), ;
     		"Ukupno :  "+space(6)+ TRANSFORM(nUkPorez, "9999999.999"), "WRITE" )
   	
	i10:=i10+1
   
   	UzmiIzIni(cIniName,'Varijable','MPPorez'+alltrim(str(i10)), ;
     		"---------------------------", "WRITE")
     	
	i10:=i10+1
	
   	// do kraja popuni sa prazno
	do while i10 < 8
   		UzmiIzIni(cIniName,'Varijable','MPPorez'+alltrim(str(i10)), ;
     			"", "WRITE")
  		
		i10:=i10+1
	enddo
	
	select pripr
   	select por
	use
endif


if gRekTar=="D" .and. (gVarC="X" .or. cidtipdok=="13")
   // gVarC="X" - radimo prakticno magacin maloprodaje- OPRESA
   select pripr
   private cFilTarifa:="idfirma=="+cm2str(cidfirma)+".and. idtipdok=="+cm2str(cidtipdok)+".and. brdok=="+cm2str(cbrdok)
   set relation to idroba into roba
   index on roba->idtarifa  to fakttar2 for &cFilTarifa
   P_COND
   RekTarife()
   select pripr
   
   // azurirana faktura
   if pcount()==3  
    set index to fakt
   else
    set index to pripr
   endif
   set order to 1
endif

if !fDelphiRB
?
?
P_12CPI
endif

PrStr2T(cIdTipDok)

if !fDelphiRB
 FF
 ZAVRSI STAMPU
else
  cSwitch:=""
  SELECT (F_POM)
  USE
  UzmiIzIni(EXEPATH+"FMK.INI",'DELPHIRB','Aktivan',"1",'WRITE')
#ifdef PROBA
  private cKomLin:="start /m t:\sigma\DelphiRB "+cRTM+" "+PRIVPATH+"  pom  1"
  private cKomLiF:="start /m t:\sigma\DelphiRB "+cRTMF+" "+PRIVPATH+"  pom  1"
#else
  if IzFmkIni('FAKT','StampaWin2000','N',EXEPATH)=='D'
    private cKomLin:=cPoziv+" "+ALLTRIM(cRTM)+" "+PRIVPATH+"  pom  1"
    private cKomLinF:=cPoziv+" "+ALLTRIM(cRTMF)+" "+PRIVPATH+"  pom  1"
  else
    private cKomLin:="start " + cSwitch + " DelphiRB "+ALLTRIM(cRTM)+" "+PRIVPATH+"  pom  1"
    private cKomLinF:="start " + cSwitch + " DelphiRB "+ALLTRIM(cRTMF)+" "+PRIVPATH+"  pom  1"
  endif
#endif
  BEEP(1)
  IF lSSIP99
    cKomLin += " /P"
  ENDIF

  if IzFmkIni('UpitFax','Slati','N',PRIVPATH)=='D'
    run &cKomLinF
  else
    run &cKomLin
  endif

  IF lSSIP99
    MsgO("Cekam da DelphiRB zavrsi svoj posao...")
    DO WHILE IzFMKIni('DELPHIRB','Aktivan',"1")<>"0"
      IniRefresh()
      nSek0 := SECONDS()
      DO WHILE SECONDS()-nSek0<1.5
        OL_Yield()
      ENDDO
      IniRefresh()
    ENDDO
    MsgC()
  ENDIF
endif
CLOSERET
*}


/*! \fn Zagl2()
 *  \brief Stampa zaglavlja na fakturi
 */
 
static function Zagl2()
*{
P_COND
? space(gnLMarg)
?? m

IF "U" $ TYPE("lPartic")
lPartic:=.f.
ENDIF

if cidtipdok$"19" .and. lPartic
 ? space(gnLMarg); ?? "                                                                                                                Ukupan iznos "
 ? space(gnLMarg); ?? " R.br  Sifra      Naziv                                    Tarifa    PPP    PPU     kolicina  jmj    Ukupno     participacije"
elseif cidtipdok$"11#27"
 if IsTvin()
 	? space(gnLMarg); ?? " R.br  Sifra      Naziv                  Tarifa    PPP % i iznos   PPU % i iznos    kolicina  jmj    Cijena       Ukupno"
 else
 	? space(gnLMarg); ?? " R.br  Sifra      Naziv                                    Tarifa    PPP    PPU     kolicina  jmj    Cijena       Ukupno"
 endif
 if fPBarkod
    ? space(gnLMarg)
    ?? "       Barkod    "
 endif
else
 if glDistrib .and. cIdTipDok $ "10#21"
   camb:="  ambal."
 else
   camb:=""
 endif
 if gVarF=="1"
   ? space(gnLMarg); ?? " R.br  Sifra      Naziv                                    "+JokSBr()+"    kolicina   jmj"+camb+"    Cijena    Rabat  Por    Ukupno"
   if fPBarkod
      ? space(gnLMarg); ?? "       Barkod    "
   endif
 else
   if IsTvin()
	cPR:="Naziv"
   	cP:="% i iznos"
   else
	cPR:="Naziv         "
   	cP:=""
   endif
   IF gRabProc=="D"
     ? space(gnLMarg); ?? " R.br  Sifra      "+cPR+"                             kolicina  jmj"+camb+"    Cijena   Rabat   Cijena-Rab  Por"+cP+"    Ukupno"
   ELSE
     ? space(gnLMarg); ?? " R.br  Sifra      "+cPR+"                             kolicina  jmj"+camb+"    Cijena    Cijena-Rab  Por"+cP+"    Ukupno"
   ENDIF

   if fPBarkod
      ? space(gnLMarg); ?? "       Barkod    "
   endif
 endif
endif

? space(gnLMarg); ?? m
return
*}


/*! \fn NStr0(bZagl,fPrenos)
 *  \brief Prelaz na novu stranu
 *  \param bZagl
 *  \param fPrenos
 */
 
static function NStr0(bZagl,fPrenos)
*{
if fprenos=NIL
  fPrenos:=.t.
endif

if fprenos
 ? space(gnLmarg); ?? m
 ? space(gnLmarg+IF(gVarF=="9".and.gTipF=="2",14,0)),"Ukupno na strani "+str(++nStrana,3)+":"; @ prow(),nCol1  SAY nUk  pict picdem
 ? space(gnLmarg); ?? m
else
 ++nStrana
endif
FF
if gZagl=="1"  // zaglavlje na svakoj stranici
 P_10CPI
 if gBold=="1";B_ON;endif
 StZaglav2(gVlZagl,PRIVPATH)
 StKupac()
endif
if fprenos
 Eval(bZagl)
 ? space(gnLmarg+IF(gVarF=="9".and.gTipF=="2",14,0)),"Prenos sa strane "+str(nStrana,3)+":"; @ prow(),nCol1  SAY nUk pict picdem
 ? space(gnLmarg); ?? m
else
 ? m
 ? space(gnLmarg),"       Strana:",str(nStrana+1,3)
 ? m
endif
*}


/*! \fn StKupac(fDelphiRB)
 *  \brief
 *  \param fdelphiRB
 */
 
static function StKupac(fDelphiRb)
*{
local cMjesto:=padl(Mjesto(cIdFirma)+", "+dtoc(ddatdok),iif(gFPZag=99,gnTMarg3,0)+39)

IF "U" $ TYPE("lPartic"); lPartic:=.f.; ENDIF

if fDelphiRB==NIL
 fDelphiRB:=.t.
endif

aPom:=Sjecistr(cTxt3a,30)
if fdelphiRb

   for i:=1 to len(aPom)
     UzmiIzIni(cIniName,'Varijable','PARTNER'+ALLTRIM(STR(i)),aPom[i],'WRITE')
   next
   UzmiIzIni(cIniName,'Varijable','PARTNER'+ALLTRIM(STR(i)),cTxt3b,'WRITE')
   UzmiIzIni(cIniName,'Varijable','PARTNER'+ALLTRIM(STR(++i)),cTxt3c,'WRITE')
   FOR j:=5 TO i+1 STEP -1
     UzmiIzIni(cIniName,'Varijable','PARTNER'+ALLTRIM(STR(j)),"",'WRITE')
   NEXT
   if gDest
     if !EMPTY(PRIPR->DEST)
       cDest:=PRIPR->DEST
     else
       cDest:='--'
     endif
     UzmiIzIni(cIniName,'Varijable','Dest',cDest,'WRITE')
   endif
   UzmiIzIni(cIniName,'Varijable','REGBR',cRegBr,'WRITE')
   UzmiIzIni(cIniName,'Varijable','PORDJBR',cPorDjBr,'WRITE')
   if IzFmkIni("FAKT","Opcine","N",SIFPATH)=="D"
     UzmiIzIni(cIniName,'Varijable','KANTON',cKanton,'WRITE')
   endif
else
 IF IzFMKINI("FAKT","KupacDesno","N",KUMPATH)=="D"
   ?? space(5); ?? PADR(ALLTRIM(iif(gFPzag<>99 .or. gnTMarg2=1,cMjesto,"")),39); gPB_ON(); ?? padc(alltrim(aPom[1]),30); gPB_OFF()
   for i:=2 to len(aPom)
     ? space(5+39);gPB_ON();?? padc(alltrim(aPom[i]),30);gPB_OFF()
   next
   ?  space(5); ?? PADR(ALLTRIM(iif(gFPzag=99 .and. gnTMarg2=2,cMjesto,"")),39) ;gPB_ON();?? padc(alltrim(cTxt3b),30);gPB_OFF()
   ?  space(5); ?? PADR(ALLTRIM(iif(gFPzag=99 .and. gnTMarg2=3,cMjesto,"")),39) ;gPB_ON();?? padc(alltrim(cTxt3c),30);gPB_OFF()
   IF glDistrib .and. !EMPTY(cidpm)
     ?  space(5+39); gPB_ON();?? padc(alltrim(cIDPM),30);gPB_OFF()
   ENDIF
 ELSE
   ?? space(5);gPB_ON();?? padc(alltrim(aPom[1]),30);gPB_OFF(); ?? iif(gFPzag<>99 .or. gnTMarg2=1,cMjesto,"")
   for i:=2 to len(aPom)
     ? space(5);gPB_ON();?? padc(alltrim(aPom[i]),30);gPB_OFF()
   next
   ?  space(5);gPB_ON();?? padc(alltrim(cTxt3b),30);gPB_OFF(); ?? iif(gFPzag=99 .and. gnTMarg2=2,cMjesto,"")
   ?  space(5);gPB_ON();?? padc(alltrim(cTxt3c),30);gPB_OFF(); ?? iif(gFPzag=99 .and. gnTMarg2=3,cMjesto,"")
   IF glDistrib .and. !EMPTY(cidpm)
     ?  space(5);gPB_ON();?? padc(alltrim(cIDPM),30);gPB_OFF()
   ENDIF
 ENDIF
endif

cStr:=cidtipdok+" "+trim(cbrdok)

if fDelphiRB
  UzmiIzIni(cIniName,'Varijable','Mjesto',cMjesto,'WRITE')
else
  if gFPZag=99 .and. gnTMarg2>3 // uzmi iz parametara poizviju za stampanjemjesta
    for i:=4 to gnTMarg2
      if  gnTMarg2 = i
        ? space(35)+cMjesto
        ?
        ? space(35)
        exit
      else
        ?
      endif
      next
  endif
endif

private cpom:=""
if !(cIdTipDok $ "00#01#19")
   cPom:="G"+cidtipdok+"STR"
   cStr:=&cPom
endif

cStrRN:=""

if lUgRab
  cStr:="UGOVOR O RABATU br."
elseif (lTrebovanje .and. !Empty(pripr->idRNal))
  cStr:="IZLAZ MATERIJALA br. "		
  cStrRN:=TRIM("PO RADNOM NALOGU br. "+pripr->idRNal)
elseif cIdTipDok == "01"
  if cIdFirma="TE"
    cStr:="RADNI NALOG"
  else
    IF lPovDob
      cStr:="POVRAT DOBAVLJACU "+cIdFirma
    ELSE
      cStr:="PRIJEM U MAGACIN "+cIdFirma
    ENDIF
  endif
elseif cidtipdok="19"
  if cIdFirma="TE"
    cStr:="REALIZACIJA R.N."
  else
   if IzFMKIni("FAKT","I19jeOtpremnica","N",KUMPATH)=="D"
      cStr:="OTPREMNICA (19) "+cIdFirma
   elseif lPartic
      cStr:=StrKZN("RA¨UN PARTICIPACIJE","8",gKodnaS)+" (19) "+cIdFirma
   else
      cStr:="IZLAZ (19) "+cIdFirma
   endif
  endif
endif

if fDelphiRB
  UzmiIzIni(cIniName,'Varijable','Dokument',cStr,'WRITE')
  UzmiIzIni(cIniName,'Varijable','BROJDOK',cBrDok,'WRITE')
  // ako neko slucajno koristi staru varijantu RTM-a
  // mirso je ispravio f-ju INI_READ()
  //UzmiIzIni(cIniName,'Varijable','BROJ',cBrDok,'WRITE')
else

cStr := cStr+" "+trim(cBrdok)
if gPrinter="R"
 B_ON
 IF IzFMKINI("FAKT","KupacDesno","N",KUMPATH)=="D"
   ?
   ShowIdPar(cIdPartner,44,.f.)
   ? SPACE(12)
   ?? padc("#%FS012#"+cStr,50)
   if lTrebovanje
	? SPACE(12)
   	?? padc("#%FS012#"+cStrRN,50)
   endif
 ELSE
   ShowIdPar(cIdPartner,5,.t.)
   ?? padl("#%FS012#"+cStr,39+4+iif(gFPZag=99,gnTMarg3,0))
   if lTrebovanje
	? SPACE(12+23)
   	?? padl("#%FS012#"+cStrRN,39+4+iif(gFPZag=99,gnTMarg3,0))
   endif
 ENDIF
 B_OFF
else
 IF IzFMKINI("FAKT","KupacDesno","N",KUMPATH)=="D"
   ?
   ShowIdPar(cIdPartner,44,.f.)
   ? SPACE(12)
   B_ON; ?? padc(cStr,50); B_OFF
   if lTrebovanje
	? SPACE(12)
   	B_ON; ?? padc(cStrRN,50); B_OFF
   endif
 ELSE
   ShowIdPar(cIdPartner,5,.t.)
   B_ON; ?? padl(cStr,39+iif(gFPZag=99,gnTMarg3,0)); B_OFF
   if lTrebovanje
	? SPACE(12+23)
   	B_ON; ?? padl(cStrRN,39+iif(gFPZag=99,gnTMarg3,0)); B_OFF
   endif
 ENDIF
endif
endif

//ako nije tip dokumenta 10 ponisti podatke datuma valutiranja ...
//da ne bi slucajno uzeo zadnje upisane u INI !!!
if fDelphiRB
  if !(cIdTipDok == "10")
    UzmiIzIni(cIniName,'Varijable','BrNar',' ---- ','WRITE')
    UzmiIzIni(cIniName,'Varijable','DatPl',' ---- ','WRITE')
    UzmiIzIni(cIniName,'Varijable','BrOtp',' ---- ','WRITE')
    UzmiIzIni(cIniName,'Varijable','DatOtp',' ---- ','WRITE')
  endif
endif

return
*}


/*! \fn KatBr()
 *  \brief Kataloski broj
 */
 
function KatBr()
*{
if roba->(fieldpos("KATBR"))<>0
  if !empty(roba->katbr)
     return " ("+trim(roba->katbr)+")"
  endif
endif
return ""
*}



/*! \fn UgRabTXT()
 *  \brief Uzima tekst iz fajla gFUgRab
 */
 
static function UgRabTXT()
*{
local cPom:=""
local cFajl:=PRIVPATH+gFUgRab
if FILE(cFajl)
	cPom:=FILESTR(cFajl)
endif
return cPom
*}


/*! \fn DiVoRel()
 *  \brief 
 *  \todo nesto vezano za vindiju
 */
 
function DiVoRel()
*{
LOCAL nArr:=SELECT(), cIdVozila:=idvozila
  SELECT (F_VOZILA)
  IF !USED()
    O_VOZILA
  ENDIF
  SEEK cIdVozila
  SELECT (nArr)
  ? space(gnLMarg)
  ?? "Distributer:", TRIM(iddist)
  ?? "   Vozilo:", TRIM(VOZILA->naz), TRIM(VOZILA->tablice)
  ?? "   Relacija:", TRIM(idrelac)
return
*}


/*! \fn IspisiAmbalazu()
 *  \brief Ispisuje ambalazu
 */
 
function IspisiAmbalazu()
*{
// LOCAL nPak:=0, nKom:=0
// Prepak(IdRoba,ROBA->jmj,@nPak,@nKom,kolicina)
// @ prow(),pcol()+1 SAY STR(nPak,2)+"P+"+STR(nKom,2)+"K"
@ prow(),pcol()+1 SAY STR(ambp,2)+"P+"+STR(ambk,2)+"K"
return
*}



/*! \fn IspisiPoNar()
 *  \brief Ispisi po narudzbi
 */
 
function IspisiPoNar()
*{
LOCAL cV:=""
 IF lPoNarudzbi
   IF !EMPTY(brojnar)
     cV += "nar.br."+TRIM(brojnar)
   ENDIF
   IF !EMPTY(idnar) .and.;
      ( cIdTipDok="0" .or. idpartner<>idnar .and. IzFMKIni("FAKT","PrikaziNaruciocaAkoJeRazlicitOdKupca","D",KUMPATH)=="D" )
     cV += "  narucilac:"+TRIM(idnar)
   ENDIF
   cV:=ALLTRIM(cV)
   IF !EMPTY(cV)
     cV := " ("+cV+")"
   ENDIF
 ENDIF
return cV
*}


/*! \fn Kolicina()
 *  \brief
 */
 
function Kolicina()
*{
return IF(lPovDob,-kolicina,kolicina)
*}



function ImaC1_3()
*{
local cPom:=""
if pripr->(fieldpos("C1"))<>0
	cPom+=pripr->c1
endif
if pripr->(fieldpos("C2"))<>0
	cPom+=pripr->c2
endif
if pripr->(fieldpos("C3"))<>0
	cPom+=pripr->c3
endif
return !EMPTY(cPom)
*}



function PrintC1_3()
*{
if pripr->(fieldpos("C1"))<>0 .and. !empty(pripr->c1)
	?? "C1="+trim(pripr->c1),""
endif
if pripr->(fieldpos("C2"))<>0 .and. !empty(pripr->c2)
	?? "C2="+trim(pripr->c2),""
endif
if pripr->(fieldpos("C3"))<>0 .and. !empty(pripr->c3)
	?? "C3="+trim(pripr->c3),""
endif
if pripr->(fieldpos("opis"))<>0 .and. !empty(pripr->opis)
	?? "op="+trim(pripr->opis),""
endif


return
*}

