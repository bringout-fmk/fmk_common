#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/dok/1g/knjiz.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.31 $
 * $Log: knjiz.prg,v $
 * Revision 1.31  2004/05/06 14:30:01  sasavranic
 * Uvedena nova f-ja Iz22u10(), tigra
 *
 * Revision 1.30  2004/05/06 12:34:12  sasavranic
 * Funkcija filovanja azurirane 10-ke sa 22-kom u pripremi
 *
 * Revision 1.29  2004/02/12 15:37:16  sasavranic
 * Kopiranje podataka za novu grupu po uzoru na postojecu.
 *
 * Revision 1.28  2003/09/08 13:18:14  mirsad
 * sitne dorade za Hano - radni nalozi
 *
 * Revision 1.27  2003/08/21 08:12:08  mirsad
 * Specif.za Niagaru: - ukinuo setovanje mpc u sifr. pri unosu 13-ke, a uveo setovanje mpc u sifr. pri unosu 01-ice
 *
 * Revision 1.26  2003/08/01 09:42:48  sasa
 * ako nije nadjena banka nemoj ispisati nista
 *
 * Revision 1.25  2003/07/25 13:14:06  sasa
 * korekcije narudzbenice
 *
 * Revision 1.24  2003/07/24 15:58:13  sasa
 * stampa podataka o bankama na narudzbenici
 *
 * Revision 1.23  2003/07/06 21:50:54  mirsad
 * nova varijanta: unos radnog naloga na 12-ki (FMK.INI/KUMPATH/FAKT/RadniNalozi=D)
 *
 * Revision 1.22  2003/05/10 18:57:58  ernad
 * dodat opis za artikle u dokumentu
 *
 * Revision 1.21  2003/05/10 15:07:57  mirsad
 * dodatna polja za robne karakteristike u kumulativnoj bazi C1,C2,C3,N1,N2
 *
 * Revision 1.20  2003/04/25 10:44:36  ernad
 * ispravka za Planiku: parametar Cijena13MPC=D vise ne setuje MPC u sifrarniku pri promjeni cijene u unosu 13-ke
 *
 * Revision 1.19  2003/04/15 07:44:47  mirsad
 * ispravka: datum fakture ipak opet nudi sistemski, a ovaj put definitivno popuni zadani datum u svim stavkama fakture generisane na osnovu otpremnica
 *
 * Revision 1.18  2003/04/12 23:00:38  ernad
 * O_Edit (O_S_PRIREMA)
 *
 * Revision 1.17  2003/04/12 18:37:37  ernad
 * ImportTxt
 *
 * Revision 1.16  2003/03/28 15:38:10  mirsad
 * 1) ispravka bug-a pri gen.fakt.na osnovu otpremnica: sada se korektno setuje datum u svim stavkama
 * 2) ukinuo setovanje u proizvj.ini parametra "Broj" jer opet smeta (zbog njega se u reg.broj upisuje broj fakture)
 *
 * Revision 1.15  2003/03/16 10:07:16  ernad
 * rtf fakture
 *
 * Revision 1.14  2003/02/27 01:27:30  mirsad
 * male dorade za zips
 *
 * Revision 1.13  2003/01/19 23:44:17  ernad
 * test network speed (sa), korekcija bl.lnk
 *
 * Revision 1.12  2002/10/01 13:01:42  sasa
 * dorada za vindiju rabat na 11-ki
 *
 * Revision 1.11  2002/07/10 08:44:19  ernad
 *
 *
 * barkod funkcije kalk, fakt -> fmk/roba/barkod.prg
 *
 * Revision 1.10  2002/07/08 08:27:47  ernad
 *
 *
 * debug - uzimanje teksta na kraju fakture
 *
 * Revision 1.9  2002/07/05 10:27:12  mirsad
 * no message
 *
 * Revision 1.8  2002/07/04 14:13:07  mirsad
 * dokumentovanje ini parametara
 *
 * Revision 1.7  2002/07/04 08:34:19  mirsad
 * dokumentovanje ini parametara
 *
 * Revision 1.6  2002/07/03 12:21:49  sasa
 * funkcija FaktDisk() vise ne postoji, zamjenjena sa PrenosDiskete
 *
 * Revision 1.5  2002/06/27 17:20:33  ernad
 *
 *
 * dokument inventure, razrada, uvedena generacija dokumenta
 *
 * Revision 1.4  2002/06/27 14:03:20  ernad
 *
 *
 * dok/2g init
 *
 * Revision 1.3  2002/06/26 17:54:16  ernad
 *
 *
 * ciscenja - za dokument inventure
 *
 * Revision 1.2  2002/06/18 09:00:39  sasa
 * no message
 *
 * Revision 1.1.1.1  2002/06/17 18:30:18  ernad
 * no message
 *
 *
 */

/*! \file fmk/fakt/dok/1g/knjiz.prg
 *  \brief
 */


/*! \ingroup ini
  * \var *string FmkIni_KumPath_Doks2_ZK1
  * \brief Opis podatka koji se unosi u polje k1 tabele doks2
  * \param K1 - default vrijednost
  */
*string FmkIni_KumPath_Doks2_ZK1;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_Doks2_ZK2
  * \brief Opis podatka koji se unosi u polje k2 tabele doks2
  * \param K2 - default vrijednost
  */
*string FmkIni_KumPath_Doks2_ZK2;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_Doks2_ZK3
  * \brief Opis podatka koji se unosi u polje k3 tabele doks2
  * \param K3 - default vrijednost
  */
*string FmkIni_KumPath_Doks2_ZK3;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_Doks2_ZK4
  * \brief Opis podatka koji se unosi u polje k4 tabele doks2
  * \param K4 - default vrijednost
  */
*string FmkIni_KumPath_Doks2_ZK4;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_Doks2_ZK5
  * \brief Opis podatka koji se unosi u polje k5 tabele doks2
  * \param K5 - default vrijednost
  */
*string FmkIni_KumPath_Doks2_ZK5;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_Doks2_ZN1
  * \brief Opis podatka koji se unosi u polje n1 tabele doks2
  * \param N1 - default vrijednost
  */
*string FmkIni_KumPath_Doks2_ZN1;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_Doks2_ZN2
  * \brief Opis podatka koji se unosi u polje n2 tabele doks2
  * \param N2 - default vrijednost
  */
*string FmkIni_KumPath_Doks2_ZN2;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_19KaoRacunParticipacije
  * \brief Odredjuje da li ce se dokument 19 koristiti kao racun participacije
  * \param N - ne, default vrijednost
  * \param D - da, 19-ka se koristi kao racun participacije
  */
*string FmkIni_KumPath_FAKT_19KaoRacunParticipacije;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_Cijena13MPC
  * \brief Odredjuje da li ce se u 13-ki pohranjivati MPC bez obzira na sve ostale parametre
  * \param N - ne, default vrijednost
  * \param D - da, u 13-ki se pohranjuju MPC cijene
  */
*string FmkIni_KumPath_FAKT_Cijena13MPC;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_Doks2
  * \brief Odredjuje da li ce se koristiti tabela doks2 koja inace predstavlja dodatak tabeli doks
  * \param N - default vrijednost
  * \param D - koristi se i tabela doks2
  */
*string FmkIni_KumPath_FAKT_Doks2;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_Doks2opis
  * \brief Generalni opis za prozor unosa podataka koji se vode u tabeli doks2
  * \param dodatnih podataka - default vrijednost
  */
*string FmkIni_KumPath_FAKT_Doks2opis;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_Konsignacija
  * \brief Da li se vodi konsignaciona evidencija
  * \param N - ne, default vrijednost
  * \param D - da, omogucene opcije za konsignaciju
  */
*string FmkIni_KumPath_FAKT_Konsignacija;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_KupacMalaSlova
  * \brief Odredjuje da li se mogu za unos naziva kupca koristiti i mala slova
  * \param N - ne, default vrijednost
  * \param D - da, mogu i mala slova
  */
*string FmkIni_KumPath_FAKT_KupacMalaSlova;


/*! \ingroup ini
  * \var *string FmkIni_SifPath_FAKT_Opcine
  * \brief Odredjuje da li se pojavljuje opcina pri unosu partnera. Postoji i sifrarnik opcina.
  * \param N - default vrijednost
  * \param D - omogucava unos opcine u tabelu partnera
  */
*string FmkIni_SifPath_FAKT_Opcine;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_PPPNuditi
  * \brief Odredjuje da li ce se nuditi poreza na promet proizvoda pri unosu 10-ke tj.fakture
  * \param N - ne, default vrijednost
  * \param D - da, uvijek pri unosu 10-ke nuditi porez na promet proizvoda
  */
*string FmkIni_KumPath_FAKT_PPPNuditi;


/*! \ingroup ini
  * \var *string FmkIni_PrivPath_FAKT_PredracuniUvijekSaIznosima
  * \brief Da li ce se uvijek prikazivati iznosi na predracunima ili ce se to moci pri svakom izboru stampanja predracuna birati odgovorom na postavljeni upit
  * \param N - ne, default vrijednost
  * \param D - da, uvijek prikazuj iznose na predracunima
  */
*string FmkIni_PrivPath_FAKT_PredracuniUvijekSaIznosima;


/*! \ingroup ini
  * \var *string FmkIni_PrivPath_FAKT_StampajSveIzPripreme
  * \brief Odredjuje da li se pri izboru opcije stampanja dokumenta iz pripreme stampaju svi ili samo jedan dokument iz pripreme
  * \param N - ne stampaj sve odjednom, default vrijednost
  * \param D - da, odjednom odstampaj sve dokumente iz pripreme
  */
*string FmkIni_PrivPath_FAKT_StampajSveIzPripreme;


/*! \ingroup ini
  * \var *string FmkIni_SifPath_FAKT_TekVPC
  * \brief Odredjuje default VPC (ona koja se nudi)
  * \param 1 - VPC, default vrijednost
  * \param 2 - VPC2
  * \param 3 - VPC3
  */
*string FmkIni_SifPath_FAKT_TekVPC;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_TipDokXY_OmoguciUzimanjeFCJizKALK
  * \brief Moze uciniti dostupnom opciju uzimanja fakturne cijene na osnovu KALK-dokumenata za unos svih FAKT-dokumenata
  * \param N - moze samo u FAKT 25, default vrijednost
  * \param D - moze u svim FAKT-dokumentima
  */
*string FmkIni_KumPath_FAKT_TipDokXY_OmoguciUzimanjeFCJizKALK;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_UnosPartneraObaveznoPoSifri
  * \brief Omogucava varijantu unosa partnera na dokumentu iskljucivo pomocu sifre
  * \param N - ne mora preko sifre, default vrijednost
  * \param D - mora se unijeti sifra partnera
  */
*string FmkIni_KumPath_FAKT_UnosPartneraObaveznoPoSifri;


/*! \ingroup ini
  * \var *string FmkIni_SifPath_FAKT_VrstePlacanja
  * \brief Odredjuje da li se pojavljuje vrsta placanja pri unosu. Postoji i sifrarnik vrsta placanja.
  * \param N - default vrijednost
  * \param D - omogucava unos vrste placanja
  */
*string FmkIni_SifPath_FAKT_VrstePlacanja;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_FAKT_DatumRokPlacanja
  * \brief Odredjuje od kojeg polaznog datuma se racuna rok placanja
  * \param F - racunaj na osnovu datuma fakture, default vrijednost
  * \param O - racunaj na osnovu datuma otpremnice
  */
*string FmkIni_ExePath_FAKT_DatumRokPlacanja;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_FAKT_DelphiRB
  * \brief Da li se stampaju fakture preko delphija
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_ExePath_FAKT_DelphiRB;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_ProsiriPoljeOtpremniceNa50
  * \brief Prosirenje polja za unos broja otpremnice na 50 znakova
  * \param N - ne prosiruj, default vrijednost
  * \param D - prosiri na 50 znakova
  */
*string FmkIni_KumPath_FAKT_ProsiriPoljeOtpremniceNa50;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_FAKT_StampaViseDokumenata
  * \brief Ako je vise dokumenata u pripremi, kako se stampaju
  * \param N - samo se prvi moze odstampati, default vrijednost
  * \param D - ponudi meni dokumenata u pripremi
  */
*string FmkIni_ExePath_FAKT_StampaViseDokumenata;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_Fakt_DelphiRB
  * \brief Da li se stampaju fakture preko delphija
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_ExePath_Fakt_DelphiRB;


/*! \ingroup Stampa
  * \var *string FmkIni_PrivPath_OPRESA_Povrati
  * \brief Odredjuje da li se koriste specificnosti obrade povrata stampe
  * \param N - ne, default vrijednost
  * \param D - da, FAKT se koristi za unos povrata stampe
  */
*string FmkIni_PrivPath_OPRESA_Povrati;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_PoljeZaNazivPartneraUDokumentu_Prosiriti
  * \brief Odredjuje da li ce se prosiriti polje za unos naziva partnera u dokumentu sa 30 na 60 znakova
  * \param N - ne, default vrijednost
  * \param D - da, prosiri na 60 znakova
  */
*string FmkIni_KumPath_PoljeZaNazivPartneraUDokumentu_Prosiriti;


/*! \ingroup Stampa
  * \var *string FmkIni_KumPath_STAMPA_Opresa
  * \brief Odredjuje da li se koriste specificnosti obrade stampe
  * \param N - ne, default vrijednost
  * \param D - da, radi se o evidenciji stampe
  */
*string FmkIni_KumPath_STAMPA_Opresa;


/*! \ingroup ini
  * \var *string FmkIni_SifPath_SifRoba_DuzSifra
  * \brief Odredjuje sirinu polja za unos sifre robe
  * \param 10 - default vrijednost
  */
*string FmkIni_SifPath_SifRoba_DuzSifra;


/*! \ingroup ini
  * \var *string FmkIni_SifPath_SifRoba_ID_J
  * \brief Omogucava koristenje dodatnih skrivenih sifara robe
  * \param N - default vrijednost
  * \param D - koriste se dodatne skrivene sifre robe
  */
*string FmkIni_SifPath_SifRoba_ID_J;


