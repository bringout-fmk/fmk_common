#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/mag/rpt/1g/rpt_llm.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.15 $
 * $Log: rpt_llm.prg,v $
 * Revision 1.15  2004/05/25 13:53:17  sasavranic
 * Mogucnost evidentiranja tipa sredstva (donirano i kupljeno)
 *
 * Revision 1.14  2004/05/19 12:16:55  sasavranic
 * no message
 *
 * Revision 1.13  2004/05/05 08:16:52  sasavranic
 * Na izvj.LLP dodao uslov za partnera
 *
 * Revision 1.12  2004/02/12 15:37:29  sasavranic
 * no message
 *
 * Revision 1.11  2003/12/03 15:39:25  sasavranic
 * Na LLP i LLM uslov po polju pl.vrsta
 *
 * Revision 1.10  2003/10/06 15:00:27  sasavranic
 * Unos podataka putem barkoda
 *
 * Revision 1.9  2003/06/23 09:31:45  sasa
 * prikaz dobavljaca
 *
 * Revision 1.8  2003/03/12 09:22:31  mirsad
 * Tvin: srednja cijena
 *
 * Revision 1.7  2003/01/03 15:52:33  sasa
 * ispravka pocetnog stanja
 *
 * Revision 1.6  2003/01/03 11:06:21  sasa
 * Ispravka greske sa pocetnim stanjem gSezona->goModul:oDataBase:cSezona
 *
 * Revision 1.5  2002/07/08 23:03:54  ernad
 *
 *
 * trgomarket debug dok 80, 81, izvjestaj lager lista magacin po proizv. kriteriju
 *
 * Revision 1.4  2002/07/03 23:55:19  ernad
 *
 *
 * ciscenja planika (tragao za nepostojecim bug-om u prelgedu finansijskog obrta)
 *
 * Revision 1.3  2002/06/25 15:08:46  ernad
 *
 *
 * prikaz parovno - Planika
 *
 * Revision 1.2  2002/06/20 13:13:03  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/mag/rpt/1g/rpt_llm.prg
 *  \brief Izvjestaj "lager lista magacina"
 */


/*! \fn LLM()
 *  \brief Izvjestaj "lager lista magacina"
 *  \param fPocStanje - .t. generisi pocetno stanje, .f. samo izvjestaj
 */

