#include "sc.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/svi/specif.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.19 $
 * $Log: specif.prg,v $
 * Revision 1.19  2004/05/28 12:35:48  sasavranic
 * Dodao IsTehnoprom()
 *
 * Revision 1.18  2004/05/25 13:27:42  sasavranic
 * Uvedeno IsDomZdr()
 *
 * Revision 1.17  2004/03/23 15:47:26  sasavranic
 * Uveo novu globalnu varijablu gOznVal (oznaka valute)
 *
 * Revision 1.16  2004/03/23 08:20:23  sasavranic
 * Uveo novi parametar IsPlNS() za spec.korisnika Planika Novi Sad
 *
 * Revision 1.15  2003/12/29 12:12:06  sasavranic
 * Dodata varijanta Fakultet
 *
 * Revision 1.14  2003/11/28 14:06:03  sasavranic
 * Korekcije kod-a opresa - stampa
 *
 * Revision 1.13  2003/08/21 07:01:55  mirsad
 * uveo IsNiagara()
 *
 * Revision 1.12  2003/05/09 14:35:48  mirsad
 * Uveden novi parametar koji ukljucuje sifrarnik shema kontiranja LD->FIN
 *
 * Revision 1.11  2003/03/12 09:14:34  mirsad
 * uveden Tvin
 *
 * Revision 1.10  2003/01/08 03:16:46  mirsad
 * ubacen RNAL.DBF za rama glas i varijanta rama glas
 *
 * Revision 1.9  2002/12/23 15:15:36  sasa
 * no message
 *
 * Revision 1.8  2002/07/18 07:24:43  mirsad
 * uveden IsJerry() za specificnosti za Jerry Trade
 *
 * Revision 1.7  2002/07/05 14:08:46  sasa
 * uvedene funkcije IsUgovori(), IsStampa(), IsKonsig()
 *
 * Revision 1.6  2002/07/04 14:10:41  sasa
 * uvedeni nove f-je: IsRudnik(), Setrudnik()
 *
 * Revision 1.5  2002/07/04 09:07:35  sasa
 * uvedeni nove f-je: IsZips(), SetZips(), IsTrgom(), SetTrgom()
 *
 * Revision 1.4  2002/07/04 07:45:58  sasa
 * korekcija zaglavlja
 *
 * Revision 1.3  2002/06/25 09:34:24  ernad
 *
 *
 * /cl/sigma/fmk/svi/specif.prg ... generacija integralne dokumentacije sa posebnim osvrtom na specif Parametre
 *
 * Revision 1.2  2002/06/20 16:52:06  ernad
 *
 *
 * ciscenje planika, uvedeno fmk/svi/specif.prg
 *
 * Revision 1.1  2002/06/20 16:30:29  ernad
 * init
 *
 *
 */

/*! \defgroup Planika Specificne nadogradnje za korisnika Planika
 *  @{
 *  @}
 */

/*! \defgroup Vindija  Specificne nadogradnje za korisnika Vindija
 *  @{
 *  @}
 */
 
/*! \defgroup Tvin Specificne nadogradnje za korisnika Tvin
 *  @{
 *  @}
 */

 /*! \defgroup Niagara Specificne nadogradnje za korisnika Niagara
 *  @{
 *  @}
 */

/*! \defgroup Tigra  Specificne nadogradnje za korisnika Tigra
 *  @{
 *  @}
 */

 
/*! \defgroup Merkomerc  Specificne nadogradnje za korisnika Merkomerc
 *  @{
 *  @}
 */

 
/*! \defgroup RamaGlas  Specificne nadogradnje za korisnika RamaGlas
 *  @{
 *  @}
 */

 
/*! \defgroup LdFin  Specificnost - kontiranje obracuna LD
 *  @{
 *  @}
 */

 
/*! \defgroup Rudnik  Specificne nadogradnje za korisnika Rudnik
 *  @{
 *  @}
 */

  
/*! \defgroup SigmaCom Specificne nadogradnje za korisnika SigmaCom
 *  @{
 *  @}
 */

  
/*! \defgroup Jerry  Specificne nadogradnje za korisnika Jerry Trade
 *  @{
 *  @}
 */


/*! \var lTvin
 *  \ingroup Tvin
 *  \sa IsTvin
 */
*bool
static lTvin
*;

/*! \var lNiagara
 *  \ingroup Niagara
 *  \sa IsNiagara
 */
*bool
static lNiagara
*;

/*! \var lPlanika
 *  \ingroup Planika
 *  \sa IsPlanika
 */
*bool
static lPlanika
*;

/*! \var lPlNS
 *  \ingroup Planika Novi Sad
 *  \sa IsPlNS
 */