/*! \ingroup ini
  * \var *string FmkIni_PrivPath_UpitFax_PitatiZaFax
  * \brief Odredjuje da li ce se prilikom stampanja dokumenta pojavljivati upit "Zelite li dokument za slanje faksom?"
  * \param N - ne, default vrijednost
  * \param D - da, pojavljivace se upit za slanje faksom
  */
*string FmkIni_PrivPath_UpitFax_PitatiZaFax;


/*! \fn Knjiz()
 *  \brief Knjizenje naloga
 */
 
function Knjiz()
*{
// da li je ocitan barkod
private gOcitBarkod:=.f.
private fID_J:=.f.
private lVrsteP := ( IzFmkIni("FAKT","VrstePlacanja","N",SIFPATH)=="D" )
private lOpcine := ( IzFmkIni("FAKT","Opcine","N",SIFPATH)=="D" )
private gTBDir:="N"

O_Edit()
select pripr

if idTipDok=="IM"
	close all
	FaUnosInv()
	return
endif

if IzFMKINI('SifRoba','ID_J','N', SIFPATH)=="D"
	fId_J:=.t.
endif

lOpresaPovrati:=(IzFMKINI("OPRESA","Povrati","N",PRIVPATH)=="D" )

if gDirektEdit=="D"
  // direkt edit
  private  gTBDir:="D"
  Scatter()  // uzmi prvi red
  private  bGoreRed:={|| PrGoreRed()}
  private  bDoleRed:={|| PrDoleRed()}
  private  bDodajRed:={|| PrDodajRed() }
  private  fTBNoviRed:=.f. // trenutno smo u novom redu ?
  private  TBCanClose:=.t. // da li se moze zavrsiti unos podataka ?
  private  bZaglavlje:={|| PrZaglavlje()}
           // zaglavlje se edituje kada je kursor u prvoj koloni
           // prvog reda
  private  TBSkipBlock:={|nSkip| SkipDB(nSkip, @nTBLine)}
  private  TBScatter:="D"  // scatteruj bazu - uzmi iz baze kada radiç get
  private  TBAppend:="D"
  private  nTBLine:=1      // tekuca linija-kod viselinijskog browsa
  private  nTBLastLine:=1  // broj linija kod viselinijskog browsa
  private  TBPomjerise:="" // ako je ">2" pomjeri se lijevo dva
                           // ovo se mo§e setovati u when/valid fjama
  // varijable koje se inicijalizuju iz baze
  private TRabat:="%"
  private _txt1:=_txt2:=_txt3a:=_txt3b:=_txt3c:=""
          // txt1  -  naziv robe,usluge
  if IzFmkIni('FAKT','ProsiriPoljeOtpremniceNa50','N',KUMPATH)=='D'
    private _BrOtp:=space(50)
  else
    private _BrOtp:=space(8)
  endif
  private _DatOtp:=ctod("")
  private _BrNar:=space(8)
  private _DatPl:=ctod("")
  private _VezOtpr := ""
  private nRbr:=RbrUnum(_Rbr)


cDSFINI:=IzFMKINI('SifRoba','DuzSifra','10', SIFPATH)

ImeKol:={}
AADD(ImeKol,{"Rbr",        {|| rbr }, "nRbr", {|| nRbr:=val(rbr),.t.}, {|| tb_V_rbr() }, ">", "999" }     )
//AADD(ImeKol,{"Pbr",        {|| podbr }, "Podbr", {|| .t.}, {|| .t. }, ">" }     )
AADD(ImeKol,{"Roba",       {|| StIdROBA() }, "idroba", {|| tb_W_IdRoba() }, {|| tb_V_IdRoba()}, ">1", "@!S10" }   )
AADD(ImeKol,{"Naziv",      {|| tbRobaNaz() } }   )
AADD(ImeKol,{"Kolicina",   {|| transform(kolicina,pickol)}, "kolicina", {|| .t. } , {|| tb_V_Kolicina() },iif(gSamokol="D".or.lOpresaPovrati,"V1",">1"), PicKol }  )

if gSamoKol!="D"
 AADD(ImeKol,{"Cijena",     {|| transform(Cijena,piccdem) } , "cijena", {|| tb_W_Cijena()} , {|| tb_V_Cijena()}, ">" , piccdem} )

 if !lOpresaPovrati
  aTRabat:={  ;
     { "TRabat", {|| tb_W_Trabat()}, {|| tb_V_Trabat()}, "@!" } ;
  }
  // dodatna varijabla sa rabatom
  AADD(ImeKol,{"Rab.",    {|| transform(Rabat,"99.99")  } ,;
                          "Rabat",                         ;
                          {|| .t.} ,;
                          {|| tb_v_Rabat() } ,;
                           ">",;
                          "9999.999",;
                          aTRabat ;
                };
       )
  AADD(ImeKol,{"Por",           {|| transform(Porez,"99.9") } ,"porez" , {|| tb_W_Porez()}, {||  tb_V_Porez()},"V1" ,"99.9" } )
 endif
endif

if pripr->(fieldpos("k1"))<>0 .and. gDK1=="D"
  AADD(ImeKol,{ "K1", {|| k1}, "k1", {||.t.}, {||.t.} })
endif
if pripr->(fieldpos("k2"))<>0 .and. gDK2=="D"
  AADD(ImeKol,{ "K2", {|| k2}, "k2", {||.t.}, {||.t.} })
endif

if lPoNarudzbi
  AADD(ImeKol,{ "BrNar", {|| brojnar}, "brojnar", {||.t.}, {||.t.} })
  AADD(ImeKol,{ "IdNar", {|| idnar}, "idnar", {||.t.}, {||.t.} })
endif

Kol:={}; for i:=1 to len(ImeKol); AADD(Kol,i); next


adImeKol:={}
for i:=1 to LEN(ImeKol); AADD(adImeKol,ImeKol[i]); next
adKol:={}; for i:=1 to len(adImeKol); AADD(adKol,i); next

private cTipVPC:="1"
if gVarC $ "123"
  cTipVPC:=IzFmkIni("FAKT","TekVPC","1",SIFPATH)
endif

// PushHT("Unos,ispravka")
Box(,21,77)
TekDokument()

if lOpresaPovrati
 @ m_x+16,m_y+2 SAY "Ú <c-P> Stampa dokumenta ¿"
 @ m_x+17,m_y+2 SAY "³ <a-A> Azuriranje       ³"
 @ m_x+18,m_y+2 SAY "³ <c-T> Brisi Stavku     ³"
 @ m_x+19,m_y+2 SAY "³ <c-F9> Brisi pripremu  ³"
 @ m_x+20,m_y+2 SAY "³ <F10>  Ostale opcije   ³"
 @ m_x+21,m_y+2 SAY "À <ENT> na RBr 1 ispravkaÙ"
endif
ObjDbedit("PNal",21,77,{|| EdPripr()},"","Priprema..."+"ÍÍÍÍ<a-N> narudzb.kupca"+"ÍÍÍÍ<a-U> ugov.o rabatu"+IF(gNovine=="D",REPL("Í",4)+"<a-I> rekap.zad.",""), , , , ,6)
BoxC()
// PopHT()

else
// stari edit

private ImeKol:={ ;
          {"Red.br",        {|| Rbr() } } ,;
          {"Roba",          {|| Roba()  } } ,;
          {"Kolicina",      {|| kolicina } } ,;
          {"Cijena",        {|| Cijena } , "cijena" } ,;
          {"Rabat",         {|| Rabat  } ,"Rabat"} ,;
          {"Porez",         {|| Porez  } ,"porez"} ,;
          {"RJ",            {|| idfirma   }, "idfirma" }, ;
          {"Serbr",         {|| SerBr   }, "serbr" }, ;
          {"Partn",         {|| IdPartner   }, "IdPartner" }, ;
          {"IdTipDok",         {|| IdTipDok  }, "Idtipdok" }, ;
          {"Brdok",         {|| Brdok  }, "Brdok" }, ;
          {"DatDok",         {|| DATDOK  }, "DATDOK" } ;
        }

if glRadNal
	AADD(ImeKol, { "Rad.nalog", {|| idrnal}, "idrnal" })
endif

if pripr->(fieldpos("k1"))<>0 .and. gDK1=="D"
  AADD(ImeKol,{ "K1",{|| k1}, "k1" })
  AADD(ImeKol,{ "K2",{|| k2}, "k2" })
endif

if glDistrib
  AADD( ImeKol , { "Prod.mj." , {|| idpm     }, "IDPM"     } )
  AADD( ImeKol , { "ID distr.", {|| iddist   }, "IDDIST"   } )
  AADD( ImeKol , { "ID relac.", {|| idrelac  }, "IDRELAC"  } )
  AADD( ImeKol , { "ID vozila", {|| idvozila }, "IDVOZILA" } )
  AADD( ImeKol , { "Marsruta" , {|| marsruta }, "MARSRUTA" } )
endif

if lPoNarudzbi
  AADD(ImeKol,{ "BrNar", {|| brojnar}, "brojnar", {||.t.}, {||.t.} })
  AADD(ImeKol,{ "IdNar", {|| idnar}, "idnar", {||.t.}, {||.t.} })
endif

Kol:={}; for i:=1 to len(ImeKol); AADD(Kol,i); next

private cTipVPC:="1"
if gVarC $ "123"
  cTipVPC:=IzFmkIni("FAKT","TekVPC","1",SIFPATH)
endif


Box(,21,77)
TekDokument()
@ m_x+18,m_y+2 SAY " <c-N> Nove Stavke       ³<ENT> Ispravi stavku      ³<c-T> Brisi Stavku "
@ m_x+19,m_y+2 SAY " <c-A> Ispravka Dokumenta³<c-P> Stampa (TXT)        ³<a-F10> Asistent  "
@ m_x+20,m_y+2 SAY " <a-A> Azuriranje dok.   ³<c-F9> Brisi pripremu     ³<F5>  Kontrola zbira  "
@ m_x+21,m_y+2 SAY " <R> Rezerv  <X> Prekid R³<F10>  Ostale opcije      ³<F9> 20,12->10; 27->11"
ObjDbedit("PNal",21,77,{|| EdPripr()},"","Priprema..."+"ÍÍÍÍ<a-N> narudzb.kupca"+"ÍÍÍÍ<a-U> ugov.o rabatu"+IF(gNovine=="D",REPL("Í",4)+"<a-I> rekap.zad.",""), , , , ,4)
BoxC()

endif
closeret
*}



/*! \fn TekDokument()
 *  \brief Tekuci dokument
 */
 
function TekDokument()
*{
local nRec,aMemo,ctxt
cTxt:=padr("-",60)
if reccount2()<>0
  nRec:=recno()
  go top
  aMemo:=ParsMemo(txt)
  if len(aMemo)>=5
    cTxt:=trim(amemo[3])+" "+trim(amemo[4])+","+trim(amemo[5])
  else
    cTxt:=""
  endif
  cTxt:=padr(cTxt,30)
  cTxt:=" "+alltrim(cTxt)+", Broj: "+idfirma+"-"+idtipdok+"-"+brdok+", od "+dtoc(datdok)+" "
  go nRec
endif
@ m_x+0,m_y+2 SAY cTxt
return
*}





/*! \fn Rbr()
 *  \brief Redni broj
 */
 
function Rbr()
*{
local cRet
if eof()
   cret:=""
elseif val(pripr->podbr)==0
   cRet:=pripr->rbr+")"
else
   cRet:=pripr->rbr+"."+alltrim(pripr->podbr)
endif
return padr(cRet,6)
*}

/*! \fn Roba()
 *  \brief 
 */
 
function Roba()
*{
local cRet
cRet:=trim(StIdROBA())+" "
if eof()
  cRet:=""
elseif alltrim(podbr)=="."
  aMemo:=ParsMemo(txt)
  cRet:=aMemo[1]
else
 dbselectarr(F_ROBA)
 if gNovine=="D"
   seek PADR(LEFT(PRIPR->idroba,gnDS),LEN(PRIPR->idroba))
   if !FOUND() .or. ROBA->tip!="S"
     seek PRIPR->IdRoba
   endif
 else
   seek PRIPR->IdRoba
 endif
 dbselectarr(F_PRIPR)
 cRet+=ROBA->naz
endif
return padr(cRet,30)
*}


/*! \fn JedinaStavka()
 *  \brief U dokumentu postoji samo jedna stavka
 */
 
function JedinaStavka()
*{
nTekRec := RECNO()
nBrStavki := 0
cIdFirma := IdFirma
cIdTipDok := IdTipDok
cBrDok    := BrDok
go top
HSEEK cIdFirma+cIdTipDok+cBrDok
do while ! eof () .and. (IdFirma==cIdFirma) .and. (IdTipDok==cIdTipDok) ;
      .AND. (BrDok==cBrDok)
   nBrStavki++
   SKIP
enddo
GO nTekRec
return IIF(nBrStavki==1, .t., .f.)
*}


/*! \fn EdPripr
 *  \brief Sprema pripremu za unos/ispravku dokumenta
 *  \brief Priprema ekran i definise tipke (c+N,a+A...)
 *  \todo Ovu funkciju definitivno treba srediti....
 */
 
