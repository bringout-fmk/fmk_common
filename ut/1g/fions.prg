#include "ld.ch"



function Unos2()
return (nil)

// --------------------------------------------------------
// Vraca oznaku obracuna ako se radi o vise obracuna
// --------------------------------------------------------
function BrojObracuna()
private cOznObracuna

if lViseObr
	cOznObracuna:=cObracun
else
	cOznObracuna:=""
endif

return cOznObracuna

// ---------------------------------
// ukupno radnik
// ---------------------------------
function UkRadnik()
local i
local nArr

nArr:=select()

private cPom:=""

for i:=1 to cLDPolja
	cPom:=padl(alltrim(str(i)),2,"0")
 	select tippr
	seek cPom
 	if tippr->(found()) .and. tippr->aktivan=="D"
   		if tippr->ufs=="D"
     			_USati+=_s&cPom
   		endif
   		_UIznos+=_i&cPom
   		if tippr->uneto=="D"
      			_Uneto+=_i&cPom
   		else
      			_UOdbici+=_i&cPom
   		endif
 	endif
next

select(nArr)
return (nil)



/*! \fn ParObr(nMjesec, cObr, cIdRj)
 *  \brief Parametri obracuna
 *  \param nMjesec - mjesec
 *  \param cObr - broj obracuna
 *  \param cIdRj - id radna jedinica
 */
function ParOBr(nMjesec,cObr,cIDRJ)
*{
local nNaz
local nRec1:=0
local nRec2:=0
local nRec3:=0

if cObr==nil
	cObr:=""
endif

if cIDRJ==nil
	cIDRJ:=""
endif

nArr := SELECT()

SELECT PAROBR
SEEK STR(nMjesec,2)+cObr

IF !FOUND() .or. EOF()
	SKIP -1
ENDIF

IF IzFMKINI("LD","VrBodaPoRJ","N",KUMPATH)=="D"
	nRec1:=RECNO()
   	DO WHILE !EOF() .and. id==STR(nMjesec,2)
     		IF lViseObr .and. cObr<>obr
      			SKIP 1
			LOOP
     		ENDIF
     		IF IDRJ==cIdRj
       			nRec3:=RECNO()
       			EXIT
     		ENDIF
     		IF EMPTY(IDRJ)
       			nRec2:=RECNO()
     		ENDIF
     		SKIP 1
   	ENDDO
   	IF nRec3<>0
     		GO (nRec3)
   	ELSEIF nRec2<>0
     		GO (nRec2)
   	ELSE
     		GO (nRec1)
   	ENDIF
ENDIF

SELECT (nArr)
RETURN
*}


/*! \fn Izracunaj(ixx, fPrikaz)
 *  \brief Izracunavanje formula
 *  \param ixx - 
 *  \param fPrikaz - prikazi .t.
 */
function Izracunaj(ixx,fPrikaz)
*{
private cFormula

if PCount()==1
	fPrikaz:=.t.
endif

cFormula:=TRIM(tippr->formula)

if (tippr->fiksan<>"D") 
	// ako je fiksan iznos nista ne izracunavaj!
	if EMPTY(cFormula)
   		ixx:=0
 	else
   		ixx:=&cFormula
 	endif
	ixx:=ROUND(ixx,gZaok)
endif
return .t.
*}



/*! \fn Prosj3(cTip, cTip2)
 *  \brief Prosjek 3 mjeseca
 *  \param cTip
 *  \param cTip2
 */
