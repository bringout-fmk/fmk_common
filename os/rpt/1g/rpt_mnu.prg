#include "\cl\sigma\fmk\os\os.ch"


function Izvj()
*{
private Izbor:=1
private opc:={}
private opcexe:={}

cTip:=IF(gDrugaVal=="D",ValDomaca(),"")
cBBV:=cTip; nBBK:=1

AADD(opc, "1. pregled sredstava za rj                          ")
AADD(opcexe, {|| PregRJ()})
AADD(opc, "2. pregled sredstava po kontima")
AADD(opcexe, {|| PregRjKon()})
AADD(opc, "3. amortizacija po kontima")
AADD(opcexe, {|| PregRjAm()})
AADD(opc, "4. revalorizacija po kontima")
AADD(opcexe, {|| PregRjRev()})
AADD(opc, "5. rekapitulacija kolicina po grupacijama - k1")
AADD(opcexe, {|| RekK1()})
AADD(opc, "6. amortizacija po grupama amortizacionih stopa")
AADD(opcexe, {|| PrRjAmSt()})
AADD(opc, "7. amortizacija po kontima i po grupama amort.stopa")
AADD(opcexe, {|| PrKiAs()})
AADD(opc, "8. kartica sredstva")
AADD(opcexe, {|| KarticaSr()})
AADD(opc, "9. lista sredstava uvedenih u tekucoj godini")
AADD(opcexe, {|| NovaSredstva()})
AADD(opc, "A. lista sredstava izbrisanih u tekucoj godini")
AADD(opcexe, {|| IzbrisanaSredstva()})


Menu_SC("izv")

return
*}


