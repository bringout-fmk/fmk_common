#include "sc.ch"


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
    	endif
    
endif
use

return



