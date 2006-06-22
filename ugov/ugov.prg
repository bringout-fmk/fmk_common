#include "sc.ch"



// -----------------------------
// prikaz tabele ugovora
// -----------------------------
function P_Ugov(cId,dx,dy)
local i
local cHeader:=""
local cFieldId
private DFTkolicina:=1
private DFTidroba:=PADR("ZIPS",10)
private DFTvrsta:="1"
private DFTidtipdok:="20"
private DFTdindem:="KM "
private DFTidtxt:="10"
private DFTzaokr:=2
private DFTiddodtxt:=SPACE(2)
private gGenUgV2:="1"
private ImeKol
private Kol

cHeader += "Lista Ugovora " 
cHeader += "<F5> - definisi ugovor"
cHeader += "ÍÍÍÍ"
cHeader += "<F6> - izvjestaj/lista za K1='G'"

DFTParUg(.t.)

// setuj kolone tabele
set_a_kol(@ImeKol, @Kol)

// setuj polje pri otvaranju za sortiranje
set_fld_id(@cFieldId, cId)

private gTBDir:="N"

return PostojiSifra(F_UGOV, cFieldId, 10, 77, cHeader, @cId, dx, dy, {|Ch| key_handler(Ch)})


// ----------------------------------------------
// setovanje vrijednosti polja ID pri otvaranju
// ----------------------------------------------
static function set_fld_id(cVal, cId)
local lTrznica:=.f.

lTrznica := IzFmkIni("Fakt_Ugovori", "Trznica", "N") == "D"

cVal := "ID"

if lTrznica
	cVal := "NAZ2"
elseif ( gVFU == "1" )
	cVal := "ID"
elseif ( cId == nil )
	cVal := "ID"
else
	cVal := "NAZ2"
endif

return


// -----------------------------------------
// setovanje kolona prikaza
// -----------------------------------------
static function set_a_kol(aImeKol, aKol)
aImeKol := {}
aKol := {}

AADD(aImeKol, { "Ugovor", {|| id}, "id", {|| .t.}, {|| vpsifra(wid)}})
AADD(aImeKol, { "Partner",{|| IdPartner}, "Idpartner", {|| .t.}, {|| P_Firma(@wIdPartner)}})

// polje OPIS
if ( IzFmkIni("Fakt_Ugovori", "Opis", "D") == "D" )
	AADD(aImeKol, { "Opis", {|| naz}, "Naz" })
endif

// polje DATUM
if ( IzFmkIni("Fakt_Ugovori", "Datumi", "D") == "D" )
	// datumi bitni za obracun
  	AADD(aImeKol, { "DatumOd", {|| DatOd}, "DatOd" })
  	AADD(aImeKol, { "DatumDo", {|| DatDo}, "DatDo" })
endif

AADD(aImeKol, { "Aktivan", {|| Aktivan}, "Aktivan", {|| .t.}, {|| wAKtivan $ "DN"}})
AADD(aImeKol, { "TipDok", {|| IdTipdok}, "IdTipDok" })

// polje VRSTA
if ( IzFmkIni("Fakt_Ugovori", "Vrsta", "D") == "D" )
	AADD(aImeKol,{ "Vrsta", {|| Vrsta}, "Vrsta" })
endif

// polje TXT
if ( IzFmkIni("Fakt_Ugovori", "TXT", "D") == "D" )
	AADD(aImeKol,{ "TXT", {|| IdTxt}, "IdTxt", {|| .t.}, {|| P_FTxt(@wIdTxt)}})
endif

// polje DINDEM
if IzFMkIni('Fakt_Ugovori',"DINDEM",'D')=="D"
  AADD(aImeKol,{ "DINDEM" , {|| DINDEM},    "DINDEM"                                   } )
endif

// polje ZAOKRUZENJE
if IzFMkIni('Fakt_Ugovori',"Zaokruzenja",'D')=="D"
	AADD(aImeKol,{ "ZAOKR", {|| ZAOKR}, "ZAOKR"})
endif

// polje IDDODTXT
if ugov->(fieldpos("IDDODTXT")) <> 0
	AADD(aImeKol,{ "DodatniTXT", {|| IdDodTxt}, "IdDodTxt", {|| .t.}, {|| P_FTxt(@wIdDodTxt) } } )
endif

