#include "..\FMK.CH"

PROCEDURE SifUgovori
private Opc:={}
private opcexe:={}

AADD(Opc, "1. ugovori")
AADD(opcexe, {|| P_Ugov()})
AADD(Opc, "2. parametri ugovora")
AADD(opcexe, {|| DFTParUg()})
private Izbor:=1

Menu_SC("mugo")
CLOSERET


function P_UGOV(cId,dx,dy)

local i
PRIVATE DFTkolicina:=1, DFTidroba:=PADR("ZIPS",10)
PRIVATE DFTvrsta  :="1", DFTidtipdok :="20", DFTdindem   :="KM "
PRIVATE DFTidtxt  :="10", DFTzaokr    :=2, DFTiddodtxt :="  "

IF "U" $ TYPE("glDistrib") .or. !VALTYPE(glDistrib)=="L"; glDistrib:=.f.; ENDIF

DFTParUg(.t.)


Private ImeKol:={}
Private Kol:={}
AADD (ImeKol,{ "Ugovor" , {|| id}       ,"id"       , {|| .t.},  {|| vpsifra(wid) }  } )
AADD (ImeKol,{ "Partner", {|| IdPartner},"Idpartner", {|| .t.},{|| P_Firma(@wIdPartner)}      } )
IF RUGOV->(FIELDPOS("DESTIN"))<>0
  AADD (ImeKol,{ "Naziv partnera", {|| Ocitaj(F_PARTN,IdPartner,"NazPartn()") }, ""   } )
ENDIF

if IzFMkIni('Fakt_Ugovori',"Opis",'D')=="D"
  AADD (ImeKol,{ "Opis"   , {|| naz},      "Naz"                                       } )
endif
if IzFMkIni('Fakt_Ugovori',"Datumi",'D')=="D"
  // datumi bitni za obracun
  AADD (ImeKol,{ "DatumOd", {|| DatOd},    "DatOd"                                     } )
  AADD (ImeKol,{ "DatumDo", {|| DatDo},    "DatDo"                                     } )
endif
AADD (ImeKol,{ "Aktivan", {|| Aktivan},  "Aktivan" , {|| .t.}, {|| wAKtivan $ "DN"}   } )
AADD (ImeKol,{ "TipDok" , {|| IdTipdok}, "IdTipDok"                                  } )
if IzFMkIni('Fakt_Ugovori',"Vrsta",'D')=="D"
 AADD (ImeKol,{ "Vrsta"  , {|| Vrsta},    "Vrsta"                                     } )
endif
if IzFMkIni('Fakt_Ugovori',"TXT",'D')=="D"
 AADD (ImeKol,{ "TXT"    , {|| IdTxt},    "IdTxt" , {|| .t.} , {|| P_FTxt(@wIdTxt) }   } )
endif
if IzFMkIni('Fakt_Ugovori',"DINDEM",'D')=="D"
  AADD (ImeKol,{ "DINDEM" , {|| DINDEM},    "DINDEM"                                   } )
endif
if IzFMkIni('Fakt_Ugovori',"Zaokruzenja",'D')=="D"
  AADD (ImeKol,{ "ZAOKR"  , {|| ZAOKR},    "ZAOKR"                                   } )
endif
if ugov->(fieldpos("IDDODTXT"))<>0
  AADD (ImeKol,{ "DodatniTXT", {|| IdDodTxt}, "IdDodTxt", {|| .t.}, {|| P_FTxt(@wIdDodTxt) } } )
endif
if glDistrib
  AADD (ImeKol,{ "Rok pl.", {|| rokpl},    "rokpl"    } )
endif

if ugov->(fieldpos("A1"))<>0
  if IzFMkIni('Fakt_Ugovori',"A1",'D')=="D"
    AADD (ImeKol,{ "A1", {|| A1},    "A1"    } )
  endif
  if IzFMkIni('Fakt_Ugovori',"A2",'D')=="D"
    AADD (ImeKol,{ "A2", {|| A2},    "A2"    } )
  endif
  if IzFMkIni('Fakt_Ugovori',"B1",'D')=="D"
    AADD (ImeKol,{ "B1", {|| B1},    "B1"    } )
  endif
  if IzFMkIni('Fakt_Ugovori',"B2",'D')=="D"
    AADD (ImeKol,{ "B2", {|| B2},    "B2"    } )
  endif
