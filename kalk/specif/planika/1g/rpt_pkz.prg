#include "\cl\sigma\fmk\kalk\kalk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/specif/planika/1g/rpt_pkz.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.13 $
 * $Log: rpt_pkz.prg,v $
 * Revision 1.13  2004/05/19 12:16:56  sasavranic
 * no message
 *
 * Revision 1.12  2003/12/22 10:44:52  sasavranic
 * Dodata jos 3 reda pri stampi pregleda kretanja zaliha varijanta papira A4L
 *
 * Revision 1.11  2003/12/06 13:41:38  sasavranic
 * Stampa pregleda kretanja zaliha na A4 - planika
 *
 * Revision 1.10  2003/12/04 14:47:43  sasavranic
 * Uveden filter po polju pl.vrsta na izvjestajima za planiku
 *
 * Revision 1.9  2003/11/14 08:46:12  sasavranic
 * Uslov po K9 na llp i pkz (planika)
 *
 * Revision 1.8  2003/06/23 09:32:02  sasa
 * prikaz dobavljaca
 *
 * Revision 1.7  2003/05/09 12:23:15  ernad
 * planika pregled kretanja zaliha - prog. promjena
 *
 * Revision 1.6  2002/08/19 10:04:24  ernad
 *
 *
 * podesenja CLIP
 *
 * Revision 1.5  2002/07/30 17:40:59  ernad
 * SqlLog funkcije - Fin modul
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
 * Revision 1.2  2002/07/03 18:37:49  ernad
 *
 *
 * razbijanje dugih funkcija, kategorizacija: planika.prg -> db_cre.prg, db_gen1.prg, db_gen2.prg
 *
 * Revision 1.1  2002/06/26 08:11:21  ernad
 *
 *
 * razbijanje prg-ova
 *
 *
 */
 
/*! \fn PreglKret()
 * \brief Pregled kretanja zaliha
 * \ingroup Planika
 */
 
