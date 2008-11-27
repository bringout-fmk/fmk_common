#include "ld.ch"


// -------------------------------------------------
// nova varijanta kartica plate
// -------------------------------------------------
function kartpl2( cIdRj, cMjesec, cGodina, cIdRadn, cObrac, aNeta )
local nKRedova
local cDoprSpace := SPACE(3)
local cTprLine 
local cDoprLine 
local cMainLine 
private cLMSK := ""	

cTprLine := _gtprline()
cDoprLine := _gdoprline(cDoprSpace)
cMainLine := _gmainline()

// koliko redova ima kartica
nKRedova := kart_redova()

Eval(bZagl)

if gTipObr == "2" .and. parobr->k1 <> 0
	?? Lokal("        Bod-sat:")
	@ prow(),pcol()+1 SAY parobr->vrbod/parobr->k1*brbod pict "99999.99999"
endif

IF l2kolone
	
	P_COND2
	// aRCPos  := { PROW() , PCOL() }
	cDefDev := SET(_SET_PRINTFILE)
	SvratiUFajl()
	// SETPRC(0,0)
ENDIF

? cTprLine
? cLMSK+ Lokal(" Vrsta                  Opis         sati/iznos             ukupno")
? cTprLine

cUneto := "D"
nRRsati := 0 

nOsnNeto := 0
nOsnOstalo := 0

