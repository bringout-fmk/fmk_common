#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/param/1g/param.prg,v $
 * $Author: mirsadsubasic $ 
 * $Revision: 1.14 $
 * $Log: param.prg,v $
 * Revision 1.14  2003/09/22 08:40:11  mirsadsubasic
 * sitna ispravka na novim parametrima WinFmk
 *
 * Revision 1.13  2003/09/20 13:20:32  mirsadsubasic
 * Uvodjenje novih parametara u parametri Win stampe fakture -- merkomerc
 *
 * Revision 1.12  2003/05/10 15:07:57  mirsad
 * dodatna polja za robne karakteristike u kumulativnoj bazi C1,C2,C3,N1,N2
 *
 * Revision 1.11  2002/12/30 16:34:27  mirsad
 * no message
 *
 * Revision 1.10  2002/09/18 11:38:42  mirsad
 * dokumentovanje PARAMS i INI(proizvj.ini) parametara
 *
 * Revision 1.9  2002/09/12 07:39:42  mirsad
 * dokumentovanje INI parametara
 *
 * Revision 1.8  2002/07/04 08:34:19  mirsad
 * dokumentovanje ini parametara
 *
 * Revision 1.7  2002/07/03 12:24:00  sasa
 * u listu parametara dodata i podesenja stampaca
 *
 * Revision 1.6  2002/06/24 08:15:14  sasa
 * no message
 *
 * Revision 1.5  2002/06/21 14:06:15  sasa
 * no message
 *
 * Revision 1.4  2002/06/21 13:28:50  sasa
 * no message
 *
 * Revision 1.3  2002/06/21 12:03:00  sasa
 * no message
 *
 * Revision 1.2  2002/06/18 13:33:36  sasa
 * no message
 *
 * Revision 1.1.1.1  2002/06/17 18:30:18  ernad
 * no message
 *
 *
 */

/*! \file fmk/fakt/param/1g/param.prg
 *  \brief Parametri
 */


/*! \ingroup ini
  * \var *string FmkIni_ExePath_Fakt_NazRTM
  * \brief Naziv rtm-fajla koji definise izgled fakture
  * \param  - prazno (nema ga), default vrijednost
  * \param fakt1 - koristi se fakt1.rtm
  */
*string FmkIni_ExePath_Fakt_NazRTM;


/*! \ingroup ini
  * \var *string FmkIni_ExePath_Fakt_NazRTMFax
  * \brief Naziv rtm-fajla koji definise izgled fakture koja se salje faksom
  * \param  - prazno (nema ga), default vrijednost
  * \param fax1 - koristi se fax1.rtm
  */
*string FmkIni_ExePath_Fakt_NazRTMFax;



/*! \fn Mnu_Params()
 *  \brief Otvara glavni menij sa parametrima
 */
 
function Mnu_Params()
*{
private cSection:="1"
private cHistory:=" "
private aHistory:={}
private Izbor:=1
private opc:={}
private opcexe:={}

O_ROBA
O_PARAMS

SELECT params
USE

AADD(opc,"1. postaviti osnovne podatke o firmi           ")
AADD(opcexe,{|| SetFirma()})

AADD(opc,"2. postaviti varijante obrade dokumenata       ") 
AADD(opcexe,{|| SetVarijante()})

AADD(opc,"3. postaviti varijante izgleda dokumenata      ")
AADD(opcexe,{|| SetT1()})

AADD(opc,"4. nazivi dokumenata i teksta na kraju (potpis)")
AADD(opcexe,{|| SetT2()})

AADD(opc,"5. postaviti parametre prikaza cijene,%,iznosa ")
AADD(opcexe,{|| SetPICT()})

AADD(opc,"6. postaviti parametre - razno                 ")
AADD(opcexe,{|| SetRazno()})

AADD(opc,"7. parametri Win stampe (DelphiRB)             ")
AADD(opcexe,{|| P_WinFakt()})

AADD(opc,"8. parametri stampaca             ")
AADD(opcexe,{|| PPrint()})

Menu_SC("parf")

return nil 
*}

*string Params_ff;
/*! \ingroup params
 *  \var Params_ff
 *  \brief Omoguciti poredjenje FAKT sa FAKT druge firme?
 *  \param D - da
 *  \param N - ne
 *  \note gFaktFakt
 */


*string Params_nw;
/*! \ingroup params
 *  \var Params_nw
 *  \brief Novi korisnicki interfejs?
 *  \param D - da
 *  \param N - ne
 *  \param R - za Rudnik
 *  \param T - testni
 *  \note gNW
 */


*string Params_NF;
/*! \ingroup params
 *  \var Params_NF
 *  \brief Naziv fajla-obrasca narudzbenice
 *  \param nar.txt - koristi se fajl nar.txt u PRIVPATH-u
 *  \note gFNar
 */


*string Params_UF;
/*! \ingroup params
 *  \var Params_UF
 *  \brief Naziv fajla teksta ugovora o rabatu
 *  \param ugrab.txt - koristi se fajl ugrab.txt u PRIVPATH-u
 *  \note gFUgRab
 */


*string Params_DE;
/*! \ingroup params
 *  \var Params_DE
 *  \brief Da li je ukljucen mod direktnog edita browse-tabela
 *  \param D - da
 *  \param N - ne
 *  \note gDirektEdit
 */


*string Params_sk;
/*! \ingroup params
 *  \var Params_sk
 *  \brief Voditi samo kolicine?
 *  \param D - da
 *  \param N - ne
 *  \note gSamoKol
 */


*string Params_rP;
/*! \ingroup params
 *  \var Params_rP
 *  \brief Tekuca vrijednost za rok placanja
 *  \param 0 - 0 dana tj. rok placanja je odmah
 *  \note gRokPl
 */


*string Params_no;
/*! \ingroup params
 *  \var Params_no
 *  \brief Koriste li se artikli koji se vode po sintetickoj sifri (roba tipa "S") ?
 *  \param D - da
 *  \param N - ne
 *  \note gNovine
 */


*string Params_ds;
/*! \ingroup params
 *  \var Params_ds
 *  \brief Sinteticka duzina sifre artikla 
 *  \param 3 - duzina sinteticke sifre artikla je 3 znaka
 *  \note gnDS
 */


*string Params_vz;
/*! \ingroup params
 *  \var Params_vz
 *  \brief Naziv fajla koji definise zaglavlje dokumenata
 *  \param zagl.txt - koristi se fajl zagl.txt u PRIVPATH-u
 *  \note gVlZagl
 */


*string Params_fz;
/*! \ingroup params
 *  \var Params_fz
 *  \brief Redni broj decimale na kojoj se vrsi zaokruzenje krajnjeg iznosa fakture
 *  \param 2 - zaokruzenje izvrsiti na drugoj decimali
 *  \note gFZaok
 */


*string Params_if;
/*! \ingroup params
 *  \var Params_if
 *  \brief Svaki izlazni fajl ima posebno ime?
 *  \param D - da
 *  \param N - ne
 *  \note gImeF
 */


*string Params_95;
/*! \ingroup params
 *  \var Params_95
 *  \brief Komandna linija za RTF fajl
 *  \param c:\sigma\fakt\11\fakt.rtf
 *  \note gKomLin
 */


*string Params_k1;
/*! \ingroup params
 *  \var Params_k1
 *  \brief Prikaz polja K1 pri unosu dokumenata?
 *  \param D - da
 *  \param N - ne
 *  \note gDk1
 */


*string Params_k2;
/*! \ingroup params
 *  \var Params_k2
 *  \brief Prikaz polja K2 pri unosu dokumenata?
 *  \param D - da
 *  \param N - ne
 *  \note gDk2
 */


*string Params_im;
/*! \ingroup params
 *  \var Params_im
 *  \brief Inicijalna meni-opcija
 *  \param 1 - 1.opcija
 *  \param 9 - 9.opcija
 *  \param A - 10.opcija
 *  \param G - 16.opcija
 *  \note gIMenu
 */


*string Params_mr;
/*! \ingroup params
 *  \var Params_mr
 *  \brief Mjesto uzimeti iz RJ?
 *  \param D - da
 *  \param N - ne
 *  \note gMjRJ
 */



/*! \fn SetRazno()
 *  \brief Podesenja parametri-razno
 */
 
