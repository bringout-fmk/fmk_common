#include "\cl\sigma\fmk\kalk\kalk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/specif/planika/1g/db_gen2.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.6 $
 * $Log: db_gen2.prg,v $
 * Revision 1.6  2004/05/19 12:16:55  sasavranic
 * no message
 *
 * Revision 1.5  2003/12/04 14:47:42  sasavranic
 * Uveden filter po polju pl.vrsta na izvjestajima za planiku
 *
 * Revision 1.4  2003/01/31 13:07:40  ernad
 * planika - data width error
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


*tbl tbl_kalk_rekap2;

/*! \var tbl_kalk_rekap2
 *  \ingroup Planika
 *  \brief Pomocna tabela, formira je GenRekap2
 *
 *  \code
 * Create Table "REKAP2" ( 
 * 	OBJEKAT Char( 7 ), 
 *	G1 Char( 4 ), 
 *	IDTARIFA Char( 6 ), 
 *	MJESEC Numeric( 2 ,0 ), 
 *	GODINA Numeric( 4 ,0 ), 
 *	ZALIHAK Numeric( 16 ,2 ), 
 *	ZALIHAF Numeric( 16 ,2 ), 
 *	NABAVK Numeric( 16 ,2 ), 
 *	NABAVF Numeric( 16 ,2 ), 
 *	PNABAVK Numeric( 16 ,2 ), 
 *	PNABAVF Numeric( 16 ,2 ), 
 *	STANJEK Numeric( 16 ,2 ), 
 *	STANJEF Numeric( 16 ,2 ), 
 *	STANJRK Numeric( 16 ,2 ), 
 *	STANJRF Numeric( 16 ,2 ), 
 *	PRODAJAK Numeric( 16 ,2 ), 
 *	PRODAJAF Numeric( 16 ,2 ), 
 *	PROSZALK Numeric( 16 ,2 ), 
 *	PROSZALF Numeric( 16 ,2 ), 
 *	ORUCF Numeric( 16 ,2 ), 
 *	OMPRUCF Numeric( 16 ,2 ), 
 *	POVECANJE Numeric( 16 ,2 ), 
 *	SNIZENJE Numeric( 16 ,2 ), 
 *	BRISANO Char( 1 )
 *);
 *
 * Create Index "1" on REKAP2( GODINA, MJESEC, OBJEKAT );
 * Create Index "2" on REKAP2( GODINA, MJESEC, G1, OBJEKAT );
 * Create Index "3" on REKAP2( G1, GODINA, MJESEC );
 * Create Index "BRISAN" on REKAP2( BRISANO );
 *
 * \sa CreTblPla2 
 *
 * \endcode
 *
 */

*tbl tbl_kalk_reka22;

/*! \var tbl_kalk_reka22
 *  \ingroup Planika
 *  \brief Pomocna tabela, formira je GenRekap2
 *
 *  \code
 * Create Table "REKA22" ( 
 * 	G1 Char( 4 ), 
 *	IDTARIFA Char( 6 ), 
 *	ZALIHAK Numeric( 16 ,2 ), 
 *	ZALIHAF Numeric( 16 ,2 ), 
 *	NABAVK Numeric( 16 ,2 ), 
 *	NABAVF Numeric( 16 ,2 ), 
 *	PNABAVK Numeric( 16 ,2 ), 
 *	PNABAVF Numeric( 16 ,2 ), 
 *	STANJEK Numeric( 16 ,2 ), 
 *	STANJEF Numeric( 16 ,2 ), 
 *	STANJRF Numeric( 16 ,2 ), 
 *	STANJRK Numeric( 16 ,2 ), 
 *	PRODAJAK Numeric( 16 ,2 ), 
 *	PRODAJAF Numeric( 16 ,2 ), 
 *	PROSZALK Numeric( 16 ,2 ), 
 *	PROSZALF Numeric( 16 ,2 ), 
 *	PRODKUMK Numeric( 16 ,2 ), 
 *	PRODKUMF Numeric( 16 ,2 ), 
 *	ORUCF Numeric( 16 ,2 ), 
 *	OMPRUCF Numeric( 16 ,2 ), 
 *	POVECANJE Numeric( 16 ,2 ), 
 *	SNIZENJE Numeric( 16 ,2 ), 
 *	KOBRDAN Numeric( 16 ,9 ), 
 *	GKOBR Numeric( 16 ,9 ), 
 *	BRISANO Char( 1 )
 * );
 *
 * Create Index "1" on REKA22( G1 );
 * Create Index "BRISAN" on REKA22( BRISANO );
 *
 * \endcode
 *
 * \sa CreTblPla2 
 */