function Prosj3(cTip, cTip2)
*{
// cTip1
// "1"  -> prosjek neta/ satu
// "2"  -> prosjek ukupnog primanja/satu
// "3"  -> prosjek neta
// "4"  -> prosjek ukupnog primanja
// "5"  -> prosjek ukupnog primanja/ukupno sati
// "6"  -> prosjek ukupnih "raznih" primanja/satu
// "7"  -> prosjek ukupnih "raznih" primanja/ukupno sati
// "8"  -> prosjek ukupnih "raznih" primanja
//
// cTip2
// "1"  -> striktno predhodna 3 mjeseca
// "2"  -> vracam se mjesec unazad u kome nije bilo godisnjeg

local nMj1:=nMj2:=nMj3:=0,nDijeli:=0, cmj1:=cmj2:=cmj3:="",npomak:=0,i:=0
local nss1:=0,nss2:=0,nss3:=0,nSumsat:=0
local nsp1:=0, nsp2:=0, nsp3:=0

PushWA()

//CREATE_INDEX("LDi1","str(godina)+idrj+str(mjesec)+idradn","LD")
//CREATE_INDEX("LDi2","str(godina)+str(mjesec)+idradn","LD")
set order to tag (TagVO("2","I"))

i:=0
if ctip2=="2"
	do while .t.
  		++i
  		if _Mjesec-i<1
   			seek str(_Godina-1,4)+str(12+_Mjesec-i,2)+_idradn
   			cMj1:=str(12+_mjesec-i,2)+"."+str(_godina-1,4)
  		else
   			seek str(_Godina,4)+str(_mjesec-i,2)+_idradn
   			cMj1:=str(_mjesec-i,2)+"."+str(_godina,4)
  		endif
  		if &gFUGod<>0
    			nPomak++
  		else
    			exit
  		endif
  		if i>12  // nema podataka
    			exit
  		endif
 	enddo
endif

if _mjesec-1-npomak<1
	seek str(_Godina-1,4)+str(12+_Mjesec-1-npomak,2)+_idradn
  	cMj1:=str(12+_mjesec-1-npomak,2)+"."+str(_godina-1,4)
else
  	seek str(_Godina,4)+str(_Mjesec-1-npomak,2)+_idradn
  	cMj1:=str(_mjesec-1-npomak,2)+"."+str(_godina,4)
endif
if found()
	if lViseObr
     		ScatterS(godina,mjesec,idrj,idradn,"w")
   	else
     		wuneto := uneto
     		wusati := usati
   	endif
   	if cTip $ "13"
     		nMj1:= wUNeto
   	elseif cTip $ "678"
     		nMj1:=URPrim()
   	else
     		nMj1:=UPrim()
   	endif
   	if cTip $ "126"
    		nSS1:=wUSati
    		nSP1:=nMj1
    		if wusati<>0
      			nMj1:=nMj1/wUSati
    		else
      			nMj1:=0
    		endif
   	elseif cTip $ "5"
      		nSS1:=USati()
   	elseif cTip $ "7"
      		nSS1:=URSati()
   	endif
   	if nMj1<>0
		++nDijeli
	endif
endif
if _mjesec-2-npomak<1
	seek str(_Godina-1,4)+str(12+_Mjesec-2-npomak,2)+_idradn
  	cMj2:=str(12+_mjesec-2-npomak,2)+"."+str(_godina-1,4)
else
  	seek str(_Godina,4)+str(_Mjesec-2-npomak,2)+_idradn
  	cMj2:=str(_mjesec-2-npomak,2)+"."+str(_godina,4)
endif
if found()
	if lViseObr
     		ScatterS(godina,mjesec,idrj,idradn,"w")
   	else
     		wuneto := uneto
     		wusati := usati
   	endif
   	if cTip $ "13"
     		nMj2:= wUNeto
   	elseif cTip $ "678"
     		nMj2:=URPrim()
   	else
     		nMj2:=UPrim()
   	endif
   	if cTip $ "126"
    		nSS2:=wUSati
    		nSP2:=nMj2
    		if wusati<>0
      			nMj2:=nMj2/wUSati
    		else
      			nMj2:=0
    		endif
   	elseif cTip $ "5"
      		nSS2:=USati()
   	elseif cTip $ "7"
      		nSS2:=URSati()
   	endif
   	if nMj2<>0
		++nDijeli
	endif
endif

if _mjesec-3-npomak<1
	seek str(_Godina-1,4)+str(12+_Mjesec-3-npomak,2)+_idradn
  	cMj3:=str(12+_mjesec-3-npomak,2)+"."+str(_godina-1,4)
else
  	seek str(_Godina,4)+str(_Mjesec-3-npomak,2)+_idradn
  	cMj3:=str(_mjesec-3-npomak,2)+"."+str(_godina,4)
endif
if found()
	if lViseObr
     		ScatterS(godina,mjesec,idrj,idradn,"w")
   	else
     		wuneto := uneto
     		wusati := usati
   	endif
   	if cTip $ "13"
     		nMj3:= wUNeto
   	elseif cTip $ "678"
     		nMj3:=URPrim()
   	else
     		nMj3:=UPrim()
   	endif
   	if cTip $ "126"
    		nSS3:=wUSati
    		nSP3:=nMj3
    		if wusati<>0
      			nMj3:=nMj3/wUSati
    		else
      			nMj3:=0
    		endif
   	elseif cTip $ "5"
      		nSS3:=USati()
   	elseif cTip $ "7"
      		nSS3:=URSati()
   	endif
   	if nMj3<>0
		++nDijeli
	endif
endif

if nDijeli==0
	nDijeli:=99999999
endif

nSumsat:=IF(nSS1+nSS2+nSS3<>0,nSS1+nSS2+nSS3,99999999)

Box("#"+IF(cTip$"57","UKUPNA PRIMANJA","Prosjek")+" ZA MJESECE UNAZAD:",6,60)
 @ m_x+2,m_y+2 SAY cmj1; @ row(),col()+2 SAY nMj1 pict "999999.999"
 IF cTip$"126"; ?? "  primanja/sati:"; ?? nsp1,"/",nss1; ENDIF
 IF cTip$"57"; ?? "  sati:"; ?? nss1; ENDIF
 @ m_x+3,m_y+2 SAY cmj2; @ row(),col()+2 SAY nMj2 pict "999999.999"
 IF cTip$"126"; ?? "  primanja/sati:"; ?? nsp2,"/",nss2; ENDIF
 IF cTip$"57"; ?? "  sati:"; ?? nss2; ENDIF
 @ m_x+4,m_y+2 SAY cmj3; @ row(),col()+2 SAY nMj3 pict "999999.999"
 IF cTip$"126"; ?? "  primanja/sati:"; ?? nsp3,"/",nss3; ENDIF
 IF cTip$"57"; ?? "  sati:"; ?? nss3; ENDIF
 @ m_x+6,m_y+2 SAY "Prosjek"; @ row(),col()+2 SAY (nMj3+nMj2+nMj1)/IF(cTip$"57",nSumsat,nDijeli) pict "999999.999"
 inkey(0)
BoxC()

PopWa()

return  (nMj3+nMj2+nMj1)/IF(cTip$"57",nSumsat,ndijeli)
*}


/*! \fn UPrim()
 *  \brief Racuna ukupna primanja
 */
function UPrim()
*{
IF lViseObr
	c719:=UbaciPrefix(gFUPrim,"w")
ELSE
  	c719:=gFUPrim
ENDIF
return &c719
*}

/*! \fn USati()
 *  \brief Racuna ukupne sate
 */
function USati()
*{
IF lViseObr
	c719:=UbaciPrefix(gFUSati,"w")
ELSE
  	c719:=gFUSati
ENDIF
return &c719
*}


/*! \fn URPrim()
 *  \brief Ukupna razna primanja
 */
function URPrim()
*{
IF lViseObr
	c719:=UbaciPrefix(gFURaz,"w")
ELSE
  	c719:=gFURaz
ENDIF
return &c719
*}