endif

Kol:={}
FOR i:=1 TO LEN(ImeKol); AADD(Kol,i); NEXT

Private gTBDir:="N"
IF IzFMkIni('Fakt_Ugovori',"Trznica",'N')=="D"
  return PostojiSifra(F_UGOV,"NAZ2",10,77,"Lista Ugovora <F5> - definisi ugovorÍÍÍÍ<F6> - izvjestaj/lista za K1='G'",@cId,dx,dy,{|Ch| UgovBlok(Ch)})
ELSEIF gVFU=="1"
  return PostojiSifra(F_UGOV,"ID",10,77,"Lista Ugovora <F5> - definisi ugovorÍÍÍÍ<F6> - izvjestaj/lista za K1='G'",@cId,dx,dy,{|Ch| UgovBlok(Ch)})
ELSE
  return PostojiSifra(F_UGOV,IF(cID==NIL,"ID","NAZ2"),10,77,"Lista Ugovora <F5> - definisi ugovorÍÍÍÍ<F6> - izvjestaj/lista za K1='G'",@cId,dx,dy,{|Ch| UgovBlok(Ch)})
ENDIF


function UgovBlok(Ch)

local GetList:={}, nRec:=0

@ m_x+11,30 SAY "<c+G> - generisanje novih ugovora"

if Ch==K_CTRL_T
 if Pitanje(,"Izbrisati ugovor sa pripadajucim stavkama ?","N")=="D"
    cId:=id
    select rugov
    seek cid
    do while !eof() .and. cid==id
       skip; nTrec:=recno(); skip -1
       delete
       go nTrec
    enddo
    select ugov
    delete

    return 7  // prekini zavrsi i refresh

 endif

  // automatsko generisanje ugovora za sve partnere
  // sa podacima predhodnog
elseif Ch==K_CTRL_G
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

     if lastkey()==K_ESC; return DE_CONT; endif

     if cDN=="D"
      set relation to id into ugov
     endif

     do while !eof()
       skip; nTrec:=recno(); skip -1
        if cDN=="D" .and. ugov->aktivan=="D" .and. cArtikalOld==idroba .or.;
           cDN=="N" .and. cArtikalOld==idroba
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


