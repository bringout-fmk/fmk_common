#include "\cl\sigma\fmk\fakt\fakt.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fakt/db/1g/db.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.22 $
 * $Log: db.prg,v $
 * Revision 1.22  2003/12/12 15:24:51  sasavranic
 * uvedeno stampanje barkod-a i na varijantu fakture 2, 3
 *
 * Revision 1.21  2003/12/10 11:57:59  sasavranic
 * no message
 *
 * Revision 1.20  2003/12/08 15:12:20  sasavranic
 * Dorada za opresu, polje remitenda
 *
 * Revision 1.19  2003/10/04 12:32:48  sasavranic
 * uveden security sistem
 *
 * Revision 1.18  2003/07/06 21:50:54  mirsad
 * nova varijanta: unos radnog naloga na 12-ki (FMK.INI/KUMPATH/FAKT/RadniNalozi=D)
 *
 * Revision 1.17  2003/04/14 20:27:28  ernad
 * bug: lock requiered pri unosu partnera
 *
 * Revision 1.16  2003/04/12 23:00:38  ernad
 * O_Edit (O_S_PRIREMA)
 *
 * Revision 1.15  2003/01/21 15:01:58  ernad
 * probelm excl fakt - kalk ?! direktorij kalk
 *
 * Revision 1.14  2003/01/18 18:26:49  ernad
 * speed testing exclusive
 *
 * Revision 1.13  2003/01/18 12:08:50  ernad
 * no message
 *
 * Revision 1.12  2002/10/15 11:48:14  sasa
 * formatiranje koda
 *
 * Revision 1.11  2002/07/04 11:06:09  mirsad
 * dokumentovanje ini parametara
 *
 * Revision 1.10  2002/07/04 08:42:26  mirsad
 * dokumentovanje ini parametara
 *
 * Revision 1.9  2002/07/04 08:34:19  mirsad
 * dokumentovanje ini parametara
 *
 * Revision 1.8  2002/06/28 20:19:36  ernad
 *
 *
 * debug GenDokInv
 *
 * Revision 1.7  2002/06/28 10:20:33  ernad
 *
 *
 * ispravka fje IsDocExists, nova fja FaNoviBroj, debug Azur (lVrstap)
 *
 * Revision 1.6  2002/06/28 06:34:16  ernad
 *
 *
 * dokument inventure skeleton funkcija Generacija dokumenta viska, manjka
 *
 * Revision 1.5  2002/06/27 17:20:33  ernad
 *
 *
 * dokument inventure, razrada, uvedena generacija dokumenta
 *
 * Revision 1.4  2002/06/27 14:03:20  ernad
 *
 *
 * dok/2g init
 *
 * Revision 1.3  2002/06/26 17:54:16  ernad
 *
 *
 * ciscenja - za dokument inventure
 *
 * Revision 1.2  2002/06/18 08:30:35  sasa
 * no message
 *
 * Revision 1.1.1.1  2002/06/17 18:30:18  ernad
 * no message
 *
 *
 */

/*! \file fmk/fakt/db/1g/db.prg
 *  \brief Database operacije
 */

/*! \ingroup ini
  * \var *string FmkIni_SifPath_FAKT_VrstePlacanja
  * \brief Odredjuje da li se pojavljuje vrsta placanja pri unosu. Postoji i sifrarnik vrsta placanja.
  * \param N - default vrijednost
  * \param D - omogucava unos vrste placanja
  */
*string FmkIni_SifPath_FAKT_VrstePlacanja;


/*! \ingroup ini
  * \var *string FmkIni_SifPath_FAKT_Opcine
  * \brief Odredjuje da li se pojavljuje opcina pri unosu partnera. Postoji i sifrarnik opcina.
  * \param N - default vrijednost
  * \param D - omogucava unos opcine u tabelu partnera
  */
*string FmkIni_SifPath_FAKT_Opcine;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_Doks2
  * \brief Odredjuje da li ce se koristiti tabela doks2 koja inace predstavlja dodatak tabeli doks
  * \param N - default vrijednost
  * \param D - koristi se i tabela doks2
  */
*string FmkIni_KumPath_FAKT_Doks2;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_CROBA_GledajFakt
  * \brief Odredjuje da li ce se koristiti i FAKT-dokumenti za centralno pracenje stanja robe kroz sql-tabelu croba
  * \param N - default vrijednost
  * \param D - koriste se FAKT-dokumenti za centralno pracenje stanja robe
  */
*string FmkIni_KumPath_CROBA_GledajFakt;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_CROBA_CROBA_RJ
  * \brief Sadrzi sifre firmi/radnih jedinica ciji se dokumenti koriste za centralno pracenje stanja robe
  * \param 10#20 - gledaj radne jedinice 10 i 20, default vrijednost
  */
*string FmkIni_KumPath_CROBA_CROBA_RJ;


/*! \ingroup ini
  * \var *string FmkIni_SifPath_SifRoba_ID_J
  * \brief Omogucava koristenje dodatnih skrivenih sifara robe
  * \param N - default vrijednost
  * \param D - koriste se dodatne skrivene sifre robe
  */
*string FmkIni_SifPath_SifRoba_ID_J;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_ProtuDokument13kiIdeNaRJ
  * \brief Odredjuje sifru radne jedinice na kojoj se formira zaduzenje prodavnice kao automatski generisan dokument na osnovu dokumenta tipa 13
  * \param P1 - default vrijednost
  */
*string FmkIni_KumPath_FAKT_ProtuDokument13kiIdeNaRJ;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_Brojac11BezEkstenzije
  * \brief Ako su brojevi 11-ki koje se prave na tekucoj instalaciji bez ekstenzije a brojevi 11-ki koje se preuzimaju sa drugog prodajnog mjesta sa ekstenzijom onda se moze desiti da tekuci brojac ne daje zeljeni broj nove 11-ke pa se parametrom D rjesava ovaj problem
  * \param N - default vrijednost
  * \param D - pri odredjivanju sljedeceg broja dokumenta tipa 11 uzmi u obzir da su brojevi 11-ki koje se prave na tekucoj instalaciji bez ekstenzije
  */
