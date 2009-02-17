#include "ld.ch"

// ------------------------------------------------
// specifikacija place, ostali samostalni 
// ------------------------------------------------
function SpecPlU()
local GetList:={}
local aPom:={}
local i:=0
local j:=0
local k:=0
local nPom
local uNaRuke
local aOps:={}
private aSpec:={}
private gPici:="9,999,999,999,999,999"+IF(gZaok>0,PADR(".",gZaok+1,"9"),"")
private gPici2:="9,999,999,999,999,999"+IF(gZaok2>0,PADR(".",gZaok2+1,"9"),"")
private gPici3:="999,999,999,999.99"

cIdRJ:="  "
qqIDRJ:=""
qqOpSt:=""

nPorOlaksice:=0
nBrutoOsnova:=0
nBrutoOsBenef := 0
nPojBrOsn := 0
nPojBrBenef := 0
nPorOsnovica:=0
uNaRuke := 0

// prvi dan mjeseca
nDanOd := getfday( gMjesec )
nMjesecOd:=gMjesec
nGodinaOd:=gGodina
// posljednji dan mjeseca
nDanDo := getlday( gMjesec )
nMjesecDo:=gMjesec
nGodinaDo:=gGodina

// varijable izvjestaja
nMjesec := gMjesec
nGodina := gGodina

cObracun:=gObracun

cDopr1:="10"
cDopr2:="11"

cFirmNaz:=SPACE(35)
cFirmAdresa:=SPACE(35)
cFirmOpc:=SPACE(35)  
cFirmVD:=SPACE(50)  

OSpecif()

select params

private cSection:="U"
private cHistory:=" "
private aHistory:={}

RPar("i1",@cFirmNaz)
cFirmNaz := PADR(cFirmNaz, 35)
RPar("i2",@cFirmAdresa)  
cFirmAdresa := PADR(cFirmAdresa, 35)
RPar("i3",@cFirmOpc)
cFirmOpc := PADR(cFirmOpc, 35)
RPar("i0",@cFirmVD)
cFirmVD := PADR(cFirmVD, 50)
RPar("d1",@cDopr1)
RPar("d2",@cDopr2)
RPar("qj",@qqIdRJ)
RPar("st",@qqOpSt)

qqIdRj:=PadR(qqIdRj,80) 
qqOpSt:=PadR(qqOpSt,80)

cMatBr:=IzFmkIni("Specif","MatBr","--",KUMPATH)
cMatBR:=padr(cMatBr,13) 
dDatIspl := date()

do while .t.
	
	Box(,11,75)
     		
		@ m_x+ 1,m_y+ 2 SAY "Radna jedinica (prazno-sve): " ;
			GET qqIdRJ PICT "@!S15"

		@ m_x+ 2,m_y+ 2 SAY "Opstina stanov.(prazno-sve): " ;
		 	GET qqOpSt PICT "@!S20"
		
		if lViseObr
       			@ m_x+ 2,col()+1 SAY "Obr.:" GET cObracun ;
				WHEN HelpObr(.t.,cObracun) ;
				VALID ValObr(.t.,cObracun)
     		endif
     	
     		@ m_x+ 3,m_y+ 2 SAY "Period od:" GET nDanOd pict "99"
     		@ m_x+ 3,col()+1 SAY "/" GET nMjesecOd pict "99"
     		@ m_x+ 3,col()+1 SAY "/" GET nGodinaOd pict "9999"
     		@ m_x+ 3,col()+1 SAY "do:" GET nDanDo pict "99"
     		@ m_x+ 3,col()+1 SAY "/" GET nMjesecDo pict "99"
     		@ m_x+ 3,col()+1 SAY "/" GET nGodinaDo pict "9999"
     	
		
     		@ m_x+ 4,m_y+ 2 SAY " Naziv: " GET cFirmNaz
     		@ m_x+ 5,m_y+ 2 SAY "Adresa: " GET cFirmAdresa
     		@ m_x+ 6,m_y+ 2 SAY "Opcina: " GET cFirmOpc
     		@ m_x+ 7,m_y+ 2 SAY "Vrsta djelatnosti: " GET cFirmVD
     		
     		@ m_x+ 4,m_y+ 52 SAY "ID.broj :" GET cMatBR
     		@ m_x+ 5,m_y+ 52 SAY "Dat.ispl:" GET dDatIspl
     		
		
     		@ m_x+9,m_y+ 2 SAY "Doprinos zdravstvo (iz)" GET cDopr1
     		@ m_x+10,m_y+ 2 SAY "     Doprinos pio (na)" GET cDopr2
		
		read
     		clvbox()
     		ESC_BCR
   	BoxC()
   	
	aUslRJ:=Parsiraj(qqIdRj,"IDRJ")
   	aUslOpSt:=Parsiraj(qqOpSt,"IDOPSST")
   	if (aUslRJ<>nil .and. aUslOpSt<>nil)
		EXIT
	endif
