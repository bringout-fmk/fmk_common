#include "sc.ch"

/*! \fn KarticaLog()
 *  \brief Stampa pregleda dogadjaja
 */
 
function KarticaLog()
*{
O_USERS
O_EVENTS
O_EVENTLOG

select eventlog
private dDatumOd:=Date()-1
private dDatumDo:=Date()
private cModul:=PADR(goModul:oDataBase:cName,10)
private cKomponenta:=SPACE(15)
private cFunkcija:=SPACE(30)
private cSirokiIspis:="N"
private cPrikUkupno:="N"
private cKorisn:=PADR(nUser,3)
private nNivoOd := 1
private nNivoDo := 5

Box(,10,60)
	@ m_x+1,m_y+2 SAY "Datum od:" GET dDatumOd
	@ m_x+1,col()+1 SAY "do:" GET dDatumDo
	@ m_x+3,m_y+2 SAY "Modul (prazno-svi)      :" GET cModul PICT "@!"
	@ m_x+4,m_y+2 SAY "Komponenta (prazno-sve) :" GET cKomponenta PICT "@!"
	@ m_x+5,m_y+2 SAY "Funkcija (prazno-sve)   :" GET cFunkcija PICT "@!"
	@ m_x+7,m_y+2 SAY "User (prazno-svi)       :" GET cKorisn //VALID {|| EMPTY(nUser) .or. P_User(@nUser)}
	@ m_x+8,m_y+2 SAY "Nivo bitnosti od:" GET nNivoOd PICT "9"
	@ m_x+8,col()+1 SAY "do:" GET nNivoDo PICT "9"
	read
	@ m_x+9,m_y+2 SAY "Detalji (D/N) :" GET cSirokiIspis VALID cSirokiIspis$"DN" PICT "@!"
	if (!EMPTY(cModul) .and. !EMPTY(cKomponenta) .and. !EMPTY(cFunkcija) .and. !EMPTY(cKorisn))
		@ m_x+10,m_y+2 SAY "Prikazati ukupno (D/N) :" GET cPrikUkupno VALID cPrikUkupno$"DN" PICT "@!"
	endif
	read
BoxC()

if (LastKey()==K_ESC)
	return
endif

IzvjEvents(dDatumOd,dDatumDo,cModul,cKomponenta,cFunkcija,cKorisn, ;
		nNivoOd, nNivoDo )

return


 
function IzvjEvents(dDatumOd,dDatumDo,cModul,cKomponenta,cFunkcija,cKorisnik, ;
		nNivoOd, nNivoDo )

private cFilter:=".t."

select eventlog

if (!EMPTY(dDatumOd) .or. !EMPTY(dDatumDo))
	cFilter+=".and.  datum>=" + Cm2Str(dDatumOd) + " .and. datum<="+Cm2Str(dDatumDo)
endif

if (!EMPTY(cModul))
	
	// fmk uvijek ide u filter	
	cFilter += " .and. ( objekat=" + Cm2Str(PADR("FMK",10))

	cFilter += " .or. objekat=" + Cm2Str(cModul) + ")"

endif

if (!EMPTY(cKomponenta))
	cFilter+=" .and. komponenta=" + Cm2Str(cKomponenta)
endif

if (!EMPTY(cFunkcija))
	cFilter+=" .and. funkcija=" + Cm2Str(cFunkcija)
endif

if (!EMPTY(cKorisnik))
	cFilter+=" .and. user=" + Cm2Str(VAL(cKorisnik))
endif



if (cFilter=" .t. .and. ") 
	cFilter:=SubStr(cFilter,9)
endif

if (cFilter==".t.")
	set filter to
else
	set filter to &cFilter
endif

go top

EOF CRET

START PRINT CRET

//         ID  USER                    DATUM     VRIJEME   OBJEKAT-KOMPONENTA-FUNKCIJA                     
cLinija:="---- ----------------------- --------- --------- ----------------------------"

ZaglKartEvent(cLinija)

nUkN1:=0
nUkN2:=0
nUkCount1:=0
nUkCount2:=0

aGrupe:={}

if (goModul:oDataBase:nGroup1<>nil)
	AADD(aGrupe, goModul:oDataBase:nGroup1)
endif

if (goModul:oDataBase:nGroup2<>nil)
	AADD(aGrupe, goModul:oDataBase:nGroup2)
endif

if (goModul:oDataBase:nGroup3<>nil)
	AADD(aGrupe, goModul:oDataBase:nGroup3)
endif

// provrti filterisane zapise
do while !eof() 
	
	if prow()>61	
		FF
		ZaglKartEvent(cLinija)
	endif
	
	// provjeri da li korisnik iz date grupe ima pravo
	// da vidi ovaj dogadjaj

	cObj:=field->objekat
	cKomp:=field->komponenta
	cFunc:=field->funkcija
	select events
	set order to tag "1"
	seek cObj+cKomp+cFunc
	
	// provjeri bitnost
	nNivo := field->bitnost
	if nNivo < nNivoOd .or. nNivo > nNivoDo
		select eventlog
		skip
		loop
	endif
	
	if !(ASCAN(aGrupe,field->security1)>0) 
		if !(ASCAN(aGrupe,field->security2)>0) 
			if !(ASCAN(aGrupe,field->security3)>0)	
				if !(goModul:oDataBase:nGroup1==900)
					select eventlog
					skip
					loop
				endif
			endif
		endif
	endif
	select eventlog
	
	? SPACE(2)+STR(field->id,4)
	?? SPACE(2)
	@ prow(),pcol()+1 SAY PADR( GetFullUserName( field->user ), 20 )  
	@ prow(),pcol()+1 SAY SPACE(2)+DTOC(field->datum)
	@ prow(),pcol()+1 SAY SPACE(2)+field->vrijeme+SPACE(3)
	@ prow(),pcol()+1 SAY ALLTRIM(field->objekat) + "-" + ;
				ALLTRIM(field->komponenta) + "-" + ;
				ALLTRIM(field->funkcija)
	if cSirokiIspis=="D"
		
		// pomocna numericka polja
		if ( field->n1 + field->n2 <> 0 )
		
			?
			? SPACE(8)+"* kolicina: "+STR(field->n1,10,2)+SPACE(5)+"cijena: "+STR(field->n2,10,2)
			nUkN1+=field->n1
			nUkN2+=field->n2
		endif

		// pomocna numericka polja
		if (field->count1 + field->count2 <> 0 )
			
			? SPACE(8)+"* pr.vr.1: "+STR(field->count1,10,2)+" pr.vr.2: "+STR(field->count2,10,2)
			nUkCount1+=field->count1
			nUkCount1+=field->count2
		endif

		// pomocni tekst 1
		cTxt := field->c1
		if !EMPTY(cTxt)
			aTxt := sjecistr(cTxt,70)
			for i:=1 to LEN(aTxt)
				if i = 1
				  ? SPACE(8)+"* " + aTxt[i]
				else
				  ? SPACE(10) + aTxt[i]
				endif
			next
		endif
		
		// pomocni tekst 2
		cTxt := field->c2
		if !EMPTY(cTxt)
			aTxt := sjecistr(cTxt,70)
			for i:=1 to LEN(aTxt)
				if i = 1
				  ? SPACE(8)+"* "
				  ?? aTxt[i]
				else
				  ? SPACE(10) + aTxt[i]
				endif

			next
		endif
	
		// pomocni tekst 3
		cTxt := field->c3
		if !EMPTY(cTxt)
			aTxt := sjecistr(cTxt,70)
			for i:=1 to LEN(aTxt)
				if i = 1
				  ? SPACE(8)+"* "
				  ?? aTxt[i]
				else
				  ? SPACE(10) + aTxt[i]
				endif

			next
		endif

		// datumi
		? SPACE(8) + "* datum (1): " + DTOC(field->d1) + ;
			     "  datum (2): " + DTOC(field->d2)

		// opis operacije
		? SPACE(8)+"* Opis: "+ALLTRIM(field->opis)
		
		// sql string - ako postoji
		if !EMPTY(field->sql)
			? SPACE(8) + "SQL/Ostalo: " + field->sql
		endif
		?
	endif
	skip
enddo      

if prow()>59
	FF
	ZaglKartEvent(cLinija)
endif

? SPACE(2) + cLinija

if cPrikUkupno == "D"
	UkIzvjEvents(nUkN1,nUkN2,nUkCount1,nUkCount2)

endif

set filter to  // ukini filter

FF
END PRINT

return
*}