function LLM()
*{
parameters fPocStanje
local fimagresaka:=.f.
local aNabavke:={}

// ulaz, izlaz parovno
local nTUlazP
local nTIzlazP
local nKolicina

cIdFirma:=gFirma
cPrikazDob:="N"
cIdKonto:=padr("1310",gDuzKonto)

private nVPVU:=0
private nVPVI:=0
private nNVU:=0
private nNVI:=0

if IsPlanika()
	cPlVrsta:=SPACE(1)
	private cK9:=SPACE(3)
endif

if IsDomZdr()
	private cKalkTip:=SPACE(1)
endif

if IsVindija()
	cOpcine:=SPACE(50)
endif

if IzFMKIni("Svi","Sifk")=="D"
	O_SIFK
   	O_SIFV
endif

O_ROBA
O_KONCIJ
O_KONTO
O_PARTN

if fPocStanje==NIL
	fPocStanje:=.f.
else
   	fPocStanje:=.t.
   	O_PRIPR
   	cBrPSt:="00001   "
   	Box(,3,60)
     		@ m_x+1,m_y+2 SAY "Generacija poc. stanja  - broj dokumenta 16 -" GET cBrPSt
     		read
		ESC_BCR
   	BoxC()
endif

private dDatOd:=ctod("")
private dDatDo:=date()

qqRoba:=space(60)
qqTarifa:=space(60)
qqidvd:=space(60)
qqIdPartner:=space(60)

private cPNab:="N"
private cNula:="N"
private cErr:="N"
private cNCSif:="N"
private cMink:="N"
private cSredCij:="N"

cArtikalNaz:=SPACE(30)

Box(,18+IF(lPoNarudzbi,2,0)+IF(IsTvin(),1,0),60)
	do while .t.
 		if gNW $ "DX"
   			@ m_x+1,m_y+2 SAY "Firma "
			?? gFirma,"-",gNFirma
 		else
  			@ m_x+1,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 		endif
 		@ m_x+2,m_y+2 SAY "Konto   " GET cIdKonto valid "." $ cidkonto .or. P_Konto(@cIdKonto)
 		@ m_x+3,m_y+2 SAY "Artikli " GET qqRoba pict "@!S50"
 		@ m_x+4,m_y+2 SAY "Tarife  " GET qqTarifa pict "@!S50"
 		@ m_x+5,m_y+2 SAY "Vrste dokumenata  " GET qqIDVD pict "@!S30"
 		@ m_x+6,m_y+2 SAY "Partneri          " GET qqIdPartner pict "@!S30"
 		@ m_x+7,m_y+2 SAY "Prikaz Nab.vrijednosti D/N" GET cPNab  valid cpnab $ "DN" pict "@!"
 		@ m_x+8,m_y+2 SAY "Prikaz stavki kojima je VPV 0 D/N" GET cNula  valid cNula $ "DN" pict "@!"
 		@ m_x+9,m_y+2 SAY "Prikaz 'ERR' ako je VPV/Kolicina<>VPC " GET cErr pict "@!" valid cErr $ "DN"
 		@ m_x+10,m_y+2 SAY "Datum od " GET dDatOd
 		@ m_x+10,col()+2 SAY "do" GET dDatDo
 		@ m_x+12,m_y+2 SAY "Postaviti srednju NC u sifrarnik" GET cNCSif pict "@!" valid ((cpnab=="D" .and. cncsif=="D") .or. cNCSif=="N")
 		@ m_x+14,m_y+2 SAY "Prikaz samo kriticnih zaliha (D/N/O) ?" GET cMinK pict "@!" valid cMink$"DNO"
 		if lPoNarudzbi
   			qqIdNar := SPACE(60)
   			cPKN    := "N"
   			@ row()+1,m_y+2 SAY "Uslov po sifri narucioca:" GET qqIdNar pict "@!S30"
   			@ row()+1,m_y+2 SAY "Prikazati kolonu 'narucilac' ? (D/N)" GET cPKN VALID cPKN$"DN" pict "@!"
 		endif
 		if IsTvin()
 			@ row()+1,m_y+2 SAY "Prikazati srednju cijenu (D/N) ?" GET cSredCij VALID cSredCij$"DN" PICT "@!"
 		endif
 		if IsPlanika()
 			@ m_x+15,m_y+2 SAY "Prikaz dobavljaca (D/N) ?" GET cPrikazDob PICT "@!" VALID cPrikazDob$"DN"
 			@ m_x+16,m_y+2 SAY "Prikaz po pl.vrsta (uslov)" GET cPlVrsta PICT "@!"
 			@ m_x+17,m_y+2 SAY "Prikaz po K9" GET cK9 PICT "@!"
 		endif
 		if IsVindija()
 			@ m_x+17,m_y+2 SAY "Uslov po opcinama:" GET cOpcine PICT "@!S40"
 		endif
		
		if IsDomZdr()
 			@ m_x+15,m_y+2 SAY "Prikaz po tipu sredstva:" GET cKalkTip PICT "@!"
 		endif

 		@ m_x+18,m_y+2 SAY "Naziv artikla sadrzi"  GET cArtikalNaz

		read
		ESC_BCR
 
 		private aUsl1:=Parsiraj(qqRoba,"IdRoba")
 		private aUsl2:=Parsiraj(qqTarifa,"IdTarifa")
 		private aUsl3:=Parsiraj(qqIDVD,"idvd")
 		private aUsl4:=Parsiraj(qqIDPartner,"idpartner")
 		
		if lPoNarudzbi
   			aUslN:=Parsiraj(qqIdNar,"idnar")
 		endif
 		if aUsl1<>NIL .and. aUsl2<>NIL .and. aUsl3<>NIL .and. aUsl4<>NIL .and. (!lPoNarudzbi.or.aUslN<>NIL)
   			exit
 		endif
	enddo
BoxC()

lSvodi:=.f.

if IzFMKIni("KALK_LLM","SvodiNaJMJ","N",KUMPATH)=="D"
	lSvodi := ( Pitanje(,"Svesti kolicine na osnovne jedinice mjere? (D/N)","N")=="D" )
endif

// sinteticki konto
fSint:=.f.
cSintK:=cIdKonto

// ovaj dio je zamijenjen jer nije potrebna sintetika <=3 kada se to moze
// zadati pomocu .
// ----------------------------------------------------------------------
// if len(trim(cidkonto))<=3 .or. "." $ cidkonto
//  if "." $ cidkonto
//     cidkonto:=strtran(cidkonto,".","")
//  endif
//  cIdkonto:=trim(cidkonto)
//  cSintK:=cIdkonto
//  fSint:=.t.
// endif
// ----------------------------------------------------------------------

if "." $ cIdKonto
  	cIdkonto:=StrTran(cIdKonto,".","")
  	cIdkonto:=Trim(cIdKonto)
  	cSintK:=cIdKonto
  	fSint:=.t.
	lSabKon:=(Pitanje(,"Racunati stanje robe kao zbir stanja na svim obuhvacenim kontima? (D/N)","N")=="D")
endif

// ----------------------------------------------------------------------

O_KALKREP

private cFilt:=".t."

if aUsl1<>".t."
	cFilt+=".and."+aUsl1
endif

if aUsl2<>".t."
	cFilt+=".and."+aUsl2
endif
if aUsl3<>".t."
  	cFilt+=".and."+aUsl3
endif
if aUsl4<>".t."
  	cFilt+=".and."+aUsl4
endif
if !empty(dDatOd) .or. !empty(dDatDo)
 	cFilt+=".and. DatDok>="+cm2str(dDatOd)+".and. DatDok<="+cm2str(dDatDo)
endif
if lPoNarudzbi .and. aUslN<>".t."
  	cFilt+=".and."+aUslN
endif
if fSint .and. lSabKon
	cFilt+=".and. MKonto="+cm2str( cSintK )
  	cSintK:=""
endif
if IsDomZdr() .and. !Empty(cKalkTip)
	cFilt+=".and. tip=" + Cm2Str(cKalkTip)
endif
if cFilt==".t."
	set filter to
else
 	set filter to &cFilt
endif

select kalk

if fSint .and. lSabKon
  	if lPoNarudzbi .and. cPKN=="D"
    		set order to tag "6N"
  	else
    		set order to 6
    		//"6","idFirma+IdTarifa+idroba",KUMPATH+"KALK"
  	endif
  	hseek cIdFirma
else
	if lPoNarudzbi .and. cPKN=="D"
    		set order to tag "3N"
  	else
    		set order to 3
  	endif
  	hseek cIdFirma+cIdKonto
endif

select koncij
seek TRIM(cIdKonto)
select kalk

EOF CRET

nLen:=1
m:="----- ---------- -------------------- ---"+IF(lPoNarudzbi.and.cPKN=="D"," ------","")+" ---------- ---------- ---------- ---------- ---------- ----------"
if gVarEv=="2"
	m:="----- ---------- -------------------- --- ---------- ---------- ----------"
elseif koncij->naz<>"N1"
 	m+=" ---------- ----------"
else
 	m+=" ----------"
endif

if cSredCij=="D"
	m+=" ----------"
endif

if koncij->naz $ "P1#P2"
	cPNab:="D"
endif // ako je magacin got proizvoda

if koncij->naz<>"N1" .and. cPNab=="D"
	gaZagFix:={7+IF(lPoNarudzbi.and.!EMPTY(qqIdNar),3,0),6}
else
  	gaZagFix:={7+IF(lPoNarudzbi.and.!EMPTY(qqIdNar),3,0),5}
endif

start print cret

private nTStrana:=0
private bZagl:={|| ZaglLLM()}

Eval(bZagl)
nTUlaz:=nTIzlaz:=0
nTUlazP:=nTIzlazP:=0
nTVPVU:=nTVPVI:=nTNVU:=nTNVI:=0
nTRabat:=0
nCol1:=nCol0:=50

private nRbr:=0

do while !eof() .and. iif(fSint.and.lSabKon,idfirma,idfirma+mkonto)=cidfirma+cSintK .and. IspitajPrekid()
cIdRoba:=Idroba

if lPoNarudzbi .and. cPKN=="D"
  cIdNar:=idnar
endif

nUlaz:=nIzlaz:=0
nVPVU:=nVPVI:=nNVU:=nNVI:=0
nRabat:=0

select roba
hseek cIdRoba

// pretrazi artikle po nazivu
if (!Empty(cArtikalNaz) .and. AT(ALLTRIM(cArtikalNaz), ALLTRIM(roba->naz))==0)
	select kalk
	skip
	loop
endif

// uslov po planika vrsta
if (IsPlanika() .and. !EMPTY(cPlVrsta))
	if roba->vrsta <> cPlVrsta
		select kalk
		skip
		loop
	endif
endif
// uslov po roba->k9
if (IsPlanika() .and. !EMPTY(cK9) .and. roba->k9 <> cK9) 
	select kalk
	skip
	loop
endif

// Vindija - uslov po opcinama
if (IsVindija() .and. !EMPTY(cOpcine))
	select partn
	set order to tag "ID"
	hseek kalk->idpartner
	if AT(ALLTRIM(partn->idops), cOpcine)==0
		select kalk
		skip
		loop
	else
		altd()
	endif
	select roba
endif

if (fieldpos("MINK"))<>0
   nMink:=roba->mink
else
   nMink:=0
endif

select kalk
if roba->tip $ "TUY"
	skip
	loop
endif

cIdkonto:=mkonto
if cMink=="O"; cNula:="D"; endif
// ako zelim oznaciti sve kriticne zalihe onda mi trebaju i artikli
// sa stanjem 0 !!

aNabavke:={}

do while !eof() .and. iif(fSint.and.lSabKon,;
        cidfirma+IF(lPoNarudzbi.and.cPKN=="D",cIdNar,"")+cidroba==idFirma+IF(lPoNarudzbi.and.cPKN=="D",IdNar,"")+idroba,;
        cidfirma+cidkonto+IF(lPoNarudzbi.and.cPKN=="D",cIdNar,"")+cidroba==idFirma+mkonto+IF(lPoNarudzbi.and.cPKN=="D",IdNar,"")+idroba) .and.  IspitajPrekid()

  if roba->tip $ "TU"
  	skip
	loop
  endif

  if mu_i=="1"
    if !(idvd $ "12#22#94")
     nKolicina:=field->kolicina-field->gkolicina-field->gkolicin2
     nUlaz+=nKolicina
     SumirajKolicinu(nKolicina, 0, @nTUlazP, @nTIzlazP)
     nCol1:=pcol()+1
     if koncij->naz=="P2"
      nVPVU+=round(roba->plc*(kolicina-gkolicina-gkolicin2), gZaokr)
     else
      nVPVU+=round( vpc*(kolicina-gkolicina-gkolicin2) , gZaokr)
     endif
     nNVU+=round( nc*(kolicina-gkolicina-gkolicin2) , gZaokr)
   else
     nKolicina:=-field->kolicina
     nIzlaz+=nKolicina
     SumirajKolicinu(0, nKolicina, @nTUlazP, @nTIzlazP)
     if koncij->naz=="P2"
        nVPVI-=round( roba->plc*kolicina , gZaokr)
     else
        nVPVI-=round( vpc*kolicina , gZaokr)
     endif
     nNVI-=round( nc*kolicina , gZaokr)
    endif
  elseif mu_i=="5"
    nKolicina:=field->kolicina
    nIzlaz+=nKolicina
    SumirajKolicinu(0, nKolicina, @nTUlazP, @nTIzlazP)
    if koncij->naz=="P2"
      nVPVI+=round( roba->plc*kolicina , gZaokr)
    else
      nVPVI+=round( vpc*kolicina , gZaokr)
    endif
    nRabat+=round(  rabatv/100*vpc*kolicina , gZaokr)
    nNVI+=nc*kolicina
  elseif mu_i=="3"    
    // nivelacija
    nVPVU+=round( vpc*kolicina , gZaokr)
  elseif mu_i=="8"
     nKolicina:=-field->kolicina
     nIzlaz+=nKolicina
     SumirajKolicinu(0, nKolicina , @nTUlazP, @nTIzlazP)
     if koncij->naz=="P2"
       nVPVI+=round( roba->plc*(-kolicina) , gZaokr)
     else
       nVPVI+=round( vpc*(-kolicina) , gZaokr)
     endif
     nRabat+=round(  rabatv/100*vpc*(-kolicina) , gZaokr)
     nNVI+=nc*(-kolicina)
     
     nKolicina:=-field->kolicina
     nUlaz+=nKolicina
     SumirajKolicinu(nKolicina, 0, @nTUlazP, @nTIzlazP)
     if koncij->naz=="P2"
      nVPVU+=round(-roba->plc*(kolicina-gkolicina-gkolicin2), gZaokr)
     else
      nVPVU+=round(-vpc*(kolicina-gkolicina-gkolicin2) , gZaokr)
     endif
     nNVU+=round(-nc*(kolicina-gkolicina-gkolicin2) , gZaokr)
  endif
  
  if fPocStanje .and. glEkonomat
    KreDetNC(aNabavke)
  endif

  skip
enddo

if (cMink<>"D" .and. (cNula=="D" .or. round(nVPVU-nVPVI,4)<>0)) .or. ; //ne prikazuj stavke 0
   (cMink=="D" .and. nMink<>0 .and. (nUlaz-nIzlaz-nMink)<0)

if cMink=="O" .and. nMink==0 .and. round(nUlaz-nIzlaz,4)==0
  loop
endif

if cMink=="O" .and.  nMink<>0 .and. (nUlaz-nIzlaz-nMink)<0
   B_ON
endif

aNaz:=Sjecistr(roba->naz,20)
NovaStrana(bZagl)
? str(++nrbr,4)+".",cidroba
nCr:=pcol()+1
@ prow(),pcol()+1 SAY aNaz[1]

cJMJ:=ROBA->JMJ

IF lSvodi
  nKJMJ  := SJMJ(1 ,cIdRoba,@cJMJ)
  cJMJ:=PADR(cJMJ,LEN(ROBA->JMJ))
ELSE
  nKJMJ  := 1
ENDIF

@ prow(),pcol()+1 SAY cJMJ

IF lPoNarudzbi .and. cPKN=="D"
  @ prow(),pcol()+1 SAY cIdNar
ENDIF

nCol0:=pcol()+1

@ prow(),pcol()+1 SAY nKJMJ*nUlaz          pict gpickol
@ prow(),pcol()+1 SAY nKJMJ*nIzlaz         pict gpickol
@ prow(),pcol()+1 SAY nKJMJ*(nUlaz-nIzlaz) pict gpickol

if fPocStanje
  select pripr
  if glEkonomat
    FOR i:=LEN(aNabavke) TO 1 STEP -1
      IF !(ROUND(aNabavke[i,1],8)<>0)
        ADEL(aNabavke,i)
        ASIZE(aNabavke,LEN(aNabavke)-1)
      ENDIF
    NEXT
    FOR i:=1 TO LEN(aNabavke)
       append blank
       replace idfirma with cidfirma, idroba with cIdRoba,;
               idkonto with cIdKonto,;
               datdok with dDatDo+1,;
               idtarifa with roba->idtarifa,;
               datfaktp with dDatDo+1,;
               idvd with "16", brdok with cBRPST ,;
               kolicina with aNabavke[i,1],;
               nc with aNabavke[i,2]
       replace vpc with nc
    NEXT
  else
    if round(nUlaz-nIzlaz,4)<>0
       append blank
       replace idfirma with cidfirma, idroba with cIdRoba,;
               idkonto with cIdKonto,;
               datdok with dDatDo+1,;
               idtarifa with roba->idtarifa,;
               datfaktp with dDatDo+1,;
               kolicina with nUlaz-nIzlaz,;
               idvd with "16", brdok with cBRPST ,;
               nc with (nNVU-nNVI)/(nUlaz-nIzlaz),;
               vpc with (nVPVU-nVPVI)/(nUlaz-nIzlaz)

       if koncij->NAZ=="N1"
               replace vpc with nc
       endif
    endif
  endif
  select kalk
endif


nCol1:=pcol()+1

if gVarEv=="1"

if koncij->naz=="N1"
 @ prow(),pcol()+1 SAY nNVU pict gpicdem
 @ prow(),pcol()+1 SAY nNVI pict gpicdem
 @ prow(),pcol()+1 SAY nNVU-nNVI pict gpicdem
 if (nUlaz-nIzlaz)<>0
   @ prow(),pcol()+1 SAY (nNVU-nNVI)/(nUlaz-nIzlaz) pict gpicdem
 endif
else
 @ prow(),pcol()+1 SAY nVPVU pict gpicdem
 @ prow(),pcol()+1 SAY nRabat pict gpicdem
 @ prow(),pcol()+1 SAY nVPVI pict gpicdem
 @ prow(),pcol()+1 SAY nVPVU-NVPVI pict gpicdem
if round(nUlaz-nIzlaz,4)<>0
 @ prow(),pcol()+1 SAY (nVPVU-nVPVI)/(nUlaz-nIzlaz) pict gpiccdem
 if !(koncij->naz="P")
  if cErr=="D" .and. round((nVPVU-nVPVI)/(nUlaz-nIzlaz),4)<>round(KoncijVPC(),4)
    ?? " ERR"
  endif
 endif
else
 @ prow(),pcol()+1 SAY 0 pict gpicdem

 if (cErr=="D" .or. fPocstanje) .and. round((nVPVU-nVPVI),4)<>0
   fImaGresaka:=.t.
   ?? " ERR"
 endif
endif
endif // koncij

endif


if cSredCij=="D"
	@ prow(), pcol()+1 SAY (nNVU-nNVI+nVPVU-nVPVI)/(nUlaz-nIzlaz)/2 PICT "9999999.99"
endif


// novi red
@ prow()+1,0 SAY ""
if len(aNaz)>1
 @ prow(),nCR  SAY aNaz[2]
endif

if gVarEv=="1"

if cMink<>"N" .and. nMink>0
 @ prow(),ncol0    SAY padr("min.kolic:",len(gpickol))
 @ prow(),pcol()+1 SAY nKJMJ*nMink  pict gpickol
elseif cPNAB=="D" .and. koncij->naz<>"N1"
 @ prow(),ncol0    SAY space(len(gpickol))
 @ prow(),pcol()+1 SAY space(len(gpickol))
endif


if cPNAB=="D" .and. koncij->naz<>"N1"
  if round(nulaz-nizlaz,4)<>0
    @ prow(),pcol()+1 SAY (nNVU-nNVI)/(nUlaz-nIzlaz) pict gpicdem
    if cNCSif=="D"
      select roba
      replace nc with round((nNVU-nNVI)/(nUlaz-nIzlaz),3)
      select kalk
    endif
  elseif round(nUlaz,4)<>0
    @ prow(),pcol()+1 SAY nNVU/nUlaz pict gpicdem
  endif
  @ prow(),nCol1 SAY nNVU pict gpicdem
  @ prow(),pcol()+1 SAY space(len(gpicdem))
  @ prow(),pcol()+1 SAY nNVI pict gpicdem
  @ prow(),pcol()+1 SAY nNVU-nNVI pict gpicdem
  if koncij->naz=="P2"
    //@ prow(),pcol()+1 SAY roba->plc pict gpiccdem
  else
    @ prow(),pcol()+1 SAY KoncijVPC() pict gpiccdem
  endif
endif // cbpnab

if cMink=="O" .and. nMink<>0 .and. (nUlaz-nIzlaz-nMink)<0
   B_OFF
endif

endif

nTULaz+=nKJMJ*nUlaz
nTIzlaz+=nKJMJ*nIzlaz
nTVPVU+=nVPVU
nTVPVI+=nVPVI
nTNVU+=nNVU
nTNVI+=nNVI
nTRabat+=nRabat
endif  // cnula=="N"

if (IsPlanika() .and. cPrikazDob=="D")
	? PrikaziDobavljaca(cIdRoba, 6)
endif

if lKoristitiBK
	? SPACE(6) + roba->barkod
endif

enddo

? m
? "UKUPNO:"

@ prow(),nCol0 SAY ntUlaz pict gpickol
@ prow(),pcol()+1 SAY ntIzlaz pict gpickol
@ prow(),pcol()+1 SAY ntUlaz-ntIzlaz pict gpickol

nCol1:=pcol()+1

if gVarEv=="1"

if koncij->naz=="N1"
 @ prow(),pcol()+1 SAY ntNVU pict gpicdem
 @ prow(),pcol()+1 SAY ntNVI pict gpicdem
 @ prow(),pcol()+1 SAY ntNVU-NtNVI pict gpicdem
else
 @ prow(),pcol()+1 SAY ntVPVU pict gpicdem
 @ prow(),pcol()+1 SAY ntRabat pict gpicdem
 @ prow(),pcol()+1 SAY ntVPVI pict gpicdem
 @ prow(),pcol()+1 SAY ntVPVU-NtVPVI pict gpicdem
endif

if cpnab=="D" .and. koncij->naz<>"N1"
@ prow()+1,nCol1 SAY ntNVU pict gpicdem
@ prow(),pcol()+1 SAY space(len(gpicdem))
@ prow(),pcol()+1 SAY ntNVI pict gpicdem
@ prow(),pcol()+1 SAY ntNVU-ntNVI pict gpicdem
endif // cpnab

endif

? m

if (IsPlanika())
	PrintParovno(nTUlazP, nTIzlazP)
endif

FF
end print

if fimagresaka
  MsgBeep("Pogledajte artikle za koje je u izvjestaju stavljena oznaka ERR - GRESKA")
endif

if fPocStanje
 if fimagresaka .and. Pitanje(,"Nulirati pripremu (radi ponavljanja procedure) ?","D")=="D"
   select pripr
   zap
 else
   RenumPripr(cBrPst,"16")
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



/*! \fn ZaglLLM()
 *  \brief Zaglavlje izvjestaja "lager lista magacina"
 */

function ZaglLLM()
*{
Preduzece()
IF gVarEv=="2"
 P_12CPI
ELSE
 P_COND
ENDIF
select konto; hseek cidkonto
set century on
?? "KALK: LAGER LISTA  ZA PERIOD",dDatOd,"-",dDatdo,"  na dan", date(), space(12),"Str:",str(++nTStrana,3)

IF lPoNarudzbi .and. !EMPTY(qqIdNar)
  ?
  ? "Obuhvaceni sljedeci narucioci:",TRIM(qqIdNar)
  ?
ENDIF

set century off

if IsPlanika() .and. !EMPTY(cK9)
	? "Uslov po K9:", cK9
endif

if IsDomZdr() .and. !Empty(cKalkTip)
	PrikTipSredstva(cKalkTip)
endif

? "Magacin:", cIdkonto, "-", konto->naz

if cSredCij=="D"
	cSC1:="*Sred.cij.*"
	cSC2:="*         *"
else
	cSC1:=""
	cSC2:=""
endif

select kalk
if gVarEv=="2"
 ? m
 ? " R.  *  SIFRA   *                    *J. *"+IF(lPoNarudzbi.and.cPKN=="D","Naru- *","")+"   ULAZ      IZLAZ   *          "+cSC2
 ? " BR. * ARTIKLA  *   NAZIV ARTIKLA    *MJ.*"+IF(lPoNarudzbi.and.cPKN=="D","cilac *","")+"                     *  STANJE  "+cSC1
 ? "     *    1     *        2           * 3 *"+IF(lPoNarudzbi.and.cPKN=="D","      *","")+"     4          5    *  4 - 5   "+cSC2
 ? m
elseif koncij->naz<>"N1"
 ? m
 if koncij->naz=="P1"
    ? " R.  * Artikal  *   Naziv            *jmj*"+IF(lPoNarudzbi.and.cPKN=="D","Naru- *","")+"  ulaz       izlaz   * STANJE   *Prod.vr D *   Rabat  *Prod.vr P*  Prod.vr *  Prod.Cj *"+cSC1
 elseif koncij->naz=="P2"
    ? " R.  * Artikal  *   Naziv            *jmj*"+IF(lPoNarudzbi.and.cPKN=="D","Naru- *","")+"  ulaz       izlaz   * STANJE   *Plan.vr D *   Rabat  *Plan.vr P*  Plan.vr *  Plan.Cj *"+cSC1
 else
    ? " R.  * Artikal  *   Naziv            *jmj*"+IF(lPoNarudzbi.and.cPKN=="D","Naru- *","")+"  ulaz       izlaz   * STANJE   *  VPV.Dug.*   Rabat  * VPV.Pot *   VPV    *   VPC    *"+cSC1
 endif
 ? " br. *          *                    *   *"+IF(lPoNarudzbi.and.cPKN=="D","cilac *","")+"                     *          *          *          *         *          *          *"+cSC2
 if cPNab=="D"
  if koncij->naz=="P1"
    ? "     *          *                    *   *"+IF(lPoNarudzbi.and.cPKN=="D","      *","")+"                     * Cij.Kost * V.Kost. D*          * V.Kost.P* Vr.Kost. *          *"+cSC2
  else
    ? "     *          *                    *   *"+IF(lPoNarudzbi.and.cPKN=="D","      *","")+"                     * SR.NAB.C *   NV.Dug.*          *  NV.Pot *    NV    *          *"+cSC2
  endif
 endif
 ? "     *    1     *        2           * 3 *"+IF(lPoNarudzbi.and.cPKN=="D","      *","")+"     4          5    *  4 - 5   *     6    *     7    *     8   *   6 - 8  *     9    *"+cSC2
 ? m
else
 ? m
 ? " R.  * Artikal  *   Naziv            *jmj*"+IF(lPoNarudzbi.and.cPKN=="D","Naru- *","")+"  ulaz       izlaz   * STANJE   *   NV.Dug.*  NV.Pot *    NV    *    NC    *"+cSC1
 ? " br. *          *                    *   *"+IF(lPoNarudzbi.and.cPKN=="D","cilac *","")+"                     *          *          *         *          *          *"+cSC2
 ? "     *    1     *        2           * 3 *"+IF(lPoNarudzbi.and.cPKN=="D","      *","")+"     4          5    *  4 - 5   *     6    *     7   *   6 - 7  *          *"+cSC2
 ? m
endif
return
*}




/*! \fn PocStMag()
 *  \brief Generacija pocetnog stanja magacina
 */

function PocStMag()
*{
LLM(.t.)
         if !empty(goModul:oDataBase:cSezonDir) .and. Pitanje(,"Prebaciti dokument u radno podrucje","D")=="D"
          O_PRIPRRP
          O_PRIPR
          if reccount2()<>0
            select priprrp
            append from pripr
            select pripr; zap
            close all
            if Pitanje(,"Prebaciti se na rad sa radnim podrucjem ?","D")=="D"
               URadPodr()
            endif
          endif
        endif
        close all
return
*}
