#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/adm/1g/mnu_adm.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.5 $
 * $Log: mnu_adm.prg,v $
 * Revision 1.5  2003/10/07 11:48:31  sasavranic
 * Brisanje sifara za artikle koji nisu u prometu! Dorada
 *
 * Revision 1.4  2002/11/22 10:42:53  mirsad
 * omogucavanje security opcija
 *
 * Revision 1.3  2002/06/20 12:55:06  ernad
 *
 *
 * cisenja radu u sezonsko<->radno podrucje, u skladu sa novim sclib-om
 *
 * Revision 1.2  2002/06/18 14:02:38  mirsad
 * dokumentovanje (priprema za doxy)
 *
 *
 */
 
 
/*! \file fmk/kalk/adm/mnu_adm.prg
 *  \brief Meniji administrativnih opcija
 */


/*! \fn MAdminKALK()
 *  \brief Meni administrativnih opcija
 */
 
function MAdminKALK()
*{
private Opc:={}
private opcexe:={}
AADD(Opc,"1. instalacija db-a                               ")
AADD(opcexe, {|| goModul:oDatabase:install()})
AADD(opc,"2. security")
AADD(opcexe, {|| MnuSecMain()})
AADD(Opc,"3. markiraj polje roba/sez - sifk")
AADD(opcexe, {|| MPSifK()})
AADD(Opc,"4. ubaci partnera iz dokumenata u sifrarnik robe")
AADD(opcexe, {|| DobUSifK()})
AADD(opc,"5. sredjivanje kartica")
AADD(opcexe, {|| MenuSK() })
AADD(opc,"6. generacija kumulativne baze")
AADD(opcexe, {|| Gen9999()})
AADD(opc,"7. setmarza10")
AADD(opcexe, {|| SetMarza10()})
AADD(opc,"8. brisanje artikala koji se ne koriste")
AADD(opcexe, {|| Mnu_BrisiSifre()})


private Izbor:=1
Menu_SC("admk")
CLOSERET
*}


/*! \fn MenuSK()
 *  \brief Meni opcija za korekciju kartica artikala
 */

function MenuSK()
*{
PRIVATE Opc:={}
PRIVATE opcexe:={}
AADD(Opc,"1. korekcija prodajne cijene - nivelacija (VPC iz sifr.robe)    ")
AADD(opcexe, {|| KorekPC() })
AADD(Opc,"2. ispravka sifre artikla u dokumentima i sifrarniku")
AADD(opcexe, {|| RobaIdSredi() })
AADD(Opc,"3. korekcija nc storniranjem gresaka tipa NC=0   ")
AADD(opcexe, {|| KorekNC() })
AADD(Opc,"4. korekcija nc pomocu dok.95 (NC iz sifr.robe)")
AADD(opcexe, {|| KorekNC2() })
AADD(Opc,"5. korekcija prodajne cijene - nivelacija (MPC iz sifr.robe)")
AADD(opcexe, {|| KorekMPC() })
AADD(Opc,"6. postavljanje tarife u dokumentima na vrijednost iz sifrarnika")
AADD(opcexe, {|| KorekTar() })
AADD(Opc,"7. svodjenje artikala na primarno pakovanje")
AADD(opcexe, {|| NaPrimPak() })
private Izbor:=1
Menu_SC("kska")
CLOSERET
*}




