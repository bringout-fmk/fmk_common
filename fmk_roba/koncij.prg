#include "fmk.ch"

 
function P_KonCij(CId,dx,dy)
local nTArea
private ImeKol
private Kol

ImeKol := {}
Kol := {}

nTArea := SELECT()
O_KONCIJ

AADD(ImeKol, { "ID", {|| id}, "id", {|| .t.}, {|| vpsifra(wId)} })
AADD(ImeKol, { PADC("Shema",5), {|| PADC(shema,5)}, "shema"})
AADD(ImeKol, { "Tip", {|| naz}, "naz"})
AADD(ImeKol, { "PM", {|| idprodmjes}, "idprodmjes"})

IF KONCIJ->(FIELDPOS("IDRJ")<>0)
  AADD (ImeKol,{ "RJ"     , {|| idrj }, "IDRJ" , {|| .t.}, {|| .t.} })
  AADD (ImeKol,{ "Sint.RJ", {|| sidrj}, "SIDRJ", {|| .t.}, {|| .t.} })
  AADD (ImeKol,{ "Banka"  , {|| banka}, "BANKA", {|| .t.}, {|| empty(wbanka) .or. P_Firma(@wbanka)} })
ENDIF

IF KONCIJ->(FIELDPOS("M1")<>0)
  AADD (ImeKol,{ "Marker"       , {|| m1  }, "m1"  , {|| .t.}, {|| .t.} })
  AADD (ImeKol,{ "KALK14->FINxx", {|| fn14}, "fn14", {|| .t.}, {|| .t.} })
ENDIF

if KONCIJ->(fieldpos("KK1"))<>0
  AADD (ImeKol,{ padc("KK1",7 ), {|| KK1}, "KK1", {|| .t.}, {|| empty(wKK1) .or. P_Konto(@wKK1)} })
  AADD (ImeKol,{ padc("KK2",7 ), {|| KK2}, "KK2", {|| .t.}, {|| empty(wKK2) .or. P_Konto(@wKK2)} })
  AADD (ImeKol,{ padc("KK3",7 ), {|| KK3}, "KK3", {|| .t.}, {|| empty(wKK3) .or. P_Konto(@wKK3)} })
  AADD (ImeKol,{ padc("KK4",7 ), {|| KK4}, "KK4", {|| .t.}, {|| empty(wKK4) .or. P_Konto(@wKK4)} })
  AADD (ImeKol,{ padc("KK5",7 ), {|| KK5}, "KK5", {|| .t.}, {|| empty(wKK5) .or. P_Konto(@wKK5)} })
  AADD (ImeKol,{ padc("KK6",7 ), {|| KK6}, "KK6", {|| .t.}, {|| empty(wKK6) .or. P_Konto(@wKK6)} })
endif

if KONCIJ->(fieldpos("KP1"))<>0
  AADD (ImeKol,{ padc("KP1",7 ), {|| KP1}, "KP1", {|| .t.}, {|| empty(wKP1) .or. P_Konto(@wKP1)} })
  AADD (ImeKol,{ padc("KP2",7 ), {|| KP2}, "KP2", {|| .t.}, {|| empty(wKP2) .or. P_Konto(@wKP2)} })
  AADD (ImeKol,{ padc("KP3",7 ), {|| KP3}, "KP3", {|| .t.}, {|| empty(wKP3) .or. P_Konto(@wKP3)} })
  AADD (ImeKol,{ padc("KP4",7 ), {|| KP4}, "KP4", {|| .t.}, {|| empty(wKP4) .or. P_Konto(@wKP4)} })
  AADD (ImeKol,{ padc("KP5",7 ), {|| KP5}, "KP5", {|| .t.}, {|| empty(wKP5) .or. P_Konto(@wKP5)} })
endif

