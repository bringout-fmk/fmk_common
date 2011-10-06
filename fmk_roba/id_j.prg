/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "fmk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/roba/id_j.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.2 $
 * $Log: id_j.prg,v $
 * Revision 1.2  2002/06/16 14:16:54  ernad
 * no message
 *
 *
 */
 
function OsvjeziIDj()
*{
if pitanje(,"Osvjeziti FAKT javnim siframa ....","N")=="N"
  return
endif

select 0
if gModul=="FAKT"
  use (KUMPATH+"FAKT")
elseif gModul=="KALK"
  use (KUMPATH+"KALK")
endif
nKumArea:=SELECT()

O_ROBA
set order to tag "ID"
O_SIFK
O_SIFV
select fakt
set order to
go top
MsgO("Osvjezavam promjene sifarskog sistema u prometu ...")
nCount:=0
do while !eof()
  select roba
  hseek (nKumArea)->idroba
  if (nKumArea)->idroba_J <> roba->id_j
    select fakt
    replace IdRoba_J with roba->ID_J
  endif
  select fakt
  @ m_x+3,m_y+3 SAY str(++ncount,3)
  skip
enddo
MsgC()

if pitanje(,"Postaviti javne sifre za id_j prazno ?","N")=="D"
  select roba ; set order to
  go top
  do while !eof()
    if empty(id_j)
       replace id_j with id
    endif
    skip
  enddo
endif

CLOSERET
*}

// prikaz idroba
// nalazim se u tabeli koja sadrzi IDROBA, IDROBA_J
function StIdROBA()
*{
static cPrikIdRoba:=""

if cPrikIdroba == ""
  cPrikIdRoba:=IzFmkIni('SIFROBA','PrikID','ID',SIFPATH)
endif

if cPrikIdRoba="ID_J"
  return IDROBA_J
else
  return IDROBA
endif
return
*}
