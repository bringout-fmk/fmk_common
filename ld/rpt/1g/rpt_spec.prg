#include "\cl\sigma\fmk\ld\ld.ch"


function Specif()
*{
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
local aOps:={}
private aSpec:={}
private cFNTZ:="N"
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

nPorOlaksice:=0
nBrutoOsnova:=0
nOstaleObaveze:=0
nBolPreko:=0
nPorezOstali:=0
nObustave:=0
nOstOb1:=0
nOstOb2:=0
nOstOb3:=0
nOstOb4:=0
nMjesec:=gMjesec
nGodina:=gGodina
cObracun:=gObracun
cMRad:="17"
cPorOl:="33"
cBolPr:="  "
cObust:=SPACE(60)
cOstObav:=SPACE(60)

ccOO1:=SPACE(20)
ccOO2:=SPACE(20)
ccOO3:=SPACE(20)
ccOO4:=SPACE(20)
cnOO1:=SPACE(20)
cnOO2:=SPACE(20)
cnOO3:=SPACE(20)
cnOO4:=SPACE(20)

cDopr1:="10"
cDopr2:="11"
cDopr3:="12"
cDopr5:="20"
cDopr6:="21"
cDopr7:="22"
cDoprOO:=""
cPorOO:=""
cIspl1:=SPACE(30)
cIspl2:=SPACE(15)
cIspl3:=SPACE(20)  // naziv, sjediste i broj racuna isplatioca
nLimG1:=0
nLimG2:=0
nLimG3:=0
nLimG4:=0
nLimG5:=0

OSpecif()

if (FieldPos("DNE")<>0)
	go top
 	do while !eof()
   		AADD(aOps,{id,dne,0}) // sifra opstine, dopr.koje nema, neto
   		skip 1
 	enddo
 	lPDNE:=.t.
else
	lPDNE:=.f.
endif

select params

private cSection:="4"
private cHistory:=" "
private aHistory:={}

RPar("i1",@cIspl1)
RPar("i2",@cIspl2)  
RPar("i3",@cIspl3)
RPar("i4",@cMRad) 
RPar("i5",@cPorOl)
RPar("i6",@cBolPr)

cBolPr:=TRIM(cBolPr)

if (!EMPTY(cBolPr) .and. Right(cBolPr,1)<>";")
	cBolPr:=cBolPr+";"
endif

cBolPr:=PadR(cBolPr,20)

RPar("i7",@cObust)
RPar("i8",@cOstObav)
RPar("i9",@cFNTZ)
RPar("d1",@cDopr1)
RPar("d2",@cDopr2)
RPar("d3",@cDopr3)
RPar("d5",@cDopr5)
RPar("d6",@cDopr6)
RPar("d7",@cDopr7)
RPar("a1",@ccOO1)
RPar("a2",@ccOO2)
RPar("a3",@ccOO3)
RPar("a4",@ccOO4)
RPar("a5",@cnOO1)
RPar("a6",@cnOO2)
RPar("a7",@cnOO3)
RPar("a8",@cnOO4)
RPar("l1",@nLimG1)
RPar("l2",@nLimG2)
RPar("l3",@nLimG3)
RPar("l4",@nLimG4)
RPar("l5",@nLimG5)
RPar("qj",@qqIdRJ)
RPar("st",@qqOpSt)

qqIdRj:=PadR(qqIdRj,80) 
qqOpSt:=PadR(qqOpSt,80)

// maticni broj, porezni djelovodni broj , datum isplate place

cMatBr:=IzFmkIni("Specif","MatBr","--",KUMPATH)
cPorDBR:=IzFmkIni("Specif","PorDBR","--",KUMPATH)
cSBR:=IzFmkIni("Specif","SBR","--",KUMPATH)
cSPBR:=IzFmkIni("Specif","SPBR","--",KUMPATH)
cMatBR:=padr(cMatBr,13) ; cPorDBR := Padr(cPorDBR,8)
cNOPU:=space(10)  // broj koji dodjeljuje poreska uprava
dDatIspl:=date()

if IzFmkIni('LD','StatBroj9mjesta','N',KUMPATH)=='D'
	cSBR:=padr(cSBR,9)
else
	cSBR:=padr(cSBR,8)
endif

cSPBR:=padr(cSPBR,4)


do while .t.
	Box(,22+IF(gVarSpec=="1",0,1),75)
     		@ m_x+ 1,m_y+ 2 SAY "Radna jedinica (prazno-sve): "  GET qqIdRJ PICT "@!S20"
     		@ m_x+ 2,m_y+ 2 SAY "Opstina stanov.(prazno-sve): "  GET qqOpSt PICT "@!S20"

     		@ m_x+ 3,m_y+ 2 SAY "Mjesec:"  GET  nMjesec  pict "99"
     		if lViseObr
       			@ m_x+ 3,col()+2 SAY "Obracun:"  GET  cObracun WHEN HelpObr(.t.,cObracun) VALID ValObr(.t.,cObracun)
     		endif
     		@ m_x+ 3,col()+2 SAY "Godina:"  GET  nGodina  pict "9999"
    		@ m_x+ 3,col()+2 SAY "Format iznosa 9.999,99 (D/N)?"  GET  cFNTZ  VALID cFNTZ$"DN" pict "@!"
     		@ m_x+ 4,m_y+ 2 SAY "Naziv    " GET cIspl1
     		@ m_x+ 5,m_y+ 2 SAY "sjediste " GET cIspl2
     		@ m_x+ 6,m_y+ 2 SAY "br.racuna" GET cIspl3
     		@ m_x+ 4,m_y+ 50 SAY "     No :" GET cNoPU
     		@ m_x+ 5,m_y+ 50 SAY "Mat.br  :" GET cMatBR
     		@ m_x+ 6,m_y+ 50 SAY "Por.d.br:" GET cPorDBR
     		@ m_x+ 7,m_y+ 50 SAY "Dat.ispl:" GET dDatIspl
     		@ m_x+ 8,m_y+ 50 SAY "Stat.broj" GET cSBR
     		@ m_x+ 9,m_y+ 50 SAY "Stat.podb" GET cSPBR
     		@ m_x+ 8,m_y+ 2 SAY "Sifra por.olaksice" GET cPorOl VALID LD->(FIELDPOS("I"+cPorOl))>0 .or. EMPTY(cPorOl) PICT "99"
     		@ m_x+ 9,m_y+ 2 SAY "Sifra bolovanja 'preko 42' " GET cBolPr PICT "@!S20"
		@ m_x+10,m_y+ 2 SAY "Obustave (nabrojati sifre - npr. 29;30;)" GET cObust  PICT "@!S20"
     		@ m_x+11,m_y+ 2 SAY "Ostale obaveze (nabrojati sifre - npr. D->AX;D->BX;)" GET cOstObav  PICT "@!S20"
     		@ m_x+12,m_y+ 2 SAY "Doprinos za penz.i inv.osig. -iz plate" GET cDopr1
     		@ m_x+13,m_y+ 2 SAY "Doprinos za zdravstv.osigur. -iz plate" GET cDopr2
     		@ m_x+14,m_y+ 2 SAY "Doprinos za osig.od nezaposl.-iz plate" GET cDopr3
     		@ m_x+15,m_y+ 2 SAY "Doprinos za penz.i inv.osig. -na platu" GET cDopr5
     		@ m_x+16,m_y+ 2 SAY "Doprinos za zdravstv.osigur. -na platu" GET cDopr6
     		@ m_x+17,m_y+ 2 SAY "Doprinos za osig.od nezaposl.-na platu" GET cDopr7
     		@ m_x+18,m_y+ 2 SAY "Ost.obaveze: NAZIV                  USLOV"
     		@ m_x+19,m_y+ 2 SAY " 1." GET ccOO1
     		@ m_x+19,m_y+30 GET cnOO1
     		@ m_x+20,m_y+ 2 SAY " 2." GET ccOO2
     		@ m_x+20,m_y+30 GET cnOO2
     		@ m_x+21,m_y+ 2 SAY " 3." GET ccOO3
     		@ m_x+21,m_y+30 GET cnOO3
     		@ m_x+22,m_y+ 2 SAY " 4." GET ccOO4
     		@ m_x+22,m_y+30 GET cnOO4
     		if gVarSpec=="2"
       			@ m_x+23,m_y+2 SAY "Limit za gr.posl.1" GET nLimG1 PICT "9999.99"
       			@ m_x+23,m_y+29 SAY "2" GET nLimG2 PICT "9999.99"
       			@ m_x+23,m_y+39 SAY "3" GET nLimG3 PICT "9999.99"
       			@ m_x+23,m_y+49 SAY "4" GET nLimG4 PICT "9999.99"
       			@ m_x+23,m_y+59 SAY "5" GET nLimG5 PICT "9999.99"
     		endif
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


WPar("i1",cIspl1)
WPar("i2",cIspl2)
WPar("i3",cIspl3)
WPar("i4",cMRad)
WPar("i5",cPorOl)
WPar("i6",cBolPr)
WPar("i7",cObust)
WPar("i8",cOstObav)
WPar("i9",cFNTZ)
WPar("d1",cDopr1)
WPar("d2",cDopr2)
WPar("d3",cDopr3)
WPar("d5",cDopr5)
WPar("d6",cDopr6)
WPar("d7",cDopr7)
WPar("a1",ccOO1)
WPar("a2",ccOO2)
WPar("a3",ccOO3)
WPar("a4",ccOO4)
WPar("a5",cnOO1)
WPar("a6",cnOO2)
WPar("a7",cnOO3)
WPar("a8",cnOO4)
WPar("l1",nLimG1)
WPar("l2",nLimG2)
WPar("l3",nLimG3)
WPar("l4",nLimG4)
WPar("l5",nLimG5)

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
UzmiIzIni(cPom,'Specif',"PorDBR",cPorDBR,'WRITE')
UzmiIzIni(cPom,'Specif',"SBR",cSBR,'WRITE')
UzmiIzIni(cPom,'Specif',"SPBR",cSPBR,'WRITE')

cIniName:=EXEPATH+'proizvj.ini'

 //
 // Radi DRB6 iskoristio f-ju Razrijedi()
 //   npr.:    string  ->  s t r i n g
 //
UzmiIzIni(cIniName,'Varijable',"NAZISJ", cIspl1+", "+cIspl2 ,'WRITE')
UzmiIzIni(cIniName,'Varijable',"NOPU", cNoPU ,'WRITE')
UzmiIzIni(cIniName,'Varijable',"GOD",Razrijedi(str(nGodina,4)),'WRITE')
UzmiIzIni(cIniName,'Varijable',"MJ",Razrijedi(strtran(str(nMjesec,2)," ","0")),'WRITE')
UzmiIzIni(cIniName,'Varijable',"BRRAC",cIspl3,'WRITE')
UzmiIzIni(cIniName,'Varijable',"MATBR",Razrijedi(cMatBR),'WRITE')
UzmiIzIni(cIniName,'Varijable',"PORDBR",Razrijedi(cPorDBR),'WRITE')
UzmiIzIni(cIniName,'Varijable',"SBR",Razrijedi(cSBR),'WRITE')
UzmiIzIni(cIniName,'Varijable',"SPBR",Razrijedi(cSPBR),'WRITE')
UzmiIzIni(cIniName,'Varijable',"DATISPL",DTOC(dDatIspl),'WRITE')

if lViseObr
	cObracun:=TRIM(cObracun)
else
	cObracun:=""
endif

cPorOO:=Izrezi("P->",2,@cOstObav)
cDoprOO:=Izrezi("D->",2,@cOstObav)
cDoprOO1:=Izrezi("D->",2,@cnOO1)
cDoprOO2:=Izrezi("D->",2,@cnOO2)
cDoprOO3:=Izrezi("D->",2,@cnOO3)
cDoprOO4:=Izrezi("D->",2,@cnOO4)

// ----------- MS 07.04.01
// SELECT PAROBR; HSEEK STR(nMjesec,2)+cObracun
// IF !FOUND()
//  MsgBeep("Greska: ne postoje parametri obracuna za "+ALLTRIM(STR(nMjesec))+". mjesec!")
//   CLOSERET
// ENDIF

ParObr(nMjesec,cObracun,LEFT(qqIdRJ,2))

// ----------- MS 07.04.01

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
 nURadnika:=0
 DO WHILE STR(nGodina,4)+STR(nMjesec,2)==STR(godina,4)+STR(mjesec,2)
   SELECT RADN; HSEEK LD->idradn
   SELECT LD
   IF ! ( RADN->(&aUslOpSt) )
     SKIP 1; LOOP
   ENDIF
   nP77 := IF( !EMPTY(cMRad)  , LD->&("I"+cMRad)  , 0 )
   nP78 := IF( !EMPTY(cPorOl) , LD->&("I"+cPorOl) , 0 )

   //nP79 := IF( !EMPTY(cBolPr) , LD->&("I"+cBolPr) , 0 )
   nP79:=0
   IF !EMPTY(cBolPr) .or. !EMPTY(cBolPr)
     FOR t:=1 TO 99
       cPom := IF( t>9, STR(t,2), "0"+STR(t,1) )
       IF LD->( FIELDPOS( "I" + cPom ) ) <= 0
         EXIT
       ENDIF
       nP79 += IF( cPom $ cBolPr   , LD->&("I"+cPom) , 0 )
     NEXT
   ENDIF

   nP80 := nP81 := nP82 := nP83 := nP84 := nP85 := 0
   IF !EMPTY(cObust) .or. !EMPTY(cOstObav)
     altd()
     FOR t:=1 TO 99
       cPom := IF( t>9, STR(t,2), "0"+STR(t,1) )
       IF LD->( FIELDPOS( "I" + cPom ) ) <= 0
         EXIT
       ENDIF
       nP80 += IF( cPom $ cObust   , LD->&("I"+cPom) , 0 )
       nP81 += IF( cPom $ cOstObav , LD->&("I"+cPom) , 0 )
       nP82 += IF( cPom $ cnOO1    , LD->&("I"+cPom) , 0 )
       nP83 += IF( cPom $ cnOO2    , LD->&("I"+cPom) , 0 )
       nP84 += IF( cPom $ cnOO3    , LD->&("I"+cPom) , 0 )
       nP85 += IF( cPom $ cnOO4    , LD->&("I"+cPom) , 0 )
     NEXT
   ENDIF
   IF LD->uneto>0  // zbog npr.bol.preko 42 dana koje ne ide u neto
     IF LEN(aPom)<1 .or. ( nPom := ASCAN(aPom,{|x| x[1]==LD->brbod}) ) == 0
       AADD( aPom , { LD->brbod , 1 , nP77 , LD->uneto } )
     ELSE
       if ! ( lViseObr .and. EMPTY(cObracun) .and. LD->obr$"23456789" )
         aPom[nPom,2] += 1  // broj radnika
       endif
       aPom[nPom,3] += nP77  // minuli rad
       aPom[nPom,4] += LD->uneto // neto
     ENDIF
   ENDIF

   nUNeto+=ld->uneto
   nUNetoOsnova+=MAX(ld->uneto,PAROBR->prosld*gPDLimit/100)
  altd()
  //porez na platu i ostali porez
  SELECT POR
   GO TOP

   DO WHILE !EOF()
     PozicOps(POR->poopst)
     IF !ImaUOp("POR",POR->id)
       SKIP 1; LOOP
     ENDIF
     IF ID=="01"
//       nPorNaPlatu  += ROUND2(POR->iznos * MAX(ld->uneto,PAROBR->prosld*gPDLimit/100) / 100,gZaok2)
       nPorNaPlatu  += POR->iznos * MAX(ld->uneto,PAROBR->prosld*gPDLimit/100) / 100
     ELSE
       IF ID $ cPorOO
         nPorezOstali   += ROUND2(POR->iznos * MAX(ld->uneto,PAROBR->prosld*gPDLimit/100) / 100,gZaok2)
//         nOstaleObaveze += ROUND2(POR->iznos * MAX(ld->uneto,PAROBR->prosld*gPDLimit/100) / 100,gZaok2)
       ENDIF
     ENDIF
     SKIP 1
   ENDDO

   SELECT LD
   
   nURadnika++
   nPorOlaksice+=nP78
   nBolPreko+=nP79
   nObustave+=nP80
   nOstaleObaveze+=nP81
   nOstOb1+=nP82; nOstOb2+=nP83; nOstOb3+=nP84; nOstOb4+=nP85
   IF lPDNE
     nOps := ASCAN( aOps , {|x| x[1]==RADN->idopsst} )
     IF nOps>0
       aOps[nOps,3] += MAX(ld->uneto,PAROBR->prosld*gPDLimit/100)
     ELSE
       AADD( aOps , { RADN->idopsst, "", MAX(ld->uneto,PAROBR->prosld*gPDLimit/100) } )
     ENDIF
   ENDIF
   SKIP 1
 ENDDO

 nPorNaPlatu:=round2(nPorNaPlatu,gZaok2)
 
 // obustave iz place
 UzmiIzIni(cIniName,'Varijable','O18I', FormNum2(-nObustave,16,gPici2), 'WRITE')

 // Ostale obaveze = OstaleObaveze.1

 ASORT( aPom , , , {|x,y| x[1]>y[1]} )
 FOR i:=1 TO LEN(aPom)
   IF gVarSpec=="1"
     IF i<=nGrupaPoslova
       aSpec[i,1]:=aPom[i,1]; aSpec[i,2]:=aPom[i,2]; aSpec[i,3]:=aPom[i,3]
       aSpec[i,4]:=aPom[i,4]
     ELSE
       aSpec[nGrupaPoslova,2]+=aPom[i,2]; aSpec[nGrupaPoslova,3]+=aPom[i,3]
       aSpec[nGrupaPoslova,4]+=aPom[i,4]
     ENDIF
   ELSE     // gVarSpec=="2"
     DO CASE
       CASE aPom[i,1] <= nLimG5
         aSpec[5,1]:=aPom[i,1]; aSpec[5,2]+=aPom[i,2]
         aSpec[5,3]+=aPom[i,3]; aSpec[5,4]+=aPom[i,4]
       CASE aPom[i,1] <= nLimG4
         aSpec[4,1]:=aPom[i,1]; aSpec[4,2]+=aPom[i,2]
         aSpec[4,3]+=aPom[i,3]; aSpec[4,4]+=aPom[i,4]
       CASE aPom[i,1] <= nLimG3
         aSpec[3,1]:=aPom[i,1]; aSpec[3,2]+=aPom[i,2]
         aSpec[3,3]+=aPom[i,3]; aSpec[3,4]+=aPom[i,4]
       CASE aPom[i,1] <= nLimG2
         aSpec[2,1]:=aPom[i,1]; aSpec[2,2]+=aPom[i,2]
         aSpec[2,3]+=aPom[i,3]; aSpec[2,4]+=aPom[i,4]
       CASE aPom[i,1] <= nLimG1
         aSpec[1,1]:=aPom[i,1]; aSpec[1,2]+=aPom[i,2]
         aSpec[1,3]+=aPom[i,3]; aSpec[1,4]+=aPom[i,4]
     ENDCASE
   ENDIF
   aSpec[nGrupaPoslova+1,2]+=aPom[i,2]; aSpec[nGrupaPoslova+1,3]+=aPom[i,3]
   aSpec[nGrupaPoslova+1,4]+=aPom[i,4]
 NEXT



 altd()
 // ukupno radnika
 UzmiIzIni(cIniName,'Varijable','U016', str(nURadnika,0) ,'WRITE')
 // ukupno neto
 UzmiIzIni(cIniName,'Varijable','U018',FormNum2(nUNETO,16,gPici2),'WRITE')



 altd()

 //31.01.01 nPorNaPlatu  := ROUND2(POR->iznos * aSpec[nGrupaPoslova+1,4] / 100,gZaok2)
 //SELECT POR; HSEEK "01"  // por.na platu
 //nPorNaPlatu  := ROUND2(POR->iznos * nUNeto / 100,gZaok2)
 //01.02.01 prebaceno u do while petlju

 //13.02.2001
 //UzmiIzIni(cIniName,'Varijable','D13N', FormNum2(POR->IZNOS,16,gpici3)+"%",'WRITE')
 UzmiIzIni(cIniName,'Varijable','D13N', " ", 'WRITE')
 SELECT POR; SEEK "01"
 UzmiIzIni(cIniName,'Varijable','D13_1N',FormNum2(POR->IZNOS,16,gpici3)+"%",'WRITE')

 altd()
 nPom=nPorNaPlatu-nPorOlaksice
 UzmiIzIni(cIniName,'Varijable','D13I',FormNum2(nPom,16,gPici2),'WRITE')
 nPom=nPorNaPlatu
 UzmiIzIni(cIniName,'Varijable','D13_1I',FormNum2(nPom,16,gPici2),'WRITE')
 nPom:=nPorOlaksice
 UzmiIzIni(cIniName,'Varijable','D13_2I',FormNum2(nPom,16,gPici2),'WRITE')
 nPom:=nBolPreko
 UzmiIzIni(cIniName,'Varijable','N17I',FormNum2(nPom,16,gPici2),'WRITE')

// ------------------------------------------------------------------
// ------------------------------------------------------------------
 nBrutoOsnova:=round(PAROBR->k3 * nUNetoOsnova / 100,gZaok2)
 // ukupno bruto
 nPom:=nBrutoOsnova
 UzmiIzIni(cIniName,'Varijable','U017',FormNum2(nPom,16,gPici2),'WRITE')

 SELECT DOPR; GO TOP
 DO WHILE !EOF()
   IF DOPR->poopst=="1" .and. lPDNE
     nBOO:=0
     FOR i:=1 TO LEN(aOps)
       IF ! ( DOPR->id $ aOps[i,2] )
         nBOO += aOps[i,3]
       ENDIF
     NEXT
     nBOO := ROUND( PAROBR->k3 * nBOO / 100 ,gZaok2 )
   ELSE
     nBOO := nBrutoOsnova
   ENDIF
   IF ID $ cDoprOO1  // Ostale obaveze - 1
     IF EMPTY(ccOO1) .and. nOstOb1==0; ccOO1:=NAZ; ENDIF
     nOstOb1 += round2(MAX(DLIMIT,nBOO*iznos / 100), gZaok2)
   ENDIF
   IF ID $ cDoprOO2  // Ostale obaveze - 2
     IF EMPTY(ccOO2) .and. nOstOb2==0; ccOO2:=NAZ; ENDIF
     nOstOb2 += round2(MAX(DLIMIT,nBOO*iznos / 100), gZaok2)
   ENDIF
   IF ID $ cDoprOO3  // Ostale obaveze - 3
     IF EMPTY(ccOO3) .and. nOstOb3==0; ccOO3:=NAZ; ENDIF
     nOstOb3 += round2(MAX(DLIMIT,nBOO*iznos / 100), gZaok2)
   ENDIF
   IF ID $ cDoprOO4 // Ostale obaveze - 4
     IF EMPTY(ccOO4) .and. nOstOb4==0; ccOO4:=NAZ; ENDIF
     nOstOb4 += round2(MAX(DLIMIT,nBOO*iznos / 100), gZaok2)
   ENDIF
   IF ID $ cDoprOO   // Ostale obaveze
     altd()
     nOstaleObaveze += round2(MAX(DLIMIT,nBOO * iznos / 100), gZaok2)
   ENDIF
   SKIP 1
 ENDDO


 nkD1X := Ocitaj( F_DOPR , cDopr1 , "iznos" , .t. )
 nkD2X := Ocitaj( F_DOPR , cDopr2 , "iznos" , .t. )
 nkD3X := Ocitaj( F_DOPR , cDopr3 , "iznos" , .t. )
 nkD5X := Ocitaj( F_DOPR , cDopr5 , "iznos" , .t. )
 nkD6X := Ocitaj( F_DOPR , cDopr6 , "iznos" , .t. )
 nkD7X := Ocitaj( F_DOPR , cDopr7 , "iznos" , .t. )


 //stope na bruto
 
 nPom:=nKD1X+nKD2X+nKD3X
 UzmiIzIni(cIniName,'Varijable','D11B',FormNum2(nPom,16,gpici3)+"%" , 'WRITE')
 nPom:=nKD1X
 UzmiIzIni(cIniName,'Varijable','D11_1B', FormNum2(nPom,16,gpici3)+"%", 'WRITE')
 nPom:=nKD2X
 UzmiIzIni(cIniName,'Varijable','D11_2B', FormNum2(nPom,16,gpici3)+"%", 'WRITE')
 nPom:=nKD3X
 UzmiIzIni(cIniName,'Varijable','D11_3B', FormNum2(nPom,16,gpici3)+"%", 'WRITE')

 nPom:=nKD5X+nKD6X+nKD7X
 UzmiIzIni(cIniName,'Varijable','D12B', FormNum2(nPom,16,gpici3)+"%", 'WRITE')
 nPom:=nKD5X
 UzmiIzIni(cIniName,'Varijable','D12_1B', FormNum2(nPom,16,gpici3)+"%", 'WRITE')
 nPom:=nKD6X
 UzmiIzIni(cIniName,'Varijable','D12_2B', FormNum2(nPom,16,gpici3)+"%", 'WRITE')
 nPom:=nKD7X
 UzmiIzIni(cIniName,'Varijable','D12_3B', FormNum2(nPom,16,gpici3)+"%", 'WRITE')

 nDopr1X := round2(nBrutoOsnova * nkD1X / 100, gZaok2)
 nDopr2X := round2(nBrutoOsnova * nkD2X / 100, gZaok2)
 nDopr3X := round2(nBrutoOsnova * nkD3X / 100, gZaok2)
 nDopr5X := round2(nBrutoOsnova * nkD5X / 100, gZaok2)
 nDopr6X := round2(nBrutoOsnova * nkD6X / 100, gZaok2)
 nDopr7X := round2(nBrutoOsnova * nkD7X / 100, gZaok2)

 // iznos doprinosa
 nPom:=nDopr1X+nDopr2X+nDopr3X
 UzmiIzIni(cIniName,'Varijable','D11I', FormNum2(nPom,16,gPici2), 'WRITE')
 nPom:=nDopr1X
 UzmiIzIni(cIniName,'Varijable','D11_1I', FormNum2(nPom,16,gPici2), 'WRITE')
 nPom:=nDopr2X
 UzmiIzIni(cIniName,'Varijable','D11_2I', FormNum2(nPom,16,gPici2), 'WRITE')
 nPom:=nDopr3X
 UzmiIzIni(cIniName,'Varijable','D11_3I', FormNum2(nPom,16,gPici2), 'WRITE')

 nPom:=nDopr5X+nDopr6X+nDopr7X
 UzmiIzIni(cIniName,'Varijable','D12I',FormNum2(nPom,16,gPici2) , 'WRITE')
 nPom:=nDopr5X
 UzmiIzIni(cIniName,'Varijable','D12_1I', FormNum2(nPom,16,gPici2), 'WRITE')
 nPom:=nDopr6X
 UzmiIzIni(cIniName,'Varijable','D12_2I', FormNum2(nPom,16,gPici2), 'WRITE')
 nPom:=nDopr7X
 UzmiIzIni(cIniName,'Varijable','D12_3I', FormNum2(nPom,16,gPici2), 'WRITE')

 nPorOlaksice   := ABS( nPorOlaksice   )
 nBolPreko      := ABS( nBolPreko      )
 nObustave      := ABS( nObustave      )
 nOstOb1        := ABS( nOstOb1        )
 nOstOb2        := ABS( nOstOb2        )
 nOstOb3        := ABS( nOstOb3        )
 nOstOb4        := ABS( nOstOb4        )
 nOstaleObaveze := ABS( IF( nOstaleObaveze==0, nOstOb1+nOstOb2+nOstOb3+nOstOb4, nOstaleObaveze ) )

 nPom:=nDopr1X+nDopr2x+nDopr3x+;
       nDopr5x+nDopr6x+nDopr7x+;
       nPorNaPlatu+nPorezOstali-;
       nPorOlaksice+nOstaleOBaveze;
 // ukupno obaveze
 UzmiIzIni(cIniName,'Varijable','U15I', FormNum2(nPom,16,gPici2), 'WRITE')

 // ukupno placa_i_obaveze = obaveze + ukupno_neto + poreskeolaksice
 nPom := nPom + nUNETO + nPorOlaksice
 UzmiIzIni(cIniName,'Varijable','U16I', FormNum2(nPom,16,gPici2), 'WRITE')

 // obustave
 nPom := nObustave
 UzmiIzIni(cIniName,'Varijable','O18I', FormNum2(nPom,16,gPici2), 'WRITE')

 // neto za isplatu  = neto  + nPorOlaksice
 // -----------------------------------------
 // varijanta D - specificno za FEB jer treba da izbazi bol.preko.42
 // dana iz neta za isplatu na specifikaciji, vec je uracunat u netu.

 if IzFmkIni('LD','BolPreko42IzbaciIz19','N',KUMPATH)=='D'
    nPom := nUNETO + nPorOlaksice - nObustave
 else
    nPom := nUNETO + nBolPreko + nPorOlaksice - nObustave
 endif
 UzmiIzIni(cIniName,'Varijable','N19I', FormNum2(nPom,16,gPici2), 'WRITE')

 // PIO iz + PIO na placu
 nPom:=nDopr1x+nDopr5x
 UzmiIzIni(cIniName,'Varijable','D20', FormNum2(nPom,16,gPici2), 'WRITE')
 // zdravsveno iz + zdravstveno na placu
 nPom:=nDopr2x+nDopr6x
 UzmiIzIni(cIniName,'Varijable','D21', FormNum2(nPom,16,gPici2), 'WRITE')
 // nezaposlenost iz + nezaposlenost na placu
 nPom:=nDopr3x+nDopr7x
 UzmiIzIni(cIniName,'Varijable','D22', FormNum2(nPom,16,gPici2), 'WRITE')

 nPom=nPorNaPlatu-nPorOlaksice
 UzmiIzIni(cIniName,'Varijable','P23', FormNum2(nPom,16,gPici2), 'WRITE')


 nPom=nPorezOstali
 UzmiIzIni(cIniName,'Varijable','O14_1I', FormNum2(nPom,16,gPici2), 'WRITE')

 nPom=nOstaleObaveze + nPorezOstali
 UzmiIzIni(cIniName,'Varijable','O14I', FormNum2(nPom,16,gPici2), 'WRITE')


IniRefresh()
//Odstampaj izvjestaj

if lastkey()!=K_ESC .and.  pitanje(,"Aktivirati Win Report ?","D")=="D"

 private cKomLin:="DelphiRB "+IzFmkIni("Specif","NazRTM","ldspec", KUMPATH)+" "+PRIVPATH+"  DUMMY 1"
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


FUNCTION UzmiVar(cVar)
 LOCAL cVrati:={"","''"}, nPom:=0
 DO CASE
   CASE cVar=="P1"
       cVrati := { "" , "TRIM(cIspl1)" }
   CASE cVar=="P2"
       cVrati := { "" , "cIspl2" }
   CASE cVar=="P3"
       cVrati := { "" , "cIspl3" }
   CASE cVar=="P4"
       cVrati := { "" , "NazMjeseca(nMjesec)+IspisObr()" }
   CASE cVar=="P5"
       cVrati := { "" , "nGodina" }
   CASE cVar=="NP"
       cVrati := { "" , "STR(PAROBR->vrbod,7,2)", "FormNum1(PAROBR->vrbod,7,gPici3)" }
   CASE cVar=="BP"
       cVrati := { "" , "STR(nBrutoOsnova,10,gZaok2)", "FormNum1(nBrutoOsnova,10,gPici2)" }

   CASE LEFT(cVar,1)=="N" .and. (nPom:=VAL(RIGHT(cVar,1)))>0 .and. nPom<7
       IF LEN(aSpec)>=nPom .and. aSpec[nPom,2]>0
         cVrati := { "" , "STR(PAROBR->vrbod,7,2)", "FormNum1(PAROBR->vrbod,7,gPici3)" }
       ELSE
         cVrati := { "" , "STR(0,7,2)", "FormNum1(0,7,gPici3)" }
       ENDIF

   CASE cVar=="02"
       cVrati := { "" , "STR(aSpec[1,2],5,0)" }
   CASE cVar=="12"
       cVrati := { "" , "STR(aSpec[2,2],5,0)" }
   CASE cVar=="22"
       cVrati := { "" , "STR(aSpec[3,2],5,0)" }
   CASE cVar=="32"
       cVrati := { "" , "STR(aSpec[4,2],5,0)" }
   CASE cVar=="42"
       cVrati := { "" , "STR(aSpec[5,2],5,0)" }
   CASE cVar=="S2"
       cVrati := { "" , "STR(aSpec[6,2],5,0)" }

   CASE cVar=="04"
       cVrati := { "" , "STR(aSpec[1,3],9,2)", "FormNum1(aSpec[1,3],9,gPici3)" }
   CASE cVar=="14"
       cVrati := { "" , "STR(aSpec[2,3],9,2)", "FormNum1(aSpec[2,3],9,gPici3)" }
   CASE cVar=="24"
       cVrati := { "" , "STR(aSpec[3,3],9,2)", "FormNum1(aSpec[3,3],9,gPici3)" }
   CASE cVar=="34"
       cVrati := { "" , "STR(aSpec[4,3],9,2)", "FormNum1(aSpec[4,3],9,gPici3)" }
   CASE cVar=="44"
       cVrati := { "" , "STR(aSpec[5,3],9,2)", "FormNum1(aSpec[5,3],9,gPici3)" }
   CASE cVar=="S4"
       cVrati := { "" , "STR(aSpec[6,3],9,2)", "FormNum1(aSpec[6,3],9,gPici3)" }

   CASE cVar=="05"
       cVrati := { "" , "STR(aSpec[1,4],9,2)", "FormNum1(aSpec[1,4],9,gPici3)" }
   CASE cVar=="15"
       cVrati := { "" , "STR(aSpec[2,4],9,2)", "FormNum1(aSpec[2,4],9,gPici3)" }
   CASE cVar=="25"
       cVrati := { "" , "STR(aSpec[3,4],9,2)", "FormNum1(aSpec[3,4],9,gPici3)" }
   CASE cVar=="35"
       cVrati := { "" , "STR(aSpec[4,4],9,2)", "FormNum1(aSpec[4,4],9,gPici3)" }
   CASE cVar=="45"
       cVrati := { "" , "STR(aSpec[5,4],9,2)", "FormNum1(aSpec[5,4],9,gPici3)" }
   CASE cVar=="S5"
       cVrati := { "" , "STR(aSpec[6,4],9,2)", "FormNum1(aSpec[6,4],9,gPici3)" }

   CASE cVar=="03"
       cVrati := { "" , "STR(aSpec[1,4]-aSpec[1,3],9,2)", "FormNum1(aSpec[1,4]-aSpec[1,3],9,gPici3)" }
   CASE cVar=="13"
       cVrati := { "" , "STR(aSpec[2,4]-aSpec[2,3],9,2)", "FormNum1(aSpec[2,4]-aSpec[2,3],9,gPici3)" }
   CASE cVar=="23"
       cVrati := { "" , "STR(aSpec[3,4]-aSpec[3,3],9,2)", "FormNum1(aSpec[3,4]-aSpec[3,3],9,gPici3)" }
   CASE cVar=="33"
       cVrati := { "" , "STR(aSpec[4,4]-aSpec[4,3],9,2)", "FormNum1(aSpec[4,4]-aSpec[4,3],9,gPici3)" }
   CASE cVar=="43"
       cVrati := { "" , "STR(aSpec[5,4]-aSpec[5,3],9,2)", "FormNum1(aSpec[5,4]-aSpec[5,3],9,gPici3)" }
   CASE cVar=="S3"
       cVrati := { "" , "STR(aSpec[6,4]-aSpec[6,3],9,2)", "FormNum1(aSpec[6,4]-aSpec[6,3],9,gPici3)" }

   CASE cVar=="T1"
       cVrati := { "" , "STR(IF(aSpec[1,2]=0,0,aSpec[1,4]/aSpec[1,2]),9,2)", "FormNum1(IF(aSpec[1,2]=0,0,aSpec[1,4]/aSpec[1,2]),9,gPici3)" }
   CASE cVar=="T2"
       cVrati := { "" , "STR(IF(aSpec[2,2]=0,0,aSpec[2,4]/aSpec[2,2]),9,2)", "FormNum1(IF(aSpec[2,2]=0,0,aSpec[2,4]/aSpec[2,2]),9,gPici3)" }
   CASE cVar=="T3"
       cVrati := { "" , "STR(IF(aSpec[3,2]=0,0,aSpec[3,4]/aSpec[3,2]),9,2)", "FormNum1(IF(aSpec[3,2]=0,0,aSpec[3,4]/aSpec[3,2]),9,gPici3)" }
   CASE cVar=="T4"
       cVrati := { "" , "STR(IF(aSpec[4,2]=0,0,aSpec[4,4]/aSpec[4,2]),9,2)", "FormNum1(IF(aSpec[4,2]=0,0,aSpec[4,4]/aSpec[4,2]),9,gPici3)" }
   CASE cVar=="T5"
       cVrati := { "" , "STR(IF(aSpec[5,2]=0,0,aSpec[5,4]/aSpec[5,2]),9,2)", "FormNum1(IF(aSpec[5,2]=0,0,aSpec[5,4]/aSpec[5,2]),9,gPici3)" }
   CASE cVar=="T6"
       cVrati := { "" , "STR(IF(aSpec[6,2]=0,0,aSpec[6,4]/aSpec[6,2]),9,2)", "FormNum1(IF(aSpec[6,2]=0,0,aSpec[6,4]/aSpec[6,2]),9,gPici3)" }

   CASE cVar=="01"
       cVrati := { "" , "IF(aSpec[1,2]=0,SPACE(6),STR((aSpec[1,4]-aSpec[1,3])/(aSpec[1,2]*PAROBR->vrbod),6,2))", "FormNum1(IF(aSpec[1,2]=0,0,(aSpec[1,4]-aSpec[1,3])/(aSpec[1,2]*PAROBR->vrbod)),6,gPici3)" }
   CASE cVar=="11"
       cVrati := { "" , "IF(aSpec[2,2]=0,SPACE(6),STR((aSpec[2,4]-aSpec[2,3])/(aSpec[2,2]*PAROBR->vrbod),6,2))", "FormNum1(IF(aSpec[2,2]=0,0,(aSpec[2,4]-aSpec[2,3])/(aSpec[2,2]*PAROBR->vrbod)),6,gPici3)" }
   CASE cVar=="21"
       cVrati := { "" , "IF(aSpec[3,2]=0,SPACE(6),STR((aSpec[3,4]-aSpec[3,3])/(aSpec[3,2]*PAROBR->vrbod),6,2))", "FormNum1(IF(aSpec[3,2]=0,0,(aSpec[3,4]-aSpec[3,3])/(aSpec[3,2]*PAROBR->vrbod)),6,gPici3)" }
   CASE cVar=="31"
       cVrati := { "" , "IF(aSpec[4,2]=0,SPACE(6),STR((aSpec[4,4]-aSpec[4,3])/(aSpec[4,2]*PAROBR->vrbod),6,2))", "FormNum1(IF(aSpec[4,2]=0,0,(aSpec[4,4]-aSpec[4,3])/(aSpec[4,2]*PAROBR->vrbod)),6,gPici3)" }
   CASE cVar=="41"
       cVrati := { "" , "IF(aSpec[5,2]=0,SPACE(6),STR((aSpec[5,4]-aSpec[5,3])/(aSpec[5,2]*PAROBR->vrbod),6,2))", "FormNum1(IF(aSpec[5,2]=0,0,(aSpec[5,4]-aSpec[5,3])/(aSpec[5,2]*PAROBR->vrbod)),6,gPici3)" }
   CASE cVar=="S1"
       cVrati := { "" , "IF(aSpec[6,2]=0,SPACE(6),STR((aSpec[6,4]-aSpec[6,3])/(aSpec[6,2]*PAROBR->vrbod),6,2))", "FormNum1(IF(aSpec[6,2]=0,0,(aSpec[6,4]-aSpec[6,3])/(aSpec[6,2]*PAROBR->vrbod)),6,gPici3)" }

   CASE cVar=="71"
       cVrati := { "" , "STR(nkD1X+nkD2X+nkD3X,7,2)+'%'", "FormNum1(nkD1X+nkD2X+nkD3X,7,gPici3)+'%'" }
   CASE cVar=="91"
       cVrati := { "" , "STR(nDopr1X+nDopr2X+nDopr3X,9,2)", "FormNum1(nDopr1X+nDopr2X+nDopr3X,9,gPici3)" }

   CASE cVar=="72"
       cVrati := { "" , "STR(nkD1X,7,2)+'%'", "FormNum1(nkD1X,7,gPici3)+'%'" }
   CASE cVar=="92"
       cVrati := { "" , "STR(nDopr1X,9,2)", "FormNum1(nDopr1X,9,gPici3)" }

   CASE cVar=="73"
       cVrati := { "" , "STR(nkD2X,7,2)+'%'", "FormNum1(nkD2X,7,gPici3)+'%'" }
   CASE cVar=="93"
       cVrati := { "" , "STR(nDopr2X,9,2)", "FormNum1(nDopr2X,9,gPici3)" }

   CASE cVar=="74"
       cVrati := { "" , "STR(nkD3X,7,2)+'%'", "FormNum1(nkD3X,7,gPici3)+'%'" }
   CASE cVar=="94"
       cVrati := { "" , "STR(nDopr3X,9,2)", "FormNum1(nDopr3X,9,gPici3)" }

   CASE cVar=="75"
       cVrati := { "" , "STR(nkD5X+nkD6X+nkD7X,7,2)+'%'", "FormNum1(nkD5X+nkD6X+nkD7X,7,gPici3)+'%'" }
   CASE cVar=="95"
       cVrati := { "" , "STR(nDopr5X+nDopr6X+nDopr7X,9,2)", "FormNum1(nDopr5X+nDopr6X+nDopr7X,9,gPici3)" }

   CASE cVar=="76"
       cVrati := { "" , "STR(nkD5X,7,2)+'%'", "FormNum1(nkD5X,7,gPici3)+'%'" }
   CASE cVar=="96"
       cVrati := { "" , "STR(nDopr5X,9,2)", "FormNum1(nDopr5X,9,gPici3)" }

   CASE cVar=="77"
       cVrati := { "" , "STR(nkD6X,7,2)+'%'", "FormNum1(nkD6X,7,gPici3)+'%'" }
   CASE cVar=="97"
       cVrati := { "" , "STR(nDopr6X,9,2)", "FormNum1(nDopr6X,9,gPici3)" }

   CASE cVar=="78"
       cVrati := { "" , "STR(nkD7X,7,2)+'%'", "FormNum1(nkD7X,7,gPici3)+'%'" }
   CASE cVar=="98"
       cVrati := { "" , "STR(nDopr7X,9,2)", "FormNum1(nDopr7X,9,gPici3)" }

   CASE cVar=="89"
       cVrati := { "" , "STR(POR->iznos,7,2)+'%'", "FormNum1(POR->iznos,7,gPici3)+'%'" }
   CASE cVar=="99"
       cVrati := { "" , "STR(nPorNaPlatu,9,2)", "FormNum1(nPorNaPlatu,9,gPici3)" }

   CASE cVar=="9A"
       cVrati := { "" , "STR(nPorOlaksice,9,2)", "FormNum1(nPorOlaksice,9,gPici3)" }

   CASE cVar=="9B"
       cVrati := { "" , "STR(nPorNaPlatu-nPorOlaksice,9,2)", "FormNum1(nPorNaPlatu-nPorOlaksice,9,gPici3)" }

   CASE cVar=="9C"
       cVrati := { "" , "STR(nOstaleObaveze,9,2)", "FormNum1(nOstaleObaveze,9,gPici3)" }

   CASE cVar=="9D"
       cVrati := { "" , "STR(nDopr1X+nDopr2X+nDopr3X+nDopr5X+nDopr6X+nDopr7X+nPorNaPlatu-nPorOlaksice+nOstaleObaveze,9,2)", "FormNum1(nDopr1X+nDopr2X+nDopr3X+nDopr5X+nDopr6X+nDopr7X+nPorNaPlatu-nPorOlaksice+nOstaleObaveze,9,gPici3)" }

   CASE cVar=="9E"
       cVrati := { "" , "STR(aSpec[6,4]+nDopr1X+nDopr2X+nDopr3X+nDopr5X+nDopr6X+nDopr7X+nPorNaPlatu+nOstaleObaveze,9,2)", "FormNum1(aSpec[6,4]+nDopr1X+nDopr2X+nDopr3X+nDopr5X+nDopr6X+nDopr7X+nPorNaPlatu+nOstaleObaveze,9,gPici3)" }

   CASE cVar=="9F"
       cVrati := { "" , "STR(aSpec[6,4]+nBolPreko-nObustave+nPorOlaksice,9,2)", "FormNum1(aSpec[6,4]+nBolPreko-nObustave+nPorOlaksice,9,gPici3)" }

   CASE cVar=="O1"
       cVrati := { "" , "STR(nObustave,9,2)", "FormNum1(nObustave,9,gPici3)" }

   CASE cVar=="O2"
       cVrati := { "" , "STR(nBolPreko,9,2)", "FormNum1(nBolPreko,9,gPici3)" }

   CASE cVar=="C1"
       cVrati := { "" , "PADR(ccOO1,20)" }
   CASE cVar=="C2"
       cVrati := { "" , "PADR(ccOO2,20)" }
   CASE cVar=="C3"
       cVrati := { "" , "PADR(ccOO3,20)" }
   CASE cVar=="C4"
       cVrati := { "" , "PADR(ccOO4,20)" }

   CASE cVar=="D1"
       cVrati := { "" , "STR(nOstOb1,9,2)", "FormNum1(nOstOb1,9,gPici3)" }
   CASE cVar=="D2"
       cVrati := { "" , "STR(nOstOb2,9,2)", "FormNum1(nOstOb2,9,gPici3)" }
   CASE cVar=="D3"
       cVrati := { "" , "STR(nOstOb3,9,2)", "FormNum1(nOstOb3,9,gPici3)" }
   CASE cVar=="D4"
       cVrati := { "" , "STR(nOstOb4,9,2)", "FormNum1(nOstOb4,9,gPici3)" }

   CASE cVar=="B1"
       cVrati := { "K", "gPB_ON()" }
   CASE cVar=="B0"
       cVrati := { "K", "gPB_OFF()" }
   CASE cVar=="U1"
       cVrati := { "K", "gPU_ON()" }
   CASE cVar=="U0"
       cVrati := { "K", "gPU_OFF()" }
   CASE cVar=="I1"
       cVrati := { "K", "gPI_ON()" }
   CASE cVar=="I0"
       cVrati := { "K", "gPI_OFF()" }
 ENDCASE
RETURN cVrati



FUNCTION PRNKod_ON(cKod)
 LOCAL i:=0
  FOR i:=1 TO LEN(cKod)
    DO CASE
      CASE SUBSTR(cKod,i,1)=="U"
         gPU_ON()
      CASE SUBSTR(cKod,i,1)=="I"
         gPI_ON()
      CASE SUBSTR(cKod,i,1)=="B"
         gPB_ON()
    ENDCASE
  NEXT
RETURN (NIL)


FUNCTION PRNKod_OFF(cKod)
 LOCAL i:=0
  FOR i:=1 TO LEN(cKod)
    DO CASE
      CASE SUBSTR(cKod,i,1)=="U"
         gPU_OFF()
      CASE SUBSTR(cKod,i,1)=="I"
         gPI_OFF()
      CASE SUBSTR(cKod,i,1)=="B"
         gPB_OFF()
    ENDCASE
  NEXT
return (nil)
*}