if ( ugov->(fieldpos("A1")) <> 0 )
	if IzFMkIni('Fakt_Ugovori',"A1",'D')=="D"
    		AADD(aImeKol,{ "A1", {|| A1}, "A1"})
  	endif
  	if IzFMkIni('Fakt_Ugovori',"A2",'D')=="D"
    		AADD(aImeKol,{ "A2", {|| A2}, "A2"})
  	endif
  	if IzFMkIni('Fakt_Ugovori',"B1",'D')=="D"
    		AADD(aImeKol,{ "B1", {|| B1}, "B1"})
  	endif
  	if IzFMkIni('Fakt_Ugovori',"B2",'D')=="D"
    		AADD(aImeKol,{ "B2", {|| B2}, "B2"})
  	endif
endif

for i:=1 TO LEN(aImeKol)
	AADD(aKol, i)
next

return


// --------------------------------
// key handler
// --------------------------------
static function key_handler(Ch)
local GetList:={}
local nRec:=0

@ m_x+11, 30 SAY "<c+G> - generisanje novih ugovora"

do case
	case ( Ch == K_CTRL_T )
		// brisi ugovor
		if br_ugovor() == 1
			return DE_REFRESH
		endif
		return DE_CONT
		
	case ( Ch == K_CTRL_G )
	   	
		// automatsko generisanje novih ugovora 
		// za sve partnere sa podacima
		// prethodnog ugovora
	   	gen_ug_part()
	    
	case (Ch == K_F2)
	
		// ispravka ugovora
		edit_ugovor(.f.)
		return 7
		
	case (Ch == K_CTRL_N)
		
		// novi ugovor
	   	edit_ugovor(.t.)
	  	return 7
	  
	case ( Ch == K_F5 )
    		
		V_RUgov(ugov->id)
 		return 6 
		// DE_CONT2

	case ( Ch == K_F6 )
  		I_ListaUg()

	case ( Ch == K_ALT_L )
  		Labelu()

endcase

return DE_CONT


// -----------------------------------------------------------
// generacija novog ugovora za partnera na osnovu prethodnog
// -----------------------------------------------------------
function gen_ug_part()
local cArtikal
local cArtikalOld
local cDN
local nTRec

if Pitanje(,'Generisanje ugovora za partnere (D/N)?','N')=='D'
	select rugov
     	cArtikal:=idroba
     	cArtikalOld:=idroba
     	cDN:="N"
	Box(,3,50)
      	@ m_x+1, m_y+5 SAY "Generisi ugovore za artikal: " GET cArtikal
      	@ m_x+2, m_y+5 SAY "Preuzmi podatke artikla: " GET cArtikalOld
      	@ m_x+3, m_y+5 SAY "Zamjenu vrsiti samo za aktivne D/N: " GET cDN valid cDN $ "DN"
      	read
     	BoxC()

     	if LastKey() == K_ESC
		return DE_CONT
	endif

	if cDN=="D"
      		set relation to id into ugov
     	endif

     	do while !eof()
       		skip
		nTrec:=recno()
		skip -1
        	if cDN=="D" .and. ugov->aktivan=="D" .and. cArtikalOld==idroba .or. cDN=="N" .and. cArtikalOld==idroba
        		Scatter()
        		append blank
        		_idroba := cArtikal
        		Gather()
        		@ m_x+1, m_y+2 SAY "Obuhvaceno: " + STR(nTrec)
        		go nTrec
        	else
        		go nTrec
        	endif
     	enddo
     	set relation to
     	select ugov
endif

return DE_CONT



// ------------------------------------
// brisanje ugovora 
// ------------------------------------
function br_ugovor()
local cId
local nTRec
if Pitanje(,"Izbrisati ugovor sa pripadajucim stavkama ?","N")=="D"
	cId:=id
    	select rugov
    	seek cid
    	do while !eof() .and. cId==id
       		skip
		nTrec := RecNo()
		skip -1
       		delete
       		go nTrec
    	enddo
    	select ugov
    	delete
	return 1
endif

return 0



// -----------------------------------
// promjena broja ugovora
// -----------------------------------
function edit_ugovor(lNovi)
local cIdOld
local cId
local nTRec

if !lNovi .and. Pitanje(,"Promjena broja ugovora ?","N")=="D"
	
	cIdOld:=id
	cId:=Id
     	Box(,2,50)
      	@ m_x+1, m_y+2 SAY "Broj ugovora" GET cID VALID !Empty(cId) .and. cId<>cIdOld
      	read
     	BoxC()
     	
	if Lastkey() == K_ESC
		return DE_CONT
	endif
     	
	select rugov
     	seek cIdOld
     	
	do while !eof() .and. ( cIdOld == id )
       		skip
		nTrec:=recno()
		skip -1
       		replace id with cid
       		go nTrec
     	enddo
     	select ugov
     	replace id with cid
