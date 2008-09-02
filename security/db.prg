#include "sc.ch"

function CreSecurity(nArea)
*{

close all

cSecurPath:=goModul:oDatabase:cSigmaBD+SLASH+"security"+SLASH

if !DirExists(cSecurPath)
	DirMak2(cSecurPath)
endif

if gReadOnly
	return
endif

if (nArea==nil)
	nArea:=-1
endif



// USERS.DBF
aDbf:={}
AADD(aDbf,{"ID","N",3,0})  
AADD(aDbf,{"NAZ","C",15,0})  
AADD(aDbf,{"PSW","C",15,0})  
AADD(aDbf,{"FULLNAME","C",40,0})  
AADD(aDbf,{"IDGRUPA1","N",3,0})  
AADD(aDbf,{"IDGRUPA2","N",3,0})  
AADD(aDbf,{"IDGRUPA3","N",3,0})  

if (nArea==-1 .or. nArea==F_USERS)
	if !file((cSecurPath+"users.dbf"))
		DBCREATE2(cSecurPath+"users.dbf",aDbf)
	endif
	CREATE_INDEX("ID","STR(id,3)",cSecurPath+"users.dbf",.t.)
	CREATE_INDEX("NAZ","naz",cSecurPath+"users.dbf",.t.)
endif

O_USERS
if (users->(reccount2()<1))
	// kreiram default administratora
	select (F_USERS)
	append blank
	Scatter()
	_id:=0
	_naz:="ADMINISTRATOR"
	_fullname:="ADMINISTRATOR"
	_psw:=CRYPT(PADR("SIGMAFMK",15),"SIGMASE")
	_idgrupa1:=900
	Gather()
endif
USE



// GROUPS.DBF
aDbf:={}
AADD(aDbf,{"ID","N",3,0})  
AADD(aDbf,{"NAZ","C",15,0})  

if (nArea==-1 .or. nArea==F_GROUPS)
	if !file((cSecurPath+"groups.dbf"))
		DBCREATE2(cSecurPath+"groups.dbf",aDbf)
	endif
	CREATE_INDEX("ID","STR(id,3)",cSecurPath+"groups.dbf",.t.)
endif

O_GROUPS
if (groups->(reccount2()<1))
	// kreiram default grupu
	select (F_GROUPS)
	append blank
	Scatter()
	_id:=900
	_naz:="ADMINISTRATORI"
	Gather()
endif
USE



// RULES.DBF
aDbf:={}
AADD(aDbf,{"ID","N",3,0})  
AADD(aDbf,{"ID2","N",3,0})  
AADD(aDbf,{"OBJEKAT","C",10,0})  
AADD(aDbf,{"KOMPONENTA","C",15,0})  
AADD(aDbf,{"FUNKCIJA","C",30,0})  
AADD(aDbf,{"DOZVOLA","C",1,0})  
AADD(aDbf,{"LOG","C",1,0})  

if (nArea==-1 .or. nArea==F_RULES)
	if !file((cSecurPath+"rules.dbf"))
		DBCREATE2(cSecurPath+"rules.dbf",aDbf)
	endif
	CREATE_INDEX("ID2","STR(id2,3)",cSecurPath+"rules.dbf",.t.)
	CREATE_INDEX("1","objekat+komponenta+funkcija+STR(id,3)+STR(id2,3)",cSecurPath+"rules.dbf",.t.)
	CREATE_INDEX("2","objekat+komponenta+funkcija+STR(id2,3)+STR(id,3)",cSecurPath+"rules.dbf",.t.)
	CREATE_INDEX("ID","STR(id,3)+objekat",cSecurPath+"rules.dbf",.t.)
endif

O_RULES
if (rules->(reccount2()<1))
	// kreiram default pravilo
	select (F_RULES)
	append blank
	Scatter()
	_id:=900
	_objekat:="FMK"
	_dozvola:="D"
	_log:="D"
	Gather()
endif
USE

return
*}



function P_Users(cId,dx,dy)
*{
local i
local nArr
nArr:=SELECT()
private ImeKol
private Kol
ImeKol:={}
Kol:={}

O_GROUPS
O_USERS
select (nArr)

AADD(ImeKol, { PADR("Id",3), {|| id}, "id", {|| IncId(@wId),.f.}, {|| .t.} , , "999"  })
AADD(ImeKol, { PADR("Naziv",15), {|| naz}, "naz" })

if users->(FIELDPOS("fullname")) <> 0
	AADD(ImeKol, { PADR("Puni naziv",15), {||fullname}, "fullname" })
endif

AADD(ImeKol, { PADR("Lozinka",15), {|| psw}, "psw", {|| WhenPsw()}, {|| ValidPsw()} })
AADD(ImeKol, { PADR("1.grupa",7), {|| idGrupa1}, "idGrupa1", {|| .t.}, {|| P_Groups(@wIdGrupa1)} })
AADD(ImeKol, { PADR("2.grupa",7), {|| idGrupa2}, "idGrupa2", {|| .t.}, {|| EMPTY(wIdGrupa2) .or. P_Groups(@wIdGrupa2)} })
AADD(ImeKol, { PADR("3.grupa",7), {|| idGrupa3}, "idGrupa3", {|| .t.}, {|| EMPTY(wIdGrupa3) .or. P_Groups(@wIdGrupa3)} }) 

for i:=1 to LEN(ImeKol)	
	AADD(Kol,i)
next

return PostojiSifra(F_USERS,1,10,70,"Users - korisnici",@cId,dx,dy)
*}


