#include "\cl\sigma\fmk\fin\fin.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fin/rpt/1g/kartica.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.9 $
 * $Log: kartica.prg,v $
 * Revision 1.9  2004/05/14 14:34:11  sasavranic
 * no message
 *
 * Revision 1.8  2004/04/16 13:54:31  sasavranic
 * Problem sa ispisom radne jedinice na izvjestaju kartice, uvijek ista radna jedinica
 *
 * Revision 1.7  2004/03/11 16:44:48  sasavranic
 * no message
 *
 * Revision 1.6  2004/03/02 18:37:27  sasavranic
 * no message
 *
 * Revision 1.5  2004/02/16 14:26:10  sasavranic
 * Na specifikaciji po suban kontima napravio rasclanjenje po RJ FUNK FOND
 *
 * Revision 1.4  2004/02/07 09:18:19  sasavranic
 * Dodao opis radne jedinice na suban kartici ako je gRJ==D
 *
 * Revision 1.3  2002/12/13 16:16:30  mirsad
 * dorada: uslov za naziv konta na suban.kartici (samo za brza=N)
 *
 * Revision 1.2  2002/06/20 11:45:37  sasa
 * no message
 *
 *
 */


/*! \file fmk/fin/rpt/1g/kartica.prg
 *  \brief Kartice
 */

/*! \fn Kartica()
 *  \brief Menij za izbor kartice
 */
 
function Kartica()
*{
private opc:={}
private opcexe:={}
private Izbor:=1
private picDEM:=FormPicL(gPicDEM,12)
private picBHD:=FormPicL(gPicBHD,16)

AADD(opc, "1. sintetika                    ")
AADD(opcexe, {|| SinKart()})
AADD(opc, "2. sintetika - po mjesecima")
AADD(opcexe, {|| SinKart2()})
AADD(opc, "3. analitika")
AADD(opcexe, {|| AnKart()})
AADD(opc, "4. subanalitika")
AADD(opcexe, {|| SubKart()})

Menu_SC("kart")

return
*}


/*! \fn SubKart(lOtvst)
 *  \brief Subanaliticka kartica
 *  \param lOtvst  - .t. otvorene stavke
 */
 
