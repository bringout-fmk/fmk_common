#include "\cl\sigma\fmk\kalk\kalk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/sif/1g/sifre.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.9 $
 * $Log: sifre.prg,v $
 * Revision 1.9  2003/10/04 12:34:31  sasavranic
 * uveden security sistem
 *
 * Revision 1.8  2003/10/04 11:08:02  sasavranic
 * uveden security sistem
 *
 * Revision 1.7  2002/09/04 10:29:58  sasa
 * Do daljnjeg ukinuta opcija DOKS->TXT
 *
 * Revision 1.6  2002/07/06 17:28:58  ernad
 *
 *
 * izvjestaj Trgomarket: pregled stanja po objektima
 *
 * Revision 1.5  2002/07/06 12:29:01  ernad
 *
 *
 * kalk, planika GenRekap1, GenRekap2
 *
 * Revision 1.4  2002/06/24 08:51:19  sasa
 * no message
 *
 * Revision 1.3  2002/06/20 16:52:06  ernad
 *
 *
 * ciscenje planika, uvedeno fmk/svi/specif.prg
 *
 *
 */
 
/*! \file fmk/kalk/sif/1g/sifre.prg
 *  \brief Sifrarnici
 */

/*! \fn Sifre()
 *  \brief Glavni menij za izbor sifrarnika
 */
 
function Sifre()
*{
PRIVATE PicDem
PicDem:=gPICDem
close all

private opc:={}
private opcexe:={}
AADD(opc,"1. opci sifrarnici                  ")
if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","OPCISIFOPEN"))
	AADD(opcexe, {|| SifFmkSvi()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif
AADD(opc,"2. robno-materijalno poslovanje")
if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","ROBMATSIFOPEN"))
	AADD(opcexe, {|| SifFmkRoba()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc,"3. magacinski i prodajni objekti")
if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","PRODOBJSIFOPEN"))
	AADD(opcexe, {|| P_Objekti()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

if IsPlanika()
	AADD(opc, "P. planika")
	if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","PLSIFOPEN"))
		AADD(opcexe, {|| KaSifPlanika() })
	else
		AADD(opcexe, {|| MsgBeep(cZabrana) })
	endif
endif
private Izbor:=1
Menu_SC("msif")
CLOSERET
return .f.
*}



/*! \fn ServFun()
 *  \brief Servisne funkcije 
 */
 
function ServFun()
*{
Msg("Nije u upotrebi")
closeret
return
*}


/*! \fn RobaBlock(Ch)
 *  \brief Obrada funkcija nad sifrarnikom robe
 *  \param Ch - Pritisnuti taster
 */
 
function RobaBlock(Ch)
*{
LOCAL cSif:=ROBA->id, cSif2:=""

if Ch==K_CTRL_T .and. gSKSif=="D"

 // provjerimo da li je sifra dupla
 PushWA()
 SET ORDER TO TAG "ID"
 SEEK cSif
 SKIP 1
 cSif2:=ROBA->id
 PopWA()
 IF !(cSif==cSif2)
   // ako nije dupla provjerimo da li postoji u kumulativu
   if ImaUKumul(cSif,"7")
     Beep(1)
     Msg("Stavka se ne moze brisati jer se vec nalazi u dokumentima!")
     return 7
   endif
 ENDIF

elseif Ch==K_ALT_M
   return  MpcIzVpc()

elseif Ch==K_F2 .and. gSKSif=="D"
 if ImaUKumul(cSif,"7")
   return 99
 endif

elseif Ch==K_F8  // cjenovnik
 
 PushWa()
 nRet:=CjenR()
 OSifBaze()
 SELECT ROBA
 PopWA()
 return nRet

elseif upper(Chr(Ch))=="S"

  TB:Stabilize()  // problem sa "S" - exlusive, htc
  PushWa()
  KalkStanje(roba->id)
  PopWa()
  return 6  // DE_CONT2

endif

return DE_CONT
*}


/*! \fn FSvaki2()
 *  \brief Ne radi ama bas nista!!!
 */
 
function FSvaki2()
*{
return
*}


/*! \fn IspisFirme(cIdRj)
 *  \brief Ispis firme na osnovu radne jedinice
 *  \param cIdRj - radna jedinica
 */
function IspisFirme(cIdRj)
*{
local nOArr

nOArr:=SELECT()
?? "Firma: "
B_ON
?? gNFirma
B_OFF
if !EMPTY(cIdrj)
  SELECT rj
  HSEEK cIdrj
  SELECT(nOArr)
  ?? "  RJ",rj->naz
endif
return
*}


/*! \fn OSifBaze()
 *  \brief Otvara sve tabele vezane za sifrarnike
 */
 
function OSifBaze()
*{
if IzFMKIni("Svi","Sifk")=="D"
 O_SIFK
 O_SIFV
endif
O_KONTO
O_KONCIJ
O_PARTN
O_TNAL
O_TDOK
O_TRFP
O_TRMP
O_VALUTE
O_TARIFA
O_ROBA
O_SAST
return
*}

function P_K1()
*{

SELECT(F_K1)
if !USED()
	O_K1
endif

ImeKol:={ { "ID  ",  {|| id },     "id"       },;
 { "Naz",    {|| naz},     "naz"      };
}
Kol:={1,2}
PostojiSifra(F_K1, I_ID, 10, 60, "Lista - K1")
return
*}


function P_Objekti()
*{

SELECT(F_OBJEKTI)
if !USED()
	O_OBJEKTI
endif

ImeKol:={ { "ID  ",  {|| id },     "id"       },;
 { "Naziv", {|| naz},     "naz"      },;
 { "IdObj", {|| idobj},     "idobj"      };
}
Kol:={1,2,3}
PostojiSifra(F_OBJEKTI, 1, 10, 60, "Objekti")
return 
*}