/*! \fn URSati()
 *  \brief Ukupna razna primanja sati
 */
function URSati()
*{
IF lViseObr
	c719:=UbaciPrefix(gFURSati,"w")
ELSE
  	c719:=gFURSati
ENDIF
return &c719
*}

**********************************************
function Prosj1(cTip,cTip2,cF0)
* if cTip== "1"  -> prosjek neta/ satu
* if ctip== "2"  -> prosjek ukupnog primanja/satu
* if cTip=="3"  -> prosjek neta
* if cTip=="4"  -> prosjek ukupnog primanja
* if cTip=="5"  -> prosjek ukupnog primanja/ukupno sati
* if cTip== "6"  -> prosjek ukupnih "raznih" primanja/satu
* if cTip== "7"  -> prosjek ukupnih "raznih" primanja/ukupno sati
* if cTip== "8"  -> prosjek ukupnih "raznih" primanja

* if cTip2=="1"  -> prosli mjesec i  primanje <> 0
* if ctip2=="2"  -> predhodni mjesec za koji je UNeto==UPrim() i primanje <> 0
* if ctip2=="3"  -> predhodni mjesec za koji je UNeto==URPrim() i primanje <> 0
*
* cF0 = "_i18"  - ne uzimaj mjesec ako je _i18<>0
*************************************************
local nMj1:=0,i:=0
private cFormula
PushWA()

if cF0=NIL
   cFormula:="0"
else
   cFormula:=cF0
endif

//CREATE_INDEX("LDi1","str(godina)+idrj+str(mjesec)+idradn","LD")
//CREATE_INDEX("LDi2","str(godina)+str(mjesec)+idradn","LD")
set order to tag (TagVO("2","I"))

i:=0
do while .t.
 ++i
 if _Mjesec-i<1
   seek str(_Godina-1,4)+str(12+_Mjesec-i,2)+_idradn
   cmj1:=str(12+_mjesec-i,2)+"."+str(_godina-1,4)
 else
   seek str(_Godina,4)+str(_Mjesec-i,2)+_idradn
   cmj1:=str(_mjesec-i,2)+"."+str(_godina,4)
 endif

 if found()
   if lViseObr
     ScatterS(godina,mjesec,idrj,idradn,"w")
   else
     wuneto := uneto
     wusati := usati
   endif
   if cTip $ "13"
     nMj1:= wUNeto
   elseif cTip $ "678"
     nMj1:=URPrim()
   else
     nMj1:=UPrim()
   endif
   if cTip $ "126"
    if wusati<>0
      nMj1:=nMj1/wUSati
    else
      nMj1:=0
    endif
   elseif cTip $ "5"
    if USati()<>0
      nMj1:=nMj1/USati()
    else
      nMj1:=0
    endif
   elseif cTip $ "7"
    if URSati()<>0
      nMj1:=nMj1/URSati()
    else
      nMj1:=0
    endif
   endif
 else
   MsgBeep(Lokal("Prosjek je uzet iz sifrarnika radnika - OSN.BOL. !"))
   SELECT RADN; SET ORDER TO TAG "1"; GO TOP
   HSEEK _IdRadn
   nMj1 := osnbol
   SELECT LD
   exit
 endif

 if nMj1==0; loop; endif

 if &cFormula<>0
    loop
 endif

 if cTip2=="1"  // gleda se prosli mjesec
   exit
 elseif cTip2=="3"
   if round(wUNeto,2)==round(URPrim(),2)
     exit
   endif
 else
   if round(wUNeto,2)==round(UPrim(),2)
     exit
   endif
 endif

enddo

Box(,4,50)
 @ m_x+1,m_y+2 SAY "PRIMANJE ZA PROSLI MJESEC:"
 @ m_x+2,m_y+2 SAY  cmj1; @ row(),col()+2 SAY nMj1 pict "999999.999"
 @ m_x+4,m_y+2 SAY "Prosjek"; @ row(),col()+2 SAY nMj1 pict "999999.999"
 inkey(0)
BoxC()

PopWa()

return  nMj1


*********************
*
*********************
function Predhodni(i,cVar,cObr)
 local cKljuc:=""
 if cObr==NIL; cObr:="1"; ENDIF
 private cpom:=""

 IF "U" $ TYPE("lRekalk"); lRekalk:=.f.; ENDIF

 IF lRekalk .and. !TPImaPO(SUBSTR(cVar,3))  // pri rekalkulaciji ne racunaj
   return 0                                 // predhodni ukoliko u formuli
 ENDIF                                      // nema parametara obracuna

 PushWa()

 //CREATE_INDEX("LDi1","str(godina)+idrj+str(mjesec)+idradn","LD")
 //CREATE_INDEX("LDi2","str(godina)+str(mjesec)+idradn","LD")
 set order to tag (TagVO("2","I"))

 if _Mjesec-i<1
    hseek str(_Godina-1,4)+str(12+_Mjesec-1,2)+_idradn
 else
    hseek str(_Godina,4)+str(_Mjesec-i,2)+_idradn
 endif

 cPom:=cVar
 cField=substr(cPom,2)

 if lViseObr
   &cPom := 0
   cKljuc := STR(godina,4)+STR(mjesec,2)+idradn
   IF !EMPTY(cObr)
     do while !eof() .and. STR(godina,4)+STR(mjesec,2)+idradn == cKljuc
       IF obr==cObr
         &cPom += &cField
       ENDIF
       skip 1
     enddo
   ELSE
     do while !eof() .and. STR(godina,4)+STR(mjesec,2)+idradn == cKljuc
       &cPom += &cField
       skip 1
     enddo
   ENDIF
 else
   &cPom:=&cField
 endif

 PopWa()
