#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/kalks/1g/kalks.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.2 $
 * $Log: kalks.prg,v $
 * Revision 1.2  2002/06/19 13:57:53  mirsad
 * no message
 *
 *
 */
 

/*! \file fmk/kalk/kalks/1g/kalks.prg
 *  \brief Rad sa pomocnom izvjestajnom tabelom KALKS
 */


/*! \fn KalksInit()
 *  \brief Formira pomocnu izvjestajnu tabelu KALKS
 */

function KalksInit()
*{
if gKalks
O_KALKS
if reccount()=0
  select kalks; set order to 0
  showkorner(0,100)
  MsgO("Sacekajte ... azuriram KALKS ")
   AP52 FROM (KUMPATH+"KALK")  WHILE  {|| showkorner(1,100)}
  MsgC()
endif
use
endif
return
*}

