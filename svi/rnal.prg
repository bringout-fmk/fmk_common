#include "sc.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/svi/rnal.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.2 $
 * $Log: rnal.prg,v $
 * Revision 1.2  2004/03/18 09:18:59  sasavranic
 * Dodao funkciju GetNameRNal() koja daje vijednost polja naz iz tabele rnal
 *
 * Revision 1.1  2003/01/08 03:17:59  mirsad
 * ubacen RNAL.DBF za rama glas i varijanta rama glas
 *
 * Revision 1.2  2002/06/16 11:44:53  ernad
 * unos header-a
 *
 *
 */
 
/*! \fn P_RNal(cId,dx,dy)
 */
function P_RNal(cId,dx,dy)
*{
private imekol,kol
ImeKol:={ { padc("Id",10), {|| id}, "id", {|| .t.}, {|| vpsifra(wid)} },;
          { padc("Naziv",60), {||  naz}, "naz" }                       ;
       }

Kol:={}
FOR i:=1 TO LEN(ImeKol); AADD(Kol,i); NEXT
return PostojiSifra(F_RNAL,1,10,65,"Lista radnih naloga",@cId,dx,dy)
*}


/*! \fn GetNameFromRNal(cIdRnal)
 *  \brief Vraca naziv radnog naloga za trazeni cIdRnal
 *  \param cIdRnal - id radnog naloga
 */
function GetNameRNal(cIdRnal)
*{
local nArr
nArr:=SELECT()
O_RNAL
select rnal
set order to tag "ID"
seek cIdRnal
cRet:=ALLTRIM(field->naz)
select (nArr)
return cRet
*}