function EdPripr()
*{
// poziva je ObjDbedit u KnjNal
local nTr2
local cPom
local cENTER:=chr(K_ENTER)+chr(K_ENTER)+chr(K_ENTER)

if (Ch==K_ENTER  .and. Empty(BrDok) .and. EMPTY(rbr))
	return DE_CONT
endif

TekDokument()

select pripr
do case
	case (Ch==K_CTRL_T .or. (Ch=K_DEL .and. gTBDir=="D"))
     		if BrisiStavku()==1
     			return DE_REFRESH
		else
			return DE_CONT
		endif
	case Ch==K_ENTER .and. gTBDir="N"
    		Box("ist",19,75,.f.)
   		Scatter()
    		nRbr:=RbrUnum(_Rbr)
    		// PushHT("Elementi")
    		if EditPripr(.f.)==0
     			// PopHt()
     			BoxC()
     			return DE_CONT
    		else
     			// PopHt()
     			Gather()
			PrCijSif()  // ako treba, promijeni cijenu u sifrarniku
			BoxC()
     			return DE_REFRESH
    		endif
	case Ch==K_CTRL_A  .and. gTBDir="N"
        	ProdjiKrozStavke()
        	return DE_REFRESH
	case Ch==K_CTRL_N  .and. gTBDir="N"
        	NoveStavke()
        	return DE_REFRESH
	case Ch=K_CTRL_P
        	PrintDok()
        	return DE_REFRESH
	case Ch==K_ALT_L
        	close all
         	FaLabelBKod()
         	O_edit()
	case Ch==K_ALT_P
        	if !CijeneOK("Stampanje")
           		return DE_REFRESH
        	endif
        	if EMPTY(NarBrDok())
           		return DE_REFRESH
        	endif
		cPom:=idtipdok
        	close all
		if cPom=="13"
          		StOLPP()
        	else
          		StampRtf(PRIVPATH+"fakt.rtf", nil, cPom)
        	endif
        	close all
        	O_Edit()
        	return DE_REFRESH
	case Ch=K_ALT_A
        	if !CijeneOK("Azuriranje")
           		return DE_REFRESH
        	endif
        	CLOSE ALL
        	Azur()
        	O_Edit()
        	if gDirektEdit=="D"
          		KEYBOARD REPL(CHR(K_LEFT),8)
        	endif
        	return DE_REFRESH
	case Ch==K_CTRL_F9
		BrisiPripr()
        	return DE_REFRESH
	case Ch==K_F5
        	// kontrola zbira
        	nRec:=RecNo()
        	Box(,12,72)
          		nDug2:=nRab2:=nPor2:=0
          		cDinDem:=dindem
          		nC:=1
          		KonZbira()
          		if nC>9
            			InkeySc(0)
            			@ m_x+1,m_y+2 CLEAR to m_x+12,m_y+70
            			nC:=1
				@ m_x,m_y+2 SAY ""
          		endif
			@ m_x+nC,m_y+2 SAY Replicate("-",65)
            		@ m_x+nC+1,m_y+2   SAY "Ukupno   "
            		@ m_x+nC+1,col()+1 SAY nDug2      pict "9999999.99"
            		@ m_x+nC+1,col()+1 SAY nRab2      pict "9999999.99"
            		@ m_x+nC+1,col()+1 SAY nDug2-nRab2 pict "9999999.99"
            		@ m_x+nC+1,col()+1 SAY nPor2 pict          "9999999.99"
            		@ m_x+nC+1,col()+1 SAY nDug2-nRab2+nPor2 pict "9999999.99"
            		@ m_x+nC+1,col()+1 SAY "("+cDinDem+")"
           		InkeySc(0)
        	BoxC()
        	go nRec
        	return DE_CONT
	case UPPER(Chr(Ch))  $ "RX"
        	go top
        	if idtipdok $ "20#27"
         		do while !eof()
           			if UPPER(Chr(Ch))=="R"
            				replace serbr with "*"
           			elseif UPPER(Chr(Ch))=="X"
            				replace serbr with ""
           			endif
           			skip
         		enddo
        	endif
        	Beep(1)
        	go top
        	return DE_REFRESH
	case UPPER(Chr(Ch))=="R"
        	return DE_REFRESH
	case Ch==K_F8
		if IsTigra()
			Iz22u10()
			return DE_REFRESH
		else
			NotImp()
		endif
	case Ch==K_F9
        	Iz20u10()  // izvrsena zamjena
        	return DE_REFRESH
	case Ch==K_ALT_F10
      		private nEntera:=30
      		for iSekv:=1 to INT(RecCount2()/15)+1
       			cSekv:=chr(K_CTRL_A)
       			for nKekk:=1 to MIN(RecCount2(),15)*20
        			cSekv+=cEnter
       			next
       			keyboard cSekv
      		next
      		return DE_REFRESH
	case Ch==K_F10
       		PopupKnjiz()
       		SETLASTKEY(K_CTRL_PGDN)
       		return DE_REFRESH
	case Ch=K_ALT_I
       		RekZadMpO()
       		O_Edit()
       		return DE_REFRESH
	case Ch=K_ALT_N
       		SELECT PRIPR
		nRec:=RECNO()
       		GO TOP
       		StNarKup()
       		GO (nRec)
       		return DE_CONT
	case Ch=K_ALT_U
       		SELECT PRIPR
		nRec:=RECNO()
       		GO TOP
       		StUgRabKup()
       		O_Edit()
       		SELECT PRIPR
       		GO (nRec)
       		return DE_CONT
endcase

return DE_CONT
*}

function BrisiStavku()
*{
cSecur:=SecurR(KLevel,"BRISIGENDOK")
if m1="X" .and. ImaSlovo ("X", cSecur)   // pripr->m1
       Beep(1)
       Msg("Dokument izgenerisan, ne smije se brisati !!",0)
       return 0
endif
if Pitanje(,"Zelite izbrisati ovu stavku ?","D")=="D"
        if (RecCount2 () == 1) .OR. JedinaStavka ()
           SELECT DOKS
           HSEEK PRIPR->IdFirma+PRIPR->IdTipDok+PRIPR->BrDok
           if FOUND () .AND. DOKS->M1 == "Z"
              // dokument zapisan samo u DOKS-u
              DELETE
           endif
           SELECT PRIPR
        endif
	delete
        return 1
endif
return 0
*}

function ProdjiKrozStavke()
*{	
PushWA()

select PRIPR
// go top
Box(,19,75,.f.,"")
nDug:=0
do while !eof()
   skip; nTR2:=RECNO(); skip-1
   Scatter()
   nRbr:=RbrUnum(_Rbr)
   //@ m_x+1,m_y+1 CLEAR to m_x+21,m_y+76
   BoxCLS()
   if EditPripr(.f.)==0
     exit
   endif
   nDug+=round( _Cijena*_kolicina*PrerCij()*(1-_Rabat/100)*(1+_Porez/100) , ZAOKRUZENJE)
   @ m_x+20,m_y+2 SAY "ZBIR DOKUMENTA:"
   @ m_x+20,col()+1 SAY nDug PICTURE '9 999 999 999.99'
   inkeySc(10)
   select PRIPR
   Gather()
   PrCijSif()      // ako treba, promijeni cijenu u sifrarniku
   go nTR2
 enddo
 PopWA()
BoxC()

return
*}

function NoveStavke()
*{

nDug:=nPrvi:=0
go top
do while .not. eof() // kompletan nalog sumiram
   nDug+=round( Cijena*Kolicina*PrerCij()*(1-Rabat/100)*(1+Porez/100) , ZAOKRUZENJE)
   skip
enddo
go bottom
Box("knjn",19,77,.f.,"Unos novih stavki")
do while .t.
   Scatter()
   if alltrim(_podbr)=="." .and. empty(_idroba)
    nRbr:=RbrUnum(_Rbr)
    _PodBr:=" 1"
   elseif _podbr>=" 1"
    nRbr:=RbrUnum(_Rbr)
    _podbr:= str(val(_podbr)+1,2)
   else
    nRbr:=RbrUnum(_Rbr)+1
    _PodBr:="  "
   endif
   BoxCLS()
   _c1:=_c2:=_c3:=SPACE(20)
   _opis:=space(120)
   _n1:=_n2:=0
   if EditPripr(.t.)==0
     exit
   endif
   nDug+=round( _Cijena*_Kolicina*PrerCij()*(1-_Rabat/100)*(1+_Porez/100) , ZAOKRUZENJE)
   @ m_x+20,m_y+2 SAY "ZBIR DOKUMENTA:"
   @ m_x+20,col()+2 SAY nDug PICTURE '9 999 999 999.99'
   inkeySc(10)
   select PRIPR
   APPEND BLANK
   Gather()
   PrCijSif()      // ako treba, promijeni cijenu u sifrarniku
enddo
BoxC()

return
*}

function PrintDok()
*{

SpojiDuple()  // odradi ovo prije stampanja !

SrediRbr()
O_Edit() // sredirbr zatvori pripremu !!

if gTBDir=="D"
   if eof()
     skip -1
   endif
endif

if !CijeneOK ("Stampanje")
   return DE_REFRESH
endif
if EMPTY(NarBrDok ())
   return DE_REFRESH
endif

if IzFMKIni("FAKT","StampajSveIzPripreme","N",PRIVPATH)=="D"
  lSSIP99:=.t.
else
  lSSIP99:=.f.
endif

lJos:=.t.
if lSSIP99

  if IzFMKIni('FAKT','DelphiRB','N')=='D'
    UzmiIzIni(EXEPATH+"FMK.INI",'DELPHIRB','Aktivan',"0",'WRITE')
  else
    StartPrint(.t.)
  endif

  if IzFMKIni("STAMPA","Opresa","N",KUMPATH)=="D"
    gRPL_gusto()
    nDokumBr:=0
  endif
endif
do while lJos
  if gNovine=="D" .or. (IzFMKINI('FAKT','StampaViseDokumenata','N')=="D")
    lJos:=StViseDokMenu()
    if LEN(gFiltNov)==0
      GO TOP
      exit
    endif
  else
    lJos:=.f.
  endif
  cPom:=idtipdok
  StampTXT(nil,cPom,nil)
  O_Edit()
enddo
if lSSIP99
  if IzFMKIni("STAMPA","Opresa","N",KUMPATH)=="D"
    gRPL_normal()
  endif
  if ! (IzFMKIni('FAKT','DelphiRB','N')=='D')
    EndPrint()
  endif
endif

lSSIP99:=.f.

return
*}


function RekZadMpO()
*{

SELECT PRIPR
GO TOP
cSort1:="IzSifK('PARTN','LINI',idpartner,.f.)+idroba"
cFilt1:="idtipdok=='13'.and.idfirma=="+cm2str(PRIPR->idfirma)
INDEX ON &cSort1 to "TMPPRIPR" for &cFilt1
GO TOP
StartPrint()
? "FAKT,",date(),", REKAPITULACIJA ZADUZENJA MALOPRODAJNIH OBJEKATA"
? ; IspisFirme(PRIPR->idfirma)
?
do while !EOF()
  cLinija:=IzSifK('PARTN','LINI',idpartner,.f.)
  ? "LINIJA:",cLinija
  ? "---------- ---------------------------------------- ----------"
  ? "  SIFRA                NAZIV ARTIKLA                 KOLICINA "
  ? "---------- ---------------------------------------- ----------"
  do while !EOF() .and. cLinija==IzSifK('PARTN','LINI',idpartner,.f.)
    cIdRoba:=idroba; nKol:=0
    SELECT ROBA; SEEK LEFT(cIdRoba,gnDS); SELECT PRIPR
    do while !EOF() .and.;
	     cLinija==IzSifK('PARTN','LINI',idpartner,.f.) .and.;
	     idroba==cIdRoba
      nKol += kolicina
      SKIP 1
    enddo
    ? cIdRoba, ROBA->naz, STR(nKol,10,0)
  enddo
  ? "---------- ---------------------------------------- ----------"
  ?
  if !EOF()
    FF
  endif
enddo
FF
EndPrint()
CLOSE ALL
return     
*}

/*! \fn CijeneOK(cStr)
 *  \brief
 *  \param cStr
 */
 
function CijeneOK(cStr)
*{
local fMyFlag := .F., lRetFlag := .T., nTekRec
  SELECT PRIPR
  nTekRec := RECNO ()
  if PRIPR->IdTipDok $ "10#11#15#20#25#27"
     // PROVJERI IMA LI NEODREDJENIH CIJENA ako se radi o fakturi
     Scatter()
     SET ORDER to 1
     Seek2 (_IdFirma + _IdTipDok + _BrDok)
     do while ! EOF() .AND. IdFirma == _IdFirma .AND. ;
           IdTipDok == _IdTipDok .AND. BrDok == _BrDok
        if Cijena == 0 .and. EMPTY (PodBr)
           Beep (3)
           Msg ("Utvrdjena greska na stavci broj " + ;
                ALLTRIM (rbr) + "!#" + ;
                "CIJENA NIJE ODREDJENA!!!", 30)
           fMyFlag := .T.
        endif
        SKIP
     END
     if fMyFlag
        Msg (cStr+" nije dozvoljeno!#Vracate se na pripremu!", 30)
        lRetFlag := .F.
     endif
  endif
  GO nTekRec
return (lRetFlag)
*}



/*! \fn EdOtpr(Ch)
 *  \brief Ispravka otpremnica
 *  \param Ch
 */

function EdOtpr(Ch)
*{
local cDn:="N",nRet:=DE_CONT
do case
 case Ch==ASC(" ") .or. Ch==K_ENTER
   Beep(1)
   if m1=" "    // iz DOKS
     replace m1 with "*"
     nSuma+=Iznos
   else
     replace m1 with " "
     nSuma-=Iznos
   endif
   @ m_x+1,m_Y+55 SAY nSuma pict picdem
   nRet:=DE_REFRESH
endcase
return nRet
*}


/*! \fn RenumPripr(cVezOtpr,dNajnoviji)
 *  \brief
 *  \param cVezOtpr
 *  \param dNajnoviji - datum posljednje radjene otpremnice
 */
 