function SetRazno()
*{
private cSection:="1"
private cHistory:=" "
private aHistory:={}
private GetList:={}

O_PARAMS

gKomLin:=PADR(gKomLin,70)

Box(,20,77,.f.,"OSTALI PARAMETRI (RAZNO)")
	@ m_x+2,m_y+2 SAY "Naziv fajla zaglavlja (prazno bez zaglavlja)" GET gVlZagl VALID V_VZagl()
	@ m_x+3,m_y+2 SAY "Novi korisnicki interfejs D-da/N-ne/R-rudnik/T-test" GET gNW VALID gNW $ "DNRT" PICT "@!"
  	@ m_x+4,m_y+2 SAY "Na kraju fakture izvrsiti zaokruzenje" GET gFZaok PICT "99"
  	@ m_x+5,m_y+2 SAY "Svaki izlazni fajl ima posebno ime ?" GET gImeF VALID gImeF $ "DN"
  	@ m_x+6,m_y+2 SAY "Komandna linija za RTF fajl:" GET gKomLin PICT "@S40"
  	@ m_x+8,m_y+2 SAY "Inicijalna meni-opcija (1/2/.../G)" GET gIMenu VALID gIMenu $ "123456789ABCDEFG" PICT "@!"
  	@ m_x+9,m_y+2 SAY "Prikaz K1" GET gDk1 PICT "@!" VALID gDk1 $ "DN"
  	@ m_x+9,col()+2 SAY "Prikaz K2" GET gDk2 PICT "@!" VALID gDk2 $ "DN"
  	@ m_x+10,m_y+2 SAY "Mjesto uzimati iz RJ (D/N)" GET gMjRJ PICT "@!" VALID gMjRJ $ "DN"
  	@ m_x+11,m_y+2 SAY "Omoguciti poredjenje FAKT sa FAKT druge firme (D/N) ?" GET gFaktFakt VALID gFaktFakt $ "DN" PICT "@!"
  	@ m_x+12,m_y+2 SAY "Koriste li se artikli koji se vode po sintet.sifri, roba tipa 'S' (D/N) ?" GET gNovine VALID gNovine $ "DN" PICT "@!"
  	@ m_x+13,m_y+2 SAY "Duzina sifre artikla sinteticki " GET gnDS VALID gnDS>0 PICT "9"

  	@ m_x+14,m_y+2 SAY "Naziv fajla obrasca narudzbenice" GET gFNar VALID V_VNar()
  	@ m_x+15,m_y+2 SAY "Naziv fajla teksta ugovora o rabatu" GET gFUgRab VALID V_VUgRab()
  	@ m_x+17,m_y+2 SAY "Mod direktnog edita " GET gDirektEdit PICT "@!" VALID gDirektEdit $ "DN"
  	@ m_x+18,m_y+2 SAY "Voditi samo kolicine " GET gSamoKol PICT "@!" VALID gSamoKol $ "DN"
  	@ m_x+19,m_y+2 SAY "Tekuca vrijednost za rok placanja  " GET gRokPl PICT "999"
  	READ
BoxC()

gKomLin:=TRIM(gKomLin)

if (LASTKEY()<>K_ESC)
	Wpar("ff",gFaktFakt)
   	Wpar("nw",gNW)
   	Wpar("NF",gFNar)
   	Wpar("UF",gFUgRab)
   	Wpar("DE",gDirektEdit)
   	Wpar("sk",gSamoKol)
   	Wpar("rP",gRokPl)
   	Wpar("no",gNovine)
   	Wpar("ds",gnDS)
   	WPar("vz",gVlZagl)
   	WPar("fz",gFZaok)
   	WPar("if",gImeF)
   	WPar("95",gKomLin)   // prvenstveno za win 95
   	WPar("k1",@gDk1)
   	WPar("k2",@gDk2)
   	WPar("im",gIMenu)
   	WPar("mr",gMjRJ)
endif

return 
*}


*string Params_s7;
/*! \ingroup params
 *  \var Params_s7
 *  \brief Grad tj.mjesto u kojem je firma
 *  \param Zenica - u Zenici
 *  \note gMjStr
 */


*string Params_fi;
/*! \ingroup params
 *  \var Params_fi
 *  \brief Sifra firme/default radne jedinice
 *  \param 10 - sifra firme ili default radne jedinice je 10
 *  \note gFirma
 */


*string Params_ts;
/*! \ingroup params
 *  \var Params_ts
 *  \brief Tip poslovnog subjekta
 *  \param Preduzece - znaci da se radi o preduzecu
 *  \note gTS
 */


*string Params_fn;
/*! \ingroup params
 *  \var Params_fn
 *  \brief Naziv firme
 *  \param SIGMA-COM - naziv firme je SIGMA-COM
 *  \note gNFirma
 */


*string Params_Bv;
/*! \ingroup params
 *  \var Params_Bv
 *  \brief Bazna valuta
 *  \param D - domaca
 *  \param P - pomocna
 *  \note gBaznaV
 */


*string Params_mV;
/*! \ingroup params
 *  \var Params_mV
 *  \brief Koristiti modemsku vezu?
 *  \param S - da, server
 *  \param K - da, korisnik
 *  \param N - ne koristiti modemsku vezu
 *  \note gModemVeza
 */


/*! \fn SetFirma()
 *  \brief Podesenje osnovnih parametara o firmi
 */
 
function SetFirma()
*{
private  GetList:={}

O_PARAMS

gMjStr:=PADR(gMjStr,20)

Box(,6,60,.f.,"MATICNA FIRMA, BAZNA VALUTA")
	@ m_x+2,m_y+2 SAY "Firma: " GET gFirma
  	@ m_x+3,m_y+2 SAY "Naziv: " GET gNFirma
  	@ m_x+3,col()+2 SAY "TIP SUBJ.: " GET gTS
  	@ m_x+4,m_y+2 SAY "Grad" GET gMjStr
  	@ m_x+5,m_y+2 SAY "Bazna valuta (Domaca/Pomocna)" GET gBaznaV  VALID gBaznaV $ "DP"  PICT "!@"
  	@ m_x+6,m_y+2 SAY "Koristiti modemsku vezu S-erver/K-orisnik/N" GET gModemVeza VALID gModemVeza $ "SKN"  PICT "!@"
  	READ
BoxC()

gMjStr:=TRIM(gMjStr)

if (LASTKEY()<>K_ESC)
	WPar("s7",gMjStr)
  	Wpar("fi",gFirma)
  	Wpar("ts",gTS)
  	Wpar("fn",gNFirma)
  	Wpar("Bv",gBaznaV)
  	WPar("mV",gModemVeza)
endif

return
*}


*string Params_p0;
/*! \ingroup params
 *  \var Params_p0
 *  \brief Format prikaza cijena
 *  \param 99999.999 - 5 mjesta za cijeli i 3 za decimalni dio broja
 *  \note PicCDem
 */


*string Params_p1;
/*! \ingroup params
 *  \var Params_p1
 *  \brief Format prikaza iznosa
 *  \param 99999.999 - 5 mjesta za cijeli i 3 za decimalni dio broja
 *  \note PicDem
 */


*string Params_p2;
/*! \ingroup params
 *  \var Params_p2
 *  \brief Format prikaza kolicina
 *  \param 99999.999 - 5 mjesta za cijeli i 3 za decimalni dio broja
 *  \note PicKol
 */


/*! \fn SetPict()
 *  \brief Podesenje Pict iznosa, kolicine, ...
 */
 
function SetPict()
*{
private  GetList:={}

O_PARAMS

PicKol:=STRTRAN(PicKol,"@Z ","")

Box(,4,60,.f.,"PARAMETRI PRIKAZA - PICTURE KODOVI")
	@ m_x+1,m_y+2 SAY "Prikaz cijene   " GET PicCDem
  	@ m_x+2,m_y+2 SAY "Prikaz iznosa   " GET PicDem
  	@ m_x+3,m_y+2 SAY "Prikaz kolicine " GET PicKol
  	read
BoxC()

if (LASTKEY()<>K_ESC)
   	WPar("p0",PicCDem)
   	WPar("p1",PicDem)
   	WPar("p2",PicKol)
endif

return 
*}


*string Params_dp;
/*! \ingroup params
 *  \var Params_dp
 *  \brief Omoguciti unos datuma placanja, broja otpremnice i broja narudzbe?
 *  \param 1 - da
 *  \param 2 - ne
 *  \note gDodPar
 */


*string Params_dv;
/*! \ingroup params
 *  \var Params_dv
 *  \brief Omoguciti unos datuma placanja u svim varijantama izgleda fakture 9?
 *  \param D - da
 *  \param N - ne
 *  \note gDatVal
 */


*string Params_pd;
/*! \ingroup params
 *  \var Params_pd
 *  \brief Generisati ulazni dokument (01) pri azuriranju izlaza (13-ke)?
 *  \param D - da
 *  \param N - ne
 *  \note gProtu13
 */


*string Params_mn;
/*! \ingroup params
 *  \var Params_mn
 *  \brief Ukljuciti mreznu numeraciju dokumenata?
 *  \param D - da
 *  \param N - ne
 *  \note gMreznoNum
 */


*string Params_dc;
/*! \ingroup params
 *  \var Params_dc
 *  \brief Maloprodajna cijena koja se koristi u 13-ki
 *  \param   - uvijek pri stampi pita za cijenu koja se zeli prikazati
 *  \param 1 - MPC
 *  \param 2 - MPC2
 *  \param 6 - MPC6
 *  \note g13dcij
 */


*string Params_vo;
/*! \ingroup params
 *  \var Params_vo
 *  \brief Varijanta dokumenta 13
 *  \param 1 - default varijanta
 *  \param 2 - varijanta radjena za Niagaru i Lagunu
 *  \note gVar13
 */


