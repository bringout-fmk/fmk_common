#include "\cl\sigma\fmk\fin\fin.ch"
/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fin/sif/1g/mnu_sif.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.9 $
 * $Log: mnu_sif.prg,v $
 * Revision 1.9  2004/03/02 18:37:27  sasavranic
 * no message
 *
 * Revision 1.8  2004/01/13 19:07:57  sasavranic
 * appsrv konverzija
 *
 *
 */


/*! \file fmk/fin/sif/1g/mnu_sif.prg
 *  \brief Menij sifrarnika
 */


/*! \fn MnuSifrarnik()
 *  \brief Menij sifrarnika
 */


function MnuSifrarnik()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. opci sifrarnik                  ")
if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","OPCISIFOPEN"))
	AADD(opcexe, {|| SifFmkSvi()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "2. finansijsko poslovanje ")
if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","FINPSIFOPEN"))
	AADD(opcexe, {|| MnuSpecSif()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

if (gRj=="D" .or. gTroskovi=="D")
	AADD(opc, "3. budzet")
	AADD(opcexe, {|| MnuBudzSif()})
endif

Menu_SC("sif")

return
*}

/*! \fn MnuSpecSif()
 *  \brief Specificni sifrarnika
 */
function MnuSpecSif()
*{
private opc:={}
private opcexe:={}
private izbor:=1

O_KONTO
O_TRFP2
if (IsLdFin())
	O_TRFP3
endif
O_PKONTO

AADD(opc, "1. kontni plan                          ")
AADD(opcexe, {|| P_KontoFin()})
AADD(opc, "2. sheme kontiranja                     ")
AADD(opcexe, {|| P_Trfp2()})
AADD(opc, "3. prenos konta u ng")
AADD(opcexe, {|| P_PKonto()})

if IzFMKIni("FAKT","VrstePlacanja","N",SIFPATH)=="D"
	O_VRSTEP
 	AADD(opc,"4. vrste placanja")
	AADD(opcexe, {|| P_VrsteP()})
	//16
else
	AADD(opc,"4. --------------")
	AADD(opcexe, {|| nil})
endif

if IzFMKIni("FIN","LimitiPoUgovoru_PoljeK3","N",SIFPATH)=="D"
	O_ULIMIT
 	AADD(opc,"5. limiti po ugovorima")  //17
	AADD(opcexe, {|| P_ULimit()})
else
 	AADD(opc,"5. --------------")
	AADD(opcexe, {|| nil})
endif

if IzFMKIni("FIN","KUF","N")=="D"
	lKUF:=.t.
  	O_KUF
  	AADD(opc,"6. KUF")  // 18
	AADD(opcexe, {|| P_Kuf()})
else
	lKUF:=.f.
  	AADD(opc,"6. --------------")
	AADD(opcexe, {|| nil})
endif

if IzFMKIni("FIN","KIF","N")=="D"
	lKIF:=.t.
  	O_KIF
  	O_VPRIH
  	AADD(opc,"7. KIF")            // 19
	AADD(opcexe, {|| P_Kif()})
  	AADD(opc,"8. vrste prihoda")  // 20
	AADD(opcexe, {|| P_VPrih()})
else
	lKIF:=.f.
  	AADD(opc,"7. --------------")
	AADD(opcexe, {|| nil})
  	AADD(opc,"8. --------------")
	AADD(opcexe, {|| nil})
endif

if (IsLdFin())
	AADD(opc,"9. sheme kontiranja obracuna LD")
	AADD(opcexe, {|| P_TRFP3()})
endif

Menu_SC("sopc")

return
*}

/*! \fn MnuBudzSif()
 *  \brief Menij budzetskog poslovanja
 */
function MnuBudzSif()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

OSifBudzet()

AADD(opc,"1. radne jedinice              ")
AADD(opcexe, {|| P_Rj()})
AADD(opc,"2. funkc.kval       ")
AADD(opcexe, {|| P_FunK()})
AADD(opc,"3. plan budzeta")
AADD(opcexe, {|| P_Budzet()})
AADD(opc,"4. partije->konta ")
AADD(opcexe, {|| P_ParEK()})
AADD(opc,"5. fond   ")
AADD(opcexe, {|| P_Fond()})

if gBuIz=="D"
	AADD(opc,"6. konta-izuzeci")
	AADD(opcexe, {|| P_BuIZ()})
else
	AADD(opc,"6. -------------")
	AADD(opcexe, {|| nil})
endif

Menu_SC("sbdz")

return
*}

/*! \fn OSifBudzet()
 *  \brief Otvara potrebne tabele za budzetsko poslovanje
 */
function OSifBudzet()
*{
O_RJ
O_FUNK
O_FOND
O_BUDZET
O_PAREK
O_BUIZ
O_KONTO
if File(SIFPATH+"trfp2.dbf")
	O_TRFP2
endif
return
*}



