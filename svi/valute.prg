#include "sc.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */
 

/*! \fn Kurs(dDat,cValIz,cValU)
 *  \param dDat - datum na koji se trazi omjer
 *  \param cValIz - valuta iz koje se vrsi preracun iznosa
 *  \param cValU  - valuta u koju se preracunava iznos valute cValIz
 *  \param cValIz i cValU se mogu zadati kao sifre valuta ili kao tipovi
 *  \param Npr. tip "P" oznacava pomocnu, a tip "D" domacu valutu
 *  \param Ako nisu zadani, uzima se da je cValIz="P", a cValU="D"
 *  \param Ako je zadano samo neko cValIz<>"P", cValU ce biti "P"
 *
 *  \return f-ja vraca protuvrijednost jedinice valute cValIz u valuti cValU
 */
 
function Kurs(dDat, cValIz, cValU)
*{
local nNaz
local nArr
local nPom1:=0
local nPom2:=0
local cPom:=""

IF cValIz==NIL
	cValIz:="P"
ENDIF

IF cValU==NIL 
	cValU:=IF(cValIz=="P","D","P") 
ENDIF

nArr:=SELECT()

SELECT (F_VALUTE)
IF !USED()
	O_VALUTE
ENDIF

// pronadjimo kurs valute "iz"
SET ORDER TO TAG (IF(cValIz $ "PD","NAZ","ID2"))
GO TOP
SEEK cValIz
IF !FOUND()
	Msg("Nepostojeca valuta iz koje se pretvara iznos:## '"+cValIz+"' !")
  	nPom1:=1
ELSEIF DTOS(dDat)<DTOS(datum)
  	Msg("Nepostojeci kurs valute iz koje se pretvara iznos:## '"+cValIz+"'. Provjeriti datum !")
  	nPom1:=1
ELSE
  	cPom:=id
  	DO WHILE DTOS(dDat)>=DTOS(datum).and.cPom==id; SKIP 1; ENDDO
  	SKIP -1
  	nPom1:=IF(kurslis=="1",kurs1,IF(kurslis=="2",kurs2,kurs3))
ENDIF

// pronadjimo kurs valute "u"
SET ORDER TO TAG (IF(cValIz $ "PD","NAZ","ID2"))
GO TOP
SEEK cValU
IF !FOUND()
  	Msg("Nepostojeca valuta u koju se pretvara iznos:## '"+cValU+"' !")
  	nPom2:=1
ELSEIF DTOS(dDat)<DTOS(datum)
  	Msg("Nepostojeci kurs valute u koju se pretvara iznos:## '"+cValU+"'. Provjeriti datum !")
  	nPom2:=1
ELSE
  	cPom:=id
  	DO WHILE DTOS(dDat)>=DTOS(datum).and.cPom==id; SKIP 1; ENDDO
  	SKIP -1
  	nPom2:=IF(kurslis=="1",kurs1,IF(kurslis=="2",kurs2,kurs3))
ENDIF

select (nArr)
return (nPom2/nPom1)
*}

function ValDomaca()     // vraca skraceni naziv domace valute
*{
local xRez
PushWa()
SELECT F_VALUTE
IF !USED()
O_VALUTE
ENDIF
SET ORDER TO TAG "NAZ"
xRez:=Ocitaj(F_VALUTE,"D","naz2")
PopWa()
return xRez
*}

function ValPomocna()    // vraca skraceni naziv pomocne (strane) valute
*{
local xRez
PushWa()
SELECT F_VALUTE
IF !USED()
	O_VALUTE
ENDIF
SET ORDER TO TAG "NAZ"
xRez:=Ocitaj(F_VALUTE,"P","naz2")
PopWa()
return xRez
*}

