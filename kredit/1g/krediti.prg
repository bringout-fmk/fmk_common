#include "\dev\fmk\ld\ld.ch"


//#define  RADNIK  radn->(padr(  trim(naz)+" ("+trim(imerod)+") "+ime,35))

function NoviKredit()
*{
local i
local cIdRadn:=SPACE(_LR_)
private nMjesec:=gMjesec
private nGodina:=gGodina
private cIdKred:=SPACE(_LK_)
private nIznKred:=0
private nRata:=0
private nRata2:=0
private cOsnov:=SPACE(20)

if Logirati(goModul:oDataBase:cName,"KREDIT","NOVIKREDIT")
	lLogNoviKredit:=.t.
else
	lLogNoviKredit:=.f.
endif

do while .t.
	OTblKredit()
	Box(,10,70)
  		@ m_x+1,m_y+2 SAY "Mjesec:" GET nMjesec pict "99"
  		@ m_x+1,col()+2 SAY "Godina:" GET nGodina pict "9999"
  		@ m_x+2,m_y+2 SAY "Radnik  :" GET cIdRadn  valid {|| P_Radn(@cIdRadn),setpos(m_x+2,m_y+20),qqout(trim(radn->naz)+" ("+trim(radn->imerod)+") "+radn->ime),.t.}
  		@ m_x+3,m_y+2 SAY "Kreditor:" GET cIdKred pict "@!" valid P_Kred(@cIdKred,3,21)
  		@ m_x+4,m_y+2 SAY "Kredit po osnovu:" GET cOsnov pict "@!"
  		@ m_x+5,m_y+2 SAY "Ukupan iznos kredita:" GET nIznKred pict "99"+gPicI
  		if IzFMKIni("LD","ZaNoviKreditUnositiBrojRata","N",KUMPATH)=="D"
    			lBrojRata:=.t.
    			@ m_x+7,m_y+2 SAY "Broj rata   :" GET nRata2 pict "9999" valid nRata2>0
  		else
    			lBrojRata:=.f.
    			@ m_x+7,m_y+2 SAY "Rata kredita:" GET nRata pict gpici valid nRata>0
  		endif
  		read
		ESC_BCR
	BoxC()
	
	if lBrojRata
  		nRata:=ROUND(nIznKred/nRata2,2)
  		if nRata*nRata2-nIznKred<0
    			nRata += 0.01
  		endif
	endif

	select radkr
	set order to 2
	//"2","idradn+idkred+naosnovu+str(godina)+str(mjesec)"

	seek cidradn+cIdkred+cosnov
	private nRec:=0
	if found()
  		if Pitanje(,"Stavke vec postoje. Zamijeniti novim podacima ?","D")=="N"
    			MsgBeep("Rate nisu formirane! Unesite novu osnovu kredita za zadanog kreditora!")
    			closeret
  		else
    			select radkr
    			do while !eof() .and. cidradn==idradn .and. cidkred==idkred .and. cosnov==naosnovu
      				skip
				nRec:=recno()
				skip -1
      				delete
      				go nRec
    			enddo
  		endif
	endif

	private nOstalo:=nIznKred
	nTekMj:=nMjesec
	nTekGodina:=nGodina

	i:=0
	nTekMj:=nMjesec-1
	
	do while .t.
		if nTeKMj+1>12
    			nTekMj:=1
    			++nTekGodina
  		else
   			nTekMj++
  		endif
  		nIRata:=nRata
  		if nIRata>0 .and. (nOstalo-nIRata<0)  // rata je pozitivna
    			nIRata:=nOstalo
  		endif
  		if nIRata<0 .and. (nOstalo-nIRata>0)  // rata je negativna
    			nIRata:=nOstalo
  		endif
  		if round(nIRata,2)<>0
   			append blank
   			replace idradn with cidradn, mjesec with nTekMj, Godina with nTekGodina,idkred with cidkred, iznos with nIRata, naosnovu with cOsnov
   			++i
  		endif

		nOstalo:=nOstalo-nIRata
  		if round(nOstalo,2)==0
    			exit
  		endif
	enddo
	
	if lLogNoviKredit
		EventLog(nUser,goModul:oDataBase:cName,"KREDIT","NOVIKREDIT",nIznKred,nil,nil,nil,"","",ALLTRIM(cIdRadn)+" rata:"+STR(i,3),Date(),Date(),"","Definisan novi kredit")
	endif
	
	private cDn:="N"
	Box(,5,60)
		set confirm off
  		@ m_x+1,m_y+2 SAY "Za radnika "+cIdRadn+" kredit je formiran na "+STR(i,3)+" rata"
  		@ m_x+3,m_y+2 SAY "Prikazati pregled kamata:" GET cDN pict "@!"
  		read
	BoxC()

	set confirm on

	close all

	if cDn=="D"
  		EditKredit(cIdRadn,cIdKred,cOsnov)
	endif

enddo

closeret
return
*}


