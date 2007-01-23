#include "sc.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 *
 */

// -----------------------------------------
// otvaranje tabele roba - sifrarnik
// -----------------------------------------
function P_Roba(cId, dx, dy)
local cRet
local bRoba
local nTArea
local lArtGroup := .f.
private ImeKol
private Kol

PushWa()
ImeKol:={}

nTArea := SELECT()

O_ROBA

if (IzFmkIni("Svi","SifAuto","N", SIFPATH)=="N") .or.;
   (IzFmkIni("SifRoba","ID","D", SIFPATH)=="D")
	AADD(ImeKol, {padc("ID",10),  {|| id }, iif(IzFmkIni("Svi","SifAuto","N", SIFPATH)="D","","id")  , {|| .t.}, {|| vpsifra(wId)} })
endif

// kataloski broj
if roba->(fieldpos("KATBR"))<>0
	AADD(ImeKol, {padc("KATBR",14 ), {|| PADR(katBr, 14)}, "katBr"   })
endif

// sifra dobavljaca
if roba->(fieldpos("SIFRADOB"))<>0
	AADD(ImeKol, {padc("S.dobav.",13 ), {|| PADR(sifraDob, 13)}, "sifraDob"   })
endif

// naziv
if glProvNazRobe
	AADD(ImeKol, {padc("Naziv",40), {|| LEFT(naz, 40)},"naz",{|| .t.}, {|| VpNaziv(wNaz)}})
else
	AADD(ImeKol, {padc("Naziv",40), {|| LEFT(naz, 40)},"naz",{|| .t.}, {|| .t.}})
endif

// jedinica mjere
AADD(ImeKol, {padc("JMJ",3), {|| jmj},       "jmj"    })

// DEBLJINA i TIP
if roba->(fieldpos("DEBLJINA")) <> 0
	AADD(ImeKol, {padc("Debljina",10 ), {|| transform(debljina, "999999.99")}, "debljina", nil, nil, "999999.99" })

	AADD(ImeKol, {padc("Roba tip",10 ), {|| roba_tip}, "roba_tip", {|| .t.}, {|| .t. }})
endif

// STRINGS
if roba->(fieldpos("STRINGS")) <> 0
	AADD(ImeKol, {padc("Strings", 10 ), {|| strings}, "strings", {|| .t.}, {|| .t. }})
endif

// VPC
if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","SHOWVPC"))
	AADD(ImeKol, {padc("VPC",10 ), {|| transform(VPC,"999999.999")}, "vpc" , nil, nil, nil, gPicCDEM  })
endif

// VPC2
if roba->(fieldpos("vpc2"))<>0
	if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","SHOWVPC2"))
		if IzFMkIni('SifRoba',"VPC2",'D', SIFPATH)=="D"
			AADD(ImeKol, {padc("VPC2",10 ), {|| transform(VPC2,"999999.999")}, "vpc2", NIL, NIL,NIL, gPicCDEM   })
 		endif
	endif
endif

AADD(ImeKol, {padc("MPC",10 ), {|| transform(MPC,"999999.999")}, "mpc", NIL, NIL,NIL, gPicCDEM  })

if roba->(fieldpos("PLC"))<>0  .and. IzFMkIni("SifRoba","PlanC","N", SIFPATH)=="D"
	AADD(ImeKol, {padc("Plan.C",10 ), {|| transform(PLC,"999999.999")}, "PLC", NIL, NIL,NIL, gPicCDEM    })
endif

for i:=2 to 10
	cPom:="MPC"+ALLTRIM(STR(i))
	cPom2:='{|| transform('+cPom+',"999999.999")}'
	if roba->( fieldpos( cPom ) )  <>  0
		if i>1  // parametriziraj
			cPrikazi:=IzFMkIni('SifRoba',cPom,'D', SIFPATH)
		else
			cPrikazi:="D"
		endif

		if cPrikazi=="D"
			AADD(ImeKol, {padc(cPom,10 ), &(cPom2) , cPom , nil, nil, nil, gPicCDEM })
		endif
	endif
next

if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","SHOWNC"))
	AADD(ImeKol, {padc("NC",10 ), {|| transform(NC,gPicCDEM)}, "NC", NIL, NIL, NIL, gPicCDEM  })
endif

AADD(ImeKol, {"Tarifa",{|| IdTarifa}, "IdTarifa", {|| .t. }, {|| P_Tarifa(@wIdTarifa), EditOpis() }   })

AADD(ImeKol, {"Tip",{|| " "+Tip+" "}, "Tip", {|| .t.}, {|| wTip $ " TUCKVPSXY" } ,NIL,NIL,NIL,NIL, 27 } )

