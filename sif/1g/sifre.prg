#include "ld.ch"


function P_Radn(cId,dx,dy)
local i
local nArr

nArr:=SELECT()

private imekol
private kol
private cFooter := ""

select (F_RADN)
if (!used())
	O_RADN
endif

// filterisanje tabele radnika
_radn_filter( .t. )

select (nArr)

ImeKol:={}
AADD(ImeKol, { Lokal(padr("Id",6)), {|| id}, "id", {|| .t.}, {|| vpsifra(wid)} })
AADD(ImeKol, { Lokal(padr("Prezime", 20)),{|| naz}, "naz" } )
AADD(ImeKol, { Lokal(padr("Ime roditelja",15)),{|| imerod}, "imerod" } )
AADD(ImeKol, { Lokal(padr("Ime",15)), {|| ime}, "ime" } )
AADD(ImeKol, { padr( IF(gBodK=="1", Lokal("Br.bodova"), Lokal("Koeficij.")), 10),{|| brbod}, "brbod" })
AADD(ImeKol, { Lokal(padr("MinR%", 5)), {|| kminrad}, "kminrad" })

if RADN->(FIELDPOS("KLO")) <> 0
   
   AADD(ImeKol, { Lokal(padr("Koef.l.odb.", 15)), {|| klo}, "klo" })
   AADD(ImeKol, { Lokal(padr("Tip rada", 15)), {|| tiprada}, "tiprada", ;
   	{|| .t.}, {|| wtiprada $ " #I#A#S#N#P#U#R" .or. MsgTipRada() } })
   
   if RADN->(FIELDPOS("SP_KOEF")) <> 0
   	AADD(ImeKol, { Lokal(padr("prop.koef", 15)), {|| sp_koef}, "sp_koef" })
   endif
   
   if RADN->(FIELDPOS("OPOR")) <> 0
   	AADD(ImeKol, { Lokal(padr("oporeziv", 15)), {|| opor}, "opor" })
   endif
   
   if RADN->(FIELDPOS("TROSK")) <> 0
   	AADD(ImeKol, { Lokal(padr("koristi trosk.", 15)), {|| trosk}, "trosk" })
   endif
  
endif

AADD(ImeKol, { Lokal(padr("StrSpr",6)), {|| padc(Idstrspr,6)}, "idstrspr", {||.t.}, {|| P_StrSpr(@wIdStrSpr)} } )
AADD(ImeKol, { Lokal(padr("V.Posla",6)), {|| padc(IdVPosla,6)}, "IdVPosla", {||.t.}, {|| empty(widvposla) .or. P_VPosla(@wIdVPosla)} })
AADD(ImeKol, { Lokal(padr("Ops.Stan",8)),{|| padc(IdOpsSt,8)}, "IdOpsSt", {||.t.}, {|| P_Ops(@wIdOpsSt)} })
AADD(ImeKol, { Lokal(padr("Ops.Rada",8)),{|| padc(IdOpsRad,8)}, "IdOpsRad", {||.t.}, {|| P_Ops(@wIdOpsRad)} })
AADD(ImeKol, { Lokal(padr("Maticni Br.",13)),{|| padc(matbr,13)}, "MatBr", {||.t.}, {|| .t.} })
AADD(ImeKol, { Lokal(padr("Dat.Od",8)), {|| datod}, "datod", {||.t.}, {|| .t.} })
AADD(ImeKol, { Lokal(padr("POL",3)), {|| padc(pol,3)}, "POL", {||.t.}, {|| wPol $ "MZ"} })
AADD(ImeKol, { padr("K1",2),{|| padc(k1,2)}, "K1", {||.t.}, {|| .t.} })
AADD(ImeKol, { padr("K2",2),{|| padc(k2,2)}, "K2", {||.t.}, {|| .t.} })
AADD(ImeKol, { padr("K3",2),{|| padc(k3,2)}, "K3", {||.t.}, {|| .t.} })
AADD(ImeKol, { padr("K4",2),{|| padc(k4,2)}, "K4", {||.t.}, {|| .t.} })
AADD(ImeKol, { Lokal(padr("PorOl",6)), {|| porol}, "POROL", {||.t.}, {|| .t.} })

AADD(ImeKol, { Lokal(padr("Radno mjesto",30)), {|| rmjesto}, "RMJESTO", {||.t.}, {|| .t.} })

AADD(ImeKol, { Lokal(padr("Br. Knjizice ",12)), {|| padc(brknjiz,12)}, "brknjiz", {||.t.}, {|| .t.} })

AADD(ImeKol, { Lokal(padr("Br. Tekuceg rac.",20)) , {|| padc(brtekr,20)}, "brtekr", {||.t.}, {|| .t.} })

AADD(ImeKol, { Lokal(padr("Isplata",7)), {|| padc(isplata,7)}, "isplata", {||.t.}, {|| wIsplata $ "  #TR#SK#BL" .or. MsgIspl()} })
AADD(ImeKol, { Lokal(padr("Banka",6)), {|| padc(idbanka,6)}, "idbanka", {||.t.}, {|| EMPTY(WIDBANKA) .OR. P_Kred(@widbanka)} } )

AADD( ImeKol, { Lokal( padr("OSN.Bol", 11) ) , {|| osnbol}, "osnbol" } )

if radn->(fieldpos("N1")<>0)
	AADD(ImeKol,{padc("N1",12 ),{|| n1},"n1"})
  	AADD(ImeKol,{padc("N2",12 ),{|| n2},"n2"})
  	AADD(ImeKol,{padc("N3",12 ),{|| n3},"n3"})
endif

if radn->(fieldpos("IDRJ")<>0)
	AADD(ImeKol, { "ID RJ" , {|| idrj}, "idrj", {||.t.}, {|| EMPTY(wIdRj) .or. P_Rj(@wIdRj)} } )
endif

// Dodaj specificna polja za popunu obrasca DP
if radn->(fieldpos("STREETNAME")<>0)
	AADD(ImeKol,{Lokal(padc("Ime ul.",40 )), {|| streetname},"streetname"})
  	AADD(ImeKol,{Lokal(padc("Broj ul.",10 )),{|| streetnum},"streetnum"})
  	AADD(ImeKol,{Lokal(padc("Zaposl.od",12 )),{|| hiredfrom},"hiredfrom",{|| .t.},{|| P_HiredFrom(@wHiredfrom)}})
  	AADD(ImeKol,{Lokal(padc("Zaposl.do",12 )),{|| hiredto},"hiredto"})
endif


if radn->(FIELDPOS("AKTIVAN")) <> 0
	AADD(ImeKol, { "Aktivan?",{|| aktivan}, "aktivan" } )
endif

Kol:={}

for i:=1 to LEN(ImeKol)
	AADD(Kol,I)
next

