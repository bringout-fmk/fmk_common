#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/mag/rpt/1g/mnu_izvj.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.4 $
 * $Log: mnu_izvj.prg,v $
 * Revision 1.4  2002/07/08 23:03:54  ernad
 *
 *
 * trgomarket debug dok 80, 81, izvjestaj lager lista magacin po proizv. kriteriju
 *
 * Revision 1.3  2002/06/25 15:08:46  ernad
 *
 *
 * prikaz parovno - Planika
 *
 * Revision 1.2  2002/06/20 13:13:03  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/mag/rpt/1g/mnu_izvj.prg
 *  \brief Meniji magacinskih izvjestaja
 */


/*! \fn IzvjM()
 *  \brief Osnovni meni magacinskih izvjestaja
 */

function IzvjM()
*{
private Opc:={}
private opcexe:={}
AADD(Opc,"1. kartica - magacin                      ")
AADD(opcexe,{|| KarticaM()})
AADD(Opc,"2. lager lista - magacin")
AADD(opcexe,{|| LLM()})
AADD(Opc,"3. lager lista - proizvoljni sort")
AADD(opcexe,{|| KaLagM()})

AADD(Opc,"4. finansijsko stanje magacina")
AADD(opcexe, {|| FLLM()})
AADD(Opc,"5. realizacija po partnerima")
AADD(opcexe,{||  RealPartn()})
AADD(Opc,"6. promet grupe partnera")
AADD(opcexe,{|| PrometGP()})
AADD(opc,"7. pregled robe za dobavljaca")
AADD(opcexe, {|| ProbDob()})

AADD(Opc,"----------------------------------")
AADD(opcexe, nil)
AADD(Opc,"7. porezi")
AADD(opcexe,{|| MPoreziMag()})
AADD(Opc,"----------------------------------")
AADD(opcexe, nil)
AADD(Opc,"S. pregledi za vise objekata")
AADD(opcexe, {|| MRekMag() })
private Izbor:=1
Menu_SC("imag")
CLOSERET
return
*}




/*! \fn MPoreziMag()
 *  \brief Meni izvjestaja o porezima
 */

function MPoreziMag()
*{
private Opc:={}
private opcexe:={}
AADD(Opc,"1. realizacija - veleprodaja po tarifama")
AADD(opcexe,{|| RekPorMag()})
AADD(Opc,"2. porez na promet ")
AADD(opcexe,{|| RekPorNap()})
AADD(Opc,"3. rekapitulacija po tarifama")
AADD(opcexe,{|| RekmagTar()})
private Izbor:=1
Menu_SC("porm")
CLOSERET
return
*}




/*! \fn MRekMag()
 *  \brief Meni izvjestaja za vise objekata(konta)
 */
 
function MRekMag()
*{
private Opc:={}
private opcexe:={}
AADD(Opc,"1. rekapitulacija finansijskog stanja")
AADD(opcexe, {|| RFLLM() } )
private Izbor:=1
Menu_SC("rmag")
CLOSERET
return
*}




