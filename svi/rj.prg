#include "sc.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/svi/rj.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.4 $
 * $Log: rj.prg,v $
 * Revision 1.4  2003/07/24 11:01:12  mirsad
 * za modul FAKT vratio kolone koje su se prikazivale u sifrarniku rad.jedinica
 *
 * Revision 1.3  2002/07/04 19:04:08  ernad
 *
 *
 * ciscenje sifrarnik fakt
 *
 * Revision 1.2  2002/06/16 11:44:53  ernad
 * unos header-a
 *
 *
 */

/*! \fn P_Rj(cId,dx,dy)
 *  \brief Otvara sifranik radnih jedinica 
 *  \param cId
 *  \param dx
 *  \param dy
 */

function P_RJ(cId,dx,dy)
*{
private imekol,kol:={}

if gModul=="FAKT" 
	ImeKol:={ { padr("Id",2), {|| id}, "id", {|| .t.}, {|| vpsifra(wid)} },;
	          { padr("Naziv",35), {||  naz}, "naz" }                      ,;
	          { padr("Tip cij.",10), {||  tip}, "tip" }                   ,;
	          { padr("Konto",10), {||  konto}, "konto" }                   ;
	       }
	IF gMjRJ=="D"
	  AADD(ImeKol, { padr("Grad",20), {||  grad}, "grad" } )
	ENDIF

	FOR i:=1 TO LEN(ImeKol); AADD(Kol,i); NEXT
else
	ImeKol:={ { padr("Id",2), {|| id}, "id", {|| .t.}, {|| vpsifra(wid)} },;
	          { padr("Naziv",35), {||  naz}, "naz" }                       ;
	       }
	Kol:={1,2}
endif
private gTBDir:="N"
return PostojiSifra(F_RJ,1,10,65,"Lista radnih jedinica",@cId,dx,dy)

*}
