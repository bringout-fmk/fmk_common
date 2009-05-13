#include "ld.ch"

static __var_obr


// ----------------------------------------
// ----------------------------------------
function Rekap(lSvi)
private nC1:=20
private i
private cTPNaz
private cUmPD:="N"
private nKrug:=1
private nUPorOl:=0
private cFilt1:=""
private cNaslovRekap:=Lokal("LD: Rekapitulacija primanja")
private aUsl1, aUsl2
private aNetoMj

lPorNaRekap:=IzFmkIni("LD","PoreziNaRekapitulaciji","N",KUMPATH)=="D"

cIdRadn:=SPACE(_LR_)
cIdRj:=gRj
cMjesec:=gMjesec
cGodina:=gGodina
cObracun:=gObracun
cMjesecDo:=cMjesec
nStrana:=0
cRTipRada := " "
aUkTr:={}

if lSvi==nil
	lSvi:=.f.
endif

ORekap()

cIdRadn:=SPACE(6)
cStrSpr:=SPACE(3)
cOpsSt:=SPACE(4)
cOpsRad:=SPACE(4)
cK4:="S"

if lSvi
	qqRJ:=SPACE(60)
	BoxRekSvi()
	if (LastKey()==K_ESC)
		return
	endif
else
	qqRJ:=SPACE(2)
	BoxRekJ()
	if (LastKey()==K_ESC)
		return
	endif
endif

select ld
	
if lViseObr
	cObracun:=TRIM(cObracun)
else
	cObracun:=""
endif

if lSvi
	set order to tag (TagVO("2"))
else
	set order to tag (TagVO("1"))
endif

if lSvi
	
	cFilt1:=".t." + IF(EMPTY(cStrSpr),"",".and.IDSTRSPR=="+cm2str(cStrSpr))+IF(EMPTY(qqRJ),"",".and."+aUsl1)
	
	if cMjesec!=cMjesecDo
  		cFilt1:=cFilt1 + ".and.mjesec>="+cm2str(cMjesec)+".and.mjesec<="+cm2str(cMjesecDo)+".and.godina="+cm2str(cGodina)
	endif
	
	GO TOP

else

	cFilt1 := ".t." + IF(EMPTY(cStrSpr),"",".and.IDSTRSPR=="+cm2str(cStrSpr))
	if cMjesec!=cMjesecDo
  		cFilt1 := cFilt1 + ".and.mjesec>="+cm2str(cMjesec)+".and.mjesec<="+cm2str(cMjesecDo)+".and.godina="+cm2str(cGodina)
	endif

endif 	

if lViseObr
	cFilt1 += ".and. OBR="+cm2str(cObracun)
endif
	
cFilt1:=STRTRAN(cFilt1,".t..and.","")

if cFilt1==".t."
	SET FILTER TO
else
	SET FILTER TO &cFilt1
endif

if !lSvi
	seek STR(cGodina,4)+cIdRj+STR(cMjesec,2)+cObracun
	EOF CRET
else
  	seek str(cGodina,4)+STR(cMjesec,2)+cObracun
	EOF CRET
endif

PoDoIzSez(cGodina, cMjesecDo)

if !lPorNaRekap
   cLinija:="------------------------  ----------------               -------------------"
else
   cLinija:="------------------------  ---------------  ---------------  -------------"
endif

CreOpsLD()
CreRekLD()

O_REKLD
O_OPSLD

select ld

START PRINT CRET
?
P_10CPI

if IzFMKIni("LD","RekapitulacijaGustoPoVisini","N",KUMPATH)=="D"
	lGusto:=.t.
  	gRPL_Gusto()
  	nDSGusto:=VAL(IzFMKIni("RekapGustoPoVisini","DodatnihRedovaNaStranici","11",KUMPATH))
  	gPStranica+=nDSGusto
else
  	lGusto:=.f.
  	nDSGusto:=0
endif

// samo pozicionira bazu PAROBR na odgovarajuci zapis
ParObr(cmjesec, cGodina, IIF(lViseObr,cObracun,), IIF(!lSvi,cIdRj,))

private aRekap[cLDPolja,2]

for i:=1 to cLDPolja
	aRekap[i,1]:=0
  	aRekap[i,2]:=0
next

nT1:=nT2:=nT3:=nT4:=0
nUNeto:=0
nUNetoOsnova:=0
nDoprOsnova := 0
nDoprOsnOst := 0
nULOdbitak := 0
nUBNOsnova:=0
nUDoprIz := 0
nUIznos:=0
nPorOsnova:=0
nPorNROsnova:=0
nUPorNROsnova:=0
nUSati:=0
nUOdbici:=0
nUOdbiciP:=0
nUOdbiciM:=0
nLjudi:=0
nKoefLO:=0

private aNeta:={}

select ld

if cMjesec!=cMjesecDo
	if lSvi
   		go top
		private bUslov:={|| godina==cGodina .and. mjesec>=cMjesec .and. mjesec<=cMjesecDo .and. IF(lViseObr,obr=cObracun,.t.) }
 	else
   		private bUslov:={|| godina==cGodina .and. idrj==cIdRj .and. mjesec>=cMjesec .and. mjesec<=cMjesecDo .and. IF(lViseObr,obr=cObracun,.t.) }
 	endif
else
 	if lSvi
   		private bUslov:={|| cgodina==godina .and. cmjesec=mjesec .and. IF(lViseObr,obr=cObracun,.t.) }
 	else
   		private bUslov:={|| cgodina==godina .and. cidrj==idrj .and. cmjesec=mjesec .and. IF(lViseObr,obr=cObracun,.t.) }
 	endif
endif

// napravi obracun
napr_obracun(lSvi)

if nLjudi==0
	nLjudi:=9999999
endif

B_ON
?? cNaslovRekap
B_OFF

if !empty(cstrspr)
	?? SPACE(1) + Lokal("za radnike strucne spreme") + SPACE(1),cStrSpr
endif

if !empty(cOpsSt)
	? Lokal("Opstina stanovanja:"),cOpsSt
endif

if !empty(cOpsRad)
	? Lokal("Opstina rada:"),cOpsRad
endif

if lSvi
	ZaglSvi()
else
	ZaglJ()
endif

if lPorNaRekap
	? SPACE(60) + Lokal("Porez:") + STR(por->iznos) + "%"
endif

? cLinija

// ispisi tipove primanja...
IspisTP(lSvi)

if IzFmkIni("LD","Rekap_ZaIsplatuRasclanitiPoTekRacunima","N",KUMPATH)=="D" .and. LEN(aUkTR)>1
	PoTekRacunima()
endif

? cLinija

nPosY := 60
if lPorNaRekap
	nPosY := 42
endif

? Lokal("UKUPNO ZA ISPLATU")
@ prow(), nPosY SAY nUIznos pict gpici
?? "",gValuta

? cLinija

if !lGusto
	?
endif

ProizvTP()

// prikaz koeficijenta benef.
if cMjesec == cMjesecDo
	
	if !lGusto
		?
	endif
	
	PrikKBO()
	
	PrikKBOBenef()

endif

