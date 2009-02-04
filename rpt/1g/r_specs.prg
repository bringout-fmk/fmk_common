#include "ld.ch"


// ------------------------------------------------
// specifikacija place, samostalni poduzetnik
// ------------------------------------------------
function SpecPlS()
local GetList:={}
local aPom:={}
local nGrupaPoslova:=5
local nLM:=5
local nLin
local nPocetak
local i:=0
local j:=0
local k:=0
local nPreskociRedova
local cLin
local nPom
local uNaRuke
local aOps:={}
local cRepSr := "N"
local cRTipRada := " "
private aSpec:={}
private cFNTZ:="D"
private gPici:="9,999,999,999,999,999"+IF(gZaok>0,PADR(".",gZaok+1,"9"),"")
private gPici2:="9,999,999,999,999,999"+IF(gZaok2>0,PADR(".",gZaok2+1,"9"),"")
private gPici3:="999,999,999,999.99"

for i:=1 to nGrupaPoslova+1
	AADD(aSpec,{0,0,0,0})
	//  br.bodova, br.radnika, minuli rad, uneto
next

cIdRJ:="  "
qqIDRJ:=""
qqOpSt:=""

nBrutoOsnova:=0
nBrutoOsBenef := 0
nPojBrOsn := 0
nPojBrBenef := 0
nOstaleObaveze:=0
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
cDopr3:="12"
cFirmNaz:=SPACE(35)
cFirmAdresa:=SPACE(35)
cFirmOpc:=SPACE(35)  
cFirmVD:=SPACE(50)  
cRadn:=SPACE(_LR_)

OSpecif()

select params

private cSection:="S"
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
RPar("d3",@cDopr3)
RPar("qj",@qqIdRJ)
RPar("st",@qqOpSt)

qqIdRj:=PadR(qqIdRj,80) 
qqOpSt:=PadR(qqOpSt,80)

cMatBr:=IzFmkIni("Specif","MatBr","--",KUMPATH)
cMatBR:=padr(cMatBr,13) 
dDatIspl := date()

do while .t.
	
	Box(,13,75)
     		
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
     		
		
     		@ m_x+ 8,m_y+ 2 SAY "Poduzetnik:" GET cRadn ;
			VALID P_RADN(@cRadn)
     		
		
		@ m_x+10,m_y+ 2 SAY "          Doprinos pio (iz+na):" GET cDopr1
     		@ m_x+11,m_y+ 2 SAY "    Doprinos zdravstvo (iz+na):" GET cDopr2
     		@ m_x+12,m_y+ 2 SAY "Doprinos nezaposlenost (iz+na):" GET cDopr3
     		
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
WPar("d3",cDopr3)

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
nUNetoOsnova:=0
nPorNaPlatu:=0
nKoefLO := 0
nURadnika:=0
nULicOdbitak := 0