/*! \fn GenRekap2(lK2X, cC, lMarkiranaRoba)
 *
 * \param lK2X : .f. - ne gledaj K2='X' za zbrajanje kolicine; .t. - uzmi u obzir K2='X' za zbrajanje kolicine (roba kod koje je ROBA->K2="X" nece ulaziti u zbir)
 * 
 * \param lMarkiranaRoba  .t. - selekcija robe vrsi se na osnovu polja _M1_ iz sifrarnika
 * \ingroup Planika
 * \result formira se Tabela REKAP2.DBF
 *
 * \note proslijediti aUsl1 - konto1, aUsl2 - konto2, aUslR - uslov za robu; REKAP2.DBF , OBJEKTI.DBF, K1.DBF - ostaju otvoreni
 *
 * \sa ObrtPoMjF
 *
 */

function GenRekap2(lK2X, cC, lMarkiranaRoba)
*{
local lMagacin
local lProdavnica

if (lK2X==nil)
   lK2X:=.f.
endif
if (cC==nil)
	cC:="P"
endif

if (lMarkiranaRoba==nil)
	lMarkiranaRoba:=.f.
endif

SELECT kalk

PRIVATE cFilt3:=""

cFilt3 := "("+aUsl1+".or."+aUsl2+") .and.DATDOK<="+cm2str(dDatDo)

if aUslR<>".t."
	cFilt3+=".and."+aUslR
endif

set filter to &cFilt3

GO TOP

nStavki:=0
Box(,2,70)
do while !EOF()
	if lMarkiranaRoba .and. SkLoNMark("ROBA", kalk->idroba)
		skip
		loop
	endif
	SELECT roba
	HSEEK kalk->idRoba
	
	if IsPlanika() .and. !EMPTY(cPlVrsta) .and. roba->vrsta <> cPlVrsta
		select kalk
		skip
		loop
	endif
	
	if IsPlanika() .and. !EMPTY(cK9) .and. roba->k9 <> cK9
		select kalk
		skip
		loop
	endif	
	
	lMagacin:=.t.
	SELECT rekap2

	Sca2MKonto(dDatOd, dDatDo, aUsl1, aUsl2, cIdKPovrata, cC, lK2X, @lMagacin)
	Sca2PKonto(dDatOd, dDatDo, aUsl1, aUsl2, cIdKPovrata, cC, lK2X, @lProdavnica)

	@ m_x+1,m_y+2 SAY ++nStavki pict "99999"

	SELECT kalk
	skip
enddo

GRekap22()

BoxC()

return
*}