function EditKredit
*{
parameters cIdRadn,cIdKred,cNaOsnovu
altd()
if pcount()==0
	cIdRadn:=space(_LR_)
  	cIdKRed:=space(_LK_)
  	cNaOsnovu:=space(20)
endif

OTblKredit()

select radkr
set order to 2

Box(,19,77)
	ImeKol:={}
	AADD(ImeKol,{"Mjesec",{|| mjesec}})
	AADD(ImeKol,{"Godina",{|| godina}})
	AADD(ImeKol,{"Iznos",{|| iznos}})
	AADD(ImeKol,{"Otplaceno",{|| placeno}})
	AADD(ImeKol,{"NaOsnovu",{|| naosnovu}})
	Kol:={}
	for i:=1 to LEN(ImeKol)
		AADD(Kol,i)
	next
	
	set cursor on

	@ m_x+1,m_y+2 SAY "KREDIT - pregled, ispravka"
	@ m_x+2,m_y+2 SAY "Radnik:   " GET cIdRadn  valid {|| P_Radn(@cIdRadn),setpos(m_x+2,m_y+20),qqout(trim(radn->naz)+" ("+trim(radn->imerod)+") "+radn->ime),P_Krediti(cIdRadn,@cIdKred,@cNaOsnovu),.t.}
	@ m_x+3,m_y+2 SAY "Kreditor: " GET cIdKred  valid P_Kred(@cIdKred,3,21) pict "@!"
	@ m_x+4,m_y+2 SAY "Na osnovu:" GET cNaOsnovu pict "@!"
	
	if pcount()==0
 		read
		ESC_BCR
	else
 		GetList:={}
	endif
	
	cNaOsnovu:=PADR(cNaOsnovu,LEN(radkr->naosnovu))
	
	BrowseKey(m_x+6,m_y+1,m_x+19,m_y+77,ImeKol,{|Ch| EddKred(Ch)},"idradn+idkred+naosnovu=cidradn+cidkred+cnaosnovu",cIdRadn+cIdKred+cNaOsnovu,2,,)
BoxC()

closeret
return
*}



function EddKred(Ch)
*{
local cDn:="N"
local nRet:=DE_CONT
local nRec:=RECNO()

if Logirati(goModul:oDataBase:cName,"KREDIT","EDITKREDIT")
	lLogEditKredit:=.t.
else
	lLogEditKredit:=.f.
endif

select radkr

do case
	case Ch==K_ENTER
       		scatter()
       		Box(,6,70)
         		@ m_x+1,m_y+2 SAY "Rucna prepravka rate !"
         		@ m_x+3,m_y+2 SAY "Iznos  " GET _iznos pict gpici
         		@ m_x+4,m_y+2 SAY "Placeno" GET _placeno pict gpici
          			// ernad 13.02.2001
          			cNaOsnovu2:=cNaOsnovu
          			@ m_x+6,m_y+2 SAY "Na osnovu" GET cNaOsnovu2
          			read
          			if cNaOsnovu2<>naosnovu .and. Pitanje(,"Zelite li promijeniti osnov kredita ? (D/N)","N")=="D"
           				SEEK cIdRadn+cIdKred+cNaOsnovu
           				DO WHILE !EOF() .and. idradn+idkred+naosnovu==cIdRadn+cIdKred+cNaOsnovu
             					SKIP 1
						nRecK:=RECNO()
						SKIP -1
             					Scatter("w")
						wNaOsnovu:=cNaOsnovu2
						Gather("w")
             					GO (nRecK)
           				ENDDO
           				_naosnovu:=cNaOsnovu:=cNaOsnovu2
          			endif
    			read
       		BoxC()
       		GO (nRec)
       		
		Gather()
       		
		if lLogEditKredit
			EventLog(nUser,goModul:oDataBase:cName,"KREDIT","EDITKREDIT",radkr->placeno,radkr->iznos,nil,nil,"","","Rad:"+ALLTRIM(cIdRadn),Date(),Date(),"","Rucna ispravka rate kredita za radnika")
		endif
		select radkr
		nRet:=DE_REFRESH
  	case Ch==K_CTRL_N
       		nRet:=DE_REFRESH
  	case Ch==K_CTRL_T
    		nRet:=DE_REFRESH
  	case Ch==K_CTRL_P
     		PushWa()
         	//StRjes(radkr->idradn,radkr->idkred,radkr->naosnovu)
     		PopWA()
     		nRet:=DE_REFRESH
  	case Ch==K_F10
  		nRet:=DE_REFRESH
endcase
return nRet
*}