if KONCIJ->(fieldpos("KO1"))<>0
  AADD (ImeKol,{ padc("KO1",7 ), {|| KO1}, "KO1", {|| .t.}, {|| empty(wKO1) .or. P_Konto(@wKO1)} })
  AADD (ImeKol,{ padc("KO2",7 ), {|| KO2}, "KO2", {|| .t.}, {|| empty(wKO2) .or. P_Konto(@wKO2)} })
  AADD (ImeKol,{ padc("KO3",7 ), {|| KO3}, "KO3", {|| .t.}, {|| empty(wKO3) .or. P_Konto(@wKO3)} })
  AADD (ImeKol,{ padc("KO4",7 ), {|| KO4}, "KO4", {|| .t.}, {|| empty(wKO4) .or. P_Konto(@wKO4)} })
  AADD (ImeKol,{ padc("KO5",7 ), {|| KO5}, "KO5", {|| .t.}, {|| empty(wKO5) .or. P_Konto(@wKO5)} })
endif
if KONCIJ->(fieldpos("KUMTOPS"))<>0
   AADD (ImeKol,{ "Kum.dir.TOPS-a", {|| KUMTOPS}, "KUMTOPS", {|| .t.}, {|| .t.} })
 AADD (ImeKol,{ "Sif.dir.TOPS-a", {|| SIFTOPS}, "SIFTOPS", {|| .t.}, {|| .t.} })
endif

if KONCIJ->(fieldpos("REGION"))<>0
  AADD (ImeKol,{ "Region", {|| Region}, "Region", {|| .t.}, {|| .t.} })
endif

if KONCIJ->(fieldpos("SUFIKS"))<>0
  AADD (ImeKol,{ "Sufiks BrKalk", {|| sufiks}, "sufiks", {|| .t.}, {|| .t.} })
endif

for i:=1 to LEN(ImeKol)
	AADD(Kol, i)
next

select (nTArea)
return PostojiSifra(F_KONCIJ,1,10,60,"Lista: Konta - tipovi cijena",@cId,dx,dy)


function P_KonCij2(CId,dx,dy)
local nTArea
private ImeKol
private Kol

ImeKol := {}
Kol := {}

nTArea := SELECT()
O_KONCIJ

AADD(ImeKol, { "ID", {|| id}, "id", {|| .t.}, {|| vpsifra(wId)} })
AADD(ImeKol, { PADC("Shema",5), {|| PADC(shema,5)}, "shema"})
AADD(ImeKol, { "Tip", {|| naz}, "naz"})
AADD(ImeKol, { "PM", {|| idprodmjes}, "idprodmjes"})

if KONCIJ->(fieldpos("KPD"))<>0
  AADD (ImeKol,{ padc("KP6",7 ), {|| KP6}, "KP6", {|| .t.}, {|| empty(wKP6) .or. P_Konto(@wKP6)} })
  AADD (ImeKol,{ padc("KP7",7 ), {|| KP7}, "KP7", {|| .t.}, {|| empty(wKP7) .or. P_Konto(@wKP7)} })
  AADD (ImeKol,{ padc("KP8",7 ), {|| KP8}, "KP8", {|| .t.}, {|| empty(wKP8) .or. P_Konto(@wKP8)} })
  AADD (ImeKol,{ padc("KP9",7 ), {|| KP9}, "KP9", {|| .t.}, {|| empty(wKP9) .or. P_Konto(@wKP9)} })
  AADD (ImeKol,{ padc("KPA",7 ), {|| KPA}, "KPA", {|| .t.}, {|| empty(wKPA) .or. P_Konto(@wKPA)} })
  AADD (ImeKol,{ padc("KPB",7 ), {|| KPB}, "KPB", {|| .t.}, {|| empty(wKPB) .or. P_Konto(@wKPB)} })
  AADD (ImeKol,{ padc("KPC",7 ), {|| KPC}, "KPC", {|| .t.}, {|| empty(wKPC) .or. P_Konto(@wKPC)} })
  AADD (ImeKol,{ padc("KPD",7 ), {|| KPD}, "KPD", {|| .t.}, {|| empty(wKPD) .or. P_Konto(@wKPD)} })
endif

