#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/dok/1g/stdok23.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.17 $
 * $Log: stdok23.prg,v $
 * Revision 1.17  2003/12/12 15:24:51  sasavranic
 * uvedeno stampanje barkod-a i na varijantu fakture 2, 3
 *
 * Revision 1.16  2003/12/04 11:11:43  sasavranic
 * Uvedena konverzija i za varijantu "2" fakture
 *
 * Revision 1.15  2003/12/03 14:19:17  sasavranic
 * uvedena konverzija znakova
 *
 * Revision 1.14  2003/12/03 13:34:11  sasavranic
 * Ispravljen bug ispisa Ident.br i za poreski broj
 *
 * Revision 1.13  2003/09/08 13:18:14  mirsad
 * sitne dorade za Hano - radni nalozi
 *
 * Revision 1.12  2003/07/11 06:43:26  sasa
 * trebovanje kada je popunjeno polje radnog naloga
 *
 * Revision 1.11  2003/07/11 06:29:15  sasa
 * trebovanje kada je popunjeno polje radnog naloga
 *
 * Revision 1.10  2003/05/14 15:25:13  sasa
 * ispravka buga sa stampom kroz delphirb ako je podesen parametar 10Duplo=D
 *
 * Revision 1.9  2003/03/28 15:38:10  mirsad
 * 1) ispravka bug-a pri gen.fakt.na osnovu otpremnica: sada se korektno setuje datum u svim stavkama
 * 2) ukinuo setovanje u proizvj.ini parametra "Broj" jer opet smeta (zbog njega se u reg.broj upisuje broj fakture)
 *
 * Revision 1.8  2003/03/26 14:55:07  mirsad
 * umjesto "Reg.br." i "Por.br." svuda stavljen ispis "Ident.br."
 *
 * Revision 1.7  2002/10/17 14:38:57  mirsad
 * ispravka bug-a (rabat u MP, za Vindiju)
 *
 * Revision 1.6  2002/10/02 17:23:15  sasa
 * no message
 *
 * Revision 1.5  2002/10/01 13:01:32  sasa
 * dorada za vindiju rabat na 11-ki
 *
 * Revision 1.4  2002/09/14 12:04:53  mirsad
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

/*! \file fmk/fakt/dok/1g/stdok23.prg
 *  \brief Stampa fakture u varijanti 2 3
 */


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_Doks2
  * \brief Da li se koristi baza dodatnih podataka o dokumentu DOKS2 ?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_KumPath_FAKT_Doks2;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_BARKODumjestoSERIJSKOGBROJA
  * \brief Da li se umjesto serijskog broja ispisuje barkod ?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_KumPath_FAKT_BARKODumjestoSERIJSKOGBROJA;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_PharmaMAC
  * \brief Koriste li se specificnosti radjene za Pharma MAC ?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_KumPath_FAKT_PharmaMAC;


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
  * \var *string FmkIni_ExePath_DELPHIRB_Aktivan
  * \brief Indikator aktivnosti Delphi RB-a
  * \param 1 - aktivan
  * \param 0 - nije aktivan
  */
*string FmkIni_ExePath_DELPHIRB_Aktivan;


/*! \ingroup ini
  * \var *string FmkIni_PrivPath_UpitFax_Slati
  * \brief Ako se stampa preko Delphi RB-a, da li se pravi dokument za slanje faksom ?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_PrivPath_UpitFax_Slati;


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
  * \var *string FmkIni_SifPath_FAKT_Opcine
  * \brief Koristi li se sifrarnik opcina i sifra opcine u sifrarniku partnera?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_SifPath_FAKT_Opcine;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_FAKT_StampaViseDokumenata
  * \brief Da li se moze stampati vise od jednog dokumenta u pripremi ?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_ExePath_FAKT_StampaViseDokumenata;


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
  * \var *string FmkIni_ExePath_FAKT_KrozDelphi
  * \brief Da li se dokumenti stampaju kroz Delphi RB ?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_ExePath_FAKT_KrozDelphi;


/*! \ingroup ini
 *  \var *string FmkIni_ExePath_FAKT_DelphiRB
 *  \brief Da li ce se fakture stampati kroz DelphiRB ?
 *  \param D  - Prilikom poziva stampe dokumenti se stampaju kroz DelphiRB
 *  \param N  - Obicna stampa dokumenata
 *  \param P  - Pitanje prilikom poziva stampe DelphiRB ili obicni TXT
 */
*string FmkIni_ExePath_FAKT_DelphiRB;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_Doks2_ZK1
  * \brief Opis podatka koji se smjesta u polje K1 baze DOKS2
  * \param K1 - default vrijednost
  */
*string FmkIni_KumPath_Doks2_ZK1;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_Doks2_ZK2
  * \brief Opis podatka koji se smjesta u polje K2 baze DOKS2
  * \param K2 - default vrijednost
  */
*string FmkIni_KumPath_Doks2_ZK2;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_Doks2_ZK3
  * \brief Opis podatka koji se smjesta u polje K3 baze DOKS2
  * \param K3 - default vrijednost
  */
*string FmkIni_KumPath_Doks2_ZK3;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_Doks2_ZK4
  * \brief Opis podatka koji se smjesta u polje K4 baze DOKS2
  * \param K4 - default vrijednost
  */
*string FmkIni_KumPath_Doks2_ZK4;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_Doks2_ZK5
  * \brief Opis podatka koji se smjesta u polje K5 baze DOKS2
  * \param K5 - default vrijednost
  */
*string FmkIni_KumPath_Doks2_ZK5;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_Doks2_ZN1
  * \brief Opis podatka koji se smjesta u polje N1 baze DOKS2
  * \param N1 - default vrijednost
  */
*string FmkIni_KumPath_Doks2_ZN1;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_Doks2_ZN2
  * \brief Opis podatka koji se smjesta u polje N2 baze DOKS2
  * \param N2 - default vrijednost
  */
*string FmkIni_KumPath_Doks2_ZN2;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_Doks2opis
  * \brief Opis generalnih podataka o dokumentu koji se smjestaju u bazu DOKS2
  * \param dodatnih podataka - default vrijednost
  */