*string FmkIni_KumPath_FAKT_Brojac11BezEkstenzije;


/*! \ingroup ini
  * \var *string FmkIni_KumPath_FAKT_NemaIzlazaBezUlaza
  * \brief Omogucava zabranu pravljenja dokumenata koji bi stanje robe doveli u minus
  * \param N - default vrijednost
  * \param D - zabrani pravljenje dokumenta koji "tjera robu u minus"
  */
*string FmkIni_KumPath_FAKT_NemaIzlazaBezUlaza;



/*! \fn O_Edit(cVar2)
 *  \brief Otvaranje tabela za editovanje podataka
 *  \param cVar2 := .t. - otvara se fakt kao priprema, za stampu stare fakture
 */
 
function O_Edit(cVar2)
*{
if glRadNal
	O_RNAL
endif

if glDistrib
	O_RELAC
  	O_VOZILA
  	O_KALPOS
endif

if goModul:lOpresaStampa
	O_POMGN
endif

if goModul:lVrstePlacanja
	O_VRSTEP
endif

if goModul:lOpcine
	O_OPS
endif

O_KONTO
O_SAST
O_PARTN
O_ROBA

#ifdef CAX
	select (F_PRIPR)
  	use
#endif

if (PCount()==0)
	O_S_PRIPR
 	O_FAKT
else
 	O_PFAKT
endif

O_FTXT
O_TARIFA
O_VALUTE

if goModul:lDoks2
	O_DOKS2
endif

O_DOKS
O_RJ
O_SIFK
O_SIFV


select pripr
set order to 1
go top
return nil
*}


/*! \fn PovSvi()
 *  \brief Povrat dokumenta u pripremu sa zadanim kriterijem
 */

function PovSvi()
*{
local nRec
private qqBrDok:=SPACE(80)
private qqDatDok:=SPACE(80)
private qqTipdok:=SPACE(80)

if (KLevel<>"0")
	Beep(2)
    	Msg("Nemate pristupa ovoj opciji !",4)
    	closeret
endif

O_FAKT

// obavezno exclusivno otvori
O_PRIPR
O_DOKS

lDoks2:=.f.

if goModul:lDoks2
	lDoks2:=.t.
  	O_DOKS2
endif

SELECT fakt
set order to 1

cIdFirma:=gFirma
cIdTipDok:=SPACE(2)
cBrDok:=SPACE(8)
cIdF:=cIdFirma

Box(,4,60)
	do while .t.
  		@ m_x+1,m_y+2 SAY "Rj               "  GEt cIdF pict "@!"
  		@ m_x+2,m_y+2 SAY "Vrste dokumenata "  GEt qqTipdok pict "@S40"
  		@ m_x+3,m_y+2 SAY "Broj dokumenata  "  GEt qqBrDok pict "@S40"
  		@ m_x+4,m_y+2 SAY "Datumi           "  GET qqDatDok pict "@S40"
  		read
  	
		private aUsl1:=Parsiraj(qqBrDok,"BrDok","C")
  		private aUsl2:=Parsiraj(qqDatDok,"DatDok","D")
  		private aUsl3:=Parsiraj(qqTipdok,"IdTipdok","C")
  		if (aUsl1<>nil .and. aUsl2<>nil .and. aUsl3<>nil)
    			exit
  		endif
 	enddo
Boxc()

if Pitanje("","Dokumente sa zadanim kriterijumom vratiti u pripremu ???","N")=="N"
	closeret
endif

Beep(6)

if Pitanje("","Jeste li sigurni ???","N")=="N"
	closeret
endif

select fakt

if !FLock()
	Msg("FAKT datoteka je zauzeta ",3)
	closeret
endif

if lDoks2
	select doks2
  	if !FLock()
		Msg("DOKS2 datoteka je zauzeta ",3)
		closeret
	endif
endif

select doks

if !FLock()
	Msg("DOKS datoteka je zauzeta ",3)
	closeret
endif

private cFilt:=aUsl1+".and."+aUsl2+".and."+aUsl3+if(EMPTY(cIdF),"",".and.IdFirma=="+cm2str(cIdF))

cFilt:=STRTRAN(cFilt,".t..and.","")

if cFilt==".t."
	set filter to
else
	set filter to &cFilt
endif

go top

do while !eof()
	cIdFirma:=idfirma
	cIdTipDok:=idtipdok
	cBrDok:=brdok
	select fakt
	seek cIdFirma+cIdTipDok+cBrDok

	if !Found()
  		select doks
  		skip
		loop
	endif

	fRezerv:=.f.
	fPrenesi:=.f.
	do while !eof() .and. cIdFirma==idfirma .and. cIdTipDok==idtipdok .and. cBrDok==brdok
   		fPrenesi=.t.
   		select fakt
		Scatter()
   		if !fRezerv .and. _idtipdok$"20#27" .and. _Serbr="*" .and. Pitanje(,"Predracun je na rezervaciji - ukinuti je ?","D")=="D"
      			fRezerv:=.t.
   		endif
   		select pripr
   		append ncnl
   		if fRezerv .and. _idtipdok$"20#27"  
		// ako je bio na rezervaciji
      			_serbr:=""
   		endif
   		Gather2()
   		select fakt
   		skip
	enddo
	
	if fPrenesi
  		select doks
  		seek cIdFirma+cIdTipDok+cBrDok
  		do while !eof() .and. cIdFirma==idfirma .and. cIdTipDok==idtipdok .and. cBrDok==brdok
    			skip 1
			nRec:=RecNo()
			skip -1
    			DbDelete2()
    			go nRec
  		enddo
  		
		if lDoks2
    			select doks2
    			seek cIdFirma+cIdTipDok+cBrDok
    			do while !eof() .and. cIdFirma==idfirma .and. cIdTipDok==idtipdok .and. cBrDok==brdok
      				skip 1
				nRec:=RecNo()
				skip -1
      				DbDelete2()
      				go nRec
    			enddo
  		endif
  		select fakt
  		seek cIdFirma+cIdTipDok+cBrDok
  		do while !eof() .and. cIdFirma==idfirma .and. cIdTipDok==idtipdok .and. cBrDok==brdok
    			skip 1
			nRec:=RecNo()
			skip -1
    			DbDelete2()
    			go nRec
  		enddo
	endif // fprenesi

	select doks

enddo // eof
closeret
*}


