#include "sc.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */
 
function SifFmkSvi()
*{
private Opc:={}
private opcexe:={}

AADD(opc,"1. partneri                          ")
if (ImaPravoPristupa("FMK","SIF","PARTNOPEN"))
	AADD(opcexe, {|| P_Firma()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

if (goModul:oDataBase:cName <> "FIN")
	AADD(opc,"2. konta")
	if (ImaPravoPristupa("FMK","SIF","KONTOOPEN"))
		AADD(opcexe, {|| P_Konto() } )
	else
		AADD(opcexe, {|| MsgBeep(cZabrana)})
	endif
else
	AADD(opc, "2. ----------------- ")
	AADD(opcexe, {|| NotImp()})
endif

AADD(opc,"3. tipovi naloga")
if (ImaPravoPristupa("FMK","SIF","TIPNALOPEN"))
	AADD(opcexe, {|| P_VN() } )
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc,"4. tipovi dokumenata")
if (ImaPravoPristupa("FMK","SIF","TIPDOKOPEN"))
	AADD(opcexe, {|| P_TipDok() } )
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc,"5. valute")
if (ImaPravoPristupa("FMK","SIF","VALUTEOPEN"))
	AADD(opcexe, {|| P_Valuta() } )
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc,"6. radne jedinice")
if (ImaPravoPristupa("FMK","SIF","RJOPEN"))
	AADD(opcexe, {|| P_RJ() } )
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc,"7. opcine")
if (ImaPravoPristupa("FMK","SIF","OPCINEOPEN"))
	AADD(opcexe, {|| P_Ops() } )
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc,"8. banke")
if (ImaPravoPristupa("FMK","SIF","BANKEOPEN"))
	AADD(opcexe, {|| P_Banke() } )
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc,"9. sifk - karakteristike")  
if (ImaPravoPristupa("FMK","SIF","SIFKOPEN"))
	AADD(opcexe, {|| P_SifK() } )
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

if (IsRamaGlas() .or.  gModul=="FAKT".and. glRadNal )
	AADD(opc, "R. radni nalozi")  
	AADD(opcexe, {|| P_RNal() } )
endif

// lokalizacija
gLokal := ALLTRIM(gLokal)
if gLokal <> "0"
	AADD(opc, "L. lokalizacija")
	AADD(opcexe, {|| P_Lokal() } )
endif


CLOSE ALL
OFmkSvi()

private Izbor:=1
gMeniSif:=.t.
Menu_SC("ssvi")
gMeniSif:=.f.

CLOSERET
return
*}

function IsPdvObveznik(cIdPartner)
local cIdBroj

cIdBroj := IzSifK("PARTN", "REGB", cIdPartner, .f.)

if !EMPTY(cIdBroj)
  if LEN(ALLTRIM(cIdBroj)) == 12
     
     return .t.
  else
     return .f.
  endif
else
  return .f.
endif

function IsIno(cIdPartner, lShow)
// isti je algoritam za utvrdjivanje
// ino partnera bio dobavljac ili kupac
return IsInoDob(cIdPartner, lShow)


function IsInoDob(cIdPartner, lShow)
local cIdBroj

cIdBroj := IzSifK("PARTN", "REGB", cIdPartner, .f.)

if !EMPTY(cIdBroj)
  if LEN(ALLTRIM(cIdBroj)) < 12
     //MsgBeep("Partner " + cIdPartner + " ima iden broj " + cIdBroj + "##" +;
     //    "< 12, znaci ovo je ino partner")
     return .t.
  else
     return .f.
  endif
else
  return .f.
endif

// primjer: PdvParIIIF ( cIdPartner, 1.17, 1, 0)
//         ako je partner pdv obvezinik return 1.17
//         ako je no pdv return 1
//         ako je ino return 0
function PdvParIIIF(cIdPartner, nPdvObv, nNoPdv, nIno, nUndefined)
local cIdBroj

cIdBroj := IzSifK("PARTN", "REGB", cIdPartner, .f.)
cIdBroj := ALLTRIM(cIdBroj)

if !EMPTY(cIdBroj)
  if (LEN(cIdBroj) == 12)
  	return nPdvObv
  elseif (LEN(cIdBroj) == 13)
  	return nNoPdv
  else
  	return nIno
  endif
else
  return nUndefined
endif

// u ovo polje se stavlja clan zakona o pdv-u ako postoji 
// osnova za oslobadjanje
//
function PdvOslobadjanje(cIdPartner)
local cIdBroj
return cIdBroj := IzSifK("PARTN", "PDVO", cIdPartner, .f.)

// -------------------------------------------------------------------------
// profili 
// primjer: Profil partnera = "KUP,KMS"
//          KUP - kupac
//          DOB - dobavljac
//          KMS - komisionar
//          KMT - komintent u konsignacionoj prodaji
//          INO - ino partner
//          UIO - radi se o specificnom partneru - uprava za indirektno
//                oporezivanje
//          SPE - partner koji obavlja poslove spediciji kod uvoza robe
//          TRA - obavlja transport
//    
//  Napomena: partner moze biti i kupac i dobavljac - stavlja se KUP,DOB
//            znaci moze imati vise funkcija
//
//  profil partnera = SVI atributi koji odgovaraju ovom partneru
//  ------------------------------------------------------------------------
function IsProfil(cIdPartner, cProfId)
local cProfili
cProfili := IzSifK("PARTN", "PROF", cIdPartner, .f.)

if cProfId $ UPPER(cProfili)
	return .t.
else
	return .f.
endif

// -----------------------------------
// partner je komisionar
// -----------------------------------
function IsKomision(cIdPartner)

return IsProfil(cIdPartner, "KMS")

