#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/prod/rpt/1g/rpt_llp.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.20 $
 * $Log: rpt_llp.prg,v $
 * Revision 1.20  2004/05/25 14:24:04  sasavranic
 * Mogucnost evidentiranja tipa sredstva (donirano i kupljeno)
 *
 * Revision 1.19  2004/05/19 12:16:55  sasavranic
 * no message
 *
 * Revision 1.18  2004/05/07 14:38:59  sasavranic
 * no message
 *
 * Revision 1.17  2004/05/05 08:16:52  sasavranic
 * Na izvj.LLP dodao uslov za partnera
 *
 * Revision 1.16  2003/12/03 15:39:25  sasavranic
 * Na LLP i LLM uslov po polju pl.vrsta
 *
 * Revision 1.15  2003/11/14 08:45:59  sasavranic
 * Uslov po K9 na llp i pkz (planika)
 *
 * Revision 1.14  2003/10/06 15:00:28  sasavranic
 * Unos podataka putem barkoda
 *
 * Revision 1.13  2003/06/23 09:31:20  sasa
 * prikaz dobavljaca
 *
 * Revision 1.12  2003/05/09 12:23:15  ernad
 * planika pregled kretanja zaliha - prog. promjena
 *
 * Revision 1.11  2003/04/30 13:14:03  sasa
 * Ispravljena greska u uslovu if cSRedCij:
 *
 *    if (lPoNarudzbi .and. cSRedCij...)
 *
 * bilo:
 *
 *   if cSRedCij.....
 *
 * Revision 1.10  2003/03/12 09:24:34  mirsad
 * Tvin: srednja cijena
 *
 * Revision 1.9  2003/01/10 14:14:56  ernad
 *
 *
 * bug - prenos poc stanja za region 2 - prodavnice RS
 *
 * Revision 1.8  2003/01/09 16:29:15  mirsad
 * ispravka bug-a u planici (gen.p.st.prod.)
 *
 * Revision 1.7  2002/08/05 13:33:11  mirsad
 * 1.w.0.9.26, ispravljen bug u generaciji poc.st.prodavnice
 *
 * Revision 1.6  2002/08/05 11:03:58  ernad
 *
 *
 * Fin/SQLLog funkcije, debug bug RJ/KUMPATH
 *
 * Revision 1.5  2002/07/03 23:55:19  ernad
 *
 *
 * ciscenja planika (tragao za nepostojecim bug-om u prelgedu finansijskog obrta)
 *
 * Revision 1.4  2002/06/25 15:08:47  ernad
 *
 *
 * prikaz parovno - Planika
 *
 * Revision 1.3  2002/06/25 12:04:07  ernad
 *
 *
 * ubaceno kreiranje SECUR-a (posto je prebacen u kumpath)
 *
 * Revision 1.2  2002/06/21 12:12:43  mirsad
 * dokumentovanje
 *
 *
 */
 
*string
static cTblKontrola:=""
*;

*array
static aPorezi:={}
*;


/*! \file fmk/kalk/prod/rpt/1g/rpt_llp.prg
 *  \brief Izvjestaj "lager lista prodavnice"
 */


/*! \fn LLP()
 *  \brief Izvjestaj "lager lista prodavnice"
 */