*string FmkIni_KumPath_FAKT_Doks2opis;


/*! \fn StDok23()
 *  \brief Stampa fakture u varijanti 2 3
 *  \param cIdFirma
 *  \param cIdTipDok
 *  \param cBrDok
 */

function StDok23()
*{
parameters cIdFirma,cIdTipDok,cBrDok
private i,nCol1:=0,cTxt1,cTxt2,aMemo,nMPVBP:=nVPVBP:=0
private cTi,nUk,nRab,nUk2:=nRab2:=0
private nStrana:=0,nCTxtR:=10

if pcount()==3
	O_Edit(.t.)
else
	O_Edit()
endif

lDoks2:=(IzFMKINI("FAKT","Doks2","N",KUMPATH)=="D")

BK_SB:=(IzFMKINI("FAKT","BARKODumjestoSERIJSKOGBROJA","N",KUMPATH)=="D")

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
  if IzFmkIni('FAKT','10Duplo','N')=='D' .and. pripr->(reccount2())<=10
     // dupli prored fakture do deset stavki !!!
     cRTM := ALLTRIM(cRTM) + "dp"
  endif
endif

cTI:="1"  // tip izvjestaja  1,2
O_PARAMS
private cSection:="1",cHistory:=" "; aHistory:={}
RPar("c1",@cTI)
select params; use

select PRIPR

if pcount()==0  // poziva se faktura iz pripreme
 IF gNovine=="D" .or. (IzFMKINI('FAKT','StampaViseDokumenata','N')=="D")
   FilterPrNovine()
 ENDIF
 cIdTipdok:=idtipdok;cIdFirma:=IdFirma;cBrDok:=BrDok
endif

IF glDistrib .and. cIdTipDok $ "10#21"
  mamb := " -------"
ELSE
  mamb := ""
ENDIF

if gVarF $ "13"
 if gVarF=="3"  .and. cidtipdok=="12"
   private M:="     ------ ---------- ---------------------------------------- "+IF(!glDistrib.and.BK_SB,"---","")+"---------- ----------- --- ----------- -----------"
 else
   private M:="------ ---------- ---------------------------------------- "+IF(cIdTipDok=="16".or.!glDistrib.and.BK_SB,"---","")+"---------- ----------- ---"+mamb+" ----------- ------ ---- -----------"
 endif
else
 private M:="------ ---------- ---------------------------------------- ----------- ---"+mamb+" ----------- ------ ----------- ---- -----------"
endif

if cIdTipDok=="16"
private mCTSB:="                                                           -------------"
endif

seek cidfirma+cidtipdok+cbrdok
NFOUND CRET

IF idtipdok=="01" .and. kolicina<0 .and. gPovDob$"DN"
  lPovDob := ( Pitanje(,"Stampati dokument povrata dobavljacu? (D/N)",gPovDob)=="D" )
ELSE
  lPovDob:=.f.
ENDIF

aDbf:={ {"POR","C",10,0},;
          {"IZNOS","N",17,8} ;
         }
dbcreate2(PRIVPATH+"por",aDbf)
O_POR   // select 95
index  on BRISANO TAG "BRISAN"
index  on POR  TAG "1" ;  set order to tag "1"
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

if cidtipdok$"11#27"
 if IsVindija()
  	private m:="------ ---------- ---------------------------------------- ------- ------ ------- ----------- --- ----------- ------ -----------"
 else
 	private m:="------ ---------- ---------------------------------------- ------- ------ ------- ----------- --- ----------- -----------"
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

_BrOtp:=space(8); _DatOtp:=ctod(""); _BrNar:=space(8); _DatPl:=ctod("")

if lDoks2
  d2k1 := SPACE(15)
  d2k2 := SPACE(15)
  d2k3 := SPACE(15)
  d2k4 := SPACE(20)
  d2k5 := SPACE(20)
  d2n1 := SPACE(12)
  d2n2 := SPACE(12)
endif

if val(podbr)=0  .and. val(rbr)==1
   aMemo:=ParsMemo(txt)
   if len(aMemo)>0
     cTxt1:=padr(aMemo[1],40)
   endif
   if len(aMemo)>=5
    cTxt2:=aMemo[2]
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
   if len(aMemo)>=9
    _BrOtp:=aMemo[6]; _DatOtp:=ctod(aMemo[7]); _BrNar:=amemo[8]; _DatPl:=ctod(aMemo[9])
   endif
   IF lDoks2
     IF len (aMemo)>=11
       d2k1 := aMemo[11]
     EndIF
     IF len (aMemo)>=12
       d2k2 := aMemo[12]
     EndIF
     IF len (aMemo)>=13
       d2k3 := aMemo[13]
     EndIF
     IF len (aMemo)>=14
       d2k4 := aMemo[14]
     EndIF
     IF len (aMemo)>=15
       d2k5 := aMemo[15]
     EndIF
     IF len (aMemo)>=16
       d2n1 := aMemo[16]
     EndIF
     IF len (aMemo)>=17
       d2n2 := aMemo[17]
     EndIF
   ENDIF
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
      cTxt2:=aMemo[2]
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

  UzmiIzIni(cIniName,'Varijable','Linija1',IzFmkIni("Zaglavlje","Linija1",gNFirma,KUMPATH),'WRITE')
  UzmiIzIni(cIniName,'Varijable','Linija2',IzFmkIni("Zaglavlje","Linija2","-",KUMPATH),'WRITE')
  UzmiIzIni(cIniName,'Varijable','Linija3',IzFmkIni("Zaglavlje","Linija3","-",KUMPATH),'WRITE')
  UzmiIzIni(cIniName,'Varijable','Linija4',IzFmkIni("Zaglavlje","Linija4","-",KUMPATH),'WRITE')
  UzmiIzIni(cIniName,'Varijable','Linija5',IzFmkIni("Zaglavlje","Linija5","-",KUMPATH),'WRITE')

endif

nLTxt2:=1
for i:=1 to len(cTxt2)
  if substr(cTxt2,i,1)=chr(13)
   ++nLTxt2
  endif
next
// zasto dodajem ???????  tri reda ???
if idtipdok $ "10#11"; nLTxt2+=3; endif

seek cidfirma+cidtipdok+cbrdok
private nStavkiDok:=0   // izbroj broj stavki dokumenta
do while idfirma==cidfirma .and. idtipdok==cidtipdok .and. brdok==cbrdok .and. !eof()
   ++nStavkiDok
   skip
enddo
seek cidfirma+cidtipdok+cbrdok

if fDelphiRB

   aDBf:={}
   AADD(aDBf,{ 'RBR'                 , 'C' ,   4 ,  0 })
   AADD(aDBf,{ 'SIFRA'               , 'C' ,  10 ,  0 })
   AADD(aDBf,{ 'BARKOD'              , 'C' ,  13 ,  0 })
   if gDest
   AADD(aDBf,{ 'DEST'                , 'C' ,  20 ,  0 })
   endif
   AADD(aDBf,{ 'NAZIV'               , 'C' ,  40 ,  0 })
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
   AADD(aDBf,{ 'CijenaMR'            , 'C' ,  12 ,  0 })  // cijena-rabat


   nSek0 := SECONDS()
   nSekW := VAL( IzFMKIni("FAKT","CekanjeNaSljedeciPozivDRB","6",KUMPATH) )
   DO WHILE FILE(PRIVPATH+"POM.DBF")
     FERASE(PRIVPATH+"POM.DBF")
     IF SECONDS()-nSek0 > nSekW
       IF Pitanje(,"Zauzet POM.DBF. Pokusati ponovo? (D/N)","D")=="D"
         nSek0 := SECONDS()
         LOOP
       ELSE
         goModul:quit()
       ENDIF
     ENDIF
   ENDDO

   dbcreate2(PRIVPATH+'POM.DBF',aDbf)
   select ( F_POM ); usex (PRIVPATH+'POM')
   INDEX ON RBR  TAG "1"
   select pripr
else
 POCNI STAMPU
 P_10CPI
 if gBold=="1";B_ON;endif
 StZaglav2(gVlZagl,PRIVPATH)
endif

cIdTipDok:=IdTipDok
dDatDok:=datdok
cBrDok:=brdok

StKupac(fDelphiRB)

if !fDelphiRB
 for i:=1 to gOdvT2; ?; next
 IF glDistrib .and. cIdTipDok $ "10#21"
   DiVoRel()
 ENDIF
 Zagl2()
endif


nUk:=0
nRab:=0
nZaokr:=ZAOKRUZENJE
cDinDEM:=dindem

if cIdTipDok$"06#16" .and. !( cDinDem $ valdomaca()+valpomocna() )
  nKurs:=1/OmjerVal(ValBazna(),cDinDem,datdok)
else
  nKurs:=Koef(cDinDem) // sve pozive "Koef(cDinDem)" zamijenio sam sa "nKurs"
endif

private nTekStavka:=0 // tekuca stavka dokumenta

do while idfirma==cidfirma .and. idtipdok==cidtipdok .and. brdok==cbrdok .and. !eof()

   NSRNPIdRoba()   // Nastimaj (hseek) Sifr.Robe Na Pripr->IdRoba

   ++nTekStavka
   if alltrim(podbr)=="."   .or. roba->tip="U"
      aMemo:=ParsMemo(txt)
      cTxt1:=padr(aMemo[1],40)
   endif
   if roba->tip="U"
      cTxtR:=aMemo[1]
   endif

   if alltrim(podbr)=="."
    if prow()>gERedova+48-nLTxt2  // prelaz na sljedecu stranicu ?
      if prow()>50   // nemoj na pola strane na novu stranu
        NStr0({|| Zagl2()}, (nStavkiDok-nTekStavka)>0 )
      endif
    endif

    if fDelphiRB
      select pripr
      select pom
      append blank
      replace rbr with pripr->(Rbr())
      replace naziv with KonvZnWin(@cTxt1,gKonvZnWin), kolicina with transform(PRIPR->(kolicina()),pickol)
      select pripr
    else

      ? space(gnLMarg)
      if cidtipdok=="12"; ?? space(5); endif
      ?? Rbr(),""
      if gVarF $ "13"
         ?? space(10),cTxt1,space(10),transform(kolicina(),pickol),space(3)
      else
         ?? cTxt1,space(10),transform(kolicina(),pickol),space(3)
      endif
    endif
    if cTI=="2"
       nRec:=recno()
       cRbr:=Rbr
       nUk2:=nRab2:=nPor2:=0
       do while !eof() .and. idfirma+idtipdok+brdok==cidfirma+cidtipdok+cbrdok.and. Rbr==cRbr
        if podbr=" ."
          skip; loop
        endif
        nUk2+=round(kolicina()*cijena*PrerCij()*nKurs,nZaokr)
        //nRab2+=round(kolicina()*cijena*PrerCij()*rabat/100*nKurs,nZaokr)
        nRab2+=round(cijena*kolicina()*PrerCij()*rabat/100*nKurs,nZaokr)
        nPor2+=round(kolicina()*cijena*PrerCij()*(1-rabat/100)*Porez/100*nKurs,nZaokr)
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
       else //fDelphiRB
           @ prow(),pcol()+1 SAY iif(kolicina==0,0,nUk2/kolicina()) pict piccdem
         if !(gVarF=="3" .and. cidtipdok=="12")
           @ prow(),pcol()+1 SAY cRab+"%"
         endif
         if gVarF=="2"
           @ prow(),pcol()+1 SAY iif(kolicina<>0,(nUk2-nRab2)/kolicina(),0) pict piccdem
         endif
         if nporez-int(nporez)<>0
           cPor:=str(nporez,3,1)
         else
           cPor:=str(nporez,3,0)
         endif
         if !(gVarF=="3" .and. cidtipdok=="12")
           @ prow(),pcol()+1 SAY cPor+"%"
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
           if !found(); append blank; replace por with cPor ;endif
             replace iznos with iznos+nPor2
             select pripr
           endif

    endif //tip=="2" - prikaz vrijednosti u . stavci
   else   // podbr nije "."
     if idtipdok $ "11#15#27"  // maloprodaja ili izlaz iz MP putem VP ili predr.MP
       select tarifa
       hseek roba->idtarifa
       IF IzFMKINI("POREZI","PPUgostKaoPPU","D")=="D"
         nMPVBP:=round( pripr->(cijena*nKurs*PrerCij()*kolicina())/(1+tarifa->zpp/100+tarifa->ppp/100)/(1+tarifa->opp/100) , nZaokr)
       ELSE
         nMPVBP:=round( pripr->(cijena*nKurs*PrerCij()*kolicina())/((1+tarifa->opp/100)*(1+tarifa->ppp/100)+tarifa->zpp/100) , nZaokr)
       ENDIF
       if tarifa->opp<>0
         select por
         seek "PPP "+str(tarifa->opp,6,2)
         if !found(); append blank; replace por with "PPP "+str(tarifa->opp,6,2) ;endif
         replace iznos with iznos+nMPVBP*tarifa->opp/100
       endif
       if tarifa->ppp<>0
         select por
         seek "PPU "+str(tarifa->ppp,6,2)
         if !found(); append blank; replace por with "PPU "+str(tarifa->ppp,6,2); endif
         replace iznos with iznos+nMPVBP*(1+tarifa->opp/100)*tarifa->ppp/100
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

    aSBr := Sjecistr( IF(glDistrib,ROBA->idtarifa,IF(BK_SB,ROBA->barkod,serbr)) ,;
                      IF(cIdTipDok=="16".or.BK_SB.and.!glDistrib,13,10) )

    if roba->tip="U"
     aTxtR:=SjeciStr(aMemo[1],iif(gVarF $ "13".and.!idtipdok$"11#27",51,40-IF(gNW=="R".and.idtipdok$"11#27",6,0)))   // duzina naziva + serijski broj
      if fdelphiRB
       select pom
       append blank  //prvo se stavlja naziv!!!
       replace naziv with pripr->(aMemo[1])
       select pripr
      endif
    else
     aTxtR:=SjeciStr(trim(roba->naz)+Katbr(),40-IF(gNW=="R".and.idtipdok$"11#27",6,0))
      if fdelphiRB
       cK1:=cK2:=""
       select pom
       append blank // prvo se stavlja naziv!!
       replace naziv with pripr->(trim(roba->naz)+iif(!empty(ck1+ck2)," "+ck1+" "+ck2,"")+Katbr()+IspisiPoNar())
       replace serbr with pripr->serbr
       select pripr
      endif
    endif

    if prow()>gERedova+48-len(aSbr)-nLTxt2  // prelaz na sljedecu stranicu ?
        NStr0({|| Zagl2()},(nStavkiDok-nTekStavka)>0)
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
      if cidtipdok=="12"; ?? space(5); endif
      ?? Rbr(),idroba
      nCTxtR:=pcol()+1
      @ prow(),nCTxtR SAY aTxtR[1]
    endif

    if !cIdTipDok$"11#27"
      if !(roba->tip="U") .and. gVarF $ "13"
        //nCTxtR:=pcol()+1
        if !fDelphiRB
          @ prow(),pcol()+1 SAY aSbr[1]
        endif
      endif
    else
      //nCTxtR:=pcol()+1
     if fDelphiRB
       select tarifa;hseek roba->idtarifa
       select pom
       replace POREZ1 with transform(tarifa->opp,"9999.9%")
       replace POREZ2 with transform(tarifa->ppp,"999.9%")
       select pripr
     else
      IF gNW=="R"
        @ prow(),pcol()+1 SAY PADR(ALLTRIM(serbr),5)
      ENDIF
      @ prow(),pcol()+1 SAY roba->idtarifa
      select tarifa;hseek roba->idtarifa
      @ prow(),pcol()+1 SAY tarifa->opp pict "9999.9%"
      @ prow(),pcol()+2 SAY tarifa->ppp pict "999.9%"
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

    if empty(podbr) .or. (!empty(podbr) .and. cTI=="1")
         if fDelphiRB
            select pom
            replace cijena with pripr->(transform(cijena*Koef(cDinDem),piccdem))
            select pripr
         else
            @ prow(),pcol()+1 SAY cijena*nKurs pict piccdem
         endif
         if rabat-int(rabat) <> 0
             cRab:=str(rabat,5,2)
         else
             cRab:=str(rabat,5,0)
         endif
           
	if cIdTipDok $ "11" .and. IsVindija()
         	if (gVarF=="3" .or. gVarF=="2")
               		@ prow(),pcol()+1 SAY cRab+"%"
             	endif
	endif
	   
	if !cidtipdok$"11#27"
             if !(gVarF=="3" .and. cidtipdok=="12")
               if fDelphiRB
                 select pom
                 replace Rabat with pripr->(cRab+"%")
                 select pripr
               else
                 @ prow(),pcol()+1 SAY cRab+"%"
               endif
             endif
             if gVarF=="2"
               if fDelphiRB
                 select pom
                 replace CijenaMR with pripr->(transform(cijena*(1-rabat/100)*Koef(cDinDem),piccdem))
                 select pripr
               else
                 @ prow(),pcol()+1 SAY cijena*(1-rabat/100)*nKurs  pict piccdem
               endif
             endif
             endif
	     if !cIdTipDok $ "11#27"
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
               if !(gVarF=="3" .and. cidtipdok=="12")
                 @ prow(),pcol()+1 SAY cPor+"%"
               endif
             endif
           endif

           nCol1:=pcol()+1

           if fDelphiRB
                select pom
                replace UKUPNO with pripr->(transform(round(kolicina()*cijena*Koef(cDinDem),nZaokr),picdem))
                select pripr
           else
             @ prow(),pcol()+1 SAY round( kolicina()*cijena*nKurs*PrerCij(), nZaokr) pict picdem
           endif
           nPor2:=round( kolicina()*nKurs*PrerCij()*cijena*(1-rabat/100)*Porez/100, nZaokr)

           if !fDelphiRB
             for i:=2 to len(aTxtR)
               @ prow()+1,nCTxtR  SAY aTxtR[i]
             next
           endif

           if nPor2<>0
              select por
              if roba->tip="U"
               cPor:="PPU "+ str(pripr->Porez,5,2)+"%"
              else
               cPor:="PPP "+ str(pripr->Porez,5,2)+"%"
              endif
              seek cPor
              if !found(); append blank; replace por with cPor ;endif
              replace iznos with iznos+nPor2
              select pripr
           endif
    endif


    nUk+=round(PrerCij()*kolicina()*cijena*nKurs,nZaokr)
    //nRab+=round(PrerCij()*kolicina()*cijena*nKurs*rabat/100,nZaokr)
    altd()
    
    if IsVindija()
   	// rabat racunaju po mpcbezporeza*rabat
	nRab+=round(nMPVBP*Rabat/100 , nZaokr)
    else
	nRab+=round( Cijena*kolicina()*PrerCij()*Rabat/100 , nZaokr)
    endif
    
   endif
   cCTSB:=serbr
   skip
   IF !EOF() .and. cIdTipDok=="16" .and. cCTSB<>serbr
      // podvuci kolonu polja SERBR (car.tarifa u racunu konsign.)
      ? space(gnLMarg); ?? mCTSB
   ENDIF
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

enddo
nRab:=round(nRab,nZaokr)
nUk:= round(nUk, nZaokr)

if !fDelphiRB
  ? space(gnLMarg); ??  m
endif

nPor2:=0 // treba mi iznos poreza da bih vidio da li cu stampati red "Ukupno"
select por; go top
do while !eof()
 nPor2+=round(Iznos,nZaokr); skip
enddo
select pripr

if fDelphiRB
   UzmiIzIni(cIniName,'Varijable','UkupnoRabat',transform(0,picdem),'WRITE')
   UzmiIzIni(cIniName,'Varijable','DINDEM',cDinDEM,'WRITE')
   UzmiIzIni(cIniName,'Varijable','Ukupno',transform(nUk,picdem),'WRITE')
endif

if !(cidtipdok $ "11#12#27") .and. (nRab<>0  .or. nPor2<>0)
  if !fDelphiRB
    ? space(gnLMarg); ??  padl("Ukupno ("+cDinDem+") :",98); @ prow(),nCol1 SAY nUk pict picdem
  endif
endif

if (cIdTipDok=="11" .and. IsVindija())
  if !fDelphiRB
    
    ? space(gnLMarg)
    ?? PADL("Ukupno ("+cDinDem+") :",98)
    @ prow(),nCol1 SAY nUk pict picdem
    
    ? space(gnLMarg)
    ?? PADL("Rabat  ("+cDinDem+") :",98)
    @ prow(),nCol1 SAY nRab pict picdem
    
  endif
endif


if !(cidtipdok $ "11#12#27") .and. nRab<>0
  if !fDelphiRB
    ? space(gnLMarg)
    	??  padl("Rabat ("+cDinDem+") :",98);  @ prow(),nCol1 SAY nRab pict picdem
  endif
endif

cPor:=""
nPor2:=0
if !cidtipdok$"11#27"
 select por
 go top
 nPorI:=0

  UzmiIzIni(cIniName,'Varijable','PorezStopa1',"-",'WRITE')
  UzmiIzIni(cIniName,'Varijable','Porez1',"0",'WRITE')
  for i:=2 to 5
    UzmiIzIni(cIniName,'Varijable','Porez'+alltrim(str(i)),"",'WRITE')
  next

  do while !eof()  // string poreza
     if fDelphiRB
       UzmiIzIni(cIniName,'Varijable','PorezStopa'+alltrim(str(++nPori)),trim(por),'WRITE')
       UzmiIzIni(cIniName,'Varijable','Porez'+alltrim(str(nPori)),transform(round(IF(cIdTipDok=="15",-1,1)*iznos,nzaokr),picdem),'WRITE')
     else
       ? space(gnLMarg); ?? padl(trim(por)+":",98); @ prow(),nCol1 SAY IF(cIdTipDok=="15",-1,1)*iznos pict picdem
     endif
     nPor2+=Iznos
     skip
  enddo
 nPor2 := IF(cIdTipDok=="15",-1,1) * nPor2
 select pripr
endif

nFZaokr:=round(nUk-nRab+nPor2,nZaokr)-round2(round(nUk-nRab+nPor2,nZaokr),gFZaok)
if gFZaok<>9 .and. round(nFzaokr,4)<>0
 if fDelphiRB
    UzmiIzIni(cIniName,'Varijable','Zaokruzenje',transform(nFZaokr,picdem),'WRITE')
 else
    ? space(gnLMarg); ?? padl("Zaokruzenje:",98); @ prow(),nCol1 SAY nFZaokr pict picdem
 endif
endif
cPom:=Slovima(round(nUk-nRab+nPor2-nFZaokr,nZaokr),cDinDem)
if fDelphiRB
   UzmiIzIni(cIniName,'Varijable','UkupnoMRabat',transform(round(nUk-nRab,nzaokr),picdem),'WRITE')
   UzmiIzIni(cIniName,'Varijable','UkupnoPorez',transform(round(nPor2,nzaokr),picdem),'WRITE')
   UzmiIzIni(cIniName,'Varijable','Ukupno2',transform(round(nUk-nRab+nPor2-nFzaokr,nzaokr),picdem),'WRITE')
   UzmiIzIni(cIniName,'Varijable','Slovima',cPom,'WRITE')
else
   ? space(gnLMarg); ??  m
   ? space(gnLMarg); ??  padl("U K U P N O  ("+cDinDem+") :",98); @ prow(),nCol1 SAY round(nUk-nRab+nPor2-nFZaokr,nZaokr) pict picdem
   ? space(gnLmarg)
   if cidtipdok=="12"; ?? space(5); endif
   if !empty(picdem)
     ?? "slovima: ",cPom
   endif
endif

if !fDelphiRB
  ? space(gnLMarg); ?? m
  ?

  if prow()>gERedova+48-nLTxt2  // prelaz na sljedecu stranicu ?
     NStr0({|| Zagl2()},.f.)
  endif
endif

if fDelphiRB
  ctxt2:=strtran(ctxt2,"ç"+Chr(10),"")
  ctxt2:=strtran(ctxt2,Chr(13)+Chr(10),Chr(13)+Chr(10))

  for i:=1 to 15
   UzmiIzIni(cIniName,'Varijable','KrajTxt'+alltrim(str(i)),"",'WRITE')
  next

  for i:=1 to numtoken(cTxt2,Chr(13)+Chr(10))
   UzmiIzIni(cIniName,'Varijable','KrajTxt'+alltrim(str(i)),"####"+token(KonvZnWin(@cTxt2,gKonvZnWin),Chr(13)+Chr(10),i),'WRITE')
  next
else
  ctxt2:=strtran(ctxt2,"ç"+Chr(10),"")
  ctxt2:=strtran(ctxt2,Chr(13)+Chr(10),Chr(13)+Chr(10)+space(gnLMarg))
  ? space(gnLMarg); ?? ctxt2
  ?
endif

if !fDelphiRB
 if cidtipdok$"11#27"
 select por ; go top
 ? space(gnLMarg); ?? "- Od toga porez: ----------"
 nUkPorez:=0
 do while !eof()
  ? space(gnLMarg); ?? por+"%   :"
  @ prow(),pcol()+1 SAY iznos pict  "9999999.999"
  nukporez+=iznos
  skip
 enddo
 ? space(gnLMarg); ?? "Ukupno :  "+space(5)
 @ prow(),pcol()+1 SAY nUkPorez pict "9999999.999"
 ? space(gnLMarg); ?? "---------------------------"
 select pripr
 select por; use
 endif
endif

if !fDelphiRB
 ?
 ?
 P_12CPI
endif

altd()
PrStr2T(cIdTipDok)

if gBold=="1";B_OFF;endif
if !fDelphiRB
  FF
  ZAVRSI STAMPU
else
  cSwitch:=""
  SELECT (F_POM); USE
  UzmiIzIni(EXEPATH+"FMK.INI",'DELPHIRB','Aktivan',"1",'WRITE')
#ifdef PROBA
  if IzFmkIni('FAKT','StampaWin2000','N',EXEPATH)=='D'
    private cKomLin:=cPoziv+" "+cRTM+" "+PRIVPATH+"  pom  1"
    private cKomLinF:=cPoziv+" "+cRTMF+" "+PRIVPATH+"  pom  1"
  else
    private cKomLin:="start /m t:\sigma\DelphiRB "+cRTM+" "+PRIVPATH+"  pom  1"
    private cKomLiF:="start /m t:\sigma\DelphiRB "+cRTMF+" "+PRIVPATH+"  pom  1"
  endif
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
 *  \brief Ispis zaglavlja
 */
 
static function Zagl2()
*{
P_COND
if !fDelphiRB
? space(gnLMarg); ?? m

if cidtipdok$"11#27"
  IF gNW=="R"
   ? space(gnLMarg); ?? " R.br  Sifra      Naziv                              KJ/KG Tarifa    PPP    PPU     kolicina  jmj    Cijena       Ukupno"
  ELSE
   ? space(gnLMarg)
   if IsVindija()
   	?? " R.br  Sifra      Naziv                                    Tarifa    PPP    PPU     kolicina  jmj    Cijena    Rab.     Ukupno"
   else
   	?? " R.br  Sifra      Naziv                                    Tarifa    PPP    PPU     kolicina  jmj    Cijena       Ukupno"
   endif
  ENDIF
else
 if glDistrib .and. cIdTipDok $ "10#21"
   camb:="  ambal."
 else
   camb:=""
 endif
 if gVarF $ "13"
   if gVarF=="3"  .and. cidtipdok=="12"
     ? space(gnLMarg); ?? "      R.br  Sifra      Naziv                                    "+JokSBr()+"    kolicina   jmj"+camb+"    Cijena    Ukupno"
   else
     ? space(gnLMarg); ?? " R.br  Sifra      Naziv                                    "+IF(cIdTipDok=="16","  Car.tar. ",JokSBr())+"    kolicina   jmj"+camb+"    Cijena    Rabat  Por    Ukupno"
   endif
 else
   ? space(gnLMarg); ?? " R.br  Sifra      Naziv                                      kolicina  jmj"+camb+"    Cijena   Rabat   Cijena-Rab  Por    Ukupno"
 endif
endif

? space(gnLMarg); ?? m
endif
return
*}



/*! \fn NStr0(bZagl,fPrenos)
 *  \brief Prelazak na novu stranu
 *  \param bZagl
 *  \param fPrenos
 */
 
static function NStr0(bZagl, fPrenos)
*{
if fPrenos=NIL
  fPrenos:=.f.  // ako je true -> stampaj prenos sa strane ....
endif

? space(gnLmarg); ?? m
? space(gnLmarg)
if cidtipdok=="12"; ?? space(5); endif


  ?? " *** Kraj strane "+str(++nStrana,3)+ ", prenos na stranu"+str(nStrana+1,3)+ "  nastavak  ->"
? space(gnLmarg); ?? m
FF
if gZagl=="1"  // zaglavlje na svakoj stranici
 P_10CPI
 if gBold=="1";B_ON;endif
 StZaglav2(gVlZagl,PRIVPATH)
 StKupac()
endif
if gBold=="1";B_ON;endif


if fPrenos
 Eval(bZagl)
 ? space(gnLmarg)
 if cidtipdok=="12"; ?? space(5); endif
 ?? " Prenos sa strane "+str(nStrana,3)+":"; @ prow(),nCol1  SAY nUk pict picdem
 ? space(gnLmarg); ?? m
else
 ? space(gnLmarg)
 if cidtipdok=="12"; ?? space(5); endif
 ?? "*********** Prenos sa strane "+str(nStrana,3)
 ? space(gnLmarg); ?? m
endif
*}


/*! \fn StKupac(fDelphiRB)
 *  \brief 
 *  \param fDelphiRB
 */
 
static function StKupac(fDelphiRB)
*{
local cMjesto:=padl(Mjesto(cIdFirma)+", "+dtoc(ddatdok),iif(gFPZag=99,gnTMarg3,0)+39)
//local cMjesto:=padl(Mjesto(cIdFirma)+", "+dtoc(ddatdok)+" godine",iif(gFPZag=99,gnTMarg3,0)+39)

lPharmaMAC := ( IzFMKINI("FAKT","PharmaMAC","N",KUMPATH)=="D" )

if fDelphiRB==NIL
 fDelphiRB:=.t.
endif


if gBold=="1";B_ON;endif

aPom:=Sjecistr(KonvZnWin(@cTxt3a,gKonvZnWin),30)

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
   UzmiIzIni(cIniName,'Varijable','Mjesto',cMjesto,'WRITE')
   if IzFmkIni("FAKT","Opcine","N",SIFPATH)=="D"
     UzmiIzIni(cIniName,'Varijable','KANTON',cKanton,'WRITE')
   endif
else
  IF IzFMKINI("FAKT","KupacDesno","N",KUMPATH)=="D"
    if !(cidtipdok$"10#06#16")
      @ prow(),6 SAY padr(Mjesto(cIdFirma)+", "+dtoc(ddatdok)+" godine",36)
      ?
    endif
    ? space(5+38),gPB_ON+"⁄ƒƒƒƒƒƒƒƒƒ"+IF(cIdTipDok=="06","KONSIGNATOR:","ƒƒƒƒƒƒƒƒƒƒƒƒ")+"ƒƒƒƒƒƒƒƒƒø"+gPB_OFF
    // ---------------- MS 07.04.01
    // ? space(6),gPB_ON+padc(alltrim(cTxt3a),30)+gPB_OFF
    aPom:=Sjecistr(cTxt3a,30)
    ? space(7+38);gPB_ON();?? padc(alltrim(aPom[1]),30);gPB_OFF()
    for i:=2 to len(aPom)
      ? space(7+38);gPB_ON();?? padc(alltrim(aPom[i]),30);gPB_OFF()
    next
    // ---------------- MS 07.04.01
    ? space(6+38),gPB_ON+padc(alltrim(cTxt3b),30)+gPB_OFF
    ? space(6+38),gPB_ON+padc(alltrim(cTxt3c),30)+gPB_OFF
    IF glDistrib .and. !EMPTY(cidpm)
      ? space(6+38),gPB_ON+padc(alltrim(cidpm),30)+gPB_OFF
    ENDIF
    ? space(5+38),gPB_ON+"¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ"+gPB_OFF
  ELSE
    if !(cidtipdok$"10#06#16") .and. (!lPharmaMAC .or. !(cidtipdok$"20#19"))
      @ prow(),36 SAY padl(Mjesto(cIdFirma)+", "+dtoc(ddatdok)+" godine",36)
      ?
    endif
    ? space(5),gPB_ON+"⁄ƒƒƒƒƒƒƒƒƒ"+IF(cIdTipDok=="06","KONSIGNATOR:","ƒƒƒƒƒƒƒƒƒƒƒƒ")+"ƒƒƒƒƒƒƒƒƒø"+gPB_OFF
    // ---------------- MS 07.04.01
    // ? space(6),gPB_ON+padc(alltrim(cTxt3a),30)+gPB_OFF
    aPom:=Sjecistr(cTxt3a,30)
    ? space(7);gPB_ON();?? padc(alltrim(aPom[1]),30);gPB_OFF()
    for i:=2 to len(aPom)
      ? space(7);gPB_ON();?? padc(alltrim(aPom[i]),30);gPB_OFF()
    next
    // ---------------- MS 07.04.01
    ? space(6),gPB_ON+padc(alltrim(cTxt3b),30)+gPB_OFF
    ? space(6),gPB_ON+padc(alltrim(cTxt3c),30)+gPB_OFF
    IF glDistrib .and. !EMPTY(cidpm)
      ? space(6),gPB_ON+padc(alltrim(cidpm),30)+gPB_OFF
    ENDIF
    ? space(5),gPB_ON+"¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ"+gPB_OFF
  ENDIF
endif

cStr:=cidtipdok+" "+trim(cbrdok)

private cpom:=""

cStrRN:=""

if !(cIdTipDok $ "00#01#19")
  cPom:="G"+cidtipdok+"STR"
  if !fDelphiRB
     cStr:=&cPom + " " + trim(BrDok)
  else
     cStr:=&cPom
  endif
elseif cIdTipDok=="19" .and. IzFMKIni("FAKT","I19jeOtpremnica","N",KUMPATH)=="D"
  cStr := "OTPREMNICA " + cStr
elseif cIdTipDok=="19" .and. IzFMKIni("FAKT","I19jeOtpremnica","N",KUMPATH)=="N"
  cStr := "IZLAZ POO " + cStr
elseif cIdTipDok=="01"
  IF lPovDob
    cStr := "POVRAT DOBAVLJACU " + cStr
  ELSE
    cStr := "ULAZ " + cStr
  ENDIF
elseif cIdTipDok=="00"
  cStr := "POCETNO STANJE " + cStr
elseif (lTrebovanje .and. !Empty(pripr->idRNal))
  cStr:="IZLAZ MATERIJALA br. " + cStr		
  cStrRN:=TRIM("PO RADNOM NALOGU br. "+pripr->idRNal)
endif

if fDelphiRB
  UzmiIzIni(cIniName,'Varijable','Dokument',cStr,'WRITE')
  UzmiIzIni(cIniName,'Varijable','BROJDOK',cBrDok,'WRITE')
  // ako se koristi i stara varijanta RTM-a
  //UzmiIzIni(cIniName,'Varijable','BROJ',cBrDok,'WRITE')
else
  if IzFMKINI("FAKT","KupacDesno","N",KUMPATH)=="D"
    ?
    ShowIdPar(cIdPartner,45,.f.)
    ? space(12)
    B_ON; ?? padc(cStr,50); B_OFF
    if lTrebovanje
    	? space(12)
    	B_ON; ?? padc(cStrRN,50); B_OFF
    endif
  else
    ShowIdPar(cIdPartner,7,.t.)
    ? space(35)
    B_ON; ?? padl(cStr,39); B_OFF
    if lTrebovanje
    	? space(35)
    	B_ON; ?? padl(cStrRN,39); B_OFF
    endif
  endif

endif

if !fDelphiRB
  ?
  if gBold=="1";B_ON;endif
endif


if cidtipdok=="10"

    if !fDelphiRB
      P_COND;? space(gnLMarg); P_10CPI
    endif

    altd()


    if !empty(_brOtp)
      if fDelphiRB
         UzmiIzIni(cIniName,'Varijable','BrOtp',_BrOtp,'WRITE')
         UzmiIzIni(cIniName,'Varijable','DatOtp',DTOC(_DatOtp),'WRITE')
      else
        ?? "Otpremnica broj :",_BrOtp
        if !empty(_Datotp)
          ?? " od",_DatOtp
        else
          ??  space(12)
        endif
      endif
    else
      if !fDelphiRB
        ?? space(38)
      endif
    endif

 if fDelphiRB
   UzmiIzIni(cIniName,'Varijable','DatFakt',dtoc(ddatdok),'WRITE')
 else
   ?? space(6),"Datum fakture :",ddatdok
   P_COND;? space(gnLMarg); P_10CPI
 endif

 if !empty(_brnar)
   if fDelphiRB
     UzmiIzIni(cIniName,'Varijable','BrNar',_brnar,'WRITE')
   else
      if gDest
       ?? "Ugovor/narudzba :",_brnar+", "+PRIPR->DEST
      else
       ?? "Ugovor/narudzba :",_brnar
      endif
   endif
 else
   ?? space(26)
 endif

 if fDelphiRB
   UzmiIzIni(cIniName,'Varijable','DatPl',dtoc(_datpl),'WRITE')
 else
   if gDest
     ?? space(18-LEN(PRIPR->DEST)), "Datum placanja:",_DatPl
     ?
   else
     ?? space(18), "Datum placanja:",_DatPl
     ?
   endif
 endif

elseif cIdTipDok=="06"
 if fDelphiRB
   //  ?????
 else
   P_COND; ? space(gnLMarg); P_10CPI
   ?? "Po ulaznoj fakturi broj:", _brotp
   ?? SPACE(1)
   ?? padl(Mjesto(cIdFirma)+", "+dtoc(ddatdok)+". godine",36)

   P_COND; ? space(gnLMarg); P_10CPI
   ?? "                i UCD-u:", _brnar
 endif
elseif cIdTipDok=="16" .or. lPharmaMAC.and.cIdTipDok$"19#20"
 P_COND; ? space(gnLMarg); P_10CPI
 @ prow(), 43 SAY padl(Mjesto(cIdFirma)+", "+dtoc(ddatdok)+". godine",36)
endif

IF cIdTipDok=="10" .and. lDoks2
  aDP777:=ListDodP()
  IF LEN(aDP777)>0
    FOR i:=1 TO LEN(aDP777)
      P_COND; ? space(gnLMarg)
      ?? aDP777[i]
    NEXT
  ENDIF
ENDIF

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



/*! \fn ListDodP()
 *  \brief Priprema liste dodatnih podataka
 *  \return aVrati
 */
 
function ListDodP()
*{
LOCAL aVrati:={}, nArr:=SELECT(), aPom:={}, cPom:=""
    IF !EMPTY(d2k1)
      AADD( aPom , IzFMKINI( "Doks2" , "ZK1" , "K1" , KUMPATH )+;
                   " "+TRIM(d2k1) )
    ENDIF
    IF !EMPTY(d2k2)
      AADD( aPom , IzFMKINI( "Doks2" , "ZK2" , "K2" , KUMPATH )+;
                   " "+TRIM(d2k2) )
    ENDIF
    IF !EMPTY(d2k3)
      AADD( aPom , IzFMKINI( "Doks2" , "ZK3" , "K3" , KUMPATH )+;
                   " "+TRIM(d2k3) )
    ENDIF
    IF !EMPTY(d2k4)
      AADD( aPom , IzFMKINI( "Doks2" , "ZK4" , "K4" , KUMPATH )+;
                   " "+TRIM(d2k4) )
    ENDIF
    IF !EMPTY(d2k5)
      AADD( aPom , IzFMKINI( "Doks2" , "ZK5" , "K5" , KUMPATH )+;
                   " "+TRIM(d2k5) )
    ENDIF
    IF !EMPTY(d2n1)
      AADD( aPom , IzFMKINI( "Doks2" , "ZN1" , "N1" , KUMPATH )+;
                   " "+ALLTRIM(STR(VAL(d2N1))) )
    ENDIF
    IF !EMPTY(d2n2)
      AADD( aPom , IzFMKINI( "Doks2" , "ZN2" , "N2" , KUMPATH )+;
                   " "+ALLTRIM(STR(VAL(d2N2))) )
    ENDIF
    IF LEN(aPom)>0
      AADD( aVrati, "Lista "+;
                    IzFMKINI("FAKT","Doks2opis","dodatnih podataka",KUMPATH)+;
                    ":" )
      cPom:=aPom[1]
      FOR i:=2 TO LEN(aPom)
        IF LEN(cPom+aPom[i])+2 <= 120
          IF !EMPTY(cPom); cPom+=", "; ENDIF
          cPom += aPom[i]
        ELSE
          AADD( aVrati, cPom )
          cPom := aPom[i]
        ENDIF
      NEXT
      IF !EMPTY(cPom)
         AADD( aVrati, cPom )
      ENDIF
    ENDIF
  SELECT (nArr)
return aVrati
*}


function RegPorBrGet(cRegBr,cPorDjBr)
*{
local cPom
cPom:=IzSifK("PARTN","REGB",cIdPartner,.f.)
if !empty(cPom)
	cRegBr:="Ident.br.: " + cPom
else
	cRegBr:=""
endif

cPom:=IzSifK("PARTN","PORB",cIdPartner,.f.)
if !empty(cPom)
	cPorDjBr:="Por.br.: " + cPom
else
	cPorDjBr:=""
endif

return
*}
