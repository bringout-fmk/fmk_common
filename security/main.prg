#include "sc.ch"

// ------------------------------------------------------
// otvara login screen - prijavu korisnika
// ------------------------------------------------------
function LoginScreen()
local nPokusaj
local cIme
local cLozinka
local nKursor
nPokusaj:=0
cIme:=PADR(IzFmkIni("Security","LastUser","",PRIVPATH),15)
cLozinka:=SPACE(15)
private GetList:={}
Box("#PRIJAVA KORISNIKA",5,70)
	do while (.t.)
		
		++ nPokusaj
		
		if (nPokusaj > 4)
			MsgBeep("Odustanite molim Vas, nemate pravo pristupa!")
			clear screen
			quit
		endif
		
		nKursor := SETCURSOR(4)
		cLozinka := SPACE(15)
		
		@ m_x+2, m_y+2 SAY "IME    " GET cIme COLOR "N/BG" PICT "@!"
		@ m_x+4, m_y+2 SAY "LOZINKA" GET cLozinka COLOR "BG/BG" PICT "@!"
		READ
		
		if LASTKEY() == K_ESC
			clear screen
			quit
		endif
		
		if (PrijavaOK(cIme,cLozinka))
			goModul:oDatabase:setUser(users->naz)
			goModul:oDatabase:setPassword(users->psw)
			goModul:oDatabase:setGroup1(users->idGrupa1)
			goModul:oDatabase:setGroup2(users->idGrupa2)
			goModul:oDatabase:setGroup3(users->idGrupa3)
			UzmiIzIni(PRIVPATH+"fmk.ini","Security","LastUser",cIme,"WRITE")
			exit
		else
			MsgBeep("Nepostojeci korisnik!")
		endif
	enddo
BoxC()

SETCURSOR(nKursor)

return



function PrijavaOK(cIme,cLozinka)
*{
local lOK
lOK:=.f.
select (F_USERS)
if (!used())
	O_USERS
endif
set order to tag "NAZ"
seek cIme
if (found() .and. cLozinka==CRYPT(users->psw,"SIGMASE"))
	lOK:=.t.
endif
return lOK
*}



function ShowUser()
*{
local nArea
local aPos
nArea:=SELECT()
aPos:={ROW(),COL()}
select (F_GROUPS)
if (!used())
	O_GROUPS
endif
@ 1,50 SAY goModul:oDatabase:cUser+":"+Ocitaj(F_GROUPS,STR(goModul:oDatabase:nGroup1,3),"naz") COLOR "G/N"
select (nArea)
@ aPos[1], aPos[2] SAY ""
return
*}



function ImaPravoPristupa(cObjekat,cKomponenta,cFunkcija)
*{
local lMoze
local cUser
local nArea
local aGrupe
lMoze:=.f.
nArea:=SELECT()
if (gSecurity<>"D" .or. nArea==179)
	return .t.
endif
cUser:=goModul:oDatabase:cUser
aGrupe:={}
if (goModul:oDatabase:nGroup1<>nil)
	AADD(aGrupe, goModul:oDatabase:nGroup1)
endif
if (goModul:oDatabase:nGroup2<>nil)
	AADD(aGrupe, goModul:oDatabase:nGroup2)
endif
if (goModul:oDatabase:nGroup3<>nil)
	AADD(aGrupe, goModul:oDatabase:nGroup3)
endif
select (F_RULES)
if (!used())
	O_RULES
endif

cObjekat:=PADR(cObjekat, LEN(field->objekat))
cKomponenta:=PADR(cKomponenta, LEN(field->komponenta))
cFunkcija:=PADR(cFunkcija, LEN(field->funkcija))

set order to tag "1"
seek cObjekat+cKomponenta+cFunkcija+cUser
if (!found())
	set order to tag "2"
	seek cObjekat+cKomponenta+cFunkcija+cUser
	if (!found())
		// ako pravilo nije definisano za konkretnog usera gledamo grupe
		set order to tag "1"
		seek cObjekat+cKomponenta+cFunkcija
		if (!found())
			//ne postoji pravilo pa cemo ubaciti default vrijednost
			append blank
			Scatter()
			_id:=900
			_id2:=0
			_objekat:=cObjekat
			_komponenta:=cKomponenta
			_funkcija:=cFunkcija
			_dozvola:="D"
			_log:="D"
			Gather()
			if (UGrupiUsera(field->id,field->id2,aGrupe))
				lMoze:=(field->dozvola=="D")
			endif
		else
			do while (!eof() .and. field->objekat+field->komponenta+field->funkcija==cObjekat+cKomponenta+cFunkcija)
				if (UGrupiUsera(field->id,field->id2,aGrupe))
					lMoze:=(field->dozvola=="D")
				endif
				skip 1
			enddo
		endif
	else
		lMoze:=(field->dozvola=="D")
	endif
else
	lMoze:=(field->dozvola=="D")
endif
select (nArea)
return lMoze
*}


