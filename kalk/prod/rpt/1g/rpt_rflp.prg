#include "\cl\sigma\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/prod/rpt/1g/rpt_rflp.prg,v $
 * $Author: sasavranic $ 
 * $Revision: 1.8 $
 * $Log: rpt_rflp.prg,v $
 * Revision 1.8  2004/05/19 12:16:55  sasavranic
 * no message
 *
 * Revision 1.7  2003/11/11 14:06:35  sasavranic
 * Uvodjenje f-je IspisNaDan()
 *
 * Revision 1.6  2003/09/29 13:26:56  mirsadsubasic
 * sredjivanje koda za poreze u ugostiteljstvu
 *
 * Revision 1.5  2003/09/20 07:37:07  mirsad
 * sredj.koda za poreze u MP
 *
 * Revision 1.4  2002/07/22 14:16:03  mirsad
 * dodao proracun poreza u ugostiteljstvu (varijante "M" i "J")
 *
 * Revision 1.3  2002/06/25 15:08:47  ernad
 *
 *
 * prikaz parovno - Planika
 *
 * Revision 1.2  2002/06/21 12:12:24  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/prod/rpt/1g/rpt_rflp.prg
 *  \brief Izvjestaj "rekapit.finansijskog stanja po objektima"
 */


/*! \fn RFLLP()
 *  \brief Izvjestaj "rekapit.finansijskog stanja po objektima"
 */