function PreglKret()
*{
local i
private nT1:=nT4:=nT5:=nT6:=nT7:=0
private nTT1:=nTT4:=nTT5:=nTT6:=nTT7:=0
private n1:=n4:=n5:=n6:=n7:=0
private nCol1:=0
private PicCDEM:="999999.999"
private PicProc:="999999.99%"
private PicDEM:= "9999999.99"
private Pickol:= "@ 999999"

private dDatOd:=DATE()
private dDatDo:=DATE()
private qqKonto:=PADR("13;",60)
private qqRoba:=SPACE(60)
private cIdKPovrata:=SPACE(7)
private cK7:="N"
private cK9:=SPACE(3)
private cPrikazDob:="N"
private cKartica 
private cNObjekat
private cLinija

private PREDOVA2:=62
private aUTar:={}
private nUkObj:=0
private nITar:=0
private cRekPoRobama:="D"
private cRekPoDobavljacima:="D"
private cRekPoGrupamaRobe:="D"
private aUGArt:={}
private cPrSort:="SUBSTR(cIdRoba,3,3)"
private cKesiraj:="N"
private aUsl1
private aUsl2
private aUslR
private cPlVrsta:=" "
private cPapir:="A4 "

O_SIFK
O_SIFV
O_ROBA
O_K1
O_OBJEKTI

if (GetVars(@cNObjekat, @dDatOd, @dDatDo, @cIdKPovrata, @cRekPoRobama, @cRekPoDobavljacima, @cRekPoGrupamaRobe, @cK7, @cK9, @cPlVrsta, @cPapir, @cPrikazDob, @aUsl1, @aUsl2, @aUslR )==0)
	return
endif

private fSMark:=.f.
if right(trim(qqRoba),1)="*"
  fSMark:=.t.
endif

CreTblPobjekti()
CreTblRek1("1")

O_POBJEKTI
O_KONCIJ
O_ROBA
O_KONTO 
O_TARIFA
O_K1
O_OBJEKTI
O_KALK
O_REKAP1
GenRekap1(aUsl1, aUsl2, aUslR, cKartica, "1", cKesiraj, fSMark, cK7, cK9, cIdKPovrata)

altd()

SetLinija(@cLinija, @nUkObj)

select rekap1
SET ORDER TO TAG "2"
go top

gaZagFix:={}
gaKolFix:={}
SetGaZag(cRekPoRobama, cRekPoDobavljacima, cRekPoGrupamaRobe, @gaZagFix, @gaKolFix)

START PRINT CRET

if ((cPapir=="A3L") .or. (cPapir=="A4L") .or. gPrinter=="R")
	PREDOVA2=46
	?? "#%LANDS#"
endif

nStr:=0

if (cRekPoRobama=="D")
	ZagPKret()
endif

nCol1:=43

// inicijalizuj pomocna polja
FillPObjekti()

select rekap1
nRbr:=0

fFilovo:=.f.
do while !eof()

	cG1:=g1
	select pobjekti    
	// inicijalizuj polja
	go top
	do while !eof()
		// prodaja grupa
		replace prodg with 0   
		REPLACE zalg  with 0
		skip
	enddo
	select rekap1

	fFilGr:=.f.

	do while !eof() .and. cG1==field->g1

		select pobjekti   
		go top
		do while !eof()
			// prodaja tarifa,grupa
			replace prodt with 0  
			REPLACE zalt  with 0
			skip
		enddo
		select rekap1
		cIdTarifa:=idtarifa
		fFilovo:=.f.

		do while !eof() .and. cG1==g1 .and. rekap1->idTarifa==cIdTarifa

			cIdroba:=rekap1->idroba
			SELECT roba
			HSEEK cIdRoba
			
			if !EMPTY(cPlVrsta) .and. field->vrsta <> cPlVrsta
				select rekap1
				skip
				loop
			endif
			
			//nadji mpc u nekoj prodavnici
			nMpc:=NadjiPMpc()

			nK2:=nK1:=0
			
			SetK1K2(cG1, cIdTarifa, cIdRoba, @nK1, @nK2)
			
			if (ROUND(nK2,3)==0 .and. ROUND(nK1,2)==0)
				// stanje nula, skoci na sljedecu robu !!!!!
				select rekap1
				seek cG1+cIdTarifa+cIdroba+CHR(254)
				loop
			endif

			fFilovo:=.t.
			fFilGr:=.t.
			aStrRoba:=SjeciStr(trim(roba->naz)+" (MPC:"+alltrim(str(nmpc,7,2))+")",27)

			if (prow()> PREDOVA2+gPStranica-3)
				FF
				ZagPKret()
			endif
			
			++nRBr
			if (cRekPoRobama=="D")
				? str(nRBr,4)+"."+cidroba
				nColR:=pcol()+1
				@ prow(),ncolR  SAY aStrRoba[1]
				nCol1:=pcol()
			endif

			if (ROBA->k2<>"X")
				aPom:={"A",&cPrSort}
				for i:=1 to nUkObj+2
					AADD(aPom,{0,0})
				next
				nITar:=ASCAN( aUGArt , {|x| x[2]==aPom[2]} )
				if nITar==0
					AADD(aUGArt,aPom)
					nITar:=LEN(aUGArt)
				endif
			endif

			// prvi red zalihe
			nK2:=0
			// izracunajmo prvo ukupno (kolona "SVI")
			select pobjekti    
			go top
			do while (!eof() .and. pobjekti->id<"99")
				 select rekap1
				 HSEEK cG1+cIdTarifa+cIdRoba+pobjekti->idobj
				 nK2+=field->k2
				 select pobjekti
				 skip
			enddo

			if cRekPoRobama=="D"
				// ispis kolone "SVI"
				@ prow(),pcol()+1 SAY nk2 pict pickol
				// kolona "Ucesce" se preskace
				@ prow(),pcol()+1 SAY SPACE(6)  
			endif
			if ROBA->k2<>"X"
				aUGArt[nITar,3,1]+=nk2
			endif
			// ispisi kolone za pojedine objekte
			select pobjekti    
			go top
			i:=0
			
			do while (!eof() .and. id<"99")
				 SELECT rekap1
				 HSEEK cG1+cIdTarifa+cIdRoba+pobjekti->idobj
				 if cRekPoRobama=="D"
					   if k4pp<>0
						@ prow(),pcol()+1 SAY STRTRAN(TRANS(k2,pickol)," ","*")
					   else
						@ prow(),pcol()+1 SAY k2 pict pickol
					   endif
				 endif
				 ++i
				 if ROBA->k2<>"X"
					aUGArt[nITar,4+i,1]+=k2
				 endif
				 select pobjekti
				 if roba->k2<>"X"   
					//samo u finansijski zbir
					replace zalt  with zalt+rekap1->k2,;
						zalu  with zalu+rekap1->k2 ,;
						zalg  with zalg+rekap1->k2
				 endif
				 skip
			enddo

			// ovo je objekat 99
			if roba->k2<>"X"   
				// roba sa oznakom k2=X
				replace zalt   with zalt+nk2 ,;
					zalu   with zalu+nk2 ,;
					zalg   with zalg+nk2
			endif

			// drugi red  prodaja  u mjesecu  k1
			select pobjekti    
			nK1:=0
			if cRekPoRobama=="D"
				?
				if len(aStrRoba)>1
					@ prow(),nColR SAY aStrRoba[2]
				endif
					@ prow(),nCol1 SAY ""
			endif

			// ispisi kolone za pojedine objekte
			go top
			do while (!EOF() .and. pobjekti->id<"99")
				 select rekap1
				 HSEEK cG1+cIdTarifa+cIdRoba+pobjekti->idobj
				 nK1+=field->k1
				 select pobjekti
				 skip
			enddo

			if cRekPoRobama=="D"
				@ prow(),pcol()+1 SAY nk1 pict pickol
				if !(nk2+nk1==0)
					@ prow(),pcol()+1 SAY nk1/(nk2+nk1)*100 pict "999.99%"
				else
					@ prow(),pcol()+1 SAY "???.??%"
				endif
			endif

			if ROBA->k2<>"X"
				aUGArt[nITar,3,2]+=nK1
			endif

			select pobjekti
			go top
			lIzaProc:=.t.
			i:=0
			do while (!eof() .and. pobjekti->id<"99")
				select rekap1
				hseek cG1+cIdTarifa+cIdRoba+pobjekti->idobj
				if cRekPoRobama=="D"
					   if k4pp<>0
						@ prow(),pcol()+1-IF(lIzaProc,1,0) SAY STRTRAN(TRANS(k1,IF(lIzaProc,"999999",pickol))," ","*")
					   else
						@ prow(),pcol()+1-IF(lIzaProc,1,0) SAY k1 pict IF(lIzaProc,"999999",pickol)
					   endif
				endif
				++i
				
				select pobjekti
				if roba->k2<>"X"
					aUGArt[nITar,4+i,2]+=rekap1->k1
					replace prodt  with  prodt+rekap1->k1,;
						produ  with  produ+rekap1->k1,;
						prodg  with  prodg+rekap1->k1
				endif
				skip
				lIzaProc:=.f.
			enddo

			// skipuje na polje "99"
			if roba->k2<>"X" 
				REPLACE prodt with prodt+nk1 
				REPLACE	produ with produ+nk1 
				REPLACE	prodg with prodg+nk1
			endif
			
			if (cPrikazDob=="D")
				? PrikaziDobavljaca(cIdRoba, 6)
			endif
			
			if cRekPoRobama=="D"
				? cLinija
			endif

			select rekap1
			seek cG1+cIdTarifa+cIdroba+CHR(255) 

		enddo

		if !fFilovo 
			loop
		endif

		// pocetak Ukupno tarifa ****************************
		if cRekPoRobama=="D"
			if (prow()> PREDOVA2+gPStranica-3)
				FF
				ZagPKret()
			endif
		
			//?  cLinija
			//? "Ukupno tarifa", cIdTarifa
		endif

		aPom:={"T",cIdTarifa}
		for i:=1 to nUkObj+2
			AADD(aPom,{0,0})
		next
		AADD(aUTar,aPom)
		nITar:=LEN(aUTar)

		select pobjekti
		// idi na "objekat" 99 (SVI)
		go bottom 
		if cRekPoRobama=="D"
			// @ prow(),nCol1+1 SAY field->zalt PICT pickol
		endif
		aUTar[nITar,3,1]:=zalt
		if cRekPoRobama=="D"
			// kolona "Ucesce" se preskace
			// @ prow(),pcol()+1 SAY SPACE(6)             
		endif
		select pobjekti
		go top
		i:=0
		do while (!eof() .and. field->id<"99")
			if cRekPoRobama=="D"
				//@ prow(),pcol()+1 SAY field->zalt pict pickol
			endif
			++i
			aUTar[nITar,4+i,1]:=zalt
			skip
		enddo
		
		select pobjekti
		// idi na "objekat" 99 (SVI)
		go bottom 
		if cRekPoRobama=="D"
			// @ prow()+1,nCol1+1 SAY field->prodt pict pickol
		endif
		aUTar[nITar,3,2]:=field->prodt
		if !(field->prodt+field->zalt==0)
			aUTar[nITar,4,2]:=field->prodt/(field->prodt+field->zalt)*100
			if (cRekPoRobama=="D")
				// @ prow(),pcol()+1 SAY field->prodt/(field->prodt+field->zalt)*100 pict "999.99%"
			endif
		else
			if (cRekPoRobama=="D")
				// @ prow(),pcol()+1 SAY "???.??%"
			endif
		endif
		select pobjekti
		go top
		lIzaProc:=.t.
		i:=0
		do while (!EOF() .and. field->id<"99")
			if (cRekPoRobama=="D")
				// @ prow(),pcol()+1-IF(lIzaProc,1,0) SAY field->prodt pict IF(lIzaProc,"999999",pickol)
			endif
			++i
			aUTar[nITar,4+i,2]:=field->prodt
			skip
			lIzaProc:=.f.
		enddo
		if cRekPoRobama=="D"
			//?  cLinija
		endif
		// kraj ukupno tarifa *********************************
		
		select rekap1

	enddo

	if !fFilGr
		loop
	endif

	if (cRekPoRobama=="D")
			
		if (prow()> PREDOVA2+gPStranica-2)
			FF
			ZagPKret()
		endif

		? strtran(cLinija, "-", "=")
	endif

	select k1
	hseek cg1
	select rekap1

	if (cRekPoRobama=="D")
		? "Ukupno grupa",cG1,"-",k1->naz
	endif

	aPom:={"G",cG1+" - "+k1->naz}
	for i:=1 to nUkObj+2
		AADD(aPom,{0,0})
	next
	AADD(aUTar,aPom)
	nITar:=LEN(aUTar)

	select pobjekti
	// idi na "objekat" 99 (SVI)
	go bottom 
	if cRekPoRobama=="D"
		@ prow(),nCol1+1 SAY zalg PICT pickol
		// kolona "Ucesce" se preskace
		@ prow(),pcol()+1 SAY SPACE(6)             
	endif
	aUTar[nITar,3,1]:=zalg
	select pobjekti 
	go top
	i:=0
	do while (!eof() .and. pobjekti->id<"99")
		if cRekPoRobama=="D"
			@ prow(),pcol()+1 SAY zalg pict pickol
		endif
		++i
		aUTar[nITar,4+i,1]:=zalg
		skip
	enddo
	select pobjekti
	go bottom // idi na "objekat" 99 (SVI)
	if cRekPoRobama=="D"
		@ prow()+1,nCol1+1 SAY prodg pict pickol
	endif
	aUTar[nITar,3,2]:=prodg
	if !(prodg+zalg==0)
		aUTar[nITar,4,2]:=prodg/(prodg+zalg)*100
		if cRekPoRobama=="D"
			@ prow(),pcol()+1 SAY prodg/(prodg+zalg)*100 pict "999.99%"
		endif
		else
		if cRekPoRobama=="D"
			@ prow(),pcol()+1 SAY "???.??%"
		endif
	endif

	select pobjekti
	go top
	lIzaProc:=.t.
	i:=0
	do while (!eof() .and. id<"99")
		if cRekPoRobama=="D"
			@ prow(),pcol()+1-IF(lIzaProc,1,0) SAY prodg pict IF(lIzaProc,"999999",pickol)
		endif
		++i
		aUTar[nITar,4+i,2]:=prodg
		skip
		lIzaProc:=.f.
	enddo

	select rekap1
	if cRekPoRobama=="D"
		 strtran(cLinija,"-","=")
	endif

enddo                        

		
if (cRekPoRobama=="D")
	if (prow()> PREDOVA2+gPStranica-3)
		FF
		ZagPKret()
	endif
	//donja funkcija ne vrsi ispis zaglavlja
	RekPoRobama(cLinija, nCol1) 

endif


if (cRekPoDobavljacima=="D")
	RekPoDob(cRekPoRobama, cLinija, nCol1, nUkObj, @aUTar) 
endif

if (cRekPoGrupamaRobe=="D")
	RekPoGrup(cRekPoGrupama, cRekPoDobavljacima, @aUGArt) 
endif

FF
end print
#ifdef CAX
close all
#endif

closeret

return
*}