function SumKredita()
*{
local fUsed:=.t.
PushWa()
select (F_RADKR)
if !Used()
	fUsed:=.f.
 	O_RADKR
endif
seek str(_godina,4)+str(_mjesec,2)+_idradn
nIznos:=0
do while !eof() .and. _godina==godina .and. _mjesec=mjesec .and. idradn=_idradn
	niznos+=iznos
  	replace Placeno with Iznos
 	skip
enddo
if !fUsed
	select radkr
	use
endif
PopWa()
return nIznos
*}


function Okreditu(_idradn, cIdkred, cNaOsnovu, _mjesec, _godina)
*{
// izbaci matricu vezano za kredit
local nUkupno, nPlaceno, nNTXORd
local fused:=.t.

PushWa()

select (F_RADKR)

altd()

if !used()
	fUsed:=.f.
 	O_RADKR
 	set order to 2
 	//"RADKRi2","idradn+idkred+naosnovu itd..."
else
 	nNTXORD:=indexord()
 	set order to 2
endif

seek _idradn + cIdkred + cNaOsnovu

nUkupno:=0
nPlaceno:=0

do while !eof() .and. idradn=_idradn .and. idkred=cIdKred .and. naosnovu==cNaOsnovu 
	nUkupno+=iznos
  	
	if (mjesec > _mjesec) .or. (godina > _godina)
		skip
		loop
	endif
	
	nPlaceno+=placeno
  
  	skip
enddo

if !fUsed
	select radkr
	use
else
	#ifdef C52
 		ordsetfocus(nNTXOrd)
	#else
 		set order to nNTXORd
	#endif
endif

PopWa()

return {nUkupno,nPlaceno}
*}




