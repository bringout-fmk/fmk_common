#include "\dev\fmk\ld\ld.ch"

static DUZ_STRANA:=64


// kartica plate radnika
function KartPl(cIdRj, cMjesec, cGodina, cIdRadn, cObrac)
local i
local aNeta:={}

lSkrivena:=.f.
cLMSK:=""

l2kolone:=.f.
lRadniSati:=IzFmkIni("LD","RadniSati","N",KUMPATH)=="D"

if (IzFMKIni("LD","SkrivenaKartica","N",KUMPATH)=="D" .and. Pitanje(,"Stampati u formi skrivene kartice? (D/N)","D")=="D")
	lSkrivena:=.t.
	cLMSK:=SPACE(VAL(IzFMKINI("SkrivenaKartica","LMarginaKolona","10",KUMPATH)))
	nIZRSK:=VAL(IzFMKINI("SkrivenaKartica","IspodZaglavljaRedova","4",KUMPATH))
	nPZRSK:=VAL(IzFMKINI("SkrivenaKartica","PrijeZaglavljaRedova","2",KUMPATH))
	nKRSK:=VAL(IzFMKINI("SkrivenaKartica","KarticaRedova","52",KUMPATH))
	nDMSK:=VAL(IzFMKINI("SkrivenaKartica","DMarginaRedova","5",KUMPATH))
	l2kolone:=(IzFMKINI("SkrivenaKartica","Dvokolonski","D",KUMPATH)=="D")
endif

cVarSort:="1"

private cNKNS
cNKNS:="N"

if (PCount()<4)
	cIdRadn:=SPACE(_LR_)
	cIdRj:=gRj
	cMjesec:=gMjesec
	cGodina:=gGodina
	cObracun:=gObracun
	O_PAROBR
	O_RJ
	O_RADN
	O_VPOSLA
	O_RADKR
	O_KRED
	O_LD
else
	cObracun:=cObrac
endif

if lRadniSati
	O_RADSAT
endif

private nC1:=20+LEN(cLMSK)

cVarijanta:=" "
c2K1L:="D"

if (PCount()<4)
	O_PARAMS
	private cSection:="4"
	private cHistory:=" "
	private aHistory:={}
	RPar("VS",@cVarSort)
	RPar("2K",@c2K1L)
	RPar("NK",@cNKNS)
	cIdRadn:=SPACE(_LR_)
	Box(,8,75)
	@ m_x+1,m_y+2 SAY Lokal("Radna jedinica (prazno-sve rj): ")  GET cIdRJ valid empty(cidrj) .or. P_RJ(@cidrj)
	@ m_x+2,m_y+2 SAY Lokal("Mjesec: ") GET cMjesec pict "99"
	if lViseObr
		@ m_x+2,col()+2 SAY Lokal("Obracun: ") GET cObracun WHEN HelpObr(.t.,cObracun) VALID ValObr(.t.,cObracun)
	endif
	@ m_x+3,m_y+2 SAY Lokal("Godina: ") GET cGodina pict "9999"
	@ m_x+4,m_y+2 SAY Lokal("Radnik (prazno-svi radnici): ")  GET  cIdRadn  valid empty(cIdRadn) .or. P_Radn(@cIdRadn)
	if !lSkrivena
		@ m_x+5,m_y+2 SAY Lokal("Varijanta ( /5): ")  GET  cVarijanta valid cVarijanta $ " 5"
	endif
	@ m_x+6,m_y+2 SAY Lokal("Ako su svi radnici, sortirati po (1-sifri,2-prezime+ime)")  GET cVarSort VALID cVarSort$"12"  pict "9"
	if !lSkrivena
		@ m_x+7,m_y+2 SAY Lokal("Dvije kartice na jedan list ? (D/N)")  GET c2K1L VALID c2K1L $ "DN"  pict "@!"
		@ m_x+8,m_y+2 SAY Lokal("Ispis svake kartice krece od pocetka stranice? (D/N)")  GET cNKNS VALID cNKNS$"DN"  pict "@!"
	endif
	read
	clvbox()
	ESC_BCR
	BoxC()
	select params
	WPar("VS",cVarSort)
	WPar("2K",c2K1L)
	WPar("NK",cNKNS)
	SELECT PARAMS
	USE
	if lViseObr
		O_TIPPRN
	else
		O_TIPPR
	endif