for i:=1 to cLDPolja
	
	cPom := padl(alltrim(str(i)),2,"0")
	
	select tippr
	seek cPom
	
	if tippr->uneto=="N" .and. cUneto=="D"
		
		cUneto:="N"
		
		? cTprLine
		? cLMSK+Lokal("Ukupna primanja u netu:")
		@ prow(),nC1+8  SAY  _USati  pict gpics
		?? SPACE(1) + Lokal("sati")
		@ prow(),60+LEN(cLMSK) SAY _UNeto pict gpici
		?? "",gValuta
		? cTprLine
	
	endif
	
	if tippr->(found()) .and. tippr->aktivan=="D"

		if _i&cpom<>0 .or. _s&cPom<>0
			
			// uvodi se djoker # : Primjer: Naziv tipa primanja
			// je: REDOVAN RAD BOD #RADN->N1 -> naci RADN->N1
			// i ispisati REDOVAN RAD BOD 12.0
			
			nDJ:=at("#",tippr->naz)
			cTPNaz:=tippr->naz
			
			if nDJ<>0
				
				RSati:=_s&cPom
				
				@ prow(),60+LEN(cLMSK) SAY _i&cPom * parobr->k3/100 pict gpici
				@ prow()+1,0 SAY Lokal("Odbici od bruta: ")
				@ prow(), pcol()+48 SAY "-" + ALLTRIM(STR((_i&cPom * (parobr->k3)/100)-_i&cPom))
				if type(cDJ)="C"
					cTPNaz:=left(tippr->naz,nDJ-1)+&cDJ
				elseif type(cPom)="N"
					cTPNAZ:=left(tippr->naz,nDJ-1)+alltrim(str(&cDJ))
				endif
			endif
			
			? cLMSK+tippr->id+"-"+padr(cTPNAZ,len(tippr->naz)),tippr->opis
			nC1:=pcol()
			
			if tippr->fiksan $ "DN"
				
				@ prow(),pcol()+8 SAY _s&cPom  pict gpics
				?? " s"
				
				if tippr->id=="01" .and. lRadniSati
					nRRSati:=_s&cPom
					@ prow(),60+LEN(cLMSK) SAY _i&cPom * parobr->k3/100 pict gpici
					@ prow()+1,0 SAY Lokal("Odbici od bruta: ")
					@ prow(), pcol()+48 SAY "-" + ALLTRIM(STR((_i&cPom * (parobr->k3)/100)-_i&cPom))
				else
					@ prow(),60+LEN(cLMSK) say _i&cPom pict gpici
				endif
			
			elseif tippr->fiksan=="P"
				
				@ prow(),pcol()+8 SAY _s&cPom  pict "999.99%"
				@ prow(),60+LEN(cLMSK) say _i&cPom        pict gpici
			elseif tippr->fiksan=="B"
				
				@ prow(),pcol()+8 SAY _s&cPom  pict "999999"; ?? " b"
				@ prow(),60+LEN(cLMSK) say _i&cPom        pict gpici
			elseif tippr->fiksan=="C"
				
				@ prow(),60+LEN(cLMSK) say _i&cPom        pict gpici
			endif
			
			if tippr->(FIELDPOS("TPR_TIP")) <> 0
			  // uzmi osnovice
			  if tippr->tpr_tip == "N"
				nOsnNeto += _i&cPom
			  elseif tippr->tpr_tip == "2"
				nOsnOstalo += _i&cPom
			  elseif tippr->tpr_tip == " "
				// standardni tekuci sistem
				if tippr->uneto == "D"
					nOsnNeto += _i&cPom
				else
					nOsnOstalo += _i&cPom
				endif
			  endif
			else
				// standardni tekuci sistem
				if tippr->uneto == "D"
					nOsnNeto += _i&cPom
				else
					nOsnOstalo += _i&cPom
				endif
			endif
			
			if "SUMKREDITA" $ tippr->formula .and. gReKrKP=="1"
				
				IF l2kolone
					P_COND2
				ELSE
					P_COND
				ENDIF
				
				? cTprLine
				? cLMSK+"  ",Lokal("Od toga pojedinacni krediti:")
				select radkr
				set order to 1
				seek str(_godina,4)+str(_mjesec,2)+_idradn
				do while !eof() .and. _godina==godina .and. _mjesec=mjesec .and. idradn==_idradn
					select kred
					hseek radkr->idkred
					select radkr
					? cLMSK+"  ",idkred,left(kred->naz,22),naosnovu
					@ prow(),58+LEN(cLMSK) SAY iznos pict "("+gpici+")"
					skip 1
				enddo
				
				? cTprLine
				
				IF l2kolone
					P_COND2
				ELSE
					P_12CPI
				ENDIF
				
				select ld
				
			elseif "SUMKREDITA" $ tippr->formula
				
				select radkr
				set order to 1
				seek str(_godina,4) + str(_mjesec,2) + _idradn
				ukredita:=0
				
				IF l2kolone
					P_COND2
				ELSE
					P_COND
				ENDIF
				
				? m2:=cLMSK+"   ------------------------------------------------  --------- --------- -------"
				?     cLMSK+Lokal("        Kreditor      /              na osnovu         Ukupno    Ostalo   Rata")
				? m2
				
				do while !eof() .and. _godina==godina .and. _mjesec=mjesec .and. idradn==_idradn
					select kred
					hseek radkr->idkred
					select radkr
					aIznosi:=OKreditu(idradn, idkred, naosnovu, _mjesec, _godina)
					? cLMSK+" ",idkred,left(kred->naz,22),PADR(naosnovu,20)
					@ prow(),pcol()+1 SAY aIznosi[1] pict "999999.99" // ukupno
					@ prow(),pcol()+1 SAY aIznosi[1]-aIznosi[2] pict "999999.99"// ukupno-placeno
					@ prow(),pcol()+1 SAY iznos pict "9999.99"
					ukredita+=iznos
					skip 1
				enddo
				
				IF l2kolone
					P_COND2
				ELSE
					P_12CPI
				ENDIF
				
				select ld
			endif
		endif
	endif
next

if cVarijanta=="5"

	// select ldsm
	
	select ld
	PushWA()
	set order to tag "2"
	hseek str(_godina,4)+str(_mjesec,2)+"1"+_idradn+_idrj
	// hseek "1"+str(_godina,4)+str(_mjesec,2)+_idradn+_idrj
	?
	? cLMSK+Lokal("Od toga 1. dio:")
	@ prow(),60+LEN(cLMSK) SAY UIznos pict gpici
	? cTprLine
	hseek str(_godina,4)+str(_mjesec,2)+"2"+_idradn+_idrj
	// hseek "2"+str(_godina,4)+str(_mjesec,2)+_idradn+_idrj
	? cLMSK+Lokal("Od toga 2. dio:")
	@ prow(),60+LEN(cLMSK) SAY UIznos pict gpici
	? cTprLine
	select ld
	PopWA()
endif

if lRadniSati
	? Lokal("NAPOMENA: Ostaje da se plati iz preraspodjele radnog vremena ")
	?? ALLTRIM(STR((ld->radsat)-nRRSati))  + Lokal(" sati.")
	? Lokal("          Uplaceno za tekuci mjesec: " + " sati.")
	? Lokal("          Ostatak predhodnih obracuna: ") + GetStatusRSati(cIdRadn) + SPACE(1) + Lokal("sati")
	?