/*! \fn Povrat(fR,cIdFirma,cIdTipDok,cBrDok,lTest)
 *  \brief Povrat dokumenta u pripremu
 *  \param fR          - rezervacija
 *  \param cIdFirma
 *  \param cIdTipDok
 *  \param cBrDok
 *  \param lTest
 */

*function Povrat(fR,cIdFirma,cIdTipDok,cBrDok,lTest)
*{

function Povrat
parameters fR, cIdFirma, cIdTipDok, cBrDok, lTest
local fBrisao:=.f.
local nRec
local cBrisiKum := " "

if lTest==nil
	lTest:=.f.
endif

if (PCount()==0)
	fR:=.f.
endif

if (KLevel>"1")  // Klevel <> "0"
	Beep(2)
    	Msg("Nemate pristupa ovoj opciji !",4)
    	closeret
endif


O_FAKT

// obavezno exclusivno otvori
O_PRIPR
O_DOKS

set filter to

lDoks2:=.f.

if goModul:lDoks2
	lDoks2:=.t.
 	O_DOKS2
endif

select fakt
set order to 1

cSifDok:="  "

if cIdFirma==nil  // bez parametara
	cIdFirma:=gFirma
  	if fR
    		if Pitanje(,"Prekinuti rezervaciju VP-20 ili MP-27 (V/M)?","V","VM")=="V"
      			cSifDok:="20"
    		else
      			cSifDok:="27"
    		endif
  	endif
  	
	cIdTipDok:=SPACE(2)
  	cBrDok:=SPACE(8)

  	Box("",1,35)
   		@ m_x+1,m_y+2 SAY "Dokument:"
   		@ m_x+1,col()+1 GET cIdFirma
   		@ m_x+1,col()+1 SAY "-"
   		
		if fR
     			cIdTipDok:=cSifDok
     			@ m_x+1,col()+1 SAY cIdTipDok
   		else
     			@ m_x+1,col()+1 GET cIdTipDok
   		endif
   		
		@ m_x+1,col()+1 SAY "-" GET cBrDok
   		read
		ESC_BCR
  	BoxC()

endif  // cidfirma=NIL

if (!fR .and. !lTest)
	if Pitanje("","Dokument "+cIdFirma+"-"+cIdTipDok+"-"+cBrDok+" povuci u pripremu (D/N) ?","D")=="N"
   		closeret
 	endif
endif

select fakt

if !FLock()
	MsgBeep("FAKT datoteka je zauzeta ",10)
	closeret
endif

if lDoks2
	select doks2
  	if !FLock()
		Msg("DOKS2 datoteka je zauzeta ",10)
		closeret
	endif
endif

select doks

if !FLock()
	MsgBeep("DOKS datoteka je zauzeta ",10)
	closeret
endif

fBrisao:=.f.

if !fR
	select fakt
  	hseek cIdFirma+cIdTipDok+cBrDok
  	//NFOUND CRET
  	if (fakt->m1=="X")
    		// izgenerisani dokument
    		MsgBeep("Radi se o izgenerisanom dokumentu!!!")
    		if Pitanje(,"Zelite li nastaviti?!", "N")=="N"
      			CLOSERET
    		endif
  	endif
	
  	fRezerv:=.f.
  	fBrisao:=.f.
  	do while !eof() .and. cIdFirma==idfirma .and. cIdTipDok==idtipdok .and. cBrDok==brdok
    		fBrisao:=.t.
    		select fakt
		Scatter()
    		if (!fRezerv .and. _idtipdok$"20#27" .and. _Serbr="*" .and. Pitanje(,"Predracun je na rezervaciji - ukinuti je ?","D")=="D")
       			fRezerv:=.t.
       			// potvrda da se ukine rezervacija
    		endif
    		
		select pripr
    		append ncnl
    		if (fRezerv .and. _idtipdok$"20#27")  
			// ako je bio na rezervaciji
       			_serbr:=""
    		endif
    		
		Gather2()
    		select fakt
    		skip
  	enddo

  	// setuj varijablu fBrisao !!
  	select doks
  	hseek cIdFirma+cIdTipDok+cBrDok
  	do while !eof() .and. cIdFirma==idfirma .and. cIdTipDok==idtipdok .and. cBrDok==brdok
     		fBrisao:=.t.
     		skip
  	enddo

endif // !fr

if (fR .or. fRezerv)
	select fakt
 	seek cIdFirma+cIdTipDok+cBrDok
 	//NFOUND CRET
	fBrisao:=.f.
 	do while !eof() .and. cIdFirma==idfirma .and. cIdTipDok==idtipdok .and. cBrDok==brdok
    		select fakt
		Scatter()
    		_serbr:=""
    		Gather2()
    		select fakt
    		fBrisao:=.t.
    		skip
 	enddo
 	
	select doks
 	seek cIdFirma+cIdTipDok+cBrDok
 	//NFOUND CRET
 	do while !eof() .and. cIdFirma==idfirma .and. cIdTipDok==idtipdok .and. cBrDok==brdok
    		select doks
		Scatter()
    		_rezerv:=""  // ukini rezervaciju
    		Gather2()
    		select fakt
    		fBrisao:=.t.
    		skip
 	enddo
 	Beep(1)
endif

if !fR
	if !fBrisao
    		MsgBeep("Ne postoji zadani dokument ")
    		closeret
  	endif
  	if lTest
    		cBrisiKum:="D"
  	else
    		cBrisiKum:=Pitanje("","Zelite li izbrisati dokument iz datoteke kumulativa (D/N)?","N")
  	endif
  	
	if (cBrisiKum=="D")
    		if lDoks2
      			select doks2
      			seek cIdFirma+cIdTipDok+cBrDok
      			do while !eof() .and. cIdFirma==idfirma .and. cIdTipDok==idtipdok .and. cBrDok==brdok
        			skip 1
				nRec:=RecNo()
				skip -1
        			DbDelete2()
        			go nRec
      			enddo
    		endif
    		
		select doks
    		seek cIdFirma+cIdTipDok+cBrDok
    		do while !eof() .and. cIdFirma==idfirma .and. cIdTipDok==idtipdok .and. cBrDok==brdok
      			skip 1
			nRec:=RecNo()
			skip -1
      			DbDelete2()
      			go nRec
    		enddo
    		if Logirati(goModul:oDataBase:cName,"DOK","POVRATDOK")
			EventLog(nUser,goModul:oDataBase:cName,"DOK","POVRATDOK",nil,nil,nil,nil,"","",cIdFirma+"-"+cIdTipDok+"-"+cBrDok,Date(),Date(),"","Povrat dokumenta u pripremu")
		endif
		select fakt
    		seek cIdFirma+cIdTipDok+cBrDok
    		//parametri za croba
    		fCroba:=(IzFmkIni('CROBA','GledajFakt','N',KUMPATH)=='D')
    		cROBA_RJ:=IzFmkIni('CROBA','CROBA_RJ','10#20',KUMPATH)

    		if fCROBA
     			nH:=0
     			cSQLFile:='c:\sigma\sql'
     			ASQLCRoba(@nH,cSQLFile)
    		endif

    		do while !eof() .and. cIdFirma==idfirma .and. cIdTipDok==idtipdok .and. cBrDok==brdok
      			skip 1
			nRec:=RecNo()
			skip -1
      			if (fCRoba .and. idfirma$cROBA_RJ)
        			if (idtipdok="0")
          				ASQLCRoba(@nH,"#CONT",idroba,"V","1",-kolicina)
        			elseif (idtipdok="1" .and. !(idtipdok="10".and.serbr="*") .or. idtipdok$"20#27" .and. serbr="*" .or. idtipdok="21")
          				ASQLCRoba(@nH,"#CONT",idroba,"V","2",-kolicina)
        			endif
      			endif
      			
			DbDelete2()
      			go nRec
    		enddo
    		
		if fCROba
     			MsgO("Pokrecem SQL-croba update")
       			ASQLCroba(@nH,"#END#"+cSQLFile)
     			Msgc()
    		endif
  	endif
endif // !fr

if (cBrisiKum=="N")
	// u PRIPR resetujem flagove generacije, jer mi je dokument ostao u kumul.
	select pripr
  	set order to 1
  	hseek cIdFirma+cIdTipDok+cBrDok
  	
	while !eof() .and. pripr->(idfirma+idtipdok+brdok)==(cIdFirma+cIdTipDok+cBrDok)
    		if (pripr->m1=="X")
      			replace m1 WITH " "
    		endif
    		skip
  	enddo
endif

closeret
return
*}



