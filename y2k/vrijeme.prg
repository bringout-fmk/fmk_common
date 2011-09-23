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


local dSDat:=date()
local cVrij:=time()

set date format to "DD.MM.YYYY"

clear
@ 2,5 SAY "........ SIGMA-COM software ........."

 @ 4, 5 SAY  "Datum:  " GET dSDat
 @ 5, 5 SAY  "Vrijeme:" GET cVrij
 read


  cDN:="N"
  @ 8, 5 SAY  "Postaviti vrijeme i datum racunara:" GET cDn pict "@!" valid cdn $ "DN"
  read

  if cDN=="D"
   setdate(dSDat)
   settime(cVrij)
  endif
