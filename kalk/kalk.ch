
/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/kalk.ch,v $
 * $Author: sasavranic $ 
 * $Revision: 1.119 $
 * $Log: kalk.ch,v $
 * Revision 1.119  2004/06/01 10:40:37  sasavranic
 * BugFix, generacija nivelacije za prod. na osnovu polja N2
 *
 * Revision 1.118  2004/05/27 07:09:51  sasavranic
 * Dodao uslov za tip sredstva i na izvjestaj Fin.stanja magacina
 *
 * Revision 1.117  2004/05/25 13:53:16  sasavranic
 * Mogucnost evidentiranja tipa sredstva (donirano i kupljeno)
 *
 * Revision 1.116  2004/05/19 12:16:54  sasavranic
 * no message
 *
 * Revision 1.115  2004/05/13 10:28:40  sasavranic
 * Uvedena varijanta racunanja PRUCMP bez izbijanja PPP (sl.novine)
 *
 * Revision 1.114  2004/05/05 08:16:52  sasavranic
 * Na izvj.LLP dodao uslov za partnera
 *
 * Revision 1.113  2004/03/18 10:00:25  enespivic
 *     Na izvjestaju "rekapitulacija fin. stanja po magacinima" nakon ispisa
 *      podataka za odgovarajuci konto ispisuje se u novom redu puni naziv konta.
 *
 * Revision 1.112  2004/03/02 18:37:28  sasavranic
 * no message
 *
 * Revision 1.111  2004/02/12 15:37:28  sasavranic
 * no message
 *
 * Revision 1.110  2004/02/02 13:11:20  sasavranic
 * no message
 *
 * Revision 1.109  2004/01/19 13:13:54  sasavranic
 * Pri generaciji IM magacina, pita za cijene VPC ili NC
 *
 * Revision 1.108  2004/01/09 14:22:35  sasavranic
 * Dorade za dom zdravlja
 *
 * Revision 1.107  2004/01/09 08:49:08  sasavranic
 * Na stampi invent.magacina prikaz VPC ili ne
 *
 * Revision 1.106  2004/01/07 13:43:27  sasavranic
 * Korekcija algoritama za tarife, ako je bilo promjene tarifa
 *
 * Revision 1.105  2004/01/06 18:06:12  sasavranic
 * no message
 *
 * Revision 1.104  2003/12/26 10:31:37  sasavranic
 * Ispravljen algoritam izvjestaja ako je popust u pitanju! Planika - pregled prometa
 *
 * Revision 1.103  2003/12/26 08:54:40  sasavranic
 * no message
 *
 * Revision 1.102  2003/12/24 10:38:53  sasavranic
 * Uracunaj i snizenje ako ga je bilo na pregledu prometa za vise objekata - Planika
 *
 * Revision 1.101  2003/12/22 14:59:10  sasavranic
 * Uslov za sortiranje rednih brojeva u pripremi...varijanta Jerry
 *
 * Revision 1.100  2003/12/22 10:44:51  sasavranic
 * Dodata jos 3 reda pri stampi pregleda kretanja zaliha varijanta papira A4L
 *
 * Revision 1.99  2003/12/06 13:41:38  sasavranic
 * Stampa pregleda kretanja zaliha na A4 - planika
 *
 * Revision 1.98  2003/12/04 14:47:42  sasavranic
 * Uveden filter po polju pl.vrsta na izvjestajima za planiku
 *
 * Revision 1.97  2003/12/03 15:39:24  sasavranic
 * Na LLP i LLM uslov po polju pl.vrsta
 *
 * Revision 1.96  2003/12/03 15:19:39  sasavranic
 * Prikaz artikala najprometnijih kod kojih je JMJ='PAR'
 *
 * Revision 1.95  2003/11/29 13:48:42  sasavranic
 * Dorade: preuzimanje barkodova pri preuzimanju realizacije iz kalk-a
 *
 * Revision 1.94  2003/11/22 15:25:49  sasavranic
 * planika robno poslovanje, prodnc
 *
 * Revision 1.93  2003/11/22 09:08:38  sasavranic
 * ispravljen bug pri stampi 81-ce varijanta prenos za TOPS
 *
 * Revision 1.92  2003/11/20 16:17:51  ernadhusremovic
 * Planika Kranje Robno poslovanje / 2
 *
 * Revision 1.87  2003/11/04 02:13:24  ernadhusremovic
 * Planika Kranj - Robno poslovanje
 *
 * Revision 1.86  2003/10/11 09:26:50  sasavranic
 * Ispravljen bug pri unosu izlaznih kalkulacija, na stanju uvije 0 robe, varijanta barkod
 *
 * Revision 1.85  2003/10/06 15:00:26  sasavranic
 * Unos podataka putem barkoda
 *
 * Revision 1.84  2003/10/04 11:06:38  sasavranic
 * uveden security sistem
 *
 * Revision 1.83  2003/09/29 13:26:55  mirsadsubasic
 * sredjivanje koda za poreze u ugostiteljstvu
 *
 * Revision 1.82  2003/09/20 07:37:07  mirsad
 * sredj.koda za poreze u MP
 *
 * Revision 1.81  2003/09/08 13:18:52  mirsad
 * vratio trosak MP u 11-ki
 *
 * Revision 1.80  2003/09/08 08:41:43  ernad
 * porezi u ugostiteljstvu
 *
 * Revision 1.79  2003/08/30 15:43:25  mirsad
 * dvije nove opcije (F10 u pripremi): J.prenos KALK 10->11  i  K. prenos KALK 16->14
 *
 * Revision 1.78  2003/08/30 15:40:19  mirsad
 * dvije nove opcije (F10 u pripremi): J.prenos KALK 10->11  i  K. prenos KALK 16->14
 *
 * Revision 1.77  2003/08/27 07:57:33  mirsad
 * 1) nova opcija u pripremi: F11/4.obracun poreza pri uvozu  2) Vindija:prikaz novih kolona na pregledu prodaje (kolicina za period prije 7 i 28 dana)
 *
 * Revision 1.76  2003/08/09 08:12:14  mirsad
 * dorada za vindiju: pri rasporedu troskova uveo uslov po tarifama
 *
 * Revision 1.75  2003/08/05 12:03:21  mirsad
 * debug: setovanje marze VP pri ispravki 15-ke
 *
 * Revision 1.74  2003/08/01 16:19:23  mirsad
 * tvin, debug, 11-ka i 12-ka, kontrola stanja robe pri unosu
 *
 * Revision 1.73  2003/07/29 15:56:24  mirsad
 * ispravka: pri izlazu više ne razdvaja nabavke po cijeni veæ samo po narudžbi i naruèiocu
 *
 * Revision 1.72  2003/07/24 14:25:44  mirsad
 * omogucio unos procenta popusta na KALK 41 i 42
 *
 * Revision 1.71  2003/07/24 14:24:45  mirsad
 * ipak za izlaz vrsim prenos KALK97->FAKT19 a za ulaz KALK97->FAKT01
 *
 * Revision 1.70  2003/07/24 11:03:55  mirsad
 * omogucio prenos KALK97->FAKT01 pri azuriranju gledajuci konta u RJ.DBF u FAKT-u
 *
 * Revision 1.69  2003/07/21 08:10:12  mirsad
 * varijanta koristenja polja UKSTAVKI u DOKS u koje se upisuje broj stavki dokumenta
 *
 * Revision 1.68  2003/07/18 07:24:54  mirsad
 * stavio u f-ju kontrolu stanja za varijantu po narudzbama za izlazne dokumente (14,41,42)
 *
 * Revision 1.67  2003/07/08 18:18:17  sasa
 * gDuzKonto:=7, a ne 8
 *
 * Revision 1.66  2003/07/07 12:16:59  sasa
 * Prikaz infa poslije generisanja katops
 *
 * Revision 1.65  2003/07/06 22:20:23  mirsad
 * prenos fakt12->kalk96 obuhvata i varijantu unosa radnog naloga u fakt12
 *
 * Revision 1.64  2003/07/02 07:36:44  ernad
 * Planika - llp, llps, dodatni uslov za artikal "NAZ $ &*"
 *
 * Revision 1.63  2003/06/25 17:47:58  mirsad
 * 1) vraæanje u f-ju 15-ke
 * 2) debug: opis stavki u FIN-nalogu ako je u shemi definisano zaokr. pomocu ";9"  prociscen od ovih spec.simbola
 *
 * Revision 1.62  2003/06/23 09:32:36  sasa
 * prikaz dobavljaca
 *
 * Revision 1.61  2003/06/09 14:50:56  sasa
 * nver
 *
 * Revision 1.60  2003/06/06 14:37:31  sasa
 * nova verzija
 *
 * Revision 1.59  2003/05/27 00:37:56  mirsad
 * debug kalk->fin - porezi u ugost.var."T"
 *
 * Revision 1.58  2003/05/09 12:23:15  ernad
 * planika pregled kretanja zaliha - prog. promjena
 *
 * Revision 1.57  2003/04/30 13:14:37  sasa
 * Nova verzija ispravljen bug pri povlacenju izvjestaja sint.ll za vise prod.
 *
 * Revision 1.56  2003/04/12 06:55:35  mirsad
 * omogucen prenos KALK10,11,81->FAKT poput KALK->TOPS za udaljene lokacije
 *
 * Revision 1.55  2003/04/02 07:10:58  mirsad
 * dodan uslov za broj prethodnih sezona koje se gledaju da bi se utvrdilo koja je roba nabavljana od zadanog dobavljaca u izvj."pregled robe za dobavljaca"
 *
 * Revision 1.54  2003/03/17 07:58:08  mirsad
 * dorada za Biletiæa: obrazac sank liste na osnovu dokumenta IP
 *
 * Revision 1.53  2003/03/13 15:44:15  mirsad
 * ispravka bug-a - Tvin (po narudzbama)
 *
 * Revision 1.52  2003/03/11 15:24:23  mirsad
 * no message
 *
 * Revision 1.51  2003/03/05 08:33:46  mirsad
 * no message
 *
 * Revision 1.50  2003/02/24 02:39:57  mirsad
 * ispravka bug-a na fllm (ispis ukupno odlutao); uveo mogucnost zabrane unosa viska na IP
 *
 * Revision 1.49  2003/02/13 10:41:39  ernad
 * zaostali commit-i
 *
 * Revision 1.48  2003/02/04 00:25:58  mirsad
 * dorada: dugi uslov za kupca i opstinu kupca u pregledu prodaje za Vindiju
 *
 * Revision 1.47  2003/02/03 00:35:06  mirsad
 * Vindija-propust i dorada-otpisi; Jerry-dorada-IP
 *
 * Revision 1.46  2003/01/28 07:39:52  mirsad
 * dorada radni nalozi za pogon.knjigov.
 *
 * Revision 1.45  2003/01/21 16:18:22  ernad
 * planika gSQL=D bug tops
 *
 * Revision 1.44  2003/01/18 12:08:50  ernad
 * no message
 *
 * Revision 1.43  2003/01/15 12:39:10  ernad
 * bug 2003
 *
 * Revision 1.42  2003/01/10 14:14:56  ernad
 *
 *
 * bug - prenos poc stanja za region 2 - prodavnice RS
 *
 * Revision 1.41  2003/01/10 00:25:43  ernad
 *
 *
 * - popravka make systema
 * make zip ... \\*.chs -> \\\*.chs
 * ispravka std.ch ReadModal -> ReadModalSc
 * uvoðenje keyb/get.prg funkcija
 *
 * Revision 1.40  2003/01/09 16:28:25  mirsad
 * ispravka bug-a u planici (gen.p.st.prod.)
 *
 * Revision 1.39  2003/01/07 15:09:00  mirsad
 * ispravke rada u sezonama (sclib)
 *
 * Revision 1.38  2002/12/30 16:36:21  mirsad
 * no message
 *
 * Revision 1.37  2002/12/27 18:09:37  sasa
 * nova verzija
 *
 * Revision 1.36  2002/12/18 15:45:24  mirsad
 * nova opcija u ostalim opcijama (F11): promjena umjesto popusta smanji mpcsapp
 *
 * Revision 1.35  2002/11/22 10:44:38  mirsad
 * nova verzija - uveden secur.sistem i sredio makroe oblasti prema novom sistemu
 *
 * Revision 1.34  2002/10/07 14:15:59  mirsad
 * novi parametar: broj decimala za prikaz iznosa stavki KALK 4x varijanta Jerry
 *
 * Revision 1.33  2002/09/25 11:35:23  sasa
 * Nova verzija KALK-a
 *
 * Revision 1.32  2002/09/24 13:57:58  mirsad
 * ispravka bug-a u izvj."pregled prodaje" - sada obuhvata i dokumente "01" iz POS.DBF-a
 *
 * Revision 1.31  2002/08/19 10:04:04  ernad
 * mergiranje verzija (mirsad, ernad)
 *
 * Revision 1.30  2002/08/05 13:32:50  mirsad
 * 1.w.0.9.26, ispravljen bug u generaciji poc.st.prodavnice
 *
 * Revision 1.29  2002/08/02 13:43:52  mirsad
 * za Jerry: da se i pri promjeni artikla u ispravci stavke osvjezi sifra tarife
 *
 * Revision 1.28  2002/07/31 08:28:52  mirsad
 * omoguæeno vezivanje varijante TOPS->KALK za prod.mjesto
 *
 * Revision 1.27  2002/07/30 17:40:59  ernad
 * SqlLog funkcije - Fin modul
 *
 * Revision 1.26  2002/07/18 12:10:21  ernad
 *
 *
 * specif/planika : Pregled obrta po mjesecima
 * O_SIFK, O_SIFV ispravljeno (otvara bez obzira na parametre)
 *
 * Revision 1.25  2002/07/17 11:48:16  ernad
 *
 *
 * debug "Alias does not exist" SIFV, IzSifK
 *
 * Revision 1.24  2002/07/17 08:19:55  ernad
 *
 *
 * debug "Alias does not exist" funkcija IzSifK()
 *
 * Revision 1.23  2002/07/16 11:12:29  ernad
 *
 *
 * rlabele: uvedena GetVars() radi preglednosti, te jednostavnijeg uvodjenja novih varijanti
 *
 * Revision 1.22  2002/07/12 14:02:36  mirsad
 * zavrsena dorada za labeliranje robe za Aden
 *
 * Revision 1.21  2002/07/12 10:15:55  ernad
 *
 *
 * debug ROBPR.DBF, ROBPR.CDX - uklonjena funkcija DodajRobPr()
 *
 * Revision 1.20  2002/07/10 09:45:18  ernad
 *
 *
 *
 * skeleton rlabele (Roba labele - naljepnice)
 *
 * Revision 1.19  2002/07/08 23:03:54  ernad
 *
 *
 * trgomarket debug dok 80, 81, izvjestaj lager lista magacin po proizv. kriteriju
 *
 * Revision 1.18  2002/07/06 17:28:58  ernad
 *
 *
 * izvjestaj Trgomarket: pregled stanja po objektima
 *
 * Revision 1.17  2002/07/06 12:29:01  ernad
 *
 *
 * kalk, planika GenRekap1, GenRekap2
 *
 * Revision 1.16  2002/07/04 19:04:08  ernad
 *
 *
 * ciscenje sifrarnik fakt
 *
 * Revision 1.15  2002/07/03 23:55:19  ernad
 *
 *
 * ciscenja planika (tragao za nepostojecim bug-om u prelgedu finansijskog obrta)
 *
 * Revision 1.14  2002/07/03 07:31:12  ernad
 *
 *
 * planika, debug na terenu
 *
 * Revision 1.13  2002/07/01 17:49:28  ernad
 *
 *
 * formiranje finalnih build-ova (fin, kalk, fakt, pos) pred teren planika
 *
 * Revision 1.12  2002/06/29 17:32:01  ernad
 *
 *
 * planika - pregled prometa prodavnice
 *
 * Revision 1.11  2002/06/26 17:53:45  ernad
 *
 *
 * ciscenje, inventura magacina
 *
 * Revision 1.10  2002/06/25 08:44:24  ernad
 *
 *
 * ostranicavanje planika, doxy - grupa: Planika
 *
 * Revision 1.9  2002/06/24 07:47:59  ernad
 * korekcije tops->kalk, kolicina 0
 *
 * Revision 1.8  2002/06/21 14:00:31  ernad
 * -
 *
 * Revision 1.7  2002/06/20 16:52:05  ernad
 *
 *
 * ciscenje planika, uvedeno fmk/svi/specif.prg
 *
 * Revision 1.6  2002/06/20 12:55:06  ernad
 *
 *
 * cisenja radu u sezonsko<->radno podrucje, u skladu sa novim sclib-om
 *
 * Revision 1.5  2002/06/19 19:48:40  ernad
 *
 *
 * ciscenje
 *
 * Revision 1.4  2002/06/17 09:43:43  ernad
 *
 *
 * header
 *
 * Revision 1.3  2002/06/17 07:30:28  ernad
 * -
 *
 * Revision 1.2  2002/06/17 07:19:17  ernad
 *
 *
 * header
 *
 *
 */
 
#ifndef SC_DEFINED
	#include "sc.ch"
#endif

#define D_KA_VERZIJA "1.w.1.1.23"
#define D_KA_PERIOD  '11.94-01.06.04'


#ifndef FMK_DEFINED
	#include "\cl\sigma\fmk\fmk.ch"
#endif

#ifdef CDX
	#include "\cl\sigma\fmk\kalk\cdx\kalk.ch"
#else
	#include "\cl\sigma\fmk\kalk\ax\kalk.ch"
#endif

#xcommand CLREZRET   =>  IspitajRezim(); CLOSERET
#define GSCTEMP "c:"+SLASH+"sctemp"+SLASH

#define I_ID 1
