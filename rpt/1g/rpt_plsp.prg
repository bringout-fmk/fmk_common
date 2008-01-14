#include "\dev\fmk\ld\ld.ch"


function PlatSp()
local nC1:=20
local cVarSort:="2"
local lSviRadnici := .f.
local cSviRadn := "N"

cIdRadn:=SPACE(_LR_)
cIdRj:=gRj
cMjesec:=gMjesec
cGodina:=gGodina
cObracun:=gObracun

O_RJ
O_RADN
O_LD

cProred:="N"
cPrikIzn:="D"
nProcenat:=100
nZkk:=gZaok
cDrugiDio:="D"
cNaslov:=""       
// ISPLATA PLATA
cNaslovTO:=""     
// ISPLATA TOPLOG OBROKA
nIznosTO:=0
// export za banku
cZaBanku:="N"

O_PARAMS

private cSection:="4"
private cHistory:=" "
private aHistory:={}

RPar("VS",@cVarSort)
RPar("ni",@cNaslov)
RPar("to",@cNaslovTO)

cNaslov:=PADR(cNaslov,90)
cNaslovTO:=PADR(cNaslovTO,90)

Box(,13,60)
@ m_x+1,m_y+2 SAY "Radna jedinica (prazno-sve): "  GET cIdRJ
@ m_x+2,m_y+2 SAY "Mjesec: "  GET  cmjesec  pict "99"
if lViseObr
  @ m_x+ 2,col()+2 SAY "Obracun: "  GET  cObracun WHEN HelpObr(.t.,cObracun) VALID ValObr(.t.,cObracun)
endif
@ m_x+ 3,m_y+2 SAY "Godina: "  GET  cGodina  pict "9999"
@ m_x+ 4,m_y+2 SAY "Prored:"   GET  cProred  pict "@!"  valid cProred $ "DN"
@ m_x+ 5,m_y+2 SAY "Prikaz iznosa:" GET cPrikIzn pict "@!" valid cPrikizn$"DN"
@ m_x+ 6,m_y+2 SAY "Prikaz u procentu %:" GET nprocenat pict "999.99"
@ m_x+ 7,m_y+2 SAY "Sortirati po(1-sifri,2-prezime+ime)"  GET cVarSort VALID cVarSort$"12"  pict "9"
@ m_x+ 8,m_y+2 SAY "Naslov izvjestaja"  GET cNaslov pict "@S30"
@ m_x+ 9,m_y+2 SAY "Naslov za topl.obrok"  GET cNaslovTO pict "@S30"
@ m_x+10,m_y+2 SAY "Iznos (samo za topli obrok)"  GET nIznosTO pict gPicI

@ m_x+11,m_y+2 SAY "Izlistati sve radnike (D/N)"  GET cSviRadn pict "@!" VALID cSviRadn $ "DN"

read
clvbox()
ESC_BCR
if nprocenat<>100
  @ m_x+12,m_y+2 SAY "zaokruzenje" GET nZkk pict "99"
  @ m_x+13,m_y+2 SAY "Prikazati i drugi spisak (za "+LTRIM(STR(100-nProcenat,6,2))+"%-tni dio)" GET cDrugiDio VALID cDrugiDio$"DN" PICT "@!"
  
  read
else
  cDrugiDio:="N"
endif
BoxC()

 WPar("VS",cVarSort)
 cNaslov:=ALLTRIM(cNaslov)
 WPar("ni",cNaslov)
 cNaslovTO:=ALLTRIM(cNaslovTO)
 WPar("to",cNaslovTO)
 SELECT PARAMS; USE

if cSviRadn == "D"
	lSviRadnici := .t.
endif


IF nIznosTO<>0
  cNaslov:=cNaslovTO
  qqImaTO:=IzFMKIni("LD","UslovImaTopliObrok",'UPPER(RADN->K2)=="D"',KUMPATH)
ENDIF

IF !EMPTY(cNaslov)
  cNaslov += (SPACE(1) + Lokal("za mjesec:")+STR(cMjesec,2)+". " + Lokal("godine:")+STR(cGodina,4)+".")
