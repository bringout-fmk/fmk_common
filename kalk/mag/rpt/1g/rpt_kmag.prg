#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/mag/rpt/1g/rpt_kmag.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.10 $
 * $Log: rpt_kmag.prg,v $
 * Revision 1.10  2004/05/25 13:53:16  sasavranic
 * Mogucnost evidentiranja tipa sredstva (donirano i kupljeno)
 *
 * Revision 1.9  2004/05/25 13:27:22  sasavranic
 * Dom Zdravlja SA:
 * evidentiranje tipa sredstva pri pravljenju ulaza,
 * mogucnost prikaza tipa sredstva na izvjestajima
 *
 * Revision 1.8  2004/05/19 12:16:54  sasavranic
 * no message
 *
 * Revision 1.7  2004/05/05 08:16:52  sasavranic
 * Na izvj.LLP dodao uslov za partnera
 *
 * Revision 1.6  2003/11/11 14:06:34  sasavranic
 * Uvodjenje f-je IspisNaDan()
 *
 * Revision 1.5  2003/10/06 15:00:27  sasavranic
 * Unos podataka putem barkoda
 *
 * Revision 1.4  2003/06/23 09:31:45  sasa
 * prikaz dobavljaca
 *
 * Revision 1.3  2002/06/20 16:52:06  ernad
 *
 *
 * ciscenje planika, uvedeno fmk/svi/specif.prg
 *
 * Revision 1.2  2002/06/20 13:13:03  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/mag/rpt/1g/rpt_kmag.prg
 *  \brief Izvjestaj "kartica magacin"
 */


/*! \fn KarticaM()
 *  \brief Izvjestaj "kartica magacin"
 *  \param cIdFirma - sifra firme
 *  \param cIdRoba - sifra robe
 *  \param cIdKonto - konto
 *
 *  \note parametri funkcije privatni
 *  \todo prebaciti parametre na lokalne varijable
 */