function RenumPripr(cVezOtpr,dNajnoviji)
*{
//poziva se samo pri generaciji otpremnica u fakturu
local dDatDok
local lSetujDatum:=.f.
private nRokPl:=0, cSetPor:="N"

select pripr
set order to 1
go top
if RecCount2 () == 0
   return
endif

nRbr:=999
go bottom
do while !bof()
  replace rbr with str(--nRbr,3)
  skip -1
enddo

nRbr:=0
do while !eof()
  skip;nTrec:=recno(); skip -1
  if empty(podbr)
    replace rbr with str(++nRbr,3)
  else
    if nRbr==0; nRbr:=1; endif
    replace rbr with str(nRbr,3)
  endif
  go nTrec
enddo

go top

Scatter()
_txt1:=_txt2:=_txt3a:=_txt3b:=_txt3c:=""
if IzFmkIni('FAKT','ProsiriPoljeOtpremniceNa50','N',KUMPATH)=='D'
  _BrOtp:=space(50)
else
  _BrOtp:=space(8)
endif
_DatOtp:=ctod(""); _BrNar:=space(8); _DatPl:=ctod("")
if cVezOtpr==nil
  cVezOtpr:= ""
endif
aMemo:=ParsMemo(_txt)
if len(aMemo)>0
  _txt1:=aMemo[1]
endif
if len(aMemo)>=2
  _txt2:=aMemo[2]
endif
if len(aMemo)>=5
  _txt3a:=aMemo[3]; _txt3b:=aMemo[4]; _txt3c:=aMemo[5]
endif
if len(aMemo)>=9
 _BrOtp:=aMemo[6]; _DatOtp:=ctod(aMemo[7]); _BrNar:=amemo[8]; _DatPl:=ctod(aMemo[9])
endif
if len(aMemo)>=10 .and. !EMPTY(aMemo[10])
  cVezOtpr := aMemo[10]
endif
nRbr:=1

Box("#PARAMETRI DOKUMENTA:",10,75)

  if gDodPar=="1"
    if IzFmkIni('FAKT','ProsiriPoljeOtpremniceNa50','N',KUMPATH)=='D'
      @  m_x+1,m_y+2 SAY "Otpremnica broj:" GET _brotp PICT "@S8"
    else
      @  m_x+1,m_y+2 SAY "Otpremnica broj:" GET _brotp
    endif
   @  m_x+2,m_y+2 SAY "          datum:" GET _Datotp
   @  m_x+3,m_y+2 SAY "Ugovor/narudzba:" GET _brNar
  endif

  if gDodPar=="1" .or. gDatVal=="D"
   nRokPl:=gRokPl
   @  m_x+4,m_y+2 SAY "Datum fakture  :" GET _DatDok
   if dNajnoviji<>NIL
   	@  m_x+4,m_y+35 SAY "Datum posljednje otpremnice:" GET dNajnoviji WHEN .f. COLOR "GR+/B"
   endif
   @  m_x+5,m_y+2 SAY "Rok plac.(dana):" GET nRokPl PICT "99" ;
         WHEN FRokPl("0",.t.)   VALID FRokPl("1",.t.)
   @  m_x+6,m_y+2 SAY "Datum placanja :" GET _DatPl VALID FRokPl("2",.t.)
   read
  endif

  @ m_x+8, m_y+2 SAY "Obracunati PPP ?" GET cSetPor pict "@!" valid cSetPor $ "DN"
  read

BoxC()

dDatDok:=_Datdok

UzorTxt()
if !Empty (cVezOtpr)
  _txt2 += Chr(13)+Chr(10)+cVezOtpr
endif
_txt:=Chr(16)+trim(_txt1)+Chr(17) + Chr(16)+_txt2+Chr(17)+;
      Chr(16)+trim(_txt3a)+Chr(17) + Chr(16)+_txt3b+Chr(17)+;
      Chr(16)+trim(_txt3c)+Chr(17) +;
      Chr(16)+_BrOtp+Chr(17) +;
      Chr(16)+dtoc(_DatOtp)+Chr(17) +;
      Chr(16)+_BrNar+Chr(17) +;
      Chr(16)+dtoc(_DatPl)+Chr(17)+;
      Iif (Empty (cVezOtpr), "", Chr(16)+cVezOtpr+Chr(17))

if datDok<>dDatDok
	lSetujDatum:=.t.
endif
Gather()

if lSetujDatum .or. cSetPor=="D"    // obracunaj porez na promet proizvoda na sve stavke!!
   ObracunajPP(cSetPor,dDatDok)
endif
return
*}


/*! \fn EditPripr(fNovi)
 *  \brief Unos/ispravka stavki u pripremi
 *  \param fNovi
 */
 