function P_Valuta(cid,dx,dy)
*{
PRIVATE ImeKol,Kol

ImeKol:={ { "ID "       , {|| id }   , "id"        },;
          { "Naziv"     , {|| naz}   , "naz"       },;
          { "Skrac."    , {|| naz2}  , "naz2"      },;
          { "Datum"     , {|| datum} , "datum"     },;
          { "Kurs1"     , {|| kurs1} , "kurs1"     },;
          { "Kurs2"     , {|| kurs2} , "kurs2"     },;
          { "Kurs3"     , {|| kurs3} , "kurs3"     },;
          { "Tip(D/P/O)", {|| tip}   , "tip"       ,{|| .t.},{|| wtip$"DPO"}};
        }
Kol:={1,2,3,4,5,6,7,8}
altd()

return PostojiSifra(F_VALUTE,2,10,77,"Valute",@cid,dx,dy)
*}


function ValSekund()
*{
if gBaznaV=="D"
  return ValPomocna()
else
  return ValDomaca()
endif
*}


function OmjerVal(ckU, ckIz, dD)
*{
local nU:=0
local nIz:=0
local nArr:=SELECT()
   SELECT (F_VALUTE)
   IF !USED()
   O_VALUTE
   ENDIF

   PRIVATE cFiltV := "( naz2=="+cm2str( PADR(ckU,4) )+" .or. naz2=="+cm2str(PADR(ckIz,4))+" ) .and. DTOS(datum)<="+cm2str(DTOS(dD))
   SET FILTER TO &cFiltV
   SET ORDER TO TAG "ID2"
   GO TOP
   DO WHILE !EOF()
     IF naz2==PADR(ckU,4)
       nU  := IF(kurslis=="1", kurs1, IF(kurslis=="2", kurs2, kurs3))
     ELSEIF naz2==PADR(ckIz,4)
       nIz := IF(kurslis=="1",kurs1, IF(kurslis=="2", kurs2, kurs3))
     ENDIF
     SKIP 1
   ENDDO
   SET FILTER TO
   
   //if ALLTRIM(gnFirma) == "TEST"
   //  MsgBeep("nIz =" + STR(nIz, 10,3) + "nU = " + STR(nU, 10,3) )
   //endif
   
   SELECT (nArr)
   IF nIz==0
     MsgBeep("Greska! Za valutu "+ ckIz + " na dan "+DTOC(dD)+" nemoguce utvrditi kurs!")
   ENDIF
   IF nU==0
     MsgBeep("Greska! Za valutu "+ckU+" na dan "+DTOC(dD)+" nemoguce utvrditi kurs!")
   ENDIF
RETURN IF( nIz==0 .or. nU==0 , 0 , (nU/nIz) )
*}


function ImaUSifVal(cKratica)
*{
LOCAL lIma:=.f., nArr:=SELECT()
   SELECT (F_VALUTE)
   IF !USED()
   	O_VALUTE
   ENDIF
   GO TOP
   DO WHILE !EOF()
     IF naz2==PADR(cKratica,4)
       lIma:=.t.
       EXIT
     ENDIF
     SKIP 1
   ENDDO
   SELECT (nArr)
RETURN lIma
*}


function UBaznuValutu(dDatdok)
*{
Kurs(ddatdok,if(gBaznaV=="P","D","P"),gBaznaV)
return
*}



function ValBazna()
*{
if gBaznaV=="P"
  return ValPomocna()
else
  return ValDomaca()
endif
*}


/*! \fn OmjerVal(v1,v2)
 *  \brief Omjer valuta 
 *  \param v1  - valuta 1
 *  \param v2  - valuta 2
 */

function OmjerVal2(v1,v2)
*{
 LOCAL nArr:=SELECT(), n1:=1, n2:=1, lv1:=.f., lv2:=.f.
  SELECT VALUTE
  SET ORDER TO TAG "ID2"
  GO BOTTOM
  DO WHILE !BOF() .and. (!lv1.or.!lv2)
    IF !lv1 .and. naz2==v1; n1:=kurs1; lv1:=.t.; ENDIF
    IF !lv2 .and. naz2==v2; n2:=kurs1; lv2:=.t.; ENDIF
    SKIP -1
  ENDDO
 SELECT (nArr)
RETURN (n1/n2)
*}



