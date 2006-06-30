#include "\cl\sigma\fmk\virm\virm.ch"

function PrenosKalk()
*{
gUVarPP:=IzFmkIni("POREZI","PPUgostKaoPPU","T",KUMPATH)
cPNaBr:=IzFmkIni("KALKVIRM","PozivNaBr"," ", KUMPATH)
cPnabr:=padr(cPnabr,10)
cVUPL:=IzFmkIni("KALKVIRM","VrstaUplate"," ", KUMPATH)
cVUPL:=padr(cVUPL,1)
qqIDVD:="42;"
dDatOd:=Date()
dDatDo:=Date()
dDatVir:=Date()
O_PARTN
O_SIFK
O_SIFV
O_BANKE
O_PARAMS
O_KALK
O_TARIFA
O_JPRIH
O_KALVIR
O_VRPRIM
O_PRIPR

select params
private cSection:="2"
private cHistory:=" "
private aHistory:={}

Rpar("01",@qqIDVD)
Rpar("02",@dDatOd)
Rpar("03",@dDatDo)
Rpar("04",@dDatVir)
UsTipke()
set cursor on
qqIDVD := PADR(qqIDVD,80)

select partn

do while .t.
	Box(,7,70)
		@ m_x+ 0, m_y+ 2 SAY "P R E N O S   I Z   K A L K"
    		cKo_zr:=space(3)
    		cIdBanka:=padr(cko_zr,3)
    		@ m_x+2,m_y+2 SAY "Posiljaoc (sifra banke):       " GET cIdBanka valid  OdBanku(gFirma,@cIdBanka)
    		read
    		cKo_zr:=cIdBanka
    		select partn
		seek gFirma
    		cKo_txt:=trim(partn->naz) + ", " + trim(partn->mjesto)+", "+trim(partn->adresa) + ", " + trim(partn->telefon)
		@ m_x+ 3, m_y+ 2 SAY "Poziv na broj " GET cPNABR
    		@ m_x+ 3, col()+4 SAY "Vrsta uplate " GET cVUPL
    		@ m_x+ 4, m_y+ 2 SAY "Uslov za vrstu dok." GET qqIDVD PICT "@!S20"
    		@ m_x+ 5, m_y+ 2 SAY "Dokum. za period od" GET dDatOd
    		@ m_x+ 5, col()+2 SAY "do" GET dDatDo
    		@ m_x+ 6, m_y+ 2 SAY "Datum virmana      " GET dDatVir
    		read
		ESC_BCR
  		if LastKey()==K_ESC
  			return
  		endif
  	BoxC()
  	aUsl1:=Parsiraj(qqIDVD,"IDVD")
  	if aUsl1<>nil
		EXIT
	endif
enddo

UzmiIzIni(KUMPATH+"fmk.ini","KALKVIRM","PozivNaBr",cPNaBr, "WRITE")
UzmiIzIni(KUMPATH+"fmk.ini","KALKVIRM","VrstaUplate",cVUPL, "WRITE")

qqIDVD:=TRIM(qqIDVD)
BosTipke()

select params

if lastkey()<>K_ESC
  Wpar("01",qqIDVD)
  Wpar("02",dDatOd)
  Wpar("03",dDatDo)
  Wpar("04",dDatVir)
  select params; use
endif
use


cFilter:=aUsl1

cFilter += ".and. DatDok>="+cm2str(dDatOd)+".and. DatDok<="+cm2str(dDatDo)

// postavljamo filter na vrstu i datum dokumenata u KALK.DBF
// ---------------------------------------------------------
SELECT KALK
SET FILTER TO &cFilter

// napravimo praznu POM.DBF
// ------------------------
CrePom()

// ubacimo u POM.DBF stavke iz KALVIR.DBF
// --------------------------------------
PRIVATE c77, qqRoba, qqKonto, qqIzraz, lSamoPripremi:=.t.
SELECT KALVIR
GO TOP
DO WHILE !EOF()
  qqRoba:=".f."; qqKonto:=".f."; qqIzraz:="0"
  SELECT POM
    APPEND BLANK
      c77 := TRIM(KALVIR->formula)
      c77 := &c77    // samo da se izvrÁi f-ja IzKalk() ako je ima
      REPLACE IDVRPRIM WITH KALVIR->id ,;
              ROBA     WITH qqRoba     ,;
              KONTO    WITH qqKonto    ,;
              IZRAZ    WITH qqIzraz    ,;
              PNABR    WITH IF(KALVIR->(FIELDPOS("pnabr"))<>0,KALVIR->pnabr,"")
  SELECT KALVIR
  SKIP 1
ENDDO

lSamoPripremi:=.f.

PRIVATE cRoba, cKonto, cIzraz

// popunimo POM.DBF iz KALK.DBF
// ----------------------------
SELECT KALK
GO TOP
DO WHILE !EOF()     // idi po KALK-u
  SELECT TARIFA
  HSEEK KALK->idtarifa
  SELECT POM
  GO TOP
  DO WHILE !EOF()     // idi po POM-u
    cRoba  := ROBA
    cKonto := KONTO
    cIzraz := IZRAZ
    IF KALK->(&cRoba .and. &cKonto)
      private nPRUC:=0
      KALK->(Proracun())
      REPLACE iznos WITH iznos+KALK->(&cIzraz)
    ENDIF
    SKIP 1
  ENDDO
  SELECT KALK
  SKIP 1
ENDDO

//cDOpis   := "OD "+DTOC(dDatOd)+" DO "+DTOC(dDatDo)
cDOpis:=""

// sad pravimo PRIPR.DBF od POM.DBF
// --------------------------------
SELECT POM
GO TOP
DO WHILE !EOF()

  cSvrha_pl := idvrprim
  nFormula  := ROUND( iznos , 2 )
  select VRPRIM; hseek cSvrha_pl
  select PARTN ; hseek gFirma

  select PRIPR; GO BOTTOM
  nRbr := rbr

  IF nFormula>0

    APPEND BLANK
    replace rbr with ++nrbr, ;
            mjesto with gmjesto,;
            svrha_pl with csvrha_pl,;
            iznos with nFormula ,;
            POD with dDatOd ,;
            PDO with dDatDo

            //orgjed with gorgjed,;

    replace na_teret  with gFirma,;
            Ko_Txt with cko_txt,;
            Ko_ZR with cKo_zr ,;
            kome_txt with VRPRIM->naz

            //nacpl with VRPRIM->nacin_pl, ;


    cPomOpis := trim(VRPRIM->pom_txt)+IF(!EMPTY(cDOpis)," "+cDOpis,"")

    if vrprim->idpartner="JP  " // javni prihodi
       cBPO    := gOrgJed  // iskoristena za broj poreskog obveznika
       IF EMPTY(POM->pnabr)
         ckPNABR := cPNABR
       ELSE
         ckPNABR := POM->pnabr
       ENDIF
       ckVUPL  := cVUPL
    else
       cBPO    := ""
       ckPNABR := ""
       ckVUPL  := ""
    endif

    replace kome_zr with VRPRIM->racun,;
            dat_upl with dDatVir,;
            svrha_doz with cPomOpis,;
            BPO with cBPO,;
            PnaBR with ckPNABR,;
            VUPL with ckVUPL

            //sifra with VRPRIM->sifra
            //dat_dpo with dDatVir,;

    //if nacpl=="2"
    //       replace ko_zr with partn->dziror
    //endif

  ENDIF

  SELECT POM
  SKIP 1
ENDDO


FillJprih()


CLOSERET


// --------------------------------------
// cRoba : uslov za obuhvatanje artikala
// cKonto: uslov za obuhvatanje konta
// cIzraz: izraz za utvr–ivanje iznosa
// cMP   : "M"-magacin ili "P"-prodavnica
// cRT   : prvi parametar je uslov za "R"-roba , "T" tarifa
// ----------------------------------------------------------
function IzKalk(cRoba,cKonto,cIzraz,cMP,cRT)
  IF cKonto==NIL; cKonto:=".f."; ENDIF
  IF cRoba==NIL; cRoba:=".f."; ENDIF
  IF cMP==NIL; cMP:="P"; ENDIF
  if cRT==NIL; cRT:="R"; ENDIF
  IF cIzraz==NIL; cIzraz:="MPCSAPP*KOLICINA"; ENDIF
  IF lSamoPripremi
    IF cRoba<>".f."
      if cRT=="R"
        qqRoba  := Parsiraj(cRoba,"IDROBA")
      else
        qqRoba  := Parsiraj(cRoba,"IDTarifa")
      endif
    ENDIF
    IF cKonto<>".f."
      qqKonto := Parsiraj(cKonto,cMP+"KONTO")
    ENDIF
    qqIzraz:=cIzraz
  ENDIF
RETURN 0


********************
function CrePom()
*
********************
select (F_POM); USE
// kreiranje pomocne baze POM.DBF
// ------------------------------
cPom:=PRIVPATH+"POM"
  IF ferase(PRIVPATH+"POM.DBF")==-1
    MsgBeep("Ne mogu izbrisati POM.DBF!")
    ShowFError()
  ENDIF
  IF ferase(PRIVPATH+"POM.CDX")==-1
    MsgBeep("Ne mogu izbrisati POM.CDX!")
    ShowFError()
  ENDIF
  // ferase(cPom+".CDX")
aDbf := {}
AADD(aDBf,{ 'IDVRPRIM'    , 'C' , LEN(VRPRIM->id) ,  0 })
AADD(aDBf,{ 'ROBA'        , 'C' ,150 ,  0 })
AADD(aDBf,{ 'KONTO'       , 'C' ,150 ,  0 })
AADD(aDBf,{ 'IZRAZ'       , 'C' ,150 ,  0 })
AADD(aDBf,{ 'IZNOS'       , 'N' , 22 ,  9 })
AADD(aDBf,{ 'PNABR'       , 'C' , 10 ,  0 })
DBCREATE2 (cPom, aDbf)
USEX (cPom)
INDEX ON IDVRPRIM TAG "1"
SET ORDER TO TAG "1" ; GO TOP
RETURN .T.

// PPP
FUNC PMP1()
RETURN (KOLICINA*KALK->mpc*TARIFA->opp/100)

// PPU
FUNC PMP2()
RETURN (KOLICINA*KALK->mpc*(1+TARIFA->opp/100)*TARIFA->ppp/100)

// PP
FUNC PMP3()
RETURN (KOLICINA*KALK->mpc*(1+TARIFA->opp/100)*TARIFA->zpp/100)



function PorRUCMP()
*{
local nV:=0
nV:=round(nPRUC*(Kolicina-GKolicina-GKolicin2),gZaokr)
return nV
*}


function PorPP()
*{
local nV:=0
if gUVarPP$"MT"
	nV:=round(mpcsapp*(kolicina-gkolicina-gkolicin2)*_opp/(1+_opp),gZaokr)
else
	nV:=round(_OPP*MPC*(kolicina-gkolicina-gkolicin2),gZaokr)
endif
return nV
*}


function PorPU()
*{
local nV:=0
nV:=round(_PPP*(1+_OPP)*MPC*(Kolicina-GKolicina-GKolicin2),gZaokr)
return nV
*}


function PorP()
*{
local nV:=0
nV:=round(_zpp*(mpcsapp-nPRUC)*(Kolicina-GKolicina-GKolicin2),gZaokr)
return nV
*}



function Proracun()
*{
local cIdVd, nPom
local lKontPRUCMP

private nPrevoz,nCarDaz,nZavTr,nBankTr,nSpedTr,nMarza,nMarza2
nFV:=FCj*Kolicina
SKol:=Kolicina
KTroskovi()
VtPorezi()
cIdVd:=kalk->idvd
lKontPRUCMP:=(gUVarPP$"MJRT")

if (lKontPRUCMP .and. cIdVd $ "41#42#81" .and. _mpp<>0)
	if (gUVarPP$"T")
		nPRUC:=MAX(mpcsapp-nc-PPPMP(),mpcsapp*_dlruc)*_mpp/(1+_mpp)
	elseif (gUVarPP$"R")
		nPom    := nMarza2
		nPRUC   := MAX( mpcsapp*_dlruc , nPom ) *_mpp/(1+_mpp)
		nMarza2 := nPom-nPRUC
	elseif (gUVarPP$"MJ")
		nPRUC:=PPUMP()
	endif
else
	nPRUC:=0
endif
return
*}



function VTPOREZI()
*{
public _ZPP:=0
public _OPP:=tarifa->opp/100
public _PPP:=tarifa->ppp/100
public _ZPP:=tarifa->zpp/100
public _PORVT:=0
if tarifa->(FIELDPOS("MPP")<>0)
	public _MPP   := tarifa->mpp/100
	public _DLRUC := tarifa->dlRuc/100
else
	public _MPP   := 0
	public _DLRUC := 0
endif
return
*}



/*! \fn KTroskovi()
 *  \brief Proracun iznosa troskova pri unosu u pripremi
 */

function KTroskovi()
*{
local Skol:=0,nPPP:=0

Skol:=Kolicina

nPPP:=1

if TPrevoz=="%"
  nPrevoz:=Prevoz/100*FCj2
elseif TPrevoz=="A"
  nPrevoz:=Prevoz
elseif TPrevoz=="U"
  if skol<>0
   nPrevoz:=Prevoz/SKol
  else
   nPrevoz:=0
  endif
else
  nPrevoz:=0
endif

if TCarDaz=="%"
  nCarDaz:=CarDaz/100*FCj2
elseif TCarDaz=="A"
  nCarDaz:=CarDaz
elseif TCarDaz=="U"
  if skol<>0
   nCarDaz:=CarDaz/SKol
  else
   nCarDaz:=0
  endif
else
  nCarDaz:=0
endif

if TZavTr=="%"
  nZavTr:=ZavTr/100*FCj2
elseif TZavTr=="A"
  nZavTr:=ZavTr
elseif TZavTr=="U"
  if skol<>0
   nZavTr:=ZavTr/SKol
  else
   nZavTr:=0
  endif
else
  nZavTr:=0
endif

if TBankTr=="%"
  nBankTr:=BankTr/100*FCj2
elseif TBankTr=="A"
  nBankTr:=BankTr
elseif TBankTr=="U"
  if skol<>0
   nBankTr:=BankTr/SKol
  else
   nBankTr:=0
  endif
else
  nBankTr:=0
endif

if TSpedTr=="%"
  nSpedTr:=SpedTr/100*FCj2
elseif TSpedTr=="A"
  nSpedTr:=SpedTr
elseif TSpedTr=="U"
  if skol<>0
   nSpedTr:=SpedTr/SKol
  else
   nSpedTr:=0
  endif
else
  nSpedTr:=0
endif

if IdVD $ "14#94#15"   // izlaz po vp
  nMarza:=VPC*nPPP*(1-Rabatv/100)-NC
elseif idvd=="24"  // usluge
  nMarza:=marza
elseif idvd $ "11#12#13"
  nMarza:=VPC*nPPP-FCJ
else
  nMarza:=VPC*nPPP-NC
endif

if (idvd $ "11#12#13")
	nMarza2:=MPC-VPC-nPrevoz
elseif ( (idvd $ "41#42#43#81") .or. (IsJerry() .and. idvd="4") )
	nMarza2:=MPC-NC
else
	nMarza2:=MPC-VPC
endif
return
*}



/*! \fn PPUMP()
 *  \brief Racuna i daje porez na promet usluga u maloprodaji
 */
function PPUMP()
*{
local nVrati
if (gUVarPP$"JM" .and. _mpp>0)
	nVrati := field->MPCSAPP*_DLRUC*_MPP/(1+_MPP)
else
	nVrati := field->MPC*(1+_OPP)*_PPP
endif
return nVrati
*}



/*! \fn PPPMP() 
 *  \brief Racuna i daje porez na promet proizvoda u maloprodaji
 */
function PPPMP()
*{
local nVrati
if (gUVarPP$"MT")
	nVrati := field->MPCSAPP*_OPP/(1+_OPP)
else
	nVrati := field->MPC*_OPP
endif
return nVrati
*}