if gMinR=="B"
	ImeKol[6]:={Lokal(padr("MinR",7)), {|| transform(kminrad,"9999.99")},"kminrad"}
endif

for i:=1 to 9
	cPom:="S"+ALLTRIM(STR(i))
	nPom:=LEN(ImeKol)
	if radn->(fieldpos(cPom)<>0)
		cPom2:=IzFmkIni("LD","OpisRadn"+cPom,"KOEF_"+cPom,KUMPATH)
		AADD(ImeKol,{ cPom+"("+cPom2+")", {|| &cPom.}, cPom })
		AADD(Kol,nPom+1)
	endif
next


return PostojiSifra(F_RADN, 1, 12, 72, Lokal("Lista radnika") + SPACE(5) + "<S> filter radnika on/off", ;
          @cId, dx, dy, ;
	  {|Ch| RadBl(Ch)},,,,,{"ID"})



// ------------------------------------------
// filterisanje tabele radnika
// ------------------------------------------
static function _radn_filter( lFiltered )
local cFilter := ""

if radn->(FIELDPOS("aktivan")) = 0
	return
endif

if lFiltered == nil
	lFiltered := .t.
endif

cFilter := "aktivan $ ' #D'"

if lFiltered == .t. .and. gRadnFilter == "D"
	set filter to &cFilter
	go top
else
	set filter to
	go top
endif

return



/*! \fn P_HiredFrom(dHiredFrom)
 *  \brief
 *  \param dHiredFrom
 */
function P_HiredFrom(dHiredFrom)
*{
if EMPTY(DToS(dHiredFrom)) .and. !EMPTY(DToS(field->datod)) .and. Pitanje(, Lokal("Popuni polje na osnovu polja Datum Od"), "D") == "D"
	dHiredFrom:=field->datod
endif
return .t.
*}

/*! \fn P_StreetNum(cStreetNum)
 *  \brief
 *  \param cStreetNum - vrijednost polja streetnum 
 */
function P_StreetNum(cStreetNum)
*{
if EMPTY(field->streetnum)
	cStreetNum:=SPACE(5) + "0"
endif
return .t.


// ---------------------------------------------
// ispisuje info o poreskoj kartici
// ---------------------------------------------
static function p_pkartica( cIdRadn )
local nTA := SELECT()

if gVarObracun == "1"
	return
endif

O_PK_RADN
select pk_radn
seek cIdRadn

if FOUND() .and. field->idradn == cIdRadn
	@ prow()+8, pcol()+5 SAY "               " COLOR "W+/W"
else
	@ prow()+8, pcol()+5 SAY "pk: nepopunjena" COLOR "W+/R+"
endif

select (nTA)

return



// --------------------------------------------
// radn. blok funkcije
// --------------------------------------------
function RadBl(Ch)
local cMjesec:=gMjesec

// ispisi info o poreskoj kartici
p_pkartica( field->id )


if (Ch==K_ALT_M)
	Box(,4,60)
		@ m_x+1,m_y+2 SAY "Postavljenje koef. minulog rada:"
   		@ m_x+2,m_y+2 SAY "Pazite da ovu opciju ne izvrsite vise puta za isti mjesec !"
   		@ m_x+4,m_y+2 SAY "Mjesec:" GET cmjesec pict "99"
   		read
	BoxC()

	if (LastKey()==K_ESC)
		return DE_CONT
	endif

	MsgO(Lokal("Prolazim kroz tabelu radnika.."))

	select radn
	go top
	do while !eof()
		
		if Month(datOd) == cMjesec
     			
			if pol=="M"
       				replace kminrad with kminrad+gMRM
     			elseif pol=="Z"
       				replace kminrad with kminrad+gMRZ
     			endif
    		
		endif
    		
		if kminrad > 20   
			// ogranicenje minulog rada
      			replace kminrad with 20
    		endif
    		
		skip
	enddo
	
	MsgC()
	go top
	return DE_REFRESH
elseif (Ch==K_CTRL_T)
	if ImaURadKr(radn->id,"2")
   		Beep(1)
   		Msg(Lokal("Stavka radnika se ne moze brisati jer se vec nalazi u obracunu!"))
  		return 7
 	endif
elseif (Ch==K_F2)
	if ImaURadKr(radn->id,"2")
   		return 99
 	endif

elseif ( UPPER(CHR(Ch)) == "P" )
	
	// poreska kartica, vraca faktor odbitka...
 	nFakt := p_kartica( field->id )

	select radn
	
	if nFakt >= 0 .and. nFakt <> radn->klo
	  if Pitanje(,"Postaviti novi faktor licnog odbitka ?", "D") == "D"
	    replace radn->klo with nFakt
	  endif
	endif
	
	return DE_CONT

elseif ( UPPER(CHR(Ch)) == "D" ) 

	pk_delete( field->id )
	
	select radn
	return DE_CONT

elseif ( UPPER(CHR(Ch))=="S" )
	
	// filter po radnicima
	cTmp := DBFilter()

	if EMPTY(cTmp)
		msgbeep("prikazuju se samo aktivni radnici ...")
		_radn_filter( .t. )
		return DE_REFRESH
	else
		msgbeep("vracam filter na sve radnike ....")
		_radn_filter( .f. )
		return DE_REFRESH
	endif

endif

return DE_CONT
*}


function MsgIspl()
Box(,3,50)
	@ m_x+1,m_y+2 SAY Lokal("Vazece sifre su: TR - tekuci racun   ")
 	@ m_x+2,m_y+2 SAY Lokal("                 SK - stedna knjizica")
 	@ m_x+3,m_y+2 SAY Lokal("                 BL - blagajna")
 	inkey(0)
BoxC()
return .f.



// ------------------------------
// sifrarnik parametri obracuna
// ------------------------------
function P_ParObr(cId,dx,dy)
local nArr
nArr:=SELECT()
private imekol := {}
private kol := {}

select (F_PAROBR)
if (!used())
	O_PAROBR
endif

AADD(ImeKol,{ padr("mjesec",8), {|| id}, "id", {|| wid:=val(wid), .t. },{|| wid:=str(wid,2), .t.}  })

AADD(ImeKol, { "godina" , {|| godina} , "godina" } )

if lViseObr
  	AADD(ImeKol, { padr("obracun",10) , {|| obr} , "obr" } )
endif

if IzFMKINI( "LD", "VrBodaPoRJ", "N", KUMPATH ) == "D"
  	AADD(ImeKol, { "rj" , {|| IDRJ} , "IDRJ" } )
endif

AADD(ImeKol, { padr("opis",10), {|| naz}, "naz" } )
AADD(ImeKol, { padr(IF(gBodK == "1","vrijednost boda","vr.koeficijenta"),15),;
	{|| vrbod}, "vrbod" } )

