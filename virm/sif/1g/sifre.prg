#include "\cl\sigma\fmk\virm\virm.ch"


function P_Firme(cId,dx,dy)
LOCAL vrati
PRIVATE ImeKol,Kol
ImeKol:={}
Kol:={}
AADD(ImeKol, { PADC("ID",6),      {|| id },     "id"   , {|| .t.}, {|| vpsifra(wid)}    } )
AADD(ImeKol, { PADC("Naziv",25),  {|| naz},     "naz"      } )
AADD(ImeKol, { PADC("PTT",5),     {|| PTT},     "ptt"      } )
AADD(ImeKol, { PADC("Mjesto",16), {|| MJESTO},  "mjesto"   } )
AADD(ImeKol, { PADC("Adresa",24), {|| ADRESA},  "adresa"   } )
AADD(ImeKol, { PADC("Telefon",12),{|| TELEFON}, "telefon"  } )

//AADD(ImeKol, { padc("Fax",12 ),   {|| fax},     "fax" }      )
//AADD(ImeKol, { padc("MobTel",20 ),{|| mobtel},  "mobtel" }   )

//AADD(ImeKol, { PADC("Ziro R ",22),{|| ZIROR},   "ziror"    } )
//AADD(ImeKol, { padc("Dev ZR",22 ),{|| DZIROR},  "Dziror"  }   )

for i:=1 to len(ImeKol); AADD(Kol,i) ; next

//if IzFmkIni("Svi","Sifk")="D"
PushWa()
select sifk; set order to tag "ID"; seek "PARTN"
do while !eof() .and. ID="PARTN"

 AADD (ImeKol, {  IzSifKNaz("PARTN",SIFK->Oznaka) })
 AADD (ImeKol[Len(ImeKol)], &( "{|| ToStr(IzSifk('PARTN','" + sifk->oznaka + "')) }" ) )
 AADD (ImeKol[Len(ImeKol)], "SIFK->"+SIFK->Oznaka )
 if sifk->edkolona > 0
   for ii:=4 to 9
    AADD( ImeKol[Len(ImeKol)], NIL  )
   next
   AADD( ImeKol[Len(ImeKol)], sifk->edkolona  )
 else
   for ii:=4 to 10
    AADD( ImeKol[Len(ImeKol)], NIL  )
   next
 endif

 // postavi picture za brojeve
 if sifk->Tip="N"
   if decimal > 0
     ImeKol [Len(ImeKol),7] := replicate("9", sifk->duzina - sifk->decimal-1 )+"."+replicate("9",sifk->decimal)
   else
     ImeKol [Len(ImeKol),7] := replicate("9", sifk->duzina )
   endif
 endif

 AADD  (Kol, iif( sifk->UBrowsu='1',++i, 0) )

 skip
enddo
PopWa()
//endif

// PushHT("2-1")
vrati:=PostojiSifra(F_PARTN,1,10,77,"Lista partnera:",@cId,dx,dy)
// PopHT()
return vrati


*****************************************
* sifrarnik vrsta primalaca za virmane
******************************************
function P_VrPrim(cId,dx,dy)
LOCAL vrati
PRIVATE ImeKol,Kol
ImeKol:={}
Kol:={}

AADD(Imekol, { "ID"     , {|| id }   , "id"    , {|| .t.}, {|| vpsifra(wid)} } )
AADD(Imekol, { "Opis"   , {|| NAZ              }, "NAZ"      } )
AADD(Imekol, { "Pomocni tekst"   , {|| POM_TXT          }, "POM_TXT"  } )
AADD(Imekol, { "Konto "    , {|| idkonto          }, "idkonto"  } )
AADD(Imekol, { "Partner "    , {|| idpartner         }, "idpartner"  } )
AADD(Imekol, { "Valuta ( ,1,2)"  , {|| PADC(NACIN_PL,14)}, "NACIN_PL" } )
AADD(Imekol, { "Racun"      , {|| RACUN           }, "RACUN"   } )
AADD(Imekol, { "Unos dobavlj (D/N)"   , {|| PADC(DOBAV,13)   }, "DOBAV"    } )

For i:=1 to len(ImeKol); AADD(Kol,i) ; next


// PushHT("2-1")
vrati:=PostojiSifra(F_VRPRIM,1,10,77,"Lista: Vrste primalaca:",@cId,dx,dy)
// PopHT()
return vrati

