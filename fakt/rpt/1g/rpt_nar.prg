#include "\cl\sigma\fmk\fakt\fakt.ch"



function Mnu_Narudzba()
*{
local cNarFirma:=gFirma
local cNarIdVD:=SPACE(2)
local cNarBrDok:=SPACE(8)
local cPripr:="N"
local lPripr:=.f.

Box(,5,70)
	@ m_x+1, m_y+2 SAY "Stampa narudzbenice:                 "
	@ m_x+2, m_y+2 SAY "-------------------------------------"
	@ m_x+3, m_y+2 SAY "Na osnovu dokumenta u pripremi" GET cPripr VALID cPripr$"DN" PICT "@!"
	read
	if cPripr=="N"
		@ m_x+3, m_y+2 SAY SPACE(60)
		@ m_x+4, m_y+2 SAY "Narudzbenica na osnovu dokumenta: "
		@ m_x+5, m_y+2 SAY "" GET cNarFirma 
		@ m_x+5, m_y+6 SAY "-" GET cNarIdVD
		@ m_x+5, m_y+11 SAY "-" GET cNarBrDok
	endif
	read
BoxC()

if LastKey()==K_ESC
	return
endif
if cPripr=="D"
	lPripr:=.t.
endif

Rpt_Narudzbenica(cNarFirma, cNarIdVD, cNarBrDok, lPripr)

return
*}


function Rpt_Narudzbenica(cIdFirma, cIdVD, cBrDok, lPriprema)
*{
private cComArgs:=""


cFmkNETExec:="start sc.fmk.winui.exe "
cNarudzbaArgs:=" /FAKT /NARUDZBA "
cDokArgs:="/IdFirma=" + cIdFirma + " /IdTipDok=" + cIdVD + " /BrNal=" + cBrDok

cComArgs+=cFmkNETExec + cNarudzbaArgs

if lPriprema 
	cComArgs+="/IdFirma=PRIPR" 
endif	

if !lPriprema
	cComArgs+=cDokArgs 
endif

run &cComArgs

return
*}