function WhenPsw()
*{
if (!EMPTY(wpsw))
	wpsw:=CRYPT(wpsw,"SIGMASE")
endif
return .t.
*}


function ValidPsw()
*{
if (!EMPTY(wpsw))
	wpsw:=CRYPT(wpsw,"SIGMASE")
endif
return .t.
*}



function P_Groups(cId,dx,dy)
*{
local i
local nArr
nArr:=SELECT()
private ImeKol
private Kol
ImeKol:={}
Kol:={}

O_GROUPS
select (nArr)

AADD(ImeKol, { PADR("Id",3), {|| id}, "id", {|| IncId(@wId),.f.}, {|| .t.}, , "999" })
AADD(ImeKol, { PADR("Naziv",15), {|| naz}, "naz" })

for i:=1 to LEN(ImeKol)	
	AADD(Kol,i)
next

return PostojiSifra(F_GROUPS,1,10,70,"Groups - korisnicke grupe",@cId,dx,dy)
*}


function P_Rules(cId,dx,dy)
*{
local i
local nArr
nArr:=SELECT()
private ImeKol
private Kol
ImeKol:={}
Kol:={}
O_RULES

select (nArr)

AADD(ImeKol, { PADR("Id",3), {|| id}, "id" })
AADD(ImeKol, { PADR("Id2",3), {|| id2}, "id2" })
AADD(ImeKol, { PADR("Objekat",10), {|| objekat}, "objekat" })
AADD(ImeKol, { PADR("Komponenta",15), {|| komponenta}, "komponenta" })
AADD(ImeKol, { PADR("Funkcija",30), {|| funkcija}, "funkcija" })
AADD(ImeKol, { PADR("Dozvola(D/N)",12), {|| dozvola}, "dozvola", {|| .t.}, {|| wdozvola$"DN"} })
AADD(ImeKol, { PADR("Log(D/N)",8), {|| log}, "log", {|| .t.}, {|| wlog$"DN"} })

for i:=1 to LEN(ImeKol)	
	AADD(Kol,i)
next

return PostojiSifra(F_RULES,1,10,70,"Rules - pravila za definisanje korisnika i korisnickih grupa",@cId,dx,dy,{|Ch| RulesBlock(Ch)},,,,,{"ID"})
*}


/*! \fn IncID(wId)
 *  \brief Povecava vrijednost polja ID za 1
 */
static function IncID(wId)
*{
local nRet:=.t.
if ((Ch==K_CTRL_N) .or. (Ch==K_F4))
	if (LastKey()==K_ESC)
		return nRet:=.f.
	endif
	nRecNo:=RecNo()
	wId:=LastID(nRecNo)+1
	AEVAL(GetList,{|o| o:display()})
endif
return nRet
*}



/*! \fn LastID(nRecNo)
 *  \brief Vraca vrijednost polja ID tabele events.dbf ili bilo koje tabele koja ima polje ID (numericko)
 *  \param nRecNo - broj zapisa na koji se pointer treba vratiti poslije uzete vrijednosti
 */
static function LastID(nRecNo)
*{
go bottom
nLastID:=field->id
go nRecNo
return nLastID
*}


function AddSecgaSDBFs()
*{
AADD(gaSDBFs, {F_EVENTS,   "EVENTS",   P_SECPATH})
AADD(gaSDBFs, {F_EVENTLOG, "EVENTLOG", P_SECPATH})
AADD(gaSDBFs, {F_USERS,    "USERS",    P_SECPATH})
AADD(gaSDBFs, {F_GROUPS,   "GROUPS",   P_SECPATH})
AADD(gaSDBFs, {F_RULES,    "RULES",    P_SECPATH})
return
*}

function RulesBlock(Ch)
*{

if (Ch==K_ALT_M)
	Box(,7,70)
		cExistingGroup:=SPACE(3)
		cNewGroup:=SPACE(3)
		cSetLicenceTo:=SPACE(1)
		
		@ 1+m_x, 2+m_y SAY "Migrate data                          "
		@ 2+m_x, 2+m_y SAY "--------------------------------------"
		@ 3+m_x, 2+m_y SAY "From existing group:" GET cExistingGroup
		@ 4+m_x, 2+m_y SAY "To new group:" GET cNewGroup
		@ 5+m_x, 2+m_y SAY "Set licence for new group to "
		@ 6+m_x, 2+m_y SAY "(D or N or empty)            " GET cSetLicenceTo VALID cSetLicenceTo $ " DN"
		read
	BoxC()
	if LastKey()==K_ESC
		return DE_CONT
	endif
	MigrateRulesForGroup(cExistingGroup, cNewGroup, cSetLicenceTo)
	go top
	return DE_REFRESH
	
endif


return DE_CONT
*}



