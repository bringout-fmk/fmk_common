#include "\dev\fmk\ld\ld.ch"



/*! \fn RazlikaLD()
 *  \brief Razlika LD-a prema novom prosjecnom LD-u i vrijednosti boda
 */
function RazlikaLD()
*{
if IzFmkIni("LD", "Korekcije", "N", KUMPATH) == "N"
	return
endif

private cRadId
private dMOd
private dYOd
private dMDo
private dYDo
private aParObr:={}
private aGodine:={}
private lMjesec

// daj formu uslova izvjestaja i setuj varijable
if GetVars(@dMOd, @dYOd, @dMDo, @dYDo, @cRadId, @lMjesec) == 0
	return
endif

// daj podatke parametara obracuna i napuni ih u aParObr
// aParObr {}
// GODINA, MJESEC, VRBOD, PROSJ(70%)
//  2002, parobr->id, parobr->vrbod, parobr->k2

aGodine := GetGodine(dYOd, dYDo)

GetParObr(@aParObr, aGodine)

if LEN(aParObr) == 0
	MsgBeep("Greska pri sumiranju parametara obracuna!")
	return
endif

// prikazi razlike u obracunu plate
StRazlike(dMOd, dYOd, dMDo, dYDo, aGodine, aParObr, lMjesec, cRadId)

return
*}


/*! \fn GetVars(dMOd, dYOd, dMDo, dYDo, cRadId, lMjesec)
 *  \brief Prikupi varijable izvjestaja
 *  \param dMOd - mjesec od
 *  \param dYOd - godina od
 *  \param dMDo - mjesec do
 *  \param dYDo - godina do
 *  \param cRadId - id radnik
 *  \param lMjesec - .t. kupi podatke na mjesecnom novou
 */
static function GetVars(dMOd, dYOd, dMDo, dYDo, cRadId, lMjesec)
*{
dMOd:=Month(DATE())
dYOd:=Year(DATE())
dMDo:=Month(Date())
dYDo:=Year(Date())
cGodine:=SPACE(40)
cRadId:=SPACE(6)
lMjesec:=.f.
cMjNivo:="N"

Box(,10, 70)
	@ 1+m_x, 2+m_y SAY "Uslovi izvjestaja pregled razlika" COLOR "I"
	@ 2+m_x, 2+m_y SAY "----------------------------------------"
	@ 4+m_x, 2+m_y SAY "Datum od" GET dMOd VALID !Empty(dMOd) PICT "99" 
	@ 4+m_x, 13+m_y SAY "." GET dYOd VALID !Empty(dYOd) PICT "9999"
	@ 5+m_x, 2+m_y SAY "Datum do" GET dMdo VALID !Empty(dMDo) PICT "99"
	@ 5+m_x, 13+m_y SAY "." GET dYDo VALID !Empty(dYDo) PICT "9999"
	@ 6+m_x, 2+m_y SAY "Radnik (prazno-svi)" GET cRadId VALID Empty(cRadId) .or. P_Radn(@cRadId) 
	@ 8+m_x, 2+m_y SAY "Stampati stavke na mjes.nivou" GET cMjNivo VALID cMjNivo$"DN" PICT "@!" 
	read
BoxC()

if LastKey()==K_ESC
	return 0
endif

if (cMjNivo=="D")
	lMjesec:=.t.
endif

return 1
*}

/*! \fn GetParObr(aParObr, cGodine)
 *  \brief Izvuci parametre obracuna u matricu aParObr
 *  \param aParObr - matrica 
 *  \param cGodine - godine: 2002;2004;2005;
 */
static function GetParObr(aParObr, aGodine)
*{
O_PAROBR

nErr:=0
for i:=1 to LEN(aGodine)
	if EMPTY(aGodine[i])
		loop
	endif
	if (aGodine[i] <> ALLTRIM(STR(YEAR(Date()))))
		cPath := SIFPATH + aGodine[i] + SLASH + "PAROBR"
		if !File(cPath + ".DBF") 
			loop
		endif
		cAlias := "TPO" + ALLTRIM(STR(i))
		select (235 + i)
		use (cPath) ALIAS &cAlias 
		set order to tag "ID"
	else
		// ako je RADP onda koristi PAROBR iz RADP
		set order to tag "ID"
		cAlias := "PAROBR"
	endif
	go top
	do while !EOF()
		// puni matricu aParObr {}
		// aParObr[1] = aGodine[1] (npr. 2002)
		// aParObr[2] = parobr->id (npr. 1)
		// aParObr[3] = parobr->vrbod (npr. 82.00)
		// aParObr[4] = parobr->k2 (npr. 338.00) 
		AADD(aParObr, {VAL(aGodine[i]), VAL(&cAlias->id), &cAlias->vrbod, &cAlias->k2})
		skip
	enddo

next

return
*}


/*! \fn GetGodine(dY1, dY2)
 *  \brief Vraca matricu sa godinama na osnovu datuma po pricipu: {2002, 2003, 2004, ..., 2010}
 *  \param dY1 - godina 1
 *  \param dY2 - godina 2
 */
static function GetGodine(dY1, dY2)
*{
cGodine := ""
for i:=dY1 to dY2
	cGodine += STR(i, 4) + ";"
next

aRet:={}
aRet:=TokToNiz(ALLTRIM(cGodine), ";")

return aRet
*}



