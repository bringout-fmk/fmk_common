#include "sc.ch"

// ----------------------
// ----------------------
function PP_Firma()
*{

// cDirSif - putanja (direktorij) sifrarnika aktivne firme
cK2KS:=PADR(TRIM(cDirSif)+SLASH, 40)

O_PARAMS
private cSection:="6"
private cHistory:=" "
private aHistory:={}
Params1()
RPar("ks",@cK2KS)

Box(,3,77)
	@ m_x+2, m_y+2 SAY "Direktorij sifrarnika druge firme:" GET cK2KS PICT "@!"
READ
BoxC()
IF LASTKEY()==K_ESC
	SELECT PARAMS
	USE
RETURN
ENDIF

Params2()
WPar("ks",@cK2KS)
SELECT PARAMS
USE

IF TRIM(cK2KS)!=TRIM(cDirSif)
	cPom:=SezRad(TRIM(cK2KS))+"PARTN.DBF"
IF SELECT("PART2")!=0
	SELECT PART2
	USE
ENDIF
IF !(FILE(cPom))
	Msg("Na zadanom direktoriju druge firme ne postoji baza za poredjenje !",6)
RETURN
ENDIF
USE (cPom) ALIAS PART2 NEW
SET ORDER TO TAG "ID"
GO TOP
ELSE
	Msg("Zadani direktorij je isti kao i direktorij sifrarnika ove firme !",6)
RETURN
ENDIF

gnLMarg:=0
gTabela:=1
gOstr:="D"

SELECT PARTN
SET ORDER TO TAG "ID"
GO TOP
if eof()
	Msg("Ne postoje trazeni podaci...",6)
	return
endif

START PRINT CRET

PRIVATE cIdSif:="", cNazSif:="", cNazSif2:=""

aKol:={ { "SIFRA(ID)"           , {|| cIdSif   }, .f., "C", 10, 0, 1, 1},;
  { "NAZIV U OVOJ FIRMI"  , {|| cNazSif  }, .f., "C", 40, 0, 1, 2},;
  { "("+cDirSif+"\)"      , {|| "#"      }, .f., "C", 40, 0, 2, 2},;
  { "NAZIV U DRUGOJ FIRMI", {|| cNazSif2 }, .f., "C", 40, 0, 1, 3},;
  { "("+TRIM(cK2KS)+")"   , {|| "#"      }, .f., "C", 40, 0, 2, 3} }

?? space(gnLMarg); ?? "KALK: Izvjestaj na dan",date()
? space(gnLMarg); IspisFirme("")

StampaTabele(aKol,{|| FSvaki2()},,gTabela,,;
,"REZULTAT UPOREDJIVANJA SIFRARNIKA PARTNERA",;
		       {|| FFor3()},IF(gOstr=="D",,-1),,,,,)
FF
END PRINT

RETURN
*}

function FFor3()
*{
cIdSif:=id
cNazSif:=naz

SELECT PART2
HSEEK cIdSif

IF FOUND()
	cNazSif2:=naz
ELSE
	cNazSif2:="  NEMA !  "
ENDIF

SELECT PARTN
RETURN !(PARTN->naz==PART2->naz)
*}