function Sca2MKonto(dDatOd, dDatDo, aUsl1, aUsl2, cIdKPovrata, cC, lK2X, lMagacin)
*{
local nPomKolicina
local nTC

if !EMPTY(kalk->mKonto) .and. (KALK->(&aUsl2) .or. kalk->mKonto==cIdKPovrata)
	cGodina:=STR(YEAR(kalk->datDok),4)
	cMjesec:=STR(MONTH(kalk->datDok),2)
	HSEEK cGodina+cMjesec+roba->k1+kalk->mKonto
	if !found()
		APPEND BLANK
		REPLACE objekat with kalk->mKonto
		REPLACE godina with VAL(cGodina)
		REPLACE mjesec with VAL(cMjesec)
		REPLACE g1 with roba->k1
	endif
else
	lMagacin:=.f.
endif

if cC=="P"
	nTC:=KALK->vpc
else
	nTC:=KALK->nc
endif

// biljezi magacin - radi zaliha
if !lMagacin

elseif (kalk->mu_i=="1" .or. (kalk->mu_i=="5" .and. kalk->idvd=="97"))
	
	// mu_i=="5" jeste izlaz iz magacina, ali ga ovdje treba prikazivati
	// kao storno ulaza
	if (kalk->mu_i=="5" .and. kalk->idvd=="97")
		nPomKolicina:= -1 * kalk->kolicina
	else
		nPomKolicina:= kalk->kolicina
	endif
	if (!lK2X .or. !(LEFT(roba->k2,1)=='X'))
		field->stanjek += nPomKolicina
	endif
	field->stanjef += nPomKolicina*nTC
	
	if (kalk->datDok<=dDatOd)
		
		if !lK2X .or. !(LEFT(roba->K2,1)=='X')
			field->zalihak += nPomKolicina
		endif
		field->zalihaf += nPomKolicina*nTC
		if (kalk->mKonto==cIdKPovrata)
			if (!lK2X .or. !(LEFT(roba->k2,1)=='X'))
				field->stanjrk += nPomKolicina
			endif
			field->stanjrf += nPomKolicina*nTC
		endif
	else
		if (kalk->mKonto==cIdKPovrata)
			// magacin rekl. robe
			if (!lK2X .or. !(LEFT(roba->k2,1)=='X'))
				field->stanjrk += nPomKolicina
			endif
			field->stanjrf += nPomKolicina*nTC
		elseif (kalk->idvd=="10")
			if (!lK2X .or. !(LEFT(roba->K2,1)=='X'))
				field->nabavk += nPomKolicina
			endif
			field->nabavf += nPomKolicina*nTC
		endif
	endif

elseif (kalk->mu_i=="5") 
	
	// izlaz iz magacina
	if (!lK2X .or. !(LEFT(roba->k2,1)=='X'))
		field->stanjek-=kalk->kolicina
	endif
	field->stanjef-=kalk->kolicina*nTC
	if kalk->datdok<=dDatOd
		if (!lK2X .or. !(LEFT(roba->k2,1)=='X'))
			field->zalihak-=kalk->kolicina
		endif
		field->zalihaf-=kalk->kolicina*nTC
		if (kalk->mKonto==cIdKPovrata)
			if !lK2X .or. !(LEFT(roba->k2,1)=='X')
				field->stanjrk-=kalk->kolicina
			endif
			field->stanjrf-=kalk->kolicina*nTC
		endif
	else
		if (kalk->mKonto==cIdKPovrata)
			if (!lK2X .or. !(LEFT(roba->k2,1)=='X'))
				field->stanjrk-=kalk->kolicina
			endif
			field->stanjrf-=kalk->kolicina*nTC
		elseif kalk->idvd=="14"
			// izlaz velepr.
			if (!lK2X .or. !(roba->K2='X'))
				field->prodajak+=kalk->kolicina
			endif
			if (cC=="P")
				field->prodajaf+=kalk->(kolicina*nTC*(1-RabatV/100))
				field->orucf+=kalk->(kolicina*(nTC*(1-RabatV/100)-nc))
			else
				field->prodajaf+=kalk->(kolicina*nTC)
			endif
		endif
	endif

elseif (kalk->mu_i=="3" .and. cC=="P")
	// nivelacija - samo za prod.cijenu
	if kalk->datdok<=dDatOd
		field->zalihaf+=kalk->kolicina*nTC
	endif

	if (nTC>0)
		field->povecanje+=kalk->(kolicina*nTC)
	else
		// apsolutno
		field->snizenje+=abs(kalk->(kolicina*nTC)) 
	endif

	if (kalk->mKonto==cIdKPovrata)
		field->stanjrf+=kalk->kolicina*nTC
	else
		field->stanjef+=kalk->kolicina*nTC
	endif

endif 

return
*}

