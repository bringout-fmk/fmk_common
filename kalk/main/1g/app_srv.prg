#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/main/1g/app_srv.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.2 $
 * $Log: app_srv.prg,v $
 * Revision 1.2  2002/06/24 07:34:41  mirsad
 * no message
 *
 *
 */
 

/*! \file fmk/kalk/main/1g/app_srv.prg
 *  \brief
 */


/*! \fn BatchObrada(p3,p4,p5,p6,p7)
 *  \param p3 -
 *  \param p4 -
 *  \param p5 -
 *  \param p6 -
 *  \param p7 -
 *  \brief
 */

// parametri pri pozivu programa 3-7 (parametri 1,2 su Korisnik+Sifra)
// pozivom KALK 11 11 /B se poziva ova funkcija.
// Otvara se fajl PRIVPATH+para.txt i citaju parametri
 
function BatchObrada(p3,p4,p5,p6,p7)
*{
if mpar37("/B",p3,p4,p5,p6,p7)
  // sada cemo staviti da je batch stampa azuriranog dokumenta
  KEYBOARD Chr(K_ENTER) + Chr(K_ESC)
  nH:=FOPEN(PRIVPATH+"para.txt")
  cKom:=FReadLn(nH)
  cKom:=left(cKom, (len(cKom) -2 ))
  if alltrim(cKom)="STAZUR"
    cBroj:=FreadLn(nH)
    cBroj:=left(cBroj, (len(cBroj) -2 ))
    FClose(nH)
    StKalk(.t.,cBroj)
  else
    FClose(nH)
  endif
  goModul:quit()
endif
return
*}