// ako postoji polje i ako je nova varijanta obracuna
if parobr->(FIELDPOS("K5")) <> 0 .and. gVarObracun == "2"
	AADD(ImeKol, { padr("n.koef.1",8), {|| k5} , "k5"  } )
	AADD(ImeKol, { padr("n.koef.2",8), {|| k6} , "k6"  } )
endif

if parobr->(FIELDPOS("K7")) <> 0 .and. gVarObracun == "2"
	AADD(ImeKol, { padr("n.koef.3",8), {|| k7} , "k7"  } )
	AADD(ImeKol, { padr("n.koef.4",8), {|| k8} , "k8"  } )
endif

AADD(ImeKol, { padr("br.sati",5), {|| k1} , "k1"  } )

if gVarObracun <> "2"
	AADD(ImeKol, { padr("Koef2",5), {|| k2} , "k2"  } )
	AADD(ImeKol, { padr("Bruto osn.",6), {|| k3} , "k3"  }  )
	AADD(ImeKol, { padr("Koef4",6), {|| k4} , "k4"  } )
endif

AADD(ImeKol, { padr("prosj.LD",12), {|| Prosld} , "PROSLD"  }  )

if parobr->(FIELDPOS("M_NET_SAT")) <> 0 .and. gVarObracun == "2"
	AADD(ImeKol, { padr("mn sat.",12), {|| m_net_sat} , "m_net_sat"  } )
endif
if parobr->(FIELDPOS("M_BR_SAT")) <> 0 .and. gVarObracun == "2"
	AADD(ImeKol, { padr("mb sat.",12), {|| m_br_sat} , "m_br_sat"  } )
endif

for i := 1 to LEN( ImeKol )
	AADD( kol, i )
next

select (nArr)

return PostojiSifra(F_PAROBR, 1, 10, 70, Lokal("Parametri obracuna"), ;
	@cId, dx, dy)



// --------------------------------------------
// --------------------------------------------
function P_TipPr(cId,dx,dy)
*{
local nArr
local i
nArr:=SELECT()
private imekol := {}
private kol := {}

select (F_TIPPR)
if (!used())
	O_TIPPR
endif
select (nArr)

AADD(ImeKol, { padr("Id",2), {|| id}, "id", {|| .t.}, {|| vpsifra(wid)} } )
AADD(ImeKol, { padr("Naziv",20), {||  naz}, "naz" } )
AADD(ImeKol, { "Aktivan", {||  padc(aktivan,7) }, "aktivan" } )
AADD(ImeKol, { "Fiksan", {||  padc(fiksan,7) }, "fiksan" } )
AADD(ImeKol, { padr("U fond s.",10), {||  padc(ufs,10) }, "ufs" } )
AADD(ImeKol, { padr("U neto", 6), {||  padc(uneto,6 ) }, "uneto" } )

if TIPPR->(FIELDPOS("TPR_TIP")) <> 0
	AADD(ImeKol, { padr("tp.tip", 6), {||  tpr_tip }, "tpr_tip", {|| .t.}, {|| v_tpr_tip(wtpr_tip) } } )
endif

AADD(ImeKol, { padr("Formula",200), {|| formula}, "formula"  } )
AADD(ImeKol, { padr("Opis",8), {|| opis}, "opis"  } )

for i:=1 to LEN(ImeKol)
	AADD(Kol, i)
next

return PostojiSifra(F_TIPPR, 1, 10, 55, Lokal("Tipovi primanja"), ;
	@cId, dx, dy, ;
	{|Ch| TprBl(Ch)},,,,,{"ID"})


// -----------------------------------------
// valid tpr_tip
// -----------------------------------------
function v_tpr_tip( cTip )
if EMPTY(cTip)
	msgbeep("Tip moze biti:##prazno - standardno#N - neto#2 - naknade za rad#X - neoporezive stavke, krediti itd...")
endif
return .t.

// ---------------------------------------- 
// valid dop_tip
// ---------------------------------------- 
function v_dop_tip( cTip)
if EMPTY(cTip)
	msgbeep("Tip moze biti:##prazno - standardno#N - neto#2 - ostale naknade#P - neto + ostale naknade#B - bruto#R - neto na ruke")
endif
return .t.


// ------------------------------------------
// ------------------------------------------
function TprBl(Ch)
if Logirati(goModul:oDataBase:cName,"SIF","EDITTIPPR")
	select tippr
	if (Ch==K_F2)
		MsgO("Evidentiram stanje sifrarnika...")
		cStanje:=(tippr->id+"-"+tippr->aktivan+"-"+tippr->fiksan+"-"+tippr->uneto+"-"+tippr->ufs)
		EventLog(nUser,goModul:oDataBase:cName,"SIF","EDITTIPPR",nil,nil,nil,nil,"","",cStanje,Date(),Date(),"F-"+ALLTRIM(tippr->formula),"Promjena stanja sifrarnika tippr")
		select tippr
		MsgC()
		return DE_REFRESH
	endif
endif

return DE_CONT
*}



function P_TipPr2(cId,dx,dy)
*{
local nArr
nArr:=SELECT()
private imekol
private kol

select (F_TIPPR2)
if (!used())
	O_TIPPR2
endif
select (nArr)

ImeKol:={ { padr("Id",2), {|| id}, "id", {|| .t.}, {|| vpsifra(wid)} },;
          { padr("Naziv",20), {||  naz}, "naz" }                       ,;
          {      "Aktivan"  , {||  padc(aktivan,7) }, "aktivan" }      ,;
          {      "Fiksan"  , {||  padc(fiksan,7) }, "fiksan" }         ,;
          { padr("U fond s.",10), {||  padc(ufs,10) }, "ufs" } ,;
          { padr("U neto", 6), {||  padc(uneto,6 ) }, "uneto" } ,;
          { padr("Formula",200), {|| formula}, "formula"  }, ;
          { padr("Opis",8), {|| opis}, "opis"  } ;
       }
Kol:={1,2,3,4,5,6,7,8}
return PostojiSifra( F_TIPPR2, 1, 10, 55, Lokal("Tipovi primanja za obracun 2"), ;
	@cId, dx, dy, ;
	{|Ch| Tpr2Bl(Ch)},,,,,{"ID"})
*}


// -----------------------------------------------
// -----------------------------------------------
function Tpr2Bl(Ch)
*{
if Logirati(goModul:oDataBase:cName,"SIF","EDITTIPPR2")
	select tippr
	if (Ch==K_F2)
		MsgO("Evidentiram stanje sifrarnika...")
		cStanje:=(tippr->id+"-"+tippr->aktivan+"-"+tippr->fiksan+"-"+tippr->uneto+"-"+tippr->ufs)
		EventLog(nUser,goModul:oDataBase:cName,"SIF","EDITTIPPR2",nil,nil,nil,nil,"","",cStanje,Date(),Date(),"F-"+ALLTRIM(tippr->formula),"Promjena stanja sifranika tippr2")
		select tippr
		MsgC()
		return DE_REFRESH
	endif
endif

return DE_CONT
*}