function Sca2PKonto(dDatOd, dDatDo, aUsl1, aUsl2, cIdKPovrata, cC, lK2X, lMagacin)
*{
local nTC

lProdavnica:=.t.
SELECT rekap2

if !EMPTY(kalk->pkonto) .and. kalk->(&aUsl1)
	cGodina:=STR(YEAR(kalk->datDOK),4)
	cMjesec:=STR(MONTH(kalk->datDOK),2)
	HSEEK cGodina+cMjesec+roba->k1+kalk->pkonto
	if !found()
		APPEND BLANK
		replace objekat with kalk->pkonto,;
		godina with val(cGodina),;
		mjesec with val(cMjesec),;
		g1 with roba->k1
	endif
else
	lProdavnica:=.f.
endif

if cC=="P"
	nTC:=KALK->mpc
else
	nTC:=KALK->nc
endif

if !lProdavnica

elseif (kalk->pu_i=="1")
	
	// ulaz moze biti po osnovu prijema, 80 - preknjizenja
	// odnosno internog dokumenta

	if !lK2X .or. !(roba->K2='X')
		field->stanjek+=kalk->kolicina
	endif
	field->stanjef+=kalk->(kolicina*nTC)

	if kalk->datdok<=dDatOd
		if !lK2X .or. !(roba->K2='X')
			field->zalihak+=kalk->kolicina
		endif
		field->zalihaf+=kalk->(kolicina*nTC)
	else
		if kalk->idvd $ "11#12#13#81"
			if !lK2X .or. !(roba->K2='X')
			field->pnabavk += KALK->kolicina
			endif
			field->pnabavf += KALK->kolicina*nTC
		endif
		field->omprucf+=kalk->(kolicina*(nTC-nc))
	endif


elseif kalk->Pu_i=="3" .and. cC=="P" 
	
	// nivelacija - samo za prod.cijenu
	
	field->stanjef+=kalk->(kolicina*nTC)

	if kalk->datdok<=dDatOd
		field->zalihaf+=kalk->(kolicina*nTC)
	endif

	if KALK->mpcsapp>0
		field->povecanje+=kalk->(kolicina*nTC)
	else
		field->snizenje+=abs(kalk->(kolicina*nTC)) // apsolutno
	endif


elseif kalk->pu_i=="5"
	
	// izlaz iz prodavnice moze biti 42,41,11,12,13

	if !lK2X .or. !(roba->K2='X')
		field->stanjek-=kalk->kolicina
	endif
	field->stanjef-=kalk->kolicina*nTC

	if kalk->datdok<=dDatOd
		if !lK2X .or. !(roba->K2='X')
			field->zalihak-=kalk->kolicina
		endif
		field->zalihaf-=kalk->(kolicina*nTC)

	else   
		// 02.01 - 31.12
		if kalk->idvd $ "41#42#43" // maloprodaja
			if !lK2X .or. !(roba->K2='X')
				field->prodajak+=kalk->kolicina
			endif
			field->prodajaf+=kalk->(kolicina*nTC)
			field->orucf+=kalk->(kolicina*(nTC-nc))
		endif
	endif


endif 


return
*}


