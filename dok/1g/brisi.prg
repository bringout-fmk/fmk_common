#include "\dev\fmk\ld\ld.ch"



function BrisiRadnika()
*{
local nTrec
local cIdRadn
local cMjesec
local cIdRj
local fnovi
nUser:=001
O_RADN

if Logirati(goModul:oDataBase:cName,"DOK","BRISIRADNIKA")
	lLogBrRadn:=.t.
else
	lLogBrRadn:=.f.
endif


do while .t.
	O_LD
	cIdRadn:=SPACE(_LR_)
	cIdRj:=gRj
	cMjesec:=gMjesec
	cGodina:=gGodina
	cObracun := gObracun
	Box(,4,60)
		@ m_x+1,m_y+2 SAY "Radna jedinica: "
		QQOUTC(cIdRJ,"N/W")
		@ m_x+2,m_y+2 SAY "Mjesec: "
		QQOUTC(str(cMjesec,2),"N/W")
		if lViseObr
  			@ m_x+2,col()+2 SAY "Obracun: "
			QQOUTC(cObracun,"N/W")
		endif
		@ m_x+3,m_y+2 SAY "Godina: "
		QQOUTC(STR(cGodina,4),"N/W")
		@ m_x+4,m_y+2 SAY "Radnik" GET cIdRadn valid {|| cIdRadn $ "XXXXXX" .or. P_Radn(@cIdRadn),SetPos(m_x+2,m_y+20),QQOUT(TRIM(radn->naz)+" ("+TRIM(radn->imerod)+") "+radn->ime),.t.}
		read
		ESC_BCR
	BoxC()
	
	if GetObrStatus(cIdRj,cGodina,cMjesec)$"ZX"
		MsgBeep("Obracun zakljucen! Ne mozete vrsiti brisanje podataka!!!")
		return
	elseif GetObrStatus(cIdRj,cGodina,cMjesec)=="N"
		MsgBeep("Nema otvorenog obracuna za "+ALLTRIM(STR(cMjesec))+"."+ALLTRIM(STR(cGodina)))
		return
	endif

	if cIdRadn<>"XXXXXX"
		select ld
		seek STR(cGodina,4)+cIdRj+STR(cMjesec,2)+BrojObracuna()+cIdRadn
		if Found()
  			if Pitanje(,"Sigurno zelite izbrisati ovaj zapis D/N","N")=="D"
    				delete
				MsgBeep("Izbrisan obracun za radnika: " + cIdRadn + "  !!!")
  				if lLogBrRadn
					EventLog(nUser,goModul:oDataBase:cName,"DOK","BRISIRADNIKA",nil,nil,nil,nil,cIdRj,STR(cMjesec,2),"Rad:"+cIdRadn+" God:"+STR(cGodina,4),Date(),Date(),"","Brisanje obracuna za jednog radnika")
				endif
			endif
		else
  			Msg("Podatak ne postoji...",4)
		endif
	else
		select ld
		set order to 0
  		if FLock()
   			go top
   			Postotak(1,RecCount(),"Ukloni 0 zapise")
   			do while !eof()
     				nPom:=0
     				Scatter()
     				for i:=1 to cLDPolja
        				cPom:=PadL(ALLTRIM(STR(i)),2,"0")
        				nPom+=(ABS(_i&cPom) + ABS(_s&cPom))
					// ako su sve nule
     				next
     				if (Round(nPom,5)=0)
        				DbDelete2()
     				endif
     				Postotak(2,RecNo())
     				skip
   			enddo
   			Postotak(0)
  		else
    			MsgBeep("Neko vec koristi datoteku LD !!!")
  		endif
	endif
	
	select ld
	use
enddo

closeret
return
*}

function BrisiMjesec()
*{
local cMjesec
local cIdRj
local fnovi
nUser:=001
O_RADN

if Logirati(goModul:oDataBase:cName,"DOK","BRISIMJESEC")
	lLogBrMjesec:=.t.
else
	lLogBrMjesec:=.f.
endif


do while .t.
	O_LD
	cIdRadn:=SPACE(_LR_)
	cIdRj:=gRj
	cMjesec:=gMjesec
	cGodina:=gGodina
	cObracun:=gObracun
	Box(,4,60)
		@ m_x+1,m_y+2 SAY "Radna jedinica: " GET cIdRJ
		@ m_x+2,m_y+2 SAY "Mjesec: "  GET cMjesec pict "99"
		if lViseObr
  			@ m_x+2,col()+2 SAY "Obracun: " GET cObracun WHEN HelpObr(.f.,cObracun) VALID ValObr(.f.,cObracun)
		endif
		@ m_x+3,m_y+2 SAY "Godina: "  GET cGodina pict "9999"
		read
		ClvBox()
		ESC_BCR
	BoxC()
	
	if GetObrStatus(cIdRj,cGodina,cMjesec)$"ZX"
		MsgBeep("Obracun zakljucen! Ne mozete vrsiti brisanje podataka!!!")
		return
	elseif GetObrStatus(cIdRj,cGodina,cMjesec)=="N"
		MsgBeep("Nema otvorenog obracuna za "+ALLTRIM(STR(cMjesec))+"."+ALLTRIM(STR(cGodina)))
		return
	endif

	
	if Pitanje(,"Sigurno zelite izbrisati sve podatke za RJ za ovaj mjesec !?","N")=="N"
		closeret
	endif
	
	MsgO("Sacekajte, brisem podatke....")

	select ld
	
	seek STR(cGodina,4)+cIdRj+STR(cMjesec,2)+BrojObracuna()
	
	do while STR(cGodina,4)+cIdRj+STR(cMjesec,2)==STR(Godina,4)+IdRj+STR(Mjesec,2) .and. if(lViseObr,cObracun==obr,.t.)
   		skip
		nRec:=RecNo()
		skip -1
   		cIdRadn:=idradn
   		delete
		go nRec
	enddo
	
	if lLogBrMjesec
		EventLog(nUser,goModul:oDataBase:cName,"DOK","BRISIMJESEC",nil,nil,nil,nil,cIdRj,STR(cMjesec,2),STR(cGodina,4),Date(),Date(),"","Brisanje obracuna za mjesec")
	endif
	
	MsgBeep("Obracun za " + STR(cMjesec,2) + " mjesec izbrisani !!!")
	MsgC()
	exit
enddo

closeret
return
*}