ENDIF

select ld
//CREATE_INDEX("LDi1","str(godina)+idrj+str(mjesec)+idradn","LD")
//CREATE_INDEX("LDi2","str(godina)+str(mjesec)+idradn","LD")

if lViseObr
  cObracun:=TRIM(cObracun)
else
  cObracun:=""
endif

if empty(cidrj)
  cidrj:=""
  IF cVarSort=="1"
    set order to tag (TagVO("2"))
    hseek str(cGodina,4)+str(cmjesec,2)+cObracun
  ELSE
    Box(,2,30)
     nSlog:=0; nUkupno:=RECCOUNT2()
     cSort1:="SortPrez(IDRADN)"
     cFilt := IF(EMPTY(cMjesec),".t.","MJESEC==cMjesec")+".and."+;
              IF(EMPTY(cGodina),".t.","GODINA==cGodina")
     if lViseObr
       cFilt+=".and. obr=cObracun"
     endif
     INDEX ON &cSort1 TO "TMPLD" FOR &cFilt EVAL(TekRec2()) EVERY 1
    BoxC()
    GO TOP
  ENDIF
else
  IF cVarSort=="1"
    set order to tag (TagVO("1"))
    hseek str(cGodina,4)+cidrj+str(cmjesec,2)+cObracun
  ELSE
    Box(,2,30)
     nSlog:=0; nUkupno:=RECCOUNT2()
     cSort1:="SortPrez(IDRADN)"
     cFilt := "IDRJ==cIdRj.and."+;
              IF(EMPTY(cMjesec),".t.","MJESEC==cMjesec")+".and."+;
              IF(EMPTY(cGodina),".t.","GODINA==cGodina")
     if lViseObr
       cFilt+=".and. obr=cObracun"
     endif
     INDEX ON &cSort1 TO "TMPLD" FOR &cFilt EVAL(TekRec2()) EVERY 1
    BoxC()
    GO TOP
  ENDIF
endif


EOF CRET

nStrana:=0

m:="----- "+replicate("-",_LR_)+" ----------------------------------- ----------- -------------------------"
bZagl:={|| ZPlatSp() }

select rj; hseek ld->idrj; select ld

START PRINT CRET


nPocRec:=RECNO()

FOR nDio:=1 TO IF(cDrugiDio=="D",2,1)

IF nDio==2; GO (nPocRec); ENDIF

Eval(bZagl)

nT1:=nT2:=nT3:=nT4:=0
nRbr:=0
do while !eof() .and.  cgodina==godina .and. idrj=cidrj .and. cmjesec=mjesec .and.;
         !( lViseObr .and. !EMPTY(cObracun) .and. obr<>cObracun )
 IF lViseObr .and. EMPTY(cObracun)
   ScatterS(godina,mjesec,idrj,idradn)
 else
   Scatter()
 endif
 select radn; hseek _idradn; select ld
 if nIznosTO = 0      // isplata plate
   if !lSviRadnici .and. !(empty(radn->isplata) .or. radn->isplata="BL")
      skip
      loop
   endif
 else               // isplata toplog obroka
   if !(&qqImaTO)
      skip
      loop
   endif
 endif
 if prow()>62+gpStranica; FF; Eval(bZagl); endif
 ? str(++nRbr,4)+".",idradn, RADNIK
 
 nC1:=pcol()+1
 IF nIznosTO<>0
   _uiznos:=nIznosTO
 ENDIF
 if cprikizn=="D"
   if nProcenat<>100
    IF nDio==1
      @ prow(),pcol()+1 SAY round(_uiznos*nprocenat/100,nzkk) pict gpici
    ELSE
      @ prow(),pcol()+1 SAY ROUND(_uiznos,nzkk)-round(_uiznos*nprocenat/100,nzkk) pict gpici
    ENDIF
   else
    @ prow(),pcol()+1 SAY _uiznos pict gpici
   endif
 else
  @ prow(),pcol()+1 SAY space(len(gpici))
 endif
 @ prow(),pcol()+4 SAY replicate("_",22)
 if cProred=="D"
   ?
 endif
 nT1+=_usati; nT2+=_uneto; nT3+=_uodbici
 IF  NPROCENAT<>100
   IF nDio==1
     nT4 += round(_uiznos*nprocenat/100,nzkk)
   ELSE
     nT4 += ( round(_uiznos,nzkk) - round(_uiznos*nprocenat/100,nzkk) )
   ENDIF
 ELSE
   nT4+=_uiznos
 ENDIF
 skip