function NazMjeseca(nMjesec)
*{
local aVrati:={"Januar","Februar","Mart","April","Maj","Juni","Juli",;
                "Avgust","Septembar","Oktobar","Novembar","Decembar","UKUPNO"}
if (nMjesec>0 .and. nMjesec<14)
	return aVrati[nMjesec]
else
	return ""
endif
*}


function Specif2()
*{

O_RADN
O_RJ
O_STRSPR
O_OPS
O_LD

cIdRj:=gRj
cMjesec:=gMjesec
cGodina:=gGodina
cObracun:=gObracun
gOstr:="D"
gTabela:=1
cMRad:="17"
cIdRadn:=space(6)
cStrSpr:=space(3)
cOpsSt:=space(4)
cOpsRad :=space(4)
qqRJ:=SPACE(60)

O_PARAMS

private cSection:="4"
private cHistory:=" "
private aHistory:={}

RPar("i4",@cMRad)

Box(,12,70)
do while .t.
 @ m_x+2,m_y+2 SAY "Radne jedinice: "  GET  qqRJ PICT "@!S25"
 @ m_x+3,m_y+2 SAY "Mjesec: "  GET  cmjesec  pict "99"
 if lViseObr
   @ m_x+3,col()+2 SAY "Obracun: " GET cObracun WHEN HelpObr(.t.,cObracun) VALID ValObr(.t.,cObracun)
 endif
 @ m_x+4,m_y+2 SAY "Godina: "  GET  cGodina  pict "9999"
 @ m_x+6,m_y+2 SAY "Sifra minulog rada" GET cMRad VALID LD->(FIELDPOS("I"+cMRad))>0 .or. EMPTY(cMRad) PICT "99"
 @ m_x+7,m_y+2 SAY "Opstina stanovanja: "  GET  cOpsSt pict "@!" valid empty(cOpsSt) .or. P_Ops(@cOpsSt)
 @ m_x+8,m_y+2 SAY "Opstina rada:       "  GET  cOpsRad  pict "@!" valid empty(cOpsRad) .or. P_Ops(@cOpsRad)
 @ m_X+11, m_y+2 SAY "Ukljuceno ostranicavanje ? (D/N)" GET gOstr VALID gOstr$"DN" PICT "@!"
 @ m_X+11,m_y+38 SAY "Tip tabele (0/1/2)" GET gTabela VALID gTabela<3.and.gTabela>=0 PICT "9"
 read; clvbox(); ESC_BCR
 aUsl1:=Parsiraj(qqRJ,"IDRJ")
 aUsl2:=Parsiraj(qqRJ,"ID")
 if aUsl1<>NIL.and.aUsl2<>NIL; exit; endif
enddo
BoxC()

WPar("i4",cMRad)
select params
use

SELECT LD

Box(,2,30)
  nSlog:=0; nUkupno:=RECCOUNT2()
  cSort1 := "IDSTRSPR"
  cFilt  := "Tacno(aUsl1) .and. cGodina==GODINA .and. cMjesec==MJESEC .and. ImaUOps(cOpsSt,cOpsRad)"
  if lViseObr .and. !EMPTY(cObracun)
    cFilt += ( ".and. OBR==" + cm2str(cObracun) )
  endif
  INDEX ON &cSort1 TO "TMPLD" FOR &cFilt EVAL(TekRec2()) EVERY 1
BoxC()

GO TOP
if eof(); Msg("Ne postoje trazeni podaci...",6); closeret; endif

START PRINT CRET

PRIVATE cIdSS:="", cNIdSS:=""
PRIVATE nUkRad:=0, nUkMin:=0, nUkNet:=0, nSveUk:=0

aKol:={ { "STRUCNA SPREMA" , {|| cIdSS+"("+cNIdSS+")"},.f., "C",15, 0, 1, 1},;
        { "BR.RADNIKA"     , {|| nUKRad              },.t., "N",10, 0, 1, 2},;
        { "NETO"           , {|| nUkNet              },.t., "N",12, 2, 1, 3},;
        { "MINULI RAD"     , {|| nUkMin              },.t., "N",12, 2, 1, 4},;
        { "NETO-MINULI RAD", {|| nSveUk              },.t., "N",12, 2, 1, 5} }

P_10CPI

?? gnFirma
?
? "Mjesec:",str(cmjesec,2)+IspisObr()
?? "    Godina:",str(cGodina,5)

O_RJ
select rj

? "Obuhvacene radne jedinice: "

if !EMPTY(qqRJ)
	SET FILTER TO &aUsl2
  	GO TOP
  	do while !eof()
    		?? field->id+" - "+field->naz
    		? SPACE(27)
    		SKIP 1
  	enddo
else
	?? "SVE"
  	?
endif

SELECT LD

? "Opstina stanovanja :",;
    IF( EMPTY(cOpsSt) , "SVE" , Ocitaj(F_OPS,cOpsSt,"id+'-'+naz") )
? "Opstina rada       :",;
    IF( EMPTY(cOpsRad) , "SVE" , Ocitaj(F_OPS,cOpsRad,"id+'-'+naz") )
?

StampaTabele(aKol,{|| FSvaki1()},,gTabela,,;
     ,"SPECIFIKACIJA NETA I MINULOG RADA PO OPSTINAMA I RAD.JEDINICAMA",;
                             {|| FFor1()},IF(gOstr=="D",,-1),,,,,)
FF

END PRINT

CLOSERET
return
*}