static function NadjiPMpc()
*{
local nMpc
local nTRec
select rekap1

nMpc:=field->mpc
// ako sam na objektu koji je u stvari magacin nMpc=0
// imao sam problem da je gornja cijena izvucena iz magacina
// zato cu provrtiti dok ne nadjem prodavnicku cijenu
if (nMpc==0)
	nTRec:=recno()
	do while !eof() .and. field->idRoba=cIdRoba
		if mpc<>0
			nMpc:=mpc
			exit
		endif
		skip
	enddo
	go nTRec 
endif

return nMpc
*}

function SetK1K2(cG1, cIdTarifa, cIdRoba, nK1, nK2)
*{		
nK2:=0
nK1:=0
select pobjekti
go top
do while (!EOF()  .and. field->id<"99")
	select rekap1
	hseek  cG1+cIdtarifa+cIdroba+pobjekti->idobj
	nK2+=field->k2
	nK1+=field->k1
	select pobjekti
	skip
enddo

return
*}


/*! \fn Izmj_cPrSort()
 *  \brief Formula za kljucni dio sifre pri grupisanju roba
 *  \ingroup Planika
 */
 
static function Izmj_cPrSort()
*{
local GetList:={}
 Box(,3,75)
  cPrSort:=PADR(cPrSort,80)
  @ m_x+2, m_y+2 SAY "Formula za kljucni dio sifre pri grupisanju roba:" GET cPrSort PICT "@S20"
  READ
  cPrSort:=ALLTRIM(cPrSort)
 BoxC()
return
*}

