#include "\cl\sigma\fmk\fin\fin.ch"
#include "\cl\sigma\fmk\fin\specif\tigra\1g\fin_tgr.ch"


/*! \fn GeneracijaStPartnera()
 *  \brief Glavni menij prenosa podataka na HH
 */
function GeneracijaStPartnera()
*{
private opc:={}
private opcexe:={}
private Izbor:=1

O_KONCIJ

AADD(opc, "1. prenos stanja partnera na HH        ")
AADD(opcexe, {|| PrenStanjaPartnHH()})
AADD(opc, "2. pregled izgenerisanih podataka ")
AADD(opcexe, {|| Rpt_StanjePartnera()})
AADD(opc, "3. koncij (KALK) ")
AADD(opcexe, {|| P_Koncij()})

Menu_SC("pnh")

return
*}


/*! \fn PrenStanjaPartnHH()
 *  \brief Glavna funkcija prenosa podataka na HH
 */
function PrenStanjaPartnHH()
*{
MsgBeep("Prije prenosa FIN stanja na HH, treba prvo##odraditi prenos stanja iz TOPS-a!")
lOK:=.f.
if Pitanje(,"Prenjeti stanje partnera na HH", "D")=="D"
	lOK:=.t.
endif
if !lOK
	return
endif

private dDatOd:=Date()-400
private dDatDo:=Date()
private cNula:="N"
private nBrDana:=15
private nMinIznos:=5

SET CURSOR ON
Box(,5,42)
	@ m_x+2, m_y+2 SAY "Od datuma:" GET dDatOd
	@ m_x+2, m_y+22 SAY "Do datuma:" GET dDatDo
	@ m_x+3, m_y+2 SAY "Partneri sa stanjem 0 (D/N)?" GET cNula VALID cNula$"DN" PICT "!@"
	@ m_x+4, m_y+2 SAY "Prenijeti iznos stavke >" GET nMinIznos PICT "999.99"
	read
BoxC()

if LastKey()==K_ESC
	return
endif

OPrenosHH()
ScanSuban(dDatOd, dDatDo, nBrDana, cNula)

return
*}


/*! \fn OPrenosHH()
 *  \brief Otvara tabele potrebne za prenos
 */
function OPrenosHH()
*{
// otvaranje tabela potrebnih za prenos

O_SUBAN
O_PARTN

return
*}

/*! \fn DodajUPartn(nIdN,cIdPartn,cNazPartn,nIznos)
 *  \brief Dodaje zapis u tabelu partn
 *  \param nIdN - polje IDN iz rngost
 *  \param cIdPartn - polje ID iz rngost
 *  \param cNazPartn - polje naz iz rngost
 *  \param nIznos - stanje za partnera
 */
function DodajUPartn(nIdN, cIdPartn, cNazPartn, nIznos)
*{
local nArr
nArr:=SELECT()

select (F_F_STANJE)

append blank
replace id with nIdN
replace oznaka with cIdPartn
replace naz with cNazPartn
replace stanje with nIznos
select (nArr)
return
*}


/*! \fn DodajUOStav(nIdN,dDatum,cBrojDok,cStatus,nIznos)
 *  \brief Dodaje zapis u tabelu OStav
 *  \param nIdN - polje IDN iz rngost (veza sa partn->id)
 *  \param dDatum - datum otvorene stavke
 *  \param cBrojDok - broj dokumenta
 *  \param cStatus - status D/P (duguje/potrazuje)
 *  \param nIznos - iznos racuna (D/P)
 */
function DodajUOStav(nIdN, dDatum, cBrojDok, cStatus, nIznos, dDatVal, cVeza)
*{
local nArr
nArr:=SELECT()

select (F_F_OSTAV)

append blank
replace id with nIdN
replace datum with DToS(dDatum)
replace brdok with cBrojDok
replace vrsta with cStatus
replace iznos with nIznos
if dDatVal<>nil
	replace datval with dDatVal
endif
if cVeza<>nil
	replace veza with cVeza
endif

select (nArr)

return
*}

/*! \fn DodajUParams(cID,cNaziv,cOpis)
 *  \brief Dodaje zapis u tabelu params - ovo je kontrolna tabela iz koje mozemo vidjeti koliko je preneseno partnera a koliko otvorenih stavki te kada je zadnji put prenos radjen.
 *  \param cID - 1. PAZ - Posljednje azuriranje 2. PCN - Broj prenesenih partnera 3. SCN - Broj prenesenih otvorenih stavki.
 *  \param cNaziv - Naziv promjene
 *  \param cOpis - Opis promjene
 */
function DodajUParams(cID,cNaziv,cOpis)
*{
local nArr
nArr:=SELECT()

select (F_F_PARAMS)

append blank
replace id with cId
replace naz with cNaziv
replace opis with cOpis

select (nArr)
return
*}