function SubKart(lOtvst)
*{
local cBrza:="D"
local nC1:=37
local nSirOp:=20
local nCOpis:=0
local cOpis:=""
private fK1:=fk2:=fk3:=fk4:="N"
private cIdFirma:=gFirma
private fOtvSt:=lOtvSt
private c1k1z:="N"
private picBHD:=FormPicL(gPicBHD,16)
private picDEM:=FormPicL(gPicDEM,12)

O_KONTO
O_PARTN
if gRJ=="D"
	O_RJ
endif
private cSazeta:="N"
private cK14:="1"

cDinDem:="1"
dDatOd:=CToD("")
dDatDo:=CToD("")
cKumul:="1"
cPredh:="1"
qqKonto:=""
qqPartner:=""

if PCount()==0
	fOtvSt:=.f.
endif

O_PARAMS

private cSection:="1"
private cHistory:=" "
private aHistory:={}

RPar("k1",@fk1)
RPar("k2",@fk2)
RPar("k3",@fk3)
RPar("k4",@fk4)

private cSection:="4"
private cHistory:=" "
private aHistory:={}

Params1()
RPar("c1",@cKumul)
RPar("c2",@cPredh)
RPar("c3",@cBrza)
RPar("cS",@cSazeta)
RPar("c4",@cIdFirma)
RPar("c5",@qqKonto)
RPar("c6",@qqPartner)
RPar("d1",@dDatOd)
RPar("d2",@dDatDo)
RPar("c7",@cDinDem)
RPar("c8",@c1K1Z)
RPar("14",@cK14)

if gNW=="D"
	cIdFirma:=gFirma
endif

cK1:="9"
cK2:="9"
cK3:="99"
cK4:="99"

if IzFMKIni("FIN","LimitiPoUgovoru_PoljeK3","N",SIFPATH)=="D"
	cK3:="999"
endif
if gDUFRJ=="D"
	cIdRj:=SPACE(60)
else
  	cIdRj:="999999"
endif
cFunk:="99999"
cFond:="9999"
private cRasclaniti:="N"
private cIdVN:=SPACE(40)
qqBrDok:=SPACE(40)
qqNazKonta:=SPACE(40)

Box("#"+IF(fOtvSt,"KARTICA OTVORENIH STAVKI","SUBANALITICKA KARTICA"),21,65)
	set cursor on
	@ m_x+2,m_y+2 SAY "BEZ/SA kumulativnim prometom  (1/2):" GET cKumul
 	@ m_x+3,m_y+2 SAY "BEZ/SA prethodnim prometom (1/2):" GET cPredh
 	@ m_x+4,m_y+2 SAY "Brza kartica (D/N)" GET cBrza pict "@!" valid cBrza $ "DN"
 	@ m_x+4,col()+2 SAY "Sazeta kartica (bez opisa) D/N" GET cSazeta  pict "@!" valid cSazeta $ "DN"
 	read
	do while .t.
		if gDUFRJ=="D"
   			cIdFirma:=PADR(gFirma+";",30)
   			@ m_x+5,m_y+2 SAY "Firma: " GET cIdFirma PICT "@!S20"
 		else
   			if gNW=="D"
     				@ m_x+5,m_y+2 SAY "Firma "
				?? gFirma,"-",gNFirma
   			else
    				@ m_x+5,m_y+2 SAY "Firma: " GET cIdFirma valid {|| EMPTY(cIdFirma).or.P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
   			endif
 		endif
		if cBrza="D"
   			qqKonto:=padr(qqKonto,7)
   			qqPartner:=padr(qqPartner,len(partn->id))
  			@ m_x+6,m_y+2 SAY "Konto  " GET qqKonto  valid P_KontoFin(@qqKonto)
   			@ m_x+7,m_y+2 SAY "Partner" GET qqPartner valid empty(qqPartner) .or. RTRIM(qqPartner)==";" .or. P_Firma(@qqPartner) pict "@!"
 		else
   			qqKonto:=padr(qqkonto,100)
   			qqPartner:=padr(qqPartner,100)
   			@ m_x+6,m_y+2 SAY "Konto  " GET qqKonto  PICTURE "@!S50"
   			@ m_x+7,m_y+2 SAY "Partner" GET qqPartner PICTURE "@!S50"
 		endif
	 	@ m_x+ 8,m_y+2 SAY "Datum dokumenta od:" GET dDatod
 		@ m_x+ 8,col()+2 SAY "do" GET dDatDo   valid dDatOd<=dDatDo
 		@ m_x+10,m_y+2 SAY "Uslov za vrstu naloga (prazno-sve)" GET cIdVN PICT "@!S20"
 		if gVar1=="0"
  			@ m_x+11,m_y+2 SAY "Kartica za "+ALLTRIM(ValDomaca())+"/"+ALLTRIM(ValPomocna())+"/"+ALLTRIM(ValDomaca())+"-"+ALLTRIM(ValPomocna())+" (1/2/3)"  GET cDinDem valid cDinDem $ "123"
 		else
  			cDinDem:="1"
	 	endif
 		@ m_x+12,m_y+2 SAY "Prikaz  K1-K4 (1); Dat.Valute (2); oboje (3)"+IF(gNW=="N".and.cSazeta=="N","; nista (4)","")  GET cK14 valid cK14 $ "123"+IF(gNW=="N".and.cSazeta=="N","4","")
 		cRasclaniti:="N"
 		if gRJ=="D"
  			@ m_x+13,m_y+2 SAY "Rasclaniti po RJ/FUNK/FOND; "  GET cRasclaniti pict "@!" valid cRasclaniti $ "DN"
	 	endif
	 	UpitK1K4(14)
 		@ row()+1,m_y+2 SAY "Uslov za broj veze (prazno-svi) " GET qqBrDok PICT "@!S20"
 		if cBrza<>"D"
   			@ row()+1,m_y+2 SAY "Uslov za naziv konta (prazno-svi) " GET qqNazKonta PICT "@!S20"
 		endif
	 	@ row()+1,m_y+2 SAY "Svaka kartica treba da ima zaglavlje kolona ? (D/N)"  GET c1k1z pict "@!" valid c1k1z $ "DN"
		read
		ESC_BCR
	
		if !(cK14 $ "123") .and. ( cSazeta=="D" .or. gNW=="D" )
   			cK14:="3"
 		endif
		if cSazeta=="N"
  			if cDinDem=="3"
   				nC1:=59+IF(gNW=="N",17,0)
  			else
   				nC1:=63+IF(gNW=="N",17,0)
  			endif
	 	endif
	
		if cDinDem=="3"
   			cKumul:="1"
	 	endif
	
		aUsl3:=parsiraj(cIdVN,"IDVN","C")
 		if gDUFRJ=="D"
   			aUsl4:=Parsiraj(cIdFirma,"IdFirma")
   			aUsl5:=Parsiraj(cIdRJ,"IdRj")
 		endif
 		aBV:=Parsiraj(qqBrDok,"UPPER(BRDOK)","C")
 		aNK:=Parsiraj(qqNazKonta,"UPPER(naz)","C")

 		if cBrza=="D"
   			if aBV<>NIL .and. aUsl3<>NIL .and. IF(gDUFRJ=="D",aUsl4<>NIL.and.aUsl5<>NIL,.t.)
			exit
			endif
		else
			qqKonto:=trim(qqKonto)
    			qqPartner:=trim(qqPartner)
    			aUsl1:=parsiraj(qqKonto,"IdKonto","C")
    			aUsl2:=parsiraj(qqPartner,"IdPartner","C")

    			if aBV<>NIL .and. aUsl1<>NIL .and. aUsl2<>NIL .and. aUsl3<>NIL .and. IF(gDUFRJ=="D",aUsl4<>NIL.and.aUsl5<>NIL,.t.)
				exit
			endif // ako je NIL - sintaksna greska
 		endif
	enddo
BoxC()

if cSazeta=="D"
	private picBHD:=FormPicL(gPicBHD,14)
endif

if Params2()
	WPar("c1",cKumul)
	WPar("c2",cPredh)
	WPar("c3",cBrza)
 	WPar("cS",cSazeta)
 	WPar("c4",cIdFirma)
	WPar("c5",qqKonto)
	WPar("c6",qqPartner)
 	WPar("d1",dDatOd)
	WPar("d2",@dDatDo)
 	WPar("c7",@cDinDem)
 	WPar("c8",@c1K1Z)
 	WPar("14",cK14)
endif

select params
use

cIdFirma:=TRIM(cIdFirma)

cSecur:=SecurR(KLevel,"KartSve")

if cBrza=="N" .and. ImaSlovo("X",cSecur)
	MsgBeep("Dozvoljena vam je samo brza kartica !")
    	closeret
endif

if cDinDem=="3"
	if cSazeta=="D"
   		m:="-- ---- ---------- -------- -------- -------------- -------------- -------------- ------------ ------------ ------------"
	else
   		if gNW=="N".and.cK14=="4"
     			m:="-- ---- ---- ---------------- ---------- -------- ---------------- ---------------- ---------------- --------------- ------------- ------------ ------------"
   		elseif gNW=="N"
     			m:="-- ---- ---- ---------------- ---------- -------- -------- ---------------- ---------------- ---------------- --------------- ------------- ------------ ------------"
   		else
     			m:="-- ---- ---- ---------- -------- -------- ---------------- ---------------- ---------------- --------------- ------------- ------------ ------------"
   		endif
 	endif
elseif cKumul=="1"
	if cSazeta=="D"
   		m:="-- ---- ---------- -------- -------- -------------- -------------- --------------"
 	else
   		if gNW=="N"
     			m:="-- ---- ---- ---------------- ---------- -------- -------- -------------------- ---------------- ----------------- ---------------"
   		else
     			m:="-- ---- ---- ---------- -------- -------- -------------------- ---------------- ----------------- ---------------"
   		endif
 	endif
else
	if cSazeta=="D"
   		m:="-- ---- ---------- -------- -------- -------------- ------------- --------------- -------------- --------------"
 	else
  		if gNW=="N".and.cK14=="4"
    			m:="-- ---- ---- ---------------- ---------- -------- -------------------- ---------------- ----------------- ---------------- ----------------- ---------------"
  		elseif gNW=="N"
    			m:="-- ---- ---- ---------------- ---------- -------- -------- -------------------- ---------------- ----------------- ---------------- ----------------- ---------------"
  		else
    			m:="-- ---- ---- ---------- -------- -------- -------------------- ---------------- ----------------- ---------------- ----------------- ---------------"
  		endif
 	endif
endif

lVrsteP:=.f.

if IzFMKIni("FAKT","VrstePlacanja","N",SIFPATH)=="D"
	lVrsteP:=.t.
  	O_VRSTEP
endif

O_SUBAN

//"1","IdFirma+IdKonto+IdPartner+dtos(DatDok)+BrNal+RBr"

O_TDOK

if IzFMKIni("FIN","LimitiPoUgovoru_PoljeK3","N",SIFPATH)=="D"
	O_ULIMIT
  	SELECT ULIMIT
  	SET ORDER TO TAG "2"
endif

select SUBAN

CistiK1k4()

cFilter:=".t." +IF(!EMPTY(cIdVN),".and."+aUsl3,"")+;
           IF(cBrza=="N",".and."+aUsl1+".and."+aUsl2,"")+;
           IF(EMPTY(dDatOd).or.cPredh=="2","",".and.DATDOK>="+cm2str(dDatOd))+;
           IF(EMPTY(dDatDo),"",".and.DATDOK<="+cm2str(dDatDo))+;
           IF(fk1=="D".and.len(ck1)<>0,".and.k1="+cm2str(ck1),"")+;
           IF(fk2=="D".and.len(ck2)<>0,".and.k2="+cm2str(ck2),"")+;
           IF(fk3=="D".and.len(ck3)<>0,".and.k3=ck3","")+;
           IF(fk4=="D".and.len(ck4)<>0,".and.k4="+cm2str(ck4),"")+;
           IF(gRj=="D".and.len(cIdrj)<>0,IF(gDUFRJ=="D",".and."+aUsl5,".and.idrj="+cm2str(cIdRJ)),"")+;
           IF(gTroskovi=="D".and.LEN(cFunk)<>0,".and.funk="+cm2str(cFunk),"")+;
           IF(gTroskovi=="D".and.LEN(cFond)<>0,".and.fond="+cm2str(cFond),"")+;
           IF(gDUFRJ=="D",".and."+aUsl4,;
           IF(LEN(cIdFirma)<2,".and.IDFIRMA="+cm2str(cIdFirma),"")+;
           IF(LEN(cIdFirma)<2.and.cBrza=="D",".and.IDKONTO=="+cm2str(qqKonto),"")+;
           IF(LEN(cIdFirma)<2.and.cBrza=="D".and.!(RTRIM(qqPartner)==";"),".and.IDPARTNER=="+cm2str(qqPartner),""))

if !EMPTY(qqBrDok)
	cFilter+=(".and." + aBV)
endif

cFilter:=STRTRAN(cFilter,".t..and.","")

if LEN(cIdFirma)<2 .or. gDUFRJ=="D"
	set index to
  	if cRasclaniti=="D"
    		index on idkonto+idpartner+idrj+funk+fond to SUBSUB for &cFilter
  	elseif cBrza=="D" .and. RTRIM(qqPartner)==";"
    		index on IdKonto+dtos(DatDok)+idpartner to SUBSUB for &cFilter
  	else
    		index on IdKonto+IdPartner+dtos(DatDok)+BrNal+RBr to SUBSUB for &cFilter
  	endif
else
	if cRasclaniti=="D"
    		set index to
    		index on idfirma+idkonto+idpartner+idrj+funk+fond to SUBSUB for &cFilter
  	else
   		if cfilter==".t."
     			set filter to
   		else
     			set filter to &cFilter
		endif
	endif
endif

if LEN(cIdFirma)<2 .or. gDUFRJ=="D"
	// nema smisla sikovati jer je vec postavljen filter
  	GO TOP
else
  	if cBrza=="N"
    		HSEEK cIdFirma
  	else
    		if RTRIM(qqPartner)==";"
      			SET ORDER TO 5
			GO TOP
      			HSEEK cIdFirma+qqKonto
    		else
      			HSEEK cIdFirma+qqKonto+qqPartner
    		endif
  	endif
endif

#ifndef CAX
	EOF RET
#else
	EOF CRET
#endif

nStr:=0
START PRINT CRET

PrikK1k4()

nSviD:=0
nSviP:=0
nSviD2:=0
nSviP2:=0

do whilesc !eof() .and. IF(gDUFRJ!="D",IdFirma=cIdFirma,.t.) // firma
	nKonD:=0
	nKonP:=0
	nKonD2:=0
	nKonP2:=0
	cIdKonto:=IdKonto
	if nStr==0
		ZaglSif(.t.)
	endif
	if cBrza=="D"   // "brza" kartica
  		if IdKonto<>qqKonto .or. IdPartner<>qqPartner .and. RTRIM(qqPartner)!=";"
     			exit
  		endif
	endif
	if !EMPTY(qqNazKonta)
  		select konto
  		hseek cIdKonto
  		if !(&(aNK))
    			select suban
    			skip 1
    			loop
  		else
    			select suban
  		endif
	endif

	do whilesc !eof() .and. cIdKonto==IdKonto .and. IF(gDUFRJ!="D",IdFirma=cIdFirma,.t.)

    		nPDugBHD:=0
		nPPotBHD:=0
		nPDugDEM:=0
		nPPotDEM:=0  // prethodni promet
    		nDugBHD:=0
		nPotBHD:=0
		nDugDEM:=0
		nPotDEM:=0
    		nZDugBHD:=0
		nZPotBHD:=0
		nZDugDEM:=0
		nZPotDEM:=0
    		cIdPartner:=IdPartner
    		
		if cRasclaniti=="D"
       			cRasclan:=idrj+funk+fond
    		else
       			cRasclan:=""
    		endif
    		
		if cBrza=="D"   // "brza" kartica
      			if IdKonto<>qqKonto .or. IdPartner<>qqPartner .and. RTRIM(qqPartner)!=";"
         			exit
      			endif
    		endif

    		if prow()>55+gPStranica
     			FF
			ZaglSif(.t.)
    		endif

    		? m
    		? "KONTO   "
		@ prow(),pcol()+1 SAY cIdKonto
    		SELECT KONTO
		HSEEK cIdKonto
    		@ prow(),pcol()+2 SAY naz
    		? "Partner "
		@ prow(),pcol()+1 SAY IF(cBrza=="D".and.RTRIM(qqPartner)==";",":  SVI",cIdPartner)
    		if cRasclaniti=="D"
      			select rj
      			set order to tag "ID"
      			seek cRasclan
      			? "        "
      			@ prow(),pcol()+1 SAY left(cRasclan,6) +"/"+substr(cRasclan,7,5)+"/"+substr(cRasclan,12)
      			select konto
    		endif

    		if !( cBrza=="D" .and. RTRIM(qqPartner)==";" )
     			SELECT PARTN
			HSEEK cIdPartner
     			@ prow(),pcol()+1 SAY naz
			@ prow(),pcol()+1 SAY naz2
			@ prow(),pcol()+1 SAY ZiroR
    		endif
    		
		select SUBAN
    		
		if c1k1z=="D"
      			ZaglSif(.f.)
    		else
      			? m
    		endif
    		fPrviPr:=.t.  // prvi prolaz

		do whilesc !eof() .and. cIdKonto==IdKonto .and. (cIdPartner==IdPartner .or. (cBrza=="D" .and. RTRIM(qqPartner)==";")) .and. Rasclan() .and. IF(gDUFRJ!="D",IdFirma=cIdFirma,.t.)
			if prow()>62+gPStranica
             			FF
				ZaglSif(.t.)
             			? m
             			? "KONTO   "
				@ prow(),pcol()+1 SAY cIdKonto
             			SELECT KONTO
				HSEEK cIdKonto
             			@ prow(),pcol()+2 SAY naz
             			? "Partner "
				@ prow(),pcol()+1 SAY IF(cBrza=="D".and.RTRIM(qqPartner)==";",":  SVI",cIdPartner)
             			if !( cBrza=="D" .and. RTRIM(qqPartner)==";" )
              				SELECT PARTN
					HSEEK cIdPartner
              				@ prow(),pcol()+1 SAY naz
					@ prow(),pcol()+1 SAY naz2
					@ prow(),pcol()+1 SAY ZiroR
             			endif
             			? "        "
				@ prow(),pcol()+1 SAY left(cRasclan,6) +"/"+substr(cRasclan,7,5)+"/"+substr(cRasclan,12)
             			select SUBAN
             			? m
          		endif
			
			if cPredh=="2" .and. fPrviPr
             			fPrviPr:=.f.
             			do while !eof() .and. cIdKonto==IdKonto .and. (cIdPartner==IdPartner .or. (cBrza=="D".and.RTRIM(qqPartner)==";")) .and. Rasclan().and. dDatOd>DatDok  .and. IF(gDUFRJ!="D",IdFirma=cIdFirma,.t.)
					if fOtvSt .and. OtvSt=="9"  // stavka je zatvorena, kartica otv.st
               					if d_P=="1"
                					nZDugBHD+=iznosbhd
							nZDugDEM+=iznosdem
               					else
                					nZPotBHD+=iznosbhd
							nZPotDEM+=iznosdem
               					endif
             				else
               					if d_P=="1"
                					nPDugBHD+=iznosbhd
							nPDugDEM+=iznosdem
               					else
                					nPPotBHD+=iznosbhd
							nPPotDEM+=iznosdem
               					endif
             				endif
					skip
             			enddo  //prethodni promet
				
				? "PROMET DO "; ?? dDatOd
             			if cSazeta=="D"
                			if cDinDem=="3"
                 				@ prow(),36 SAY ""
                			else
                 				@ prow(),36 SAY ""
                			endif
             			else
                			if cDinDem=="3"
                 				if gNW=="D"
                   					@ prow(),58 SAY ""
                 				else
                   					@ prow(),58+IF(cK14=="4",8,17) SAY ""
                 				endif
                			else
                 				if gNW=="D"
                   					@ prow(),62 SAY ""
                 				else
                   					@ prow(),62+IF(cK14=="4",8,17) SAY ""
                 				endif
                			endif
             			endif
             			
				nC1:=pcol()+1
             			if cDinDem=="1"
                			@ prow(),pcol()+1 SAY nPDugBHD PICTURE picBHD
                			@ prow(),pcol()+1 SAY nPPotBHD PICTURE picBHD
                			nDugBHD+=nPDugBHD
                			nPotBHD+=nPPotBHD
             			elseif cDinDem=="2"   // devize
                			@ prow(),pcol()+1 SAY nPDugDEM PICTURE picbhd
                			@ prow(),pcol()+1 SAY nPPotDEM PICTURE picbhd
                			nDugDEM+=nPDugDEM
                			nPotDEM+=nPPotDEM
             			elseif cDinDem=="3"   // devize
                			@ prow(),pcol()+1 SAY nPDugBHD PICTURE picBHD
                			@ prow(),pcol()+1 SAY nPPotBHD PICTURE picBHD
                			nDugBHD+=nPDugBHD
                			nPotBHD+=nPPotBHD
                			@ prow(),pcol()+1 SAY nDugBHD-nPotBHD pict picbhd

                			@ prow(),pcol()+1 SAY nPDugDEM PICTURE picdem
                			@ prow(),pcol()+1 SAY nPPotDEM PICTURE picdem
                			nDugDEM+=nPDugDEM
                			nPotDEM+=nPPotDEM
                			@ prow(),pcol()+1 SAY nDugDEM-nPotDEM pict picdem
             			endif

             			if cKumul=="2"  // sa kumulativom
                			if cDinDem=="1"
                 				@ prow(),pcol()+1 SAY nDugBHD PICTURE picbhd
                 				@ prow(),pcol()+1 SAY nPotBHD PICTURE picbhd
                			else
                 				@ prow(),pcol()+1 SAY nDugDEM PICTURE picbhd
                 				@ prow(),pcol()+1 SAY nPotDEM PICTURE picbhd
                			endif
            			endif

             			if cDinDem=="1"  // dinari
               				@ prow(),pcol()+1 SAY nDugBHD-nPotBHD pict picbhd
             			elseif cDinDem=="2"
               				@ prow(),pcol()+1 SAY nDugDEM-nPotDEM pict picbhd
             			endif

				/// nisam imao ovu liniju ???? , te{ko sam uo~io !!!!!!!!
             			// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
             			if !(cIdKonto==IdKonto .and. (cIdPartner==IdPartner .or. (cBrza=="D" .and. RTRIM(qqPartner)==";")) ) .and. Rasclan()
                      			loop
             			endif
             			// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

          		endif  // prethodni promet
			
			if !(fOtvSt .and. OtvSt=="9")
              			? IdVN
				@ prow(),pcol()+1 SAY BrNal
              			if cSazeta=="N"
               				@ prow(),pcol()+1 SAY RBr
               				if gNW=="N"
                				@ prow(),pcol()+1 SAY IdTipDok
                				SELECT TDOK
						HSEEK SUBAN->IdTipDok
                				@ prow(),pcol()+1 SAY naz
               				endif
              			endif
              			SELECT SUBAN
              			@ prow(),pcol()+1 SAY padr(BrDok,10)
              			@ prow(),pcol()+1 SAY DatDok
              			if ck14=="1"
                			@ prow(),pcol()+1 SAY k1+"-"+k2+"-"+K3Iz256(k3)+k4
              			elseif ck14=="2"
               				@ prow(),pcol()+1 SAY DatVal
              			elseif ck14=="3"
                			nC7:=pcol()+1
                			@ prow(),nc7 SAY DatVal
              			endif

              			if cSazeta=="N"
               				if cDinDem=="3"
                				nSirOp:=16
						nCOpis:=pcol()+1
                				@ prow(),pcol()+1 SAY padr(cOpis:=ALLTRIM(Opis),16)
               				else
                				nSirOp:=20
						nCOpis:=pcol()+1
                				@ prow(),pcol()+1 SAY PADR(cOpis:=ALLTRIM(Opis),20)
               				endif
              			endif

              			nC1:=pcol()+1
          		endif // fOtvStr

          		if cDinDem=="1"
           			if fOtvSt .and. OtvSt=="9"
            				if D_P=="1"
             					nZDugBHD+=IznosBHD
            				else
             					nZPotBHD+=IznosBHD
            				endif	
           			else // otvorena stavka
            				if D_P=="1"
             					@ prow(),pcol()+1 SAY IznosBHD PICTURE picBHD
             					@ prow(),pcol()+1 SAY 0 PICT picBHD
             					nDugBHD+=IznosBHD
            				else
             					@ prow(),pcol()+1 SAY 0 PICT picBHD
             					@ prow(),pcol()+1 SAY IznosBHD PICTURE picBHD
             					nPotBHD+=IznosBHD
            				endif
            				if cKumul=="2"   // prikaz kumulativa
              					@ prow(),pcol()+1 SAY nDugBHD pict picbhd
              					@ prow(),pcol()+1 SAY nPotBHD pict picbhd
            				endif
           			endif
          		elseif cDinDem=="2"   // devize

           			if fOtvSt .and. OtvSt=="9"
            				IF D_P=="1"
             					nZDugDEM+=IznosDEM
            				ELSE
             					nZPotDEM+=IznosDEM
            				ENDIF
           			else  // otvorena stavka
            				IF D_P=="1"
             					@ prow(),pcol()+1 SAY IznosDEM PICTURE picbhd
             					@ prow(),pcol()+1 SAY 0 PICTURE picbhd
             					nDugDEM+=IznosDEM
            				ELSE
             					@ prow(),pcol()+1 SAY 0        PICTURE picbhd
             					@ prow(),pcol()+1 SAY IznosDEM PICTURE picbhd
             					nPotDEM+=IznosDEM
            				ENDIF
            				if cKumul=="2"   // prikaz kumulativa
              					@ prow(),pcol()+1 SAY nDugDEM pict picbhd
              					@ prow(),pcol()+1 SAY nPotDEM pict picbhd
            				endif
           			endif
          		elseif cDinDem=="3"
           			if fOtvSt .and. OtvSt=="9"
            				IF D_P=="1"
             					nZDugBHD+=IznosBHD
						nZDugDEM+=IznosDEM
            				ELSE
             					nZPotBHD+=IznosBHD
						nZPotDEM+=IznosDEM
            				ENDIF
           			else  // otvorene stavke
            				IF D_P=="1"
             @ prow(),pcol()+1 SAY IznosBHD PICTURE picBHD
             @ prow(),pcol()+1 SAY 0        PICTURE picBHD
             nDugBHD+=IznosBHD
            ELSE
             @ prow(),pcol()+1 SAY 0        PICTURE picBHD
             @ prow(),pcol()+1 SAY IznosBHD PICTURE picBHD
             nPotBHD+=IznosBHD
            ENDIF
            @ prow(),pcol()+1 SAY nDugBHD-nPotBHD pict picbhd
            IF D_P=="1"
             @ prow(),pcol()+1 SAY IznosDEM PICTURE picdem
             @ prow(),pcol()+1 SAY 0        PICTURE picdem
             nDugDEM+=IznosDEM
            ELSE
             @ prow(),pcol()+1 SAY 0        PICTURE picdem
             @ prow(),pcol()+1 SAY IznosDEM PICTURE picdem
             nPotDEM+=IznosDEM
            ENDIF
            @ prow(),pcol()+1 SAY nDugDEM-nPotDEM pict picdem
           endif
          endif

          if !(fOtvSt .and. OtvSt=="9")
          // ******** saldo ..........
           if cDinDem="1"
            @ prow(),pcol()+1 SAY nDugBHD-nPotBHD pict picbhd
           elseif cDinDem=="2"
            @ prow(),pcol()+1 SAY nDugDEM-nPotDEM pict picbhd
           endif

           OstatakOpisa(@cOpis,nCOpis,{|| IF(prow()>60+gPStranica,EVAL({|| gPFF(),ZaglSif(.t.)}),)},nSirOp)
           if ck14=="3"
             @ prow()+1,nc7 SAY k1+"-"+k2+"-"+K3Iz256(k3)+k4
             if gRj=="D"
              @ prow(),pcol()+1 SAY "RJ:"+idrj
             endif
             if gTroskovi=="D"
              @ prow(),pcol()+1 SAY "Funk.:"+Funk
              @ prow(),pcol()+1 SAY "Fond.:"+Fond
             endif
           endif
          endif
          OstatakOpisa(@cOpis,nCOpis,{|| IF(prow()>60+gPStranica,EVAL({|| gPFF(),ZaglSif(.t.)}),)},nSirOp)


          SKIP 1
     enddo // partner

     IF prow()>56+gPStranica; FF; ZaglSif(.t.); ENDIF

     ? M
     ? "UKUPNO:"+cIdkonto+IF(cBrza=="D".and.RTRIM(qqPartner)==";","","-"+cIdPartner)
     if cRasclaniti=="D"
        @ prow(), pcol()+1 SAY left(cRasclan,6) +"/"+substr(cRasclan,7,5)+"/"+substr(cRasclan,12)
     endif

     if cDinDem=="1"
       @ prow(),nC1      SAY nDugBHD PICTURE picBHD
       @ prow(),pcol()+1 SAY nPotBHD PICTURE picBHD
       if cKumul=="2"
        @ prow(),pcol()+1 SAY nDugBHD pict picbhd
        @ prow(),pcol()+1 SAY nPotBHD pict picbhd
       endif
       @ prow(),pcol()+1 SAY nDugBHD-nPotBHD pict picbhd
     elseif cDinDem=="2"
       @ prow(),nC1      SAY nDugDEM PICTURE picBHD
       @ prow(),pcol()+1 SAY nPotDEM PICTURE picBHD
       if cKumul=="2"
        @ prow(),pcol()+1 SAY nDugDEM pict picbhd
        @ prow(),pcol()+1 SAY nPotDEM pict picbhd
       endif
       @ prow(),pcol()+1 SAY nDugDEM-nPotDEM pict picbhd
     elseif  cDinDem=="3"
       @ prow(),nC1      SAY nDugBHD PICTURE picBHD
       @ prow(),pcol()+1 SAY nPotBHD PICTURE picBHD
       @ prow(),pcol()+1 SAY nDugBHD-nPotBHD pict picbhd

       @ prow(),pcol()+1      SAY nDugDEM PICTURE picdem
       @ prow(),pcol()+1 SAY nPotDEM PICTURE picdem
       @ prow(),pcol()+1 SAY nDugDEM-nPotDEM pict picdem
     endif


     if fOtvST
       ? "Promet zatvorenih stavki:"
       if cDinDem=="1"
          @ prow(),nC1      SAY nZDugBHD PICTURE picBHD
          @ prow(),pcol()+1 SAY nZPotBHD PICTURE picBHD
          if cKumul=="2"
           @ prow(),pcol()+1 SAY nZDugBHD pict picbhd
           @ prow(),pcol()+1 SAY nZPotBHD pict picbhd
          endif
          @ prow(),pcol()+1 SAY nZDugBHD-nZPotBHD pict picbhd
       elseif cDinDem=="2"
          @ prow(),nC1      SAY nZDugDEM PICTURE picBHD
          @ prow(),pcol()+1 SAY nZPotDEM PICTURE picBHD
          if cKumul=="2"
           @ prow(),pcol()+1 SAY nZDugDEM pict picbhd
           @ prow(),pcol()+1 SAY nZPotDEM pict picbhd
          endif
          @ prow(),pcol()+1 SAY nZDugDEM-nZPotDEM pict picbhd
       elseif  cDinDem=="3"
          @ prow(),nC1      SAY nZDugBHD PICTURE picBHD
          @ prow(),pcol()+1 SAY nZPotBHD PICTURE picBHD
          @ prow(),pcol()+1 SAY nZDugBHD-nZPotBHD pict picbhd

          @ prow(),pcol()+1 SAY nZDugDEM PICTURE picdem
          @ prow(),pcol()+1 SAY nZPotDEM PICTURE picdem
          @ prow(),pcol()+1 SAY nZDugDEM-nZPotDEM pict picdem
       endif
     endif

     ? m

     nKonD+=nDugBHD;  nKonP+=nPotBHD
     nKonD2+=nDugDEM; nKonP2+=nPotDEM

     if fk3=="D" .and. !len(ck3)=0 .and. cBrza=="D" .and.;
        IzFMKIni("FIN","LimitiPoUgovoru_PoljeK3","N",SIFPATH)=="D"
       nLimit  := ABS( Ocitaj(F_ULIMIT,k3iz256(ck3)+cIdPartner,"limit") )
       nSLimit := ABS( nDugBHD-nPotBHD )
       ? "------------------------------"
       ? "LIMIT PO K3  :",TRANS(nLimit        ,"999999999999.99")
       ? "SALDO PO K3  :",TRANS(nSLimit       ,"999999999999.99")
       ? "R A Z L I K A:",TRANS(nLimit-nSLimit,"999999999999.99")
       ? "------------------------------"
     endif

     if gnRazRed==99
       FF; ZaglSif(.t.)
     else
       i:=0
       do while prow()<=55+gPstranica.and.gnRazRed>i
         ?; ++i
       enddo
     endif

enddo // konto

   if cBrza=="N"
     IF prow()>56+gPStranica; FF; ZaglSif(.t.); ENDIF
     ? M
     ? "UKUPNO ZA KONTO:"+cIdKonto
     if cDinDem=="1"
       @ prow(),nC1            SAY nKonD  PICTURE picBHD
       @ prow(),pcol()+1       SAY nKonP  PICTURE picBHD
       if cKumul=="2"
        @ prow(),pcol()+1       SAY nKonD  PICTURE picBHD
        @ prow(),pcol()+1       SAY nKonP  PICTURE picBHD
       endif
       @ prow(),pcol()+1  SAY nKonD-nKonP pict picbhd
     elseif cDinDem=="2"
       @ prow(),nC1            SAY nKonD2 PICTURE picBHD
       @ prow(),pcol()+1       SAY nKonP2 PICTURE picBHD
       if cKumul=="2"
        @ prow(),pcol()+1       SAY nKonD2 PICTURE picBHD
        @ prow(),pcol()+1       SAY nKonP2 PICTURE picBHD
       endif
       @ prow(),pcol()+1  SAY nKonD2-nKonP2 pict picbhd
     elseif cDinDem=="3"
       @ prow(),nC1            SAY nKonD  PICTURE picBHD
       @ prow(),pcol()+1       SAY nKonP  PICTURE picBHD
       @ prow(),pcol()+1  SAY nKonD-nKonP pict picbhd
       @ prow(),pcol()+1       SAY nKonD2 PICTURE picdem
       @ prow(),pcol()+1       SAY nKonP2 PICTURE picdem
       @ prow(),pcol()+1  SAY nKonD2-nKonP2 pict picdem

     endif
     ? M
   endif

nSviD+=nKonD; nSviP+=nKonP
nSviD2+=nKonD2; nSviP2+=nKonP2

if gnRazRed==99
  FF; ZaglSif(.t.)
else
  i:=0
  do while prow()<=55+gPstranica.and.gnRazRed>i
    ?; ++i
  enddo
endif

enddo // eof()


if cBrza=="N"
IF prow()>56+gPStranica; FF; ZaglSif(.t.); ENDIF
? M
? "UKUPNO ZA SVA KONTA:"
if cDinDem=="1"
  @ prow(),nC1       SAY nSviD        PICTURE picBHD
  @ prow(),pcol()+1  SAY nSviP        PICTURE picBHD
  if cKumul=="2"
   @ prow(),pcol()+1  SAY nSviD        PICTURE picBHD
   @ prow(),pcol()+1  SAY nSviP        PICTURE picBHD
  endif
  @ prow(),pcol()+1  SAY nSviD-nSviP  PICTURE picBHD
elseif cDinDem=="2"
  @ prow(),nC1       SAY nSviD2        PICTURE picBHD
  @ prow(),pcol()+1  SAY nSviP2        PICTURE picBHD
  if cKumul=="2"
   @ prow(),pcol()+1  SAY nSviD2       PICTURE picBHD
   @ prow(),pcol()+1  SAY nSviP2       PICTURE picBHD
  endif
  @ prow(),pcol()+1  SAY nSviD2-nSviP2 PICTURE picBHD
elseif cDinDem=="3"
  @ prow(),nC1       SAY nSviD        PICTURE picBHD
  @ prow(),pcol()+1  SAY nSviP        PICTURE picBHD
  @ prow(),pcol()+1  SAY nSviD-nSviP  PICTURE picBHD
  @ prow(),pcol()+1  SAY nSviD2        PICTURE picdem
  @ prow(),pcol()+1  SAY nSviP2        PICTURE picdem
  @ prow(),pcol()+1  SAY nSviD2-nSviP2 PICTURE picdem
endif
? M
?
endif // cBrza

FF
END PRINT

#ifndef CAX
closeret
#endif
return
*}



/*! \fn Telefon(cTel)
 *  \brief Postavlja uslov za partnera (npr. Telefon('417'))
 *  \param cTel  - Broj telefona
 */
 
function Telefon(cTel)
*{
local nSelect
nselect:=select()
select partn
hseek suban->idpartner
select (nselect)
return partn->telefon=cTel
*}


/*! \fn ZaglSif(lPocStr)
 *  \brief Zaglavlje subanaliticke kartice ili kartice otvorenih stavki
 *  \param lPocStr
 */
 
function ZaglSif(lPocStr)
*{
if lPocStr==NIL; lPocStr:=.f.; ENDIF
if c1k1z==NIL; c1k1z:="N"; endif
if c1k1z<>"D" .or. lPocStr
  Preduzece()
  if cDinDem=="3"  .or. cKumul=="2"
    P_COND2
  else
    P_COND
  endif
  if fOtvSt
   ? "FIN: KARTICA OTVORENIH STAVKI "
  else
   ? "FIN: SUBANALITICKA KARTICA  ZA "
  endif

  ?? iif(cDinDem=="1",ValDomaca(),iif(cDinDem=="2",ValPomocna(),ValDomaca()+"-"+ValPomocna()))," NA DAN:",DATE()
  if !(empty(dDatOd) .and. empty(dDatDo))
      ?? "   ZA PERIOD OD",dDatOd,"DO",dDatDo
  endif
  IF !EMPTY(qqBrDok)
    ? "Izvjestaj pravljen po uslovu za broj veze/racuna: '"+TRIM(qqBrDok)+"'"
  ENDIF
  @ prow(),125 SAY "Str."+str(++nStr,5)
endif

SELECT SUBAN
if c1k1z<>"D" .or. !lPocStr
  if cDinDem=="3"
   if cSazeta=="D"
    ?  "-------- --------------------------- ---------------------------- -------------- -------------------------- ------------"
    ?  "*NALOG *     D O K U M E N T        *      PROMET  "+ValDomaca()+"          *    SALDO     *       PROMET  "+ValPomocna()+"       *   SALDO   *"
    ?  "------- ------------------- -------- -----------------------------     "+ValDomaca()+"     * -------------------------    "+ValPomocna()+"    *"
    ?  "*V.* BR *   BROJ   * DATUM  *"+iif(cK14=="1"," K1-K4 "," VALUTA")+;
                                           "*     DUG     *      POT     *              *      DUG    *   POT      *           *"
    ?  "*N.*    *          *        *       *                            *              *             *            *           *"
   else
    if gNW=="N".and.cK14=="4"
     ?  "------------ ----------------------------------------------------- --------------------------------- -------------- -------------------------- -------------"
     ?  "*  NALOG    *               D  O  K  U  M  E  N  T                *          PROMET  "+ValDomaca()+"           *    SALDO     *       PROMET  "+ValPomocna()+"       *   SALDO    *"
     ?  "------------ ------------------------------------ ---------------- ----------------------------------      "+ValDomaca()+"    * --------------------------    "+ValPomocna()+"    *"
     ?  "*V.*BR * R. *     TIP I      *   BROJ   *  DATUM *    OPIS        *     DUG       *       POT       *              *      DUG    *   POT      *            *"
     ?  "*N.*   * Br.*     NAZIV      *          *        *                *               *                 *              *             *            *            *"
    elseif gNW=="N"
     ?  "------------ -------------------------------------------------------------- --------------------------------- -------------- -------------------------- -------------"
     ?  "*  NALOG    *                       D  O  K  U  M  E  N  T                 *          PROMET  "+ValDomaca()+"           *    SALDO     *       PROMET  "+ValPomocna()+"       *   SALDO    *"
     ?  "------------ ------------------------------------ -------- ---------------- ----------------------------------      "+ValDomaca()+"    * --------------------------    "+ValPomocna()+"    *"
     ?  "*V.*BR * R. *     TIP I      *   BROJ   *  DATUM *"+iif(cK14=="1"," K1-K4  "," VALUTA ")+"*    OPIS        *     DUG       *       POT       *              *      DUG    *   POT      *            *"
     ?  "*N.*   * Br.*     NAZIV      *          *        *        *                *               *                 *              *             *            *            *"
    else
     ?  "------------ --------------------------------------------- --------------------------------- -------------- -------------------------- -------------"
     ?  "*  NALOG    *           D O K U M E N T                   *          PROMET  "+ValDomaca()+"           *    SALDO     *       PROMET  "+ValPomocna()+"       *   SALDO    *"
     ?  "------------ ------------------- -------- ---------------- ----------------------------------      "+ValDomaca()+"    * --------------------------    "+ValPomocna()+"    *"
     ?  "*V.*BR * R. *   BROJ   *  DATUM *"+iif(cK14=="1"," K1-K4  "," VALUTA ")+"*    OPIS        *     DUG       *       POT       *              *      DUG    *   POT      *            *"
     ?  "*N.*   * Br.*          *        *        *                *               *                 *              *             *            *            *"
    endif
   endif
  elseif cKumul=="1"
   if cSazeta=="D"
    ?  "-------- ---------------------------- --------------------------- ---------------"
    ?  "* NALOG *      D O K U M E N T       *       P R O M E T         *    SALDO     *"
    ?  "-------- ------------------- -------- ---------------------------               *"
    ?  "*V.*BR  *   BROJ   *  DATUM *"+iif(cK14=="1"," K1-K4  "," VALUTA ")+"*    DUGUJE   *   POTRA各JE  *             *"
    ?  "*N.*    *          *        *        *            *              *              *"
   else
    if gNW=="N"
     ?  "------------ ------------------------------------------------------------------ ---------------------------------- ---------------"
     ?  "*  NALOG    *                       D  O  K  U  M  E  N  T                     *           P R O M E T            *    SALDO     *"
     ?  "------------ ------------------------------------ -------- -------------------- ----------------------------------               *"
     ?  "*V.*BR * R. *     TIP I      *  BROJ    *  DATUM *"+iif(cK14=="1"," K1-K4  "," VALUTA ")+"*    OPIS            *    DUGUJE     *    POTRA各JE     *              *"
     ?  "*N.*   * Br.*     NAZIV      *          *        *        *                    *               *                  *              *"
    else
     ?  "------------ ------------------------------------------------- ---------------------------------- ---------------"
     ?  "*  NALOG    *            D O K U M E N T                      *           P R O M E T            *    SALDO     *"
     ?  "------------ ------------------- -------- -------------------- ----------------------------------               *"
     ?  "*V.*BR * R. *   BROJ   *  DATUM *"+iif(cK14=="1"," K1-K4  "," VALUTA ")+"*    OPIS            *    DUGUJE     *    POTRAZUJE     *              *"
     ?  "*N.*   * Br.*          *        *        *                    *               *                  *              *"
    endif
   endif
  else
   if cSazeta=="D"
    ?  "-------- ---------------------------- --------------------------- ----------------------------- ---------------"
    ?  "* NALOG *    D O K U M E N T         *        P R O M E T        *      K U M U L A T I V      *    SALDO     *"
    ?  "-------- ------------------- -------- --------------------------- ------------------------------              *"
    ?  "*V.*BR  *   BROJ   *  DATUM *"+iif(cK14=="1"," K1-K4  "," VALUTA ")+"*   DUGUJE   *  POTRAZUJE   *    DUGUJE    *  POTRA各JE   *              *"
    ?  "*N.*    *          *        *        *            *              *              *              *              *"
   else
    if gNW=="N".and.cK14=="4"
     ?  "------------ --------------------------------------------------------- ---------------------------------- ---------------------------------- ---------------"
     ?  "*  NALOG    *               D  O  K  U  M  E  N  T                    *           P R O M E T            *           K U M U L A T I V      *    SALDO     *"
     ?  "------------ ------------------------------------ -------------------- ---------------------------------- ----------------------------------               *"
     ?  "*V.*BR * R. *     TIP I      *   BROJ   *  DATUM *    OPIS            *    DUGUJE     *    POTRAZUJE     *    DUGUJE     *    POTRA各JE     *              *"
     ?  "*N.*   * Br.*     NAZIV      *          *        *                    *               *                  *               *                  *              *"
    elseif gNW=="N"
     ?  "------------ ------------------------------------------------------------------ ---------------------------------- ---------------------------------- ---------------"
     ?  "*  NALOG    *                       D  O  K  U  M  E  N  T                     *           P R O M E T            *           K U M U L A T I V      *    SALDO     *"
     ?  "------------ ------------------------------------ -------- -------------------- ---------------------------------- ----------------------------------               *"
     ?  "*V.*BR * R. *     TIP I      *   BROJ   *  DATUM *"+iif(cK14=="1"," K1-K4  "," VALUTA ")+"*    OPIS            *    DUGUJE     *    POTRAZUJE     *    DUGUJE     *    POTRA各JE     *              *"
     ?  "*N.*   * Br.*     NAZIV      *          *        *        *                    *               *                  *               *                  *              *"
    else
     ?  "------------ ------------------------------------------------- ---------------------------------- ---------------------------------- ---------------"
     ?  "*  NALOG    *            D O K U M E N T                      *           P R O M E T            *           K U M U L A T I V      *    SALDO     *"
     ?  "------------ ------------------- -------- -------------------- ---------------------------------- ----------------------------------               *"
     ?  "*V.*BR * R. *   BROJ   *  DATUM *"+iif(cK14=="1"," K1-K4  "," VALUTA ")+"*    OPIS            *    DUGUJE     *    POTRAZUJE     *    DUGUJE     *    POTRA各JE     *              *"
     ?  "*N.*   * Br.*          *        *        *                    *               *                  *               *                  *              *"
    endif
   endif
  endif
  ? m
endif

RETURN
*}



/*! \fn Rasclan()
 *  \brief Rasclanjuje SUBAN->(IdRj+Funk+Fond)
 */
 
function Rasclan()
*{
if cRasclaniti=="D"
  return cRasclan==suban->(idrj+funk+fond)
else
  return .t.
endif
*}


/*! \fn SubKart2(lOtvSt)
 *  \brief Subanaliticka kartica kod koje se mogu navesti dva konta i vidjeti kroz jednu karticu
 *  \param lOtvSt
 */
 
function SubKart2(lOtvSt)
*{
local cBrza:="D", nSirOp:=20, nCOpis:=0, cOpis:=""
local fK1:=fk2:=fk3:=fk4:="N",nC1:=35

private fOtvSt:=lOtvSt
cIdFirma:=gFirma

private picBHD:=FormPicL(gPicBHD,16)
private picDEM:=FormPicL(gPicDEM,12)

O_KONTO
O_PARTN

private cSazeta:="N",cK14:="1"

cDinDem:="1"
dDatOd:=dDatDo:=ctod("")
cKumul:=cPredh:="1"
private qqKonto:=qqKonto2:=qqPartner:=""

if pcount()==0; fOtvSt:=.f.;endif
if gNW=="D";cIdFirma:=gFirma; endif
cK1:=cK2:="9"; cK3:=cK4:="99"
IF IzFMKIni("FIN","LimitiPoUgovoru_PoljeK3","N",SIFPATH)=="D"
  cK3:="999"
ENDIF
cPoVezi:="N"

cNula:="N"
Box("",18,65)
set cursor on
 if fOtvSt
  @ m_x+1,m_y+2 SAY "KARTICA OTVORENIH STAVKI KONTO/KONTO2"
 else
  @ m_x+1,m_y+2 SAY "SUBANALITICKA KARTICA"
 endif
 @ m_x+2,m_y+2 SAY "BEZ/SA kumulativnim prometom  (1/2):" GET cKumul
 @ m_x+4,m_y+2 SAY "Sazeta kartica (bez opisa) D/N" GET cSazeta  pict "@!" valid cSazeta $ "DN"
 read
do while .t.

 if gNW=="D"
   @ m_x+5,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
 else
  @ m_x+5,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 endif

 cPrelomljeno:="N"
 if cBrza="D"
   qqKonto:=padr(qqKonto,7)
   qqKonto2:=padr(qqKonto2,7)
   qqPartner:=padr(qqPartner,6)
   @ m_x+6,m_y+2 SAY "Konto   " GET qqKonto  valid P_KontoFin(@qqKonto)
   @ m_x+7,m_y+2 SAY "Konto 2 " GET qqKonto2  valid P_KontoFin(@qqKonto2) .and. qqKonto2>qqkonto
   @ m_x+8,m_y+2 SAY "Partner (prazno svi)" GET qqPartner valid (";" $ qqpartner) .or. empty(qqPartner) .or. P_Firma(@qqPartner)  pict "@!"
 endif
 @ m_x+9,m_y+2 SAY "Datum dokumenta od:" GET dDatod
 @ m_x+9,col()+2 SAY "do" GET dDatDo   valid dDatOd<=dDatDo
 IF gVar1=="0"
   @ m_x+10,m_y+2 SAY "Kartica za "+ALLTRIM(ValDomaca())+"/"+ALLTRIM(ValPomocna())+"/"+ALLTRIM(ValDomaca())+"-"+ALLTRIM(ValPomocna())+" (1/2/3)"  GET cDinDem valid cDinDem $ "123"
 ENDIF
 @ m_x+11,m_y+2 SAY "Sabrati po brojevima veze D/N ?"  GET cPoVezi valid cPoVezi $ "DN" pict "@!"
 @ m_x+11,col()+2 SAY "Prikaz prebijenog stanja " GET cPrelomljeno valid cprelomljeno $ "DN" pict "@!"
 @ m_x+12,m_y+2 SAY "Prikaz  K1-K4 (1); Dat.Valute (2); oboje (3)"  GET cK14 valid cK14 $ "123"


 if fk1=="D"; @ m_x+14,m_y+2 SAY "K1 (9 svi) :" GET cK1; endif
 if fk2=="D"; @ m_x+15,m_y+2 SAY "K2 (9 svi) :" GET cK2; endif
 if fk3=="D"; @ m_x+16,m_y+2 SAY "K3 ("+cK3+" svi):" GET cK3; endif
 if fk4=="D"; @ m_x+17,m_y+2 SAY "K4 (99 svi):" GET cK4; endif

 @ m_x+18,m_Y+2 SAY "Prikaz kartica sa 0 stanjem " GET cNula valid cNula $ "DN" pict "@!"
 read; ESC_BCR

 if cSazeta=="N"
  if cDinDem=="3"
   nC1:=68
  else
   nC1:=72
  endif
 endif

 if cDinDem=="3"
   cKumul:="1"
 endif

 if cBrza=="D"
   exit
 else
    qqKonto:=trim(qqKonto)
    qqPartner:=trim(qqPartner)
    exit

 endif

enddo

BoxC()

if cSazeta=="D"
 private picBHD:=FormPicL(gPicBHD,14)
endif


if cDinDem=="3"
 if cSazeta=="D"
   m:="------- -- ---- ---------- -------- -------- -------------- -------------- -------------- ------------ ------------ ------------"
 else
   if gNW=="N"
     m:="------- -- ---- ---- ---------------- ---------- -------- -------- ---------------- ---------------- ---------------- --------------- ------------- ------------ ------------"
   else
     m:="------- -- ---- ---- ---------- -------- -------- ---------------- ---------------- ---------------- --------------- ------------- ------------ ------------"
   endif
 endif
elseif cKumul=="1"
 if cSazeta=="D"
   M:="------- -- ---- ---------- -------- -------- -------------- -------------- --------------"
 else
   if gNW=="N"
     M:="------- -- ---- ---- ---------------- ---------- -------- -------- -------------------- ---------------- ----------------- ---------------"
   else
     M:="------- -- ---- ---- ---------- -------- -------- -------------------- ---------------- ----------------- ----------------"
   endif
 endif
else
 if cSazeta=="D"
   M:="------- -- ---- ---------- -------- -------- -------------- -------------- -------------- -------------- ---------------"
 else
  if gNW=="N"
    M:="------- -- ---- ---- ---------------- ---------- -------- -------- -------------------- ---------------- ----------------- ---------------- ----------------- ---------------"
  else
    M:="------- -- ---- ---- ---------- -------- -------- -------------------- ---------------- ----------------- ---------------- ----------------- ----------------"
  endif
 endif
endif

lVrsteP:=.f.
IF IzFMKIni("FAKT","VrstePlacanja","N",SIFPATH)=="D"
  lVrsteP:=.t.
  O_VRSTEP
ENDIF

O_SUBAN
O_TDOK

select SUBAN
if cPoVezi=="D"
 //SUBANi3","IdFirma+IdKonto+IdPartner+BrDok+dtos(DatDok)",KUMPATH+"SUBAN")
 set order to 3
endif

if ck1=="9"; ck1:=""; endif
if ck2=="9"; ck2:=""; endif
if ck3==REPL("9",LEN(cK3))
  ck3:=""
else
  cK3 := K3U256(cK3)
endif
if ck4=="99"; ck4:=""; endif

private cFilter

cFilter := ".t."+IF(EMPTY(dDatOd),"",".and.DATDOK>="+cm2str(dDatOd))+;
           IF(EMPTY(dDatDo),"",".and.DATDOK<="+cm2str(dDatDo))

if ! ( fk1=="N" .and. fk2=="N" .and. fk3=="N" .and. fk4=="N" )
  cFilter := cFilter + ".and.k1="+cm2str(ck1)+".and.k2="+cm2str(ck2)+;
                       ".and.k3=ck3.and.k4="+cm2str(ck4)
endif

if ";" $ qqpartner
  qqPartner:=strtran(qqpartner,";","")
  cFilter+=".and. idpartner='"+trim(qqpartner)+"'"
  qqpartner:=""
endif

cFilter:=STRTRAN(cFilter,".t..and.","")

if cfilter==".t."
  set filter to
else
  set filter to &cFilter
endif
   //HSEEK cIdFirma+qqKonto+qqPartner


nStr:=0

if empty(qqpartner)
  qqPartner:=trim(qqpartner)
endif

SEEK cidfirma+qqkonto+qqpartner
if !found() // nema na 1200
  SEEK cidfirma+qqkonto2+qqpartner
endif

NFOUND CRET

START PRINT CRET


nSviD:=nSviP:=nSviD2:=nSviP2:=0

nKonD:=nKonP:=nKonD2:=nKonP2:=0
cIdKonto:=IdKonto

nProlaz:=0

if empty(qqpartner)  // prodji tri puta
   nProlaz:=1
   HSEEK cidfirma+qqkonto
   if eof()
     nProlaz:=2
     HSEEK cidfirma+qqkonto2
   endif
endif

do while .t.

if !eof() .and. idfirma==cidfirma .and. ;
   ( (nProlaz=0 .and. (idkonto==qqkonto .or. idkonto==qqkonto2))  .or. ;
     (nProlaz=1 .and. idkonto=qqkonto) .or. ;
     (nProlaz=2 .and. idkonto=qqkonto2) ;
   )
else
  exit
endif


    nPDugBHD:=nPPotBHD:=nPDugDEM:=nPPotDEM:=0  // prethodni promet
    nDugBHD:=nPotBHD:=nDugDEM:=nPotDEM:=0
    nZDugBHD:=nZPotBHD:=nZDugDEM:=nZPotDEM:=0
    cIdPartner:=IdPartner


    fZaglavlje:=.f.
    fProsao:=.f.
    do whilesc !eof() .and. IdFirma==cIdFirma .and. cIdPartner==idpartner .and. (idkonto==qqkonto .or. idkonto==qqkonto2)

          cIdKonto:=idkonto
          cOtvSt:=OtvSt
          if !(fOtvSt .and. cOtvSt=="9")
              fprosao:=.t.
              if !fzaglavlje
                 if prow()>55+gpstranica
                   FF; ZaglSif2(.t.)
                 else
                   ZaglSif2(iif(nstr=0,.t.,.f.))
                 endif
                 fzaglavlje:=.t.
              endif
              ? cidkonto,IdVN; @ prow(),pcol()+1 SAY BrNal
              if cSazeta=="N"
                @ prow(),pcol()+1 SAY RBr
                if gNW=="N"
                  @ prow(),pcol()+1 SAY IdTipDok
                  SELECT TDOK; HSEEK SUBAN->IdTipDok
                  @ prow(),pcol()+1 SAY naz
                endif
              endif
              SELECT SUBAN
              @ prow(),pcol()+1 SAY padr(BrDok,10)
              @ prow(),pcol()+1 SAY DatDok
              If ck14=="1"
                @ prow(),pcol()+1 SAY k1+"-"+k2+"-"+K3Iz256(k3)+k4
              elseif ck14=="2"
                @ prow(),pcol()+1 SAY DatVal
              else
                nC7:=pcol()+1
                @ prow(),nc7 SAY DatVal
              endif

              if cSazeta=="N"
               if cDinDem=="3"
                nSirOp:=16; nCOpis:=pcol()+1
                @ prow(),pcol()+1 SAY left(cOpis:=ALLTRIM(Opis),16)
               else
                nSirOp:=20; nCOpis:=pcol()+1
                @ prow(),pcol()+1 SAY PADR(cOpis:=ALLTRIM(Opis),20)
               endif
              endif

              nC1:=pcol()+1
          endif // fOtvStr

          nDBHD:=nPBHD:=nDDEM:=nPDEM:=0
          if cPovezi=="D"
             cBrDok:=brdok
             do whilesc !eof() .and. IdFirma==cIdFirma .and. cIdpartner==idpartner .and. (idkonto==qqkonto .or. idkonto==qqkonto2) .and. brdok==cBrdok
                IF D_P=="1"
                  nDBHD+=iznosbhd
                  nDDEM+=iznosdem
                ELSE
                  nPBHD+=iznosbhd
                  nPDEM+=iznosdem
                endif
                skip
             enddo
             if cPrelomljeno=="D"
                 Prelomi(@nDBHD,@nPBHD)
                 Prelomi(@nDDEM,@nPDEM)
             endif
          else
             IF D_P=="1"
               nDBHD+=iznosbhd; nDDEM+=iznosdem
             ELSE
               nPBHD+=iznosbhd; nPDEM+=iznosdem
             endif
          endif
          if cDinDem=="1"
           if fOtvSt .and. cOtvSt=="9"
             nZDugBHD+=nDBHD
             nZPotBHD+=nPBHD
           else // otvorena stavka
             @ prow(),pcol()+1 SAY nDBHD PICTURE picBHD
             @ prow(),pcol()+1 SAY nPBHD  PICTURE picBHD
             nDugBHD+=nDBHD
             nPotBHD+=nPBHD
             if cKumul=="2"   // prikaz kumulativa
               @ prow(),pcol()+1 SAY nDugBHD pict picbhd
               @ prow(),pcol()+1 SAY nPotBHD pict picbhd
             endif
           endif
          elseif cDinDem=="2"   // devize

           if fOtvSt .and. cOtvSt=="9"
            nZDugDEM+=nDDEM
            nZPotDEM+=nPDEM
           else  // otvorena stavka
            @ prow(),pcol()+1 SAY nDDEM PICTURE picbhd
            @ prow(),pcol()+1 SAY nPDEM PICTURE picbhd
            nDugDEM+=nDDEM
            nPotDEM+=nPDEM
             if cKumul=="2"   // prikaz kumulativa
               @ prow(),pcol()+1 SAY nDugDEM pict picbhd
               @ prow(),pcol()+1 SAY nPotDEM pict picbhd
             endif
            endif
          elseif cDinDem=="3"
           if fOtvSt .and. cOtvSt=="9"
            nZDugBHD+=nDBHD; nZDugDEM+=nDDEM
            nZPotBHD+=nPBHD; nZPotDEM+=nPDEM
           else  // otvorene stavke
            @ prow(),pcol()+1 SAY nDBHD PICTURE picBHD
            @ prow(),pcol()+1 SAY nPBHD PICTURE picBHD
            nDugBHD+=nDBHD
            nPotBHD+=nPBHD
            @ prow(),pcol()+1 SAY nDugBHD-nPotBHD pict picbhd

            @ prow(),pcol()+1 SAY nDDEM PICTURE picdem
            @ prow(),pcol()+1 SAY nPDEM PICTURE picdem
            nDugDEM+=nDDEM
            nPotDEM+=nPDEM
            @ prow(),pcol()+1 SAY nDugDEM-nPotDEM pict picdem
           endif
          endif

          if !(fOtvSt .and. cOtvSt=="9")
           ******** saldo ..........
           if cDinDem="1"
            @ prow(),pcol()+1 SAY nDugBHD-nPotBHD pict picbhd
           elseif cDinDem=="2"
            @ prow(),pcol()+1 SAY nDugDEM-nPotDEM pict picbhd
           endif

           OstatakOpisa(@cOpis,nCOpis,{|| IF(prow()>60+gPStranica,EVAL({|| gPFF(),ZaglSif2()}),)},nSirOp)
           if ck14=="3"
             @ prow()+1,nc7 SAY k1+"-"+k2+"-"+K3Iz256(k3)+k4
           endif
          endif
          OstatakOpisa(@cOpis,nCOpis,{|| IF(prow()>60+gPStranica,EVAL({|| gPFF(),ZaglSif2()}),)},nSirOp)
          if cPoVezi<>"D"
            SKIP
          endif
          if nprolaz=0 .or. nProlaz=1
            if (idkonto<>cidkonto .or. idpartner<>cIdpartner) .and. cidkonto==qqkonto
              hseek cidfirma+qqkonto2+cIdpartner
            endif
          endif

     enddo // konto

     if cNula=="D" .or. fprosao .or.   round(nZDugBHD-nZPotBHD,2)<>0

      if !fzaglavlje
         if prow()>55+gpstranica
           FF; ZaglSif2(.t.)
         else
           ZaglSif2(iif(nstr=0,.t.,.f.))
         endif
         fzaglavlje:=.t.
      endif
      ? M
      ? "UKUPNO:"

      if cDinDem=="1"
       @ prow(),nC1      SAY nDugBHD PICTURE picBHD
       @ prow(),pcol()+1 SAY nPotBHD PICTURE picBHD
       if cKumul=="2"
        @ prow(),pcol()+1 SAY nDugBHD pict picbhd
        @ prow(),pcol()+1 SAY nPotBHD pict picbhd
       endif
       @ prow(),pcol()+1 SAY nDugBHD-nPotBHD pict picbhd
      elseif cDinDem=="2"
       @ prow(),nC1      SAY nDugDEM PICTURE picBHD
       @ prow(),pcol()+1 SAY nPotDEM PICTURE picBHD
       if cKumul=="2"
        @ prow(),pcol()+1 SAY nDugDEM pict picbhd
        @ prow(),pcol()+1 SAY nPotDEM pict picbhd
       endif
       @ prow(),pcol()+1 SAY nDugDEM-nPotDEM pict picbhd
      elseif  cDinDem=="3"
       @ prow(),nC1      SAY nDugBHD PICTURE picBHD
       @ prow(),pcol()+1 SAY nPotBHD PICTURE picBHD
       @ prow(),pcol()+1 SAY nDugBHD-nPotBHD pict picbhd

       @ prow(),pcol()+1      SAY nDugDEM PICTURE picdem
       @ prow(),pcol()+1 SAY nPotDEM PICTURE picdem
       @ prow(),pcol()+1 SAY nDugDEM-nPotDEM pict picdem
      endif


      if fOtvST
       ? "Promet zatvorenih stavki:"
       if cDinDem=="1"
          @ prow(),nC1      SAY nZDugBHD PICTURE picBHD
          @ prow(),pcol()+1 SAY nZPotBHD PICTURE picBHD
          if cKumul=="2"
           @ prow(),pcol()+1 SAY nZDugBHD pict picbhd
           @ prow(),pcol()+1 SAY nZPotBHD pict picbhd
          endif
          @ prow(),pcol()+1 SAY nZDugBHD-nZPotBHD pict picbhd
       elseif cDinDem=="2"
          @ prow(),nC1      SAY nZDugDEM PICTURE picBHD
          @ prow(),pcol()+1 SAY nZPotDEM PICTURE picBHD
          if cKumul=="2"
           @ prow(),pcol()+1 SAY nZDugDEM pict picbhd
           @ prow(),pcol()+1 SAY nZPotDEM pict picbhd
          endif
          @ prow(),pcol()+1 SAY nZDugDEM-nZPotDEM pict picbhd
       elseif  cDinDem=="3"
          @ prow(),nC1      SAY nZDugBHD PICTURE picBHD
          @ prow(),pcol()+1 SAY nZPotBHD PICTURE picBHD
          @ prow(),pcol()+1 SAY nZDugBHD-nZPotBHD pict picbhd

          @ prow(),pcol()+1 SAY nZDugDEM PICTURE picdem
          @ prow(),pcol()+1 SAY nZPotDEM PICTURE picdem
          @ prow(),pcol()+1 SAY nZDugDEM-nZPotDEM pict picdem
       endif
      endif

      ? m
     endif // fprosao

     nKonD+=nDugBHD;  nKonP+=nPotBHD
     nKonD2+=nDugDEM; nKonP2+=nPotDEM

  if nProlaz=0
     exit
  elseif nprolaz==1
     seek cidfirma+qqkonto+cidpartner+chr(255)
     if qqkonto<>idkonto // nema vise
        nProlaz:=2
        seek cidfirma+qqkonto2
        cIdpartner:=replicate("",len(idpartner))
        if !found()
          exit
        endif
     endif
  endif


  if nprolaz==2
      do while .t.
       seek cidfirma+qqkonto2+cidpartner+chr(255)
       nTRec:=recno()
       if idkonto==qqkonto2
         cIdPartner:=idpartner
         hseek cidfirma+qqkonto+cIdpartner
         if !found() // ove kartice nije bilo
            go nTRec
            exit
         else
            loop  // vrati se traziti
         endif
       endif
       exit
      enddo
  endif

  ?
  ?
  ?
enddo
FF
END PRINT
#ifndef CAX
closeret
#endif
return
*}



/*! \fn ZaglSif2(fStrana)
 *  \brief Zaglavlje subanaliticke kartice 2
 *  \param fStrana
 */
 
function ZaglSif2(fStrana)
*{
if cDinDem=="3"  .or. cKumul=="2"
  P_COND2
else
  P_COND
endif

if fOtvSt
 ?? "FIN: KARTICA OTVORENIH STAVKI KONTO/KONTO2 "
else
 ?? "FIN: SUBANALITICKA KARTICA  ZA "
endif

?? iif(cDinDem=="1",ALLTRIM(ValDomaca()),iif(cDinDem=="2",ALLTRIM(ValPomocna()),ALLTRIM(ValDomaca())+"-"+ALLTRIM(ValPomocna())))," NA DAN:",DATE()
if !(empty(dDatOd) .and. empty(dDatDo))
    ?? "   ZA PERIOD OD",dDatOd,"DO",dDatDo
endif
if fstrana
 @ prow(),125 SAY "Str."+str(++nStr,5)
endif

if gNW=="D"
 ? "Firma:",gFirma,"-",gNFirma
else
 SELECT PARTN; HSEEK cIdFirma
 ? "Firma:",cIdFirma,partn->naz,partn->naz2
endif


SELECT PARTN; HSEEK cIdPartner
? "PARTNER:",cIdPartner,partn->naz,partn->naz2

SELECT SUBAN

if cDinDem=="3"
 if cSazeta=="D"
  ?  "------- -------- --------------------------- ---------------------------- -------------- -------------------------- ------------"
  ?  "*KONTO * NALOG *     D O K U M E N T        *      PROMET  "+ValDomaca()+"          *    SALDO     *       PROMET  "+ValPomocna()+"       *   SALDO   *"
  ?  "*       ------- ------------------- -------- -----------------------------     "+ValDomaca()+"     * -------------------------    "+ValPomocna()+"    *"
  ?  "*      * V.* BR *   BROJ   * DATUM  *"+iif(cK14=="1"," K1-K4 "," VALUTA")+;
                                       "*     DUG     *      POT     *              *      DUG    *   POT      *           *"
  ?  "*      * N.*    *          *        *       *                            *              *             *            *           *"
 else
  if gNW=="N"
   ?  "------- ------------ -------------------------------------------------------------- --------------------------------- -------------- -------------------------- --------------"
   ?  "*KONTO *   NALOG    *                    D  O  K  U  M  E  N  T                    *          PROMET  "+ValDomaca()+"           *    SALDO     *       PROMET  "+ValPomocna()+"       *   SALDO     *"
   ?  "*       ------------ ------------------------------------ -------- ---------------- ----------------------------------      "+ValDomaca()+"    * --------------------------    "+ValPomocna()+"     *"
   ?  "*      * V.*BR * R. *     TIP I      *   BROJ   *  DATUM *"+iif(cK14=="1"," K1-K4  "," VALUTA ")+"*    OPIS        *     DUG       *       POT       *              *      DUG    *   POT      *             *"
   ?  "*      * N.*   * Br.*     NAZIV      *          *        *        *                *               *                 *              *             *            *             *"
  else
   ?  "------- ------------ --------------------------------------------- --------------------------------- -------------- -------------------------- -------------"
   ?  "*KONTO *   NALOG    *           D O K U M E N T                   *          PROMET  "+ValDomaca()+"           *    SALDO     *       PROMET  "+ValPomocna()+"       *   SALDO     *"
   ?  "*       ------------ ------------------- -------- ---------------- ----------------------------------      "+ValDomaca()+"    * --------------------------    "+ValPomocna()+"     *"
   ?  "*      * V.*BR * R. *   BROJ   *  DATUM *"+iif(cK14=="1"," K1-K4  "," VALUTA ")+"*    OPIS        *     DUG       *       POT       *              *      DUG    *   POT      *             *"
   ?  "*      * N.*   * Br.*          *        *        *                *               *                 *              *             *            *             *"
  endif
 endif
elseif cKumul=="1"
 if cSazeta=="D"
  ?  "------- -------- ---------------------------- --------------------------- ---------------"
  ?  "*KONTO *  NALOG *      D O K U M E N T       *       P R O M E T         *    SALDO      *"
  ?  "*       -------- ------------------- -------- ---------------------------                *"
  ?  "*      * V.*BR  *   BROJ   *  DATUM *"+iif(cK14=="1"," K1-K4  "," VALUTA ")+"*    DUGUJE   *   POTRA各JE  *              *"
  ?  "*      * N.*    *          *        *        *            *              *               *"
 else
  if gNW=="N"
   ?  "------- ------------ ------------------------------------------------------------------ ---------------------------------- ----------------"
   ?  "*KONTO *   NALOG    *                    D  O  K  U  M  E  N  T                        *           P R O M E T            *    SALDO      *"
   ?  "*       ------------ ------------------------------------ -------- -------------------- ----------------------------------                *"
   ?  "*      * V.*BR * R. *     TIP I      *   BROJ   *  DATUM *"+iif(cK14=="1"," K1-K4  "," VALUTA ")+"*    OPIS            *    DUGUJE     *    POTRA各JE     *               *"
   ?  "*      * N.*   * Br.*     NAZIV      *          *        *        *                    *               *                  *               *"
  else
   ?  "------- ------------ ------------------------------------------------- ---------------------------------- ---------------"
   ?  "*KONTO *   NALOG    *              D  O  K  U  M  E  N  T             *           P R O M E T            *    SALDO      *"
   ?  "*       ------------ ------------------- -------- -------------------- ----------------------------------                *"
   ?  "*      * V.*BR * R. *   BROJ   *  DATUM *"+iif(cK14=="1"," K1-K4  "," VALUTA ")+"*    OPIS            *    DUGUJE     *    POTRA各JE     *               *"
   ?  "*      * N.*   * Br.*          *        *        *                    *               *                  *               *"
  endif
 endif
else
 if cSazeta=="D"
  ?  "------- ------- ---------------------------- --------------------------- ------------------------------ ---------------"
  ?  " KONTO * NALOG *      D O K U M E N T       *        P R O M E T        *      K U M U L A T I V       *    SALDO     *"
  ?  "        ------- -------------------- -------- --------------------------- ------------------------------              *"
  ?  "       * V.*BR *   BROJ   *  DATUM *"+iif(cK14=="1"," K1-K4  "," VALUTA ")+"*   DUGUJE    *  POTRAZUJE   *    DUGUJE    *  POTRAZUJE   *              *"
  ?  "       *       *          *        *        *             *              *              *              *              *"
 else
  if gNW=="N"
   ?  "------- ------------ ------------------------------------------------------------------ ---------------------------------- ---------------------------------- ---------------"
   ?  "*KONTO *   NALOG    *                    D  O  K  U  M  E  N  T                        *           P R O M E T            *           K U M U L A T I V      *    SALDO     *"
   ?  "*       ------------ ------------------------------------ -------- -------------------- ---------------------------------- ----------------------------------               *"
   ?  "*      * V.*BR * R. *     TIP I      *   BROJ   *  DATUM *"+iif(cK14=="1"," K1-K4  "," VALUTA ")+"*    OPIS            *    DUGUJE     *    POTRA各JE     *    DUGUJE     *    POTRA各JE     *              *"
   ?  "*      * N.*   * Br.*     NAZIV      *          *        *        *                    *               *                  *               *                  *              *"
  else
   ?  "------- ------------ ------------------------------------------------- ---------------------------------- ---------------------------------- ----------------"
   ?  "*KONTO *   NALOG    *            D O K U M E N T                      *           P R O M E T            *           K U M U L A T I V      *    SALDO      *"
   ?  "*       ------------ ------------------- -------- -------------------- ---------------------------------- ----------------------------------                *"
   ?  "*      * V.*BR * R. *   BROJ   *  DATUM *"+iif(cK14=="1"," K1-K4  "," VALUTA ")+"*    OPIS            *    DUGUJE     *    POTRAZUJE     *    DUGUJE     *    POTRA各JE     *               *"
   ?  "*      * N.*   * Br.*          *        *        *                    *               *                  *               *                  *               *"
  endif
 endif
endif
? m

RETURN
*}



/*! \fn V_Firma(cIdFirma)
 *  \brief Validacija firme - unesi firmu po referenci
 *  \param cIdfirma  - id firme
 */
 
function V_Firma(cIdFirma)
*{
P_Firma(@cIdFirma)
cIdFirma:=trim(cIdFirma)
cIdFirma:=left(cIdFirma,2)
return .t.
*}



/*! \fn Prelomi(nDugX,nPotX)
 *  \brief 
 *  \param nDugX
 *  \param nPotX 
 */
 
function Prelomi(nDugX,nPotX)
*{
if (ndugx-npotx)>0
   nDugX:=nDugX-nPotX
   nPotX:=0
else
   nPotX:=nPotX-nDugX
   nDugX:=0
endif
return
*}


