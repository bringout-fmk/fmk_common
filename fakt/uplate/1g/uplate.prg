#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/uplate/1g/uplate.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.7 $
 * $Log: uplate.prg,v $
 * Revision 1.7  2004/01/07 13:43:59  sasavranic
 * Na izvjestaju Lista salda kupaca dodao kolonu ukupno
 *
 * Revision 1.6  2002/09/28 15:49:48  mirsad
 * prenos pocetnog stanja za evid.uplata dovrsen
 *
 * Revision 1.5  2002/09/27 12:20:43  mirsad
 * ispr.bug na pregledu salda kupaca
 *
 * Revision 1.4  2002/09/26 13:39:52  mirsad
 * dorada za Franex: lista salda kupaca i generisanje pocetnog stanja
 *
 * Revision 1.3  2002/09/26 12:47:05  mirsad
 * no message
 *
 * Revision 1.2  2002/06/19 09:59:22  sasa
 * no message
 *
 * Revision 1.1.1.1  2002/06/17 18:30:18  ernad
 * no message
 *
 *
 */

/*! \file fmk/fakt/uplate/1g/uplate.prg
 *  \brief Uplate
 */


/*! \fn Uplate()
 *  \brief Uplate
 */
 
function Uplate()
*{
O_DOKS
set order to tag "6"
//"6","IdFirma+idpartner+idtipdok",KUMPATH+"DOKS"
O_PARTN
O_UPL

cIdPartner:=SPACE(6)
dDatOd:=ctod("")
dDatDo:=date()
qqTipDok:=padr("10;",40)

ImeKol:={}
Kol:={}

AADD(ImeKol,{ "DATUM UPLATE"    ,    {|| DATUPL   }   })
AADD(ImeKol,{ PADC("OPIS",30)   ,    {|| OPIS     }   })
AADD(ImeKol,{ PADC("IZNOS",12)  ,    {|| IZNOS    }   })

for i:=1 to len(ImeKol)
	AADD(Kol,i)
next

private bBKUslov:={|| idpartner=cidpartner}
private bBkTrazi:={|| cIdPartner}
// Brows ekey uslova

Box(,20,70)
do while .t.

	@ m_x+0, m_y+20 SAY PADC(" EVIDENCIJA UPLATA - KUPCI ",35,CHR(205))
	@ m_x+1, m_y+ 2 SAY "Sifra partnera:" GET cIdPartner VALID P_Firma(@cIdPartner,1,26)
	@ m_x+2, m_y+ 2 SAY "Tip dokumenta zaduzenja:" GET qqTipDok pict "@!S20"
	@ m_x+3, m_y+ 2 SAY "Zaduzenja od datuma    :"  get dDatOd
	@ m_x+3,col()+1 SAY "do:"  get dDatDo
	read
	ESC_BCR
  
	aUslTD:=Parsiraj(qqTipdok,"IdTipdok","C")
	if aUslTD==nil
		MsgBeep("Provjerite uslov za tip dokumenta !")
		loop
	endif

	// utvrdimo ukupno zaduzenje
	nUkZaduz:=UkZaduz()

	set cursor on

	// utvrdimo ukupan iznos uplata
	nUkUplata:=UkUplata()

	select (F_UPL)
	go top

	//@ m_x+ 2,m_y+ 2 SAY ""; ?? "Naziv partnera:",PARTN->naz
	@ m_x+16,m_y+ 1 SAY REPL(CHR(22),70)
	@ m_x+17,m_y+30 SAY " (+)     ZADUZENJE:"
	@ m_x+18,m_y+30 SAY " (-)       UPLATIO:"
	@ m_x+19,m_y+30 SAY " 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�"
	@ m_x+20,m_y+30 SAY " (=) PREOSTALI DUG:"
	DajStanjeKupca()
	@ m_x+ 4,m_y+ 1 SAY REPL(CHR(22),70)

	seek cIdPartner  // pozicioniraj se na pocetak !!
	ObjDbEdit("EvUpl",20,70,{|| EdUplata()} ,"","<c-N> nova uplata  <F2> ispravka  <c-T> brisanje  <c-P> stampanje",.f. , NIL, 1, , 4, 3, NIL, {|nSkip| SkipDBBK(nSkip)} )

	//  BrowseKey(m_x+5,m_y+4,m_x+15,m_y+68,ImeKol,{|Ch| EdUplata(Ch)},"idpartner==cidpartner",cidpartner,2,,,{|| .f.})

enddo
BoxC()

CLOSERET
return nil
*}


