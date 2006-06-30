#include "\cl\sigma\fmk\kam\kam.ch"


function Obrac(fVise)
local nKumKam:=0

nGlavn:=2892359.28
dDatOd:=ctod("01.02.92")
dDatDo:=ctod("30.09.96")

private cVarObracuna
cVarObracuna:="Z"  // zatezna kamata

if fvise=NIL
  fVise:=.f.
endif

if !fvise
************************************************
O_PARAMS
private cSection:="1"; cHistory:=" ";aHistory:={}
Params1()
RPar("d1",@dDatOd);RPar("d2",@dDatDo)
RPar("n3",@nGlavn)
************************************************

Box("#OBRACUN KAMATE ZA JEDNU GLAVNICU",3,77)
 @ m_x+1,m_y+2 SAY "Glavnica:" GET nGlavn  pict "9999999999999.99"
 @ m_x+2,m_y+2 SAY "Od datuma:" GET dDatOd
 @ m_x+2,col()+2 SAY "do:" GET dDatDo
 @ m_x+3,m_y+2 SAY "Varijanta obracuna kamate (Z-zatezna kamata,P-prosti kamatni racun)" GET cVarObracuna VALID cVarObracuna$"ZP" PICT "@!"
 read; ESC_BCR
BoxC()

*********************
if Params2()
 WPar("d1",dDatOd);WPar("d2",dDatDo)
 WPar("n3",nGlavn)
endif
select params; use
**********************

endif // fvise

select (F_KS)
if !used()
  O_KS; set order to 2
endif

private picDem:="9999999999999.99"

START PRINT CRET

P_10CPI
? space(45),"SIGMA-COM: K A M A T E"
?
?
B_ON
? space(45),"Preduzece:",gNFirma
B_OFF
?
? "Partner: _____________________________________"
?
? "Obracun kamate po dokumentu : ________________ "
?
?

if (cVarObracuna=="Z")
	? "Obracun zatezne kamate za period:",dDatOd,"-",dDatDo
else
	? "Prosti kamatni obracun za period:",dDatOd,"-",dDatDo
endif

?
? "   Glavnica:"
@ prow(),pcol()+1 SAY nGlavn pict picDEM

if (cVarObracuna=="Z")
	? m:="-------- -------- --- ---------------- ---------- ------- ----------------"
	? "     Period       Dana      Osnovica     Tip kam.  Konform.      Iznos"
	? "                                         i stopa    koef         kamate"
else
	? m:="-------- -------- --- ---------------- --------- ----------------"
	? "     Period       Dana    Osnovica       Stopa       Iznos"
	? "                                                     kamate"
endif
? m


nKumKam:=0

seek dtos(dDatOd)
if dDatOd < ks->DatOd .or. eof()
 skip -1
endif

do while .t.

ddDatDo:=min(ks->DatDO,dDatDo)

//if dDatOd==ddDatDo
//  exit                ?????????? da li ovo treba ??????????
//endif

if (IzFmkIni("KAM","DodajDan","D",KUMPATH)=="D")
	nPeriod:= ddDatDo-dDatOd+1
else
	nPeriod:= ddDatDo-dDatOd
endif
*nPeriod:= ddDatDo-dDatOd  // zeljezara

if (cVarObracuna=="P")
	if (Prestupna(YEAR(dDatOd)))
		nExp:=366
	else
		nExp:=365
	endif
else
	if ks->tip=="G"
		if ks->duz==0
			//if year(dDatOD) % 4 == 0
			//  nExp:=366
			//else
			nExp:=365
			//endif
		else
			nExp:=ks->duz
		endif
	elseif ks->tip=="M"
		if ks->duz==0
			dExp:= "01."
			if month(ddDatdo)==12
				dExp+="01."+alltrim(str(year(ddDatdo)+1))
			else
				dExp+=alltrim(str(month(ddDatdo)+1))+"."+alltrim(str(year(ddDatdo)))
			endif
			// dexp - karakter varijabla
			nExp:=day(ctod(dExp)-1)
			//nExp:=30
		else
			nExp:=ks->duz
		endif
	elseif ks->tip=="3"
		nExp:=ks->duz
	endif
endif

if ks->den<>0  .and. dDatOd==ks->datod
 ? "********* Izvrsena Denominacija osnovice sa koeficijentom:",ks->den,"****"
 nGlavn:=round(nGlavn*ks->den,2)
 nKumKam:=round(nKumKam*ks->den,2)
endif

if (cVarObracuna=="Z") 
	nKKam:=((1+ks->stkam/100)^(nPeriod/nExp) - 1.00000)
	nIznKam:=nKKam*nGlavn
else
	nKStopa:=ks->stkam/100
	cPom777:=IzFmkIni("KAM","FormulaZaProstuKamatu","nGlavn*nKStopa*nPeriod/nExp",KUMPATH)
	nIznKam:=&(cPom777)
endif

nIznKam:=round(nIznKam,2)

? dDatOd,ddDatDo
@ prow(),pcol()+1 SAY nPeriod pict "999"
@ prow(),pcol()+1 SAY nGlavn pict picdem
if (cVarObracuna=="Z")
	@ prow(),pcol()+1 SAY ks->tip
	@ prow(),pcol()+1 SAY ks->stkam
	@ prow(),pcol()+1 SAY nKKam*100 pict "9999.99"
else
	@ prow(),pcol()+1 SAY ks->stkam
endif
@ prow(),pcol()+1 SAY nIznKam pict picdem


nKumKam+=nIznKam

if (cVarObracuna=="Z")
	nGlavn+=nIznKam
endif

if dDatDo<=ks->DatDo // kraj obracuna
 exit
endif

skip

dDatOd:=ks->DatOd

enddo
? m
?
? "Ukupno kamata    :",transform(nKumKam,"999,999,999,999,999.99")
?
if (cVarObracuna=="Z")
	? "NOVO STANJE      :",transform(nGlavn,"999,999,999,999,999.99")
else
	? "GLAVNICA+KAMATA  :",transform(nGlavn+nKumKam,"999,999,999,999,999.99")
endif

?
FF
END PRINT
closeret







function V_VZagl()
private cKom:="q "+PRIVPATH+gVlZagl
if Pitanje(,"Zelite li izvrsiti ispravku zaglavlja ?","N")=="D"
 if !empty(gVlZagl)
   Box(,25,80)
   run &ckom
   BoxC()
 endif
endif
return .t.



function Prestupna(nGodina)
local lPrestupna
lPrestupna:=.f.
if nGodina%4==0
	lPrestupna:=.t.
endif
return lPrestupna
