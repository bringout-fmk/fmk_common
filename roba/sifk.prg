#include "sc.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/roba/sifk.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.2 $
 * $Log: sifk.prg,v $
 * Revision 1.2  2002/06/16 14:16:54  ernad
 * no message
 *
 *
 */
 

/*! \fn SifkFill(cSifk,cSifv,cSifrarnik,cIDSif)
  * \brief  SifkFill Napuni pomocne tabele (radi prenosa) sifk, sifv
  * \param cSIFK ime sifk tabele (npr PRIVPATH+"_SIFK")
  * \param cSifV ime sifv tabele
  * \param cSifrarnik sifrarnik (npr "ROBA")
  */
  
function SifkFill(cSifk,cSifv,cSifrarnik,cIDSif)
*{
PushWa()

use (cSifK) new   alias _SIFK
use (cSifV) new   alias _SIFV

select _SIFK
if reccount2()==0  // nisu upisane karakteristike, ovo se radi samo jednom
select sifk; set order to tag "ID";  seek padr(cSifrarnik,8)
// uzmi iz sifk sve karakteristike ID="ROBA"

do while !eof() .and. ID=padr(cSifrarnik,8)
   Scatter()
   select _Sifk; append blank
   Gather()
   select sifK
   skip
enddo
endif // reccount()

// uzmi iz sifv sve one kod kojih je ID=ROBA, idsif=2MON0002

select sifv; set order to tag "IDIDSIF"
seek padr(cSifrarnik,8) + cidsif
do while !eof() .and. ID=padr(cSifrarnik,8) .and. idsif= padr(cidsif,len(cIdSif))
 Scatter()
 select _SifV; append blank
 Gather()
 select sifv
 skip
enddo

select _sifv
use
select _sifk
use

PopWa()

return
*}

/*!
 @function   SifkOsv
 @abstract   Osvjezi tabele SIFK, SIFV iz pomocnih tabela (uobicajeno _SIFK, SIFV)
 @discussion -
 @param cSIFK ime sifk tabele (npr PRIVPATH+"_SIFK")
 @param cSifV ime sifv tabele
 @param cSifrarnik sifrarnik (npr "ROBA")
*/

function SifkOsv(cSifk,cSifv,cSifrarnik,cIDSif)
*{
PushWa()

use (cSifK) new   alias _SIFK
use (cSifV) new   alias _SIFV

select sifk; set order to tag "ID2" // id + oznaka
select _sifk
do while !eof()
 scatter()
 select sifk; seek _SIFK->(ID+OZNAKA)
 if !found()
  append blank
 endif
 Gather()
 select _SIFK
 skip
enddo

select sifV; set order to tag "ID"  //"ID","id+oznaka+IdSif",SIFPATH+"SIFV"
select _SIFV
do while !eof()
 scatter()
 select SIFV; seek _SIFV->(ID+OZNAKA+IDSIF)
 if !found()
  append blank
 endif
 Gather()
 select _SIFV
 skip
enddo

select _SIFK; use
select _SIFV; use

PopWa()

return
*}