/*! \fn StRazlike(dMOd, dYOd, dMDo, dYDo, aGodine, aParObr, lMjesec, cRadId)
 *  \brief Stampa reporta razlika LD-a
 *  \param dMOd - mjesec od
 *  \param dYOd - godina od
 *  \param dMDo - mjesec do
 *  \param dYDo - godina do
 *  \param aGodine - matrica sa godinama
 *  \param aParObr - matrica sa parametrima obracuna
 *  \param lMjesec - .t. stampati stavke na mjes.nivou ..TODO..
 *  \param cRadId - ID radnik
 */
static function StRazlike(dMOd, dYOd, dMDo, dYDo, aGodine, aParObr, lMjesec, cRadId)
*{
O_LD
O_RADN
nBrojac:=1

START PRINT CRET

? "RPT: Spisak razlika za isplatu radnicima"
?

P_COND

cFilter := " ( godina >= " + Cm2Str(dYOd) + " .and. mjesec >= "  + Cm2Str(dMOd) + " ) .and. ( godina <= " + Cm2Str(dYDo) + " .and. mjesec <= " + Cm2Str(dMDo) + " )"

select ld
set order to tag "5" // idradn + STR(godina) + STR(mjesec)
set filter to &cFilter
go top

// formula za obracun koeficijenta
LKOEF:="(PROSJ / (ld->brbod * VRBOD))"

// setuj zaglavlje
aLArgs:={}
AADD(aLArgs, {5, " RBr"})
AADD(aLArgs, {6, "  ID"})
AADD(aLArgs, {20, "   Ime i prezime"})
for i:=1 to LEN(aGodine)
	AADD(aLArgs, {10, "   " + aGodine[i]})
next
AADD(aLArgs, {10, "  UKUPNO"})
AADD(aLArgs, {10, " UK(10%)"})
cLine:=SetRptLineAndText(aLArgs, 0)
cTxt:=SetRptLineAndText(aLArgs, 1)

? cLine
? cTxt
? cLine

aPom:={}
aPomTot:={}
nUUk:=0

for i:=1 to LEN(aGodine)
	AADD(aPomTot, {aGodine[i], 0})
next

do while !EOF()
	
	cRdnk:=ld->idradn

	// prazna polja preskaci
	if Empty(cRdnk)
		skip
		loop
	endif
	
	if !Empty(cRadId)
		if cRdnk <> cRadId
			skip
			loop
		endif
	endif
	
	do while !EOF() .and. idradn == cRdnk 	
		
		for i:=1 to LEN(aGodine)
			
			nIznG:=0
		
			do while !EOF() .and. idradn == cRdnk .and. godina == VAL(aGodine[i])
				nScn := ASCAN(aParObr, {|aVal| aVal[1] == ld->godina .and. aVal[2] == ld->mjesec })

				// ako je nasao parametre obracuna
				
				if (nScn > 0)
					VRBOD := aParObr[nScn, 3]
					PROSJ := aParObr[nScn, 4]
				else
					skip
					loop
				endif
				
				select radn
				hseek ld->idradn
				select ld
				
				altd()	
				
				nKoef := &LKOEF
		
				// ako zadovoljava uslov za prikaz
				if (nKoef > 1) 
					nFixno := (I13 + I16)
					nUNeto := ld->uneto
					nUNNeto := nKoef * (nUNeto - nFixno)
					nIznG += nUNNeto - nUNeto + nFixno	
				endif
				skip
			enddo
			AADD(aPom, {aGodine[i], nIznG})
		next
	enddo
	
	nUk := 0
	nKontrola := 0
	
	for i:=1 to LEN(aPom)
		nKontrola += aPom[i, 2]
	next
	
	if (nKontrola > 0)
		PrintRadnik(nBrojac, cRdnk, PADR(ALLTRIM(radn->ime) + " " + ALLTRIM(radn->naz), 20))
		for i:=1 to LEN(aPom)
			PrintRow(aPom[i, 2])
			nUk += aPom[i, 2]
			nUUK += nUk
		next
	
		PrintRow(nUk)
		PrintRow(nUk * 0.1)
	
		++ nBrojac
	endif

	for i:=1 to LEN(aPom)
		aPomTot[i, 2] += aPom[i, 2]
	next

	aPom := {}
enddo

? cLine
? "UKUPNO:"
?? SPACE(26)
for i:=1 to LEN(aPomTot)
	PrintRow(aPomTot[i, 2])
next
PrintRow(nUUk)
PrintRow(nUUk*0.1)
? cLine


FF
END PRINT

return
*}


/*! \fn PrintRadnik(nCt, cId, cNaz)
 *  \brief Printa rbr, ime i prezime radnika u novi red
 *  \param nCt - counter
 *  \param cId - id radnika
 *  \param cNaz - naziv radnika
 */
static function PrintRadnik(nCt, cId, cNaz)
*{

? STR(nCt, 5)
?? SPACE(1) + cId
?? SPACE(1) + cNaz

return
*}


/*! \fn PrintRow(nIznos)
 *  \brief Ispisuje brojcanu vrijednost u postojecem redu
 *  \param nIznos - iznos koji se ispisuje
 */
static function PrintRow(nIznos)
*{
@ prow(), pcol()+1 SAY STR(nIznos, 10, 2)
return
*}


