#include "\cl\sigma\fmk\ld\ld.ch"

function MnuObracun()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. unos                              ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"DOK","UNOS"))
	AADD(opcexe, {|| Unos()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "2. administracija obracuna           ")
AADD(opcexe, {|| MnuAdmObr()})

Menu_SC("obr")

return
*}



function MnuAdmObr()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc, "1. otvori / zakljuci obracun                     ")
if gZastitaObracuna=="D"
	AADD(opcexe, {|| DlgZakljucenje()})
else
	AADD(opcexe, {|| MsgBeep("Opcija nije dostupna !")})
endif

if lViseObr
	AADD(opc, "2. preuzmi podatke iz obracuna       ")
	if (ImaPravoPristupa(goModul:oDatabase:cName,"DOK","UZMIOBR"))
		AADD(opcexe, {|| UzmiObr()})
	else
		AADD(opcexe, {|| MsgBeep(cZabrana)})
	endif
else
	AADD(opc, "2. --------------------              ")
	AADD(opcexe, {|| nil})
endif

AADD(opc, "3. prenos obracuna u smece           ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"DOK","LDSMECE"))
	AADD(opcexe, {|| LdSmece()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "4. povrat obracuna iz smeca          ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"DOK","SMECELD"))
	AADD(opcexe, {|| SmeceLd()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "5. uklanjanje obracuna iz smeca      ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"DOK","BRISISMECE"))
	AADD(opcexe, {|| BrisiSmece()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "6. uzmi obracun iz ClipBoarda (sif0) ")
if (ImaPravoPristupa(goModul:oDatabase:cName,"DOK","OBRIZCLIP"))
	AADD(opcexe, {|| ObrIzClip()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc, "7. radnici obradjeni vise puta za isti mjesec")
AADD(opcexe, {|| VisePuta()})

Menu_SC("ao")

return
*}




