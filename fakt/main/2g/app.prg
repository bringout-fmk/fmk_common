#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/main/2g/app.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.36 $
 * $Log: app.prg,v $
 * Revision 1.36  2004/03/23 15:47:58  sasavranic
 * no message
 *
 * Revision 1.35  2004/02/12 15:37:16  sasavranic
 * Kopiranje podataka za novu grupu po uzoru na postojecu.
 *
 * Revision 1.34  2004/01/13 19:07:54  sasavranic
 * appsrv konverzija
 *
 * Revision 1.33  2003/12/10 11:57:59  sasavranic
 * no message
 *
 * Revision 1.32  2003/12/04 11:11:43  sasavranic
 * Uvedena konverzija i za varijantu "2" fakture
 *
 * Revision 1.31  2003/11/13 15:36:22  sasavranic
 * no message
 *
 * Revision 1.30  2003/10/04 12:32:48  sasavranic
 * uveden security sistem
 *
 * Revision 1.29  2003/07/06 21:50:54  mirsad
 * nova varijanta: unos radnog naloga na 12-ki (FMK.INI/KUMPATH/FAKT/RadniNalozi=D)
 *
 * Revision 1.28  2003/05/10 15:07:57  mirsad
 * dodatna polja za robne karakteristike u kumulativnoj bazi C1,C2,C3,N1,N2
 *
 * Revision 1.27  2003/04/25 10:44:36  ernad
 * ispravka za Planiku: parametar Cijena13MPC=D vise ne setuje MPC u sifrarniku pri promjeni cijene u unosu 13-ke
 *
 * Revision 1.26  2003/04/16 15:02:58  mirsad
 * ispravke buga "zaklj.zapis" na pripr.dbf
 *
 * Revision 1.25  2003/04/14 20:27:28  ernad
 * bug: lock requiered pri unosu partnera
 *
 * Revision 1.24  2003/04/12 23:00:39  ernad
 * O_Edit (O_S_PRIREMA)
 *
 * Revision 1.23  2003/03/12 10:37:09  mirsad
 * parametrizirao poziv labeliranja
 *
 * Revision 1.22  2003/02/27 01:27:30  mirsad
 * male dorade za zips
 *
 * Revision 1.21  2003/01/21 15:01:58  ernad
 * probelm excl fakt - kalk ?! direktorij kalk
 *
 * Revision 1.20  2002/12/21 11:54:17  mirsad
 * ispravke: blokovi za partnera i robu sada se setuju u setgvars gdje i treba
 *
 * Revision 1.19  2002/10/02 17:22:52  mirsad
 * testiranje-sezone
 *
 * Revision 1.18  2002/10/01 13:34:47  mirsad
 * uklonio inicijalizaciju gNFirma, gFirma, gTS
 *
 * Revision 1.17  2002/09/11 13:49:02  mirsad
 * dokumentovanje INI parametara
 *
 * Revision 1.16  2002/07/08 07:53:26  ernad
 *
 *
 * debug Fakt/lBenjo
 *
 * Revision 1.15  2002/07/05 14:35:44  sasa
 * izbacena funkcija mMenuRudnik()
 *
 * Revision 1.14  2002/07/04 19:04:08  ernad
 *
 *
 * ciscenje sifrarnik fakt
 *
 * Revision 1.13  2002/07/04 08:35:12  sasa
 * dodata f-ja SetFMKRGVars()
 *
 * Revision 1.12  2002/07/04 08:34:19  mirsad
 * dokumentovanje ini parametara
 *
 * Revision 1.11  2002/07/04 08:16:10  sasa
 * dodata f-ja SetFMKSGVars()
 *
 * Revision 1.10  2002/07/03 12:23:40  sasa
 * uvodjenje methoda ::mMenuStandard
 *
 * Revision 1.9  2002/07/01 13:35:12  sasa
 * Sredjivanje menija u toku
 *
 * Revision 1.8  2002/06/28 21:49:17  ernad
 *
 *
 * dodana opcija u glavni meni "administracija db-a"
 *
 * Revision 1.7  2002/06/27 14:03:20  ernad
 *
 *
 * dok/2g init
 *
 * Revision 1.6  2002/06/26 18:22:05  ernad
 *
 *
 * oFakt:lDuzinaSifre
 *
 * Revision 1.5  2002/06/21 13:50:13  sasa
 * no message
 *
 * Revision 1.4  2002/06/21 13:05:21  sasa
 * no message
 *
 * Revision 1.3  2002/06/21 12:02:50  sasa
 * no message
 *
 * Revision 1.2  2002/06/18 13:09:02  sasa
 * no message
 *
 * Revision 1.1.1.1  2002/06/17 18:30:18  ernad
 * no message
 *
 *
 */