endif

if lNovi
	nRec:=RECNO()
	GO BOTTOM
	SKIP 1
endif
 	    
Scatter()
 	    
if lNovi
	_datod:=DATE()
   	_datdo:=CTOD("31.12.2059")
   	_aktivan:="D"
   	_dindem:=DFTdindem
   	_idtipdok:=DFTidtipdok
   	_zaokr:=DFTzaokr
   	_vrsta:=DFTvrsta
   	_idtxt:=DFTidtxt
   	_iddodtxt:=DFTiddodtxt
endif

Box(,15,75,.f.)
@ m_x+ 1,m_y+2 SAY "Ugovor            " GET _ID        PICT "@!"
@ m_x+ 2,m_y+2 SAY "Partner           " GET _IDPARTNER VALID {|| x:=P_Firma(@_IdPartner), MSAY2(m_x+2,m_y+35,Ocitaj(F_PARTN,_IdPartner,"NazPartn()")) ,x } PICT "@!"
@ m_x+ 3,m_y+2 SAY "Opis ugovora      " GET _naz       PICT "@!"
@ m_x+ 4,m_y+2 SAY "Datum ugovora     " GET _datod
@ m_x+ 5,m_y+2 SAY "Datum kraja ugov. " GET _datdo
@ m_x+ 6,m_y+2 SAY "Aktivan (D/N)     " GET _aktivan VALID _aktivan $ "DN"  PICT "@!"
@ m_x+ 7,m_y+2 SAY "Tip dokumenta     " GET _idtipdok PICT "@!"
@ m_x+ 8,m_y+2 SAY "Vrsta             " GET _vrsta    PICT "@!"
@ m_x+ 9,m_y+2 SAY "TXT na kraju dok. " GET _idtxt  VALID P_FTxt(@_IdTxt) PICT "@!"
@ m_x+10,m_y+2 SAY "Valuta (KM/DEM)   " GET _dindem PICT "@!"
if ugov->(fieldpos("IDDODTXT"))<>0
	@ m_x+11,m_y+2 SAY "Dodatni txt       " GET _iddodtxt VALID P_FTxt(@_IdDodTxt) PICT "@!"
endif
if ugov->(fieldpos("A1"))<>0
	@ m_x+12,m_y+2 SAY "A1                " GET _a1
        @ m_x+13,m_y+2 SAY "A2                " GET _a2
        @ m_x+14,m_y+2 SAY "B1                " GET _b1
        @ m_x+15,m_y+2 SAY "B2                " GET _b2
endif
read
BoxC()

if LastKey() == K_ESC
	return DE_CONT
endif

if lNovi 
	append blank
endif

Gather()

if lNovi
	GO (nRec)
endif

return 7



// ----------------------------------------
// ----------------------------------------
function P_Ugov2(cIdPartner)
*  cidpartner - proslijediti partnera
*               iz sifrarnika partnera


private Imekol, Kol , lIzSifPArtn


if alias()="PARTN"
  lIzSifPartn:=.t.
else
  lIzSifPartn:=.f.
endif


SELECT (F_UGOV)

PRIVATE cIdUg:=ID

SELECT (F_RUGOV)
SET ORDER TO TAG "ID"
SET FILTER TO
SET FILTER TO ID=cIdUg
GO TOP

PRIVATE gTBDir:="D"
ImeKol:={}; Kol:={}
AADD(ImeKol,{ "IDRoba",   {|| IdRoba}  , "IDROBA"  , {|| .t.}, {|| glDistrib.and.RIGHT(TRIM(widroba),1)==";".or.P_Roba(@widroba)}, ">" })
AADD(ImeKol,{ "Kolicina", {|| Kolicina}, "KOLICINA", {|| .t.}, {|| .t.}, ">" })
if IzFMkIni('Fakt_Ugovori',"Rabat_Porez",'D')=="D"
  AADD(ImeKol,{ "Rabat",    {|| Rabat}   , "RABAT"   , {|| .t.}, {|| .t.}, ">" })
  AADD(ImeKol,{ "Porez",    {|| Porez}   , "POREZ"   , {|| .t.}, {|| .t.}, ">" })
