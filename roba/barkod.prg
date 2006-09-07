#include "sc.ch"


/*! \ingroup ini
  * \var *string FmkIni_SifPath_BARKOD_EAN
  * \brief Omogucava automatsko formiranje barkodova pri labeliranju
  * \param  - ne formiraj barkod ako ga nema, default vrijednost
  * \param 13 - ako nema barkoda sam formira interni barkod pri labeliranju
  */
*string FmkIni_SifPath_BARKOD_EAN;


/*! \ingroup ini
  * \var *string FmkIni_SifPath_BARKOD_NazRTM
  * \brief Definise naziv rtm-fajla koji definise izgled labele barkoda
  * \param barkod - default vrijednost
  */
*string FmkIni_SifPath_BARKOD_NazRTM;


/*! \ingroup ini
  * \var *string FmkIni_SifPath_BARKOD_Prefix
  * \brief Ovim parametrom se moze definisati prefiks internog barkoda
  * \param  - bez prefiksa, default vrijednost
  */
*string FmkIni_SifPath_BARKOD_Prefix;


/*! \ingroup ini
  * \var *string FmkIni_SifPath_BarKod_Auto
  * \brief Odredjuje da li ce se moci automatski formirati barkodovi
  * \param N - default vrijednost
  * \param D - omogucena automatika formiranja barkodova
  */
*string FmkIni_SifPath_BarKod_Auto;


/*! \ingroup ini
  * \var *string FmkIni_SifPath_BarKod_AutoFormula
  * \brief Formula za automatsko odredjivanje novog barkoda
  * \param ID - na osnovu sifre robe, default vrijednost
  */
*string FmkIni_SifPath_BarKod_AutoFormula;


/*! \ingroup ini
  * \var *string FmkIni_SifPath_BarKod_JMJ
  * \brief Da li ce se na labeli barkoda prikazivati pored naziva i jedinica mjere artikla
  * \param D - da, default vrijednost
  * \param N - ne prikazuj jedinicu mjere
  */
*string FmkIni_SifPath_BarKod_JMJ;


/*! \ingroup ini
  * \var *string FmkIni_SifPath_Barkod_BrDok
  * \brief Da li ce se na labelama striktno prikazivati broj dokumenta
  * \param D - da, default vrijednost
  * \param N - omogucava editovanje proizvoljnog teksta prije ispisa labela
  */
*string FmkIni_SifPath_Barkod_BrDok;


/*! \ingroup ini
  * \var *string FmkIni_SifPath_Barkod_Prefix
  * \brief Ovim parametrom se moze definisati prefiks internog barkoda
  * \param  - bez prefiksa, default vrijednost
  */
*string FmkIni_SifPath_Barkod_Prefix;