*string Params_vn;
/*! \ingroup params
 *  \var Params_vn
 *  \brief Varijanta numeracije dokumenta 13 za varijantu 2 dokumenta 13
 *  \param 1 - Laguna: unosi se RJ koja se zaduzuje a na osnovu tog podatka se iz sifrarnika RJ uzme konto i upise u polje IDPARTNER
 *  \param 2 - Niagara: unosi se konto prodavnice koja se zaduzuje, a brojac je u formi KKNN/MM gdje je KK oznaka prodavnice a odredjuje se kao zadnji dio konta pocevsi od 4.mjesta (13201->01,1329->09), NN je redni broj sa nulom ispred ako je manji od 10 (01,02,...,10,11,...), a MM je mjesec u kojem se pravi dokument (01,02,...,12)
 *  \note gVarNum
 */


*string Params_pk;
/*! \ingroup params
 *  \var Params_pk
 *  \brief Da li se prati trenutno stanje artikla pri unosu dokumenta?
 *  \param D - da
 *  \param N - ne
 *  \note gPratiK
 */


*string Params_50;
/*! \ingroup params
 *  \var Params_50
 *  \brief Varijante koristenja cijene
 *  \param   - samo VPC
 *  \param 1 - VPC ili VPC2
 *  \param 2 - VPC ili VPC2 
 *  \param 3 - NC
 *  \param 4 - uporedo se prikazuje MPC
 *  \param X - samo MPC
 *  \note gVarC
 */


*string Params_mp;
/*! \ingroup params
 *  \var Params_mp
 *  \brief Koja se cijena nudi u fakturi maloprodaje (11-ki) ?
 *  \param 1 - MPC
 *  \param 2 - VPC+porezi (diskontna cijena)
 *  \param 3 - MPC2
 *  \param 4 - MPC3
 *  \param 5 - MPC4
 *  \param 6 - MPC5
 *  \param 7 - MPC6
 *  \note gMP
 */


*string Params_nd;
/*! \ingroup params
 *  \var Params_nd
 *  \brief Numericki dio broja dokumenta za automatiku odredjivanja narednog broja dokumenta
 *  \param 5 - prvih 5 znakova
 *  \note gNumDio
 */


*string Params_PR;
/*! \ingroup params
 *  \var Params_PR
 *  \brief Upozorenje na promjenu radne jedinice ?
 *  \param D - da, da se ne bi slucajnom greskom upisala pogresna radna jedinica
 *  \param N - ne upozoravaj
 *  \note gDetPromRj
 */


*string Params_vp;
/*! \ingroup params
 *  \var Params_vp
 *  \brief U otpremnici (12-ki) omoguciti unos poreza ?
 *  \param D - da
 *  \param N - ne
 *  \note gV12Por
 */


*string Params_vu;
/*! \ingroup params
 *  \var Params_vu
 *  \brief Varijanta fakturisanja na osnovu ugovora
 *  \param 1 - ugovori se sortiraju po siframa, default varijanta
 *  \param 2 - ugovori se sortiraju po nazivima izuzev kod pregleda sifrarnika kroz meni sifrarnika (tada je sortiranje po siframa)
 *  \note gVFU
 */


/*! \fn SetVarijante()
 *  \brief Podesenje varijante obrade dokumenata
 */
 
function SetVarijante()
*{
private  GetList:={}

O_PARAMS

Box(,22,76,.f.,"VARIJANTE OBRADE DOKUMENATA")
	@ m_x+1,m_y+2 SAY "Unos Dat.pl, otpr., narudzbe D/N (1/2) ?" GET gDoDPar VALID gDodPar $ "12" PICT "@!"
  	@ m_x+1,m_y+46 SAY "Dat.pl.u svim v.f.9 (D/N)?" GET gDatVal VALID gDatVal $ "DN" PICT "@!"
  	@ m_x+2,m_y+2 SAY "Generacija ulaza prilikom izlaza 13" GET gProtu13 VALID gProtu13 $ "DN" PICT "@!"
  	@ m_x+3,m_y+2 SAY "Mrezna numeracija dokumenata D/N" GET gMreznoNum PICT "@!" VALID gMreznoNum $ "DN"
  	@ m_x+4,m_y+2 SAY "Maloprod.cijena za 13-ku ( /1/2/3/4/5/6)   " GET g13dcij VALID g13dcij$" 123456"
  	@ m_x+5,m_y+2 SAY "Varijanta dokumenta 13 (1/2)   " GET gVar13 VALID gVar13$"12"
  	@ m_x+6,m_y+2 SAY "Varijanta numeracije dokumenta 13 (1/2)   " GET gVarNum VALID gVarNum$"12"
  	@ m_x+7,m_y+2 SAY "Pratiti trenutnu kolicinu D/N ?" GET gPratiK PICT "@!" VALID gPratiK $ "DN"
  	@ m_x+8,m_y+2 SAY "Koristenje VP cijene:"
  	@ m_x+9,m_y+2 SAY "           ( ) samo VPC   (X) koristiti samo MPC"
  	@ m_x+10,m_y+2 SAY "           (1) VPC1/VPC2"
  	@ m_x+11,m_y+2 SAY "           (2) VPC1/VPC2 putem rabata u odnosu na VPC1"
  	@ m_x+12,m_y+2 SAY "           (3) NC , (4) Uporedo vidi i MPC............" GET gVarC
  	@ m_x+13,m_y+2 SAY "U fakturi maloprodaje koristiti:"
  	@ m_x+14,m_y+2 SAY "           (1) MPC iz sifrarnika"
  	@ m_x+15,m_y+2 SAY "           (2) VPC + PPP + PPU"
  	@ m_x+16,m_y+2 SAY "           (3) MPC2   (4) MPC3   (5) MPC4"
  	@ m_x+17,m_y+2 SAY "           (6) MPC5   (7) MPC6 ............." GET gMP VALID gMP $ "1234567"
  	@ m_x+18,m_y+2 SAY "Numericki dio broja dokumenta:" GET gNumDio PICT "99"
  	@ m_x+19,m_y+2 SAY "Upozorenje na promjenu radne jedinice:" GET gDetPromRj PICT "@!" VALID gDetPromRj $ "DN"
  	@ m_x+20,m_y+2 SAY "Var.otpr.-12 sa porezom :" GET gV12Por PICT "@!" VALID gV12Por $ "DN"
  	@ m_x+21,m_y+2 SAY "Var.fakt.po ugovorima (1/2) :" GET gVFU PICT "9" VALID gVFU $ "12"
  	@ m_x+22,m_y+2 SAY "Koristiti C1 (D/N)?" GET gKarC1 PICT "@!" VALID gKarC1$"DN"
  	@ m_x+22,col()+2 SAY "C2 (D/N)?" GET gKarC2 PICT "@!" VALID gKarC2$"DN"
  	@ m_x+22,col()+2 SAY "C3 (D/N)?" GET gKarC3 PICT "@!" VALID gKarC3$"DN"
  	@ m_x+22,col()+2 SAY "N1 (D/N)?" GET gKarN1 PICT "@!" VALID gKarN1$"DN"
  	@ m_x+22,col()+2 SAY "N2 (D/N)?" GET gKarN2 PICT "@!" VALID gKarN2$"DN"
  	read
BoxC()

if (LASTKEY()<>K_ESC)
	WPar("dp",gDodPar)
   	WPar("dv",gDatVal)
   	WPar("pd",gProtu13)
   	WPar("mn",gMreznoNum)
   	WPar("dc",g13dcij)
   	WPar("vo",gVar13)
   	WPar("vn",gVarNum)
   	WPar("pk",gPratik)
   	WPar("50",gVarC)
   	WPar("mp",gMP)  // varijanta maloprodajne cijene
   	WPar("nd",gNumdio)
   	WPar("PR",gDetPromRj)
   	WPar("vp",gV12Por)
   	WPar("vu",gVFU)
   	WPar("g1",gKarC1)
   	WPar("g2",gKarC2)
   	WPar("g3",gKarC3)
   	WPar("g4",gKarN1)
   	WPar("g5",gKarN2)
endif

return 
*}


*string Params_c1;
/*! \ingroup params
 *  \var Params_c1
 *  \brief Prikaz cijena u podstavkama ili u glavnim stavkama ?
 *  \param 1 - u podstavkama
 *  \param 2 - u glavnim stavkama
 *  \note cIzvj
 */


*string Params_tf;
/*! \ingroup params
 *  \var Params_tf
 *  \brief Varijanta izgleda fakture
 *  \param 1 -
 *  \param 2 -
 *  \param 3 -
 *  \note gTipF
 */


*string Params_vf;
/*! \ingroup params
 *  \var Params_vf
 *  \brief Podvarijanta izgleda fakture
 *  \param 1 -
 *  \param 2 -
 *  \param 3 -
 *  \param 4 -
 *  \param 9 -
 *  \param A -
 *  \param B -
 *  \note gVarF
 */


*string Params_kr;
/*! \ingroup params
 *  \var Params_kr
 *  \brief Broj redova za vertikalno pomjeranje znakova krizanja i broja dokumenta u podvarijanti 9 izgleda fakture na A4 papiru
 *  \param 0 - ne pomjeraj nista
 *  \note gKriz
 */


