#include "ld.ch"
#include "rddinit.ch"

// -----------------------------------------
// parametri - firma
// -----------------------------------------
function SetFirma()
private GetList:={}

Box(, 6,60)
	@ m_x+1,m_y+2 SAY "Radna jedinica:" GET gRJ valid P_Rj(@gRj) pict "@!"
      	@ m_x+2,m_y+2 SAY "Mjesec        :" GET gMjesec pict "99"
      	@ m_x+3,m_y+2 SAY "Godina        :" GET gGodina pict "9999"
      	if lViseObr
        	@ m_x+4,m_y+2 SAY "Obracun       " GET gObracun WHEN HelpObr(.f.,gObracun) VALID ValObr(.f.,gObracun)
      	endif
      	@ m_x+5,m_y+2 SAY "Naziv firme   :" GET gNFirma
      	@ m_x+6,m_y+2 SAY "Tip subjekta  :" GET gTS
      	read
      	ClvBox()
BoxC()

if (LastKey()<>K_ESC)
	Wpar("fn",gNFirma)
      	Wpar("ts",gTS)
      	Wpar("go",gGodina)
      	Wpar("mj",gMjesec)
      	Wpar("ob",gObracun)
      	Wpar("rj",gRJ)
	if gZastitaObracuna=="D"
		IspisiStatusObracuna(gRj,gGodina,gMjesec)
	endif
endif

return



// -----------------------------------------
// parametri - formati prikaza
// -----------------------------------------
function SetForma()
private GetList:={}

Box(,5,60)
	@ m_x+1,m_y+2 SAY "Zaokruzenje primanja          :" GET gZaok pict "99"
      	@ m_x+2,m_y+2 SAY "Zaokruzenje poreza i doprinosa:" GET gZaok2 pict "99"
      	@ m_x+3,m_y+2 SAY "Valuta                        :" GET gValuta pict "XXX"
      	@ m_x+4,m_y+2 SAY "Prikaz iznosa                 :" GET gPicI
      	@ m_x+5,m_y+2 SAY "Prikaz sati                   :" GET gPicS
	read
BoxC()

if (LastKey()<>K_ESC)
	Wpar("pi",gPicI)
      	Wpar("ps",gPicS)
      	Wpar("va",gValuta)
      	Wpar("z2",gZaok2)
      	Wpar("zo",gZaok)
endif

return



// -----------------------------------------
// parametri - formule
// -----------------------------------------
function SetFormule()
private GetList:={}

Box(,19,77)
	gFURaz:=PADR(gFURaz,100)
      	gFUPrim:=PADR(gFUPrim,100)
      	gFUSati:=PADR(gFUSati,100)
      	gFURSati:=PADR(gFURSati,100)
	gBFForm:=PADR(gBFForm,100)
      	@ m_x+1,m_y+2 SAY "Formula za ukupna primanja:" GET gFUPrim  pict "@!S30"
      	@ m_x+2,m_y+2 SAY "Formula za ukupno sati    :" GET gFUSati  pict "@!S30"
      	@ m_x+3,m_y+2 SAY "Formula za godisnji       :" GET gFUGod pict "@!S30"
      	@ m_x+5,m_y+2 SAY "Formula za uk.prim.-razno :" GET gFURaz pict "@!S30"
      	@ m_x+6,m_y+2 SAY "Formula za uk.sati -razno :" GET gFURSati pict "@!S30"
      	@ m_x+8,m_y+2 SAY "God. promjena koef.min.rada - ZENE:" GET gMRZ   pict "9999.99"
      	@ m_x+9,m_y+2 SAY "God. promjena koef.min.rada - MUSK:" GET gMRM   pict "9999.99"
      	@ m_x+11,m_y+2 SAY "% prosjecne plate kao donji limit neta za obracun poreza i doprinosa" GET gPDLimit pict "999.99"
      	
	@ m_x+13,m_y+2 SAY "Osnovni licni odbitak" GET gOsnLOdb VALID gOsnLOdb > 0 PICT "9999.99"
	
	@ m_x+15,m_y+2 SAY "  Trosak - ugovor o djelu (%):" GET gUgTrosk PICT "999.99"
	
	@ m_x+16,m_y+2 SAY "Trosak - autorski honorar (%):" GET gAhTrosk PICT "999.99"
	
	@ m_x+18,m_y+2 SAY "Kod benef.gledaj formulu:" GET gBFForm pict "@!S30"
      	read