if cMjesec == cMjesecDo
	
	// obracunaj i prikazi poreze
	
	private nPor
	private nPor2 
	private nPorOps
	private nPorOps2
	
	obr_porez( @nPor, @nPor2, @nPorOps, @nPorOps2, @nUPorOl )
	
	if !lGusto
		?
 		?
	endif

	?

	if prow() > 55 + gpStranica
		FF
	endif

	private nDopr
	private nDopr2
	
	// obracunaj i prikazi doprinose
	obr_doprinos( @nDopr, @nDopr2 )

	if cUmPD == "D"
		P_10CPI
	endif

	?

	cLinija := "---------------------------------"

	if prow() > 49 + gPStranica
		FF
	endif

	? cLinija

	? "     " + Lokal("NETO PRIMANJA:")
	@ prow(),pcol()+1 SAY nUNeto pict gpici
	?? "(" + Lokal("za isplatu:")
	@ prow(),pcol()+1 SAY nUNeto+nUOdbiciM pict gpici
	?? "," + Lokal("Obustave:")
	@ prow(),pcol()+1 SAY -nUOdbiciM pict gpici
	?? ")"
	? " " + Lokal("PRIMANJA VAN NETA:")
	@ prow(),pcol()+1 SAY nUOdbiciP pict gpici  // dodatna primanja van neta
	? "            " + Lokal("POREZI:")
	IF cUmPD=="D"
		@ prow(),pcol()+1 SAY nPor-nUPorOl-nPor2    pict gpici
	ELSE
  		@ prow(),pcol()+1 SAY nPor-nUPorOl    pict gpici
	ENDIF
	? "         " + Lokal("DOPRINOSI:")
	IF cUmPD=="D"
  		@ prow(),pcol()+1 SAY nDopr-nDopr2    pict gpici
	ELSE
  		@ prow(),pcol()+1 SAY nDopr    pict gpici
	ENDIF
	? cLinija
	IF cUmPD=="D"
  		? Lokal(" POTREBNA SREDSTVA:")
  		@ prow(),pcol()+1 SAY nUNeto+nUOdbiciP+(nPor-nUPorOl)+nDopr-nPor2-nDopr2    pict gpici
	ELSE
  		? Lokal(" POTREBNA SREDSTVA:")
  		@ prow(),pcol()+1 SAY nUNeto+nUOdbiciP+(nPor-nUPorOl)+nDopr    pict gpici
	ENDIF
	? cLinija
	?
	? Lokal("Izvrsena obrada na") + " ",str(nLjudi,5), Lokal("radnika")
	?
	if nUSati==0
		nUSati:=999999
	endif
	? Lokal("Prosjecni neto/satu je"),alltrim(transform(nUNeto,gpici)),"/",alltrim(str(nUSati)),"=",alltrim(transform(nUNeto/nUsati,gpici)),"*",alltrim(transform(parobr->k1,"999")),"=",alltrim(transform(nUneto/nUsati*parobr->k1,gpici))

ELSE 
	// cMjesec == cMjesecDo 
	// za vise mjeseci nema prikaza poreza i doprinosa
  	// ali se moze dobiti bruto osnova i prosjecni neto po satu
  	ASORT(aNetoMj,,,{|x,y| x[1]<y[1]})
  	?
  	?     Lokal("MJESEC³  UK.NETO  ³UK.SATI³KOEF.BRUTO³FOND SATI³BRUTO OSNOV³PROSJ.NETO ")
  	?     " (A)  ³    (B)    ³  (C)  ³   (D)    ³   (E)   ³(B)*(D)/100³(E)*(B)/(C)"
  	? ms:="ÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄ"
  	nT1:=nT2:=nT3:=nT4:=nT5:=0
  	FOR i:=1 TO LEN(aNetoMj)
    		? STR(aNetoMj[i,1],4,0) +". ³"+;
      		TRANS(aNetoMj[i,2],gPicI) +"³"+;
     		STR(aNetoMj[i,3],7) +"³"+;
      		TRANS(aNetoMj[i,4],"999.99999%") +"³"+;
      		STR(aNetoMj[i,5],9) +"³"+;
      		TRANS(ROUND2(aNetoMj[i,2]*aNetoMj[i,4]/100,gZaok2),gPicI) +"³"+;
      		TRANS(aNetoMj[i,5]*aNetoMj[i,2]/aNetoMj[i,3],gPicI)
      		nT1 += aNetoMj[i,2]
      		nT2 += aNetoMj[i,3]
      		nT3 += aNetoMj[i,5]
      		nT4 += ROUND2(aNetoMj[i,2]*aNetoMj[i,4]/100,gZaok2)
      		nT5 += aNetoMj[i,5]*aNetoMj[i,2]/aNetoMj[i,3]
  	NEXT
  
  	nT5 := nT5/LEN(aNetoMj)
  	? ms
  	?     "UKUPNO³"+;
      		TRANS(nT1,gPicI) +"³"+;
      		STR(nT2,7) +"³"+;
      		"          "+"³"+;
      		STR(nT3,9) +"³"+;
      		TRANS(nT4,gPicI) +"³"+;
      		TRANS(nT5,gPicI)

ENDIF

P_10CPI
?
?
?  PADC("     " + Lokal("Obradio:") + "                                 " + Lokal("Direktor:") + "    ",80)
?
?  PADC("_____________________                    __________________",80)
?
FF

IF lGusto
	gRPL_Normal()
  	gPStranica-=nDSGusto
ENDIF

END PRINT

#ifdef CAX
	select opsld
	use
	select rekld
	use
	select ld
#endif

CLOSERET
return



function RekapLd(cId,nGodina,nMjesec,nIzn1,nIzn2,cIdPartner,cOpis,cOpis2,lObavDodaj, cIzdanje)
*{

if lObavDodaj==nil
	lObavDodaj:=.f.
endif

if cIdPartner=NIL
	cIdPartner=""
endif

if cOpis=nil
	cOpis=""
endif

if cOpis2=nil
  	cOpis2=""
endif

if cIzdanje == nil
	cIzdanje := ""
endif

pushwa()

select rekld
if lObavDodaj
	append blank
else
  	seek str(nGodina,4)+str(nMjesec,2)+cId+" "
  	if !found()
       		append blank
  	endif
endif

replace godina with str(nGodina,4),mjesec with str(nMjesec,2),;
        id    with  cId,;
        iznos1 with nIzn1, iznos2 with nIzn2,;
        idpartner with cIdPartner,;
        opis with cOpis ,;
        opis2 with cOpis2
	
if gAHonorar == "D"
	replace izdanje with cIzdanje
endif

popwa()

return
*}


// Otvara potrebne tabele za kreiranje izvjestaja rekapitulacije
function ORekap()
*{
O_POR
O_DOPR
O_PAROBR
O_RJ
O_RADN
O_STRSPR
O_KBENEF
O_VPOSLA
O_OPS
O_RADKR
O_KRED
O_LD
if lViseObr
	O_TIPPRN
else
	O_TIPPR
endif

return
*}