function EditPripr(fNovi)
*{
local nXpom
local nYpom
local nRec
local aMemo
local nPom:=IF(VAL(gIMenu)<1,ASC(gIMenu)-55,VAL(gIMenu))

private aPom:={"00 - Pocetno stanje     ",;
               "01 - Ulaz / Radni nalog ",;
               "06 - Ulaz u konsig.skladiste",;
               "10 - Racun veleprodaje",;
               "11 - Racun maloprodaje",;
               "12 - Otpremnica",;
               "13 - Otpremnica u maloprodaju",;
               "15 - Izlaz iz MP putem VP",;
               "16 - Konsignacioni racun",;
               "19 - "+Naziv19ke(),;
               "20 - Predracun",;
  IF(glDistrib,"21 - Teretni list",;
               "21 - Revers"),;
               "22 - Realizovane otpremnice   ",;
               "25 - Knjizna obavijest        ",;
               "26 - Narudzbenica             ",;
               "27 - Predracun MP             "},  h[16]

if IzFmkIni("FAKT","Konsignacija","N",KUMPATH)=="N"
	ADEL(aPom,9)
  	ADEL(aPom,3)
  	ASIZE(aPom,LEN(aPom)-2)
  	ASIZE(h,LEN(aPom))
endif

lDoks2:=(IzFmkIni("FAKT","Doks2","N",KUMPATH)=="D")

AFILL(h,"")

private nRokPl:=0
private cOldKeyDok:=_idfirma+_idtipdok+_brdok

_txt1:=_txt2:=_txt3a:=_txt3b:=_txt3c:=""   // txt1  -  naziv robe,usluge

if IzFmkIni('FAKT','ProsiriPoljeOtpremniceNa50','N',KUMPATH)=='D'
	_BrOtp:=SPACE(50)
else
  	_BrOtp:=SPACE(8)
endif

_DatOtp:=CToD("")
_BrNar:=SPACE(8)
_DatPl:=CToD("")
_VezOtpr:=""

if lDoks2
	d2k1:=SPACE(15)
  	d2k2:=SPACE(15)
  	d2k3:=SPACE(15)
  	d2k4:=SPACE(20)
  	d2k5:=SPACE(20)
  	d2n1:=SPACE(12)
  	d2n2:=SPACE(12)
endif

set cursor on

if !fnovi
	aMemo:=ParsMemo(_txt)
   	if (LEN(aMemo)>0)
     		_txt1:=aMemo[1]
   	endif
   	if (LEN(aMemo)>=2)
     		_txt2:=aMemo[2]
   	endif
   	if (LEN(aMemo)>=5)
     		_txt3a:=aMemo[3]
		_txt3b:=aMemo[4]
		_txt3c:=aMemo[5]
   	endif
   	if (LEN(aMemo)>=9)
    		_BrOtp:=aMemo[6]
		_DatOtp:=CToD(aMemo[7])
		_BrNar:=aMemo[8]
		_DatPl:=CToD(aMemo[9])
   	endif
   	if (LEN(aMemo)>=10 .and. !EMPTY(aMemo[10]))
     		_VezOtpr:=aMemo[10]
   	endif
   	if lDoks2
     		if (LEN(aMemo)>=11)
      			d2k1:=aMemo[11]
     		endif
     		if (LEN(aMemo)>=12)
       			d2k2:=aMemo[12]
     		endif
     		if (LEN(aMemo)>=13)
       			d2k3:=aMemo[13]
     		endif
     		if (LEN(aMemo)>=14)
       			d2k4:=aMemo[14]
     		endif
     		if (LEN(aMemo)>=15)
       			d2k5:=aMemo[15]
     		endif
     		if (LEN(aMemo)>=16)
       			d2n1:=aMemo[16]
     		endif
     		if (LEN(aMemo)>=17)
       			d2n2:=aMemo[17]
     		endif
   	endif
else
	_serbr:=SPACE(LEN(serbr))
   	if glDistrib
     		_ambp:=0
		_ambk:=0
   	endif
	_cijena:=0
	_idRoba:=SPACE(LEN(_idRoba))
	_kolicina:=0
endif

if (fNovi .and. (nRbr==1 .and. VAL(_podbr)<1)) // prva stavka
	nPom:=if(VAL(gIMenu)<1,ASC(gIMenu)-55,VAL(gIMenu))
   	_IdFirma:=gFirma
	_IdTipDok:="10"
   	_datdok:=date()
   	_zaokr:=2
   	_dindem:=LEFT(VAlBazna(),3)
else
	nPom:=ASCAN(aPom,{|x|_IdTipdok==LEFT(x,2)})
endif

if (nRbr==1 .and. VAL(_podbr)<1)
	if gNW$"DR"
   		@ m_x+1,m_y+2 SAY gNFirma
   		if RecCount2()==0
     			_idFirma:=gFirma
   		endif
   		@ m_x+1,col()+2 SAY " RJ:" GET _idFirma PICT "@!" VALID {|| EMPTY(_idFirma) .or. _idFirma==gFirma .or. P_RJ(@_idFirma) .and. V_Rj()}

   		read
  	else
   		@  m_x+1,m_y+2 SAY "Firma:" GET _IdFirma VALID P_Firma(@_IdFirma,1,20) .and. LEN(TRIM(_idFirma))<=2
  	endif
    	if gNW=="N"
		read
	endif
    	
	nPom:=Menu2(5,30,aPom,nPom)
    	
	ESC_Return 0
    	
	_IdTipdok:=LEFT(aPom[nPom],2)

	if !(ImaPravoPristupa(goModul:oDataBase:cName,"DOK","UNOSDOK" + ALLTRIM(_IdTipDok)))
		MsgBeep(cZabrana)
		return 0
	endif
	
    	@  m_x+3,m_y+2 SAY PADR(aPom[ASCAN(aPom,{|x|_IdTipdok==LEFT(x,2)})],40)
   	// if lastkey()==K_ESC; PopHT(); endif
   	if (_idTipDok=="13" .and. gVarNum=="2" .and. gVar13=="2")
     		@ m_x+1, 57 SAY "Prodavn.konto" GET _idPartner VALID P_Konto(@_idPartner)
     		read
     		_idPartner:=LEFT(_idPartner,6)
     		if (EMPTY(ALLTRIM(_txt3a+_txt3b+_txt3c)).or._idpartner!=idpartner)
      			_txt3a:=MEMOLINE(ALLTRIM(KONTO->naz)+" ("+ALLTRIM(_idpartner)+")",30,1)
      			_txt3b:=MEMOLINE(ALLTRIM(KONTO->naz)+" ("+ALLTRIM(_idpartner)+")",30,2)
      			_txt3c:=MEMOLINE(ALLTRIM(KONTO->naz)+" ("+ALLTRIM(_idpartner)+")",30,3)
     		endif
   	elseif (_idtipdok=="13" .and. gVarNum=="1" .and. gVar13=="2")
     		_idPartner:=if(EMPTY(_idPartner),"P1",RJIzKonta(_idPartner+" "))
     		@ m_x+1, 57 SAY "RJ - objekat:" GET _idPartner valid P_RJ(@_idPartner) pict "@!"
     		read
     		_idpartner:=PADR(KontoIzRJ(_idpartner),6)
     		if EMPTY(ALLTRIM(_txt3a+_txt3b+_txt3c)).or._idpartner!=idpartner
      			_txt3a:=MEMOLINE(RJ->id+" - "+ALLTRIM(RJ->naz)+" (ZADU@ENJE)",30,1)
      			_txt3b:=MEMOLINE(RJ->id+" - "+ALLTRIM(RJ->naz)+" (ZADU@ENJE)",30,2)
      			_txt3c:=MEMOLINE(RJ->id+" - "+ALLTRIM(RJ->naz)+" (ZADU@ENJE)",30,3)
     		endif
   	endif
   	if (fNovi .and. (nRbr==1 .and. podbr<"0"))
     		_M1:=" "  // marker generacije nuliraj
     		gOcitBarkod:=.f.
     		if (gMreznoNum=="N")
        		cBroj1:=OdrediNBroj(_idfirma,_idtipdok)   //_brdok
        		if (_idTipDok=="12")
           			cBroj2:=OdrediNBroj(_idfirma,"22")
           			if VAL(LEFT(cBroj1,gNumDio))>=val(left(cBroj2,gNumDio))
              			// maximum izmedju broja 22 i 12
              				_Brdok:=cBroj1
           			else
              				_BrDok:=cBroj2
          			endif
        		else
           			_BrDok:=cBroj1
        		endif
			
			select PRIPR
     		else
        		_BrDok := SPACE (LEN (_BrDok))
     		endif
   	endif
  	do while .t.
   		@  m_x+3,m_y+40 SAY "Datum:" GET _datDok
   		@  m_x+3,m_y+col()+2 SAY "Broj:" GET _BrDok WHEN gMreznoNum=="N" VALID !EMPTY(_BrDok).and.(!glDistrib.or.!JeStorno10().or.PuniDVRiz10())
		//if IzFMkIni('FAKT',"IdPartnNaF",'N',KUMPATH)=="D" .or.;
   		if lSpecifZips
     			_txt3a:=PADR(_txt3a,60)
   		else
     			if IzFMKINI("PoljeZaNazivPartneraUDokumentu","Prosiriti","N",KUMPATH)=="D"
      				_txt3a:=padr(_txt3a,60)
     			else
      				_txt3a:=padr(_txt3a,30)
     			endif
   		endif

   		_txt3b:=padr(_txt3b,30)
   		_txt3c:=padr(_txt3c,30)

   		lUSTipke:=.f.
   		if (gNovine=="D" .or. IzFMKINI("FAKT","UnosPartneraObaveznoPoSifri","N",KUMPATH)=="D")
     			@  m_x+5,m_y+2  SAY "Partner " get _idpartner  picture "@!" valid { || P_Firma(@_idpartner,6,11) , _Txt3a:=padr(_idpartner+".",30) , IzSifre() }
     			if pripr->(FIELDPOS("IDPM"))<>0
       				@  m_x+7,m_y+2  SAY "Prod.mj." get _idpm valid {|| P_IDPM(@_idpm,_idpartner)}
     			endif
   		else
     			if IzFMKINI("FAKT","KupacMalaSlova","N",KUMPATH)=="D"
       				lUSTipke:=.t.
       				@  m_x+5,m_y+2  SAY "Partner " get _Txt3a  picture "@S30" valid IzSifre()
       				@  m_x+6,m_y+2  SAY "        " get _Txt3b  picture "@"
       				@ m_x+7,m_y+2  SAY "Mjesto  " get _Txt3c  picture "@"
     			else
       				@  m_x+5,m_y+2  SAY "Partner " get _Txt3a  picture "@!S30" valid IzSifre()
       				@  m_x+6,m_y+2  SAY "        " get _Txt3b  picture "@!"
       				@  m_x+7,m_y+2  SAY "Mjesto  " get _Txt3c  picture "@!"
     			endif
   		endif

   		if _idtipdok=="10"
     			if gDodPar=="1"
       				if IzFmkIni('FAKT','ProsiriPoljeOtpremniceNa50','N',KUMPATH)=='D'
          				@  m_x+5,m_y+45 SAY "Otpremnica broj:" GET _brotp PICT "@S8" WHEN W_BrOtp(fnovi)
       				else
          				@  m_x+5,m_y+45 SAY "Otpremnica broj:" GET _brotp WHEN W_BrOtp(fnovi)
       				endif
      				@  m_x+6,m_y+45 SAY "          datum:" GET _Datotp
      				@  m_x+7,m_y+45 SAY "Ugovor/narudzba:" GET _brNar
     			endif

     			if (gDodPar=="1" .or. gDatVal=="D")
      				if fNovi
					nRokPl:=gRokPl
				endif
      				@  m_x+8,m_y+45 SAY "Rok plac.(dana):" GET nRokPl PICT "99" WHEN FRokPl("0",fnovi)   VALID FRokPl("1",fnovi)
				@  m_x+9,m_y+45 SAY "Datum placanja :" GET _DatPl VALID FRokPl("2",fnovi)
     			endif
     			if lVrsteP
      				@ m_x+10,m_y+38  SAY "Nacin placanja" get _idvrstep  picture "@!" valid P_VRSTEP(@_idvrstep,10,56)
     			endif
   		elseif (_idtipdok=="06")
      			if IzFmkIni('FAKT','ProsiriPoljeOtpremniceNa50','N',KUMPATH)=='D'
        			@ m_x+5,m_y+45 SAY "Po ul.fakt.broj:" GET _brotp PICT "@S8" when  W_BrOtp(fnovi)
      			else
        			@ m_x+5,m_y+45 SAY "Po ul.fakt.broj:" GET _brotp when  W_BrOtp(fnovi)
      			endif
      			@  m_x+7,m_y+45 SAY "       i UCD-u :" GET _brNar
   		endif
   		if (glDistrib .and. _idtipdok$"10#12#13#26#21#22")
     			@ m_x+11,m_y+31  SAY "Relacija   :" get _idrelac  picture "@!" valid {|| _idtipdok$"21#22".or.JeStorno10().and.PuniDVRiz10().or.IzborRelacije(@_IdRelac,@_IdDist,@_IdVozila,@_datdok,@_marsruta)}
   		endif

   		// dodatno polje DEST   <-- gradiz
   		if (gDest .and. !glDistrib)
     			@  m_x+10,m_y+31  SAY "Destinacija :" get _Dest
   		endif

   		if !lOpresaPovrati
     			if _idtipdok$"06#16"
       				@ m_x+9,m_y+2  SAY Valdomaca()+"/"+VAlPomocna() get _DINDEM pict "@!" valid ImaUSifVal(_dindem)
     			else
       				@ m_x+9,m_y+2  SAY Valdomaca()+"/"+VAlPomocna() get _DINDEM pict "@!" valid _dindem $ valdomaca()+valpomocna()
     			endif
   		endif

		if glRadNal .and. _idtipdok$"12"
			@ m_x+9, m_y+15 SAY "Rad.nalog:" GET _idRNal VALID P_RNal(@_idRNal) PICT "@!"
		endif

   		if lUSTipke
   			USTipke()
   		endif
   		
		READ
   		
		if lUSTipke
   			BosTipke()
   		endif
    		
		if (lDoks2 .and. _idtipdok=="10")
      			EdDoks2()
    		endif
   		
		_txt3a:=trim(_txt3a)
   		_txt3b:=trim(_txt3b)
   		_txt3c:=trim(_txt3c)
   		ESC_Return 0

   		if (gMreznoNum=="D")
     			exit
   		endif

   		select DOKS
   		set order to 1
   		hseek _idfirma+_idtipdok+_brDok
   		if !Found()
      			select PRIPR
      			exit
   		else
      			Beep(4)
      			Msg("Vec postoji dokument "+_idtipdok+"-"+_brdok,6)
      			select PRIPR
   		endif
  	enddo
  	
	ChSveStavke(fNovi)
else
	@ m_x+1,m_y+2 SAY gNFirma 
	?? "  RJ:", _IdFirma
   	@ m_x+4,m_y+2 SAY PADR(aPom[ASCAN(aPom,{|x|_IdTipdok==LEFT(x,2)})],35)
   	@ m_x+4,m_y+40 SAY "Datum: "
   	?? _datDok
   	@ m_x+4,m_y+col()+2 SAY "Broj: "
	?? _BrDok
   	_txt2:=""
endif

if (gNovine=="D" .and. fNovi)
	@ m_x+11,m_y+2 SAY "R.br: "+STR(nRbr,4,0)
else
	@ m_x+11,m_y+2 SAY "R.br:" GET nRbr Picture "9999"
endif

if (gNovine=="D")
	if fNovi
     		_idroba:=SPACE(LEN(_idroba))
     		_kolicina:=0
   	endif
else
	@ m_x+11,col()+2 SAY "Podbr.:" GET _PodBr VALID V_Podbr()
endif

cDSFINI:=IzFMKINI('SifRoba','DuzSifra','10',SIFPATH)

if fID_J
	@ m_x+13,m_y+2 SAY "Artikal  " GET _IdRoba_J PICT "@!S10" WHEN {|| _idroba_J:=padr(_Idroba_J,VAL(cDSFINI)),W_Roba()} valid {|| _Idroba_J:=iif(len(trim(_Idroba_J))<10,left(_Idroba_J,10),_Idroba_J), V_Roba(),GetUsl(fnovi), NijeDupla(fNovi)}
else
	@ m_x+13,m_y+2  SAY "Artikal  " get _IdRoba pict "@!S10" when {|| _idroba:=padr(_idroba,VAL(cDSFINI)),W_Roba()} valid {|| _idroba:=iif(len(trim(_idroba))<10,left(_idroba,10),_idroba), V_Roba(),GetUsl(fnovi),NijeDupla(fNovi)}
endif

RKOR2:=0

if lPoNarudzbi
	if (_idtipdok="0")
     		RKOR2+=3
     		@ m_x+14,m_y+2 SAY "Po narudzbi br." GET _brojnar
     		@ m_x+15,m_y+2 SAY "za narucioca" GET _idnar pict "@!" valid empty(_idnar) .or. P_Firma(@_idnar,15,25)
   	endif
endif

RKOR2+=GetKarC3N2(row()+1)

if (pripr->(fieldpos("K1"))<>0 .and. gDK1=="D")
	@ m_x+13+RKOR2,m_y+66 SAY "K1" GET _K1 pict "@!"
endif

if (pripr->(fieldpos("K2"))<>0 .and. gDK2=="D")
	@ m_x+14+RKOR2,m_y+66 SAY "K2" GET _K2 pict "@!"
endif

if gNovine=="D"

else
	if (gSamokol!="D" .and. !glDistrib)
    		@ m_x+14+RKOR2,m_y+2  SAY JokSBr()+" "  get _serbr pict "@s15"  when _podbr<>" ."
   	endif
endif

if (gVarC $ "123" .and. _idtipdok $ "10#12#20#21#25")
	@  m_x+14+RKOR2,m_y+59  SAY "Cijena (1/2/3):" GET cTipVPC
endif

RKOR:=0

lGenStavke:=.f.

if ( _m1=="X" .and.  !fnovi )
	// ako je racun, onda ne moze biti cijena 0 !
   	@ m_x+16+RKOR2,m_y+2  SAY "Kolicina "
	@ row(),col()+1 SAY _kolicina pict pickol
   	if _Cijena=0
     		V_Kolicina()
   	endif
else
	if (glDistrib .or. lPoNarudzbi)
     		read
     		ESC_return 0
   	endif
   	cPako:="(PAKET)"  // naziv jedinice mjere veceg pakovanja
   	if (glDistrib .and. Prepak(_idroba,@cPako,@_ambp,@_ambk,_kolicina))
     		// --- unos kolicine veceg pakovanja - "pretvornik"
     		@ m_x+16+RKOR2,m_y+2   SAY "AMBALAZA:" get _ambp pict pickol VALID {|| Prepak(_idroba,cPako,_ambp,_ambk,@_kolicina,.f.),ShowGets()}
     		@ m_x+16+RKOR2,col()+1 SAY cPako
     		@ m_x+16+RKOR2,col()+2 SAY "+" get _ambk pict pickol VALID {|| Prepak(_idroba,cPako,_ambp,_ambk,@_kolicina,.f.),ShowGets()}
     		@ m_x+16+RKOR2,col()+1 SAY "("+TRIM(ROBA->JMJ)+")"
     		// ---
     		@ m_x+18+RKOR2,m_y+2  SAY "Kolicina " get _Kolicina   pict pickol valid {|| Prepak(_idroba,cPako,@_ambp,@_ambk,_kolicina),ShowGets(),V_Kolicina()}
     		RKOR:=2
   	else
     		if (lPoNarudzbi .and. !_idtipdok="0")
       			aNabavke:={}
       			if !fNovi
         			AADD(aNabavke,{0,_cijena,_kolicina,_idnar,_brojnar})
       			endif
       			KalkNab3m(_idfirma,_idroba,aNabavke)
       			if (LEN(aNabavke)>1)
				lGenStavke:=.t.
			endif
       			if (LEN(aNabavke)>0)
         			// - tekuca -
         			i:=LEN(aNabavke)
         			_kolicina := aNabavke[i,3]
         			_idnar:=if(_kolicina<>0,aNabavke[i,4],SPACE(LEN(_idnar)))
         			_brojnar:=if(_kolicina<>0,aNabavke[i,5],SPACE(LEN(_brojnar)))
         			// ----------
       			else
         			_idnar:=SPACE(LEN(_idnar))
         			_brojnar:=SPACE(LEN(_brojnar))
       			endif
       			@ m_x+15+RKOR2,m_y+2 SAY "Kolicina " GET _Kolicina PICT PicKol when LEN(aNabavke)<1 valid V_Kolicina()
       			@ row(),col()+2 SAY IspisPoNar(,,.t.)
     		else
       			@ m_x+16+RKOR2,m_y+2 SAY "Kolicina " get _Kolicina pict pickol valid V_Kolicina()
     		endif
   	endif
endif

private trabat:="%"

if (gSamokol!="D")  // samo kolicine
	if (_idtipdok=="19" .and. IzFMKIni("FAKT","19KaoRacunParticipacije","N",KUMPATH)=="D")
    		_trabat:="I"
    		_rabat:=_kolicina*_cijena*(1-_rabat/100)
    		@ m_x+16+RKOR+RKOR2,25  SAY "Cij." GET _Cijena PICT piccdem WHEN _podbr<>" ." .and. KLevel<="1" VALID _cijena>0

    		@ m_x+16+RKOR+RKOR2,col()+2 SAY "Participacija" GET _Rabat PICT "9999.999" when _podbr<>" ."

	else
		if (gNovine=="D" .and. fNovi)
    			@ m_x+16+RKOR+RKOR2,25 SAY if(_idtipdok=="13".and.(gVar13=="2".or.glCij13Mpc),"MP cijena","Cijena")+TRANSFORM(_Cijena,piccdem)
   		else
    			@ m_x+16+RKOR+RKOR2,25  SAY IF(_idtipdok=="13".and.(gVar13=="2".or.glCij13Mpc),"MP cijena","Cijena") GET _Cijena   PICT piccdem WHEN  _podbr<>" ." .and. KLevel<="1" .and. SKCKalk(.t.) VALID SKCKalk(.f.)
   		endif
   		if !(_idtipdok $ "12#13").or.(_idtipdok=="12".and.gV12Por=="D")
      			@  m_x+16+RKOR+RKOR2,col()+2  SAY "Rabat" get _Rabat pict "9999.999" when _podbr<>" ." .and. !_idtipdok$"15#27"
      			@ m_x+16+RKOR+RKOR2,col()+1  GET TRabat when {||  trabat:="%",!_idtipdok$"11#15#27" .and. _podbr<>" ."} valid trabat $ "% AUCI" .and. V_Rabat()  pict "@!"
    			@ m_x+16+RKOR+RKOR2,col()+2 SAY "Porez" GET _Porez pict "99.99"  when {|| if( fNovi .and. _idtipdok=="10" .and. IzFMKIni("FAKT","PPPNuditi","N",KUMPATH)=="D".and.ROBA->tip!="U" , _porez := TARIFA->opp , ), _podbr<>" ." .and. !(roba->tip $ "KV") .and. !_idtipdok$"11#15#27"} valid V_Porez()
   		endif
	endif

	private cId:="  "

endif //gSamokol=="D"  // samo kolicine

read

ESC_return 0

//if (_idTipDok=="11")
	//aPorezi:={}
	//SetAPorezi(@aPorezi)
	//_trabat:="%"
	//nVrijednost:=_kolicina*_cijena
	//nMPCbezPOR:=MpcBezPor(nVrijednost, aPorezi)
	//_rabat:=(nMPCBezPOR * (1-_rabat/100))
//endif

if (_idtipdok=="19" .and. IzFMKIni("FAKT","19KaoRacunParticipacije","N",KUMPATH)=="D")
	_trabat:="%"
   	_rabat:=(_kolicina*_cijena-_rabat)/(_kolicina*_cijena)*100
endif

if !(_idtipdok $ "12#13") .and. gSamokol!="D"
	UzorTxt()
endif

if (_podbr==" ." .or.  roba->tip="U" .or. (nrbr==1 .and. val(_podbr)<1))
	_txt2:=OdsjPLK(_txt2)           // odsjeci na kraju prazne linije
     	if !"Faktura formirana na osnovu" $ _txt2
        	_txt2 += CHR(13)+Chr(10)+_VezOtpr
     	endif
    	_txt:=Chr(16)+trim(_txt1)+Chr(17) + Chr(16)+_txt2+Chr(17)+Chr(16)+trim(_txt3a)+Chr(17) + Chr(16)+_txt3b+Chr(17)+Chr(16)+trim(_txt3c)+Chr(17)+Chr(16)+_BrOtp+Chr(17)+Chr(16)+dtoc(_DatOtp)+Chr(17)+Chr(16)+_BrNar+Chr(17)+Chr(16)+dtoc(_DatPl)+Chr(17)+IIF(Empty(_VezOtpr),Chr(16)+ ""+Chr(17), Chr(16)+_VezOtpr+Chr(17))+if(lDoks2,Chr(16)+d2k1+Chr(17) , "" )+IF(lDoks2 , Chr(16)+d2k2+Chr(17) , "" )+IF(lDoks2,Chr(16)+d2k3+Chr(17) , "" )+IF(lDoks2,Chr(16)+d2k4+Chr(17) , "" )+IF(lDoks2,Chr(16)+d2k5+Chr(17) , "" )+IF(lDoks2,Chr(16)+d2n1+Chr(17) , "" )+IF( lDoks2 , Chr(16)+d2n2+Chr(17) , "" )
else
	_txt:=""
endif

_Rbr:=RedniBroj(nRbr)

// if _DINDEM==left(ValSekund(),3)   // preracunaj u dinare
if _DINDEM!=left(ValBazna(),3)   // preracunaj u dinare
	if _DINDEM==left(ValSekund(),3)   // preracunaj u dinare
      		_Cijena:=_Cijena*UBaznuValutu(_datdok)
   	else
      		_Cijena:=_Cijena*OmjerVal(ValBazna(),_DINDEM,_datdok)
		// iz valute tipa "O" u baznu
   	endif
endif

if lPoNarudzbi
	if lGenStavke
     		pIzgSt:=.t.
     		// vise od jedne stavke
     		for i:=1 to LEN(aNabavke)-1
       			// generiçi sve izuzev posljednje
       			APPEND BLANK
       			_rbr:=RedniBroj(nRBr)
       			_kolicina:=aNabavke[i,3]
       			_idnar:=aNabavke[i,4]
       			_brojnar:=aNabavke[i,5]
       			if nRBr<>1
         			_txt:=""
       			endif
       			Gather()
       			++nRBr
     		next
     		// posljednja je tekuca
     		_rbr:=RedniBroj(nRbr)
     		_kolicina:=aNabavke[i,3]
     		_idnar:=aNabavke[i,4]
     		_brojnar:=aNabavke[i,5]
   	else
     		// jedna ili nijedna
     		if LEN(aNabavke)>0
       			// jedna
       			_kolicina:=aNabavke[1,3]
       			_idnar:=aNabavke[1,4]
       			_brojnar:=aNabavke[1,5]
     		elseif _kolicina==0
       			// nije izabrana kolicina -> kao da je prekinut unos tipkom Esc
      			return 0
     		endif
   	endif
endif

return 1
*}