**************************
* sifrarnik vrsta primalaca za uplatnice
**************************
function P_VrPrim2(cId,dx,dy)
LOCAL vrati
PRIVATE ImeKol,Kol
ImeKol:={ { "ID"     , {|| id }   , "id"    , {|| .t.}, {|| vpsifra(wid)} },;
          { "Opis"            , {|| NAZ              }, "NAZ"      },;
          { "Pomocni tekst"   , {|| POM_TXT          }, "POM_TXT"  },;
          { "Konto "    , {|| idkonto          }, "idkonto"  },;
          { "Partner "    , {|| idpartner         }, "idpartner"  },;
          { "Valuta ( ,1,2)"  , {|| PADC(NACIN_PL,14)}, "NACIN_PL" },;
          { "Racun"      , {|| Racun          }, "Racun"   },;
          { "Unos dobavlj (D/N)"   , {|| PADC(DOBAV,13)   }, "DOBAV"    };
        }
Kol:={1,2,3,4,5,6,7,8}
// PushHT("2-1")
vrati:=PostojiSifra(F_VRPRIM2,1,10,77,"LISTA VRSTA PRIMALACA ZA UPLATNICE:",@cId,dx,dy)
// PopHT()
return vrati

**************************
**************************
function P_LDVIRM(cId,dx,dy)
LOCAL vrati
PRIVATE ImeKol,Kol
ImeKol:={ { "ID"     , {|| id }   , "id"    , {|| .t.}, {|| P_VRPRIM(@wId), wnaz:=vrprim->naz,.t. } },;
          { "Opis"   , {|| NAZ}, "NAZ"      },;
          { "FORMULA"   , {|| formula          }, "formula"  };
        }
Kol:={1,2,3}
// PushHT("2-1")
vrati:=PostojiSifra(F_LDVIRM,1,10,77,"LISTA LD->VIRM:",@cId,dx,dy)
// PopHT()
return vrati

**************************
**************************
function P_KALVIR(cId,dx,dy)
LOCAL vrati
PRIVATE ImeKol,Kol:={}
ImeKol:={ { "ID"     , {|| id }   , "id"    , {|| .t.}, {|| P_VRPRIM(@wId), wnaz:=vrprim->naz,.t. } },;
          { "Opis"   , {|| NAZ}, "NAZ"      },;
          { "FORMULA"   , {|| formula          }, "formula"  };
        }
if KALVIR->(fieldpos("pnabr"))<>0
  AADD (ImeKol,{ "Poz.na br.", {|| pnabr }, "pnabr" })
endif
FOR i:=1 TO LEN(ImeKol); AADD(Kol,i); NEXT
// PushHT("2-1")
vrati:=PostojiSifra(F_KALVIR,1,10,77,"LISTA KALK->VIRM:",@cId,dx,dy)
// PopHT()
return vrati

********************************************
* sifrarnik podataka za stampanje na virmanu
********************************************
function P_STAMP(cId,dx,dy)
LOCAL vrati
PRIVATE ImeKol,Kol
ImeKol:={ { PADC("Ime varijable",20), {|| id                }, "id"       },;
          { PADC("Opis",40)         , {|| naz               }, "naz"      },;
          { "V.koord.(mm)"    , {|| PADC(STR(v_pomak,6,2),12) }, "v_pomak"  },;
          { "H.koo.(znakova)" , {|| PADC(STR(h_pomak,6,2),15) }, "h_pomak"  },;
          { "Ravnanje(L/D/C)" , {|| PADC(ravnanje,15)       }, "ravnanje" },;
          { "Duzina(znakova)" , {|| PADC(STR(duzina,2),15)  }, "duzina"   },;
          { "Stampati(D/N)"   , {|| PADC(stampati,13)       }, "stampati" };
        }
Kol:={1,2,3,4,5,6,7}
// PushHT("2-1")
vrati:=PostojiSifra(F_STAMP,1,10,77,"LISTA PODATAKA ZA STAMPANJE - VIRMANI:",@cId,dx,dy)
// PopHT()
return vrati