static function PaperFormatHelp()
*{
cPoruka:="Formati papira - legenda:"
cPoruka+="##A3  - A3 format papira"
cPoruka+="##A3L - A3 landscape papir"
cPoruka+="##A4  - A4 format papira"
cPoruka+="##A4L - A4 landscape papir"
MsgBeep(cPoruka)
return
*}


/*! \ingroup Planika
 *  \fn ZagPKret(cVarijanta)
 *  \brief Zaglavlje izvjestaja pregled kretanja
 *  \param cVarijanta - "1" - Pregl. kret zalika, "2" - rekapitulacija po grupama dobavljaca, "3" - rekapitulacija po grupama artikala
 *
 */
 
static function ZagPKret(cVarijanta)
*{
if cPapir=="A4L" .or. cPapir=="A3L"
	P_COND2	
endif
if cVarijanta==nil
	cVarijanta:="1"
endif
if !cPapir$"A4L#A3L"
	?? gTS+":",gNFirma,space(40),"Strana:"+str(++nStr,3)
	?
	?  "PREGLED KRETANJA ZALIHA za period:",dDatOd,"-",dDAtDo
	?
else
	?? gTS+":",gNFirma,"  PREGLED KRETANJA ZALIHA za period:",dDatOd,"-",dDAtDo
endif
if qqRoba=nil
	qqRoba:=""
endif
? "Kriterij za Objekat:",trim(qqKonto), "Robu:",TRIM(qqRoba)
if !cPapir$"A4L#A3L"
	?
endif
if cVarijanta=="2"
  ?
  ?
  ?
  ?
  ? REPL("*",71)
  ? PADC("REKAPITULACIJA PO K1-DOBAVLJACIMA",71)
  ? REPL("*",71)
  ?
elseif cVarijanta=="3"
  
?
?
?
?

? REPL("*",71)
? PADC("REKAPITULACIJA PO GRUPAMA ARTIKALA",71)
? REPL("*",71)
?
endif

if (cPapir=="A4L" .or. cPapir=="A3L")
	P_COND2  
else
	P_COND
endif

? "---- --------------------------------------"
select pobjekti
go top
do while !eof()
	?? " ------"
	skip
enddo
?? " ------"

? " R.     SIFRA     NAZIV  ARTIKLA            "
select objekti
go bottom
?? padc(objekti->naz,7)
?? padc("Ucesce",7)
go top
do while (!EOF() .and. objekti->id<"99")
	?? padc(objekti->naz,7)
	skip
enddo

? " br.                                       "
?? padc("za/pr",7)
?? SPACE(7)
select pobjekti
go top
do while (!EOF() .and. field->id<"99")
	?? padc("za/pr",7)
	skip
enddo

? "---- --------------------------------------"
select pobjekti
go top
do while !eof()
	?? " ------" 
	skip
enddo

?? " ------"

return nil
*}