/*! \fn ScanKoncij()
 *  \brief Skenira koncij i upisuje podatke u ostav i partn za odredjenu kasu
 */

static function ScanKoncij()
*{
local cTSifPath
local nSifPath
local cTKumPath

nBrStavki:=0

O_KONCIJ

if (FIELDPOS("KUMTOPS")==0)
	MsgBeep("Prvo izvrsite modifikaciju struktura pomocu KALK.CHS !")
	close all
	return 0
endif

// prodji kroz koncij
go top

do while !EOF()
	cTSifPath:=TRIM(field->siftops)
	cTKumPath:=TRIM(field->kumtops)
	
	@ m_x+1,m_y+2 SAY "Upisujem podatke u tabele ..."
	@ m_x+2,m_y+2 SAY "----------------------------------"
	
	if EMPTY(cTSifPath) .or. EMPTY(cTKumPath)
		SKIP 1
		loop
	endif
	
	AddBs(@cTKumPath)
	AddBs(@cTSifPath)
	
	if (!FILE(cTKumPath+"OSTAV.DBF"))
		SKIP 1
		loop
	endif

	@ m_x+3,m_y+2 SAY SPACE(35)
	@ m_x+3,m_y+2 SAY "Putanja: " + ALLTRIM(cTKumPath)
	@ m_x+4,m_y+2 SAY SPACE(35)
	@ m_x+4,m_y+2 SAY "Kasa: " + ALLTRIM(koncij->idprodmjes)
	
	SELECT (F_F_PARAMS)
	USE (cTKumPath+"PARAMS")
	set order to tag "ID"

	SELECT (F_F_OSTAV)
	USE (cTKumPath+"OSTAV")
	set order to tag "ID"

	SELECT (F_F_STANJE)
	USE (cTKumPath+"PARTN") ALIAS STANJE
	set order to tag "ID"

	SELECT (F_T_PARTN)
	USE (cTSifPath+"RNGOST")
	set order to tag "IDFMK"
	
	go top

	altd()
	select prenhh
	set order to tag "1"	
	go top
	
	altd()	
	
	for i:=1 to prenhh->(RecCount())
		
		cPart:=prenhh->idpartner
		nIznos:=prenhh->iznos
		cDokument:=prenhh->dokument
		dDat:=prenhh->datum
		cDugPot:=prenhh->d_p
		cVeza:=prenhh->veza
		dDatVal:=prenhh->datval
		
		select (F_T_PARTN)
		set order to tag "IDFMK"
		go top
				
		seek PADR(cPart, 6)
		if !Found()
			// ako je polje rngost->idfmk prazno 
			// pretpostavlja se da je (rngost->id)==(partn->id)
			@ m_x+5, m_y+2 SAY "Polje IDFmk prazno! Uzimam polje ID"
			set order to tag "ID"
			go top
			seek PADR(cPart, 6)
			// ako ni njega ne nadje preskacem zapis 
			// (ovaj partn ne postoji !!!)
			if !Found()
				select prenhh
				skip
				loop
			endif
		endif
		
		//uzmi idfmk iz rngost i uvecaj ga za 100000	
		nTOPSIdN:=(field->idn+100000)
		cIdFmk:=field->id
		cNaz:=field->naz
		
		// dodaj u partn STANJE ako je "STPART" a ako ne dodaj u OSTAV
		if (ALLTRIM(prenhh->dokument)=="STPART")
			DodajUPartn(nTOPSIdN, cIdFmk, cNaz, nIznos)
		else
			DodajUOstav(nTOPSIdN, dDat, cDokument, cDugPot, nIznos, dDatVal, cVeza)
			++ nBrStavki
		endif	
		
		@ m_x+5,m_y+2 SAY "                                   "
		@ m_x+6,m_y+2 SAY "Partner: " + ALLTRIM(STR(nTOPSIdN))
		
		select prenhh
		skip
	next
	
	SELECT koncij
	SKIP 1
enddo

DodajUParams("PAZ", DToS(DATE()), "Posljednje azuriranje")
DodajUParams("SCN", STR(prenhh->(RecCount())), "Preneseno otvorenih stavki FIN")

MsgBeep("Broj upisanih stavki: " + ALLTRIM(STR(nBrStavki)))

return 1
*}




/*! \fn ScanSuban(dDatumOd, dDatumDo, nBrDan, cNulaDN)
 *  \brief Generacija otvorenih stavki za partnera u niz aFinArr
 *  \param dDatumOd - datum od kojeg se prenose podaci
 *  \param dDatumDo - datum do kojeg se prenose podaci
 *  \param nBrDan - broj dana do kojeg se prenose stavka po stavka (DATE() do (DATE()-nBrDan))
 *  \param cNulaDN - da li se prenose salda 0 "D/N"	
 */