endif

if rugov->(fieldpos("K1"))<>0
  if IzFMkIni('Fakt_Ugovori',"K2",'D')=="D"
    AADD (ImeKol,{ "K1",  {|| K1},    "K1"  , {|| .t.}, {|| .t.}, ">"  } )
  endif
  if IzFMkIni('Fakt_Ugovori',"K2",'D')=="D"
    AADD (ImeKol,{ "K2",  {|| K2},    "K2"  , {|| .t.}, {|| .t.}, ">"  } )
  endif
endif
//AADD (ImeKol,{ "DESTINACIJA",  {|| DESTIN},    "DESTIN"  , {|| .t.}, {|| EMPTY(wdestin).or.P_Destin(@wdestin)}, "V0"  } )

for i:=1 to len(ImeKol); AADD(Kol,i); next

Box(,20,72)
 @ m_x+19,m_y+1 SAY "<PgDn> sljedeci, <PgUp> prethodni ³<c-N> nova stavka          "
 @ m_x+20,m_y+1 SAY "<TAB>  podaci o ugovoru           ³<c-L> novi ugovor          "

 private  bGoreRed:=NIL
 private  bDoleRed:=NIL
 private  bDodajRed:=NIL
 
 // trenutno smo u novom redu ?
 private  fTBNoviRed:=.f. 
 // da li se moze zavrsiti unos podataka ?
 
 private  TBCanClose:=.t. 
 
 // mogu dodavati slogove
 private  TBAppend:="N"  
 
 private  bZaglavlje:=NIL
 
 // zaglavlje se edituje kada je kursor u prvoj koloni
 // prvog reda
 private  TBSkipBlock:={|nSkip| SkipDB(nSkip, @nTBLine)}
 private  nTBLine:=1      // tekuca linija-kod viselinijskog browsa
 private  nTBLastLine:=1  // broj linija kod viselinijskog browsa
 private  TBPomjerise:="" // ako je ">2" pomjeri se lijevo dva
                         // ovo se mo§e setovati u when/valid fjama

 private  TBScatter:="N"  // uzmi samo teku†e polje
 private lTrebaOsvUg:=.t.
 adImeKol:={}; for i:=1 TO LEN(ImeKol); AADD(adImeKol,ImeKol[i]); next
 adKol:={}; for i:=1 to len(adImeKol); AADD(adKol,i); next

 if cIdPartner<>NIL
   Ch:=K_CTRL_L
   TempIni('Fakt_Ugovori_Novi','Partner',cIdpartner,"WRITE")
   EdUgov2()
 else
   TempIni('Fakt_Ugovori_Novi','Partner','_NIL_',"WRITE")
   ObjDbedit("",20,72,{|| EdUgov2()},"","Stavke ugovora...", , , , ,2,6)
 endif

BoxC()
SELECT (F_RUGOV)
SET FILTER TO

SELECT (F_UGOV)

RETURN


// --------------------------------------------------
// --------------------------------------------------
function EdUgov2()

local nRet:=-77
local GetList:={}
local nRec:=RECNO()
local nArr:=SELECT()