*bool
static lPlNS
*;

/*! \var lTigra
 *  \ingroup Tigra
 *  \sa IsTigra
 */
*bool
static lTigra
*;


/*! \var lSigmaCom
 *  \ingroup SigmaCom
 *  \sa IsSigmaCom
 */
*bool 
static lSigmaCom
*;


/*! \var lJerry
 *  \ingroup Jerry
 *  \sa IsJerry
 */
*bool 
static lJerry
*;


/*! \var lVindija
 *  \ingroup Vindija
 *  \sa IsVindija
 */
*bool
static lVindija
*;

/*! \var lRudnik
 *  \ingroup Rudnik
 *  \sa IsRudnik
 */
*bool
static lRudnik
*;

/*! \var lZips
 *  \ingroup Zips
 *  \sa IsZips
 */
*bool
static lZips
*;

/*! \var lTrgom
 *  \ingroup Trgomarket
 *  \sa IsTrgom
 */
*bool
static lTrgom
*;

/*! \var lKonsig
 *  \ingroup Konsignacija
 *  \sa IsKonsig
 */
*bool
static lKonsig
*;

/*! \var lStampa
 *  \ingroup Opresa magacin stampe
 *  \sa IsStampa
 */
*bool
static lStampa
*;

/*! \var lUgovori
 *  \ingroup Ugovori
 *  \sa IsUgovori
 */
*bool
static lUgovori
*;


/*! \var lRamaGlas
 *  \ingroup Specificnosti za Rama glas
 *  \sa IsRamaGlas
 */
*bool
static lRamaGlas
*;


/*! \var lLdFin
 *  \ingroup Specificnosti za ld->fin
 *  \sa IsLdFin
 */
*bool
static lLdFin
*;

/*! \var lMupZeDo
 *  \ingroup Specificnosti za mup ze-do
 *  \sa IsMupZeDo
 */
*bool
static lMupZeDo
*;

/*! \var lFakultet
 *  \ingroup Specificnosti za fakultet
 *  \sa IsFakultet
 */
*bool
static lFakultet
*;


/*! \var lDomZdr
 *  \ingroup Specificnosti za Dom zdravlja
 *  \sa IsDomZdr
 */
*bool
static lDomZdr
*;


/*! \var lRabati
 *  \ingroup Koristenje rabatnih skala
 *  \sa IsRabati
 */
*bool
static lRabati
*;


/*! \var lTehnoprom
 *  \ingroup Specificnosti za tehnoprom
 *  \sa IsTehnoprom
 */
*bool
static lTehnoprom
*;


*string IzFmkIni_KumPath_FMK_Planika;

/*! \ingroup Planika
 *  \var *string IzFmkIni_KumPath_FMK_Planika
 *  \param N - standardni korisnik
 *  \param D - korisnik za koga su implementirane specificne nadogradnje  "Planika"
 */
 
/*! \ingroup Planika
 *  \fn IsPlanika()
 *  \return True - Ako je ini parametar Planika podesen na "D", u suprotnom False 
 *  \sa IzFmkIni_KumPath_FMK_Planika
 */
function IsPlanika()
*{
return lPlanika
*}

function SetPlanika(lValue)
*{
lPlanika:=lValue
*}

/*! \ingroup Planika
 *  \fn IsPlNS()
 *  \return True - Ako je ini parametar PlNS podesen na "D", u suprotnom False 
 *  \sa IzFmkIni_KumPath_FMK_PlNS
 */
function IsPlNS()
*{
return lPlNS
*}

function SetPlNS(lValue)
*{
lPlNS:=lValue
*}


function IsVindija()
*{
return lVindija
*}

function SetVindija(lValue)
*{
lVindija:=lValue
*}

function IsZips()
*{
return lZips
*}

function SetZips(lValue)
*{
lZips:=lValue
*}

function IsTvin()
*{
return lTvin
*}

function SetTvin(lValue)
*{
lTvin:=lValue
*}


function IsNiagara()
*{
return lNiagara
*}

function SetNiagara(lValue)
*{
lNiagara:=lValue
*}


function IsTrgom()
*{
return lTrgom
*}

function SetTrgom(lValue)
*{
lTrgom:=lValue
*}

function IsRudnik()
*{
return lRudnik
*}

function SetRudnik(lValue)
*{
lRudnik:=lValue
*}

function IsKonsig()
*{
return lKonsig
*}

function SetKonsig(lValue)
*{
lKonsig:=lValue
*}

function IsStampa()
*{
return lStampa
*}

function SetStampa(lValue)
*{
lStampa:=lValue
*}

function IsUgovori()
*{
return lUgovori
*}