function ListaKredita() //lista kredita
*{
private fSvi  // izlistaj sva preduzeca

private nR:=nIzn:=nIznP:=0
private nUkIzn:=nUkIznP:=nUkIRR:=0
private nCol1:=10
private lRjRadn:=.f.
private cIdRj

O_KRED
O_RADN
if FIELDPOS("IDRJ")<>0
	lRjRadn:=.t.
	O_RJ
	cIdRj:="  "
endif
O_RADKR
private m:="----- "+replicate("-",_LR_)+" ------------------------------- "+replicate("-",39)

cIdKred:=space(_LK_)

cNaOsnovu:=padr(".",20)
cIdRadnaJedinica:=SPACE(2)
cGodina:=gGodina; cMjesec:=gmjesec
private cRateDN:="D", cAktivni:="D"
Box(,13,60)
 if lRjRadn
  @ m_x+1,m_y+2 SAY "RJ (prazno=sve): " GET cIdRj  valid {|| EMPTY(cIdRj) .or. P_Rj(@cIdRj)} pict "@!"
 endif
 @ m_x+2,m_y+2 SAY "Kreditor ('.' svi): " GET cIdKred  valid {|| cidkred='.' .or. P_Kred(@cIdKred)} pict "@!"
 @ m_x+3,m_y+2 SAY "Na osnovu ('.' po svim osnovama):" GET cNaOsnovu pict "@!"
 @ m_x+4,m_y+2 SAY "Prikazati rate kredita D/N/J/R/T:"
 @ m_x+5,m_y+2 SAY "D - prikazati sve rate"
 @ m_x+6,m_y+2 SAY "N - prikazati samo broj rata i ukupan iznos"
 @ m_x+7,m_y+2 SAY "J - samo jedna rata"
 @ m_x+8,m_y+2 SAY "R - partija,br.rata,iznos,rata,ostalo"
 @ m_x+9,m_y+2 SAY "T - trenutno stanje" GET cRateDN pict "@!" valid cRateDN $ "DNJRT"
 @ m_x+10,m_y+2 SAY "Prikazi samo aktivne-neotplacene kredite D/N" GET cAktivni pict "@!" valid cAktivni$"DN"
 read
 ESC_BCR
 if cRateDN $ "JR"
   @ m_x+12,m_y+2 SAY "Prikazati ratu od godina/mjesec:" GET cGodina pict "9999"
   @ m_x+12,col()+1 SAY "/" GET cMjesec pict "99"
   read; ESC_BCR
 endif
 if lRjRadn .and. EMPTY(cIdRj)
	lRazdvojiPoRj:=(Pitanje(,"Razdvojiti spiskove po radnim jedinicama? (D/N)","N")=="D")
 else
	lRazdvojiPoRj:=.f.
 endif
BoxC()
if trim(cNaOsnovu)=="."
   cNaOsnovu:=""
endif

select radkr
if lRazdvojiPoRj
	set relation to idradn into radn
	Box(,2,30)
		nSlog:=0
		nUkupno:=RECCOUNT2()
		cSort1:="radn->idRj+idKred+naOsnovu+idRadn"
		cFilt :=".t."
		if !cIdKred="."
			cFilt += ".and. idKred==cIdKred"
		endif
		INDEX ON &cSort1 TO "TMPRK" FOR &cFilt EVAL(TekRec2()) EVERY 1
	BoxC()
	go top
else // zadana je radna jedinica ili je prikaz svih rj na jednom spisku
	if lRjRadn .and. !empty(cIdRj)
		set relation to idradn into radn
		set filter to radn->idRj==cIdRj
	endif
	set order to 3
	//"RADKRi3","idkred+naosnovu+idradn"
	seek cIdKred+cNaOsnovu
endif

nRbr:=0

if cRateDN=="R"
	m+=REPL("-",16)
endif

if cidkred='.'
	fSvi:=.t.
  	go top
else
  	if !lRazdvojiPoRj .and. !found()
    		MsgBeep("Nema podataka!")
    		CLOSERET
  	endif
  	fSvi:=.f.
endif

START PRINT CRET

ZaglKred()
do while !eof()  // vrti ako je fsvi=.t. ili ako je lRazdvojiPoRj=.t.
	if lRazdvojiPoRj
		cIdTekRj:=radn->idRj
 		? 
		? "RJ:", radn->idRj, "-", Ocitaj(F_RJ,cIdTekRj,"naz")
 		? 
	endif
	cIdKred:=IdKred
	select kred
	hseek cIdKred
	select radkr	
	if fsvi
 		?
 		? StrTran(m,"-","*")
 		? gTS+":",cIdKred,kred->naz
 		? StrTran(m,"-","*")
	endif
	cOsn:=""
	nCol1:=20
	do while !eof() .and. idkred=cIdKred .and. naosnovu=cNaOsnovu .and. if(lRazdvojiPoRj,radn->idRj==cIdTekRj,.t.)
   		private cOsn:=naosnovu
   		cIdRadn:=idradn
  		nIzn:=nIznP:=0
   		if cAktivni=="D"
     			nTekRec := RECNO()
     			RKgod := RADKR->Godina
     			RKmjes := RADKR->Mjesec
     			do while !Eof() .and. idkred=cidkred .and. cosn==naosnovu .and. idradn==cidradn
				nIzn += RADKR->Iznos
        			nIznP += RADKR->Placeno
        			RKgod := RADKR->Godina
				RKmjes := RADKR->Mjesec
       				SKIP 1
     			enddo
     			if nIzn>nIznP .or. (nIzn==nIznP .and. RKgod==cGodina .and. RKmjes>=cMjesec)
       				go nTekRec
     			else
       				LOOP
     			endif
   		endif
		
		if cNaOsnovu=="" .and. cOsn<>naosnovu
     			?
    			? m
     			? "KREDIT PO OSNOVI:",naosnovu
     			? m
   		endif
		
		select radn
		hseek cidradn
   		select radkr
  		if prow()>60
			FF
			ZaglKred()
		endif
   		?
   		? str(++nRbr,4)+".",cIdRadn,RADNIK

  		if cRateDN == "D"
    			?? " Osnov:",cOsn,replicate("_",11)
   		endif
   		nR:=nIzn:=nIznP:=0
   		nCol1:=64
   		nIRR:=0
   		do while !eof() .and. idkred=cidkred .and. cosn==naosnovu .and. idradn==cidradn
			nKoef:=1
     
			if cRateDN<>"J" .or. (godina==cgodina .and. mjesec==cmjesec)
				++nR
				nIzn+=iznos*nKoef
				nIznP+=placeno
				if iznos*nKoef==0 .and. cRateDN=="R"
					--nR
				endif  // mozda i za sve var. ?!
				IF cMjesec==mjesec .and. cGodina==godina
					nIRR:=iznos*nKoef
				ENDIF
			endif

			if cRateDN=="D"
				? space(47),str(mjesec)+"/"+str(godina)
				nCol1:=pcol()+1
				@ prow(),pcol()+1 SAY iznos*nKoef pict gpici
			elseif cRateDN=="J"
				if godina==cgodina .and. mjesec==cmjesec
					?? "",str(mjesec)+"/"+str(godina)
					nCol1:=pcol()+1
					@ prow(),pcol()+1 SAY iznos*nKoef pict gpici
					@ prow(),pcol()+1 SAY "___________"
				endif
			endif
			skip 1
		enddo

		if cRateDN=="N"
			@ prow(),pcol()+1 SAY nR pict "9999"
			nCol1:=pcol()+1
			@ prow(),pcol()+1 SAY nIzn pict gpici
			@ prow(),pcol()+1 SAY "___________"
		endif

		if cRateDN=="T"
			@ prow(),pcol()+1 SAY ""
			nCol1:=pcol()+1
			@ prow(),pcol()+1 SAY nIzn pict gpici
			@ prow(),pcol()+1 SAY nIznP pict gpici
			@ prow(),pcol()+1 SAY nIzn-nIznP pict gpici
		endif

		if cRateDN=="R"
			@ prow(),pcol()+1 SAY cOsn
			@ prow(),pcol()+1 SAY nR pict "9999"
			nCol1:=pcol()+1
			@ prow(),pcol()+1 SAY nIzn pict gpici
			@ prow(),pcol()+1 SAY nIRR pict gpici
			@ prow(),pcol()+1 SAY nIzn-nIznP pict gpici
		endif

		nUkIzn+=nIzn
		nUkIznP+=nIznP
		nUkIRR+=nIRR
	enddo

	if prow()>62
		FF
		ZaglKred()
	endif

	? m
	? "UKUPNO:"
	@ prow(),nCol1 SAY nUkIzn pict gpici

	if cratedn=="T"
		@ prow(),pcol()+1 SAY nUkIznP  pict gpici
		@ prow(),pcol()+1 SAY nUkizn-nUkIznP  pict gpici
	endif

	if cratedn=="R"
		@ prow(),pcol()+1 SAY nUkIRR          pict gpici
		@ prow(),pcol()+1 SAY nUkizn-nUkIznP  pict gpici
	endif
	? m

	if !fsvi .and. !lRazdvojiPoRj
		exit
	endif

enddo  // eof()

FF
END PRINT

CLOSERET
return
*}



