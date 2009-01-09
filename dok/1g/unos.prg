#include "ld.ch"

// ------------------------------------------------------
// unos obracuna plate
// ------------------------------------------------------
function Unos()
local lSaveObracun
private lNovi
private lRadniSati
private GetList
private cIdRadn
private nPlacenoRSati

cIdRadn:=SPACE(_LR_)
GetList:={}
cRj:=gRj
nGodina:=gGodina
nMjesec:=gMjesec

if GetObrStatus(cRj,nGodina,nMjesec)$"ZX"
	MsgBeep("Obracun zakljucen! Ne mozete vrsiti ispravku podataka!!!")
	return
elseif GetObrStatus(cRj,nGodina,nMjesec)=="N"
	MsgBeep("Nema otvorenog obracuna za "+ALLTRIM(STR(nMjesec))+"."+ALLTRIM(STR(nGodina)))
	return
endif

lRadniSati:=(IzFmkIni("LD","RadniSati","N",KUMPATH)=="D")

do while .t.
	
	lSaveObracun:=.f.
	
	PrikaziBox(@lSaveObracun)

	if (lSaveObracun)
  		select ld
		cIdRadn:=field->idRadn
		if (_UIznos<0)
    			Beep(2)
    			Msg(Lokal("Radnik ne moze imati platu u negativnom iznosu!!!"))
  		endif
  		nPom:=0
  		for i:=1 to cLDPolja
     			cPom:=PADL(ALLTRIM(STR(i)),2,"0")
     			nPom+=ABS(_i&cPom) + ABS(_s&cPom)  // ako su sve nule
  		next
  		
		if (nPom <> 0)
			
			// upisi tekucu varijantu obracuna
			_varobr := gVarObracun
			
			Gather()

     		else
     			if lNovi
        			delete
     			endif
  		endif

		if gListic=="D"
    			if lViseObr
      				KartPl(cRj,nMjesec,nGodina,cIdRadn,gObracun)
    			else
      				KartPl(cRj,nMjesec,nGodina,cIdRadn)
    			endif
  		endif

	else 
		//K_ESC
  		
		if lNovi  // ako je novi zapis  .and. ESCAPE
     			delete
  		endif
  		
		return
		
	endif

	select ld
	use  
	// svaki put zatvoriti tabelu ld

	Beep(1)

enddo // do while .t.
return



function QQOUTC(cTekst,cBoja)
*{
@ ROW(),COL() SAY cTekst COLOR cBoja
return
*}


function OObracun()
*{
O_LD
O_PAROBR
O_RADN
O_VPOSLA
O_STRSPR
O_DOPR
O_POR
O_KBENEF
O_OPS
O_RJ
O_RADKR
O_KRED
if lRadniSati
	O_RADSAT
endif
if (IsRamaGlas())
	O_RADSIHT
	O_RNAL
endif

return
*}