function RFLLP()
*{

local nKolUlaz
local nKolIzlaz

private aPorezi
aPorezi:={}

cIdFirma:=gFirma
cidKonto:=padr("132.",gDuzKonto)
if IzFMKIni("Svi","Sifk")=="D"
   O_SIFK
   O_SIFV
endif
O_ROBA
O_TARIFA
O_KONCIJ
O_KONTO
O_PARTN

dDatOd:=ctod("")
dDatDo:=date()
qqRoba:=space(60)
qqTarifa:=qqidvd:=space(60)
private cPNab:="N"
private cNula:="D",cErr:="N"
private cTU:="2"
if IsPlanika()
	private cK9:=SPACE(3)
endif

Box(,9,60)
do while .t.
 if gNW $ "DX"
   @ m_x+1,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
 else
  @ m_x+1,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 endif
 @ m_x+2,m_y+2 SAY "Konto   " GET cIdKonto valid "." $ cidkonto .or.P_Konto(@cIdKonto)
 @ m_x+4,m_y+2 SAY "Tarife  " GET qqTarifa pict "@!S50"
 @ m_x+5,m_y+2 SAY "Artikli " GET qqRoba   pict "@!S50"
 @ m_x+6,m_y+2 SAY "Vrste dokumenata  " GET qqIDVD pict "@!S30"
 @ m_x+7,m_y+2 SAY "Datum od " GET dDatOd
 @ m_x+7,col()+2 SAY "do" GET dDatDo
 @ m_x+8,m_y+2  SAY "Prikaz: roba tipa T / dokumenata IP (1/2)" GET cTU  valid cTU $ "12"
 if IsPlanika()
 	@ m_x+9,m_y+2 SAY "Prikaz po K9" GET cK9 PICT "@!"
 endif
 read
 ESC_BCR
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

O_KALKREP

select kalk
set order to 4
//("KALKi4","idFirma+Pkonto+idroba+dtos(datdok)+PU_I+IdVD","KALK")


cFilt1:="Pkonto="+cm2Str(cIdkonto)

if !empty(dDatOd) .or. !empty(dDatdo)
cFilt1+=".and.DATDOK>="+cm2str(dDatOd)+".and.DATDOK<="+cm2str(dDatDo)
endif

if aUsl2<>".t."
 cFilt1+=".and."+aUsl2
endif
if aUsl3<>".t."
 cFilt1+=".and."+aUsl3
endif
if aUslR<>".t."
 cFilt1+=".and."+aUslR
endif

cFilt1:=strtran(cFilt1,".t..and.","")
set filter to &cFilt1

hseek cIdFirma

select koncij
seek trim(cIdKonto)
select kalk

EOF CRET

nLen:=1
// m:="----- ----------- ---------- ---------- ---------- ---------- ---------- ---------- ----------"
m:="----- ----------- ---------- ---------- ---------- ---------- ---------- ----------"

start print cret

private nTStrana:=0

private bZagl:={|| ZaglRFLLP()}


Eval(bZagl)
nTUlaz:=nTIzlaz:=0
ntMPVU:=ntMPVI:=nTNVU:=nTNVI:=0
ntMPVBU:=ntMPVBI:=0
// nTRabat:=0
nCol1:=nCol0:=50
private nRbr:=0

nMPVBU:=nMPVBI:=0

aRTar:={}


nKolUlaz:=0
nKolIzlaz:=0

do while !eof() .and. cIdFirma==idfirma .and. IspitajPrekid()

nUlaz:=nIzlaz:=0
nMPVU:=nMPVI:=nNVU:=nNVI:=0
nMPVBU:=nMPVBI:=0
// nRabat:=0


dDatDok:=datdok
cBroj:=pkonto
do while !eof() .and. cIdFirma+cBroj==idFirma+pkonto .and. IspitajPrekid()


  select roba
  hseek kalk->idroba

  // uslov po K9, planika
  if (IsPlanika() .and. !EMPTY(cK9) .and. roba->k9 <> cK9)
    select kalk
    skip
    loop
  endif
  
  select kalk

  if cTU=="2" .and.  roba->tip $ "UT"  // prikaz dokumenata IP, a ne robe tipa "T"
     skip; loop
  endif
  if cTU=="1" .and. idvd=="IP"
     skip; loop
  endif

  select roba; hseek kalk->idroba
  select tarifa; hseek kalk->idtarifa; select kalk

  Tarifa(pkonto,idroba,@aPorezi)

  VtPorezi()

  nBezP:=0
  nSaP:=0
  nNV:=0

  if pu_i=="1"
    nBezP  := mpc*kolicina
    nMPVBU += nBezP
    nSaP  := mpcsapp*kolicina
    nMPVU += nSaP
    nNVU  += nc*(kolicina)
    nNV  += nc*(kolicina)
  elseif pu_i=="5"
    nBezP  := -mpc*kolicina
    nSaP   := -mpcsapp*kolicina
    if idvd $ "12#13"
     nMPVBU += nBezP
     nMPVU  += nSaP
     nNVU   -= nc*kolicina
     nNV   -= nc*kolicina
    else
     nMPVBI -= nBezP
     nMPVI  -= nSaP
     nNVI   += nc*kolicina
     nNV   -= nc*kolicina
    endif
  elseif pu_i=="3"    // nivelacija
    nBezP  := mpc*kolicina
    nMPVBU += nBezP
    nSaP   := mpcsapp*kolicina
    nMPVU  += nSaP
  elseif pu_i=="I"
    nBezP  := -MpcBezPor(mpcsapp,aPorezi,,nc)*gkolicin2
    nMPVBI -= nBezP
    nSaP   := -mpcsapp*gkolicin2
    nMPVI  += -nSaP
    nNVI   += nc*gkolicin2
    nNV   -= nc*gkolicin2
  endif

  if IsPlanika()
  	UkupnoKolP(@nKolUlaz, @nKolIzlaz)
  endif
  
  nElem := ASCAN( aRTar , {|x| x[1]==TARIFA->ID} )

  if glUgost
  	nP1:=Izn_P_PPP(nBezP,aPorezi,,nSaP)
  	nP2:=Izn_P_PRugost(nSaP,nBezP,nNV,aPorezi)
  	nP3:=Izn_P_PPUgost(nSaP,nP2,aPorezi)
  else
  	nP1:=Izn_P_PPP(nBezP,aPorezi,,nSaP)
  	nP2:=Izn_P_PPU(nBezP,aPorezi)
  	nP3:=Izn_P_PP(nBezP,aPorezi)
  endif

  IF nElem>0
    aRTar[nElem, 2] += nBezP
    aRTar[nElem, 6] += nP1
    aRTar[nElem, 7] += nP2
    aRTar[nElem, 8] += nP3
    aRTar[nElem, 9] += nP1+nP2+nP3
    aRTar[nElem,10] += nSaP
  ELSE
    AADD( aRTar , { TARIFA->ID , nBezP , _OPP*100 , PrPPUMP() , _ZPP*100,;
                    nP1 , nP2 , nP3 ,;
                    nP1+nP2+nP3 , nSaP } )
  ENDIF

  skip
enddo  // cbroj

if round(nNVU-nNVI,4)==0 .and. round(nMPVU-nMPVI,4)==0
  loop
endif


if prow()>61+gPStranica
	FF
	eval(bZagl)
endif
? str(++nrbr,4)+".",padr(cBroj,11)
nCol1:=pcol()+1

nTMPVU+=nMPVU; nTMPVI+=nMPVI
nTMPVBU+=nMPVBU; nTMPVBI+=nMPVBI
nTNVU+=nNVU; nTNVI+=nNVI

 @ prow(),pcol()+1 SAY nMPVBU pict gpicdem
 @ prow(),pcol()+1 SAY nMPVBI pict gpicdem
 @ prow(),pcol()+1 SAY nMPVBU-nMPVBI pict gpicdem
 @ prow(),pcol()+1 SAY nMPVU pict gpicdem
 @ prow(),pcol()+1 SAY nMPVI pict gpicdem
 @ prow(),pcol()+1 SAY nMPVU-nMPVI pict gpicdem

enddo

? m
? "UKUPNO:"

 @ prow(),nCol1    SAY ntMPVBU pict gpicdem
 @ prow(),pcol()+1 SAY ntMPVBI pict gpicdem
 @ prow(),pcol()+1 SAY ntMPVBU-ntMPVBI pict gpicdem
 @ prow(),pcol()+1 SAY ntMPVU pict gpicdem
 @ prow(),pcol()+1 SAY ntMPVI pict gpicdem
 @ prow(),pcol()+1 SAY ntMPVU-ntMPVI pict gpicdem

? m

M:="------------ ------------- ---------- ----------- ----------- --------- ---------- ---------- ---------- ----------"

P_COND
?
?
?
? "REKAPITULACIJA PO TARIFAMA"
? "--------------------------"
? m
? "*     TARIF *      MPV    *    PPP   *    PPU   *    PP    *   PPP    *   PPU    *   PP     * UKUPNO   * MPV     *"
? "*     BROJ  *             *     %    *     %    *     %    *          *          *          * POREZ    * SA Por  *"
? m

ASORT( aRTar ,,, { |x,y|  x[1] < y[1] } )

nT1:=nT4:=nT5:=nT6:=nT7:=nT5a:=0
FOR i:=1 TO LEN(aRTar)
  if prow()>62+gPStranica
  	FF
  endif
  @ prow()+1,0        SAY space(6)+aRTar[i,1]
  nCol1:=pcol()+4
  @ prow(),pcol()+4   SAY aRTar[i, 2]  PICT  gPicDEM
  @ prow(),pcol()+1   SAY aRTar[i, 3]  PICT  gPicProc
  @ prow(),pcol()+1   SAY aRTar[i, 4]  PICT  gPicProc
  @ prow(),pcol()+1   SAY aRTar[i, 5]  PICT  gPicProc
  @ prow(),pcol()+1   SAY aRTar[i, 6]  PICT  gPicDEM
  @ prow(),pcol()+1   SAY aRTar[i, 7]  PICT  gPicDEM
  @ prow(),pcol()+1   SAY aRTar[i, 8]  PICT  gPicDEM
  @ prow(),pcol()+1   SAY aRTar[i, 9]  PICT  gPicDEM
  @ prow(),pcol()+1   SAY aRTar[i,10]  PICT  gPicDEM
  nT1+=aRTar[i,2];  nT4+=aRTar[i,6];  nT5+=aRTar[i,7] ;  nT5a+=aRTar[i,8]
  nT6+=aRTar[i,9];  nT7+=aRTar[i,10]
NEXT

if prow()>60+gPStranica
	FF
endif
? m
? "UKUPNO:"
@ prow(),nCol1     SAY  nT1  pict gpicdem
@ prow(),pcol()+1  SAY  0    pict "@Z "+gpicdem
@ prow(),pcol()+1  SAY  0    pict "@Z "+gpicdem
@ prow(),pcol()+1  SAY  0    pict "@Z "+gpicdem
@ prow(),pcol()+1  SAY  nT4  pict gpicdem
@ prow(),pcol()+1  SAY  nT5  pict gpicdem
@ prow(),pcol()+1  SAY  nT5a pict gpicdem
@ prow(),pcol()+1  SAY  nT6  pict gpicdem
@ prow(),pcol()+1  SAY  nT7  pict gpicdem
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


/*! \fn ZaglRFLLP()
 *  \brief Zaglavlje izvjestaja "rekapit.finansijskog stanja po objektima"
 */

function ZaglRFLLP()
*{

Preduzece()

P_12CPI
select konto
hseek cidkonto
?? space(60)," DATUM "; ?? date(), space(5),"Str:",str(++nTStrana,3)
IspisNaDan(5)
?
?
? "KALK: Rekapitulacija fin. stanja po objektima za period",dDatOd,"-",dDatDo
?
?
? "Kriterij za objekte:",cidkonto,"-",konto->naz
?
if len(aUslR)<>0
	? "Kriterij za artikle:",qqRoba
endif

if IsPlanika() .and. !EMPTY(cK9)
 	? "Uslov po K9:", cK9
endif

select kalk
P_COND
?
? m
? "R.br * Konto     * MPV.Dug. * MPV.Pot  *   MPV    * MPV sa PP* MPV sa PP*MPV sa PP*"
? "     *           *          *          *          *   Dug    *    Pot   *         *"
? m

return
*}