endif

PoDoIzSez(cGodina,cMjesec)

if cVarijanta=="5"
	O_LDSM
endif

SELECT LD

cIdRadn:=trim(cidradn)

IF EMPTY(cIdRadn) .and. cVarSort=="2"
	IF EMPTY(cIdRj)
		IF lViseObr .and. !EMPTY(cObracun)
			INDEX ON str(godina)+str(mjesec)+obr+SortPrez(idradn)+idrj TO "TMPLD"
			seek str(cGodina,4)+str(cmjesec,2)+cObracun+cIdRadn
		ELSE
			INDEX ON str(godina)+str(mjesec)+SortPrez(idradn)+idrj TO "TMPLD"
			seek str(cGodina,4)+str(cmjesec,2)+cIdRadn
		ENDIF
		cIdrj:=""
	ELSE
		IF lViseObr .and. !EMPTY(cObracun)
			INDEX ON str(godina)+idrj+str(mjesec)+obr+SortPrez(idradn) TO "TMPLD"
			seek str(cGodina,4)+cidrj+str(cmjesec,2)+cObracun+cIdRadn
		ELSE
			INDEX ON str(godina)+idrj+str(mjesec)+SortPrez(idradn) TO "TMPLD"
			seek str(cGodina,4)+cidrj+str(cmjesec,2)+cIdRadn
		ENDIF
	ENDIF
ELSE
	if empty(cidrj)
		set order to tag (TagVO("2"))
		seek str(cGodina,4)+str(cmjesec,2)+IF(lViseObr.and.!EMPTY(cObracun),cObracun,"")+cIdRadn
		cIdrj:=""
	else
		IF PCOUNT()<4
			SET ORDER TO TAG (TagVO("1"))
		ENDIF
		seek str(cGodina,4)+cidrj+str(cmjesec,2)+IF(lViseObr.and.!EMPTY(cObracun),cObracun,"")+cIdRadn
	endif
ENDIF

EOF CRET

nStrana:=0

select vposla
hseek ld->idvposla
select rj
hseek ld->idrj
select ld

if pcount()>=4
	START PRINT RET
else
	START PRINT CRET
endif

?
P_12CPI

IF lSkrivena
	gRPL_Gusto()
ENDIF

ParObr(cmjesec,IF(lViseObr,cObracun,),cIdRj)

private lNKNS
lNKNS:=(cNKNS=="D")

nRbrKart:=0

bZagl:={|| ZaglKar()}

nT1:=nT2:=nT3:=nT4:=0


//-- Prikaz samo odredjenih doprinosa na kartici plate
//-- U fmk.ini /kumpath se definisu koji dopr. da se prikazuju
//-- Po defaultu stoji prazno - svi doprinosi

cPrikDopr:=IzFmkIni("LD","DoprNaKartPl","D",KUMPATH)
lPrikSveDopr:=(cPrikDopr=="D")

do while !eof() .and. cgodina==godina .and. idrj=cidrj .and. cmjesec=mjesec .and. idradn=cIdRadn .and. !( lViseObr .and. !EMPTY(cObracun) .and. obr<>cObracun )

	aNeta:={}

	m:=cLMSK+"----------------------- --------  ----------------   ------------------"
	IF lViseObr .and. EMPTY(cObracun)
		ScatterS(Godina,Mjesec,IdRJ,IdRadn)
	ELSE
		Scatter()
	ENDIF

	select radn
	hseek _idradn
	select vposla
	hseek _idvposla
	select rj
	hseek _idrj
	select ld

	AADD(aNeta,{vposla->idkbenef,_UNeto})

	if gPrBruto<>"X"
		// gPrBruto$"DN"
		KartPlDN(cIdRj,cMjesec,cGodina,cIdRadn,cObrac,@aNeta)
	else
		// gPrBruto=="X"
		KartPlX(cIdRj,cMjesec,cGodina,cIdRadn,cObrac,@aNeta)
	endif

	nT1+=_usati
	nT2+=_uneto
	nT3+=_uodbici
	nT4+=_uiznos

	select ld
	skip 1