enddo


WPar("i1",cFirmNaz)
WPar("i2",cFirmAdresa)
WPar("i3",cFirmOpc)
WPar("i0",cFirmVD)
WPar("d1",cDopr1)
WPar("d2",cDopr2)
qqIdRj:=TRIM(qqIdRj)
qqOpSt:=TRIM(qqOpSt)
WPar("qj",qqIdRJ)
WPar("st",qqOpSt)

select params
use

PoDoIzSez(nGodina,nMjesec)

// fmk.ini parametri
cPom:=KUMPATH+"fmk.ini"
UzmiIzIni(cPom,'Specif',"MatBr",cMatBr,'WRITE')

cIniName:=EXEPATH+'proizvj.ini'

UzmiIzIni(cIniName,'Varijable',"NAZ", cFirmNaz ,'WRITE')
UzmiIzIni(cIniName,'Varijable',"ADRESA", cFirmAdresa ,'WRITE')
UzmiIzIni(cIniName,'Varijable',"OPCINA", cFirmOpc ,'WRITE')
UzmiIzIni(cIniName,'Varijable',"VRDJ", cFirmVD ,'WRITE')

UzmiIzIni(cIniName,'Varijable',"GODOD",Razrijedi(str(nGodinaOd,4)),'WRITE')
UzmiIzIni(cIniName,'Varijable',"GODDO",Razrijedi(str(nGodinaDo,4)),'WRITE')

UzmiIzIni(cIniName,'Varijable',"MJOD",Razrijedi(strtran(str(nMjesecOd,2)," ","0")),'WRITE')
UzmiIzIni(cIniName,'Varijable',"MJDO",Razrijedi(strtran(str(nMjesecDo,2)," ","0")),'WRITE')

UzmiIzIni(cIniName,'Varijable',"DANOD",Razrijedi(strtran(str(nDanOd,2)," ","0")),'WRITE')
UzmiIzIni(cIniName,'Varijable',"DANDO",Razrijedi(strtran(str(nDanDo,2)," ","0")),'WRITE')

UzmiIzIni(cIniName,'Varijable',"MATBR",Razrijedi(cMatBR),'WRITE')
UzmiIzIni(cIniName,'Varijable',"DATISPL",DTOC(dDatIspl),'WRITE')

if lViseObr
	cObracun:=TRIM(cObracun)
else
	cObracun:=""
endif

ParObr(nMjesec,cObracun,LEFT(qqIdRJ,2))

SELECT LD
SET ORDER TO TAG (TagVO("2"))

PRIVATE cFilt:=".t."

IF !EMPTY(qqIdRJ)
   cFilt += ( ".and." + aUslRJ )
ENDIF

IF !EMPTY(cObracun)
   cFilt += ( ".and. OBR==" + cm2str(cObracun) )
ENDIF

SET FILTER TO &cFilt

GO TOP
HSEEK STR(nGodina,4)+STR(nMjesec,2)
 
nUNeto:=0
nPorNaPlatu:=0
nKoefLO := 0
nURadnika:=0
nULicOdbitak := 0
nUPorOsn := 0
nPovD1X := 0
nPovD2X := 0
nDrD1X := 0
nDrD2X := 0
nTrosk := 0
nUTrosk := 0
nBO := 0
nUBrSaTr := 0
nUkupno := 0
nUOsnDr := 0
nUOsnPov := 0
nBrOsnPov := 0
nBrOsnDr := 0
nPNaPlPov := 0
nPNaPlDr := 0