/*! \fn FRokPl(cVar,fNovi)
 *  \brief Validacija roka placanja
 *  \param cVar
 *  \param fNovi
 */
 
function FRokPl(cVar,fNovi)
*{
local fOtp:=.f.

if IzFMKINI('FAKT','DatumRokPlacanja','F')=="O"
 // F  - faktura, O -  otpremnica
 fOtp:=.t.
endif

if cVar=="0"   // when
  if nRokPl<0
     return .t.   // ne diraj nista
  endif
  if !fnovi
   if EMPTY(_datpl)
      nRokPl:=0
   else
     if fotp
       nRokPl:=_datpl-_datotp
     else
       nRokPl:=_datpl-_datdok
     endif
   endif
  endif

elseif cVar=="1"  // valid
  if nRokPl<0  // moras unijeti pozitivnu vrijednost ili 0
        MsgBeep("Unijeti broj dana !")
        return .f.
  endif
  if nRokPl=0 .and. gRokPl<0
     // exclusiv, ako je 0 ne postavljaj rok placanja !
    _datPl:=ctod("")
  else
    if fotp
      _datPl:=_datotp+nRokPl
    else
      _datPl:=_datdok+nRokPl
    endif
  endif

else  // cVar=="2" - postavi datum placanja

  if EMPTY(_datpl)
    nRokPl:=0
  else
    if fotp
      nRokPl:=_datpl-_datotp
    else
      nRokPl:=_datpl-_datdok
    endif
  endif

endif
ShowGets()
return .t.
*}



/*! \fn SljBrDok13(cBrD,nBrM,cKon)
 *  \brief
 *  \param cBrD
 *  \param nBrM
 *  \param cKon
 */
 
function SljBrDok13(cBrD,nBrM,cKon)
*{
local nPom
local cPom:=""
local cPom2

cPom2:=PADL(ALLTRIM(STR(VAL(ALLTRIM(SUBSTR(cKon,4))))),2,"0")
nPom:=AT("/",cBrD)
if VAL(SUBSTR(cBrD,nPom+1,2))!=nBrM
	cPom:="01"
else
	cPom:=NovaSifra(SUBSTR(cBrD,nPom-2,2))
endif
return cPom2+cPom+"/"+PADL(ALLTRIM(STR(nBrM)),2,"0")
*}



/*! \fn PrCijSif()
 *  \brief Promjena cijene u sifrarniku
 */
 
function PrCijSif()
*{
NSRNPIdRoba()
   SELECT (F_ROBA)

//   if PRIPR->idtipdok=="13" .and. ( gVar13=="2" .or. IzFMKINI("FAKT","Cijena13MPC","N",KUMPATH)=="D" )   // Planika-Alisa ne odgovara joj ovo, MS 25.04.03

//   if PRIPR->idtipdok=="13" .and. gVar13=="2" // ovo izgleda nikome ne odgovara (Niagara koristi gVar13=="2"), MS 21.08.03

   if PRIPR->idtipdok=="01" .and. IsNiagara()
     if g13dcij$" 1".and.PRIPR->cijena!=MPC
       Scatter();  _mpc:=PRIPR->cijena; Gather()
     elseif g13dcij=="2".and.PRIPR->cijena!=MPC2
       Scatter(); _mpc2:=PRIPR->cijena; Gather()
     elseif g13dcij=="3".and.PRIPR->cijena!=MPC3
       Scatter(); _mpc3:=PRIPR->cijena; Gather()
     elseif g13dcij=="4".and.PRIPR->cijena!=MPC4
       Scatter(); _mpc4:=PRIPR->cijena; Gather()
     elseif g13dcij=="5".and.PRIPR->cijena!=MPC5
       Scatter(); _mpc5:=PRIPR->cijena; Gather()
     elseif g13dcij=="6".and.PRIPR->cijena!=MPC6
       Scatter(); _mpc6:=PRIPR->cijena; Gather()
     endif
   endif
   SELECT PRIPR
return
*}


/*! \fn RJIzKonta(cKonto)
 *  \brief Vraca radnu jedinicu iz sif->konto na osnovu zadatog konta
 *  \param cKonto   - konto
 *  \return cVrati
 */
 
