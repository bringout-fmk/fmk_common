#include "sc.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/svi/partn.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.5 $
 * $Log: partn.prg,v $
 * Revision 1.5  2004/02/12 15:37:55  sasavranic
 * no message
 *
 * Revision 1.4  2002/07/04 19:04:08  ernad
 *
 *
 * ciscenje sifrarnik fakt
 *
 * Revision 1.3  2002/06/16 11:44:53  ernad
 * unos header-a
 *
 *
 */
function P_Firma(cId, dx, dy)
*{
private ImeKol
private Kol

ImeKol:={}
Kol:={}

AADD(ImeKol,{PADR("ID",6),{|| id},"id",{|| .t.},{|| vpsifra(wid)}})
AADD(ImeKol,{PADR("Naziv",25),{|| naz},"naz"})
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

FOR i:=1 TO LEN(ImeKol); AADD(Kol,i); NEXT

PushWa()

select (F_SIFK)
if !used()
  O_SIFK; O_SIFV
endif

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

PRIVATE gTBDir

gTBDir:="N"
return PostojiSifra(F_PARTN,1,10,60,"Lista Partnera", @cId, dx, dy,;
       gPartnBlock)
*}