if roba->(fieldpos("BARKOD"))<>0
	if glAutoFillBK
		AADD (ImeKol,{ padc("BARKOD",14 ), {|| BARKOD}, "BarKod" , {|| WhenBK()} , {|| DodajBK(@wBarkod) }  })
	else
		AADD (ImeKol,{ padc("BARKOD",14 ), {|| BARKOD}, "BarKod" , {|| .t.} , {|| DodajBK(@wBarkod) }  })
	endif
endif

if roba->(fieldpos("mink"))<>0
	AADD (ImeKol,{ padc("MINK",10 ), {|| transform(MINK,"999999.99")}, "MINK"   })
endif

if roba->(fieldpos("K1"))<>0
	AADD (ImeKol,{ padc("K1",4 ), {|| k1 }, "k1"   })
	AADD (ImeKol,{ padc("K2",4 ), {|| k2 }, "k2"   })
	AADD (ImeKol,{ padc("N1",12), {|| N1 }, "N1"   })
	AADD (ImeKol,{ padc("N2",12 ), {|| N2 }, "N2"   })
endif
if roba->(fieldpos("K7"))<>0
	AADD (ImeKol,{ padc("K7",2 ), {|| k7 }, "k7"   })
	AADD (ImeKol,{ padc("K8",2 ), {|| k8 }, "k8"   })
	AADD (ImeKol,{ padc("K9",3 ), {|| k9 }, "k9"   })
endif

if roba->(fieldpos("ZANIVEL"))<>0
	AADD (ImeKol,{ padc("Nova cijena", 20 ), {|| transform(zanivel,"999999.999")}, "zanivel", NIL, NIL,NIL, gPicCDEM  })
endif
if roba->(fieldpos("ZANIV2"))<>0
	AADD (ImeKol,{ padc("Nova cijena/2", 20 ), {|| transform(zaniv2,"999999.999")}, "zaniv2", NIL, NIL,NIL, gPicCDEM  })
endif


if roba->(fieldpos("IDTARIFA2"))<>0
	AADD (ImeKol,{ "Tarifa R2",{|| IdTarifa2}, "IdTarifa2", {|| .t. }, {|| set_tar_rs(@wIdTarifa2, wIdTarifa) .or. P_Tarifa(@wIdTarifa2) }   })
	AADD (ImeKol,{ "Tarifa R3",{|| IdTarifa3}, "IdTarifa3", {|| .t. }, {|| set_tar_rs(@wIdTarifa3, wIdTarifa) .or. P_Tarifa(@wIdTarifa3) }   })
endif


if IsPlanika()
	AADD (ImeKol,{ padc("Pl.Vr.", 3 ), {|| vrsta },  "vrsta",  {|| .t. }, {|| P_RVrsta(@wVrsta), .t. } })
	AADD (ImeKol,{ padc("Pl.Sezona", 9 ), {|| sezona }, "sezona", {|| .t.}, {|| P_PlSezona(@wSezona) } })
	AADD (ImeKol,{ padc("Id partner", 6 ), {|| idpartner }, "idpartner", {|| .t.}, {|| P_IdPartner(@wIdPartner) } })
	if roba->(fieldpos("TPURCHASE"))<>0
		AADD (ImeKol,{ padc("Grupa nabavke",13 ), {|| tpurchase}, "tpurchase",  {|| .t. }, {|| P_TPurchase(@wtpurchase), .t. } })
	endif
endif

Kol := {}

FOR i:=1 TO LEN(ImeKol)
	AADD(Kol,i)
NEXT

select sifk
set order to tag "ID"
seek "ROBA"

do while !eof() .and. ID="ROBA"
	AADD (ImeKol, {  IzSifKNaz("ROBA",SIFK->Oznaka) })
 	AADD (ImeKol[Len(ImeKol)], &( "{|| ToStr(IzSifk('ROBA','" + sifk->oznaka + "')) }" ) )
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
     			ImeKol [Len(ImeKol),7] := replicate("9", sifk->duzina-sifk->decimal-1 )+"."+replicate("9",sifk->decimal)
   		else
     			ImeKol [Len(ImeKol),7] := replicate("9", sifk->duzina )
   		endif
 	endif
	AADD  (Kol, iif( sifk->UBrowsu='1',++i, 0) )
	skip
enddo

if IsPlanika()
	select (F_RVRSTA)
	if !used()
		O_RVRSTA
	endif
endif

select (nTArea)

private gTbDir:="N"
bRoba:=gRobaBlock

cPomTag:=IzFMKIni("SifRoba","SortTag","ID",SIFPATH)

cRet:=PostojiSifra(F_ROBA,(cPomTag),15,77,"Lista artikala - robe", @cId, dx, dy, bRoba,,,,,{"ID"})

PopWa()
return cRet