enddo

IF lSkrivena
	gRPL_Normal()
	IF !pcount()>=4 .and. (nRBrKart%2)==1
		FF
	ENDIF
ENDIF

if pcount()>=4  // predji na drugu stranu
	FF
endif

END PRINT

if pcount()<4
	closeret
else // pcount >= "4"
	set order to tag (TagVO("1"))
endif

return
*}

// ---------------------------
// ---------------------------
function ZaglKar()

++nRBrKart

// nova stranica odredjuje odakle ce se poceti stampati
// gura karticu do polovine stranice ako fali redova
IF !lSkrivena .and. !lNKNS .and. gPrBruto<>"D" .and. c2K1L=="D" .and. (nRBrKart%2)==0
	DO WHILE prow() < 34
		?
	ENDDO
ENDIF

IF lSkrivena
	FOR i:=1 TO nPZRSK
		?
	NEXT
	P_12CPI
	?? cLMSK + Lokal("OBRACUN PLATE ZA") + SPACE(1) + str(mjesec,2) + IspisObr() + "/" + str(godina,4), " ZA " + UPPER(TRIM(gTS)), gNFirma
	? cLMSK+idradn,"-",RADNIK,"  Mat.br:",radn->matbr
	ShowHiredFromTo(radn->hiredfrom, radn->hiredto, cLMSK)
	? cLMSK + Lokal("Radno mjesto:"), radn->rmjesto, Lokal("  STR.SPR:"), IDSTRSPR
	? cLMSK + Lokal("Vrsta posla:"), idvposla, vposla->naz, Lokal("         Radi od:"), radn->datod
	FOR i:=1 TO nIZRSK
		?
	NEXT
	? cLMSK+IF(gBodK=="1", Lokal("Broj bodova :"), Lokal("Koeficijent :")), transform(brbod,"99999.99"),space(24)
	if gMinR=="B"
		?? Lokal("Minuli rad:"), transform(kminrad,"9999.99")
	else
		?? Lokal("K.Min.rada:"), transform(kminrad,"99.99%")
	endif
	? cLMSK+IF(gBodK=="1", Lokal("Vrijednost boda:"), Lokal("Vr.koeficijenta:")), transform(parobr->vrbod,"99999.99999")
ELSE
	? LOKAL("OBRACUN PLATE ZA") + SPACE(1) + str(mjesec,2) + IspisObr() + "/" + str(godina,4)," ZA "+ UPPER(TRIM(gTS)), gNFirma
	? "RJ:",idrj,rj->naz
	? idradn,"-",RADNIK,"  Mat.br:",radn->matbr
	ShowHiredFromTo(radn->hiredfrom, radn->hiredto, "")
	? Lokal("Radno mjesto:"),radn->rmjesto, "  STR.SPR:",IDSTRSPR
	? Lokal("Vrsta posla:"),idvposla,vposla->naz,"         Radi od:",radn->datod
	? IF(gBodK=="1", Lokal("Broj bodova :"),Lokal("Koeficijent :")),transform(brbod,"99999.99"),space(24)
	if gMinR=="B"
		?? Lokal("Minuli rad:"), transform(kminrad,"9999.99")
	else
		?? Lokal("K.Min.rada:"), transform(kminrad,"99.99%")
	endif
	? IF(gBodK=="1",Lokal("Vrijednost boda:"), Lokal("Vr.koeficijenta:")), transform(parobr->vrbod,"99999.99999")
	if lRadniSati
		?? SPACE(19) + Lokal("Radni sati:   ") + ALLTRIM(STR(ld->radsat))
	endif
ENDIF

return
*}

// provjerava koliko kartica ima redova
static function kart_redova()
local nRows:=0
local cField
local cFIznos:="_I"
local cFSati:="_S"
local nStRedova:=23

if gPrBruto == "X"
	nStRedova := 32
endif

// ako nema potpisa standardnih redova je manje
if gPotp=="N"
	nStRedova:=nStRedova - 4