BoxC()

if (LastKey()<>K_ESC)
	Wpar("gd", gFUGod)
      	WPar("m1", @gMRM)
      	WPar("m2", @gMRZ)
      	WPar("dl", @gPDLimit)
      	Wpar("uH", @gFURSati)
      	Wpar("uS", @gFUSati)
	Wpar("uB", @gBFForm)
      	Wpar("up", gFUPrim)
      	Wpar("ur", gFURaz)
      	Wpar("lo", gOsnLOdb)
      	Wpar("t1", gUgTrosk)
      	Wpar("t2", gAhTrosk)
endif

return


// -----------------------------------------
// parametri nacin obracuna
// -----------------------------------------
function SetObracun()
local nX := 1
private GetList:={}

cVarPorol:=PADR(cVarPorol,2)

Box(, 17, 77)
	
	@ m_x+nX,m_y+2 SAY "Varijanta obracuna" GET gVarObracun
      	
	++nX
	
	@ m_x+nX,m_y+2 SAY "  ' ' - (prazno) stara varijanta obracuna" 
	
	++nX
	
	@ m_x+nX,m_y+2 SAY "  '2' - nova varijanta obracuna, zak.pr.2009" 
	
	++nX	
	
	@ m_x+nX,m_y+2 SAY "Tip obracuna (legacy)" GET gTipObr
      	++nX
	@ m_x+nX,m_y+2 SAY "Mogucnost unosa mjeseca pri obradi D/N:" GET gUnMjesec  pict "@!" valid glistic $ "DN"
      	++nX
      	@ m_x+nX,m_y+2 SAY "Koristiti set formula (sifrarnik Tipovi primanja):" GET gSetForm pict "9" valid V_setform()
      	++nX
      	@ m_x+nX,m_y+2 SAY "Minuli rad  %/B:" GET gMinR  valid gMinR $ "%B"   pict "@!"
      	++nX
      	@ m_x+nX,m_y+2 SAY "Pri obracunu napraviti poreske olaksice D/N:" GET gDaPorOl  valid gDaPorOl $ "DN"   pict "@!"
      	++nX
      	@ m_x+nX,m_y+2 SAY "Ako se prave por.ol.pri obracunu, koja varijanta se koristi:"
      	++nX
      	@ m_x+nX,m_y+2 SAY " '1' - POROL = RADN->porol*PAROBR->prosld/100 ÄÄ¿  "
      	++nX
      	@ m_x+nX,m_y+2 SAY " '2' - POROL = RADN->porol, '29' - LD->I29    ÄÄÁÄ>" GET cVarPorOl WHEN gDaPorOl=="D"   PICT "99"
      	++nX

      	@ m_x+nX,m_y+2 SAY "Grupe poslova u specif.uz platu (1-automatski/2-korisnik definise):" GET gVarSpec  valid gVarSpec $ "12" pict "9"
      	++nX
      	@ m_x+nX,m_y+2 SAY "Obrada sihtarice ?" GET gSihtarica valid gSihtarica $ "DN" pict "@!"
      	++nX
      	@ m_x+nX,m_y+2 SAY "Obrada autorskih honorara ?" GET gAHonorar valid gAHonorar $ "DN" .and. ahon_ready() pict "@!"
	read
BoxC()

if (LastKey()<>K_ESC)
	WPar("fo", gSetForm)
      	WPar("mr", @gMinR)   // min rad %, Bodovi
      	WPar("p9", @gDaPorOl) // praviti poresku olaksicu D/N
      	Wpar("to",gTipObr)
      	Wpar("vo",cVarPorOl)
      	WPar("um",gUNMjesec)
      	Wpar("vs",gVarSpec)
      	Wpar("Si",gSihtarica)
      	Wpar("aH",gAHonorar)
	Wpar("ov",gvarObracun)
endif

return

// -----------------------------------------------
// formati prikaza dokumenata
// -----------------------------------------------
function SetPrikaz()
private GetList:={}

gPotp1 := PADR(gPotp1, 150)
gPotp2 := PADR(gPotp2, 150)