do case
  case Ch==K_TAB
    OsvjeziPrikUg(.t.)

  case Ch==K_CTRL_L
    nRet:=OsvjeziPrikUg(.t.,.t.)
    IF nRet==DE_REFRESH
      cIdUg:=UGOV->ID
      SELECT (nArr); SET FILTER TO
      IF !EMPTY(DFTidroba)
        APPEND BLANK
        Scatter()
         _id:=cIdUg; _idroba:=DFTidroba; _kolicina:=DFTkolicina
        Gather()
      ENDIF
      SET FILTER TO ID==cIdUg; GO TOP
    ENDIF

  case Ch==K_PGDN
    if lIzSifPArtn
      do while .t.  .and. !eof()
       select partn; skip
       select ugov; set order to tag "PARTNER"; set filter to; seek partn->id
       if !found()
          select partn; loop
          // skaci do prvog sljedeceg ugovora
       else
          exit
       endif
       select partn
      enddo
      if eof()
        skip -1
      endif


    else  // vrti se iz liste ugovora
     SELECT UGOV; SKIP 1
     IF EOF(); SKIP -1; SELECT (nArr); RETURN (nRet); ENDIF
    endif

    cIdUg:=ID
    SELECT (nArr); SET FILTER TO; SET FILTER TO ID==cIdUg; GO TOP
    OsvjeziPrikUg(.f.)
    nRet:=DE_REFRESH

  case Ch==K_PGUP
    if lIzSifPArtn
      do while .t.  .and. !bof()
       select partn; skip -1
       select ugov; set order to tag "PARTNER"; set filter to; seek partn->id
       if !found()
          select partn; loop
          // skaci do prvog sljedeceg ugovora
       else
          exit
       endif
       select partn
      enddo
      if bof()
        skip
      endif


    else  
     // vrti se iz liste ugovora
     SELECT UGOV; SKIP -1
     IF BOF(); SELECT (nArr); RETURN (nRet); ENDIF
    endif
    cIdUg:=ID
    SELECT (nArr); SET FILTER TO; SET FILTER TO ID==cIdUg; GO TOP
    OsvjeziPrikUg(.f.)
    nRet:=DE_REFRESH

  case Ch==K_CTRL_N
    IF EMPTY(cIdUg)
      Msg("Prvo morate izabrati opciju <c-L> za novi ugovor!")
      RETURN DE_CONT
    ENDIF
    GO BOTTOM; SKIP 1
    Scatter()
    _id := cIdUg
    
    Box(,8,77)
     @ m_x+2, m_y+2 SAY "SIFRA ARTIKLA:" GET _idroba ;
        VALID (glDistrib .and. RIGHT(TRIM(_idroba),1)==";") .or. P_Roba(@_idroba) ;
	PICT "@!"
     @ m_x+3, m_y+2 SAY "Kolicina      " GET _Kolicina  ;
        pict "99999999.999"
     if IzFMkIni('Fakt_Ugovori',"Rabat_Porez",'D')=="D"
       @ m_x+4, m_y+2 SAY "Rabat         " GET _Rabat ;
             pict "99.999"
       @ m_x+5, m_y+2 SAY "Porez         " GET _Porez ;
             pict "99.99"
     endif

     IF FIELDPOS("K1")<>0
       if IzFMkIni('Fakt_Ugovori',"K1",'D')=="D"
          @ m_x+6, m_y+2 SAY "K1            " GET _K1 PICT "@!"
       endif
       if IzFMkIni('Fakt_Ugovori',"K2",'D')=="D"
         @ m_x+7, m_y+2 SAY "K2            " GET _K2 PICT "@!"
       endif
     ENDIF
     @ m_x+8, m_y+2 SAY "Destinacija   " GET _destin ;
          PICT "@!" VALID EMPTY(_destin) .or. P_Destin(@_destin)
     READ
    BoxC()

    IF LASTKEY()!=K_ESC
      APPEND BLANK
      Gather()
      lTrebaOsvUg:=.t.
    ELSE
      GO (nRec)
      RETURN DE_CONT
    ENDIF

    nRet:=DE_REFRESH

  case Ch==K_CTRL_T
     if Pitanje(,"Izbrisati stavku ?","N")=="D"
       DELETE
       lTrebaOsvUg:=.t.
       nRet:=DE_REFRESH
     else
       RETURN DE_CONT
     endif

endcase

IF lTrebaOsvUg
  OsvjeziPrikUg(.f.)
  lTrebaOsvUg:=.f.
ENDIF
IF nRet!=-77
  Ch:=0
ELSE
  nRet:=DE_CONT
ENDIF

return nRet


// ----------------------------------------
// osvjezavanje prikaza ugovora
// ----------------------------------------
function OsvjeziPrikUg(lWhen, lNew)
local cPom
local GetList:={}
local nArr:=SELECT()
local nRecUg:=0
local nRecRug:=0
local lRefresh:=.f.
local cEkran:=""

if lNew == nil
	lNew:=.f.
endif

SELECT UGOV

if lNew
    cEkran:=SAVESCREEN( m_x+10, m_y+1, m_x+17, m_y+72)
    @ m_x+10, m_y+1 CLEAR TO m_x+17, m_y+72
    @ m_x+13, m_y+1 SAY PADC("N O V I    U G O V O R",72)
    nRecUg:=RECNO()
    GO BOTTOM
    SKIP 1
    Scatter("w")
    waktivan:="D"
    wdatod:=DATE()
    wdatdo:=CTOD("31.12.2059")
    wdindem   := DFTdindem
    widtipdok := DFTidtipdok
    wzaokr    := DFTzaokr
    wvrsta    := DFTvrsta
    widtxt    := DFTidtxt
    widdodtxt := DFTiddodtxt

    SKIP -1
    
    if EMPTY(id)
    	wid := PADL("1", LEN(id), "0")
    else
    	wid := PADR(NovaSifra(TRIM(id)), LEN(ID))
    endif
    