*string Params_55;
/*! \ingroup params
 *  \var Params_55
 *  \brief Broj redova za vertikalno pomjeranje znakova krizanja i broja dokumenta u podvarijanti 9 izgleda fakture na A5 papiru
 *  \param 0 - ne pomjeraj nista
 *  \note gKrizA5
 */


*string Params_vr;
/*! \ingroup params
 *  \var Params_vr
 *  \brief Podvarijanta izgleda RTF fakture za varijantu 2 izgleda fakture
 *  \param   - (prazno), default varijanta
 *  \param 1 - za Minex
 *  \param 2 - za Likom
 *  \param 3 - za Zenelu
 *  \note gVarRF
 */


*string Params_er;
/*! \ingroup params
 *  \var Params_er
 *  \brief Broj dodatnih redova dokumenta po listu
 *  \param
 *  \note gERedova
 */


*string Params_pr;
/*! \ingroup params
 *  \var Params_pr
 *  \brief Lijeva margina za stampanje dokumenata (broj kolona)
 *  \param 4 - odvoji slijeva 4 kolone
 *  \note gnLMarg
 */


*string Params_56;
/*! \ingroup params
 *  \var Params_56
 *  \brief Lijeva margina za stampanje dokumenata u varijanti 2 podvarijanta 9 za A5 papir (broj kolona)
 *  \param 4 - odvoji slijeva 4 kolone
 *  \note gnLMargA5
 */


*string Params_pt;
/*! \ingroup params
 *  \var Params_pt
 *  \brief Gornja margina pri stampanju dokumenata (broj redova). Koristi se samo ako nije definisan fajl zaglavlja
 *  \param 9 - odmakni 9 redova od pocetka lista
 *  \note gnTMarg
 */


*string Params_a5;
/*! \ingroup params
 *  \var Params_a5
 *  \brief Moze li se koristiti obrazac A5 u podvarijanti 9 ?
 *  \param D - uz upit da, ponudjeni odgovor na upit je uvijek "D"
 *  \param N - uz upit da, ali ponudjeni odgovor na upit je uvijek "N"
 *  \param 0 - ne, nema ni upita
 *  \note gFormatA5
 */


*string Params_fp;
/*! \ingroup params
 *  \var Params_fp
 *  \brief Horizontalno pomjeranje zaglavlja u podvarijanti 9 za A4 papir (broj kolona)
 *  \param 2 - pomjeriti dvije kolone udesno
 *  \note gFPzag
 */


*string Params_51;
/*! \ingroup params
 *  \var Params_51
 *  \brief Horizontalno pomjeranje zaglavlja u podvarijanti 9 za A5 papir (broj kolona)
 *  \param 2 - pomjeriti dvije kolone udesno
 *  \note gFPzagA5
 */


*string Params_52;
/*! \ingroup params
 *  \var Params_52
 *  \brief Vertikalno pomjeranje stavki u podvarijanti 9 za A5 papir (broj redova)
 *  \param 2 - pomjeriti dva reda prema dolje
 *  \note gnTMarg2A5
 */


*string Params_53;
/*! \ingroup params
 *  \var Params_53
 *  \brief Vertikalno pomjeranje totala u podvarijanti 9 za A5 papir (broj redova)
 *  \param 2 - pomjeriti dva reda prema dolje
 *  \note gnTMarg3A5
 */


*string Params_54;
/*! \ingroup params
 *  \var Params_54
 *  \brief Vertikalno pomjeranje donjeg dijela fakture u podvarijanti 9 za A5 papir (broj redova)
 *  \param 2 - pomjeriti dva reda prema dolje
 *  \note gnTMarg4A5
 */


*string Params_d1;
/*! \ingroup params
 *  \var Params_d1
 *  \brief Vertikalno pomjeranje stavki u podvarijanti 9 za A4 papir (broj redova)
 *  \param 2 - pomjeriti dva reda prema dolje
 *  \note gnTMarg2
 */


*string Params_d2;
/*! \ingroup params
 *  \var Params_d2
 *  \brief Vertikalno pomjeranje totala u podvarijanti 9 za A4 papir (broj redova)
 *  \param 2 - pomjeriti dva reda prema dolje
 *  \note gnTMarg3
 */


*string Params_d3;
/*! \ingroup params
 *  \var Params_d3
 *  \brief Vertikalno pomjeranje donjeg dijela fakture u podvarijanti 9 za A4 papir (broj redova)
 *  \param 2 - pomjeriti dva reda prema dolje
 *  \note gnTMarg4
 */


*string Params_cr;
/*! \ingroup params
 *  \var Params_cr
 *  \brief Znak kojim se precrtava dio teksta na obrascu fakture (podvarijanta 9)
 *  \param X - precrtavati znakom X
 *  \note gZnPrec
 */


*string Params_ot;
/*! \ingroup params
 *  \var Params_ot
 *  \brief Broj redova za odvajanje tabele od broja dokumenta
 *  \param 3 - odvojiti 3 reda
 *  \note gOdvT2
 */


*integer Params_tb;
/*! \ingroup params
 *  \var Params_tb
 *  \brief Nacin crtanja tabele koji se koristi pri stampanju sifrarnika i u pojedinim izvjestajima i dokumentima
 *  \param 0 - koristi se samo znak "-" (minus) za iscrtavanje horizontalnih linija, a vertikale se ne iscrtavaju
 *  \param 1 - sve se crta jednostrukom linijom
 *  \param 2 - okvir tabele se crta dvostrukom linijom, a ostalo jednostrukom
 *  \note gTabela
 *  \sa StampaTabele()
 */


*string Params_za;
/*! \ingroup params
 *  \var Params_za
 *  \brief Da li se zaglavlje dokumenta ispisuje na svakoj stranici?
 *  \param D - da
 *  \param N - ne
 *  \note gZagl
 */


*string Params_zb;
/*! \ingroup params
 *  \var Params_zb
 *  \brief Crni tj."masni" ispis dokumenta ?
 *  \param 1 - da
 *  \param 2 - ne
 *  \note gbold
 */


*string Params_RT;
/*! \ingroup params
 *  \var Params_RT
 *  \brief Prikaz rekapitulacije po tarifama u dokumentu 13-ki ?
 *  \param D - da
 *  \param N - ne
 *  \note gRekTar
 */


*string Params_HL;
/*! \ingroup params
 *  \var Params_HL
 *  \brief Ispis horizontalnih linija izmedju stavki dokumenta?
 *  \param D - da
 *  \param N - ne
 *  \note gHLinija
 */


*string Params_rp;
/*! \ingroup params
 *  \var Params_rp
 *  \brief Prikaz rabata u % (procentu) ?
 *  \param D - da
 *  \param N - ne
 *  \note gRabProc
 */


/*! \fn SetT1()
 *  \brief Varijante izgleda dokumenta
 */
 