/*! \file fmk/fakt/main/2g/app.prg
 *  \brief
 */

/*! \ingroup ini
  * \var *string FmkIni_KumPath_ZASTITA_PodBugom
  * \brief Odredjuje da li ce se zabraniti izbor opcija glavnog menija
  * \param N - ne, default vrijednost
  * \param D - da, zabrani izbor opcija glavnog menija (kao da je pod bug-om)
  */
*string FmkIni_KumPath_ZASTITA_PodBugom;


/*! \ingroup ini
  * \var *string FmkIni_SifPath_SifRoba_DuzSifra
  * \brief Odredjuje duzinu sifre robe pri unosu u dokumentu
  * \param 10 - default vrijednost
  */
*string FmkIni_SifPath_SifRoba_DuzSifra;


/*! \ingroup ini
  * \var *string FmkIni_SifPath_FAKT_TekVpc
  * \brief Odredjuje koja je tekuca veleprodajna cijena iz sifrarnika robe
  * \param 1 - VPC, default vrijednost
  * \param 2 - VPC2
  */
*string FmkIni_SifPath_FAKT_TekVpc;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_Distribucija
  * \brief Odredjuje da li se koriste specificnosti za distribuciju robe (sistem koji koristi Vindija)
  * \param N - default vrijednost
  * \param D - da, koriste se specificnosti za distribuciju robe
  */
*string FmkIni_KumPath_FAKT_Distribucija;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_DestinacijaNaFakturi
  * \brief Da li ce se prikazivati destinacija kupca na fakturi?
  * \param N - default vrijednost
  * \param D - da, prikazivati destinaciju kupca na fakturi
  */
*string FmkIni_KumPath_FAKT_DestinacijaNaFakturi;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_TipDok01_StampaPovrataDobavljacu_DefaultOdgovor
  * \brief Odredjuje da li ce se pojaviti upit za stampanje dokumenta povrata dobavljacu pri izboru opcije stampanja dokumenta tipa 01 (ulaz), pod uslovom da je unesena kolicina manja od 0
  * \param 0 - nema upita, default vrijednost
  * \param D - pojavljuje se upit sa ponudjenim odgovorom "D"
  * \param N - pojavljuje se upit sa ponudjenim odgovorom "N"
  */
*string FmkIni_KumPath_FAKT_TipDok01_StampaPovrataDobavljacu_DefaultOdgovor;


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
  * \var *string FmkIni_KumPath_POREZI_PPUgostKaoPPU
  * \brief Odredjuje nacin obracuna poreza u maloprodaji (u ugostiteljstvu). Ako se definise ovaj parametar ima prioritet nad istim koji se nalazi u ExePath-u
  * \param - - gleda se vrijednost drugog parametra koji je pod istim nazivom ali se nalazi u ExePath-u, default vrijednost
  * \param M - racuna PRUC iskljucivo koristeci propisani donji limit RUC-a, default vrijednost
  * \param R - racuna PRUC na osnovu stvarne RUC ili na osnovu pr.d.lim.RUC-a ako je stvarni RUC manji od propisanog limita
  * \param J - metoda koju koriste u Jerry-ju
  * \param D - racuna PPU a ne PRUC (stari sistem), s tim da se PP racuna na istu osnovicu kao i PPU
  * \param N - racuna PPU a ne PRUC (stari sistem), s tim da se PP racuna na istu osnovicu kao i PPP
  * \sa FmkIni_ExePath_POREZI_PPUgostKaoPPU
  */