function ZaglKred()
*{
P_10CPI

if cRateDN=="R"
	? "LD, izvjestaj na dan:",date()
 	? "FIRMA   :",gNFirma
 	?
	if !fsvi
 		? "Kreditor:",cidkred,kred->naz
	endif
 	? "Ziro-r. :",kred->ziro
 	?
 	? PADC("DOJAVA KREDITA ZA MJESEC : "+STR(cMjesec)+". GODINE: "+STR(cGodina)+".",78)
else
 	? "LD: SPISAK KREDITA, izvjestaj na dan:",date()
	if !fsvi
 		? "Kreditor:",cidkred,kred->naz
	endif
 	if !(cNaOsnovu=="")
  		?? "   na osnovu:",cnaosnovu
 	endif
endif

if lRjRadn .and. !empty(cIdRj)
	? "RJ:", cIdRj, "-", Ocitaj(F_RJ,cIdRj,"naz")
endif

if cRateDN=="R"
	P_COND
else
	P_12CPI
endif

?
? m
if cRateDN=="N"
	? " Rbr *"+padc("Sifra ",_LR_)+"*    Radnik                         Br.Rata    Iznos      Potpis"
elseif cRateDN=="T"
  	? " Rbr *"+padc("Sifra ",_LR_)+"*    Radnik                           Ukupno       Placeno       Ostalo"
elseif cRateDN=="R"
  	? " Red.*"+padc(" ",_LR_)+"*                                  Partija kr.   Broj     Iznos                   Ostatak"
  	? " br. *"+padc("Sifra ",_LR_)+"*    Radnik                        (na osnovu)   rata     kredita      Rata         duga "
else
  	? " Rbr *"+padc("Sifra ",_LR_)+"*    Radnik                        Mjesec/godina/Rata"
endif
? m
return
*}




