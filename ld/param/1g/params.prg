#include "\cl\sigma\fmk\ld\ld.ch"
#include "\cl\sigma\fmk\ld\cdx\rddinit.ch"

function SetFirma()
*{
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
*}


function SetForma()
*{
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
*}

function SetFormule()
*{
private GetList:={}

Box(,14,77)
	gFURaz:=PADR(gFURaz,100)
      	gFUPrim:=PADR(gFUPrim,100)
      	gFUSati:=PADR(gFUSati,100)
      	gFURSati:=PADR(gFURSati,100)
      	@ m_x+1,m_y+2 SAY "Formula za ukupna primanja:" GET gFUPrim  pict "@!S30"
      	@ m_x+3,m_y+2 SAY "Formula za ukupno sati    :" GET gFUSati  pict "@!S30"
      	@ m_x+5,m_y+2 SAY "Formula za godisnji       :" GET gFUGod pict "@!S30"
      	@ m_x+7,m_y+2 SAY "Formula za uk.prim.-razno :" GET gFURaz pict "@!S30"
      	@ m_x+9,m_y+2 SAY "Formula za uk.sati -razno :" GET gFURSati pict "@!S30"
      	@ m_x+11,m_y+2 SAY "God. promjena koef.min.rada - ZENE:" GET gMRZ   pict "9999.99"
      	@ m_x+12,m_y+2 SAY "God. promjena koef.min.rada - MUSK:" GET gMRM   pict "9999.99"
      	@ m_x+14,m_y+2 SAY "% prosjecne plate kao donji limit neta za obracun poreza i doprinosa" GET gPDLimit pict "999.99"
      	read
BoxC()

if (LastKey()<>K_ESC)
	Wpar("gd",gFUGod)
      	WPar("m1", @gMRM)
      	WPar("m2", @gMRZ)
      	WPar("dl", @gPDLimit)
      	Wpar("uH",@gFURSati)
      	Wpar("uS",@gFUSati)
      	Wpar("up",gFUPrim)
      	Wpar("ur",gFURaz)
endif

return
*}


function SetObracun()
*{
private GetList:={}

cVarPorol:=PADR(cVarPorol,2)

Box(,10,77)
	@ m_x+1,m_y+2 SAY "Tip obracuna " GET gTipObr
      	@ m_x+2,m_y+2 SAY "Mogucnost unosa mjeseca pri obradi D/N:" GET gUnMjesec  pict "@!" valid glistic $ "DN"
      	@ m_x+3,m_y+2 SAY "Koristiti set formula (sifrarnik Tipovi primanja):" GET gSetForm pict "9" valid V_setform()
      	@ m_x+4,m_y+2 SAY "Minuli rad  %/B:" GET gMinR  valid gMinR $ "%B"   pict "@!"
      	@ m_x+5,m_y+2 SAY "Pri obracunu napraviti poreske olaksice D/N:" GET gDaPorOl  valid gDaPorOl $ "DN"   pict "@!"
      	@ m_x+6,m_y+2 SAY "Ako se prave por.ol.pri obracunu, koja varijanta se koristi:"
      	@ m_x+7,m_y+2 SAY " '1' - POROL = RADN->porol*PAROBR->prosld/100 ÄÄ¿  "
      	@ m_x+8,m_y+2 SAY " '2' - POROL = RADN->porol, '29' - LD->I29    ÄÄÁÄ>" GET cVarPorOl WHEN gDaPorOl=="D"   PICT "99"

      	@ m_x+9,m_y+2 SAY "Grupe poslova u specif.uz platu (1-automatski/2-korisnik definise):" GET gVarSpec  valid gVarSpec $ "12" pict "9"
      	@ m_x+10,m_y+2 SAY "Obrada sihtarice ?" GET gSihtarica valid gSihtarica $ "DN" pict "@!"
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
endif

return
*}



