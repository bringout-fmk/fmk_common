#include "\cl\sigma\fmk\virm\virm.ch"


function MnuSifrarnik()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

OSifVirm()

AADD(opc, "1. opci sifrarnici          ")
AADD(opcexe, {|| MnuSifOpc()})
AADD(opc, "2. specificni sifrarnici ")
AADD(opcexe, {|| MnuSifSpec()})

Menu_SC("sif")
return
*}

function MnuSifOpc()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. partneri                    ")
AADD(opcexe, {|| P_Firme()})
AADD(opc, "2. valute")
AADD(opcexe, {|| P_Valuta()})
AADD(opc, "3. opcine")
AADD(opcexe, {|| P_Ops()})
AADD(opc, "4. banke")
AADD(opcexe, {|| P_Banke()})
AADD(opc, "5. sifk")
AADD(opcexe, {|| P_SifK()})

Menu_SC("sopc")
return
*}


function MnuSifSpec()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. vrste primalaca                          ")
AADD(opcexe, {|| P_VrPrim()})
AADD(opc, "2. javni prihodi")
AADD(opcexe, {|| P_JPrih()})
AADD(opc, "3. ld   -> virm")
AADD(opcexe, {|| P_LdVirm()})
AADD(opc, "4. kalk -> virm")
AADD(opcexe, {|| P_KalVir()})
AADD(opc, "5. podaci za stampanje-uplatnice ")
AADD(opcexe, {|| P_Stamp2()})


Menu_SC("ssp")
return
*}


function OSifVirm()
*{
O_SIFK
O_SIFV
O_STAMP
O_STAMP2
O_PARTN
O_VRPRIM
O_VRPRIM2
O_VALUTE
O_LDVIRM
O_KALVIR
O_JPRIH
O_BANKE
O_OPS
return
*}