function P_Krediti
*{
parameters cIdRadn,cIdkred,cNaOsnovu
// Ponudi postojece kredite, i napuni cidkred, cnaosnovu
local i
private ImeKol

PushWa()

select radkr
set order to 2
//"2","idradn+idkred+naosnovu+str(godina)+str(mjesec)",KUMPATH+"RADKR")
set scope to (cIdRadn)

seek cIdRadn

private Imekol:={}
AADD(ImeKol, {"Kreditor",      {|| IdKred   } } )
AADD(ImeKol, {"Osnov",         {|| NaOsnovu } } )
AADD(ImeKol, {"Mjesec",        {|| mjesec   } } )
AADD(ImeKol, {"Godina",        {|| godina   } } )
AADD(ImeKol, {"Iznos",         {|| Iznos    } } )

Kol:={}

for i:=1 to LEN(ImeKol)
	AADD(Kol,i)
next

Box(,18,60)
	ObjDbedit("PKred",18,60,{|| EdP_Krediti()},"Postojece stavke za "+cidradn,"", , , , )
Boxc()

set scope to

PopwA()
return
*}



function EdP_Krediti()
*{
if Ch==K_ENTER
	cIdKred:=radkr->idkred
  	cNaOsnovu:=radkr->naosnovu
  	return DE_ABORT
endif

return DE_CONT
*}



/*! \fn Bez0(cStr)
 *  \brief vraca string varijablu bez nula (e.g. "00005"  -> "5")
 *  \param cStr - string
 */
 
function Bez0(cStr)
*{
local nSjeci
local i
local n0:=0

nSjeci:=1
for i:=1 to LEN(cStr)
	if SubStr(cStr,i,1) $ " 0"
        	nSjeci:=i+1
    	else
        	exit
    	endif
next
return SubStr(cStr,nSjeci)
*}



function Slovima(nIzn,cDINDEM)
*{
local nPom
local cRez:=""
lI:=.f.

if nIzn<0
	nIzn:=-nIzn
  	cRez:="negativno:"
endif

if (nPom:=INT(nIzn/10**9))>=1
	if nPom==1
     		cRez+="milijarda"
   	else
     		Stotice(nPom,@cRez,.f.,.t.,cDinDEM)
      		if Right(cRez,1) $ "eiou"
        		cRez+="milijarde"
      		else
        		cRez+="milijardi"
     		endif
   	endif
   	
	nIzn:=nIzn-nPom*10**9
   	lI:=.t.
endif

if (nPom:=int(nIzn/10**6))>=1
	if lI
		cRez+=""
	endif
   	lI:=.t.
   	if nPom==1
     		cRez+="milion"
   	else
     		Stotice(nPom,@cRez,.f.,.f.,cDINDEM)
     		cRez+="miliona"
   	endif
   	nIzn:=nIzn-nPom*10**6
   	l6:=.t.
endif

if (nPom:=int(nIzn/10**3))>=1
	if lI
		cRez+=""
	endif
   	lI:=.t.
   	if nPom==1
     		cRez+="hiljadu"
   	else
     		Stotice(nPom,@cRez,.f.,.t.,cDINDEM)
     		if Right(cRez,1) $ "eiou"
       			cRez+="hiljade"
     		else
       			cRez+="hiljada"
     		endif
   	endif
   	nIzn:=nIzn-nPom*10**3
endif

if lI .and. nIzn>=1
	cRez+=""
endif

Stotice(nIzn,@cRez,.t.,.t.,cDINDEM)

return
*}



function Stotice(nIzn,cRez,lDecimale,lMnozina,cDINDEM)
*{
local lDec
local lSto:=.f.
local i

if (nPom:=int(nIzn/100))>=1
	aSl:={ "stotinu", "dvijestotine", "tristotine", "~etiristotine","petstotina","{eststotina","sedamstotina","osamstotina","devetstotina"}
      	if gKodnaS=="8"
        	for i:=1 to len(aSL)
          		aSL[i]:=KSTo852(aSl[i])
        	next
      	endif
      	cRez+=aSl[nPom]
      	nIzn:=nIzn-nPom*100
      	lSto:=.t.
endif

lDec:=.f.
do while .t.
	if lDec
        	cRez+=alltrim(str(nIzn,2))
     	else
      		if INT(nIzn)>10 .and. INT(nIzn)<20
        		aSl:={"jedanaest","dvanaest","trinaest","cetrnaest","petnaest","sesnaest","sedamnaest","osamnaest","devetnaest"}
        		if gKodnaS=="8"
          			for i:=1 to len(aSL)
            				aSL[i]:=KSTo852(aSl[i])
          			next
        		endif
        		cRez+=aSl[int(nIzn)-10]
        		nIzn:=nIzn-int(nIzn)
      		endif
      		if (nPom:=int(nIzn/10))>=1
        		aSl:={ "deset", "dvadeset", "trideset", "cetrdeset","pedeset","sezdeset","sedamdeset","osamdeset","devedeset"}
        		if gKodnaS=="8"
          			for i:=1 to len(aSL)
            				aSL[i]:=KSTo852(aSl[i])
          			next
        		endif
        		cRez+=aSl[nPom]
        		nIzn:=nIzn-nPom*10
      		endif
      		if (nPom:=int(nIzn))>=1
         		aSl:={ "jedan", "dva", "tri", "cetiri","pet","sest","sedam","osam","devet"}
			if gKodnaS=="8"
          			for i:=1 to len(aSL)
            				aSL[i]:=KSTo852(aSl[i])
          			next
         		endif
        		if lMnozina
             			aSl[1]:="jedna"
             			aSl[2]:="dvije"
        		endif
        		cRez+=aSl[nPom]
        		nIzn:=nIzn-nPom
      		endif
      		
		if !lDecimale
			exit
		endif
	endif // ldec
     	
	if lDec
		cRez+="/100 "+cDINDEM
		exit
	endif
     	
	lDec:=.t.
     	lMnozina:=.f.
     	nIzn:=Round(nIzn*100,0)
     	
	if nIzn>0
       		if !empty(cRez)
           		cRez+=" i "
       		endif
     	else
       		if empty(cRez)
          		cRez:="nula DEM"
       		else
          		cRez+=" "+cDINDEM
       		endif
       		exit
     	endif
enddo

return cRez
*}





