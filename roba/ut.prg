#include "sc.ch"


function Mnu_BrisiSifre()
*{
Box(,6,60)
	@ 1+m_x,2+m_y SAY "Brisanje artikala koji se ne nalaze u prometu"
	@ 2+m_x,2+m_y SAY "---------------------------------------------"
read

MsgBeep("Prije pokretanja ove opcije !!!OBAVEZNO!!!##napraviti arhivu podataka!")
if Pitanje(,"Sigurno zelite obrisati sifre (D/N) ?","N")=="D"
	if SigmaSif("BRSIF")
		BrisiVisakSifri()
	endif
endif

return
*}


function BrisiVisakSifri()
*{
private nNextRobaRec
private nRobaRec
cIdRoba:=""
nBrojac:=0
nDeleted:=0
nAktivne:=0
cDB:=goModul:oDataBase:cName

OpenDB()

select roba
set order to tag "ID"
go top

do while !EOF()
	nRobaRec:=RecNo()
	skip
	nNextRobaRec:=RecNo()
	skip -1
	cIdRoba:=field->id
	select &cDB
	set order to tag "7"
	hseek cIdRoba
	++nBrojac
	@ 4+m_x,2+m_y SAY "Skeniram: " + ALLTRIM(cIdRoba)
	if !Found()
		select roba
		go (nRobaRec)
		delete
		++nDeleted
		@ 5+m_x,2+m_y SAY "Trenutno pobrisano: " + STR(nDeleted)
		skip
		go (nNextRobaRec)
	else
		++nAktivne
		@ 6+m_x,2+m_y SAY "Ostalo aktivnih: " + STR(nAktivne)
		select roba
		skip
		go (nNextRobaRec)
		//loop
	endif
enddo

BoxC()

MsgBeep("Skenirano " + STR(nBrojac) + " zapisa##Obrisano " + STR(nDeleted) + " zapisa")
MsgBeep("Sada obavezno treba izvrsiti##pakovanje i reindex tabela !!!")
return
*}


function OpenDB()
*{
O_ROBA
if (goModul:oDataBase:cName=="KALK")
	O_KALK
endif
if (goModul:oDataBase:cName=="FAKT")
	O_FAKT
endif
return
*}