function KarticaM()
*{
parameters cIdFirma,cIdRoba,cIdKonto

local PicCDEM:=gPicCDEM
local PicProc:=gPicProc
local PicDEM:= gPicDem
local Pickol:="@Z " + gpickol
local nNV:=0
local nVPV:=0
private fKNabC:=.f.
private fVeci:=.f.

O_PARTN
O_TARIFA
if IzFMKIni("Svi","Sifk")=="D"
	O_SIFK
   	O_SIFV
endif
O_ROBA
O_KONTO

dDatOd:=ctod("")
dDatDo:=date()
cPredh:="N"

private cIdR:=cIdRoba

cBrFDa:="N"
cPrikFCJ2:="N"

if IsPlanika()
	cPrikazDob:="N"
	private cK9:=SPACE(3)
endif

if IsDomZdr()
	private cKalkTip:=SPACE(1)
endif

cIdPArtner:=space(6)
cPVSS:="D"  // D-Prikaz Vrijednosti Samo u Saldu  (N-duguje,potrazuje,saldo)

if cIdKonto==NIL
	cIdFirma:=gFirma
 	cIdRoba:=space(10)
 	cIdKonto:=padr("1310",gDuzKonto)
	O_PARAMS
 	private cSection:="1"
	private cHistory:=" "
	private aHistory:={}
 	Params1()
	RPar("c1",@cIdRoba)
	RPar("c2",@cIdKonto)
	RPar("c3",@cPredh)
 	RPar("d1",@dDatOd)
	RPar("d2",@dDatDo)
 	RPar("c4",@cBrFDa)
 	RPar("c5",@cPrikFCJ2)
 	RPar("c6",@cPVSS)
 	cIdKonto:=padr(cIdKonto,gDuzKonto)
 
 	Box(,13+IF(lPoNarudzbi,2,0),60)
  	do while .t.
    		if gNW $ "DX"
     			@ m_x+1,m_y+2 SAY "Firma "
			?? gFirma,"-",gNFirma
    		else
     			@ m_x+1,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cIdFirma:=left(cIdFirma,2),.t.}
    		endif
    		@ m_x+ 2,m_y+2 SAY "Konto  " GET cIdKonto valid P_Konto(@cIdKonto)
    		if lKoristitiBK
    			@ m_x+ 3,m_y+2 SAY "Artikal" GET cIdRoba  pict "@!" when {|| cIdRoba:=PADR(cIdRoba,VAL(gDuzSifIni)),.t.} valid {|| EMPTY(cIdRoba), cIdRoba:=iif(LEN(TRIM(cIdRoba))<=10,Left(cIdRoba,10),cIdRoba), right(trim(cIdRoba),1) $ ";>", P_ROBA(@cIdRoba)}
    		else
    			@ m_x+ 3,m_y+2 SAY "Artikal" GET cIdRoba  pict "@!" valid empty(cIdRoba) .or. right(trim(cIdRoba),1) $ ";>" .or. P_ROBA(@cIdRoba)
    		endif
    		@ m_x+ 5,m_y+2 SAY "Partner (prazno-svi)"  GET cIdPArtner  valid empty(cIdPartner) .or. P_Firma(@cIdPartner)  pict "@!"
    		@ m_x+ 7,m_y+2 SAY "Datum od " GET dDatOd
    		@ m_x+ 7,col()+2 SAY "do" GET dDatDo
    		@ m_x+ 8,m_y+2 SAY "sa prethodnim prometom (D/N)" GET cPredh pict "@!" valid cpredh $ "DN"
    		@ m_x+ 9,m_y+2 SAY "Prikaz broja fakt/otpremice D/N"  GET cBrFDa  valid cBrFDa $ "DN" pict "@!"
    		@ m_x+10,m_y+2 SAY "Prikaz fakturne cijene kod ulaza (KALK 10) D/N"  GET cPrikFCJ2  valid cPrikFCJ2 $ "DN" pict "@!"
    		if !gVarEv=="2"
      			@ m_x+11,m_y+2 SAY "Prikaz vrijednosti samo u saldu ? (D/N)"  GET cPVSS valid cPVSS $ "DN" pict "@!"
    		endif
		if lPoNarudzbi
      			qqIdNar:=SPACE(60)
      			cPKN:="N"
      			@ row()+1,m_y+2 SAY "Uslov po sifri narucioca:" GET qqIdNar pict "@!S30"
      			@ row()+1,m_y+2 SAY "Prikazati kolone 'narucilac' i 'br.narudzbe' ? (D/N)" GET cPKN VALID cPKN$"DN" pict "@!"
    		endif
    
    		if IsPlanika()	
    			@ m_x+12,m_y+2 SAY "Prikaz dobavljaca (D/N) ?" GET cPrikazDob VALID cPrikazDob $ "DN" PICT "@!"
    			@ m_x+13,m_y+2 SAY "Prikaz po K9 " GET cK9 PICT "@!"
    		endif
		if IsDomZdr()
    			@ m_x+12,m_y+2 SAY "Prikaz po tip-u " GET cKalkTip PICT "@!"
		endif
		
   		READ
    		ESC_BCR
    		if lPoNarudzbi
     			aUslN:=Parsiraj(qqIdNar,"idnar")
    		endif
    		if (!lPoNarudzbi.or.aUslN<>NIL)
      			exit
    		endif
  	enddo
 	BoxC()

 	if empty(cIdRoba) .or. cIdroba=="SIGMAXXXXX"
    		if pitanje(,"Niste zadali sifru artikla, izlistati sve kartice ?","N")=="N"
       			closeret
    		else
       			if !empty(cIdRoba)
           			if Pitanje(,"Korekcija nabavnih cijena ???","N")=="D"
              				fKNabC:=.t.
           			endif
       			endif
       			cIdr:=""
    		endif
 	else
    		cIdr:=cIdRoba
 	endif

 	if right(trim(cIdroba),1)==";"
    		fVeci:=.f.
    		cIdr:=trim(strtran(cIdroba,";",""))
 	elseif right(trim(cIdRoba),1)==">"
    		cIdr:=trim(strtran(cIdroba,">",""))
    		fVeci:=.t.
 	endif

 	if Params2()
   		WPar("c1",cIdRoba)
		WPar("c2",cIdKonto)
		WPar("c3",cPredh)
   		WPar("d1",dDatOd)
		WPar("d2",dDatDo)
   		WPar("c4",@cBrFDa)
   		WPar("c5",@cPrikFCJ2)
   		WPar("c6",@cPVSS)
 	endif
 	select params
	use