*string FmkIni_KumPath_POREZI_PPUgostKaoPPU;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_Svi_SQLLog
  * \brief Da li se koriste SQL logovi?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_KumPath_Svi_SQLLog;


/*! \ingroup ini
  * \var *string FmkIni_PrivPath_FAKT_ReadOnly
  * \brief Da li se FAKT koristi samo za preglede?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_PrivPath_FAKT_ReadOnly;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_FMK_TerminalServer
  * \brief
  * \param N - default vrijednost
  * \param
  */
*string FmkIni_ExePath_FMK_TerminalServer;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_10PoNarudzbi
  * \brief Da li se koristi evidencija po narudzbi?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_KumPath_FAKT_10PoNarudzbi;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_CROBA_GledajFakt
  * \brief Da li se FAKT-dokumenti koriste za utvrdjivanje stanja robe u centralnoj bazi robe CROBA?
  * \param N - ne, default vrijednost
  * \param D - da
  */
*string FmkIni_KumPath_CROBA_GledajFakt;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_SQL_cSQLKom
  * \brief
  * \param mysql -f -h 192.168.0.1 -B -N - default vrijednost
  * \param
  */
*string FmkIni_KumPath_SQL_cSQLKom;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_CROBA_CROBA_RJ
  * \brief Lista radnih jedinica ciji se dokumenti odrazavaju na stanje u centralnoj bazi robe CROBA
  * \param 10#20 - radne jedinice 10 i 20, default vrijednost
  */
*string FmkIni_KumPath_CROBA_CROBA_RJ;


/*! \ingroup Zips
  * \var *string FmkIni_ExePath_Fakt_Specif_ZIPS
  * \brief Odredjuje mogucnost koristenja specificnosti radjenih za Zips
  * \param N - ne, default vrijednost
  * \param D - da, omoguci specificnosti radjene za Zips
  */
*string FmkIni_ExePath_Fakt_Specif_ZIPS;



/*! \fn TFaktModNew()
 *  \brief
 */
 
function TFaktModNew()
*{
local oObj

#ifdef CLIP

#else
	oObj:=TFaktMod():new()
#endif

oObj:self:=oObj
return oObj
*}


#ifdef CPP
/*! \class TFaktMod
 *  \brief FAKT aplikacijski modul
 */