// -----------------------------------------------
// -----------------------------------------------
function P_RJ(cId,dx,dy)
local nArr
nArr:=SELECT()
private imekol := {}
private kol := {}

select (F_RJ)
if (!used())
	O_RJ
endif
select (nArr)

AADD(ImeKol, { padr("Id",2), {|| id}, "id", {|| .t.}, {|| vpsifra(wid)} } )
AADD(ImeKol, { padr("Naziv",35), {||  naz}, "naz" } )

if rj->(FieldPos("TIPRADA")) <> 0
	AADD(ImeKol, { "tip rada" , {||  tiprada }, "tiprada"  } )
endif
if rj->(FieldPos("OPOR")) <> 0
	AADD(ImeKol, { "oporeziv" , {||  opor }, "opor"  } )
endif

for i:=1 to LEN(ImeKol)
	AADD(Kol, i)
next

return PostojiSifra(F_RJ, 1, 10, 55, Lokal("Lista radnih jedinica"), @cId, dx, dy)



function P_Ops(cId,dx,dy)
local nArr
local i:=0
nArr:=SELECT()
private imekol
private kol:={}

select (F_OPS)
if (!used())
	O_OPS
endif
select (nArr)

ImeKol:={ { padr("Id",2), {|| id}, "id", {|| .t.}, {|| vpsifra(wid)} },;
          { padr("IDJ",3), {||  idj}, "idj" }                       ,;
          { padr("Kan",3), {||  idKan}, "idKan" }                       ,;
          { padr("N0",3), {||  idN0}, "IdN0" }                       ,;
          { padr("Naziv",20), {||  naz}, "naz" }                       ;
       }

Kol:={}

if OPS->(fieldpos("REG"))<>0
	AADD( ImeKol, { padr("Region",20), {||  reg}, "reg" } )
endif

if OPS->(fieldpos("PNE"))<>0
	AADD( ImeKol, { padr("Bez poreza:",20), {||  pne}, "pne" } )
endif
if OPS->(fieldpos("DNE"))<>0
  	AADD( ImeKol, { padr("Bez doprinosa:",20), {||  dne}, "dne" } )
endif
if OPS->(fieldpos("AH_POR"))<>0
  	AADD( ImeKol, { padr("aut.hon.porez",20), {||  ah_por}, "ah_por" })
endif
if OPS->(fieldpos("AH_PRTR"))<>0
  	AADD( ImeKol, {padr("aut.hon.pr.trosak",20), {|| ah_prtr}, "ah_prtr" })
endif
if OPS->(fieldpos("AH_PRST"))<>0
  	AADD( ImeKol, {padr("aut.hon.pr.stopa",20), {|| ah_prst}, "ah_prst" })
endif

// dodaj specificna polja za popunu obrasca DP
if OPS->(fieldpos("ZIPCODE"))<>0
  	AADD(ImeKol,{padr("PTT br.", 7),{|| zipcode},"zipcode"})
  	AADD(ImeKol,{padr("PU sif.kant.", 12),{|| puccanton},"puccanton"})
  	AADD(ImeKol,{padr("PU kod opc.", 11),{|| puccity},"puccity"})
endif

for i:=1 to LEN(ImeKol)
	AADD(kol,i)
next
return PostojiSifra(F_OPS, 1, 10, 65, ;
 	Lokal("Lista opcina"), ;
	@cId,dx,dy)
*}


function P_Kred(cId,dx,dy)
*{
local nArr
nArr:=SELECT()
private imekol,kol

select (F_KRED)
if (!used())
	O_KRED
endif
select (nArr)

ImeKol:={ { padr("Id",6), {|| id}, "id", {|| .t.}, {|| vpsifra(wid)} },;
          { padr("Naziv",30), {||  naz}, "naz" }                       ,;
          { padr("Adresa",30)  ,{||  adresa}, "adresa" }                     ,;
          { padr("Mjesto",20)  ,{||  mjesto}, "mjesto" }                     ,;
          { padr("PTT",5)  ,{||  ptt}, "ptt" }                     ,;
          { padr("Filijala",30)  ,{||  fil}, "fil" }                     ,;
          { padr("Racun",20)  ,{||  ziro}, "ziro" }                     ,;
          { padr("Partija",20),{||  zirod}, "zirod" }                 ;
       }
// Dorade 2001
Kol:={1,2,3,4,5,6,7,8}
return PostojiSifra(F_KRED, 1, 10, 55, Lokal("Lista kreditora"), ;
	@cId, dx, dy)
*}

// -----------------------------
// -----------------------------
function KrBlok(Ch)
*{
if (Ch==K_CTRL_T)
	if ImaURadKr(KRED->id,"3")
   		Beep(1)
   		Msg(Lokal("Firma se ne moze brisati jer je vec koristena u obracunu!"))
   		return 7
 	endif
elseif (Ch==K_F2)
	if ImaURadKr(KRED->id,"3")
   		return 99
 	endif
endif

return DE_CONT
*}