endif

lBezG2:=.f.

if IzFMKINI("KALK","NeGrupaPartnera","N",PRIVPATH)=="D" .and. Pitanje(,"Zelite li prikazati grupu 2 ? (D/N)","N")=="N"
  	lBezG2:=.t.
endif

O_KONCIJ
O_KALK

nKolicina:=0
select kalk
set order to 3

private cFilt:=".t."

if lPoNarudzbi .and. aUslN<>".t."
	cFilt+=".and."+aUslN
endif

if !empty(cIdPartner)
  	cFilt+=".and.IdPartner==" + Cm2Str(cIdPartner)
endif

if IsDomZdr() .and. !Empty(cKalkTip)
	cFilt+=".and. tip==" + Cm2Str(cKalkTip)
endif

if !(cFilt==".t.")
  	set filter to &cFilt
endif

hseek cIdFirma+cIdKonto+cIdR
EOF CRET

select koncij
seek trim(cIdKonto)

select kalk

gaZagFix:={7+IF(lPoNarudzbi.and.!EMPTY(qqIdNar),3,0),4}
start print cret
nLen:=1

IF gVarEv=="2"
	m:="-------- ----------- ------ "+IF(lPoNarudzbi.and.cPKN=="D","------ ---------- ","")+"------ ---------- ---------- ----------"

ELSE
	m:="-------- ----------- ------ "+IF(lPoNarudzbi.and.cPKN=="D","------ ---------- ","")+"------ ---------- ---------- ---------- ---------- ----------"
 	IF cPVSS=="N".and.koncij->naz="N1"
   		m+=" ---------- ----------"
	ENDIF

	if koncij->naz<>"N1"
		m+=" ---------- ---------- ---------- ----------"
   		IF cPVSS=="N"
   	  		m+=" ---------- ----------"
   		ENDIF
	endif

	if gRokTr=="D"
		m+=" --------"
	endif
ENDIF


private nTStrana:=0

Zagl()

