#include "sc.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/svi/konto.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.6 $
 * $Log: konto.prg,v $
 * Revision 1.6  2004/03/16 15:15:50  sasavranic
 * no message
 *
 * Revision 1.5  2004/03/15 16:17:09  sasavranic
 * Uvedena funkcija GetNameFromKonto(cIdKonto) koja vraca naziv konta po zadatom id-u
 *
 * Revision 1.4  2004/03/02 18:37:28  sasavranic
 * no message
 *
 * Revision 1.3  2002/06/16 11:44:53  ernad
 * unos header-a
 *
 *
 */
 

/*! \fn P_Konto(cId,dx,dy)
 *  \brief Otvaranje sifrarnika konta
 *  \param cId
 *  \param dx
 *  \param dy
 */
function P_Konto(cId,dx,dy)
*{
PRIVATE ImeKol,Kol
ImeKol:={ ;
          { "ID  ",  {|| id },     "id"  , {|| .t.}, {|| vpsifra(wId)}     },;
          { "Naziv", {|| naz},     "naz"      };
        }
Kol:={1,2}
return PostojiSifra(F_KONTO,1,10,60,"Lista: Konta",@cId,dx,dy)
*}


/*! \fn GetNameFromKonto(cIdKonto)
 *  \brief Funkcija vraca vrijednost polja naziv po zadatom idkonto
 *  \param cIdKonto - Oznaka konta koji se trazi
 */
function GetNameFromKonto(cIdKonto)
*{
local nArr
nArr:=SELECT()
select konto
hseek cIdKonto
cRet:=ALLTRIM(field->naz)
select (nArr)
return cRet
*}

