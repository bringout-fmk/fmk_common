#include "\cl\sigma\fmk\kalk\kalk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/mag/rpt/2g/rpt_lag.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.3 $
 * $Log: rpt_lag.prg,v $
 * Revision 1.3  2004/05/05 08:16:52  sasavranic
 * Na izvj.LLP dodao uslov za partnera
 *
 * Revision 1.2  2002/07/08 23:03:54  ernad
 *
 *
 * trgomarket debug dok 80, 81, izvjestaj lager lista magacin po proizv. kriteriju
 *
 * Revision 1.1  2002/07/08 22:20:43  ernad
 *
 *
 * lager lista magacin - proizvoljni sort
 *
 *
 */


function TKaLagMNew()
*{
local oObj

oObj:=TKaLagM():new()

oObj:nTUlazK:=0
oObj:nTIzlazK:=0
oObj:nTVpvU:=0
oObj:nTVpvI:=0
oObj:nTNvU:=0
oObj:nTNvI:=0
oObj:nTRabat:=0

oObj:nStr:=0
oObj:nStrLen:=63

oObj:self:=oObj

oObj:cUslRobaNaz:=""
oObj:nRbr:=0

return oObj
*}


#ifndef CPP
#include "class(y).ch"
CREATE CLASS TKaLagM
	
	EXPORTED:
	
	var nStr
	var nStrLen
	var cLinija

	var self
	var dDatOd
	var dDatDo
	
	var cIdKonto
	var cUslTarifa
	var cUslIdVd
	var cUslPartner
	var cUslRobaNaz
	var cUslRoba
	
	
	// row varijable (za IdRoba)
	var nUlazK
	var nIzlazK
	var nVpvU
	var nVpvI
	var nNvU
	var nNvI
	var nRabat
	var nRbr
	
	// row varijable (za IdRoba)
	var nTUlazK
	var nTIzlazK
	var nTVpvU
	var nTVpvI
	var nTNvU
	var nTNvI
	var nTRabat

	
	var cSort
	
	// varijante izvjestaja
	
	// "N", "P"
	var cNabIliProd 
	var cPrikKolNula
	
	// kreiraj pomocnu tabelu
	method creTmpTbl
	method addTmpRec

	// prodji kroz bazu podataka
	method openDb
	method closeDb
	
	method setFiltDb
	method setFiltDbTmp
	
	method skipRec
	method calcRec
	
	method calcRec
	method sortTmpTbl
	method getVars
	
	method setLinija
	method printHeader
	method printDetail
	method printFooter

	method calcTotal
	method printTotal
	
END CLASS
#endif

function KaLagM()
*{
local cIdRoba
local cIdTarifa
local nRec
local oRpt:=TKaLagMNew()

do while .t.
	oRpt:creTmpTbl()
	if (oRpt:getVars()==0)
		oRpt:closeDB()
		return
	endif
	oRpt:openDb()
	if (oRpt:setFiltDb()==0)
		oRpt:closeDb()
		loop
	else
		exit
	endif
enddo



SELECT kalk
SEEK gFirma+oRpt:cIdKonto
EOF CRET

nRec:=0
MsgO("Kreiram pomocnu tabelu ...")
do while (!EOF() .and. oRpt:cIdKonto==field->mKonto)
	if (oRpt:skipRec()==1)
		loop
	endif
		
	oRpt:nUlazK:=0
	oRpt:nIzlazK:=0
	oRpt:nVpvU:=0
	oRpt:nVpvI:=0
	oRpt:nNvU:=0
	oRpt:nNvI:=0
	oRpt:nRabat:=0
	
	cIdRoba:=field->idRoba
	cIdTarifa:=field->idTarifa
	do while (!EOF() .and. cIdRoba==field->idRoba .and. cIdTarifa==field->idTarifa)
		++nRec
		ShowKorner(nRec,1)
		oRpt:calcRec()
		SKIP
	enddo
	oRpt:addTmpRec(cIdRoba, cIdTarifa)
	SELECT kalk
enddo
MsgC()


StartPrint()
// rpt_tmp je gotova, formiramo izvjestaj
SELECT rpt_tmp
oRpt:setFiltDbTmp()
oRpt:sortTmpTbl()
GO TOP

oRpt:nStr:=0
oRpt:setLinija()
oRpt:printHeader()
altd()
nRec:=0
do while !EOF()
	ShowKorner(nRec,1)
	++nRec
	oRpt:printDetail()
	oRpt:calcTotal()
	SKIP
enddo
oRpt:printTotal()
oRpt:printFooter()

oRpt:closeDb()

EndPrint()
return
*}