function SetPrikaz()
*{
private GetList:={}

Box(,7,77)
	@ m_x+1,m_y+2 SAY "Krediti-rekap.po 'na osnovu' (D/N/X)?" GET gReKrOs VALID gReKrOs $ "DNX" PICT "@!"
      	@ m_x+2,m_y+2 SAY "Na kraju obrade odstampati listic D/N:" GET gListic  pict "@!" valid glistic $ "DN"
      	@ m_x+3,m_y+2 SAY "Prikaz bruto iznosa na kartici radnika (D/N/X) " GET gPrBruto pict "@!" valid gPrBruto $ "DNX"
      	@ m_x+4,m_y+2 SAY "Potpis na kartici radnika D/N:" GET gPotp  valid gPotp $ "DN"   pict "@!"
      	@ m_x+5,m_y+2 SAY "Varijanta kartice plate za kredite (1/2) ?" GET gReKrKP VALID gReKrKP$"12"
      	@ m_x+6,m_y+2 SAY "Opis osnovnih podataka za obracun (1-bodovi/2-koeficijenti) ?" GET gBodK VALID gBodK$"12"
      	@ m_x+7,m_y+2 SAY "Pregled plata: varijanta izvjestaja (1/2)" GET gVarPP VALID gVarPP$"12"
      	read
BoxC()

if (LastKey()<>K_ESC)
	Wpar("bk",gBodK)
      	Wpar("kp",gReKrKP)
      	Wpar("pp",gVarPP)
      	Wpar("li",gListic)
      	WPar("pb", gPrBruto)   // set formula
      	WPar("po", gPotp)   // potp4is na listicu
      	Wpar("rk",gReKrOs)
      	//Wpar("tB",gTabela)
endif

return
*}



function SetRazno()
*{
private GetList:={}

Box(, 3,60)
	@ m_x+ 2,m_y+2 SAY "Fajl obrasca specifikacije" GET gFSpec VALID V_FSpec()
      	read
BoxC()

if (LastKey()<>K_ESC)
	WPar("os", @gFSpec)   // fajl-obrazac specifikacije
endif

return
*}


function V_SetForm()
*{
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
*}


/*
function SkloniSezonu(cSezona,fInverse,fDa,fNulirati,fRS)
*{
local cScr

if fDa==nil
	fDa:=.f.
endif

if fInverse==nil
	fInverse:=.f.
endif

if fNulirati==nil
	fNulirati:=.f.
endif

if fRs==nil
	// mrezna radna stanica , sezona je otvorena
  	fRs:=.f.
endif

if fRs // radna stanica
	if File(PRIVPATH+cSezona+SLASH+"_RADKR.DBF")
      	// nema se sta raditi ......., pripr.dbf u sezoni postoji !
      		return
	endif
  	aFilesK:={}
  	aFilesS:={}
  	aFilesP:={}
endif

save screen to cScr

cls
?
if fInverse
	? "Prenos iz  sezonskih direktorija u radne podatke"
else
	? "Prenos radnih podataka u sezonske direktorije"
endif

?
// privatni
fNul:=.f.

Skloni(PRIVPATH,"PARAMS.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"_RADN.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"_RADKR.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"_OPSLD.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"_KRED.DBF",cSezona,finverse,fda,fnul)
Skloni(PRIVPATH,"_PRIPNO.DBF",cSezona,finverse,fda,fnul)

if fNulirati
	fNul:=.t.
else
	fNul:=.f.
endif  // kumulativ datoteke

Skloni(PRIVPATH,"LDSM.DBF",cSezona,finverse,fda,fnul)

if fRs
	// mrezna radna stanica!!! , baci samo privatne direktorije
 	?
 	?
 	?
 	Beep(4)
 	? "pritisni nesto za nastavak.."
 	restore screen from cScr
 	return
endif

fNul:=.f.

Skloni(KUMPATH,"RADN.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"RADKR.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"RJ.DBF",cSezona,finverse,fda,fnul)
Skloni(KUMPATH,"LD.DBF",cSezona,finverse,fda,fnul)

fNul:=.f.

Skloni(SIFPATH,"PAROBR.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"KRED.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"OPS.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"POR.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"DOPR.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"STRSPR.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"KBENEF.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"VPOSLA.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"TIPPR.DBF",cSezona,finverse,fda,fnul)
//if lViseObr
Skloni(SIFPATH,"TIPPR2.DBF",cSezona,finverse,fda,fnul)
//endif
Skloni(SIFPATH,"SIFK.DBF",cSezona,finverse,fda,fnul)
Skloni(SIFPATH,"SIFV.DBF",cSezona,finverse,fda,fnul)

//sifrarnici
?
?
?
Beep(4)
? "pritisni nesto za nastavak.."

restore screen from cScr
return
*}
*/


function PrenosLD()
*{
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



