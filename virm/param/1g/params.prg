#include "\cl\sigma\fmk\virm\virm.ch"


function Pars1()
*{
O_PARAMS
private cSection:="1",cHistory:=" "; aHistory:={}
RPar("Pi",@gPici)
Rpar("a4",@gA43)
RPar("bn",@gINulu)
Rpar("e3",@gNazad)
Rpar("fz",@gZaglav)
Rpar("i'",@gnInca)
Rpar("nt",@gNumT)
Rpar("pm",@gKLpomak)
RPar("pr",@gnLMarg)
Rpar("ra",@gnRazmak)
RPar("tb",@gTabela)
RPar("du",@gIDU)

gDirFin:=padr(gDirFin,25)
gDirLD :=padr(gDirLD ,25)
gDirKALK :=padr(gDirKALK ,25)


UsTipke()

 set cursor on

 aNiz:={ {"Lijeva margina pri stampanju (znakova)" , "gnLMarg", , "99", },;
         {"Pomak u kojim dijelovima incha "   , "gnInca", , "9999", },;
         {"Tip tabele  (0/1/2)"          , "gTabela", "gTabela>=0.and.gTabela<3", "9", },;
         {"Format papira za ispis  ( 3 - A3 , 4 - A4 )", "gA43", "gA43 $ '43'", "9", },;
         {"Odstupanje razmaka izmedju redova kod stampe (%)", "gnRazmak", , "999.99", },;
         {"Kod za razmak izmedju redova", "gKLpomak", , "@S30", },;
         {"Kod za vracanje glave stampaca 1 znak lijevo", "gNazad", , , },;
         {"Iznos stampati u formatu 1.000.000,00 (D/N) ?", "gNumT", "gNumT$'DN'", "@!", },;
         {"Naziv fajla zaglavlja  (prazno-bez zaglavlja)", "gZaglav", "V_VZagl()", , } ,;
         {"Ako je iznos = 0, treba ga stampati? (D/N)", "gINulu", "gINulu$'DN'", "@!", } ,;
         {"Direktorij FIN - priprema ", "gDirFin", , , } ,;
         {"Direktorij LD  - kumulativ", "gDirLD", , , } ,;
         {"Direktorij KALK- kumulativ", "gDirKALK", , , } ,;
         {"Prikaz iznosa", "gPici", , , },;
         {"Ako nije zadan inicijalni datum uplate, uzimati sistemski datum (D/N)?", "gIDU", "gIDU$'DN'", "@!", } }

 VarEdit(aNiz,0,1,24,78,"OPSTI PARAMETRI RADA PROGRAMA","B1")

BosTipke()

gDirFin:=trim(gDirFin)
gDirLD :=trim(gDirLD )
gDirKALK :=trim(gDirKALK )

if lastkey()<>K_ESC
  WPar("Pi",gPici)
  Wpar("a4",gA43)
  WPar("bn",gINulu)
  Wpar("df",gDirFin)
  Wpar("dl",gDirLD)
  Wpar("dk",gDirKALK)
  Wpar("e3",gNazad)
  Wpar("fz",gZaglav)
  Wpar("i'",gnInca)
  Wpar("nt",gNumT)
  Wpar("pm",gKLpomak)
  WPar("pr",gnLMarg)
  Wpar("ra",gnRazmak)
  WPar("tb",gTabela)
  WPar("du",gIDU)
  select params; use
endif
return
*}


function Pars2()
*{
O_PARAMS
private cSection:="1",cHistory:=" "; aHistory:={}
Rpar("c0",@gKpocet0)
Rpar("c1",@gKpocet1)
Rpar("c2",@gKpocet2)
Rpar("c9",@gKKraj0)
Rpar("e1",@gPrecrt1)
Rpar("e2",@gPrecrt2)
RPar("pt",@gnTMarg)
Rpar("r1",@gnRazTrak)
Rpar("r2",@gTrakas)

public gKpocet0:=PADR(gKpocet0,80)
public gKKraj0:=PADR(gKKraj0,80)
UsTipke()

 set cursor on

 aNiz:={ {"Gornja margina (mm)"               , "gnTMarg", , "999.99", },;
         {"Ini linija za virmane", "gKpocet0", , "@S40", },;
         {"Linija za kraj stamp", "gKKraj0", , "@S40", },;
         {"Inicijalna kodna linija za "+ValDomaca()+" virmane", "gKpocet1", , "@S25", },;
         {"Inicijalna kodna linija za dev. virmane", "gKpocet2", , "@S25", },;
         {"Precrtati val.kraticu na "+ALLTRIM(ValDomaca())+" virmanima? (D/N/V-ispis van polja iznosa)", "gPrecrt1", "gPrecrt1$'DNV'", "@!", },;
         {"Precrtati val.kraticu na dev.virmanima? (D/N/V-ispis van polja iznosa)", "gPrecrt2", "gPrecrt2$'DNV'", "@!", },;
         {"Da li su virmani na perforiranom papiru (D/N) ?", "gTrakas", "gTrakas$'DN'", "@!", },;
         {"Razmak izmedju virmana kod stampe za perforirani papir (mm)", "gnRazTrak", , "999.99", } }

 VarEdit(aNiz,0,1,24,78,"PARAMETRI RADA PROGRAMA ZA VIRMANE","B1")

BosTipke()

if lastkey()<>K_ESC
  Wpar("c0",trim(gKpocet0))
  Wpar("c1",gKpocet1)
  Wpar("c2",gKpocet2)
  Wpar("c9",trim(gKKraj0))
  Wpar("e1",gPrecrt1)
  Wpar("e2",gPrecrt2)
  WPar("pt",gnTMarg)
  Wpar("r1",gnRazTrak)
  Wpar("r2",gTrakas)
  select params; use
endif
return
*}