function DodajBK(cBK)
*{
if empty(cBK) .and. IzFmkIni("BARKOD", "Auto", "N", SIFPATH)=="D" .and. IzFmkIni("BARKOD","Svi","N",SIFPATH)=="D" .and. (Pitanje(,"Formirati Barkod ?","N")=="D")
	cBK:=NoviBK_A()
endif
return .t.


// funkcija za labeliranje barkodova...
function KaLabelBKod()
local cIBK
local cPrefix
local cSPrefix
local cBoxHead
local cBoxFoot
local lStrings := .f.
local lDelphi := .t.
private cKomLin
private Kol
private ImeKol

O_SIFK
O_SIFV
O_PARTN
O_ROBA
set order to tag "ID"
O_BARKOD
O_PRIPR

lStrings := is_strings()

SELECT PRIPR
private aStampati:=ARRAY(RECCOUNT())

GO TOP

for i:=1 to LEN(aStampati)
	aStampati[i]:="D"
next

// setuj kolone za pripremu...
set_a_kol(@ImeKol, @Kol)

cBoxHead := "<SPACE> markiranje Í <ESC> kraj"
cBoxFoot := "Priprema za labeliranje bar-kodova..."

Box(,20,50)
ObjDbedit("PLBK", 20, 50, {|| KaEdPrLBK()}, cBoxHead, cBoxFoot, .t. , , , ,0)
BoxC()

if lStrings
	if Pitanje(,"Stampa deklaracije (D/N)?", "D") == "D"
		lDelphi := .f.
	endif
endif

if lDelphi
	// stampanje delphi labela... 
	st_lab_delphi(aStampati)
else
	// stampanje deklaracija...
	st_lab_deklar(aStampati)
endif

closeret
return


// labeliranje delphi...
static function st_lab_delphi(aStampati)
local nRezerva
local cLinija2
local cPrefix
local cSPrefix

nRezerva := 0
cLinija2 := PADR("Uvoznik:" + gNFirma, 45)

Box(,4,75)
	@ m_x+0, m_y+25 SAY " LABELIRANJE BAR KODOVA "
	@ m_x+2, m_y+ 2 SAY "Rezerva (broj komada):" GET nRezerva VALID nRezerva>=0 PICT "99"
	@ m_x+3, m_y+ 2 SAY "Linija 2  :" GET cLinija2
	READ
	ESC_BCR
BoxC()

cPrefix := IzFmkIni("Barkod","Prefix","",SIFPATH)
cSPrefix := Pitanje(,"Stampati barkodove koji NE pocinju sa +'"+cPrefix+"' ?","N")

SELECT BARKOD
ZAP
SELECT PRIPR
GO TOP

do while !EOF()
	if aStampati[RECNO()]=="N"
		SKIP 1
		loop
	endif
	
	SELECT ROBA
	HSEEK PRIPR->idroba
	if empty(barkod).and.(IzFmkIni("BarKod","Auto","N",SIFPATH)=="D")
		
		private cPom:=IzFmkIni("BarKod","AutoFormula","ID",SIFPATH)
		
		// kada je barkod prazan, onda formiraj sam interni barkod
		cIBK:=IzFmkIni("BARKOD","Prefix","",SIFPATH) + &cPom
		
		if IzFmkIni("BARKOD","EAN","",SIFPATH)=="13"
			cIBK := NoviBK_A()
		endif
		PushWa()
		set order to tag "BARKOD"
		seek cIBK
		if found()
			PopWa()
			MsgBeep("Prilikom formiranja internog barkoda##vec postoji kod: "+cIBK+"??##"+"Moracete za artikal "+pripr->idroba+" sami zadati jedinstveni barkod !")
			replace barkod with "????"
		else
			PopWa()
			replace barkod with cIBK
		endif
	endif
	
	if cSprefix=="N"
		// ne stampaj koji nemaju isti prefix
		if left(barkod,len(cPrefix))!=cPrefix
			select pripr
			skip
			loop
		endif
	endif

	SELECT BARKOD
	for i:=1 to pripr->kolicina+IF(pripr->kolicina>0, nRezerva, 0)
		APPEND BLANK
		REPLACE id WITH pripr->idRoba
		REPLACE naziv WITH TRIM(LEFT(ROBA->naz, 40))+" ("+TRIM(ROBA->jmj)+")"
		REPLACE l1 WITH DTOC(PRIPR->datdok)+", "+TRIM(PRIPR->(idfirma+"-"+idvd+"-"+brdok))
		REPLACE l2 WITH cLinija2
		REPLACE vpc WITH ROBA->vpc
		REPLACE mpc WITH ROBA->mpc
		REPLACE barkod WITH roba->barkod
	next
	SELECT PRIPR
	SKIP 1
enddo
close all

if Pitanje(,"Aktivirati Win Report ?","D")=="D"
	cKomLin := "DelphiRB "+IzFmkIni("BARKOD","NazRTM","barkod", SIFPATH)+" "+PRIVPATH+"  barkod 1"
	run &cKomLin
endif

return


// setovanje varijabli stampe
static function get_vars(cPartner, lPrikBK) 
local nX := 1
local nBoXMax := 10
local cPrikBK := "N"
private GetList:={}

cPartner := SPACE(6)

Box(, nBoxMax, 60)
	
	@ m_x + nX, m_y + 2 SAY "USLOVI STAMPE:"
	
	nX := nX + 2
	
	@ m_x + nX, m_y + 2 SAY "Uvoznik/serviser:" GET cPartner VALID !EMPTY(cPartner) .and. p_firma(@cPartner)
	
	++ nX
	
	@ m_x + nX, m_y + 2 SAY "Prikaz barkod-a (D/N)" GET cPrikBK VALID cPrikBK $ "DN" PICT "@!"
	
	read
BoxC()

if cPrikBK == "D"
	lPrikBK := .t.
else
	lPrikBK := .f.
endif

ESC_RETURN 0

return 1


// labeliranje deklaracija...
static function st_lab_deklar(aStampati)
local cTxtOut
local cRoba
local nDKolicina
local lPrikBK
local nH
local nIdString
local aStrings:={}
local cSep := ","
// varijable stavki deklaracije
local cIdPartner
local cUvozNaz
local cUvozAdr
local cRobaNaz
local cServNaz
local i

// output fajl
cTxtOut := PRIVPATH + "LABEL.TXT"

// varijable reporta
if get_vars(@cIdPartner, @lPrikBK) == 0
	close all
	return
endif

select pripr
go top

// kreiraj fajl
create_file(cTxtOut, @nH)

Beep(1)

MsgO("Priprema deklaracija u toku...")

do while !EOF()
	
	// preskoci ako ne treba stampati
	if aStampati[RECNO()] == "N"
		skip 1
		loop
	endif
	
	cRoba := field->idroba
	nDKolicina := field->kolicina
	
	// ako roba nema definisano strings - preskoci...
	if !is_roba_strings(cRoba)
		skip 1
		loop
	endif
	
	select partn
	set order to tag "ID"
	go top
	seek cIdPartner
	
	cUvozNaz := ALLTRIM(field->naz)
	cUvozAdr := ALLTRIM(field->adresa)
	cServNaz := cUvozNaz
	
	select roba
	hseek cRoba
	
	// naziv robe
	cRobaNaz := ALLTRIM(roba->naz)
	nIdString := roba->strings
	
	// napuni matricu sa atributima...
	aStrings := get_str_val(nIdString)

	cFText := "DEKLARACIJA"
	cFText += cSep
	cFText += "Uvoznik: " + cUvozNaz 
	cFText += cSep
	cFText += cUvozAdr
	cFText += cSep
	cFText += "S.Art: " + cRoba
	cFText += cSep
	cFText += "Art: " + cRobaNaz
	cFText += cSep
	
	// uzmi i vrijednosti iz matrice...
	if LEN(aStrings) > 0
	
		for i:=1 to LEN(aStrings)
			if ALLTRIM(aStrings[i, 3]) == "R_G_ATTRIB" .and. ;
			   ALLTRIM(aStrings[i, 5]) <> "-"
				
				cFText += ALLTRIM(aStrings[i, 4])
				cFText += " "
				cFText += ALLTRIM(aStrings[i, 5])
				cFText += cSep
				
			endif
		next
	endif

	cFText += "Serviser: " + cServNaz

	// koliko je kolicina artikla, toliko dodaj deklaracija...
	for i:=1 to nDKolicina
		write_2_file(nH, cFText, .t.)
	next
	
	select pripr
	skip 1
enddo

// zatvori fajl
close_file(nH)

MsgC()

MsgBeep("Priprema deklaracija zavrsena !")

close all

return


// setovanje kolone opcije pregleda labela....
static function set_a_kol(aImeKol, aKol)
aImeKol := {}
aKol := {}

AADD(aImeKol, {"IdRoba"    ,{|| IdRoba }} )
AADD(aImeKol, {"Kolicina"  ,{|| transform( Kolicina, picv ) }} )
AADD(aImeKol, {"Stampati?" ,{|| bk_stamp_dn( aStampati[RECNO()] ) }} )

aKol:={}
for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return

// prikaz stampati ili ne stampati
static function bk_stamp_dn(cDN)
local cRet := ""
if cDN == "D"
	cRet := "-> DA <-"
else
	cRet := "      NE"
endif

return cRet



/*! \fn KaEdPrLBK()
 *  \brief Obrada dogadjaja u browse-u tabele "Priprema za labeliranje bar-kodova"
 *  \sa KaLabelBKod()
 *  \todo spojiti KaLabelBKod i FaLabelBkod
 */

function KaEdPrLBK()
*{
if Ch==ASC(' ')
	if aStampati[recno()]=="N"
		aStampati[recno()] := "D"
	else
		aStampati[recno()] := "N"
	endif
	return DE_REFRESH
endif
return DE_CONT
*}


/*! \fn FaLabelBKod()
 *  \brief Priprema za labeliranje barkodova
 *  \todo Spojiti
 */ 
function FaLabelBKod()
*{
local cIBK , cPrefix, cSPrefix

O_SIFK
O_SIFV

O_ROBA
SET ORDER to TAG "ID"
O_BARKOD
O_PRIPR

SELECT PRIPR

private aStampati:=ARRAY(RECCOUNT())

GO TOP

for i:=1 to LEN(aStampati)
  	aStampati[i]:="D"
next

ImeKol:={ {"IdRoba",      {|| IdRoba  }      } ,;
    {"Kolicina",    {|| transform(Kolicina,Pickol) }     } ,;
    {"Stampati?",   {|| IF(aStampati[RECNO()]=="D","-> DA <-","      NE") }      } ;
  }

Kol:={}; for i:=1 to len(ImeKol); AADD(Kol,i); next
Box(,20,50)
ObjDbedit("PLBK",20,50,{|| KaEdPrLBK()},"<SPACE> markiranjeÍÍÍÍÍÍÍÍÍÍÍÍÍÍ<ESC> kraj","Priprema za labeliranje bar-kodova...", .t. , , , ,0)
BoxC()

nRezerva:=0

cLinija1:=padr("Proizvoljan tekst",45)
cLinija2:=padr("Uvoznik:"+gNFirma,45)
Box(,4,75)
@ m_x+0, m_y+25 SAY " LABELIRANJE BAR KODOVA "
@ m_x+2, m_y+ 2 SAY "Rezerva (broj komada):" GET nRezerva VALID nRezerva>=0 PICT "99"
if IzFmkIni("Barkod","BrDok","D",SIFPATH)=="N"
@ m_x+3, m_y+ 2 SAY "Linija 1  :" GET cLinija1
endif
@ m_x+4, m_y+ 2 SAY "Linija 2  :" GET cLinija2
READ
ESC_BCR
BoxC()

cPrefix:=IzFmkIni("Barkod","Prefix","",SIFPATH)
cSPrefix:= pitanje(,"Stampati barkodove koji NE pocinju sa +'"+cPrefix+"' ?","N")

SELECT BARKOD
ZAP
SELECT PRIPR
GO TOP
do while !EOF()


if aStampati[RECNO()]=="N"; SKIP 1; loop; endif
SELECT ROBA
HSEEK PRIPR->idroba
if empty(barkod) .and. (  IzFmkIni("BarKod" , "Auto" , "N", SIFPATH) == "D")
private cPom:=IzFmkIni("BarKod","AutoFormula","ID", SIFPATH)
  // kada je barkod prazan, onda formiraj sam interni barkod

cIBK:=IzFmkIni("BARKOD","Prefix","",SIFPATH) +&cPom

if IzFmkIni("BARKOD","EAN","",SIFPATH) == "13"
   cIBK:=NoviBK_A()
endif

PushWa()
set order to tag "BARKOD"
seek cIBK
if found()
     PopWa()
     MsgBeep(;
       "Prilikom formiranja internog barkoda##vec postoji kod: "  + cIBK + "??##" + ;
     "Moracete za artikal "+pripr->idroba+" sami zadati jedinstveni barkod !" )
     replace barkod with "????"
else
    PopWa()
    replace barkod with cIBK
endif

endif
if cSprefix=="N"
// ne stampaj koji nemaju isti prefix
if left(barkod,len(cPrefix)) != cPrefix
      select pripr
      skip
      loop
endif
endif


SELECT BARKOD
for  i:=1  to  PRIPR->kolicina + IF( PRIPR->kolicina > 0 , nRezerva , 0 )

	APPEND BLANK

	REPLACE ID       WITH  KonvZnWin(PRIPR->idroba)

	if IzFmkIni("Barkod","BrDok","D",SIFPATH)=="D"
		REPLACE L1 WITH KonvZnWin(DTOC(PRIPR->datdok)+", "+TRIM(PRIPR->(idfirma+"-"+idtipdok+"-"+brdok)))
	else
		REPLACE L1 WITH KonvZnWin(cLinija1)
	endif

	REPLACE L2 WITH KonvZnWin(cLinija2), VPC WITH ROBA->vpc, MPC WITH ROBA->mpc, BARKOD WITH roba->barkod

	nRobNazLen := LEN(roba->naz)
	
	if IzFmkIni("BarKod","JMJ","D",SIFPATH)=="N"
		replace NAZIV WITH KonvZnWin(TRIM(LEFT(ROBA->naz, nRobNazLen)))
	else
		replace NAZIV WITH KonvZnWin(TRIM(LEFT(ROBA->naz, nRobNazLen))+" ("+TRIM(ROBA->jmj)+")")
	endif

next
SELECT PRIPR
SKIP 1

enddo

close all

if pitanje(,"Aktivirati Win Report ?","D")=="D"
	private cKomLin:="DelphiRB "+IzFmkIni("BARKOD","NazRTM","barkod", SIFPATH)+" "+PRIVPATH+"  barkod 1"
	run &cKomLin
endif


CLOSERET
*}

/*! \fn FaEdPrLBK()
 *  \brief Priprema barkodova
 */
 
function FaEdPrLBK()
*{
if Ch==ASC(' ')
     aStampati[recno()] := IF( aStampati[recno()]=="N" , "D" , "N" )
     return DE_REFRESH
  endif
return DE_CONT
*}