function LLP()
*{
parameters fPocStanje
// indikator gresaka
local fImaGresaka:=.f.  
local cKontrolnaTabela

cIdFirma:=gFirma
cIdKonto:=PadR("1320",gDuzKonto)
O_SIFK
O_SIFV
O_ROBA
O_KONTO
O_PARTN

cKontrolnaTabela:="N"

if (fPocStanje==nil)
	fPocStanje:=.f.
else
   	fPocStanje:=.t.
   	O_PRIPR
   	cBrPSt:="00001   "
   	Box(,2,60)
     		@ m_x+1,m_y+2 SAY "Generacija poc. stanja  - broj dokumenta 80 -" GET cBrPSt
     		read
   	BoxC()
endif

cNula:="D"
cK9:=SPACE(3)
dDatOd:=CToD("")
dDatDo:=Date()
qqRoba:=SPACE(60)
qqTarifa:=SPACE(60)
qqidvd:=SPACE(60)
qqIdPartn:=SPACE(60)
private cPNab:="N"
private cNula:="D"
private cTU:="N"
private cSredCij:="N"
private cPrikazDob:="N"
private cPlVrsta:=SPACE(1)

if IsDomZdr()
	private cKalkTip:=SPACE(1)
endif

Box(,17+IF(lPoNarudzbi,2,0)+IF(IsTvin(),1,0),68)

cGrupacija:=space(4)
cPredhStanje:="N"

do while .t.
	if gNW $ "DX"
   		@ m_x+1,m_y+2 SAY "Firma "
		?? gFirma,"-",gNFirma
 	else
  		@ m_x+1,m_y+2 SAY "Firma  " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 	endif
 	@ m_x+2,m_y+2 SAY "Konto   " GET cIdKonto valid P_Konto(@cIdKonto)
 	@ m_x+3,m_y+2 SAY "Artikli " GET qqRoba pict "@!S50"
 	@ m_x+4,m_y+2 SAY "Tarife  " GET qqTarifa pict "@!S50"
 	@ m_x+5,m_y+2 SAY "Partneri" GET qqIdPartn pict "@!S50"
 	@ m_x+6,m_y+2 SAY "Vrste dokumenata  " GET qqIDVD pict "@!S30"
 	@ m_x+7,m_y+2 SAY "Prikaz Nab.vrijednosti D/N" GET cPNab  valid cpnab $ "DN" pict "@!"
 	@ m_x+8,m_y+2 SAY "Prikaz stavki kojima je MPV 0 D/N" GET cNula  valid cNula $ "DN" pict "@!"
 	@ m_x+9,m_y+2 SAY "Datum od " GET dDatOd
 	@ m_x+9,col()+2 SAY "do" GET dDatDo
 	@ m_x+12,m_y+2 SAY "Prikaz robe tipa T/U  (D/N)" GET cTU valid cTU $ "DN" pict "@!"
 	@ m_x+12, COL()+2 SAY " generisati kontrolnu tabelu ? " GET cKontrolnaTabela VALID cKontrolnaTabela $ "DN" PICT "@!"
 	@ m_x+13,m_y+2 SAY "Odabir grupacije (prazno-svi) GET" GET cGrupacija pict "@!"
 	@ m_x+14,m_y+2 SAY "Prikaz prethodnog stanja" GET cPredhStanje pict "@!" valid cPredhStanje $ "DN"
 	if lPoNarudzbi
   		qqIdNar := SPACE(60)
   		cPKN    := "N"
   		@ row()+1,m_y+2 SAY "Uslov po sifri narucioca:" GET qqIdNar pict "@!S30"
   		@ row()+1,m_y+2 SAY "Prikazati kolonu 'narucilac' ? (D/N)" GET cPKN VALID cPKN$"DN" pict "@!"
 	endif
 	if IsTvin()
 		@ row()+1, m_y+2 SAY "Prikazati srednju cijenu (D/N) ?" GET cSredCij VALID cSredCij$"DN" PICT "@!"
 	endif
 
	if IsPlanika()
 		@ m_x+15,m_y+2 SAY "Prikaz dobavljaca (D/N) ?" GET cPrikazDob pict "@!" valid cPrikazDob $ "DN"
		@ m_x+16,m_y+2 SAY "Prikaz po K9 (uslov)" GET cK9 pict "@!"
		@ m_x+17,m_y+2 SAY "Prikaz po pl.vrsta (uslov)" GET cPlVrsta pict "@!"
 	endif
	
	if IsDomZdr()	
 		@ m_x+15,m_y+2 SAY "Prikaz po tipu sredstva " GET cKalkTip PICT "@!"
	endif
  
	read
 	ESC_BCR
 	private aUsl1:=Parsiraj(qqRoba,"IdRoba")
 	private aUsl2:=Parsiraj(qqTarifa,"IdTarifa")
 	private aUsl3:=Parsiraj(qqIDVD,"idvd")
	private aUsl4:=Parsiraj(qqIdPartn, "IdPartner")
 	if lPoNarudzbi
  		aUslN:=Parsiraj(qqIdNar,"idnar")
 	endif
 	if aUsl1<>NIL .and. aUsl2<>NIL .and. aUsl3<>NIL .and.(!lPoNarudzbi.or.aUslN<>NIL)
   		exit
 	endif
	if aUsl4<>NIL
		exit
	endif
enddo
BoxC()

CLOSE ALL

if (cKontrolnaTabela=="D")
	CreTblKontrola()
endif

if fPocStanje
	O_PRIPR
endif

O_SIFK
O_SIFV
O_ROBA
O_KONTO
O_PARTN
O_KONCIJ
O_KALKREP

private fSMark:=.f.
if right(trim(qqRoba),1)="*"
	fSMark:=.t.
endif

private cFilter:=".t."

if aUsl1<>".t."
  	cFilter+=".and."+aUsl1   // roba
endif
if aUsl2<>".t."
  	cFilter+=".and."+aUsl2   // tarifa
endif
if aUsl3<>".t."
  	cFilter+=".and."+aUsl3   // idvd
endif
if aUsl4<>".t."
	cFilter+=".and."+aUsl4   // partner
endif
if lPoNarudzbi .and. aUslN<>".t."
  	cFilter+=".and."+aUslN
endif
// po tipu sredstva
if IsDomZdr() .and. !Empty(cKalkTip)
	cFilter+=".and. tip="+Cm2Str(cKalkTip)
endif

select KALK

if lPoNarudzbi .and. cPKN=="D"
  	set order to tag "4N"
else
  	set order to 4
endif

set filter to &cFilter
//"4","idFirma+Pkonto+idroba+dtos(datdok)+PU_I+IdVD","KALKS")
hseek cIdfirma+cIdkonto
EOF CRET

nLen:=1
m:="----- ---------- -------------------- ---"+IF(lPoNarudzbi.and.cPKN=="D"," ------","")+" ---------- ---------- ---------- ---------- ---------- ---------- ----------"
if cPredhstanje=="D"
  	m+=" ----------"
endif
if cSredCij=="D"
	m+=" ----------"
endif

start print cret
select konto
hseek cidkonto
select KALK

private nTStrana:=0

private bZagl:={|| ZaglLLP()}

nTUlaz:=0
nTIzlaz:=0
nTPKol:=0
nTMPVU:=0
nTMPVI:=0
nTNVU:=0
nTNVI:=0
// predhodna vrijednost
nTPMPV:=0
nTPNV:=0  
nTRabat:=0
nCol1:=50
nCol0:=50
nRbr:=0

Eval(bZagl)
do while !eof() .and. cIdFirma+cIdKonto==idfirma+pkonto .and. IspitajPrekid()
	cIdRoba:=Idroba
	if lPoNarudzbi .and. cPKN=="D"
  		cIdNar:=idnar
	endif
	if fSMark .and. SkLoNMark("ROBA",cIdroba)
   		skip
   		loop
	endif
	select roba
	hseek cIdRoba
	
	// uslov po K9
	if (IsPlanika() .and. !EMPTY(cK9) .and. roba->k9 <> cK9)
		select kalk
		skip
		loop
	endif

	// uslov po PL.VRSTA
	if (IsPlanika() .and. !EMPTY(cPlVrsta) .and. roba->vrsta <> cPlVrsta) 
		select kalk
		skip
		loop
	endif

	select KALK
	nPKol:=0
	nPNV:=0
	nPMPV:=0
	nUlaz:=0
	nIzlaz:=0
	nMPVU:=0
	nMPVI:=0
	nNVU:=0
	nNVI:=0
	nRabat:=0
	if cTU=="N" .and. roba->tip $ "TU"
		skip
		loop
	endif

	do while !eof() .and. cidfirma+cidkonto+IF(lPoNarudzbi.and.cPKN=="D",cIdNar,"")+cidroba==idFirma+pkonto+IF(lPoNarudzbi.and.cPKN=="D",IdNar,"")+idroba .and. IspitajPrekid()
		if fSMark .and. SkLoNMark("ROBA",cIdroba)
     			skip
     			loop
  		endif
  		if cPredhStanje=="D"
    			if datdok<dDatOd
     				if pu_i=="1"
       					SumirajKolicinu(kolicina, 0, @nPKol, 0, fPocStanje)
       					nPMPV+=mpcsapp*kolicina
       					nPNV+=nc*(kolicina)
     				elseif pu_i=="5"
       					SumirajKolicinu(-kolicina, 0, @nPKol, 0, fPocStanje)
       					nPMPV-=mpcsapp*kolicina
       					nPNV-=nc*kolicina
     				elseif pu_i=="3"    
       					// nivelacija
       					nPMPV+=field->mpcsapp*field->kolicina
     				elseif pu_i=="I"
       					SumirajKolicinu(-gKolicin2, 0, @nPKol, 0, fPocStanje)
       					nPMPV-=mpcsapp*gkolicin2
       					nPNV-=nc*gkolicin2
     				endif
    			endif
  		else
    			if field->datdok<ddatod .or. field->datdok>ddatdo
      				skip
      				loop
    			endif
  		endif // cpredhstanje

  		if cTU=="N" .and. roba->tip $ "TU"
  			skip
			loop
  		endif
  		if !empty(cGrupacija)
    			if cGrupacija<>roba->k1
      				skip
      				loop
    			endif
  		endif
  		if DatDok>=dDatOd  // nisu predhodni podaci
  			if pu_i=="1"
    				SumirajKolicinu(kolicina, 0, @nUlaz, 0, fPocStanje)
    				nCol1:=pcol()+1
    				nMPVU+=mpcsapp*kolicina
    				nNVU+=nc*(kolicina)
  			elseif pu_i=="5"
    				if idvd $ "12#13"
     					SumirajKolicinu(-kolicina, 0, @nUlaz, 0, fPocStanje)
     					nMPVU-=mpcsapp*kolicina
     					nNVU-=nc*kolicina
    				else
     					SumirajKolicinu(0, kolicina, 0, @nIzlaz, fPocStanje)
     					nMPVI+=mpcsapp*kolicina
     					nNVI+=nc*kolicina
    				endif

  			elseif pu_i=="3"    // nivelacija
    				nMPVU+=mpcsapp*kolicina
  			elseif pu_i=="I"
    				SumirajKolicinu(0, gkolicin2, 0, @nIzlaz, fPocStanje)
    				nMPVI+=mpcsapp*gkolicin2
    				nNVI+=nc*gkolicin2
			endif
  		endif
		skip
	enddo
	//ne prikazuj stavke 0
	if cNula=="D" .or. round(nMPVU-nMPVI+nPMPV,4)<>0 
		if PROW()>61+gPStranica
			FF
			eval(bZagl)
		endif
		select roba
		hseek cidroba
		select KALK
		aNaz:=Sjecistr(roba->naz,20)
		? str(++nRbr,4)+".",cIdRoba
		nCr:=pcol()+1
		@ prow(),pcol()+1 SAY aNaz[1]
		@ prow(),pcol()+1 SAY roba->jmj
		if lPoNarudzbi .and. cPKN=="D"
  			@ prow(),pcol()+1 SAY cIdNar
		endif
		nCol0:=pCol()+1
		if cPredhStanje=="D"
 			@ prow(),pcol()+1 SAY nPKol pict gpickol
		endif
		@ prow(),pcol()+1 SAY nUlaz pict gpickol
		@ prow(),pcol()+1 SAY nIzlaz pict gpickol
		@ prow(),pcol()+1 SAY nUlaz-nIzlaz+nPkol pict gpickol
		if fPocStanje
  			select pripr
  			if round(nUlaz-nIzlaz,4)<>0
     				append blank
     				replace idFirma with cIdfirma, idroba with cIdRoba, idkonto with cIdKonto, datdok with dDatDo+1, idTarifa with Tarifa(cIdKonto, cIdRoba, @aPorezi), datfaktp with dDatDo+1, kolicina with nulaz-nizlaz, idvd with "80", brdok with cBRPST, nc with (nNVU-nNVI+nPNV)/(nulaz-nizlaz+nPKol), mpcsapp with (nMPVU-nMPVI+nPMPV)/(nulaz-nizlaz+nPKol), TMarza2 with "A"
				if koncij->NAZ=="N1"
             				replace vpc with nc
     				endif
			endif
  			select KALK
		endif

		nCol1:=pcol()+1
		@ prow(),pcol()+1 SAY nMPVU pict gPicDem
		@ prow(),pcol()+1 SAY nMPVI pict gPicDem
		@ prow(),pcol()+1 SAY nMPVU-NMPVI+nPMPV pict gPicDem
		select koncij
		seek trim(cIdKonto)
		select roba
		hseek cidroba
		_mpc:=UzmiMPCSif()
		select KALK
		if round(nUlaz-nIzlaz+nPKOL,4)<>0
 			@ prow(),pcol()+1 SAY (nMPVU-nMPVI+nPMPV)/(nUlaz-nIzlaz+nPKol) pict gpiccdem
 			if round((nMPVU-nMPVI+nPMPV)/(nUlaz-nIzlaz+nPKol),4) <> round(_mpc,4)
   				?? " ERR"
   				//fImaGresaka:=.t. ovo necemo uzeti u obzir prilikom generacije pst.
 			endif
		else
 			@ prow(),pcol()+1 SAY 0 pict gpicdem
 			if round((nMPVU-nMPVI+nPMPV),4)<>0
   				?? " ERR"
   				fImaGresaka:=.t.
 			endif
		endif

		if cSredCij=="D"
			@ prow(), pcol()+1 SAY (nNVU-nNVI+nPNV+nMPVU-nMPVI+nPMPV)/(nUlaz-nIzlaz+nPKol)/2 PICT "9999999.99"
		endif

		if LEN(aNaz)>1 .or. cPredhStanje=="D" .or. cPNab=="D"
  			@ prow()+1,0 SAY ""
  			if len(aNaz)>1
    				@ prow(),nCR  SAY aNaz[2]
  			endif
  			@ prow(),nCol0-1 SAY ""
		endif
		if (cKontrolnaTabela=="D")
			AzurKontrolnaTabela(cIdRoba, nUlaz-nIzlaz+nPkol, nMpvU-nMpvI+nPMpv)
		endif

		if cPredhStanje=="D"
 			@ prow(),pcol()+1 SAY nPMPV pict gpicdem
		endif
		if cPNab=="D"
 			@ prow(),pcol()+1 SAY space(len(gpickol))
 			@ prow(),pcol()+1 SAY space(len(gpickol))
 			if round(nulaz-nizlaz+nPKol,4)<>0
  				@ prow(),pcol()+1 SAY (nNVU-nNVI+nPNV)/(nUlaz-nIzlaz+nPKol) pict gpicdem
 			else
  				@ prow(),pcol()+1 SAY space(len(gpicdem))
 			endif
 			@ prow(),nCol1 SAY nNVU pict gpicdem
 			//@ prow(),pcol()+1 SAY space(len(gpicdem))
 			@ prow(),pcol()+1 SAY nNVI pict gpicdem
 			@ prow(),pcol()+1 SAY nNVU-nNVI+nPNV pict gpicdem
 			@ prow(),pcol()+1 SAY _MPC pict gpiccdem
		endif
		nTULaz+=nUlaz
		nTIzlaz+=nIzlaz
		nTPKol+=nPKol
		nTMPVU+=nMPVU
		nTMPVI+=nMPVI
		nTNVU+=nNVU
		nTNVI+=nNVI
		nTRabat+=nRabat
		nTPMPV+=nPMPV
		nTPNV+=nPNV
	endif //cNula

	if (IsPlanika() .and. cPrikazDob=="D")
		? PrikaziDobavljaca(cIdRoba, 6) 
	endif

	if lKoristitiBK
		? SPACE(6) + roba->barkod
	endif
enddo

? m
? "UKUPNO:"
@ prow(),nCol0-1 SAY ""
if cPredhStanje=="D"
	@ prow(),pcol()+1 SAY nTPMPV pict gpickol
endif
@ prow(),pcol()+1 SAY nTUlaz pict gpickol
@ prow(),pcol()+1 SAY nTIzlaz pict gpickol
@ prow(),pcol()+1 SAY nTUlaz-nTIzlaz+nTPKol pict gpickol
nCol1:=pcol()+1
@ prow(),pcol()+1 SAY nTMPVU pict gpicdem
@ prow(),pcol()+1 SAY nTMPVI pict gpicdem
@ prow(),pcol()+1 SAY nTMPVU-nTMPVI+nTPMPV pict gpicdem

if cPNab=="D"
	@ prow()+1,nCol0-1 SAY ""
	if cPredhStanje=="D"
 		@ prow(),pcol()+1 SAY nTPNV pict gpickol
	endif
	@ prow(),pcol()+1 SAY space(len(gpicdem))
	@ prow(),pcol()+1 SAY space(len(gpicdem))
	@ prow(),pcol()+1 SAY space(len(gpicdem))
	@ prow(),pcol()+1 SAY nTNVU pict gpicdem
	@ prow(),pcol()+1 SAY nTNVI pict gpicdem
	@ prow(),pcol()+1 SAY nTNVU-nTNVI+nTPNV pict gpicdem
endif

? m

FF
END PRINT

if fImaGresaka
	MsgBeep("Pogledajte artikle za koje je u izvjestaju stavljena oznaka ERR - GRESKA")
endif

if fPocStanje
	if fimagresaka .and. Pitanje(,"Nulirati pripremu (radi ponavljanja procedure) ?","D")=="D"
   		select pripr
   		zap
 	else
   		RenumPripr(cBrPSt,"80")
 	endif
endif

#ifdef CAX
	if gKalks
		select kalk
 		use
 	endif
#endif
closeret
return
*}