method openDb

O_TARIFA
O_ROBA
O_TARIFA
O_KONTO
O_DOKS
O_KALK

//"3","idFirma+mkonto+idroba+dtos(datdok)+podbr+MU_I+IdVD
SELECT kalk
SET ORDER TO TAG "3"

GO TOP
return
*}


method closeDb

CLOSE ALL
return
*}

method addTmpRec(cIdRoba, cIdTarifa)

SELECT rpt_tmp
SEEK cIdRoba

if !FOUND()
	APPEND BLANK
	REPLACE idRoba WITH cIdRoba
	//tarifu cu uzeti iz sifrarnika tarifa
	REPLACE idTarifa WITH roba->idTarifa
endif

REPLACE idPartner WITH kalk->idPartner
REPLACE ulazK WITH field->ulazK+::nUlazK
REPLACE izlazK WITH field->izlazK+::nIzlazK
	
if (::cNabIliProd=="P")
	REPLACE ulazF WITH field->ulazF+::nVpvU
	REPLACE izlazF WITH field->izlazF+::nVpvI
else
	REPLACE ulazF WITH field->ulazF+::nNvU
	REPLACE izlazF WITH field->izlazF+::nNvI
endif

REPLACE robaNaz WITH roba->naz
REPLACE jmj WITH roba->jmj

return
*}

method calcRec()
local nKolicina

if (field->mu_i=="1")

	if !(kalk->idVd $ "12#22#94")
		nKolicina:=field->kolicina-field->gkolicina-field->gkolicin2
		::nUlazK+=nKolicina
		::nVpvU+=round( field->vpc*(field->kolicina-field->gkolicina-field->gkolicin2), gZaokr)
		::nNvU+=round(field->nc*(field->kolicina-field->gkolicina-field->gkolicin2) , gZaokr)
	else
		nKolicina:=-field->kolicina
		::nIzlazK+=nKolicina
		::nVpvI-=ROUND( field->vpc*field->kolicina , gZaokr)
		::nNvI-=ROUND( field->nc*field->kolicina , gZaokr)
	endif
	
elseif (field->mu_i=="5")
	nKolicina:=field->kolicina
	::nIzlazK+=nKolicina
	::nVpvI+=ROUND(field->vpc*field->kolicina, gZaokr)
	::nRabat+=ROUND(field->rabatv/100*field->vpc*field->kolicina, gZaokr)
	::nNvI+=field->nc*field->kolicina

elseif (field->mu_i=="3")    
	// nivelacija
	::nVpvU+=ROUND(field->vpc*field->kolicina, gZaokr)

elseif (field->mu_i=="8")
	nKolicina:=-field->kolicina
	::nIzlazK+=nKolicina
	::nVpvI+=ROUND(field->vpc*nKolicina , gZaokr)
	::nRabat+=ROUND(field->rabatv/100*field->vpc*nKolicina, gZaokr)
	::nNvI+=nc*nKolicina
	nKolicina:=-field->kolicina
	::nUlazK+=nKolicina
	::nVpvU+=ROUND(field->vpc*nKolicina , gZaokr)
	::nNvU+=nc*nKolicina
endif


return
*}

method getVars
local cKto

::dDatOd:=CTOD("")
::dDatDo:=DATE()

O_PRIPR
::cIdKonto:=PADR("1310",LEN(pripr->mKonto))
USE

::cUslRoba:=SPACE(60)
::cUslPartner:=SPACE(60)
::cUslTarifa:=SPACE(60)
::cUslIdVd:=SPACE(60)

Box(nil, 20, 70)

@ m_x+1, m_y+2 SAY "Datum " GET ::dDatOd
@ m_x+1, COL()+2 SAY "-" GET ::dDatDo

O_KONTO

::cSort:="R"
::cNabIliProd:="P"
::cPrikKolNula:="D"

cKto:=::cIdKonto
@ m_x+3, m_y+2 SAY "Magacinski konto  " GET cKto VALID P_Konto(@cKto)

@ m_x+5, m_y+2 SAY "Uslovi:"
@ m_x+6, m_y+2 SAY "- za robu     :" GET ::cUslRoba    PICT "@!S40"
@ m_x+7, m_y+2 SAY "- za partnera :" GET ::cUslPartner PICT "@!S40"
@ m_x+8, m_y+2 SAY "- za tarife   :" GET ::cUslTarifa  PICT "@!S40"
@ m_x+9, m_y+2 SAY "- vrste dok.  :" GET ::cUslIdVd    PICT "@!S40"