do while !eof() .and. iif(fVeci,idfirma+mkonto+idroba>=cIdFirma+cIdKonto+cIdR , idfirma+mkonto+idroba=cIdFirma+cIdKonto+cIdR)
	if mkonto<>cIdKonto .or. idfirma<>cIdFirma
  		exit
	endif
	
	cIdRoba:=idroba
	select roba
	hseek cIdRoba

	// uslov po roba->k9
	if (IsPlanika() .and. EMPTY(cIdR) .and. !EMPTY(cK9) .and. roba->k9<>cK9)
		select kalk
		skip
		loop
	endif

	select tarifa
	hseek roba->idtarifa
	? m
	? "Artikal:",cIdRoba,"-",trim(roba->naz)+ iif(lKoristitiBK," BK:"+roba->barkod,"")+" ("+roba->jmj+")"

	if (IsPlanika() .and. cPrikazDob=="D")
		?? PrikaziDobavljaca(cIdRoba, 3)
	endif

	? m
	select kalk

	nCol1:=10
	nUlaz:=nIzlaz:=0
	nRabat:=nNV:=nVPV:=0
	tnNVd:=tnNVp:=tnVPVd:=tnVPVp:=0
	fPrviProl:=.t.
	nColDok:=9
	nColFCJ2:=68
	cLastPar:=""
	cSKGrup:=""
	do while !eof() .and. cIdFirma+cIdKonto+cIdRoba==idFirma+mkonto+idroba
  		nNVd:=nNVp:=nVPVd:=nVPVp:=0
  		IF lBezG2 .and. idvd=="14"
    			IF !(cLastPar==idpartner)
      				cLastPar := idpartner
      				// uzmi iz sifk karakteristiku GRUP
      				cSKGrup:=IzSifK("PARTN","GRUP",idpartner,.f.)
    			ENDIF
    			IF cSKGrup=="2"
      				SKIP 1
				LOOP
    			ENDIF
  		ENDIF
		if datdok<ddatod .and. cPredh=="N"
     			skip
			loop
  		endif
  		if datdok>ddatdo
     			skip
			loop
  		endif

  		if cPredh=="D" .and. datdok>=dDatod .and. fPrviProl
        		// ispis predhodnog stanja ***************
        		fPrviprol:=.f.
        		? "Stanje do ",ddatod
        		@ prow(),35+IF(lPoNarudzbi.and.cPKN=="D",18,0)   SAY nulaz        pict pickol
        		@ prow(),pcol()+1 SAY nizlaz       pict pickol
        		@ prow(),pcol()+1 SAY nUlaz-nIzlaz pict pickol
        		IF gVarEv=="1"
          			if round(nulaz-nizlaz,4)<>0
           				@ prow(),pcol()+1 SAY nNV/(nulaz-nizlaz)    pict pickol
          			else
           				@ prow(),pcol()+1 SAY 0          pict pickol
          			endif
          			IF cPVSS=="N".and.koncij->naz="N1"
            				@ prow(),pcol()+1 SAY tnNVd          pict picdem
            				@ prow(),pcol()+1 SAY tnNVp          pict picdem
          			ENDIF
          			@ prow(),pcol()+1 SAY nNV          pict picdem
          			if koncij->naz<>"N1"
            				@ prow(),pcol()+1 SAY nRabat       pict pickol
            				if round(nulaz-nizlaz,4)<>0
              					@ prow(),pcol()+1 SAY nVPV/(nulaz-nizlaz) pict piccdem
            				elseif nvpv<>0
              					@ prow(),pcol()+1 SAY PADC("ERR",len(piccdem))
            				else
              					@ prow(),pcol()+1 SAY 0            pict pickol
            				endif
            				IF cPVSS=="N"
              					@ prow(),pcol()+1 SAY tnVPVd          pict picdem
              					@ prow(),pcol()+1 SAY tnVPVp          pict picdem
            				ENDIF
            				@ prow(),pcol()+1 SAY nVPV         pict picdem
          			endif
        		ENDIF
        		// ispis predhodnog stanja ***************
   		endif
		
		if prow()-gPStranica>62
			FF
			Zagl()
		endif
  		if mu_i=="1" .and. !(idvd $ "12#22#94")
			nUlaz+=kolicina-gkolicina-gkolicin2
    			if datdok>=ddatod
     				? datdok,idvd+"-"+brdok,idtarifa
     				IF lPoNarudzbi .and. cPKN=="D"
       					?? "", idnar, brojnar
     				ENDIF
     				?? "",idpartner
     				nCol1:=pcol()+1
     				@ prow(),pcol()+1 SAY kolicina-gkolicina-gkolicin2 pict pickol
     				@ prow(),pcol()+1 SAY 0    pict pickol
     				@ prow(),pcol()+1 SAY nUlaz-nIzlaz    pict pickol
     				IF gVarEv=="1"
       					@ prow(),pcol()+1 SAY nc   pict piccdem
     				ENDIF
    			endif // cpredh
    			nNVd:=nc*(kolicina-gkolicina-gkolicin2)
    			tnNVd+=nNVd
    			nNV+=nc*(kolicina-gkolicina-gkolicin2)
    			if koncij->naz=="P2"
      				nVPVd:=roba->plc*(kolicina-gkolicina-gkolicin2)
      				tnVPVd+=nVPVd
      				nVPV+=roba->plc*(kolicina-gkolicina-gkolicin2)
    			else
      				nVPVd:=vpc*(kolicina-gkolicina-gkolicin2)
      				tnVPVd+=nVPVd
      				nVPV+=vpc*(kolicina-gkolicina-gkolicin2)
    			endif

    if datdok>=ddatod
     IF gVarEv=="1"
       IF cPVSS=="N".and.koncij->naz="N1"
         @ prow(),pcol()+1 SAY nNVd   pict picdem
         @ prow(),pcol()+1 SAY nNVp   pict picdem
       ENDIF
       @ prow(),pcol()+1 SAY nNV   pict picdem
       if koncij->naz<>"N1"
        @ prow(),pcol()+1 SAY 0  pict piccdem
        if koncij->naz=="P2"
             @ prow(),pcol()+1 SAY roba->plc  pict piccdem
        else
             @ prow(),pcol()+1 SAY vpc  pict piccdem
        endif
        IF cPVSS=="N"
          @ prow(),pcol()+1 SAY nvpvd pict picdem
          @ prow(),pcol()+1 SAY nvpvp pict picdem
        ENDIF
        @ prow(),pcol()+1 SAY nvpv pict picdem
       endif
     ENDIF
     if cBrFDa=="D"
       @ prow()+1,nColDok SAY brfaktp
       if !empty(idzaduz2)
         @ prow(),pcol()+1 SAY " RN: "; ?? idzaduz2
       endif
     endif

     if cPrikFCJ2=="D" .and. idvd=="10"
       @ prow()+IF(cBrFDa=="D",0,1),nColFCJ2 SAY fcj2 PICT piccdem
     endif

    endif  // cpredh


  elseif mu_i=="5"

    if fKNabC  //korekcija nabavnih cijena, opcija skrivena - nedokumentovana
       if round(nUlaz-nIzlaz,2)<>0
         replace nc with   nNV/(nUlaz-nIzlaz)
       endif
    endif


    nIzlaz+=kolicina
    if datdok>=ddatod
      ? datdok,idvd+"-"+brdok,idtarifa
      IF lPoNarudzbi .and. cPKN=="D"
        ?? "", idnar, brojnar
      ENDIF
      ?? "",idpartner
      nCol1:=pcol()+1
      @ prow(),pcol()+1 SAY 0         pict pickol
      @ prow(),pcol()+1 SAY kolicina  pict pickol
      @ prow(),pcol()+1 SAY nUlaz-nIzlaz    pict pickol
      IF gVarEv=="1"
        @ prow(),pcol()+1 SAY nc        pict piccdem
      ENDIF
    endif // cpredh

    nNVp:=nc*(kolicina)
    tnNVp+=nNVp
    nNV-=nc*(kolicina)
    if koncij->naz=="P2"
      nVPVp:=roba->plc*(kolicina)
      tnVPVp+=nVPVp
      nVPV-=roba->plc*(kolicina)
    else
      nVPVp:=vpc*(kolicina)
      tnVPVp+=nVPVp
      nVPV-=vpc*(kolicina)
    endif
    nRabat+=vpc*rabatv/100*kolicina
    if datdok>=ddatod
      IF gVarEv=="1"
        IF cPVSS=="N".and.koncij->naz="N1"
          @ prow(),pcol()+1 SAY nNVd   pict picdem
          @ prow(),pcol()+1 SAY nNVp   pict picdem
        ENDIF
        @ prow(),pcol()+1 SAY nnv        pict picdem
        if koncij->naz<>"N1"
         if koncij->naz=="P2"
            @ prow(),pcol()+1 SAY vpc*rabatv/100*kolicina  pict piccdem
            @ prow(),pcol()+1 SAY roba->plc  pict piccdem
         else
            @ prow(),pcol()+1 SAY vpc*rabatv/100*kolicina  pict piccdem
            @ prow(),pcol()+1 SAY vpc  pict piccdem
         endif
         IF cPVSS=="N"
           @ prow(),pcol()+1 SAY nvpvd pict picdem
           @ prow(),pcol()+1 SAY nvpvp pict picdem
         ENDIF
         @ prow(),pcol()+1 SAY nvpv pict picdem
         if idvd=="11"
           @ prow(),pcol()+1 SAY mpcsapp  pict piccdem
         endif
        endif
      ENDIF
      if cBrFDa=="D"
        @ prow()+1,nColDok SAY brfaktp
        if !empty(idzaduz2)
          @ prow(),pcol()+1 SAY " RN: "; ?? idzaduz2
        endif
      endif
    endif // cpredh

  elseif mu_i=="1" .and. (idvd $ "12#22#94")    // povrat
    nIzlaz-=kolicina
    if datdok>=ddatod
      ? datdok,idvd+"-"+brdok,idtarifa
      IF lPoNarudzbi .and. cPKN=="D"
        ?? "", idnar, brojnar
      ENDIF
      ?? "",idpartner
      nCol1:=pcol()+1
      @ prow(),pcol()+1 SAY 0          pict pickol
      @ prow(),pcol()+1 SAY -kolicina  pict pickol
      @ prow(),pcol()+1 SAY nUlaz-nIzlaz    pict pickol
      IF gVarEv=="1"
        @ prow(),pcol()+1 SAY nc        pict piccdem
        IF cPVSS=="N".and.koncij->naz="N1"
          @ prow(),pcol()+1 SAY nNVd   pict picdem
          @ prow(),pcol()+1 SAY nNVp   pict picdem
        ENDIF
        @ prow(),pcol()+1 SAY nnv        pict picdem
      ENDIF
    endif // cpredh
    nNVp:=-nc*(kolicina)
    tnNVp+=nNVp
    nNV+=nc*(kolicina)
    if koncij->naz=="P2"
      nVPVp:=-roba->plc*(kolicina)
      tnVPVp+=nVPVp
      nVPV+=roba->plc*(kolicina)
    else
      nVPVp:=-vpc*(kolicina)
      tnVPVp+=nVPVp
      nVPV+=vpc*(kolicina)
    endif
    if datdok>=ddatod
      IF gVarEv=="1"
        if koncij->naz<>"N1"
         @ prow(),pcol()+1 SAY 0         pict piccdem
         if koncij->naz=="P2"
            @ prow(),pcol()+1 SAY roba->plc     pict piccdem
         else
            @ prow(),pcol()+1 SAY vpc       pict piccdem
         endif
         IF cPVSS=="N"
           @ prow(),pcol()+1 SAY nvpvd pict picdem
           @ prow(),pcol()+1 SAY nvpvp pict picdem
         ENDIF
         @ prow(),pcol()+1 SAY nvpv pict picdem
         if !(idvd=="94")
          @ prow(),pcol()+1 SAY mpcsapp   pict piccdem
         endif
        endif
      ENDIF
      if cBrFDa=="D"
       @ prow()+1,nColDok SAY brfaktp
       if !empty(idzaduz2)
         @ prow(),pcol()+1 SAY " RN: "; ?? idzaduz2
       endif
      endif
    endif // cpredh
  elseif mu_i=="3"   // nivelacija
    if datdok>=ddatod
      ? datdok,idvd+"-"+brdok,idtarifa
      IF lPoNarudzbi .and. cPKN=="D"
        ?? "", idnar, brojnar
      ENDIF
    endif // cpredh
    nVPVd:=vpc*(kolicina)
    tnVPVd+=nVPVd
    nVPV+=vpc*(kolicina)
    if datdok>=ddatod

       @ prow(),pcol()+1 SAY padr("NIV   ("+ transform(kolicina,pickol)+")",len(pickol)*2+1)
       @ prow(),pcol()+1 SAY padr(" stara VPC:",len(pickol)-2)
       @ prow(),pcol()+1 SAY mpcsapp       pict piccdem  // kod ove kalk to predstavlja staru vpc
       @ prow(),pcol()+1 SAY padr("nova VPC:",len(piccdem)+IF(cPVSS=="N".and.koncij->naz="N1",2*(len(picdem)+1),0))
       if koncij->naz<>"N1"
        @ prow(),pcol()+1 SAY vpc+mpcsapp pict piccdem
        @ prow(),pcol()+1 SAY vpc         pict piccdem
        IF cPVSS=="N"
          @ prow(),pcol()+1 SAY nvpvd pict picdem
          @ prow(),pcol()+1 SAY nvpvp pict picdem
        ENDIF
        @ prow(),pcol()+1 SAY nvpv pict picdem
       endif
       if cBrFDa=="D"
         @ prow()+1,nColDok SAY brfaktp
         if !empty(idzaduz2)
           @ prow(),pcol()+1 SAY " RN: "; ?? idzaduz2
         endif
       endif
    endif //cpredh

  elseif mu_i=="8"
     // 15-ka

    nIzlaz+=  - kolicina
    nUlaz +=  - kolicina
    if datdok>=ddatod
      ? datdok,idvd+"-"+brdok,idtarifa
      IF lPoNarudzbi .and. cPKN=="D"
        ?? "", idnar, brojnar
      ENDIF
      ?? "",idpartner
      nCol1:=pcol()+1
      @ prow(),pcol()+1 SAY -kolicina  pict pickol
      @ prow(),pcol()+1 SAY -kolicina  pict pickol
      @ prow(),pcol()+1 SAY nUlaz-nIzlaz    pict pickol
      IF gVarEv=="1"
        @ prow(),pcol()+1 SAY nc        pict piccdem
      ENDIF
    endif // cpredh

    //nNV-=nc*(kolicina)
    //if koncij->naz=="P2"
    //  nVPV-=roba->plc*(kolicina)
    //else
    //  nVPV-=vpc*(kolicina)
    //endif
    nRabat+=vpc*rabatv/100*kolicina
    if datdok>=ddatod
      IF gVarEv=="1"
        IF cPVSS=="N".and.koncij->naz="N1"
          @ prow(),pcol()+1 SAY nNVd   pict picdem
          @ prow(),pcol()+1 SAY nNVp   pict picdem
        ENDIF
        @ prow(),pcol()+1 SAY nnv        pict picdem
        if koncij->naz<>"N1"
         if koncij->naz=="P2"
            @ prow(),pcol()+1 SAY vpc*rabatv/100*kolicina  pict piccdem
            @ prow(),pcol()+1 SAY roba->plc  pict piccdem
         else
            @ prow(),pcol()+1 SAY vpc*rabatv/100*kolicina  pict piccdem
            @ prow(),pcol()+1 SAY vpc  pict piccdem
         endif
         IF cPVSS=="N"
           @ prow(),pcol()+1 SAY nvpvd pict picdem
           @ prow(),pcol()+1 SAY nvpvp pict picdem
         ENDIF
         @ prow(),pcol()+1 SAY nvpv pict picdem
         if idvd=="11"
           @ prow(),pcol()+1 SAY mpcsapp  pict piccdem
         endif
        endif
      ENDIF
      if cBrFDa=="D"
        @ prow()+1,nColDok SAY brfaktp
        if !empty(idzaduz2)
          @ prow(),pcol()+1 SAY " RN: "; ?? idzaduz2
        endif
      endif
    endif // cpredh


  endif
  if gRokTr=="D"; @ prow(),pcol()+1 SAY RokTr; endif
  skip    // kalk