DO WHILE STR(nGodina,4)+STR(nMjesec,2)==STR(godina,4)+STR(mjesec,2)
   
	SELECT RADN
   	HSEEK LD->idradn
   	cRTR := g_tip_rada(ld->idradn, ld->idrj)
   
   	// ugovor o djelu, aut.honorar i predsjednici
   	if !(cRTR $ "U#A#P")
		select ld
		skip
		loop
	endif

	nRSpr_koef := 0
	nTrosk := 0

	// da li koristi troskove
	cKTrosk := radn->trosk
	
   	SELECT LD
   
   	IF ! ( RADN->(&aUslOpSt) )
     		SKIP 1
     		LOOP
   	ENDIF	
  
   	nKoefLO := ld->ulicodb
   	nULicOdbitak += nKoefLO
 
	nUNeto += ld->uneto
 
	nBrSaTr := bruto_osn( ld->uneto, cRTR, nKoefLO, nRSpr_koef, cKTrosk )
 	
	// samo za povremene
	if cRTR $ "A#U"
		nUBrSaTr += nBrSaTr
	endif

	nPTrosk := 0

	if cRTR == "U"
		nPTrosk := gUgTrosk 
	elseif cRTR == "A"
		nPTrosk := gAHTrosk
	else
		nPTrosk := 0
	endif

	// ako netrebaju troskovi onda ih nema
	if cKTrosk == "N"
		nPTrosk := 0
	endif

	if cRTR $ "A#U"
		// troskovi su ?
		nTrosk := nBrSaTr * (nPTrosk / 100)
		nUTrosk += nTrosk
	endif

	// prava bruto osnova bez troskova je ?
	nBO := nBrSaTr - nTrosk

 	if cRTR $ "A#U"
		nBrOsnPov += nBO
	else
		nBrOsnDr += nBO
	endif

	if cRTR $ "A#U"
		// prihodi
		nPom := nUBrSaTr
 		UzmiIzIni(cIniName,'Varijable','POVPRIH',FormNum2(nPom,16,gPici2),'WRITE')

		// rashodi
		nPom := nUTrosk
 		UzmiIzIni(cIniName,'Varijable','POVRASH',FormNum2(nPom,16,gPici2),'WRITE')

		// dohodak
		nPom := nBrOsnPov
 		UzmiIzIni(cIniName,'Varijable','POVDOH',FormNum2(nPom,16,gPici2),'WRITE')
	
	else
		nPom := nBrOsnDr
 		UzmiIzIni(cIniName,'Varijable','DRDOH',FormNum2(nPom,16,gPici2),'WRITE')
	endif

 	SELECT DOPR
 	GO TOP
 
 	DO WHILE !EOF()
   
   		IF DOPR->poopst=="1" 
     
     			nBOO:=0
     
     			FOR i:=1 TO LEN(aOps)
       				IF ! ( DOPR->id $ aOps[i,2] )
         				nBOO += aOps[i,3]
       				ENDIF
     			NEXT
     			nBOO := bruto_osn( nBOO, cRTR, nKoefLO )
   		ELSE
     			if cRTR $ "A#U"
				nBOO := nBrOsnPov
			else
				nBOO := nBrOsnDr
			endif
   		ENDIF

		SKIP 1
	ENDDO

	if cRTR == "U"
 		nkD1X := get_dopr(cDopr1, "U")
 		nkD2X := get_dopr(cDopr2, "U")
	elseif cRTR == "A"
		nkD1X := get_dopr(cDopr1, "A")
 		nkD2X := get_dopr(cDopr2, "A")
	else
		nkD1X := get_dopr(cDopr1, "P")
 		nkD2X := get_dopr(cDopr2, "P")
	endif

	if cRTR $ "A#U"
		// povremeni poslovi doprinosi
		nPovD1X := round2(nBrOsnPov * nkD1X / 100, gZaok2)
 		nPovD2X := round2(nBrOsnPov * nkD2X / 100, gZaok2)
	else
		// ostali poslovi doprinosi
		nDrD1X := round2(nBrOsnDr * nkD1X / 100, gZaok2)
 		nDrD2X := round2(nBrOsnDr * nkD2X / 100, gZaok2)
	endif
		
	nPojD1X := round2(nBO * nkD1X / 100, gZaok2)

	// upisi povremeni poslovi doprinosi
 	nPom:=nPovD1X
 	UzmiIzIni(cIniName,'Varijable','POVDZ', FormNum2(nPom,16,gPici2), 'WRITE')
 	nPom:=nPovD2X
 	UzmiIzIni(cIniName,'Varijable','POVDP', FormNum2(nPom,16,gPici2), 'WRITE')
	
	// upisi ostali samostalni rad - doprinosi
	nPom:=nDrD1X
 	UzmiIzIni(cIniName,'Varijable','DRDZDR', FormNum2(nPom,16,gPici2), 'WRITE')
 	nPom:=nDrD2X
 	UzmiIzIni(cIniName,'Varijable','DRDPIO', FormNum2(nPom,16,gPici2), 'WRITE')

 	// ukupno dopr.zdravstvo
	nPom:=nPovD1X+nDrD1X
 	UzmiIzIni(cIniName,'Varijable','DZDRU', FormNum2(nPom,16,gPici2), 'WRITE')
	// ukupno dopr.pio
	nPom:=nPovD2X+nDrD2X
 	UzmiIzIni(cIniName,'Varijable','DPIOU', FormNum2(nPom,16,gPici2), 'WRITE')

	if cRTR $ "A#U"
		nOsnPov := ( nBO - nPojD1X )
		nUOsnPov += nOsnPov
	else
 		nOsnDr := ( nBO - nPojD1X )
		nUOsnDr += nOsnDr
	endif

 	
 	//porez na platu i ostali porez
 	SELECT POR
 	GO TOP

 	DO WHILE !EOF()

     		PozicOps(POR->poopst)
     
     		IF !ImaUOp("POR",POR->id)
       			SKIP 1
       			LOOP
     		ENDIF
     		
		IF por->por_tip == "B"
       			if cRTR $ "A#U"
				nPNaPlPov  += POR->iznos * MAX(nOsnPov,PAROBR->prosld*gPDLimit/100) / 100
     			else
				nPNaPlDr  += POR->iznos * MAX(nOsnDr,PAROBR->prosld*gPDLimit/100) / 100
			endif
		ENDIF
     		SKIP 1
   	ENDDO

   	SELECT LD
   
   	nURadnika++
   
   	SKIP 1