static function GetVars(cNObjekat, dDatOd, dDatDo, cIdKPovrata, cRekPoRobama, cRekPoDobavljacima, cRekPoGrupamaRobe, cK7, cK9, cPlVrsta, cPapir, cPrikazDob,  aUsl1, aUsl2, aUslR )
*{

O_PARAMS
private cSection:="F",cHistory:=" ",aHistory:={}
Params1()
RPar("c1",@cidKPovrata)
RPar("c2",@qqKonto)
RPar("c3",@cPrSort)
RPar("d1",@dDatOd)
RPar("d2",@dDatDo)
RPar("cR",@qqRoba)
RPar("cP",@cPrikazDob)
RPar("Ke",@cKesiraj)
RPar("fP",@cPapir)
 
cKartica:="N" 
cNObjekat:=space(20)

Box(,18,70)
 set cursor on
 SET KEY K_F2 to Izmj_cPrSort()
 SET KEY K_F1 to PaperFormatHelp()
 @ m_x+15,m_y+15 SAY "<F2> - promjena formule za rekapit.po grup.robe"
 do while .t.
  @ m_x+1,m_y+2 SAY "Konta prodavnice:" GET qqKonto pict "@!S50"
  @ m_x+3,m_y+2 SAY "tekuci promet je period:" GET dDatOd
  @ m_x+3,col()+2 SAY "do" GET dDatDo
  @ m_x+4,m_y+2 SAY "Kriterij za robu :" GET qqRoba pict "@!S50"
  @ m_x+6,m_y+2 SAY "Magacin u koji se vrsi povrat rekl. robe:" GET cIdKPovrata pict "@!"
  @ m_x+ 9,m_Y+2 SAY "Pregled po robama?              (D/N)" GET cRekPoRobama pict "@!" valid cRekPoRobama $ "DN"
  @ m_x+10,m_Y+2 SAY "Rekapitulacija po dobavljacima? (D/N)" GET cRekPoDobavljacima pict "@!" valid cRekPoDobavljacima $ "DN"
  @ m_x+11,m_Y+2 SAY "Rekapitulacija po grupama robe? (D/N)" GET cRekPoGrupamaRobe pict "@!" valid cRekPoGrupamaRobe $ "DN"
  @ m_x+12,m_Y+2 SAY "Prikaz za k7='*'              ? (D/N)" GET cK7 pict "@!" valid cK7 $ "DN"
  @ m_x+13,m_Y+2 SAY "Prikaz dobavljaca ? (D/N)" GET cPrikazDob pict "@!" valid cPrikazDob $ "DN"
  @ m_x+16,m_Y+2 SAY "Uslov po K9 " GET cK9
  @ m_x+17,m_Y+2 SAY "Uslov po pl.vrsta " GET cPlVrsta PICT "@!"
  @ m_x+18,m_Y+2 SAY "Format papira " GET cPapir VALID !Empty(cPapir)
  ?? " <F1> Formati papira - legenda"
  READ
  if (LASTKEY()==K_ESC)
  	BoxC()
	return 0
  endif
  aUsl1:=Parsiraj(qqKonto,"PKonto")
  aUsl2:=Parsiraj(qqKonto,"MKonto")
  aUslR:=Parsiraj(qqRoba,"IdRoba")
  if aUsl1<>nil .and. aUslR<>nil
  	exit
  endif
 enddo
 SET KEY K_F2 TO
 SET KEY K_F1 TO
BoxC()

select roba
use


select params
if Params2()
	WPar("c1",cidKPovrata)
	WPar("c2",qqKonto)
	WPar("c3",cPrSort)
	WPar("d1",dDatOd); WPar("d2",dDatDo)
	WPar("cR",@qqRoba)
	WPar("Ke",@cKesiraj)
	WPar("fP",@cPapir)
endif
select params
use

return 1
*}


