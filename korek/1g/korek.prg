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
private lMjesec

// daj formu uslova izvjestaja i setuj varijable
if GetVars(@dMOd, @dYOd, @dMDo, @dYDo, @cRadId, @lMjesec) == 0
	return
endif

// daj podatke parametara obracuna i napuni ih u aParObr
// aParObr {}
// GODINA, MJESEC, VRBOD, PROSJ(70%)

cGodine := GetGodine(dYOd, dYDo)
aGodine := GetParObr(@aParObr, cGodine)

if LEN(aGodine) == 0
	MsgBeep("Greska pri sumiranju parametara obracuna!")
	return
endif

// prikazi razlike u obracunu plate
StRazlike(dMOd, dYOd, dMDo, dYDo, aGodine, aParObr, lMjesec, cRadId)


return
*}


/*! \fn GetVars()
 *  \brief Prikupi varijable izvjestaja
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
static function GetParObr(aParObr, cGodine)
*{
O_PAROBR

// napravi matricu iz cGodine:="2002;2003;2004;"
// aPom {}
// aPom[2002]
// aPom[2003]
// aPom[2004]

altd()

aPom:={}
aPom:=TokToNiz(ALLTRIM(cGodine), ";")
nErr:=0

for i:=1 to LEN(aPom)
	if EMPTY(aPom[i])
		loop
	endif
	if (aPom[i] <> "RADP")
		cPath := SIFPATH + aPom[i] + SLASH + "PAROBR"
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
	altd()
	do while !EOF()
		// puni matricu aParObr {}
		//   aParObr = 2002   , ID "1"     , vrbod, k2 
		AADD(aParObr, {VAL(aPom[i]), VAL(&cAlias->id), &cAlias->vrbod, &cAlias->k2})
		skip
	enddo

next

return aPom
*}



static function GetGodine(dY1, dY2)
*{

cGodine := ""
for i:=dY1 to dY2

	cGodine += STR(i, 4) + ";"
next

return cGodine
*}



/*! \fn StRazlike(dDat1, dDat2, aParObr, lMjesec, cRadId)
 *  \brief Stampa reporta razlika LD-a
 */
static function StRazlike(dMOd, dYOd, dMDo, dYDo, aGodine, aParObr, lMjesec, cRadId)
*{
O_LD
O_RADN
altd()
nBrojac:=1

START PRINT CRET

? "RPT: Prikaz razlika za uplatu"
?

P_COND

cFilter := " ( godina >= " + Cm2Str(dYOd) + " .and. mjesec >= "  + Cm2Str(dMOd) + " ) .and. ( godina <= " + Cm2Str(dYDo) + " .and. mjesec <= " + Cm2Str(dMDo) + " )"

select ld
set order to tag "5" // idradn + STR(godina) + STR(mjesec)
set filter to &cFilter
go top

// formula za obracun koeficijenta
KOEF:="(PROSJ / (ld->brbod * VRBOD))"

? REPLICATE("-", 95)
? "RBr  *  ID  * Ime i prezime      *"
for i:=1 to LEN(aGodine)
	?? SPACE(1)
	?? "    " + aGodine[i] + "  *"
next
?? "  UKUPNO   *  UK.(10%)  *"
? REPLICATE("-", 95)

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
					VRBOD:=aParObr[nScn, 3]
					PROSJ:=aParObr[nScn, 4]
				else
					skip
					loop
				endif
				select radn
				hseek ld->idradn
				select ld
	
				nKoef := &KOEF
		
				// ako zadovoljava uslov za prikaz
				if (nKoef > 1) 
		
					nUNeto := ld->uneto
					nUNNeto := nKoef * nUNeto
					nIznG += nUNNeto - nUNeto
			
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

? REPLICATE("-", 95)

? "UKUPNO:"
?? SPACE(26)
for i:=1 to LEN(aPomTot)
	PrintRow(aPomTot[i, 2])
next
PrintRow(nUUk)
PrintRow(nUUk*0.1)

? REPLICATE("-", 95)


FF
END PRINT

return
*}


static function PrintRadnik(nCt, cId, cNaz)
*{

? STR(nCt, 5)
?? SPACE(1) + cId
?? SPACE(1) + cNaz

return
*}


static function PrintRow(nIznos)
*{
?? SPACE(1), STR(nIznos, 10, 2)
return
*}


