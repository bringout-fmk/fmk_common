#include "\cl\sigma\fmk\kalk\kalk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/rpt/1g/rpt_spo.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.4 $
 * $Log: rpt_spo.prg,v $
 * Revision 1.4  2004/05/19 12:16:55  sasavranic
 * no message
 *
 * Revision 1.3  2003/06/23 09:32:24  sasa
 * prikaz dobavljaca
 *
 * Revision 1.2  2002/07/08 23:03:54  ernad
 *
 *
 * trgomarket debug dok 80, 81, izvjestaj lager lista magacin po proizv. kriteriju
 *
 * Revision 1.1  2002/07/06 17:28:58  ernad
 *
 *
 * izvjestaj Trgomarket: pregled stanja po objektima
 *
 *
 */


*string
static nCol1:=0
*;

*string
static cPicCDem
*;

*string
static cPicProc
*;

*string
static cPicDem
*;

*string
static cPicKol
*;

*string
static cStrRedova2:=62
*;

*string
static cPrikProd:="N"
*;


*string
static qqKonto
*;

*string
static qqRoba
*;

*string
static cUslov1
*;

*string
static cUslov2
*;

*string
static cUslovRoba
*;

*string
static cK9
*;

*int
static cNObjekat
*;

*string
static cLinija
*;

*string
static cPrikazDob
*;

#define ROBAN_LEN 40
#define KOLICINA_LEN 10