function SetLinija(cLinija, nUkObj)
*{
cLinija:="---- --------- ----------------------------"
select pobjekti    
// inicijalizuj cLinija
go top
do while !eof() .and. field->id<"99"
	nUkObj++
	cLinija+=" ------"
	skip
enddo
cLinija+=" ------" 
cLinija+=" ------"  

return
*}

function SetGaZag(cRekPoRobama, cRekPoDobavljacima, cRekPoGrupamaRobe, gaZagFix, gaKolFix)
*{

if cRekPoRobama=="D"
	// 7.red fajla, 4 reda ukupno (7.,8.,9. i 10.) (ovi redovi su zaglavlje ovog izvjestaja i fiksno se prikazuju na ekranu)
	gaZagFix:={ 7, 4}    
	// 6.kolona, 38 kolona ukupno, od 7.reda ispisuj
	gaKolFix:={ 1, 58, 7 }   

elseif cRekPoDobavljacima=="D"
	gaZagFix:={15, 4}
	gaKolFix:={ 1, 58, 15 }
elseif cRekPoGrupamaRobe=="D"
	gaZagFix:={15, 4}
	gaKolFix:={ 1, 58, 15 }
endif

return
*}

function RekPoRobama(cLinija, nCol1)
*{

? cLinija

? "UKUPNO:"
select pobjekti
// idi na "objekat" 99 (SVI)
go bottom 
@ prow(),nCol1+1 SAY zalu PICT pickol
// kolona "Ucesce" se preskace
@ prow(),pcol()+1 SAY SPACE(6)
select pobjekti
go top
do while (!EOF() .and. id<"99")
	@ prow(),pcol()+1 SAY zalu pict pickol
	skip
enddo

select pobjekti
// idi na "objekat" 99 (SVI)
go bottom 
@ prow()+1,nCol1+1 SAY produ pict pickol
if !(produ+zalu==0)
	@ prow(),pcol()+1 SAY produ/(produ+zalu)*100 pict "999.99%"
else
	@ prow(),pcol()+1 SAY "???.??%"
endif

select pobjekti
go top
lIzaProc:=.t.
do while !eof()  .and. id<"99"
	@ prow(),pcol()+1-IF(lIzaProc,1,0) SAY produ pict IF(lIzaProc,"999999",pickol)
	skip
	lIzaProc:=.f.
enddo
select rekap1
? cLinija

return
*}