enddo

if prow()>60+gpStranica; FF; Eval(bZagl); endif
? m
? SPACE(1) + Lokal("UKUPNO:")
if cprikizn=="D"
  @ prow(),nC1 SAY  nT4 pict gpici
endif
? m
FF

NEXT

END PRINT

CLOSERET


function ZPlatSp()
*{
P_12CPI
? UPPER(gTS)+":",gnFirma
?
if empty(cidrj)
	? Lokal("Pregled za sve RJ ukupno:")
else
 	? Lokal("RJ:"), cIdRj, rj->naz
endif

?? SPACE(2) + Lokal("Mjesec:"),str(cmjesec,2)+IspisObr()
?? SPACE(4) + Lokal("Godina:"),str(cGodina,5)
DevPos(prow(),74)
?? Lokal("Str."),str(++nStrana,3)
?

IF !EMPTY(cNaslov)
	? PADC(ALLTRIM(cNaslov),90)
  	? PADC(REPL("-",LEN(ALLTRIM(cNaslov))),90)
ENDIF
if nProcenat<>100
	?
 	? Lokal("Procenat za isplatu:")
 	if nDio==1
  		@ prow(),pcol()+1 SAY nprocenat pict "999.99%"
 	else
  		@ prow(),pcol()+1 SAY 100-nprocenat pict "999.99%"
 	endif
	?
endif
? m
? Lokal("Rbr   Sifra           Naziv radnika               ") + iif(cPrikIzn=="D",Lokal("ZA ISPLATU"),"          ")+"         " + Lokal("Potpis")
? m

return
*}


/*! \fn PlatSpTR(cVarijanta)
 *  \brief Platni spisak tekuci racun
 *  \param cVarijanta "1" - tekuci racun, "2" - stedna knjizica
 */
