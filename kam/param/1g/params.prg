#include "\cl\sigma\fmk\kam\kam.ch"


function Pars()

O_PARAMS
private cSection:="1",cHistory:=" "; aHistory:={}
RPar("ff",@gFirma)
Rpar("fn",@gNFirma)
Rpar("nw",@gNW)
RPar("vz",@gVlZagl)
RPar("kk",@gKumKam)
RPar("do",@gDatObr)


gDirFin:=padr(gDirFin,25)
gVlZagl:=padr(gVlZagl,11)
Box(,14,60)
 set cursor on
 @ m_x+1,m_y+2 SAY "Firma" GET gFirma
 @ m_x+1,col()+2 SAY "Naziv:" get gNFirma
 @ m_x+2,m_y+2 SAY "Datum obracuna:" get gDatObr
 @ m_x+3,m_y+2 SAY "Direktorij FIN - kumulativ:" GET gDirFin

 @ m_x+5,m_y+2 SAY "Naziv fajla zaglavlja (prazno bez zaglavlja)" GET gVlZagl ;
                valid V_VZagl()

 @ m_x+7,m_y+2 SAY "Prikazivati kolonu 'kumulativ kamate' (D/N) ?" GET gKumKam VALID gKumKam$"DN" PICT "@!"

 @ m_x+14,m_y+2 SAY "Novi korisnicki interfejs D/N" GET gNW valid gNW $ "DN" pict "@!"
 read
BoxC()

gDirFin:=trim(gDirFin)
gVlZagl:=trim(gVlZagl)

if lastkey()<>K_ESC
 Wpar("df",gDirFin)
 WPar("ff",gFirma)
 Wpar("fn",gNFirma)
 Wpar("nw",gNW)
 WPar("vz",gVlZagl)
 WPar("kk",gKumKam)
 WPar("do",gDatObr)
 select params; use
endif
closeret