function PrikaziBox(lSaveObracun)
*{
private cIdRj
private cGodina
private cIdRadn
private cMjesec

cIdRadn:=SPACE(6)
cIdRj:=gRj
cMjesec:=gMjesec
cGodina:=gGodina
cObracun:=gObracun

if gAHonorar == "D"
	cIzdanje := SPACE(10)
	if gIzdanje <> nil .and. !EMPTY(gIzdanje)
		cIzdanje := gIzdanje
	endif
endif

if Logirati("LD","DOK","UNOS")
	lLogUnos:=.t.
else
	lLogUnos:=.f.
endif

OObracun()

if lViseObr
	O_TIPPRN
else
	O_TIPPR
endif

lNovi:=.f.

Box(,21,77)
	@ m_x+1,m_y+2 SAY Lokal("Radna jedinica: ")
	QQOutC(cIdRJ,"GR+/N")
	if gUNMjesec=="D"
 		@ m_x+1,col()+2 SAY Lokal("Mjesec: ")  GET cMjesec pict "99"
	else
 		@ m_x+1,col()+2 SAY Lokal("Mjesec: ")
		QQOutC(str(cMjesec,2),"GR+/N")
	endif

	if lViseObr
 		if gUNMjesec=="D"
  			@ m_x+1,col()+2 SAY Lokal("Obracun: ") GET cObracun WHEN HelpObr(.f.,cObracun) VALID ValObr(.f.,cObracun)
 		else
  			@ m_x+1,col()+2 SAY Lokal("Obracun: ")
			QQOutC(cObracun,"GR+/N")
 		endif
	endif

	@ m_x+1,COL()+2 SAY Lokal("Godina: ")
	QQOutC(str(cGodina,4),"GR+/N")
	
	@ m_x+2,m_y+2 SAY Lokal("Radnik:") GET cIdRadn ;
	  VALID {|| P_Radn(@cIdRadn), SetPos(m_x+2,m_y+17), ;
	  QQOUT(PADR( TRIM(radn->naz)+" ("+TRIM(radn->imerod)+") "+TRIM(radn->ime), 28 )), .t.}
	
	if gAHonorar == "D"
		@ m_x+2,m_y+45 SAY Lokal("Izd:") GET cIzdanje valid {|| p_izdanja(@cIzdanje), SetPos(m_x+2,m_y+61), QQOUT(PADR(TRIM(izdanja->iz_naz)+" br." + trim(izdanja->iz_broj), 13)),.t.}
	endif
	
	read
	
	clvbox()
	ESC_BCR

	select radn
	select ld
	
	if gAHonorar == "D"
		seek STR(cGodina,4)+cIdRj+str(cMjesec,2)+cIzdanje+cIdRadn
	else
		seek STR(cGodina,4)+cIdRj+str(cMjesec,2)+IF(lViseObr,cObracun,"")+cIdRadn
	endif
	
	if found()
  		lNovi:=.f.
  		scatter()
		if gAHonorar == "D"
			gIzdanje := _izdanje
		endif
	else
		lNovi:=.t.
  		append blank
  		Scatter()
  		_Godina:=cGodina
  		_idrj:=cIdRj
		_idradn:=cIdRadn
		_mjesec:=cMjesec
  		if lViseObr
			_obr := cObracun
		endif
		if gAHonorar == "D"
			_izdanje := cIzdanje
			gIzdanje := cIzdanje
		endif
	endif

	if lNovi
		_brbod:=radn->brbod
		_kminrad:=radn->kminrad
		_idvposla:=radn->idvposla
		_idstrspr:=radn->idstrspr
	endif

	ParObr(cMjesec,IF(lViseObr,cObracun,),cIdRj)  
	// podesi parametre obracuna za ovaj mjesec
	
	if gTipObr=="1"
 		@ m_x+3,m_y+2   SAY IF(gBodK=="1", Lokal("Broj bodova"), Lokal("Koeficijent")) GET _brbod pict "99999.99" valid FillBrBod()
	else
 		@ m_x+3,m_y+2   SAY Lokal("Plan.osnov ld") GET _brbod pict "99999.99" valid FillBrBod()
	endif
	select ld
	@ m_x+3,col()+2 SAY IF(gBodK=="1", Lokal("Vrijednost boda"), Lokal("Vr.koeficijenta")); @ row(),col()+1 SAY parobr->vrbod  pict "99999.99999"
	if gMinR=="B"
 		@ m_x+3,col()+2 SAY Lokal("Minuli rad (bod)") GET _kminrad pict "9999.99" valid FillKMinRad()
	else
 		@ m_x+3,col()+2 SAY Lokal("Koef.minulog rada") GET _kminrad pict "99.99%" valid FillKMinRad()
	endif
	@ m_x+4,m_y+2 SAY Lokal("Vrsta posla koji radnik obavlja") GET _IdVPosla valid (empty(_idvposla) .or. P_VPosla(@_IdVPosla,4,43)) .and. FillVPosla()
	read
	if (IsRamaGlas() .and. RadnikJeProizvodni())
		UnosSatiPoRNal(cGodina,cMjesec,cIdRadn)
	endif
	if lRadniSati
		@ m_x+4,m_y+59 SAY "R.sati:" GET _radSat
	endif
	
	read
	
	if lRadniSati
		FillRadSati(cIdRadn,_radSat)
	endif
	
	if gSihtarica=="D"
		UzmiSiht()
	endif 

	PrikUnos()
	
	if gAHonorar == "D"
		
		_USati:=0
		_UNeto:=0
		_UOdbici:=0
		_UNeto2 := 0
		_UBruto2 := 0
		_ULicOdb := 0

		UkRadnik()  	

		if izr_honorar( cIdRadn, .t. ) == .f.
			lSaveObracun := .f.
			BoxC()
			return
		endif

	endif
	
	PrikUkupno(@lSaveObracun)
		
	if lLogUnos
		if lNovi
			EventLog(nUser,goModul:oDataBase:cName,"DOK","UNOS",ld->uiznos,nil,nil,nil,STR(cMjesec,2),ALLTRIM(cIdRadn),STR(cGodina,4),Date(),Date(),"", Lokal("Obracunata plata za radnika"))
		else
			EventLog(nUser,goModul:oDataBase:cName,"DOK","UNOS",ld->uiznos,nil,nil,nil,STR(cMjesec,2),ALLTRIM(cIdRadn),STR(cGodina,4),Date(),Date(),"", Lokal("Korekcija obracuna za radnika"))
		endif
	endif

BoxC()
return



// ----------------------------------
// ispisuje ukupno na dnu obracuna
// ----------------------------------
function PrikUkupno(lSaveObracun)

_USati:=0
_UNeto:=0
_UOdbici:=0

UkRadnik()  
// filuje _USati,_UNeto,_UOdbici	

_UIznos := _UNeto + _UOdbici

if gVarObracun == "2"

	
	altd()

	nKLO := radn->klo
	cTipRada := radn->tiprada

	// daj bruto i licni odbitak
	_ULicOdb := gOsnLOdb * nKLO
	
	// bruto osnova
	_UBruto2 := bruto_osn( _UNeto, cTipRada, _ULicOdb ) 

	// uiznos je sada sa uracunatim brutom i ostalim
	
	// ukupno doprinosi IZ place
	nUDoprIZ := u_dopr_iz( _Ubruto2, cTipRada )
	
	// poreska osnovica
	nPorOsnovica := ( (_UBruto2 - nUDoprIz) - _ulicodb )
	
	// porez
	nPorez := izr_porez( nPorOsnovica, "B" )
		
	_uiznos := ((_UBruto2 - nUDoprIz) - nPorez ) + _UOdbici
	
endif

@ m_x+19,m_y+2 SAY "Ukupno sati:"
@ row(),col()+1 SAY _USati PICT gPics

if gVarObracun == "2"
	@ m_x+19,col()+2 SAY "Koef.lic.odb.:"
	@ row(),col()+1 SAY _ULicOdb PICT gPici
endif

@ m_x+20,m_y+2 SAY "Primanja:"
@ row(),col()+1 SAY _UNeto PICT gPici
@ m_x+20,col()+2 SAY "Odbici:"
@ row(),col()+1 SAY _UOdbici PICT gPici
@ m_x+20,col()+2 SAY "UKUPNO ZA ISPLATU:"
@ row(),col()+1 SAY _UIznos PICT gPici
@ m_x+22,m_y+10 SAY "Pritisni <ENTER> za snimanje, <ESC> napustanje"

Inkey(0)

do while LastKey()<>K_ESC .and. LastKey()<>K_ENTER
	Inkey(0)
enddo

if LastKey()==K_ESC
	MsgBeep("Obracun nije pohranjen !!!")
	lSaveObracun:=.f.
else
	MsgBeep("Obracun je pohranjen !!!")
	lSaveObracun:=.t.
endif

return



// --------------------------
// obrada sihtarice
// --------------------------
function UzmiSiht()

O_PARAMS

private cZadnjiRadnik:=cIdRadn
private cSection:="S"

RPar("zr",@cZadnjiRAdnik)

O_RADSIHT
select radsiht
seek str(_godina,4)+str(cmjesec,2)+cZadnjiRadnik+cIdRj
if found() // ovaj je radnik fakat radjen
	seek str(_godina,4)+str(cmjesec,2)+cidradn+cIdRj
	if !found()
	// ako je ovaj radnik vec radjen ne pitaj nista za preuzimanje
		if pitanje(,'Zelite li preuzeti sihtaricu od radnika '+cZadnjiRadnik+' D/N','D')=='D'
			select radsiht
			seek str(_godina,4)+str(cmjesec,2)+cZadnjiRadnik+cIdRj
			private nTSrec:=0
			do while !eof() .and. (str(godina,4)+str(mjesec,2)+idradn+IdRj)==(str(_godina,4)+str(cmjesec,2)+cZadnjiRadnik+cIdRj)
				skip
				nTSrec:=recno()
				skip -1
				Scatter('w')
				wIdRadn:=cidradn  
				// sve je isto osim sifre radnika
				append blank
				Gather('w')
				go nTSrec
			enddo
		endif // pitanje
	endif
endif

Unossiht()

select params
private cSection:="S"
select radsiht
seek str(_godina,4)+str(cmjesec,2)+cIdRadn+cIdRj
if found()  // nesto je bilo u sihtarici
	select params
	cZadnjiRadnik:=cIdRadn
	WPar("zr",cZadnjiRAdnik)
endif

select params
use
select radsiht
use

return

// ------------------------------------------------
// unos tipova primanja
// ------------------------------------------------
function PrikUnos()
local i
private cIdTP:="  "
private nRedTP:=4
private cVarTP
private cIznosTP
cTipPrC:=" "

for i:=1 to cLDPolja
	if i < 10
		cIdTP:="0" + ALLTRIM(STR(i))
		cVarTP:="_S0"+ALLTRIM(STR(i))
		cIznosTP:="_I0"+ALLTRIM(STR(i))
		cPoljeIznos:="I0"+ALLTRIM(STR(i))
		cPoljeSati:="S0"+ALLTRIM(STR(i))
	else
		cIdTP:=ALLTRIM(STR(i))
		cVarTP:="_S"+ALLTRIM(STR(i))
		cIznosTP:="_I"+ALLTRIM(STR(i))
		cPoljeIznos:="I"+ALLTRIM(STR(i))
		cPoljeSati:="S"+ALLTRIM(STR(i))
	endif
	
	nRedTP++
	
	select tippr
	seek cIdTP
	select ld
	
	if LD->(FieldPos(cPoljeIznos)=0) .and. LD->(FieldPos(cPoljeSati)=0)
		MsgBeep("Broj polja u LD -> 30, potrebna modifikacija struktura !!!")
		return	
	endif
	
	cW:="WhUnos("+cm2str(cIdTp)+")"
	cV:="Izracunaj(@"+cIznosTP+")"

	if (tippr->(FOUND()) .and. tippr->aktivan=="D")
		if (tippr->fiksan $ "DN")
      			@ m_x+nRedTP,m_Y+2 SAY tippr->id+"-"+tippr->naz+" (SATI) " GET &cVarTP PICT gPics when &cW valid &cV
 		elseif (tippr->fiksan=="P")
    			@ m_x+nRedTP,m_Y+2 SAY tippr->id+"-"+tippr->naz+" (%)    " GET &cVarTP. PICT "999.99" when &cW valid &cV
 		elseif tippr->fiksan=="B"
    			@ m_x+nRedTP,m_Y+2 SAY tippr->id+"-"+tippr->naz+"(BODOVA)" GET &cVarTP. PICT gPici when &cW valid &cV
 		elseif tippr->fiksan=="C"
    			@ m_x+nRedTP,m_Y+2 SAY tippr->id+"-"+tippr->naz+"        " GET cTipPrC when &cW valid &cV
		endif
 	
		@ m_x+nRedTP,m_y+50 SAY "IZNOS" GET &cIznosTP PICT gPici
	endif
	
	if (i%17==0)
		read
		@ m_x+5,m_y+2 CLEAR TO m_x+21,m_y+69
		nRedTP:=4
	endif

	if (i==cLDPolja)
		read
	endif

next

return

// --------------------------------------------------
// validacija WHEN na unosu tipova primanja
// --------------------------------------------------
function WhUnos(cTP)
tippr->(DbSeek(cTP))
return .t.



function UnosSatiPoRNal(nGodina,nMjesec,cIdRadn)
private cRNal[8], nSati[8]
UcitajSateRNal(nGodina,nMjesec,cIdRadn)
@ m_x+10, m_y+2 SAY "Radni nalog" GET cRNal[1] VALID ValRNal(cRNal[1],1)
@ m_x+10, col()+2 SAY "sati" GET nSati[1] WHEN !EMPTY(cRNal[1]) PICT "999.99"
@ m_x+11, m_y+2 SAY "Radni nalog" GET cRNal[2] VALID ValRNal(cRNal[2],2)
@ m_x+11, col()+2 SAY "sati" GET nSati[2] WHEN !EMPTY(cRNal[2]) PICT "999.99"
@ m_x+12, m_y+2 SAY "Radni nalog" GET cRNal[3] VALID ValRNal(cRNal[3],3)
@ m_x+12, col()+2 SAY "sati" GET nSati[3] WHEN !EMPTY(cRNal[3]) PICT "999.99"
@ m_x+13, m_y+2 SAY "Radni nalog" GET cRNal[4] VALID ValRNal(cRNal[4],4)
@ m_x+13, col()+2 SAY "sati" GET nSati[4] WHEN !EMPTY(cRNal[4]) PICT "999.99"
@ m_x+14, m_y+2 SAY "Radni nalog" GET cRNal[5] VALID ValRNal(cRNal[5],5)
@ m_x+14, col()+2 SAY "sati" GET nSati[5] WHEN !EMPTY(cRNal[5]) PICT "999.99"
@ m_x+15, m_y+2 SAY "Radni nalog" GET cRNal[6] VALID ValRNal(cRNal[6],6)
@ m_x+15, col()+2 SAY "sati" GET nSati[6] WHEN !EMPTY(cRNal[6]) PICT "999.99"
@ m_x+16, m_y+2 SAY "Radni nalog" GET cRNal[7] VALID ValRNal(cRNal[7],7)
@ m_x+16, col()+2 SAY "sati" GET nSati[7] WHEN !EMPTY(cRNal[7]) PICT "999.99"
@ m_x+17, m_y+2 SAY "Radni nalog" GET cRNal[8] VALID ValRNal(cRNal[8],8)
@ m_x+17, col()+2 SAY "sati" GET nSati[8] WHEN !EMPTY(cRNal[8]) PICT "999.99"
read
if (LASTKEY()!=K_ESC)
	SnimiSateRNal(nGodina,nMjesec,cIdRadn)
endif
@ m_x+10, m_y+2 CLEAR TO m_x+17,75
return



function ValRNal(cPom,i)
if !EMPTY(cPom)
	P_RNal(@cPom)
	cRNal[i]:=cPom
endif
return .t.


function UcitajSateRNal(nGodina,nMjesec,cIdRadn)
local nArr:=SELECT()
local i:=0
select radsiht
seek str(nGodina,4)+str(nMjesec,2)+cIdRadn
do while !eof() .and. str(field->godina,4)+str(field->mjesec,2)+field->idRadn==str(nGodina,4)+str(nMjesec,2)+cIdRadn
	++i
	cRNal[i]:=field->idRNal
	nSati[i]:=field->sati
	skip 1
enddo
for j:=i+1 to 8
	cRNal[j]:=SPACE(10)
	nSati[j]:=0
next
select (nArr)
return


function SnimiSateRNal(nGodina,nMjesec,cIdRadn)
local nArr:=SELECT()
local nRec
local i
select radsiht
seek str(nGodina,4)+str(nMjesec,2)+cIdRadn
do while !eof() .and. str(field->godina,4)+str(field->mjesec,2)+field->idRadn==str(nGodina,4)+str(nMjesec,2)+cIdRadn
	skip 1
	nRec:=RECNO()
	skip -1
	delete
	go (nRec)
enddo
for i:=1 to 8
	if !EMPTY(cRNal[i])
		append blank
		replace godina with nGodina, mjesec with nMjesec, idRadn with cIdRadn, idRNal with cRNal[i], sati with nSati[i]
	endif
next
select (nArr)
return