endif

if gPrBruto=="D"  
	
	// prikaz bruto iznosa
	
	select (F_POR)
	
	if !used()
		O_POR
	endif
	
	select (F_DOPR)
	
	if !used()
		O_DOPR
	endif
	
	select (F_KBENEF)
	
	if !used()
		O_KBENEF
	endif

	nBO:=0
	nBFO:=0
	
	nOsnZaBr := nOsnNeto

	nBo := round2( nOsnZaBr * parobr->k5  , gZaok2 )

	if UBenefOsnovu()
		nBFo := round2( ((( nOsnZaBr )-(&gBFForm)) * parobr->k5 ), gZaok2 )
	endif

	// bruto placa iz neta...

	? cMainLine
	? cLMSK + "1. BRUTO PLACA :  ", ;
	        ALLTRIM(STR(nOsnZaBr)) + " * " + ;
		ALLTRIM(STR(parobr->k5))

	@ prow(),60+LEN(cLMSK) SAY nBo pict gpici
	
	? cMainLine
	
	IF lSkrivena
		? cMainLine
	ELSE
		?
	ENDIF
	
	// razrada doprinosa ....
	
	? cLmSK + cDoprSpace + Lokal("Obracun doprinosa:")
	
	select dopr
	go top
	
	nPom := 0
	nDopr := 0
	nUkDoprIz := 0
	nC1 := 20 + LEN(cLMSK)
	
	do while !eof()
		
		if dopr->(FIELDPOS("DOP_TIP")) <> 0
			
			if dopr->dop_tip == "N" .or. dopr->dop_tip == " " 
				nOsn := nOsnNeto
			elseif dopr->dop_tip == "2"
				nOsn := nOsnOstalo
			elseif dopr->dop_tip == "P"
				nOsn := nOsnNeto + nOsnOstalo
			endif
		
		endif
		
		PozicOps(DOPR->poopst)
			
		// preskoci zbirne doprinose
		if LEFT( dopr->id, 1 ) <> "1"
			skip
			loop 
		endif

		IF !ImaUOp("DOPR",DOPR->id) .or. !lPrikSveDopr .and. !DOPR->ID $ cPrikDopr
			SKIP 1
			LOOP
		ENDIF
		
		if right(id,1)=="X"
			? cDoprLine
		endif
		
		if ("BENEF" $ dopr->naz .and. nBFO == 0)
			skip
			loop
		endif
		
		? cLMSK + cDoprSpace + id, "-", naz
		@ prow(),pcol()+1 SAY iznos pict "99.99%"
		
		if empty(idkbenef) 
			// doprinos udara na neto
			if ("BENEF" $ dopr->naz .and. nBFO <> 0)
				@ prow(),pcol()+1 SAY nBFO pict gpici
				nC1:=pcol()+1
				@ prow(),pcol()+1 SAY nPom:=max(dlimit,round(iznos/100*nBFO,gZaok2)) pict gpici
			else
				@ prow(),pcol()+1 SAY nBo pict gpici
				nC1:=pcol()+1
				@ prow(),pcol()+1 SAY nPom:=max(dlimit,round(iznos/100*nBO,gZaok2)) pict gpici
			endif
			
			if dopr->id == "1X"
				nUkDoprIz += nPom
			endif

		else
			nPom0:=ASCAN(aNeta,{|x| x[1]==idkbenef})
			if nPom0<>0
				nPom2:=parobr->k3/100*aNeta[nPom0,2]
			else
				nPom2:=0
			endif
			if round(nPom2,gZaok2)<>0
				@ prow(),pcol()+1 SAY nPom2 pict gpici
				nC1:=pcol()+1
				nPom:=max(dlimit,round(iznos/100*nPom2,gZaok2))
				@ prow(),pcol()+1 SAY nPom pict gpici
			endif
		endif
		
		if right(id,1)=="X"
			
			? cDoprLine
			?
			nDopr += nPom
		
		endif
		
		if !lSkrivena .and. prow()>57+gPStranica
			FF
		endif
		
		skip 1
		
	enddo


	nOporDoh := nBo - nUkDoprIz

	// oporezivi dohodak ......
	
	? cMainLine
	?  cLMSK + Lokal("2. OPOREZIVI DOHODAK ( bruto - dopr.IZ )")
	@ prow(),60+LEN(cLMSK) SAY nOporDoh pict gpici
	? cMainLine
	
	// razrada licnog odbitka ....
	
	nLicOdbitak := g_licni_odb( radn->id )
	nKoefOdbitka := radn->klo

	? cLMSK + Lokal("3. LICNI ODBITAK"), SPACE(14) + ;
		ALLTRIM(STR(gOsnLOdb)) + " * koef. " + ;
		ALLTRIM(STR(nKoefOdbitka)) + " = "
	@ prow(),60+LEN(cLMSK) SAY nLicOdbitak pict gpici

	? cMainLine

	nPorOsnovica := ( nOporDoh - nLicOdbitak )

	?  cLMSK + Lokal("4. OSNOVICA POREZA NA DOHODAK (2 - 3)")
	@ prow(),60+LEN(cLMSK) SAY nPorOsnovica pict gpici

	? cMainLine

	// razrada poreza na platu ....
	// u ovom dijelu idu samo porezi na bruto TIP = "B"

	? cLMSK + Lokal("5. AKONTACIJA POREZA NA DOHODAK")

	select por
	go top
	
	nPom:=0
	nPor:=0
	nC1:=30 + LEN(cLMSK)
	nPorOl:=0
	
	do while !eof()
	
		// vrati algoritam poreza
		cAlgoritam := get_algoritam()
		
		PozicOps( POR->poopst )
		
		IF !ImaUOp("POR",POR->id)
			SKIP 1
			LOOP
		ENDIF
		
		// sracunaj samo poreze na bruto
		if por->por_tip <> "B"
			skip 
			loop
		endif
	
		// obracunaj porez
		aPor := obr_por( por->id, nPorOsnovica, 0 )
		
		// ispisi porez
		nPor += isp_por( aPor, cAlgoritam, cLMSK, .t., .t. )
		
		skip 1
	enddo

	@ prow(),60+LEN(cLMSK) SAY nPor pict gpici

	// ostala primanja 
	? cMainLine
	? cLMSK + Lokal("6. UKUPNO OSTALA PRIMANJA")

	@ prow(),60+LEN(cLMSK) SAY nOsnOstalo pict gpici


	// ukupno za isplatu ....
	nZaIsplatu := ( nOporDoh - nPor ) + nOsnOstalo
	
	?

	? cMainLine
	?  cLMSK + Lokal("UKUPNO ZA ISPLATU ( 2 - 5 + 6 )")
	@ prow(),60+LEN(cLMSK) SAY nZaIsplatu pict gpici

	? cMainLine

	if !lSkrivena .and. prow()>55+gPStranica
		FF
	endif

	?
	
	// if prow()>31
	if gPotp <> "D"
		if pcount()==0
			FF
		endif
	endif
	
