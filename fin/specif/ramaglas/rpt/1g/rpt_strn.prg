#include "\cl\sigma\fmk\fin\fin.ch"


/*! \file fmk/fin/specif/ramaglas/rpt/1g/rpt_strn.prg
 *  \brief Specifikacije troskova radnih naloga - "pogonsko knjigovodstvo"
 */


/*! \fn SpecTrosRN()
 *  \brief Specifikacija troskova po radnim nalozima (tj.objektima)
 */

function SpecTrosRN()
*{

picBHD:=FormPicL("9 "+gPicBHD,17)

cIdFirma:=gFirma
qqRN:=SPACE(40)
dOd:=CTOD("")
dDo:=DATE()

O_PARTN

Box("#SPECIFIKACIJA TROSKOVA PO RADNIM NALOZIMA",10,75)

if gNW=="D"
	@ m_x+2,m_y+2 SAY "Firma "
	?? gFirma,"-",gNFirma
else
	@ m_x+2,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
endif

@ m_x+4, m_y+2 SAY "Radni nalozi (uslov):" GET qqRN
@ m_x+5, m_y+2 SAY "Period: od datuma" GET dOd
@ m_x+5, col()+2 SAY "do datuma" GET dDo

do while .t.
	read
	ESC_BCR
	aUsl1:=Parsiraj(qqRN,"brDok","C")
	aUsl2:=Parsiraj("TD;","konto->oznaka","C")
	if aUsl1<>NIL .and. aUsl2<>NIL
		exit
	endif
enddo

BoxC()

cIdFirma:=left(cIdFirma,2)

O_RNAL
O_KONTO
O_SUBAN

// 1) utvrditi ukupne troskove (nUkTros)
cPom:=IzFmkIni("Troskovi","Uslov",'idKonto="3"',KUMPATH)
set filter to &cPom
go top
nUkTros:=0
do while !EOF()
	nUkTros := nUkTros + IF(field->d_p="1",1,-1)*field->iznosBHD
	skip 1
enddo
set filter to
// ------------------------------

select SUBAN
SET RELATION TO idKonto INTO konto

private cFilt1:="IdFirma=='"+cIdFirma+"'.and."+aUsl1+".and."+aUsl2
private cSort:="brDok+idKonto"
index on &cSort to VEZSUB for &cFilt1


go top
EOF CRET

private m
m:=REPLICATE("-",83)

nUkDirTros:=0
nUkTDP:=0
aTDP:={}
aTD:={}

aIzvj:={}

do while (!eof())
	cBrDok:=field->brDok
	select rnal
	hseek PADR(cBrDok,10)
	AADD(aIzvj,{cBrDok})
	nTekRN:=LEN(aIzvj)
	AADD(aIzvj[nTekRN],"")
	AADD(aIzvj[nTekRN],"Broj radnog naloga : "+cBrDok)
	AADD(aIzvj[nTekRN],"Naziv radnog naloga: "+field->naz)
	AADD(aIzvj[nTekRN],m)
	select suban
	nUkupno:=0
	do while (!eof() .and. field->brDok==cBrDok)
		cIdKonto:=field->idKonto
		cNazKonta:=konto->naz
		nIznos:=0
		lTDP:=(konto->oznaka="TDP")
		do while (!eof() .and. field->brDok==cBrDok .and. field->idKonto==cIdKonto)
			if d_p=="1"
				nIznos+=iznosbhd
			else
				nIznos-=iznosbhd
			endif
			skip 1
		enddo
		// 2) utvrditi ukupne direktne troskove (nUkDirTros)
		nUkDirTros+=nIznos
		// -------------------------------
		if lTDP
			// 4) utvrditi trosak plata proizvodnih radnika po radnom nalogu (aTDP[x])
			nPom:=ASCAN(aTDP, {|x| x[1]==cBrDok})
			if nPom>0
				aTDP[nPom,2]:=aTDP[nPom,2]+nIznos
			else
				AADD(aTDP, {cBrDok, nIznos})
			endif
			// ----------------------------------------------
			// 5) utvrditi ukupni trosak plata proizvodnih radnika (nUkTDP)
			nUkTDP:=nUkTDP+nIznos
			// ----------------------------------------------
		endif
		nUkupno+=nIznos
		AADD(aIzvj[nTekRN],cIdKonto+"-"+cNazKonta+" "+TRANSFORM(nIznos,picBHD))
	enddo
	AADD(aIzvj[nTekRN],m)
	AADD(aIzvj[nTekRN],PADR("UKUPNO DIREKTNI TROSKOVI",LEN(cIdKonto+cNazKonta)+1)+" "+TRANSFORM(nUkupno,picBHD))
	AADD(aIzvj[nTekRN],m)
	AADD(aTD,{cBrDok,nUkupno})
enddo

// 3) ukupni rezijski troskovi (nUkRezTros = nUkTros - nUkDirTros)
nUkRezTros:=nUkTros-nUkDirTros
// ------------------------------------------------

START PRINT CRET

for i:=1 to LEN(aIzvj)
	cBrDok:=aIzvj[i,1]
	for j:=2 to LEN(aIzvj[i])
		? aIzvj[i,j]
	next
	nPom:=ASCAN(aTDP,{|x| x[1]==cBrDok})
	if nPom>0
		// 6) rezijski troskovi po radnom nalogu = nUkRezTros * aTDP[x] / nUkTDP
		nRezTrosRN:=nUkRezTros*aTDP[nPom,2]/nUkTDP
		// ------------------------------------------------
		nPom2:=ASCAN(aTD,{|x| x[1]==cBrDok})
		if nPom2>0
			nDirTrosRN:=aTD[nPom2,2]
		else
			nDirTrosRN:=0
		endif
		? PADR("RASPOREDJENI REZIJSKI TROSKOVI",LEN(cIdKonto+cNazKonta)+1)+" "+TRANSFORM(nRezTrosRN,picBHD)
		? STRTRAN(m,"-","=")
		? PADR("U K U P N I   T R O S K O V I",LEN(cIdKonto+cNazKonta)+1)+" "+TRANSFORM(nDirTrosRN+nRezTrosRN,picBHD)
		? m
	endif
	?
	FF
next

END PRINT

closeret
return
*}






