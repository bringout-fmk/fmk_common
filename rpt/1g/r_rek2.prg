#include "ld.ch"

static __var_obr


// ----------------------------------------
// ----------------------------------------
function Rekap2(lSvi)
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
private cDoprSpace := SPACE(2)
private cLmSk := ""

cTpLine := _gtprline()
cDoprLine := _gdoprline(cDoprSpace)
cMainLine := _gmainline()

lPorNaRekap:=IzFmkIni("LD","PoreziNaRekapitulaciji","N",KUMPATH)=="D"

cIdRadn:=SPACE(_LR_)
cIdRj:=gRj
cMjesec:=gMjesec
cGodina:=gGodina
cObracun:=gObracun
cMjesecDo:=cMjesec
nStrana:=0
aUkTr:={}
nBO := 0

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
ParObr(cmjesec, IIF(lViseObr,cObracun,), IIF(!lSvi,cIdRj,))

private aRekap[cLDPolja,2]

for i:=1 to cLDPolja
	aRekap[i,1]:=0
  	aRekap[i,2]:=0
next

nT1:=0
nT2:=0
nT3:=0
nT4:=0
nUNeto:=0
nUNetoOsnova:=0
nDoprOsnova := 0
nDoprOsnOst := 0
nULOdbitak := 0
nUBNOsnova:=0
nUDoprIz := 0
nUIznos:=0
nUSati:=0
nUOdbici:=0
nUOdbiciP:=0
nUOdbiciM:=0
nLjudi:=0

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

// ---------------------------------------
// sracunaj ukupne vrijednosti
// dobit cemo podatke 
//   nLjudi - broj ljudi obradjeni
//   nUNetoOsnova - osnovica neto
//   
//   itd...

_calc_totals( lSvi )

if nLjudi == 0
	nLjudi := 9999999
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

? cTpLine

cLinija := cTpLine

// ispisi tipove primanja...
IspisTP( lSvi )

if IzFmkIni("LD","Rekap_ZaIsplatuRasclanitiPoTekRacunima","N",KUMPATH)=="D" .and. LEN(aUkTR)>1
	PoTekRacunima()
endif

? cTpLine

nPosY := 60
if lPorNaRekap
	nPosY := 42
endif

? Lokal("Ukupno za isplatu:")
@ prow(), nPosY SAY nUIznos pict gpici
?? "",gValuta

? cTpLine

if !lGusto
	?
endif

ProizvTP()

// 1. BRUTO IZNOS
// setuje se varijabla nBO
get_bruto()

// 2. razradi doprinose
private nDopr
private nDopr2

cLinija := cDoprLine
// obracunaj i prikazi doprinose
obr_doprinos( @nDopr, @nDopr2, nBO )

if cUmPD == "D"
	P_10CPI
endif

nOporDohod := nBO - nUDoprIz 

// OPOREZIVI DOHODAK UKUPNO
? cMainLine
? Lokal("3. OPOREZIVI DOHODAK UKUPNO")
@ prow(), 60 SAY nOporDohod 


// LICNI ODBITCI
? cMainLine
? Lokal("4. LICNI ODBICI UKUPNO")
@ prow(), 60 SAY nULOdbitak 

// osnovica za porez na dohodak
? cMainLine
? Lokal("5. OSNOVICA POREZA NA DOHODAK UKUPNO")
@ prow(), 60 SAY nULOdbitak 

nPorOsn := nOporDohodak - nULOdbitak

private nPor
private nPor2 
private nPorOps
private nPorOps2
	
obr_porez( @nPor, @nPor2, @nPorOps, @nPorOps2, @nUPorOl, nPorOsn )
	
if !lGusto
	?
	?
endif

?

if prow() > 55 + gpStranica
	FF
endif

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


// -----------------------------------------------------
// napravi obracun
// -----------------------------------------------------
static function _calc_totals(lSvi)
local i
local cTpr

nPorol := 0
nPor := 0
aNetoMj:={}

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
 
 	PopuniOpsLD()

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
  
  		aRekap[i,2] += nIznos  // iznos

  		if tippr->uneto == "N" .and. nIznos <> 0
  			
			if nIznos > 0
  				nUOdbiciP += nIznos
  			else
  				nUOdbiciM += nIznos
  			endif

  		endif
 	next
	
	++ nLjudi
	
	nUSati += _USati   
	// ukupno sati
	
	nUNeto += _UNeto  
	// ukupno neto iznos

	nULOdbitak += ( gOsnLOdb * radn->klo )

	nUNetoOsnova += _oUNeto  
	// ukupno neto osnova 
	
	if UBenefOsnovu()
		nUBNOsnova += _oUNeto - if(!Empty(gBFForm), &gBFForm, 0)
	endif

	cTR := IF( RADN->isplata $ "TR#SK", RADN->idbanka,;
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
			ParObr(mjesec,IF(lViseObr,cObracun,),IF(!lSvi,cIdRj,))
			// samo pozicionira bazu PAROBR na odgovaraju†i zapis
			AADD(aNetoMj,{mjesec,_uneto,_usati,PAROBR->k3,PAROBR->k1})
			SELECT PAROBR
			GO (nTRec)
			SELECT (nTObl)
		ENDIF
	ENDIF

	IF RADN->isplata == "TR"  // isplata na tekuci racun
		Rekapld( "IS_"+RADN->idbanka , cGodina , cMjesecDo ,_UIznos , 0 , RADN->idbanka , RADN->brtekr , RADNIK , .t. )
	ENDIF
	
	select ld
	skip
enddo

return


// ----------------------------------------------------------
// ispisuje i vraca bruto osnovicu za daljnji obracun
// ----------------------------------------------------------
static function get_bruto()

nBO := 0

? cMainLine
? Lokal("1. BRUTO PLACA UKUPNO :")
@ prow(), 60 SAY nBo := round2( 1.52555 * nUNetoOsnova, gZaok2) pict gpici
? cMainLine

return 







