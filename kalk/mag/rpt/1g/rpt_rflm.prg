#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/mag/rpt/1g/rpt_rflm.prg,v $
 * $Author: enespivic $ 
 * $Revision: 1.5 $
 * $Log: rpt_rflm.prg,v $
 * Revision 1.5  2004/03/17 13:15:40  enespivic
 * Na izvjestaju "rekapitulacija fin. stanja po magacinima" nakon ispisa
 * podataka za odgovarajuci konto ispisuje se u novom redu puni naziv konta.
 *
 * Revision 1.4  2002/07/03 23:55:19  ernad
 *
 *
 * ciscenja planika (tragao za nepostojecim bug-om u prelgedu finansijskog obrta)
 *
 * Revision 1.3  2002/06/25 15:08:46  ernad
*
 *
 * prikaz parovno - Planika
 *
 * Revision 1.2  2002/06/20 13:13:03  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/mag/rpt/1g/rpt_rflm.prg
 *  \brief Izvjestaj "rekapitulacija finansijskog stanja po magacinima"
 */


/*! \fn RFLLM()
 *  \brief Izvjestaj "rekapitulacija finansijskog stanja po magacinima"
 */

function RFLLM()
*{

local nKolUlaz
local nKolIzlaz

cIdFirma:=gFirma
cidKonto:=padr("13.",gDuzKonto)
ODbKalk()

dDatOd:=ctod("")
dDatDo:=date()
qqRoba:=space(60)
qqKonto:=space(120)
qqTarifa:=qqidvd:=space(60)
private cPNab:="N"
private cNula:="D",cErr:="N"
Box(,10,60)
do while .t.
 if gNW $ "DX"
   @ m_x+1,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
 else
  @ m_x+1,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 endif
 @ m_x+2,m_y+2 SAY "Konto   " GET cIdKonto valid "." $ cidkonto .or.P_Konto(@cIdKonto)
 @ m_x+4,m_y+2 SAY "Konta   " GET qqKonto  pict "@!S50"
 @ m_x+5,m_y+2 SAY "Tarife  " GET qqTarifa pict "@!S50"
 @ m_x+6,m_y+2 SAY "Artikli " GET qqRoba   pict "@!S50"
 @ m_x+7,m_y+2 SAY "Vrste dokumenata  " GET qqIDVD pict "@!S30"
 @ m_x+8,m_y+2 SAY "Datum od " GET dDatOd
 @ m_x+8,col()+2 SAY "do" GET dDatDo
 @ m_x+9,m_y+2 SAY "Prikazati i ako je saldo=0 ? (D/N)" GET cNula  valid cNula $ "DN" pict "@!"
 read; ESC_BCR
 private aUsl1:=Parsiraj(qqKonto,"MKonto")
 private aUsl2:=Parsiraj(qqTarifa,"IdTarifa")
 private aUsl3:=Parsiraj(qqIDVD,"idvd")
 private aUslR:=Parsiraj(qqRoba,"idroba")
 if aUsl2<>NIL; exit; endif
 if aUsl3<>NIL; exit; endif
 if aUsl4<>NIL; exit; endif
enddo
BoxC()

// sinteticki konto
if len(trim(cidkonto))<=3 .or. "." $ cidkonto
  if "." $ cidkonto
     cidkonto:=strtran(cidkonto,".","")
  endif
  cIdkonto:=trim(cidkonto)
endif


SELECT kalk
set order to 3
//("3","idFirma+mkonto+idroba+dtos(datdok)+MU_I+IdVD","KALK")
hseek cidfirma

select koncij
seek trim(cidkonto)
select kalk

EOF CRET

nLen:=1
m:="----- ----------- ---------- ---------- ---------- ---------- ---------- ---------- ----------"

start print cret

private nTStrana:=0

private bZagl:={|| ZaglRFLLM()}


Eval(bZagl)
nTUlaz:=nTIzlaz:=0
nTVPVU:=nTVPVI:=nTNVU:=nTNVI:=0
nTRabat:=0
nCol1:=nCol0:=50
private nRbr:=0

nKolUlaz:=0
nKolIzlaz:=0

do while !eof() .and. cIdfirma==idfirma .and.  IspitajPrekid()

nUlaz:=nIzlaz:=0
nVPVU:=nVPVI:=nNVU:=nNVI:=0
nRabat:=0

if field->mKonto<>cIdKonto
  skip
  loop
endif

dDatDok:=datdok
cBroj:=mkonto

do while !eof() .and. cIdfirma+cBroj==idFirma+mkonto .and. IspitajPrekid()
  
  if aUsl1<>'.t.'
     if .not. &aUsl1
        skip
	loop
     endif
  endif
  
  if (datdok<dDatOd .or. datdok>dDatDo .or. mkonto<>cIdKonto)
     skip
     loop
  endif
  if aUsl2<>'.t.'
     if .not.  &aUsl2
        skip
	loop
     endif
  endif
  if aUsl3<>'.t.'
    if .not. &aUsl3
       skip
       loop
    endif
  endif
  if aUslR<>'.t.'    
    // roba
    if .not.  &aUslR
       skip 
       loop
    endif
  endif
  if mu_i=="1" .and. !(idvd $ "12#22#94")
    nCol1:=pcol()+1
    nVPVU+=round( vpc*(kolicina-gkolicina-gkolicin2) , gZaokr)
    nNVU+=round( nc*(kolicina-gkolicina-gkolicin2) , gZaokr)
  elseif mu_i=="5"
    nVPVI+=round( vpc*kolicina , gZaokr)
    nRabat+=round( rabatv/100*vpc*kolicina , gZaokr)
    nNVI+=round( nc*kolicina , gZaokr)
  elseif mu_i=="1" .and. (idvd $ "12#22#94")    
    // povrat
    nVPVI-=round( vpc*kolicina , gZaokr)
    nRabat-=round( rabatv/100*vpc*kolicina , gZaokr)
    nNVI-=round( nc*kolicina , gZaokr)
  elseif mu_i=="3"    
    // nivelacija
    nVPVU+=round( vpc*kolicina , gZaokr)
  endif
 
  if IsPlanika()
  	UkupnoKolM(@nKolUlaz, @nKolIzlaz)
  endif
 
  skip
enddo  

if (cNula<>"D" .and. round(nNVU-nNVI,4)==0 .and. round(nVPVU-nVPVI,4)==0)
  loop
endif

NovaStrana(bZagl)

select konto
seek cBroj
cNaz:=KONTO->naz
select kalk


? str(++nrbr,4)+".",padr(cBroj,11)
nCol1=pcol()+1

nTVPVU+=nVPVU; nTVPVI+=nVPVI
nTNVU+=nNVU; nTNVI+=nNVI
nTRabat+=nRabat

 @ prow(),pcol()+1 SAY nNVU pict gpicdem
 @ prow(),pcol()+1 SAY nNVI pict gpicdem
 @ prow(),pcol()+1 SAY nNVU-nNVI pict gpicdem
 @ prow(),pcol()+1 SAY nVPVU pict gpicdem
 @ prow(),pcol()+1 SAY nVPVI pict gpicdem
 @ prow(),pcol()+1 SAY nVPVU-NVPVI pict gpicdem
 @ prow(),pcol()+1 SAY nRabat pict gpicdem
 @ prow()+1,6 SAY cNaz

enddo

? m
? "UKUPNO:"

 @ prow(),nCol1    SAY ntNVU pict gpicdem
 @ prow(),pcol()+1 SAY ntNVI pict gpicdem
 @ prow(),pcol()+1 SAY ntNVU-NtNVI pict gpicdem
 @ prow(),pcol()+1 SAY ntVPVU pict gpicdem
 @ prow(),pcol()+1 SAY ntVPVI pict gpicdem
 @ prow(),pcol()+1 SAY ntVPVU-NtVPVI pict gpicdem
 @ prow(),pcol()+1 SAY ntRabat pict gpicdem

? m

if IsPlanika()
	if (prow()>55+gPStranica)
		FF
	endif
	PrintParovno(nKolUlaz, nKolIzlaz)
endif

FF
end print

#ifdef CAX
 if gKalks
 	select kalk
 	use
 endif
#endif
closeret
return
*}



/*! \fn ZaglRFLLM()
 *  \brief Zaglavlje izvjestaja "rekapitulacija finansijskog stanja po magacinima"
 */

function ZaglRFLLM()
*{
Preduzece()
P_12CPI
select konto; hseek cidkonto
?? space(60)," DATUM "; ?? date(), space(5),"Str:",str(++nTStrana,3)
?
?
? "KALK: Rekapitulacija fin. stanja po magacinima za period",dDatOd,"-",dDatDo
?
?
? "Magacin:",cidkonto,"-",konto->naz
?
if aUsl1<>'.t.'
  ? "Kriterij za konta  :",trim(qqKonto)
endif
if aUslR<>'.t.'
  ? "Kriterij za artikle:",qqRoba
endif
select kalk
P_COND
?
? m
? "R.br *    Konto    *  NV.Dug. *  NV.Pot  *    NV    *  VPV Dug.*  VPV Pot *   VPV    *  Rabat  *"
? m
return
*}