return 0


************************************
function PrimSM(cOznaka,cTipPr)
*
* cOznaka - oznaka primanja u smecu
* cTipPr  - "01, "02" , ...
*           "NE" - neto
* izlaz = primanje iz smeca
************************************
local nRez:=0

private cTipa:=""
//"LDSMi1","Obr+str(godina)+str(mjesec)+idradn+idrj",PRIVPATH+"LDSM")

private cpom:=""

PushWa()

select (F_LDSM)
if !used()
  O_LDSM
endif

seek cOznaka+str(_godina)+str(_mjesec)+_idradn+_idrj
if cTippr=="NE"
    nRez:=UNETO
else
    cTipa:="I"+cTipPr
    nRez :=&cTipa
endif

PopWa()
return nRez

**************************
**************************
function Fill(xValue,xIzn)
 if type(xIzn)<>"UI" .and. type(xIzn)<>"UE"
   xVAlue:=&xIzn
   ShowGets()
 endif
return 0

**************************
function FillR(xValue,xIzn)
* fora za bolovanje
* Filr("OSNBOL",PROSJ1("2","2","I18"))
**************************
 PushWa()
 select radn
 replace &xVAlue with xIzn
 PopWa()
return xIzn

**************************
function GETR(cPrompt,xValue)
**************************
local nRezult

private Getlist:={}

 PushWa()
 select radn

 nRezult:=&xValue
 Box(,2,60)
    @ m_x+1,m_y+2 SAY cPrompt GET nRezult
    read
 BoxC()
 if lastkey()==K_ESC
    return &xValue
 endif
 replace &xValue with nRezult
 PopWa()
return nRezult




function FillBrBod()
*{
if (radn->brbod<>_brbod)
	if Pitanje(, Lokal("Staviti u sifrarnik radnika ovu vrijednost D/N?"),"N")=="D"
     		select radn
     		replace brbod with _brbod
     		select ld
  	endif
endif
return .t.
*}



function FillKMinRad()
*{
if radn->kminrad<>_kminrad
	if Pitanje(,Lokal("Staviti u sifrarnik radnika ovu vrijednost D/N?"),"N")=="D"
     		select radn
     		replace kminrad with _kminrad
     		select ld
  	endif
endif
return .t.
*}

function FillRadSati(cIdRadnik,nRadniSati)
*{
if Pitanje(, Lokal("Unos placenih sati (D/N)?"),"D")=="N"
	return
endif

nPlacenoRSati:=0
cOdgovor:="D"

Box(,9,48)
	cSatiPredhodni:=GetStatusRSati(cIdRadnik)	
	@ m_x+1,m_y+2 SAY Lokal("Radnik:   ") + ALLTRIM(cIdRadnik)
	@ m_x+2,m_y+2 SAY Lokal("Ostalo iz predhodnih obracuna: ") + ALLTRIM(cSatiPredhodni) + " sati"
	@ m_x+3,m_y+2 SAY "-----------------------------------------------"
	@ m_x+4,m_y+2 SAY Lokal("Uplaceno sati: ") GET nPlacenoRSati PICT "99999999" 
	read
	@ m_x+5,m_y+2 SAY "-----------------------------------------------"
	@ m_x+6,m_y+2 SAY Lokal("Radni sati ovaj mjesec  : ") + ALLTRIM(STR(nRadniSati))
	@ m_x+7,m_y+2 SAY Lokal("Placeni sati ovaj mjesec: ") + ALLTRIM(STR(nPlacenoRSati))
	@ m_x+8,m_y+2 SAY Lokal("Ostalo ") + ALLTRIM(STR(nRadniSati-nPlacenoRSati+VAL(cSatiPredhodni))) + Lokal(" sati za sljedeci mjesec !")
  	@ m_x+9,m_y+2 SAY Lokal("Sacuvati promjene (D/N)? ") GET cOdgovor VALID cOdgovor$"DN" PICT "@!"
	read
	
	if cOdgovor=="D"	
		UbaciURadneSate(cIdRadnik,nRadniSati-nPlacenoRSati)
	else
		MsgBeep(Lokal("Promjene nisu sacuvane !!!"))
	endif
BoxC()
return
*}

function GetStatusRSati(cIdRadn)
*{
local nArr
nArr:=SELECT()

select radsat
hseek cIdRadn
nSati:=field->sati

select (nArr)

return STR(nSati)
*}

function UbaciURadneSate(cIdRadn,nIznosSati)
*{
local nArr
nArr:=SELECT()

select radsat
hseek cIdRadn

if Found()
	nPredhodniSati:=field->sati
	replace field->sati with nIznosSati+nPredhodniSati
else
	append blank
	replace field->idradn with cIdRadn
	replace field->sati with nIznosSati
endif

select (nArr)

return
*}

function FillVPosla()
*{
if radn->idvposla<>_idvposla
	if Pitanje( , Lokal("Staviti u sifrarnik radnika ovu vrijednost D/N?"),"N")=="D"
    		select radn
     		replace idvposla with _idvposla
     		select ld
  	endif
endif
return .t.
*}


