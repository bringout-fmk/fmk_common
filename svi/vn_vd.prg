#include "sc.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/svi/vn_vd.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.2 $
 * $Log: vn_vd.prg,v $
 * Revision 1.2  2002/06/16 11:44:53  ernad
 * unos header-a
 *
 *
 */
 
function P_VN(CId,dx,dy)
*{
PRIVATE ImeKol,Kol
ImeKol:={ { "ID  ",  {|| id },     "id"   , {|| .t.}, {|| vpsifra(wId)}    },;
          { "Naziv", {|| naz},     "naz"      };
        }
Kol:={1,2}
return PostojiSifra(F_TNAL,1,10,60,"Lista: Vrste naloga",@cId,dx,dy)
*}

function P_TipDok(cId,dx,dy)
*{
PRIVATE ImeKol,Kol
ImeKol:={ { "ID  ",  {|| id },     "id"   , {|| .t.}, {|| vpsifra(wId)}    },;
          { "Naziv", {|| naz},     "naz"      };
        }
Kol:={1,2}
return PostojiSifra(F_TDOK,1,10,32,"Lista: Tipovi dokumenata",@cId,dx,dy)
*}