function StanjePoObjektima()
*{
// kao djon cu iskoristiti pregled kretanja zaliha

*{
local i
local nT1
local nT4
local nT5
local nT6
local nT7
local nTT1
local nTT4
local nTT5
local nTT6
local nTT7
local n1
local n4
local n5
local n6
local n7
local nRecno

local cPodvuci

local lMarkiranaRoba


private dDatOd
private dDatDo

private aUTar:={}
private nUkObj:=0
private nITar:=0
private aUGArt:={}
private cPrSort:="SUBSTR(cIdRoba,3,3)"

cPodvuci:="N"


O_SIFK
O_SIFV
O_ROBA
O_K1
O_OBJEKTI

lMarkiranaRoba:=.f.
cPicCDem:="999999.999"
cPicProc:="999999.99%"
cPicDem:= "9999999.99"
cPicKol:= gPicKol
qqKonto:=PADR("13;",60)
qqRoba:=SPACE(60)

if (GetVars(@cNObjekat)==0)
	return
endiF

if RIGHT(TRIM(qqRoba),1)="*"
  lMarkiranaRoba:=.t.
endif

CreTblPobjekti()
CreTblRek1("1")

O_POBJEKTI
O_KONCIJ
O_ROBA
O_KONTO 
O_TARIFA
O_K1
O_OBJEKTI
O_KALK
O_REKAP1
GenRekap1(cUslov1, cUslov2, cUslovRoba, "N", "1", "N", lMarkiranaRoba, nil, cK9)


SetLinSpo()

select rekap1
SET ORDER TO TAG "2"
go top

SetGaZagSpo()

START PRINT CRET


if (gPrinter="R")
	cStrRedova2:=40
	?? "#%LANDS#"
endif

nStr:=0

ZaglSPo(@nStr)

nCol1:=43

// inicijalizuj pomocna polja
FillPObjekti()

select rekap1
nRbr:=0

nRecno:=0
fFilovo:=.f.
do while !eof()

	
	cG1:=rekap1->g1
	

	select pobjekti    
	// inicijalizuj polja
	go top
	do while !eof()
		// nivo grupe
		replace prodg with 0   
		REPLACE zalg  with 0
		skip
	enddo
	select rekap1

	fFilGr:=.f.
	fFilovo:=.f.
	
	do while (!EOF() .and. cG1==field->g1)
		++nRecno

		ShowKorner(nRecno,100)
		cIdroba:=rekap1->idRoba
		
		SELECT roba
		HSEEK cIdRoba
		cIdTarifa:=roba->idTarifa

		SELECT rekap1
		
		nK2:=nK1:=0
		SetK1K2(cG1, cIdTarifa, cIdRoba, @nK1, @nK2)
		
		if ((ROUND(nK2,3)==0 .and. ROUND(nK1,2)==0))
			// stanje nula, skoci na sljedecu robu
			select rekap1
			SEEK cG1+cIdTarifa+cIdroba+CHR(254)
			loop
		endif

		fFilovo:=.t.
		fFilGr:=.t.
		
		aStrRoba:=SjeciStr(trim(roba->naz), ROBAN_LEN)
		
		if (PROW()>cStrRedova2)
			FF
			ZaglSPo(@nStr)
		endif
		
		++nRBr
		? str(nRBr,4)+"."+PADR(cIdRoba,10)
		nColR:=pcol()+1
		@ prow(),nColR  SAY PADR(aStrRoba[1], ROBAN_LEN)
		nCol1:=PCOL()

		PrintZal(cG1, cIdTarifa, cIdRoba)
		
		// drugi red  prodaja  u mjesecu  k1
		nK1:=0
		if ((cPrikProd=="D") .or. LEN(aStrRoba)>1)
			?
			if LEN(aStrRoba)>1
				@ prow(),nColR SAY PADR(aStrRoba[2], ROBAN_LEN)
			endif
			@ prow(),nCol1 SAY ""
			if (cPrikProd=="D")
				PrintProd(cG1, cIdTarifa, cIdRoba)
			endif
		endif
		
		if (IsPlanika() .and. cPrikazDob=="D")
			? PrikaziDobavljaca(cIdRoba, 5)
		endif
		
		if cPodvuci=="D"
			? cLinija
		endif

		SELECT rekap1
		// pozicioniraj se na sljedeci artikal
		SEEK cG1+cIdTarifa+cIdroba+CHR(255) 

	enddo

	if !fFilGr
		loop
	endif
	
	if (PROW()>cStrRedova2)
		FF
		ZaglSPo(@nStr)
	endif

	? STRTRAN(cLinija, "-", "=")

	SELECT k1
	HSEEK cG1
	SELECT rekap1

	/*
		? "Ukupno grupa",cG1,"-",k1->naz

		// zaliha grupe
		PrintZalGr()
		if (cPrikProd=="D")
			PrintProdGr()
		endif

	*/
	
	SELECT rekap1
	STRTRAN(cLinija,"-","=")

enddo                        

if (PROW()>cStrRedova2)
	FF
	ZaglSPo(@nStr)
endif

FF
end print
#ifdef CAX
close all
#endif

closeret

return
*}



function SetK1K2(cG1, cIdTarifa, cIdRoba, nK1, nK2)
*{		
nK2:=0
nK1:=0
select pobjekti
go top
do while (!EOF()  .and. field->id<"99")
	select rekap1
	hseek  cG1+cIdtarifa+cIdroba+pobjekti->idobj
	nK2+=field->k2
	nK1+=field->k1
	select pobjekti
	skip
enddo

return
*}



static function SetLinSpo()
*{
local nObjekata

cLinija:=REPLICATE("-",4)+" "+REPLICATE("-",10)+" "+REPLICATE("-",ROBAN_LEN)
select pobjekti
go top
nObjekata:=0
do while !eof()
	cLinija:=cLinija+" "+REPLICATE("-",KOLICINA_LEN)
	++nObjekata
	skip
enddo


return
*}

static function ZaglSPo(nStr) 
*{
local nObjekata

? gTS+":",gNFirma,space(40),"Strana:"+str(++nStr,3)
?
?  "Stanje artikala po objektima za period:",dDatOd,"-",dDatDo
?
if (qqRoba==nil)
	qqRoba:=""
endif
? "Kriterij za Objekat:",trim(qqKonto), "Robu:",TRIM(qqRoba)
?

P_COND  

? cLinija

? PADC("Rbr",4)+" "+PADC("Sifra",10)+" "+PADC("NAZIV  ARTIKLA", ROBAN_LEN)
select objekti
go bottom
?? " "+PADC(ALLTRIM(objekti->naz), KOLICINA_LEN)
go top
do while (!EOF() .and. objekti->id<"99")
	?? " "+PADC(ALLTRIM(objekti->naz), KOLICINA_LEN)
	skip
enddo

// drugi red zaglavlja
? PADC(" ",4)+" "+PADC(" ",10)+" "+PADC(" ", ROBAN_LEN)
?? " "+padc("za/pr", KOLICINA_LEN)
select pobjekti
go top
do while (!EOF() .and. field->id<"99")
	?? " "+padc("zal/pr", KOLICINA_LEN)
	skip
enddo

? cLinija

return nil
*}

static function GetVars(cNObjekat)
*{

cUslov1:=""
cUslov2:=""
cUslovR:=""

dDatOd:=DATE()
dDatDo:=DATE()

O_PARAMS
private cSection:="F",cHistory:=" ",aHistory:={}
cPrikazDob:="N"
if IsPlanika()
	cK9:=SPACE(3)
endif

Params1()
RPar("c2",@qqKonto)
RPar("c3",@cPrSort)
RPar("d1",@dDatOd)
RPar("d2",@dDatDo)
RPar("cR",@qqRoba)
 
cKartica:="N" 
cNObjekat:=space(20)

cPrikProd:="N"

Box(,10,70)
set cursor on

do while .t.
	@ m_x+1,m_y+2 SAY "Konta objekata:" GET qqKonto pict "@!S50"
	@ m_x+3,m_y+2 SAY "tekuci promet je period:" GET dDatOd
	@ m_x+3,col()+2 SAY "do" GET dDatDo
	@ m_x+4,m_y+2 SAY "Kriterij za robu :" GET qqRoba pict "@!S50"
	@ m_x+5,m_y+2 SAY "Prikaz prodaje (D/N)" GET cPrikProd pict "@!" valid cPrikProd $ "DN"
	if IsPlanika()
		@ m_x+6,m_y+2 SAY "Prikaz dobavljaca (D/N)" GET cPrikazDob pict "@!" valid cPrikazDob $ "DN"
		@ m_x+7,m_y+2 SAY "Prikaz po K9" GET cK9 pict "@!"
	endif
	READ

	if (LASTKEY()==K_ESC)
		BoxC()
		return 0
	endif
	cUslov1:=Parsiraj(qqKonto,"PKonto")
	cUslov2:=Parsiraj(qqKonto,"MKonto")
	cUslovRoba:=Parsiraj(qqRoba,"IdRoba")
	
	if (cUslov1<>nil .and. cUslovRoba<>nil)
		exit
	endif
enddo
BoxC()

select roba
use

select params
if Params2()
	WPar("c2",qqKonto)
	WPar("c3",cPrSort)
	WPar("d1",dDatOd)
	WPar("d2",dDatDo)
	WPar("cR",@qqRoba)
endif
select params
use

return 1
*}

static function SetGaZagSpo()
*{

/*
if cRekPoRobama=="D"
	// 7.red fajla, 4 reda ukupno (7.,8.,9. i 10.) (ovi redovi su zaglavlje ovog izvjestaja i fiksno se prikazuju na ekranu)
	gaZagFix:={ 7, 4}    
	// 6.kolona, 38 kolona ukupno, od 7.reda ispisuj
	gaKolFix:={ 1, 58, 7 }   

elseif cRekPoDobavljacima=="D"
	gaZagFix:={15, 4}
	gaKolFix:={ 1, 58, 15 }
elseif cRekPoGrupamaRobe=="D"
	gaZagFix:={15, 4}
	gaKolFix:={ 1, 58, 15 }
endif
*/

return
*}

static function PrintZal(cG1, cIdTarifa, cIdRoba)
*{
local nK2

// prvi red zalihe
nK2:=0
// izracunajmo prvo ukupno (kolona "SVI")
select pobjekti    
go top
do while (!eof() .and. field->id<"99")
	 select rekap1
	 HSEEK cG1+cIdTarifa+cIdRoba+pobjekti->idobj
	 nK2+=field->k2
	 select pobjekti
	 skip
enddo
// ispis kolone "SVI"
@ prow(),pcol()+1 SAY nK2 pict cPicKol


// ispisi kolone za pojedine objekte
select pobjekti    
go top
do while (!EOF() .and. pobjekti->id<"99")
	 SELECT rekap1
	 HSEEK cG1+cIdTarifa+cIdRoba+pobjekti->idobj
	 if k4pp<>0
		@ prow(),pcol()+1 SAY STRTRAN(TRANS(k2,cPicKol)," ","*")
	 else
		@ prow(),pcol()+1 SAY k2 pict cPicKol
	 endif
	 select pobjekti
	 if roba->k2<>"X"   
		//samo u finansijski zbir
		replace zalt  with zalt+rekap1->k2,;
			zalu  with zalu+rekap1->k2 ,;
			zalg  with zalg+rekap1->k2
	 endif
	 skip
enddo

// ovo je objekat 99
if (roba->k2<>"X")   
	// roba sa oznakom k2=X
	replace zalt   with zalt+nk2 ,;
		zalu   with zalu+nk2 ,;
		zalg   with zalg+nk2
endif

return
*}



static function PrintProd(cG1, cIdTarifa, cIdRoba)
*{
local nK1

select pobjekti    
// ispisi kolone za pojedine objekte
nK1:=0
go top
do while (!EOF() .and. pobjekti->id<"99")
	 select rekap1
	 HSEEK cG1+cIdTarifa+cIdRoba+pobjekti->idobj
	 nK1+=field->k1
	 select pobjekti
	 skip
enddo

// sumarno prodaja
@ prow(),pcol()+1 SAY nK1 pict cPicKol

select pobjekti
go top
lIzaProc:=.t.
i:=0
do while (!eof() .and. pobjekti->id<"99")
	select rekap1
	hseek cG1+cIdTarifa+cIdRoba+pobjekti->idobj
	if k4pp<>0
		@ prow(),pcol()+1 SAY STRTRAN(TRANS(k1,cPicKol)," ","*")
	else
		@ prow(),pcol()+1 SAY k1 pict cPicKol
	endif
	++i
	
	select pobjekti
	if (roba->k2<>"X")
		REPLACE prodt  with  prodt+rekap1->k1
		REPLACE	produ  with  produ+rekap1->k1
		REPLACE	prodg  with  prodg+rekap1->k1
	endif
	skip
enddo

// skipuje na polje "99"
if roba->k2<>"X" 
	REPLACE prodt with prodt+nK1 
	REPLACE	produ with produ+nK1 
	REPLACE	prodg with prodg+nK1
endif

return

*}


static function PrintZalGr()
*{

select pobjekti
// idi na "objekat" 99 (SVI)
go bottom 
@ prow(),nCol1+1 SAY zalg PICT cPicKol
select pobjekti 
go top
i:=0
do while (!eof() .and. pobjekti->id<"99")
	@ prow(),pcol()+1 SAY zalg pict cPicKol
	++i
	skip
enddo

return
*}

static function PrintProdGr()	
*{

select pobjekti
go bottom 
// idi na "objekat" 99 (SVI)
@ prow()+1, nCol1+1 SAY prodg pict cPicKol
select pobjekti
go top
i:=0
do while (!eof()  .and. field->id<"99")
	@ prow(),pcol()+1 SAY prodg pict cPicKol
	++i
	skip
enddo

*}