/*! \fn GodMjesec(nGodina,nMjesec,nPomak)
 *  \brief eg. GodMjesec(2002,4,-6) -> {2001,10}
 *  \param nGodina
 *  \param nMjesec
 *  \param nPomak
 */
 
function GodMjesec(nGodina,nMjesec,nPomak)
*{
local nPGodina
local nPMjesec
local nVgodina:=0

if nPomak<0  // vrati se unazad
	nPomak:=ABS(nPomak)
   	nVGodina:=INT(nPomak/12)
   	nPomak:=nPomak%12
   	if nMjesec-nPomak<1
      		nPGodina:=nGodina-1
      		nPMjesec:=12+nMjesec-nPomak
   	else
      		nPGodina:=nGodina
      		nPMjesec:=nMjesec-nPomak
   	endif
   	nPGodina:=nPGodina-nVGodina
else
	nVGodina:=INT(nPomak/12)
   	nPomak:=nPomak%12
   	if nMjesec+nPomak>12
      		nPGodina:=nGodina+1
      		nPMjesec:=nMjesec+nPomak-12
   	else
      		nPGodina:=nGodina
      		nPMjesec:=nMjesec+nPomak
   	endif
   	nPGodina:=nPGodina+nVGodina
endif
return {nPGodina,nPMjesec}
*}




function DatADD(dDat,nMjeseci,nGodina)
*{
local aRez
local cPom:=""

aRez:=GodMjesec(Year(dDat),Month(dDat),nMjeseci+12*nGodina)
cPom:=STR(aRez[1],4)
cPom+=PADL(ALLTRIM(STR(aRez[2],2)),2,"0")
cPom+=PADL(ALLTRIM(STR(Day(dDat),2)),2,"0")

return STOD(cPom)
*}




/*! \fn DatRazmak(dDatDo,dDatOd,nMjeseci,nDana)
 *  \brief Datumski razmak izrazen u: mjeseci, dana. Poziv: DatRazmak("15.07.2002","05.06.2001",@nMjeseci,@nDana)
 *  \param 
 *  \param
 *  \param
 *  \param
 */
function DatRazmak(dDatDo,dDatOd,nMjeseci,nDana)
*{
local aRez
local cPom:=""
local lZadnjiDan:=.f.

nMjeseci:=0
nDana:=0
dNextMj:=dDatOd
i:=0

if Day(dDatOd)=LastDayOM(dDatOd)
	lZadnjiDan:=.t.
endif

if Month(dDatDo)==Month(dDatOd) .and. Day(dDatDo)=Day(dDatOd)
	//isti mjesec, isti dan
  	nMjeseci:=(Year(dDatDo)-Year(dDatOd))*12
  	nDana:=0
  	return
endif

do while .t.  // predvidjen je razmak do 36 mjeseci
	if Month(dNextMj)=Month(dDatDO) .and. Year(dNextMj)=Year(dDatDo)
       		// uletili smo u isti mjesec
       		nDana:=Day(dDatDo)-Day(dNextMj)
       		if nDana<0  // moramo se vratiti mjesec unazad
          		dNextMj:=AddMonth(dNextMj,-1)
          		--nMjeseci
          		if nMjeseci=0  //samo dva krnjava mjeseca
             			nDana:=(Day(EOM(dDatOd))-Day(dDatOd)+1)+Day(dDatDo)-1
          		else
             			nDana:=(Day(EOM(dNextMj))-Day(dDatOd)+1)+Day(dDatDo)-1
          		endif
       		elseif nDana>=0
       			// not implemented
		endif
       		exit
   	endif
	
	dNextMj:=AddMonth(dNextMj,1)
   	
	if lZadnjiDan  // zadnji dan u mjesecu
       		dNextMj:=eom(dNextMj)
   	endif
	
	nMjeseci++
   	++i
   	if i>200
      		MsgBeep("jel to neko lud ovdje ?")
      		exit
   	endif
enddo
return
*}