Box(,10,77)
	@ m_x+1,m_y+2 SAY "Krediti-rekap.po 'na osnovu' (D/N/X)?" GET gReKrOs VALID gReKrOs $ "DNX" PICT "@!"
      	@ m_x+2,m_y+2 SAY "Na kraju obrade odstampati listic D/N:" GET gListic  pict "@!" valid glistic $ "DN"
      	@ m_x+3,m_y+2 SAY "Prikaz bruto iznosa na kartici radnika (D/N/X) " GET gPrBruto pict "@!" valid gPrBruto $ "DNX"
      	@ m_x+4,m_y+2 SAY "Potpis na kartici radnika D/N:" GET gPotp  valid gPotp $ "DN"   pict "@!"
      	@ m_x+5,m_y+2 SAY "Varijanta kartice plate za kredite (1/2) ?" GET gReKrKP VALID gReKrKP$"12"
      	@ m_x+6,m_y+2 SAY "Opis osnovnih podataka za obracun (1-bodovi/2-koeficijenti) ?" GET gBodK VALID gBodK$"12"
      	@ m_x+7,m_y+2 SAY "Pregled plata: varijanta izvjestaja (1/2)" GET gVarPP VALID gVarPP$"12"
      	@ m_x+8,m_y+2 SAY "Potpisi na svim izvjestajima (D/N)" GET gPotpRpt VALID gPotpRpt$"DN" PICT "@!"
	read
	
	if gPotpRpt == "D"
      		@ m_x+9,m_y+2 SAY "red 1:" GET gPotp1 PICT "@S25"
      		@ m_x+9,col()+1 SAY "red 2:" GET gPotp2 PICT "@S25"
		read
	endif
      	
	@ m_x+10,m_y+2 SAY "Kartica plate - svi doprinosi (D/N)" GET gKarSDop VALID gKarSDop$"DN" PICT "@!"
	
	read

BoxC()

if (LastKey()<>K_ESC)
	Wpar("bk",gBodK)
      	Wpar("kp",gReKrKP)
      	Wpar("pp",gVarPP)
      	Wpar("li",gListic)
      	WPar("pb",gPrBruto)   
	// set formula
      	WPar("po",gPotp)   
	// potp4is na listicu
      	Wpar("rk",gReKrOs)
      	Wpar("pr",gPotpRpt)
      	Wpar("P1",gPotp1)
      	Wpar("P2",gPotp2)
	Wpar("ks",gKarSDop)

      	//Wpar("tB",gTabela)
endif

return


// -----------------------------------------
// parametri - razno
// -----------------------------------------
function SetRazno()
private GetList:={}

Box(, 3,60)
	@ m_x+ 2,m_y+2 SAY "Fajl obrasca specifikacije" GET gFSpec VALID V_FSpec()
      	read
BoxC()

if (LastKey()<>K_ESC)
	WPar("os", @gFSpec)   
	// fajl-obrazac specifikacije
endif

return



function V_SetForm()
local cScr
local nArr:=SELECT()

if (File(SIFPATH+"TIPPR.DB"+gSetForm) .and. Pitanje(,"Sifrarnik tipova primanja uzeti iz arhive br. "+gSetForm+" ?","N")=="D")
	save screen to cScr
	select (F_TIPPR)
 	use
	cls
	#ifdef C52
 		? FileCopy(SIFPATH+"TIPPR.DB"+gSetForm  ,SIFPATH+"TIPPR.DBF")
 		? FileCopy(SIFPATH+"TIPPR.CD"+gSetForm,SIFPATH+"TIPPR.CDX")
	#else
 		? FileCopy(SIFPATH+"TIPPR.DB"+gSetForm  ,SIFPATH+"TIPPR.DBF"  )
 		? FileCopy(SIFPATH+"TIPPRI1.NT"+gSetForm,SIFPATH+"TIPPRi1.NTX")
	#endif
 	
	inkey(20)
 	restore screen from cScr
 	select (F_TIPPR)
 	if !Used()
		O_TIPPR
	endif
 	P_Tippr()
 	select params