/*! \fn SpojiDuple()
 *  \brief Spajanje duplih artikala unutar jednog dokumenta
 */

function SpojiDuple()
*{
local cIdRoba
local nCnt 
local nKolicina
local cSpojiti 
local nTrec

select pripr

cSpojiti:="N"

if gOcitBarkod
	set order to tag "3"
 	go top
 	do while !eof()
    		nCnt:=0
    		cIdRoba:=idroba
    		nKolicina:=0
    		do while !eof() .and. idroba==cIdRoba
      			nKolicina+=kolicina
      			nCnt++
      			skip
    		enddo
    		
		if (nCnt>1) // imamo duple!!!
       			if cSpojiti=="N"
          			if Pitanje(,"Spojiti duple artikle ?","D")=="D"
             				cSpojiti:="D"
          			else
             				cSpojiti:="0"
          			endif
       			endif
       			
			if cSpojiti=="D"
         			seek _idfirma + cIdRoba // idi na prvu stavku
         			replace kolicina with nKolicina
         			skip
         			do while !eof() .and. idroba==cIdRoba
           				replace kolicina with 0  
					// ostale stavke imaju kolicinu 0
           				skip
         			enddo
       			endif

    		endif
	enddo
endif

if cSpojiti="D"
	select pripr
	go top
  	do while !eof()
      		skip
      		nTrec:=RecNo()
      		skip -1
      		
		// markirano za brisanje
		if (field->kolicina=0)  
         		delete
      		endif
      		go nTrec
  	enddo
endif

select pripr
set order to tag "1"
go top
return
*}




/*! \fn SrediRbr()
 *  \brief Sredi redni broj
 */
 
function SrediRbr()
*{
local nRbr:=0
local nRbrStari:=0
local cPom:=0
local cDok:=""

O_S_PRIPR
GO TOP

cDok:=idfirma+idtipdok+brdok

do while !eof()
	Scatter()
    	cPom:=_rbr
    	if (cDok != _idfirma+_idtipdok+_brdok)
      		nRbrStari:=0
		nRbr:=0
    	endif
    	if nRbrStari==RbrUnum(_rbr)
      		_rbr:=RedniBroj(nRbr)
    	else
      		++nRbr
      		_rbr:=RedniBroj(nRbr)
    	endif
    	
	Gather()
    	
	nRbrStari:=RbrUnum(cPom)
    	cDok:=idfirma+idtipdok+brdok
    	skip 1
enddo

closeret
return
*}


/*! \fn Azur(lTest)
 *  \brief Azuriranje knjizenja
 *  \param lTest
 */
 