function RJIzKonta(cKonto)
*{
local cVrati:="  ", nArr:=SELECT(), nRec
  SELECT (F_RJ)
  nRec:=RECNO()
   GO TOP
   do while !EOF()
     if cKonto==RJ->konto
       cVrati:=RJ->id
       exit
     endif
     SKIP 1
   enddo
  GO (nRec)
  SELECT (nArr)
return cVrati
*{


/*! \fn KontoIzRJ(cRJ)
 *  \brief Vraca konto na osnovu radne jedinice
 *  \param cRJ  - radna jedinica
 *  \return cVrati
 */
 
function KontoIzRJ(cRJ)
*{
local cVrati:=SPACE(7)
 PushWA()
   SELECT (F_RJ)
     HSEEK cRJ
     if FOUND()
       cVrati:=RJ->konto
     endif
 PopWA()
return cVrati
*}



/*! \fn NarBrDok(fNovi)
 *  \brief Postavlja u pripremi broj dokumenta - puni pripremu
 *  \brief NarBrDok(fNovi)->cBroj  - Generise naredni broj dokumenta
 *  \param fNovi
 *  \return _brdok
 */
 
function NarBrDok(fNovi)
*{
local nPrev:=SELECT()

if !EMPTY (PRIPR->BrDok) .or. eof()  // nema dokumenata
   // ovaj vec ima odredjen broj
   return PRIPR->BrDok
endif


if gMreznoNum == "D"
  select pripr
  nTrecPripr:=recno()
  go top
  _idtipdok:=pripr->idtipdok
  _idfirma:=pripr->idfirma
  _datdok:=pripr->datdok
  _dindem:=pripr->dindem
  _rezerv:=""
  _idpartner:=""
  _partner:=""
  _iznos:=0
  _rabat:=0
  _m1 := " "
  _idvrstep:=""
  if DOKS->(FIELDPOS("DATPL")>0)
    _datpl := CTOD("")
  endif
  if DOKS->(FIELDPOS("IDPM")>0)
    _idpm  := SPACE(15)
  endif
  go nTrecPripr
endif


// novi dokument, koji nema svog broja, u pripremi
SELECT DOKS
//Scatter ()

if gMreznoNum == "D"
   if !DOKS->(FLOCK())
      nOkr := 80     // daj mu 10 sekundi max
      do while nOkr > 0
         InkeySc (.125)
         nOkr --
         if DOKS->(FLOCK())
            exit
         endif
      enddo
      if nOkr == 0 .AND. ! DOKS->(FLOCK())
         Beep (4)
         Msg ("Nemoguce odrediti broj dokumenta - ne mogu pristupiti bazi!")
         return SPACE (LEN (_BrDok))
      endif
   endif
endif

cBroj1:=OdrediNBroj(_idfirma,_idtipdok)   //_brdok

if _idtipdok=="12"
   cBroj2:=OdrediNBroj(_idfirma,"22")
   if val(left(cBroj1,gNumDio))>=val(left(cBroj2,gNumDio))
      _Brdok:=cBroj1
   else
      _BrDok:=cBroj2
   endif
else
   _BrDok:=cBroj1
endif

if gMreznoNum == "D"
  // pravi se fizicki append u bazi dokumenata da bi se sacuvalo mjesto
  // za ovaj dokument
  //
  SELECT DOKS
  // dbappend()   // append blank skine LOCK sa baze
  appblank2 (.F., .F.)   // ne cisti, ne otkljucavaj
  _M1 := "Z"
  if fieldpos("SIFRA")<>0
    _sifra := sifrakorisn
  endif
  Gather2 ()
  DBUNLOCK()

  // popuni broj dokumenta u svakoj stavki pripreme
  SELECT PRIPR
  nTekRec := RECNO ()
  nPrevOrd := INDEXORD()
  set order to
  go top

  LOCATE for IdFirma == _IdFirma .AND. IdTipDok == _IdTipDok ;
             .AND. EMPTY (BrDok)
  do while FOUND ()
    REPLACE BrDok WITH _BrDok
    CONTINUE
  END

  GO nTekRec
  DBSETORDER(nPrevOrd)
endif

return _BrDok
*}



/*! \fn StampTXT(cIdFirma,cIdTipDok,cBrDok)
 *  \brief Stampa dokumenta
 *  \todo Ovo bi trebalo prebaciti u /RPT
 *  \param cIdFirma
 *  \param cIdTipDok
 *  \param cBrDok
 */
 
function StampTXT(cIdFirma,cIdTipDok,cBrDok)
*{
private InPicDEM:=PicDEM  // picture iznosa
private InPicCDEM:=PicCDEM  // picture iznosa
cIniName:=PRIVPATH+'fmk.ini'
UzmiIzIni(cIniName,'UpitFax','Slati','N','WRITE')
UzmiIzIni(EXEPATH+'fmk.ini','FAKT','KrozDelphi','N','WRITE')


if IzFmkIni('Fakt','DelphiRB','N',EXEPATH)=='P'
   if Pitanje(,'Zelite li stampu kroz DelphiRB D/N ?','N')=='D'
      UzmiIzIni(EXEPATH+'fmk.ini','FAKT','KrozDelphi','D','WRITE')
   endif
endif
if IzFmkIni('UpitFax','PitatiZaFax','N',PRIVPATH)=='D'
  if Pitanje(,'Zelite li dokument za slanje faks-om D/N ?','N')=='D'
     UzmiIzIni(cIniName,'UpitFax','Slati','D','WRITE')
  endif
endif

if "U" $ TYPE("lSSIP99") .or. !VALTYPE(lSSIP99)=="L"; lSSIP99:=.f.; endif


if !(cIdTipdok $ "10#11#13#15#25#27") .and.;
   !(cIdTipDok $ "20" .and. IzFMKIni("FAKT","PredracuniUvijekSaIznosima","N",PRIVPATH)=="D") .and.;
   (gSamokol=="D" .or. glDistrib.and.cIdTipDok$"26#21" .or.;
    Pitanje(,"Prikaz iznosa na dokumentu ?","D")=="N")
   Picdem:=space(len(picdem))
   PicCdem:=space(len(piccdem))
endif


#ifndef CAX
close all
#endif


lPartic := ( IzFMKIni("FAKT","19KaoRacunParticipacije","N",KUMPATH)=="D" )

if gNW=="T"
  if cIdFirma==nil
   StDokM()
  else
   StDokM(cIdFirma,cIdTipdok,cbrdok)
  endif
else
  if cidtipdok=="13"
    if cIdFirma==nil
     if IzFMKINI("STAMPA","Opresa","N",KUMPATH)=="D"
       StDok13s()
     else
       StDok13()
     endif
    else
     if IzFMKINI("STAMPA","Opresa","N",KUMPATH)=="D"
       StDok13s(cIdFirma,cIdTipdok,cbrdok)
     else
       StDok13(cIdFirma,cIdTipdok,cbrdok)
     endif
    endif
  elseif cidtipdok=="19" .and. lPartic
    if cIdFirma==nil
      StDok2()
    else
      StDok2(cIdFirma,cIdTipdok,cbrdok)
    endif
  else
   if gTipF=="1"
     if cIdFirma==nil
        StDok()
     else
        Stdok(cIdFirma,cIdTipdok,cbrdok)
     endif
   elseif gTipF=="2"
    if gVarF=="3"
      if cIdFirma==nil
         Stdok23()
      else
         Stdok23(cIdFirma,cIdTipdok,cbrdok)
      endif
    elseif gVarF=="9".or.gVarF=="B"
      if cidtipdok $ "12#10#20#25"
        if cIdFirma==nil
           StDok29()
        else
           StDok29(cIdFirma,cIdTipdok,cbrdok)
        endif
      else
        gVarF:="2"
        if cIdFirma==nil
           StDok2()
        else
           StDok2(cIdFirma,cIdTipdok,cbrdok)
        endif
        gVarF:="9"
      endif
    elseif gVarF=="A"
      if cidtipdok $ "12#10#20#25#26"
        if cIdFirma==nil
         StDok2a()
        else
         StDok2a(cIdFirma,cIdTipdok,cbrdok)
        endif
      else
        gVarF:="2"
        if cIdFirma==nil
          StDok2()
        else
          StDok2(cIdFirma,cIdTipdok,cbrdok)
        endif
        gVarF:="A"
      endif
    else
      if cIdFirma==nil
        StDok2()
      else
        StDok2(cIdFirma,cIdTipdok,cbrdok)
      endif
    endif
   else
    if cIdFirma==nil
      StDok3()
    else
      StDok3(cIdFirma,cIdTipdok,cbrdok)
    endif
   endif
  endif
endif

PicDEM:=InPicDEM
PicCDEM:=InPicCDEM

#ifdef CAX
     select (F_PRIPR)
     use
     select (F_POR)
     use
#endif
return
*}


/*! \fn StampRtf(cImeF,cIdFirma,cIdTipDok,cBrDok)
 *  \brief Stampa u rtf formatu
 *  \todo Ovo bi trebalo prebaciti u /RPT
 *  \param cImeF
 *  \param cIdFirma
 *  \param cIdTipDok
 *  \param cBrDok
 */
 
function StampRtf(cImeF,cIdFirma,cIdTipdok,cbrdok)
*{
private InPicDEM:=PicDEM  // picture iznosa
private InPicCDEM:=PicCDEM  // picture iznosa

private cRtfPoziv
private cKom

cRtfPoziv:=IzFmkIni("FAKT", "RtfPoziv", "")

if !(cIdTipdok $ "10#11#15#25#27") .and.;
   !(cIdTipDok $ "20" .and. IzFMKIni("FAKT","PredracuniUvijekSaIznosima","N",PRIVPATH)=="D") .and.;
   (gSamokol=="D" .or. glDistrib.and.cIdTipDok$"26#21" .or.;
    Pitanje(,"Prikaz iznosa na dokumentu ?","D")=="N")
   Picdem:=space(len(picdem))
   PicCdem:=space(len(picCdem))
endif

#ifndef CAX
close all
#endif

Setpxlat()

if !EMPTY(cRtfPoziv)
	cKom:=cRtfPoziv+"( "+ArgToStr(cImeF)+", "+ArgToStr(cIdFirma)+", "+ArgToStr(cIdTipDok)+", "+ArgToStr(cBrDok)+")"
	EVAL( {|| &cKom} )
else
	if gTipF=="1"
		StDRtf1(cImeF, cIdFirma, cidtipdok, cbrdok)
	elseif gTipF=="2"
		if EMPTY(gVarRF)
			StDRtf2(cImeF,cIdFirma,cidtipdok,cbrdok)
		else
			StDRtf21(cImeF,cIdFirma,cidtipdok,cbrdok)
		endif
	else
		StDRtf3(cImeF,cIdFirma,cidtipdok,cbrdok)
	endif
endif
konvtable()
PicDEM:=InPicDEM
PicCDEM:=InPicCDEM

#ifdef CAX
  select (F_PRIPR)
  use
  select (F_POR)
  use
#endif
return
*}

/* \fn ArgToStr()
 * Argument To String
 */
function ArgToStr(xArg)
*{
if (xArg==NIL)
	return "NIL"
else
	return "'"+xArg+"'"
endif
*}



/*! \fn IsprUzorTxt(fSilent,bFunc)
 *  \brief Ispravka teksta ispod fakture
 *  \param fSilent
 *  \param bFunc
 */
 
function IsprUzorTxt(fSilent,bFunc)
*{
if fSilent==nil
	fSilent:=.f.
endif
lDoks2 := ( IzFMKINI("FAKT","Doks2","N",KUMPATH)=="D" )
if !fSilent
  Scatter()
endif

if IzFmkIni('FAKT','ProsiriPoljeOtpremniceNa50','N',KUMPATH)=='D'
  _BrOtp:=space(50)
else
  _BrOtp:=space(8)
endif
_DatOtp:=ctod(""); _BrNar:=space(8); _DatPl:=ctod("")
_VezOtpr := ""
_txt1:=_txt2:=_txt3a:=_txt3b:=_txt3c:=""        // txt1  -  naziv robe,usluge
nRbr:=RbrUNum(RBr)

if lDoks2
  d2k1 := SPACE(15)
  d2k2 := SPACE(15)
  d2k3 := SPACE(15)
  d2k4 := SPACE(20)
  d2k5 := SPACE(20)
  d2n1 := SPACE(12)
  d2n2 := SPACE(12)
endif

aMemo:=ParsMemo(_txt)
if len(aMemo)>0
  _txt1:=aMemo[1]
endif
if len(aMemo)>=2
  _txt2:=aMemo[2]
endif
if len(aMemo)>=5
  _txt3a:=aMemo[3]; _txt3b:=aMemo[4]; _txt3c:=aMemo[5]
endif

if len(aMemo)>=9
 _BrOtp:=aMemo[6]; _DatOtp:=ctod(aMemo[7]); _BrNar:=amemo[8]; _DatPl:=ctod(aMemo[9])
endif
if len (aMemo)>=10 .and. !EMPTY(aMemo[10])
  _VezOtpr := aMemo [10]
endif

if lDoks2
  if len (aMemo)>=11
    d2k1 := aMemo[11]
  endif
  if len (aMemo)>=12
    d2k2 := aMemo[12]
  endif
  if len (aMemo)>=13
    d2k3 := aMemo[13]
  endif
  if len (aMemo)>=14
    d2k4 := aMemo[14]
  endif
  if len (aMemo)>=15
    d2k5 := aMemo[15]
  endif
  if len (aMemo)>=16
    d2n1 := aMemo[16]
  endif
  if len (aMemo)>=17
    d2n2 := aMemo[17]
  endif
endif

if !fSilent
  UzorTxt()
endif

if bFunc<>nil; EVAL(bFunc); endif

_txt:=Chr(16)+trim(_txt1)+Chr(17) + Chr(16)+_txt2+Chr(17)+;
      Chr(16)+trim(_txt3a)+Chr(17) + Chr(16)+_txt3b+Chr(17)+;
      Chr(16)+trim(_txt3c)+Chr(17) +;
      Chr(16)+_BrOtp+Chr(17) +;
      Chr(16)+dtoc(_DatOtp)+Chr(17) +;
      Chr(16)+_BrNar+Chr(17) +;
      Chr(16)+dtoc(_DatPl)+Chr(17) +;
      Iif (Empty (_VezOtpr),Chr(16)+ ""+Chr(17), Chr(16)+_VezOtpr+Chr(17))+;
      IF( lDoks2 , Chr(16)+d2k1+Chr(17) , "" )+;
      IF( lDoks2 , Chr(16)+d2k2+Chr(17) , "" )+;
      IF( lDoks2 , Chr(16)+d2k3+Chr(17) , "" )+;
      IF( lDoks2 , Chr(16)+d2k4+Chr(17) , "" )+;
      IF( lDoks2 , Chr(16)+d2k5+Chr(17) , "" )+;
      IF( lDoks2 , Chr(16)+d2n1+Chr(17) , "" )+;
      IF( lDoks2 , Chr(16)+d2n2+Chr(17) , "" )
if !fSilent
  Gather()
endif
return
*}



/*! \fn PrerCij()
 *  \brief Prerada cijene
 *  \brief Ako je u polje SERBR unesen podatak KJ/KG iznos se dobija kao KOLICINA*CIJENA*PrerCij()  - varijanta R - Rudnik
 *  \return nVrati
 */
 
function PrerCij()
*{
local cSBr:=ALLTRIM(_field->serbr), nVrati:=1
 if !EMPTY(cSbr) .and. cSbr!="*" .and. gNW=="R"
   nVrati := VAL(cSBr)/1000
 endif
return nVrati
*}



/*! \fn TestMainIndex()
 *  \brief
 *  \return lVrati
 */
 
function TestMainIndex()
*{
local lVrati:=.t., lUsedFAKT:=.t., lUsedDOKS:=.t., nOblast:=SELECT()

 local cProblemDok:=""
 SELECT (F_DOKS)
 if !USED()
   lUsedDOKS:=.f.
   O_DOKS
 else
   PushWA()
   SET ORDER to TAG "1"
 endif
 nDoksRec:=RECCOUNT2()
 SELECT (F_FAKT)
 if !USED()
   lUsedFAKT:=.f.
   O_FAKT
 else
   PushWA()
   SET ORDER to TAG "1"
 endif
 nFaktRec:=RECCOUNT2()
 if !(nDoksRec==0 .and. nFaktRec==0)
   SELECT DOKS; GO TOP; Scatter()
   SELECT FAKT; SEEK _IdFirma+_idtipdok+_brdok
   if !FOUND()
     cProblemDok:=_IdFirma+_idtipdok+_brdok
     lVrati:=.f.
   else
     SELECT FAKT; GO TOP; Scatter()
     SELECT DOKS; GO TOP; SEEK _IdFirma+_idtipdok+_brdok
     if !FOUND()
       lVrati:=.f.
       cProblemDok:=_IdFirma+"-"+_idtipdok+"-"+_brdok
     endif
   endif
   if !lVrati
     MsgBeep("Problem sa indeksnim bazama ili nepovezanost u FAKT.DBF i DOKS.DBF!#1) Izvrsiti reindeksiranje u modulu install FAKT!#2) Ako 1) ne pomaze, provjerite postojanje DOKUMENTA "+cProblemDok)
   endif
 endif
 SELECT (F_FAKT)
 if lUsedFAKT
   SELECT (F_FAKT)
   PopWA()
 else
   USE
 endif
 SELECT (F_DOKS)
 if lUsedDOKS
   SELECT (F_DOKS)
   PopWA()
 else
   USE
 endif
 SELECT (nOblast)
return lVrati
*}



/*! \fn PRNKod_ON(cKod)
 *  \brief
 *  \todo Prebaciti u /RPT
 *  \param cKod
 */
 
function PRNKod_ON(cKod)
*{
local i:=0
  for i:=1 to LEN(cKod)
    do CASE
      CASE SUBSTR(cKod,i,1)=="U"
         gPU_ON()
      CASE SUBSTR(cKod,i,1)=="I"
         gPI_ON()
      CASE SUBSTR(cKod,i,1)=="B"
         gPB_ON()
    ENDCASE
  next
return (nil)
*}


/*! \fn PRNKod_OFF(cKod)
 *  \brief 
 *  \todo Prebaciti u /RPT
 *  \param cKod
 */
 
function PRNKod_OFF(cKod)
*{
local i:=0
  for i:=1 to LEN(cKod)
    do CASE
      CASE SUBSTR(cKod,i,1)=="U"
         gPU_OFF()
      CASE SUBSTR(cKod,i,1)=="I"
         gPI_OFF()
      CASE SUBSTR(cKod,i,1)=="B"
         gPB_OFF()
    ENDCASE
  next
return (nil)
*}



/*! \fn Zagfirma()
 *  \brief Ispis zaglavlja na izvjestajima
 *  \todo Ovo je varijanta za nekog korisnika, ali ne znam kojeg. Prebaciti u /RPT
 */
 
function ZagFirma()
*{
P_12CPI
U_OFF
B_OFF
I_OFF
? "Subjekt:"; U_ON; ?? PADC(TRIM(gTS)+" "+TRIM(gNFirma),39); U_OFF
? "Prodajni objekat:"; U_ON; ?? PADC(ALLTRIM(NazProdObj()),30); U_OFF
? "(poslovnica-poslovna jedinica)"
? "Datum:"; U_ON; ?? PADC(SrediDat(DATDOK),18); U_OFF
?
?
return
*}


/*! \fn NazProdObj()
 *  \brief Naziv prodajnog objekta
 */
 
function NazProdObj()
*{
local cVrati:=""

cVrati:=TRIM(cTxt3a)
SELECT PRIPR
return cVrati
*}



/*! \fn EdDoks2()
 *  \brief Editovanje DOKS2.DBF pri unosu fakture
 */
 
function EdDoks2()
*{
local cPom:="", nArr:=SELECT(), GetList:={}

  cPom := IzFMKINI("FAKT","Doks2opis","dodatnih podataka",KUMPATH)

  if Pitanje(,"Zelite li unos/ispravku "+cPom+"? (D/N)","N")=="N"
    SELECT(nArr)
    return
  endif

 // uŸitajmo dodatne podatke iz FMK.INI u aDodPar
 // ---------------------------------------------
 aDodPar := {}

 AADD( aDodPar , IzFMKINI( "Doks2" , "ZK1" , "K1" , KUMPATH )  )
 AADD( aDodPar , IzFMKINI( "Doks2" , "ZK2" , "K2" , KUMPATH )  )
 AADD( aDodPar , IzFMKINI( "Doks2" , "ZK3" , "K3" , KUMPATH )  )
 AADD( aDodPar , IzFMKINI( "Doks2" , "ZK4" , "K4" , KUMPATH )  )
 AADD( aDodPar , IzFMKINI( "Doks2" , "ZK5" , "K5" , KUMPATH )  )
 AADD( aDodPar , IzFMKINI( "Doks2" , "ZN1" , "N1" , KUMPATH )  )
 AADD( aDodPar , IzFMKINI( "Doks2" , "ZN2" , "N2" , KUMPATH )  )

 nd2n1 := VAL(d2n1)
 nd2n2 := VAL(d2n2)

 Box(,9,75)
   @ m_x+0, m_y+2 SAY "Unos/ispravka "+cPom COLOR "GR+/B"
   @ m_x+2, m_y+2 SAY PADL(aDodPar[1],30) GET d2k1
   @ m_x+3, m_y+2 SAY PADL(aDodPar[2],30) GET d2k2
   @ m_x+4, m_y+2 SAY PADL(aDodPar[3],30) GET d2k3
   @ m_x+5, m_y+2 SAY PADL(aDodPar[4],30) GET d2k4
   @ m_x+6, m_y+2 SAY PADL(aDodPar[5],30) GET d2k5
   @ m_x+7, m_y+2 SAY PADL(aDodPar[6],30) GET nd2n1 PICT "999999999.99"
   @ m_x+8, m_y+2 SAY PADL(aDodPar[7],30) GET nd2n2 PICT "999999999.99"
   READ
 BoxC()

 if LASTKEY()<>K_ESC
   d2n1 := IF( nd2n1<>0 , ALLTRIM(STR(nd2n1)) , "" )
   d2n2 := IF( nd2n2<>0 , ALLTRIM(STR(nd2n2)) , "" )
 endif

 SELECT (nArr)
return
*}

/*! \fn SKCKalk(lSet)
 *  \brief Set Key za Cijenu iz Kalk
 *  \param lSet
 */
 
function SKCKalk(lSet)
*{
// knjizna obavijest obavezno, a mo§e se podesiti i za ostale dokumente
if _idtipdok=="25" .or.;
     IzFMKIni("FAKT","TipDok"+_idtipdok+"_OmoguciUzimanjeFCJizKALK","N",KUMPATH)=="D"
    if lSet
      SET KEY K_ALT_K to UCKalk()
      @ row()+1,27 SAY "ÚÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ¿"
      @ row()+1,27 SAY "³ <a-K> uzmi FCJ iz KALK ³"
      @ row()+1,27 SAY "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ"
    else
      SET KEY K_ALT_K TO
      @ row()+1,27 SAY "                          "
      @ row()+1,27 SAY "                          "
      @ row()+1,27 SAY "                          "
    endif
  endif
return .t.
*}


/*! \fn StUgRabKup()
 *  \brief Stampa dokumenta ugovor o rabatu
 *  \todo Treba prebaciti u /RPT
 */

function StUgRabKup()
*{
lUgRab:=.t.
lSSIP99:=.f.
StDok2()
lUgRab:=.f.
return
*}


/*! \fn Naziv19ke()
 *  \brief Vraca naziv za tip dokumenta 19
 *  \return cVrati
 */
 
function Naziv19ke()
*{
local cVrati:=""
cVrati:="Izlaz po ostalim osnovama"
return cVrati
*}


/*! \fn IzborBanke(cToken)
 *  \brief Izbor banke
 *  \param cToken
 *  \return cVrati
 */
 
function IzborBanke(cToken)
*{
local aOpc
local cVrati:=""
local nIzb:=1
local nMax:=0

aOpc := TokToNiz(cToken,",")

for i:=1 to LEN(aOpc)
	aOpc[i]:=TRIM(aOpc[i])
    	nMax:=MAX(LEN(aOpc[i]), nMax)
next

if LEN(aOpc)<1
	cVrati := ""
elseif LEN(aOpc)<2
	cVrati:=aOpc[1]
else
	aOpc[1]:=PADR(aOpc[1],nMax+1)
    	// meni
    	MsgO("Izaberite banku narucioca (Enter-izbor / Esc-bez banke)")
    	nIzb := Menu2(16,30,aOpc,nIzb)
    	MsgC()
    	if nIzb>0
      		cVrati:=aOpc[nIzb]
    	else
      		cVrati:=""
    	endif
endif
return cVrati
*}

/*! \fn TokToNiz(cTok,cSE)
 *  \brief Token pretvara u niz
 *  \param cTok  - string tokena
 *  \param cSE   - separator elementa
 *  \return aNiz
 */
 
function TokToNiz(cTok,cSE)
*{
local aNiz:={}, nE:=0, i:=0, cE:=""
  if cSE==nil 
  cSE := "." 
  endif
  nE := NUMTOKEN(cTok,cSE)
  for i:=1 to nE
    cE := TOKEN(cTok,cSE,i)
    AADD(aNiz,cE)
  next
return (aNiz)
*}



function IspisBankeNar(cBanke)
*{
local aOpc
O_BANKE
altd()
aOpc:=TokToNiz(cBanke,",")
cVrati:=""

select banke
set order to tag "ID"
altd()
for i:=1 to LEN(aOpc)
	hseek SUBSTR(aOpc[i],1,3)
	if Found()
		cVrati += ALLTRIM(banke->naz) + ", " + ALLTRIM(banke->adresa) + ", " + ALLTRIM(banke->mjesto) + ", " + ALLTRIM(aOpc[i]) + "; "
	else
		cVrati += ""
	endif
next
select partn

return cVrati
*}



/*! \fn KonZbira(lVidi)
 *  \brief 
 *  \param lVidi - ako je .t. ili nil mora da postoji i privatna varijabla nC:=1
 */

function KonZbira(lVidi)
*{
if lVidi==nil
	lVidi:=.t.
endif
 go top
 if lVidi
   @ m_x+nC++,m_y+15 SAY "  Uk     Rabat     Uk-Rabat   Por.na Pr  Ukupno"
   ++nC
 endif
 do while !eof()
   cRbr:=rbr
   nDug:=0; nRab:=0; nPor:=0
   do while rbr==cRbr
     nDug+=round( cijena*kolicina*PrerCij() , ZAOKRUZENJE)
     nRab+=round((cijena*kolicina*PrerCij())*Rabat/100 , ZAOKRUZENJE)
     nPor+=round((cijena*kolicina*PrerCij())*(1-Rabat/100)*Porez/100, ZAOKRUZENJE)
     skip
   enddo
   nDug2+=nDug; nRab2+=nRab; nPor2+=nPor
   if lVidi
     @ m_x+nC,m_y+2 SAY  "R.br:"
     @ m_x+nC,col()+1 SAY cRbr
     @ m_x+nC,col()+1 SAY nDug      pict "9999999.99"
     @ m_x+nC,col()+1 SAY nRab      pict "9999999.99"
     @ m_x+nC,col()+1 SAY nDug-nRab pict "9999999.99"
     @ m_x+nC,col()+1 SAY nPor pict          "9999999.99"
     @ m_x+nC,col()+1 SAY nDug-nRab+nPor pict "9999999.99"
     ++nC
     if nC>10
        InkeySc(0)
        @ m_x+1,m_y+2 CLEAR to m_x+12,m_y+70
        nC:=1
	@ m_x,m_y+2 SAY ""
     endif
   endif
 enddo
return
*}


/*! \fn JeStorno10()
 *  \brief True je distribucija i TipDokumenta=10  i krajnji desni dio broja dokumenta="S"
 */
 
function JeStorno10()
*{
return glDistrib .and. _idtipdok=="10" .and. UPPER(RIGHT(TRIM(_BrDok),1))=="S"
*}


/*! \fn RabPor10()
 *  \brief
 */
 
function RabPor10()
*{
local nArr:=SELECT()
SELECT FAKT
SET ORDER to TAG "1"
SEEK _idfirma+"10"+left(_brdok,gNumDio)

do while !EOF() .and.;
    _idfirma+"10"+left(_brdok,gNumDio)==idfirma+idtipdok+left(brdok,gNumDio).and.;
    _idroba<>idroba
    SKIP 1
enddo

if _idfirma+"10"+left(_brdok,gNumDio)==idfirma+idtipdok+left(brdok,gNumDio)
    _rabat    := rabat
    _porez    := porez
    // i cijenu, sto da ne?
    _cijena   := cijena
else
    MsgBeep("Izabrana roba ne postoji u fakturi za storniranje!")
endif
SELECT (nArr)
return
*}


function PopupKnjiz()
*{

private opc[8]
if glDistrib
 opc[1]:="1. generacija faktura na osnovu narudzbi i ugovora "
else
 opc[1]:="1. generacija faktura na osnovu ugovora            "
endif
opc[2]:="2. sredjivanje rednih br.stavki dokumenta"
opc[3]:="3. ispravka teksta na kraju fakture"
opc[4]:="4. svedi protustavkom vrijednost dokumenta na 0"
opc[5]:="5. obracunaj porez na sve stavke"
if gNovine=="D"
 opc[6]:="6. novine:priprema tiraza i generacija dostavnica"
elseif glDistrib
 opc[6]:="6. priprema sistemskih i konacnih otpremnica"
else
 opc[6]:="-----------------------------------------------"
endif
opc[7]:="7. FAKT  <->  diskete"
opc[8]:="8. brisanje dokumenta iz pripreme"
lKonsig := ( IzFMKINI("FAKT","Konsignacija","N",KUMPATH)=="D" )
if lKonsig
 AADD(opc,"9. generisi konsignacioni racun")
else
 AADD(opc,"-----------------------------------------------")
endif
AADD(opc,"A. kompletiranje iznosa fakture pomocu usluga")
if glDistrib
 AADD(opc,"B. generacija teretnog lista na osnovu narudzbi")
else
 AADD(opc,"-----------------------------------------------")
endif
AADD(opc, "C. import txt-a")

h[1]:=h[2]:=""
close all
private am_x:=m_x,am_y:=m_y
private Izbor:=1
do while .t.
  Izbor:=menu("prip",opc,Izbor,.f.)
  do case
    case Izbor==0
	exit
    case izbor == 1
	if glDistrib
	  Gen10iz26()
	else
	  GenUg()
	endif
    case izbor == 2
	SrediRbr()
    case izbor == 3
      O_S_PRIPR
      O_FTXT
      select pripr
      go top
      lDoks2 := ( IzFMKINI("FAKT","Doks2","N",KUMPATH)=="D" )
      if val(rbr)<>1
	MsgBeep("U pripremi se ne nalazi dokument")
      else
	IsprUzorTxt()
      endif
      close all
    case izbor == 4
       O_ROBA
       O_TARIFA
       O_S_PRIPR
       go top
       nDug:=0
       do while !eof()
	  scatter()
	  nDug+=round( _Cijena*_kolicina*(1-_Rabat/100) , ZAOKRUZENJE)
	  skip
       enddo
       _idroba:=space(10)
       _kolicina:=1
       _rbr:=str(RbrUnum(_Rbr)+1,3)
       _rabat:=0
       cDN:="D"
       Box(,4,60)
	  @ m_x+1 ,m_y+2 SAY "Artikal koji se stvara:" GET _idroba  pict "@!" valid P_Roba(@_idroba)
	  @ m_x+2 ,m_y+2 SAY "Kolicina" GET _kolicina valid {|| _kolicina<>0 } pict pickol
	  read
	  if lastkey()==K_ESC
	    boxc(); close all; return DE_CONT
	  endif
	  _cijena:=nDug/_kolicina
	  if _cijena<0
	    _Cijena:=-_cijena
	  else
	    _kolicina:=-_kolicina
	  endif
	  @ m_x+3 ,m_y+2 SAY "Cijena" GET _cijena  pict piccdem
	  cDN:="D"
	  @ m_x+4 ,m_y+2 SAY "Staviti cijenu u sifrarnik ?" GET cDN valid cDN $ "DN" pict "@!"
	  read
	  if cDN=="D"
	     select roba; replace vpc with _cijena; select pripr
	  endif
	  if lastkey()=K_ESC
	    boxc(); close all; return DE_CONT
	  endif
	  append blank
	  Gather()
       BoxC()
    case izbor == 5
       ObracunajPP()
    case izbor == 6 .and. gNovine=="D"
       MenuNovine()
    case izbor == 6 .and. glDistrib
       MenuSistOtp()
    case izbor == 7
       PrenosDiskete()
    case izbor == 8
       O_S_PRIPR
       lJos:=.t.
       do while lJos
	 lJos:=StViseDokMenu("BRISI")
	 if LEN(gFiltNov)==0
	   GO TOP
	   exit
	 endif
	 cPom:=""
	 do while !EOF() .and. idfirma+idtipdok+brdok==gFiltNov
	   SKIP 1
	   nnextRec:=RECNO()
	   SKIP -1
	   cPom:=idfirma+"-"+idtipdok+"-"+brdok
	   DELETE
	   GO (nnextRec)
	 enddo
	 if !EMPTY(cPom)
	   MsgBeep("Dokument "+cPom+" izbrisan iz pripreme!")
	 endif
       enddo
       CLOSE ALL
    case izbor == 9 .and. lKonsig
       GKRacun()
    case izbor == 10
       KomIznosFakt()
    case izbor == 11
       Teretnilist(.t.)
    case izbor == 12
    	ImportTxt()
  endcase
enddo
m_x:=am_x
m_y:=am_y
O_Edit()
select pripr
go bottom

return
*}


function ImportTxt()
*{
CLOSE ALL
cKom :="fmk.exe --batch --exe:ImportTxt --db:"+STRTRAN(TRIM(gNFirma), " ", "_") 
RUN &cKom
O_Edit()
return
*}



function GetKarC3N2(mx)
*{
local nKor:=0
local nDod:=0
local x:=0
local y:=0

if (pripr->(fieldpos("C1"))<>0 .and. gKarC1=="D")
	@ mx+(++nKor),m_y+2 SAY "C1" GET _C1 pict "@!"
	nDod++
endif

if (pripr->(fieldpos("C2"))<>0 .and. gKarC2=="D")
	SljPozGet(@x,@y,@nKor,mx,nDod)
	@ x,y SAY "C2" GET _C2 pict "@!"
	nDod++
endif

if (pripr->(fieldpos("C3"))<>0 .and. gKarC3=="D")
	SljPozGet(@x,@y,@nKor,mx,nDod)
	@ x,y SAY "C3" GET _C3 pict "@!"
	nDod++
endif

if (pripr->(fieldpos("N1"))<>0 .and. gKarN1=="D")
	SljPozGet(@x,@y,@nKor,mx,nDod)
	@ x,y SAY "N1" GET _N1 pict "999999.999"
	nDod++
endif

if (pripr->(fieldpos("N2"))<>0 .and. gKarN2=="D")
	SljPozGet(@x,@y,@nKor,mx,nDod)
	@ x,y SAY "N2" GET _N2 pict "999999.999"
	nDod++
endif

if (pripr->(fieldpos("opis"))<>0)
	SljPozGet(@x,@y,@nKor,mx,nDod)
	@x,y SAY "Opis" GET _opis pict "@S40"
	nDod++
endif

if nDod>0
	++nKor
endif

return nKor
*}


static function SljPozGet(x,y,nKor,mx,nDod)
*{
if nDod>0
	if nDod%3==0
		x:=mx+(++nKor)
		y:=m_y+2
	else
		x:=mx+nKor
		y:=col()+2
	endif
else
	x:=mx+(++nKor)
	y:=m_y+2
endif
return
*}