function UGrupiUsera(nId,nId2,aId)
*{
local lUGrupi
lUGrupi:=.f.
if (nId==0 .and. nId2==0)
	// default pravilo za sve grupe
	lUGrupi:=.t.
elseif (nId==0)
	// pravilo za pripadnost grupi nId2
	lUGrupi:=(ASCAN(aId, nId2)>0)
elseif (nId2==0)
	// pravilo za pripadnost grupi nId
	lUGrupi:=(ASCAN(aId, nId)>0)
else
	// pravilo za pripadnost dvjema grupama: nId i nId2
	lUGrupi:=(ASCAN(aId, nId)>0 .and. ASCAN(aId, nId2)>0)
endif
return lUGrupi
*}


function GetUserID()
cUser:=goModul:oDataBase:cUser
O_USERS
select users
set order to tag "NAZ"
seek cUser
return field->id


// vraca username usera iz sec.systema
function GetUserName( user_id )
local nTArea := SELECT()
local cUserName := ""
O_USERS
select users
set order to tag "ID"
seek STR(user_id, 3)
cUserName := ALLTRIM(field->naz)
select (nTArea)
return cUserName


// vraca full username usera iz sec.systema
function GetFullUserName( user_id )
local nTArea := SELECT()
local cUserName := ""
O_USERS
select users
set order to tag "ID"
seek STR(user_id, 3)
if users->(FIELDPOS("fullname")) <> 0
	cUserName := ALLTRIM(field->fullname)
else
	cUserName := ALLTRIM(field->naz)
endif
select (nTArea)
return cUserName


function FmkSecVer()
*{
return DBUILD
*}


/*! \fn MigrateRulesForGroup(cExistingGroup, cNewGroup, cSetLicenceTo)
 *  \brief Kopira pravila za novu grupu korisnika po uzoru na postojecu
 *  \param cExistingGroup - ID postojece grupe
 *  \param cNewGroup - ID nove grupe
 *  \param cSetLicenceTo - postavlja dozvolu na "D" ili "N" za sve stavke za novih pravila
 */
function MigrateRulesForGroup(cExistingGroup, cNewGroup, cSetLicenceTo)
*{
local aMigrate:={}

select rules
set order to tag "ID"
go top
seek cNewGroup

// Check if rules for new group allready exist
if Found()
	MsgBeep("Rules for group '" + cNewGroup + "' allready exists!")
	return
endif

go top
seek cExistingGroup

Box(,5,60)
	// Get data from rules (existing group)
	nBrojac:=0
	@ 1+m_x, 2+m_y SAY "Geting data from group '" + cExistingGroup + "'"
	do while !EOF()
		if (field->id<>VAL(cExistingGroup))
			skip
			loop
		endif
		AADD(aMigrate, {field->id, field->id2, field->objekat, field->komponenta, field->funkcija, field->dozvola, field->log})
		@ 2+m_x, 2+m_y SAY "Total cached: " + STR(++nBrojac)
		skip
	enddo
	
	//Check for shure
	if Pitanje(,"Are you shure?", "N")=="N"
		return
	endif
	
	// Insert data into rules for new group
	@ 1+m_x, 2+m_y SAY "Inserting data for group '" + cNewGroup + "'"
	nBrojac:=0
	for i:=1 to LEN(aMigrate)
		append blank
		replace id with VAL(cNewGroup)
		replace objekat with aMigrate[i, 3]
		replace komponenta with aMigrate[i, 4]
		replace funkcija with aMigrate[i, 5]
		// If cSetLicenceTo empty use the same value field->dozvola from existing group
		if EMPTY(cSetLicenceTo)
			replace dozvola with aMigrate[i, 6]
		else 
			replace dozvola with cSetLicenceTo 
		endif
		replace log with aMigrate[i, 7]
		@ 2+m_x, 2+m_y SAY "Total records added: " + STR(++nBrojac) 
	next
BoxC()

MsgBeep("Migrate " + STR(nBrojac) + " rules for group " + cNewGroup + "##Migrate operation completed successful!!!")

return
*}


