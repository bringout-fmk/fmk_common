#include "\cl\sigma\fmk\fin\fin.ch"
/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fin/rpt/1g/mnu_spec.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.4 $
 * $Log: mnu_spec.prg,v $
 * Revision 1.4  2004/02/16 14:26:10  sasavranic
 * Na specifikaciji po suban kontima napravio rasclanjenje po RJ FUNK FOND
 *
 * Revision 1.3  2004/02/16 14:12:00  sasavranic
 * Na specifikaciji po suban kontima napravio rasclanjenje po RJ FUNK FOND
 *
 * Revision 1.2  2004/01/13 19:07:57  sasavranic
 * appsrv konverzija
 *
 *
 */


/*! \file fmk/fin/rpt/1g/mnu_spec.prg
 *  \brief Menij specifikacija
 */

/*! \fn MnuSpecif()
 *  \brief Glavni menij za izbor specifikacija
 */

 
function MnuSpecif()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. partnera na kontu                                        ")
AADD(opcexe, {|| SpecDPK()})
AADD(opc, "2. otvorene stavke preko-do odredjenog broja dana za konto")
AADD(opcexe, {|| SpecBrDan()})
AADD(opc, "3. konta za partnera")
AADD(opcexe, {|| SpecPop()})
AADD(opc, "4. po analitickim kontima")
AADD(opcexe, {|| SpecPoK()})
AADD(opc, "5. po subanalitickim kontima")
AADD(opcexe, {|| SpecPoKP()})
AADD(opc, "6. za subanaliticki konto / 2")
AADD(opcexe, {|| SpecSubPro()})
AADD(opc, "7. za subanaliticki konto/konto2")
AADD(opcexe, {|| SpecKK2()})
AADD(opc, "8. pregled novih dugovanja/potrazivanja")
AADD(opcexe, {|| PregNDP()})
AADD(opc, "9. pregled partnera bez prometa")
AADD(opcexe, {|| PartVanProm()})

if gRJ=="D" .or. gTroskovi=="D"
	AADD(opc, "A. izvrsenje budzeta/pregled rashoda")
	AADD(opcexe, {|| IzvrsBudz()})
	AADD(opc, "B. pregled prihoda")
	AADD(opcexe, {|| Prihodi()})
endif

AADD(opc, "C. otvorene stavke po dospijecu - po racunima (kao kartica)")
AADD(opcexe, {|| SpecPoDosp(.t.)})
AADD(opc, "D. otvorene stavke po dospijecu - specifikacija partnera")
AADD(opcexe, {|| SpecPoDosp(.f.)})
AADD(opc, "E. rekapitulacija partnera po poslovnim godinama")
AADD(opcexe, {|| RPPG()})
AADD(opc, "F. pregled dugovanja partnera po rocnim intervalima ")
AADD(opcexe, {|| SpecDugPartnera()})

Menu_SC("spc")
return
*}