function Azur(lTest)
*{

local fRobaIDJ:=.f.
local cKontrolBroj:=""
local nPom1
local nPom2
local nPom3
local fCRoba:=.f.
local nHPid
local cType

cType:=TYPE("lVrsteP")
altd()
if (cType<>"L")
	lVrsteP:=.f.
endif

if (lTest==nil)
	lTest:=.f.
endif

if (!lTest .and. Pitanje( ,"Sigurno zelite izvrsiti azuriranje (D/N)?","N")=="N")
	return
endif

O_Edit()

// otvori exclusivno
select pripr
USE
O_PRIPR

go bottom

cPom:=idfirma+idtipdok+brdok

go top

lViseDok:=!(cPom==idfirma+idtipdok+brdok)

aOstaju:={}

if Empty(NarBrDok())
	closeret
endif

nHPid:=0

lDoks2:=goModul:lDoks2

if (!lDoks2 .and. !(fakt->(FLock()) .and. doks->(FLock())) .or. lDoks2 .and. !(fakt->(FLock()) .and. doks->(FLock()) .and. doks2->(FLock())))
	Beep(4)
  	Msg("Azuriranje NE moze vrsiti vise korisnika istovremeno !", 15)
  	closeret
endif

fRobaIDJ:=goModul:lId_J

fProtu:=.f.

if (gProtu13=="D" .and. pripr->idtipdok=="13" .and. Pitanje(,"Napraviti protu-dokument zaduzenja prodavnice","D")=="D")
	if (gVar13=="2" .and. gVarNum=="1")
      		cPRj:=RJIzKonta(pripr->idpartner+" ")
    	else
      		O_RJ
      		Box(,2,50)
       			cPRj:=IzFMKIni("FAKT","ProtuDokument13kiIdeNaRJ","P1",KUMPATH)
       			@ m_x+1,m_y+2 SAY "RJ - objekat:" GET cPRj valid P_RJ(@cPRJ) pict "@!"
       			read
      		BoxC()
      		select rj
		use
    	endif
    	
	lVecPostoji:=.f.
    	// prvo da provjerimo ima li isti broj dokumenta u DOKS
    	cKontrol2Broj:=pripr->(cPRJ+"01"+TRIM(brdok)+"/13")
    	select DOKS
	seek cKontrol2Broj
    	
	if Found()
      		lVecPostoji:=.t.
    	else
      		// ako nema u DOKS, 
		// provjerimo ima li isti broj dokumenta u FAKT
      		select fakt
		seek cKontrol2Broj
      		if Found()
			lVecPostoji:=.t.
		endif
    	endif
    	
	if lVecPostoji
      		Msg("Vec postoji dokument pod brojem "+pripr->(cPRJ+"-01-"+TRIM(brdok)+"/13"),4)
      		closeret
    	endif
    	fProtu:=.t.
endif

select doks
go top
set order to 1

cKontrolBroj:=pripr->(idfirma+idtipdok+brdok)

seek cKontrolBroj

lVecPostoji:=(Found() .and. (gMreznoNum=="N" .or. M1 <> "Z"))

if !lVecPostoji
	// nema ga u DOKS, ima li ga u FAKT ?
   	select fakt
	seek cKontrolBroj
   	if Found()
		lVecPostoji:=.t.
	endif
endif

if lVecPostoji
	Beep(4)
  	Msg("Dokument "+pripr->(idfirma+"-"+idtipdok+"-"+brdok)+" vec postoji pod istim brojem!",4)
  	if !lViseDok
    		return
  	endif
endif

fRobaIDJ:=goModul:lId_J

select roba
set order to tag "ID"
select pripr
go top

//parametri za croba

fCroba:=goModul:lCRoba
cROBA_RJ:=goModul:cRoba_RJ

if fCROBA
	nH:=0
 	// zapocni sql
 	cSQLFile:='c:\sigma\sql'
 	ASQLCRoba(@nH,cSQLFile)
endif

Box("#Proces azuriranja u toku",3,60)
	do while !eof()
  	if lViseDok
    		cPom:=idfirma+idtipdok+brdok
    		select doks
    		seek cPom
    		if Found() .and. (gMreznoNum=="N" .or. M1 <> "Z")
      			AADD(aOstaju,cPom)
      			select pripr
      			do while !eof() .and. cPom==idfirma+idtipdok+brdok
        			skip 1
      			enddo
      			loop
    		else
      			cKontrolBroj:=cPom
      			@ m_x+2, m_y+2 SAY "Azuriram dokument "+pripr->(idfirma+"-"+idtipdok+"-"+brdok)
    		endif
  	endif

  	select pripr
  	Scatter()

  	select fakt
  	
	AppBlank2(.f.,.f.)   // nemoj brisati i nemoj otkljucavati
  	
	if fRobaIDJ  
		// nafiluj polje IDROBA_J u prometu
   		select roba
		hseek _idroba
   		_idroba_j:=roba->id_j
   		select fakt
  	endif
  	
	Gather2() // opet nemoj otkljucavati

   	if (fCRoba .and. idfirma$cRoba_Rj)
     		if (_idtipdok="0")
       			ASQLCroba(@nH,"#CONT",_idroba,"V","1",_kolicina)
     		elseif (_idtipdok="1" .and. !(_idtipdok="10".and._serbr="*") .or._idtipdok$"20#27" .and. _serbr="*" .or. _idtipdok="21")
       			ASQLCroba(@nH,"#CONT",_idroba,"V","2",_kolicina)
     		endif
   	endif

  	if (fProtu .and. idtipdok=="13")
     		// appblank2(.f.,.t.)
     		AppBlank2(.f.,.f.)  // opet nemoj otkljucavati
     		_idfirma:=cPRJ
     		_idtipdok:="01"
     		_brdok:=TRIM(_brdok)+"/13"
     		// gather()
     		Gather2()
  	endif
  	select pripr
  	
	if goModul:lOpresaStampa .and. pripr->idtipdok=="13" .and. pripr->idfirma=="99"
		nDana:=VAL(IzFmkIni("Opresa", "PlusMinusDana", "0", KUMPATH))
		InsertIntoPOMGN(pripr->datdok, pripr->idroba, pripr->idpartner, pripr->kolicina, nDana)
	endif
	
	skip
enddo

select pripr
go top
do while !eof()
	if (lViseDok .and. ASCAN(aOstaju,cPom:=idfirma+idtipdok+brdok)<>0)
    		do while !eof() .and. cPom==idfirma+idtipdok+brdok
      			skip 1
    		enddo
    		loop
  	endif

  	select doks
  	set order to 1
  	
	hseek pripr->idfirma+pripr->idtipdok+pripr->brdok
  	
	if !Found()
     		// append blank
     		AppBlank2(.f.,.f.)
  	endif
  	
	if lDoks2
    		select doks2
    		set order to 1
    		hseek pripr->idfirma+pripr->idtipdok+pripr->brdok
    		if !Found()
       			// append blank
       			AppBlank2(.f.,.f.)
    		endif
  	endif
  	
	select pripr

  	cIdFirma:=idfirma
  	private cBrDok:=brdok
	private cIdTipDok:=idtipdok
	private dDatDok:=datdok
	
  	aMemo:=ParsMemo(txt)
  	
	if (LEN(aMemo)>=5)
    		cTxt:=TRIM(aMemo[3])+" "+TRIM(aMemo[4])+","+TRIM(aMemo[5])
  	else
    		cTxt:=""
  	endif
  	
	cTxt:=PadR(cTxt,30)
  	cDinDem:=dindem
  	cRezerv:=" "
  	
	if (cIdTipDok$"10#20#27" .and. Serbr="*")
     		cRezerv:="*"
  	endif
  	
	select doks
  	_field->IdFirma   := cIdFirma
  	_field->BrDok     := cBrDok
  	_field->Rezerv    := cRezerv
  	_field->DatDok    := dDatDok
  	_field->IdTipDok  := cIdTipDok
  	_field->Partner   := cTxt
  	_field->dindem    := cDinDem
  	_field->IdPartner := PRIPR->IdPartner
  	
	if lVrsteP
   		_field->IdVrsteP:=pripr->idvrstep
  	endif
  	
	if (FieldPos("DATPL")>0)
   		_field->DatPl:=if(LEN(aMemo)>=9,CToD(aMemo[9]),CToD(""))
  	endif
  	
	if (doks->m1=="Z")
    		// skidam zauzece i dobijam normalan dokument
    		// REPLACE m1 WITH " " -- isto kao i gore
    		_field->m1 := " "
  	endif
  	
	if (FieldPos("SIFRA")<>0)
     		// replace sifra with sifrakorisn
     		_field->sifra:=SifraKorisn
  	endif
  	
	if lDoks2
    		select doks2
    		_field->idfirma:=cIdFirma
    		_field->brdok:=cBrDok
    		_field->idtipdok:=cIdTipDok
    		_field->k1:=if(LEN(aMemo)>=11,aMemo[11],"")
    		_field->k2:=if(LEN(aMemo)>=12,aMemo[12],"")
    		_field->k3:=if(LEN(aMemo)>=13,aMemo[13],"")
    		_field->k4:=if(LEN(aMemo)>=14,aMemo[14],"")
    		_field->k5:=if(LEN(aMemo)>=15,aMemo[15],"")
    		_field->n1:=if(LEN(aMemo)>=16,VAL(ALLTRIM(aMemo[16])),0)
    		_field->n2:=if(LEN(aMemo)>=17,VAL(ALLTRIM(aMemo[17])),0)
  	endif
  	
	select pripr
  	nDug:=0
	nRab:=0
  	nDugD:=0
	nRabD:=0
  	
	do while !eof() .and. cIdFirma==idfirma .and. cIdTipdok==idtipdok .and. cBrDok==brdok
    		if cDinDem==LEFT(ValBazna(),3)
        		nPom1:=Round(kolicina*Cijena*PrerCij()*(1-Rabat/100),ZAOKRUZENJE)
        		// npom1 - cijena sa porezom i uracunatim rabatom
        		nPom2:=ROUND( kolicina*Cijena*PrerCij()*Rabat/100 , ZAOKRUZENJE)
        		// rabat za stavku
        		nPom3:=ROUND(nPom1*Porez/100, ZAOKRUZENJE)
        		nDug+= nPom1 + nPom3
        		// nDug je iznos ukupne fakture, ali bez izbijenog rabata !!!
        		nRab+= nPom2
    		else
        		//nPom1:=round( Cijena*kolicina*PrerCij()/UBaznuValutu(datdok)*(1+Porez/100), ZAOKRUZENJE)
        		// greska kada imamo porez  !!
        		nPom1:=round( kolicina*Cijena*PrerCij()/UBaznuValutu(datdok)*(1-Rabat/100), ZAOKRUZENJE)
        		// npom1 - cijena sa porezom i uracunatim rabatom
        		nPom2:=ROUND( kolicina*Cijena*PrerCij()/UBaznuValutu(datdok)*Rabat/100 , ZAOKRUZENJE)
        		// rabat za stavku
        		nPom3:=ROUND(nPom1*Porez/100, ZAOKRUZENJE)
        		nPom3:=ROUND(nPom1*Porez/100, ZAOKRUZENJE)
        		nDugD+= nPom1 + nPom3
        		nRabD+= nPom2
    		endif
    		skip
  	enddo
  
  	select doks
  	
	if (cDinDem==LEFT(ValBazna(),3))
   		_field->Iznos:=nDug  //-nRab   
		// iznos sadrzi umanjenje za rabat
   		_field->Rabat:=nRab
  	else
   		_field->Iznos := nDugD      //-nRab
   		_field->Rabat := nRabD
 	endif
  	
	// replace DINDEM with cDinDEM -- ovo je vec uradjeno ranije linija 1241
  	if (idtipdok=="13" .and. fProtu)  // protu dokument
    		Scatter()
    		// appblank2(.f.,.t.)       kljuccanje, kljuccanje
    		AppBlank2(.f.,.f.)
    		_idtipdok:="01"
    		_idfirma:=cPRJ
    		_BrDok:=TRIM(_brdok)+"/13"
    		// gather()    isto, isto ...
    		Gather2()
    		Beep(1)
    		Msg("Izgenerisan je dokument pod brojem "+_idfirma+"-01-"+_brdok,4)
    		if lDoks2
      			SELECT DOKS2
      			Scatter()
      			AppBlank2(.f.,.f.)
      			_idtipdok:="01"
      			_idfirma:=cPRJ
      			_brdok:=TRIM(_brdok)+"/13"
      			Gather2()
    		endif
    		// protu dokument
  	endif
	if Logirati(goModul:oDataBase:cName,"DOK","UNOSDOK")
		EventLog(nUser,goModul:oDataBase:cName,"DOK","UNOSDOK",nil,nil,nil,nil,"","",cIdFirma+"-"+cIdTipDok+"-"+cBrDok,dDatDok,Date(),"","Azuriranje dokumenta")
	endif
  	select pripr
enddo

PrModem()

lAzurOK:=.t.

select doks
go top

seek cKontrolBroj

if Found()
	select fakt
	go top
  	seek cKontrolBroj
  	if !Found()
    		lAzurOK:=.f.
  	elseif lDoks2
    		select doks2
		go top
    		seek cKontrolBroj
    		if !Found()
      			lAzurOK:=.f.
    		endif
  	endif
else
	lAzurOK:=.f.
endif

if !lAzurOK
	MsgBeep("Neuspjelo azuriranje! Priprema nije izbrisana!# 1) Izvrsite reindeksiranje# 2) Promijenite broj dokumenta u pripremi# 3) Izvrsite povrat dokumenta pod brojem koji ste prvi put zadali# 4) Izbrisite u pripremi stavke koje su vracene# 5) Vratite broj dokumenta na prvobitni i ponovo pokusajte azuriranje")
else
	select pripr
  	if (lViseDok .and. LEN(aOstaju)>0)
    		// izbrisi samo azurirane
    		go top
    		do while !eof()
      			skip 1
			nRecNo:=RecNo()
			skip -1
      			if (ASCAN(aOstaju,idfirma+idtipdok+brdok)=0)
        			delete
      			endif
      			go (nRecNo)
    		enddo
    		
		__dbpack()
    		
		MsgBeep("U pripremi su ostali dokumenti koji izgleda da vec postoje medju azuriranim!")
  	else
    		ZAP
  	endif
endif

if fCRoba
	MsgO("Pokrecem SQL-croba update")
  	ASQLCroba(@nH,"#END#"+cSQLFile)
 	Msgc()
endif 

BoxC()

closeret
return
*}


