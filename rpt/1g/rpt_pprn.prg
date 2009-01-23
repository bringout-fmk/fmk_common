#include "ld.ch"


function PlatePoRNalozima()
*{
local aSati:={}

O_RADN
O_PAROBR

O_RADSIHT

O_LD
if lViseObr
	set order to tag "2U"
else
	set order to tag "2"
endif

O_RNAL

cMjesec:=gMjesec
cGodina:=gGodina

Box("#PLATE PO RADNIM NALOZIMA",5,75)
@ m_x+2,m_y+2 SAY "Mjesec: "  GET  cMjesec  pict "99"
@ m_x+3,m_y+2 SAY "Godina: "  GET  cGodina  pict "9999"
read
ESC_BCR
BoxC()

CreRekLDP()
O_REKLDP

select radsiht
seek str(cGodina,4)+str(cMjesec,2)

aRNal:={}

do while !eof() .and. godina=cGodina .and. mjesec=cMjesec
	nUkPlata:=0
	nUkSati:=0
	cIdRadn:=field->idRadn
	select radn
	seek cIdRadn
	
	select radsiht
	aSati:={}
	do while !eof() .and. godina=cGodina .and. mjesec=cMjesec .and. idRadn==cIdRadn
		if field->sati<>0
			nUkSati+=field->sati
			AADD(aSati, {field->idRNal, field->sati})
		endif
		skip 1
	enddo

	if nUkSati==0
		loop
	endif
	
	select ld
	seek str(cGodina,4)+str(cMjesec,2)+cIdRadn
	do while !eof() .and. godina=cGodina .and. mjesec=cMjesec .and. idRadn==cIdRadn
		ParObr(cMjesec,IF(lViseObr,field->obr,),field->idRj)
		_uNeto:=field->uNeto
		for i:=1 to len(aSati)
			altd()
			RekapLdP("UNETO",cGodina,cMjesec,_uNeto*aSati[i,2]/nUkSati,0,,"","",.f.,aSati[i,1])
		next
		nUkPlata+=BrutoP(aSati,nUkSati)
		skip 1
	enddo
	select radsiht
	for i:=1 to LEN(aSati)
		nPom:=ASCAN(aRNal,{|x| x[1]==aSati[i,1]})
		nPom2:=aSati[i,2]*nUkPlata/nUkSati
		if nPom>0
			aRNal[nPom,2]+=nPom2
		else
			AADD(aRNal,{aSati[i,1],nPom2})
		endif
	next
enddo

if LEN(aRNal)=0
	MsgBeep("Nema podataka!")
	closeret
endif

start print cret

	P_12CPI

	? Lokal("LD: BRUTO PLATE PROIZVODNIH RADNIKA PO RADNIM NALOZIMA")
	? "------------------------------------------------------"
	? Lokal("Godina:"),cGodina
	? Lokal("Mjesec:"),cMjesec
	? 
	m:=REPL("-",10)+" "+REPL("-",LEN(rnal->naz))+" "+REPL("-",10)
	? m
	? PADC(Lokal("Sifra i opis radnog naloga"),11+LEN(rnal->naz))+"    " + Lokal("Iznos") + "  "
	? m
	select rnal
	nUkPlata:=0
	for i:=1 to len(aRNal)
		seek aRNal[i,1]
		? aRNal[i,1], rnal->naz, TRANSFORM(aRNal[i,2],"9999999.99")
		nUkPlata+=aRNal[i,2]
	next
	? m
	? Lokal("UKUPNO:") + "   ", SPACE(LEN(rnal->naz)), TRANSFORM(nUkPlata,"9999999.99")
	? m
	?
	? p_potpis()

	FF

end print

closeret
return
*}


function RekapLdP(cId,nGodina,nMjesec,nIzn1,nIzn2,cIdPartner,cOpis,cOpis2,lObavDodaj,cRNal)
*{

if lObavDodaj==nil
	lObavDodaj:=.f.
endif

if cIdPartner=NIL
	cIdPartner=""
endif

if cOpis=nil
	cOpis=""
endif

if cOpis2=nil
  	cOpis2=""
endif

pushwa()

select rekldp
if lObavDodaj
	append blank
else
  	seek str(nGodina,4)+str(nMjesec,2)+PADR(cId,30)+cRNal
  	if !found()
       		append blank
	else
		nIzn1+=rekldp->iznos1
  	endif
endif

replace godina with str(nGodina,4),mjesec with str(nMjesec,2),;
        id    with  cId,;
        iznos1 with nIzn1, iznos2 with nIzn2,;
        idpartner with cIdPartner,;
        opis with cOpis ,;
        opis2 with cOpis2,;
	idRNal with cRNal

popwa()

return
*}