function SetT1()
*{
private GetList:={}
private cIzvj:="1"

O_PARAMS

if ValType(gTabela)<>"N"
	gTabela:=1
endif

RPar("c1",@cIzvj)

Box(,22,76,.f.,"VARIJANTE IZGLEDA DOKUMENATA")
	@ m_x+2,m_y+2 SAY "Prikaz cijena podstavki/cijena u glavnoj stavci (1/2)" GET cIzvj
  	@ m_x+3,m_y+2 SAY "Izgled fakture 1/2/3" GET gTipF VALID gTipF $ "123"
  	@ m_x+4,m_y+2 SAY "Varijanta 1/2/3/4/9/A/B" GET gVarF VALID gVarF $ "12349AB"
  	@ m_x+5,m_y+2 SAY "Dodat.redovi po listu " GET gERedova VALID gERedova>=0 PICT "99"
  	@ m_x+6,m_y+2 SAY "Lijeva margina pri stampanju " GET gnLMarg PICT "99"
  	@ m_x+6,m_y+35 SAY "L.marg.za v.2/9/A5 " GET gnLMargA5 PICT "99"
  	@ m_x+7,m_y+2 SAY "Gornja margina " GET gnTMarg PICT "99"
  	@ m_x+8,m_y+2 SAY "Koristiti A5 obrazac u varijanti 9 D/N/0" GET gFormatA5 PICT "@!" VALID gFormatA5 $ "DN0"
  	@ m_x+ 8,m_y+58 SAY "A4   A5"
  	@ m_x+ 9,m_y+2 SAY "Horizont.pomjeranje zaglavlja u varijanti 9 (br.kolona)" GET gFPzag PICT "99"
  	@ m_x+ 9,m_y+63 GET gFPzagA5 PICT "99"
  	@ m_x+10,m_y+2 SAY "Vertikalno pomjeranje stavki u fakturi var.9(br.redova)" GET gnTmarg2 PICT "99"
  	@ m_x+10,m_y+63 GET gnTmarg2A5 PICT "99"
  	@ m_x+11,m_y+2 SAY "Vertikalno pomjeranje totala u fakturi var.9(br.redova)" GET gnTmarg3 PICT "99"
  	@ m_x+11,m_y+63 GET gnTmarg3A5 PICT "99"
  	@ m_x+12,m_y+2 SAY "Vertikalno pomj.donjeg dijela fakture  var.9(br.redova)" GET gnTmarg4 PICT "99"
  	@ m_x+12,m_y+63 GET gnTmarg4A5 PICT "99"
  	@ m_x+13,m_y+2 SAY "Vertik.pomj.znakova krizanja i br.dok.var.9(br.red.>=0)" GET gKriz PICT "99"
  	@ m_x+13,m_y+63 GET gKrizA5 PICT "99"
  	@ m_x+14,m_y+2 SAY "Znak kojim se precrtava dio teksta na papiru" GET gZnPrec
  	@ m_x+15,m_y+2 SAY "Broj linija za odvajanje tabele od broja dokumenta" GET gOdvT2 VALID gOdvT2>=0 PICT "9"
  	@ m_x+16,m_y+2 SAY "Nacin crtanja tabele (0/1/2) ?" GET gTabela VALID gTabela<3.and.gTabela>=0 PICT "9"
  	@ m_x+17,m_y+2 SAY "Zaglavlje na svakoj stranici D/N  (1/2) ? " GET gZagl VALID gZagl $ "12" PICT "@!"
  	@ m_x+18,m_y+2 SAY "Crni-masni prikaz fakture D/N  (1/2) ? " GET gBold VALID gBold $ "12" PICT "@!"
  	@ m_x+19,m_y+2 SAY "Var.RTF-fakt.,izgled tipa 2 (' '-standardno, 1-MINEX, 2-LIKOM, 3-ZENELA)" GET gVarRF VALID gVarRF $ " 123"
  	@ m_x+20,m_y+2 SAY "Prikaz rekapitulacije po tarifama na 13-ci:" GET gRekTar VALID gRekTar $ "DN" PICT "@!"
  	@ m_x+21,m_y+2 SAY "Prikaz horizot. linija:" GET gHLinija VALID gHLinija $ "DN" PICT "@!"
  	@ m_x+22,m_y+2 SAY "Prikaz rabata u %(procentu)? (D/N):" GET gRabProc VALID gRabProc $ "DN" PICT "@!"
  	read
BoxC()

if (LASTKEY()<>K_ESC)
	WPar("c1",cIzvj)
   	WPar("tf",@gTipF)
   	WPar("vf",@gVarF)
   	WPar("kr",@gKriz)
   	WPar("55",@gKrizA5)
   	WPar("vr",@gVarRF)
   	WPar("er",gERedova)
   	WPar("pr",gnLMarg)
   	WPar("56",gnLMargA5)
   	WPar("pt",gnTMarg)
   	WPar("a5",gFormatA5)
   	WPar("fp",gFPzag)
   	WPar("51",gFPzagA5)
   	WPar("52",gnTMarg2A5)
   	WPar("53",gnTMarg3A5)
   	WPar("54",gnTMarg4A5)
   	WPar("d1",gnTMarg2)
   	WPar("d2",gnTMarg3)
   	WPar("d3",gnTMarg4)
   	WPar("cr",gZnPrec)
   	WPar("ot",gOdvT2)
   	WPar("tb",gTabela)
   	WPar("za",gZagl)   // zaglavlje na svakoj stranici
   	WPar("zb",gbold)
   	WPar("RT",gRekTar)
   	WPar("HL",gHLinija)
   	WPar("rp",gRabProc)
endif

return 
*}


*string Params_r3;
/*! \ingroup params
 *  \var Params_r3
 *  \brief Naziv dokumenta tipa 06
 *  \param "ZADUZ.KONS.SKLAD.br." - default vrijednost
 *  \note g06Str
 */


*string Params_r4;
/*! \ingroup params
 *  \var Params_r4
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 06 (za potpise)
 *  \param "              Predao                  Odobrio                  Preuzeo" - default vrijednost
 *  \note g06Str2T
 */


*string Params_r5;
/*! \ingroup params
 *  \var Params_r5
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 06 u varijanti RTF fakture (za potpise)
 *  \param "\tab Predao\tab Odobrio\tab Preuzeo" - default vrijednost
 *  \note g06Str2R
 */


*string Params_s1;
/*! \ingroup params
 *  \var Params_s1
 *  \brief Naziv dokumenta tipa 10
 *  \param "RACUN/OTPREMNICA br." - default vrijednost
 *  \note g10Str
 */


*string Params_s4;
/*! \ingroup params
 *  \var Params_s4
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 10 (za potpise)
 *  \param "              Predao                  Odobrio                  Preuzeo" - default vrijednost
 *  \note g10Str2T
 */


*string Params_r1;
/*! \ingroup params
 *  \var Params_r1
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 10 u varijanti RTF fakture (za potpise)
 *  \param "\tab Predao\tab Odobrio\tab Preuzeo" - default vrijednost
 *  \note g10Str2R
 */


*string Params_s2;
/*! \ingroup params
 *  \var Params_s2
 *  \brief Naziv dokumenta tipa 11
 *  \param "RACUN MP br." - default vrijednost
 *  \note g11Str
 */


*string Params_s5;
/*! \ingroup params
 *  \var Params_s5
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 11 (za potpise)
 *  \param "              Predao                  Odobrio                  Preuzeo" - default vrijednost
 *  \note g11Str2T
 */


*string Params_x1;
/*! \ingroup params
 *  \var Params_x1
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 11 u varijanti RTF fakture (za potpise)
 *  \param "\tab Predao\tab Odobrio\tab Preuzeo" - default vrijednost
 *  \note g11Str2R
 */


*string Params_x3;
/*! \ingroup params
 *  \var Params_x3
 *  \brief Naziv dokumenta tipa 12
 *  \param "OTPREMNICA br." - default vrijednost
 *  \note g12Str
 */


*string Params_x4;
/*! \ingroup params
 *  \var Params_x4
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 12 (za potpise)
 *  \param "              Predao                  Odobrio                  Preuzeo" - default vrijednost
 *  \note g12Str2T
 */


*string Params_x5;
/*! \ingroup params
 *  \var Params_x5
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 12 u varijanti RTF fakture (za potpise)
 *  \param "\tab Predao\tab Odobrio\tab Preuzeo" - default vrijednost
 *  \note g12Str2R
 */


*string Params_x6;
/*! \ingroup params
 *  \var Params_x6
 *  \brief Naziv dokumenta tipa 13
 *  \param "OTPREMNICA U MP br." - default vrijednost
 *  \note g13Str
 */


*string Params_x7;
/*! \ingroup params
 *  \var Params_x7
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 13 (za potpise)
 *  \param "              Predao                  Odobrio                  Preuzeo" - default vrijednost
 *  \note g13Str2T
 */


*string Params_x8;
/*! \ingroup params
 *  \var Params_x8
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 13 u varijanti RTF fakture (za potpise)
 *  \param "\tab Predao\tab Odobrio\tab Preuzeo" - default vrijednost
 *  \note g13Str2R
 */


*string Params_xl;
/*! \ingroup params
 *  \var Params_xl
 *  \brief Naziv dokumenta tipa 15
 *  \param "RACUN br." - default vrijednost
 *  \note g15Str
 */


*string Params_xm;
/*! \ingroup params
 *  \var Params_xm
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 15 (za potpise)
 *  \param "              Predao                  Odobrio                  Preuzeo" - default vrijednost
 *  \note g15Str2T
 */


*string Params_xn;
/*! \ingroup params
 *  \var Params_xn
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 15 u varijanti RTF fakture (za potpise)
 *  \param "\tab Predao\tab Odobrio\tab Preuzeo" - default vrijednost
 *  \note g15Str2R
 */


*string Params_s9;
/*! \ingroup params
 *  \var Params_s9
 *  \brief Naziv dokumenta tipa 16
 *  \param "KONSIGNAC.RACUN br." - default vrijednost
 *  \note g16Str
 */


*string Params_s8;
/*! \ingroup params
 *  \var Params_s8
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 16 (za potpise)
 *  \param "              Predao                  Odobrio                  Preuzeo" - default vrijednost
 *  \note g16Str2T
 */


*string Params_r2;
/*! \ingroup params
 *  \var Params_r2
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 16 u varijanti RTF fakture (za potpise)
 *  \param "\tab Predao\tab Odobrio\tab Preuzeo" - default vrijednost
 *  \note g16Str2R
 */


*string Params_s3;
/*! \ingroup params
 *  \var Params_s3
 *  \brief Naziv dokumenta tipa 20
 *  \param "PREDRACUN br." - default vrijednost
 *  \note g20Str
 */


*string Params_s6;
/*! \ingroup params
 *  \var Params_s6
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 20 (za potpise)
 *  \param "                                                               Direktor" - default vrijednost
 *  \note g20Str2T
 */


*string Params_x2;
/*! \ingroup params
 *  \var Params_x2
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 20 u varijanti RTF fakture (za potpise)
 *  \param "\tab \tab \tab Direktor:" - default vrijednost
 *  \note g20Str2R
 */


*string Params_x9;
/*! \ingroup params
 *  \var Params_x9
 *  \brief Naziv dokumenta tipa 21
 *  \param "REVERS br." - default vrijednost
 *  \note g21Str
 */


*string Params_xa;
/*! \ingroup params
 *  \var Params_xa
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 21 (za potpise)
 *  \param "              Predao                  Odobrio                  Preuzeo" - default vrijednost
 *  \note g21Str2T
 */