function BoxRekSvi()
*{
local nArr

nArr:=SELECT()

Box(,10+IF(IsRamaGlas(),1,0),75)
	do while .t.

		if gVarObracun == "2"
			@ m_x+2,m_y+2 SAY "Vrsta djelatnosti: "  GET cRTipRada ;
				VALID val_tiprada( cRTipRada ) PICT "@!" 
		endif
		
		@ m_x+3,m_y+2 SAY "Radne jedinice: "  GET  qqRJ PICT "@!S25"
		@ m_x+4,m_y+2 SAY "Za mjesece od:"  GET  cmjesec  pict "99" VALID {|| cMjesecDo:=cMjesec,.t.}
		@ m_x+4,col()+2 SAY "do:"  GET  cMjesecDo  pict "99" VALID cMjesecDo>=cMjesec
		if lViseObr
			@ m_x+4,col()+2 SAY "Obracun: " GET cObracun WHEN HelpObr(.t.,cObracun) VALID ValObr(.t.,cObracun)
		endif
		@ m_x+5,m_y+2 SAY "Godina: "  GET  cGodina  pict "9999"
		@ m_x+7,m_y+2 SAY "Strucna Sprema: "  GET  cStrSpr pict "@!" valid empty(cStrSpr) .or. P_StrSpr(@cStrSpr)
		@ m_x+8,m_y+2 SAY "Opstina stanovanja: "  GET  cOpsSt pict "@!" valid empty(cOpsSt) .or. P_Ops(@cOpsSt)
		@ m_x+9,m_y+2 SAY "Opstina rada:       "  GET  cOpsRad  pict "@!" valid empty(cOpsRad) .or. P_Ops(@cOpsRad)
		if (IsRamaGlas())
			@ m_x+10,m_y+2 SAY "Izdvojiti radnike (P-proizvodne,N-neproizvodne,S-sve)" GET cK4 valid cK4$"PNS" pict "@!"
		endif

		read
		
		ClvBox()
		ESC_BCR
		aUsl1:=Parsiraj(qqRJ,"IDRJ")
		aUsl2:=Parsiraj(qqRJ,"ID")
		if aUsl1<>nil .and. aUsl2<>nil
			exit
		endif
	enddo
BoxC()

select (nArr)

return
*}


function BoxRekJ()
*{
local nArr

nArr:=SELECT()

Box(,8+IF(IsRamaGlas(),1,0),75)
	if gVarObracun == "2"
		@ m_x+1,m_y+2 SAY "Vrsta djelatnosti: "  GET cRTipRada ;
			VALID val_tiprada( cRTipRada ) PICT "@!" 
	endif
	@ m_x+2,m_y+2 SAY "Radna jedinica: "  GET cIdRJ
	@ m_x+3,m_y+2 SAY "Za mjesece od:"  GET  cmjesec  pict "99" VALID {|| cMjesecDo:=cMjesec,.t.}
	@ m_x+3,col()+2 SAY "do:"  GET  cMjesecDo  pict "99" VALID cMjesecDo>=cMjesec
	if lViseObr
   		@ m_x+3,col()+2 SAY "Obracun: " GET cObracun WHEN HelpObr(.t.,cObracun) VALID ValObr(.t.,cObracun)
 	endif
 	@ m_x+4,m_y+2 SAY "Godina: "  GET  cGodina  pict "9999"
 	@ m_x+6,m_y+2 SAY "Strucna Sprema: "  GET  cStrSpr pict "@!" valid empty(cStrSpr) .or. P_StrSpr(@cStrSpr)
 	@ m_x+7,m_y+2 SAY "Opstina stanovanja: "  GET  cOpsSt pict "@!" valid empty(cOpsSt) .or. P_Ops(@cOpsSt)
 	@ m_x+8,m_y+2 SAY "Opstina rada:       "  GET  cOpsRad  pict "@!" valid empty(cOpsRad) .or. P_Ops(@cOpsRad)
	if (IsRamaGlas())
		@ m_x+9,m_y+2 SAY "Izdvojiti radnike (P-proizvodne,N-neproizvodne,S-sve)" GET cK4 valid cK4$"PNS" pict "@!"
	endif
 	read
	ClvBox()
	ESC_BCR
BoxC()

select (nArr)

return
*}


// Kreira pomocnu tabelu REKLD.DBF
function CreRekLD()
*{

aDbf:={{"GODINA"     ,  "C" ,  4, 0} ,;
       {"MJESEC"     ,  "C" ,  2, 0} ,;
       {"ID"         ,  "C" , 40, 0} ,;
       {"opis"       ,  "C" , 40, 0} ,;
       {"opis2"      ,  "C" , 35, 0} ,;
       {"iznos1"     ,  "N" , 25, 4} ,;
       {"iznos2"     ,  "N" , 25, 4} ,;
       {"idpartner"  ,  "C" ,  6, 0}}

if gAHonorar == "D"
	AADD(aDbf, { "IZDANJE", "C", 40, 0 })
endif

DBCREATE2(KUMPATH+"REKLD",aDbf)

select (F_REKLD)
usex (KUMPATH+"rekld")

index ON  BRISANO+"10" TAG "BRISAN"
index on  godina+mjesec+id tag "1"

if gAHonorar == "D"
	index on  godina+mjesec+id+idpartner tag "2"
	index on  godina+mjesec+id+izdanje tag "3"
	index on  godina+mjesec+id+idpartner+izdanje tag "4"
endif

set order to tag "1"
use

return
*}