******************************
* izracun bruto iznosa
******************************
function Bruto(nbruto,ndopr)
*{

nBruto:=_UNETO
nPorDopr:=0

select (F_POR)

if !used()
	O_POR
endif

select (F_DOPR)

if !used()
	O_DOPR
endif

select (F_KBENEF)

if !used()
	O_KBENEF
endif

nBO:=0
nBo:=parobr->k3/100*MAX(_UNeto,PAROBR->prosld*gPDLimit/100)

select por
go top

nPom:=nPor:=0
nC1:=30
nPorOl:=0

do while !eof()
	nPom:=max(dlimit,round(iznos/100*MAX(_UNeto,PAROBR->prosld*gPDLimit/100),gZaok))
   	nPor+=nPom
   	skip
enddo

nBruto+=nPor
nPorDopr+=nPor

if radn->porol<>0  // poreska olaksica
	nPorOl:=parobr->prosld*radn->porol/100
   	if nPorOl>nPor // poreska olaksica ne moze biti veca od poreza
     		nPorOl:=nPor
   	endif
   	nBruto-=nPorol
   	nPorDopr-=nPorOl
endif
if radn->porol<>0
  //? m
  //? "Ukupno Porez"
    //@ prow(),nC1 SAY space(len(gpici))
    //@ prow(),39 SAY nPor-nPorOl pict gpici
   //? m
endif

select dopr
go top

nPom:=nDopr:=0
nC1:=20

do while !eof()  // DOPRINOSI
	if right(id,1)<>"X"
   		SKIP
		LOOP
 	endif
 	//? id,"-",naz
 	//@ prow(),pcol()+1 SAY iznos pict "99.99%"
 	if empty(idkbenef) // doprinos udara na neto
   		//@ prow(),pcol()+1 SAY nBO pict gpici
   		//nC1:=pcol()+1
   		nPom:=max(dlimit,round(iznos/100*nBO,gZaok))
   		nBruto+=nPom
   		nPorDopr+=nPom
 	else
   		nPom0:=ASCAN(aNeta,{|x| x[1]==idkbenef})
   		if nPom0<>0
     			nPom2:=parobr->k3/100*aNeta[nPom0,2]
   		else
     			nPom2:=0
   		endif
   		if round(nPom2,gZaok)<>0
     			//@ prow(),pcol()+1 SAY nPom2 pict gpici
     			//nC1:=pcol()+1
     			nPom:=max(dlimit,round(iznos/100*nPom2,gZaok))
     			nBruto+=nPom
     			nPorDopr+=nPom
   		endif
 	endif

	skip
enddo // doprinosi
//? m
//? "UKUPNO POREZ+DOPRINOSI"
//@ prow(),39 SAY nPorDopr pict gpici
//? m
//? "BRUTO IZNOS"
//@ prow(),60 SAY nBruto pict gpici
//? m
return (nBruto)
*}



***********************************************
// Provjerava ima li u formuli tipa
// primanja cTP parametara obracuna ("PAROBR")
***********************************************
FUNCTION TPImaPO(cTP)
  LOCAL lVrati:=.f., nObl:=SELECT()
  SELECT TIPPR; PushWA()
  SEEK cTP
  IF ID==cTP .and. "PAROBR" $ UPPER(TIPPR->formula); lVrati:=.t.; ENDIF
  PopWA(); SELECT (nObl)
RETURN lVrati


PROCEDURE PromSif()
 cSifr:="1"            // 1-radnici, 2-firme
 Box(,4,70)
  @ m_x+2, m_y+2 SAY "Iz kojeg sifrarnika je sifra koju zelite promijeniti?"
  @ m_x+3, m_y+2 SAY Lokal("(1-radnici,2-firme)..................................") GET cSifr VALID cSifr$"12"
  READ
 BoxC()
 IF LASTKEY()==K_ESC; CLOSERET; ENDIF

 DO CASE

   CASE cSifr=="1"
      #ifdef CPOR
       cIdS:=cIdN:=SPACE(13)
      #else
       cIdS:=cIdN:=SPACE(6)
      #endif
      Box(,4,60)
       @ m_x+0, m_y+2 SAY "PROMJENA SIFRE RADNIKA"
       @ m_x+2, m_y+2 SAY "Stara sifra:" GET cIdS
       @ m_x+3, m_y+2 SAY "Nova sifra :" GET cIdN
       READ
      BoxC()
      IF LASTKEY()==K_ESC .or. Pitanje( , Lokal("Jeste li sigurni da zelite promijeniti ovu sifru? (D/N)"),"N")=="N"
        CLOSERET
      ENDIF

      O_RADN
      SEEK cIdN
      IF FOUND()
        IF Pitanje( , Lokal("Nova sifra vec postoji u sifrarniku! Zelite li nastaviti?"), "N" ) == "N"
          CLOSERET
        ENDIF
      ENDIF
      SEEK cIdS
      IF FOUND()
        Scatter(); _id:=cIdN; Gather()
      ENDIF

      O_RADKR
      SET ORDER TO TAG "2"
      SEEK cIdS
      DO WHILE !EOF() .and. cIdS==IDRADN
        SKIP 1; nRec:=RECNO(); SKIP -1
        Scatter(); _idradn:=cIdN; Gather()
        GO (nRec)
      ENDDO

      O_LD
      GO TOP
      DO WHILE !EOF()
        IF cIdS==IDRADN
          Scatter(); _idradn:=cIdN; Gather()
        ENDIF
        SKIP 1
      ENDDO

      #ifdef CPOR
       O_RJES; GO TOP
       DO WHILE !EOF()
         IF cIdS==IDRADN
           Scatter(); _idradn:=cIdN; Gather()
         ENDIF
         SKIP 1
       ENDDO

       O_LDNO; GO TOP
       DO WHILE !EOF()
         IF cIdS==IDRADN
           Scatter(); _idradn:=cIdN; Gather()
         ENDIF
         SKIP 1
       ENDDO
      #endif

   CASE cSifr=="2"
      #ifdef CPOR
       cIdS:=cIdN:=SPACE(10)
      #else
       cIdS:=cIdN:=SPACE(6)
      #endif
      Box(,4,60)
       @ m_x+0, m_y+2 SAY "PROMJENA SIFRE FIRME"
       @ m_x+2, m_y+2 SAY "Stara sifra:" GET cIdS
       @ m_x+3, m_y+2 SAY "Nova sifra :" GET cIdN
       READ
      BoxC()
      IF LASTKEY()==K_ESC .or. Pitanje(,"Jeste li sigurni da zelite promijeniti ovu sifru? (D/N)","N")=="N"
        CLOSERET
      ENDIF

      O_KRED
      SEEK cIdN
      IF FOUND()
        IF Pitanje(,"Nova sifra vec postoji u sifrarniku! Zelite li nastaviti?","N")=="N"
          CLOSERET
        ENDIF
      ENDIF
      SEEK cIdS
      IF FOUND()
        Scatter(); _id:=cIdN; Gather()
      ENDIF

      O_RADKR
      SET ORDER TO TAG "3"
      SEEK cIdS
      DO WHILE !EOF() .and. cIdS==IDKRED
        SKIP 1; nRec:=RECNO(); SKIP -1
        Scatter(); _idkred:=cIdN; Gather()
        GO (nRec)
      ENDDO

      #ifdef CPOR
       O_LD
       GO TOP
       DO WHILE !EOF()
         IF cIdS==IDKRED
           Scatter(); _idkred:=cIdN; Gather()
         ENDIF
         SKIP 1
       ENDDO

       O_LDNO; GO TOP
       DO WHILE !EOF()
         IF cIdS==IDKRED
           Scatter(); _idkred:=cIdN; Gather()
         ENDIF
         SKIP 1
       ENDDO
      #endif

 ENDCASE