elseif Pitanje(,"Tekuci sifrarnik tipova primanja staviti u arhivu br. "+gSetForm+" ?","N")=="D"
	save screen to cScr
 	select (F_TIPPR)
 	use
 	cls
	#ifdef C52
 		? FileCopy(SIFPATH+"TIPPR.DBF",SIFPATH+"TIPPR.DB"+gSetForm)
 		? FileCopy(SIFPATH+"TIPPR.CDX",SIFPATH+"TIPPR.CD"+gSetForm)
	#else
 		? FileCopy(SIFPATH+"TIPPR.DBF", SIFPATH+"TIPPR.DB"+gSetForm)
 		? FileCopy(SIFPATH+"TIPPRi1.NTX",SIFPATH+"TIPPRI1.NT"+gSetForm)
	#endif
 	inkey(20)
 	restore screen from cScr
endif

select (nArr)
return .t.



function PrenosLD()
Beep(4)
MsgBeep("Da bi se rasteretili od podataka koji nam nisu potrebni,#"+;
        "vrsimo brisanje nepotrebnih podataka u tekucoj godini.##"+;
        " ?")
if Pitanje(,"Brisanje dijela podataka iz protekle sezone ?","N")="N"
	closeret
endif

if !SigmaSif("LDSTARO")
	closeret
endif

nGodina:=YEAR(Date())-1
nMjOd:=1
nMjDo:=9
Box(,4,60)
	do while .t.
 		cIspravno:="N"
   		@ m_x+1,m_y+2 SAy"Izbrisati mjesece za godinu :"  GET nGodina pict "9999"
   		@ m_x+2,m_y+2 SAY "Brisanje izvrsiti od mjeseca:" GET nMjOd pict "99"
   		@ row(),col()+2 SAY "do mjeseca" GET nMjDO pict "99"
   		@ m_x+4,m_y+2 SAY "Ispravno D/N ?" GET cispravno valid cispravno $ "DN" pict "@!"
   		read
   		if cIspravno=="D"
			exit
		endif
	enddo
Boxc()

O_LDX
set order to 0

start print cret

? "Datoteka LD..."
?

select ld
go top

do while !eof()
	if nGodina==godina .and. (mjesec>=nMjOd .and. mjesec<=nMjDo) .or. EMPTY(idradn)
		DbDelete2()
     		? "Brisem:",idrj,godina,mjesec,idradn
  	endif
	skip
enddo

select ld
use

? "Datoteka LDSM..."
?

O_LDSMX
select ldsm
go top

do while !eof()
	if nGodina==godina .and. (mjesec>=nMjOd .and. mjesec<=nMjDo) .or. EMPTY(idradn)
		DbDelete2()
     		? "Brisem:",idrj,godina,mjesec,idradn
  	endif
	skip
enddo

select ldsm
use

? "Datoteka RADKR..."
?

O_RADKRX
select radkr
go top

do while !eof()
	// ako je godina 1998, onda brisi 1997 i starije
 	if (nGodina>godina .or. EMPTY(idradn))
     		DbDelete2()
     		? "Brisem: radkr",godina,mjesec,idradn
  	endif
	skip
enddo

select radkr
use

end print

closeret
return
*}


function IspraviSpec(cKomLin)
*{
if !EMPTY(gFSpec)
	Box(,25,80)
		run @cKomLin
	BoxC()
endif
*}


function V_FSpec()
*{

private cKom:="q "+PRIVPATH+gFSpec

if Pitanje(,"Zelite li izvrsiti ispravku fajla obrasca specifikacije ?","N")=="D"
	IspraviSpec(cKom)
endif
return .t.
*}


function V_FRjes(cVarijanta)
*{

private cKom:="q "+PRIVPATH

if (cVarijanta>"4")
	cKom+="dokaz"
else
 	cKom+="rjes"
endif

if cVarijanta=="5"
	cKom+="1"
elseif cVarijanta=="6"
 	cKom+="2"
else
	cKom+=cVarijanta
endif

cKom+=".txt"

if Pitanje(,"Zelite li izvrsiti ispravku fajla obrasca rjesenja ?","N")=="D"
	IspraviSpec(cKom)
endif

return .t.
*}


#ifdef CAX
	function truename(cc)  // sklonjena iz CTP
	return cc
#else
	#ifdef EXT
		function truename(cc)  // sklonjena iz CTP
 		return cc
	#endif
#endif


#ifdef C52

