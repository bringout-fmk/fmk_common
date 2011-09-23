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


#include "sc.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/pi/db_cre.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.2 $
 * $Log: db_cre.prg,v $
 * Revision 1.2  2002/06/16 14:16:43  ernad
 * ciscenja ...
 *
 * Revision 1.1  2002/06/16 11:42:41  ernad
 *
 *
 * komponenta pi - proizvoljni izvjestaji
 *
 *
 */

/* \brief CreFmkPi()
 * \fn Kreiraj tabele proizvoljnih izvjestaja 
 */
 
function CreFmkPi()
*{
local cImeDBF

cImeDBF:=ToUnix(KUMPATH+"izvje.dbf")

if !file(cImeDBF)
   aDBf:={}
   AADD(aDBf,{ 'ID'      , 'C' ,   2 ,  0 })
   AADD(aDBf,{ 'NAZ'     , 'C' ,  50 ,  0 })
   AADD(aDBf,{ 'USLOV'   , 'C' ,  80 ,  0 })
   AADD(aDBf,{ 'KPOLJE'  , 'C' ,  50 ,  0 })
   AADD(aDBf,{ 'IMEKP'   , 'C' ,  10 ,  0 })
   AADD(aDBf,{ 'KSIF'    , 'C' ,  50 ,  0 })
   AADD(aDBf,{ 'KBAZA'   , 'C' ,  50 ,  0 })
   AADD(aDBf,{ 'KINDEKS' , 'C' ,  80 ,  0 })
   AADD(aDBf,{ 'TIPTAB'  , 'C' ,   1 ,  0 })
   DBCREATE2(cImeDBF,aDbf)
endif
CREATE_INDEX("ID","id",cImeDBF)

cImeDBF:=ToUnix(KUMPATH+"koliz.dbf")
if !file(cImeDBF)
   aDBf:={}
   AADD(aDBf,{ 'ID'      , 'C' ,   2 ,  0 })
   AADD(aDBf,{ 'NAZ'     , 'C' ,  20 ,  0 })
   AADD(aDBf,{ 'RBR'     , 'N' ,   2 ,  0 })
   AADD(aDBf,{ 'FORMULA' , 'C' , 150 ,  0 })
   AADD(aDBf,{ 'TIP'     , 'C' ,   2 ,  0 })
   AADD(aDBf,{ 'SIRINA'  , 'N' ,   3 ,  0 })
   AADD(aDBf,{ 'DECIMALE', 'N' ,   1 ,  0 })
   AADD(aDBf,{ 'SUMIRATI', 'C' ,   1 ,  0 })
   AADD(aDBf,{ 'K1'      , 'C' ,   1 ,  0 })
   AADD(aDBf,{ 'K2'      , 'C' ,   2 ,  0 })
   AADD(aDBf,{ 'N1'      , 'C' ,   1 ,  0 })
   AADD(aDBf,{ 'N2'      , 'C' ,   2 ,  0 })
   AADD(aDBf,{ 'KUSLOV'  , 'C' , 100 ,  0 })
   AADD(aDBf,{ 'SIZRAZ'  , 'C' , 100 ,  0 })
   DBCREATE2(cImeDBF,aDbf)
endif
CREATE_INDEX("ID","id"         ,cImeDBF)
CREATE_INDEX("1" ,"STR(rbr,2)" ,cImeDBF)

cImeDBF:=ToUnix(KUMPATH+"zagli.dbf")
if !file(cImeDBF)
   aDBf:={}
   AADD(aDBf,{ 'ID'      , 'C' ,   2 ,  0 })
   AADD(aDBf,{ 'x1'      , 'N' ,   3 ,  0 })
   AADD(aDBf,{ 'y1'      , 'N' ,   3 ,  0 })
   AADD(aDBf,{ 'IZRAZ'   , 'C' , 100 ,  0 })
   DBCREATE2(cImeDBF,aDbf)
endif
CREATE_INDEX( "ID", "id"                  , cImeDBF)
CREATE_INDEX( "1" , "STR(x1,3)+STR(y1,3)" , cImeDBF)
cImeDBF:=ToUnix(KUMPATH+"koniz.dbf")
if !file(cImeDBF)
   aDBf:={}
   AADD(aDBf,{ 'IZV'     , 'C' ,   2 ,  0 })
   AADD(aDBf,{ 'ID'      , 'C' ,  20 ,  0 })
   AADD(aDBf,{ 'ID2'     , 'C' ,  20 ,  0 })
   AADD(aDBf,{ 'OPIS'    , 'C' ,  57 ,  0 })
   AADD(aDBf,{ 'RI'      , 'N' ,   4 ,  0 })
   AADD(aDBf,{ 'FI'      , 'C' ,  80 ,  0 })
   AADD(aDBf,{ 'FI2'     , 'C' ,  80 ,  0 })
   AADD(aDBf,{ 'K'       , 'C' ,   2 ,  0 })
   AADD(aDBf,{ 'K2'      , 'C' ,   2 ,  0 })
   AADD(aDBf,{ 'PREDZN'  , 'N' ,   2 ,  0 })
   AADD(aDBf,{ 'PREDZN2' , 'N' ,   2 ,  0 })
   AADD(aDBf,{ 'PODVUCI' , 'C' ,   1 ,  0 })
   AADD(aDbf,{ "K1"      , "C" ,   1 ,  0 })          //
   AADD(aDbf,{ "U1"      , "C" ,   3 ,  0 })          // npr. >0 ili <0
   DBCREATE2(cImeDBF,aDbf)
endif
CREATE_INDEX("ID","id", cImeDBF)
CREATE_INDEX("1" ,"izv+STR(ri,4)" , cImeDBF)

return
*}