endif

if l2kolone
	SET PRINTER TO (cDefDev) ADDITIVE
	// SETPRC(aRCPos[1],aRCPos[2])
	altd()
	IF PROW()+2+nDMSK>nKRSK*(2-(nRBrKart%2))
		aTekst:=U2Kolone(PROW()+2+nDMSK-nKRSK*(2-(nRBrKart%2)))
		FOR i:=1 TO LEN(aTekst)
			IF i==1
				?? aTekst[i]
			ELSE
				? aTekst[i]
			ENDIF
		NEXT
		SETPRC(nKRSK*(2-(nRBrKart%2))-2-nDMSK,PCOL())
	ELSE
		PRINTFILE(PRIVPATH+"xoutf.txt")
	ENDIF
endif

// potpis na kartici
kart_potpis()

// obrada sekvence za kraj papira

// skrivena kartica
if lSkrivena
	if prow()<nKRSK+5
		nPom:=nKRSK-PROW()
		FOR i:=1 TO nPom
			?
		NEXT
	else
		FF
	endif
// 2 kartice na jedan list N - obavezno FF
elseif c2K1L == "N"
	FF
// ako je prikaz bruto D obavezno FF
elseif gPrBruto == "D"
	FF
// nova kartica novi list - obavezno FF
elseif lNKNS
	FF
// druga kartica takodjer FF
elseif (nRBRKart%2 == 0) 
	FF
// prva kartica, ali druga ne moze stati
elseif (nRBRKart%2 <> 0) .and. (DUZ_STRANA - prow() < nKRedova )
	--nRBRKart
	FF
endif

return