function PlatSpTR(cVarijanta)
*{
local nC1:=20
cIdRadn:=space(_LR_)
cIdRj:=gRj
cMjesec:=gMjesec
cGodina:=gGodina
cObracun:=gObracun
cVarSort:="2"

O_KRED
O_RJ
O_RADN
O_LD

cProred:="N"
cPrikIzn:="D"
nProcenat:=100
nZkk:=gZaok

private cIsplata:=""
private cLokacija
private cConstBrojTR
private nH

if cVarijanta=="1"
	cIsplata:="TR"
else
   	cIsplata:="SK"
endif
cZaBanku:="N"
cIDBanka:=SPACE(_LR_)
cDrugiDio:="D"

O_PARAMS

private cSection:="4"
private cHistory:=" "
private aHistory:={}
RPar("VS",@cVarSort)

Box(,11,50)
@ m_x+1,m_y+2 SAY "Radna jedinica (prazno-sve): "  GET cIdRJ
@ m_x+2,m_y+2 SAY "Mjesec: "  GET  cmjesec  pict "99"
if lViseObr
	@ m_x+2,col()+2 SAY "Obracun: "  GET  cObracun WHEN HelpObr(.t.,cObracun) VALID ValObr(.t.,cObracun)
endif
@ m_x+3,m_y+2 SAY "Godina: "  GET  cGodina  pict "9999"
@ m_x+4,m_y+2 SAY "Prored:"   GET  cProred  pict "@!"  valid cProred $ "DN"
@ m_x+5,m_y+2 SAY "Prikaz iznosa:" GET cPrikIzn pict "@!" valid cPrikizn$"DN"
@ m_x+6,m_y+2 SAY "Prikaz u procentu %:" GET nprocenat pict "999.99"
@ m_x+7,m_y+2 SAY "Banka        :" GET cIdBanka valid P_Kred(@cIdBanka)
@ m_x+8,m_y+2 SAY "Sortirati po(1-sifri,2-prezime+ime)"  GET cVarSort VALID cVarSort$"12"  pict "9"
@ m_x+11,m_y+2 SAY "Spremiti izvjestaj za banku (D/N)" GET cZaBanku pict "@!"

read
clvbox()
ESC_BCR
if nProcenat<>100
	@ m_x+9,m_y+2 SAY "zaokruzenje" GET nZkk pict "99"
  	@ m_x+10,m_y+2 SAY "Prikazati i drugi spisak (za "+LTRIM(STR(100-nProcenat,6,2))+"%-tni dio)" GET cDrugiDio VALID cDrugiDio$"DN" PICT "@!"
  	read
else
	cDrugiDio:="N"
endif
BoxC()

WPar("VS",cVarSort)
SELECT PARAMS
USE

if cZaBanku == "D"
	CreateFileBanka()
endif

select ld
//CREATE_INDEX("LDi1","str(godina)+idrj+str(mjesec)+idradn","LD")
//CREATE_INDEX("LDi2","str(godina)+str(mjesec)+idradn","LD")

if lViseObr
	cObracun:=TRIM(cObracun)
else
  	cObracun:=""
endif

if empty(cIdRj)
	cIdRj:=""
  	if cVarSort=="1"
    		set order to tag (TagVO("2"))
    		hseek str(cGodina,4)+str(cmjesec,2)+cObracun
  	else
    		Box(,2,30)
     		nSlog:=0
		nUkupno:=RECCOUNT2()
     		cSort1:="SortPrez(IDRADN)"
     		cFilt:=IF(EMPTY(cMjesec),".t.","MJESEC==cMjesec")+".and."+IF(EMPTY(cGodina),".t.","GODINA==cGodina")
     		if lViseObr
       			cFilt+=".and. obr=cObracun"
     		endif
     		INDEX ON &cSort1 TO "TMPLD" FOR &cFilt EVAL(TekRec2()) EVERY 1
    		BoxC()
    		go top
  	endif
else
	if cVarSort=="1"
    		set order to tag (TagVO("1"))
    		hseek str(cGodina,4)+cidrj+str(cmjesec,2)+cObracun
  	else
    		Box(,2,30)
     		nSlog:=0
		nUkupno:=RECCOUNT2()
     		cSort1:="SortPrez(IDRADN)"
     		cFilt:="IDRJ==cIdRj.and."+IF(EMPTY(cMjesec),".t.","MJESEC==cMjesec")+".and."+IF(EMPTY(cGodina),".t.","GODINA==cGodina")
     		if lViseObr
       			cFilt+=".and. obr=cObracun"
     		endif
     		INDEX ON &cSort1 TO "TMPLD" FOR &cFilt EVAL(TekRec2()) EVERY 1
    		BoxC()
    		go top
  	endif
endif

EOF CRET

nStrana:=0
m:="----- ------ ----------------------------------- ----------- -------------------------"
bZagl:={|| ZPlatSpTR() }

select rj
hseek ld->idrj
select ld

START PRINT CRET

nPocRec:=RECNO()

for nDio:=1 to IF(cDrugiDio=="D",2,1)
	if nDio==2
		go (nPocRec)
	endif
	Eval(bZagl)
	nT1:=0
	nT2:=0
	nT3:=0
	nT4:=0
	nRbr:=0
	do while !eof() .and.  cGodina==godina .and. idrj=cIdRj .and. cMjesec=mjesec .and.!(lViseObr .and. !EMPTY(cObracun) .and. obr<>cObracun )
		if lViseObr .and. EMPTY(cObracun)
   			ScatterS(godina,mjesec,idrj,idradn)
 		else
   			Scatter()
 		endif
 		select radn
		hseek _idradn
		select ld
 		if radn->isplata<>cIsplata .or. radn->idbanka<>cIdBanka // samo za tekuce racune
    			skip
    			loop
 		endif
 		if prow()>62+gPStranica
			FF
			Eval(bZagl)
		endif
 		? str(++nRbr,4)+".",idradn, RADNIK
		
 		if cZaBanku == "D"
			cZaBnkRadnik := FormatSTR(ALLTRIM(RADNZABNK), 40)
		endif
		
		nC1:=pcol()+1
 		
		if cPrikIzn=="D"
   			if nProcenat<>100
    				if nDio==1
      					@ prow(),pcol()+1 SAY round(_uiznos*nprocenat/100,nzkk) pict gpici
    				else
      					@ prow(),pcol()+1 SAY ROUND(_uiznos,nzkk)-round(_uiznos*nprocenat/100,nzkk) pict gpici
    				endif
   			else
    				@ prow(),pcol()+1 SAY _uiznos pict gpici
				if cZaBanku == "D"
					cZaBnkIznos:=FormatSTR(ALLTRIM(STR(_uiznos), 6, 2), 7, .t. )
				endif
   			endif
 		else
  			@ prow(),pcol()+1 SAY space(len(gpici))
 		endif
 		if cIsplata=="TR"
  			@ prow(),pcol()+4 SAY padl(radn->brtekr,22)
			if cZaBanku=="D"
				cZaBnkTekRn:=FormatSTR(ALLTRIM(radn->brtekr), 7, .t. )
			endif
 		else
   			@ prow(),pcol()+4 SAY padl(radn->brknjiz,22)
 			if cZaBanku=="D"
				cZaBnkTekRn:=FormatSTR(ALLTRIM(radn->brknjiz), 7, .t. )
			endif
		endif
 		if cProred=="D"
   			?
 		endif
 		nT1+=_usati
		nT2+=_uneto
		nT3+=_uodbici
 		if  nProcenat<>100
  			if nDio==1
     				nT4+=round(_uiznos*nprocenat/100,nzkk)
   			else
     				nT4+=(round(_uiznos,nzkk) - round(_uiznos*nprocenat/100,nZKK))
   			endif
 		else
   			nT4+=_uiznos
 		endif
 		skip
		
		if cZaBanku=="D"
			cUpisiZaBanku:=""
			cUpisiZaBanku+=cZaBnkTekRn
			cUpisiZaBanku+=cZaBnkRadnik
			cUpisiZaBanku+=cZaBnkIznos
			Write2File(nH, cUpisiZaBanku, .t.)
			// reset varijable
			cUpisiZaBanku:=""
		endif
	enddo

	if prow()>60+gPStranica
		FF
		Eval(bZagl)
	endif
	? m
	? SPACE(1) + Lokal("UKUPNO:")
	if cPrikIzn=="D"
  		@ prow(),nC1 SAY nT4 pict gpici
	endif
	? m
	FF
next

if cZaBanku == "D"
	CloseFileBanka(nH)	
endif

END PRINT
CLOSERET
return
*}