// Kreira pomocnu tabelu REKLDP.DBF
function CreRekLDP()
*{
local aDbf
aDbf:={{"GODINA"     ,  "C" ,  4, 0} ,;
       {"MJESEC"     ,  "C" ,  2, 0} ,;
       {"ID"         ,  "C" , 30, 0} ,;
       {"opis"       ,  "C" , 20, 0} ,;
       {"opis2"      ,  "C" , 35, 0} ,;
       {"iznos1"     ,  "N" , 25, 4} ,;
       {"iznos2"     ,  "N" , 25, 4} ,;
       {"idpartner"  ,  "C" ,  6, 0},;
       {"idRNal"     ,  "C" , 10, 0}}

DBCREATE2(KUMPATH+"REKLDP",aDbf)

select (F_REKLDP)
usex (KUMPATH+"rekldp")

index ON  BRISANO+"10" TAG "BRISAN"
index on  godina+mjesec+id+idRNal  tag "1"

set order to tag "1"
use

return
*}


*******************************************
* izracun bruto iznosa - proizvodni radnici
*******************************************
function BrutoP(aSati,nUkSati)
*{
local nPom, nPom2, nBruto, nPorDopr, i, nBO, nPor, nC1, nPorOl, nDopr, nPom0

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
nBo:=parobr->k3/100*MAX(_UNeto,PAROBR->prosld*gPDLimit/100)

select por
go top

nPom:=nPor:=0
nC1:=30
nPorOl:=0

do while !eof()
	nPom:=max(dlimit,round(iznos/100*MAX(_UNeto,PAROBR->prosld*gPDLimit/100),gZaok))
	for i:=1 to len(aSati)
		RekapLdP("POR"+por->id,cGodina,cMjesec,nPom*aSati[i,2]/nUkSati,0,,"","",.f.,aSati[i,1])
	next
   	nPor+=nPom
   	skip
enddo

nBruto+=nPor
nPorDopr+=nPor

if radn->porol<>0  // poreska olaksica
	nPorOl:=parobr->prosld*radn->porol/100
   	if nPorOl>nPor // poreska olaksica ne moze biti veca od poreza
     		nPorOl:=nPor
   	endif
	for i:=1 to len(aSati)
		RekapLdP("POROL",cGodina,cMjesec,nPorol*aSati[i,2]/nUkSati,0,,"","",.f.,aSati[i,1])
	next
   	nBruto-=nPorol
   	nPorDopr-=nPorOl
endif
if radn->porol<>0
  //? m
  //? "Ukupno Porez"
    //@ prow(),nC1 SAY space(len(gpici))
    //@ prow(),39 SAY nPor-nPorOl pict gpici
   //? m
endif

select dopr
go top

nPom:=nDopr:=0
nC1:=20

do while !eof()  // DOPRINOSI
 	//? id,"-",naz
 	//@ prow(),pcol()+1 SAY iznos pict "99.99%"
 	if empty(idkbenef) // doprinos udara na neto
   		//@ prow(),pcol()+1 SAY nBO pict gpici
   		//nC1:=pcol()+1
   		nPom:=max(dlimit,round(iznos/100*nBO,gZaok))
		if right(id,1)=="X"
   			nBruto+=nPom
   			nPorDopr+=nPom
		endif
		for i:=1 to len(aSati)
			RekapLdP("DOPR"+dopr->id,cGodina,cMjesec,nPom*aSati[i,2]/nUkSati,0,,"","",.f.,aSati[i,1])
		next
 	else
   		nPom0:=ASCAN(aNeta,{|x| x[1]==idkbenef})
   		if nPom0<>0
     			nPom2:=parobr->k3/100*aNeta[nPom0,2]
   		else
     			nPom2:=0
   		endif
   		if round(nPom2,gZaok)<>0
     			//@ prow(),pcol()+1 SAY nPom2 pict gpici
     			//nC1:=pcol()+1
     			nPom:=max(dlimit,round(iznos/100*nPom2,gZaok))
			if right(id,1)=="X"
     				nBruto+=nPom
	     			nPorDopr+=nPom
			endif
			for i:=1 to len(aSati)
				RekapLdP("DOPR"+dopr->id,cGodina,cMjesec,nPom*aSati[i,2]/nUkSati,0,,"","",.f.,aSati[i,1])
			next
   		endif
 	endif

	skip
enddo // doprinosi

return (nBruto)
*}