elseif Ch==K_F2 .or. Ch==K_CTRL_N
 if Ch==K_F2 .and. Pitanje(,"Promjena broja ugovora ?","N")=="D"
     cIdOld:=id
     cId:=Id
     Box(,2,50)
      @ m_x+1, m_y+2 SAY "Broj ugovora" GET cID  valid !empty(cid) .and. cid<>cidold
      read
     BoxC()
     if lastkey()==K_ESC; return DE_CONT; endif
     select rugov
     seek cidOld
     do while !eof() .and. cidold==id
       skip; nTrec:=recno(); skip -1
       replace id with cid
       go nTrec
     enddo
     select ugov
     replace id with cid
 endif

 IF Ch==K_CTRL_N
   nRec:=RECNO()
   GO BOTTOM
   SKIP 1
 ENDIF
 Scatter()
 IF Ch==K_CTRL_N
   _datod:=DATE()
   _datdo:=CTOD("31.12.2059")
   _aktivan:="D"
   _dindem   := DFTdindem
   _idtipdok := DFTidtipdok
   _zaokr    := DFTzaokr
   _vrsta    := DFTvrsta
   _idtxt    := DFTidtxt
   _iddodtxt := DFTiddodtxt
 ENDIF
     Box(,15,75,.f.)
       @ m_x+ 1,m_y+2 SAY "Ugovor            " GET _ID        PICT "@!"
       @ m_x+ 2,m_y+2 SAY "Partner           " GET _IDPARTNER VALID {|| x:=P_Firma(@_IdPartner), MSAY2(m_x+2,m_y+35,Ocitaj(F_PARTN,_IdPartner,"NazPartn()")) ,x } PICT "@!"
       @ m_x+ 3,m_y+2 SAY "Opis ugovora      " GET _naz       PICT "@!"
   if IzFMkIni('Fakt_Ugovori',"Datumi",'D')=="D"
       @ m_x+ 4,m_y+2 SAY "Datum ugovora     " GET _datod
       @ m_x+ 5,m_y+2 SAY "Datum kraja ugov. " GET _datdo
   endif
       
       @ m_x+ 6,m_y+2 SAY "Aktivan (D/N)     " GET _aktivan VALID _aktivan $ "DN"  PICT "@!"
       if IzFMkIni('Fakt_Ugovori',"Tip",'D')=="D"
          @ m_x+ 7,m_y+2 SAY "Tip dokumenta     " GET _idtipdok PICT "@!"
       endif
       if IzFMkIni('Fakt_Ugovori',"Vrsta",'D')=="D"
          @ m_x+ 8,m_y+2 SAY "Vrsta             " GET _vrsta    PICT "@!"
       endif
       if IzFMkIni('Fakt_Ugovori',"TXT",'D')=="D"
           @ m_x+ 9,m_y+2 SAY "TXT na kraju dok. " GET _idtxt  VALID P_FTxt(@_IdTxt) PICT "@!"
       endif
       if IzFMkIni('Fakt_Ugovori',"DINDEM",'D')=="D"
          @ m_x+10,m_y+2 SAY "Valuta (KM/DEM)   " GET _dindem PICT "@!"
       endif

       if IzFMkIni('Fakt_Ugovori',"TXT2",'D')=="D"
        if ugov->(fieldpos("IDDODTXT"))<>0
         @ m_x+11,m_y+2 SAY "Dodatni txt       " GET _iddodtxt VALID P_FTxt(@_IdDodTxt) PICT "@!"
        endif
       endif
       if glDistrib
         @ m_x+11,m_y+30 SAY "Rok pl." GET _rokpl PICT "9999"
       endif
       if ugov->(fieldpos("A1"))<>0
        if IzFMkIni('Fakt_Ugovori',"A1",'D')=="D"
         @ m_x+12,m_y+2 SAY "A1                " GET _a1
        endif
        if IzFMkIni('Fakt_Ugovori',"A2",'D')=="D"
         @ m_x+13,m_y+2 SAY "A2                " GET _a2
        endif
        if IzFMkIni('Fakt_Ugovori',"B1",'D')=="D"
         @ m_x+14,m_y+2 SAY "B1                " GET _b1
        endif
        if IzFMkIni('Fakt_Ugovori',"B2",'D')=="D"
         @ m_x+15,m_y+2 SAY "B2                " GET _b2
        endif
       endif
       read
     BoxC()
     if Ch==K_CTRL_N .and. lastkey()<>K_ESC
        append blank
     endif
     if lastkey()<>K_ESC
       Gather()
     elseif Ch==K_CTRL_N
       GO (nRec)
     endif
 return 7

elseif Ch==K_F5
  // .and. !EMPTY(UGOV->id)
  IF RUGOV->(FIELDPOS("DESTIN"))<>0
    P_Ugov2()
    RETURN DE_REFRESH
  ELSE
    V_RUgov(ugov->id)
    return 6 // DE_CONT2
  ENDIF

elseif Ch==K_F6
  I_ListaUg()

elseif Ch==K_ALT_L
  Labelu()

else
  return DE_CONT

endif

return DE_CONT


function V_Rugov
parameters cID
*
* cId - idugovora

private GetList:={}
private ImeKol:={}
private Kol:={}

Box(,15,50)
select rugov
ImeKol:={}
AADD(ImeKol,{ "IDRoba",     {|| IdRoba}                          })
AADD(ImeKol,{ "Kolicina",   {|| Kolicina}                           })

if IzFMkIni('Fakt_Ugovori',"Rabat_Porez",'D')=="D"
 AADD(ImeKol,{ "Rabat",   {|| Rabat}                           })
 AADD(ImeKol,{ "Porez",   {|| Porez}                           })
endif


if rugov->(fieldpos("K1"))<>0
 if IzFMkIni('Fakt_Ugovori',"K1",'D')=="D"
  AADD (ImeKol,{ "K1",  {|| K1},    "K1"    } )
 endif
 if IzFMkIni('Fakt_Ugovori',"K2",'D')=="D"
  AADD (ImeKol,{ "K2",  {|| K2},    "K2"    } )
 endif