function OKumul(nArea,cStaza,cIme,nIndexa,cDefault)
*{
local cPath
local cScreen

if cDefault==nil
	cDefault:="0"
endif

select (nArea)

if gKesiraj $ "CD"
	cPath:=STRTRAN(cStaza,LEFT(cStaza,3),gKesiraj+":"+SLASH)
	DirMak2(cPath)  // napravi odrediçni direktorij
	if cDefault!="0"
    		if !File(cPath+cIme+".DBF") .or. Pitanje(,"Osvjeziti podatke za "+cIme, cDefault )=="D"
			save screen to cScr
     			cls
     			? "Molim sacekajte prenos podataka na vas racunar "
     			? "radi brzeg pregleda podataka"
     			?
     			? "Ovaj racunar NE KORISTITE za unos novih podataka !"
     			?
     			close all
     			CopySve(cIme+"*.DB?",cStaza,cPath)
     			CopySve(cIme+"*.CDX",cStaza,cPath)
     			?
     			? "pritisni nesto za nastavak ..."
     			inkey(10)
     			restore screen from cScr
   		endif
  	endif
else
	cPath:=cStaza
endif

cPath:=cPath+cIme

use  (cPath)
return NIL

#else

function OKumul(nArea,cStaza,cIme,nIndexa,cDefault)
local cPath
local cScreen

if cDefault==nil
	cDefault:="0"
endif

select (nArea)

if Used()
	return
endif

// CAX - samo jednom otvori !!!!!!!!!!!!!!!!!

if gKesiraj $ "CD"
	cPath:=strtran(cStaza,LEFT(cStaza,3),gKesiraj+":"+SLASH)
	DirMak2(cPath)  // napravi odrediçni direktorij
	if cDefault!="0"
    		if !File(cPath+cIme+".DBF") .or. Pitanje(,"Osvjeziti podatke za "+cIme, cDefault )=="D"
     			save screen to cScr
     			cls
     			? "Molim sacekajte prenos podataka na vas racunar "
     			? "radi brzeg pregleda podataka"
     			?
     			? "Ovaj racunar NE KORISTITE za unos novih podataka !"
     			?
     			close all
     			CopySve(cIme+"*.DB?",cStaza,cPath)
     			CopySve(cIme+"*.CDX",cStaza,cPath)
     			?
     			? "pritisni nesto za nastavak ..."
     			inkey(10)
     			restore screen from cScr
   		endif
  	endif
else
	cPath:=cStaza
endif

cPath:=cPath+cIme

use (cPath)
return NIL

#endif


function LDPoljaINI()
*{
//sasa, 17.04.04, ako ne postoji LD.DBF preskoci ove parametre i idi na instalacju fajlova
if !FILE(KUMPATH+"LD.DBF")
	return
endif

O_LD

if ld->(fieldpos("S60"))<>0
	public cLDPolja:=60
elseif ld->(fieldpos("S50"))<>0
	public cLDPolja:=50
elseif ld->(fieldpos("S40"))<>0
	public cLDPolja:=40
elseif ld->(fieldpos("S30"))<>0
	public cLDPolja:=30
else
	public cLDPolja:=14
endif

if ld->(fieldpos("OBR"))<>0
	public lViseObr:=.t.
else
	public lViseObr:=.f.
endif

use
return
*}


function HelpObr(lIzv,cObracun)
*{
if lIzv==nil
	lIzv:=.f.
endif

if gNHelpObr=0
	Box(,3+IF(lIzv,1,0),40)
    		@ m_x+0, m_y+2 SAY PADC(" POMOC: ",36,"Í")
    		if lIzv
      			@ m_x+2, m_y+2 SAY "Ukucajte broj obracuna (1/2/.../9)"
      			@ m_x+3, m_y+2 SAY "ili prazno ako zelite sve obracune"
    		else
      			@ m_x+2, m_y+2 SAY "Ukucajte broj obracuna (1/2/.../9)"
    		endif
    		++gnHelpObr
endif
return .t.
*}



function ValObr(lIzv,cObracun)
*{
local lVrati:=.t.

if lIzv==nil
	lIzv:=.f.
endif

if lIzv
	lVrati:=(cObracun $ " 123456789" )
else
	lVrati:=(cObracun $ "123456789" )
endif

if gnHelpObr>0 .and. lVrati
	BoxC()
    	--gnHelpObr
endif

return lVrati
*}


function ClVBox()
*{

local i:=0
for i:=1 to gnHelpObr
	BoxC()
next
gnHelpObr:=0

return
*}



