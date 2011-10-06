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


// --------------------------------------------------------------------
// tekuci parametri ugovora
// --------------------------------------------------------------------
function DFTParUg(lIni)
local GetList:={}

if lIni == nil
	lIni:=.f.
endif

O_PARAMS
private cSection:="2"
private cHistory:=" "
private aHistory:={}

if !lIni
	private DFTkolicina:=1
    	private DFTidroba:=PADR("",10)
    	private DFTvrsta:="1"
    	private DFTidtipdok:="10"
    	private DFTdindem:="KM "
    	private DFTidtxt:="10"
    	private DFTzaokr:=2
    	private DFTiddodtxt:="  "
	private gGenUgV2:="1"
	private gFinKPath:=SPACE(50)
endif

RPar("01", @DFTkolicina)
RPar("02", @DFTidroba)
RPar("03", @DFTvrsta)
RPar("04", @DFTidtipdok)
RPar("05", @DFTdindem)
RPar("06", @DFTidtxt)
RPar("07", @DFTzaokr)
RPar("08", @DFTiddodtxt)
RPar("09", @gGenUgV2)
RPar("10", @gFinKPath)

if !lIni
	Box(,11,75)
     	@ m_x+ 0,m_y+23 SAY "TEKUCI PODACI ZA NOVE UGOVORE"
     	@ m_x+ 2,m_y+ 2 SAY PADL("Artikal" , 20) GET DFTidroba VALID EMPTY(DFTidroba) .or. P_Roba(@DFTidroba,2,28) PICT "@!"
     	@ m_x+ 3,m_y+ 2 SAY PADL("Kolicina", 20) GET DFTkolicina PICT pickol
     	@ m_x+ 4,m_y+ 2 SAY PADL("Tip ug.(1/2/G)", 20) GET DFTvrsta VALID DFTvrsta$"12G"
     	@ m_x+ 5,m_y+ 2 SAY PADL("Tip dokumenta", 20) GET DFTidtipdok
     	@ m_x+ 6,m_y+ 2 SAY PADL("Valuta", 20) GET DFTdindem PICT "@!"
     	@ m_x+ 7,m_y+ 2 SAY PADL("Napomena 1", 20) GET DFTidtxt VALID P_FTXT(@DFTidtxt)
     	@ m_x+ 8,m_y+ 2 SAY PADL("Napomena 2", 20) GET DFTiddodtxt VALID P_FTXT(@DFTiddodtxt)
     	@ m_x+ 9,m_y+ 2 SAY PADL("Zaokruzenje", 20) GET DFTzaokr PICT "9"
     	@ m_x+10,m_y+ 2 SAY PADL("gen.ug. ver 1/2", 20) GET gGenUgV2 PICT "@!" VALID gGenUgV2 $ "12"
     	@ m_x+11,m_y+ 2 SAY PADL("Fin KUMPATH", 20) GET gFinKPath PICT "@!"
     	READ
    	BoxC()

	// snimi promjene
    	if LASTKEY()!=K_ESC
      		WPar("01", DFTkolicina)
      		WPar("02", DFTidroba)
      		WPar("03", DFTvrsta)
      		WPar("04", DFTidtipdok)
      		WPar("05", DFTdindem)
      		WPar("06", DFTidtxt)
      		WPar("07", DFTzaokr)
      		WPar("08", DFTiddodtxt)
		WPar("09", gGenUgV2)
		WPar("10", gFinKPath)
    	endif
    
endif
use

return