*string Params_xb;
/*! \ingroup params
 *  \var Params_xb
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 21 u varijanti RTF fakture (za potpise)
 *  \param "\tab Predao\tab Odobrio\tab Preuzeo" - default vrijednost
 *  \note g21Str2R
 */


*string Params_xc;
/*! \ingroup params
 *  \var Params_xc
 *  \brief Naziv dokumenta tipa 22
 *  \param "ZAKLJ.OTPREMNICA br." - default vrijednost
 *  \note g22Str
 */


*string Params_xd;
/*! \ingroup params
 *  \var Params_xd
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 22 (za potpise)
 *  \param "              Predao                  Odobrio                  Preuzeo" - default vrijednost
 *  \note g22Str2T
 */


*string Params_xe;
/*! \ingroup params
 *  \var Params_xe
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 22 u varijanti RTF fakture (za potpise)
 *  \param "\tab Predao\tab Odobrio\tab Preuzeo" - default vrijednost
 *  \note g22Str2R
 */


*string Params_xf;
/*! \ingroup params
 *  \var Params_xf
 *  \brief Naziv dokumenta tipa 25
 *  \param "KNJIZNA OBAVIJEST br." - default vrijednost
 *  \note g25Str
 */


*string Params_xg;
/*! \ingroup params
 *  \var Params_xg
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 25 (za potpise)
 *  \param "              Predao                  Odobrio                  Preuzeo" - default vrijednost
 *  \note g25Str2T
 */


*string Params_xh;
/*! \ingroup params
 *  \var Params_xh
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 25 u varijanti RTF fakture (za potpise)
 *  \param "\tab Predao\tab Odobrio\tab Preuzeo" - default vrijednost
 *  \note g25Str2R
 */


*string Params_xi;
/*! \ingroup params
 *  \var Params_xi
 *  \brief Naziv dokumenta tipa 26
 *  \param "NARUDZBA SA IZJAVOM br." - default vrijednost
 *  \note g26Str
 */


*string Params_xj;
/*! \ingroup params
 *  \var Params_xj
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 26 (za potpise)
 *  \param "                                      Potpis:" - default vrijednost
 *  \note g26Str2T
 */


*string Params_xk;
/*! \ingroup params
 *  \var Params_xk
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 26 u varijanti RTF fakture (za potpise)
 *  \param "\tab \tab Potpis:" - default vrijednost
 *  \note g26Str2R
 */


*string Params_xo;
/*! \ingroup params
 *  \var Params_xo
 *  \brief Naziv dokumenta tipa 27
 *  \param "PREDRACUN MP br." - default vrijednost
 *  \note g27Str
 */


*string Params_xp;
/*! \ingroup params
 *  \var Params_xp
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 27 (za potpise)
 *  \param "                                                               Direktor" - default vrijednost
 *  \note g27Str2T
 */


*string Params_xr;
/*! \ingroup params
 *  \var Params_xr
 *  \brief Tekst koji se ispisuje na kraju dokumenta tipa 27 u varijanti RTF fakture (za potpise)
 *  \param "\tab \tab \tab Direktor:" - default vrijednost
 *  \note g27Str2R
 */


/*! \fn SetT2()
 *  \brief Ispis naziva dokumenta i potpisa na kraju fakture
 */
 