CLOSERET




function UnosSiht()
local cidradn,cIdRj,nGodina,nMjesec

Private GetList:={}

DO WHILE .T. // G.PETLJA

nGodina:=_Godina
nMjesec:=_Mjesec
cIDradn:=_Idradn
cIDrj:=_IdRj

O_NORSIHT   // sifrarnik normi koje se koriste u sihtarici
O_TPRSIHT   // tipovi primanja koji se unose u kroz sihtarice


select (F_RADSIHT)
if !used(); O_RADSIHT; endif

Scatter()
_Godina:=nGodina
_Mjesec:=nmjesec
_Idradn:=cIdRAdn
_IdRj:=cIdRj
_Dan:=1
_DanDio:=" "


if _BrBod=0
 _BrBod:=radn->brbod
endif

Box(,6 ,68)
@ m_x+0,m_y+2 SAY "SIHTARICA:"

 nDan:=1
 do while .t.

 @ m_x+1,m_Y+2 SAY "Dan" GET _dan pict "99"
 @ m_x+1,col()+2 SAY "Dio dana" GET _dandio valid _dandio$" 12345678" pict "@!"
 @ m_x+1,col()+2 SAY "Broj bodova" GET _BrBod pict "99999.999"  ;
    when {|| _BrBod:=BodovaNaDan(ngodina,nmjesec,cidradn,cidrj,_dan,_dandio),;
              _Brbod:=iif(_BrBod=0,radn->brbod,_BrBod), .t.}
 read

    if lastkey()=K_ESC; exit; endif
 if _Dan>31 .or. _dan=0; exit; endif


 select TPRSiht; go top; _idtippr:=ID
 do while .t.

    @ m_x+2,m_y+2 SAY "   Primanje" GET _idtippr ;
            valid  empty(_idtippr) .or. P_TPRSiht(@_idtippr,2,25) pict "@!"

    read
    if lastkey()=K_ESC; exit; endif
    select RADSIHT
    seek str(_godina,4)+str(_mjesec,2)+_IdRadn+_IdRj+str(_dan,2)+_dandio+_idtippr
    if found() // uzmi tekuce vrijednosti
      _izvrseno:=izvrseno
      _bodova:=bodova
      _idnorsiht:=idnorsiht
    else
      _bodova:=0
      _izvrseno:=0
      _idnorsiht:=space(4)
    endif
    select TPRSiht; hseek _idtippr
    if tprSiht->k1="F"
     @ m_x+3,m_y+2 SAY "Sifra Norme" GET _IdNorSiht ;
             valid  P_NorSiht(@_idNorSiht)

    else
      _IdNorSiht:=space(4)
       @ m_x+3,m_y+2 SAY space(25)
    endif


    @ m_x+3,m_y+40 SAY "    Izvrseno" GET _Izvrseno  pict "999999.999" ;
            when !empty(_idtippr)

    @ m_x+5,m_y+40 SAY "Ukupno bodova" GET _Bodova pict "99999999.99" ;
          when   {|| _Bodova:=_BrBod*_izvrseno/iif(TPRSiht->k1="F",NorSiht->Iznos,1), .f.}

    read

    if empty(_idtippr)
       // ako je primanje prazno - prevrni na slijedeci dan
       exit
    endif
    select RADSIHT
    seek str(_godina,4)+str(_mjesec,2)+_IdRadn+_IdRj+str(_dan,2)+_dandio+_idtippr

    if round(_izvrseno,4)<>0 .or. round(_Bodova,4)<>0   // nije nulirano
       if !found(); append blank; endif
       Gather()
    else
       if found() // a sadrßaj je 0
          DELETE
       endif
    endif

    select TPRSiht;seek _idtippr; skip; _idtippr:=id
    if eof(); exit; endif
 enddo
    ++_Dan ; if _Dan>31 .or. _dan=0; exit; endif
 enddo

Boxc()

// zavrseno azuriranje RADSIHT
***************************************************************
START PRINT CRET
P_12CPI
? gTS+":",gnFirma
?? "; Radna jedinica:",cIdRj
?
? "Godina:",str(ngodina,4),"/",str(nmjesec,2)
?
? "*** Pregled Sihtarice za:"
?? cIDradn,radn->naz
?
P_COND2