/*! \fn OdrediNBroj(_idfirma,_idtipdok)
 *  \brief 
 *  \param _idfirma
 *  \param _idtipdok
 */
 
function OdrediNbroj(_idfirma, _idtipdok)
*{
local lBrdok:=""

select DOKS
set order to 1
go top
altd()
if (gVarNum=="2".and._idtipdok=="13")
	seek _idfirma+_idtipdok+PADL(ALLTRIM(STR(VAL(ALLTRIM(SUBSTR(_idpartner,4))))),2,"0")+CHR(238)
 	skip -1
 	do while !bof() .and. _idfirma==idfirma.and._idtipdok==idtipdok.and.LEFT(_idpartner,6)==LEFT(idpartner,6).and.SUBSTR(brdok,6,2)!=PADL(ALLTRIM(STR(MONTH(_datdok))),2,"0")
   		skip -1
 	enddo
else
	seek _idfirma+_idtipdok+"È"
 	skip -1
 	if (_idtipdok=="11" .and. !EMPTY(SUBSTR(brdok,gNumDio+1)) .and. IzFmkIni("FAKT","Brojac11BezEkstenzije","N",KUMPATH)=="D")
   		do while !bof() .and. _idfirma==idfirma .and. _idtipdok==idtipdok .and. !Empty(SUBSTR(brdok,gNumDio+1))
     			skip -1
   		enddo
 	endif
endif

if (_idtipdok<>idtipdok .or. _idfirma<>idfirma .or. LEFT(_idpartner,6)<>LEFT(idpartner,6) .and. (gVarNum=="2" .and. _idtipdok=="13"))
	if (gVarNum=="2".and._idtipdok=="13")
    		lBrDok:=PADL(ALLTRIM(STR(VAL(ALLTRIM(SUBSTR(_idpartner,4))))),2,"0")+"01/"+PADL(ALLTRIM(STR(MONTH(_datdok))),2,"0")
  	else
    		lBrDok:=UBrojDok(1,gNumDio,"")
  	endif
else
	if (gVarNum=="2".and._idtipdok=="13")
    		lBrDok:=SljBrDok13(brdok,MONTH(_datdok),_idpartner)
  	else
    		lBrDok:=UBrojDok( val(left(brdok,gNumDio))+1, gNumDio, right(brdok,len(brdok)-gNumDio))
  	endif
endif

if (glDistrib .and. _idtipdok=="10" .and. UPPER(RIGHT(TRIM(lBrDok),1))=="S")
  	lBrDok:=padr(left(lBrdok,gNumDio),8)
else
  	lBrDok:=padr(lBrdok,8)
endif

return lBrDok
*}