endif

// ispitaj standardna ld polja _I(nn), _S(nn)
for i:=1 to cLDPolja
	cField := PADL(ALLTRIM(STR(i)),2,"0")
	if &(cFIznos+cField)<>0 .or. &(cFSati+cField)<>0
		++ nRows
	endif
next

// ispitaj kredite
select radkr
set order to 1
seek str(_godina,4) + str(_mjesec,2) + _idradn
do while !eof() .and. _godina==godina .and. _mjesec=mjesec .and. idradn==_idradn
	++ nRows
	skip 
enddo
select ld
return (nRows + nStRedova)


// kartica plate - bruto = N .or. D
static function KartPlDN(cIdRj,cMjesec,cGodina,cIdRadn,cObrac,aNeta)
local nKRedova

// koliko redova ima kartica
nKRedova := kart_redova()

Eval(bZagl)

if gTipObr=="2" .and. parobr->k1<>0
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

? m
? cLMSK+ Lokal(" Vrsta                  Opis         sati/iznos             ukupno")
? m

cUneto:="D"
nRRsati:=0 

for i:=1 to cLDPolja
	
	cPom:=padl(alltrim(str(i)),2,"0")
	
	select tippr
	seek cPom
	
	if tippr->uneto=="N" .and. cUneto=="D"
		cUneto:="N"
		? m
		? cLMSK+Lokal("UKUPNO NETO:")
		@ prow(),nC1+8  SAY  _USati  pict gpics
		?? SPACE(1) + Lokal("sati")
		@ prow(),60+LEN(cLMSK) SAY _UNeto pict gpici
		?? "",gValuta
		? m
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
			
			if "SUMKREDITA" $ tippr->formula .and. gReKrKP=="1"
				
				IF l2kolone
					P_COND2
				ELSE
					P_COND
				ENDIF
				
				? m
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
				
				? m
				
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

? m
?  cLMSK+Lokal("UKUPNO ZA ISPLATU")
@ prow(),60+LEN(cLMSK) SAY _UIznos pict gpici
?? "",gValuta
? m

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
	? m
	hseek str(_godina,4)+str(_mjesec,2)+"2"+_idradn+_idrj
	// hseek "2"+str(_godina,4)+str(_mjesec,2)+_idradn+_idrj
	? cLMSK+Lokal("Od toga 2. dio:")
	@ prow(),60+LEN(cLMSK) SAY UIznos pict gpici
	? m
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

