#include "\dev\fmk\ld\ld.ch"

function ParObracun()
*{

O_RJ
O_PARAMS

select rj

Box(,3+IF(lViseObr,1,0),50)
	set cursor on
	@ m_x+1,m_y+2 SAY "Radna jedinica" GET gRJ  valid P_Rj(@gRj) pict "@!"
	@ m_x+2,m_y+2 SAY "Mjesec        " GET gMjesec pict "99"
 	@ m_x+3,m_y+2 SAY "Godina        " GET gGodina pict "9999"
 	if lViseObr
   		@ m_x+4, m_y+2 SAY "Obracun       " GET gObracun WHEN HelpObr(.f.,gObracun) VALID ValObr(.f.,gObracun)
 	endif
 	read
 	clvbox()
BoxC()

if (LASTKEY()<>K_ESC)
	select params
 	Wpar("rj",@gRJ)
 	Wpar("mj",@gMjesec)
 	Wpar("go",@gGodina)
 	Wpar("ob",@gObracun)
 	select params
	use
endif

if gZastitaObracuna=="D"
	IspisiStatusObracuna(gRj,gGodina,gMjesec)
endif

return
*}




function IspisiStatusObracuna(cRj,nGodina,nMjesec)
*{

if GetObrStatus(cRj,nGodina,nMjesec)$"ZX"
	cStatusObracuna:="Obracun zakljucen !!!    "
	cClr:="W/R"
endif

if GetObrStatus(cRj,nGodina,nMjesec)$"UP"
	cStatusObracuna:="Obracun otvoren          "
	cClr:="W/B"
endif

if GetObrStatus(cRj,nGodina,nMjesec)=="N"
	cStatusObracuna:="Nema otvorenog obracuna !"
	cClr:="W/R"
endif

@ 24,1 SAY cStatusObracuna COLOR cClr

return
*}