endif

IF RUGOV->(FIELDPOS("DESTIN"))<>0
  AADD (ImeKol,{ "DESTINACIJA",  {|| DESTIN},    "DESTIN"    } )
ENDIF
for i:=1 to len(ImeKol); AADD(Kol,i); next

set cursor on
@ m_x+1,m_y+1 SAY ""; ?? "Ugovor:",ugov->id,ugov->naz,ugov->DatOd
BrowseKey(m_x+3,m_y+1,m_x+14,m_y+50,ImeKol,{|Ch| EdRugov(Ch)},"id+brisano==cid+' '",cid,2,,,{|| .f.})

select ugov
BoxC()
return .t.


function EdRugov(Ch)
local  fK1:=.f., fDestin:=.f.

local nRet:=DE_CONT
do case
  case Ch==K_F2  .or. Ch==K_CTRL_N
     cIdRoba:=IdRoba
     nKolicina:=kolicina
     nRabat:=rabat
     nPorez:=porez
     IF RUGOV->(FIELDPOS("DESTIN"))<>0
       fDestin:=.t.
       cDestin:=DESTIN
     ENDIF
     if fieldpos("K1")<>0
       cK1:=k1
       cK2:=k2
       fK1:=.t.
     endif

     Box(,7,75,.f.)
       @ m_x+1,m_y+2 SAY "Roba       " GET cIdRoba   pict "@!" valid P_Roba(@cIDRoba)
       @ m_x+2,m_y+2 SAY "Kolicina   " GET nKolicina pict "99999999.999"

       if IzFMkIni('Fakt_Ugovori',"Rabat_Porez",'D')=="D"
         @ m_x+3,m_y+2 SAY "Rabat      " GET nRabat pict "99.999"
         @ m_x+4,m_y+2 SAY "Porez      " GET nPorez pict "99.99"
       endif

       if fk1
         if IzFMkIni('Fakt_Ugovori',"K1",'D')=="D"
           @ m_x+5,m_y+2 SAY "K1         " GET cK1 PICT "@!"
         endif
         if IzFMkIni('Fakt_Ugovori',"K2",'D')=="D"
           @ m_x+6,m_y+2 SAY "K2         " GET cK2 PICT "@!"
         endif
       endif
       if fDestin
        @ m_x+7,m_y+2 SAY "Destinacija" GET cDestin PICT "@!" VALID EMPTY(cDestin) .or. P_Destin(@cDestin)
       endif
       read
     BoxC()

     if Ch==K_CTRL_N .and. lastkey()<>K_ESC
       append blank
       replace id with cid
     endif
     if lastkey()<>K_ESC
       replace idroba with cidroba, kolicina with nKolicina, rabat with nrabat,;
               porez with nPorez
       if fk1
         replace k1 with ck1, k2 with ck2
       endif
       if fDestin
         REPLACE DESTIN WITH cDestin
       endif
     endif
     nRet:=DE_REFRESH
  case Ch==K_CTRL_T
     if Pitanje(,"Izbrisati stavku ?","N")=="D"
        delete
     endif
     nRet:=DE_DEL

endcase
return nRet