enddo   // cIdRoba
? m
? "Ukupno:"
@ prow(),nCol1    SAY nulaz        pict pickol
@ prow(),pcol()+1 SAY nizlaz       pict pickol
@ prow(),pcol()+1 SAY nUlaz-nIzlaz pict pickol

IF gVarEv=="1"
  if round(nulaz-nizlaz,4)<>0
   @ prow(),pcol()+1 SAY nNV/(nulaz-nizlaz)    pict pickol
  else
   @ prow(),pcol()+1 SAY 0          pict pickol
  endif
  IF cPVSS=="N".and.koncij->naz="N1"
    @ prow(),pcol()+1 SAY tnNVd          pict picdem
    @ prow(),pcol()+1 SAY tnNVp          pict picdem
  ENDIF
  @ prow(),pcol()+1 SAY nNV          pict picdem
  if koncij->naz<>"N1"
    @ prow(),pcol()+1 SAY nRabat       pict pickol
    if round(nulaz-nizlaz,4)<>0
      @ prow(),pcol()+1 SAY nVPV/(nulaz-nizlaz) pict piccdem
    elseif round(nvpv,3)<>0
      @ prow(),pcol()+1 SAY PADC("ERR",len(piccdem))
    else
      @ prow(),pcol()+1 SAY 0            pict pickol
    endif
    IF cPVSS=="N"
      @ prow(),pcol()+1 SAY tnVPVd          pict picdem
      @ prow(),pcol()+1 SAY tnVPVp          pict picdem
    ENDIF
    @ prow(),pcol()+1 SAY nVPV         pict picdem
  endif