function ZPlatSpTR()
*{
P_12CPI

select kred
// ovo izbacio jer ne daje dobar naziv banke!!!
//hseek radn->idbanka
hseek cIdBanka
select ld

?
? Lokal("Poslovna BANKA:") + SPACE(1), cIDBanka, "-", kred->naz
?
? UPPER(gTS)+":",gnFirma
?

if empty(cIdRj)
	? Lokal("Pregled za sve RJ ukupno:")
else
 	? Lokal("RJ:"),cIdRj,rj->naz
endif

?? SPACE(2) + Lokal("Mjesec:"),str(cmjesec,2)+IspisObr()
?? SPACE(4) + Lokal("Godina:"),str(cGodina,5)
devpos(prow(),74)
?? Lokal("Str."),str(++nStrana,3)
?
if nprocenat<>100
	?
 	? Lokal("Procenat za isplatu:")
	if nDio==1
  		@ prow(),pcol()+1 SAY nprocenat pict "999.99%"
 	else
  		@ prow(),pcol()+1 SAY 100-nprocenat pict "999.99%"
 	endif
	?
endif
?
? m
? Lokal("Rbr   Sifra           Naziv radnika               ") + iif(cPrikIzn=="D",Lokal("ZA ISPLATU"),"          ") + iif(cIsplata=="TR", SPACE(9) + Lokal("Broj T.Rac"),SPACE(8) + Lokal("Broj St.knj"))
? m

return
*}