// Unos opisa u sifrarnik robe
function EditOpis()
local cOp:="N"
private GetList:={}
if IzFMkIni('SifRoba',"PitanjeOpis",'N',SIFPATH)=="D"
	@ m_x+7, m_y+43 SAY "Unijeti opis D/N ?" get cOp pict "@!" valid cop $ "DN"
 	read
endif
UsTipke()
if cOp=="D"
 	Box(,14,55)
   	@ m_x+1,m_y+2 SAY "** <c-W> za kraj unosa opisa **"
  	wOpis:=MemoEdit(wOpis,m_x+3,m_y+1,m_x+14,m_y+55)
   	wOpis:=OdsjPLK(wOpis)
 	BoxC()
endif
BosTipke()
return .t.


// ------------------------------------
// formiranje MPC na osnovu VPC
// ------------------------------------
function MpcIzVpc()

if pitanje(,"Formirati MPC na osnovu VPC ? (D/N)","N")=="N"
	return DE_CONT
endif

private GetList:={}
private nZaokNa:=1
private cMPC:=" "
private cVPC:=" "

Scatter()
select tarifa
hseek _idtarifa
select roba

Box(,4,70)
@ m_x+2, m_y+2 SAY "Set cijena VPC ( /2)  :" GET cVPC VALID cVPC$" 2"
@ m_x+3, m_y+2 SAY "Set cijena MPC ( /2/3):" GET cMPC VALID cMPC$" 23"
READ
IF EMPTY(cVPC)
	cVPC:=""
ENDIF
IF EMPTY(cMPC)
	cMPC:=""
ENDIF
BoxC()

Box(,6,70)
@ m_X+1, m_y+2 SAY trim(roba->id)+"-"+trim(LEFT(roba->naz, 40))
@ m_X+2, m_y+2 SAY "TARIFA"
@ m_X+2, col()+2 SAY _idtarifa
@ m_X+3, m_y+2 SAY "VPC"+cVPC
@ m_X+3, col()+1 SAY _VPC&cVPC pict gPicDem
@ m_X+4, m_y+2 SAY "Postojeca MPC"+cMPC
@ m_X+4, col()+1 SAY roba->MPC&cMPC pict gPicDem
@ m_X+5, m_y+2 SAY "Zaokruziti cijenu na (broj decimala):" GET nZaokNa VALID {|| _MPC&cMPC:=round(_VPC&cVPC * (1+ tarifa->opp/100) * (1+tarifa->ppp/100+tarifa->zpp/100),nZaokNa),.t.} pict "9"
@ m_X+6, m_y+2 SAY "MPC"+cMPC GET _MPC&cMPC WHEN {|| _MPC&cMPC:=round(_VPC&cVPC * (1+ tarifa->opp/100) * (1+tarifa->ppp/100+tarifa->zpp/100),nZaokNa),.t.} pict gPicDem
read
BoxC()
if lastkey()<>K_ESC
	Gather()
        IF Pitanje(,"Zelite li isto uraditi za sve artikle kod kojih je MPC"+cMPC+"=0 ? (D/N)","N")=="D"
        	nRecAM:=RECNO()
           	Postotak(1,RECCOUNT2(),"Formiranje cijena")
           	nStigaoDo:=0
           	GO TOP
           	DO WHILE !EOF()
             		IF ROBA->MPC&cMPC == 0
               			Scatter()
                		select tarifa
				hseek _idtarifa
				select roba
                		_MPC&cMPC:=round(_VPC&cVPC * (1+ tarifa->opp/100) * (1+tarifa->ppp/100+tarifa->zpp/100),nZaokNa)
               			Gather()
             		ENDIF
             		Postotak(2,++nStigaoDo)
             		SKIP 1
           	ENDDO
           	Postotak(0)
           	GO (nRecAM)
        ENDIF
        return DE_REFRESH
endif
return DE_CONT


// -------------------------------------------------------
// setovanje tarife 2 i 3 u sifrarniku na osnovu idtarifa
// -------------------------------------------------------
function set_tar_rs(cId1, cId2)
if EMPTY(cId1)
	cId1 := cId2
endif
return .t.


function WhenBK()
if empty(wBarKod)
	wBarKod:=PADR(wId,LEN(wBarKod))
	AEVAL(GetList,{|o| o:display()})
endif
return .t.


// roba ima zasticenu cijenu
// sto znaci da krajnji kupac uvijek placa fixan iznos pdv-a 
// bez obzira po koliko se roba prodaje
function RobaZastCijena( cIdTarifa )
lZasticena := .f.
lZasticena := lZasticena .or.  (PADR(cIdTarifa, 6) == PADR("PDVZ",6))
lZasticena := lZasticena .or.  (PADR(cIdTarifa, 6) == PADR("PDV17Z",6))
lZasticena := lZasticena .or.  (PADR(cIdTarifa, 6) == PADR("CIGA05",6))

return lZasticena