DO WHILE STR(nGodina,4)+STR(nMjesec,2)==STR(godina,4)+STR(mjesec,2)
   
        if field->idradn <> cRadn
		skip
		loop
	endif

        SELECT RADN
        HSEEK LD->idradn

   	cRTR := radn->tiprada
   
   	if cRTR <> "S"
   		select ld
		skip
		loop
   	endif

   	// koeficijent propisani
   	nRSpr_koef := radn->sp_koef
   
   	SELECT LD
   
   	IF ! ( RADN->(&aUslOpSt) )
     		SKIP 1
    		LOOP
   	ENDIF
  
   	nKoefLO := ld->ulicodb
	nULicOdbitak += nKoefLO
   	nUNeto+=ld->uneto
   	nNetoOsn:=MAX(ld->uneto,PAROBR->prosld*gPDLimit/100)
   	nUNetoOsnova+=nNetoOsn
  
 
	// prvo doprinosi i bruto osnova ....
 	nPojBrOsn := bruto_osn( nNetoOsn, cRTR, nKoefLO, nRSpr_koef )
 	nBrutoOsnova += nPojBrOsn
 
	// ukupno bruto
 	nPom := nBrutoOsnova
 	UzmiIzIni(cIniName,'Varijable','U017',FormNum2(nPom,16,gPici2),'WRITE')
	
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
     			nBOO := nBrutoOsnova
   		ENDIF
		
		SKIP 1
 	ENDDO

 	nkD1X := get_dopr(cDopr1, "S")
 	nkD2X := get_dopr(cDopr2, "S")
 	nkD3X := get_dopr(cDopr3, "S")

	//stope na bruto
 
	nPom:=nKD1X+nKD2X+nKD3X
 	UzmiIzIni(cIniName,'Varijable','D11B',FormNum2(nPom,16,gpici3)+"%" , 'WRITE')
 	nPom:=nKD1X
 	UzmiIzIni(cIniName,'Varijable','D11_1B', FormNum2(nPom,16,gpici3)+"%", 'WRITE')
 	nPom:=nKD2X
 	UzmiIzIni(cIniName,'Varijable','D11_2B', FormNum2(nPom,16,gpici3)+"%", 'WRITE')
 	nPom:=nKD3X
 	UzmiIzIni(cIniName,'Varijable','D11_3B', FormNum2(nPom,16,gpici3)+"%", 'WRITE')


 	nDopr1X := round2(nBrutoOsnova * nkD1X / 100, gZaok2)
 	nDopr2X := round2(nBrutoOsnova * nkD2X / 100, gZaok2)
 	nDopr3X := round2(nBrutoOsnova * nkD3X / 100, gZaok2)

 	nPojDoprIZ := round2((nPojBrOsn * nkD1X /100), gZaok2 ) + ;
 		round2((nPojBrOsn * nkD2X / 100), gZaok2) + ;
		round2((nPojBrOsn* nkD3X / 100), gZaok2 )

	// iznos doprinosa
 
 	nPom:=nDopr1X+nDopr2X+nDopr3X
 
 	// ukupni doprinosi iz plate
 	nUkDoprIZ := nPom	

 	UzmiIzIni(cIniName,'Varijable','D11I', FormNum2(nPom,16,gPici2), 'WRITE')
 	nPom:=nDopr1X
 	UzmiIzIni(cIniName,'Varijable','D11_1I', FormNum2(nPom,16,gPici2), 'WRITE')
 	nPom:=nDopr2X
 	UzmiIzIni(cIniName,'Varijable','D11_2I', FormNum2(nPom,16,gPici2), 'WRITE')
 	nPom:=nDopr3X
 	UzmiIzIni(cIniName,'Varijable','D11_3I', FormNum2(nPom,16,gPici2), 'WRITE')

 

	SELECT LD
   
   	nURadnika++
   
   	SKIP 1
 
ENDDO

// podaci o radniku
// ime poduzetnika
UzmiIzIni(cIniName,'Varijable','PODNAZ', ALLTRIM(radn->ime) + ;
	" " + ALLTRIM(radn->naz) ,'WRITE')
// adresa
UzmiIzIni(cIniName,'Varijable','PODADR', ALLTRIM(radn->streetname) + ;
	" " + ALLTRIM(radn->streetnum) ,'WRITE')
// matbr
UzmiIzIni(cIniName,'Varijable','PODMAT', Razrijedi(radn->matbr) ,'WRITE')
// opcina
UzmiIzIni(cIniName,'Varijable','PODOPC', ;
	Ocitaj( F_OPS, radn->idopsrad, "naz", .t.) ,'WRITE')

// ukupno radnika
UzmiIzIni(cIniName,'Varijable','U016', str(nURadnika,0) ,'WRITE')

// ukupno neto
UzmiIzIni(cIniName,'Varijable','U018',FormNum2(nUNETO,16,gPici2),'WRITE')

nPom := nBrutoOsnova
nUUNR := nPom
UzmiIzIni(cIniName,'Varijable','UNR', FormNum2(nPom,16,gPici2), 'WRITE')
 
IniRefresh()
//Odstampaj izvjestaj

if lastkey()!=K_ESC .and.  pitanje(,"Aktivirati Win Report ?","D")=="D"

 cSpecRtm := "SPECBS"

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

CLOSERET
return