function SetUgovori(lValue)
*{
lUgovori:=lValue
*}

function IsRabati()
*{
return lRabati
*}

function SetRabati(lValue)
*{
lRabati:=lValue
*}


function IsRamaGlas()
*{
return lRamaGlas
*}

function IsLdFin()
*{
return lLdFin
*}

function SetRamaGlas(lValue)
*{
lRamaGlas:=lValue
*}


function SetLdFin(lValue)
*{
lLdFin:=lValue
*}



function IsJerry()
*{
return lJerry
*}

function SetJerry(lValue)
*{
lJerry:=lValue
*}


function IsMupZeDo()
*{
return lMupZeDo
*}

function SetMupZeDo(lValue)
*{
lMupZeDo:=lValue
*}


function IsFakultet()
*{
return lFakultet
*}

function SetFakultet(lValue)
*{
lFakultet:=lValue
*}


function IsTigra()
*{
return lTigra
*}

function SetTigra(lValue)
*{
lTigra:=lValue
*}


function IsDomZdr()
*{
return lDomZdr
*}

function SetDomZdr(lValue)
*{
lDomZdr:=lValue
*}


function IsTehnoprom()
*{
return lTehnoprom
*}

function SetTehnoprom(lValue)
*{
lTehnoprom:=lValue
*}


/*! \fn SetSpecifVars()
 *  \brief Setuje globalne varijable za specificne korisnike
 */
 
function SetSpecifVars()
*{
if IzFmkIni("FMK","Tvin","N",KUMPATH)=="D"
	SetTvin(.t.)
else
	SetTvin(.f.)
endif

if IzFmkIni("FMK","Niagara","N",KUMPATH)=="D"
	SetNiagara(.t.)
else
	SetNiagara(.f.)
endif

if IzFmkIni("FMK","Planika","N",KUMPATH)=="D"
	SetPlanika(.t.)
else
	SetPlanika(.f.)
endif

if IzFmkIni("FMK","DomZdr","N",KUMPATH)=="D"
	SetDomZdr(.t.)
else
	SetDomZdr(.f.)
endif

if IzFmkIni("FMK","Tehnoprom","N",KUMPATH)=="D"
	SetTehnoprom(.t.)
else
	SetTehnoprom(.f.)
endif

if IzFmkIni("FMK","PlNS","N",KUMPATH)=="D"
	SetPlNS(.t.)
else
	SetPlNS(.f.)
endif

if IzFmkIni("FMK","Vindija","N",KUMPATH)=="D"
	SetVindija(.t.)
else
	SetVindija(.f.)
endif

if IzFmkIni("FMK","Zips","N",KUMPATH)=="D"
	SetZips(.t.)
else
	SetZips(.f.)
endif

if IzFmkIni("FMK","Trgom","N",KUMPATH)=="D"
	SetTrgom(.t.)
else
	SetTrgom(.f.)
endif

if IzFmkIni("FMK","Rudnik","N",KUMPATH)=="D"
	SetRudnik(.t.)
else
	SetRudnik(.f.)
endif

if IzFmkIni("FMK","Konsignacija","N",KUMPATH)=="D"
	SetKonsig(.t.)
else
	SetKonsig(.f.)
endif

if IzFmkIni("FMK","Stampa","N",KUMPATH)=="D"
	SetStampa(.t.)
else
	SetStampa(.f.)
endif

if IzFmkIni("FMK","Ugovori","N",KUMPATH)=="D"
	SetUgovori(.t.)
else
	SetUgovori(.f.)
endif


if IzFmkIni("FMK","Jerry","N",KUMPATH)=="D"
	SetJerry(.t.)
else
	SetJerry(.f.)
endif


if IzFmkIni("FMK","Tigra","N",KUMPATH)=="D"
	SetTigra(.t.)
else
	SetTigra(.f.)
endif


if IzFmkIni("FMK","RamaGlas","N",KUMPATH)=="D"
	SetRamaGlas(.t.)
else
	SetRamaGlas(.f.)
endif


if IzFmkIni("FMK","LdFin","N",KUMPATH)=="D"
	SetLdFin(.t.)
else
	SetLdFin(.f.)
endif

if IzFmkIni("FMK","MUPZEDO","N",KUMPATH)=="D"
	SetMupZeDo(.t.)
else
	SetMupZeDo(.f.)
endif

if IzFmkIni("FMK","Fakultet","N",KUMPATH)=="D"
	SetFakultet(.t.)
else
	SetFakultet(.f.)
endif

if IzFmkIni("FMK","Rabati","N",KUMPATH)=="D"
	SetRabati(.t.)
else
	SetRabati(.f.)
endif


return
*}