function RekPoDob(cRekPoRobama, cLinija, nCol1, nUkObj, aUTar) 
*{

 aPom:={"U",""}
  for i:=1 to nUkObj+2
    AADD(aPom,{0,0})
  next
  AADD(aUTar,aPom)
  nITar:=LEN(aUTar)
  FF
  ZagPKret("2")
  
  cLinija2:=STRTRAN(cLinija,"-","=")
  for i:=1 to LEN(aUTar)
    	
	if (prow()> PREDOVA2+gPStranica-3)
		FF
		ZagPKret("2")
	endif

	if aUTar[i,1]=="T"                   
	      // tarife
	      ? cLinija
	      ? "Ukupno tarifa",aUTar[i,2]
	    elseif aUTar[i,1]=="G"               
	      // dobavljaci
	      ? cLinija2
	      ? "Ukupno grupa",aUTar[i,2]
	    else
	      ? cLinija2
	      ? "UKUPNO:"
	endif
	@ prow(),nCol1+1 SAY aUTar[i,3,1] PICT pickol
	
	// kolona "Ucesce" se preskace
	@ prow(),pcol()+1 SAY SPACE(6)             
	for j:=1 to nUkObj
	     @ prow(),pcol()+1 SAY aUTar[i,4+j,1] pict pickol
	next
	@ prow()+1,nCol1+1 SAY aUTar[i,3,2] pict pickol
	if !(aUTar[i,3,1]+aUTar[i,3,2]==0)
		@ prow(),pcol()+1 SAY aUTar[i,3,2]/(aUTar[i,3,2]+aUTar[i,3,1])*100 pict "999.99%"
	else
		@ prow(),pcol()+1 SAY "???.??%"
	endif
	lIzaProc:=.t.
	for j:=1 to nUkObj
	     @ prow(),pcol()+1-IF(lIzaProc,1,0) SAY aUTar[i,4+j,2] pict IF(lIzaProc,"999999",pickol)
	     lIzaProc:=.f.
	next
	
	if aUTar[i,1]=="T"
	      ? cLinija
	    else
	      ? cLinija2
	 endif
	 
	 if i<nITar .and. aUTar[i,1]=="G"
	      aUTar[nITar,3,1]+=aUTar[i,3,1]
	      aUTar[nITar,3,2]+=aUTar[i,3,2]
	      for j:=1 to nUkObj
		aUTar[nITar,4+j,1]+=aUTar[i,4+j,1]
		aUTar[nITar,4+j,2]+=aUTar[i,4+j,2]
	      next
	 endif
  next

return
*}

