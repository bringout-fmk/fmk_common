#include "sc.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/svi/ops.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.6 $
 * $Log: ops.prg,v $
 * Revision 1.6  2004/02/12 15:37:55  sasavranic
 * no message
 *
 * Revision 1.5  2004/01/13 19:08:00  sasavranic
 * appsrv konverzija
 *
 * Revision 1.4  2003/07/25 13:14:20  sasa
 * korekcije narudzbenice
 *
 * Revision 1.3  2003/07/24 16:00:30  sasa
 * stampa podataka o bankama na narudzbenici
 *
 * Revision 1.2  2002/06/16 11:44:53  ernad
 * unos header-a
 *
 *
 */
 
function P_Ops(cId,dx,dy)
*{
local nArr
private ImeKol
private Kol

nArr:=SELECT()

O_OPS

ImeKol:={}
Kol:={}

AADD(ImeKol, { PADR("Id", 2), {|| id}, "id", {|| .t.}, {|| vpsifra(wid)} })
if ops->(FieldPOS("IDJ")<>0) 
	AADD(ImeKol, {PADR("IDJ", 3), {|| idj}, "idj"})
	AADD(ImeKol, {PADR("Kan", 3), {|| idkan}, "idkan"})
	AADD(ImeKol, {PADR("N0", 3), {|| idN0}, "idN0"})
endif
AADD(ImeKol, {PADR("Naziv", 20), {|| naz}, "naz"})

//ImeKol:={ { padr("Id",2), {|| id}, "id", {|| .t.}, {|| vpsifra(wid)} },;
//          { padr("IDJ",3), {||  idj}, "idj" }                       ,;
//          { padr("Kan",3), {||  idKan}, "idKan" }                       ,;
//          { padr("N0",3), {||  idN0}, "IdN0" }                       ,;
//          { padr("Naziv",20), {||  naz}, "naz" }                       ;
//       }

Kol:={}
FOR i:=1 TO LEN(ImeKol); AADD(Kol,i); NEXT
select (nArr)

return PostojiSifra(F_OPS,1,10,65,"Lista opcina",@cId,dx,dy)

*}


function P_Banke(cId,dx,dy)
*{
local nArr
nArr:=SELECT()
private imekol,kol

select (F_BANKE)
if (!used())
	O_BANKE
endif
select (nArr)

ImeKol:={ { padr("Id",2), {|| id}, "id", {|| .t.}, {|| vpsifra(wid)} },;
          { "Naziv", {||  naz}, "naz" },;
          { "Mjesto", {||  mjesto}, "mjesto" },;
          { "Adresa", {|| adresa}, "adresa" }}
Kol:={1,2,3,4}
return PostojiSifra(F_BANKE,1,10,55,"Lista banaka",@cId,dx,dy)
*}