class TFaktMod: public TAppMod
{
	public:
	*int nDuzinaSifre;
	*string cTekVpc;
	*void dummy();
	*void setGVars();
	*void mMenu();
	*void mMenuStandard();
	*void sRegg();
	*void initdb();
	*void srv();	
#endif

#ifndef CPP
#include "class(y).ch"
CREATE CLASS TFaktMod INHERIT TAppMod
	EXPORTED:
	var nDuzinaSifre 
	var cTekVpc
	var lVrstePlacanja
	var lOpcine
	var lDoks2
	var lId_J
	var lCRoba
	var cRoba_Rj
	var lOpresaStampa
	method dummy 
	method setGVars
	method mMenu
	method mMenuStandard
	method sRegg
	method initdb
	method srv
END CLASS
#endif


/*! \fn TFaktMod::dummy()
 *  \brief dummy
 */

*void TFaktMod::dummy()
*{
method dummy()
return
*}


*void TFaktMod::initdb()
*{
method initdb()

::oDatabase:=TDBFaktNew()

return NIL
*}


/*! \fn *void TFaktMod::mMenu()
 *  \brief Osnovni meni FAKT modula
 */
*void TFaktMod::mMenu()
*{
method mMenu()

private Izbor
private lPodBugom

if gSql=="D"
	O_Log()
endif


SETKEY(K_SH_F1,{|| Calc()})
Izbor:=1

O_DOKS
SELECT doks
TrebaRegistrovati(20)
USE

::mMenuStandard()

::quit()

return nil
*}


*void TFaktMod::mMenuStandard()
*{
method mMenuStandard

private opc:={}
private opcexe:={}

AADD(opc,"1. unos/ispravka dokumenta             ")
if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","UNOSDOK"))
	AADD(opcexe,{|| Knjiz()})
else
	AADD(opcexe,{|| MsgBeep(cZabrana)})
endif
AADD(opc,"2. izvjestaji")
AADD(opcexe,{|| Izvj()})
AADD(opc,"3. pregled dokumenata")
AADD(opcexe,{|| MBrDoks()})
AADD(opc,"4. generacija dokumenata")
if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","GENDOK"))
	AADD(opcexe,{|| MGenDoks()})
else
	AADD(opcexe,{|| MsgBeep(cZabrana)})
endif
AADD(opc,"5. moduli - razmjena podataka")
if (ImaPravoPristupa(goModul:oDataBase:cName,"RAZDB","MODULIRAZMJENA"))
	AADD(opcexe,{|| ModRazmjena()})
else
	AADD(opcexe,{|| MsgBeep(cZabrana)})
endif
AADD(opc,"6. udaljene lokacije - razmjena")
if (ImaPravoPristupa(goModul:oDataBase:cName,"RAZDB","UDLOKRAZMJENA"))
	AADD(opcexe,{|| PrenosDiskete()})
else
	AADD(opcexe,{|| MsgBeep(cZabrana)})
endif
AADD(opc,"7. ostale operacije nad dokumentima")
AADD(opcexe,{|| MAzurDoks()})
AADD(opc,"------------------------------------")
AADD(opcexe,{|| nil})
AADD(opc,"8. sifrarnici")
AADD(opcexe,{|| Sifre()})
AADD(opc,"9. administracija baze podataka")
if (ImaPravoPristupa(goModul:oDataBase:cName,"MAIN","DBADMIN"))
	AADD(opcexe,{|| MnuAdmin()})
else
	AADD(opcexe,{|| MsgBeep(cZabrana)})
endif
AADD(opc,"------------------------------------")
AADD(opcexe,{|| nil})
AADD(opc,"A. stampa azuriranog dokumenta")
AADD(opcexe,{|| StAzFakt()})
AADD(opc,"P. povrat dokumenta u pripremu")
if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","POVRATDOK"))
	AADD(opcexe,{|| Povrat()})
else
	AADD(opcexe,{|| MsgBeep(cZabrana)})
endif
AADD(opc,"------------------------------------")
AADD(opcexe,{|| nil})
AADD(opc,"X. parametri")
if (ImaPravoPristupa(goModul:oDataBase:cName,"PARAM","PARAMETRI"))
	AADD(opcexe,{|| Mnu_Params()})
else
	AADD(opcexe,{|| MsgBeep(cZabrana)})
endif
private Izbor:=1

Menu_SC("mfak", .t., lPodBugom)

return 
*}


*void TFaktMod::sRegg()
*{
method sRegg()
sreg("FAKT.EXE","FAKT")
return
*}

*void TFaktMod::srv()
*{
method srv()
? "Pokrecem FAKT aplikacijski server"
if (MPar37("/KONVERT", goModul))
	if LEFT(self:cP5,3)=="/S="
		cKonvSez:=SUBSTR(self:cP5,4)
		? "Radim sezonu: " + cKonvSez
		if cKonvSez<>"RADP"
			// prebaci se u sezonu cKonvSez
			goModul:oDataBase:cSezonDir:=SLASH+cKonvSez
 			goModul:oDataBase:setDirKum(trim(goModul:oDataBase:cDirKum)+SLASH+cKonvSez)
 			goModul:oDataBase:setDirSif(trim(goModul:oDataBase:cDirSif)+SLASH+cKonvSez)
 			goModul:oDataBase:setDirPriv(trim(goModul:oDataBase:cDirPriv)+SLASH+cKonvSez)
		endif
	endif
	goModul:oDataBase:KonvZN()
	goModul:quit(.f.)
endif
return
*}



/*! \fn *void TFaktMod::setGVars()
 *  \brief opste funkcije FIN modula
 *  \todo izbaciti varijablu lBenjo
 */
*void TFaktMod::setGVars()
*{
method setGVars()
local cSekcija
local cVar
local cVal

SetFmkRGVars()

SetFmkSGVars()

SetSpecifVars()

::nDuzinaSifre:=VAL(IzFMKINI('SifRoba','DuzSifra','10', SIFPATH))
::cTekVpc:=IzFmkIni("FAKT","TekVpc","1",SIFPATH)
public gFiltNov:=""
public gVarNum:="1"
public gProtu13:="N"
//  protudokument 13-ke

public lBenjo
//public gFirma:="10", gTS:="Preduzece"
public gFPzag:=0
public gZnPrec:="="
//public gNFirma:=space(20)  // naziv firme
public gNW:="D"  // new vawe
public gNovine:="N"        // novine/stampa u asortimanu
public gnDS:=5             // duzina sifre artikla - sinteticki
public gFaktFakt:="N"
public gBaznaV:="D"
public Kurslis:="1"
public PicCdem:="99999999.99"
public Picdem:="99999999.99"
public Pickol:="9999999.999"
public gnLMarg:=6  // lijeva margina teksta
public gnLMargA5:=6  // lijeva margina teksta
public gnTMarg:=11 // gornja margina
public gnTMarg2:=3 // vertik.pomj. stavki u fakturi var.9
public gnTMarg3:=0 // vertik.pomj. totala fakture var.9
public gnTMarg4:=0 // vertik.pomj. za donji dio fakture var.9
public gMjStr:="Zenica", gMjRJ:="N"
public gDK1:="N"
public gDK2:="N"

public g10Str:="RA¬UN/OTPREMNICA br."
public g10Str2T:="              Predao                  Odobrio                  Preuzeo"
public g10Str2R:="\tab Predao\tab Odobrio\tab Preuzeo"

public g16Str:="KONSIGNAC.RA¬UN br."
public g16Str2T:="              Predao                  Odobrio                  Preuzeo"
public g16Str2R:="\tab Predao\tab Odobrio\tab Preuzeo"

public g06Str:="ZADU¦.KONS.SKLAD.br."
public g06Str2T:="              Predao                  Odobrio                  Preuzeo"
public g06Str2R:="\tab Predao\tab Odobrio\tab Preuzeo"

public g20Str:="PREDRA¬UN br."
public g20Str2T:="                                                               Direktor"
public g20Str2R:="\tab \tab \tab Direktor:"

public g11Str:="RA¬UN MP br."
public g11Str2T:="              Predao                  Odobrio                  Preuzeo"
public g11Str2R:="\tab Predao\tab Odobrio\tab Preuzeo"

public g15Str:="RA¬UN br."
public g15Str2T:="              Predao                  Odobrio                  Preuzeo"
public g15Str2R:="\tab Predao\tab Odobrio\tab Preuzeo"

public g12Str:="OTPREMNICA br."
public g12Str2T:="              Predao                  Odobrio                  Preuzeo"
public g12Str2R:="\tab Predao\tab Odobrio\tab Preuzeo"

public g13Str:="OTPREMNICA U MP br."
public g13Str2T:="              Predao                  Odobrio                  Preuzeo"
public g13Str2R:="\tab Predao\tab Odobrio\tab Preuzeo"

public g21Str:="REVERS br."
public g21Str2T:="              Predao                  Odobrio                  Preuzeo"
public g21Str2R:="\tab Predao\tab Odobrio\tab Preuzeo"

public g22Str:="ZAKLJ.OTPREMNICA br."
public g22Str2T:="              Predao                  Odobrio                  Preuzeo"
public g22Str2R:="\tab Predao\tab Odobrio\tab Preuzeo"

public g25Str:="KNJI¦NA OBAVIJEST br."
public g25Str2T:="              Predao                  Odobrio                  Preuzeo"
public g25Str2R:="\tab Predao\tab Odobrio\tab Preuzeo"

public g26Str:="NARUD¦BA SA IZJAVOM br."
public g26Str2T:="                                      Potpis:"
public g26Str2R:="\tab \tab Potpis:"

public g27Str:="PREDRA¬UN MP br."
public g27Str2T:="                                                               Direktor"
public g27Str2R:="\tab \tab \tab Direktor:"


public gDodPar:="2", gDatVal:="N"

public gTipF:="2"
public gVarF:="2", gVarRF:=" ", gKriz:=0, gKrizA5:=2
public gERedova:=9 // extra redova
public gVlZagl:=space(12)   // naziv fajla vlastitog zaglavlja
public gPratiK:="N"
public gFZaok:=2
public gImeF:="N"
public gKomlin:=""
public gNumDio:=5
public gDetPromRj:="N"
public gVarC:=" "
public gMP:="1"
public gTabela:=1
public gZagl:="2"
public gBold:="2"
public gRekTar:="N"
public gHLinija:="N", gRabProc:="D"
public g13dcij:="1"  // default MP cijena za 13-ku
public gVar13:="1"
public gFormatA5:="0"
public gMreznoNum:="N"
public gIMenu:="3", gOdvT2:=0, gV12Por:="N", gVFU:="1"
public gModemVeza:="N"
public gFPZagA5:=0, gnTMarg2A5:=3, gnTMarg3A5:=-4, gnTMarg4A5:=0

public gFNar:=PADR("NAR.TXT",12)
public gFUgRab:=PADR("UGRAB.TXT",12)
public gDirektEdit:="N"
public gSamokol:="N"
public gRokPl:=0

public gKarC1:="N"
public gKarC2:="N"
public gKarC3:="N"
public gKarN1:="N"
public gKarN2:="N"


O_PARAMS
private cSection:="1",cHistory:=" "; aHistory:={}


RPar("50",@gVarC)       // varijanta cijene
RPar("95",@gKomLin)       // prvenstveno za win 95

if empty(gKomLin)
 gKomLin:="start "+trim(goModul:oDataBase:cDirPriv)+"\fakt.rtf"
endif

Rpar("Bv",@gBaznaV)
RPar("cr",@gZnPrec)
RPar("d1",@gnTMarg2)
RPar("d2",@gnTMarg3)
RPar("d3",@gnTMarg4)
RPar("dc",@g13dcij)
RPar("dp",@gDodPar)   // dodatni parametri fakture broj otpremnice itd
RPar("dv",@gDatVal)
RPar("er",@gERedova)
//RPar("fi",@gFirma)
//RPar("ts",@gTS)
//Rpar("fn",@gNFirma)
RPar("fp",@gFPzag)
RPar("fz",@gFZaok)
RPar("if",@gImeF)
RPar("im",@gIMenu)
RPar("k1",@gDK1)
RPar("k2",@gDK2)
RPar("mp",@gMP)       // varijanta maloprodajne cijene
RPar("mr",@gMjRJ)
RPar("nd",@gNumdio)
RPar("PR",@gDetPromRj)
Rpar("ff",@gFaktFakt)
Rpar("nw",@gNW)
Rpar("NF",@gFNar)
Rpar("UF",@gFUgRab)
Rpar("DE",@gDirektEdit)
Rpar("sk",@gSamoKol)
Rpar("rP",@gRokPl)
Rpar("no",@gNovine)
Rpar("ds",@gnDS)
Rpar("ot",@gOdvT2)
RPar("p0",@PicCDem)
RPar("p1",@PicDem)
RPar("p2",@PicKol)
RPar("pk",@gPratik)
RPar("pr",@gnLMarg)
RPar("56",@gnLMargA5)
RPar("pt",@gnTMarg)
RPar("r1",@g10Str2R)
RPar("r2",@g16Str2R)
RPar("r5",@g06Str2R)

RPar("s1",@g10Str)
RPar("s9",@g16Str)
RPar("r3",@g06Str)
RPar("s2",@g11Str)
RPar("xl",@g15Str)
RPar("s3",@g20Str)
RPar("s4",@g10Str2T)
RPar("s8",@g16Str2T)
RPar("r4",@g06Str2T)
RPar("s5",@g11Str2T)
RPar("xm",@g15Str2T)
RPar("s6",@g20Str2T)
RPar("s7",@gMjStr)
RPar("tb",@gTabela)
RPar("tf",@gTipF)
RPar("vf",@gVarF)
RPar("kr",@gKriz)
RPar("55",@gKrizA5)
RPar("51",@gFPzagA5)
RPar("52",@gnTMarg2A5)
RPar("53",@gnTMarg3A5)
RPar("54",@gnTMarg4A5)
RPar("vp",@gV12Por)
RPar("vu",@gVFU)
RPar("vr",@gVarRF)
RPar("vo",@gVar13)
RPar("vn",@gVarNum)
RPar("vz",@gVlZagl)
RPar("x1",@g11Str2R)
RPar("xn",@g15Str2R)
RPar("x2",@g20Str2R)
RPar("x3",@g12Str)
RPar("x4",@g12Str2T)
RPar("x5",@g12Str2R)
RPar("x6",@g13Str)
RPar("x7",@g13Str2T)
RPar("x8",@g13Str2R)
RPar("x9",@g21Str)
RPar("xa",@g21Str2T)
RPar("xb",@g21Str2R)
RPar("xc",@g22Str)
RPar("xd",@g22Str2T)
RPar("xe",@g22Str2R)
RPar("xf",@g25Str)
RPar("xg",@g25Str2T)
RPar("xh",@g25Str2R)
RPar("xi",@g26Str)
RPar("xj",@g26Str2T)
RPar("xk",@g26Str2R)
RPar("xo",@g27Str)
RPar("xp",@g27Str2T)
RPar("xr",@g27Str2R)
RPar("za",@gZagl)   // dodatni parametri fakture broj otpremnice itd
RPar("zb",@gbold)
RPar("RT",@gRekTar)
RPar("HL",@gHLinija)
RPar("rp",@gRabProc)
RPar("pd",@gProtu13)
RPar("a5",@gFormatA5)
RPar("mn",@gMreznoNum)
RPar("mV",@gModemVeza)
RPar("g1",@gKarC1)
RPar("g2",@gKarC2)
RPar("g3",@gKarC3)
RPar("g4",@gKarN1)
RPar("g5",@gKarN2)

/*
if empty(gNFirma)
  Box(,1,50)
    Beep(1)
    @ m_x+1,m_y+2 SAY "Unesi naziv firme:" GET gNFirma pict "@!"
    read
  BoxC()
  WPar("fn",gNFirma)
endif
*/

if valtype(gtabela)<>"N"
   gTabela:=1
endif

select params
use
cSekcija:="SifRoba"; cVar:="PitanjeOpis"
IzFmkIni (cSekcija,cVar, IzFMkIni(cSekcija,cVar,'D') , SIFPATH)
cSekcija:="SifRoba"; cVar:="ID_J"
IzFmkIni (cSekcija,cVar, IzFMkIni(cSekcija,cVar,'N') , SIFPATH)
cSekcija:="SifRoba"; cVar:="VPC2"
IzFmkIni (cSekcija,cVar, IzFMkIni(cSekcija,cVar,'D') , SIFPATH)
cSekcija:="SifRoba"; cVar:="MPC2"
IzFmkIni (cSekcija,cVar, IzFMkIni(cSekcija,cVar,'D') , SIFPATH)
cSekcija:="SifRoba"; cVar:="MPC3"
IzFmkIni (cSekcija,cVar, IzFMkIni(cSekcija,cVar,'D') , SIFPATH)
cSekcija:="SifRoba"; cVar:="PrikId"
IzFmkIni (cSekcija,cVar, IzFMkIni(cSekcija,cVar,'ID') , SIFPATH)
cSekcija:="SifRoba"; cVar:="DuzSifra"
IzFmkIni (cSekcija,cVar, IzFMkIni(cSekcija,cVar,'10') , SIFPATH)

cSekcija:="BarKod"; cVar:="Auto"
IzFmkIni (cSekcija,cVar, IzFMkIni(cSekcija,cVar,'N') , SIFPATH)
cSekcija:="BarKod"; cVar:="AutoFormula"
IzFmkIni (cSekcija,cVar, IzFMkIni(cSekcija,cVar,'ID') , SIFPATH)
cSekcija:="BarKod"; cVar:="Prefix"
IzFmkIni (cSekcija,cVar, IzFMkIni(cSekcija,cVar,'') , SIFPATH)
cSekcija:="BarKod"; cVar:="NazRTM"
IzFmkIni (cSekcija,cVar, IzFMkIni(cSekcija,cVar,'barkod') , SIFPATH)

public glDistrib := (IzFmkIni("FAKT","Distribucija","N",KUMPATH)=="D")
public gDest := (IzFmkIni("FAKT","DestinacijaNaFakturi","N",KUMPATH)=="D")
public gPovDob := IzFmkIni("FAKT_TipDok01","StampaPovrataDobavljacu_DefaultOdgovor","0",KUMPATH)

public gUVarPP := IzFMKINI("POREZI","PPUgostKaoPPU","M")
cPom:=IzFMKINI("POREZI","PPUgostKaoPPU","-",KUMPATH)
IF cPom<>"-"
  gUVarPP:=cPom
ENDIF
gSQL:=IzFmkIni("Svi","SQLLog","N",KUMPATH)

if IzFmkIni("FAKT","ReadOnly","N", PRIVPATH)=="D"
   gReadOnly:=.t.
   @ 22,65 SAY "ReadOnly rezim"
endif

if IzFmkIni("FMK","TerminalServer","N")=="D"
   PUBLIC gTerminalServer
   gTerminalServer:=.t.
endif

public lPoNarudzbi
lPoNarudzbi:= ( IzFMKINI("FAKT","10PoNarudzbi","N",KUMPATH)=="D" )

public lSpecifZips
lSpecifZips:= ( IzFmkIni("FAKT_Specif","ZIPS","N")=="D" )

IF IzFmkIni('CROBA','GledajFakt','N',KUMPATH)=='D'
   //PUBLIC gCENTPATH:=IzFmkIni('CROBA','CROBA_DIR','C:\SIGMA\FMK\',PRIVPATH)
   PUBLIC gSQLKom:= IzFmkIni("SQL","cSQLKom","mysql -f -h 192.168.0.1 -B -N",KUMPATH)
   gSQLKom+=" "
  IzFmkIni('CROBA','CROBA_RJ','10#20',KUMPATH)
ENDIF

public gModul:="FAKT"
gGlBaza:="FAKT.DBF"

gRobaBlock:={|Ch| FaRobaBlock(Ch)}
gPartnBlock:={|Ch| FaPartnBlock(Ch)}

lBenjo:=IsTrgom()

public glCij13Mpc:=(IzFmkIni("FAKT","Cijena13MPC","N",KUMPATH)=="D")

public gcLabKomLin:=IzFmkIni("FAKT","PozivZaLabeliranje","labelira labelu",KUMPATH)
public gNovine:=(IzFmkIni("STAMPA","Opresa","N",KUMPATH))

public glRadNal
glRadNal:=(IzFmkIni("FAKT","RadniNalozi","N",KUMPATH)=="D")

public gKonvZnWin
gKonvZnWin:=IzFmkIni("DelphiRB","Konverzija","3",EXEPATH)

::lVrstePlacanja:=IzFMKIni("FAKT","VrstePlacanja","N",SIFPATH)=="D"

::lOpcine:=IzFmkIni("FAKT","Opcine","N",SIFPATH)=="D"

::lDoks2:=IzFMKINI("FAKT","Doks2","N",KUMPATH)=="D"

::lId_J:=IzFmkIni("SifRoba", "ID_J", "N", SIFPATH)=="D"

::lCRoba:=(IzFmkIni('CROBA','GledajFakt','N',KUMPATH)=='D')

::cRoba_Rj:=IzFmkIni('CROBA','CROBA_RJ','10#20',KUMPATH)

::lOpresaStampa:=IzFmkIni('Opresa','Remitenda','N',PRIVPATH)=="D"

if !(goModul:oDatabase:lAdmin)
	MsgO("Pakujem pripremu")
		O_PRIPR
		__dbPack()
		USE
	MsgC()
endif

return
*}