/*! \fn IsplataTR(cVarijanta)
 *  \brief Isplata nekog tipa primanja na tekuci racun ili stednu knjizicu
 *  \param cVarijanta "1" - tekuci racun, "2" - stedna knjizica
 */
function IsplataTR(cVarijanta)
*{
local nC1:=20
cIdRadn:=space(_LR_)
cIdRj:=gRj
cMjesec:=gMjesec
cGodina:=gGodina
cObracun:=gObracun
cVarSort:="2"
cIdTipPr:="  "

O_TIPPR
O_KRED
O_RJ
O_RADN
O_LD
set relation to idradn into radn

cProred:="N"
cPrikIzn:="D"
nZkk:=gZaok
if IsMupZeDo()
	cZaBanku:="N"
endif
private cIsplata:=""
private cLokacija
private cConstBrojTR
private nH

if cVarijanta=="1"
	cIsplata:="TR"
else
   	cIsplata:="SK"
endif

cIDBanka:=SPACE(LEN(radn->idbanka))

O_PARAMS

private cSection:="4"
private cHistory:=" "
private aHistory:={}
RPar("VS",@cVarSort)

Box(,10,50)
@ m_x+1,m_y+2 SAY "Radna jedinica (prazno-sve): "  GET cIdRJ
@ m_x+2,m_y+2 SAY "Mjesec: "  GET  cmjesec  pict "99"
if lViseObr
	@ m_x+2,col()+2 SAY "Obracun: "  GET  cObracun WHEN HelpObr(.t.,cObracun) VALID ValObr(.t.,cObracun)
endif
@ m_x+3,m_y+2 SAY "Godina: "  GET  cGodina  pict "9999"
@ m_x+4,m_y+2 SAY "Prored:"   GET  cProred  pict "@!"  valid cProred $ "DN"
@ m_x+5,m_y+2 SAY "Prikaz iznosa:" GET cPrikIzn pict "@!" valid cPrikizn$"DN"
@ m_x+6,m_y+2 SAY "Primanje (prazno-sve ukupno):" GET cIdTipPr valid empty(cIdTipPr).or.P_TipPr(@cIdTipPr)
@ m_x+7,m_y+2 SAY "Banka (prazno-sve) :" GET cIdBanka valid empty(cIdBanka).or.P_Kred(@cIdBanka)
@ m_x+8,m_y+2 SAY "Sortirati po(1-sifri,2-prezime+ime)"  GET cVarSort VALID cVarSort$"12"  pict "9"

// benjo, 08.04.2004, dodan uslov zbog ispadanja ako nije mupzedo
if ( IsMupZeDo() )
	@ m_x+9,m_y+2 SAY "Snimiti izvjestaj za banku (D/N)?"  GET cZaBanku VALID cZaBanku$"DN"  pict "@!"
endif

read
clvbox()
ESC_BCR
BoxC()

WPar("VS",cVarSort)
SELECT PARAMS
USE

if (IsMupZeDo() .and. cZaBanku=="D")
	CreateFileBanka()
endif

select ld
//CREATE_INDEX("LDi1","str(godina)+idrj+str(mjesec)+idradn","LD")
//CREATE_INDEX("LDi2","str(godina)+str(mjesec)+idradn","LD")

if lViseObr
	cObracun:=TRIM(cObracun)
else
  	cObracun:=""
endif

if empty(cIdRj)
	cIdRj:=""
	Box(,2,30)
     	nSlog:=0
	nUkupno:=RECCOUNT2()
  	if cVarSort=="1"
     		cSort1:="radn->idbanka+IDRADN"
  	else
     		cSort1:="radn->idbanka+SortPrez(IDRADN)"
  	endif
	if empty(cIdBanka)
		cFilt:="radn->isplata==cIsplata.and."
	else
		cFilt:="radn->isplata==cIsplata.and.radn->idBanka==cIdBanka.and."
	endif
     	cFilt:=cFilt+IF(EMPTY(cMjesec),".t.","MJESEC==cMjesec")+".and."+IF(EMPTY(cGodina),".t.","GODINA==cGodina")
     	if lViseObr
       		cFilt+=".and. obr=cObracun"
     	endif
     	INDEX ON &cSort1 TO "TMPLD" FOR &cFilt EVAL(TekRec2()) EVERY 1
    	BoxC()
    	go top
else
    	Box(,2,30)
     	nSlog:=0
	nUkupno:=RECCOUNT2()
	if cVarSort=="1"
     		cSort1:="radn->idbanka+IDRADN"
  	else
     		cSort1:="radn->idbanka+SortPrez(IDRADN)"
  	endif
	if empty(cIdBanka)
		cFilt:="radn->isplata==cIsplata.and."
	else
		cFilt:="radn->isplata==cIsplata.and.radn->idBanka==cIdBanka.and."
	endif
     	cFilt:=cFilt+"IDRJ==cIdRj.and."+IF(EMPTY(cMjesec),".t.","MJESEC==cMjesec")+".and."+IF(EMPTY(cGodina),".t.","GODINA==cGodina")
     	if lViseObr
       		cFilt+=".and. obr=cObracun"
     	endif
     	INDEX ON &cSort1 TO "TMPLD" FOR &cFilt EVAL(TekRec2()) EVERY 1
    	BoxC()
    	go top
endif

EOF CRET

nStrana:=0
m:="----- ------ ----------------------------------- ----------- -------------------------"
bZagl:={|| ZIsplataTR() }

select rj
hseek ld->idrj
select ld

START PRINT CRET

do while !eof()

	cIdTBanka:=radn->idBanka
	nStrana:=0

	Eval(bZagl)
	nT1:=0
	nT2:=0
	nT3:=0
	nT4:=0
	nRbr:=0

	do while !eof() .and.  cGodina==godina .and. idrj=cIdRj .and. cMjesec=mjesec .and.!(lViseObr .and. !EMPTY(cObracun) .and. obr<>cObracun ) .and. radn->idBanka==cIdTBanka
		if lViseObr .and. EMPTY(cObracun)
   			ScatterS(godina,mjesec,idrj,idradn)
 		else
   			Scatter()
 		endif
 		//select radn
		//hseek _idradn
		//select ld

		if empty(cIdTipPr)
			nIznosTP:=_uiznos
		else
			nIznosTP:=_i&cIdTipPr
		endif
 		if nIznosTP=0
    			skip
    			loop
 		endif
 		if prow()>62+gPStranica
			FF
			Eval(bZagl)
		endif
 		? str(++nRbr,4)+".",idradn, RADNIK
 		cZaBnkRadnik:=FormatSTR(RADNZABNK, 40)
		
		nC1:=pcol()+1
 		if cPrikIzn=="D"
    			@ prow(),pcol()+1 SAY nIznosTP pict gpici
 			cZaBnkIznos:=FormatSTR(ALLTRIM(STR(nIznosTP)),20)
		else
  			@ prow(),pcol()+1 SAY space(len(gpici))
 		endif
 		if cIsplata=="TR"
  			@ prow(),pcol()+4 SAY padl(radn->brtekr,22)
			cZaBnkTekRN:=FormatSTR(ALLTRIM(radn->brtekr), 6)
 		else
   			@ prow(),pcol()+4 SAY padl(radn->brknjiz,22)
 		endif
 		if cProred=="D"
   			?
 		endif
		if IsMupZeDo() .and. cZaBanku=="D"
			cUpisiZaBanku:=""
			cUpisiZaBanku+=cConstBrojTR
			cUpisiZaBanku+=cZaBnkIznos
			cUpisiZaBanku+=cZaBnkTekRn
			cUpisiZaBanku+=cZaBnkRadnik
			Write2File(nH, cUpisiZaBanku, .t.)
			// reset varijable
			cUpisiZaBanku:=""
		endif
		
		nT1+=_usati
		nT2+=_uneto
		nT3+=_uodbici
   		nT4+=nIznosTP
 		skip
	enddo

	if prow()>60+gPStranica
		FF
		Eval(bZagl)
	endif
	? m
	? SPACE(1) + Lokal("UKUPNO:")
	if cPrikIzn=="D"
  		@ prow(),nC1 SAY nT4 pict gpici
	endif
	? m
	FF
	
enddo

if (IsMupZeDo() .and. cZaBanku=="D")
	CloseFileBanka(nH)
endif

END PRINT
CLOSERET
return
*}