// Kreira pomocnu tabelu OPSLD.DBF
function CreOpsLD()
*{

aDbf:={{"ID"    ,"C", 1,0},;
       {"PORID" ,"C", 2,0},;
       {"IDOPS" ,"C", 4,0},;
       {"IZNOS" ,"N",25,4},;
       {"IZNOS2","N",25,4},;
       {"IZNOS3","N",25,4},;
       {"IZNOS4","N",25,4},;
       {"IZNOS5","N",25,4},;
       {"IZNOS6","N",25,4},;
       {"IZNOS7","N",25,4},;
       {"BR_OSN","N",25,4},;
       {"IZN_OST","N",25,4},;
       {"T_ST_1","N",5,2},;
       {"T_ST_2","N",5,2},;
       {"T_ST_3","N",5,2},;
       {"T_ST_4","N",5,2},;
       {"T_ST_5","N",5,2},;
       {"T_IZ_1","N",25,4},;
       {"T_IZ_2","N",25,4},;
       {"T_IZ_3","N",25,4},;
       {"T_IZ_4","N",25,4},;
       {"T_IZ_5","N",25,4},;
       {"LJUDI" ,"N", 10,0}}


if FILE(PRIVPATH + "OPSLD.DBF")
	FERASE(PRIVPATH + "OPSLD.DBF")
	FERASE(PRIVPATH + "OPSLD.CDX")
endif

DBCreate2(PRIVPATH + "opsld", aDbf)
select(F_OPSLD)
usex (PRIVPATH+"opsld")

INDEX ON PORID+ID+IDOPS tag "1"
index ON BRISANO TAG "BRISAN"
use

return


// ---------------------------------------------------------------
// Popunjava tabelu OPSLD
// ---------------------------------------------------------------
function PopuniOpsLD( cTip, cPorId, aPorezi )
local nT_st_1 := 0
local nT_st_2 := 0
local nT_st_3 := 0
local nT_st_4 := 0
local nT_st_5 := 0
local nT_iz_1 := 0
local nT_iz_2 := 0
local nT_iz_3 := 0
local nT_iz_4 := 0
local nT_iz_5 := 0
local i
local nPom
local nOsnovica := 0
local nOstalo := 0
local nBrOsnova := 0
local nOsnov5 := 0
local nOsnov4 := 0

if cTip == nil
	cTip := ""
endif

if cPorId == nil
	cPorId := SPACE(2)
endif

if aPorezi == nil
	aPorezi := {}
endif

// ako je stepenasta...
if cTip == "S"

	// uzmi prirodu obracuna
	cPrObr := get_pr_obracuna()

	if cPrObr == "N" .or. cPrObr == " " .or. cPrObr == "B"
		nOsnovica := _oosnneto
	elseif cPrObr == "2"
		nOsnovica := _oosnostalo
	elseif cPrObr == "P"
		nOsnovica := ( _oosnneto + _oosnostalo )
	endif
	
	// uzmi stope i iznose...
	// aPorez[5] - stopa
	// aPorez[6] - iznos
	
	for i:=1 to LEN(aPorezi)
		
		if i==1
			nT_st_1 := aPorezi[i, 5]
			nT_iz_1 := aPorezi[i, 6]
		endif
		
		if i==2
			nT_st_2 := aPorezi[i, 5]
			nT_iz_2 := aPorezi[i, 6]
		endif
		if i==3
			nT_st_3 := aPorezi[i, 5]
			nT_iz_3 := aPorezi[i, 6]
		endif
		if i==4
			nT_st_4 := aPorezi[i, 5]
			nT_iz_4 := aPorezi[i, 6]
		endif
		if i==5
			nT_st_5 := aPorezi[i, 5]
			nT_iz_5 := aPorezi[i, 6]
		endif
	next
else
	cPorId := "  "
	nOsnovica := _ouneto
	nOsnov3 := nPorOsnova	
	nOsnov4 := _oosnneto	
	nOsnov5 := nPorNROsnova	
	nOstalo := _uodbici
	nBrOsnova := nMRadn_bo 
endif

select ops
seek radn->idopsst
select opsld

// po opc.stanovanja
seek cPorId + "1" + radn->idopsst

if Found()
	
	replace iznos with iznos + nOsnovica
	replace iznos2 with iznos2 + nPorOl
	replace iznos3 with iznos3 + nOsnov3
	replace iznos4 with iznos4 + nOsnov4
	replace iznos5 with iznos5 + nOsnov5
	replace izn_ost with izn_ost + nOstalo
	replace br_osn with br_osn + nBrOsnova
	replace ljudi with ljudi + 1
	
	replace t_iz_1 with t_iz_1 + nT_iz_1
	replace t_iz_2 with t_iz_2 + nT_iz_2
	replace t_iz_3 with t_iz_3 + nT_iz_3
	replace t_iz_4 with t_iz_4 + nT_iz_4
	replace t_iz_5 with t_iz_5 + nT_iz_5
	
	if nT_st_1 > t_st_1
		replace t_st_1 with nT_st_1
	endif
	
	if nT_st_2 > t_st_2
		replace t_st_2 with nT_st_2
	endif
	
	if nT_st_3 > t_st_3
		replace t_st_3 with nT_st_3
	endif
	
	if nT_st_4 > t_st_4
		replace t_st_4 with nT_st_4
	endif
	
	if nT_st_5 > t_st_5
		replace t_st_5 with nT_st_5
	endif

else
	append blank
	replace id with "1"
	replace porid with cPorId
	replace idops with radn->idopsst
	replace iznos with nOsnovica
	replace iznos2 with iznos2 + nPorOl
	replace iznos3 with iznos3 + nOsnov3
	replace iznos4 with iznos4 + nOsnov4
	replace iznos5 with iznos5 + nOsnov5
	replace br_osn with br_osn + nBrOsnova

	replace izn_ost with nOstalo
	replace ljudi with 1
	
	replace t_iz_1 with nT_iz_1
	replace t_iz_2 with nT_iz_2
	replace t_iz_3 with nT_iz_3
	replace t_iz_4 with nT_iz_4
	replace t_iz_5 with nT_iz_5
	
	if nT_st_1 > t_st_1
		replace t_st_1 with nT_st_1
	endif
	
	if nT_st_2 > t_st_2
		replace t_st_2 with nT_st_2
	endif
	
	if nT_st_3 > t_st_3
		replace t_st_3 with nT_st_3
	endif
	
	if nT_st_4 > t_st_4
		replace t_st_4 with nT_st_4
	endif
	
	if nT_st_5 > t_st_5
		replace t_st_5 with nT_st_5
	endif
	
endif

// po kantonu
seek cPorId + "3" + ops->idkan

if found()
	replace iznos with iznos + nOsnovica
	replace iznos2 with iznos2 + nPorOl
	replace iznos3 with iznos3 + nOsnov3
	replace iznos4 with iznos4 + nOsnov4
	replace iznos5 with iznos5 + nOsnov5
	replace br_osn with br_osn + nBrOsnova

	replace ljudi with ljudi + 1
	
	replace izn_ost with izn_ost + nOstalo
	replace t_iz_1 with t_iz_1 + nT_iz_1
	replace t_iz_2 with t_iz_2 + nT_iz_2
	replace t_iz_3 with t_iz_3 + nT_iz_3
	replace t_iz_4 with t_iz_4 + nT_iz_4
	replace t_iz_5 with t_iz_5 + nT_iz_5
	
	if nT_st_1 > t_st_1
		replace t_st_1 with nT_st_1
	endif
	
	if nT_st_2 > t_st_2
		replace t_st_2 with nT_st_2
	endif
	
	if nT_st_3 > t_st_3
		replace t_st_3 with nT_st_3
	endif
	
	if nT_st_4 > t_st_4
		replace t_st_4 with nT_st_4
	endif
	
	if nT_st_5 > t_st_5
		replace t_st_5 with nT_st_5
	endif
else
	append blank
	replace id with "3"
	replace porid with cPorId
	replace idops with ops->idkan
	replace iznos with nOsnovica
	replace iznos2 with iznos2 + nPorOl
	replace iznos3 with iznos3 + nOsnov3
	replace iznos4 with iznos4 + nOsnov4
	replace iznos5 with iznos5 + nOsnov5
	replace br_osn with br_osn + nBrOsnova

	replace izn_ost with nOstalo
	replace ljudi with 1
	
	replace t_iz_1 with nT_iz_1
	replace t_iz_2 with nT_iz_2
	replace t_iz_3 with nT_iz_3
	replace t_iz_4 with nT_iz_4
	replace t_iz_5 with nT_iz_5
	
	if nT_st_1 > t_st_1
		replace t_st_1 with nT_st_1
	endif
	
	if nT_st_2 > t_st_2
		replace t_st_2 with nT_st_2
	endif
	
	if nT_st_3 > t_st_3
		replace t_st_3 with nT_st_3
	endif
	
	if nT_st_4 > t_st_4
		replace t_st_4 with nT_st_4
	endif
	
	if nT_st_5 > t_st_5
		replace t_st_5 with nT_st_5
	endif

endif

// po idn0
seek cPorId + "5" + ops->idn0
if found()
	
	replace iznos with iznos + nOsnovica
	replace iznos2 with iznos2 + nPorOl
	replace iznos3 with iznos3 + nOsnov3
	replace iznos4 with iznos4 + nOsnov4
	replace iznos5 with iznos5 + nOsnov5
	replace br_osn with br_osn + nBrOsnova

	replace ljudi with ljudi + 1
	
	replace izn_ost with izn_ost + nOstalo
	replace t_iz_1 with t_iz_1 + nT_iz_1
	replace t_iz_2 with t_iz_2 + nT_iz_2
	replace t_iz_3 with t_iz_3 + nT_iz_3
	replace t_iz_4 with t_iz_4 + nT_iz_4
	replace t_iz_5 with t_iz_5 + nT_iz_5
	
	if nT_st_1 > t_st_1
		replace t_st_1 with nT_st_1
	endif
	
	if nT_st_2 > t_st_2
		replace t_st_2 with nT_st_2
	endif
	
	if nT_st_3 > t_st_3
		replace t_st_3 with nT_st_3
	endif
	
	if nT_st_4 > t_st_4
		replace t_st_4 with nT_st_4
	endif
	
	if nT_st_5 > t_st_5
		replace t_st_5 with nT_st_5
	endif

else
	append blank
	replace id with "5"
	replace porid with cPorId
	replace idops with ops->idn0
	replace iznos with nOsnovica
	replace iznos2 with iznos2 + nPorOl
	replace iznos3 with iznos3 + nOsnov3
	replace iznos4 with iznos4 + nOsnov4
	replace iznos5 with iznos5 + nOsnov5
	replace br_osn with br_osn + nBrOsnova

	replace izn_ost with nOstalo
	replace ljudi with 1
	
	replace t_iz_1 with nT_iz_1
	replace t_iz_2 with nT_iz_2
	replace t_iz_3 with nT_iz_3
	replace t_iz_4 with nT_iz_4
	replace t_iz_5 with nT_iz_5

	if nT_st_1 > t_st_1
		replace t_st_1 with nT_st_1
	endif
	
	if nT_st_2 > t_st_2
		replace t_st_2 with nT_st_2
	endif
	
	if nT_st_3 > t_st_3
		replace t_st_3 with nT_st_3
	endif
	
	if nT_st_4 > t_st_4
		replace t_st_4 with nT_st_4
	endif
	
	if nT_st_5 > t_st_5
		replace t_st_5 with nT_st_5
	endif

endif

select ops
seek radn->idopsrad
select opsld

// po opc.rada
seek cPorId + "2" + radn->idopsrad
if found()
	
	replace iznos with iznos + nOsnovica
	replace iznos2 with iznos2 + nPorOl
	replace iznos3 with iznos3 + nOsnov3
	replace iznos4 with iznos4 + nOsnov4
	replace iznos5 with iznos5 + nOsnov5
	replace br_osn with br_osn + nBrOsnova

	replace ljudi with ljudi + 1
	
	replace izn_ost with izn_ost + nOstalo
	replace t_iz_1 with t_iz_1 + nT_iz_1
	replace t_iz_2 with t_iz_2 + nT_iz_2
	replace t_iz_3 with t_iz_3 + nT_iz_3
	replace t_iz_4 with t_iz_4 + nT_iz_4
	replace t_iz_5 with t_iz_5 + nT_iz_5

	if nT_st_1 > t_st_1
		replace t_st_1 with nT_st_1
	endif
	
	if nT_st_2 > t_st_2
		replace t_st_2 with nT_st_2
	endif
	
	if nT_st_3 > t_st_3
		replace t_st_3 with nT_st_3
	endif
	
	if nT_st_4 > t_st_4
		replace t_st_4 with nT_st_4
	endif
	
	if nT_st_5 > t_st_5
		replace t_st_5 with nT_st_5
	endif


else
	append blank
	replace id with "2"
	replace porid with cPorId
	replace idops with radn->idopsrad
	replace iznos with nOsnovica
	replace iznos2 with iznos2 + nPorOl
	replace iznos3 with iznos3 + nOsnov3
	replace iznos4 with iznos4 + nOsnov4
	replace iznos5 with iznos5 + nOsnov5
	replace br_osn with br_osn + nBrOsnova

	replace izn_ost with nOstalo
	replace ljudi with 1
	
	replace t_iz_1 with nT_iz_1
	replace t_iz_2 with nT_iz_2
	replace t_iz_3 with nT_iz_3
	replace t_iz_4 with nT_iz_4
	replace t_iz_5 with nT_iz_5
	
	if nT_st_1 > t_st_1
		replace t_st_1 with nT_st_1
	endif
	
	if nT_st_2 > t_st_2
		replace t_st_2 with nT_st_2
	endif
	
	if nT_st_3 > t_st_3
		replace t_st_3 with nT_st_3
	endif
	
	if nT_st_4 > t_st_4
		replace t_st_4 with nT_st_4
	endif
	
	if nT_st_5 > t_st_5
		replace t_st_5 with nT_st_5
	endif

endif

// po kantonu
seek cPorId + "4" + ops->idkan
if found()
	
	replace iznos with iznos + nOsnovica
	replace iznos2 with iznos2 + nPorOl
	replace iznos3 with iznos3 + nOsnov3
	replace iznos4 with iznos4 + nOsnov4
	replace iznos5 with iznos5 + nOsnov5
	replace br_osn with br_osn + nBrOsnova

	replace ljudi with ljudi + 1
	
	replace izn_ost with izn_ost + nOstalo
	replace t_iz_1 with t_iz_1 + nT_iz_1
	replace t_iz_2 with t_iz_2 + nT_iz_2
	replace t_iz_3 with t_iz_3 + nT_iz_3
	replace t_iz_4 with t_iz_4 + nT_iz_4
	replace t_iz_5 with t_iz_5 + nT_iz_5

	if nT_st_1 > t_st_1
		replace t_st_1 with nT_st_1
	endif
	
	if nT_st_2 > t_st_2
		replace t_st_2 with nT_st_2
	endif
	
	if nT_st_3 > t_st_3
		replace t_st_3 with nT_st_3
	endif
	
	if nT_st_4 > t_st_4
		replace t_st_4 with nT_st_4
	endif
	
	if nT_st_5 > t_st_5
		replace t_st_5 with nT_st_5
	endif

else
	append blank
	replace id with "4"
	replace porid with cPorId
	replace idops with ops->idkan
	replace iznos with nOsnovica
	replace iznos2 with iznos2 + nPorOl
	replace iznos3 with iznos3 + nOsnov3
	replace iznos4 with iznos4 + nOsnov4
	replace iznos5 with iznos5 + nOsnov5
	replace br_osn with br_osn + nBrOsnova

	replace izn_ost with nOstalo
	replace ljudi with 1
	
	replace t_iz_1 with nT_iz_1
	replace t_iz_2 with nT_iz_2
	replace t_iz_3 with nT_iz_3
	replace t_iz_4 with nT_iz_4
	replace t_iz_5 with nT_iz_5
	
	if nT_st_1 > t_st_1
		replace t_st_1 with nT_st_1
	endif
	
	if nT_st_2 > t_st_2
		replace t_st_2 with nT_st_2
	endif
	
	if nT_st_3 > t_st_3
		replace t_st_3 with nT_st_3
	endif
	
	if nT_st_4 > t_st_4
		replace t_st_4 with nT_st_4
	endif
	
	if nT_st_5 > t_st_5
		replace t_st_5 with nT_st_5
	endif

endif

// po idn0
seek cPorId + "6" + ops->idn0
if found()
	
	replace iznos with iznos + nOsnovica
	replace iznos2 with iznos2 + nPorOl
	replace iznos3 with iznos3 + nOsnov3
	replace iznos4 with iznos4 + nOsnov4
	replace iznos5 with iznos5 + nOsnov5
	replace br_osn with br_osn + nBrOsnova

	replace ljudi with ljudi + 1
	
	replace izn_ost with izn_ost + nOstalo
	replace t_iz_1 with t_iz_1 + nT_iz_1
	replace t_iz_2 with t_iz_2 + nT_iz_2
	replace t_iz_3 with t_iz_3 + nT_iz_3
	replace t_iz_4 with t_iz_4 + nT_iz_4
	replace t_iz_5 with t_iz_5 + nT_iz_5
	
	if nT_st_1 > t_st_1
		replace t_st_1 with nT_st_1
	endif
	
	if nT_st_2 > t_st_2
		replace t_st_2 with nT_st_2
	endif
	
	if nT_st_3 > t_st_3
		replace t_st_3 with nT_st_3
	endif
	
	if nT_st_4 > t_st_4
		replace t_st_4 with nT_st_4
	endif
	
	if nT_st_5 > t_st_5
		replace t_st_5 with nT_st_5
	endif

else
	append blank
	replace id with "6"
	replace porid with cPorId
	replace idops with ops->idn0
	replace iznos with nOsnovica
	replace izn_ost with nOstalo
	replace iznos2 with iznos2 + nPorOl
	replace iznos3 with iznos3 + nOsnov3
	replace iznos4 with iznos4 + nOsnov4
	replace iznos5 with iznos5 + nOsnov5
	replace br_osn with br_osn + nBrOsnova

	replace ljudi with 1
	replace t_iz_1 with nT_iz_1
	replace t_iz_2 with nT_iz_2
	replace t_iz_3 with nT_iz_3
	replace t_iz_4 with nT_iz_4
	replace t_iz_5 with nT_iz_5
	
	if nT_st_1 > t_st_1
		replace t_st_1 with nT_st_1
	endif
	
	if nT_st_2 > t_st_2
		replace t_st_2 with nT_st_2
	endif
	
	if nT_st_3 > t_st_3
		replace t_st_3 with nT_st_3
	endif
	
	if nT_st_4 > t_st_4
		replace t_st_4 with nT_st_4
	endif
	
	if nT_st_5 > t_st_5
		replace t_st_5 with nT_st_5
	endif

endif

select ld

return



// -----------------------------------------------------
// napravi obracun
// -----------------------------------------------------
function napr_obracun(lSvi)
local i
local cTpr

nPorOl:=0
nUPorOl:=0
aNetoMj:={}
nRadn_bo := 0
nMRadn_bo := 0

do while !eof() .and. eval(bUSlov)
	
	if lViseObr .and. EMPTY(cObracun)
   		ScatterS(godina, mjesec, idrj, idradn)
 	else
   		Scatter()
 	endif

 	select radn
	hseek _idradn
	select vposla
	hseek _idvposla

 	if ( (!empty(cOpsSt) .and. cOpsSt<>radn->idopsst)) ;
		.or. ((!empty(cOpsRad) .and. cOpsRad<>radn->idopsrad))
		
   		select ld
   		skip 1
		loop
		
 	endif

	if (IsRamaGlas() .and. cK4 <> "S")
	
		if (cK4="P" .and. !radn->k4="P" .or. cK4="N".and.radn->k4="P")
			select ld
			skip 1
			loop
		endif
	endif

 	_ouneto := MAX(_uneto, PAROBR->prosld * gPDLimit/100 )
	
 	_oosnneto := 0
	_oosnostalo := 0

 	// vrati osnovicu za neto i ostala primanja
 	for i:=1 to cLDPolja
 		
		cTprField := PADL( ALLTRIM(STR(i)), 2, "0" )
		cTpr := "_I" + cTprField
		
		if &cTpr == 0
			loop
		endif
		
		select tippr
		seek cTprField
		select ld
		
		if tippr->(FIELDPOS("TPR_TIP")) <> 0
		  if tippr->tpr_tip == "N"
			
			// osnovica neto
			_oosnneto += &cTpr
			
		  elseif tippr->tpr_tip == "2"
			
			// osnovica ostalo
			_oosnostalo += &cTpr
			
		  elseif tippr->tpr_tip == " "
		
			if tippr->uneto == "D"
				
				// osnovica ostalo
				_oosnneto += &cTpr
				
			elseif tippr->uneto == "N"
				
				// osnovica ostalo
				_oosnostalo += &cTpr
				
			endif
		  endif
		else
			if tippr->uneto == "D"
				// osnovica ostalo
				_oosnneto += &cTpr
			elseif tippr->uneto == "N"
				// osnovica ostalo
				_oosnostalo += &cTpr
			endif
		endif
 	next

 	// obradi poreze....
	
 	select por
	go top
	
 	nPor:=0
	nPorOl:=0
 	
	do while !eof()  
		
		// porezi
   		
		cAlgoritam := get_algoritam()
		
		PozicOps( POR->poopst )
   		
		if !ImaUOp( "POR", POR->id )
     			SKIP 1
			LOOP
   		endif
   	
		aPor := obr_por( por->id, _oosnneto, _oosnostalo )

		// samo izracunaj total, ne ispisuj porez
		nPor += isp_por( aPor, cAlgoritam, "", .f. )

		//nPor += round2(max(dlimit,iznos/100*_oUNeto),gZaok2)
		
		if cAlgoritam == "S"
			PopuniOpsLd( cAlgoritam, por->id, aPor )
		endif
		
		select por
		
		skip
		
 	enddo
 	
	if radn->porol <> 0 .and. gDaPorOl=="D" .and. !Obr2_9() 
		// poreska olaksica
   		
		if alltrim(cVarPorOl)=="2"
     			nPorOl:=RADN->porol
   		elseif alltrim(cVarPorol)=="1"
     			nPorOl:=round(parobr->prosld*radn->porol/100,gZaok)
   		else
     			nPorOl:= &("_I"+cVarPorol)
   		endif
   		
		if nPorOl>nPor 
			// poreska olaksica ne moze biti veca od poreza
     			nPorOl:=nPor
   		endif
   		
		nUPorOl+=nPorOl
 	endif


	nPom:=ASCAN(aNeta,{|x| x[1]==vposla->idkbenef})
 	
	if nPom==0
    		AADD(aNeta,{vposla->idkbenef,_oUNeto})
 	else
    		aNeta[nPom,2]+=_oUNeto
 	endif

 	for i:=1 to cLDPolja
	
  		cPom:=padl(alltrim(str(i)),2,"0")
  		select tippr
		seek cPom
		select ld
  		aRekap[i,1]+=_s&cPom  // sati
  		nIznos:=_i&cPom
  
  		aRekap[i,2]+=nIznos  // iznos

  		if tippr->uneto=="N" .and. nIznos<>0
  			
			if nIznos>0
  				nUOdbiciP+=nIznos
  			else
  				nUOdbiciM+=nIznos
  			endif

  		endif
 	next
	
	++ nLjudi
	
	nUSati += _USati   // ukupno sati
	nUNeto += _UNeto  // ukupno neto iznos

	nULOdbitak += ( gOsnLOdb * radn->klo )

	nUNetoOsnova += _oUNeto  
	// ukupno neto osnova 
	
	nDoprOsnova += _oosnneto
	// neto osnova za obracun doprinosa
	
	nDoprOsnOst += _oosnostalo
	// ostalo - osonova za obracun doprinosa

	if UBenefOsnovu()
		nUBNOsnova += _oUNeto - if(!Empty(gBFForm), &gBFForm, 0)
	endif

	cTR := IF( RADN->isplata$"TR#SK", RADN->idbanka,;
                                 SPACE(LEN(RADN->idbanka)) )

	IF LEN(aUkTR)>0 .and. ( nPomTR := ASCAN( aUkTr , {|x| x[1]==cTR} ) ) > 0
   		aUkTR[nPomTR,2] += _uiznos
 	ELSE
   		AADD( aUkTR , { cTR , _uiznos } )
 	ENDIF

 	nUIznos += _UIznos  // ukupno iznos
	nUOdbici += _UOdbici  // ukupno odbici

	IF cMjesec <> cMjesecDo
		
		nPom:=ASCAN(aNetoMj,{|x| x[1]==mjesec})
		
		IF nPom>0
			aNetoMj[nPom,2] += _uneto
			aNetoMj[nPom,3] += _usati
		ELSE
			nTObl:=SELECT()
			nTRec := PAROBR->(RECNO())
			ParObr(mjesec,godina,IF(lViseObr,cObracun,),IF(!lSvi,cIdRj,))
			// samo pozicionira bazu PAROBR na odgovaraju†i zapis
			AADD(aNetoMj,{mjesec,_uneto,_usati,PAROBR->k3,PAROBR->k1})
			SELECT PAROBR
			GO (nTRec)
			SELECT (nTObl)
		ENDIF
	ENDIF

	PopuniOpsLD()
	
	IF RADN->isplata == "TR"  // isplata na tekuci racun
		Rekapld( "IS_"+RADN->idbanka , cgodina , cmjesecDo ,_UIznos , 0 , RADN->idbanka , RADN->brtekr , RADNIK , .t. )
	ENDIF
	
	select ld
	skip
enddo

return


// ----------------------------------------
// ----------------------------------------
function ZaglSvi()

select por
go top
O_RJ
select rj
P_10CPI

?? Lokal("Obuhvacene radne jedinice: ")
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
 
B_ON
 
IF cMjesec==cMjesecDo
   ? Lokal("Firma:"),gNFirma,"  " + Lokal("Mjesec:"),str(cmjesec,2)+IspisObr()
   ?? "    " + Lokal("Godina:"), str(cGodina,4)
   B_OFF
   ? IF(gBodK=="1",Lokal("Vrijednost boda:"),Lokal("Vr.koeficijenta:")), transform(parobr->vrbod,"99999.99999")
 ELSE
   ? Lokal("Firma:"),gNFirma,"  " + Lokal("Za mjesece od:"),str(cmjesec,2),"do",str(cmjesecDo,2)+IspisObr()
   ?? "    " + Lokal("Godina:"), str(cGodina,4)
   B_OFF
ENDIF
?


return


// ----------------------------
// ----------------------------
function ZaglJ()

O_RJ
select rj
hseek cIdRj
select por
go top
select ld

?
B_ON
if cMjesec==cMjesecDo
	? Lokal("RJ:"), cIdRj, rj->naz,SPACE(2) + Lokal("Mjesec:"),str(cmjesec,2)+IspisObr()
   	?? SPACE(4) + Lokal("Godina:"), str(cGodina,4)
   	B_OFF
     	? if(gBodK=="1",Lokal("Vrijednost boda:"),Lokal("Vr.koeficijenta:")), transform(parobr->vrbod,"99999.99999")
else
   	? Lokal("RJ:"),cidrj,rj->naz,"  " + Lokal("Za mjesece od:"),str(cmjesec,2),"do",str(cmjesecDo,2)+IspisObr()
   	?? SPACE(4) + Lokal("Godina:"), str(cGodina,4)
   	B_OFF
endif

?

return


function IspisTP(lSvi)

cUNeto:="D"

for i:=1 to cLDPolja
	if prow()>55+gPStranica
    		FF
  	endif
  	cPom:=padl(alltrim(str(i)),2,"0")
  	_s&cPom:=aRekap[i,1]   // nafiluj ove varijable radi prora~una dodatnih stavki
  	_i&cPom:=aRekap[i,2]

  	cPom:=padl(alltrim(str(i)),2,"0")
  	select tippr
	seek cPom
  	if tippr->uneto=="N" .and. cUneto=="D"
    		cUneto:="N"
    		? cLinija
    		if !lPorNaRekap
       			if gVarObracun == "2"
				? Lokal("OPOREZIVA PRIMANJA:")
			else
				? Lokal("UKUPNO NETO:")
			endif
			@ prow(),nC1+8  SAY  nUSati  pict gpics
			?? SPACE(1) + Lokal("sati")
       			@ prow(),60 SAY nUNeto pict gpici
			?? "",gValuta
    		else
       			if gVarObracun == "2"
				? Lokal("OPOREZIVA PRIMANJA:")
			else
				? Lokal("UKUPNO NETO:")
			endif
			@ prow(),nC1+5  SAY  nUSati  pict gpics
			?? SPACE(1) + Lokal("sati")
       			@ prow(),42 SAY nUNeto pict gpici; ?? "",gValuta
       			@ prow(),60 SAY nUNeto*(por->iznos/100) pict gpici
			?? "",gValuta
    		endif
    		_UNeto:=nUNeto
    		_USati:=nUSati
    		? cLinija
  	endif

	if tippr->(found()) .and. tippr->aktivan=="D" .and. (aRekap[i,2]<>0 .or. aRekap[i,1]<>0)
        	cTPNaz:=tippr->naz
  		? tippr->id+"-"+cTPNaz
  		nC1:=pcol()
  		if !lPorNaRekap
   			if tippr->fiksan $ "DN"
     				@ prow(),pcol()+8 SAY aRekap[i,1]  pict gpics; ?? " s"
     				@ prow(),60 say aRekap[i,2]      pict gpici
   			elseif tippr->fiksan=="P"
     				@ prow(),pcol()+8 SAY aRekap[i,1]/nLjudi pict "999.99%"
     				@ prow(),60 say aRekap[i,2]        pict gpici
   			elseif tippr->fiksan=="C"
     				@ prow(),60 say aRekap[i,2]        pict gpici
   			elseif tippr->fiksan=="B"
    				@ prow(),pcol()+8 SAY aRekap[i,1] pict "999999"; ?? " b"
     				@ prow(),60 say aRekap[i,2]      pict gpici
   			endif
  		else
   			if tippr->fiksan $ "DN"
     				@ prow(),pcol()+5 SAY aRekap[i,1]  pict gpics; ?? " s"
     				@ prow(),42 say aRekap[i,2]      pict gpici
     				if tippr->uneto=="D"
        				@ prow(),60 say aRekap[i,2]*(por->iznos/100)      pict gpici
     				endif
   			elseif tippr->fiksan=="P"
     				@ prow(),pcol()+4 SAY aRekap[i,1]/nLjudi pict "999.99%"
     				@ prow(),42 say aRekap[i,2]        pict gpici
     				if tippr->uneto=="D"
        				@ prow(),60 say aRekap[i,2]*(por->iznos/100)      pict gpici
     				endif
   			elseif tippr->fiksan=="C"
     				@ prow(),42 say aRekap[i,2]        pict gpici
     					if tippr->uneto=="D"
        					@ prow(),60 say aRekap[i,2]*(por->iznos/100)      pict gpici
     					endif
   			elseif tippr->fiksan=="B"
     				@ prow(),pcol()+4 SAY aRekap[i,1] pict "999999"; ?? " b"
     				@ prow(),42 say aRekap[i,2]      pict gpici
     				if tippr->uneto=="D"
        				@ prow(),60 say aRekap[i,2]*(por->iznos/100)      pict gpici
     				endif
   			endif
  		endif
   		IF cMjesec==cMjesecDo
     			Rekapld("PRIM"+tippr->id,cgodina,cmjesec,aRekap[i,2],aRekap[i,1])
   		ELSE
     			Rekapld("PRIM"+tippr->id,cgodina,cMjesecDo,aRekap[i,2],aRekap[i,1])
   		ENDIF

		IspisKred(lSvi)
	endif

next

return


function IspisKred(lSvi)
if "SUMKREDITA" $ tippr->formula
	if gReKrOs=="X"
        	? cLinija
        	? "  ",Lokal("Od toga pojedinacni krediti:")
        	SELECT RADKR
		SET ORDER TO TAG "3"
        	SET FILTER TO STR(cGodina,4)+STR(cMjesec,2)<=STR(godina,4)+STR(mjesec,2) .and. STR(cGodina,4)+STR(cMjesecDo,2)>=STR(godina,4)+STR(mjesec,2)
        	GO TOP
        	DO WHILE !EOF()
          		cIdKred:=IDKRED
          		SELECT KRED; HSEEK cIdKred; SELECT RADKR
          		nUkKred := 0
          		DO WHILE !EOF() .and. IDKRED==cIdKred
            			cNaOsnovu:=NAOSNOVU; cIdRadnKR:=IDRADN
            			SELECT RADN; HSEEK cIdRadnKR; SELECT RADKR
            			cOpis2   := RADNIK
            			nUkKrRad := 0
            			DO WHILE !EOF() .and. IDKRED==cIdKred .and. cNaOsnovu==NAOSNOVU .and. cIdRadnKR==IDRADN
              				mj:=mjesec
              				if lSvi
               					select ld
						set order to tag (TagVO("2"))
						hseek  str(cGodina,4)+str(mj,2)+if(lViseObr.and.!EMPTY(cObracun),cObracun,"")+radkr->idradn
               					//"LDi2","str(godina)+str(mjesec)+idradn"
              				else
                				select ld
						hseek  str(cGodina,4)+cidrj+str(mj,2)+if(lViseObr.and.!EMPTY(cObracun),cObracun,"")+radkr->idradn
              				endif // lSvi
              				select radkr
              				if ld->(found())
                				nUkKred  += iznos
                				nUkKrRad += iznos
              				endif
              				SKIP 1
            			ENDDO
            			if nUkKrRad<>0
              				Rekapld("KRED"+cidkred+cnaosnovu,cgodina,cmjesecDo,nUkKrRad,0,cidkred,cnaosnovu,cOpis2,.t.)
            			endif
          		ENDDO
          		IF nUkKred<>0    // ispisati kreditora
            			if prow()>55+gPStranica
              				FF
            			endif
            			? "  ",cidkred,left(kred->naz,22)
            			@ prow(),58 SAY nUkKred  pict "("+gpici+")"
          		ENDIF
        	ENDDO
      	else
        	? cLinija
        	? "  ",Lokal("Od toga pojedinacni krediti:")
        	cOpis2:=""
        	select radkr
		set order to 3 
		go top
       		//"RADKRi3","idkred+naosnovu+idradn+str(godina)+str(mjesec)","RADKR")
        	do while !eof()
        		select kred
			hseek radkr->idkred 
			select radkr
         		private cidkred:=idkred, cNaOsnovu:=naosnovu
         		select radn; hseek radkr->idradn; select radkr
         		cOpis2:= RADNIK
         		seek cidkred+cnaosnovu
         		private nUkKred:=0
         		do while !eof() .and. idkred==cidkred .and. ( cnaosnovu==naosnovu .or. gReKrOs=="N" )
          			if lSvi
           				select ld
					set order to tag (TagVO("2"))
					hseek  str(cGodina,4)+str(cmjesec,2)+if(lViseObr.and.!EMPTY(cObracun),cObracun,"")+radkr->idradn
           				//"LDi2","str(godina)+str(mjesec)+idradn"
          			else
            				select ld
					hseek  str(cGodina,4)+cidrj+str(cmjesec,2)+if(lViseObr.and.!EMPTY(cObracun),cObracun,"")+radkr->idradn
          			endif // lSvi
          			select radkr
          			if ld->(found()) .and. godina==cgodina .and. mjesec=cmjesec
            				nUkKred+=iznos
          			endif
          			IF cMjesecDo>cMjesec
            				FOR mj:=cMjesec+1 TO cMjesecDo
              					if lSvi
               						select ld
							set order to tag (TagVO("2"))
							hseek  str(cGodina,4)+str(mj,2)+if(lViseObr.and.!EMPTY(cObracun),cObracun,"")+radkr->idradn
               						//"LDi2","str(godina)+str(mjesec)+idradn"
              					else
                					select ld
							hseek  str(cGodina,4)+cidrj+str(mj,2)+if(lViseObr.and.!EMPTY(cObracun),cObracun,"")+radkr->idradn
              					endif // lSvi
              					select radkr
              					if ld->(found()) .and. godina==cgodina .and. mjesec=mj
                					nUkKred+=iznos
              					endif
            				NEXT
          			ENDIF
          			skip
         		enddo
         		if nukkred<>0
          			if prow()>55+gPStranica
            				FF
          			endif
          			? "  ",cidkred,left(kred->naz,22),IF(gReKrOs=="N","",cnaosnovu)
          			@ prow(),58 SAY nUkKred  pict "("+gpici+")"
          			if cMjesec==cMjesecDo
            				Rekapld("KRED"+cidkred+cnaosnovu,cgodina,cmjesec,nukkred,0,cidkred,cnaosnovu, cOpis2)
          			ELSE
            				Rekapld("KRED"+cidkred+cnaosnovu,cgodina,cMjesecDo,nukkred,0,cidkred,cnaosnovu, cOpis2)
          			ENDIF
         		endif
        	enddo
        	select ld
	endif
endif

return


function PoTekRacunima()

? cLinija
? Lokal("ZA ISPLATU:")
? "-----------"

nMArr:=SELECT()
SELECT KRED
ASORT(aUkTr,,,{|x,y| x[1]<y[1]})
FOR i:=1 TO LEN(aUkTR)
    IF EMPTY(aUkTR[i,1])
      ? PADR(Lokal("B L A G A J N A"),LEN(aUkTR[i,1]+KRED->naz)+1)
    ELSE
      HSEEK aUkTR[i,1]
      ? aUkTR[i,1], KRED->naz
    ENDIF
    @ prow(),60 SAY aUkTR[i,2] pict gpici; ?? "",gValuta
NEXT
SELECT (nMArr)


return


// ----------------------------------------------
// ispis tipova primanja....
// ----------------------------------------------
function ProizvTP()

// proizvoljni redovi pocinju sa "9"

select tippr
seek "9"

do while !eof() .and. left(id,1)="9"
	if prow()>55+gPStranica
    		FF
  	endif
  	? tippr->id+"-"+tippr->naz
	cPom:=tippr->formula
	if !lPorNaRekap
     		@ prow(),60 say round2(&cPom,gZaok2) pict gpici
  	else
     		@ prow(),42 say round2(&cPom,gZaok2) pict gpici
  	endif
  	if cMjesec==cMjesecDo
    		Rekapld("PRIM"+tippr->id,cgodina,cmjesec,round2(&cpom,gZaok2),0)
  	else
    		Rekapld("PRIM"+tippr->id,cgodina,cMjesecDo,round2(&cpom,gZaok2),0)
  	endif
  	
	skip
  	
	if eof() .or. !left(id,1)="9"
    		? cLinija
  	endif
enddo

return



function PrikKBO()
nBO:=0
? Lokal("Koef. Bruto osnove (KBO):"),transform(parobr->k3,"999.99999%")
?? space(1),Lokal("BRUTO OSNOVA = NETO OSNOVA*KBO =")
@ prow(),pcol()+1 SAY nBo:=round2(parobr->k3/100*nUNetoOsnova,gZaok2) pict gpici
?
return


function PrikKBOBenef()
if nUBNOsnova == 0
	return
endif

nBO:=0
? Lokal("Koef. Bruto osnove benef.(KBO):"),transform(parobr->k3,"999.99999%")
? space(3),Lokal("BRUTO OSNOVA = NETO OSNOVA.BENEF * KBO =")
@ prow(),pcol()+1 SAY nBo:=round2(parobr->k3/100*nUBNOsnova,gZaok2) pict gpici
?
return



function UBenefOsnovu()
if radn->k4 == "BF"
	return .t.
endif

return .f.