function P_Destin(cId,dx,dy)
 LOCAL GetList:={}
 PRIVATE ImeKol, Kol:={}, cLastOznaka:=" "
 private cIdTek:=UGOV->idpartner, nArr:=SELECT()
 SELECT DEST
 SET ORDER TO TAG "1"
 HSEEK cIdTek+cId
 IF FOUND()
   IF Pitanje(,"Izvrsiti ispravku destinacije "+cId+" ? (D/N)","N")=="D"
     EdDestBlok(K_F2,cId)
     CLEAR TYPEAHEAD
     SET TYPEAHEAD TO 0
     SET TYPEAHEAD TO 1024
     KEYBOARD CHR(K_UP)+CHR(K_DOWN)
     INKEY(0.5)
     READ
   ENDIF
   SELECT (nArr)
   RETURN .t.
 ELSE // nova destinacija
   GO BOTTOM; SKIP 1
   EdDestBlok(K_CTRL_N,cId)
   INKEY(0.5)
   CLEAR TYPEAHEAD
   SET TYPEAHEAD TO 0
   SET TYPEAHEAD TO 1024
   SELECT (nArr)
   KEYBOARD CHR(K_UP)+CHR(K_DOWN)
   INKEY(0.5)
   READ
   RETURN .t.
 ENDIF

 SET SCOPE TO cIdTek
 ImeKol:={ ;
          { "OZNAKA"  , {|| OZNAKA },  "OZNAKA"  },;
          { "NAZIV"   , {|| NAZ    },  "NAZ"     },;
          { "NAZIV2"  , {|| NAZ2   },  "NAZ2"    },;
          { "PTT"     , {|| PTT    },  "PTT"     },;
          { "MJESTO"  , {|| MJESTO },  "MJESTO"  },;
          { "ADRESA"  , {|| ADRESA },  "ADRESA"  },;
          { "TELEFON" , {|| TELEFON},  "TELEFON" },;
          { "FAX"     , {|| FAX    },  "FAX"     },;
          { "MOBTEL"  , {|| MOBTEL },  "MOBTEL"  };
         }
 for i:=1 to len(ImeKol); AADD(Kol,i); next
 private gTBDir:="N"
 PostojiSifra(F_DEST,"1",10,70,"Destinacije za:"+cIdTek+"-"+Ocitaj(F_PARTN,cIdTek,"naz"), , , , {|Ch| EdDestBlok(Ch)},,,,.f.)

 private gTBDir:="D"
 cId:=cLastOznaka
 set scope to
 select (nArr)
return .t.


function EdDestBlok(Ch,cDest)
local GetList:={}
local nRet:=DE_CONT
do case
  case Ch==K_F2  .or. Ch==K_CTRL_N

     sID       := cIdTek
     sOZNAKA   := IF(Ch==K_CTRL_N,cDest,OZNAKA)
     sNAZ      := IF(Ch==K_CTRL_N,Ocitaj(F_PARTN,cIdTek,"naz"),NAZ)
     sNAZ2     := IF(Ch==K_CTRL_N,Ocitaj(F_PARTN,cIdTek,"naz2"),NAZ2)
     sPTT      := PTT
     sMJESTO   := MJESTO
     sADRESA   := ADRESA
     sTELEFON  := TELEFON
     sFAX      := FAX
     sMOBTEL   := MOBTEL

     Box(, 11,75,.f.)
       @ m_x+ 2,m_y+2 SAY "Oznaka destinacije" GET sOZNAKA   PICT "@!"
       @ m_x+ 3,m_y+2 SAY "NAZIV             " GET sNAZ
       @ m_x+ 4,m_y+2 SAY "NAZIV2            " GET sNAZ2
       @ m_x+ 5,m_y+2 SAY "PTT broj          " GET sPTT      PICT "@!"
       @ m_x+ 6,m_y+2 SAY "Mjesto            " GET sMJESTO   PICT "@!"
       @ m_x+ 7,m_y+2 SAY "Adresa            " GET sADRESA   PICT "@!"
       @ m_x+ 8,m_y+2 SAY "Telefon           " GET sTELEFON  PICT "@!"
       @ m_x+ 9,m_y+2 SAY "Fax               " GET sFAX      PICT "@!"
       @ m_x+10,m_y+2 SAY "Mobitel           " GET sMOBTEL   PICT "@!"
       read
     BoxC()
     if Ch==K_CTRL_N .and. lastkey()<>K_ESC
        append blank
        replace id with sid
     endif
     if lastkey()<>K_ESC
       replace OZNAKA   WITH sOZNAKA  ,;
               NAZ      WITH sNAZ     ,;
               NAZ2     WITH sNAZ2    ,;
               PTT      WITH sPTT     ,;
               MJESTO   WITH sMJESTO  ,;
               ADRESA   WITH sADRESA  ,;
               TELEFON  WITH sTELEFON ,;
               FAX      WITH sFAX     ,;
               MOBTEL   WITH sMOBTEL
     endif
     nRet:=DE_REFRESH
  case Ch==K_CTRL_T
     if Pitanje(,"Izbrisati stavku ?","N")=="D"
        delete
     endif
     nRet:=DE_DEL
  case Ch==K_ESC .or. Ch==K_ENTER
     cLastOznaka:=DEST->OZNAKA