function ZIsplataTR()
*{
P_12CPI

select kred
// ovo izbacio jer ne daje dobar naziv banke!!!
//hseek radn->idbanka
hseek cIdTBanka
select ld

?
? Lokal("Poslovna BANKA:") + SPACE(1), cIDTBanka, "-", kred->naz
?
? UPPER(gTS)+":",gnFirma
?

if empty(cidrj)
	? Lokal("Pregled za sve RJ ukupno:")
else
 	? Lokal("RJ:"), cIdRj, rj->naz
endif

?? SPACE(2) + Lokal("Mjesec:"), str(cmjesec,2)+IspisObr()
?? SPACE(4) + Lokal("Godina:"), str(cGodina,5)
devpos(prow(),74)
?? Lokal("Str."), str(++nStrana,3)
?
if empty(cIdTipPr)
	? Lokal("PLATNI SPISAK")
else
	? Lokal("ISPLATA TIPA PRIMANJA:"), cIdTipPr, TIPPR->naz
endif
?
? m
? Lokal("Rbr   Sifra           Naziv radnika               ") + iif(cPrikIzn=="D",Lokal("ZA ISPLATU"),"          ")+iif(cIsplata=="TR",SPACE(9) + Lokal("Broj T.Rac"), SPACE(8) + Lokal("Broj St.knj"))
? m

return
*}


