#include "sc.ch"
/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/roba/barkod.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.5 $
 * $Log: barkod.prg,v $
 * Revision 1.5  2003/09/08 08:41:43  ernad
 * porezi u ugostiteljstvu
 *
 * Revision 1.4  2003/08/22 11:13:39  mirsad
 * parametar konv.znakova win. koristi se sada i u labeliranju barkodova
 *
 * Revision 1.3  2002/07/10 08:44:19  ernad
 *
 *
 * barkod funkcije kalk, fakt -> fmk/roba/barkod.prg
 *
 * Revision 1.2  2002/06/17 13:05:16  ernad
 * barkod.prg
 *
 * Revision 1.1  2002/06/17 13:03:32  ernad
 * init
 *
 *
 */


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

*}


/*! \fn KaLabelBKod()
 *  \brief Priprema i labeliranje bar-kodova
 */

function KaLabelBKod()
*{
local cIBK
local cPrefix
local cSPrefix

private cKomLin

O_SIFK
O_SIFV
O_ROBA
set order to tag "ID"

O_BARKOD
O_PRIPR

SELECT PRIPR

private aStampati:=ARRAY(RECCOUNT())

GO TOP

for i:=1 to LEN(aStampati)
	aStampati[i]:="D"
next

ImeKol:={ {"IdRoba",{|| IdRoba}}, {"Kolicina",{|| transform(Kolicina,picv)}} ,{"Stampati?",{|| IF(aStampati[RECNO()]=="D","-> DA <-","      NE")}} }

Kol:={}
for i:=1 to len(ImeKol)
	AADD(Kol,i)
next

Box(,20,50)
ObjDbedit("PLBK",20,50,{|| KaEdPrLBK()},"<SPACE> markiranje             อ<ESC> kraj","Priprema za labeliranje bar-kodova...", .t. , , , ,0)
BoxC()

nRezerva:=0

cLinija2:=padr("Uvoznik:"+gNFirma,45)

Box(,4,75)
	@ m_x+0, m_y+25 SAY " LABELIRANJE BAR KODOVA "
	@ m_x+2, m_y+ 2 SAY "Rezerva (broj komada):" GET nRezerva VALID nRezerva>=0 PICT "99"
	@ m_x+3, m_y+ 2 SAY "Linija 2  :" GET cLinija2
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
	if aStampati[RECNO()]=="N"
		SKIP 1
		loop
	endif
	SELECT ROBA
	HSEEK PRIPR->idroba
	if empty(barkod).and.(IzFmkIni("BarKod","Auto","N",SIFPATH)=="D")
		private cPom:=IzFmkIni("BarKod","AutoFormula","ID",SIFPATH)
		// kada je barkod prazan, onda formiraj sam interni barkod
		cIBK:=IzFmkIni("BARKOD","Prefix","",SIFPATH)+&cPom
		if IzFmkIni("BARKOD","EAN","",SIFPATH)=="13"
			cIBK:=NoviBK_A()
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
		REPLACE naziv WITH TRIM(ROBA->naz)+" ("+TRIM(ROBA->jmj)+")"
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
	cKomLin:="DelphiRB "+IzFmkIni("BARKOD","NazRTM","barkod", SIFPATH)+" "+PRIVPATH+"  barkod 1"
	run &cKomLin
endif


CLOSERET
return

*}

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
ObjDbedit("PLBK",20,50,{|| KaEdPrLBK()},"<SPACE> markiranjeออออออออออออออ<ESC> kraj","Priprema za labeliranje bar-kodova...", .t. , , , ,0)
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

	if IzFmkIni("BarKod","JMJ","D",SIFPATH)=="N"
		replace NAZIV    WITH  KonvZnWin(TRIM(ROBA->naz))
	else
		replace NAZIV    WITH  KonvZnWin(TRIM(ROBA->naz)+" ("+TRIM(ROBA->jmj)+")")
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