function SetT2()
*{
private  GetList:={}

O_PARAMS

g10Str:=PADR(g10Str,20)
g16Str:=PADR(g16Str,20)
g06Str:=PADR(g06Str,20)
g11Str:=PADR(g11Str,20)
g12Str:=PADR(g12Str,20)
g13Str:=PADR(g13Str,20)
g15Str:=PADR(g15Str,20)
g20Str:=PADR(g20Str,20)
g21Str:=PADR(g21Str,20)
g22Str:=PADR(g22Str,20)
g25Str:=PADR(g25Str,20)
g26Str:=PADR(g26Str,24)
g27Str:=PADR(g27Str,20)
g10Str2T:=PADR(g10Str2T,132)
g10Str2R:=PADR(g10Str2R,132)
g16Str2T:=PADR(g16Str2T,132)
g16Str2R:=PADR(g16Str2R,132)
g06Str2T:=PADR(g06Str2T,132)
g06Str2R:=PADR(g06Str2R,132)
g11Str2T:=PADR(g11Str2T,132)
g15Str2T:=PADR(g15Str2T,132)
g11Str2R:=PADR(g11Str2R,132)
g15Str2R:=PADR(g15Str2R,132)
g12Str2T:=PADR(g12Str2T,132)
g12Str2R:=PADR(g12Str2R,132)
g13Str2T:=PADR(g13Str2T,132)
g13Str2R:=PADR(g13Str2R,132)
g20Str2T:=PADR(g20Str2T,132)
g20Str2R:=PADR(g20Str2R,132)
g21Str2T:=PADR(g21Str2T,132)
g21Str2R:=PADR(g21Str2R,132)
g22Str2T:=PADR(g22Str2T,132)
g22Str2R:=PADR(g22Str2R,132)
g25Str2T:=PADR(g25Str2T,132)
g25Str2R:=PADR(g25Str2R,132)
g26Str2T:=PADR(g26Str2T,132)
g26Str2R:=PADR(g26Str2R,132)
g27Str2T:=PADR(g27Str2T,132)
g27Str2R:=PADR(g27Str2R,132)

Box(,22,76,.f.,"ISPIS NAZIVA DOKUMENATA I TEKSTA NA KRAJU (POTPIS), 1.strana")
	@ m_x+ 1,m_y+2 SAY "06 - Tekst"      GET g06Str
  	@ m_x+ 2,m_y+2 SAY "06 - Potpis TXT" GET g06Str2T PICT"@S50"
  	@ m_x+ 3,m_y+2 SAY "06 - Potpis RTF" GET g06Str2R PICT"@S50"
  	@ m_x+ 4,m_y+2 SAY "10 - Tekst"      GET g10Str
  	@ m_x+ 5,m_y+2 SAY "10 - Potpis TXT" GET g10Str2T PICT"@S50"
  	@ m_x+ 6,m_y+2 SAY "10 - Potpis RTF" GET g10Str2R PICT"@S50"
  	@ m_x+ 7,m_Y+2 SAY "11 - Tekst"      GET g11Str
  	@ m_x+ 8,m_y+2 SAY "11 - Potpis TXT" GET g11Str2T PICT "@S50"
  	@ m_x+ 9,m_y+2 SAY "11 - Potpis RTF" GET g11Str2R PICT "@S50"
  	@ m_x+10,m_y+2 SAY "12 - Tekst"      GET g12Str
  	@ m_x+11,m_y+2 SAY "12 - Potpis TXT" GET g12Str2T PICT "@S50"
  	@ m_x+12,m_y+2 SAY "12 - Potpis RTF" GET g12Str2R PICT "@S50"
  	@ m_x+13,m_y+2 SAY "13 - Tekst"      GET g13Str
  	@ m_x+14,m_y+2 SAY "13 - Potpis TXT" GET g13Str2T PICT "@S50"
  	@ m_x+15,m_y+2 SAY "13 - Potpis RTF" GET g13Str2R PICT "@S50"
  	@ m_x+16,m_y+2 SAY "15 - Tekst"      GET g15Str
  	@ m_x+17,m_y+2 SAY "15 - Potpis TXT" GET g15Str2T PICT "@S50"
  	@ m_x+18,m_y+2 SAY "15 - Potpis RTF" GET g15Str2R PICT "@S50"
  	@ m_x+19,m_y+2 SAY "16 - Tekst"      GET g16Str
  	@ m_x+20,m_y+2 SAY "16 - Potpis TXT" GET g16Str2T PICT"@S50"
  	@ m_x+21,m_y+2 SAY "16 - Potpis RTF" GET g16Str2R PICT"@S50"
  	read
BoxC()

Box(,19,76,.f.,"ISPIS NAZIVA DOKUMENATA I TEKSTA NA KRAJU (POTPIS), 2.strana")
	@ m_x+ 1,m_y+2 SAY "20 - Tekst"      GET g20Str
  	@ m_x+ 2,m_y+2 SAY "20 - Potpis TXT" GET g20Str2T PICT "@S50"
  	@ m_x+ 3,m_y+2 SAY "20 - Potpis RTF" GET g20Str2R PICT "@S50"
  	@ m_x+ 4,m_y+2 SAY "21 - Tekst"      GET g21Str
  	@ m_x+ 5,m_y+2 SAY "21 - Potpis TXT" GET g21Str2T PICT "@S50"
  	@ m_x+ 6,m_y+2 SAY "21 - Potpis RTF" GET g21Str2R PICT "@S50"
  	@ m_x+ 7,m_y+2 SAY "22 - Tekst"      GET g22Str
  	@ m_x+ 8,m_y+2 SAY "22 - Potpis TXT" GET g22Str2T PICT"@S50"
  	@ m_x+ 9,m_y+2 SAY "22 - Potpis RTF" GET g22Str2R PICT"@S50"
  	@ m_x+10,m_y+2 SAY "25 - Tekst"      GET g25Str
  	@ m_x+11,m_y+2 SAY "25 - Potpis TXT" GET g25Str2T PICT"@S50"
  	@ m_x+12,m_y+2 SAY "25 - Potpis RTF" GET g25Str2R PICT"@S50"
  	@ m_x+13,m_y+2 SAY "26 - Tekst"      GET g26Str
  	@ m_x+14,m_y+2 SAY "26 - Potpis TXT" GET g26Str2T PICT"@S50"
 	@ m_x+15,m_y+2 SAY "26 - Potpis RTF" GET g26Str2R PICT"@S50"
  	@ m_x+16,m_y+2 SAY "27 - Tekst"      GET g27Str
  	@ m_x+17,m_y+2 SAY "27 - Potpis TXT" GET g27Str2T PICT"@S50"
  	@ m_x+18,m_y+2 SAY "27 - Potpis RTF" GET g27Str2R PICT"@S50"
  	read
BoxC()

if gKodnaS=="8"
	g10Str:=KSTo852(TRIM(g10Str)  )
        g10Str2T:=KSTo852(TRIM(g10Str2T))
        g10Str2R:=(TRIM(g10Str2R))
        g16Str:=KSTo852(TRIM(g16Str)  )
        g16Str2T:=KSTo852(TRIM(g16Str2T))
        g16Str2R:=(TRIM(g16Str2R))
        g06Str:=KSTo852(TRIM(g06Str)  )
        g06Str2T:=KSTo852(TRIM(g06Str2T))
        g06Str2R:=(TRIM(g06Str2R))
        g11Str:=KSTo852(TRIM(g11Str)  )
        g11Str2T:=KSTo852(TRIM(g11Str2T))
        g11Str2R:=(TRIM(g11Str2R))
        g12Str:=KSTo852(TRIM(g12Str)  )
        g12Str2T:=KSTo852(TRIM(g12Str2T))
        g12Str2R:=(TRIM(g12Str2R))
        g13Str:=KSTo852(TRIM(g13Str)  )
        g13Str2T:=KSTo852(TRIM(g13Str2T))
        g13Str2R:=(TRIM(g13Str2R))
        g15Str:=KSTo852(TRIM(g15Str)  )
        g15Str2T:=KSTo852(TRIM(g15Str2T))
        g15Str2R:=(TRIM(g15Str2R))
        g20Str:=KSTo852(TRIM(g20Str)  )
        g20Str2T:=KSTo852(TRIM(g20Str2T))
        g20Str2R:=(TRIM(g20Str2R))
        g21Str:=KSTo852(TRIM(g21Str)  )
        g21Str2T:=KSTo852(TRIM(g21Str2T))
        g21Str2R:=(TRIM(g21Str2R))
        g22Str:=KSTo852(TRIM(g22Str)  )
        g22Str2T:=KSTo852(TRIM(g22Str2T))
        g22Str2R:=(TRIM(g22Str2R))
        g25Str:=KSTo852(TRIM(g25Str)  )
        g25Str2T:=KSTo852(TRIM(g25Str2T))
        g25Str2R:=(TRIM(g25Str2R))
        g26Str:=KSTo852(TRIM(g26Str)  )
        g26Str2T:=KSTo852(TRIM(g26Str2T))
        g26Str2R:=(TRIM(g26Str2R))
        g27Str:=KSTo852(TRIM(g27Str)  )
        g27Str2T:=KSTo852(TRIM(g27Str2T))
        g27Str2R:=(TRIM(g27Str2R))
else
        g10Str:=KSTo7(TRIM(g10Str)  )
        g10Str2T:=KSTo7(TRIM(g10Str2T))
        g10Str2R:=(TRIM(g10Str2R))
        g16Str:=KSTo7(TRIM(g16Str)  )
        g16Str2T:=KSTo7(TRIM(g16Str2T))
        g16Str2R:=(TRIM(g16Str2R))
        g06Str:=KSTo7(TRIM(g06Str)  )
        g06Str2T:=KSTo7(TRIM(g06Str2T))
        g06Str2R:=(TRIM(g06Str2R))
        g11Str:=KSTo7(TRIM(g11Str)  )
        g11Str2T:=KSTo7(TRIM(g11Str2T))
        g11Str2R:=(TRIM(g11Str2R))
        g12Str:=KSTo7(TRIM(g12Str)  )
        g12Str2T:=KSTo7(TRIM(g12Str2T))
        g12Str2R:=(TRIM(g12Str2R))
        g13Str:=KSTo7(TRIM(g13Str)  )
        g13Str2T:=KSTo7(TRIM(g13Str2T))
        g13Str2R:=(TRIM(g13Str2R))
        g15Str:=KSTo7(TRIM(g15Str)  )
        g15Str2T:=KSTo7(TRIM(g15Str2T))
        g15Str2R:=(TRIM(g15Str2R))
        g20Str:=KSTo7(TRIM(g20Str)  )
        g20Str2T:=KSTo7(TRIM(g20Str2T))
        g20Str2R:=(TRIM(g20Str2R))
        g21Str:=KSTo7(TRIM(g21Str)  )
        g21Str2T:=KSTo7(TRIM(g21Str2T))
        g21Str2R:=(TRIM(g21Str2R))
        g22Str:=KSTo7(TRIM(g22Str)  )
        g22Str2T:=KSTo7(TRIM(g22Str2T))
        g22Str2R:=(TRIM(g22Str2R))
        g25Str:=KSTo7(TRIM(g25Str)  )
        g25Str2T:=KSTo7(TRIM(g25Str2T))
        g25Str2R:=(TRIM(g25Str2R))
        g26Str:=KSTo7(TRIM(g26Str)  )
        g26Str2T:=KSTo7(TRIM(g26Str2T))
        g26Str2R:=(TRIM(g26Str2R))
        g27Str:=KSTo7(TRIM(g27Str)  )
        g27Str2T:=KSTo7(TRIM(g27Str2T))
        g27Str2R:=(TRIM(g27Str2R))
endif

if (LASTKEY()<>K_ESC)
	WPar("s1",g10Str)
  	WPar("s2",g11Str)
  	WPar("s3",g20Str)
  	WPar("s4",@g10Str2T)
  	WPar("s5",@g11Str2T)
  	WPar("s6",@g20Str2T)
  	WPar("s9",g16Str)
  	WPar("r3",g06Str)
  	WPar("s8",@g16Str2T)
  	WPar("r4",@g06Str2T)
  	WPar("x1",@g11Str2R)
  	WPar("x2",@g20Str2R)
  	WPar("x3",@g12Str)
  	WPar("x4",@g12Str2T)
  	WPar("x5",@g12Str2R)
  	WPar("x6",@g13Str)
  	WPar("x7",@g13Str2T)
  	WPar("x8",@g13Str2R)
  	WPar("xl",@g15Str)
  	WPar("xm",@g15Str2T)
  	WPar("xn",@g15Str2R)
  	WPar("x9",@g21Str)
  	WPar("xa",@g21Str2T)
  	WPar("xb",@g21Str2R)
  	WPar("xc",@g22Str)
 	WPar("xd",@g22Str2T)
  	WPar("xe",@g22Str2R)
  	WPar("xf",@g25Str)
  	WPar("xg",@g25Str2T)
  	WPar("xh",@g25Str2R)
  	WPar("xi",@g26Str)
  	WPar("xj",@g26Str2T)
  	WPar("xk",@g26Str2R)
  	WPar("xo",@g27Str)
  	WPar("xp",@g27Str2T)
  	WPar("xr",@g27Str2R)
  	WPar("r1",@g10Str2R)
  	WPar("r2",@g16Str2R)
  	WPar("r5",@g06Str2R)
endif

return 
*}



/*! \fn V_VZagl()
 *  \brief Ispravka zaglavlja
 */
 
function V_VZagl()
*{
private cKom:="q "+PRIVPATH+gVlZagl

if Pitanje(,"Zelite li izvrsiti ispravku zaglavlja ?","N")=="D"
	if !EMPTY(gVlZagl)
   		Box(,25,80)
   			run &ckom
   		BoxC()
 	endif
endif
return .t.
*}


/*! \fn V_VNar()
 *  \brief Ispravka fajla narudzbenice
 */
 
function V_VNar()
*{
private cKom:="q "+PRIVPATH+gFNar

if Pitanje(,"Zelite li izvrsiti ispravku fajla obrasca narudzbenice ?","N")=="D"
	if !EMPTY(gFNar)
   		Box(,25,80)
   			run &ckom
   		BoxC()
 	endif
endif
return .t.
*}



/*! \fn V_VUgRab()
 *  \brief Ispravka fajla ugovora o rabatu
 */
 
function V_VUgRab()
*{
private cKom:="q "+PRIVPATH+gFUgRab

if Pitanje(,"Zelite li izvrsiti ispravku fajla-teksta ugovora o rabatu ?","N")=="D"
	if !EMPTY(gFUgRab)
   		Box(,25,80)
   			run &ckom
   		BoxC()
 	endif
endif
return .t.
*}


/*! \ingroup ini
  * \var *string ProizvjIni_ExePath_Varijable_Firma
  * \brief Naziv firme
  * \param -- - nije definisano, default vrijednost
  */