function Write2File(nH, cLinija, lNoviRed)
#DEFINE NL CHR(13)+CHR(10)
if lNoviRed
	FWrite(nH, cLinija+NL)
else
	FWrite(nH, cLinija)
endif
return


// ----------------------------------------------
// formatiranje stringa ....
// ----------------------------------------------
function FormatSTR(cString, nLen, lLeft, cFill )

if lLeft == nil
	lLeft := .f.
endif

if cFill == nil
	cFill := "0"
endif

// formatiraj string na odredjenu duzinu
cRet := PADR( cString, nLen )

// zamjeni "." -> ","
cRet := STRTRAN( cRet, ".", "," )

if lLeft == .t.
	cRet := PADL( ALLTRIM( cRet ), nLen, cFill )
endif

return cRet



function CreateFileBanka()
*{
MsgBeep("Odaberite lokaciju za snimanje fajla")
Box(,5,70)
	cLokacija:="C:\" + DToS(Date()) + ".txt" + SPACE(30)
	cConstBrojTR:="56480 "
	@ 1+m_x, 2+m_y SAY "Parametri:"
	@ 3+m_x, 2+m_y SAY "Sifra isplatioca tek.rac:" GET cConstBrojTR 
	@ 4+m_x, 2+m_y SAY "Naziv fajla prenosa:" GET cLokacija
	read
BoxC()
if Pitanje(,"Izvrsiti prenos fajla","D")=="N"
	return
endif
if (AT("a:", cLokacija)<>0 .or. AT("A:", cLokacija)<>0)
	MsgBeep("Spremite praznu disketu...")
endif

cConstBrojTR:=FormatSTR(ALLTRIM(cConstBrojTR), 6)
cLokacija:=ALLTRIM(cLokacija)
nH:=FCreate(cLokacija)

if nH==-1
	MsgBeep("Greska pri kreiranju fajla !!!")
	return
endif
return
*}


function CloseFileBanka(nHnd)
*{
FClose(nHnd)
MsgBeep("Fajl pohranjen u " + cLokacija)
*}