endcase
return nRet




PROCEDURE P_Ugov2(cIdPartner)
*  cidpartner - proslijediti partnera
*               iz sifrarnika partnera


private Imekol, Kol , lIzSifPArtn


altd()
if alias()="PARTN"
  lIzSifPartn:=.t.
else
  lIzSifPartn:=.f.
endif


SELECT (F_UGOV)

PRIVATE cIdUg:=ID

SELECT (F_RUGOV); SET ORDER TO TAG "ID"; SET FILTER TO
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
AADD (ImeKol,{ "DESTINACIJA",  {|| DESTIN},    "DESTIN"  , {|| .t.}, {|| EMPTY(wdestin).or.P_Destin(@wdestin)}, "V0"  } )
for i:=1 to len(ImeKol); AADD(Kol,i); next

Box(,20,72)
 @ m_x+19,m_y+1 SAY "<PgDn> sljedeci, <PgUp> prethodni ³<c-N> nova stavka          "
 @ m_x+20,m_y+1 SAY "<TAB>  podaci o ugovoru           ³<c-L> novi ugovor          "

 private  bGoreRed:=NIL
 private  bDoleRed:=NIL
 private  bDodajRed:=NIL
 private  fTBNoviRed:=.f. // trenutno smo u novom redu ?
 private  TBCanClose:=.t. // da li se moze zavrsiti unos podataka ?
 private  TBAppend:="N"  // mogu dodavati slogove
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
SELECT (F_RUGOV); SET FILTER TO
SELECT (F_UGOV)

RETURN



function EdUgov2()
*

local nRet:=-77, GetList:={}, nRec:=RECNO(), nArr:=SELECT()
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


    else  // vrti se iz liste ugovora
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
     @ m_x+2, m_y+2 SAY "SIFRA ARTIKLA:" GET _idroba VALID glDistrib.and.RIGHT(TRIM(_idroba),1)==";".or.P_Roba(@_idroba) PICT "@!"
     @ m_x+3, m_y+2 SAY "Kolicina      " GET _Kolicina pict "99999999.999"
     if IzFMkIni('Fakt_Ugovori',"Rabat_Porez",'D')=="D"
       @ m_x+4, m_y+2 SAY "Rabat         " GET _Rabat pict "99.999"
       @ m_x+5, m_y+2 SAY "Porez         " GET _Porez pict "99.99"
     endif

     IF FIELDPOS("K1")<>0
       if IzFMkIni('Fakt_Ugovori',"K1",'D')=="D"
          @ m_x+6, m_y+2 SAY "K1            " GET _K1 PICT "@!"
       endif
       if IzFMkIni('Fakt_Ugovori',"K2",'D')=="D"
         @ m_x+7, m_y+2 SAY "K2            " GET _K2 PICT "@!"
       endif
     ENDIF
     @ m_x+8, m_y+2 SAY "Destinacija   " GET _destin PICT "@!" VALID EMPTY(_destin).or.P_Destin(@_destin)
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


FUNCTION OsvjeziPrikUg(lWhen,lNew)

local cpom
LOCAL GetList:={}, nArr:=SELECT(), nRecUg:=0, nRecRug:=0, lRefresh:=.f.
LOCAL cEkran:=""