@ m_x+11, m_y+2 SAY "Sortirati:"
@ m_x+12, m_y+2 SAY "- po partneru (P)" 
@ m_x+13, m_y+2 SAY "- po tarifi   (T)" 
@ m_x+14, m_y+2 SAY "- po id roba  (R)" 
@ m_x+15, m_y+2 SAY "- po jed.mj.  (J)" 
@ m_x+16, m_y+2 SAY "- po naz roba (N)" GET ::cSort VALID ::cSort $ "KPTMRNJ" PICT "@!"

@ m_x+18, m_y+2 SAY "(N)abavna / (P)rodajna vrijednost " GET ::cNabIliProd PICT "@!" VALID ::cNabIliProd $ "NP"
@ m_x+19, m_y+2 SAY "Prikazati sve (i kolicina 0) " GET ::cPrikKolNula PICT "@!" VALID ::cPrikKolNula $ "DN"
READ

::cIdKonto:=cKto

BoxC()

SELECT konto
USE

if (LASTKEY()==K_ESC)
	return 0
endif

return 1
*}


method creTmpTbl
local aTbl

cTbl:=PRIVPATH+"rpt_tmp.dbf"

aTbl:={}
AADD(aTbl, { "idRoba",  "C", 10, 0})
AADD(aTbl, { "RobaNaz", "C", 40, 0})
AADD(aTbl, { "idTarifa","C", 6, 0})
AADD(aTbl, { "idPartner","C", 6, 0})
AADD(aTbl, { "jmj",     "C", 3, 0})
AADD(aTbl, { "ulazK",   "N", 15, 4})
AADD(aTbl, { "izlazK",  "N", 15, 4})
AADD(aTbl, { "ulazF",   "N", 16, 4})
AADD(aTbl, { "izlazF",  "N", 16, 4})
AADD(aTbl, { "rabatF",  "N", 16, 4})

DBCREATE2(cTbl, aTbl)
CREATE_INDEX("idRoba", "idRoba+idTarifa", cTbl, .f.)
CREATE_INDEX("RobaNaz", "RobaNaz+idTarifa", cTbl, .f.)
CREATE_INDEX("idTarifa", "idTarifa+idRoba", cTbl, .f.)
CREATE_INDEX("jmj", "jmj+idRoba+idTarifa", cTbl, .f.)
CREATE_INDEX("idPartner", "idPartner+idroba+idTarifa", cTbl, .f.)

CLOSE ALL

O_RPT_TMP
SET ORDER TO TAG "idRoba"

altd()
return
*}

method setFiltDb
local cPom

private cFilter

cFilter:=".t."

cPom:=Parsiraj(::cUslRoba,"IdRoba")
if (cPom==nil)
	return 0
endif

if (cPom<>".t.")
	cFilter+=".and."+cPom
endif

cPom:=Parsiraj(::cUslTarifa,"IdTarifa")
if (cPom==nil)
	return 0
endif

if (cPom<>".t.")
	cFilter+=".and."+cPom
endif

cPom:=Parsiraj(::cUslIdVd,"IdVd")
if (cPom==nil)
	return 0
endif

if (cPom<>".t.")
	cFilter+=".and."+cPom
endif

cPom:=Parsiraj(::cUslPartner,"IdPartner")
if (cPom==nil)
	return 0
endif

if (cPom<>".t.")
	cFilter+=".and."+cPom
endif

if (!EMPTY(::dDatOd) .or. !EMPTY(::dDatDo))
	cFilter+=".and. DatDok>="+cm2str(::dDatOd)+".and. DatDok<="+cm2str(::dDatDo)
endif

SET FILTER TO &cFilter
GO TOP

altd()
return 1


method skipRec

local lPreskoci

// preskoci slogove koji ne zadovoljavaju uslov
// a nisu mogli biti obuhvaceni u fitleru

private cWFilter

cWFilter:=Parsiraj(::cUslRobaNaz,"naz")

SELECT roba
HSEEK kalk->idRoba

lPreskoci:=.f.
if !(&cWFilter)
	lPreskoci:=.t.
endif

SELECT kalk
if (lPreskoci)
	SKIP
	return 1
endif

if roba->tip $ "TU"
  	SKIP
	return 1
endif


return 0
*}

method sortTmpTbl

do case
	case (::cSort=="P")
		SET ORDER TO TAG "idPartner"
	case (::cSort=="T")
		SET ORDER TO TAG "idTarifa"
	case (::cSort=="R")
		SET ORDER TO TAG "idRoba"
	case (::cSort=="N")
		SET ORDER TO TAG "RobaNaz"
	case (::cSort=="J")
		SET ORDER TO TAG "jmj"
