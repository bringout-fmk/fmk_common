/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/fakt.ch,v $
 * $Author: sasavranic $ 
 * $Revision: 1.91 $
 * $Log: fakt.ch,v $
 * Revision 1.91  2004/05/27 09:27:02  sasavranic
 * Koristenje zajednickog sifranika valuta
 *
 * Revision 1.90  2004/05/11 09:00:31  sasavranic
 * Dodao stampu narudzbenice kroz Fmk.NET
 *
 * Revision 1.89  2004/05/06 14:30:00  sasavranic
 * Uvedena nova f-ja Iz22u10(), tigra
 *
 * Revision 1.88  2004/03/18 09:17:42  sasavranic
 * Uslov za radni nalog na pregledu dokumenata te kartici artikla
 *
 * Revision 1.87  2004/02/12 15:37:16  sasavranic
 * Kopiranje podataka za novu grupu po uzoru na postojecu.
 *
 * Revision 1.86  2004/01/13 19:07:53  sasavranic
 * appsrv konverzija
 *
 * Revision 1.85  2004/01/07 13:43:58  sasavranic
 * Na izvjestaju Lista salda kupaca dodao kolonu ukupno
 *
 * Revision 1.84  2003/12/12 15:24:50  sasavranic
 * uvedeno stampanje barkod-a i na varijantu fakture 2, 3
 *
 * Revision 1.83  2003/12/10 10:56:41  sasavranic
 * Stavljena xcommand O_POMGN
 *
 * Revision 1.82  2003/12/08 15:12:20  sasavranic
 * Dorada za opresu, polje remitenda
 *
 * Revision 1.81  2003/12/04 11:11:43  sasavranic
 * Uvedena konverzija i za varijantu "2" fakture
 *
 * Revision 1.80  2003/12/03 14:19:24  sasavranic
 * uvedena konverzija znakova
 *
 * Revision 1.79  2003/12/03 13:34:20  sasavranic
 * Ispravljen bug ispisa Ident.br i za poreski broj
 *
 * Revision 1.78  2003/11/28 15:11:59  sasavranic
 * Opresa - stampa, stampa dostavnica u jedan red
 *
 * Revision 1.77  2003/11/28 14:04:17  sasavranic
 * Korekcije kod-a opresa - stampa
 *
 * Revision 1.76  2003/11/21 08:49:04  sasavranic
 * Opresa - stampa, stampa samo jedne dostavnice
 * FMK.INI/PRIVPATH
 * [Stampa]
 *  JednaDostavnica=D
 *
 * Revision 1.75  2003/10/29 10:24:09  sasavranic
 * na kartici dodat ispis jmj
 *
 * Revision 1.74  2003/10/04 12:32:47  sasavranic
 * uveden security sistem
 *
 * Revision 1.73  2003/09/26 11:16:31  mirsadsubasic
 * debug: vratio u f-ju parametar za korištenje VPC
 *
 * Revision 1.72  2003/09/20 13:20:19  mirsadsubasic
 * Uvodjenje novih parametara u parametri Win stampe fakture -- merkomerc
 *
 * Revision 1.71  2003/09/17 15:13:59  mirsad
 * sitni debug: uklonio poruku na kraju izvj.lager liste "gcnt1=x"
 *
 * Revision 1.70  2003/09/12 09:34:57  ernad
 * omoguceno biranje i VPC po RJ
 *
 * Revision 1.69  2003/09/08 13:18:14  mirsad
 * sitne dorade za Hano - radni nalozi
 *
 * Revision 1.68  2003/08/21 08:12:08  mirsad
 * Specif.za Niagaru: - ukinuo setovanje mpc u sifr. pri unosu 13-ke, a uveo setovanje mpc u sifr. pri unosu 01-ice
 *
 * Revision 1.67  2003/08/07 11:30:00  sasa
 * Dodat naziv organa na narudzbenici
 *
 * Revision 1.66  2003/08/06 17:44:49  mirsad
 * dorada za Tvin, varijanta faktura 2/2, prikaz iznosa poreza za svaku stavku
 *
 * Revision 1.65  2003/08/01 09:42:05  sasa
 * nove karakteristike na nar
 *
 * Revision 1.64  2003/07/25 13:13:54  sasa
 * korekcije narudzbenice
 *
 * Revision 1.63  2003/07/24 11:01:34  mirsad
 * za modul FAKT vratio kolone koje su se prikazivale u sifrarniku rad.jedinica
 *
 * Revision 1.62  2003/07/23 14:20:50  sasa
 * broj sudskog rjesenja
 *
 * Revision 1.61  2003/07/16 11:17:53  sasa
 * broj rjesenja
 *
 * Revision 1.60  2003/07/11 06:36:00  sasa
 * trebovanje kada je popunjeno polje radnog naloga
 *
 * Revision 1.59  2003/07/07 14:09:22  sasa
 * Prebacene pomocne tabele POMGN i PPOMGN.DBF u KUMPATH
 *
 * Revision 1.58  2003/07/06 21:50:53  mirsad
 * nova varijanta: unos radnog naloga na 12-ki (FMK.INI/KUMPATH/FAKT/RadniNalozi=D)
 *
 * Revision 1.57  2003/05/27 15:34:25  mirsad
 * ukinuo f-ju za pregled normativa , prebacio je u modul roba/rpt_sast.prg
 *
 * Revision 1.56  2003/05/23 13:08:10  ernad
 * haaktrans rtm faktura
 *
 * Revision 1.55  2003/05/20 09:14:01  ernad
 * - RTM faktura za tip dokumenta 11
 *
 * Revision 1.54  2003/05/20 07:29:01  mirsad
 * Formatirao duzinu naziva robe za izvjestaje na 40 znakova.
 *
 * Revision 1.53  2003/05/14 15:24:39  sasa
 * ispravka buga
 *
 * Revision 1.52  2003/05/10 18:57:58  ernad
 * dodat opis za artikle u dokumentu
 *
 * Revision 1.51  2003/05/10 15:07:57  mirsad
 * dodatna polja za robne karakteristike u kumulativnoj bazi C1,C2,C3,N1,N2
 *
 * Revision 1.50  2003/05/05 09:53:04  mirsad
 * debug: TOPS->FAKT odredjivanje brojeva generisanih FAKT-dokumenata sada OK
 *
 * Revision 1.49  2003/04/28 13:39:12  mirsad
 * omogucen prikaz rekapitulacije po tarifama na lager listi (za Opresu)
 *
 * Revision 1.48  2003/04/25 10:44:36  ernad
 * ispravka za Planiku: parametar Cijena13MPC=D vise ne setuje MPC u sifrarniku pri promjeni cijene u unosu 13-ke
 *
 * Revision 1.47  2003/04/24 06:59:15  mirsad
 * preuzimanje TOPS->FAKT
 *
 * Revision 1.46  2003/04/16 15:02:58  mirsad
 * ispravke buga "zaklj.zapis" na pripr.dbf
 *
 * Revision 1.45  2003/04/14 20:27:28  ernad
 * bug: lock requiered pri unosu partnera
 *
 * Revision 1.44  2003/04/12 23:00:38  ernad
 * O_Edit (O_S_PRIREMA)
 *
 * Revision 1.43  2003/04/12 18:38:35  ernad
 * ImportTxt
 *
 * Revision 1.42  2003/04/12 07:00:09  mirsad
 * omogucen prenos KALK10,11,81->FAKT poput KALK->TOPS za udaljene lokacije
 *
 * Revision 1.41  2003/03/29 09:52:39  mirsad
 * Ispravka bug-a na tabelarnom pregledu dokumenata: nakon omoguæavanja uslova za opæinu za tabelarni prikaz poèeo ispadati u situaciji kada se vraæa dokument u pripremu a ne izabere se prelazak u nju
 *
 * Revision 1.40  2003/03/28 15:38:10  mirsad
 * 1) ispravka bug-a pri gen.fakt.na osnovu otpremnica: sada se korektno setuje datum u svim stavkama
 * 2) ukinuo setovanje u proizvj.ini parametra "Broj" jer opet smeta (zbog njega se u reg.broj upisuje broj fakture)
 *
 * Revision 1.39  2003/03/27 15:13:45  mirsad
 * izvjestaj "specif.prodaje" sada radi kao i uslov za opcinu za tabelarni prikaz liste dokumenata
 *
 * Revision 1.38  2003/03/26 14:54:37  mirsad
 * umjesto "Reg.br." i "Por.br." svuda stavljen ispis "Ident.br."
 *
 * Revision 1.37  2003/03/16 10:07:16  ernad
 * rtf fakture
 *
 * Revision 1.36  2003/03/12 10:37:09  mirsad
 * parametrizirao poziv labeliranja
 *
 * Revision 1.35  2003/03/05 08:32:07  mirsad
 * no message
 *
 * Revision 1.34  2003/03/01 08:42:46  mirsad
 * ispravke bugova-Zips
 *
 * Revision 1.33  2003/01/29 06:00:36  ernad
 * citanje ini fajlova
 *
 * Revision 1.32  2003/01/21 15:01:58  ernad
 * probelm excl fakt - kalk ?! direktorij kalk
 *
 * Revision 1.31  2003/01/19 23:44:17  ernad
 * test network speed (sa), korekcija bl.lnk
 *
 * Revision 1.30  2003/01/18 18:26:49  ernad
 * speed testing exclusive
 *
 * Revision 1.29  2003/01/18 12:08:50  ernad
 * no message
 *
 * Revision 1.28  2003/01/15 12:39:09  ernad
 * bug 2003
 *
 * Revision 1.27  2003/01/14 03:23:33  ernad
 * exclusiv ... probelm mreza W2K ...
 *
 * Revision 1.26  2003/01/10 00:25:43  ernad
 *
 *
 * - popravka make systema
 * make zip ... \\*.chs -> \\\*.chs
 * ispravka std.ch ReadModal -> ReadModalSc
 * uvoðenje keyb/get.prg funkcija
 *
 * Revision 1.25  2002/12/21 11:52:43  mirsad
 * ispravke bugova
 *
 * Revision 1.24  2002/10/18 13:26:43  sasa
 * nova verzija
 *
 * Revision 1.23  2002/10/15 13:25:13  sasa
 * nova verzija
 *
 * Revision 1.22  2002/09/28 15:49:48  mirsad
 * prenos pocetnog stanja za evid.uplata dovrsen
 *
 * Revision 1.21  2002/09/27 12:22:02  mirsad
 * ispr.bug na pregledu salda kupaca
 *
 * Revision 1.20  2002/09/26 12:47:05  mirsad
 * no message
 *
 * Revision 1.19  2002/09/26 10:30:29  sasa
 * nova verzija
 *
 * Revision 1.18  2002/07/08 08:27:47  ernad
 *
 *
 * debug - uzimanje teksta na kraju fakture
 *
 * Revision 1.17  2002/07/08 07:53:26  ernad
 *
 *
 * debug Fakt/lBenjo
 *
 * Revision 1.16  2002/07/05 14:34:17  sasa
 * implementirani izvjestaji za rudnik, sifrarnici za vindiju, ugovori
 *
 * Revision 1.15  2002/07/05 08:23:07  ernad
 *
 *
 * parametar ExePath/Fakt_specif/Fakt_Kalk -> KumPath/Fakt/FaktKalk
 *
 * Revision 1.14  2002/07/04 19:04:08  ernad
 *
 *
 * ciscenje sifrarnik fakt
 *
 * Revision 1.13  2002/07/04 13:35:04  ernad
 *
 *
 * debug: Stanje robe uzima parametre iz lager liste (a oni se ne mogu ispraviti pri pozivu izvjestaja)
 *
 * Revision 1.12  2002/07/04 08:20:40  sasa
 * nova verzija
 *
 * Revision 1.11  2002/07/03 07:31:12  ernad
 *
 *
 * planika, debug na terenu
 *
 * Revision 1.10  2002/07/01 09:02:20  mirsad
 * no message
 *
 * Revision 1.9  2002/06/28 21:49:17  ernad
 *
 *
 * dodana opcija u glavni meni "administracija db-a"
 *
 * Revision 1.8  2002/06/28 20:19:36  ernad
 *
 *
 * debug GenDokInv
 *
 * Revision 1.7  2002/06/28 07:22:35  ernad
 *
 *
 * zavrsetak formiranja skeleton-a (Obrazac inventure)
 *
 * Revision 1.6  2002/06/27 17:21:33  ernad
 *
 *
 * azuriranje verzije - dokument inventure
 *
 * Revision 1.5  2002/06/27 14:03:20  ernad
 *
 *
 * dok/2g init
 *
 * Revision 1.4  2002/06/26 18:07:23  ernad
 * ciscenja
 *
 * Revision 1.3  2002/06/24 08:15:27  sasa
 * no message
 *
 * Revision 1.2  2002/06/21 13:04:59  sasa
 * no message
 *
 * Revision 1.1.1.1  2002/06/17 18:30:18  ernad
 * no message
 *
 *
 */
 
#ifndef SC_DEFINED
	#include "sc.ch"
#endif

#define D_FA_VERZIJA "1.w.0.7.93"
#define D_FA_PERIOD  "11.94-27.05.04"


#ifndef FMK_DEFINED
	#include "\cl\sigma\fmk\fmk.ch"
#endif

#ifdef CDX
	#include "\cl\sigma\fmk\fakt\cdx\fakt.ch"
#else
	#include "\cl\sigma\fmk\fakt\ax\fakt.ch"
#endif

#define I_ID 1

#command POCNI STAMPU   => if !lSSIP99 .and. !StartPrint()       ;
                           ;close all             ;
                           ;return                ;
                           ;endif

#command ZAVRSI STAMPU  => if !lSSIP99; EndPrint(); endif

#define  ZAOKRUZENJE    2




#define NL  chr(13)+chr(10)