// ------------------------------------------------
// ------------------------------------------------
function ImaURadKr(cKljuc,cTag)
*{
local lVrati:=.f.
local lUsed:=.t.
local nArr:=SELECT()

select (F_RADKR)

if !USED()
	lUsed:=.f.
    	O_RADKR
else
	PushWA()
endif

set order to tag (cTag)
seek cKljuc

lVrati:=Found()

if !lUsed
	use
else
	PopWA()
endif

select (nArr)

return lVrati


function ImaUObrac(cKljuc,cTag)
*{
local lVrati:=.f.
local lUsed:=.t.
local nArr:=SELECT()

select (F_LD)

if !USED()
	lUsed:=.f.
    	O_LD
else
	PushWA()
endif

set order to tag (cTag)
seek cKljuc

lVrati:=found()

if !lUsed
	use
else
    	PopWA()
endif

if !lVrati  // ako nema u LD, provjerimo ima li u 1.dijelu obracuna (smece)
	select (F_LDSM)
    	if !USED()
      		lUsed:=.f.
      		O_LDSM
    	else
      		PushWA()
    	endif
    	set order to tag (cTag)
    	seek cKljuc
    	lVrati:=Found()
    	if !lUsed
      		use
    	else
      		PopWA()
    	endif
endif
select (nArr)

return lVrati
*}

// ---------------------------------
// ---------------------------------
function P_POR(cId,dx,dy)
local nArr
local i
nArr:=SELECT()
private Imekol := {}
private Kol := {}

select (F_POR)
if (!used())
	O_POR
endif

select (nArr)

AADD(ImeKol, { padr("Id", 2), {|| id}, "id", {|| .t.}, {|| vpsifra(wid)} } )

if POR->(FIELDPOS("ALGORITAM")) <> 0
	AADD(ImeKol, { "Algor.", {|| algoritam}, "algoritam" } )
endif

AADD(ImeKol, { padr("Naziv",20), {|| naz}, "naz" })

AADD(ImeKol, { padr("Iznos",20), {||  iznos}, "iznos", {|| IF( POR->(FIELDPOS("ALGORITAM")) <> 0 , wh_oldpor(walgoritam), .t. ) } })

AADD(ImeKol, { padr("Donji limit",12), {||  dlimit}, "dlimit" })

AADD(ImeKol, { padr("PoOpst",6), {||  poopst}, "poopst" })

// nove stope i iznosi....
if POR->(FIELDPOS("ALGORITAM")) <> 0

	AADD(ImeKol, { "p.tip", {|| por_tip}, "por_tip", {|| .t.}, {|| v_dop_tip(wpor_tip)} } )
	AADD(ImeKol, { "St.1", {|| s_sto_1}, "s_sto_1", {|| wh_por(walgoritam)} } )
	AADD(ImeKol, { "Izn.1", {|| s_izn_1}, "s_izn_1", {|| wh_por(walgoritam) } } )
	AADD(ImeKol, { "St.2", {|| s_sto_2}, "s_sto_2", {|| wh_por(walgoritam)} } )
	AADD(ImeKol, { "Izn.2", {|| s_izn_2}, "s_izn_2", {|| wh_por(walgoritam)} } )
	AADD(ImeKol, { "St.3", {|| s_sto_3}, "s_sto_3", {|| wh_por(walgoritam)} } )
	AADD(ImeKol, { "Izn.3", {|| s_izn_3}, "s_izn_3", {|| wh_por(walgoritam)} } )
	AADD(ImeKol, { "St.4", {|| s_sto_4}, "s_sto_4", {|| wh_por(walgoritam)} } )
	AADD(ImeKol, { "Izn.4", {|| s_izn_4}, "s_izn_4", {|| wh_por(walgoritam)} } )
	AADD(ImeKol, { "St.5", {|| s_sto_5}, "s_sto_5", {|| wh_por(walgoritam)} } )
	AADD(ImeKol, { "Izn.5", {|| s_izn_5}, "s_izn_5", {|| wh_por(walgoritam)} } )
	
endif

for i:=1 to LEN(ImeKol)
	AADD(Kol, i)
next

PushWa()

select (F_SIFK)

O_SIFK
O_SIFV
select sifk
set order to tag "ID"
seek "POR"

do while !eof() .and. ID="POR"
	AADD (ImeKol, {  IzSifKNaz("POR",SIFK->Oznaka) })
	AADD (ImeKol[Len(ImeKol)], &( "{|| ToStr(IzSifk('POR','" + sifk->oznaka + "')) }" ) )
	AADD (ImeKol[Len(ImeKol)], "SIFK->"+SIFK->Oznaka )

	if (sifk->edkolona>0)
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
	if (sifk->Tip="N")
		if (decimal>0)
     			ImeKol[Len(ImeKol),7] := replicate("9", sifk->duzina - sifk->decimal-1 )+"."+replicate("9",sifk->decimal)
   		else
     			ImeKol[Len(ImeKol),7] := replicate("9", sifk->duzina )
   		endif
	endif

	AADD(Kol, iif( sifk->UBrowsu='1',++i, 0) )
	skip
enddo

PopWa()
return PostojiSifra(F_POR, 1, 10, 75, ;
        Lokal("Lista poreza na platu.....<F5> arhiviranje poreza, <F6> pregled"), ;
	@cId,dx,dy,{|Ch| PorBl(Ch)})


// -------------------------------
// when porez
// -------------------------------
function wh_por( cAlg )
local lRet := .f.

if cAlg == "S"
	lRet := .t.
endif

return lRet


// -------------------------------
// when stari porez
// -------------------------------
function wh_oldpor( cAlg )
local lRet := .f.

if EMPTY(cAlg) .or. cAlg <> "S"
	lRet := .t.
endif

return lRet



function P_DOPR(cId,dx,dy)
*{
local nArr
nArr:=SELECT()
private imekol := {}
private kol := {}

select (F_SIFK)
if !used()
	O_SIFK
endif
select (F_SIFV)
if !used()
	O_SIFV
endif
select (F_DOPR)
if !used()
	O_DOPR
endif
select (nArr)

AADD(ImeKol, { padr("Id",2), {|| id}, "id" } )
AADD(ImeKol, { padr("Naziv",20), {||  naz}, "naz" } )
AADD(ImeKol, { padr("Iznos",20), {||  iznos}, "iznos" } )

if DOPR->(FIELDPOS("DOP_TIP")) <> 0
	AADD(ImeKol, { padr("d.tip", 6), {||  dop_tip}, "dop_tip", {|| .t.}, {|| v_dop_tip(wdop_tip) } }  )
endif

if DOPR->(FIELDPOS("TIPRADA")) <> 0
	AADD(ImeKol, { padr("tip rada", 10), {|| tiprada}, "tiprada", {|| .t.}, {|| wtiprada $ " #I#S#N#P#U#A#R" .or. MsgTipRada() } }  )
endif

AADD(ImeKol, { padr("KBenef",5), {|| padc(idkbenef,5)}, "idkbenef", {|| .t.}, {|| empty(widkbenef) .or. P_KBenef(@widkbenef) } } )
AADD(ImeKol, { padr("Donji limit",12), {||  dlimit}, "dlimit" } )
AADD(ImeKol, { padr("PoOpst",6), {||  poopst}, "poopst" }  )


for i:=1 to LEN(ImeKol)
	AADD(Kol, i)
next

PushWa()

select (F_SIFK)

O_SIFK
O_SIFV

select sifk
set order to tag "ID"
seek "DOPR"

do while !eof() .and. ID="DOPR"
	AADD(ImeKol,{IzSifKNaz("DOPR",SIFK->Oznaka)})
 	AADD(ImeKol[Len(ImeKol)], &( "{|| ToStr(IzSifk('DOPR','" + sifk->oznaka + "')) }" ) )
 	AADD(ImeKol[Len(ImeKol)], "SIFK->"+SIFK->Oznaka )
 	if (sifk->edkolona>0)
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
 	if (sifk->tip="N")
   		if (decimal>0)
     			ImeKol[LEN(ImeKol),7] := replicate("9", sifk->duzina - sifk->decimal-1 )+"."+replicate("9",sifk->decimal)
   		else
     			ImeKol[LEN(ImeKol),7] := replicate("9", sifk->duzina )
   		endif
 	endif
	AADD  (Kol, iif( sifk->UBrowsu='1',++i, 0) )
	skip
enddo

PopWa()
return PostojiSifra(F_DOPR, 1, 10, 75, ;
	Lokal("Lista doprinosa na platu......<F5> arhiviranje doprinosa, <F6> pregled"), ;
	@cId,dx,dy,{|Ch| DoprBl(Ch)})




// --------------------------------
// --------------------------------
function P_KBenef(cId,dx,dy)
*{
local nArr
nArr:=SELECT()
private imekol
private kol

select (F_KBENEF)
if (!used())
	O_KBENEF
endif
select (nArr)

ImeKol:={ { padr("Id",3), {|| padc(id,3)}, "id", {|| .t.}, {|| vpsifra(wid)} },;
          { padr("Naziv",8), {||  naz}, "naz" }                      , ;
          { padr("Iznos",5), {||  iznos}, "iznos" }                       ;
       }
Kol:={1,2,3}
return PostojiSifra(F_KBENEF, 1, 10, 55, ;
	Lokal("Lista koef.beneficiranog radnog staza"), ;
	@cId,dx,dy)
*}



function P_StrSpr(cId,dx,dy)
*{
local nArr
nArr:=SELECT()
private imekol,kol

select (F_STRSPR)
if (!used())
	O_STRSPR
endif
select (nArr)

ImeKol:={ { padr("Id",3), {|| id}, "id", {|| .t.}, {|| vpsifra(wid)} },;
          { padr("Naziv",20), {||  naz}, "naz" }                    , ;
          { padr("naz2",6), {|| naz2}, "naz2" }                     ;
       }
Kol:={1,2,3}
return PostojiSifra( F_STRSPR, 1, 10, 55, ;
	Lokal("Lista: strucne spreme"), ;
	@cId,dx,dy)
*}


function P_VPosla(cId,dx,dy)
*{
local nArr
nArr:=SELECT()
private imekol
private kol

select (F_VPOSLA)
if (!used())
	O_VPOSLA
endif
select (nArr)

ImeKol:={ { padr("Id",2), {|| id}, "id", {|| .t.}, {|| vpsifra(wid)} },;
          { padr("Naziv",20), {||  naz}, "naz" }                    , ;
          { padr("KBenef",5), {|| padc(idkbenef,5)}, "idkbenef", {|| .t.}, {|| P_KBenef(@widkbenef) }  }  ;
       }
Kol:={ 1,2,3}
return PostojiSifra(F_VPOSLA, 1, 10, 55, ;
	Lokal("Lista: Vrste posla"), ;
	@cId,dx,dy)
*}


// ----------------------------------------------
// sifrarnik izdanja
// ----------------------------------------------
function P_Izdanja(cId,dx,dy)
local i
local nArr
nArr:=SELECT()
private imekol := {}
private kol := {}

select (F_IZDANJA)
if (!used())
	O_IZDANJA
endif
select (nArr)

ImeKol:={ { padr("Id",10), {|| id}, "id", {|| .t.}, {|| vpsifra(wid)} }, ;
          { padr("Naziv",20), {||  iz_naz}, "iz_naz" }, ;
          { padr("broj",10), {|| iz_broj}, "iz_broj"  }, ;
          { padr("datum",8), {|| iz_datum}, "iz_datum"  } }

for i:=1 to LEN(ImeKol)
	AADD(Kol, i)
next

return PostojiSifra(F_IZDANJA,1,10,55,"Autorski honorari: lista izdanja",@cId,dx,dy)




function P_NorSiht(cId,dx,dy)
*{
local nArr
nArr:=SELECT()
private imekol
private kol

select (F_NORSIHT)
if (!used())
	O_NORSIHT
endif
select (nArr)

ImeKol:={ { padr("Id",4), {|| id}, "id", {|| .t.}, {|| vpsifra(wid)} },;
          { padr("Naziv",20), {||  naz}, "naz" }                    , ;
          { padr("JMJ",3), {|| padc(jmj,3)}, "jmj"  } , ;
          { padr("Iznos",8), {|| Iznos}, "Iznos"  }  ;
       }
Kol:={1,2,3,4}
return PostojiSifra(F_NORSIHT,1,10,55,"Lista: Norme u sihtarici",@cId,dx,dy)
*}



function P_TPRSiht(cId,dx,dy)
*{
local nArr
nArr:=SELECT()
private imekol
private kol

select (F_TPRSIHT)
if (!used())
	O_TPRSIHT
endif
select (nArr)

ImeKol:={ { padr("Id",4), {|| id}, "id", {|| .t.}, {|| vpsifra(wid)} },;
          { padr("Naziv",30), {||  naz}, "naz" }                    , ;
          { padC("K1",3), {|| padc(K1,3)}, "k1"  }  ;
       }
Kol:={1,2,3}
return PostojiSifra(F_TPRSIHT,1,10,55,"Lista: Tipovi primanja u sihtarici",@cId,dx,dy)
*}



function TotBrisRadn()
*{
local cSigurno:="N"
local nRec
private cIdRadn:=SPACE(6)

if !SigmaSif("SIGMATB ")
	return
endif

O_RADN         // id, "1"
O_RADKR        // idradn, "2"
O_LD           // idradn, "RADN"
O_LDSM         // idradn, "RADN"

Box(,7,75)
	@ m_x+ 0, m_y+ 5 SAY Lokal("TOTALNO BRISANJE RADNIKA IZ EVIDENCIJE")
 	@ m_x+ 8, m_y+20 SAY Lokal("<F5> - trazenje radnika pomocu sifrarnika")
 	set key K_F5 TO TRUSif()
 	do while .t.
    		BoxCLS()
    			if cSigurno=="D"
      				cIdRadn:=SPACE(6)
      				cSigurno:="N"
    			endif
    			@ m_x+2, m_y+2 SAY Lokal("Radnik") GET cIdRadn PICT "@!"
    			@ m_x+6, m_y+2 SAY "Sigurno ga zelite obrisati (D/N) ?" GET cSigurno WHEN PrTotBR(cIdRadn) VALID cSigurno$"DN" PICT "@!"
    			read
    			if (LastKey()==K_ESC)
				EXIT
			endif
    			if cSigurno!="D"
				LOOP
			endif
    			// brisem ga iz sifrarnika radnika
    			// -------------------------------
      			select (F_RADN)
			set order to tag "1"
			go top
      			seek cIdRadn
      			do while !eof() .and. id==cIdRadn
        			skip 1
				nRec:=RecNo()
				skip -1
				delete
				go (nRec)
      			enddo
    			// brisem ga iz baze kredita
    			// -------------------------
      			select (F_RADKR)
			set order to tag "2"
			go top
      			seek cIdRadn
      			do while !eof() .and. idradn==cIdRadn
        			skip 1
				nRec:=RecNo()
				skip -1
				DELETE
				go (nRec)
      			enddo
    			// brisem ga iz baze obracuna
    			// --------------------------
      			select (F_LD)
			set order to tag "RADN"
			go top
      			seek cIdRadn
      			do while !eof() .and. idradn==cIdRadn
        			skip 1
				nRec:=RecNo()
				skip -1
				DELETE
				go (nRec)
      			enddo
    			// brisem ga iz baze obracuna u smecu
    			// ----------------------------------
      			select (F_LDSM)
			set order to tag "RADN"
			go top
      			seek cIdRadn
      			do while !eof() .and. idradn==cIdRadn
        			skip 1
				nRec:=RecNo()
				skip -1
				DELETE
				go (nRec)
      			enddo
	enddo
 	set key K_F5 to
BoxC()
CLOSERET
*}


function PrTotBr(cIdRadn)
*{
local cBI:="W+/G"

select (F_RADN)
set order to tag "1" 
go top
seek cIdRadn

select (F_RADKR)
set order to tag "2"  
go top
seek cIdRadn

cKljuc:=STR(godina,4)+STR(mjesec,2)

do while !eof() .and. idradn==cIdRadn
	if (cKljuc<STR(godina,4)+STR(mjesec,2))
      		cKljuc:=STR(godina,4)+STR(mjesec,2)
    	endif
    	skip 1
enddo
skip -1

SELECT (F_LD)   ; SET ORDER TO TAG "RADN"; GO TOP; SEEK cIdRadn
cKljuc:=STR(godina,4)+STR(mjesec,2)
DO WHILE !EOF() .and. idradn==cIdRadn
	IF cKljuc < STR(godina,4)+STR(mjesec,2)
      		cKljuc:=STR(godina,4)+STR(mjesec,2)
    	ENDIF
    	SKIP 1
ENDDO
SKIP -1

SELECT (F_LDSM) ; SET ORDER TO TAG "RADN"; GO TOP; SEEK cIdRadn
cKljuc:=STR(godina,4)+STR(mjesec,2)
DO WHILE !EOF() .and. idradn==cIdRadn
	IF cKljuc < STR(godina,4)+STR(mjesec,2)
      		cKljuc:=STR(godina,4)+STR(mjesec,2)
    	ENDIF
    	SKIP 1
ENDDO
SKIP -1

@ m_x+3, m_y+1 CLEAR TO m_x+5, m_y+75
@ m_x+3, m_y+ 2 SAY "PREZIME I IME:"
@ m_x+3, m_y+17 SAY IF(RADN->id==cIdRadn,RADN->(TRIM(naz)+" ("+TRIM(imerod)+") "+TRIM(ime)),"nema podatka") COLOR cBI
@ m_x+4, m_y+ 2 SAY "POSLJEDNJI OBRACUN:"
@ m_x+4, m_y+22 SAY IF(LD->idradn==cIdRadn,STR(LD->mjesec,2)+"/"+STR(LD->godina,4),"nema podatka") COLOR cBI
@ m_x+4, m_y+35 SAY "RJ:"
@ m_x+4, m_y+39 SAY IF(LD->idradn==cIdRadn,LD->idrj,"nema podatka") COLOR cBI
@ m_x+5, m_y+ 2 SAY "POSLJEDNJA RATA KREDITA:"
@ m_x+5, m_y+27 SAY IF(RADKR->idradn==cIdRadn,STR(RADKR->mjesec,2)+"/"+STR(RADKR->godina,4),"nema podatka") COLOR cBI

RETURN IF(RADN->id==cIdRadn.or.LD->idradn==cIdRadn.or.;
          LDSM->idradn==cIdRadn.or.RADKR->idradn==cIdRadn,.t.,.f.)

*}



function TRUSif()
*{
if READVAR()=="CIDRADN"
	P_Radn(@cIdRadn)
    	KEYBOARD CHR(K_ENTER)+CHR(K_UP)
endif
return
*}


function P_Banke(cId,dx,dy)
*{
local nArr
nArr:=SELECT()
private imekol,kol

select (F_BANKE)
if (!used())
	O_BANKE
endif
select (nArr)

ImeKol:={ { padr("Id",2), {|| id}, "id", {|| .t.}, {|| vpsifra(wid)} },;
          { "Naziv", {||  naz}, "naz" }                      ,;
          { "Mjesto", {|| mjesto}, "mjesto" }                ;
       }
Kol:={1,2,3}
return PostojiSifra(F_BANKE, 1, 10, 55,;
	Lokal("Lista banaka"), ;
	@cId,dx,dy)
*}



function PorBl(Ch)
*{
local nVrati:=DE_CONT
local nRec:=RecNo()
private GetList:={}

do case
	case Ch==K_F5
      	// pitati za posljednji mjesec
      	cMj:=gMjesec
     	cGod:=gGodina
      	Box("#PROMJENA POREZA U TOKU GODINE",4,60)
        	@ m_x+2, m_y+2 SAY "Posljednji mjesec po starim porezima:" GET cMj VALID cMj>0 .and. cMj<13
        	@ m_x+3, m_y+2 SAY "Godina: "+STR(cGod)
        	read
        	if LastKey()==K_ESC
			BoxC()
			return nVrati
		endif
      	BoxC()
      	
	// formiraj imena direktorija
      	cPodDir:=PADL(ALLTRIM(STR(cMj)),2,"0")+STR(cGod,4)
      	cPath:=SIFPATH
      	aIme:={ "POR.DBF" , "POR.CDX" }
      	// zatvaram POR.DBF
      	select POR
      	use
      	// napraviti direktorij i iskopirati POR.* u njega
      	DirMake(cPath+cPodDir)
      	lKopirano:=.f.
      	for i:=1 to LEN(aIme)
        	if File(cPath+cPodDir+SLASH+aIme[i])
          		MsgBeep("Fajl "+aIme[i]+" vec postoji u "+cpath+cPodDir+" !"+"#Ukoliko ga sada zamijenite necete ga moci vratiti!")
          		if Pitanje(,"Zelite li ga zamijeniti?","N")=="N"
            			LOOP
          		endif
        	endif
        	lKopirano:=.t.
        	FileCopy(cPath+aIme[i],cPath+cPodDir+SLASH+aIme[i])
      	next
	// otvaram POR.DBF
      	O_POR
      	go (nRec)

      	// poruka: mozete definisati nove poreze
      	if lKopirano
        	MsgBeep("Stari porezi su smjesteni u podrucje "+cPodDir+"#Nakon ovoga mozete definisati nove poreze.")
      	endif

	case Ch==K_F6
      	// meni sezona
      	cPath:=SIFPATH
      	cGodina:=gGodina
      	Box(,3,30)
        	@ m_x+2, m_y+2 SAY "Godina:" GET cGodina PICT "9999"
        	READ
      	BoxC()
      	IF LASTKEY()==K_ESC
		RETURN nVrati
	ENDIF
      	cGodina:=STR(cGodina,4,0)
      	aSez := ASezona2(cPath,cGodina,"POR.DBF")
      	IF EMPTY(aSez)
        	MsgBeep("Ne postoje sezone promjena poreza u "+cGodina+". godini!")
        	RETURN nVrati
      	ELSE
        	// meni sezona - aSez
        	// ------------------
        	FOR i:=1 TO LEN(aSez)
          		aSez[i] := PADR( aSez[i,1]+" - "+NazMjeseca(VAL(LEFT(aSez[i,1],2))) , 73)
        	NEXT
        	h:=ARRAY(LEN(aSez)); AFILL(h,"")
        	Box("#SEZONE PRED PROMJENU POREZA U "+cGodina+".GODINI: อออออ <Enter>-izbor ",MIN(LEN(aSez),16)+3,77)
         		@ m_x+1, m_y+2 SAY PADC("M J E S E C",75)
         		@ m_x+2, m_y+2 SAY REPL("ฤ",75)
         		nPom := 1
         		@ row()-1, col()-6 SAY ""
         		nPom := Menu("SPME",aSez,nPom,.f.,,,{m_x+2,m_y+1})
         		IF nPom>0
           			Menu("SPME",aSez,0,.f.)
         		ENDIF
        	BoxC()
        	IF nPom>0
          		cPorDir := LEFT( aSez[nPom] , 6 )
        	ELSE
          		RETURN nVrati
        	ENDIF
      	ENDIF
      	
	// otvaranje sezonske baze
      	SELECT (F_POR)
	USE
      	USE (cPath+cPorDir+SLASH+"POR") 
	SET ORDER TO TAG "ID"
      	GO TOP
      	@ m_x+11, m_y+2 SAY "Porezi koji su vazili zakljucno sa (MMGGGG):"+cPorDir
      	KEYBOARD CHR(K_CTRL_PGUP)
      	nVrati:=DE_REFRESH

endcase

return nVrati
*}


// ------------------------------------
// ------------------------------------
function DoprBl(Ch)
*{
local nVrati:=DE_CONT
local nRec:=RECNO()

DO CASE
    CASE Ch==K_F5

      // pitati za posljednji mjesec
      // ---------------------------
      cMj  := gMjesec
      cGod := gGodina
      private GetList:={}
      Box( Lokal("#PROMJENA DOPRINOSA U TOKU GODINE"), 4, 60)
        @ m_x+2, m_y+2 SAY Lokal("Posljednji mjesec po starim doprinosima:") GET cMj VALID cMj>0 .and. cMj<13
        @ m_x+3, m_y+2 SAY "Godina: "+STR(cGod)
        READ
        IF LASTKEY()==K_ESC; BoxC(); RETURN nVrati; ENDIF
      BoxC()

      // formiraj imena direktorija
      // --------------------------
      cPodDir := PADL(ALLTRIM(STR(cMj)),2,"0")+STR(cGod,4)
      cPath:=SIFPATH
      aIme := { "DOPR.DBF" , "DOPR.CDX" }

      // zatvaram DOPR.DBF
      // -----------------
      SELECT DOPR
      USE

      // napraviti direktorij i iskopirati DOPR.* u njega
      // -------------------------------------------------
      DIRMAKE(cPath+cPodDir)
      lKopirano:=.f.
      FOR i:=1 TO LEN(aIme)
        IF FILE(cpath+cPodDir+"\"+aIme[i])
          MsgBeep("Fajl "+aIme[i]+" vec postoji u "+cpath+cPodDir+" !"+;
                  "#Ukoliko ga sada zamijenite necete ga moci vratiti!")
          IF Pitanje(,"Zelite li ga zamijeniti?","N")=="N"
            LOOP
          ENDIF
        ENDIF
        lKopirano:=.t.
        FILECOPY( cPath+aIme[i] , cpath+cPodDir+"\"+aIme[i] )
      NEXT

      // otvaram DOPR.DBF
      // ----------------
      O_DOPR
      GO (nRec)

      // poruka: mozete definisati nove doprinose
      // ----------------------------------------
      IF lKopirano
        MsgBeep("Stari doprinosi su smjesteni u podrucje "+cPodDir+"#Nakon ovoga "+;
                "mozete definisati nove doprinose.")
      ENDIF

    CASE Ch==K_F6
      // meni sezona
      cPath   := SIFPATH
      cGodina := gGodina
      private GetList:={}
      Box(,3,30)
        @ m_x+2, m_y+2 SAY "Godina:" GET cGodina PICT "9999"
        READ
      BoxC()
      IF LASTKEY()==K_ESC; RETURN nVrati; ENDIF
      cGodina:=STR(cGodina,4,0)
      aSez := ASezona2(cPath,cGodina,"DOPR.DBF")
      IF EMPTY(aSez)
        MsgBeep("Ne postoje sezone promjena doprinosa u "+cGodina+". godini!")
        RETURN nVrati
      ELSE
        // meni sezona - aSez
        // ------------------
        FOR i:=1 TO LEN(aSez)
          aSez[i] := PADR( aSez[i,1]+" - "+NazMjeseca(VAL(LEFT(aSez[i,1],2))) , 73)
        NEXT
        h:=ARRAY(LEN(aSez)); AFILL(h,"")
        Box("#SEZONE PRED PROMJENU DOPRINOSA U "+cGodina+".GODINI: อออออ <Enter>-izbor ",MIN(LEN(aSez),16)+3,77)
         @ m_x+1, m_y+2 SAY PADC("M J E S E C",75)
         @ m_x+2, m_y+2 SAY REPL("ฤ",75)
         nPom := 1
         @ row()-1, col()-6 SAY ""
         nPom := Menu("SDME",aSez,nPom,.f.,,,{m_x+2,m_y+1})
         IF nPom>0
           Menu("SDME",aSez,0,.f.)
         ENDIF
        BoxC()
        IF nPom>0
          cDoprDir := LEFT( aSez[nPom] , 6 )
        ELSE
          RETURN nVrati
        ENDIF
      ENDIF

      // otvaranje sezonske baze
      SELECT (F_DOPR); USE
      USE (cPath+cDoprDir+"\DOPR") ; SET ORDER TO TAG "ID"
      GO TOP
      @ m_x+11, m_y+2 SAY "Doprinosi koji su vazili zakljucno sa (MMGGGG):"+cDoprDir
      KEYBOARD CHR(K_CTRL_PGUP)
      nVrati:=DE_REFRESH

ENDCASE

return nVrati
*}