Linija()
?
select TPRSiht; go top
?? space(3)+" "+space(6)+" "
fPrvi:=.t.
do while !eof()
  if fprvi
     ?? space(4)+" "
     fprvi:=.f.
  endif
  ?? padc(id,22)
  skip
enddo
select TPRSiht; go top
?
?? space(3)+" "+space(6)+" "
fPRvi:=.t.
do while !eof()
  if fprvi
     ?? space(4)+" "
     fprvi:=.f.
  endif
  ?? padc(alltrim(naz),22)
  skip
enddo
?
?? space(3)+" "+space(6)+" "
select TPRSiht; go top
fPRvi:=.t.
do while !eof()
  if fprvi
     ?? space(4)+" "
     fprvi:=.f.
  endif
  ?? padc("izvrseno/bodova",22)
  skip
enddo

Linija()

private aSihtUk:={}

for i:=1 to TPRSiht->(reccount2())
 AADd(aSihtUk,0)
next

for nDan:=1  to 31

 for nDanDio:=0 to 8
  cDanDio:=IF(nDanDio==0," ",STR(nDanDio,1))


  _BrBod:=BodovaNaDan(ngodina,nmjesec,cidradn,cidrj,ndan,cDanDio)

  IF _brbod==0 .and. !EMPTY(cDanDio)
    LOOP
  ENDIF

  IF cDanDio==" "
    ? str(ndan,3)
  ELSE
    ? " /"+cDanDio
  ENDIF
  ?? str(_BrBod,6,2)

  ?? " "

  select TPRSiht; go top
  fPRvi:=.t.

  nPozicija:=0
  do while !eof()
    ++nPozicija

    select RADSIHT
    seek str(ngodina,4)+str(nmjesec,2)+cIdRadn+cIdRj+str(ndan,2)+cDanDio+tprsiht->id

    // utvrdi Áifru norme za dan
    if fprvi   // odstampaj sifru norme
      if  dan=ndan .and. dandio==cDanDio .and. idtippr="01"
       ?? idNorSiht+" "
      else
       ?? space(4)+" "
      endif
      fPRvi:=.f.
    endif

    if found()
      Scatter()
      ?? str(_Izvrseno,10,2),str(_Bodova,10,2)+" "
      aSihtUk[nPozicija]+=_Bodova
    else
      ?? space(22)
      aSihtUk[nPozicija]+=0
    endif

    select TPRSiht;  skip
  enddo
 next
next

Linija()
?
?? space(3)+" "+space(6)+" "
select TPRSiht; go top
fPRvi:=.t.
i:=0
altd()
_BrBod:=radn->brbod
if _brbod=0
   MsgBeep("U sifrarniku radnika definisite broj bodova za radnika !")
endif

do while !eof()
  ++i
  if fprvi
     ?? space(4)+" "
     fprvi:=.f.
  endif
  ?? space(10), str(aSihtUk[i],10,2)
  cPom:=id  // napuni Karticu radnika !!!!!
  if _Brbod<>0
    _s&cPom:=aSihtUk[i]/_Brbod
  endif
  skip
enddo
Linija()
altd()
FF
END PRINT
*****************************************************

if pitanje(,"Zavrsili ste unos sihtarice ?","D")=="D"
   exit
endif


ENDDO // glavna petlja

select TPRSiht; use
//select RadSiht; use
select NorSiht; use

select ld

return (nil)


function BodovaNaDan(ngodina,nmjesec,cidradn,cidrj,ndan,cDanDio)
local _BrBod:=0

select RADSIHT
seek str(ngodina,4)+str(nmjesec,2)+cIdRadn+cIdRj+STR(nDan,2)+cDanDio
//+"01"+str(ndan,2)
// id na prvi slog
ntRec:=Recno()   // ispisi broj bodova
IF !FOUND()
  _BrBod:=0
ELSE
   _brbod:=brbod
ENDIF
// do while !eof() .and. nmjesec=mjesec .and. ngodina=godina .and. cidradn==idRadn .and. cidrj==idrj .and. nDan==dan
//   skip
// enddo
go nTRec
return _BrBod





function Linija()

?
?? padc("---",3)+" "+replicate("-",6)+" "
fprvi:=.t.
select TPRSiht; go top
go top

do while !eof()
  if fprvi
     ?? replicate("-",4)+" "
     fprvi:=.f.
  endif
  ?? replicate("-",10)+" "+replicate("-",10)+" "
  skip
enddo

return (nil)


FUNC UbaciPrefix(cU,cP)

  cU := PADR(UPPER( cU ),250)

  cU := STRTRAN( cU , "I0"      , cP+"I0"      )
  cU := STRTRAN( cU , "I1"      , cP+"I1"      )
  cU := STRTRAN( cU , "I2"      , cP+"I2"      )
  cU := STRTRAN( cU , "I3"      , cP+"I3"      )
  cU := STRTRAN( cU , "I4"      , cP+"I4"      )

  cU := STRTRAN( cU , "S0"      , cP+"S0"      )
  cU := STRTRAN( cU , "S1"      , cP+"S1"      )
  cU := STRTRAN( cU , "S2"      , cP+"S2"      )
  cU := STRTRAN( cU , "S3"      , cP+"S3"      )
  cU := STRTRAN( cU , "S4"      , cP+"S4"      )

  cU := STRTRAN( cU , "USATI"   , cP+"USATI"   )
  cU := STRTRAN( cU , "UNETO"   , cP+"UNETO"   )
  cU := STRTRAN( cU , "UODBICI" , cP+"UODBICI" )
  cU := STRTRAN( cU , "UIZNOS"  , cP+"UIZNOS"  )