********************************************
* sifrarnik podataka za stampanje na virmanu
********************************************
function P_STAMP2(cId,dx,dy)
LOCAL vrati
PRIVATE ImeKol,Kol
ImeKol:={ { PADC("Ime varijable",20), {|| id                }, "id"       },;
          { PADC("Opis",40)         , {|| naz               }, "naz"      },;
          { "V.koord.(mm)"    , {|| PADC(STR(v_pomak,6,2),12) }, "v_pomak"  },;
          { "H.koo.(znakova)" , {|| PADC(STR(h_pomak,6,2),15) }, "h_pomak"  },;
          { "Ravnanje(L/D/C)" , {|| PADC(ravnanje,15)       }, "ravnanje" },;
          { "Duzina(znakova)" , {|| PADC(STR(duzina,2),15)  }, "duzina"   },;
          { "Stampati(D/N)"   , {|| PADC(stampati,13)       }, "stampati" };
        }
Kol:={1,2,3,4,5,6,7}
// PushHT("2-1")
vrati:=PostojiSifra(F_STAMP2,1,10,77,"LISTA PODATAKA ZA STAMPANJE - UPLATNICE:",@cId,dx,dy)
// PopHT()
return vrati


************************************
************************************
function P_Valuta(cid,dx,dy)
PRIVATE ImeKol,Kol
ImeKol:={ { "ID "       , {|| id }   , "id"        },;
          { "Naziv"     , {|| naz}   , "naz"       },;
          { "Skrac."    , {|| naz2}  , "naz2"      },;
          { "Datum"     , {|| datum} , "datum"     },;
          { "Kurs1"     , {|| kurs1} , "kurs1"     },;
          { "Kurs2"     , {|| kurs2} , "kurs2"     },;
          { "Kurs3"     , {|| kurs3} , "kurs3"     },;
          { "Tip(D/P/O)", {|| tip}   , "tip"       ,{|| .t.},{|| wtip$"DPO"}};
        }
Kol:={1,2,3,4,5,6,7,8}
return PostojiSifra(F_VALUTE,1,10,77,"Valute",@cid,dx,dy)

*****************************************
* zabranjuje dupli unos sifre
*****************************************
static function  vpsifra(wid)
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



**************************
* sifrarnik javnih prihoda
**************************
function P_JPrih(cId,dx,dy)
LOCAL vrati
PRIVATE ImeKol,Kol
ImeKol:={}
Kol:={}
AADD(Imekol,{ "Vrsta",   {|| Id} ,      "Id" })
AADD(Imekol,{ "N0",      {|| IdN0} ,    "IdN0" })
AADD(Imekol,{ "Kan",     {|| IdKan} ,   "IdKan" })
AADD(Imekol,{ "Ops",     {|| IdOps} ,   "IdOps" })
AADD(Imekol,{ "Naziv",   {|| Naz} ,     "Naz" })
AADD(Imekol,{ "Racun",   {|| Racun} ,   "Racun" })
AADD(Imekol,{ "BudzOrg", {|| BudzOrg} , "BudzOrg" })
FOR i:=1 TO LEN(ImeKol); AADD(Kol,i); NEXT

vrati:=PostojiSifra(F_JPRIH,1,10,77,"Lista Javnih prihoda",@cId,dx,dy)
return vrati


***************************************
***************************************
function P_Ops(cId,dx,dy)

private imekol,kol

ImeKol:={ { padr("Id",2), {|| id}, "id", {|| .t.}, {|| vpsifra(wid)} },;
          { padr("IDJ",3), {||  idj}, "idj" }                       ,;
          { padr("Kan",3), {||  idKan}, "idKan" }                       ,;
          { padr("N0",3), {||  idN0}, "IdN0" }                       ,;
          { padr("Naziv",20), {||  naz}, "naz" }                       ;
       }

Kol:={}
FOR i:=1 TO LEN(ImeKol); AADD(Kol,i); NEXT
return PostojiSifra(F_OPS,1,10,65,"Lista opcina",@cId,dx,dy)


***************************************
***************************************
function P_Banke(cId,dx,dy)

private imekol,kol

ImeKol:={ { padr("Id",2), {|| id}, "id", {|| .t.}, {|| vpsifra(wid)} },;
          { "Naziv", {||  naz}, "naz" }                      ,;
          { "Mjesto", {|| mjesto}, "mjesto" }                ;
       }
Kol:={1,2,3}
return PostojiSifra(F_BANKE,1,10,55,"Lista banaka",@cId,dx,dy)
