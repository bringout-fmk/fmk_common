#include "\cl\sigma\fmk\kalk\kalk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/specif/planika/1g/db_gen1.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.6 $
 * $Log: db_gen1.prg,v $
 * Revision 1.6  2004/05/19 12:16:55  sasavranic
 * no message
 *
 * Revision 1.5  2002/07/09 13:05:41  ernad
 *
 *
 * debug planika - sitnice
 *
 * Revision 1.4  2002/07/06 17:28:58  ernad
 *
 *
 * izvjestaj Trgomarket: pregled stanja po objektima
 *
 * Revision 1.3  2002/07/06 12:29:01  ernad
 *
 *
 * kalk, planika GenRekap1, GenRekap2
 *
 * Revision 1.2  2002/07/03 23:55:19  ernad
 *
 *
 * ciscenja planika (tragao za nepostojecim bug-om u prelgedu finansijskog obrta)
 *
 * Revision 1.1  2002/07/03 18:37:49  ernad
 *
 *
 * razbijanje dugih funkcija, kategorizacija: planika.prg -> db_cre.prg, db_gen1.prg, db_gen2.prg
 *
 *
 */
 
*string tbl_roba_k2;

/*! \ingroup Planika
 *  \var tbl_roba_k2
 *  \brief Polje koje odredjuje da li ce se artikal uzeti u obzir pri sumiranju kolicina (u slucaju planike "kolicina"="pari")
 *  \param "X" - ne sumiraj
 *  \param "ostale vrijednosti" - uvrsti u suma pari
 *  \param Atributi polja C(4,0)
 */
 
 
*tbl tbl_kalk_rekap1;

/*! \var tbl_kalk_rekap1
 *  \brief Pomocna tabela formira je GenRekap1
 *
 * \code
 * Create Table "REKAP1" ( 
 *	IDROBA Char( 10 ), 
 *	OBJEKAT Char( 7 ), 
 *	G1 Char( 4 ), 
 * 	IDTARIFA Char( 6 ), 
 *	MPC Numeric( 10 ,2 ), 
 *	K1 Numeric( 14 ,5 ), 
 *	K2 Numeric( 14 ,5 ), 
 *	K4PP Numeric( 14 ,5 ), 
 *	BRISANO Char( 1 )
 * );
 *
 * Create Index "1" on REKAP1( OBJEKAT, IDROBA ); 
 * Create Index "2" on REKAP1( G1, IDTARIFA, IDROBA, OBJEKAT );
 * Create Index "BRISAN" on REKAP1( BRISANO );
 *
 * \endcode
 *
 * \sa CreTblPlanika
 */

/*! \ingroup Planika
 * \fn GenRekap1(cKartica, cVarijanta, cKesiraj, fSMark)
 * \param cKartica  - "D" - ocitaj cijene sa kartica
 * \param cVarijanta - "1" - pregled kretanja zaliha; "2" - iskazi
 * \param fSMark  .t. - selekcija robe vrsi se na osnovu polja _M1_ iz sifrarnika
 * \param aUsl1
 * \param aUsl2
 * \param aUslR
 *
 * \note prije poziva funkcije pripremiti privatne varijable aUsl1 - konto1, aUsl2 - konto2, aUslR - uslov za robu; po zavrsetku funkcije REKAP1.DBF , OBJEKTI.DBF, K1.DBF - ostaju otvoreni
 *
 *  \sa PreglKret, ObrazInv 
 */
 