/*! \fn EdUplata()
 *  \brief Obradjuje funkcije nad uplatama
 */
 
function EdUplata()
*{
local fK1:=.f.
local nRet:=DE_CONT

do case

	case Ch==K_F2  .or. Ch==K_CTRL_N

		dDatUpl := IF( Ch==K_F2 , DATUPL , DATE()           )
		cOpis   := IF( Ch==K_F2 , OPIS   , SPACE(LEN(OPIS)) )
		nIznos  := IF( Ch==K_F2 , IZNOS  , 0                )

		Box(,3,60,.f.)
			@ m_x+0,m_y+10 SAY PADC(IF(Ch==K_F2,"ISPRAVKA EVIDENTIRANE","EVIDENTIRANJE NOVE")+" STAVKE",40,CHR(205))
			@ m_x+1,m_y+ 2 SAY "Datum uplate" GET dDatUpl
			@ m_x+2,m_y+ 2 SAY "Opis        " GET cOpis
			@ m_x+3,m_y+ 2 SAY "Iznos       " GET nIznos pict picdem
			read
		BoxC()

		if Ch==K_CTRL_N .and. lastkey()<>K_ESC
			append blank
			replace idpartner with cidpartner
		endif

		if lastkey()<>K_ESC
			replace datupl WITH dDatUpl, opis WITH cOpis, iznos WITH nIznos
			nUkUplata:=UkUplata()
			DajStanjeKupca()
			nRet:=DE_REFRESH
		endif

	case Ch==K_CTRL_T

		if Pitanje(,"Izbrisati stavku ?","N")=="D"
			delete
			nUkUplata:=UkUplata()
			DajStanjeKupca()
			nRet:=DE_REFRESH
		endif

	case Ch==K_CTRL_P

		StKartKup()
		nRet:=DE_REFRESH

endcase

return nRet
*}


/*! \fn DajStanjeKupca()
 *  \brief Vraca stanje kupca
 */
 
function DajStanjeKupca()
*{
	@ m_x+17,m_y+49 SAY STR(nUkZaduz,15,2) COLOR "N/W"
	@ m_x+18,m_y+49 SAY STR(nUkUplata,15,2) COLOR "N/W"
	@ m_x+20,m_y+49 SAY STR(nUkZaduz-nUkUplata,15,2) COLOR "N/W"
return nil
*}


/*! \fn UkZaduz()
 *  \brief Ukupno zaduzenje
 */
 
function UkZaduz()
*{
local nArr:=SELECT(), nVrati:=0

select (F_DOKS)
seek gFirma+cIdPartner

do while !eof() .and. idpartner==cIdPartner
	if datdok>=dDatOd .and. datdok<=dDatDo .and. &aUslTD
		nVrati += ROUND(iznos,ZAOKRUZENJE)
	endif
	skip 1
enddo

select (nArr)

return nVrati
*}


/*! \fn UkUplata(lPushWA)
 *  \brief Ukupno uplata
 *  \param lPushWA - .t.-skeniraj pa vrati stanje baze uplata, .f.-ne radi to
 */
 
function UkUplata(lPushWA)
*{
local nArr:=SELECT(), nVrati:=0

if lPushWA==nil
	lPushWA:=.t.
endif

select (F_UPL)

if lPushWA
	PushWA()
	set order to tag "2"
endif

seek cIdPartner

do while !eof() .and. idpartner==cIdPartner
	if datupl>=dDatOd .and. datupl<=dDatDo
		nVrati += iznos
	endif
	skip 1
enddo

if lPushWA
	PopWA()
endif

select (nArr)

return nVrati
*}


