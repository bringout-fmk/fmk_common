#include "fmk.ch"

// ------------------------------------------
// brisanje sifri koje se ne nalaze u prometu
// ------------------------------------------
function Mnu_BrisiSifre()
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

// --------------------------
// brise duple sifre
// --------------------------
function BrisiVisakSifri()
private nNextRobaRec
private nRobaRec
cIdRoba:=""
nBrojac:=0
nDeleted:=0
nAktivne:=0
cDB:=goModul:oDataBase:cName

_openDB()

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



static function _openDB()
O_ROBA
if (goModul:oDataBase:cName=="KALK")
	O_KALK
endif
if (goModul:oDataBase:cName=="FAKT")
	O_FAKT
endif
return



// ----------------------------------
// svedi na standardnu jedinicu mjere
// ( npr. KOM->LIT ili KOM->KG )
// ----------------------------------

function SJMJ(nKol,cIdRoba,cJMJ)
 LOCAL nVrati:=0, nArr:=SELECT(), aNaz:={}, cKar:="SJMJ", nKO:=1, n_Pos:=0
  SELECT SIFV; SET ORDER TO TAG "ID"
  HSEEK "ROBA    "+cKar+PADR(cIdRoba,15)
  DO WHILE !EOF().and.id+oznaka+idsif=="ROBA    "+cKar+PADR(cIdRoba,15)
    IF !EMPTY(naz)
      AADD( aNaz , naz )
    ENDIF
    SKIP 1
  ENDDO
  IF LEN(aNaz)>0
    // slijedi preracunavanje
    // ----------------------
    n_Pos := AT( "_" , aNaz[1] )
    cPom   := ALLTRIM( SUBSTR( aNaz[1] , n_Pos+1 ) )
    nKO    := &cPom
    nVrati := nKol*nKO
    cJMJ   := ALLTRIM( LEFT( aNaz[1] , n_Pos-1 ) )
  ELSE
    // valjda je ve† u osnovnoj JMJ
    // ----------------------------
    nVrati:=nKol
  ENDIF
  SELECT (nArr)
return nVrati