/*! \fn FaNoviBroj(cIdFirma, cIdTiDdok)
 *  \brief Odredi novi broj Fakt-dokumenta 
 *  \param cIdFirma
 *  \param cIdTipDok
 *
 *  \note Ne pokriva specif. slucajeve "a-la" Nijagara ...
 */
 
function FaNovibroj(cIdFirma, cIdTipDok)
*{
local cBrdok
local cPom
local cDesniDio
local nPom
local nDesniDio

cBrDok:=""

select doks
set order to 1
go top

seek cIdFirma+cIdTipDok+CHR(254)
skip -1

if ((field->idtipdok)<>cIdTipDok)
	cBrDok:=UBrojDok(1,gNumDio,"")
	return cBrDok
endif

cPom:=LEFT(field->brDok,gNumDio)
nPom:=VAL(cPom)+1
nDesniDio:=LEN(field->brDok)-gNumDio
cDesniDio:=RIGHT(field->brDok,nDesniDio)
cBrDok:= UBrojDok( nPom, gNumDio, cDesniDio)

return cBrDok
*}




function BrisiPripr()
*{

cSecur:=SecurR(KLevel,"BRISIGENDOK")

if (m1="X" .and. ImaSlovo("X",cSecur))   // pripr->m1
	Beep(1)
  	Msg("Dokument izgenerisan, ne smije se brisati !!",0)
  	return DE_CONT
endif

if Pitanje(,"Zelite li izbrisati pripremu !!????","N")=="D"
	select pripr
   	go top
   	do while !eof()
      		cIdFirma:=IdFirma
      		cIdTipDok:=IdTipDok
      		cBrDok:=BrDok
      		select doks
      		hseek pripr->IdFirma+pripr->IdTipDok+pripr->BrDok
      		if (Found() .and. (doks->M1=="Z"))
	 		// dokument zapisan samo u DOKS-u
	 		delete
      		endif
      		select pripr
      		skip
      		do while !eof() .and. (idfirma==cIdFirma) .and. (idtipdok==cIdTipDok) .and. (BrDok==BrDok)
			skip
      		enddo
   	enddo

   	select pripr
   	zap
endif

return
*}