static function GRekap22()
*{

// REKAP2 je gotova, formirati REKA22

nStavki:=0
SELECT rekap2
//g1+str(godina)+str(mjesec)
set order to TAG "3"

GO TOP
do while !EOF()
	
	cG1:=g1
	nZalihaF:=0
	nZalihaK:=0
	nNabavF:=0
	nNabavK:=0
	nPNabavF:=0
	nPNabavK:=0
	nProdajaF:=0
	nProdajaK:=0

	// matrica zaliha
	aZalihe:={}  
	nProdKumF:=0 
	nProdKumK:=0
	nPovecanje:=0
	nSnizenje:=0
	nStanjRF:=0
	nStanjRK:=0
	nORucF:=0
	nOMPRucF:=0
	nStanjeF:=0
	nStanjeK:=0
	
	SELECT rekap2

	do while (!EOF() .and. rekap2->g1==cG1)
		
		SELECT rekap2
		nMjesec:=rekap2->mjesec
		nGodina:=rekap2->godina
		
		do while ((!EOF() .and. rekap2->g1==cG1  .and. nMjesec==rekap2->mjesec .and. nGodina==rekap2->godina))
			
			if (YEAR(dDatOd)==Godina .and. MONTH(dDatOd)==mjesec)
				// samo je 01.98 mjesec poc zalihe
				nZalihaf+=zalihaf
				nZalihak+=zalihak
			endif
			
			nNabavF+=nabavf
			nNabavK+=nabavk
			nPNabavF+=pnabavf
			nPNabavK+=pnabavk
			nProdajaF+=prodajaf 
			nProdajaK+=prodajak
			nProdKumF+=ProdajaF
			nProdKumK+=Prodajak
			nStanjeF+=StanjeF
			nStanjeK+=StanjeK
			nStanjRF+=StanjRF
			nStanjRK+=StanjRK
			nPovecanje+=povecanje
			nSnizenje+=snizenje
			nORucF+=orucf
			nOMPRucF+=omprucf
			
			SELECT rekap2
			SKIP
			
		enddo

		if (YEAR(dDatOd)==rekap2->godina .and. MONTH(dDatOd)==rekap2->mjesec)
			if (round(nZalihaF,4)<>0 .and. IzFmkIni("Planika","ProsZalihaBezPocZalihe","D",KUMPATH)=="N")
				AADD(AZalihe,{nZalihaF,nZalihaK})  // poc zaliha
			endif
		endif
		if ROUND(nStanjef,4)<>0
			AADD(AZalihe,{nStanjeF,nStanjeK})
		endif
		
		// 01.01 - 30.09
		// znaci imamo 10 uzoraka: 01.01, 31.01, 31.02, ..., 30.09

	enddo
	
	SELECT reka22
	APPEND BLANK
	nProszalf:=0
	nProszalk:=0
	nKObrDan:=0
	nGKObr:=0

	if LEN(aZalihe)<>0
		for i:=1 to LEN(aZalihe)
			nProsZalf+=aZalihe[i,1]
			nProsZalk+=aZalihe[i,2]
		next
		nProsZalF:=nProsZalf/LEN(aZalihe)
		nProsZalk:=nProsZalk/LEN(aZalihe)
		if nProsZalF<>0
			nKobrDan := nProdKumf/nProsZalf
			nGKObr   := nKObrDan*12/LEN(aZalihe)
		endif
	endif

	REPLACE  g1 with cG1
	REPLACE zalihaf   with nZalihaF
	REPLACE nabavF   with nNabavF
	REPLACE pnabavF   with nPNabavF
	REPLACE prodajaF  with nProdajaF
	REPLACE stanjeF  with nStanjeF
	REPLACE stanjrF   with nStanjRF
	REPLACE orucf    with nORucf
	REPLACE omprucf   with nOMPRucf
	REPLACE proszalF  with nProsZalF
	REPLACE prodKumF with nProdKumF
	REPLACE povecanje with nPovecanje
	REPLACE snizenje with nSnizenje
	REPLACE KObrDan   with nKObrDan
	if (ABS(nGKObr) > 99999)
		MsgBeep("G. Koef obracuna za "+cG1+" "+STR(nGKOBr)+" ???")
		REPLACE GKObr  with 0
	else
		REPLACE GKObr    with nGKObr
	endif
	REPLACE zalihak   with nZalihak
	REPLACE nabavk   with nNabavk
	REPLACE pnabavk   with nPNabavk
	REPLACE prodajak  with nProdajak
	REPLACE stanjek  with nStanjek
	REPLACE stanjrk   with nStanjRk
	REPLACE prodKumk with nProdKumk
	REPLACE proszalk  with nProsZalK

	SELECT rekap2
enddo


return
*}
