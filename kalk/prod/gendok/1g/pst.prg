#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/prod/gendok/1g/pst.prg,v $
 * $Author: sasa $ 
 * $Revision: 1.5 $
 * $Log: pst.prg,v $
 * Revision 1.5  2003/01/03 15:52:47  sasa
 * ispravka pocetnog stanja
 *
 * Revision 1.4  2003/01/03 15:15:27  sasa
 * ispravka pocetnog stanja
 *
 * Revision 1.3  2003/01/03 11:06:34  sasa
 * Ispravka greske sa pocetnim stanjem gSezona->goModul:oDataBase:cSezona
 *
 * Revision 1.2  2002/06/21 09:24:55  mirsad
 * no message
 *
 *
 */
 

/*! \file fmk/kalk/prod/gendok/1g/pst.prg
 *  \brief Generisanje dokumenta pocetnog stanja prodavnice
 */


/*! \fn PocStProd()
 *  \brief Generisanje dokumenta pocetnog stanja prodavnice
 */

function PocStProd()
*{
LLP(.t.)
if !empty(goModul:oDataBase:cSezonDir) .and. Pitanje(,"Prebaciti dokument u radno podrucje","D")=="D"
	O_PRIPRRP
          O_PRIPR
          if reccount2()<>0
           select priprrp
           append from pripr
           select pripr; zap
           close all
           if Pitanje(,"Prebaciti se na rad sa radnim podrucjem ?","D")=="D"
               URadPodr()
           endif
          endif
endif
close all

return nil
*}

