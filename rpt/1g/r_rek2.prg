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
private cDoprSpace := ""
private cLmSk := ""

cTpLine := _gtprline()
cDoprLine := _gdoprline(cDoprSpace)
cMainLine := _gmainline()
cMainLine := REPLICATE("-", 2) + cMainLine

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
cRTipRada := " "
nKoefLO := 0

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
P_12CPI

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

nT1:=0
nT2:=0
nT3:=0
nT4:=0
nUNeto:=0
nUNetoOsnova:=0
nDoprOsnova := 0
nDoprOsnOst := 0
nPorOsnova := 0
nPorNROsnova := 0
nUPorNROsnova := 0
nURadn_bo := 0
nUMRadn_bo := 0
nURadn_bbo := 0
nUPorOsnova := 0
nULOdbitak := 0
nUBNOsnova:=0
nUDoprIz := 0
nURadn_diz := 0
nUIznos:=0
nUSati:=0
nUOdbici:=0
nUOdbiciP:=0
nUOdbiciM:=0
nLjudi:=0
nUBBTrosk := 0
nURTrosk := 0

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

nstr()

? cTpLine

nPosY := 60
if lPorNaRekap
	nPosY := 42
endif

? Lokal("Ukupno (primanja sa obustavama):")
@ prow(), nPosY SAY nUNeto + nUOdbiciP + nUOdbici pict gpici
?? "",gValuta

? cTpLine

if !lGusto
	?
endif

ProizvTP()

nstr()

if cRTipRada $ "A#U"

 ? cMainLine
 ? Lokal("a) UKUPNI BRUTO SA TROSKOVIMA ")
 @ prow(), 60 SAY nUBBTrosk PICT gPicI 
 ? Lokal("b) UKUPNI TROSKOVI ")
 @ prow(), 60 SAY nURTrosk PICT gPici 

endif


// 1. BRUTO IZNOS
// setuje se varijabla nBO
get_bruto( nURadn_bo )

// 2. DOPRINOSI
private nDopr
private nDopr2

? Lokal("2. OBRACUN DOPRINOSA")
? cMainLine

// bruto osnova minimalca
if nURadn_bo < nUMRadn_bo
	? Lokal("min.bruto osnova za obracun doprinosa")
	@ prow(), 60 SAY nUMRadn_bo PICT gPici
endif

cLinija := cDoprLine
// obracunaj i prikazi doprinose
obr_doprinos( @nDopr, @nDopr2, cRTipRada )

nstr()

// LICNI ODBITCI
? cMainLine
? Lokal("3. LICNI ODBICI UKUPNO")
@ prow(), 60 SAY nULOdbitak PICT gPici

nstr()

nPorOsn := nURadn_bo - nUDoprIz - nULOdbitak

// osnovica za porez na dohodak
? cMainLine
? Lokal("4. OSNOVICA ZA OBRACUN POREZA NA DOHODAK (1-2-3)")
@ prow(), 60 SAY nPorOsn PICT gPici
? cMainLine

private nPor
private nPor2 
private nPorOps
private nPorOps2
private nUZaIspl

nUZaIspl := 0
nPorez1 := 0
nPorez2 := 0
nPorOp1 := 0
nPorOp2 := 0
nPorOl1 := 0
nTOsnova := 0
nPorB := 0
nPorR := 0

// obracunaj porez na bruto
nTOsnova := obr_porez( @nPor, @nPor2, @nPorOps, @nPorOps2, @nUPorOl, "B" )

nPorB := nPor

// ako je stvarna osnova veca od ove BRUTO - DOPRIZ - ODBICI
// rijec je o radnicima koji nemaju poreza
if ROUND(nTOsnova, 2) > ROUND(nPorOsn,2)
	? Lokal("!!! razlika osnovice poreza (radi radnika bez poreza):")
	@ prow(), 60 SAY nPorOsn - nTOsnova pict gpici
	?
endif

nPorez1 += nPor
nPorez2 += nPor2
nPorOp1 += nPorOps
nPorOp2 += nPorOps2
nPorOl1 += nUPorOl

nNetoIspl := nUPorNROsnova
nUZaIspl := ( nNetoIspl ) + nUOdbiciM + nUOdbiciP

? cMainLine
? Lokal("5. UKUPNA NETO PLATA")
@ prow(), 60 SAY nNetoIspl PICT gpici 

// obracun ostalog poreza na neto
? cMainLine
? Lokal("7. OSNOVICA ZA OBRACUN OSTALIH NAKNADA (6)")
@ prow(), 60 SAY nNetoIspl PICT gpici 
? cMainLine

// obracunaj ostali porez na neto
obr_porez( @nPor, @nPor2, @nPorOps, @nPorOps2, @nUPorOl, "R" )

