/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "sc.ch"

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



function OpenDB()
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



// ----------------------------------------------------------
// sredi sifru dobavljaca, poravnanje i popunjavanje
//   ako je sifra manja od LEN(5) popuni na LEN(8) sa "0"
// 
// cSifra - sifra dobavljaca
// nLen - na koliko provjeravati
// cFill - cime popuniti
// ----------------------------------------------------------
function fix_sifradob( cSifra, nLen, cFill )
local nTmpLen

if gArtCDX = "SIFRADOB"

  nTmpLen := LEN( roba->sifradob )

  // dodaj prefiks ako je ukucano manje od 5
  if LEN( ALLTRIM( cSifra ) ) < 5
	cSifra := PADR( PADL( ALLTRIM(cSifra), nLen, cFill ) , nTmpLen )
  endif
endif

return .t.