ENDIF
? m

?
?
enddo
FF
end print

closeret
return
*}



/*! \fn Zagl()
 *  \brief Zaglavlje izvjestaja "kartica magacin"
 */

static function Zagl()
*{
select konto
hseek cIdKonto
Preduzece()
P_12CPI
?? "KARTICA MAGACIN za period",ddatod,"-",ddatdo,space(10),"Str:",str(++nTStrana,3)
IspisNaDan(5)
IF lPoNarudzbi .and. !EMPTY(qqIdNar)
	?
  	? "Obuhvaceni sljedeci narucioci:",TRIM(qqIdNar)
  	?
ENDIF
if IsPlanika() .and. !EMPTY(cK9)
	? "Uslov po K9:", cK9
endif

if IsDomZdr() .and. !EMPTY(cKalkTip)
	PrikTipSredstva(cKalkTip)
endif

? "Konto: ",cIdKonto,"-",konto->naz
select kalk
if gVarEv=="2"
	IF lPoNarudzbi .and. cPKN=="D"
    		P_COND
  	ELSE
    		P_12CPI
  	ENDIF
elseif koncij->naz<>"N1"
  	IF lPoNarudzbi .and. cPKN=="D" .or. cPVSS=="N"
    		P_COND2
  	ELSE
    		P_COND
  	ENDIF
else
  	IF lPoNarudzbi .and. cPKN=="D" .or. cPVSS=="N"
    		P_COND
  	ELSE
    		P_12CPI
  	ENDIF
endif
? m
IF gVarEv=="2"
	? "*Datum  *  Dokument *Tarifa*"+IF(lPoNarudzbi.and.cPKN=="D","Naru- *   Broj   *","")+" Partn *   Ulaz   *  Izlaz   * Stanje   "
 	? "*       *           *      *"+IF(lPoNarudzbi.and.cPKN=="D","cilac * narudzbe *","")+"       *          *          *          "
ELSE
	? "*Datum  *  Dokument *Tarifa*"+IF(lPoNarudzbi.and.cPKN=="D","Naru- *   Broj   *","")+" Partn *   Ulaz   *  Izlaz   * Stanje   *   NC     *"+IF(cPVSS=="N".and.koncij->naz="N1","  NV dug. *  NV pot. *","")+"   NV    *"
	if koncij->naz<>"N1"
  		if koncij->naz=="P2"
    			?? "  RABAT   *  Plan.C  *"+IF(cPVSS=="N"," PlVr dug.* PlVr pot.*","")+" Plan.Vr *  MPCSAPP *"
  		else
    			?? "  RABAT   *   VPC    *"+IF(cPVSS=="N"," VPV dug. * VPV pot. *","")+"   VPV   *  MPCSAPP *"
  		endif
	endif
	if gRokTr=="D"
		?? "  RokTr"
	endif
	? "*       *           *      *"+IF(lPoNarudzbi.and.cPKN=="D","cilac * narudzbe *","")+"       *          *          *          *"+IF(cPrikFCJ2=="D",PADC("FCJ",10),SPACE(10))+"*"+IF(cPVSS=="N".and.koncij->naz="N1","          *          *","")+"         *"
	if koncij->naz<>"N1"
  		?? "          *          *"+IF(cPVSS=="N","          *          *","")+"         *          *"
	endif
ENDIF

? m

return (nil)
*}

