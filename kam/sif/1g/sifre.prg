#include "\cl\sigma\fmk\kam\kam.ch"

function Sifre()
local Izb:=1
private opc[3]

opc[1]:="1. kamatne stope  "
opc[2]:="2. kamatne stope/2"
opc[3]:="3. partneri"


O_PARTN
O_KS
O_KS2
//O_TOKVAL

do while .t.

  h[1]:=""
  h[2]:=""
  Izb:=Menu("kmsf",opc,Izb,.f.)
     do case
        case Izb==0
           exit
        case Izb==1
           P_KS()
        case Izb==2
           P_KS2()
        case Izb==3
           P_Firma()
     endcase
enddo

closeret


*************************
function P_KS(cId,dx,dy)
PRIVATE ImeKol,Kol
ImeKol:={ { PADR("ID",3),   {|| id },     "id"   , {|| .t.}, {|| vpsifra(wid)}    },;
          { PADR("Tip",3), {|| padc(Tip,3)},  "Tip"   },;
          { PADR("DatOd",8), {|| Datod},    "datOd"     },;
          { PADR("DatDo",8), {|| DatDo},    "DatDo"     },;
          { PADR("Rev",6),     {|| StRev},     "StRev"      },;
          { PADR("Kam",6), {|| StKam},  "StKam"   },;
          { PADR("DENOM",15), {|| Den},  "Den"   },;
          { PADR("DUZ.",4), {|| Duz } ,  "Duz"   };
        }
Kol:={1,2,3,4,5,6,7,8}

//          { PADR("Naziv",10),  {|| naz},     "naz"      },;
return PostojiSifra(F_KS,1,10,60,"Lista kamatnih stopa",@cId,dx,dy)

*************************
function P_KS2(cId,dx,dy)
PRIVATE ImeKol,Kol
ImeKol:={ { PADR("ID",3),   {|| id },     "id"   , {|| .t.}, {|| vpsifra(wid)}    },;
          { PADR("Tip",3), {|| padc(Tip,3)},  "Tip"   },;
          { PADR("DatOd",8), {|| Datod},    "datOd"     },;
          { PADR("DatDo",8), {|| DatDo},    "DatDo"     },;
          { PADR("Rev",6),     {|| StRev},     "StRev"      },;
          { PADR("Kam",6), {|| StKam},  "StKam"   },;
          { PADR("DENOM",15), {|| Den},  "Den"   },;
          { PADR("DUZ.",4), {|| Duz } ,  "Duz"   };
        }
Kol:={1,2,3,4,5,6,7,8}

//          { PADR("Naziv",10),  {|| naz},     "naz"      },;
return PostojiSifra(F_KS2,1,10,60,"Lista kamatnih stopa/2",@cId,dx,dy)

**********************
**********************
function P_Konto(cId,dx,dy)
PRIVATE ImeKol,Kol
ImeKol:={ { PADR("ID",7),  {|| id },     "id"  , {|| .t.}, {|| vpsifra(wid)} },;
          { "Naziv",       {|| naz},     "naz"      };
        }
Kol:={1,2}
return PostojiSifra(F_KONTO,1,10,60,"Lista: Konta ",@cId,dx,dy)


*************************
*************************
function P_Firma(cId,dx,dy)
PRIVATE ImeKol,Kol
ImeKol:={ { PADR("ID",6),   {|| id },     "id"   , {|| .t.}, {|| vpsifra(wid)}    },;
          { PADR("Naziv",25),  {|| naz},     "naz"      },;
          { PADR("PTT",5),     {|| PTT},     "ptt"      },;
          { PADR("Mjesto",16), {|| MJESTO},  "mjesto"   },;
          { PADR("Adresa",24), {|| ADRESA},  "adresa"   },;
          { PADR("Ziro R ",22),{|| ZIROR},   "ziror"    };
        }
Kol:={1,2,3,4,5,6,7}


if partn->(fieldpos("DZIROR"))<>0
  AADD (ImeKol,{ padr("Dev ZR",22 ), {|| DZIROR}, "Dziror" })
  AADD(Kol,8)
endif

AADD(Imekol,{ PADR("Telefon",12),  {|| TELEFON}, "telefon"  } )

if partn->(fieldpos("FAX"))<>0
  AADD (ImeKol,{ padr("Fax",12 ), {|| fax}, "fax" })
  AADD(Kol,9)
endif
if partn->(fieldpos("MOBTEL"))<>0
  AADD (ImeKol,{ padr("MobTel",20 ), {|| mobtel}, "mobtel" })
  AADD(Kol,10)
endif
if partn->(fieldpos("ID2"))<>0
  AADD (ImeKol,{ padr("Id2",6 ), {|| id2}, "id2" })
  AADD(Kol,11)
endif
if partn->(fieldpos("IdOps"))<>0
  AADD (ImeKol,{ padr("Opstina",6 ), {|| idOps}, "idOps" })
  AADD(Kol,12)
endif

return PostojiSifra(F_PARTN,1,10,60,"Lista Partnera",@cId,dx,dy,,)

*****************************************
* zabranjuje dupli unos sifre
*****************************************
static function vpsifra(wid)
local nrec:=recno(),nRet
seek wid
if found() .and. Ch==K_CTRL_N
  Beep(3)
  nRet:=.f.
else
  nRet:=.t.
endif
go nrec
return nRet
