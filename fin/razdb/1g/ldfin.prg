#include "\cl\sigma\fmk\fin\fin.ch"


/*! \file fmk/fin/razdb/1g/ldfin.prg
 *  \brief Prenos podataka LD->FIN
 */
 
/*! \fn LdFin() 
 *  \brief Prenos podataka LD->FIN
 */

function LdFin()
*{
local cPath, nIznos

private cShema:="1"
private dDatum:=DATE()
private _godina:=YEAR(DATE())
private _mjesec:=MONTH(DATE())

Box("#KONTIRANJE OBRACUNA PLATE",7,75)
	@ m_x+2, m_y+2 SAY "GODINA:" GET _godina PICT "9999"
	@ m_x+3, m_y+2 SAY "MJESEC:" GET _mjesec PICT "99"
	@ m_x+5, m_y+2 SAY "Shema kontiranja:" GET cShema PICT "@!"
	@ m_x+6, m_y+2 SAY "Datum knjizenja :" GET dDatum
	READ
BoxC()

if LASTKEY()==K_ESC
	close all
	return
endif

cPath:=KUMPATH
cPath:=STRTRAN(cPath,SLASH+"FIN",SLASH+"LD")

O_RNAL
O_NALOG
O_PRIPR
O_TRFP3

if file(cPath+"REKLD.DBF")
	use (cPath+"REKLD.DBF") new
	set order to 1
else
	MsgBeep("Niste pokrenuli rekapitulaciju LD-a!")
	close all
	return
endif

if file(cPath+"REKLDP.DBF")
	use (cPath+"REKLDP.DBF") new
	set order to 1
endif

select trfp3
set filter to shema=cShema
go top


if gBrojac=="1"
	select NALOG
	set order to 1
	seek gfirma+trfp3->idvn+"X"
	skip -1
	if idfirma+idvn==gfirma+trfp3->idvn
		cbrnal:=NovaSifra(brnal)
	else
		cbrnal:="0001"
	endif
else
	select NALOG
	set order to 2
	seek gfirma+"X"
	skip -1
	cbrnal:=padl(alltrim(str(val(brnal)+1)),4,"0")
endif

select trfp3

nRBr:=0
nIznos:=0

do while !eof()
	private cPom:=trfp3->id
	if "#RN#"$cPom
		select rnal
		go top
		do while !eof()
			cPom:=trfp3->id
			cBrDok:=rnal->id
			cPom:=STRTRAN(cPom,"#RN#",cBrDok)
			nIznos:=&cPom
			if round(nIznos,2)<>0
				select pripr
				append blank
				replace idvn     with trfp3->idvn
				replace	idfirma  with gFirma
				replace	brnal    with cBrNal
				replace	rbr      with STR(++nRBr,4)
				replace datdok   with dDatum
				replace	idkonto  with trfp3->idkonto
				replace	d_p      with trfp3->d_p
				replace	iznosbhd with nIznos
				replace	brdok    with cBrDok
				replace	opis     with TRIM(trfp3->naz)+" "+STR(_mjesec,2)+"/"+STR(_godina,4)
				select rnal
			endif
			skip 1
		enddo
		select trfp3
	else
		nIznos:=&cPom
		cBrDok:=""
		if round(nIznos,2)<>0
			select pripr
			append blank
			replace idvn     with trfp3->idvn
			replace	idfirma  with gFirma
			replace	brnal    with cBrNal
			replace	rbr      with STR(++nRBr,4)
			replace datdok   with dDatum
			replace	idkonto  with trfp3->idkonto
			replace	d_p      with trfp3->d_p
			replace	iznosbhd with nIznos
			replace	brdok    with cBrDok
			replace	opis     with TRIM(trfp3->naz)+" "+STR(_mjesec,2)+"/"+STR(_godina,4)
			select trfp3
		endif
	endif
	skip 1
enddo

close all
return
*}


/*! \fn RLD(cId, nIz12)
 *  \brief
 *  \param cId
 *  \param nIz12
 */
 
function RLD(cId, nIz12)
*{
local npom1:=0, npom2:=0, nVrati
if nIz12==NIL
	niz12:=1
endif
RekapLD(cid,_godina,_mjesec,@npom1,@npom2)
if nIz12==1
	nVrati:=npom1
else
	nVrati:=npom2
endif
return nVrati
*}


/*! \fn RekapLD(cId, nGodina, nMjesec, nIzn1, nIzn2, cOpis)
 *  \brief Rekapitulacija LD
 *  \param cId
 *  \param nGodina
 *  \param nMjesec
 *  \param nIzn1
 *  \param nIzn2
 *  \param cOpis
 */
function RekapLD(cId, nGodina, nMjesec, nIzn1, nIzn2, cOpis)
*{
local nArr:=SELECT()

if SELECT("REKLD")=0
	return
endif

if copis=NIL
  copis:=""
endif

select rekld
nizn1:=nizn2:=0
seek str(ngodina,4)+str(nmjesec,2)+cid

do while !eof() .and. godina+mjesec+id = str(ngodina,4)+str(nmjesec,2)+cid
	nizn1 += iznos1
	nizn2 += iznos2
	skip 1
enddo

select (nArr)
return
*}


/*! \fn RLDP(cId, cBrDok, nIz12)
 *  \brief
 *  \param cId
 *  \param cBrDok
 *  \param nIz12
 */
function RLDP(cId, cBrDok, nIz12)
*{
local npom1:=0, npom2:=0
if niz12=NIL
	niz12:=1
endif
RekapLDP(cid,_godina,_mjesec,@npom1,@npom2,cBrDok)
if niz12==1
 return npom1
else
 return npom2
endif
return 0
*}


/*! \fn RekapLDP(cId, nGodina, nMjesec, nIzn1, nIzn2, cBrDok)
 *  \brief
 *  \param cId
 *  \param nGodina
 *  \param nMjesec
 *  \param nIzn1
 *  \param nIzn2
 *  \param cBrDok
 */

function RekapLDP(cId, nGodina, nMjesec, nIzn1, nIzn2, cBrDok)
*{
local nArr:=SELECT()

if SELECT("REKLDP")=0
	return
endif

if cBrDok==NIL
  cBrDok:=""
endif

select rekldp
nizn1:=nizn2:=0
seek str(ngodina,4)+str(nmjesec,2)+cid

do while !eof() .and. godina+mjesec+id = str(ngodina,4)+str(nmjesec,2)+cid
	if idrnal=cBrDok
		nizn1 += iznos1
		nizn2 += iznos2
	endif
	skip 1
enddo

select (nArr)
return
*}