function GenRekap1(aUsl1, aUsl2, aUslR, cKartica, cVarijanta, cKesiraj, fSMark, cK7, cK9, cIdKPovrata)
*{
local nSec

if (cKesiraj=nil)
  cKesiraj:="N"
endif

if (fSMark==nil)
	fSMark:=.f.
endif

if (cK7==nil)
	cK7:="N"
endif

if (cK9)==nil
	cK9:="999"
endif

if (cIdKPovrata==nil)
	cIdKPovrata:="XXXXXXXX"
endif

nSec:=SECONDS()

SELECT kalk
set order to 0

PRIVATE cFilt1:=""

cFilt1 := "DatDok<="+cm2str(dDatDo)+".and.("+aUsl1+".or."+aUsl2+")"
if aUslr<>".t."
  cFilt1+=".and."+aUslR
endif

SELECT kalk
set filter to &cFilt1

#ifndef CAX
  showkorner(rloptlevel()+100,1,66)
#endif

go top

nStavki:=0
Box(,2,70)
do while !EOF()
	if fSMark .and. SkLoNMark("ROBA", kalk->idroba)
		skip
		loop
	endif

	SELECT roba
	hseek kalk->(idroba)
	if cK7=="D" .and. EMPTY(roba->k7)
		SELECT kalk
		skip
		loop
	endif
	
	if (cK9<>"999" .and. !Empty(cK9) .and. roba->k9<>cK9)
		select kalk
		skip
		loop
	endif
	
	SELECT rekap1
	ScanMKonto(dDatOd, dDatDo, cIdKPovrata, cKartica, cVarijanta, cKesiraj)

	SELECT rekap1
	ScanPKonto(dDatOd, dDatDo, cIdKPovrata, cKartica, cVarijanta, cKesiraj)

	if ((++nStavki % 100)==0)
		@ m_x+1,m_y+2 SAY nStavki pict "99999"
	endif

	SELECT kalk
	skip
enddo

nStavki:=0

SELECT roba
go top   
do while !EOF()
	if roba->tip=="N" 
		// nova roba
		SELECT pobjekti
		go top  
		// za sve objekte
		do while !EOF()
			SELECT rekap1
			hseek pobjekti->idobj+roba->id
			if !found()
				APPEND BLANK
				replace objekat with pobjekti->idobj
				REPLACE idroba with roba->id
				REPLACE idtarifa with roba->idtarifa
				REPLACE g1 with roba->k1
				field->mpc:=roba->mpc
			endif
			SELECT pobjekti
			skip
		enddo
	endif
	@ m_x+1,m_y+2 SAY "***********************"
	@ m_x+1,col()+2 SAY ++nStavki pict "99999"
	SELECT roba
	skip
enddo 

BoxC()

nSec:=SECONDS()-nSec
if (nSec>1)  
	// nemoj "brze izvjestaje"
	@ 23,75 SAY nSec pict "9999"
endif

return
*}

function ScanMKonto(dDatOd, dDatDo, cIdKPovrata, cKartica, cVarijanta, cKesiraj)
*{
local nGGOrd
local nGGo
local nMpc
local cSeek

if EMPTY(kalk->mKonto)
	return 0
endif

hseek kalk->(mKonto+idroba) 
if !found()
	APPEND BLANK
	// radi promjene tarifa promjenio sam kalk->idtarifa u roba->idtarifa
	//replace objekat with kalk->mKonto, idroba with kalk->idroba, idtarifa with kalk->idtarifa, g1 with roba->k1
	replace objekat with kalk->mKonto, idroba with kalk->idroba, idtarifa with roba->idtarifa, g1 with roba->k1
	if (cKartica=="D")  
		// ocitaj sa kartica
		nMpc:=0
		if (cVarijanta<>"1")
			// varijanta="1" - pregled kretanja zaliha
			cSeek:=kalk->(idfirma+mKonto+idroba)
			SELECT kalk
			nGGOrd:=indexord()
			nGGo:=recno()
			SELECT koncij
			seek trim(kalk->mKonto)
			SELECT kalk
			// dan prije inventure !!!
			FaktVPC(@nmpc,cSeek,dDatDo-1)  
			dbsetorder(nGGOrd)
			go nGGo
			SELECT rekap1
			field->mpc:=nmpc
		endif
	else
		field->mpc:=roba->mpc
	endif
endif

if kalk->mu_i=="1"
	if kalk->datdok<=dDatDo  
		// stanje zalihe
		field->k2+=kalk->kolicina
	endif
	if cVarijanta<>"1"  
		// u pregledu kretanja zaliha ovo nam ne treba
		if (kalk->datdok<dDatOd) 
			// predhodno stanje
			field->k0+=kalk->kolicina
		endif
		if DInRange(kalk->datdok, dDatOd, dDatDo ) 
			// tekuci prijem
			field->k4+=kalk->kolicina
		endif
	endif
elseif kalk->mu_i=="5" 
	// izlaz iz magacina
	if cVarijanta<>"1"  
		// u pregledu kretanja zaliha ovo nam ne treba
		if (kalk->datdok<dDatOd)  
			// predhodno stanje
			field->k0-=kalk->kolicina
		endif
	endif
	if kalk->datdok<=dDatDo  
		// stanje trenutne zalihe
		field->k2-=kalk->kolicina
	endif

	if kalk->idvd $ "14#94"
		if (cVarijanta<>"1")  
			// u pregledu kretanja zaliha ovo nam ne treba
			if (kalk->datdok<=dDatDo) 
				// kumulativna prodaja
				field->k3+=kalk->kolicina
			endif
		endif
		if DInRange(kalk->datDok, dDatOd, dDatDo ) 
			// stanje trenutne prodaje
			field->k1+=kalk->kolicina
		endif
	endif

elseif (kalk->mu_i=="3") 
	// nivelacija
	if (kalk->datDok=dDatDo)  
		// dokument nivelacije na dan inventure
		if (cVarijanta<>"1")
			field->novampc:=kalk->mpcsapp+kalk->vpc
		endif
		field->mpc:=kalk->mpcsapp 
	endif
endif


return 1
*}