nPorR := nPor
nPorez1 += nPor
nPorez2 += nPor2
nPorOp1 += nPorOps
nPorOp2 += nPorOps2
nPorOl1 += nUPorOl

? cMainLine
? Lokal("8. UKUPNO ODBICI/NAKNADE IZ PLATE:")
? Lokal("             ODBICI:")
@ prow(), 60 SAY nUOdbiciM PICT gpici
? Lokal("     OSTALE NAKNADE:")
@ prow(), 60 SAY nUOdbiciP PICT gpici
? cMainLine

// ukupno za isplatu
? cMainLine
if cRTipRada $ "A#U"
	? Lokal("9. UKUPNO ZA ISPLATU (bruto-dopr-porez+troskovi):")
	@ prow(), 60 SAY nUZaIspl+nURTrosk PICT gpici
else
	? Lokal("9. UKUPNO ZA ISPLATU (bruto-dopr-porez+odbici+naknade):")
	@ prow(), 60 SAY nUZaIspl PICT gpici
endif
? cMainLine

?

cLinija := "-----------------------------------------------------------"

? cLinija
? Lokal("OPOREZIVA PRIMANJA:")
@ prow(),pcol()+1 SAY nUNeto pict gpici
?? "(" + Lokal("za isplatu:")
@ prow(),pcol()+1 SAY nUZaIspl pict gpici
?? "," + Lokal("Obustave:")
@ prow(),pcol()+1 SAY -nUOdbiciM pict gpici
?? ")"
? "    " + Lokal("OSTALE NAKNADE:")
@ prow(),pcol()+1 SAY nUOdbiciP pict gpici  // dodatna primanja van neta
? cLinija
? " " + Lokal("OPOREZIVI DOHODAK (1):")
@ prow(),pcol()+1 SAY nURadn_bo-nUDoprIz pict gpici
? "         " + Lokal("POREZ 10% (2):")
IF cUmPD=="D"
	@ prow(),pcol()+1 SAY nPorB-nPorOl1-nPorez2    pict gpici
ELSE
	@ prow(),pcol()+1 SAY nPorB-nPorOl1    pict gpici
ENDIF
? "     " + Lokal("OSTALI POREZI (3):")
@ prow(),pcol()+1 SAY nPorR pict gpici
? "         " + Lokal("DOPRINOSI (4):")
IF cUmPD=="D"
	@ prow(),pcol()+1 SAY nDopr-nDopr2    pict gpici
ELSE
	@ prow(),pcol()+1 SAY nDopr    pict gpici
ENDIF

? cLinija

IF cUmPD=="D"
	? Lokal(" POTREBNA SREDSTVA (1 + 3 + 4):")
	@ prow(),pcol()+1 SAY (nURadn_Bo-nUDoprIz)+(nPorR)+nDopr-nPorez2-nDopr2    pict gpici
ELSE
	? Lokal(" POTREBNA SREDSTVA (1 + 3 + 4 + ost.nakn.):")
	@ prow(),pcol()+1 SAY (nURadn_Bo-nUDoprIz)+(nPorR)+nDopr+nUOdbiciP pict gpici
ENDIF
? cLinija
?
? Lokal("Izvrsena obrada na") + " ",str(nLjudi,5), Lokal("radnika")
?
if nUSati==0
	nUSati:=999999
endif
? Lokal("Prosjecni neto/satu je"),alltrim(transform(nNetoIspl,gpici)),"/",alltrim(str(nUSati)),"=",alltrim(transform(nNetoIspl/nUsati,gpici)),"*",alltrim(transform(parobr->k1,"999")),"=",alltrim(transform(nNetoIspl/nUsati*parobr->k1,gpici))


P_12CPI
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


static function nstr()
if prow() > 52 + gpStranica
	FF
endif
return


// -----------------------------------------------------
// napravi obracun
// -----------------------------------------------------
static function _calc_totals(lSvi)
local i
local cTpr