function Pars3()
*{
O_PARAMS
private cSection:="1",cHistory:=" "; aHistory:={}
Rpar("u0",@gUKpocet0)
Rpar("u1",@gUKpocet1)
Rpar("u2",@gUKpocet2)
Rpar("u3",@gUKKraj0)
Rpar("u4",@gUPrecrt1)
Rpar("u5",@gUPrecrt2)
RPar("u6",@gnUTMarg)
Rpar("u7",@gnURazTrak)
Rpar("u8",@gUTrakas)

public gUKpocet0:=PADR(gUKpocet0,80)
public gUKKraj0:=PADR(gUKKraj0,80)
UsTipke()

 set cursor on

 aNiz:={ {"Gornja margina (mm)"               , "gnUTMarg", , "999.99", },;
         {"Ini linija za uplatnice", "gUKpocet0", , "@S40", },;
         {"Linija za kraj stamp", "gUKKraj0", , "@S40", },;
         {"Inicijalna kodna linija za "+ValDomaca()+" uplatnice", "gUKpocet1", , "@S25", },;
         {"Inicijalna kodna linija za dev. uplatnice", "gUKpocet2", , "@S25", },;
         {"Precrtati val.kraticu na "+ALLTRIM(ValDomaca())+" uplatnicama? (D/N/V-ispis van polja iznosa)", "gUPrecrt1", "gUPrecrt1$'DNV'", "@!", },;
         {"Precrtati val.kraticu na dev.uplatnicama? (D/N/V-ispis van polja iznosa)", "gUPrecrt2", "gUPrecrt2$'DNV'", "@!", },;
         {"Da li su uplatnice na perforiranom papiru (D/N) ?", "gUTrakas", "gUTrakas$'DN'", "@!", },;
         {"Razmak izmedju uplatnica kod stampe za perforirani papir (mm)", "gnURazTrak", , "999.99", } }

 VarEdit(aNiz,0,1,24,78,"PARAMETRI RADA PROGRAMA ZA UPLATNICE","B1")

BosTipke()

if lastkey()<>K_ESC
  Wpar("u0",trim(gUKpocet0))
  Wpar("u1",gUKpocet1)
  Wpar("u2",gUKpocet2)
  Wpar("u3",trim(gUKKraj0))
  Wpar("u4",gUPrecrt1)
  Wpar("u5",gUPrecrt2)
  WPar("u6",gnUTMarg)
  Wpar("u7",gnURazTrak)
  Wpar("u8",gUTrakas)
  select params; use
endif
return
*}



FUNCTION V_VZagl()
 PRIVATE cKom:="q "+PRIVPATH+gZaglav
 IF !EMPTY(gZaglav)
  IF Pitanje(,"Zelite li izvrsiti ispravku zaglavlja ?","N")=="D"
    Prozor1(0,0,24,79)
    RUN &ckom
    Prozor0()
  ENDIF
 ENDIF
RETURN .t.


FUNCTION ValDomaca()     // vraca skraceni naziv domace valute
local xRez, nSelect
#ifdef CAX
 nSelect:=select()
#else
 PushWa()
#endif
SELECT (F_VALUTE)
#ifdef CAX
O_VALUTE
#else
IF !USED(); O_VALUTE; ENDIF
#endif
SET ORDER TO TAG "NAZ"
seek "D"
xRez:=naz2

#ifdef CAX
 select(nSelect)
#else
 PopWa()
#endif
return xRez

FUNCTION ValPomocna()    // vraca skraceni naziv pomocne (strane) valute
local xRez,nSelect

#ifdef CAX
nSelect:=select()
#else
PushWa()
#endif
SELECT (F_VALUTE)
#ifdef CAX
 O_VALUTE
#else
 IF !USED(); O_VALUTE; ENDIF
#endif
SET ORDER TO TAG "NAZ"
seek "P"
xRez:=naz2
#ifdef CAX
 select(nSelect)
#else
 PopWa()
#endif
return xRez
*}