function LdSmece()
*{
O_LD
O_LDSM
cIdRj:=gRj
cMjesec:=gMjesec
cGodina:=gGodina
cObracun:=" "

Box(,3,70)
	@ m_x+1,m_y+2 SAY "Mjesec:  "  GET cMjesec pict "99"
	@ m_x+1,col()+2 SAY "Godina:  "  GET cGodina pict "9999"
	@ m_x+3,m_y+2   SAY "Obracun: "  GET cObracun
	read
	ESC_BCR
BoxC()

select ldsm

seek cObracun+STR(cGodina,4)+STR(cMjesec,2)

if Found()
	Beep(1)
  	Msg("Ova varijanta obracuna vec postoji u smecu",4)
  	closeret
endif

select ld
set order to tag "2"   
// str(godina)+str(mjesec)+idradn

MsgC("Prenos obracuna u smece")
seek STR(cGodina)+STR(cMjesec)

do while !eof() .and. godina=cGodina .and. mjesec=cMjesec
	Scatter()
   	_Obr:=cObracun
   	select ldsm
   	append blank
   	gather()
   	select ld
   	skip
enddo
MsgC()

closeret
*}


function SmeceLd()
*{
local i
O_LD
O_LDSM

cIdRj:=gRj
cMjesec:=gMjesec
cGodina:=gGodina
cObracun:=" "
cDodati:="N"

Box(,4,70)
	@ m_x+1,  m_y+2 SAY "Mjesec:  "  GET cMjesec pict "99"
 	@ m_x+1,col()+2 SAY "Godina:  "  GET cGodina pict "9999"
 	@ m_x+3,  m_y+2 SAY "Obracun: "  GET cObracun
 	@ m_x+4,  m_y+2 SAY "Dodati (iznose) na postojeci obracun: "  GET cDodati pict "@!" valid cDodati $ "DN"
 	read
	ESC_BCR
BoxC()

select ldsm
seek cObracun+STR(cGodina,4)+STR(cMjesec,2)

if !Found()
	Beep(1)
  	Msg("Ova varijanta obracuna ne postoji u smecu",4)
  	closeret
endif

select ld
set order to tag "2"   
// str(godina)+str(mjesec)+idradn

if Pitanje(,"Sigurno zelite izvrsiti povrat obracuna iz smeca ?","N")=="N"
	closeret
endif

MsgO("Povrat obracuna iz smeca...")

select ldsm
seek cObracun+STR(cGodina)+STR(cMjesec)

do while !eof() .and. cobracun==obr .and. godina=cgodina .and. mjesec=cmjesec
	Scatter()
   	select ld
   	seek STR(_godina)+STR(_mjesec)+_idradn+_idrj
   	if !Found()
     		append blank
     		Gather()
   	else   // postoji zapis
     		if cDodati=="N"  // ne dodaji na postojeci obracun
       			Gather()
     		else
        		private cPom:=""
        		Scatter("w") // stanje u datoteci ld
        		for i:=1 to cLDPolja
         			cPom:=PadL(ALLTRIM(STR(i)),2,"0")
         			wi&cPom+=_i&cPom
        		next
        		wuneto+=_uneto
        		wuodbici+=_uodbici
        		wuiznos+=_uiznos
        		Gather("w")
		endif
	endif
   	
	select ldsm
   	skip
enddo
MsgC()

closeret
return
*}


function BrisiSmece()
*{

local nRec
O_LD
O_LDSM

cIdRj:=gRj
cMjesec:=gMjesec
cGodina:=gGodina
cObracun:=" "

Box(,3,70)
	@ m_x+1,  m_y+2 SAY "Mjesec:  "  GET cMjesec pict "99"
 	@ m_x+1,col()+2 SAY "Godina:  "  GET cGodina pict "9999"
 	@ m_x+3,  m_y+2 SAY "Obracun: "  GET cObracun
 	read
	ESC_BCR
BoxC()

select ldsm
seek cObracun+STR(cGodina,4)+STR(cMjesec,2)

do while !eof() .and. cObracun==obr .and. godina=cGodina .and. mjesec=cMjesec
	skip
	nRec:=RecNo()
	skip -1
  	delete
  	MsgBeep("Obracun izbrisan iz smeca !!!")
	go nRec
enddo
closeret
return
*}