/*! \fn DanaUMjesecu(dDatum)
 *  \brief Koliko ima dana u mjesecu
 */
function DanaUmjesecu(dDatum)
*{
local nDatZM
nDatZM:=EOM(dDatum)
return Day(nDatZM)
*}



/*! \fn DatZadUMjesecu(dDatum)
 *  \brief Vraca datum zadnjed u mjesecu
 *  \param dDatum
 */
 
function DatZadUMjesecu(dDatum)
*{
local nDana
local dPoc

dPoc:=dDatum
nDana:=Day(dDatum)
do while .t.
	dDatum++
   	if Month(dPoc)=Month(dDatum)
      		nDana:=Day(dDatum)
   	else
      		exit  // uletio sam usljedeci mjesec
   	endif
enddo
return dDatum-1  // vrati se unazad
*}



/*! \fn BrisiKredit()
 *  \brief Brisanje kredita za nekog radnika
 */
function BrisiKredit()
*{
cIdRadn:=SPACE(_LR_)
cIdKRed:=SPACE(_LK_)
cNaOsnovu:=SPACE(20)
cBrisi:="N"
 
if Logirati(goModul:oDataBase:cName,"KREDIT","BRISIKREDIT")
	lLogBrisiKredit:=.t.
else
 	lLogBrisiKredit:=.f.
endif

OTblKrediti()

set order to 2

Box("#BRISANJE NEOTPLACENIH RATA KREDITA",9,77)
	@ m_x+2,m_y+2 SAY "Radnik:   " GET cIdRadn  valid {|| P_Radn(@cIdRadn),setpos(m_x+2,m_y+20),qqout(trim(radn->naz)+" ("+trim(radn->imerod)+") "+radn->ime),P_Krediti(cIdRadn,@cIdKred,@cNaOsnovu),.t.}
  	@ m_x+3,m_y+2 SAY "Kreditor: " GET cIdKred  valid P_Kred(@cIdKred,3,21) pict "@!"
  	@ m_x+4,m_y+2 SAY "Na osnovu:" GET cNaOsnovu pict "@!"
  	@ m_x+6, m_y+2, m_x+8, m_y+76 BOX "         " COLOR "GR+/R"
  	@ m_x+7,m_y+8 SAY "Jeste li 100% sigurni da zelite izbrisati ovaj kredit ? (D/N)" COLOR "GR+/R"
  	@ row(), col()+1 GET cBrisi VALID cBrisi$"DN" PICT "@!" COLOR "N/W"
  	read
	ESC_BCR
BoxC()

if cBrisi=="D"
	SELECT RADKR
   	SET ORDER TO TAG "2" // idradn+idkred+naosnovu+str(godina)+str(mjesec)
   	SEEK cIdRadn+cIdKred+cNaOsnovu
   	nStavki:=0
   	DO WHILE !EOF() .and. idradn+idkred+naosnovu==cIdRadn+cIdKred+cNaOsnovu
     		SKIP 1
		nRec:=RECNO()
		SKIP -1
     		IF placeno=0
       			++nStavki
       			DELETE
     		ENDIF
     		GO (nRec)
   	ENDDO
   	IF nStavki>0
     		if lLogBrisiKredit
     			EventLog(nUser,goModul:oDataBase:cName,"KREDIT","BRISIKREDIT",nil,nil,nil,nil,"",ALLTRIM(STR(nStavki)),ALLTRIM(cIdRadn),Date(),Date(),"","Obrisan kredit")
     		endif
     		MsgBeep("Sve neotplacene rate (ukupno "+ALLTRIM(STR(nStavki))+") kredita izbrisane!")
   	ELSE
     		MsgBeep("Nista nije izbrisano. Za izabrani kredit ne postoje neotplacene rate!")
   	ENDIF
ENDIF

CLOSERET
return
*}


function OTblKredit()
*{
O_RJ
O_KRED
O_STRSPR
O_OPS
O_RADN
O_RADKR
return
*}