IF lNew==NIL; lNew:=.f.; ENDIF


  SELECT UGOV
  IF lNew
    cEkran:=SAVESCREEN( m_x+10, m_y+1, m_x+17, m_y+72)
    @ m_x+10, m_y+1 CLEAR TO m_x+17, m_y+72
    @ m_x+13, m_y+1 SAY PADC("N O V I    U G O V O R",72)
    nRecUg:=RECNO()
    GO BOTTOM; SKIP 1; Scatter("w")
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
    wid:=IF( EMPTY(id) , PADL("1",LEN(id),"0") ,;
                         PADR(NovaSifra(TRIM(id)),LEN(ID)) )
  ELSE
    Scatter("w")
  ENDIF


  cPom:= TempIni('Fakt_Ugovori_Novi','Partner','_NIL',"READ")
  if cPom <> "_NIL_"
    wIdPartner:=padr(cPom,6)
    cPom:= TempIni('Fakt_Ugovori_Novi','Partner','_NIL_',"WRITE")
  endif



  @ m_x+1, m_y+ 1 SAY "UGOVOR BROJ    :" GET wid WHEN lWhen VALID !lWhen .or. !EMPTY(wid) .and. VPSifra(wid)
  if IzFMkIni('Fakt_Ugovori',"Opis",'D')=="D"
     @ m_x+1, m_y+30 SAY "OPIS UGOVORA   :" GET wnaz WHEN lWhen
  endif

  @ m_x+2, m_y+ 1 SAY "PARTNER        :" GET widpartner WHEN lWhen VALID !lWhen .or. P_Firma(@widpartner).and.MSAY2(m_x+2,30,Ocitaj(F_PARTN,wIdPartner,"NazPartn()")) PICT "@!"

  if IzFMkIni('Fakt_Ugovori',"Datumi",'D')=="D"
   @ m_x+3, m_y+ 1 SAY "DATUM UGOVORA  :" GET wdatod WHEN lWhen
   @ m_x+3, m_y+30 SAY "DATUM PRESTANKA:" GET wdatdo WHEN lWhen
  endif

  if IzFMkIni('Fakt_Ugovori',"Vrsta",'D')=="D"
    @ m_x+4, m_y+ 1 SAY "VRSTA UGOV.(1/2/G):" GET wvrsta WHEN lWhen VALID !lWhen .or. wvrsta$"12G"
  endif
  if IzFMkIni('Fakt_Ugovori',"Tip",'D')=="D"
    @ m_x+4, m_y+30 SAY "TIP DOKUMENTA  :" GET widtipdok WHEN lWhen
  endif
  @ m_x+5, m_y+ 1 SAY "AKTIVAN (D/N)  :" GET waktivan WHEN lWhen VALID !lWhen .or. waktivan$"DN" PICT "@!"
  if IzFMkIni('Fakt_Ugovori',"DINDEM",'D')=="D"
    @ m_x+5, m_y+30 SAY "VALUTA (KM/DEM):" GET wdindem WHEN lWhen PICT "@!"
  endif
  if IzFMkIni('Fakt_Ugovori',"TXT",'D')=="D"
   @ m_x+6, m_y+ 1 SAY "TXT-NAPOMENA   :" GET widtxt WHEN lWhen
  endif
  if IzFMkIni('Fakt_Ugovori',"TXT2",'D')=="D"
    @ m_x+6, m_y+30 SAY "TXT-NAPOMENA2  :" GET widdodtxt WHEN lWhen
  endif
  if glDistrib
   @ m_x+7, m_y+ 1 SAY "Rok plac.(dana):" GET wrokpl WHEN lWhen PICT "9999"
  endif

  READ

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
        SKIP 1; nRecRug:=RECNO(); SKIP -1
        Scatter(); _id:=wid; Gather()
        GO (nRecRug)
      ENDDO
      cIdUg:=wid
      SET FILTER TO ID==cIdUg; GO TOP
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