function RekPoGrup(cRekPoGrupama, cRekPoDobavljacima, aUGArt) 
*{

ASORT( aUGArt , , , { |x,y|  x[2] < y[2] } )
aPom:={"U",""}
for i:=1 to nUkObj+2
	AADD(aPom,{0,0})
next
AADD(aUGArt,aPom)
nITar:=LEN(aUGArt)

FF
ZagPKret("3")
cLinija2:=STRTRAN(cLinija,"-","=")

for i:=1 to LEN(aUGArt)
  	
	if (prow()> PREDOVA2+gPStranica-3)
		FF
		ZagPKret("3")
	endif

	  
	if aUGArt[i,1]=="A"   
	      ? cLinija
	      ? "Grupa",aUGArt[i,2]
	else
	      ? cLinija2
	      ? "UKUPNO:"
	endif
	
	@ prow(),nCol1+1 SAY aUGArt[i,3,1] PICT pickol
	    // kolona "Ucesce" se preskace
	    @ prow(),pcol()+1 SAY SPACE(6)             
	    for j:=1 to nUkObj
	     @ prow(),pcol()+1 SAY aUGArt[i,4+j,1] pict pickol
	    next
	    @ prow()+1,nCol1+1 SAY aUGArt[i,3,2] pict pickol
	    if !(aUGArt[i,3,1]+aUGArt[i,3,2]==0)
	      @ prow(),pcol()+1 SAY aUGArt[i,3,2]/(aUGArt[i,3,2]+aUGArt[i,3,1])*100 pict "999.99%"
	    else
	      @ prow(),pcol()+1 SAY "???.??%"
	    endif
	    lIzaProc:=.t.
	    for j:=1 to nUkObj
	     @ prow(),pcol()+1-IF(lIzaProc,1,0) SAY aUGArt[i,4+j,2] pict IF(lIzaProc,"999999",pickol)
	     lIzaProc:=.f.
	    next
	    if aUGArt[i,1]=="A"
	      ? cLinija
	    else
	      ? cLinija2
	    endif
	    if i<nITar .and. aUGArt[i,1]=="A"
	      aUGArt[nITar,3,1]+=aUGArt[i,3,1]
	      aUGArt[nITar,3,2]+=aUGArt[i,3,2]
	      for j:=1 to nUkObj
		aUGArt[nITar,4+j,1]+=aUGArt[i,4+j,1]
		aUGArt[nITar,4+j,2]+=aUGArt[i,4+j,2]
	      next
	endif
next

return
*}
