#include "\cl\sigma\fmk\ld\ld.ch"


/*! \fn DlgZakljucenje()
 *  \brief Dijalog za zakljucavanje i otvaranje obracuna
 */
 
function DlgZakljucenje()
*{

O_OBRACUNI
O_RJ

select obracuni

cRadnaJedinica:="  "
nMjObr:=gMjesec
nGodObr:=gGodina
cOdgovor:="N"
cStatus:="U"

Box(,9,40)
	@ m_x+1,m_y+2 SAY "Radna jedinica:" GET cRadnaJedinica valid P_Rj(@cRadnaJedinica) PICT "@!"
      	@ m_x+2,m_y+2 SAY "Mjesec        :" GET nMjObr PICT "99"
      	@ m_x+3,m_y+2 SAY "Godina        :" GET nGodObr PICT "9999"
       	@ m_x+4,m_y+2 SAY "--------------------------------------"
       	@ m_x+5,m_y+2 SAY "Opcije: "
	@ m_x+6,m_y+2 SAY "  - otvori (U)"
	@ m_x+7,m_y+2 SAY "  - zakljuci (Z)" GET cStatus VALID cStatus$"UZ" PICT "@!"
	@ m_x+8,m_y+2 SAY "--------------------------------------"
	@ m_x+9,m_y+2 SAY "Snimiti promjene (D/N)?" GET cOdgovor VALID cOdgovor$"DN" PICT"@!"
	read

	if (cOdgovor=="D")
		if (cStatus=="Z")
			if (!ImaPravoPristupa(goModul:oDatabase:cName,"DOK","ZAKLJUCIOBR"))
				MsgBeep("Vi nemate pravo na zakljucenje obracuna!")
			else
				ZakljuciObr(cRadnaJedinica,nGodObr,nMjObr,"Z")
			endif
		elseif (cStatus=="U") 
			if (ProsliObrOtvoren(cRadnaJedinica,nGodObr,nMjObr))
				MsgBeep("Morate prvo zakljuciti obracun za prethodni mjesec!")
			else
				OtvoriObr(cRadnaJedinica,nGodObr,nMjObr,"U")
			endif
		endif
	endif
BoxC()

return
*}



/*! \fn OtvoriObr(cRj,nGodina,nMjesec,cStatus)
 *  \brief Otvara obracun ili ga ponovo otvara zavisno od statusa
 *  \param cRJ - radna jedinica
 *  \param nGodina - godina
 *  \param nMjesec - mjesec
 *  \param cStatus - status: "U" otvori novi, "P" ponovo otvori
 */
 
function OtvoriObr(cRj,nGodina,nMjesec,cStatus)
*{

if Logirati("LD","DOK","OTVORIOBR")
	lLogOtvoriObracun:=.t.
else
	lLogOtvoriObracun:=.f.
endif

select obracuni
hseek cRj+ALLTRIM(STR(nGodina))+FmtMjesec(nMjesec)

if !Found()
	AddStatusObr(cRj,nGodina,nMjesec,"U")
	if lLogOtvoriObracun
		EventLog(nUser,goModul:oDataBase:cName,"DOK","OTVORIOBR",0,0,0,0,cRJ,STR(nMjesec,2),STR(nGodina,4),Date(),Date(),"","Otvoren novi obracun")
	endif
	MsgBeep("Obracun otvoren !!!")
	IspisiStatusObracuna(cRj,nGodina,nMjesec)
	return
endif

if JelZakljucen(cRj,nGodina,nMjesec)
	if (!ImaPravoPristupa(goModul:oDatabase:cName,"DOK","OTVORIOBR-P"))
		MsgBeep("Vi nemate pravo na ponovno otvaranje zakljucenog obracuna!")
		return
	endif
	if Pitanje(,"Obracun zakljucen, otvoriti ponovo","N")=="D"
		hseek cRj+ALLTRIM(STR(nGodina))+FmtMjesec(nMjesec)
		ChStatusObr(cRJ,nGodina,nMjesec,"P")
		if lLogOtvoriObracun
			EventLog(nUser,goModul:oDataBase:cName,"DOK","OTVORIOBR",0,0,0,0,cRJ,STR(nMjesec,2),STR(nGodina,4),Date(),Date(),"","Ponovo otvoren obracun")
		endif
		MsgBeep("Obracun ponovo otvoren !!!")
		IspisiStatusObracuna(cRJ,nGodina,nMjesec)
		return
	else
		MsgBeep("Obracun nije otvoren !!!")
		return
	endif
endif

return
*}


/*! \fn ZakljuciObr(cRj,nGodina,nMjesec,cStatus)
 *  \brief Zakljucuje obracun ili ga ponovo zakljucuje zavisno od statusa
 *  \param cRJ - radna jedinica
 *  \param nGodina - godina
 *  \param nMjesec - mjesec
 *  \param cStatus - status: "Z" zakljuci, "X" ponovo zakljuci
 */

