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


parameters v1, v2, v3, v4

local dSDat:=date()
// local cVrij:=time()

set date format to "DD.MM.YYYY"

IF v1<>NIL .and. UPPER(v1)=="/H"
  ? "SINTAKSA ZA KORISTENJE PROGRAMA:"
  ?
  ? "      vrij2k [D] [M] [G] [A]"
  ?
  ? "Znacenje parametara:"
  ?
  ? " D - broj dana za korekciju sistemskog datuma"
  ? " M - broj mjes.za korekciju sistemskog datuma"
  ? " G - broj god. za korekciju sistemskog datuma"
  ? " A - automatski rad: postavlja se D ako treba preskociti upit za novi datum"
  ?
  ? "                                     SIGMA-COM ZENICA, 27.12.1999.god."
ENDIF

if v1==NIL; v1:= 0; else; v1:=VAL(v1); endif
if v2==NIL; v2:= 0; else; v2:=VAL(v2); endif
if v3==NIL; v3:= 0; else; v3:=VAL(v3); endif
if v4==NIL; v4:="N"; endif

if YEAR(dSDat)>2030 .and. (v1<>0.or.v2<>0.or.v3<>0)
  dSDat := CTOD( PADL(LTRIM(STR(DAY(dSDat)+v1)),2,"0") + "." +;
                 PADL(LTRIM(STR(MONTH(dSDat)+v2)),2,"0") + "." +;
                 PADL(LTRIM(STR(YEAR(dSDat)+v3)),4,"0"))
endif

IF YEAR(dSDat)<1999 .or. v1<>0.or.v2<>0.or.v3<>0

 IF YEAR(dSDat)<1999
   dSDat:=CTOD("01.01.2000")
 ENDIF

 clear
 @ 2,5 SAY "........ SIGMA-COM software ........."

 @ 4, 5 SAY  "Datum:  " GET dSDat
//  @ 5, 5 SAY  "Vrijeme:" GET cVrij
 read


//   cDN:="N"
//   @ 8, 5 SAY  "Postaviti vrijeme i datum racunara:" GET cDn pict "@!" valid cdn $ "DN"
  cDN:="D"
  @ 8, 5 SAY  "Postaviti datum racunara:" GET cDn pict "@!" valid cdn $ "DN"
  read

  if cDN=="D"
   setdate(dSDat)
//    settime(cVrij)
  endif

ENDIF