/*! \fn KomIznosFakt()
 *  \brief Kompletiranje iznosa fakture pomocu usluga
 */
 
function KomIznosFakt()
*{
local nIznos:=0
local cIdRoba

O_SIFK
O_SIFV
O_S_PRIPR
O_TARIFA
O_ROBA

cIdRoba:=SPACE(LEN(id))

Box("#KOMPLETIRANJE IZNOSA FAKTURE POMOCU USLUGA",5,75)
	@ m_x+2, m_y+2 SAY "Sifra usluge:" GET cIdRoba VALID P_Roba(@cIdRoba) PICT "@!"
	@ m_x+3, m_y+2 SAY "Zeljeni iznos fakture:" GET nIznos PICT picdem
	read
	ESC_BCR
BoxC()

select roba
hseek cIdRoba
select tarifa
hseek roba->idtarifa
select pripr

nDug2:=0
nRab2:=0
nPor2:=0

KonZbira(.f.)

go bottom

Scatter()

append blank

_idroba:=cIdRoba
_kolicina:=IF(nDug2-nRab2+nPor2>nIznos,-1,1)
_rbr:=STR(RbrUnum(_Rbr)+1,3)
_cijena:=ABS(nDug2-nRab2+nPor2-nIznos)
_rabat:=0 
_porez:=0

if !(_idtipdok $ "11#15#27")
	_porez:=if( ROBA->tip=="U",tarifa->ppp,tarifa->opp)
	_cijena:=_cijena/(1+_porez/100)
endif

_txt:=Chr(16)+ROBA->naz+Chr(17)

Gather()

MsgBeep("Formirana je dodatna stavka. Vratite se tipkom <Esc> u pripremu"+"#i prekontrolisite fakturu!")

CLOSERET

return
*}



function FaStanje(cIdRj, cIdroba, nUl, nIzl, nRezerv, nRevers, lSilent)
*{

if (lSilent==nil)
	lSilent:=.f.
endif

select fakt

//"3","idroba+dtos(datDok)","FAKT"

set order to tag "3"

if (!lSilent)
	lBezMinusa:=(IzFMKIni("FAKT","NemaIzlazaBezUlaza","N",KUMPATH) == "D" )
endif

if (roba->tip=="U")
	return 0
endif

if (!lSilent)
	MsgO("Izracunavam trenutno stanje ...")
endif

seek cIdRoba

nUl:=0
nIzl:=0
nRezerv:=0
nRevers:=0

do while (!EOF() .and. cIdRoba==field->idRoba)
	if (fakt->idFirma<>cIdRj)
		SKIP
		loop
	endif
	if (LEFT(field->idTipDok,1)=="0")
		// ulaz
		nUl+=kolicina
	elseif (LEFT(field->idTipDok,1)=="1")   
		// izlaz faktura
		if !(left(field->serBr,1)=="*" .and. field->idTipDok=="10")  
			nIzl += field->kolicina
		endif
	elseif (field->idTipDok $ "20#27")
		if (LEFT(field->serBr,1)=="*")
			nRezerv += field->kolicina
		endif
	elseif (field->idTipDok=="21")
			nRevers += field->kolicina
	endif
	skip
enddo

if (!lSilent)
	MsgC()
endif

return
*}

function IsDocExists(cIdFirma, cIdTipDok, cBrDok)
*{
local nArea
local lRet

lRet:=.f.

nArea:=SELECT()
select DOKS
set order to tag "1"
HSEEK cIdFirma+cIdTipDok+cBrDok
if FOUND()
	lRet:=.t.
endif
SELECT(nArea)
return lRet

*}


function SpeedSkip()

nSeconds:=SECONDS()

nKrugova:=1
Box(,3,50)
	@ m_x+1,m_y+2 SAY "Krugova:" GET nKrugova
	read
BoxC()


O_FAKT
set order to tag "1"

i:=0
for j:=1 to nKrugova
go top

? "krug broj", j
do while !eof()
	i=i+1
	if i % 150 = 0
		? j, i, recno(), idFirma, idTipDok, brDok, "SEC:", SECONDS()-nSeconds
	endif	

	OL_Yield()
	nKey:=INKEY()
	
	if (nKey==K_ESC)
		CLOSE ALL 
		RETURN
	endif

	SKIP
enddo
next

MsgBeep("Vrijeme izvrsenja:" + STR( SECONDS()-nSeconds ) )

return