PROCEDURE DFTParUg(lIni)
 LOCAL GetList:={}
  IF lIni==NIL; lIni:=.f.; ENDIF
  O_PARAMS
  private cSection:="2",cHistory:=" "; aHistory:={}

  IF !lIni
    private DFTkolicina:=1, DFTidroba:=PADR("ZIPS",10)
    private DFTvrsta    :="1", DFTidtipdok :="20", DFTdindem   :="KM "
    private DFTidtxt    :="10", DFTzaokr    :=2, DFTiddodtxt :="  "
  ENDIF

  RPar("01",@DFTkolicina)
  RPar("02",@DFTidroba)
  RPar("03",@DFTvrsta   )
  RPar("04",@DFTidtipdok)
  RPar("05",@DFTdindem  )
  RPar("06",@DFTidtxt   )
  RPar("07",@DFTzaokr   )
  RPar("08",@DFTiddodtxt)

  IF !lIni
    Box(,10,75)
     @ m_X+ 0,m_y+23 SAY "TEKUCI PODACI ZA NOVE UGOVORE"
     @ m_X+ 2,m_y+ 2 SAY "Artikal        " GET DFTidroba VALID EMPTY(DFTidroba) .or. P_Roba(@DFTidroba,2,28) PICT "@!"
     @ m_X+ 3,m_y+ 2 SAY "Kolicina       " GET DFTkolicina PICT pickol
     @ m_X+ 4,m_y+ 2 SAY "Tip ug.(1/2/G) " GET DFTvrsta    VALID DFTvrsta$"12G"
     @ m_X+ 5,m_y+ 2 SAY "Tip dokumenta  " GET DFTidtipdok
     @ m_X+ 6,m_y+ 2 SAY "Valuta (KM/DEM)" GET DFTdindem   PICT "@!"
     @ m_X+ 7,m_y+ 2 SAY "Napomena 1     " GET DFTidtxt    VALID P_FTXT(@DFTidtxt)
     @ m_X+ 8,m_y+ 2 SAY "Napomena 2     " GET DFTiddodtxt VALID P_FTXT(@DFTiddodtxt)
     @ m_X+ 9,m_y+ 2 SAY "Zaokruzenje    " GET DFTzaokr    PICT "9"
     READ
    BoxC()

    IF LASTKEY()!=K_ESC
      WPar("01",DFTkolicina)
      WPar("02",DFTidroba)
      WPar("03",DFTvrsta   )
      WPar("04",DFTidtipdok)
      WPar("05",DFTdindem  )
      WPar("06",DFTidtxt   )
      WPar("07",DFTzaokr   )
      WPar("08",DFTiddodtxt)
    ENDIF
  ENDIF
  USE
RETURN



FUNCTION NazPartn()
  LOCAL cVrati, cPom
  cPom:=UPPER(ALLTRIM(mjesto))
  IF cPom$UPPER(naz) .or. cPom$UPPER(naz2)
    cVrati:=TRIM(naz)+" "+TRIM(naz2)
  ELSE
    cVrati:=TRIM(naz)+" "+TRIM(naz2)+" "+TRIM(mjesto)
  ENDIF
RETURN PADR(cVrati,40)

FUNCTION MSAY2(x,y,c)
  @ x,y SAY c
RETURN .t.


PROCEDURE I_ListaUg()
 LOCAL nArr:=SELECT(), i:=0

 SELECT UGOV; PushWA()
 SET ORDER TO TAG "ID"
 SELECT RUGOV; PushWA()
 SET ORDER TO TAG "IDROBA"

 PRIVATE nRbr:=0, cSort:="1", gOstr:="D", lLin:=.t.
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
                {|| OdgovaraLi()},IF(gOstr=="D",,-1),,lLin,,,)

 END PRINT

 SELECT RUGOV; PopWA()
 SELECT UGOV; PopWA()
 SELECT (nArr)

RETURN


FUNCTION OdgovaraLi()
RETURN &(cFiltTrz)


FUNCTION ZaOdgovarajuci()
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



function IzfUgovor()
* za ZIPS - pogledaj ugovore za partnera

if IzFMkIni('FIN','VidiUgovor','N')=="D"
Pushwa()

select (F_UGOV)
if !used()
  O_UGOV
  O_RUGOV
  O_DEST
  O_ROBA
  O_TARIFA
endif

PRIVATE DFTkolicina:=1, DFTidroba:=PADR("ZIPS",10)
PRIVATE DFTvrsta  :="1", DFTidtipdok :="20", DFTdindem   :="KM "
PRIVATE DFTidtxt  :="10", DFTzaokr    :=2, DFTiddodtxt :="  "

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


select ugov; go top
if !eof() // postoji ugovor za partnera
select rugov
seek ugov->id
if !found() // izbrisane
  if Pitanje(,"Sve stavke ugovora su izbrisane, izbrisati ugovor u potputnosti ? ","D")=="D"
     select ugov
     delete
  endif
endif
endif

PopWa()

endif // iz fmk.ini

return .t.