/*! \fn SkipDBBK(nRequest)
 *  \brief
 *  \param nRequest
 */
 
function SkipDBBK(nRequest)
*{
local nCount
nCount := 0
if LASTREC()!=0
	if .not. EVAL(bBKUslov)
		seek EVAL(bBkTrazi)
		if .not. EVAL(bBKUslov)
			go bottom
			skip 1
		endif
		nRequest=0
	endif
	if nRequest>0
		do while nCount<nRequest .and. EVAL(bBKUslov)
			skip 1
			if eof() .or. !EVAL(bBKUslov)
				skip -1
				exit
			endif
			nCount++
		enddo
	elseif nRequest<0
		do while nCount>nRequest .and. EVAL(bBKUslov)
			skip -1
			if (Bof())
				exit
			endif
			nCount--
		enddo
		if (!EVAL(bBKUslov))
			skip 1
			nCount++
		endif
	endif
endif
return (nCount)
*}


/*! \fn StKartKup()
 *  \brief Stanje na kartici kupca
 */
 
static function StKartKup()
*{
local nRec:=0

START PRINT CRET

nRec:=RECNO()
go top

P_10CPI
? "FAKT, " + DTOC(date()) + ", KARTICA KUPCA"
? "-----------------------------"
?
? "ZA PERIOD: OD "+DTOC(dDatOd)+" DO "+DTOC(dDatDo)
? "KUPAC:",cIdPartner,"-",PARTN->naz
?
? "-------- "+REPL("-",LEN(opis))+" "+REPL("-",10)
? "DAT.UPL.�"+PADC("OPIS",LEN(opis))+"�"+PADC("IZNOS",10)
? "-------- "+REPL("-",LEN(opis))+" "+REPL("-",10)

seek cIdPartner
do while !eof() .and. idpartner==cIdPartner
	? datupl
	?? "�"+opis+"�"
	?? TRANS(iznos,"9999999.99")
	skip 1
enddo

? "-------- "+REPL("-",LEN(opis))+" "+REPL("-",10)
?
? " UKUPNO ZADUZENJE",TRANS(nUkZaduz,"9999999.99")
? "  - UKUPNO UPLATE",TRANS(nUkUplata,"9999999.99")
? "-----------------","----------"
? "  = PREOSTALI DUG",TRANS(nUkZaduz-nUkUplata,"9999999.99")
?

go (nRec)

FF
END PRINT

return nil
*}


/*! \fn SaldaKupaca(lPocStanje)
 *  \brief Izvjestaj koji daje salda svih kupaca
 *  \param lPocStanje - .t.-generisi i pocetno stanje, .f.-daj samo pregled
 */
 