nPorol := 0
nRadn_bo := 0
nRadn_bbo := 0
nMRadn_bo := 0
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

	select ld

	cTipRada := g_tip_rada( ld->idradn, ld->idrj )

	// provjeri tip rada
	if cTipRada $ tr_list() .and. EMPTY( cRTipRada ) 
		// ovo je u redu...
	elseif ( cRTipRada <> cTipRada )
		select ld
		skip 1
		loop
	endif

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

	nRadn_lod := _ulicodb 

	nKoefLO := nRadn_lod

	cTrosk := radn->trosk

	// RS ?
	lInRS := in_rs( radn->idopsst, radn->idopsrad ) .and. cTipRada $ "A#U"

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
	
	nRSpr_koef := 0
	if cTipRada == "S"
		nRSpr_koef := radn->sp_koef	
	endif

	// br.osn za radnika
	nRadn_bo := bruto_osn( _oosnneto, cTipRada , nKoefLO, nRSpr_koef, cTrosk ) 
	nTrosk := 0

	if cTipRada $ "A#U"
		if cTrosk <> "N"
			if cTipRada == "A"
				nTrosk := gAHTrosk
			elseif cTipRada == "U"
				nTrosk := gUgTrosk
			endif
			// ako je u rs-u
			if lInRS == .t.
				nTrosk := 0
			endif
		endif
	endif

	// troskovi za ugovore i honorare
	nRTrosk := nRadn_bo * ( nTrosk / 100 )
	// ukupno bez troskova
	nUBBTrosk += nRadn_bo
	// ukupno troskovi
	nURTrosk += nRTrosk

	// troskove uzmi ako postoje, i to je osnovica
	nRadn_bo := nRadn_bo - nRTrosk
	
	if cTipRada $ " #I#N" 
		// minimalna bruto osnova
		nMRadn_bo := min_bruto( nRadn_bo, _usati )
		
		// ukupno minimalna bruto osnova
		nUMRadn_bo += nMRadn_bo

	else
		nMRadn_bo := nRadn_no
		nUMRadn_bo += nRadn_bo
	endif

	// ukupno bruto osnova
	nURadn_bo += nRadn_bo

	if UBenefOsnovu()
		// beneficirani
		nRadn_bbo := bruto_osn( _oosnneto - if(!Empty(gBFForm), &gBFForm, 0), cTipRada, nKoefLO, nRSpr_koef )
		nURadn_bbo += nRadn_bbo
	endif

	// da bi dobio osnovicu za poreze
	// moram vidjeti i koliko su doprinosi IZ
	nRadn_diz := u_dopr_iz( nMRadn_bo , cTipRada )

	if lInRS == .t.
		nRadn_diz := 0
	endif

	// ukupni doprinosi iz
	nURadn_diz += nRadn_diz
	
	// osnovica za poreze
	nRadn_posn := ROUND2( (nRadn_bo - nRadn_diz ) - nRadn_lod, gZaok2 )
	
	if lInRS == .t.
		nRadn_posn := 0
	endif

	// ovo je total poreske osnove za radnika
	nPorOsnova := nRadn_posn

	if nPorOsnova < 0 .or. !radn_oporeziv( radn->id, ld->idrj )
		nPorOsnova := 0
	endif

	// ovo je total poreske osnove
	nUPorOsnova += nPorOsnova

 	// obradi poreze....
	
 	select por
	go top
	
	

 	nPor:=0
	nPorOl:=0
 	
	do while !eof()  
		
		cAlgoritam := get_algoritam()
		
		PozicOps( POR->poopst )
   		
		if !ImaUOp( "POR", POR->id )
     			SKIP 1
			LOOP
   		endif
   	
		if por->por_tip == "B"
			aPor := obr_por( por->id, nPorOsnova, 0 )
		else
			aPor := obr_por( por->id, _oosnneto, _oosnostalo )
		endif

		// samo izracunaj total, ne ispisuj porez
		
		nTmpP := isp_por( aPor, cAlgoritam, "", .f. )
		
		if nTmpP < 0 
			nTmpP := 0
		endif
	
		nPor += nTmpP

		if cAlgoritam == "S"
			PopuniOpsLd( cAlgoritam, por->id, aPor )
		endif
		
		select por
		
		skip
		
 	enddo

	altd()

 	// neto na ruke osnova
	// BRUTO - DOPR_IZ - POREZ
	nPorNROsnova := ROUND2 ( (nRadn_bo - nRadn_diz) - nPor, gZaok2 )

	// minimalna neto osnova
	nPorNrOsnova := min_neto( nPorNROsnova, _usati )

	if lInRS == .t.
		nPorNROsnova := 0
	endif
	
	nUPorNROsnova += nPorNROsnova

 	
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

	nULOdbitak += nRadn_lod

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
			ParObr(mjesec,godina,IF(lViseObr,cObracun,),IF(!lSvi,cIdRj,))
			// samo pozicionira bazu PAROBR na odgovaraju†i zapis
			AADD(aNetoMj,{mjesec,_uneto,_usati,PAROBR->k3,PAROBR->k1})
			SELECT PAROBR
			GO (nTRec)
			SELECT (nTObl)
		ENDIF
	ENDIF
	
	// napuni opsld sa ovim porezom
 	PopuniOpsLD()

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
static function get_bruto( nIznos )

nBO := nIznos

? cMainLine
if cRTiprada $ "A#U"
	? Lokal("1. BRUTO PLATA (bruto sa troskovima - troskovi):")
else
	? Lokal("1. BRUTO PLATA UKUPNO:")
endif
@ prow(), 60 SAY nBO pict gpici
? cMainLine

return 



