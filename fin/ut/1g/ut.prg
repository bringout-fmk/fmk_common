#include "\cl\sigma\fmk\fin\fin.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fin/ut/1g/ut.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.7 $
 * $Log: ut.prg,v $
 * Revision 1.7  2004/01/29 12:53:45  sasavranic
 * Ispravljena greska za SECUR.DBF
 *
 * Revision 1.6  2004/01/13 19:07:57  sasavranic
 * appsrv konverzija
 *
 * Revision 1.5  2003/01/10 00:25:43  ernad
 *
 *
 * - popravka make systema
 * make zip ... \\*.chs -> \\\*.chs
 * ispravka std.ch ReadModal -> ReadModalSc
 * uvoðenje keyb/get.prg funkcija
 *
 * Revision 1.4  2002/11/18 04:29:19  mirsad
 * dorade-security
 *
 * Revision 1.3  2002/11/15 16:48:45  sasa
 * korekcija koda
 *
 * Revision 1.2  2002/06/21 08:50:54  sasa
 * no message
 *
 *
 */


/*! \file fmk/fin/ut/1g/ut.prg
 *  \brief Utility
 */

/*! \fn OtkljucajBug()
    \brief ??Otkljucaj lafo bug?
    \note sifra: BUG
 */
 
function OtkljucajBug()
*{
if SigmaSif("BUG     ")
	lPodBugom:=.f.
    	gaKeys:={}
endif
return NIL
*}

/*! \fn Izvj0()
 *  \brief
 */
function Izvj0()
*{
// sasa, 28.01.04, problem sa secur.dbf
//cSecur:=SecurR(KLevel,"IZVJESTAJI")
//if ImaSlovo("X",cSecur)
//	MsgBeep("Opcija nedostupna !")
//	return
//endif
Izvjestaji()

return
*}

/*! \fn PovratNaloga()
 *  \brief Povrat naloga
 */
function PovratNaloga()
*{
if gBezVracanja=="N"
	Povrat()
endif

return
*}

/*! \fn Preknjizenje()
 *  \brief preknjizenje
 */
function Preknjizenje()
*{
cSecur:=SecurR(KLevel,"Preknjiz")
cSecur2:=SecurR(KLevel,"SGLEDAJ")
if ImaSlovo("X",cSecur) .or. ImaSlovo("D",cSecur2)
	MsgBeep("Opcija nedostupna !")
else
	Preknjiz()
endif
return
*}

/*! \fn PrebKartica()
 *  \brief Prebacivanja kartica
 */
function PrebKartica()
*{
cSecur:=SecurR(KLevel,"Prekart")
cSecur2:=SecurR(KLevel,"SGLEDAJ")
if ImaSlovo("TX",cSecur) .or. ImaSlovo("D",cSecur2)
	MsgBeep("Opcija nedostupna !")
else
	PreKart()
endif
return
*}


/*! \fn GenPocStanja()
 *  \brief generacija pocetnog stanja
 */
function GenPocStanja()
*{
cSecur:=SecurR(KLevel,"PrenosNG")
cSecur2:=SecurR(KLevel,"SGLEDAJ")
if ImaSlovo("X",cSecur) .or. ImaSlovo("D",cSecur2)
	MsgBeep("Opcija nedostupna !")
else
	PrenosFin()
endif
return
*}

/*! \fn ImaUSubanNemaUNalog()
 *  \brief Ispituje da li nalog postoji u SUBAN ako ga nema u NALOG
 */
function ImaUSubanNemaUNalog()
*{
Box(,5,60)
close all
select 1
use nalog
set order to 1
select 2
use suban
set order to 0
select 3
use anal
set order to 0
select 4
use sint
set order to 0
for i:=1 to 3
	if i==1
		cAlias:="SUBAN"
	elseif i==2
		cAlias:="ANAL"
	else
		cAlias:="SINT"
	endif
	select &cAlias
	go top
	do while !eof().and.inkey()!=27
		select nalog
		seek &cAlias->(idfirma+idvn+brnal)
		if !found()
			select &cAlias
			Beep(1)
			@ m_x+5,m_y+2 SAY  "nema naloga! "
			?? idfirma+"-"+idvn+"-"+brnal
			InkeySc(0)
			@ m_x+5,m_y+2 SAY  "             "
		else
			@ m_x+3,m_y+2 SAY idfirma+"-"+idvn+"-"+brnal
		endif
		select &cAlias
		@ m_x+1,m_y+2 SAY recno()
		?? calias
		skip 1
	enddo
next
BoxC()
close all
return
*}


/*! \fn StornoNaloga()
 *  \brief Storniranje naloga
 */
function StornoNaloga()
*{
Povrat(.t.)
return
*}