function SaldaKupaca(lPocStanje)
*{
local nUkZaduz
local nUkUplata
local nStrana
local gSezonDir
local cDirKum

gSezonDir:=goModul:oDatabase:cSezonDir
cDirKum:=goModul:oDatabase:cDirKum

if lPocStanje==nil
	lPocStanje:=.f.
endif

nStrana:=1

O_DOKS
set order to tag "6"
//"6","IdFirma+idpartner+idtipdok",KUMPATH+"DOKS"
O_PARTN
O_UPL
set order to tag "2"

if lPocStanje
	select 0
	usex (STRTRAN(cDirKum,gSezonDir,SLASH)+"UPL") alias uplrp
endif

cIdPartner:=SPACE(6)
dDatOd:=ctod("")
dDatDo:=date()
qqTipDok:=padr("10;",40)

Box(,6,70)
do while .t.
	if lPocStanje
		@ m_x+0, m_y+10 SAY PADC(" GENERISANJE POCETNOG STANJA ZA EVIDENCIJU UPLATA KUPACA ",55,CHR(205))
	else
		@ m_x+0, m_y+20 SAY PADC(" LISTA SALDA KUPACA ",35,CHR(205))
	endif
	@ m_x+2, m_y+ 2 SAY "Tip dokumenta zaduzenja:" GET qqTipDok pict "@!S20"
	@ m_x+3, m_y+ 2 SAY "Zaduzenja od datuma    :"  get dDatOd
	@ m_x+3,col()+1 SAY "do:"  get dDatDo
	read
	ESC_BCR
  
	aUslTD:=Parsiraj(qqTipdok,"IdTipdok","C")
	if aUslTD==nil
		MsgBeep("Provjerite uslov za tip dokumenta !")
		loop
	endif

	set cursor on
	
	exit

enddo
BoxC()

select (F_PARTN)
set order to tag "ID"
go top

START PRINT CRET

P_10CPI

? "SALDA KUPACA"
? "------------"
? "Za period:", dDatOd, "-", dDatDo
? "Tipovi dokumenata zaduzenja kupaca:", TRIM(qqTipDok)

m1:=PADC("SIFRA I NAZIV KUPCA",LEN(field->id+field->naz)+1)+" "+PADC("ZADUZENJA",12)+" "+PADC("UPLATE",12)+" "+PADC("SALDO",12)
m2:=REPL("-",LEN(field->id))+" "+REPL("-",LEN(field->naz))+" "+REPL("-",12)+" "+REPL("-",12)+" "+REPL("-",12)

? m2
? m1
? m2

nUkSaldo:=0
nUUZaduz:=0
nUUUplata:=0

do while !eof()

	cIdPartner:=field->id

	// utvrdimo ukupno zaduzenje
	nUkZaduz:=UkZaduz()

	// utvrdimo ukupan iznos uplata
	nUkUplata:=UkUplata(.f.)

	if (nUkZaduz<>0 .or. nUkUplata<>0)
		if (prow()>61+gPStranica)
			? m2
			?
			? " "+PADC(ALLTRIM(STR(nStrana))+". strana",78)
			FF
			? m2
			? m1
			? m2
			++nStrana
		endif
		? cIdPartner, field->naz, STR(nUkZaduz,12,2), STR(nUkUplata,12,2), STR(nUkZaduz-nUkUplata,12,2)
		nUUZaduz+=nUkZaduz
		nUUUplata+=nUkUplata
		nUkSaldo+=nUkZaduz-nUkUplata
		if (lPocStanje .and. nUkZaduz-nUkUplata<>0)
			select uplrp
			append blank
			replace field->datupl with CTOD("01.01."+STR(VAL(RIGHT(gSezonDir,4))+1,4)), field->idpartner with cIdPartner, field->opis with "#POCETNO STANJE#", field->iznos with -(nUkZaduz-nUkUplata)
			select partn
		endif
	endif
	
	skip 1
	
enddo

? m2
? "UKUPNO:   " + SPACE(23) + STR(nUUZaduz,12,2) + " " + STR(nUUUplata,12,2) + " " + STR(nUkSaldo,12,2)
?
? " "+PADC(ALLTRIM(STR(nStrana))+". i posljednja strana",78)
FF
END PRINT

CLOSERET
return nil
*}


/*! \fn GPSUplata()
 *  \brief Generisanje pocetnog stanja za evidenciju uplata
 */

function GPSUplata()
*{
local gSezonDir

gSezonDir:=goModul:oDatabase:cSezonDir

if EMPTY(gSezonDir)
	MsgBeep("Morate uci u sezonsko podrucje prosle godine!")
elseif Pitanje(,"Generisati pocetno stanje za evidenciju uplata? (D/N)","N")=="D"
	SaldaKupaca(.t.)
	MsgBeep("Generisanje pocetnog stanja za evidenciju uplata zavrseno!#Provjerite salda kupaca u tekucoj godini!")
endif
return nil
*}