else

    Scatter("w")

endif

cPom:= TempIni('Fakt_Ugovori_Novi','Partner','_NIL',"READ")
if cPom <> "_NIL_"
	wIdPartner:=padr(cPom,6)
    	cPom:= TempIni('Fakt_Ugovori_Novi','Partner','_NIL_',"WRITE")
endif

@ m_x+1, m_y+ 1 SAY "UGOVOR BROJ    :" GET wid WHEN lWhen VALID !lWhen .or. !EMPTY(wid) .and. VPSifra(wid)
@ m_x+1, m_y+30 SAY "OPIS UGOVORA   :" GET wnaz WHEN lWhen
@ m_x+2, m_y+ 1 SAY "PARTNER        :" GET widpartner ;
        WHEN lWhen ;
	VALID !lWhen .or. P_Firma(@widpartner) .and. MSAY2(m_x+2,30, Ocitaj(F_PARTN,wIdPartner,"NazPartn()")) PICT "@!"

@ m_x+3, m_y+ 1 SAY "DATUM UGOVORA  :" GET wdatod ;
         WHEN lWhen
@ m_x+3, m_y+30 SAY "DATUM PRESTANKA:" GET wdatdo ;
         WHEN lWhen
@ m_x+4, m_y+ 1 SAY "VRSTA UGOV.(1/2/G):" GET wvrsta ;
       WHEN lWhen ;
       VALID !lWhen .or. wvrsta$"12G"
@ m_x+4, m_y+30 SAY "TIP DOKUMENTA  :" GET widtipdok WHEN lWhen
@ m_x+5, m_y+ 1 SAY "AKTIVAN (D/N)  :" GET waktivan ;
         WHEN lWhen ;
	 VALID !lWhen .or. waktivan$ "DN" ;
	 PICT "@!"
@ m_x+5, m_y+30 SAY "VALUTA (KM/DEM):" GET wdindem ;
       WHEN lWhen ;
       PICT "@!"
@ m_x+6, m_y+ 1 SAY "TXT-NAPOMENA   :" GET widtxt ;
      WHEN lWhen
@ m_x+6, m_y+30 SAY "TXT-NAPOMENA2  :" GET widdodtxt ;
       WHEN lWhen

read

IF !lWhen
	@ m_x+2, m_y+24 SAY "---->("+Ocitaj(F_PARTN,wIdPartner,"NazPartn()")+")"
ENDIF

IF lNew .and. !LASTKEY()==K_ESC
	lRefresh:=.t.
    	APPEND BLANK
ELSEIF lNew
	GO (nRecUg)
ENDIF

IF lWhen .and. !LASTKEY()==K_ESC
	IF wid!=id
      		lRefresh:=.t.
      		SELECT RUGOV
      		SET FILTER TO
      		HSEEK UGOV->id
      		DO WHILE !EOF() .and. id==UGOV->id
        		SKIP 1
			nRecRug:=RECNO()
			SKIP -1
        		Scatter()
			_id:=wid
			Gather()
        		GO (nRecRug)
      		ENDDO
      		cIdUg:=wid
      		SET FILTER TO ID==cIdUg
		GO TOP
      		SELECT UGOV
    	ENDIF
    	Gather("w")
ENDIF

IF lWhen
	lTrebaOsvUg:=.t.
ENDIF

IF lNew
	RESTSCREEN( m_x+10, m_y+1, m_x+17, m_y+72, cEkran)
ENDIF

SELECT (nArr)
RETURN (IF(lRefresh,DE_REFRESH,DE_CONT))



// -----------------------------------
// -----------------------------------
function I_ListaUg()
local nArr:=SELECT()
local i:=0

SELECT UGOV
PushWA()
SET ORDER TO TAG "ID"
SELECT RUGOV
PushWA()
SET ORDER TO TAG "IDROBA"

PRIVATE nRbr:=0
private cSort:="1"
private gOstr:="D"
private lLin:=.t.
PRIVATE cUgovId  := ""
PRIVATE cUgovNaz := ""
PRIVATE cPartnNaz := ""
PRIVATE nRugovKol := 0

cFiltTrz := Parsiraj( IzFMkIni('Fakt_Ugovori',"ZakupljeniArtikli",'K--T;'), "ID")