ENDDO

nPNaPlPov := round2( nPNaPlPov, gZaok2 )
nPNaPlDr := round2( nPNaPlDr, gZaok2 )

nUkupno := nPNaPlPov + nPNaPlDr + nPovD1X + nPovD2X + nDrD1X + nDrD2X

UzmiIzIni(cIniName,'Varijable','POVPOSN', FormNum2(nUOsnPov,16,gPici2), 'WRITE')
UzmiIzIni(cIniName,'Varijable','POVPIZN', FormNum2(nPNaPlPov,16,gPici2), 'WRITE')
 
UzmiIzIni(cIniName,'Varijable','DRPOSN', FormNum2(nUOsnDr,16,gPici2), 'WRITE')
UzmiIzIni(cIniName,'Varijable','DRPIZN', FormNum2(nPNaPlDr,16,gPici2), 'WRITE')

UzmiIzIni(cIniName,'Varijable','POREZ', FormNum2(nPNaPlDr+nPNaPlPov,16,gPici2), 'WRITE')

// ukupno radnika
UzmiIzIni(cIniName,'Varijable','U016', str(nURadnika,0) ,'WRITE')

nPom=nUkupno
UzmiIzIni(cIniName,'Varijable','UKOBAV',FormNum2(nPom,16,gPici2),'WRITE')

 
IniRefresh()
//Odstampaj izvjestaj

if lastkey()!=K_ESC .and.  pitanje(,"Aktivirati Win Report ?","D")=="D"

 cSpecRtm := "SPECBU"

 private cKomLin := "DelphiRB " + cSpecRtm + ;
	" " + PRIVPATH + "  DUMMY 1"

 cPom := alltrim(IzFmkIni("Specif","LijevaMargina","-",KUMPATH))
 
 if cPom!="-"
  cKomLin += " lmarg:"+cPom
 endif
 
 cPom := alltrim(IzFmkIni("Specif","GornjaMargina","-",KUMPATH))
 
 if cPom!="-"
  cKomLin += " tmarg:"+cPom
 endif

 run &cKomLin

endif

closeret
return