*string ProizvjIni_ExePath_Varijable_Firma;


/*! \ingroup ini
  * \var *string ProizvjIni_ExePath_Varijable_Adres
  * \brief Adresa firme
  * \param -- - nije definisano, default vrijednost
  */
*string ProizvjIni_ExePath_Varijable_Adres;


/*! \ingroup ini
  * \var *string ProizvjIni_ExePath_Varijable_Tel
  * \brief Broj telefona firme
  * \param -- - nije definisano, default vrijednost
  */
*string ProizvjIni_ExePath_Varijable_Tel;


/*! \ingroup ini
  * \var *string ProizvjIni_ExePath_Varijable_Fax
  * \brief Broj faksa firme
  * \param -- - nije definisano, default vrijednost
  */
*string ProizvjIni_ExePath_Varijable_Fax;


/*! \ingroup ini
  * \var *string ProizvjIni_ExePath_Varijable_RegBroj
  * \brief Registarski broj firme
  * \param -- - nije definisano, default vrijednost
  */
*string ProizvjIni_ExePath_Varijable_RegBroj;


/*! \ingroup ini
  * \var *string ProizvjIni_ExePath_Varijable_PorBroj
  * \brief Poreski broj firme
  * \param -- - nije definisano, default vrijednost
  */
*string ProizvjIni_ExePath_Varijable_PorBroj;


/*! \ingroup ini
  * \var *string ProizvjIni_ExePath_Varijable_ZRacun1
  * \brief Broj ziro racuna 1
  * \param -- - nije definisano, default vrijednost
  */
*string ProizvjIni_ExePath_Varijable_ZRacun1;


/*! \ingroup ini
  * \var *string ProizvjIni_ExePath_Varijable_ZRacun2
  * \brief Broj ziro racuna 2
  * \param -- - nije definisano, default vrijednost
  */
*string ProizvjIni_ExePath_Varijable_ZRacun2;


/*! \ingroup ini
  * \var *string ProizvjIni_ExePath_Varijable_ZRacun3
  * \brief Broj ziro racuna 3
  * \param -- - nije definisano, default vrijednost
  */
*string ProizvjIni_ExePath_Varijable_ZRacun3;


/*! \ingroup ini
  * \var *string ProizvjIni_ExePath_Varijable_ZRacun4
  * \brief Broj ziro racuna 4
  * \param -- - nije definisano, default vrijednost
  */
*string ProizvjIni_ExePath_Varijable_ZRacun4;


/*! \ingroup ini
  * \var *string ProizvjIni_ExePath_Varijable_ZRacun5
  * \brief Broj ziro racuna 5
  * \param -- - nije definisano, default vrijednost
  */
*string ProizvjIni_ExePath_Varijable_ZRacun5;


/*! \ingroup ini
  * \var *string ProizvjIni_ExePath_Varijable_LokSlika
  * \brief Lokacija slike u koja sadrzi znak (logo) firme
  * \param -- - nije definisano, default vrijednost
  */
*string ProizvjIni_ExePath_Varijable_LokSlika;


/*! \fn P_WinFakt()
 *  \brief Podesavanje parametara stampe kroz DelphiRB
 */

function P_WinFakt()
*{

cIniName:=EXEPATH+'proizvj.ini'

cFirma:=PADR(UzmiIzIni(cIniName,'Varijable','Firma','--','READ'),30)
cAdresa:=PADR(UzmiIzIni(cIniName,'Varijable','Adres','--','READ'),30)
cTelefoni:=PADR(UzmiIzIni(cIniName,'Varijable','Tel','--','READ'),50)
cFax:=PADR(UzmiIzIni(cIniName,'Varijable','Fax','--','READ'),30)
cRBroj:=PADR(UzmiIzIni(cIniName,'Varijable','RegBroj','--','READ'),13)
cPBroj:=PADR(UzmiIzIni(cIniName,'Varijable','PorBroj','--','READ'),13)
cBrSudRj:=PADR(UzmiIzIni(cIniName,'Varijable','BrSudRj','--','READ'),45)
cBrUpisa:=PADR(UzmiIzIni(cIniName,'Varijable','BrUpisa','--','READ'),45)
cZRac1:=PADR(UzmiIzIni(cIniName,'Varijable','ZRacun1','--','READ'),45)
cZRac2:=PADR(UzmiIzIni(cIniName,'Varijable','ZRacun2','--','READ'),45)
cZRac3:=PADR(UzmiIzIni(cIniName,'Varijable','ZRacun3','--','READ'),45)
cZRac4:=PADR(UzmiIzIni(cIniName,'Varijable','ZRacun4','--','READ'),45)
cZRac5:=PADR(UzmiIzIni(cIniName,'Varijable','ZRacun5','--','READ'),45)
cZRac6:=PADR(UzmiIzIni(cIniName,'Varijable','ZRacun6','--','READ'),45)
cNazivRtm:=PADR(IzFmkIni('Fakt','NazRTM','',EXEPATH),15)
cNazivFRtm:=PADR(IzFmkIni('Fakt','NazRTMFax','',EXEPATH),15)
cPictLoc:=PADR(UzmiIzIni(cIniName,'Varijable','LokSlika','--','READ'),30)
cDN:="D"

Box(,22,63)
	@ m_x+1,m_Y+2 SAY "Podesavanje parametara Win stampe:"
   	@ m_x+3,m_Y+2 SAY "Naziv firme: " GET cFirma
   	@ m_x+4,m_Y+2 SAY "Adresa: " GET cAdresa
   	@ m_x+5,m_Y+2 SAY "Telefon: " GET cTelefoni
   	@ m_x+6,m_Y+2 SAY "Fax: " GET cFax
   	@ m_x+7,m_Y+2 SAY "Ziro racun 1: " GET cZRac1
   	@ m_x+8,m_Y+2 SAY "Ziro racun 2: " GET cZRac2
   	@ m_x+9,m_Y+2 SAY "Ziro racun 3: " GET cZRac3
   	@ m_x+10,m_Y+2 SAY "Ziro racun 4: " GET cZRac4
  	@ m_x+11,m_Y+2 SAY "Ziro racun 5: " GET cZRac5
  	@ m_x+12,m_Y+2 SAY "Ziro racun 6: " GET cZRac6
   	@ m_x+13,m_Y+2 SAY "Identifikac.broj: " GET cRBroj
   	@ m_x+14,m_Y+2 SAY "Porezni dj. broj: " GET cPBroj
   	@ m_x+15,m_Y+2 SAY "Br.sud.rjesenja: " GET cBrSudRj
   	@ m_x+16,m_Y+2 SAY "Reg.broj upisa: " GET cBrUpisa
   	
	@ m_x+17,m_Y+2 SAY "--------------------------------------------"
   	@ m_x+18,m_Y+2 SAY "Lokacija slike: " GET cPictLoc
   	@ m_x+19,m_Y+2 SAY "Naziv RTM fajla za fakture: " GET cNazivRtm
   	@ m_x+20,m_Y+2 SAY "Naziv RTM fajla za slanje dok.faksom: " GET cNazivFRtm
   	@ m_x+21,m_Y+2 SAY "Snimi podatke D/N? " GET cDN valid cDN $ "DN" pict "@!"
   	read
BoxC()

if lastkey()=K_ESC
	return
endif

if cDN=="D"
	UzmiIzIni(cIniName,'Varijable','Firma',cFirma,'WRITE')
    	UzmiIzIni(cIniName,'Varijable','Adres',cAdresa,'WRITE')
    	UzmiIzIni(cIniName,'Varijable','Tel',cTelefoni,'WRITE')
    	UzmiIzIni(cIniName,'Varijable','Fax',cFax,'WRITE')
    	UzmiIzIni(cIniName,'Varijable','RegBroj',cRBroj,'WRITE')
    	UzmiIzIni(cIniName,'Varijable','PorBroj',cPBroj,'WRITE')
    	UzmiIzIni(cIniName,'Varijable','BrSudRj',cBrSudRj,'WRITE')
    	UzmiIzIni(cIniName,'Varijable','BrUpisa',cBrUpisa,'WRITE')
    	UzmiIzIni(cIniName,'Varijable','ZRacun1',cZRac1,'WRITE')
    	UzmiIzIni(cIniName,'Varijable','ZRacun2',cZRac2,'WRITE')
    	UzmiIzIni(cIniName,'Varijable','ZRacun3',cZRac3,'WRITE')
    	UzmiIzIni(cIniName,'Varijable','ZRacun4',cZRac4,'WRITE')
    	UzmiIzIni(cIniName,'Varijable','ZRacun5',cZRac5,'WRITE')
    	UzmiIzIni(cIniName,'Varijable','ZRacun6',cZRac6,'WRITE')
    	UzmiIzIni(EXEPATH+"fmk.ini",'Fakt','NazRTM',cNazivRtm,'WRITE')
    	UzmiIzIni(EXEPATH+"fmk.ini",'Fakt','NazRTMFax',cNazivFRtm,'WRITE')
    	UzmiIzIni(cIniName,'Varijable','LokSlika',cPictLoc,'WRITE')
    	MsgBeep("Podaci snimljeni!")
else
	return
endif

return
*}