end case
	
return

method setFiltDbTmp
local cPom

// postavi filter na pomocnoj tabeli
// ako ima potrebe

return


method setLinija
local i

::cLinija:=""

::cLinija+=REPLICATE("-", 6)+" "
::cLinija+=REPLICATE("-", LEN(field->idRoba))+" "
::cLinija+=REPLICATE("-", LEN(field->idTarifa))+" "
::cLinija+=REPLICATE("-", LEN(field->robaNaz))+" "


::cLinija+=REPLICATE("-", LEN(gPicKol))

for i:=1 to 3
	::cLinija+=" "+REPLICATE("-", LEN(gPicDem))
next
return
*}

method printHeader
local cHeader
::nStr++
?
P_COND
@ PROW(), 100 SAY "Str."+STR(::nStr,3)
? "Preduzece: ", gNFirma, 
?
PushWa()

SELECT konto
SEEK ::cIdKonto
? "Magacinski konto:", ::cIdKonto, konto->naz
PopWa()
? 
? ::cLinija

cHeader:=""
cHeader:=PADC("Rbr",5)+" "
cHeader+=PADC("idRoba",LEN(field->idRoba))+" "
cHeader+=PADC("Tar.",LEN(field->idTarifa))+" "
cHeader+=PADC(" Naziv artikla",LEN(field->robaNaz))+" "
cHeader+=PADC("kolicina", LEN(gPicKol))+" "
if (::cNabIliProd=="P")
	cHeader+=PADC("Vpv Ul.", LEN(gPicKol))+" "
	cHeader+=PADC("Vpv Izl.", LEN(gPicKol))+" "
	cHeader+=PADC("VPV", LEN(gPicKol))
else	
	cHeader+=PADC("Nv Ul.", LEN(gPicKol))+" "
	cHeader+=PADC("Nv Izl.", LEN(gPicKol))+" "
	cHeader+=PADC("Nab.vr", LEN(gPicKol))
endif

? cHeader
? ::cLinija

return
*}

method printFooter
return
*}

method printDetail

if (::cPrikKolNula=="N") 
	if (ROUND(field->ulazK-field->izlazK,4)==0)
		return
	endif
endif

if (PROW()>::nStrLen-1)
	FF
	::printHeader()
endif
? STR(++::nRbr,4)+". "
@ PROW(), PCOL()+1 SAY field->idRoba
@ PROW(), PCOL()+1 SAY field->idTarifa
@ PROW(), PCOL()+1 SAY field->robaNaz


@ PROW(), PCOL()+1 SAY field->ulazK-field->izlazK PICT gPicKol
@ PROW(), PCOL()+1 SAY field->ulazF PICT gPicDem
@ PROW(), PCOL()+1 SAY field->izlazF PICT gPicDem
@ PROW(), PCOL()+1 SAY field->ulazF-field->izlazF PICT gPicDem
	
return
*}

method calcTotal

if (::cPrikKolNula=="N") 
	if (ROUND(field->ulazK-field->izlazK,4)==0)
		return
	endif
endif


::nTUlazK+=field->ulazK
::nTIzlazK+=field->izlazK

if (::cNabIliProd=="P")
	::nTVpvU+=field->ulazF
	::nTVpvI+=field->izlazF
else	
	::nTNvU+=field->ulazF
	::nTNvI+=field->izlazF
endif

return
*}

method printTotal

if (PROW()>::nStrLen-3)
	FF
	::printHeader()
endif

? ::cLinija
? PADR(" ",6)
@ PROW(), PCOL()+1 SAY SPACE(LEN(field->idRoba))
@ PROW(), PCOL()+1 SAY SPACE(LEN(field->idTarifa))
@ PROW(), PCOL()+1 SAY SPACE(LEN(field->robaNaz))

@ PROW(), PCOL()+1 SAY ::nTUlazK-::nTIzlazK PICT gPicKol

if (::cNabIliProd=="P")
	@ PROW(), PCOL()+1 SAY ::nTVpvU PICT gPicDem
	@ PROW(), PCOL()+1 SAY ::nTVpvI PICT gPicDem
	@ PROW(), PCOL()+1 SAY ::nTVpvU-::nTVpvI PICT gPicDem
else
	@ PROW(), PCOL()+1 SAY ::nTNvU PICT gPicDem
	@ PROW(), PCOL()+1 SAY ::nTNvI PICT gPicDem
	@ PROW(), PCOL()+1 SAY ::nTNvU-::nTNvI PICT gPicDem
endif

? ::cLinija
return