function ScanSuban(dDatumOd, dDatumDo, nBrDan, cNulaDN)
*{

Cre_PomDB()
O_PRENHH

cIdKont:="2120   "
nBrojac:=0
// uvijek ponisti
select prenhh
set order to tag "1"
zap
__dbpack()

O_SUBAN
select suban
set order to tag "3"
seek gFirma+cIdKont

//aFinArr:={}
cPartner:="XZZX2"
nBrPartn:=0

Box(,6,60)
@ 1+m_x, 2+m_y SAY "Prolazim kroz SUBAN ..."
@ 2+m_x, 2+m_y SAY "----------------------------"

do while !eof() .and. idfirma==gFirma .and. idkonto==cIdKont
	nBrojac:=0
	nUkDuguje:=0
	nUkPotrazuje:=0
	nUkStanjePartn:=0
	cIdPartner:=field->idpartner
	
	if "5BA01"$cIdPartner
		
		altd()
	endif
	
	@ 4+m_x, 2+m_y SAY "ID partner: " + ALLTRIM(cIdPartner)
	if Empty(field->idpartner) .or. field->idpartner==cPartner
		skip
		loop
	endif
	
	aFinArr:={}
	
	do while !eof() .and. idkonto==cIdKont .and. idfirma==gFirma .and. idpartner==cIdPartner .and. datdok<=dDatumDo	
		cPartner:=cIdPartner
		if (field->idpartner<>cIdPartner)
			skip
		else
			++ nBrojac
			dDatum:=field->datdok
			dDatVal:=field->datval
			
			cDokument:=ALLTRIM(field->idvn) + "-" + ALLTRIM(field->brnal)
			cBrVeze:=field->brdok
			
			if (field->D_P=="1")
				cDP:="D"
			else
				cDP:="P"
			endif
			
			nIznosBHD:=field->iznosBHD
			
			// dodaj u matricu sve stavke partnera
			AADD(aFinArr, {cIdPartner, dDatum, "F-"+cDokument, cDP, nIznosBHD, dDatVal, cBrVeze})
			if field->D_P=="1"
				nUkStanjePartn += nIznosBHD
			else
				nUkStanjePartn -= nIznosBHD
			endif

			@ 5+m_x, 2+m_y SAY "Obradjeno stavki: " + ALLTRIM(STR(nBrojac))
			skip
		endif
	enddo
	
	if nUkStanjePartn > nMinIznos
		for i:=1 to LEN(aFinArr)
			InsertIntoPrenHH(aFinArr[i, 1], aFinArr[i, 2], aFinArr[i, 3], aFinArr[i, 4], aFinArr[i, 5], aFinArr[i, 6], aFinArr[i, 7])
		next
		InsertIntoPrenHH(cIdPartner, DATE(), "STPART", "D", nUkStanjePartn)
		++ nBrPartn
	endif
enddo

MsgBeep("Broj obradjenih partnera: " + ALLTRIM(STR(nBrPartn)))

// pocisti status
@ 4+m_x, 2+m_y SAY "Spreman za upis podataka u tabele..."
@ 5+m_x, 2+m_y SAY SPACE(20)

//skeniraj koncij i ubacuj podatke u ostav i partn
ScanKoncij()

BoxC()

MsgBeep("Prenos uspjesno zavrsen !!!")
MsgBeep("!!! VAZNA NAPOMENA !!! ##Ako se broj obradjenih stavki znatno razlikuje##od broja upisanih stavki pogledajte da li je ##definisan IDFMK za svakog od partnera ##u sifrarniku partnera u TOPS-u!")

if Pitanje(,"Prikazati izvjestaj","D")=="D"
	Rpt_StanjePartnera()
endif

return
*}



static function Cre_PomDB()
*{
if !FILE(PRIVPATH + "prenhh.dbf")
	aDbf:={}
	AADD(aDbf, {"idpartner", "C", 6, 0})
	AADD(aDbf, {"datum", "D", 8, 0})
	AADD(aDbf, {"dokument", "C", 10, 0})
	AADD(aDbf, {"d_p", "C", 1, 0})
	AADD(aDbf, {"iznos", "N", 12, 2})
	AADD(aDbf, {"datval", "D", 8, 0})
	AADD(aDbf, {"veza", "C", 10, 0})
	DBCreate2(PRIVPATH + "prenhh", aDbf)
endif

if !FILE(PRIVPATH + "prenhh.cdx")
	CREATE_INDEX("1","idpartner+DToS(datum)",PRIVPATH+"prenhh.dbf",.t.)
endif

return
*}


static function InsertIntoPrenHH(cIdPartner, dDatum, cDokument, cDP, nIznos, dDatVal, cBrVeze)
*{
local nArr
nArr:=SELECT()

select prenhh

append blank
replace idpartner with cIdPartner
replace datum with dDatum
replace dokument with cDokument
replace d_p with cDP
replace iznos with nIznos
if dDatVal<>nil
	replace datval with dDatVal
endif
if cBrVeze<>nil
	replace veza with cBrVeze
endif

select (nArr)

return
*}