function ScanPKonto(dDatOd, dDatDo, cIdKPovrata, cKartica, cVarijanta, cKesiraj)
*{
local nGGOrd
local nGGo
local nMpc
local cSeek
 
if EMPTY(kalk->pkonto)     
	return 0
endif

HSEEK kalk->(pkonto+idroba)
if !FOUND()
	APPEND BLANK
	replace objekat with kalk->pkonto
	REPLACE idroba with kalk->idroba
	REPLACE idtarifa with roba->idtarifa
	REPLACE g1 with roba->k1
	if (cKartica=="D")  
		// ocitaj sa kartica
		nMpc:=0
		cSeek:=kalk->(idfirma+pkonto+idroba)
		SELECT kalk
		nGGo:=recno()
		nGGOrd:=indexord()
		SELECT koncij
		seek trim(kalk->pkonto)
		SELECT kalk
		// dan prije inventure !!!
		FaktMPC(@nmpc,cSeek,dDatDo-1)  
		dbsetorder(nGGOrd)
		go nGGo
		SELECT rekap1
		field->mpc:=nMpc
	else
		field->mpc:=roba->mpc
	endif
endif

if (kalk->pu_i=="1" .and. kalk->kolicina>0)
	
	// ulaz moze biti po osnovu prijema, 80 - preknjizenja
	// odnosno internog dokumenta

	if kalk->datdok<=dDatDo  // kumulativno stanje
		field->k2+=kalk->kolicina  // zalihe
	endif
	if (cVarijanta<>"1")
		if kalk->datdok<dDatOd  
			// predhodno stanje
			field->k0+=kalk->kolicina
		endif
		if DInRange(kalk->datdok,dDatOd,dDatDo ) 
			// tekuci prijem
			field->k4+=kalk->kolicina
		endif
	else
		if DInRange(kalk->datdok,dDatOd,dDatDo ) 
			// tekuci prijem
			if kalk->idvd=="80" .and. !EMPTY(kalk->idkonto2)
				// bilo je promjena po osnovu predispozicije
				field->k4pp+=kalk->kolicina
			endif
		endif
	endif

elseif (kalk->pu_i=="3")

	// nivelacija
	if kalk->datdok=dDatDo   
		// dokument nivelacije na dan inventure
		if cVarijanta<>"1"
			field->novampc:=kalk->(Fcj+mpcsapp)
		endif
		// stara cijena
		field->mpc:=kalk->fcj

	endif

elseif kalk->pu_i=="5" .or. (kalk->pu_i=="1" .and. kalk->kolicina<0)

	// izlaz iz prodavnice moze biti 42,41,11,12,13
	// f1 - tekuca prodaja, f2 zaliha, f3 - kumulativna prodaja
	// f4 - prijem u toku mjeseca
	// f6 - izlaz iz prodavnice po ostalim osnovama
	// f5 - reklamacije u toku mjeseca, f7 - reklamacije u toku godine

	if (cVarijanta<>"1")
		if kalk->datdok<dDatOd
			if kalk->pu_i=="5"    
				// predhodno stanje
				field->k0-=kalk->kolicina
			else
				field->k0-=abs(kalk->kolicina)
			endif
		endif
	endif

	if (kalk->datdok<=dDatDo)
		if kalk->pu_i=="5"
			// zaliha
			field->k2-=kalk->kolicina       
		else
			field->k2-=abs(kalk->kolicina)
		endif
	endif

	if (kalk->idvd $ "41#42#43") 
		//prodaja
		if DInRange(kalk->datdok,dDatOd,dDatDo ) 
			// tekuca prodaja
			field->k1+=kalk->kolicina
		endif
		if (cVarijanta<>"1")
			if kalk->datdok<=dDatDo  
				// kumulativna prodaja
				field->k3+=kalk->kolicina
			endif
		endif

	else  

		// izlazi iz prodavnice po ostalim osnovima
		
		if (cVarijanta<>"1")
			if (kalk->idvd $ "11#12#13" .and. kalk->mKonto==cIdKPovrata)  
				// reklamacija
				if DInRange(kalk->datdok,dDatOd,dDatDo ) 
					// tekuce reklamacije
					// reklamacije u mjesecu
					field->k5+=abs(kalk->kolicina) 
				endif
				if kalk->datdok<=dDatDo
					// kumulativno reklamacije
					field->k7+=abs(kalk->kolicina)   
				endif
			else
				if DInRange(kalk->datdok, dDatOd, dDatDo)
					// izlaz-otprema po ostalim osnovama
					field->k6+=abs(kalk->kolicina)  
				endif
			endif
		else
			if DInRange(kalk->datdok, dDatOd, dDatDo )
				if kalk->idvd=="80" .and. !EMPTY(kalk->idkonto2)
					// bilo je promjena po osnovu predispozicije
					field->k4pp+=kalk->kolicina
				endif
			endif
		endif
	endif
endif


return 1
*}


