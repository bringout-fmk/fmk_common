#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/prod/rpt/1g/mnu_izvj.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.5 $
 * $Log: mnu_izvj.prg,v $
 * Revision 1.5  2002/07/01 17:49:28  ernad
 *
 *
 * formiranje finalnih build-ova (fin, kalk, fakt, pos) pred teren planika
 *
 * Revision 1.4  2002/06/29 17:32:02  ernad
 *
 *
 * planika - pregled prometa prodavnice
 *
 * Revision 1.3  2002/06/21 12:23:21  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/prod/rpt/1g/mnu_izvj.prg
 *  \brief Meniji prodavnickih izvjestaja
 */


/*! \fn IzvjP()
 *  \brief Osnovni meni prodavnickih izvjestaja
 */

function IzvjP()
*{
if gVodiSamoTarife=="D"
	IzvjTar()
	return
endif

private Opc:={}
private opcexe:={}
AADD(Opc, "1. kartica - prodavnica                          ")
AADD(opcexe, {|| KarticaP()})
AADD(Opc, "2. lager lista - prodavnica")
AADD(opcexe, {|| LLP()})
AADD(Opc, "3. finansijsko stanje prodavnice")
AADD(opcexe, {|| FLLP()})
AADD(Opc,  "---------------------------------")
AADD(opcexe, NIL)
AADD(Opc,  "4. porezi")
AADD(opcexe, {|| PoreziProd()})
AADD(Opc,  "---------------------------------")
AADD(opcexe, NIL)
AADD(Opc,  "5. pregled za vise objekata")
AADD(opcexe, {|| RekProd()})
private Izbor:=1
Menu_SC("izp")
return nil
*}




/*! \fn PoreziProd()
 *  \brief Meni izvjestaja o porezima u prodavnici
 */

function PoreziProd()
*{
private Opc:={}
private opcexe:={}
AADD(Opc, "1. ukalkulisani porezi ")
AADD(opcexe, {|| RekKPor()})
AADD(Opc, "2. realizovani porezi")
AADD(opcexe, {|| RekRPor()})
private Izbor:=1
Menu_SC("porp")
return nil
*}




/*! \fn RekProd()
 *  \brief Meni izvjestaja za vise prodavnica
 */

function RekProd()
*{
private Izbor
private opc:={}
private opcexe:={}
AADD(opc, "1. sinteticka lager lista                  ")
AADD(opcexe, {|| LLPS()})
AADD(opc, "2. rekapitulacija fin stanja po objektima")
AADD(opcexe, {|| RFLLP()})
AADD(opc, "3. dnevni promet za sve objekte")
AADD(opcexe, {|| DnevProm()})
AADD(opc, "4. pregled prometa prodavnica za period")
AADD(opcexe, {|| PPProd()})

Izbor:=1
Menu_SC("prsi")
return nil
*}