aKol:={ { "R.br."         , {|| STR(nRbr,4)+"."   }, .f., "C", 5, 0, 1,++i },;
         { "Broj ugovora"  , {|| cUgovId           }, .f., 'C',12, 0, 1,++i },;
         { "Naziv objekta" , {|| ROBA->naz         }, .f., 'C',30, 0, 1,++i },;
         { "Naziv zakupca" , {|| cPARTNnaz         }, .f., 'C',30, 0, 1,++i },;
         { "m2 objekta"    , {|| nRUGOVkol         }, .f., 'N',15, 3, 1,++i },;
         { "Jedin.cijena"  , {|| ROBA->vpc         }, .f., 'N',15, 2, 1,++i },;
         { "Iznos"         , {|| nRUGOVkol*ROBA->vpc   },;
                                                      .t., 'N',15, 2, 1,++i } }

START PRINT CRET
 
SELECT ROBA
GO TOP

StampaTabele(aKol,{|| ZaOdgovarajuci()},,gTabela,,,;
                "PREGLED UGOVORA ZA "+cFiltTrz,;
                {|| OdgovaraLi()}, IIF( gOstr=="D",,-1),, lLin,,,)

END PRINT

SELECT RUGOV
PopWA()
SELECT UGOV
PopWA()

SELECT (nArr)

return


// ----------------------------------
// ----------------------------------
static function OdgovaraLi()
return &(cFiltTrz)


// --------------------------------------------
// --------------------------------------------
static function ZaOdgovarajuci()
++nRbr
SELECT RUGOV
HSEEK ROBA->id
IF FOUND()
    nRUGOVkol:=RUGOV->kolicina
    SELECT UGOV
     SEEK RUGOV->id
     IF FOUND()
       cUgovId   := UGOV->id
       cUgovNaz  := UGOV->naz
       SELECT PARTN
        SEEK UGOV->idpartner
       IF FOUND()
         cPartnNaz := PARTN->naz
       ELSE
         cPartnNaz := ""
       ENDIF
     ELSE
       MsgBeep("Greska! Stavka ugovora '"+RUGOV->ID+"' postoji, ugovor ne postoji?!")
       IF Pitanje(,"Brisati problematicnu stavku (u RUGOV.DBF) ? (D/N)","N")=="D"
         SELECT RUGOV; DELETE
       ENDIF
       cUgovId   := ""
       cUgovNaz  := ""
       cPartnNaz := ""
     ENDIF

ELSE
    cUgovId   := ""
    cUgovNaz  := ""
    cPartnNaz := ""
    nRugovKol := 0
ENDIF
SELECT ROBA

RETURN .t.


//----------------------------------------------
// pogledaj ugovore za partnera
//----------------------------------------------
function IzfUgovor()

if IzFMkIni('FIN','VidiUgovor','N')=="D"
Pushwa()

select (F_UGOV)
if !used()
  O_UGOV
endif

select (F_RUGOV)
if !used()
  O_RUGOV
endif

select (F_DEST)
if !used()
  O_DEST
endif

SELECT (F_ROBA)
if !used()
  O_ROBA
endif

SELECT (F_TARIFA)
if !used()
  O_TARIFA
endif

PRIVATE DFTkolicina:=1
private DFTidroba:=PADR("ZIPS",10)
PRIVATE DFTvrsta  :="1"
private DFTidtipdok :="20"
private DFTdindem :="KM "
PRIVATE DFTidtxt := "10"
private DFTzaokr:=2
private DFTiddodtxt :="  "

DFTParUg(.t.)

select ugov
private cFilter:="Idpartner=="+cm2str(partn->id)
set filter to &cFilter
go top
if eof()
  MsgBeep("Ne postoje definisani ugovori za korisnika")
  if pitanje(,"Zelite li definisati novi ugovor ?","N")=="D"
     set filter to
     P_UGov2(partn->id)

     select partn
     P_Ugov2()
  else
     PopWa()
     return .t.
  endif

else
    select partn
    P_Ugov2()
endif


select ugov
go top
// postoji ugovor za partnera
if !eof()
select rugov
seek ugov->id
if !found() 
  if Pitanje(,"Sve stavke ugovora su izbrisane, izbrisati ugovor u potputnosti ? ","D")=="D"
     select ugov
     delete
  endif
endif
endif

PopWa()

endif

return .t.