RETURN TRIM(cU)


************************************
function PrimLD(cOznaka,cTipPr)
*
* cOznaka - oznaka obracuna
* cTipPr  - "01, "02" , ...
*           "NE" - neto
* izlaz = iznos cTipPr (primanja ili neta)
************************************
local nRez:=0, nArr:=SELECT()
private cTipa:=""
private cpom:=""

select (F_LD)
if !used()
  O_LD
endif

PushWA()

SET ORDER TO TAG "1"
//  CREATE_INDEX("1","str(godina)+idrj+str(mjesec)+obr+idradn",KUMPATH+"LD")

seek str(_godina,4)+_idrj+str(_mjesec,2)+cOznaka+_idradn

if cTippr=="NE"
    nRez:=UNETO
else
    cTipa:="I"+cTipPr
    nRez :=&cTipa
endif

PopWa()

SELECT (nArr)
return nRez



********************
********************
function ObrIzClip()
local cMjesec,cIdRj,fnovi,lSveRJ

O_RADN
O_LD

cIdRadn:=space(_LR_)
cIdRj:=gRj; cMjesec:=gMjesec
cGodina:=gGodina
cObracun := gObracun
Box("#ZAMJENA POSTOJECEG OBRACUNOM IZ CLIPBOARD-a",4,60)

@ m_x+1,m_y+2 SAY "Radna jedinica (prazno-sve):" GET cIdRJ
@ m_x+2,m_y+2 SAY "Mjesec: "  GET cMjesec pict "99"
if lViseObr
  @ m_x+2,col()+2 SAY "Obracun: " GET cObracun WHEN HelpObr(.f.,cObracun) VALID ValObr(.f.,cObracun)
endif
@ m_x+3,m_y+2 SAY "Godina: "  GET cGodina pict "9999"
read; clvbox(); ESC_BCR
BoxC()

lSveRJ:=.f.
if EMPTY(cIDRJ) .and. pitanje(,"Zelite li preuzeti podatke ZA SVE RJ za ovaj mjesec iz CLIPBOARD-a ?","D")=="D"
  lSveRJ:=.t.
endif

MsgBeep("Ova opcija ce prvo izbrisati postojeci obracun.#"+;
        "Zatim ce se preuzeti obracun iz CLIPBOARD-a (SIF0\LD.DBF).#"+;
        "Ukoliko ste sigurni da ovo zelite, na sljedece pitanje#"+;
        "odgovorite potvrdno (kucajte 'D').")

if pitanje(,"Sigurno zelite preuzeti podatke za ovaj mjesec iz CLIPBOARD-a ?","N")=="N"
 closeret
endif

Msgo("Sacekajte, brisem tekuci obracun....")
  SELECT LD
  IF lSveRJ
    SET ORDER TO TAG "2"  // "str(godina)+str(mjesec)+obr+idradn+idrj"
    seek str(cGodina,4)+str(cMjesec,2)+if(lViseObr,cObracun,"")
    do while !EOF() .and.;
             str(cGodina,4)+str(cMjesec,2)==str(Godina,4)+str(Mjesec,2) .and.;
             if(lViseObr,cObracun==obr,.t.)
       skip 1; nRec:=recno(); skip -1
       delete
       go nRec
    enddo
  ELSE
    seek str(cGodina,4)+cIdRj+str(cMjesec,2)+if(lViseObr,cObracun,"")
    do while !EOF() .and.;
             str(cGodina,4)+cIdRj+str(cMjesec,2)==str(Godina,4)+IdRj+str(Mjesec,2) .and.;
             if(lViseObr,cObracun==obr,.t.)
       skip 1; nRec:=recno(); skip -1
       delete
       go nRec
    enddo
  ENDIF
MsgC()

Msgo("Preuzimam obracun iz CLIPBOARD-a....")
  SELECT 0
  USE (ClipPutanja()+"LD.DBF") ALIAS LDCLIP
  SET ORDER TO 0
  SET FILTER TO STR(godina,4)==STR(cGodina,4) .and.;
                STR(mjesec,2)==STR(cMjesec,2) .and.;
                (IDRJ==cIDRJ .or. lSveRJ) .and.;
                IF(lViseObr,cObracun==obr,.t.)
  GO TOP
  DO WHILE !EOF()
    Scatter()
    SELECT LD; APPEND BLANK; Gather()
    SELECT LDCLIP
    SKIP 1
  ENDDO
MsgC()
CLOSERET


function ClipPutanja()
*{
local nP2:=AT(SLASH+"SIF",SIFPATH)  //  c:\sigma\sif
return (LEFT(SIFPATH,nP2)+"SIF0"+SLASH)    // "c:\sigma\"+"sif0\"
*}


/*! \fn DMG(nDan,nMjesec,nGodina)
 *  \brief vraca datumsku varijablu iz int varijabli (eg. DMG(1,5,2002)->01.05.2002)
 *  \param nDan - dan
 *  \param nMjesec - mjesec
 *  \param nGodina - godina
 *  \return var type Date
 */
function DMG(nDan,nMjesec,nGodina)
*{
local cPom
cPom:=PADL(ALLTRIM(STR(nDan,2)),2,"0")
cPom+="."+PADL(ALLTRIM(STR(nMjesec,2)),2,"0")
cPom+="."+PADL(ALLTRIM(STR(nGodina,4)),4,"0")
return CTOD(cPom)
*}

* odsjeca Prazne Linije na Kraju stringa
function OdsjPLK(cTxt)
*{
local i
for i:=len(cTxt) to 1 step -1
  if !(substr(cTxt,i,1) $ Chr(13)+Chr(10)+" ç")
       exit
  endif
next
return left(cTxt,i)
*}