if KONCIJ->(fieldpos("KPK"))<>0
  AADD (ImeKol,{ padc("KPF",7 ), {|| KOF}, "KPF", {|| .t.}, {|| empty(wKPF) .or. P_Konto(@wKPF)} })
  AADD (ImeKol,{ padc("KPG",7 ), {|| KOG}, "KPG", {|| .t.}, {|| empty(wKPG) .or. P_Konto(@wKPG)} })
  AADD (ImeKol,{ padc("KPH",7 ), {|| KOH}, "KPH", {|| .t.}, {|| empty(wKPH) .or. P_Konto(@wKPH)} })
  AADD (ImeKol,{ padc("KPI",7 ), {|| KOI}, "KPI", {|| .t.}, {|| empty(wKPI) .or. P_Konto(@wKPI)} })
  AADD (ImeKol,{ padc("KPJ",7 ), {|| KOJ}, "KPJ", {|| .t.}, {|| empty(wKPJ) .or. P_Konto(@wKPJ)} })
  AADD (ImeKol,{ padc("KPK",7 ), {|| KOK}, "KPK", {|| .t.}, {|| empty(wKPK) .or. P_Konto(@wKPK)} })
endif

if KONCIJ->(fieldpos("KOD"))<>0
  AADD (ImeKol,{ padc("KO6",7 ), {|| KO6}, "KO6", {|| .t.}, {|| empty(wKO6) .or. P_Konto(@wKO6)} })
  AADD (ImeKol,{ padc("KO7",7 ), {|| KO7}, "KO7", {|| .t.}, {|| empty(wKO7) .or. P_Konto(@wKO7)} })
  AADD (ImeKol,{ padc("KO8",7 ), {|| KO8}, "KO8", {|| .t.}, {|| empty(wKO8) .or. P_Konto(@wKO8)} })
  AADD (ImeKol,{ padc("KO9",7 ), {|| KO9}, "KO9", {|| .t.}, {|| empty(wKO9) .or. P_Konto(@wKO9)} })
  AADD (ImeKol,{ padc("KOA",7 ), {|| KOA}, "KOA", {|| .t.}, {|| empty(wKOA) .or. P_Konto(@wKOA)} })
  AADD (ImeKol,{ padc("KOB",7 ), {|| KOB}, "KOB", {|| .t.}, {|| empty(wKOB) .or. P_Konto(@wKOB)} })
  AADD (ImeKol,{ padc("KOC",7 ), {|| KOC}, "KOC", {|| .t.}, {|| empty(wKOC) .or. P_Konto(@wKOC)} })
  AADD (ImeKol,{ padc("KOD",7 ), {|| KOD}, "KOD", {|| .t.}, {|| empty(wKOD) .or. P_Konto(@wKOD)} })
endif

if KONCIJ->(fieldpos("KOK"))<>0
  AADD (ImeKol,{ padc("KOF",7 ), {|| KOF}, "KOF", {|| .t.}, {|| empty(wKOF) .or. P_Konto(@wKOF)} })
  AADD (ImeKol,{ padc("KOG",7 ), {|| KOG}, "KOG", {|| .t.}, {|| empty(wKOG) .or. P_Konto(@wKOG)} })
  AADD (ImeKol,{ padc("KOH",7 ), {|| KOH}, "KOH", {|| .t.}, {|| empty(wKOH) .or. P_Konto(@wKOH)} })
  AADD (ImeKol,{ padc("KOI",7 ), {|| KOI}, "KOI", {|| .t.}, {|| empty(wKOI) .or. P_Konto(@wKOI)} })
  AADD (ImeKol,{ padc("KOJ",7 ), {|| KOJ}, "KOJ", {|| .t.}, {|| empty(wKOJ) .or. P_Konto(@wKOJ)} })
  AADD (ImeKol,{ padc("KOK",7 ), {|| KOK}, "KOK", {|| .t.}, {|| empty(wKOK) .or. P_Konto(@wKOK)} })
endif

for i:=1 to LEN(ImeKol)
	AADD(Kol, i)
next

select (nTArea)
return PostojiSifra(F_KONCIJ,1,10,60,"Lista: Konta / Atributi / 2 ",@cId,dx,dy)