function FFor1()
*{
cIdSS:=_FIELD->IDSTRSPR
 nUKRad:=nUkMin:=nUkNet:=nSveUk:=0
 cNIdSS:=Ocitaj(F_STRSPR,_FIELD->IDSTRSPR,"TRIM(naz)")
 DO WHILE !EOF() .and. cIdSS==_FIELD->IDSTRSPR
   if ! ( lViseObr .and. EMPTY(cObracun) .and. obr<>"1" )
     nUkRad++
   endif
   nUkMin += &("I"+cMRad)
   nUkNet += _FIELD->UNETO
   SKIP 1
 ENDDO
 nSveUk := nUkNet - nUkMin
 SKIP -1
RETURN .t.


function FSvaki1()
*{
return
*}

function TekRec2()
*{
nSlog++
@ m_x+1, m_y+2 SAY PADC(ALLTRIM(STR(nSlog))+"/"+ALLTRIM(STR(nUkupno)),20)
@ m_x+2, m_y+2 SAY "Obuhvaceno: "+STR(cmxKeysIncluded())
return (NIL)
*}


function ImaUOps(cOStan,cORada)
*{
LOCAL lVrati:=.f.
 IF ( EMPTY(cOStan) .or. Ocitaj(F_RADN,_FIELD->IDRADN,"IDOPSST")==cOStan ) .and.;
    ( EMPTY(cORada) .or. Ocitaj(F_RADN,_FIELD->IDRADN,"IDOPSRAD")==cORada )
   lVrati:=.t.
 ENDIF
RETURN lVrati
*}




function SpecifPoMjes()
*{
gnLMarg:=0
gTabela:=1
gOstr:="N"
cIdRj:=gRj
cGodina:=gGodina
cIdRadn:=SPACE(6)
cSvaPrim:="S"
qqOstPrim:=""
cSamoAktivna:="D"

O_LD

PraviMTEMP()

// copy structure extended to struct
// USE
// create MTEMP from struct
CLOSE ALL

O_RJ
O_STRSPR
O_OPS
O_RADN
O_LD
O_PARAMS

private cSection:="6"
private cHistory:=" "
private aHistory:={}

RPar("p1",@cIdRadn)
RPar("p2",@cSvaPrim)
RPar("p3",@qqOstPrim)
RPar("p4",@cSamoAktivna)
qqOstPrim:=PADR(qqOstPrim,100)

cPrikKolUk:="D"

Box(,7,77)

@ m_x+1,m_y+2 SAY "Radna jedinica (prazno sve): "  GET cIdRJ
@ m_x+2,m_y+2 SAY "Godina: "  GET  cGodina  pict "9999"
@ m_x+3,m_y+2 SAY "Radnik (prazno-svi radnici): "  GET  cIdRadn  valid empty(cIdRadn) .or. P_Radn(@cIdRadn)

@ m_x+4,m_y+2 SAY "Prikazati primanja (N-neto,V-van neta,S-sva primanja,0-nista)" GET cSvaPrim PICT "@!" VALID cSvaPrim$"NVS0"
@ m_x+5,m_y+2 SAY "Ostala primanja za prikaz (navesti sifre npr. 25;26;27;):" GET qqOstPrim PICT "@S15"
@ m_x+6,m_y+2 SAY "Prikazati samo aktivna primanja ? (D/N)" GET cSamoAktivna PICT "@!" VALID cSamoAktivna$"DN"
@ m_x+7,m_y+2 SAY "Prikazati kolonu 'ukupno' ? (D/N)" GET cPrikKolUk PICT "@!" VALID cPrikKolUk$"DN"

read
ESC_BCR

BoxC()

qqOstPrim:=TRIM(qqOstPrim)
WPar("p1",cIdRadn)
WPar("p2",cSvaPrim)
WPar("p3",qqOstPrim)
WPar("p4",cSamoAktivna)
SELECT PARAMS
USE

SELECT 0
#ifdef CAX
    if !used()
      AX_AutoOpen(.f.); usex (PRIVPATH+"MTEMP")  ; AX_AutoOpen(.t.)
    endif
  #else
    usex (PRIVPATH+"MTEMP")
  #endif

// USEX MTEMP ALIAS MTEMP NEW

O_TIPPR

SELECT LD

PRIVATE cFilt1 := "GODINA=="+cm2str(cGodina)+;
		  IF(EMPTY(cIdRJ),"",".and.IDRJ=="+cm2str(cIdRJ))+;
		  IF(EMPTY(cIdRadn),"",".and.IDRADN=="+cm2str(cIdRadn))

SET FILTER TO &cFilt1
SET ORDER TO TAG "2"
GO TOP

DO WHILE !EOF()
  cMjesec:=mjesec
  DO WHILE !EOF() .and. cMjesec==mjesec
    SELECT MTEMP
    IF MTEMP->mjesec!=cMjesec
      APPEND BLANK
      REPLACE mjesec WITH cMjesec
    ENDIF
    FOR i:=1 TO cLDPolja
      cSTP := PADL(ALLTRIM(STR(i)),2,"0")
      IF cSvaPrim!="S" .and. !(cSTP $ qqOstPrim)
        SELECT TIPPR; HSEEK cSTP; SELECT MTEMP
        IF cSvaPrim=="N" .and. TIPPR->uneto=="N" .or.;
           cSvaPrim=="V" .and. TIPPR->uneto=="D" .or.;
           cSvaPrim=="0"
          LOOP
        ENDIF
      ENDIF
      cNPPI := "I"+cSTP
      cNPPS := "S"+cSTP
      nFPosI := FIELDPOS(cNPPI)
      nFPosS := FIELDPOS(cNPPS)
      IF nFPosI>0
        FIELDPUT( nFPosI , FIELDGET(nFPosI) + LD->(FIELDGET(nFPosI)) )
        if ! ( lViseObr .and. LD->obr<>"1" ) // samo sati iz 1.obracuna
          FIELDPUT( nFPosS , FIELDGET(nFPosS) + LD->(FIELDGET(nFPosS)) )
        endif
      ELSE
        EXIT
      ENDIF
    NEXT
    SELECT LD
    SKIP 1
  ENDDO
ENDDO


nSum:={}
aKol:={}

nKol:=1
nRed:=0
nKorekcija:=0

nPicISUk := IF(cPrikKolUk=="D",9,10)  // ako nema kolone ukupno mo§e i 10
nPicSDec := Decimala( gPicS )
nPicIDec := Decimala( gPicI )

NUK := IF(cPrikKolUk=="D",13,12)   // ukupno kolona za iznose

FOR i:=1 TO cLDPolja

  cSTP := PADL(ALLTRIM(STR(i)),2,"0")

  cNPPI := "I"+cSTP
  cNPPS := "S"+cSTP

  SELECT TIPPR; HSEEK cSTP; cAktivno := aktivan
  SELECT LD

  IF FIELDPOS(cNPPI) > 0

    IF ( cSamoAktivna=="N" .or. UPPER(cAktivno)=="D" ) .and.;
       ( cSvaPrim=="S" .or. cSTP $ qqOstPrim .or.;
         cSvaPrim=="N" .and. TIPPR->uneto=="D" .or.;
         cSvaPrim=="V" .and. TIPPR->uneto=="N" )

      cNPrim := "{|| '"+cSTP + "-" +;
                TIPPR->naz+"'}"

      AADD(aKol, { IF((i-nKorekcija)==1,"TIP PRIMANJA","") , &cNPrim. , .f., "C", 25, 0, 2*(i-nKorekcija)-1, 1 } )

      FOR j:=1 TO NUK

        cPomMI := "nSum["+ALLTRIM(STR(i-nKorekcija))+","+ALLTRIM(STR(j))+",1]"
        cPomMS := "nSum["+ALLTRIM(STR(i-nKorekcija))+","+ALLTRIM(STR(j))+",2]"

        AADD(aKol, { IF(i-nKorekcija==1,NazMjeseca(j),""), {|| &cPomMI.}, .f., "N", nPicISUk+IF(j>12,1,0), nPicIDec, 2*(i-nKorekcija)-1, j+1} )
        AADD(aKol, { IF(i-nKorekcija==1,"IZNOS/SATI","") , {|| &cPomMS.}, .f., "N", nPicISUk+IF(j>12,1,0), nPicSDec, 2*(i-nKorekcija)  , j+1} )

      NEXT

    ELSE

      nKorekcija+=1

    ENDIF

  ELSE
    EXIT
  ENDIF

NEXT

// dodati sumu svega (red "UKUPNO")
// --------------------------------
AADD(aKol, { "", {|| REPL("=",25)}, .f., "C", 25, 0, 2*(i-nKorekcija)-1, 1 } )

AADD(aKol, { "", {|| "U K U P N O"    }, .f., "C", 25, 0, 2*(i-nKorekcija), 1 } )
FOR j:=1 TO NUK
  cPomMI := "nSum["+ALLTRIM(STR(i-nKorekcija))+","+ALLTRIM(STR(j))+",1]"
  cPomMS := "nSum["+ALLTRIM(STR(i-nKorekcija))+","+ALLTRIM(STR(j))+",2]"

  AADD(aKol, { "", {|| &cPomMI.}, .f., "N", nPicISUk+IF(j>12,1,0), nPicIDec, 2*(i-nKorekcija)  , j+1} )
  AADD(aKol, { "", {|| &cPomMS.}, .f., "N", nPicISUk+IF(j>12,1,0), nPicSDec, 2*(i-nKorekcija)+1, j+1} )
NEXT
// --------------------------------

nSumLen:=i-1-nKorekcija+1
nSum:=ARRAY(nSumLen,NUK,2)
FOR k:=1 TO nSumLen
  FOR j:=1 TO NUK
    FOR l:=1 TO 2
       nSum[k,j,l] := 0
    NEXT
  NEXT
NEXT

SELECT MTEMP
GO TOP

START PRINT CRET

P_12CPI

?? space(gnLMarg); ?? "LD: Izvjestaj na dan",date()
? space(gnLMarg); IspisFirme("")
? space(gnLMarg); ?? "RJ: "; B_ON; ?? IF( EMPTY(cIdRJ) , "SVE" , cIdRJ ); B_OFF
?? "  GODINA: "; B_ON; ?? cGodina; B_OFF
? "RADNIK: "
IF EMPTY(cIdRadn)
 ?? "SVI"
ELSE
 SELECT (F_RADN); HSEEK cIdRadn
 SELECT (F_STRSPR); HSEEK RADN->idstrspr
 SELECT (F_OPS); HSEEK RADN->idopsst; cOStan:=naz
 HSEEK RADN->idopsrad
 SELECT (F_RADN)
 B_ON; ?? cIdRadn+"-"+trim(naz)+' ('+trim(imerod)+') '+ime; B_OFF
 ? "Br.knjiz: "; B_ON; ?? brknjiz; B_OFF
 ?? "  Mat.br: "; B_ON; ?? matbr; B_OFF
 ?? "  R.mjesto: "; B_ON; ?? rmjesto; B_OFF

 ? "Min.rad: "; B_ON; ?? kminrad; B_OFF
 ?? "  Str.spr: "; B_ON; ?? STRSPR->naz; B_OFF
 ?? "  Opst.stan: "; B_ON; ?? cOStan; B_OFF

 ? "Opst.rada: "; B_ON; ?? OPS->naz; B_OFF
 ?? "  Dat.zasn.rad.odnosa: "; B_ON; ?? datod; B_OFF
 ?? "  Pol: "; B_ON; ?? pol; B_OFF
 SELECT MTEMP
ENDIF

#ifdef CPOR
StampaTabele(aKol,{|| FSvaki3()},,gTabela,,;
     ,"Specifikacija primanja po mjesecima"+IF(lIsplaceni,"","-neisplaceni"),;
                             {|| FFor3()},IF(gOstr=="D",,-1),,,,,)
#else
StampaTabele(aKol,{|| FSvaki3()},,gTabela,,;
     ,"Specifikacija primanja po mjesecima",;
                             {|| FFor3()},IF(gOstr=="D",,-1),,,,,,.f.)
#endif

select ld

FF
END PRINT

return

*}

FUNCTION FFor3()
 LOCAL nArr:=SELECT()
 DO WHILE !EOF()
   nKorekcija:=0
   FOR i:=1 TO cLDPolja
     cSTP := PADL(ALLTRIM(STR(i)),2,"0")
     cNPPI := "I"+cSTP
     cNPPS := "S"+cSTP
     SELECT TIPPR; HSEEK cSTP; cAktivno:=aktivan
     SELECT (nArr)
     nFPosI := FIELDPOS(cNPPI)
     nFPosS := FIELDPOS(cNPPS)
     IF nFPosI>0
       IF ( cSamoAktivna=="N" .or. UPPER(cAktivno)=="D" ) .and.;
          ( cSvaPrim=="S" .or. cSTP $ qqOstPrim .or.;
            cSvaPrim=="N" .and. TIPPR->uneto=="D" .or.;
            cSvaPrim=="V" .and. TIPPR->uneto=="N" )
         nSum[i-nKorekcija,mjesec,1] := FIELDGET(nFPosI)
              nSum[nSumLen,mjesec,1] += FIELDGET(nFPosI)
         nSum[i-nKorekcija,mjesec,2] := FIELDGET(nFPosS)
              nSum[nSumLen,mjesec,2] += FIELDGET(nFPosS)

         IF NUK>12
           // kolona 13.mjeseca tj."ukupno" iznos
           nSum[i-nKorekcija,NUK,1] += FIELDGET(nFPosI)
           // red ukupno kolone 13.mjeseca tj."sveukupno" iznos
                nSum[nSumLen,NUK,1] += FIELDGET(nFPosI)
           // kolona 13.mjeseca tj."ukupno" sati
           nSum[i-nKorekcija,NUK,2] += FIELDGET(nFPosS)
           // red ukupno kolone 13.mjeseca tj."sveukupno" sati
                nSum[nSumLen,NUK,2] += FIELDGET(nFPosS)
         ENDIF
       ELSE
         nKorekcija+=1
       ENDIF
     ELSE
       EXIT
     ENDIF
   NEXT
   SKIP 1
 ENDDO
// SKIP -1
RETURN .t.


PROCEDURE FSvaki3()
RETURN



FUNCTION Izrezi(cPoc,nIza,cOstObav)
  LOCAL cVrati:="", nPoz:=0
  DO WHILE (nPoz:=AT(cPoc,cOstObav)) > 0
    cVrati := cVrati + SUBSTR(cOstObav,nPoz+LEN(cPoc),nIza) + ";"
    cOstObav:=STUFF(cOstObav,nPoz,LEN(cPoc)+nIza,"")
    cOstObav:=STRTRAN(cOstObav,";;",";")
  ENDDO
RETURN cVrati


FUNCTION FormNum1(nIznos,nDuz,pici)
 LOCAL cVrati
 cVrati:=TRANSFORM(nIznos,pici)
 cVrati:=STRTRAN(cVrati,".",":")
 cVrati:=STRTRAN(cVrati,",",".")
 cVrati:=STRTRAN(cVrati,":",",")
 cVrati:=ALLTRIM(cVrati)
 cVrati:=IF(LEN(cVrati)>nDuz,REPL("*",nDuz),PADL(cVrati,nDuz))
RETURN cVrati


FUNCTION FormNum2(nIznos,nDuz,pici)
 return alltrim(formnum1(nIznos,nDuz,pici))



PROCEDURE Specif3()

O_RADN
O_RJ
O_STRSPR
O_OPS
O_LD

cIdRj:=gRj; cmjesec:=gMjesec; cMjesecDo:=gMjesec
cGodina:=gGodina
cObracun:=gObracun
gOstr:="D"; gTabela:=1

cIdRadn:=space(6)
cStrSpr:=space(3)
cOpsSt:=space(4)
cOpsRad :=space(4)

qqRJ:=SPACE(60)

// O_PARAMS
// Private cSection:="4",cHistory:=" ",aHistory:={}
// RPar("i4",@cMRad)

Box(,11,70)
do while .t.
 @ m_x+ 2, m_y+ 2 SAY "Radne jedinice: "  GET  qqRJ PICT "@!S25"
 @ m_x+ 3, m_y+ 2 SAY "Od mjeseca: "  GET  cmjesec  pict "99"
 @ m_x+ 3, col()+2 SAY "do mjeseca: "  GET  cmjesecdo  pict "99"
 if lViseObr
   @ m_x+ 3, col()+2 SAY "Obracun: "  GET  cObracun WHEN HelpObr(.t.,cObracun) VALID ValObr(.t.,cObracun)
 endif
 @ m_x+ 4, m_y+ 2 SAY "Godina: "  GET  cGodina  pict "9999"
 @ m_x+ 6, m_y+ 2 SAY "Opstina stanovanja: "  GET  cOpsSt pict "@!" valid empty(cOpsSt) .or. P_Ops(@cOpsSt)
 @ m_x+ 7, m_y+ 2 SAY "Opstina rada:       "  GET  cOpsRad  pict "@!" valid empty(cOpsRad) .or. P_Ops(@cOpsRad)
 @ m_X+10, m_y+ 2 SAY "Ukljuceno ostranicavanje ? (D/N)" GET gOstr VALID gOstr$"DN" PICT "@!"
 @ m_X+10, m_y+38 SAY "Tip tabele (0/1/2)" GET gTabela VALID gTabela<3.and.gTabela>=0 PICT "9"
 read; clvbox(); ESC_BCR
 aUsl1:=Parsiraj(qqRJ,"IDRJ")
 aUsl2:=Parsiraj(qqRJ,"ID")
 if aUsl1<>NIL.and.aUsl2<>NIL; exit; endif
enddo
BoxC()

// WPar("i4",cMRad)
// select params; use

SELECT LD

Box(,2,30)
  nSlog:=0; nUkupno:=RECCOUNT2()
  cSort1 := "IDSTRSPR"
  cFilt  := aUsl1+" .and. cGodina==GODINA .and."+IF(cMjesec<>cMjesecdo," cMjesec<=MJESEC .and. cMjesecDo>=MJESEC"," cMjesec==MJESEC")+" .and. ImaUOps(cOpsSt,cOpsRad)"
  if lViseObr .and. !empty(cObracun)
    cFilt += ( ".and. OBR==" + cm2str(cObracun) )
  endif
  INDEX ON &cSort1 TO "TMPLD" FOR &cFilt EVAL(TekRec2()) EVERY 1
BoxC()

GO TOP
if eof(); Msg("Ne postoje trazeni podaci...",6); closeret; endif

START PRINT CRET

PRIVATE cIdSS:="", cNIdSS:=""
PRIVATE nUkRad:=0, nUkNet:=0, nSUkRad:=0, nSUkNet:=0

aKol:={ { "STRUCNA SPREMA" , {|| cIdSS+"("+cNIdSS+")"},.f., "C" ,15, 0, 1, 1},;
        { "(1)"            , {|| "#"                 },.f., "C" ,15, 0, 2, 1},;
        { "BR.RADNIKA"     , {|| nUKRad              },.f., "N" ,10, 0, 1, 2},;
        { "(2)"            , {|| "#"                 },.f., "C" ,10, 0, 2, 2},;
        { "NETO"           , {|| nUkNet              },.f., "N" ,12, 2, 1, 3},;
        { "(3)"            , {|| "#"                 },.f., "C" ,12, 0, 2, 3},;
        { "PROSJECNI NETO" , {|| IF(nUkRad==0,0,nUkNet/nUkRad) },.f., "N-",16, 2, 1, 4},;
        { "(4) = (3)/(2)"  , {|| "#"                 },.f., "C" ,16, 0, 2, 4} }

P_10CPI
?? gnFirma
?
IF cMjesec==cMjesecDo
  ? "Mjesec:",str(cmjesec,2)+IspisObr()
  ?? "    Godina:",str(cGodina,5)
ELSE
  ? "Od mjeseca:",str(cmjesec,2)+".","do mjeseca:",str(cmjesecdo,2)+"."+IspisObr()
  ?? "    Godina:",str(cGodina,5)
ENDIF

O_RJ
SELECT RJ
? "Obuhvacene radne jedinice: "
IF !EMPTY(qqRJ)
  SET FILTER TO &aUsl2
  GO TOP
  DO WHILE !EOF()
    ?? id+" - "+naz
    ? SPACE(27)
    SKIP 1
  ENDDO
ELSE
  ?? "SVE"
  ?
ENDIF
SELECT LD
? "Opstina stanovanja :",;
    IF( EMPTY(cOpsSt) , "SVE" , Ocitaj(F_OPS,cOpsSt,"id+'-'+naz") )
? "Opstina rada       :",;
    IF( EMPTY(cOpsRad) , "SVE" , Ocitaj(F_OPS,cOpsRad,"id+'-'+naz") )
?

gaDodStavke:={}

StampaTabele(aKol,{|| FSvaki31()},,gTabela,,;
     ,"SPECIFIKACIJA PROSJECNOG NETA PO STRUCNOJ SPREMI",;
                             {|| FFor31()},IF(gOstr=="D",,-1),,,,,)

END PRINT

CLOSERET


FUNCTION FFor31()
 gaDodStavke := {}
 cIdSS:=_FIELD->IDSTRSPR
 nUKRad:=nUkNet:=0
 cNIdSS:=Ocitaj(F_STRSPR,_FIELD->IDSTRSPR,"TRIM(naz)")
 DO WHILE !EOF() .and. cIdSS==_FIELD->IDSTRSPR
   IF ! ( lViseObr .and. EMPTY(cObracun) .and. _FIELD->OBR<>"1" )
     nUkRad++
   ENDIF
   nUkNet += _FIELD->UNETO
   SKIP 1
 ENDDO
 nSUkRad += nUkRad
 nSUkNet += nUkNet
 IF EOF()
   gaDodStavke  := { { "UKUPNO", nSUkRad , nSUkNet , IF(nSUkRad==0,0,nSUkNet/nSUkRad) } }
 ENDIF
 SKIP -1
RETURN .t.


FUNCTION FSvaki31()
RETURN IF(!EMPTY(gaDodStavke),"PODVUCI"+"=",NIL)



PROCEDURE PraviMTEMP()
 LOCAL i:=0
  //benjo, 21.04.04, dodat uslov zbog toga jer na Win98 ne dozvoljava brisanje  
  //                 datoteke ako je otvorena u nekom radnom podrucju.
  if select("MTEMP")>0
  	MTEMP->( dbclosearea() )
  endif
  
  IF ferase(PRIVPATH+"MTEMP.DBF")==-1
    MsgBeep("Ne mogu izbrisati MTEMP.DBF!")
    ShowFError()
  ENDIF
  aDbf:=LD->(DBSTRUCT())

  // ovdje cemo sva numericka polja prosiriti za 4 mjesta
  // (izuzeci su polja GODINA i MJESEC)
  // ----------------------------------------------------
  FOR i:=1 TO LEN(aDbf)
    IF aDbf[i,2]=="N" .and. !( UPPER(TRIM(aDbf[i,1])) $ "GODINA#MJESEC" )
      aDbf[i,3] += 4
    ENDIF
  NEXT

  DBCREATE2 (PRIVPATH+"MTEMP", aDbf)
RETURN



// ----------------------------
// Porezi i Doprinosi Iz Sezone
// ---------------------------------------------------------------------
// Ova procedura ispituje da li je za izraŸunavanje poreza i doprinosa
// u izvjeçtaju potrebno koristiti çifrarnike iz sezone. Ako se ustanovi
// da ovi çifrarnici postoje u sezoni 'MMGGGG' podrazumijeva se da njih
// treba koristiti za izvjeçtaj. U tom sluŸaju zatvaraju se postoje†i
// çifrarnici POR i DOPR iz radnog podruŸja, a umjesto njih otvaraju se
// sezonski.
// ---------------------------------------------------------------------
// cG - izvjeçtajna godina, cM - izvjeçtajni mjesec
// ---------------------------------------------------------------------
// Ukoliko izvjeçtaj koristi baze POR i/ili DOPR, one moraju biti
// otvorene prije pokretanje ove procedure.
// Ovu proceduru najbolje je pozivati odmah nakon upita za izvjeçtajnu
// godinu i mjesec (prije toga nema svrhe), a prije glavne izvjeçtajne
// petlje.
// ---------------------------------------------------------------------
PROCEDURE PoDoIzSez(cG,cM)
 LOCAL nArr:=SELECT(), cPath, aSez, i, cPom, lPor, lDopr, cPorDir, cDoprDir
  IF cG==NIL .or. cM==NIL; RETURN; ENDIF
  IF VALTYPE(cG)=="N"; cG:=STR(cG,4,0)                 ; ENDIF
  IF VALTYPE(cM)=="N"; cM:=PADL(ALLTRIM(STR(cM)),2,"0"); ENDIF

  cPath   := SIFPATH

  aSez := ASezona2(cPath,cG)

  IF LEN(aSez)<1; RETURN; ENDIF

  lPor    := lDopr    := .f.
  cPorDir := cDoprDir := ""
  FOR i:=1 TO LEN(aSez)
    cPom := TRIM(aSez[i,1])
    IF LEFT(cPom,2) >= cM
      IF FILE(cpath+cPom+"\POR.DBF")
        lPor     := .t.
        cPorDir  := cPom
      ENDIF
      IF FILE(cpath+cPom+"\DOPR.DBF")
        lDopr    := .t.
        cDoprDir := cPom
      ENDIF
    ELSE
      EXIT
    ENDIF
  NEXT

  IF lPor
    SELECT (F_POR); USE
    USE (cPath+cPorDir+"\POR")   ; SET ORDER TO TAG "ID"
  ENDIF

  IF lDopr
    SELECT (F_DOPR); USE
    USE (cPath+cDoprDir+"\DOPR") ; SET ORDER TO TAG "ID"
  ENDIF

  SELECT (nArr)
RETURN

*************************************************************
FUNCTION Razrijedi (cStr)
*
*   Razrijedi (cStr) --> cStrRazr
*      Ubaci u string, izmedju slova, SPACE()
*
*************************************************************
LOCAL cRazrStr, nLenM1, nCnt
cStr := ALLTRIM (cStr)
nLenM1 := LEN (cStr) - 1
cRazrStr := ""
FOR nCnt := 1 TO nLenM1
  cRazrStr += SUBSTR (cStr, nCnt, 1) + " "
NEXT
cRazrStr += RIGHT (cStr, 1)
RETURN (cRazrStr)



FUNC ASezona2(cPath,cG,cFajl)
 LOCAL aSez, i, cPom
  IF cFajl==NIL; cFajl:=""; ENDIF
  aSez := DIRECTORY(cPath+"*.","DV")
  FOR i:=LEN(aSez) TO 1 STEP -1
    IF aSez[i,1]=="." .or. aSez[i,1]==".."
      ADEL(aSez,i)
      ASIZE(aSez,LEN(aSez)-1)
    ENDIF
  NEXT
  FOR i:=LEN(aSez) TO 1 STEP -1
    cPom := TRIM(aSez[i,1])
    IF LEN(cPom)<>6 .or. RIGHT(cPom,4)<>cG .or.;
       !EMPTY(cFajl) .and. !FILE(cPath+cPom+"\"+cFajl)
      ADEL(aSez,i)
      ASIZE(aSez,LEN(aSez)-1)
    ENDIF
  NEXT
  ASORT( aSez ,,, { |x,y| x[1] > y[1] } )
RETURN aSez


FUNC Cijelih(cPic)
 LOCAL nPom := ATTOKEN( ALLTRIM(cPic) , "." , 2 ) - 2
RETURN IF( nPom<1 , LEN(ALLTRIM(cPic)) , nPom )

FUNC Decimala(cPic)
 LOCAL nPom := ATTOKEN( ALLTRIM(cPic) , "." , 2 )
RETURN IF( nPom<1 , 0 ,  LEN( SUBSTR( ALLTRIM(cPic) , nPom ) )  )



function OSpecif()
*{
O_DOPR
O_POR
O_PAROBR
O_KBENEF
O_VPOSLA
O_RJ
O_RADN
O_PARAMS
O_LD
O_OPS

return
*}


