#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/ostalo/1g/ostalo.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.4 $
 * $Log: ostalo.prg,v $
 * Revision 1.4  2003/01/19 23:44:17  ernad
 * test network speed (sa), korekcija bl.lnk
 *
 * Revision 1.3  2002/06/27 14:03:20  ernad
 *
 *
 * dok/2g init
 *
 * Revision 1.2  2002/06/18 13:23:38  sasa
 * no message
 *
 * Revision 1.1.1.1  2002/06/17 18:30:18  ernad
 * no message
 *
 *
 */
 

/*! \file fmk/fakt/ostalo/1g/ostalo.prg
 */


function FaAsistent()
*{
local nEntera

nEntera:=30
for iSekv:=1 to int(RecCount2()/15)+1
cSekv:=chr(K_CTRL_A)
	for nKekk:=1 to min(reccount2(),15)*20
		cSekv+=cEnter
	next
	keyboard csekv
next
return
*}