function ZakljuciObr(cRJ,nGodina,nMjesec,cStatus)
*{
if Logirati("LD","DOK","ZAKLJUCIOBR")
	lLogZakljObracun:=.t.
else
	lLogZakljObracun:=.f.
endif

select obracuni
hseek cRj+ALLTRIM(STR(nGodina))+FmtMjesec(nMjesec)

if !Found()
	MsgBeep("Potrebno prvo otvoriti obracun !!!")
	return
endif

if field->status=="U"
	ChStatusObr(cRj,nGodina,nMjesec,"Z")
	if lLogZakljObracun
		EventLog(nUser,goModul:oDataBase:cName,"DOK","ZAKLJUCIOBR",0,0,0,0,cRj,STR(nMjesec,2),STR(nGodina,4),Date(),Date(),"","Obracun zakljucen")
	endif
	MsgBeep("Obracun zakljucen !!!")
	IspisiStatusObracuna(cRj,nGodina,nMjesec)
	return
endif

if JelOtvoren(cRj,nGodina,nMjesec)
	ChStatusObr(cRJ,nGodina,nMjesec,"X")
	if lLogZakljObracun
		EventLog(nUser,goModul:oDataBase:cName,"DOK","ZAKLJUCIOBR",0,0,0,0,cRJ,STR(nMjesec,2),STR(nGodina,4),Date(),Date(),"","Ponovo zakljucen obracun")
	endif
	MsgBeep("Obracun ponovo zakljucen !!!")
	IspisiStatusObracuna(cRj,nGodina,nMjesec)
	return
endif

return
*}


/*! \fn JelZakljucen(cRJ,nGodina,nMjesec)
 *  \brief Provjerava da li je obracun vec zakljucen
 *  \param cRJ - radna jedinica
 *  \param nGodina - godina
 *  \param nMjesec - mjesec
 */
function JelZakljucen(cRJ,nGodina,nMjesec)
*{
select obracuni
hseek (cRJ+ALLTRIM(STR(nGodina))+FmtMjesec(nMjesec))
if (Found() .and. field->status=="X" .or. Found() .and. field->status=="Z")
	return .t.
else
	return .f.
endif
*}


/*! \fn JelOtvoren(cRJ,nGodina,nMjesec)
 *  \brief Provjerava da li je obracun vec otvoren
 *  \param cRJ - radna jedinica
 *  \param nGodina - godina
 *  \param nMjesec - mjesec
 */
function JelOtvoren(cRJ,nGodina,nMjesec)
*{
select obracuni
hseek cRJ+ALLTRIM(STR(nGodina))+FmtMjesec(nMjesec)
if (Found() .and. field->status=="P" .or. Found() .and. field->status=="U")
	return .t.
else
	return .f.
endif
*}


/*! \fn AddStatusObr(cRJ,nGodina,nMjesec,cStatus)
 *  \brief Upisuje novi zapis u tabelu OBRACUNI ako ga nije nasao za cRJ+nGodina+nMjesec+cStatus
 *  \param cRJ - radna jedinica
 *  \param nGodina - godina
 *  \param nMjesec - mjesec
 *  \param cStatus - status koji se provjerava
 */
function AddStatusObr(cRJ,nGodina,nMjesec,cStatus)
*{
select obracuni
append blank
replace rj with cRJ
replace godina with nGodina
replace mjesec with nMjesec
replace status with cStatus
return
*}



/*! \fn ChStatusObr(cRJ,nGodina,nMjesec,cStatus)
 *  \brief Mjenja zapis u tabelu OBRACUNI za cRJ+nGodina+nMjesec+cStatus
 *  \param cRJ - radna jedinica
 *  \param nGodina - godina
 *  \param nMjesec - mjesec
 *  \param cStatus - status koji se provjerava
 */
function ChStatusObr(cRJ,nGodina,nMjesec,cStatus)
*{
select obracuni
Scatter()
_rj:=cRJ
_godina:=nGodina
_mjesec:=nMjesec
_status:=cStatus
Gather()
return
*}


/*! \fn FmtMjesec(nMjesec)
 *  \brief Format prikaza mjeseca
 *  \param nMjesec - mjesec
 */
function FmtMjesec(nMjesec)
*{
if nMjesec<10
	cMj:=" "+ALLTRIM(STR(nMjesec))
else
	cMj:=ALLTRIM(STR(nMjesec))
endif
return cMj
*}


/*! \fn GetObrStatus(cRJ,nGodina,nMjesec)
 *  \brief Provjerava status obracuna, ako uopste ne postoji vraca "N" inace vraca pravi status
 *  \param cRJ - radna jedinica
 *  \param nGodina - godina
 *  \param nMjesec - mjesec
 */
function GetObrStatus(cRj,nGodina,nMjesec)
*{
local nArr

nArr:=SELECT()

if gZastitaObracuna<>"D"
	return ""
endif

O_OBRACUNI
select obracuni
set order to tag "RJ"
altd()
hseek cRj+ALLTRIM(STR(nGodina))+FmtMjesec(nMjesec)

if !Found()
	cStatus:="N"
else
	cStatus:=field->status
endif

select (nArr)

return cStatus
*}


/*! \fn ProsliObrOtvoren(cRj,nGodObr,nMjObr)
 *  \brief Provjerava da li je obracun za mjesec unazad otvoren
 *  \param cRJ - radna jedinica
 *  \param nGodObr - godina
 *  \param nMjObr - mjesec
 */
function ProsliObrOtvoren(cRJ,nGodObr,nMjObr)
*{
local lOtvoren
if (nMjObr==1)
	lOtvoren:=JelOtvoren(cRJ,nGodObr-1,12)
else
	lOtvoren:=JelOtvoren(cRJ,nGodObr,nMjObr-1)
endif
return (lOtvoren)
*}