if gPrBruto=="D"  // prikaz bruto iznosa
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
	
	m:=cLMSK+"----------------------- -------- ------------- -------------"
	
	nBO:=0
	nBFO:=0
	
	nBo:=round2(parobr->k3/100*MAX(_UNeto,PAROBR->prosld*gPDLimit/100),gZaok2)
	
	if UBenefOsnovu()
		nBFo:=round2(parobr->k3/100*MAX(_UNeto-(&gBFForm),PAROBR->prosld*gPDLimit/100),gZaok2)
	endif
	
	IF lSkrivena
		? m
	ELSE
		?
		?
	ENDIF
	
	select por
	go top
	
	nPom:=0
	nPor:=0
	nC1:=30+LEN(cLMSK)
	nPorOl:=0
	
	do while !eof()
	
		lStepPor := .f.
		
		if por->(FIELDPOS("ALGORITAM")) <> 0
			if por->algoritam == "S"
				lStepPor := .t.
			endif
		endif
		
		PozicOps(POR->poopst)
		
		IF !ImaUOp("POR",POR->id)
			SKIP 1
			LOOP
		ENDIF
		
		if lStepPor == .f.
		
			? cLMSK+id,"-",naz
		
			@ prow(),pcol()+1 SAY iznos pict "99.99%"
		
			nC1:=pcol()+1
		
			@ prow(),pcol()+1 SAY MAX(_UNeto,PAROBR->prosld*gPDLimit/100) pict gpici
			@ prow(),pcol()+1 SAY nPom:=max(dlimit,round(iznos/100*MAX(_UNeto,PAROBR->prosld*gPDLimit/100),gZaok2)) pict gpici
		
			nPor += nPom
		
		else
			// stepenasti porez....
			
			// nPor += ....
		
		endif
		
		skip 1
	enddo
	
	if radn->porol<>0  .and. gDaPorOl=="D" .and. !Obr2_9()  // poreska olaksica
		if alltrim(cVarPorOl)=="2"
			nPorOl:=RADN->porol
		elseif alltrim(cVarPorol)=="1"
			nPorOl:=round(parobr->prosld*radn->porol/100,gZaok)
		else
			nPorOl:= &("_I"+cVarPorol)
		endif
		? cLMSK+Lokal("PORESKA OLAKSICA")
		if nPorOl>nPor // poreska olaksica ne moze biti veca od poreza
			nPorOl:=nPor
		endif
		if cVarPorOl=="2"
			@ prow(),pcol()+1 SAY ""
		else
			@ prow(),pcol()+1 SAY radn->PorOl pict "99.99%"
		endif
		@ prow(),nC1 SAY parobr->prosld pict gpici
		@ prow(),pcol()+1 SAY nPorOl    pict gpici
	endif
	
	if radn->porol<>0 .and. gDaPorOl=="D" .and. !Obr2_9()
		
		? m
		? cLMSK+Lokal("Ukupno Porez")
		@ prow(),nC1 SAY space(len(gpici))
		@ prow(),pcol()+1 SAY nPor-nPorOl pict gpici
		? m
		
	endif
	
	if !lSkrivena .and. prow()>55+gPStranica
		FF
	endif

	?
	
	m:=cLMSK+"----------------------- -------- ------------- -------------"
	
	select dopr
	go top
	
	nPom:=0
	nDopr:=0
	nC1:=20+LEN(cLMSK)
	
	do while !eof()
		
		PozicOps(DOPR->poopst)
		
		IF !ImaUOp("DOPR",DOPR->id) .or. !lPrikSveDopr .and. !DOPR->ID $ cPrikDopr
			SKIP 1
			LOOP
		ENDIF
		
		if right(id,1)=="X"
			? m
		endif
		
		if ("BENEF" $ dopr->naz .and. nBFO == 0)
			skip
			loop
		endif
		
		? cLMSK+id,"-",naz
		@ prow(),pcol()+1 SAY iznos pict "99.99%"
		
		if empty(idkbenef) // doprinos udara na neto
			if ("BENEF" $ dopr->naz .and. nBFO <> 0)
				@ prow(),pcol()+1 SAY nBFO pict gpici
				nC1:=pcol()+1
				@ prow(),pcol()+1 SAY nPom:=max(dlimit,round(iznos/100*nBFO,gZaok2)) pict gpici
			else
				@ prow(),pcol()+1 SAY nBO pict gpici
				nC1:=pcol()+1
				@ prow(),pcol()+1 SAY nPom:=max(dlimit,round(iznos/100*nBO,gZaok2)) pict gpici
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
			? m
			?
			nDopr+=nPom
		endif
		
		if !lSkrivena .and. prow()>57+gPStranica
			FF
		endif
		
		skip 1
		
	enddo

	m := cLMSK + "--------------------------"

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
*}


// potpis kartice
static function kart_potpis()
// potpis kartice
if !lSkrivena .and. gPotp == "D"
	?
	? cLMSK+space(5), Lokal("   Obracunao:  "), space(30), Lokal("    Potpis:")
	? cLMSK+space(5),"_______________", space(30) , "_______________"
	?
endif
return


// kartica plate bruto X
static function KartPlX(cIdRj,cMjesec,cGodina,cIdRadn,cObrac,aNeta)
local nKRedova

// koliko redova ima kartica
nKRedova := kart_redova()

Eval(bZagl)

if gTipObr=="2" .and. parobr->k1<>0
	?? "        Bod-sat:"
	@ prow(),pcol()+1 SAY parobr->vrbod/parobr->k1*brbod pict "99999.999"
endif

IF l2kolone
	P_COND2
	// aRCPos := { PROW() , PCOL() }
	cDefDev := SET(_SET_PRINTFILE)
	SvratiUFajl()
	// SETPRC(0,0)
