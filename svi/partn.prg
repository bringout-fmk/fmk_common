#include "sc.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 *
 */

function P_Firma(cId, dx, dy)
local nTArea
private ImeKol
private Kol

ImeKol:={}
Kol:={}

nTArea := SELECT()
O_PARTN

AADD(ImeKol,{PADR("ID",6),{|| id},"id",{|| .t.},{|| vpsifra(wid)}})
add_mcode(@ImeKol)
AADD(ImeKol,{PADR("Naziv",25),{|| PADR(naz,25) } , "naz"})
if IzFmkIni("Partn","Naziv2","N", SIFPATH)=="D"
	AADD(ImeKol,{PADR("Naziv2",25),{|| naz2},"naz2"})
endif
AADD(ImeKol,{PADR("PTT",5),{|| PTT},"ptt"})
AADD(ImeKol,{PADR("Mjesto",16),{|| MJESTO},"mjesto"})
AADD(ImeKol,{PADR("Adresa",24),{|| ADRESA},"adresa"})
AADD(ImeKol,{PADR("Ziro R ",22),{|| ZIROR},"ziror"})
if partn->(fieldpos("DZIROR"))<>0
	AADD(ImeKol,{padr("Dev ZR",22 ),{|| DZIROR},"Dziror"})
endif
AADD(Imekol,{PADR("Telefon",12),{|| TELEFON},"telefon"})
if partn->(fieldpos("FAX"))<>0
	AADD(ImeKol,{padr("Fax",12 ),{|| fax},"fax"})
endif
if partn->(fieldpos("MOBTEL"))<>0
	AADD(ImeKol,{padr("MobTel",20 ),{|| mobtel},"mobtel"})
endif
if partn->(fieldpos("IDOPS"))<>0 .and. (F_OPS)->(USED())
	AADD (ImeKol,{padr("Opcina",20 ),{|| idops},"idops",{|| .t.},{||P_Ops(@widops)}})
endif
if partn->(fieldpos("BRLK"))<>0
	AADD(ImeKol,{padr("Broj LK",20 ),{|| mobtel},"brlk"})
endif
if partn->(fieldpos("JMBG"))<>0
	AADD(ImeKol,{padr("JMBG",20 ),{|| mobtel},"jmbg"})
endif
if partn->(fieldpos("FIDBR"))<>0
	AADD(ImeKol,{padr("Partn Firma ID",20 ),{|| mobtel},"fidbr"})
endif

FOR i:=1 TO LEN(ImeKol)
	AADD(Kol,i)
NEXT

PushWa()

select (F_SIFK)
if !used()
	O_SIFK
  	O_SIFV
endif

select sifk
set order to tag "ID"
seek "PARTN"

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

 	AADD(Kol, iif( sifk->UBrowsu='1',++i, 0) )
	skip
enddo
PopWa()

select (nTArea)

private gTBDir
gTBDir:="N"
return PostojiSifra(F_PARTN,1,10,60,"Lista Partnera", @cId, dx, dy,;
       gPartnBlock)
*}


// funkcija vraca .t. ako je definisana grupa partnera
function p_group()
local lRet:=.f.

O_SIFK
select sifk
set order to tag "ID"
go top
seek "PARTN"
do while !eof() .and. ID="PARTN"
	if field->oznaka == "GRUP"
		lRet := .t.
		exit
	endif
	skip
enddo
return lRet



// -----------------------------------
// -----------------------------------
function p_set_group(set_field)
private Opc:={}
private opcexe:={}
private Izbor

AADD(Opc, "VP  - veleprodaja          ")
AADD(opcexe, {|| set_field := "VP ", Izbor := 0 } )
AADD(Opc, "AMB - ambulantna dostava  ")
AADD(opcexe, {|| set_field := "AMB", Izbor := 0 } )
AADD(Opc, "SIS - sistemska kuca      ")
AADD(opcexe, {|| set_field := "SIS", Izbor := 0 } )
AADD(Opc, "OST - ostali      ")
AADD(opcexe, {|| set_field := "OST", Izbor := 0 } )

Izbor:=1
Menu_Sc("pgr")

m_x := 1
m_y := 5

return .t.
*}

// vraca opis grupe
function gr_opis(cGroup)
local cRet
do case
	case cGroup == "AMB"
		cRet := "ambulantna dostava"
	case cGroup == "SIS"
		cRet := "sistemska obrada"
	case cGroup == "VP "
	 	cRet := "veleprodaja"
	case cGroup == "OST"
		cRet := "ostali"
	otherwise
		cRet := ""
endcase

return cRet


// -----------------------------------
// -----------------------------------
function p_gr(xVal, nX, nY)
local cRet := ""
local cPrn := ""

cRet := gr_opis(xVal)
cPrn := SPACE(2) + "-" + SPACE(1) + cRet

@ nX, nY+25 SAY SPACE(40)
@ nX, nY+25 SAY cPrn

return .t.


// da li partner 'cPartn' pripada grupi 'cGroup'
function p_in_group(cPartn, cGroup)
local cSifKVal
cSifKVal := IzSifK("PARTN", "GRUP", cPartn, .f.)

if cSifKVal == cGroup
	return .t.
endif

return .f.

// -----------------------------
// get partner fax
// -----------------------------
function g_part_fax(cIdPartner)
local cFax

PushWa()

SELECT F_PARTN
if !used()
	O_PARTN
endif
SEEK cIdPartner
if !found()
 cFax := "!NOFAX!"
else
 cFax := fax
endif

PopWa()

return cFax

// -----------------------------
// get partner naziv + mjesto
// -----------------------------
function g_part_name(cIdPartner)
local cRet

PushWa()

SELECT F_PARTN
if !used()
	O_PARTN
endif
SEEK cIdPartner
if !found()
 cRet := "!NOPARTN!"
else
 cRet := TRIM(LEFT(naz,25)) + " " + TRIM(mjesto)
endif

PopWa()

return cRet