/*! \fn ZaglLLP(fsint)
 *  \brief Zaglavlje izvjestaja "lager lista prodavnice"
 *  \param fsint -
 */

function ZaglLLP(fsint)
*{
if fsint==NIL
	fSint:=.f.
endif

Preduzece()
P_COND
?? "KALK: LAGER LISTA  PRODAVNICA ZA PERIOD",dDatOd,"-",dDatDo," NA DAN "
?? date(), space(12),"Str:",str(++nTStrana,3)

if lPoNarudzbi .and. !EMPTY(qqIdNar)
	?
  	? "Obuhvaceni sljedeci narucioci:",TRIM(qqIdNar)
  	?
endif
if !EMPTY(qqIdPartn)
	? "Obugvaceni sljedeci partneri:", TRIM(qqIdPartn)
endif
if fsint
	? "Kriterij za prodavnice:",qqKonto
else
 	select konto
	hseek cidkonto
 	? "Prodavnica:", cIdKonto, "-", konto->naz
endif

if IsDomZdr() .and. !Empty(cKalkTip)
	PrikTipSredstva(cKalkTip)
endif

if (lPoNarudzbi .and. cSredCij=="D")
	cSC1:="*Sred.cij.*"
	cSC2:="*         *"
else
	cSC1:=""
	cSC2:=""
endif

select kalk
? m
if cPredhStanje=="D"
	? " R.  * Artikal  *   Naziv            *jmj*"+IF(lPoNarudzbi.and.cPKN=="D","Naru- *","")+" Predh.st *  ulaz       izlaz   * STANJE   *  MPV.Dug.* MPV.Pot *   MPV    *  MPCSAPP *"+cSC1
  	? " br. *          *                    *   *"+IF(lPoNarudzbi.and.cPKN=="D","cilac *","")+" Kol/MPV  *                     *          *          *         *          *          *"+cSC2
  	if cPNab=="D"
  		? "     *          *                    *   *"+IF(lPoNarudzbi.and.cPKN=="D","      *","")+"          *                     * SR.NAB.C *   NV.Dug.*  NV.Pot *    NV    *          *"+cSC2
  	endif
else
	? " R.  * Artikal  *   Naziv            *jmj*"+IF(lPoNarudzbi.and.cPKN=="D","Naru- *","")+"  ulaz       izlaz   * STANJE   *  MPV.Dug.* MPV.Pot *   MPV    *  MPCSAPP *"+cSC1
  	? " br. *          *                    *   *"+IF(lPoNarudzbi.and.cPKN=="D","cilac *","")+"                     *          *          *         *          *          *"+cSC2
  	if cPNab=="D"
  		? "     *          *                    *   *"+IF(lPoNarudzbi.and.cPKN=="D","      *","")+"                     * SR.NAB.C *   NV.Dug.*  NV.Pot *    NV    *          *"+cSC2
  	endif
endif

if cPredhStanje=="D"
	? "     *    1     *        2           * 3 *"+IF(lPoNarudzbi.and.cPKN=="D","      *","")+"     4    *     5    *     6    *  5 - 6   *     7    *     8   *   7 - 8  *     9    *"+cSC2
  	? m
else
	? "     *    1     *        2           * 3 *"+IF(lPoNarudzbi.and.cPKN=="D","      *","")+"     4    *     5    *  4 - 5   *     6    *     7   *   6 - 7  *     8    *"+cSC2
  	? m
endif

return
*}


static function CreTblKontrola()
*{
local aDbf
local cCdx

altd()

aDbf:={}
cTblKontrola:=ToUnix("c:/sigma/kontrola.dbf")
cCdx:=ToUnix("c:/sigma/kontrola")
AADD(aDbf, { "ID", "C", 10, 0})
AADD(aDbf, { "kolicina", "N", 12, 2})
AADD(aDbf, { "Mpv", "N", 10, 2})
DBCREATE2( cTblKontrola , aDbf)
CREATE_INDEX("id","id", cCdx) 

return
*}


static function AzurKontrolnaTabela(cIdRoba, nStanje, nMpv)
*{
local nArea

nArea:=SELECT()

SELECT (F_KONTROLA)

if !USED()
	USE (cTblKontrola)
endif

SELECT kontrola
APPEND BLANK
REPLACE id WITH cIdRoba
REPLACE kolicina WITH nStanje
REPLACE Mpv WITH nMpv

SELECT(nArea)
return
*}