ENDIF
? m
? cLMSK+ Lokal(" Vrsta                  Opis         sati/iznos             ukupno")
? m
private nC1:=30+LEN(cLMSK)
for i:=1 to cLDPolja
	cPom:=padl(alltrim(str(i)),2,"0")
	select tippr
	seek cPom
	if tippr->uneto=="D"
		PrikPrimanje()
	endif
next
? m
? cLMSK+ Lokal("UKUPNO NETO:")
@ prow(),nC1+8  SAY  _USati  pict gpics
?? SPACE(1) + Lokal("sati")
@ prow(),60+LEN(cLMSK) SAY _UNeto pict gpici
?? "",gValuta
? m
nBruto:=_UNETO
nPorDopr:=0
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
nBo:=round2(parobr->k3/100*MAX(_UNeto,PAROBR->prosld*gPDLimit/100),gZaok2)
select por
go top
nPom:=nPor:=0
nC1:=30+LEN(cLMSK)
nPorOl:=0
do while !eof()
	PozicOps(POR->poopst)
	IF !ImaUOp("POR",POR->id)
		SKIP 1
		LOOP
	ENDIF
	IF !lSkrivena
		? cLMSK+id,"-",naz
		@ prow(),pcol()+1 SAY iznos pict "99.99%"
		nC1:=pcol()+1
		// @ prow(),pcol()+1 SAY _UNeto pict gpici
		@ prow(),39+LEN(cLMSK)  SAY nPom:=max(dlimit,round(iznos/100*MAX(_UNeto,PAROBR->prosld*gPDLimit/100),gZaok2)) pict gpici
	ELSE
		nPom:=max(dlimit,round(iznos/100*MAX(_UNeto,PAROBR->prosld*gPDLimit/100),gZaok2))
	ENDIF
	nPor+=nPom
	skip 1
enddo
nBruto+=nPor
nPorDopr+=nPor
if radn->porol<>0 .and. gDaPorOl=="D" .and. !Obr2_9() // poreska olaksica
	if alltrim(cVarPorOl)=="2"
		nPorOl:=RADN->porol
	elseif alltrim(cVarPorol)=="1"
		nPorOl:=round(parobr->prosld*radn->porol/100,gZaok)
	else
		nPorOl:= &("_I"+cVarPorol)
	endif
	IF !lSkrivena
		? cLMSK+ Lokal("PORESKA OLAKSICA")
	ENDIF
	if nPorOl>nPor // poreska olaksica ne moze biti veca od poreza
		nPorOl:=nPor
	endif
	IF !lSkrivena
		if cVarPorOl=="2"
			@ prow(),pcol()+1 SAY ""
		else
			@ prow(),pcol()+1 SAY radn->PorOl pict "99.99%"
		endif
		// @ prow(),nC1 SAY parobr->prosld pict gpici
		@ prow(),39+LEN(cLMSK) SAY nPorOl    pict gpici
	ENDIF
	nBruto-=nPorol
	nPorDopr-=nPorOl
endif
IF !lSkrivena
	if radn->porol<>0 .and. gDaPorOl=="D" .and. !Obr2_9()
		? m
		? cLMSK+Lokal("Ukupno Porez")
		// @ prow(),nC1 SAY space(len(gpici))
		@ prow(),39+LEN(cLMSK) SAY nPor-nPorOl pict gpici
		? m
	endif
