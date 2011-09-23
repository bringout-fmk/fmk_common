/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "sc.ch"

/*
 * ----------------------------------------------------------------
 *                          Copyright Sigma-com software 1998-2006 
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
local nNaz
local nArr
local nPom1:=0
local nPom2:=0
local cPom:=""
local cOrderTag:=""

IF cValIz==nil
	cValIz:="P"
ENDIF

IF cValU==nil
	if cValIz == "P"
	   cValU:="D"
	else
	   cVAlU:="P"
	endif 
ENDIF

nArr:=SELECT()

SELECT (F_VALUTE)
IF !USED()
	O_VALUTE
ENDIF

cOrderTag := UPPER(ORDNAME())

// pronadjimo kurs valute "iz"
if (cValIz == "P" .or. cValIz == "D") 
   if cOrderTag <> "NAZ"
   	SET ORDER TO TAG "NAZ"
	cOrderTag := "ID"
   endif
else
   if cOrderTag <> "ID2"
      SET ORDER TO TAG "ID2"
      cOrderTag:= "ID2"
   endif
endif

SEEK cValIz
IF !FOUND()
	Msg("Nepostojeca valuta iz koje se pretvara iznos:## '"+cValIz+"' !")
  	nPom1:=1
ELSEIF DTOS(dDat)<DTOS(valute->datum)
  	Msg("Nepostojeci kurs valute iz koje se pretvara iznos:## '"+cValIz+"'. Provjeriti datum !")
  	nPom1:=1
ELSE
  	cPom:=id
  	DO WHILE DTOS(dDat)>=DTOS(valute->datum) .and. cPom==valute->id
	     SKIP 1
	ENDDO
  	SKIP -1
  	nPom1:= kurs1
ENDIF

// pronadjimo kurs valute "u"
if (cValU == "P" .or. cValU == "D") 
   if cOrderTag <> "NAZ"
   	SET ORDER TO TAG "NAZ"
	cOrderTag := "ID"
   endif
else
   if cOrderTag <> "ID2"
      SET ORDER TO TAG "ID2"
      cOrderTag:= "ID2"
   endif
endif

SEEK cValU
IF !FOUND()
  	Msg("Nepostojeca valuta u koju se pretvara iznos:## '"+cValU+"' !")
  	nPom2:=1
ELSEIF DTOS(dDat) < DTOS(valute->datum)
  	Msg("Nepostojeci kurs valute u koju se pretvara iznos:## '"+cValU+"'. Provjeriti datum !")
  	nPom2:=1
ELSE
  	cPom:=id
  	DO WHILE DTOS(dDat)>=DTOS(valute->datum) .and. cPom==valute->id
	    SKIP 1
	ENDDO
  	SKIP -1
  	nPom2:= valute->kurs1
ENDIF

select (nArr)
return (nPom2/nPom1)

// -----------------------------------------------
// vraca skraceni naziv domace valute
// -----------------------------------------------
function ValDomaca()     
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

// ------------------------------------------------
// vraca skraceni naziv pomocne (strane) valute
// -----------------------------------------------
function ValPomocna()    
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

// -----------------------------------
// -----------------------------------
function P_Valuta(cid,dx,dy)
local nTArea
private ImeKol
private Kol

ImeKol := {}
Kol := {}

nTArea := SELECT()
O_VALUTE

AADD(ImeKol,   { "ID "       , {|| id }   , "id"        })
AADD(ImeKol,   { "Naziv"     , {|| naz}   , "naz"       })
AADD(ImeKol,   { "Skrac."    , {|| naz2}  , "naz2"      })
AADD(ImeKol,   { "Datum"     , {|| datum} , "datum"     })
AADD(ImeKol,   { "Kurs"      , {|| kurs1} , "kurs1"     })
AADD(ImeKol,   { "Tip(D/P/O)", {|| tip}   , "tip"    , ;
                 {|| .t.}, ;
		 {|| wtip$"DPO"}})

for i:=1 to LEN(ImeKol)
	AADD(Kol, i)
next

select (nTArea)

return PostojiSifra(F_VALUTE,2,10,77,"Valute",@cid,dx,dy)

// -------------------------------------
// sekundarna valuta
// -------------------------------------
function ValSekund()
if gBaznaV=="D"
  return ValPomocna()
else
  return ValDomaca()
endif


// --------------------------------------
// omjer valuta
// --------------------------------------
function OmjerVal(ckU, ckIz, dD)
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
   
   SELECT (nArr)
   IF nIz==0
     MsgBeep("Greska! Za valutu "+ ckIz + " na dan "+DTOC(dD)+" nemoguce utvrditi kurs!")
   ENDIF
   IF nU==0
     MsgBeep("Greska! Za valutu "+ckU+" na dan "+DTOC(dD)+" nemoguce utvrditi kurs!")
   ENDIF
RETURN IF( nIz==0 .or. nU==0 , 0 , (nU/nIz) )


// --------------------------------------------
// --------------------------------------------
function ImaUSifVal(cKratica)
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


// -------------------------------------
// pretvori u baznu valutu
// -------------------------------------
function UBaznuValutu(dDatdok)
local  cIz

if gBaznaV == "P"
    cIz := "D"
else
    cIz := "P"
endif
Kurs(dDatdok, cIz, gBaznaV)
return



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



