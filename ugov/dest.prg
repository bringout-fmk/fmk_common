#include "sc.ch"

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
 ELSE 
   // nova destinacija
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