ENDIF
select dopr
go top
nPom:=nDopr:=0
nC1:=20+LEN(cLMSK)
do while !eof()  // DOPRINOSI
	PozicOps(DOPR->poopst)
	IF !ImaUOp("DOPR",DOPR->id)
		SKIP 1
		LOOP
	ENDIF
	if right(id,1)<>"X"
		SKIP 1
		LOOP
	endif
	IF !lSkrivena
		? cLMSK+id,"-",naz
		@ prow(),pcol()+1 SAY iznos pict "99.99%"
	ENDIF
	if empty(idkbenef) // doprinos udara na neto
		// @ prow(),pcol()+1 SAY nBO pict gpici
		nC1:=pcol()+1
		nPom:=max(dlimit,round(iznos/100*nBO,gZaok2))
		if round(iznos,4)=0 .and. dlimit>0  // fuell boss
			nPom:=1*dlimit   // kartica plate
		endif
		IF !lSkrivena
			@ prow(),39+LEN(cLMSK) SAY nPom pict gpici
		ENDIF
		nDopr+=nPom
		nBruto+=nPom
		nPorDopr+=nPom
	else
		nPom0:=ASCAN(aNeta,{|x| x[1]==idkbenef})
		if nPom0<>0
			nPom2:=parobr->k3/100*aNeta[nPom0,2]
		else
			nPom2:=0
		endif
		if round(nPom2,gZaok2)<>0
			// @ prow(),pcol()+1 SAY nPom2 pict gpici
			nC1:=pcol()+1
			IF !lSkrivena
				@ prow(),39+LEN(cLMSK) SAY nPom:=max(dlimit,round(iznos/100*nPom2,gZaok2)) pict gpici
			ENDIF
			nDopr+=nPom
			nBruto+=nPom
			nPorDopr+=nPom
		endif
	endif
	skip 1
enddo // doprinosi

IF lSkrivena
	? cLMSK+Lokal("UKUPNO POREZ:")+TRANSFORM(nPor-nPorOl,gPicI)+", " + Lokal("DOPRINOSI:")+TRANSFORM(nDopr,gPicI)+", " + Lokal("POR.+DOPR.:")+TRANSFORM(nPorDopr,gPicI)
ELSE
	? m
	? cLMSK+ Lokal("UKUPNO POREZ+DOPRINOSI")
	@ prow(),39+LEN(cLMSK) SAY nPorDopr pict gpici
ENDIF

? m
? cLMSK+ Lokal("BRUTO IZNOS")
@ prow(),60+LEN(cLMSK) SAY nBruto pict gpici
? m
SELECT LD

IF !lSkrivena
	? m
ENDIF

? cLMSK+Lokal("- OBUSTAVE :")
? m
private fImaNak:=.f.,nObustave:=0

for i:=1 to cLDPolja
	cPom:=padl(alltrim(str(i)),2,"0")
	select tippr
	seek cPom
	if tippr->uneto=="N" .and. _i&cPom<0
		PrikPrimanje()
		nObustave+=abs(_i&cPom)
	elseif tippr->uneto=="N" .and. _i&cPom>0
		fimaNak:=.t.
	endif
next

if nObustave>0
	? m
	? cLMSK+Lokal("UKUPNO OBUSTAVE:")
	@ prow(),60+LEN(cLMSK) SAY nObustave pict gpici
	? m
endif

if fImaNak
	if !(nObustave>0)
		? m
	endif
	? cLMSK+"+ " + Lokal("NAKNADE (primanja van neta):")
	? m
endif

for i:=1 to cLDPolja
	cPom:=padl(alltrim(str(i)),2,"0")
	select tippr
	seek cPom
	if tippr->uneto=="N" .and. _i&cPom>0
		PrikPrimanje()
	endif
next

? m
?  cLMSK+Lokal("UKUPNO ZA ISPLATU :")
@ prow(),60+LEN(cLMSK) SAY _UIznos pict gpici
?? "",gValuta
? m

if cVarijanta=="5"
	// select ldsm
	select ld
	PushWA()
	set order to tag "2"	   
	hseek str(_godina,4)+str(_mjesec,2)+"1"+_idradn+_idrj
	//hseek "1"+str(_godina,4)+str(_mjesec,2)+_idradn+_idrj
	?
	? cLMSK+ Lokal("Od toga 1. dio:")
	@ prow(),60+LEN(cLMSK) SAY UIznos pict gpici
	? m
	hseek str(_godina,4)+str(_mjesec,2)+"2"+_idradn+_idrj
	// hseek "2"+str(_godina,4)+str(_mjesec,2)+_idradn+_idrj
	? cLMSK+ Lokal("Od toga 2. dio:")
	@ prow(),60+LEN(cLMSK) SAY UIznos pict gpici
	? m
	select ld
	PopWA()
endif

// potpis na kartici
kart_potpis()

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