/*! \fn ZaglKartEvent(cLinija)
 *  \brief Zaglavlje kartice dogadjaja
 *  \param cLinija linija za zaglavlje
 */
 
function ZaglKartEvent(cLinija)
*{
nStrana:=0

set century on

P_12CPI

? SPACE(2)
?? "Pregled logiranih dogadjaja:  ",Date(),SPACE(30),"Strana:",STR(++nStrana,3)

? SPACE(2)
?? "Period: ",dDatumOd," - ",dDatumDo
? SPACE(2)+"-------------------------------"
cStatus:=""

if !EMPTY(cModul)
	cStatus:=ALLTRIM(cModul)
else
	cStatus:="SVI"
endif

? SPACE(2)
?? "Objekat - modul: ",cStatus

if !Empty(cKomponenta)
	cStatus:=ALLTRIM(cKomponenta)
else
	cStatus:="SVE"
endif

? SPACE(2)
?? "Komponenta: ",cStatus

if !EMPTY(cFunkcija)
	cStatus:=ALLTRIM(cFunkcija)
else
	cStatus:="SVE"
endif

? SPACE(2)
?? "Funkcija: ",cStatus

if !EMPTY(cKorisn)
	select users
	set order to tag "ID"
	select eventlog 
	cStatus:=ALLTRIM(cKorisn)
	cStatus+=" - "+Ocitaj(F_USERS,PADL(ALLTRIM(cKorisn),3),"NAZ")
else
	cStatus:="SVI"
endif

? SPACE(2)
?? "User (korisnik): ",cStatus
? SPACE(2)+"-------------------------"

set century off

P_12CPI

? SPACE(2)+cLinija
? SPACE(2)+" Id   User                    Datum    Vrijeme   Objekat-komponenta-funkcija"
? SPACE(2)+cLinija

return
*}


/*! \fn UkIzvjEvents(nN1,nN2,nCnt1,nCnt2)
 *  \brief Dodaje ukupno na kraju izvjestaja
 *  \param nN1 - ukupno polje eventlog->n1
 *  \param nN2 - ukupno polje eventlog->n2
 *  \param nCnt1 - ukupno polje eventlog->count1
 *  \param nCnt2 - ukupno polje eventlog->count2
 */
 
function UkIzvjEvents(nN1,nN2,nCnt1,nCnt2)

?
? SPACE(2)+"-----------------------------------------"
? SPACE(2)+"UKUPNO: "
? SPACE(10)+"N1:     "+STR(nN1)
? SPACE(10)+"N2:     "+STR(nN2)
? SPACE(10)+"Count1: "+STR(nCnt1)
? SPACE(10)+"Count2: "+STR(nCnt2)	
? SPACE(2)+"-----------------------------------------"
?
return

