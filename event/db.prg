#include "sc.ch"


/*! \fn CreEvents(nArea)
 *  \brief Kreiranje tabela bitnih za logiranje dogadjaja
 *  \param nArea - podrucje
 */
function CreEvents(nArea)
*{
close all

cPath:=goModul:oDataBase:cSigmaBD+SLASH+"security"+SLASH

if !DirExists(cPath)
	DirMak2(cPath)
endif

if gReadOnly
	return
endif

if (nArea==nil)
	nArea:=-1
endif

// EVENTS.DBF
aDbf:={}
AADD(aDbf,{"ID","N",4,0})  
AADD(aDbf,{"OBJEKAT","C",10,0})
AADD(aDbf,{"KOMPONENTA","C",15,0})
AADD(aDbf,{"FUNKCIJA","C",30,0})
AADD(aDbf,{"NAZ","C",15,0})
AADD(aDbf,{"BITNOST","N",1,0})
AADD(aDbf,{"LOGIRATI","C",1,0})
AADD(aDbf,{"SECURITY1","N",3,0})
AADD(aDbf,{"SECURITY2","N",3,0})
AADD(aDbf,{"SECURITY3","N",3,0})
AADD(aDbf,{"OPIS","C",40,0})

if (nArea==-1 .or. nArea==F_EVENTS)
	if !file((cPath+"events.dbf"))
		DBCREATE2(cPath+"events.dbf",aDbf)
	endif
	CREATE_INDEX("ID","id",cPath+"events.dbf",.t.)
	CREATE_INDEX("1","objekat+komponenta+funkcija",cPath+"events.dbf",.t.)
endif

// EVENTLOG.DBF
aDbf:={}
AADD(aDbf,{"ID","N",15,0})  
AADD(aDbf,{"USER","N",3,0})  
AADD(aDbf,{"DATUM","D",8,0})
AADD(aDbf,{"VRIJEME","C",5,0})
AADD(aDbf,{"OBJEKAT","C",10,0})
AADD(aDbf,{"KOMPONENTA","C",15,0})
AADD(aDbf,{"FUNKCIJA","C",30,0})
AADD(aDbf,{"SQL","M",10,0})
AADD(aDbf,{"N1","N",16,2})
AADD(aDbf,{"N2","N",16,2})
AADD(aDbf,{"COUNT1","N",7,0})
AADD(aDbf,{"COUNT2","N",7,0})
AADD(aDbf,{"C1","C",2,0})
AADD(aDbf,{"C2","C",4,0})
AADD(aDbf,{"C3","C",15,0})
AADD(aDbf,{"D1","D",8,0})
AADD(aDbf,{"D2","D",8,0})
AADD(aDbf,{"LOGIRATI","C",1,0})
AADD(aDbf,{"OPIS","C",60,0})

if (nArea==-1 .or. nArea==F_EVENTLOG)
	if !file((cPath+"eventlog.dbf"))
		DBCREATE2(cPath+"eventlog.dbf",aDbf)
	endif
	CREATE_INDEX("ID","id",cPath+"eventlog.dbf",.t.)
endif

return
*}



/*! \fn P_Events(cId,dx,dy)
 *  \brief Pregled sifrarnika dogadjaja
 */
function P_Events(cId,dx,dy)
*{
local nArr
private imekol
private kol
nArr:=SELECT()

O_EVENTS

select (nArr)

ImeKol:={{PadR("Id",4),{|| id},"id",{|| IncID(@wId),.f.},{||.t.},,"999"},;
         {PadR("Objekat",10),{|| objekat},"objekat"},;
         {PadR("Komponenta",15),{|| komponenta},"komponenta"},;
         {PadR("Funkcija",30),{|| funkcija},"funkcija"},;
         {PadR("Naziv",15),{|| naz},"naz"},;
         {PadR("Bitnost",7),{|| bitnost},"bitnost"},;
         {PadR("Logirati",8),{|| logirati},"logirati"},;
         {PadR("Security1",10),{|| security1},"security1",{||.t.},{|| P_Groups(@wSecurity1)}},;
         {PadR("Security2",10),{|| security2},"security2",{||.t.},{|| P_Groups(@wSecurity2)}},;
         {PadR("Security3",10),{|| security3},"security3",{||.t.},{|| P_Groups(@wSecurity3)}},;
         {PadR("Opis",40),{|| opis},"opis"}}
	
Kol:={1,2,3,4,5,6,7,8,9,10,11}

return PostojiSifra(F_EVENTS,1,10,60,"Events - dogadjaji koji se logiraju",@cId,dx,dy)
*}


/*! \fn IncID(wId)
 *  \brief Povecava vrijednost polja ID za 1
 */
static function IncID(wId)
*{
local nRet:=.t.
altd()
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

/*! \fn BrisiLogove(lAutomatic)
 *  \brief Brisanje logova iz tabele EVENTLOG
 *  \param lAutomatic - .t. brisi automatski, .f. nemoj brisati automatski
 */
function BrisiLogove(lAutomatic)
*{
if lAutomatic
	NotImp()
	return
endif

if !SigmaSif("BRISILOG")
	return
endif

O_EVENTS
O_EVENTLOG

cModul:=PADR(goModul:oDataBase:cName,10)
dDatumOd:=Date()
dDatumDo:=Date()
cDN:="N"

Box(,5,60)
	@ m_x+1,m_y+2 SAY "Modul (prazno-svi):" GET cModul 
	@ m_x+2,m_y+2 SAY "Period od:" GET dDatumOd 
	@ m_x+3,m_y+2 SAY "Period do:" GET dDatumDo 
	@ m_x+4,m_y+2 SAY "Pobrisati (D/N)?" GET cDN VALID cDN$"DN" PICT "@!" 
	read
BoxC()

if (LastKey()==K_ESC)
	return
endif

if cDN=="D"
	PobrisiLOG(dDatumOd,dDatumDo,cModul)
endif

return
*}


function PobrisiLOG(dDatOd,dDatDo,cModul)
*{
lAuto:=.f.
//prvo provjeri da li se radi o automatskom brisanju
if (dDatOd==nil .and. dDatDo==nil .and. cModul==nil)
	// period za koji cu obrisati sve logove (odnosi se na broj mjeseci unazad)
	// TODO ovu varijablu treba da procita iz FMK.INI/EXEPATH
	cPeriod:=3	
	lAuto:=.t.
endif

if !lAuto
	i:=0
	MsgO("Prolazim kroz EVENTLOG...")
	select eventlog
	go top
	do while !EOF()
		if ((field->datum)>=dDatOd .or. (field->datum)<=dDatDo)
			if EMPTY(cModul)
				DELETE
				++i
				skip
			else
				if ((field->objekat)==cModul)
					DELETE
					++i
					skip
				else
					skip
				endif
			endif
		endif
	enddo
	MsgC()
	if i>0
		MsgBeep("Pobrisao "+ALLTRIM(STR(i))+" zapisa !!!")
	else
		MsgBeep("Nisam pronasao nista !!!")
	endif
endif

return
*}



